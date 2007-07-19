From: "Michael Chan" <mchan@broadcom.com>
Subject: [TG3]: Fix msi issue with kexec/kdump.
Date: Wed, 18 Jul 2007 20:40:47 -0700
Message-ID: <1184816447.10854.30.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: tina.yang@oracle.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1733 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753422AbXGSCr6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2007 22:47:58 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Fix msi issue with kexec/kdump.

Tina Yang <tina.yang@oracle.com> discovered an MSI related problem
when doing kdump.  The problem is that the kexec kernel is booted
without going through system reset, and as a result, MSI may already
be enabled when tg3_init_one() is called.  tg3_init_one() calls
pci_save_state() which will save the stale MSI state.  Later on in
tg3_open(), we call pci_enable_msi() to reconfigure MSI on the chip
before we reset the chip.  After chip reset, we call
pci_restore_state() which will put the stale MSI address/data back
onto the chip.

This is no longer a problem in the latest kernel because
pci_restore_state() has been changed to restore MSI state from
internal data structures which will guarantee restoring the proper
MSI state.

But I think we should still fix it.  Our save and restore sequence
can still cause very subtle problems down the road.  The fix is to
have our own functions save and restore precisely what we need.  We
also change it to save and restore state inside tg3_chip_reset() in a
more straight forward way.

Thanks to Tina for helping to test and debug the problem.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 5ee1476..7b362ed 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4847,6 +4847,59 @@ static int tg3_poll_fw(struct tg3 *tp)
 	return 0;
 }
 
+/* Save PCI command register before chip reset */
+static void tg3_save_pci_state(struct tg3 *tp)
+{
+	u32 val;
+
+	pci_read_config_dword(tp->pdev, TG3PCI_COMMAND, &val);
+	tp->pci_cmd = val;
+}
+
+/* Restore PCI state after chip reset */
+static void tg3_restore_pci_state(struct tg3 *tp)
+{
+	u32 val;
+
+	/* Re-enable indirect register accesses. */
+	pci_write_config_dword(tp->pdev, TG3PCI_MISC_HOST_CTRL,
+			       tp->misc_host_ctrl);
+
+	/* Set MAX PCI retry to zero. */
+	val = (PCISTATE_ROM_ENABLE | PCISTATE_ROM_RETRY_ENABLE);
+	if (tp->pci_chip_rev_id == CHIPREV_ID_5704_A0 &&
+	    (tp->tg3_flags & TG3_FLAG_PCIX_MODE))
+		val |= PCISTATE_RETRY_SAME_DMA;
+	pci_write_config_dword(tp->pdev, TG3PCI_PCISTATE, val);
+
+	pci_write_config_dword(tp->pdev, TG3PCI_COMMAND, tp->pci_cmd);
+
+	/* Make sure PCI-X relaxed ordering bit is clear. */
+	pci_read_config_dword(tp->pdev, TG3PCI_X_CAPS, &val);
+	val &= ~PCIX_CAPS_RELAXED_ORDERING;
+	pci_write_config_dword(tp->pdev, TG3PCI_X_CAPS, val);
+
+	if (tp->tg3_flags2 & TG3_FLG2_5780_CLASS) {
+		u32 val;
+
+		/* Chip reset on 5780 will reset MSI enable bit,
+		 * so need to restore it.
+		 */
+		if (tp->tg3_flags2 & TG3_FLG2_USING_MSI) {
+			u16 ctrl;
+
+			pci_read_config_word(tp->pdev,
+					     tp->msi_cap + PCI_MSI_FLAGS,
+					     &ctrl);
+			pci_write_config_word(tp->pdev,
+					      tp->msi_cap + PCI_MSI_FLAGS,
+					      ctrl | PCI_MSI_FLAGS_ENABLE);
+			val = tr32(MSGINT_MODE);
+			tw32(MSGINT_MODE, val | MSGINT_MODE_ENABLE);
+		}
+	}
+}
+
 static void tg3_stop_fw(struct tg3 *);
 
 /* tp->lock is held. */
@@ -4863,6 +4916,12 @@ static int tg3_chip_reset(struct tg3 *tp)
 	 */
 	tp->nvram_lock_cnt = 0;
 
+	/* GRC_MISC_CFG core clock reset will clear the memory
+	 * enable bit in PCI register 4 and the MSI enable bit
+	 * on some chips, so we save relevant registers here.
+	 */
+	tg3_save_pci_state(tp);
+
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5752 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787)
@@ -4961,50 +5020,14 @@ static int tg3_chip_reset(struct tg3 *tp)
 		pci_write_config_dword(tp->pdev, 0xd8, 0xf5000);
 	}
 
-	/* Re-enable indirect register accesses. */
-	pci_write_config_dword(tp->pdev, TG3PCI_MISC_HOST_CTRL,
-			       tp->misc_host_ctrl);
-
-	/* Set MAX PCI retry to zero. */
-	val = (PCISTATE_ROM_ENABLE | PCISTATE_ROM_RETRY_ENABLE);
-	if (tp->pci_chip_rev_id == CHIPREV_ID_5704_A0 &&
-	    (tp->tg3_flags & TG3_FLAG_PCIX_MODE))
-		val |= PCISTATE_RETRY_SAME_DMA;
-	pci_write_config_dword(tp->pdev, TG3PCI_PCISTATE, val);
-
-	pci_restore_state(tp->pdev);
+	tg3_restore_pci_state(tp);
 
 	tp->tg3_flags &= ~TG3_FLAG_CHIP_RESETTING;
 
-	/* Make sure PCI-X relaxed ordering bit is clear. */
-	pci_read_config_dword(tp->pdev, TG3PCI_X_CAPS, &val);
-	val &= ~PCIX_CAPS_RELAXED_ORDERING;
-	pci_write_config_dword(tp->pdev, TG3PCI_X_CAPS, val);
-
-	if (tp->tg3_flags2 & TG3_FLG2_5780_CLASS) {
-		u32 val;
-
-		/* Chip reset on 5780 will reset MSI enable bit,
-		 * so need to restore it.
-		 */
-		if (tp->tg3_flags2 & TG3_FLG2_USING_MSI) {
-			u16 ctrl;
-
-			pci_read_config_word(tp->pdev,
-					     tp->msi_cap + PCI_MSI_FLAGS,
-					     &ctrl);
-			pci_write_config_word(tp->pdev,
-					      tp->msi_cap + PCI_MSI_FLAGS,
-					      ctrl | PCI_MSI_FLAGS_ENABLE);
-			val = tr32(MSGINT_MODE);
-			tw32(MSGINT_MODE, val | MSGINT_MODE_ENABLE);
-		}
-
+	val = 0;
+	if (tp->tg3_flags2 & TG3_FLG2_5780_CLASS)
 		val = tr32(MEMARB_MODE);
-		tw32(MEMARB_MODE, val | MEMARB_MODE_ENABLE);
-
-	} else
-		tw32(MEMARB_MODE, MEMARB_MODE_ENABLE);
+	tw32(MEMARB_MODE, val | MEMARB_MODE_ENABLE);
 
 	if (tp->pci_chip_rev_id == CHIPREV_ID_5750_A3) {
 		tg3_stop_fw(tp);
@@ -11978,7 +12001,6 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	 */
 	if ((tr32(HOSTCC_MODE) & HOSTCC_MODE_ENABLE) ||
 	    (tr32(WDMAC_MODE) & WDMAC_MODE_ENABLE)) {
-		pci_save_state(tp->pdev);
 		tw32(MEMARB_MODE, MEMARB_MODE_ENABLE);
 		tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
 	}
@@ -12007,12 +12029,6 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 
 	tg3_init_coal(tp);
 
-	/* Now that we have fully setup the chip, save away a snapshot
-	 * of the PCI config space.  We need to restore this after
-	 * GRC_MISC_CFG core clock resets and some resume events.
-	 */
-	pci_save_state(tp->pdev);
-
 	pci_set_drvdata(pdev, dev);
 
 	err = register_netdev(dev);
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index d84e75e..5c21f49 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2345,6 +2345,7 @@ struct tg3 {
 #define PHY_REV_BCM5411_X0		0x1 /* Found on Netgear GA302T */
 
 	u32				led_ctrl;
+	u32				pci_cmd;
 
 	char				board_part_number[24];
 	char				fw_ver[16];


