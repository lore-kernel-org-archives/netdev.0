From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH 7/7] bnx2x: expose HW RX VLAN stripping toggle
Date: Tue, 30 Aug 2011 16:30:46 +0200
Message-ID: <1314714646-3642-8-git-send-email-mschmidt@redhat.com>
References: <1314714646-3642-1-git-send-email-mschmidt@redhat.com>
Cc: vladz@broadcom.com, dmitry@broadcom.com, eilong@broadcom.com,
	Michal Schmidt <mschmidt@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3027 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754580Ab1H3ObW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Aug 2011 10:31:22 -0400
In-Reply-To: <1314714646-3642-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow disabling of HW RX VLAN stripping with ethtool.

[v2: Store the flag in the fp to ensure that pending packets are
     handled correctly during a switch.]

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |    2 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |   29 ++++++++++++++++------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   10 ++++----
 3 files changed, 28 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 02fa7a7..e70a208 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -479,6 +479,7 @@ struct bnx2x_fastpath {
 	u8			igu_sb_id;	/* status block number in HW */
 	u8			flags;
 #define FP_TPA			(1 << 0)	/* TPA enabled */
+#define FP_VLAN_STRIP		(1 << 1)	/* RX VLAN headers stripping */
 
 	u16			rx_bd_prod;
 	u16			rx_bd_cons;
@@ -1180,6 +1181,7 @@ struct bnx2x {
 #define NO_MCP_FLAG			(1 << 9)
 
 #define BP_NOMCP(bp)			(bp->flags & NO_MCP_FLAG)
+#define RX_VLAN_STRIP_FLAG		(1 << 10)
 #define MF_FUNC_DIS			(1 << 11)
 #define OWN_CNIC_IRQ			(1 << 12)
 #define NO_ISCSI_OOO_FLAG		(1 << 13)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index d45aaa5..e39ea23 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -66,6 +66,9 @@ static inline void bnx2x_bz_fp(struct bnx2x *bp, int index)
 	 */
 	if ((bp->flags & TPA_ENABLE_FLAG) && !IS_FCOE_FP(fp))
 		fp->flags = FP_TPA;
+
+	if (bp->flags & RX_VLAN_STRIP_FLAG)
+		fp->flags |= FP_VLAN_STRIP;
 }
 
 /**
@@ -359,7 +362,7 @@ static void bnx2x_tpa_start(struct bnx2x_fastpath *fp, u16 queue,
 /**
  * bnx2x_set_lro_mss - calculate the approximate value of the MSS
  *
- * @bp:			driver handle
+ * @fp:			fastpath handle
  * @parsing_flags:	parsing flags from the START CQE
  * @len_on_bd:		total length of the first packet for the
  *			aggregation.
@@ -367,8 +370,8 @@ static void bnx2x_tpa_start(struct bnx2x_fastpath *fp, u16 queue,
  * Approximate value of the MSS for this aggregation calculated using
  * the first packet of it.
  */
-static inline u16 bnx2x_set_lro_mss(struct bnx2x *bp, u16 parsing_flags,
-				    u16 len_on_bd)
+static u16 bnx2x_set_lro_mss(struct bnx2x_fastpath *fp, u16 parsing_flags,
+			     u16 len_on_bd)
 {
 	/*
 	 * TPA arrgregation won't have either IP options or TCP options
@@ -382,6 +385,10 @@ static inline u16 bnx2x_set_lro_mss(struct bnx2x *bp, u16 parsing_flags,
 	else /* IPv4 */
 		hdrs_len += sizeof(struct iphdr);
 
+	/* VLAN header present and not stripped by HW */
+	if ((parsing_flags & PARSING_FLAGS_VLAN) &&
+	    !(fp->flags & FP_VLAN_STRIP))
+		hdrs_len += VLAN_HLEN;
 
 	/* Check if there was a TCP timestamp, if there is it's will
 	 * always be 12 bytes length: nop nop kind length echo val.
@@ -409,9 +416,9 @@ static int bnx2x_fill_frag_skb(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 	frag_size = le16_to_cpu(cqe->pkt_len) - len_on_bd;
 	pages = SGE_PAGE_ALIGN(frag_size) >> SGE_PAGE_SHIFT;
 
-	/* This is needed in order to enable forwarding support */
+	/* Doing LRO, let TCP know the receive MSS */
 	if (frag_size)
-		skb_shinfo(skb)->gso_size = bnx2x_set_lro_mss(bp,
+		skb_shinfo(skb)->gso_size = bnx2x_set_lro_mss(fp,
 					tpa_info->parsing_flags, len_on_bd);
 
 #ifdef BNX2X_STOP_ON_ERROR
@@ -511,7 +518,8 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 
 		if (!bnx2x_fill_frag_skb(bp, fp, queue, skb, cqe, cqe_idx)) {
-			if (tpa_info->parsing_flags & PARSING_FLAGS_VLAN)
+			if ((tpa_info->parsing_flags & PARSING_FLAGS_VLAN) &&
+			    (fp->flags & FP_VLAN_STRIP))
 				__vlan_hwaccel_put_tag(skb, tpa_info->vlan_tag);
 			napi_gro_receive(&fp->napi, skb);
 		} else {
@@ -742,8 +750,8 @@ reuse_rx:
 
 		skb_record_rx_queue(skb, fp->index);
 
-		if (le16_to_cpu(cqe_fp->pars_flags.flags) &
-		    PARSING_FLAGS_VLAN)
+		if ((le16_to_cpu(cqe_fp->pars_flags.flags) &
+		    PARSING_FLAGS_VLAN) && (fp->flags & FP_VLAN_STRIP))
 			__vlan_hwaccel_put_tag(skb,
 					       le16_to_cpu(cqe_fp->vlan_tag));
 		napi_gro_receive(&fp->napi, skb);
@@ -3415,6 +3423,11 @@ int bnx2x_set_features(struct net_device *dev, u32 features)
 	else
 		flags &= ~TPA_ENABLE_FLAG;
 
+	if (features & NETIF_F_HW_VLAN_RX)
+		flags |= RX_VLAN_STRIP_FLAG;
+	else
+		flags &= ~RX_VLAN_STRIP_FLAG;
+
 	if (features & NETIF_F_LOOPBACK) {
 		if (bp->link_params.loopback_mode != LOOPBACK_BMAC) {
 			bp->link_params.loopback_mode = LOOPBACK_BMAC;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 7bc6944..15624bc 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -2719,9 +2719,8 @@ static unsigned long bnx2x_get_q_flags(struct bnx2x *bp,
 		__set_bit(BNX2X_Q_FLG_MCAST, &flags);
 	}
 
-	/* Always set HW VLAN stripping */
-	__set_bit(BNX2X_Q_FLG_VLAN, &flags);
-
+	if (fp->flags & FP_VLAN_STRIP)
+		__set_bit(BNX2X_Q_FLG_VLAN, &flags);
 
 	return flags | bnx2x_get_common_flags(bp, fp, true);
 }
@@ -10262,12 +10261,13 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 
 	dev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 		NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_LRO |
-		NETIF_F_RXCSUM | NETIF_F_RXHASH | NETIF_F_HW_VLAN_TX;
+		NETIF_F_RXCSUM | NETIF_F_RXHASH |
+		NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 
 	dev->vlan_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 		NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_HIGHDMA;
 
-	dev->features |= dev->hw_features | NETIF_F_HW_VLAN_RX;
+	dev->features |= dev->hw_features;
 	if (bp->flags & USING_DAC_FLAG)
 		dev->features |= NETIF_F_HIGHDMA;
 
-- 
1.7.6
