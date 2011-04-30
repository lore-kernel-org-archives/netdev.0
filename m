From: Sasikanth V <sasikanth.v19@gmail.com>
Subject: [PATCH] Removed unnecessary assignments , gotos and goto labels
Date: Sat, 30 Apr 2011 23:53:29 +0530
Message-ID: <1304187809-7887-1-git-send-email-sasikanth.v19@gmail.com>
Cc: netdev@vger.kernel.org, Sasikanth V <sasikanth.v19@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:47169 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752106Ab1D3SYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Apr 2011 14:24:22 -0400
Received: by pwi15 with SMTP id 15so2190921pwi.19
        for <netdev@vger.kernel.org>; Sat, 30 Apr 2011 11:24:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Sasikanth V <sasikanth.v19@gmail.com>
---
 net/packet/af_packet.c |   71 +++++++++++++++++++++---------------------------
 1 files changed, 31 insertions(+), 40 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index b5362e9..5f03ba5 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -182,10 +182,6 @@ struct packet_ring_buffer {
 	atomic_t		pending;
 };
 
-struct packet_sock;
-static int tpacket_snd(struct packet_sock *po, struct msghdr *msg);
-
-static void packet_flush_mclist(struct sock *sk);
 
 struct packet_sock {
 	/* struct sock has to be the first member of packet_sock */
@@ -220,6 +216,9 @@ struct packet_skb_cb {
 	} sa;
 };
 
+static int tpacket_snd(struct packet_sock *po, struct msghdr *msg);
+static void packet_flush_mclist(struct sock *sk);
+
 #define PACKET_SKB_CB(__skb)	((struct packet_skb_cb *)((__skb)->cb))
 
 static inline __pure struct page *pgv_to_page(void *addr)
@@ -1459,16 +1458,14 @@ static int packet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len
 		return -EINVAL;
 
 	if (sll->sll_ifindex) {
-		err = -ENODEV;
 		dev = dev_get_by_index(sock_net(sk), sll->sll_ifindex);
-		if (dev == NULL)
-			goto out;
+		if (!dev)
+			return -ENODEV;
 	}
 	err = packet_do_bind(sk, dev, sll->sll_protocol ? : pkt_sk(sk)->num);
 	if (dev)
 		dev_put(dev);
 
-out:
 	return err;
 }
 
@@ -1498,10 +1495,9 @@ static int packet_create(struct net *net, struct socket *sock, int protocol,
 
 	sock->state = SS_UNCONNECTED;
 
-	err = -ENOBUFS;
 	sk = sk_alloc(net, PF_PACKET, GFP_KERNEL, &packet_proto);
-	if (sk == NULL)
-		goto out;
+	if (!sk)
+		return -ENOBUFS;
 
 	sock->ops = &packet_ops;
 	if (sock->type == SOCK_PACKET)
@@ -1542,8 +1538,6 @@ static int packet_create(struct net *net, struct socket *sock, int protocol,
 	spin_unlock_bh(&net->packet.sklist_lock);
 
 	return 0;
-out:
-	return err;
 }
 
 static int packet_recv_error(struct sock *sk, struct msghdr *msg, int len)
@@ -1552,10 +1546,9 @@ static int packet_recv_error(struct sock *sk, struct msghdr *msg, int len)
 	struct sk_buff *skb, *skb2;
 	int copied, err;
 
-	err = -EAGAIN;
 	skb = skb_dequeue(&sk->sk_error_queue);
-	if (skb == NULL)
-		goto out;
+	if (!skb)
+		return -EAGAIN;
 
 	copied = skb->len;
 	if (copied > len) {
@@ -1563,31 +1556,29 @@ static int packet_recv_error(struct sock *sk, struct msghdr *msg, int len)
 		copied = len;
 	}
 	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
-	if (err)
-		goto out_free_skb;
+	if (!err) {
 
-	sock_recv_timestamp(msg, sk, skb);
+		sock_recv_timestamp(msg, sk, skb);
 
-	serr = SKB_EXT_ERR(skb);
-	put_cmsg(msg, SOL_PACKET, PACKET_TX_TIMESTAMP,
-		 sizeof(serr->ee), &serr->ee);
+		serr = SKB_EXT_ERR(skb);
+		put_cmsg(msg, SOL_PACKET, PACKET_TX_TIMESTAMP,
+				sizeof(serr->ee), &serr->ee);
 
-	msg->msg_flags |= MSG_ERRQUEUE;
-	err = copied;
+		msg->msg_flags |= MSG_ERRQUEUE;
+		err = copied;
 
-	/* Reset and regenerate socket error */
-	spin_lock_bh(&sk->sk_error_queue.lock);
-	sk->sk_err = 0;
-	if ((skb2 = skb_peek(&sk->sk_error_queue)) != NULL) {
-		sk->sk_err = SKB_EXT_ERR(skb2)->ee.ee_errno;
-		spin_unlock_bh(&sk->sk_error_queue.lock);
-		sk->sk_error_report(sk);
-	} else
-		spin_unlock_bh(&sk->sk_error_queue.lock);
+		/* Reset and regenerate socket error */
+		spin_lock_bh(&sk->sk_error_queue.lock);
+		sk->sk_err = 0;
+		if ((skb2 = skb_peek(&sk->sk_error_queue)) != NULL) {
+			sk->sk_err = SKB_EXT_ERR(skb2)->ee.ee_errno;
+			spin_unlock_bh(&sk->sk_error_queue.lock);
+			sk->sk_error_report(sk);
+		} else
+			spin_unlock_bh(&sk->sk_error_queue.lock);
+	}
 
-out_free_skb:
 	kfree_skb(skb);
-out:
 	return err;
 }
 
@@ -1755,9 +1746,9 @@ static int packet_getname_spkt(struct socket *sock, struct sockaddr *uaddr,
 	rcu_read_lock();
 	dev = dev_get_by_index_rcu(sock_net(sk), pkt_sk(sk)->ifindex);
 	if (dev)
-		strncpy(uaddr->sa_data, dev->name, 14);
+		strncpy(uaddr->sa_data, dev->name, sizeof(uaddr->sa_data));
 	else
-		memset(uaddr->sa_data, 0, 14);
+		memset(uaddr->sa_data, 0, sizeof(uaddr->sa_data));
 	rcu_read_unlock();
 	*uaddr_len = sizeof(*uaddr);
 
@@ -1779,15 +1770,15 @@ static int packet_getname(struct socket *sock, struct sockaddr *uaddr,
 	sll->sll_ifindex = po->ifindex;
 	sll->sll_protocol = po->num;
 	sll->sll_pkttype = 0;
+	sll->sll_hatype = 0;	
+	sll->sll_halen = 0;
+
 	rcu_read_lock();
 	dev = dev_get_by_index_rcu(sock_net(sk), po->ifindex);
 	if (dev) {
 		sll->sll_hatype = dev->type;
 		sll->sll_halen = dev->addr_len;
 		memcpy(sll->sll_addr, dev->dev_addr, dev->addr_len);
-	} else {
-		sll->sll_hatype = 0;	/* Bad: we have no ARPHRD_UNSPEC */
-		sll->sll_halen = 0;
 	}
 	rcu_read_unlock();
 	*uaddr_len = offsetof(struct sockaddr_ll, sll_addr) + sll->sll_halen;
-- 
1.7.3.4

