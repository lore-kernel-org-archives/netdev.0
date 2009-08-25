From: Alan Cox <alan@linux.intel.com>
Subject: [PATCH 24/26] et131x: clean up PM_CSR_t
Date: Tue, 25 Aug 2009 16:01:23 +0100
Message-ID: <20090825150118.16176.20490.stgit@localhost.localdomain>
References: <20090825145619.16176.68780.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: greg@kroah.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:47836 "EHLO
	bob.linux.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755233AbZHYPGp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 11:06:45 -0400
In-Reply-To: <20090825145619.16176.68780.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alan Cox <alan@linux.intel.com>
---

 drivers/staging/et131x/et1310_address_map.h |   45 ++++++++-------------------
 drivers/staging/et131x/et1310_mac.c         |   12 ++++---
 drivers/staging/et131x/et1310_pm.c          |   27 +++++++---------
 drivers/staging/et131x/et131x_initpci.c     |   20 ++++--------
 drivers/staging/et131x/et131x_isr.c         |   13 ++++----
 5 files changed, 43 insertions(+), 74 deletions(-)


diff --git a/drivers/staging/et131x/et1310_address_map.h b/drivers/staging/et131x/et1310_address_map.h
index 7f6baa3..f4867f5 100644
--- a/drivers/staging/et131x/et1310_address_map.h
+++ b/drivers/staging/et131x/et1310_address_map.h
@@ -73,37 +73,20 @@
 /*
  * structure for power management control status reg in global address map
  * located at address 0x0010
+ *	jagcore_rx_rdy	bit 9
+ *	jagcore_tx_rdy	bit 8
+ *	phy_lped_en	bit 7
+ *	phy_sw_coma	bit 6
+ *	rxclk_gate	bit 5
+ *	txclk_gate	bit 4
+ *	sysclk_gate	bit 3
+ *	jagcore_rx_en	bit 2
+ *	jagcore_tx_en	bit 1
+ *	gigephy_en	bit 0
  */
-typedef union _PM_CSR_t {
-	u32 value;
-	struct {
-#ifdef _BIT_FIELDS_HTOL
-		u32 unused:22;		/* bits 10-31 */
-		u32 pm_jagcore_rx_rdy:1;	/* bit 9 */
-		u32 pm_jagcore_tx_rdy:1;	/* bit 8 */
-		u32 pm_phy_lped_en:1;	/* bit 7 */
-		u32 pm_phy_sw_coma:1;	/* bit 6 */
-		u32 pm_rxclk_gate:1;	/* bit 5 */
-		u32 pm_txclk_gate:1;	/* bit 4 */
-		u32 pm_sysclk_gate:1;	/* bit 3 */
-		u32 pm_jagcore_rx_en:1;	/* bit 2 */
-		u32 pm_jagcore_tx_en:1;	/* bit 1 */
-		u32 pm_gigephy_en:1;	/* bit 0 */
-#else
-		u32 pm_gigephy_en:1;	/* bit 0 */
-		u32 pm_jagcore_tx_en:1;	/* bit 1 */
-		u32 pm_jagcore_rx_en:1;	/* bit 2 */
-		u32 pm_sysclk_gate:1;	/* bit 3 */
-		u32 pm_txclk_gate:1;	/* bit 4 */
-		u32 pm_rxclk_gate:1;	/* bit 5 */
-		u32 pm_phy_sw_coma:1;	/* bit 6 */
-		u32 pm_phy_lped_en:1;	/* bit 7 */
-		u32 pm_jagcore_tx_rdy:1;	/* bit 8 */
-		u32 pm_jagcore_rx_rdy:1;	/* bit 9 */
-		u32 unused:22;		/* bits 10-31 */
-#endif
-	} bits;
-} PM_CSR_t, *PPM_CSR_t;
+
+#define ET_PM_PHY_SW_COMA		0x40
+#define ET_PMCSR_INIT			0x38
 
 /*
  * structure for interrupt status reg in global address map
@@ -271,7 +254,7 @@ typedef struct _GLOBAL_t {			/* Location: */
 	u32 txq_end_addr;			/*  0x0004 */
 	u32 rxq_start_addr;			/*  0x0008 */
 	u32 rxq_end_addr;			/*  0x000C */
-	PM_CSR_t pm_csr;			/*  0x0010 */
+	u32 pm_csr;				/*  0x0010 */
 	u32 unused;				/*  0x0014 */
 	INTERRUPT_t int_status;			/*  0x0018 */
 	INTERRUPT_t int_mask;			/*  0x001C */
diff --git a/drivers/staging/et131x/et1310_mac.c b/drivers/staging/et131x/et1310_mac.c
index b2123d0..a27d815 100644
--- a/drivers/staging/et131x/et1310_mac.c
+++ b/drivers/staging/et131x/et1310_mac.c
@@ -672,7 +672,7 @@ void SetupDeviceForMulticast(struct et131x_adapter *etdev)
 	uint32_t hash2 = 0;
 	uint32_t hash3 = 0;
 	uint32_t hash4 = 0;
-	PM_CSR_t pm_csr;
+	u32 pm_csr;
 
 	DBG_ENTER(et131x_dbginfo);
 
@@ -718,8 +718,8 @@ void SetupDeviceForMulticast(struct et131x_adapter *etdev)
 	}
 
 	/* Write out the new hash to the device */
-	pm_csr.value = readl(&etdev->regs->global.pm_csr.value);
-	if (pm_csr.bits.pm_phy_sw_coma == 0) {
+	pm_csr = readl(&etdev->regs->global.pm_csr);
+	if ((pm_csr & ET_PM_PHY_SW_COMA) == 0) {
 		writel(hash1, &rxmac->multi_hash1);
 		writel(hash2, &rxmac->multi_hash2);
 		writel(hash3, &rxmac->multi_hash3);
@@ -735,7 +735,7 @@ void SetupDeviceForUnicast(struct et131x_adapter *etdev)
 	RXMAC_UNI_PF_ADDR1_t uni_pf1;
 	RXMAC_UNI_PF_ADDR2_t uni_pf2;
 	RXMAC_UNI_PF_ADDR3_t uni_pf3;
-	PM_CSR_t pm_csr;
+	u32 pm_csr;
 
 	DBG_ENTER(et131x_dbginfo);
 
@@ -763,8 +763,8 @@ void SetupDeviceForUnicast(struct et131x_adapter *etdev)
 	uni_pf1.bits.addr1_5 = etdev->CurrentAddress[4];
 	uni_pf1.bits.addr1_6 = etdev->CurrentAddress[5];
 
-	pm_csr.value = readl(&etdev->regs->global.pm_csr.value);
-	if (pm_csr.bits.pm_phy_sw_coma == 0) {
+	pm_csr = readl(&etdev->regs->global.pm_csr);
+	if ((pm_csr & ET_PM_PHY_SW_COMA) == 0) {
 		writel(uni_pf1.value, &rxmac->uni_pf_addr1.value);
 		writel(uni_pf2.value, &rxmac->uni_pf_addr2.value);
 		writel(uni_pf3.value, &rxmac->uni_pf_addr3.value);
diff --git a/drivers/staging/et131x/et1310_pm.c b/drivers/staging/et131x/et1310_pm.c
index 846c80b..ea186a8 100644
--- a/drivers/staging/et131x/et1310_pm.c
+++ b/drivers/staging/et131x/et1310_pm.c
@@ -120,12 +120,11 @@ extern dbg_info_t *et131x_dbginfo;
 void EnablePhyComa(struct et131x_adapter *etdev)
 {
 	unsigned long flags;
-	PM_CSR_t GlobalPmCSR;
-	int32_t LoopCounter = 10;
+	u32 GlobalPmCSR;
 
 	DBG_ENTER(et131x_dbginfo);
 
-	GlobalPmCSR.value = readl(&etdev->regs->global.pm_csr.value);
+	GlobalPmCSR = readl(&etdev->regs->global.pm_csr);
 
 	/* Save the GbE PHY speed and duplex modes. Need to restore this
 	 * when cable is plugged back in
@@ -141,14 +140,12 @@ void EnablePhyComa(struct et131x_adapter *etdev)
 	/* Wait for outstanding Receive packets */
 
 	/* Gate off JAGCore 3 clock domains */
-	GlobalPmCSR.bits.pm_sysclk_gate = 0;
-	GlobalPmCSR.bits.pm_txclk_gate = 0;
-	GlobalPmCSR.bits.pm_rxclk_gate = 0;
-	writel(GlobalPmCSR.value, &etdev->regs->global.pm_csr.value);
+	GlobalPmCSR &= ~ET_PMCSR_INIT;
+	writel(GlobalPmCSR, &etdev->regs->global.pm_csr);
 
 	/* Program gigE PHY in to Coma mode */
-	GlobalPmCSR.bits.pm_phy_sw_coma = 1;
-	writel(GlobalPmCSR.value, &etdev->regs->global.pm_csr.value);
+	GlobalPmCSR |= ET_PM_PHY_SW_COMA;
+	writel(GlobalPmCSR, &etdev->regs->global.pm_csr);
 
 	DBG_LEAVE(et131x_dbginfo);
 }
@@ -159,18 +156,16 @@ void EnablePhyComa(struct et131x_adapter *etdev)
  */
 void DisablePhyComa(struct et131x_adapter *etdev)
 {
-	PM_CSR_t GlobalPmCSR;
+	u32 GlobalPmCSR;
 
 	DBG_ENTER(et131x_dbginfo);
 
-	GlobalPmCSR.value = readl(&etdev->regs->global.pm_csr.value);
+	GlobalPmCSR = readl(&etdev->regs->global.pm_csr);
 
 	/* Disable phy_sw_coma register and re-enable JAGCore clocks */
-	GlobalPmCSR.bits.pm_sysclk_gate = 1;
-	GlobalPmCSR.bits.pm_txclk_gate = 1;
-	GlobalPmCSR.bits.pm_rxclk_gate = 1;
-	GlobalPmCSR.bits.pm_phy_sw_coma = 0;
-	writel(GlobalPmCSR.value, &etdev->regs->global.pm_csr.value);
+	GlobalPmCSR |= ET_PMCSR_INIT;
+	GlobalPmCSR &= ~ET_PM_PHY_SW_COMA;
+	writel(GlobalPmCSR, &etdev->regs->global.pm_csr);
 
 	/* Restore the GbE PHY speed and duplex modes;
 	 * Reset JAGCore; re-configure and initialize JAGCore and gigE PHY
diff --git a/drivers/staging/et131x/et131x_initpci.c b/drivers/staging/et131x/et131x_initpci.c
index bea9918..d7a1b34 100644
--- a/drivers/staging/et131x/et131x_initpci.c
+++ b/drivers/staging/et131x/et131x_initpci.c
@@ -474,16 +474,16 @@ int et131x_find_adapter(struct et131x_adapter *adapter, struct pci_dev *pdev)
 void et131x_error_timer_handler(unsigned long data)
 {
 	struct et131x_adapter *etdev = (struct et131x_adapter *) data;
-	PM_CSR_t pm_csr;
+	u32 pm_csr;
 
-	pm_csr.value = readl(&etdev->regs->global.pm_csr.value);
+	pm_csr = readl(&etdev->regs->global.pm_csr);
 
-	if (pm_csr.bits.pm_phy_sw_coma == 0)
+	if ((pm_csr & ET_PM_PHY_SW_COMA) == 0)
 		UpdateMacStatHostCounters(etdev);
 	else
 		DBG_VERBOSE(et131x_dbginfo,
 			    "No interrupts, in PHY coma, pm_csr = 0x%x\n",
-			    pm_csr.value);
+			    pm_csr);
 
 	if (!etdev->Bmsr.bits.link_status &&
 	    etdev->RegistryPhyComa &&
@@ -494,7 +494,7 @@ void et131x_error_timer_handler(unsigned long data)
 	if (etdev->PoMgmt.TransPhyComaModeOnBoot == 10) {
 		if (!etdev->Bmsr.bits.link_status
 		    && etdev->RegistryPhyComa) {
-			if (pm_csr.bits.pm_phy_sw_coma == 0) {
+			if ((pm_csr & ET_PM_PHY_SW_COMA) == 0) {
 				/* NOTE - This was originally a 'sync with
 				 *  interrupt'. How to do that under Linux?
 				 */
@@ -1002,15 +1002,7 @@ int __devinit et131x_pci_setup(struct pci_dev *pdev,
 	/* Perform device-specific initialization here (See code below) */
 
 	/* If Phy COMA mode was enabled when we went down, disable it here. */
-	{
-		PM_CSR_t GlobalPmCSR = { 0 };
-
-		GlobalPmCSR.bits.pm_sysclk_gate = 1;
-		GlobalPmCSR.bits.pm_txclk_gate = 1;
-		GlobalPmCSR.bits.pm_rxclk_gate = 1;
-		writel(GlobalPmCSR.value,
-		       &adapter->regs->global.pm_csr.value);
-	}
+	writel(ET_PMCSR_INIT,  &adapter->regs->global.pm_csr);
 
 	/* Issue a global reset to the et1310 */
 	DBG_TRACE(et131x_dbginfo, "Issuing soft reset...\n");
diff --git a/drivers/staging/et131x/et131x_isr.c b/drivers/staging/et131x/et131x_isr.c
index 478569f..00b815a 100644
--- a/drivers/staging/et131x/et131x_isr.c
+++ b/drivers/staging/et131x/et131x_isr.c
@@ -274,14 +274,13 @@ void et131x_isr_handler(struct work_struct *work)
 			 */
 			if (etdev->FlowControl == TxOnly ||
 			    etdev->FlowControl == Both) {
-				PM_CSR_t pm_csr;
+				u32 pm_csr;
 
 				/* Tell the device to send a pause packet via
 				 * the back pressure register
 				 */
-				pm_csr.value =
-					readl(&iomem->global.pm_csr.value);
-				if (pm_csr.bits.pm_phy_sw_coma == 0) {
+				pm_csr = readl(&iomem->global.pm_csr);
+				if ((pm_csr & ET_PM_PHY_SW_COMA) == 0) {
 					TXMAC_BP_CTRL_t bp_ctrl = { 0 };
 
 					bp_ctrl.bits.bp_req = 1;
@@ -351,7 +350,7 @@ void et131x_isr_handler(struct work_struct *work)
 
 		/* Handle the PHY interrupt */
 		if (GlobStatus.bits.phy_interrupt) {
-			PM_CSR_t pm_csr;
+			u32 pm_csr;
 			MI_BMSR_t BmsrInts, BmsrData;
 			MI_ISR_t myIsr;
 
@@ -360,8 +359,8 @@ void et131x_isr_handler(struct work_struct *work)
 			/* If we are in coma mode when we get this interrupt,
 			 * we need to disable it.
 			 */
-			pm_csr.value = readl(&iomem->global.pm_csr.value);
-			if (pm_csr.bits.pm_phy_sw_coma == 1) {
+			pm_csr = readl(&iomem->global.pm_csr);
+			if (pm_csr & ET_PM_PHY_SW_COMA) {
 				/*
 				 * Check to see if we are in coma mode and if
 				 * so, disable it because we will not be able

