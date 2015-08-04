From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next 3/4] cxgb4/cxgb4vf: read the correct bits of PL Who Am I register
Date: Tue,  4 Aug 2015 14:36:19 +0530
Message-ID: <1438679180-25930-4-git-send-email-hariprasad@chelsio.com>
References: <1438679180-25930-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:12853 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755151AbbHDDv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 23:51:56 -0400
In-Reply-To: <1438679180-25930-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Read the correct bits of PL Who Am I for the Source PF field which has
changed in T6

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 34 ++++++++++++++++++++++++-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      |  8 ++++--
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h    |  4 +++
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c  |  3 ++-
 4 files changed, 45 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index d582e17..27e87b6 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -4551,6 +4551,32 @@ static void free_some_resources(struct adapter *adapter)
 		   NETIF_F_IPV6_CSUM | NETIF_F_HIGHDMA)
 #define SEGMENT_SIZE 128
 
+static int get_chip_type(struct pci_dev *pdev, u32 pl_rev)
+{
+	int ver, chip;
+	u16 device_id;
+
+	/* Retrieve adapter's device ID */
+	pci_read_config_word(pdev, PCI_DEVICE_ID, &device_id);
+	ver = device_id >> 12;
+	switch (ver) {
+	case CHELSIO_T4:
+		chip |= CHELSIO_CHIP_CODE(CHELSIO_T4, pl_rev);
+		break;
+	case CHELSIO_T5:
+		chip |= CHELSIO_CHIP_CODE(CHELSIO_T5, pl_rev);
+		break;
+	case CHELSIO_T6:
+		chip |= CHELSIO_CHIP_CODE(CHELSIO_T6, pl_rev);
+		break;
+	default:
+		dev_err(&pdev->dev, "Device %d is not supported\n",
+			device_id);
+		return -EINVAL;
+	}
+	return chip;
+}
+
 static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	int func, i, err, s_qpp, qpp, num_seg;
@@ -4558,6 +4584,8 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	bool highdma = false;
 	struct adapter *adapter = NULL;
 	void __iomem *regs;
+	u32 whoami, pl_rev;
+	enum chip_type chip;
 
 	printk_once(KERN_INFO "%s - version %s\n", DRV_DESC, DRV_VERSION);
 
@@ -4586,7 +4614,11 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto out_unmap_bar0;
 
 	/* We control everything through one PF */
-	func = SOURCEPF_G(readl(regs + PL_WHOAMI_A));
+	whoami = readl(regs + PL_WHOAMI_A);
+	pl_rev = REV_G(readl(regs + PL_REV_A));
+	chip = get_chip_type(pdev, pl_rev);
+	func = CHELSIO_CHIP_VERSION(chip) <= CHELSIO_T5 ?
+		SOURCEPF_G(whoami) : T6_SOURCEPF_G(whoami);
 	if (func != ent->driver_data) {
 		iounmap(regs);
 		pci_disable_device(pdev);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index b193295..5c63ceb 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -3529,7 +3529,9 @@ int t4_slow_intr_handler(struct adapter *adapter)
 void t4_intr_enable(struct adapter *adapter)
 {
 	u32 val = 0;
-	u32 pf = SOURCEPF_G(t4_read_reg(adapter, PL_WHOAMI_A));
+	u32 whoami = t4_read_reg(adapter, PL_WHOAMI_A);
+	u32 pf = CHELSIO_CHIP_VERSION(adapter->params.chip) <= CHELSIO_T5 ?
+			SOURCEPF_G(whoami) : T6_SOURCEPF_G(whoami);
 
 	if (CHELSIO_CHIP_VERSION(adapter->params.chip) <= CHELSIO_T5)
 		val = ERR_DROPPED_DB_F | ERR_EGR_CTXT_PRIO_F | DBFIFO_HP_INT_F;
@@ -3554,7 +3556,9 @@ void t4_intr_enable(struct adapter *adapter)
  */
 void t4_intr_disable(struct adapter *adapter)
 {
-	u32 pf = SOURCEPF_G(t4_read_reg(adapter, PL_WHOAMI_A));
+	u32 whoami = t4_read_reg(adapter, PL_WHOAMI_A);
+	u32 pf = CHELSIO_CHIP_VERSION(adapter->params.chip) <= CHELSIO_T5 ?
+			SOURCEPF_G(whoami) : T6_SOURCEPF_G(whoami);
 
 	t4_write_reg(adapter, MYPF_REG(PL_PF_INT_ENABLE_A), 0);
 	t4_set_reg_field(adapter, PL_INT_MAP0_A, 1 << pf, 0);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index 13ce018..e444dc4 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -2588,6 +2588,10 @@
 #define SOURCEPF_M    0x7U
 #define SOURCEPF_G(x) (((x) >> SOURCEPF_S) & SOURCEPF_M)
 
+#define T6_SOURCEPF_S    9
+#define T6_SOURCEPF_M    0x7U
+#define T6_SOURCEPF_G(x) (((x) >> T6_SOURCEPF_S) & T6_SOURCEPF_M)
+
 #define PL_INT_CAUSE_A 0x1940c
 
 #define ULP_TX_S    27
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
index 0db6dc9..63dd5fd 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
@@ -619,7 +619,8 @@ int t4vf_get_sge_params(struct adapter *adapter)
 		 */
 		whoami = t4_read_reg(adapter,
 				     T4VF_PL_BASE_ADDR + PL_VF_WHOAMI_A);
-		pf = SOURCEPF_G(whoami);
+		pf = CHELSIO_CHIP_VERSION(adapter->params.chip) <= CHELSIO_T5 ?
+			SOURCEPF_G(whoami) : T6_SOURCEPF_G(whoami);
 
 		s_hps = (HOSTPAGESIZEPF0_S +
 			 (HOSTPAGESIZEPF1_S - HOSTPAGESIZEPF0_S) * pf);
-- 
2.3.4
