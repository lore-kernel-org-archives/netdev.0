From: Hideo AOKI <haoki@redhat.com>
Subject: [PATCH 3/5] memory accounting
Date: Mon, 29 Oct 2007 17:23:21 -0400
Message-ID: <47264F49.90308@redhat.com>
References: <47264E2D.4080109@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030904090208000809070805"
Cc: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Andi Kleen <andi@firstfloor.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:57006 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752637AbXJ2V3H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 17:29:07 -0400
In-Reply-To: <47264E2D.4080109@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030904090208000809070805
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch adds UDP memory usage accounting in IPv4.

--
Hideo Aoki
Hitachi Computer Products (America) Inc.

--------------030904090208000809070805
Content-Type: text/x-patch;
 name="udp_memory_account_ipv4.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="udp_memory_account_ipv4.patch"


Signed-off-by: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>
Signed-off-by: Hideo Aoki <haoki@redhat.com>

 af_inet.c   |   30 +++++++++++++++++++++++++++++-
 ip_output.c |   25 ++++++++++++++++++++++---
 udp.c       |    9 +++++++++
 3 files changed, 60 insertions(+), 4 deletions(-)

diff -pruN linux-2.6.24-rc1-mem003-ipv4-dev-p2/net/ipv4/af_inet.c linux-2.6.24-rc1-mem003-ipv4-dev-p3/net/ipv4/af_inet.c
--- linux-2.6.24-rc1-mem003-ipv4-dev-p2/net/ipv4/af_inet.c	2007-10-24 11:34:34.000000000 -0400
+++ linux-2.6.24-rc1-mem003-ipv4-dev-p3/net/ipv4/af_inet.c	2007-10-24 19:10:27.000000000 -0400
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
diff -pruN linux-2.6.24-rc1-mem003-ipv4-dev-p2/net/ipv4/ip_output.c linux-2.6.24-rc1-mem003-ipv4-dev-p3/net/ipv4/ip_output.c
--- linux-2.6.24-rc1-mem003-ipv4-dev-p2/net/ipv4/ip_output.c	2007-10-24 11:46:43.000000000 -0400
+++ linux-2.6.24-rc1-mem003-ipv4-dev-p3/net/ipv4/ip_output.c	2007-10-24 12:31:47.000000000 -0400
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
@@ -1202,13 +1211,14 @@ int ip_push_pending_frames(struct sock *
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
@@ -1218,6 +1228,7 @@ int ip_push_pending_frames(struct sock *
 		skb->len += tmp_skb->len;
 		skb->data_len += tmp_skb->len;
 		skb->truesize += tmp_skb->truesize;
+		send_page_size += sk_datagram_pages(tmp_skb->truesize);
 		__sock_put(tmp_skb->sk);
 		tmp_skb->destructor = NULL;
 		tmp_skb->sk = NULL;
@@ -1273,6 +1284,8 @@ int ip_push_pending_frames(struct sock *
 	/* Netfilter gets whole the not fragmented skb. */
 	err = NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL,
 		      skb->dst->dev, dst_output);
+	if (sk->sk_prot->memory_allocated)
+		atomic_sub(send_page_size, sk->sk_prot->memory_allocated);
 	if (err) {
 		if (err > 0)
 			err = inet->recverr ? net_xmit_errno(err) : 0;
@@ -1302,9 +1315,15 @@ void ip_flush_pending_frames(struct sock
 {
 	struct inet_sock *inet = inet_sk(sk);
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
 
 	inet->cork.flags &= ~IPCORK_OPT;
 	kfree(inet->cork.opt);
diff -pruN linux-2.6.24-rc1-mem003-ipv4-dev-p2/net/ipv4/udp.c linux-2.6.24-rc1-mem003-ipv4-dev-p3/net/ipv4/udp.c
--- linux-2.6.24-rc1-mem003-ipv4-dev-p2/net/ipv4/udp.c	2007-10-24 12:27:37.000000000 -0400
+++ linux-2.6.24-rc1-mem003-ipv4-dev-p3/net/ipv4/udp.c	2007-10-26 19:43:20.000000000 -0400
@@ -894,6 +894,9 @@ try_again:
 
 out_free:
 	skb_free_datagram(sk, skb);
+	atomic_sub(sk_datagram_pages(skb->truesize),
+		   sk->sk_prot->memory_allocated);
+
 out:
 	return err;
 
@@ -901,6 +904,8 @@ csum_copy_err:
 	UDP_INC_STATS_BH(UDP_MIB_INERRORS, is_udplite);
 
 	skb_kill_datagram(sk, skb, flags);
+	atomic_sub(sk_datagram_pages(skb->truesize),
+		   sk->sk_prot->memory_allocated);
 
 	if (noblock)
 		return -EAGAIN;
@@ -1025,6 +1030,9 @@ int udp_queue_rcv_skb(struct sock * sk, 
 		goto drop;
 	}
 
+	atomic_add(sk_datagram_pages(skb->truesize),
+		   sk->sk_prot->memory_allocated);
+
 	UDP_INC_STATS_BH(UDP_MIB_INDATAGRAMS, up->pcflag);
 	return 0;
 
@@ -1449,6 +1457,7 @@ struct proto udp_prot = {
 	.hash		   = udp_lib_hash,
 	.unhash		   = udp_lib_unhash,
 	.get_port	   = udp_v4_get_port,
+	.memory_allocated  = &udp_memory_allocated,
 	.obj_size	   = sizeof(struct udp_sock),
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_udp_setsockopt,

--------------030904090208000809070805--
