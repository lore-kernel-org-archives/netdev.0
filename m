From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: [PATCH 09/15] ehea: Merge swqe2 TSO and non TSO paths
Date: Fri, 14 Oct 2011 12:31:06 -0300
Message-ID: <1318606272-27647-10-git-send-email-cascardo@linux.vnet.ibm.com>
References: <1318606272-27647-1-git-send-email-cascardo@linux.vnet.ibm.com>
Cc: Anton Blanchard <anton@samba.org>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp01.br.ibm.com ([32.104.18.85]:51436 "EHLO
	e24smtp01.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933217Ab1JNPbs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 11:31:48 -0400
Received: from mailhub1.br.ibm.com (mailhub1.br.ibm.com [9.18.232.109])
	by e24smtp01.br.ibm.com (8.14.4/8.13.1) with ESMTP id p9EGqclT010461
	for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 12:52:38 -0400
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by mailhub1.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p9EFZJkF1503470
	for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 12:35:21 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p9EFVZoF008754
	for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 12:31:35 -0300
In-Reply-To: <1318606272-27647-1-git-send-email-cascardo@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Blanchard <anton@samba.org>

write_swqe2_TSO and write_swqe2_nonTSO are almost identical.

For TSO we have to set the TSO and mss bits in the wqe and we only
put the header in the immediate area, no data. Collapse both
functions into write_swqe2_immediate.

Signed-off-by: Anton Blanchard <anton@samba.org>
Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ehea/ehea_main.c |   76 ++++++++---------------------
 1 files changed, 21 insertions(+), 55 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index 77aafba..0fc0ae8 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -1676,65 +1676,35 @@ static int ehea_clean_portres(struct ehea_port *port, struct ehea_port_res *pr)
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
+
+	swqe->descriptors = 0;
 
-	/* Packet is any nonTSO type
-	 *
-	 * Copy as much as possible skb->data to immediate data and
-	 * the rest to sg1entry
-	 */
-	if (skb_data_size >= SWQE2_MAX_IMM) {
-		/* copy immediate data */
-		skb_copy_from_linear_data(skb, imm_data, SWQE2_MAX_IMM);
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
@@ -1753,13 +1723,9 @@ static inline void write_swqe2_data(struct sk_buff *skb, struct net_device *dev,
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
-- 
1.7.4.4
