From: Anton Blanchard <anton@samba.org>
Subject: [PATCH 09/15] ehea: Merge swqe2 TSO and non TSO paths
Date: Thu, 12 May 2011 10:52:22 +1000
Message-ID: <20110512005623.280091906@samba.org>
References: <20110512005213.897432612@samba.org>
Cc: netdev@vger.kernel.org
To: leitao@linux.vnet.ibm.com, michael@ellerman.id.au,
	jesse@kernel.org, bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:49939 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752035Ab1ELBm6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 May 2011 21:42:58 -0400
Content-Disposition: inline; filename=ehea_12.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

write_swqe2_TSO and write_swqe2_nonTSO are almost identical.

For TSO we have to set the TSO and mss bits in the wqe and we only
put the header in the immediate area, no data. Collapse both
functions into write_swqe2_immediate.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: linux-net/drivers/net/ehea/ehea_main.c
===================================================================
--- linux-net.orig/drivers/net/ehea/ehea_main.c	2011-05-12 07:47:58.020249537 +1000
+++ linux-net/drivers/net/ehea/ehea_main.c	2011-05-12 07:47:59.140267294 +1000
@@ -1677,65 +1677,35 @@ static int ehea_clean_portres(struct ehe
 	return ret;
 }
 
-static void write_swqe2_TSO(struct sk_buff *skb,
-			    struct ehea_swqe *swqe, u32 lkey)
-{
-	struct ehea_vsgentry *sg1entry = &swqe->u.immdata_desc.sg_entry;
-	u8 *imm_data = &swqe->u.immdata_desc.immediate_data[0];
-	int skb_data_size = skb_headlen(skb);
-	int headersize;
-
-	/* Packet is TCP with TSO enabled */
-	swqe->tx_control |= EHEA_SWQE_TSO;
-	swqe->mss = skb_shinfo(skb)->gso_size;
-	/* copy only eth/ip/tcp headers to immediate data and
-	 * the rest of skb->data to sg1entry
-	 */
-	headersize = ETH_HLEN + ip_hdrlen(skb) + tcp_hdrlen(skb);
-
-	skb_data_size = skb_headlen(skb);
-
-	if (skb_data_size >= headersize) {
-		/* copy immediate data */
-		skb_copy_from_linear_data(skb, imm_data, headersize);
-		swqe->immediate_data_length = headersize;
-
-		if (skb_data_size > headersize) {
-			/* set sg1entry data */
-			sg1entry->l_key = lkey;
-			sg1entry->len = skb_data_size - headersize;
-			sg1entry->vaddr =
-				ehea_map_vaddr(skb->data + headersize);
-			swqe->descriptors++;
-		}
-	} else
-		pr_err("cannot handle fragmented headers\n");
-}
-
-static void write_swqe2_nonTSO(struct sk_buff *skb,
-			       struct ehea_swqe *swqe, u32 lkey)
+static void write_swqe2_immediate(struct sk_buff *skb, struct ehea_swqe *swqe,
+				  u32 lkey)
 {
 	int skb_data_size = skb_headlen(skb);
 	u8 *imm_data = &swqe->u.immdata_desc.immediate_data[0];
 	struct ehea_vsgentry *sg1entry = &swqe->u.immdata_desc.sg_entry;
+	unsigned int immediate_len = SWQE2_MAX_IMM;
 
-	/* Packet is any nonTSO type
-	 *
-	 * Copy as much as possible skb->data to immediate data and
-	 * the rest to sg1entry
-	 */
-	if (skb_data_size >= SWQE2_MAX_IMM) {
-		/* copy immediate data */
-		skb_copy_from_linear_data(skb, imm_data, SWQE2_MAX_IMM);
+	swqe->descriptors = 0;
+
+	if (skb_is_gso(skb)) {
+		swqe->tx_control |= EHEA_SWQE_TSO;
+		swqe->mss = skb_shinfo(skb)->gso_size;
+		/*
+		 * For TSO packets we only copy the headers into the
+		 * immediate area.
+		 */
+		immediate_len = ETH_HLEN + ip_hdrlen(skb) + tcp_hdrlen(skb);
+	}
 
-		swqe->immediate_data_length = SWQE2_MAX_IMM;
+	if (skb_is_gso(skb) || skb_data_size >= SWQE2_MAX_IMM) {
+		skb_copy_from_linear_data(skb, imm_data, immediate_len);
+		swqe->immediate_data_length = immediate_len;
 
-		if (skb_data_size > SWQE2_MAX_IMM) {
-			/* copy sg1entry data */
+		if (skb_data_size > immediate_len) {
 			sg1entry->l_key = lkey;
-			sg1entry->len = skb_data_size - SWQE2_MAX_IMM;
+			sg1entry->len = skb_data_size - immediate_len;
 			sg1entry->vaddr =
-				ehea_map_vaddr(skb->data + SWQE2_MAX_IMM);
+				ehea_map_vaddr(skb->data + immediate_len);
 			swqe->descriptors++;
 		}
 	} else {
@@ -1754,13 +1724,9 @@ static inline void write_swqe2_data(stru
 	nfrags = skb_shinfo(skb)->nr_frags;
 	sg1entry = &swqe->u.immdata_desc.sg_entry;
 	sg_list = (struct ehea_vsgentry *)&swqe->u.immdata_desc.sg_list;
-	swqe->descriptors = 0;
 	sg1entry_contains_frag_data = 0;
 
-	if (skb_is_gso(skb))
-		write_swqe2_TSO(skb, swqe, lkey);
-	else
-		write_swqe2_nonTSO(skb, swqe, lkey);
+	write_swqe2_immediate(skb, swqe, lkey);
 
 	/* write descriptors */
 	if (nfrags > 0) {


