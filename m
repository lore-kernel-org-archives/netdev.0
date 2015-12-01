From: Sunil Goutham <sunil.kovvuri@gmail.com>
Subject: [PATCH 6/6] net: thunderx: Enable BGX LMAC's RX/TX only after VF is up
Date: Tue,  1 Dec 2015 14:43:43 +0530
Message-ID: <1448961223-41888-7-git-send-email-sunil.kovvuri@gmail.com>
References: <y>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Sunil.Goutham@caviumnetworks.com,
	Sunil Goutham <sgoutham@cavium.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <y>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

Enable or disable BGX LMAC's RX/TX based on corresponding VF's
status. If otherwise, when multiple LMAC's physical link is up
then packets from all LMAC's whose corresponding VF is not yet
initialized will get forwarded to VF0. This is due to VNIC's default
configuration where CPI, RSSI e.t.c point to VF0/QSET0/RQ0.

This patch will prevent multiple copies of packets on VF0.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nic_main.c    |   20 +++++++++++++++++++-
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c |   20 ++++++++++++++++++--
 drivers/net/ethernet/cavium/thunder/thunder_bgx.h |    1 +
 3 files changed, 38 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nic_main.c b/drivers/net/ethernet/cavium/thunder/nic_main.c
index cfc24a1..4b7fd63 100644
--- a/drivers/net/ethernet/cavium/thunder/nic_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nic_main.c
@@ -37,6 +37,7 @@ struct nicpf {
 #define	NIC_GET_BGX_FROM_VF_LMAC_MAP(map)	((map >> 4) & 0xF)
 #define	NIC_GET_LMAC_FROM_VF_LMAC_MAP(map)	(map & 0xF)
 	u8			vf_lmac_map[MAX_LMAC];
+	u8			lmac_cnt;
 	struct delayed_work     dwork;
 	struct workqueue_struct *check_link;
 	u8			link[MAX_LMAC];
@@ -279,6 +280,7 @@ static void nic_set_lmac_vf_mapping(struct nicpf *nic)
 	u64 lmac_credit;
 
 	nic->num_vf_en = 0;
+	nic->lmac_cnt = 0;
 
 	for (bgx = 0; bgx < NIC_MAX_BGX; bgx++) {
 		if (!(bgx_map & (1 << bgx)))
@@ -288,6 +290,7 @@ static void nic_set_lmac_vf_mapping(struct nicpf *nic)
 			nic->vf_lmac_map[next_bgx_lmac++] =
 						NIC_SET_VF_LMAC_MAP(bgx, lmac);
 		nic->num_vf_en += lmac_cnt;
+		nic->lmac_cnt += lmac_cnt;
 
 		/* Program LMAC credits */
 		lmac_credit = (1ull << 1); /* channel credit enable */
@@ -715,6 +718,13 @@ static void nic_handle_mbx_intr(struct nicpf *nic, int vf)
 	case NIC_MBOX_MSG_CFG_DONE:
 		/* Last message of VF config msg sequence */
 		nic->vf_enabled[vf] = true;
+		if (vf >= nic->lmac_cnt)
+			goto unlock;
+
+		bgx = NIC_GET_BGX_FROM_VF_LMAC_MAP(nic->vf_lmac_map[vf]);
+		lmac = NIC_GET_LMAC_FROM_VF_LMAC_MAP(nic->vf_lmac_map[vf]);
+
+		bgx_lmac_rx_tx_enable(nic->node, bgx, lmac, true);
 		goto unlock;
 	case NIC_MBOX_MSG_SHUTDOWN:
 		/* First msg in VF teardown sequence */
@@ -722,6 +732,14 @@ static void nic_handle_mbx_intr(struct nicpf *nic, int vf)
 		if (vf >= nic->num_vf_en)
 			nic->sqs_used[vf - nic->num_vf_en] = false;
 		nic->pqs_vf[vf] = 0;
+
+		if (vf >= nic->lmac_cnt)
+			break;
+
+		bgx = NIC_GET_BGX_FROM_VF_LMAC_MAP(nic->vf_lmac_map[vf]);
+		lmac = NIC_GET_LMAC_FROM_VF_LMAC_MAP(nic->vf_lmac_map[vf]);
+
+		bgx_lmac_rx_tx_enable(nic->node, bgx, lmac, false);
 		break;
 	case NIC_MBOX_MSG_ALLOC_SQS:
 		nic_alloc_sqs(nic, &mbx.sqs_alloc);
@@ -940,7 +958,7 @@ static void nic_poll_for_link(struct work_struct *work)
 
 	mbx.link_status.msg = NIC_MBOX_MSG_BGX_LINK_CHANGE;
 
-	for (vf = 0; vf < nic->num_vf_en; vf++) {
+	for (vf = 0; vf < nic->lmac_cnt; vf++) {
 		/* Poll only if VF is UP */
 		if (!nic->vf_enabled[vf])
 			continue;
diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
index d9f27ad..c51d5c9 100644
--- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
+++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
@@ -186,6 +186,23 @@ void bgx_set_lmac_mac(int node, int bgx_idx, int lmacid, const u8 *mac)
 }
 EXPORT_SYMBOL(bgx_set_lmac_mac);
 
+void bgx_lmac_rx_tx_enable(int node, int bgx_idx, int lmacid, bool enable)
+{
+	struct bgx *bgx = bgx_vnic[(node * MAX_BGX_PER_CN88XX) + bgx_idx];
+	u64 cfg;
+
+	if (!bgx)
+		return;
+
+	cfg = bgx_reg_read(bgx, lmacid, BGX_CMRX_CFG);
+	if (enable)
+		cfg |= CMR_PKT_RX_EN | CMR_PKT_TX_EN;
+	else
+		cfg &= ~(CMR_PKT_RX_EN | CMR_PKT_TX_EN);
+	bgx_reg_write(bgx, lmacid, BGX_CMRX_CFG, cfg);
+}
+EXPORT_SYMBOL(bgx_lmac_rx_tx_enable);
+
 static void bgx_sgmii_change_link_state(struct lmac *lmac)
 {
 	struct bgx *bgx = lmac->bgx;
@@ -656,8 +673,7 @@ static int bgx_lmac_enable(struct bgx *bgx, u8 lmacid)
 	}
 
 	/* Enable lmac */
-	bgx_reg_modify(bgx, lmacid, BGX_CMRX_CFG,
-		       CMR_EN | CMR_PKT_RX_EN | CMR_PKT_TX_EN);
+	bgx_reg_modify(bgx, lmacid, BGX_CMRX_CFG, CMR_EN);
 
 	/* Restore default cfg, incase low level firmware changed it */
 	bgx_reg_write(bgx, lmacid, BGX_CMRX_RX_DMAC_CTL, 0x03);
diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.h b/drivers/net/ethernet/cavium/thunder/thunder_bgx.h
index 89a02fa..149e179 100644
--- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.h
+++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.h
@@ -183,6 +183,7 @@ enum MCAST_MODE {
 #define CAM_ACCEPT	1
 
 void octeon_mdiobus_force_mod_depencency(void);
+void bgx_lmac_rx_tx_enable(int node, int bgx_idx, int lmacid, bool enable);
 void bgx_add_dmac_addr(u64 dmac, int node, int bgx_idx, int lmac);
 unsigned bgx_get_map(int node);
 int bgx_get_lmac_count(int node, int bgx);
-- 
1.7.1
