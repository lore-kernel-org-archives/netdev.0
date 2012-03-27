From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net PATCH] bnx2x: previous driver unload revised
Date: Tue, 27 Mar 2012 08:47:07 +0200
Message-ID: <1332830827-18253-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: dmitry@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1683 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752989Ab2C0Gu0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2012 02:50:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The flow in which the bnx2x driver starts after a previous driver 
has been terminated in an 'unclean' manner has several bugs and
FW risks, which makes it possible for the driver to fail after 
boot-from-SAN or kdump.
This patch contains a revised flow which performs a safer
initialization, solving the possible crash scenarios.
Notice this patch contains lines with over 80 characters, as it
keeps print-strings in a single line.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---

Hi Dave,

please consider applying this patch to 'net'.

Thanks,
Yuval

---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |    7 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |   40 ++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h  |    3 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h  |    3 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |    1 -
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h |    2 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |  464 +++++++++++++++++-----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h  |    4 +
 8 files changed, 417 insertions(+), 107 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index e37161f..2c9ee55 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1173,6 +1173,13 @@ enum {
 };
 
 
+struct bnx2x_prev_path_list {
+	u8 bus;
+	u8 slot;
+	u8 path;
+	struct list_head list;
+};
+
 struct bnx2x {
 	/* Fields used in the tx and intr/napi performance paths
 	 * are grouped together in the beginning of the structure
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index f1f3ca6..b74700a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1721,6 +1721,29 @@ static void bnx2x_squeeze_objects(struct bnx2x *bp)
 	} while (0)
 #endif
 
+bool bnx2x_test_firmware_version(struct bnx2x *bp, bool is_err)
+{
+	/* build FW version dword */
+	u32 my_fw = (BCM_5710_FW_MAJOR_VERSION) +
+		    (BCM_5710_FW_MINOR_VERSION << 8) +
+		    (BCM_5710_FW_REVISION_VERSION << 16) +
+		    (BCM_5710_FW_ENGINEERING_VERSION << 24);
+
+	/* read loaded FW from chip */
+	u32 loaded_fw = REG_RD(bp, XSEM_REG_PRAM);
+
+	DP(NETIF_MSG_IFUP, "loaded fw %x, my fw %x\n", loaded_fw, my_fw);
+
+	if (loaded_fw != my_fw) {
+		if (is_err)
+			BNX2X_ERR("bnx2x with FW %x was already loaded, which mismatches my %x FW. aborting\n",
+				  loaded_fw, my_fw);
+		return false;
+	}
+
+	return true;
+}
+
 /* must be called with rtnl_lock */
 int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 {
@@ -1815,23 +1838,8 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 		}
 		if (load_code != FW_MSG_CODE_DRV_LOAD_COMMON_CHIP &&
 		    load_code != FW_MSG_CODE_DRV_LOAD_COMMON) {
-			/* build FW version dword */
-			u32 my_fw = (BCM_5710_FW_MAJOR_VERSION) +
-					(BCM_5710_FW_MINOR_VERSION << 8) +
-					(BCM_5710_FW_REVISION_VERSION << 16) +
-					(BCM_5710_FW_ENGINEERING_VERSION << 24);
-
-			/* read loaded FW from chip */
-			u32 loaded_fw = REG_RD(bp, XSEM_REG_PRAM);
-
-			DP(BNX2X_MSG_SP, "loaded fw %x, my fw %x",
-			   loaded_fw, my_fw);
-
 			/* abort nic load if version mismatch */
-			if (my_fw != loaded_fw) {
-				BNX2X_ERR("bnx2x with FW %x already loaded, "
-					  "which mismatches my %x FW. aborting",
-					  loaded_fw, my_fw);
+			if (!bnx2x_test_firmware_version(bp, true)) {
 				rc = -EBUSY;
 				LOAD_ERROR_EXIT(bp, load_error2);
 			}
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 8b16338..5c27454 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -431,6 +431,9 @@ void bnx2x_panic_dump(struct bnx2x *bp);
 
 void bnx2x_fw_dump_lvl(struct bnx2x *bp, const char *lvl);
 
+/* validate currect fw is loaded */
+bool bnx2x_test_firmware_version(struct bnx2x *bp, bool is_err);
+
 /* dev_close main block */
 int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode);
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
index 5d71b7d..dbff591 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
@@ -1251,6 +1251,9 @@ struct drv_func_mb {
 
 	#define DRV_MSG_CODE_LINK_STATUS_CHANGED        0x01000000
 
+	#define DRV_MSG_CODE_INITIATE_FLR               0x02000000
+	#define REQ_BC_VER_4_INITIATE_FLR               0x00070213
+
 	#define BIOS_MSG_CODE_LIC_CHALLENGE             0xff010000
 	#define BIOS_MSG_CODE_LIC_RESPONSE              0xff020000
 	#define BIOS_MSG_CODE_VIRT_MAC_PRIM             0xff030000
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index beb4cdb..efa557b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -35,7 +35,6 @@
 #define ETH_MAX_PACKET_SIZE		1500
 #define ETH_MAX_JUMBO_PACKET_SIZE	9600
 #define MDIO_ACCESS_TIMEOUT		1000
-#define BMAC_CONTROL_RX_ENABLE		2
 #define WC_LANE_MAX			4
 #define I2C_SWITCH_WIDTH		2
 #define I2C_BSC0			0
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
index 7ba557a..763535e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
@@ -89,6 +89,8 @@
 #define PFC_BRB_FULL_LB_XON_THRESHOLD				250
 
 #define MAXVAL(a, b) (((a) > (b)) ? (a) : (b))
+
+#define BMAC_CONTROL_RX_ENABLE		2
 /***********************************************************/
 /*                         Structs                         */
 /***********************************************************/
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index f7f9aa8..7e88f32 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -52,6 +52,7 @@
 #include <linux/prefetch.h>
 #include <linux/zlib.h>
 #include <linux/io.h>
+#include <linux/semaphore.h>
 #include <linux/stringify.h>
 #include <linux/vmalloc.h>
 
@@ -211,6 +212,10 @@ static DEFINE_PCI_DEVICE_TABLE(bnx2x_pci_tbl) = {
 
 MODULE_DEVICE_TABLE(pci, bnx2x_pci_tbl);
 
+/* Global resources for unloading a previously loaded device */
+#define BNX2X_PREV_WAIT_NEEDED 1
+static DEFINE_SEMAPHORE(bnx2x_prev_sem);
+static LIST_HEAD(bnx2x_prev_list);
 /****************************************************************************
 * General service functions
 ****************************************************************************/
@@ -8812,109 +8817,371 @@ static inline void bnx2x_undi_int_disable(struct bnx2x *bp)
 		bnx2x_undi_int_disable_e1h(bp);
 }
 
-static void __devinit bnx2x_undi_unload(struct bnx2x *bp)
+static void __devinit bnx2x_prev_unload_close_mac(struct bnx2x *bp)
 {
-	u32 val;
+	u32 val, base_addr, offset, mask, reset_reg;
+	bool mac_stopped = false;
+	u8 port = BP_PORT(bp);
 
-	/* possibly another driver is trying to reset the chip */
-	bnx2x_acquire_hw_lock(bp, HW_LOCK_RESOURCE_RESET);
+	reset_reg = REG_RD(bp, MISC_REG_RESET_REG_2);
 
-	/* check if doorbell queue is reset */
-	if (REG_RD(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_1_SET)
-	    & MISC_REGISTERS_RESET_REG_1_RST_DORQ) {
+	if (!CHIP_IS_E3(bp)) {
+		val = REG_RD(bp, NIG_REG_BMAC0_REGS_OUT_EN + port * 4);
+		mask = MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << port;
+		if ((mask & reset_reg) && val) {
+			u32 wb_data[2];
+			BNX2X_DEV_INFO("Disable bmac Rx\n");
+			base_addr = BP_PORT(bp) ? NIG_REG_INGRESS_BMAC1_MEM
+						: NIG_REG_INGRESS_BMAC0_MEM;
+			offset = CHIP_IS_E2(bp) ? BIGMAC2_REGISTER_BMAC_CONTROL
+						: BIGMAC_REGISTER_BMAC_CONTROL;
 
-		/*
-		 * Check if it is the UNDI driver
+			/*
+			 * use rd/wr since we cannot use dmae. This is safe
+			 * since MCP won't access the bus due to the request
+			 * to unload, and no function on the path can be
+			 * loaded at this time.
+			 */
+			wb_data[0] = REG_RD(bp, base_addr + offset);
+			wb_data[1] = REG_RD(bp, base_addr + offset + 0x4);
+			wb_data[0] &= ~BMAC_CONTROL_RX_ENABLE;
+			REG_WR(bp, base_addr + offset, wb_data[0]);
+			REG_WR(bp, base_addr + offset + 0x4, wb_data[1]);
+
+		}
+		BNX2X_DEV_INFO("Disable emac Rx\n");
+		REG_WR(bp, NIG_REG_NIG_EMAC0_EN + BP_PORT(bp)*4, 0);
+
+		mac_stopped = true;
+	} else {
+		if (reset_reg & MISC_REGISTERS_RESET_REG_2_XMAC) {
+			BNX2X_DEV_INFO("Disable xmac Rx\n");
+			base_addr = BP_PORT(bp) ? GRCBASE_XMAC1 : GRCBASE_XMAC0;
+			val = REG_RD(bp, base_addr + XMAC_REG_PFC_CTRL_HI);
+			REG_WR(bp, base_addr + XMAC_REG_PFC_CTRL_HI,
+			       val & ~(1 << 1));
+			REG_WR(bp, base_addr + XMAC_REG_PFC_CTRL_HI,
+			       val | (1 << 1));
+			REG_WR(bp, base_addr + XMAC_REG_CTRL, 0);
+			mac_stopped = true;
+		}
+		mask = MISC_REGISTERS_RESET_REG_2_UMAC0 << port;
+		if (mask & reset_reg) {
+			BNX2X_DEV_INFO("Disable umac Rx\n");
+			base_addr = BP_PORT(bp) ? GRCBASE_UMAC1 : GRCBASE_UMAC0;
+			REG_WR(bp, base_addr + UMAC_REG_COMMAND_CONFIG, 0);
+			mac_stopped = true;
+		}
+	}
+
+	if (mac_stopped)
+		msleep(20);
+
+}
+
+#define BNX2X_PREV_UNDI_PROD_ADDR(p) (BAR_TSTRORM_INTMEM + 0x1508 + ((p) << 4))
+#define BNX2X_PREV_UNDI_RCQ(val)	((val) & 0xffff)
+#define BNX2X_PREV_UNDI_BD(val)		((val) >> 16 & 0xffff)
+#define BNX2X_PREV_UNDI_PROD(rcq, bd)	((bd) << 16 | (rcq))
+
+static void __devinit bnx2x_prev_unload_undi_inc(struct bnx2x *bp, u8 port,
+						 u8 inc)
+{
+	u16 rcq, bd;
+	u32 tmp_reg = REG_RD(bp, BNX2X_PREV_UNDI_PROD_ADDR(port));
+
+	rcq = BNX2X_PREV_UNDI_RCQ(tmp_reg) + inc;
+	bd = BNX2X_PREV_UNDI_BD(tmp_reg) + inc;
+
+	tmp_reg = BNX2X_PREV_UNDI_PROD(rcq, bd);
+	REG_WR(bp, BNX2X_PREV_UNDI_PROD_ADDR(port), tmp_reg);
+
+	BNX2X_DEV_INFO("UNDI producer [%d] rings bd -> 0x%04x, rcq -> 0x%04x\n",
+		       port, bd, rcq);
+}
+
+static int __devinit bnx2x_prev_mcp_done(struct bnx2x *bp)
+{
+	u32 rc = bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_DONE, 0);
+	if (!rc) {
+		BNX2X_ERR("MCP response failure, aborting\n");
+		return -EBUSY;
+	}
+
+	return 0;
+}
+
+static bool __devinit bnx2x_prev_is_path_marked(struct bnx2x *bp)
+{
+	struct bnx2x_prev_path_list *tmp_list;
+	int rc = false;
+
+	if (down_trylock(&bnx2x_prev_sem))
+		return false;
+
+	list_for_each_entry(tmp_list, &bnx2x_prev_list, list) {
+		if (PCI_SLOT(bp->pdev->devfn) == tmp_list->slot &&
+		    bp->pdev->bus->number == tmp_list->bus &&
+		    BP_PATH(bp) == tmp_list->path) {
+			rc = true;
+			BNX2X_DEV_INFO("Path %d was already cleaned from previous drivers\n",
+				       BP_PATH(bp));
+			break;
+		}
+	}
+
+	up(&bnx2x_prev_sem);
+
+	return rc;
+}
+
+static int __devinit bnx2x_prev_mark_path(struct bnx2x *bp)
+{
+	struct bnx2x_prev_path_list *tmp_list;
+	int rc;
+
+	tmp_list = (struct bnx2x_prev_path_list *)
+		    kmalloc(sizeof(struct bnx2x_prev_path_list), GFP_KERNEL);
+	if (!tmp_list) {
+		BNX2X_ERR("Failed to allocate 'bnx2x_prev_path_list'\n");
+		return -ENOMEM;
+	}
+
+	tmp_list->bus = bp->pdev->bus->number;
+	tmp_list->slot = PCI_SLOT(bp->pdev->devfn);
+	tmp_list->path = BP_PATH(bp);
+
+	rc = down_interruptible(&bnx2x_prev_sem);
+	if (rc) {
+		BNX2X_ERR("Received %d when tried to take lock\n", rc);
+		kfree(tmp_list);
+	} else {
+		BNX2X_DEV_INFO("Marked path [%d] - finished previous unload\n",
+				BP_PATH(bp));
+		list_add(&tmp_list->list, &bnx2x_prev_list);
+		up(&bnx2x_prev_sem);
+	}
+
+	return rc;
+}
+
+static bool __devinit bnx2x_can_flr(struct bnx2x *bp)
+{
+	int pos;
+	u32 cap;
+	struct pci_dev *dev = bp->pdev;
+
+	pos = pci_pcie_cap(dev);
+	if (!pos)
+		return false;
+
+	pci_read_config_dword(dev, pos + PCI_EXP_DEVCAP, &cap);
+	if (!(cap & PCI_EXP_DEVCAP_FLR))
+		return false;
+
+	return true;
+}
+
+static int __devinit bnx2x_do_flr(struct bnx2x *bp)
+{
+	int i, pos;
+	u16 status;
+	struct pci_dev *dev = bp->pdev;
+
+	/* probe the capability first */
+	if (bnx2x_can_flr(bp))
+		return -ENOTTY;
+
+	pos = pci_pcie_cap(dev);
+	if (!pos)
+		return -ENOTTY;
+
+	/* Wait for Transaction Pending bit clean */
+	for (i = 0; i < 4; i++) {
+		if (i)
+			msleep((1 << (i - 1)) * 100);
+
+		pci_read_config_word(dev, pos + PCI_EXP_DEVSTA, &status);
+		if (!(status & PCI_EXP_DEVSTA_TRPND))
+			goto clear;
+	}
+
+	dev_err(&dev->dev,
+		"transaction is not cleared; proceeding with reset anyway\n");
+
+clear:
+	if (bp->common.bc_ver < REQ_BC_VER_4_INITIATE_FLR) {
+		BNX2X_ERR("FLR not supported by BC_VER: 0x%x\n",
+			  bp->common.bc_ver);
+		return -EINVAL;
+	}
+
+	bnx2x_fw_command(bp, DRV_MSG_CODE_INITIATE_FLR, 0);
+
+	return 0;
+}
+
+static int __devinit bnx2x_prev_unload_uncommon(struct bnx2x *bp)
+{
+	int rc;
+
+	BNX2X_DEV_INFO("Uncommon unload Flow\n");
+
+	/* Test if previous unload process was already finished for this path */
+	if (bnx2x_prev_is_path_marked(bp))
+		return bnx2x_prev_mcp_done(bp);
+
+	/* If function has FLR capabilities, and existing FW version matches
+	 * the one required, then FLR will be sufficient to clean any residue
+	 * left by previous driver
+	 */
+	if (bnx2x_test_firmware_version(bp, false) && bnx2x_can_flr(bp))
+		return bnx2x_do_flr(bp);
+
+	/* Close the MCP request, return failure*/
+	rc = bnx2x_prev_mcp_done(bp);
+	if (!rc)
+		rc = BNX2X_PREV_WAIT_NEEDED;
+
+	return rc;
+}
+
+static int __devinit bnx2x_prev_unload_common(struct bnx2x *bp)
+{
+	u32 reset_reg, tmp_reg = 0, rc;
+	/* It is possible a previous function received 'common' answer,
+	 * but hasn't loaded yet, therefore creating a scenario of
+	 * multiple functions receiving 'common' on the same path.
+	 */
+	BNX2X_DEV_INFO("Common unload Flow\n");
+
+	if (bnx2x_prev_is_path_marked(bp))
+		return bnx2x_prev_mcp_done(bp);
+
+	reset_reg = REG_RD(bp, MISC_REG_RESET_REG_1);
+
+	/* Reset should be performed after BRB is emptied */
+	if (reset_reg & MISC_REGISTERS_RESET_REG_1_RST_BRB1) {
+		u32 timer_count = 1000;
+		bool prev_undi = false;
+
+		/* Close the MAC Rx to prevent BRB from filling up */
+		bnx2x_prev_unload_close_mac(bp);
+
+		/* Check if the UNDI driver was previously loaded
 		 * UNDI driver initializes CID offset for normal bell to 0x7
 		 */
-		val = REG_RD(bp, DORQ_REG_NORM_CID_OFST);
-		if (val == 0x7) {
-			u32 reset_code = DRV_MSG_CODE_UNLOAD_REQ_WOL_DIS;
-			/* save our pf_num */
-			int orig_pf_num = bp->pf_num;
-			int port;
-			u32 swap_en, swap_val, value;
-
-			/* clear the UNDI indication */
-			REG_WR(bp, DORQ_REG_NORM_CID_OFST, 0);
-
-			BNX2X_DEV_INFO("UNDI is active! reset device\n");
-
-			/* try unload UNDI on port 0 */
-			bp->pf_num = 0;
-			bp->fw_seq =
-			      (SHMEM_RD(bp, func_mb[bp->pf_num].drv_mb_header) &
-				DRV_MSG_SEQ_NUMBER_MASK);
-			reset_code = bnx2x_fw_command(bp, reset_code, 0);
-
-			/* if UNDI is loaded on the other port */
-			if (reset_code != FW_MSG_CODE_DRV_UNLOAD_COMMON) {
-
-				/* send "DONE" for previous unload */
-				bnx2x_fw_command(bp,
-						 DRV_MSG_CODE_UNLOAD_DONE, 0);
-
-				/* unload UNDI on port 1 */
-				bp->pf_num = 1;
-				bp->fw_seq =
-			      (SHMEM_RD(bp, func_mb[bp->pf_num].drv_mb_header) &
-					DRV_MSG_SEQ_NUMBER_MASK);
-				reset_code = DRV_MSG_CODE_UNLOAD_REQ_WOL_DIS;
-
-				bnx2x_fw_command(bp, reset_code, 0);
+		reset_reg = REG_RD(bp, MISC_REG_RESET_REG_1);
+		if (reset_reg & MISC_REGISTERS_RESET_REG_1_RST_DORQ) {
+			tmp_reg = REG_RD(bp, DORQ_REG_NORM_CID_OFST);
+			if (tmp_reg == 0x7) {
+				BNX2X_DEV_INFO("UNDI previously loaded\n");
+				prev_undi = true;
+				/* clear the UNDI indication */
+				REG_WR(bp, DORQ_REG_NORM_CID_OFST, 0);
 			}
+		}
+		/* wait until BRB is empty */
+		tmp_reg = REG_RD(bp, BRB1_REG_NUM_OF_FULL_BLOCKS);
+		while (timer_count) {
+			u32 prev_brb = tmp_reg;
 
-			bnx2x_undi_int_disable(bp);
-			port = BP_PORT(bp);
-
-			/* close input traffic and wait for it */
-			/* Do not rcv packets to BRB */
-			REG_WR(bp, (port ? NIG_REG_LLH1_BRB1_DRV_MASK :
-					   NIG_REG_LLH0_BRB1_DRV_MASK), 0x0);
-			/* Do not direct rcv packets that are not for MCP to
-			 * the BRB */
-			REG_WR(bp, (port ? NIG_REG_LLH1_BRB1_NOT_MCP :
-					   NIG_REG_LLH0_BRB1_NOT_MCP), 0x0);
-			/* clear AEU */
-			REG_WR(bp, (port ? MISC_REG_AEU_MASK_ATTN_FUNC_1 :
-					   MISC_REG_AEU_MASK_ATTN_FUNC_0), 0);
-			msleep(10);
-
-			/* save NIG port swap info */
-			swap_val = REG_RD(bp, NIG_REG_PORT_SWAP);
-			swap_en = REG_RD(bp, NIG_REG_STRAP_OVERRIDE);
-			/* reset device */
-			REG_WR(bp,
-			       GRCBASE_MISC + MISC_REGISTERS_RESET_REG_1_CLEAR,
-			       0xd3ffffff);
-
-			value = 0x1400;
-			if (CHIP_IS_E3(bp)) {
-				value |= MISC_REGISTERS_RESET_REG_2_MSTAT0;
-				value |= MISC_REGISTERS_RESET_REG_2_MSTAT1;
-			}
+			tmp_reg = REG_RD(bp, BRB1_REG_NUM_OF_FULL_BLOCKS);
+			if (!tmp_reg)
+				break;
 
-			REG_WR(bp,
-			       GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_CLEAR,
-			       value);
+			BNX2X_DEV_INFO("BRB still has 0x%08x\n", tmp_reg);
 
-			/* take the NIG out of reset and restore swap values */
-			REG_WR(bp,
-			       GRCBASE_MISC + MISC_REGISTERS_RESET_REG_1_SET,
-			       MISC_REGISTERS_RESET_REG_1_RST_NIG);
-			REG_WR(bp, NIG_REG_PORT_SWAP, swap_val);
-			REG_WR(bp, NIG_REG_STRAP_OVERRIDE, swap_en);
+			/* reset timer as long as BRB actually gets emptied */
+			if (prev_brb > tmp_reg)
+				timer_count = 1000;
+			else
+				timer_count--;
 
-			/* send unload done to the MCP */
-			bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_DONE, 0);
+			/* If UNDI resides in memory, manually increment it */
+			if (prev_undi)
+				bnx2x_prev_unload_undi_inc(bp, BP_PORT(bp), 1);
 
-			/* restore our func and fw_seq */
-			bp->pf_num = orig_pf_num;
+			udelay(10);
 		}
+
+		if (!timer_count)
+			BNX2X_ERR("Failed to empty BRB, hope for the best\n");
+
 	}
 
-	/* now it's safe to release the lock */
-	bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_RESET);
+	/* No packets are in the pipeline, path is ready for reset */
+	bnx2x_reset_common(bp);
+
+	rc = bnx2x_prev_mark_path(bp);
+	if (rc) {
+		bnx2x_prev_mcp_done(bp);
+		return rc;
+	}
+
+	return bnx2x_prev_mcp_done(bp);
+}
+
+static int __devinit bnx2x_prev_unload(struct bnx2x *bp)
+{
+	int time_counter = 10;
+	u32 rc, fw, hw_lock_reg, hw_lock_val;
+	BNX2X_DEV_INFO("Entering Previous Unload Flow\n");
+
+       /* Release previously held locks */
+	hw_lock_reg = (BP_FUNC(bp) <= 5) ?
+		      (MISC_REG_DRIVER_CONTROL_1 + BP_FUNC(bp) * 8) :
+		      (MISC_REG_DRIVER_CONTROL_7 + (BP_FUNC(bp) - 6) * 8);
+
+	hw_lock_val = (REG_RD(bp, hw_lock_reg));
+	if (hw_lock_val) {
+		if (hw_lock_val & HW_LOCK_RESOURCE_NVRAM) {
+			BNX2X_DEV_INFO("Release Previously held NVRAM lock\n");
+			REG_WR(bp, MCP_REG_MCPR_NVM_SW_ARB,
+			       (MCPR_NVM_SW_ARB_ARB_REQ_CLR1 << BP_PORT(bp)));
+		}
+
+		BNX2X_DEV_INFO("Release Previously held hw lock\n");
+		REG_WR(bp, hw_lock_reg, 0xffffffff);
+	} else
+		BNX2X_DEV_INFO("No need to release hw/nvram locks\n");
+
+	if (MCPR_ACCESS_LOCK_LOCK & REG_RD(bp, MCP_REG_MCPR_ACCESS_LOCK)) {
+		BNX2X_DEV_INFO("Release previously held alr\n");
+		REG_WR(bp, MCP_REG_MCPR_ACCESS_LOCK, 0);
+	}
+
+
+	do {
+		/* Lock MCP using an unload request */
+		fw = bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_REQ_WOL_DIS, 0);
+		if (!fw) {
+			BNX2X_ERR("MCP response failure, aborting\n");
+			rc = -EBUSY;
+			break;
+		}
+
+		if (fw == FW_MSG_CODE_DRV_UNLOAD_COMMON) {
+			rc = bnx2x_prev_unload_common(bp);
+			break;
+		}
+
+		/* non-common reply from MCP night require looping */
+		rc = bnx2x_prev_unload_uncommon(bp);
+		if (rc != BNX2X_PREV_WAIT_NEEDED)
+			break;
+
+		msleep(20);
+	} while (--time_counter);
+
+	if (!time_counter || rc) {
+		BNX2X_ERR("Failed unloading previous driver, aborting\n");
+		rc = -EBUSY;
+	}
+
+	BNX2X_DEV_INFO("Finished Previous Unload Flow [%d]\n", rc);
+
+	return rc;
 }
 
 static void __devinit bnx2x_get_common_hwinfo(struct bnx2x *bp)
@@ -10100,8 +10367,16 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 	func = BP_FUNC(bp);
 
 	/* need to reset chip if undi was active */
-	if (!BP_NOMCP(bp))
-		bnx2x_undi_unload(bp);
+	if (!BP_NOMCP(bp)) {
+		/* init fw_seq */
+		bp->fw_seq =
+			SHMEM_RD(bp, func_mb[BP_FW_MB_IDX(bp)].drv_mb_header) &
+							DRV_MSG_SEQ_NUMBER_MASK;
+		BNX2X_DEV_INFO("fw_seq 0x%08x\n", bp->fw_seq);
+
+		bnx2x_prev_unload(bp);
+	}
+
 
 	if (CHIP_REV_IS_FPGA(bp))
 		dev_err(&bp->pdev->dev, "FPGA detected\n");
@@ -11431,9 +11706,18 @@ static int __init bnx2x_init(void)
 
 static void __exit bnx2x_cleanup(void)
 {
+	struct list_head *pos, *q;
 	pci_unregister_driver(&bnx2x_pci_driver);
 
 	destroy_workqueue(bnx2x_wq);
+
+	/* Free globablly allocated resources */
+	list_for_each_safe(pos, q, &bnx2x_prev_list) {
+		struct bnx2x_prev_path_list *tmp =
+			list_entry(pos, struct bnx2x_prev_path_list, list);
+		list_del(pos);
+		kfree(tmp);
+	}
 }
 
 void bnx2x_notify_link_changed(struct bnx2x *bp)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
index fd7fb45..ab0a250 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
@@ -987,6 +987,7 @@
  * clear; 1 = set. Data valid only in addresses 0-4. all the rest are zero. */
 #define IGU_REG_WRITE_DONE_PENDING				 0x130480
 #define MCP_A_REG_MCPR_SCRATCH					 0x3a0000
+#define MCP_REG_MCPR_ACCESS_LOCK				 0x8009c
 #define MCP_REG_MCPR_CPU_PROGRAM_COUNTER			 0x8501c
 #define MCP_REG_MCPR_GP_INPUTS					 0x800c0
 #define MCP_REG_MCPR_GP_OENABLE					 0x800c8
@@ -1686,6 +1687,7 @@
    [10] rst_dbg; [11] rst_misc_core; [12] rst_dbue (UART); [13]
    Pci_resetmdio_n; [14] rst_emac0_hard_core; [15] rst_emac1_hard_core; 16]
    rst_pxp_rq_rd_wr; 31:17] reserved */
+#define MISC_REG_RESET_REG_1					 0xa580
 #define MISC_REG_RESET_REG_2					 0xa590
 /* [RW 20] 20 bit GRC address where the scratch-pad of the MCP that is
    shared with the driver resides */
@@ -5606,6 +5608,7 @@
 /* [RC 32] Parity register #0 read clear */
 #define XSEM_REG_XSEM_PRTY_STS_CLR_0				 0x280128
 #define XSEM_REG_XSEM_PRTY_STS_CLR_1				 0x280138
+#define MCPR_ACCESS_LOCK_LOCK					 (1L<<31)
 #define MCPR_NVM_ACCESS_ENABLE_EN				 (1L<<0)
 #define MCPR_NVM_ACCESS_ENABLE_WR_EN				 (1L<<1)
 #define MCPR_NVM_ADDR_NVM_ADDR_VALUE				 (0xffffffL<<0)
@@ -5732,6 +5735,7 @@
 #define MISC_REGISTERS_GPIO_PORT_SHIFT				 4
 #define MISC_REGISTERS_GPIO_SET_POS				 8
 #define MISC_REGISTERS_RESET_REG_1_CLEAR			 0x588
+#define MISC_REGISTERS_RESET_REG_1_RST_BRB1			 (0x1<<0)
 #define MISC_REGISTERS_RESET_REG_1_RST_DORQ			 (0x1<<19)
 #define MISC_REGISTERS_RESET_REG_1_RST_HC			 (0x1<<29)
 #define MISC_REGISTERS_RESET_REG_1_RST_NIG			 (0x1<<7)
-- 
1.7.9.rc2
