From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [Netchannel] Full TCP receiving support.
Date: Mon, 22 May 2006 20:34:17 +0400
Message-ID: <20060522163414.GA5426@2ka.mipt.ru>
References: <20060516173416.GA22552@2ka.mipt.ru> <20060518103443.GB26183@2ka.mipt.ru> <20060520155202.GA31923@2ka.mipt.ru> <20060521.230617.64626468.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, kelly@au1.ibm.com, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:42932 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1750963AbWEVQej (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 May 2006 12:34:39 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060521.230617.64626468.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, developers.

Attached patch implements full TCP input processing for netchannels [1].
It is based on socket processing code and is fairly hairy for now.
Main idea is to queue skbs into netchannels private queue in interrupt
time and then remove skbs and process them in process' context.
To make TCP works userspace procesing code should only perform several
simple steps similar to how backlog is processed in socket code.

Attached patch against previously posted netchannel patches which
mostly implements netchannel_copy_to_user_tcp() function which performs
TCP processing and copies dat ato userspace. As you can see it is quite
trivial.

Current state is quite proof-of-concept, since there are some ugliness
in the code and various uninteresting debugs, so I plan to clean this up
and run some tests to show if such approach works or not.

Full patch and userspace application are available from netchannel homepage [1].

Thank you.

1. Netchannel homepage.
http://tservice.net.ru/~s0mbre/old/?section=projects&item=netchannel

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

diff --git a/net/core/netchannel.c b/net/core/netchannel.c
index a33ed60..7239a49 100644
--- a/net/core/netchannel.c
+++ b/net/core/netchannel.c
@@ -34,6 +34,7 @@
 #include <linux/in.h>
 #include <linux/ip.h>
 #include <linux/tcp.h>
+#include <net/tcp.h>
 #include <linux/udp.h>
 
 #include <linux/netdevice.h>
@@ -221,6 +222,13 @@ static int netchannel_convert_skb_ipv4(s
 	if (skb->len < len || len < (iph->ihl*4))
 		goto inhdr_error;
 
+	if (pskb_trim_rcsum(skb, len))
+		goto inhdr_error;
+	
+	if (iph->ihl > 5)
+		printk("netchannel: IP options: %u.%u.%u.%u -> %u.%u.%u.%u, ihl: %u.\n", 
+				NIPQUAD(iph->saddr), NIPQUAD(iph->daddr), iph->ihl);
+
 	unc->dst = iph->daddr;
 	unc->src = iph->saddr;
 	unc->proto = iph->protocol;
@@ -388,9 +396,12 @@ int netchannel_recv(struct sk_buff *skb)
 		goto unlock;
 	}
 
-	skb_queue_tail(&nc->recv_queue, skb);
 	nc->qlen += skb->len;
+	skb_queue_tail(&nc->recv_queue, skb);
 	wake_up(&nc->wait);
+	
+	if (nc->inode && SOCKET_I(nc->inode)->sk)
+		wake_up(SOCKET_I(nc->inode)->sk->sk_sleep);
 
 unlock:
 	rcu_read_unlock();
@@ -454,58 +465,75 @@ static int netchannel_copy_to_user_tcp(s
 	struct socket *sock;
 	struct sock *sk;
 	struct sk_buff *skb;
-
-	skb = netchannel_get_skb(nc, timeout, &err);
-	if (!skb)
-		return err;
+	struct iovec iov;
+	struct msghdr msg;
+	unsigned flags = MSG_DONTWAIT;
 
 	if (!nc->inode)
-		goto err_out_free;
+		goto err_out;
 	sock = SOCKET_I(nc->inode);
 	if (!sock || !sock->sk)
-		goto err_out_free;
+		goto err_out;
 
 	sk = sock->sk;
 
-	__skb_pull(skb, skb->nh.iph->ihl*4);
+	do {
+		msg.msg_control=NULL;
+		msg.msg_controllen=0;
+		msg.msg_iovlen=1;
+		msg.msg_iov=&iov;
+		msg.msg_name=NULL;
+		msg.msg_namelen=0;
+		msg.msg_flags = flags;
+		iov.iov_len=*len;
+		iov.iov_base=arg;
 
-	skb->h.raw = skb->data;
+		err = sock_recvmsg(sock, &msg, iov.iov_len, flags);
 
-	th = skb->h.th;
+		printk("netchannel: TCP: len: %u, err: %d.\n", *len, err);
 
-	printk("netchannel: TCP: syn: %u, fin: %u, rst: %u, psh: %u, ack: %u, urg: %u, ece: %u, cwr: %u, res1: %u, doff: %u.\n",
-			th->syn, th->fin, th->rst, th->psh, th->ack, th->urg, th->ece, th->cwr, th->res1, th->doff);
-	
-	if (sk->sk_state == TCP_ESTABLISHED) {
-		struct iovec to;
-		unsigned int copied;
-		
-		to.iov_base = arg;
-		to.iov_len = *len;
+		if (err > 0) {
+			*len = err;
+			return 0;
+		} else if (err && err != -EAGAIN)
+			return err;
 
-		copied = skb->len;
-		if (copied > *len)
-			copied = *len;
+		err = 0;
 
-		if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
-			err = skb_copy_datagram_iovec(skb, 0, &to, copied);
-		} else {
-			err = skb_copy_and_csum_datagram_iovec(skb,0, &to);
-		}
+		skb = netchannel_get_skb(nc, timeout, &err);
+		if (!skb)
+			return err;
+
+		__skb_pull(skb, skb->nh.iph->ihl*4);
+
+		skb->h.raw = skb->data;
+
+		th = skb->h.th;
+		TCP_SKB_CB(skb)->seq = ntohl(th->seq);
+		TCP_SKB_CB(skb)->end_seq = (TCP_SKB_CB(skb)->seq + th->syn + th->fin +
+					    skb->len - th->doff * 4);
+		TCP_SKB_CB(skb)->ack_seq = ntohl(th->ack_seq);
+		TCP_SKB_CB(skb)->when	 = 0;
+		TCP_SKB_CB(skb)->flags	 = skb->nh.iph->tos;
+		TCP_SKB_CB(skb)->sacked	 = 0;
 
-		*len = (err == 0)?copied:0;
-	}
-	
-	nc->qlen -= skb->len;
+		printk("netchannel: TCP: syn: %u, fin: %u, rst: %u, psh: %u, ack: %u, urg: %u, ece: %u, cwr: %u, res1: %u, doff: %u.\n",
+				th->syn, th->fin, th->rst, th->psh, th->ack, th->urg, th->ece, th->cwr, th->res1, th->doff);
+		
+		nc->qlen -= skb->len;
 
-	err = sk->sk_backlog_rcv(sk, skb);
-	printk("netchannel: TCP: sk_backlog_rcv() ret: %d.\n", err);
-	return err;
+		err = sk->sk_backlog_rcv(sk, skb);
+		
+		printk("netchannel: TCP: seq=%u, ack=%u, sk_state=%u, backlog_err: %d, sock_qlen: %u.\n", 
+				th->seq, th->ack_seq, sk->sk_state, err, skb_queue_len(&sk->sk_receive_queue));
+		
+		if (err)
+			return err;
+	} while (!err);
 
-err_out_free:
-	nc->qlen -= skb->len;
-	kfree_skb(skb);
+	return 0;
 
+err_out:
 	return err;
 }
 


-- 
	Evgeniy Polyakov
