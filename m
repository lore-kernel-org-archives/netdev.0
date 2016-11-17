From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 3/4] bnxt_en: Add UDP RSS support for 57X1X chips.
Date: Wed, 16 Nov 2016 21:13:09 -0500
Message-ID: <1479348790-6218-4-git-send-email-michael.chan@broadcom.com>
References: <1479348790-6218-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:35462 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933594AbcKQCNc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 21:13:32 -0500
Received: by mail-pf0-f175.google.com with SMTP id i88so45894759pfk.2
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 18:13:31 -0800 (PST)
In-Reply-To: <1479348790-6218-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The newer chips have proper support for 4-tuple UDP RSS.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 21 ++++++++++++++-------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |  3 ++-
 2 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 4db50e8..7401c90 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -3425,13 +3425,7 @@ static int bnxt_hwrm_vnic_set_rss(struct bnxt *bp, u16 vnic_id, bool set_rss)
 
 	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_VNIC_RSS_CFG, -1, -1);
 	if (set_rss) {
-		vnic->hash_type = VNIC_RSS_CFG_REQ_HASH_TYPE_IPV4 |
-				  VNIC_RSS_CFG_REQ_HASH_TYPE_TCP_IPV4 |
-				  VNIC_RSS_CFG_REQ_HASH_TYPE_IPV6 |
-				  VNIC_RSS_CFG_REQ_HASH_TYPE_TCP_IPV6;
-
-		req.hash_type = cpu_to_le32(vnic->hash_type);
-
+		req.hash_type = cpu_to_le32(bp->rss_hash_cfg);
 		if (vnic->flags & BNXT_VNIC_RSS_FLAG) {
 			if (BNXT_CHIP_TYPE_NITRO_A0(bp))
 				max_rings = bp->rx_nr_rings - 1;
@@ -6940,6 +6934,19 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 #endif
 	bnxt_set_dflt_rings(bp);
 
+	/* Default RSS hash cfg. */
+	bp->rss_hash_cfg = VNIC_RSS_CFG_REQ_HASH_TYPE_IPV4 |
+			   VNIC_RSS_CFG_REQ_HASH_TYPE_TCP_IPV4 |
+			   VNIC_RSS_CFG_REQ_HASH_TYPE_IPV6 |
+			   VNIC_RSS_CFG_REQ_HASH_TYPE_TCP_IPV6;
+	if (!BNXT_CHIP_NUM_57X0X(bp->chip_num) &&
+	    !BNXT_CHIP_TYPE_NITRO_A0(bp) &&
+	    bp->hwrm_spec_code >= 0x10501) {
+		bp->flags |= BNXT_FLAG_UDP_RSS_CAP;
+		bp->rss_hash_cfg |= VNIC_RSS_CFG_REQ_HASH_TYPE_UDP_IPV4 |
+				    VNIC_RSS_CFG_REQ_HASH_TYPE_UDP_IPV6;
+	}
+
 	if (BNXT_PF(bp) && !BNXT_CHIP_TYPE_NITRO_A0(bp)) {
 		dev->hw_features |= NETIF_F_NTUPLE;
 		if (bnxt_rfs_capable(bp)) {
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 666bc06..47be789 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -700,7 +700,6 @@ struct bnxt_vnic_info {
 	u8		*uc_list;
 
 	u16		*fw_grp_ids;
-	u16		hash_type;
 	dma_addr_t	rss_table_dma_addr;
 	__le16		*rss_table;
 	dma_addr_t	rss_hash_key_dma_addr;
@@ -952,6 +951,7 @@ struct bnxt {
 	#define BNXT_FLAG_RFS		0x100
 	#define BNXT_FLAG_SHARED_RINGS	0x200
 	#define BNXT_FLAG_PORT_STATS	0x400
+	#define BNXT_FLAG_UDP_RSS_CAP	0x800
 	#define BNXT_FLAG_EEE_CAP	0x1000
 	#define BNXT_FLAG_CHIP_NITRO_A0	0x1000000
 
@@ -1007,6 +1007,7 @@ struct bnxt {
 	struct bnxt_ring_grp_info	*grp_info;
 	struct bnxt_vnic_info	*vnic_info;
 	int			nr_vnics;
+	u32			rss_hash_cfg;
 
 	u8			max_tc;
 	struct bnxt_queue_info	q_info[BNXT_MAX_QUEUE];
-- 
1.8.3.1
