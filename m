From: Hideo AOKI <haoki@redhat.com>
Subject: [PATCH 4/4] [UDP]: memory accounting in IPv4
Date: Mon, 17 Dec 2007 21:38:47 -0500
Message-ID: <476732B7.9040502@redhat.com>
References: <47673195.80004@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Takahiro Yasui <tyasui@redhat.com>,
	Masami Hiramatsu <mhiramat@redhat.com>,
	Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	Bill Fink <billfink@mindspring.com>,
	Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>, haoki@redhat.com
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:55433 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752135AbXLRCpj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 21:45:39 -0500
In-Reply-To: <47673195.80004@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds UDP memory usage accounting in IPv4.

Send buffer accounting is performed by IP layer, because skbuff is
allocated in the layer.

Receive buffer is charged, when the buffer successfully received.
Destructor of the buffer does uncharging and reclaiming, when the
buffer is freed. To set destructor at proper place, we use
__udp_queue_rcv_skb() instead of sock_queue_rcv_skb(). To maintain
consistency of memory accounting, socket lock is used to free receive
buffer in udp_recvmsg().

New packet will be add to backlog when the socket is used by user.

Cc: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>
signed-off-by: Takahiro Yasui <tyasui@redhat.com>
signed-off-by: Masami Hiramatsu <mhiramat@redhat.com>
signed-off-by: Hideo Aoki <haoki@redhat.com>
---

 ip_output.c |   46 +++++++++++++++++++++++++++++++++--
 udp.c       |   78 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 119 insertions(+), 5 deletions(-)

diff -pruN net-2.6-udp-take11a1-p3/net/ipv4/ip_output.c net-2.6-udp-take11a1-p4/net/ipv4/ip_output.c
--- net-2.6-udp-take11a1-p3/net/ipv4/ip_output.c	2007-12-17 14:42:31.000000000 -0500
+++ net-2.6-udp-take11a1-p4/net/ipv4/ip_output.c	2007-12-17 14:42:49.000000000 -0500
@@ -707,6 +707,7 @@ static inline int ip_ufo_append_data(str
 {
 	struct sk_buff *skb;
 	int err;
+	int first_size, second_size;

 	/* There is support for UDP fragmentation offload by network
 	 * device, so create one single skb packet containing complete
@@ -720,6 +721,11 @@ static inline int ip_ufo_append_data(str
 		if (skb == NULL)
 			return err;

+		if (!sk_account_wmem_charge(sk, skb->truesize)) {
+			err = -ENOBUFS;
+			goto fail;
+		}
+
 		/* reserve space for Hardware header */
 		skb_reserve(skb, hh_len);

@@ -736,6 +742,7 @@ static inline int ip_ufo_append_data(str
 		skb->csum = 0;
 		sk->sk_sndmsg_off = 0;
 	}
+	first_size = skb->truesize;

 	err = skb_append_datato_frags(sk,skb, getfrag, from,
 			       (length - transhdrlen));
@@ -743,6 +750,15 @@ static inline int ip_ufo_append_data(str
 		/* specify the length of each IP datagram fragment*/
 		skb_shinfo(skb)->gso_size = mtu - fragheaderlen;
 		skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
+
+		second_size = skb->truesize - first_size;
+		if (!sk_account_wmem_charge(sk, second_size)) {
+			sk_account_uncharge(sk, first_size);
+			sk_mem_reclaim(sk);
+			err = -ENOBUFS;
+			goto fail;
+		}
+
 		__skb_queue_tail(&sk->sk_write_queue, skb);

 		return 0;
@@ -750,6 +766,7 @@ static inline int ip_ufo_append_data(str
 	/* There is not enough support do UFO ,
 	 * so follow normal path
 	 */
+fail:
 	kfree_skb(skb);
 	return err;
 }
@@ -924,6 +941,11 @@ alloc_new_skb:
 			}
 			if (skb == NULL)
 				goto error;
+			if (!sk_account_wmem_charge(sk, skb->truesize)) {
+				err = -ENOBUFS;
+				kfree_skb(skb);
+				goto error;
+			}

 			/*
 			 *	Fill in the control structures
@@ -954,6 +976,8 @@ alloc_new_skb:
 			copy = datalen - transhdrlen - fraggap;
 			if (copy > 0 && getfrag(from, data + transhdrlen, offset, copy, fraggap, skb) < 0) {
 				err = -EFAULT;
+				sk_account_uncharge(sk, skb->truesize);
+				sk_mem_reclaim(sk);
 				kfree_skb(skb);
 				goto error;
 			}
@@ -1023,6 +1047,10 @@ alloc_new_skb:
 				frag = &skb_shinfo(skb)->frags[i];
 				skb->truesize += PAGE_SIZE;
 				atomic_add(PAGE_SIZE, &sk->sk_wmem_alloc);
+				if (!sk_account_wmem_charge(sk, PAGE_SIZE)) {
+					err = -ENOBUFS;
+					goto error;
+				}
 			} else {
 				err = -EMSGSIZE;
 				goto error;
@@ -1124,6 +1152,11 @@ ssize_t	ip_append_page(struct sock *sk,
 				err = -ENOBUFS;
 				goto error;
 			}
+			if (!sk_account_wmem_charge(sk, skb->truesize)) {
+				kfree_skb(skb);
+				err = -ENOBUFS;
+				goto error;
+			}

 			/*
 			 *	Fill in the control structures
@@ -1213,13 +1246,14 @@ int ip_push_pending_frames(struct sock *
 	struct iphdr *iph;
 	__be16 df = 0;
 	__u8 ttl;
-	int err = 0;
+	int err = 0, send_size;

 	if ((skb = __skb_dequeue(&sk->sk_write_queue)) == NULL)
 		goto out;
 	tail_skb = &(skb_shinfo(skb)->frag_list);

 	/* move skb->data to ip header from ext header */
+	send_size = skb->truesize;
 	if (skb->data < skb_network_header(skb))
 		__skb_pull(skb, skb_network_offset(skb));
 	while ((tmp_skb = __skb_dequeue(&sk->sk_write_queue)) != NULL) {
@@ -1229,6 +1263,7 @@ int ip_push_pending_frames(struct sock *
 		skb->len += tmp_skb->len;
 		skb->data_len += tmp_skb->len;
 		skb->truesize += tmp_skb->truesize;
+		send_size += tmp_skb->truesize;
 		__sock_put(tmp_skb->sk);
 		tmp_skb->destructor = NULL;
 		tmp_skb->sk = NULL;
@@ -1284,6 +1319,8 @@ int ip_push_pending_frames(struct sock *
 	/* Netfilter gets whole the not fragmented skb. */
 	err = NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL,
 		      skb->dst->dev, dst_output);
+	sk_account_uncharge(sk, send_size);
+	sk_mem_reclaim(sk);
 	if (err) {
 		if (err > 0)
 			err = inet->recverr ? net_xmit_errno(err) : 0;
@@ -1306,10 +1343,15 @@ error:
 void ip_flush_pending_frames(struct sock *sk)
 {
 	struct sk_buff *skb;
+	int truesize = 0;

-	while ((skb = __skb_dequeue_tail(&sk->sk_write_queue)) != NULL)
+	while ((skb = __skb_dequeue_tail(&sk->sk_write_queue)) != NULL) {
+		truesize += skb->truesize;
 		kfree_skb(skb);
+	}

+	sk_account_uncharge(sk, truesize);
+	sk_mem_reclaim(sk);
 	ip_cork_release(inet_sk(sk));
 }

diff -pruN net-2.6-udp-take11a1-p3/net/ipv4/udp.c net-2.6-udp-take11a1-p4/net/ipv4/udp.c
--- net-2.6-udp-take11a1-p3/net/ipv4/udp.c	2007-12-17 14:42:40.000000000 -0500
+++ net-2.6-udp-take11a1-p4/net/ipv4/udp.c	2007-12-17 18:29:06.000000000 -0500
@@ -897,14 +897,18 @@ try_again:
 		err = ulen;

 out_free:
+	lock_sock(sk);
 	skb_free_datagram(sk, skb);
+	release_sock(sk);
 out:
 	return err;

 csum_copy_err:
 	UDP_INC_STATS_BH(UDP_MIB_INERRORS, is_udplite);

+	lock_sock(sk);
 	skb_kill_datagram(sk, skb, flags);
+	release_sock(sk);

 	if (noblock)
 		return -EAGAIN;
@@ -934,6 +938,53 @@ int udp_disconnect(struct sock *sk, int
 	return 0;
 }

+/**
+ * 	__udp_queue_rcv_skb - put new skb to receive queue of socket
+ *	@sk: socket
+ *	@skb: skbuff
+ *
+ *	This function basically does the same thing as sock_queue_rcv_skb().
+ *	The difference to it is to set another destrucfor which is able to
+ *	do memory accouting.
+ */
+int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
+{
+	int err = 0;
+	int skb_len;
+
+	/* Cast skb->rcvbuf to unsigned... It's pointless, but reduces
+	   number of warnings when compiling with -W --ANK
+	 */
+	if (atomic_read(&sk->sk_rmem_alloc) + skb->truesize >=
+	    (unsigned)sk->sk_rcvbuf) {
+		err = -ENOMEM;
+		goto out;
+	}
+
+	err = sk_filter(sk, skb);
+	if (err)
+		goto out;
+
+	skb->dev = NULL;
+	skb->sk = sk;
+	skb->destructor = sk_datagram_rfree;
+	atomic_add(skb->truesize, &sk->sk_rmem_alloc);
+
+	/* Cache the SKB length before we tack it onto the receive
+	 * queue.  Once it is added it no longer belongs to us and
+	 * may be freed by other threads of control pulling packets
+	 * from the queue.
+	 */
+	skb_len = skb->len;
+
+	skb_queue_tail(&sk->sk_receive_queue, skb);
+
+	if (!sock_flag(sk, SOCK_DEAD))
+		sk->sk_data_ready(sk, skb_len);
+out:
+	return err;
+}
+
 /* returns:
  *  -1: error
  *   0: success
@@ -1022,10 +1073,17 @@ int udp_queue_rcv_skb(struct sock * sk,
 			goto drop;
 	}

-	if ((rc = sock_queue_rcv_skb(sk,skb)) < 0) {
+	if (!sk_account_rmem_charge(sk, skb->truesize)) {
+		UDP_INC_STATS_BH(UDP_MIB_RCVBUFERRORS, up->pcflag);
+		goto drop;
+	}
+
+	if ((rc = __udp_queue_rcv_skb(sk, skb)) < 0) {
 		/* Note that an ENOMEM error is charged twice */
 		if (rc == -ENOMEM)
 			UDP_INC_STATS_BH(UDP_MIB_RCVBUFERRORS, up->pcflag);
+		sk_account_uncharge(sk, skb->truesize);
+		sk_datagram_mem_reclaim(sk);
 		goto drop;
 	}

@@ -1068,7 +1126,15 @@ static int __udp4_lib_mcast_deliver(stru
 				skb1 = skb_clone(skb, GFP_ATOMIC);

 			if (skb1) {
-				int ret = udp_queue_rcv_skb(sk, skb1);
+				int ret = 0;
+
+				bh_lock_sock_nested(sk);
+				if (!sock_owned_by_user(sk))
+					ret = udp_queue_rcv_skb(sk, skb1);
+				else
+					sk_add_backlog(sk, skb1);
+				bh_unlock_sock(sk);
+
 				if (ret > 0)
 					/* we should probably re-process instead
 					 * of dropping packets here. */
@@ -1161,7 +1227,13 @@ int __udp4_lib_rcv(struct sk_buff *skb,
 			       inet_iif(skb), udptable);

 	if (sk != NULL) {
-		int ret = udp_queue_rcv_skb(sk, skb);
+		int ret = 0;
+		bh_lock_sock_nested(sk);
+		if (!sock_owned_by_user(sk))
+			ret = udp_queue_rcv_skb(sk, skb);
+		else
+			sk_add_backlog(sk, skb);
+		bh_unlock_sock(sk);
 		sock_put(sk);

 		/* a return value > 0 means to resubmit the input, but
-- 
Hitachi Computer Products (America) Inc.
