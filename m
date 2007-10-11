From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 2/5] tg3: Add 5761 APE support
Date: Wed, 10 Oct 2007 17:45:21 -0700
Message-ID: <1192063522.4878.184.camel@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1611 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757091AbXJKApg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2007 20:45:36 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds support for the new APE block, present in 5761 chips.
APE stands for Application Processing Engine.  The primary function of
the APE is to process manageability traffic, such as ASF.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 3200c9c..5b6c1b2 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -314,6 +314,16 @@ static u32 tg3_read32(struct tg3 *tp, u32 off)
 	return (readl(tp->regs + off));
 }
 
+static void tg3_ape_write32(struct tg3 *tp, u32 off, u32 val)
+{
+	writel(val, tp->aperegs + off);
+}
+
+static u32 tg3_ape_read32(struct tg3 *tp, u32 off)
+{
+	return (readl(tp->aperegs + off));
+}
+
 static void tg3_write_indirect_reg32(struct tg3 *tp, u32 off, u32 val)
 {
 	unsigned long flags;
@@ -500,6 +510,73 @@ static void tg3_read_mem(struct tg3 *tp, u32 off, u32 *val)
 	spin_unlock_irqrestore(&tp->indirect_lock, flags);
 }
 
+static void tg3_ape_lock_init(struct tg3 *tp)
+{
+	int i;
+
+	/* Make sure the driver hasn't any stale locks. */
+	for (i = 0; i < 8; i++)
+		tg3_ape_write32(tp, TG3_APE_LOCK_GRANT + 4 * i,
+				APE_LOCK_GRANT_DRIVER);
+}
+
+static int tg3_ape_lock(struct tg3 *tp, int locknum)
+{
+	int i, off;
+	int ret = 0;
+	u32 status;
+
+	if (!(tp->tg3_flags3 & TG3_FLG3_ENABLE_APE))
+		return 0;
+
+	switch (locknum) {
+		case TG3_APE_LOCK_MEM:
+			break;
+		default:
+			return -EINVAL;
+	}
+
+	off = 4 * locknum;
+
+	tg3_ape_write32(tp, TG3_APE_LOCK_REQ + off, APE_LOCK_REQ_DRIVER);
+
+	/* Wait for up to 1 millisecond to acquire lock. */
+	for (i = 0; i < 100; i++) {
+		status = tg3_ape_read32(tp, TG3_APE_LOCK_GRANT + off);
+		if (status == APE_LOCK_GRANT_DRIVER)
+			break;
+		udelay(10);
+	}
+
+	if (status != APE_LOCK_GRANT_DRIVER) {
+		/* Revoke the lock request. */
+		tg3_ape_write32(tp, TG3_APE_LOCK_GRANT + off,
+				APE_LOCK_GRANT_DRIVER);
+
+		ret = -EBUSY;
+	}
+
+	return ret;
+}
+
+static void tg3_ape_unlock(struct tg3 *tp, int locknum)
+{
+	int off;
+
+	if (!(tp->tg3_flags3 & TG3_FLG3_ENABLE_APE))
+		return;
+
+	switch (locknum) {
+		case TG3_APE_LOCK_MEM:
+			break;
+		default:
+			return;
+	}
+
+	off = 4 * locknum;
+	tg3_ape_write32(tp, TG3_APE_LOCK_GRANT + off, APE_LOCK_GRANT_DRIVER);
+}
+
 static void tg3_disable_ints(struct tg3 *tp)
 {
 	tw32(TG3PCI_MISC_HOST_CTRL,
@@ -1448,7 +1525,8 @@ static int tg3_set_power_state(struct tg3 *tp, pci_power_t state)
 	}
 
 	if (!(tp->tg3_flags & TG3_FLAG_WOL_ENABLE) &&
-	    !(tp->tg3_flags & TG3_FLAG_ENABLE_ASF))
+	    !(tp->tg3_flags & TG3_FLAG_ENABLE_ASF) &&
+	    !(tp->tg3_flags3 & TG3_FLG3_ENABLE_APE))
 		tg3_power_down_phy(tp);
 
 	tg3_frob_aux_power(tp);
@@ -4726,6 +4804,80 @@ static void tg3_disable_nvram_access(struct tg3 *tp)
 	}
 }
 
+static void tg3_ape_send_event(struct tg3 *tp, u32 event)
+{
+	int i;
+	u32 apedata;
+
+	apedata = tg3_ape_read32(tp, TG3_APE_SEG_SIG);
+	if (apedata != APE_SEG_SIG_MAGIC)
+		return;
+
+	apedata = tg3_ape_read32(tp, TG3_APE_FW_STATUS);
+	if (apedata != APE_FW_STATUS_READY)
+		return;
+
+	/* Wait for up to 1 millisecond for APE to service previous event. */
+	for (i = 0; i < 10; i++) {
+		if (tg3_ape_lock(tp, TG3_APE_LOCK_MEM))
+			return;
+
+		apedata = tg3_ape_read32(tp, TG3_APE_EVENT_STATUS);
+
+		if (!(apedata & APE_EVENT_STATUS_EVENT_PENDING))
+			tg3_ape_write32(tp, TG3_APE_EVENT_STATUS,
+					event | APE_EVENT_STATUS_EVENT_PENDING);
+
+		tg3_ape_unlock(tp, TG3_APE_LOCK_MEM);
+
+		if (!(apedata & APE_EVENT_STATUS_EVENT_PENDING))
+			break;
+
+		udelay(100);
+	}
+
+	if (!(apedata & APE_EVENT_STATUS_EVENT_PENDING))
+		tg3_ape_write32(tp, TG3_APE_EVENT, APE_EVENT_1);
+}
+
+static void tg3_ape_driver_state_change(struct tg3 *tp, int kind)
+{
+	u32 event;
+	u32 apedata;
+
+	if (!(tp->tg3_flags3 & TG3_FLG3_ENABLE_APE))
+		return;
+
+	switch (kind) {
+		case RESET_KIND_INIT:
+			tg3_ape_write32(tp, TG3_APE_HOST_SEG_SIG,
+					APE_HOST_SEG_SIG_MAGIC);
+			tg3_ape_write32(tp, TG3_APE_HOST_SEG_LEN,
+					APE_HOST_SEG_LEN_MAGIC);
+			apedata = tg3_ape_read32(tp, TG3_APE_HOST_INIT_COUNT);
+			tg3_ape_write32(tp, TG3_APE_HOST_INIT_COUNT, ++apedata);
+			tg3_ape_write32(tp, TG3_APE_HOST_DRIVER_ID,
+					APE_HOST_DRIVER_ID_MAGIC);
+			tg3_ape_write32(tp, TG3_APE_HOST_BEHAVIOR,
+					APE_HOST_BEHAV_NO_PHYLOCK);
+
+			event = APE_EVENT_STATUS_STATE_START;
+			break;
+		case RESET_KIND_SHUTDOWN:
+			event = APE_EVENT_STATUS_STATE_UNLOAD;
+			break;
+		case RESET_KIND_SUSPEND:
+			event = APE_EVENT_STATUS_STATE_SUSPEND;
+			break;
+		default:
+			return;
+	}
+
+	event |= APE_EVENT_STATUS_DRIVER_EVNT | APE_EVENT_STATUS_STATE_CHNGE;
+
+	tg3_ape_send_event(tp, event);
+}
+
 /* tp->lock is held. */
 static void tg3_write_sig_pre_reset(struct tg3 *tp, int kind)
 {
@@ -4753,6 +4905,10 @@ static void tg3_write_sig_pre_reset(struct tg3 *tp, int kind)
 			break;
 		};
 	}
+
+	if (kind == RESET_KIND_INIT ||
+	    kind == RESET_KIND_SUSPEND)
+		tg3_ape_driver_state_change(tp, kind);
 }
 
 /* tp->lock is held. */
@@ -4774,6 +4930,9 @@ static void tg3_write_sig_post_reset(struct tg3 *tp, int kind)
 			break;
 		};
 	}
+
+	if (kind == RESET_KIND_SHUTDOWN)
+		tg3_ape_driver_state_change(tp, kind);
 }
 
 /* tp->lock is held. */
@@ -4864,6 +5023,10 @@ static void tg3_restore_pci_state(struct tg3 *tp)
 	if (tp->pci_chip_rev_id == CHIPREV_ID_5704_A0 &&
 	    (tp->tg3_flags & TG3_FLAG_PCIX_MODE))
 		val |= PCISTATE_RETRY_SAME_DMA;
+	/* Allow reads and writes to the APE register and memory space. */
+	if (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE)
+		val |= PCISTATE_ALLOW_APE_CTLSPC_WR |
+		       PCISTATE_ALLOW_APE_SHMEM_WR;
 	pci_write_config_dword(tp->pdev, TG3PCI_PCISTATE, val);
 
 	pci_write_config_dword(tp->pdev, TG3PCI_COMMAND, tp->pci_cmd);
@@ -5092,7 +5255,8 @@ static int tg3_chip_reset(struct tg3 *tp)
 /* tp->lock is held. */
 static void tg3_stop_fw(struct tg3 *tp)
 {
-	if (tp->tg3_flags & TG3_FLAG_ENABLE_ASF) {
+	if ((tp->tg3_flags & TG3_FLAG_ENABLE_ASF) &&
+	   !(tp->tg3_flags3 & TG3_FLG3_ENABLE_APE)) {
 		u32 val;
 		int i;
 
@@ -6173,6 +6337,16 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		tw32(TG3PCI_PCISTATE, val);
 	}
 
+	if (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE) {
+		/* Allow reads and writes to the
+		 * APE register and memory space.
+		 */
+		val = tr32(TG3PCI_PCISTATE);
+		val |= PCISTATE_ALLOW_APE_CTLSPC_WR |
+		       PCISTATE_ALLOW_APE_SHMEM_WR;
+		tw32(TG3PCI_PCISTATE, val);
+	}
+
 	if (GET_CHIP_REV(tp->pci_chip_rev_id) == CHIPREV_5704_BX) {
 		/* Enable some hw fixes.  */
 		val = tr32(TG3PCI_MSI_DATA);
@@ -6780,6 +6954,10 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		break;
 	};
 
+	/* Write our heartbeat update interval to APE. */
+	tg3_ape_write32(tp, TG3_APE_HOST_HEARTBEAT_INT_MS,
+			APE_HOST_HEARTBEAT_INT_DISABLE);
+
 	tg3_write_sig_post_reset(tp, RESET_KIND_INIT);
 
 	return 0;
@@ -10302,6 +10480,8 @@ static void __devinit tg3_get_eeprom_hw_cfg(struct tg3 *tp)
 			if (tp->tg3_flags2 & TG3_FLG2_5750_PLUS)
 				tp->tg3_flags2 |= TG3_FLG2_ASF_NEW_HANDSHAKE;
 		}
+		if (nic_cfg & NIC_SRAM_DATA_CFG_APE_ENABLE)
+			tp->tg3_flags3 |= TG3_FLG3_ENABLE_APE;
 		if (tp->tg3_flags2 & TG3_FLG2_ANY_SERDES &&
 		    !(nic_cfg & NIC_SRAM_DATA_CFG_FIBER_WOL))
 			tp->tg3_flags &= ~TG3_FLAG_WOL_CAP;
@@ -10334,7 +10514,8 @@ static int __devinit tg3_phy_probe(struct tg3 *tp)
 	 * firwmare access to the PHY hardware.
 	 */
 	err = 0;
-	if (tp->tg3_flags & TG3_FLAG_ENABLE_ASF) {
+	if ((tp->tg3_flags & TG3_FLAG_ENABLE_ASF) ||
+	    (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE)) {
 		hw_phy_id = hw_phy_id_masked = PHY_ID_INVALID;
 	} else {
 		/* Now read the physical PHY_ID from the chip and verify
@@ -10381,6 +10562,7 @@ static int __devinit tg3_phy_probe(struct tg3 *tp)
 	}
 
 	if (!(tp->tg3_flags2 & TG3_FLG2_ANY_SERDES) &&
+	    !(tp->tg3_flags3 & TG3_FLG3_ENABLE_APE) &&
 	    !(tp->tg3_flags & TG3_FLAG_ENABLE_ASF)) {
 		u32 bmsr, adv_reg, tg3_ctrl, mask;
 
@@ -10972,6 +11154,16 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	 */
 	tg3_get_eeprom_hw_cfg(tp);
 
+	if (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE) {
+		/* Allow reads and writes to the
+		 * APE register and memory space.
+		 */
+		pci_state_reg |= PCISTATE_ALLOW_APE_CTLSPC_WR |
+				 PCISTATE_ALLOW_APE_SHMEM_WR;
+		pci_write_config_dword(tp->pdev, TG3PCI_PCISTATE,
+				       pci_state_reg);
+	}
+
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784)
 		tp->tg3_flags |= TG3_FLAG_CPMU_PRESENT;
 
@@ -12165,13 +12357,35 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 
 	tg3_init_coal(tp);
 
+	if (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE) {
+		if (!(pci_resource_flags(pdev, 2) & IORESOURCE_MEM)) {
+			printk(KERN_ERR PFX "Cannot find proper PCI device "
+			       "base address for APE, aborting.\n");
+			err = -ENODEV;
+			goto err_out_iounmap;
+		}
+
+		tg3reg_base = pci_resource_start(pdev, 2);
+		tg3reg_len = pci_resource_len(pdev, 2);
+
+		tp->aperegs = ioremap_nocache(tg3reg_base, tg3reg_len);
+		if (tp->aperegs == 0UL) {
+			printk(KERN_ERR PFX "Cannot map APE registers, "
+			       "aborting.\n");
+			err = -ENOMEM;
+			goto err_out_iounmap;
+		}
+
+		tg3_ape_lock_init(tp);
+	}
+
 	pci_set_drvdata(pdev, dev);
 
 	err = register_netdev(dev);
 	if (err) {
 		printk(KERN_ERR PFX "Cannot register net device, "
 		       "aborting.\n");
-		goto err_out_iounmap;
+		goto err_out_apeunmap;
 	}
 
 	printk(KERN_INFO "%s: Tigon3 [partno(%s) rev %04x PHY(%s)] (%s) %s Ethernet ",
@@ -12204,6 +12418,12 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 
 	return 0;
 
+err_out_apeunmap:
+	if (tp->aperegs) {
+		iounmap(tp->aperegs);
+		tp->aperegs = NULL;
+	}
+
 err_out_iounmap:
 	if (tp->regs) {
 		iounmap(tp->regs);
@@ -12231,6 +12451,10 @@ static void __devexit tg3_remove_one(struct pci_dev *pdev)
 
 		flush_scheduled_work();
 		unregister_netdev(dev);
+		if (tp->aperegs) {
+			iounmap(tp->aperegs);
+			tp->aperegs = NULL;
+		}
 		if (tp->regs) {
 			iounmap(tp->regs);
 			tp->regs = NULL;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 88d08f3..632c2f0 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -192,6 +192,8 @@
 #define  PCISTATE_ROM_RETRY_ENABLE	 0x00000040
 #define  PCISTATE_FLAT_VIEW		 0x00000100
 #define  PCISTATE_RETRY_SAME_DMA	 0x00002000
+#define  PCISTATE_ALLOW_APE_CTLSPC_WR	 0x00010000
+#define  PCISTATE_ALLOW_APE_SHMEM_WR	 0x00020000
 #define TG3PCI_CLOCK_CTRL		0x00000074
 #define  CLOCK_CTRL_CORECLK_DISABLE	 0x00000200
 #define  CLOCK_CTRL_RXCLK_DISABLE	 0x00000400
@@ -1560,6 +1562,7 @@
 #define  NIC_SRAM_DATA_CFG_MINI_PCI		 0x00001000
 #define  NIC_SRAM_DATA_CFG_FIBER_WOL		 0x00004000
 #define  NIC_SRAM_DATA_CFG_NO_GPIO2		 0x00100000
+#define  NIC_SRAM_DATA_CFG_APE_ENABLE		 0x00200000
 
 #define NIC_SRAM_DATA_VER			0x00000b5c
 #define  NIC_SRAM_DATA_VER_SHIFT		 16
@@ -1688,6 +1691,47 @@
 #define MII_TG3_TEST1_TRIM_EN		0x0010
 #define MII_TG3_TEST1_CRC_EN		0x8000
 
+/* APE registers.  Accessible through BAR1 */
+#define TG3_APE_EVENT			0x000c
+#define  APE_EVENT_1			 0x00000001
+#define TG3_APE_LOCK_REQ		0x002c
+#define  APE_LOCK_REQ_DRIVER		 0x00001000
+#define TG3_APE_LOCK_GRANT		0x004c
+#define  APE_LOCK_GRANT_DRIVER		 0x00001000
+#define TG3_APE_SEG_SIG			0x4000
+#define  APE_SEG_SIG_MAGIC		 0x41504521
+
+/* APE shared memory.  Accessible through BAR1 */
+#define TG3_APE_FW_STATUS		0x400c
+#define  APE_FW_STATUS_READY		 0x00000100
+#define TG3_APE_HOST_SEG_SIG		0x4200
+#define  APE_HOST_SEG_SIG_MAGIC		 0x484f5354
+#define TG3_APE_HOST_SEG_LEN		0x4204
+#define  APE_HOST_SEG_LEN_MAGIC		 0x0000001c
+#define TG3_APE_HOST_INIT_COUNT		0x4208
+#define TG3_APE_HOST_DRIVER_ID		0x420c
+#define  APE_HOST_DRIVER_ID_MAGIC	 0xf0035100
+#define TG3_APE_HOST_BEHAVIOR		0x4210
+#define  APE_HOST_BEHAV_NO_PHYLOCK	 0x00000001
+#define TG3_APE_HOST_HEARTBEAT_INT_MS	0x4214
+#define  APE_HOST_HEARTBEAT_INT_DISABLE	 0
+#define  APE_HOST_HEARTBEAT_INT_5SEC	 5000
+#define TG3_APE_HOST_HEARTBEAT_COUNT	0x4218
+
+#define TG3_APE_EVENT_STATUS		0x4300
+
+#define  APE_EVENT_STATUS_DRIVER_EVNT	 0x00000010
+#define  APE_EVENT_STATUS_STATE_CHNGE	 0x00000500
+#define  APE_EVENT_STATUS_STATE_START	 0x00010000
+#define  APE_EVENT_STATUS_STATE_UNLOAD	 0x00020000
+#define  APE_EVENT_STATUS_STATE_WOL	 0x00030000
+#define  APE_EVENT_STATUS_STATE_SUSPEND	 0x00040000
+#define  APE_EVENT_STATUS_EVENT_PENDING	 0x80000000
+
+/* APE convenience enumerations. */
+#define TG3_APE_LOCK_MEM                4
+
+
 /* There are two ways to manage the TX descriptors on the tigon3.
  * Either the descriptors are in host DMA'able memory, or they
  * exist only in the cards on-chip SRAM.  All 16 send bds are under
@@ -2163,6 +2207,7 @@ struct tg3 {
 	void				(*write32_mbox) (struct tg3 *, u32,
 							 u32);
 	void __iomem			*regs;
+	void __iomem			*aperegs;
 	struct net_device		*dev;
 	struct pci_dev			*pdev;
 
@@ -2290,6 +2335,7 @@ struct tg3 {
 #define TG3_FLG2_PHY_ADJUST_TRIM	0x80000000
 	u32				tg3_flags3;
 #define TG3_FLG3_NO_NVRAM_ADDR_TRANS	0x00000001
+#define TG3_FLG3_ENABLE_APE		0x00000002
 
 	struct timer_list		timer;
 	u16				timer_counter;


