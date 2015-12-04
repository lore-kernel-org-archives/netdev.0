From: Pavel Fedin <p.fedin@samsung.com>
Subject: [PATCH] net: thunderx: Remove unnecessary struct nicpf::lmac_cnt
Date: Fri, 04 Dec 2015 18:17:22 +0300
Message-ID: <1449242242-9036-1-git-send-email-p.fedin@samsung.com>
Cc: Sunil Goutham <sgoutham@cavium.com>,
	Robert Richter <rric@kernel.org>,
	Sunil Kovvuri <sunil.kovvuri@gmail.com>,
	youngmin.lee@cavium.com, kin-yip.liu@cavium.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.w1.samsung.com ([210.118.77.14]:13948 "EHLO
	mailout4.w1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751185AbbLDPR3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2015 10:17:29 -0500
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NYU000AAAH27740@mailout4.w1.samsung.com> for
 netdev@vger.kernel.org; Fri, 04 Dec 2015 15:17:26 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit bc69fdfc6c13
("net: thunderx: Enable BGX LMAC's RX/TX only after VF is up")
introduces lmac_cnt member and starts verifying VF number against it.
This is plain wrong, and works only because currently we have hardcoded
1:1 mapping between VFs and LMACs, and num_vf_en and lmac_cnt are always
equal. However in future this may change, and the code will badly
misbehave. The worst consequence of this is failure to deliver link status
messages, causing VFs to go defunct because since commit 0b72a9a1060e
("net: thunderx: Switchon carrier only upon interface link up") VF will
not fully bring itself up without it.

This patch fixes the potential problem by removing unnecessary structure
member and doing VF number checks against correct one.

Additionally some duplicated code is factored out into nic_enable_vf()

Signed-off-by: Pavel Fedin <p.fedin@samsung.com>
---
 drivers/net/ethernet/cavium/thunder/nic_main.c | 39 ++++++++++++--------------
 1 file changed, 18 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nic_main.c b/drivers/net/ethernet/cavium/thunder/nic_main.c
index 4b7fd63..5f24d11 100644
--- a/drivers/net/ethernet/cavium/thunder/nic_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nic_main.c
@@ -37,7 +37,6 @@ struct nicpf {
 #define	NIC_GET_BGX_FROM_VF_LMAC_MAP(map)	((map >> 4) & 0xF)
 #define	NIC_GET_LMAC_FROM_VF_LMAC_MAP(map)	(map & 0xF)
 	u8			vf_lmac_map[MAX_LMAC];
-	u8			lmac_cnt;
 	struct delayed_work     dwork;
 	struct workqueue_struct *check_link;
 	u8			link[MAX_LMAC];
@@ -280,7 +279,6 @@ static void nic_set_lmac_vf_mapping(struct nicpf *nic)
 	u64 lmac_credit;
 
 	nic->num_vf_en = 0;
-	nic->lmac_cnt = 0;
 
 	for (bgx = 0; bgx < NIC_MAX_BGX; bgx++) {
 		if (!(bgx_map & (1 << bgx)))
@@ -290,7 +288,6 @@ static void nic_set_lmac_vf_mapping(struct nicpf *nic)
 			nic->vf_lmac_map[next_bgx_lmac++] =
 						NIC_SET_VF_LMAC_MAP(bgx, lmac);
 		nic->num_vf_en += lmac_cnt;
-		nic->lmac_cnt += lmac_cnt;
 
 		/* Program LMAC credits */
 		lmac_credit = (1ull << 1); /* channel credit enable */
@@ -618,6 +615,21 @@ static int nic_config_loopback(struct nicpf *nic, struct set_loopback *lbk)
 	return 0;
 }
 
+static void nic_enable_vf(struct nicpf *nic, int vf, bool enable)
+{
+	int bgx, lmac;
+
+	nic->vf_enabled[vf] = enable;
+
+	if (vf >= nic->num_vf_en)
+		return;
+
+	bgx = NIC_GET_BGX_FROM_VF_LMAC_MAP(nic->vf_lmac_map[vf]);
+	lmac = NIC_GET_LMAC_FROM_VF_LMAC_MAP(nic->vf_lmac_map[vf]);
+
+	bgx_lmac_rx_tx_enable(nic->node, bgx, lmac, enable);
+}
+
 /* Interrupt handler to handle mailbox messages from VFs */
 static void nic_handle_mbx_intr(struct nicpf *nic, int vf)
 {
@@ -717,29 +729,14 @@ static void nic_handle_mbx_intr(struct nicpf *nic, int vf)
 		break;
 	case NIC_MBOX_MSG_CFG_DONE:
 		/* Last message of VF config msg sequence */
-		nic->vf_enabled[vf] = true;
-		if (vf >= nic->lmac_cnt)
-			goto unlock;
-
-		bgx = NIC_GET_BGX_FROM_VF_LMAC_MAP(nic->vf_lmac_map[vf]);
-		lmac = NIC_GET_LMAC_FROM_VF_LMAC_MAP(nic->vf_lmac_map[vf]);
-
-		bgx_lmac_rx_tx_enable(nic->node, bgx, lmac, true);
+		nic_enable_vf(nic, vf, true);
 		goto unlock;
 	case NIC_MBOX_MSG_SHUTDOWN:
 		/* First msg in VF teardown sequence */
-		nic->vf_enabled[vf] = false;
 		if (vf >= nic->num_vf_en)
 			nic->sqs_used[vf - nic->num_vf_en] = false;
 		nic->pqs_vf[vf] = 0;
-
-		if (vf >= nic->lmac_cnt)
-			break;
-
-		bgx = NIC_GET_BGX_FROM_VF_LMAC_MAP(nic->vf_lmac_map[vf]);
-		lmac = NIC_GET_LMAC_FROM_VF_LMAC_MAP(nic->vf_lmac_map[vf]);
-
-		bgx_lmac_rx_tx_enable(nic->node, bgx, lmac, false);
+		nic_enable_vf(nic, vf, false);
 		break;
 	case NIC_MBOX_MSG_ALLOC_SQS:
 		nic_alloc_sqs(nic, &mbx.sqs_alloc);
@@ -958,7 +955,7 @@ static void nic_poll_for_link(struct work_struct *work)
 
 	mbx.link_status.msg = NIC_MBOX_MSG_BGX_LINK_CHANGE;
 
-	for (vf = 0; vf < nic->lmac_cnt; vf++) {
+	for (vf = 0; vf < nic->num_vf_en; vf++) {
 		/* Poll only if VF is UP */
 		if (!nic->vf_enabled[vf])
 			continue;
-- 
2.4.4
