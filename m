From: Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>
Subject: [RFC/PATCH 3/3] UDP memory usage accounting: measurement
Date: Fri, 21 Sep 2007 21:28:51 +0900
Message-ID: <46F3B903.3070901@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: haoki@redhat.com,
	=?ISO-2022-JP?B?GyRCNUhGIxsoQiAbJEIxUUxAGyhC?=
	<yoshfuji@linux-ipv6.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail9.hitachi.co.jp ([133.145.228.44]:33792 "EHLO
	mail9.hitachi.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753305AbXIUM2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 08:28:55 -0400
Received: from mlsv13.hitachi.co.jp (unknown [133.144.234.166])
	by mail9.hitachi.co.jp (Postfix) with ESMTP id 1747937C91
	for <netdev@vger.kernel.org>; Fri, 21 Sep 2007 21:28:54 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces memory usage measurement for UDP.


signed-off-by: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>
signed-off-by: Hideo Aoki <haoki@redhat.com>

Index: 2.6.23-rc7-udp_limit/net/ipv4/ip_output.c
===================================================================
--- 2.6.23-rc7-udp_limit.orig/net/ipv4/ip_output.c
+++ 2.6.23-rc7-udp_limit/net/ipv4/ip_output.c
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
+			if (sk->sk_protocol == IPPROTO_UDP)
+				atomic_add(sk_datagram_pages(skb->truesize),
+					   sk->sk_prot->memory_allocated);
 
 			/*
 			 *	Fill in the control structures
@@ -1023,6 +1028,8 @@ alloc_new_skb:
 				frag = &skb_shinfo(skb)->frags[i];
 				skb->truesize += PAGE_SIZE;
 				atomic_add(PAGE_SIZE, &sk->sk_wmem_alloc);
+				if (sk->sk_protocol == IPPROTO_UDP)
+					atomic_inc(sk->sk_prot->memory_allocated);
 			} else {
 				err = -EMSGSIZE;
 				goto error;
@@ -1123,7 +1130,9 @@ ssize_t	ip_append_page(struct sock *sk, 
 			if (unlikely(!skb)) {
 				err = -ENOBUFS;
 				goto error;
-			}
+			} else if (sk->sk_protocol == IPPROTO_UDP)
+				atomic_add(sk_datagram_pages(skb->truesize),
+					   sk->sk_prot->memory_allocated);
 
 			/*
 			 *	Fill in the control structures
@@ -1152,6 +1161,8 @@ ssize_t	ip_append_page(struct sock *sk, 
 			/*
 			 * Put the packet on the pending queue.
 			 */
+			atomic_add(sk_datagram_pages(skb->truesize),
+				   sk->sk_prot->memory_allocated);
 			__skb_queue_tail(&sk->sk_write_queue, skb);
 			continue;
 		}
@@ -1202,13 +1213,14 @@ int ip_push_pending_frames(struct sock *
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
@@ -1218,6 +1230,7 @@ int ip_push_pending_frames(struct sock *
 		skb->len += tmp_skb->len;
 		skb->data_len += tmp_skb->len;
 		skb->truesize += tmp_skb->truesize;
+		send_page_size += sk_datagram_pages(tmp_skb->truesize);
 		__sock_put(tmp_skb->sk);
 		tmp_skb->destructor = NULL;
 		tmp_skb->sk = NULL;
@@ -1269,6 +1282,8 @@ int ip_push_pending_frames(struct sock *
 	/* Netfilter gets whole the not fragmented skb. */
 	err = NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL,
 		      skb->dst->dev, dst_output);
+	if (sk->sk_protocol == IPPROTO_UDP)
+		atomic_sub(send_page_size, sk->sk_prot->memory_allocated);
 	if (err) {
 		if (err > 0)
 			err = inet->recverr ? net_xmit_errno(err) : 0;
@@ -1299,8 +1314,12 @@ void ip_flush_pending_frames(struct sock
 	struct inet_sock *inet = inet_sk(sk);
 	struct sk_buff *skb;
 
-	while ((skb = __skb_dequeue_tail(&sk->sk_write_queue)) != NULL)
+	while ((skb = __skb_dequeue_tail(&sk->sk_write_queue)) != NULL) {
+		if (sk->sk_protocol == IPPROTO_UDP)
+			atomic_sub(sk_datagram_pages(skb->truesize),
+				   sk->sk_prot->memory_allocated);
 		kfree_skb(skb);
+	}
 
 	inet->cork.flags &= ~IPCORK_OPT;
 	kfree(inet->cork.opt);
Index: 2.6.23-rc7-udp_limit/net/ipv4/udp.c
===================================================================
--- 2.6.23-rc7-udp_limit.orig/net/ipv4/udp.c
+++ 2.6.23-rc7-udp_limit/net/ipv4/udp.c
@@ -887,6 +887,9 @@ try_again:
 		err = ulen;
 
 out_free:
+	atomic_sub(sk_datagram_pages(skb->truesize),
+		   sk->sk_prot->memory_allocated);
+
 	skb_free_datagram(sk, skb);
 out:
 	return err;
@@ -1019,6 +1022,9 @@ int udp_queue_rcv_skb(struct sock * sk, 
 		goto drop;
 	}
 
+	atomic_add(sk_datagram_pages(skb->truesize), 
+		   sk->sk_prot->memory_allocated);
+
 	UDP_INC_STATS_BH(UDP_MIB_INDATAGRAMS, up->pcflag);
 	return 0;
 
@@ -1443,6 +1449,7 @@ struct proto udp_prot = {
 	.hash		   = udp_lib_hash,
 	.unhash		   = udp_lib_unhash,
 	.get_port	   = udp_v4_get_port,
+	.memory_allocated  = &udp_memory_allocated,
 	.obj_size	   = sizeof(struct udp_sock),
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_udp_setsockopt,

