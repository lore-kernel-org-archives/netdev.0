From: Hideo AOKI <haoki@redhat.com>
Subject: [PATCH 3/5] udp: memory accounting
Date: Thu, 15 Nov 2007 16:50:00 -0500
Message-ID: <473CBF08.3000303@redhat.com>
References: <473CBDAD.1010708@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Bill Fink <billfink@mindspring.com>,
	Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:56867 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757732AbXKOV4n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 16:56:43 -0500
In-Reply-To: <473CBDAD.1010708@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds UDP memory usage accounting in IPv4.

signed-off-by: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>
signed-off-by: Hideo Aoki <haoki@redhat.com>
---

 af_inet.c   |   30 +++++++++++++++++++++++++++++-
 ip_output.c |   25 ++++++++++++++++++++++---
 udp.c       |   10 ++++++++++
 3 files changed, 61 insertions(+), 4 deletions(-)

diff -pruN net-2.6-udp-p2/net/ipv4/af_inet.c net-2.6-udp-p3/net/ipv4/af_inet.c
--- net-2.6-udp-p2/net/ipv4/af_inet.c	2007-11-14 10:49:06.000000000 -0500
+++ net-2.6-udp-p3/net/ipv4/af_inet.c	2007-11-15 14:44:18.000000000 -0500
@@ -126,13 +126,41 @@ extern void ip_mc_drop_socket(struct soc
 static struct list_head inetsw[SOCK_MAX];
 static DEFINE_SPINLOCK(inetsw_lock);

+/**
+ *	__skb_queue_purge_and_sub_memory_allocated
+ *		- empty a list and subtruct memory allocation counter
+ *	@sk:   sk
+ *	@list: list to empty
+ *	Delete all buffers on an &sk_buff list and subtruct the
+ *	truesize of the sk_buff for memory accounting. Each buffer
+ *	is removed from the list and one reference dropped. This
+ *	function does not take the list lock and the caller must
+ *	hold the relevant locks to use it.
+ */
+static inline void __skb_queue_purge_and_sub_memory_allocated(struct sock *sk,
+					struct sk_buff_head *list)
+{
+	struct sk_buff *skb;
+	int purged_skb_size = 0;
+	while ((skb = __skb_dequeue(list)) != NULL) {
+		purged_skb_size += sk_datagram_pages(skb->truesize);
+		kfree_skb(skb);
+	}
+	atomic_sub(purged_skb_size, sk->sk_prot->memory_allocated);
+}
+
 /* New destruction routine */

 void inet_sock_destruct(struct sock *sk)
 {
 	struct inet_sock *inet = inet_sk(sk);

-	__skb_queue_purge(&sk->sk_receive_queue);
+	if (sk->sk_prot->memory_allocated && sk->sk_type != SOCK_STREAM)
+		__skb_queue_purge_and_sub_memory_allocated(sk,
+				&sk->sk_receive_queue);
+	else
+		__skb_queue_purge(&sk->sk_receive_queue);
+
 	__skb_queue_purge(&sk->sk_error_queue);

 	if (sk->sk_type == SOCK_STREAM && sk->sk_state != TCP_CLOSE) {
diff -pruN net-2.6-udp-p2/net/ipv4/ip_output.c net-2.6-udp-p3/net/ipv4/ip_output.c
--- net-2.6-udp-p2/net/ipv4/ip_output.c	2007-11-15 14:44:11.000000000 -0500
+++ net-2.6-udp-p3/net/ipv4/ip_output.c	2007-11-15 14:44:18.000000000 -0500
@@ -743,6 +743,8 @@ static inline int ip_ufo_append_data(str
 		/* specify the length of each IP datagram fragment*/
 		skb_shinfo(skb)->gso_size = mtu - fragheaderlen;
 		skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
+		atomic_add(sk_datagram_pages(skb->truesize),
+			   sk->sk_prot->memory_allocated);
 		__skb_queue_tail(&sk->sk_write_queue, skb);

 		return 0;
@@ -924,6 +926,9 @@ alloc_new_skb:
 			}
 			if (skb == NULL)
 				goto error;
+			if (sk->sk_prot->memory_allocated)
+				atomic_add(sk_datagram_pages(skb->truesize),
+					   sk->sk_prot->memory_allocated);

 			/*
 			 *	Fill in the control structures
@@ -1023,6 +1028,8 @@ alloc_new_skb:
 				frag = &skb_shinfo(skb)->frags[i];
 				skb->truesize += PAGE_SIZE;
 				atomic_add(PAGE_SIZE, &sk->sk_wmem_alloc);
+				if (sk->sk_prot->memory_allocated)
+					atomic_inc(sk->sk_prot->memory_allocated);
 			} else {
 				err = -EMSGSIZE;
 				goto error;
@@ -1123,7 +1130,9 @@ ssize_t	ip_append_page(struct sock *sk,
 			if (unlikely(!skb)) {
 				err = -ENOBUFS;
 				goto error;
-			}
+			} else if (sk->sk_prot->memory_allocated)
+				atomic_add(sk_datagram_pages(skb->truesize),
+					   sk->sk_prot->memory_allocated);

 			/*
 			 *	Fill in the control structures
@@ -1213,13 +1222,14 @@ int ip_push_pending_frames(struct sock *
 	struct iphdr *iph;
 	__be16 df = 0;
 	__u8 ttl;
-	int err = 0;
+	int err = 0, send_page_size;

 	if ((skb = __skb_dequeue(&sk->sk_write_queue)) == NULL)
 		goto out;
 	tail_skb = &(skb_shinfo(skb)->frag_list);

 	/* move skb->data to ip header from ext header */
+	send_page_size = sk_datagram_pages(skb->truesize);
 	if (skb->data < skb_network_header(skb))
 		__skb_pull(skb, skb_network_offset(skb));
 	while ((tmp_skb = __skb_dequeue(&sk->sk_write_queue)) != NULL) {
@@ -1229,6 +1239,7 @@ int ip_push_pending_frames(struct sock *
 		skb->len += tmp_skb->len;
 		skb->data_len += tmp_skb->len;
 		skb->truesize += tmp_skb->truesize;
+		send_page_size += sk_datagram_pages(tmp_skb->truesize);
 		__sock_put(tmp_skb->sk);
 		tmp_skb->destructor = NULL;
 		tmp_skb->sk = NULL;
@@ -1284,6 +1295,8 @@ int ip_push_pending_frames(struct sock *
 	/* Netfilter gets whole the not fragmented skb. */
 	err = NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL,
 		      skb->dst->dev, dst_output);
+	if (sk->sk_prot->memory_allocated)
+		atomic_sub(send_page_size, sk->sk_prot->memory_allocated);
 	if (err) {
 		if (err > 0)
 			err = inet->recverr ? net_xmit_errno(err) : 0;
@@ -1306,9 +1319,15 @@ error:
 void ip_flush_pending_frames(struct sock *sk)
 {
 	struct sk_buff *skb;
+	int num_flush_mem = 0;

-	while ((skb = __skb_dequeue_tail(&sk->sk_write_queue)) != NULL)
+	while ((skb = __skb_dequeue_tail(&sk->sk_write_queue)) != NULL) {
+		num_flush_mem += sk_datagram_pages(skb->truesize);
 		kfree_skb(skb);
+	}
+
+	if (sk->sk_prot->memory_allocated)
+		atomic_sub(num_flush_mem, sk->sk_prot->memory_allocated);

 	ip_cork_release(inet_sk(sk));
 }
diff -pruN net-2.6-udp-p2/net/ipv4/udp.c net-2.6-udp-p3/net/ipv4/udp.c
--- net-2.6-udp-p2/net/ipv4/udp.c	2007-11-15 14:44:13.000000000 -0500
+++ net-2.6-udp-p3/net/ipv4/udp.c	2007-11-15 14:44:18.000000000 -0500
@@ -829,6 +829,7 @@ int udp_recvmsg(struct kiocb *iocb, stru
 	unsigned int ulen, copied;
 	int err;
 	int is_udplite = IS_UDPLITE(sk);
+	int truesize;

 	/*
 	 *	Check any passed addresses
@@ -893,14 +894,19 @@ try_again:
 		err = ulen;

 out_free:
+	truesize = skb->truesize;
 	skb_free_datagram(sk, skb);
+	atomic_sub(sk_datagram_pages(truesize), sk->sk_prot->memory_allocated);
+
 out:
 	return err;

 csum_copy_err:
 	UDP_INC_STATS_BH(UDP_MIB_INERRORS, is_udplite);

+	truesize = skb->truesize;
 	skb_kill_datagram(sk, skb, flags);
+	atomic_sub(sk_datagram_pages(truesize), sk->sk_prot->memory_allocated);

 	if (noblock)
 		return -EAGAIN;
@@ -1025,6 +1031,9 @@ int udp_queue_rcv_skb(struct sock * sk,
 		goto drop;
 	}

+	atomic_add(sk_datagram_pages(skb->truesize),
+		   sk->sk_prot->memory_allocated);
+
 	UDP_INC_STATS_BH(UDP_MIB_INDATAGRAMS, up->pcflag);
 	return 0;

@@ -1451,6 +1460,7 @@ struct proto udp_prot = {
 	.hash		   = udp_lib_hash,
 	.unhash		   = udp_lib_unhash,
 	.get_port	   = udp_v4_get_port,
+	.memory_allocated  = &udp_memory_allocated,
 	.obj_size	   = sizeof(struct udp_sock),
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_udp_setsockopt,
-- 
Hitachi Computer Products (America) Inc.
