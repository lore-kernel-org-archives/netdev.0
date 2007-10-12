From: Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>
Subject: [PATCH 3/4] UDP memory accounting and limitation(take 5): memory
 accounting
Date: Fri, 12 Oct 2007 21:10:16 +0900
Message-ID: <470F6428.5020209@hitachi.com>
References: <470F61D4.6040808@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Hideo AOKI <hideo.aoki.tk@hitachi.com>,
	Yumiko SUGITA <yumiko.sugita.yf@hitachi.com>,
	=?ISO-2022-JP?B?IhskQkBETFobKEJAUmVkSGF0Ig==?= <haoki@redhat.com>,
	Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	=?ISO-2022-JP?B?GyRCNUhGIxsoQiAbJEIxUUxAGyhC?=
	<yoshfuji@linux-ipv6.org>
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.hitachi.co.jp ([133.145.228.42]:58371 "EHLO
	mail7.hitachi.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751712AbXJLMKV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 08:10:21 -0400
Received: from mlsv15.hitachi.co.jp (unknown [133.144.234.166])
	by mail7.hitachi.co.jp (Postfix) with ESMTP id 1FF4C37ADA
	for <netdev@vger.kernel.org>; Fri, 12 Oct 2007 21:10:20 +0900 (JST)
In-Reply-To: <470F61D4.6040808@hitachi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces memory usage accounting for UDP.


signed-off-by: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>
signed-off-by: Hideo Aoki <haoki@redhat.com>

Index: 2.6.23-udp_limit/net/ipv4/ip_output.c
===================================================================
--- 2.6.23-udp_limit.orig/net/ipv4/ip_output.c
+++ 2.6.23-udp_limit/net/ipv4/ip_output.c
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
@@ -1269,6 +1280,8 @@ int ip_push_pending_frames(struct sock *
 	/* Netfilter gets whole the not fragmented skb. */
 	err = NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL,
 		      skb->dst->dev, dst_output);
+	if (sk->sk_prot->memory_allocated)
+		atomic_sub(send_page_size, sk->sk_prot->memory_allocated);
 	if (err) {
 		if (err > 0)
 			err = inet->recverr ? net_xmit_errno(err) : 0;
@@ -1298,9 +1311,15 @@ void ip_flush_pending_frames(struct sock
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
Index: 2.6.23-udp_limit/net/ipv4/udp.c
===================================================================
--- 2.6.23-udp_limit.orig/net/ipv4/udp.c
+++ 2.6.23-udp_limit/net/ipv4/udp.c
@@ -885,6 +885,9 @@ try_again:
 		err = ulen;
 
 out_free:
+	atomic_sub(sk_datagram_pages(skb->truesize),
+		   sk->sk_prot->memory_allocated);
+
 	skb_free_datagram(sk, skb);
 out:
 	return err;
@@ -892,6 +895,9 @@ out:
 csum_copy_err:
 	UDP_INC_STATS_BH(UDP_MIB_INERRORS, is_udplite);
 
+	atomic_sub(sk_datagram_pages(skb->truesize),
+		   sk->sk_prot->memory_allocated);
+
 	skb_kill_datagram(sk, skb, flags);
 
 	if (noblock)
@@ -1017,6 +1023,9 @@ int udp_queue_rcv_skb(struct sock * sk, 
 		goto drop;
 	}
 
+	atomic_add(sk_datagram_pages(skb->truesize),
+		   sk->sk_prot->memory_allocated);
+
 	UDP_INC_STATS_BH(UDP_MIB_INDATAGRAMS, up->pcflag);
 	return 0;
 
@@ -1441,6 +1450,7 @@ struct proto udp_prot = {
 	.hash		   = udp_lib_hash,
 	.unhash		   = udp_lib_unhash,
 	.get_port	   = udp_v4_get_port,
+	.memory_allocated  = &udp_memory_allocated,
 	.obj_size	   = sizeof(struct udp_sock),
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_udp_setsockopt,
Index: 2.6.23-udp_limit/net/ipv4/af_inet.c
===================================================================
--- 2.6.23-udp_limit.orig/net/ipv4/af_inet.c
+++ 2.6.23-udp_limit/net/ipv4/af_inet.c
@@ -126,13 +126,41 @@ extern void ip_mc_drop_socket(struct soc
 static struct list_head inetsw[SOCK_MAX];
 static DEFINE_SPINLOCK(inetsw_lock);
 
+/**
+ *	__skb_queue_purge_and_sub_memory_allocated
+ *		- empty a list and subtruct memory allocation counter
+ *	@sk:   sk
+ *	@list: list to empty
+ *	Delete all buffers on an &sk_buff list and subtruct the
+ *	turesize of the sk_buff for memory accounting. Each buffer
+ *	is removed from the list and one reference dropped. This
+ *	function does not take the list lock and the caller must
+ *	hold the relevant locks to use it.
+ */
+void __skb_queue_purge_and_sub_memory_allocated(struct sock *sk,
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

