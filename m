From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] lro: remove dead code
Date: Sun, 29 Dec 2013 11:43:35 -0800
Message-ID: <20131229114335.3fbfd089@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:48262 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751987Ab3L2Tni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Dec 2013 14:43:38 -0500
Received: by mail-pa0-f42.google.com with SMTP id lj1so11002887pab.15
        for <netdev@vger.kernel.org>; Sun, 29 Dec 2013 11:43:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove leftover code that is not used anywhere in current tree.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
 include/linux/inet_lro.h |   23 ------
 net/ipv4/inet_lro.c      |  173 -----------------------------------------------
 2 files changed, 196 deletions(-)

--- a/include/linux/inet_lro.h	2013-12-24 15:15:26.549744142 -0800
+++ b/include/linux/inet_lro.h	2013-12-24 15:16:00.981281385 -0800
@@ -133,33 +133,10 @@ struct net_lro_mgr {
 void lro_receive_skb(struct net_lro_mgr *lro_mgr,
 		     struct sk_buff *skb,
 		     void *priv);
-
-/*
- * Processes a fragment list
- *
- * This functions aggregate fragments and generate SKBs do pass
- * the packets to the stack.
- *
- * @lro_mgr: LRO manager to use
- * @frags: Fragment to be processed. Must contain entire header in first
- *         element.
- * @len: Length of received data
- * @true_size: Actual size of memory the fragment is consuming
- * @priv: Private data that may be used by driver functions
- *        (for example get_tcp_ip_hdr)
- */
-
-void lro_receive_frags(struct net_lro_mgr *lro_mgr,
-		       struct skb_frag_struct *frags,
-		       int len, int true_size, void *priv, __wsum sum);
-
 /*
  * Forward all aggregated SKBs held by lro_mgr to network stack
  */
 
 void lro_flush_all(struct net_lro_mgr *lro_mgr);
 
-void lro_flush_pkt(struct net_lro_mgr *lro_mgr,
-		   struct iphdr *iph, struct tcphdr *tcph);
-
 #endif
--- a/net/ipv4/inet_lro.c	2013-12-24 15:15:26.549744142 -0800
+++ b/net/ipv4/inet_lro.c	2013-12-24 15:16:00.981281385 -0800
@@ -230,29 +230,6 @@ static void lro_add_packet(struct net_lr
 	lro_desc->last_skb = skb;
 }
 
-static void lro_add_frags(struct net_lro_desc *lro_desc,
-			  int len, int hlen, int truesize,
-			  struct skb_frag_struct *skb_frags,
-			  struct iphdr *iph, struct tcphdr *tcph)
-{
-	struct sk_buff *skb = lro_desc->parent;
-	int tcp_data_len = TCP_PAYLOAD_LENGTH(iph, tcph);
-
-	lro_add_common(lro_desc, iph, tcph, tcp_data_len);
-
-	skb->truesize += truesize;
-
-	skb_frags[0].page_offset += hlen;
-	skb_frag_size_sub(&skb_frags[0], hlen);
-
-	while (tcp_data_len > 0) {
-		*(lro_desc->next_frag) = *skb_frags;
-		tcp_data_len -= skb_frag_size(skb_frags);
-		lro_desc->next_frag++;
-		skb_frags++;
-		skb_shinfo(skb)->nr_frags++;
-	}
-}
 
 static int lro_check_tcp_conn(struct net_lro_desc *lro_desc,
 			      struct iphdr *iph,
@@ -371,128 +348,6 @@ out:
 	return 1;
 }
 
-
-static struct sk_buff *lro_gen_skb(struct net_lro_mgr *lro_mgr,
-				   struct skb_frag_struct *frags,
-				   int len, int true_size,
-				   void *mac_hdr,
-				   int hlen, __wsum sum,
-				   u32 ip_summed)
-{
-	struct sk_buff *skb;
-	struct skb_frag_struct *skb_frags;
-	int data_len = len;
-	int hdr_len = min(len, hlen);
-
-	skb = netdev_alloc_skb(lro_mgr->dev, hlen + lro_mgr->frag_align_pad);
-	if (!skb)
-		return NULL;
-
-	skb_reserve(skb, lro_mgr->frag_align_pad);
-	skb->len = len;
-	skb->data_len = len - hdr_len;
-	skb->truesize += true_size;
-	skb->tail += hdr_len;
-
-	memcpy(skb->data, mac_hdr, hdr_len);
-
-	skb_frags = skb_shinfo(skb)->frags;
-	while (data_len > 0) {
-		*skb_frags = *frags;
-		data_len -= skb_frag_size(frags);
-		skb_frags++;
-		frags++;
-		skb_shinfo(skb)->nr_frags++;
-	}
-
-	skb_shinfo(skb)->frags[0].page_offset += hdr_len;
-	skb_frag_size_sub(&skb_shinfo(skb)->frags[0], hdr_len);
-
-	skb->ip_summed = ip_summed;
-	skb->csum = sum;
-	skb->protocol = eth_type_trans(skb, lro_mgr->dev);
-	return skb;
-}
-
-static struct sk_buff *__lro_proc_segment(struct net_lro_mgr *lro_mgr,
-					  struct skb_frag_struct *frags,
-					  int len, int true_size,
-					  void *priv, __wsum sum)
-{
-	struct net_lro_desc *lro_desc;
-	struct iphdr *iph;
-	struct tcphdr *tcph;
-	struct sk_buff *skb;
-	u64 flags;
-	void *mac_hdr;
-	int mac_hdr_len;
-	int hdr_len = LRO_MAX_PG_HLEN;
-	int vlan_hdr_len = 0;
-
-	if (!lro_mgr->get_frag_header ||
-	    lro_mgr->get_frag_header(frags, (void *)&mac_hdr, (void *)&iph,
-				     (void *)&tcph, &flags, priv)) {
-		mac_hdr = skb_frag_address(frags);
-		goto out1;
-	}
-
-	if (!(flags & LRO_IPV4) || !(flags & LRO_TCP))
-		goto out1;
-
-	hdr_len = (int)((void *)(tcph) + TCP_HDR_LEN(tcph) - mac_hdr);
-	mac_hdr_len = (int)((void *)(iph) - mac_hdr);
-
-	lro_desc = lro_get_desc(lro_mgr, lro_mgr->lro_arr, iph, tcph);
-	if (!lro_desc)
-		goto out1;
-
-	if (!lro_desc->active) { /* start new lro session */
-		if (lro_tcp_ip_check(iph, tcph, len - mac_hdr_len, NULL))
-			goto out1;
-
-		skb = lro_gen_skb(lro_mgr, frags, len, true_size, mac_hdr,
-				  hdr_len, 0, lro_mgr->ip_summed_aggr);
-		if (!skb)
-			goto out;
-
-		if ((skb->protocol == htons(ETH_P_8021Q)) &&
-		    !(lro_mgr->features & LRO_F_EXTRACT_VLAN_ID))
-			vlan_hdr_len = VLAN_HLEN;
-
-		iph = (void *)(skb->data + vlan_hdr_len);
-		tcph = (void *)((u8 *)skb->data + vlan_hdr_len
-				+ IP_HDR_LEN(iph));
-
-		lro_init_desc(lro_desc, skb, iph, tcph);
-		LRO_INC_STATS(lro_mgr, aggregated);
-		return NULL;
-	}
-
-	if (lro_desc->tcp_next_seq != ntohl(tcph->seq))
-		goto out2;
-
-	if (lro_tcp_ip_check(iph, tcph, len - mac_hdr_len, lro_desc))
-		goto out2;
-
-	lro_add_frags(lro_desc, len, hdr_len, true_size, frags, iph, tcph);
-	LRO_INC_STATS(lro_mgr, aggregated);
-
-	if ((skb_shinfo(lro_desc->parent)->nr_frags >= lro_mgr->max_aggr) ||
-	    lro_desc->parent->len > (0xFFFF - lro_mgr->dev->mtu))
-		lro_flush(lro_mgr, lro_desc);
-
-	return NULL;
-
-out2: /* send aggregated packets to the stack */
-	lro_flush(lro_mgr, lro_desc);
-
-out1:  /* Original packet has to be posted to the stack */
-	skb = lro_gen_skb(lro_mgr, frags, len, true_size, mac_hdr,
-			  hdr_len, sum, lro_mgr->ip_summed);
-out:
-	return skb;
-}
-
 void lro_receive_skb(struct net_lro_mgr *lro_mgr,
 		     struct sk_buff *skb,
 		     void *priv)
@@ -506,23 +361,6 @@ void lro_receive_skb(struct net_lro_mgr
 }
 EXPORT_SYMBOL(lro_receive_skb);
 
-void lro_receive_frags(struct net_lro_mgr *lro_mgr,
-		       struct skb_frag_struct *frags,
-		       int len, int true_size, void *priv, __wsum sum)
-{
-	struct sk_buff *skb;
-
-	skb = __lro_proc_segment(lro_mgr, frags, len, true_size, priv, sum);
-	if (!skb)
-		return;
-
-	if (lro_mgr->features & LRO_F_NAPI)
-		netif_receive_skb(skb);
-	else
-		netif_rx(skb);
-}
-EXPORT_SYMBOL(lro_receive_frags);
-
 void lro_flush_all(struct net_lro_mgr *lro_mgr)
 {
 	int i;
@@ -534,14 +372,3 @@ void lro_flush_all(struct net_lro_mgr *l
 	}
 }
 EXPORT_SYMBOL(lro_flush_all);
-
-void lro_flush_pkt(struct net_lro_mgr *lro_mgr,
-		  struct iphdr *iph, struct tcphdr *tcph)
-{
-	struct net_lro_desc *lro_desc;
-
-	lro_desc = lro_get_desc(lro_mgr, lro_mgr->lro_arr, iph, tcph);
-	if (lro_desc->active)
-		lro_flush(lro_mgr, lro_desc);
-}
-EXPORT_SYMBOL(lro_flush_pkt);
