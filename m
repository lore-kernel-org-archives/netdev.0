From: sunil.kovvuri@gmail.com
Subject: [PATCH 11/21] net: thunderx: Add support for 16 LMACs of 83xx
Date: Wed, 10 Aug 2016 12:12:43 +0530
Message-ID: <1470811373-28277-12-git-send-email-sunil.kovvuri@gmail.com>
References: <1470811373-28277-1-git-send-email-sunil.kovvuri@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Sunil Goutham <sgoutham@cavium.com>, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1470811373-28277-1-git-send-email-sunil.kovvuri@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

83xx will have 4 BGX blocks i.e 16 LMACs, to avoid changing
the same with every platform, nicpf struct elements which
track LMAC related info are now allocated runtime based
on platform's max possible BGX count.

Also fixed configuring min packet size for all LMAC's
supported on a platform.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nic_main.c    | 73 ++++++++++++++++++-----
 drivers/net/ethernet/cavium/thunder/thunder_bgx.h |  2 -
 2 files changed, 59 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nic_main.c b/drivers/net/ethernet/cavium/thunder/nic_main.c
index 91c575d..8ed8ecd 100644
--- a/drivers/net/ethernet/cavium/thunder/nic_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nic_main.c
@@ -53,12 +53,12 @@ struct nicpf {
 #define	NIC_SET_VF_LMAC_MAP(bgx, lmac)	(((bgx & 0xF) << 4) | (lmac & 0xF))
 #define	NIC_GET_BGX_FROM_VF_LMAC_MAP(map)	((map >> 4) & 0xF)
 #define	NIC_GET_LMAC_FROM_VF_LMAC_MAP(map)	(map & 0xF)
-	u8			vf_lmac_map[MAX_LMAC];
+	u8			*vf_lmac_map;
 	struct delayed_work     dwork;
 	struct workqueue_struct *check_link;
-	u8			link[MAX_LMAC];
-	u8			duplex[MAX_LMAC];
-	u32			speed[MAX_LMAC];
+	u8			*link;
+	u8			*duplex;
+	u32			*speed;
 	u16			cpi_base[MAX_NUM_VFS_SUPPORTED];
 	u16			rssi_base[MAX_NUM_VFS_SUPPORTED];
 	bool			mbx_lock[MAX_NUM_VFS_SUPPORTED];
@@ -185,7 +185,7 @@ static void nic_mbx_send_ready(struct nicpf *nic, int vf)
 	mbx.nic_cfg.sqs_mode = (vf >= nic->num_vf_en) ? true : false;
 	mbx.nic_cfg.node_id = nic->node;
 
-	mbx.nic_cfg.loopback_supported = vf < MAX_LMAC;
+	mbx.nic_cfg.loopback_supported = vf < nic->num_vf_en;
 
 	nic_send_msg_to_vf(nic, vf, &mbx);
 }
@@ -278,14 +278,22 @@ static int nic_update_hw_frs(struct nicpf *nic, int new_frs, int vf)
 /* Set minimum transmit packet size */
 static void nic_set_tx_pkt_pad(struct nicpf *nic, int size)
 {
-	int lmac;
+	int lmac, max_lmac;
+	u16 sdevid;
 	u64 lmac_cfg;
 
 	/* Max value that can be set is 60 */
 	if (size > 60)
 		size = 60;
 
-	for (lmac = 0; lmac < (MAX_BGX_PER_CN88XX * MAX_LMAC_PER_BGX); lmac++) {
+	pci_read_config_word(nic->pdev, PCI_SUBSYSTEM_ID, &sdevid);
+	/* 81xx's RGX has only one LMAC */
+	if (sdevid == PCI_SUBSYS_DEVID_81XX_NIC_PF)
+		max_lmac = ((nic->hw->bgx_cnt - 1) * MAX_LMAC_PER_BGX) + 1;
+	else
+		max_lmac = nic->hw->bgx_cnt * MAX_LMAC_PER_BGX;
+
+	for (lmac = 0; lmac < max_lmac; lmac++) {
 		lmac_cfg = nic_reg_read(nic, NIC_PF_LMAC_0_7_CFG | (lmac << 3));
 		lmac_cfg &= ~(0xF << 2);
 		lmac_cfg |= ((size / 4) << 2);
@@ -336,8 +344,17 @@ static void nic_set_lmac_vf_mapping(struct nicpf *nic)
 	}
 }
 
-static void nic_get_hw_info(struct nicpf *nic)
+static void nic_free_lmacmem(struct nicpf *nic)
 {
+	kfree(nic->vf_lmac_map);
+	kfree(nic->link);
+	kfree(nic->duplex);
+	kfree(nic->speed);
+}
+
+static int nic_get_hw_info(struct nicpf *nic)
+{
+	u8 max_lmac;
 	u16 sdevid;
 	struct hw_info *hw = nic->hw;
 
@@ -385,18 +402,40 @@ static void nic_get_hw_info(struct nicpf *nic)
 		break;
 	}
 	hw->tl4_cnt = MAX_QUEUES_PER_QSET * pci_sriov_get_totalvfs(nic->pdev);
+
+	/* Allocate memory for LMAC tracking elements */
+	max_lmac = hw->bgx_cnt * MAX_LMAC_PER_BGX;
+	nic->vf_lmac_map = kmalloc_array(max_lmac, sizeof(u8), GFP_KERNEL);
+	if (!nic->vf_lmac_map)
+		goto error;
+	nic->link = kmalloc_array(max_lmac, sizeof(u8), GFP_KERNEL);
+	if (!nic->link)
+		goto error;
+	nic->duplex = kmalloc_array(max_lmac, sizeof(u8), GFP_KERNEL);
+	if (!nic->duplex)
+		goto error;
+	nic->speed = kmalloc_array(max_lmac, sizeof(u32), GFP_KERNEL);
+	if (!nic->speed)
+		goto error;
+	return 0;
+
+error:
+	nic_free_lmacmem(nic);
+	return -ENOMEM;
 }
 
 #define BGX0_BLOCK 8
 #define BGX1_BLOCK 9
 
-static void nic_init_hw(struct nicpf *nic)
+static int nic_init_hw(struct nicpf *nic)
 {
-	int i;
+	int i, err;
 	u64 cqm_cfg;
 
 	/* Get HW capability info */
-	nic_get_hw_info(nic);
+	err = nic_get_hw_info(nic);
+	if (err)
+		return err;
 
 	/* Enable NIC HW block */
 	nic_reg_write(nic, NIC_PF_CFG, 0x3);
@@ -442,6 +481,8 @@ static void nic_init_hw(struct nicpf *nic)
 	cqm_cfg = nic_reg_read(nic, NIC_PF_CQM_CFG);
 	if (cqm_cfg < NICPF_CQM_MIN_DROP_LEVEL)
 		nic_reg_write(nic, NIC_PF_CQM_CFG, NICPF_CQM_MIN_DROP_LEVEL);
+
+	return 0;
 }
 
 /* Channel parse index configuration */
@@ -741,7 +782,7 @@ static int nic_config_loopback(struct nicpf *nic, struct set_loopback *lbk)
 {
 	int bgx_idx, lmac_idx;
 
-	if (lbk->vf_id > MAX_LMAC)
+	if (lbk->vf_id >= nic->num_vf_en)
 		return -1;
 
 	bgx_idx = NIC_GET_BGX_FROM_VF_LMAC_MAP(nic->vf_lmac_map[lbk->vf_id]);
@@ -795,7 +836,7 @@ static void nic_handle_mbx_intr(struct nicpf *nic, int vf)
 	switch (mbx.msg.msg) {
 	case NIC_MBOX_MSG_READY:
 		nic_mbx_send_ready(nic, vf);
-		if (vf < MAX_LMAC) {
+		if (vf < nic->num_vf_en) {
 			nic->link[vf] = 0;
 			nic->duplex[vf] = 0;
 			nic->speed[vf] = 0;
@@ -1191,7 +1232,9 @@ static int nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	nic->node = nic_get_node_id(pdev);
 
 	/* Initialize hardware */
-	nic_init_hw(nic);
+	err = nic_init_hw(nic);
+	if (err)
+		goto err_release_regions;
 
 	nic_set_lmac_vf_mapping(nic);
 
@@ -1226,6 +1269,7 @@ err_unregister_interrupts:
 err_release_regions:
 	pci_release_regions(pdev);
 err_disable_device:
+	nic_free_lmacmem(nic);
 	devm_kfree(dev, nic->hw);
 	devm_kfree(dev, nic);
 	pci_disable_device(pdev);
@@ -1249,6 +1293,7 @@ static void nic_remove(struct pci_dev *pdev)
 	nic_unregister_interrupts(nic);
 	pci_release_regions(pdev);
 
+	nic_free_lmacmem(nic);
 	devm_kfree(&pdev->dev, nic->hw);
 	devm_kfree(&pdev->dev, nic);
 
diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.h b/drivers/net/ethernet/cavium/thunder/thunder_bgx.h
index 6225ff4..c7d7cc67 100644
--- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.h
+++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.h
@@ -29,8 +29,6 @@
 
 #define    MAX_DMAC_PER_LMAC_TNS_BYPASS_MODE	2
 
-#define    MAX_LMAC	(MAX_BGX_PER_CN88XX * MAX_LMAC_PER_BGX)
-
 /* Registers */
 #define BGX_CMRX_CFG			0x00
 #define  CMR_PKT_TX_EN				BIT_ULL(13)
-- 
2.7.4
