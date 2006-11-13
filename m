From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH] qla3xxx: Add support for Qlogic ISP4032 chip.
Date: Mon, 13 Nov 2006 14:50:15 -0800
Message-ID: <1163458215.11785.10.camel@linux-7mw0.site>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:26262 "EHLO
	avexch1.qlogic.com") by vger.kernel.org with ESMTP id S933089AbWKMWg5
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Nov 2006 17:36:57 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From 742b2f96f918225560f338b6f975c5c7ae23ba9c Mon Sep 17 00:00:00 2001
From: Ron Mercer <ron.mercer@qlogic.com>
Date: Mon, 13 Nov 2006 13:03:17 -0800
Subject: [PATCH] Add support for Qlogic ISP4032 chip.

Remove unused variables.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>

---
 drivers/net/qla3xxx.c |  831
+++++++++++++++++++++++++++++++------------------
 drivers/net/qla3xxx.h |  107 +++++-
 2 files changed, 614 insertions(+), 324 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index ec640f6..902135c 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -22,6 +22,7 @@ #include <linux/interrupt.h>
 #include <linux/errno.h>
 #include <linux/ioport.h>
 #include <linux/ip.h>
+#include <linux/in.h>
 #include <linux/if_arp.h>
 #include <linux/if_ether.h>
 #include <linux/netdevice.h>
@@ -38,7 +39,7 @@ #include "qla3xxx.h"
 
 #define DRV_NAME  	"qla3xxx"
 #define DRV_STRING 	"QLogic ISP3XXX Network Driver"
-#define DRV_VERSION	"v2.02.00-k36"
+#define DRV_VERSION	"v2.03.00-k2"
 #define PFX		DRV_NAME " "
 
 static const char ql3xxx_driver_name[] = DRV_NAME;
@@ -61,8 +62,9 @@ static int msi;
 module_param(msi, int, 0);
 MODULE_PARM_DESC(msi, "Turn on Message Signaled Interrupts.");
 
-static struct pci_device_id ql3xxx_pci_tbl[] __devinitdata = {
+static const struct pci_device_id ql3xxx_pci_tbl[] __devinitdata = {
 	{PCI_DEVICE(PCI_VENDOR_ID_QLOGIC, QL3022_DEVICE_ID)},
+	{PCI_DEVICE(PCI_VENDOR_ID_QLOGIC, QL3032_DEVICE_ID)},
 	/* required last entry */
 	{0,}
 };
@@ -72,10 +74,10 @@ MODULE_DEVICE_TABLE(pci, ql3xxx_pci_tbl)
 /*
  * Caller must take hw_lock.
  */
-static int ql_sem_spinlock(struct ql3_adapter *qdev,
-			    u32 sem_mask, u32 sem_bits)
+static int ql_sem_spinlock(struct ql3_adapter *qdev, u32 sem_mask, u32
sem_bits)
 {
-	struct ql3xxx_port_registers __iomem *port_regs =
qdev->mem_map_registers;
+	struct ql3xxx_port_registers __iomem *port_regs =
+	    qdev->mem_map_registers;
 	u32 value;
 	unsigned int seconds = 3;
 
@@ -86,20 +88,22 @@ static int ql_sem_spinlock(struct ql3_ad
 		if ((value & (sem_mask >> 16)) == sem_bits)
 			return 0;
 		ssleep(1);
-	} while(--seconds);
+	} while (--seconds);
 	return -1;
 }
 
 static void ql_sem_unlock(struct ql3_adapter *qdev, u32 sem_mask)
 {
-	struct ql3xxx_port_registers __iomem *port_regs =
qdev->mem_map_registers;
+	struct ql3xxx_port_registers __iomem *port_regs =
+	    qdev->mem_map_registers;
 	writel(sem_mask, &port_regs->CommonRegs.semaphoreReg);
 	readl(&port_regs->CommonRegs.semaphoreReg);
 }
 
 static int ql_sem_lock(struct ql3_adapter *qdev, u32 sem_mask, u32
sem_bits)
 {
-	struct ql3xxx_port_registers __iomem *port_regs =
qdev->mem_map_registers;
+	struct ql3xxx_port_registers __iomem *port_regs =
+	    qdev->mem_map_registers;
 	u32 value;
 
 	writel((sem_mask | sem_bits), &port_regs->CommonRegs.semaphoreReg);
@@ -124,14 +128,12 @@ static int ql_wait_for_drvr_lock(struct 
 				i++;
 			} else {
 				printk(KERN_ERR PFX "%s: Timed out waiting for "
-				       "driver lock...\n",
-				       qdev->ndev->name);
+				       "driver lock...\n", qdev->ndev->name);
 				return 0;
 			}
 		} else {
 			printk(KERN_DEBUG PFX
-			       "%s: driver lock acquired.\n",
-			       qdev->ndev->name);
+			       "%s: driver lock acquired.\n", qdev->ndev->name);
 			return 1;
 		}
 	}
@@ -139,16 +141,16 @@ static int ql_wait_for_drvr_lock(struct 
 
 static void ql_set_register_page(struct ql3_adapter *qdev, u32 page)
 {
-	struct ql3xxx_port_registers __iomem *port_regs =
qdev->mem_map_registers;
+	struct ql3xxx_port_registers __iomem *port_regs =
+	    qdev->mem_map_registers;
 
 	writel(((ISP_CONTROL_NP_MASK << 16) | page),
-			&port_regs->CommonRegs.ispControlStatus);
+	       &port_regs->CommonRegs.ispControlStatus);
 	readl(&port_regs->CommonRegs.ispControlStatus);
 	qdev->current_page = page;
 }
 
-static u32 ql_read_common_reg_l(struct ql3_adapter *qdev,
-			      u32 __iomem * reg)
+static u32 ql_read_common_reg_l(struct ql3_adapter *qdev, u32 __iomem *
reg)
 {
 	u32 value;
 	unsigned long hw_flags;
@@ -160,13 +162,12 @@ static u32 ql_read_common_reg_l(struct q
 	return value;
 }
 
-static u32 ql_read_common_reg(struct ql3_adapter *qdev,
-			      u32 __iomem * reg)
+static u32 ql_read_common_reg(struct ql3_adapter *qdev, u32 __iomem *
reg)
 {
 	return readl(reg);
 }
 
-static u32 ql_read_page0_reg_l(struct ql3_adapter *qdev, u32 __iomem
*reg)
+static u32 ql_read_page0_reg_l(struct ql3_adapter *qdev, u32 __iomem *
reg)
 {
 	u32 value;
 	unsigned long hw_flags;
@@ -174,22 +175,22 @@ static u32 ql_read_page0_reg_l(struct ql
 	spin_lock_irqsave(&qdev->hw_lock, hw_flags);
 
 	if (qdev->current_page != 0)
-		ql_set_register_page(qdev,0);
+		ql_set_register_page(qdev, 0);
 	value = readl(reg);
 
 	spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
 	return value;
 }
 
-static u32 ql_read_page0_reg(struct ql3_adapter *qdev, u32 __iomem
*reg)
+static u32 ql_read_page0_reg(struct ql3_adapter *qdev, u32 __iomem *
reg)
 {
 	if (qdev->current_page != 0)
-		ql_set_register_page(qdev,0);
+		ql_set_register_page(qdev, 0);
 	return readl(reg);
 }
 
 static void ql_write_common_reg_l(struct ql3_adapter *qdev,
-				u32 __iomem *reg, u32 value)
+				  u32 __iomem * reg, u32 value)
 {
 	unsigned long hw_flags;
 
@@ -201,7 +202,7 @@ static void ql_write_common_reg_l(struct
 }
 
 static void ql_write_common_reg(struct ql3_adapter *qdev,
-				u32 __iomem *reg, u32 value)
+				u32 __iomem * reg, u32 value)
 {
 	writel(value, reg);
 	readl(reg);
@@ -209,10 +210,10 @@ static void ql_write_common_reg(struct q
 }
 
 static void ql_write_page0_reg(struct ql3_adapter *qdev,
-			       u32 __iomem *reg, u32 value)
+			       u32 __iomem * reg, u32 value)
 {
 	if (qdev->current_page != 0)
-		ql_set_register_page(qdev,0);
+		ql_set_register_page(qdev, 0);
 	writel(value, reg);
 	readl(reg);
 	return;
@@ -222,10 +223,10 @@ static void ql_write_page0_reg(struct ql
  * Caller holds hw_lock. Only called during init.
  */
 static void ql_write_page1_reg(struct ql3_adapter *qdev,
-			       u32 __iomem *reg, u32 value)
+			       u32 __iomem * reg, u32 value)
 {
 	if (qdev->current_page != 1)
-		ql_set_register_page(qdev,1);
+		ql_set_register_page(qdev, 1);
 	writel(value, reg);
 	readl(reg);
 	return;
@@ -235,10 +236,10 @@ static void ql_write_page1_reg(struct ql
  * Caller holds hw_lock. Only called during init.
  */
 static void ql_write_page2_reg(struct ql3_adapter *qdev,
-			       u32 __iomem *reg, u32 value)
+			       u32 __iomem * reg, u32 value)
 {
 	if (qdev->current_page != 2)
-		ql_set_register_page(qdev,2);
+		ql_set_register_page(qdev, 2);
 	writel(value, reg);
 	readl(reg);
 	return;
@@ -246,19 +247,21 @@ static void ql_write_page2_reg(struct ql
 
 static void ql_disable_interrupts(struct ql3_adapter *qdev)
 {
-	struct ql3xxx_port_registers __iomem *port_regs =
qdev->mem_map_registers;
+	struct ql3xxx_port_registers __iomem *port_regs =
+	    qdev->mem_map_registers;
 
 	ql_write_common_reg_l(qdev,
&port_regs->CommonRegs.ispInterruptMaskReg,
-			    (ISP_IMR_ENABLE_INT << 16));
+			      (ISP_IMR_ENABLE_INT << 16));
 
 }
 
 static void ql_enable_interrupts(struct ql3_adapter *qdev)
 {
-	struct ql3xxx_port_registers __iomem *port_regs =
qdev->mem_map_registers;
+	struct ql3xxx_port_registers __iomem *port_regs =
+	    qdev->mem_map_registers;
 
 	ql_write_common_reg_l(qdev,
&port_regs->CommonRegs.ispInterruptMaskReg,
-			    ((0xff << 16) | ISP_IMR_ENABLE_INT));
+			      ((0xff << 16) | ISP_IMR_ENABLE_INT));
 
 }
 
@@ -333,7 +336,7 @@ static void eeprom_readword(struct ql3_a
 static void fm93c56a_select(struct ql3_adapter *qdev)
 {
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+	    qdev->mem_map_registers;
 
 	qdev->eeprom_cmd_data = AUBURN_EEPROM_CS_1;
 	ql_write_common_reg(qdev,
&port_regs->CommonRegs.serialPortInterfaceReg,
@@ -352,7 +355,7 @@ static void fm93c56a_cmd(struct ql3_adap
 	u32 dataBit;
 	u32 previousBit;
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+	    qdev->mem_map_registers;
 
 	/* Clock in a zero, then do the start bit */
 	ql_write_common_reg(qdev,
&port_regs->CommonRegs.serialPortInterfaceReg,
@@ -441,7 +444,7 @@ static void fm93c56a_cmd(struct ql3_adap
 static void fm93c56a_deselect(struct ql3_adapter *qdev)
 {
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+	    qdev->mem_map_registers;
 	qdev->eeprom_cmd_data = AUBURN_EEPROM_CS_0;
 	ql_write_common_reg(qdev,
&port_regs->CommonRegs.serialPortInterfaceReg,
 			    ISP_NVRAM_MASK | qdev->eeprom_cmd_data);
@@ -456,7 +459,7 @@ static void fm93c56a_datain(struct ql3_a
 	u32 data = 0;
 	u32 dataBit;
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+	    qdev->mem_map_registers;
 
 	/* Read the data bits */
 	/* The first bit is a dummy.  Clock right over it. */
@@ -520,11 +523,11 @@ static int ql_get_nvram_params(struct ql
 
 	pEEPROMData = (u16 *) & qdev->nvram_data;
 	qdev->eeprom_cmd_data = 0;
-	if(ql_sem_spinlock(qdev, QL_NVRAM_SEM_MASK,
-			(QL_RESOURCE_BITS_BASE_CODE | (qdev->mac_index) *
-			 2) << 10)) {
-		printk(KERN_ERR PFX"%s: Failed ql_sem_spinlock().\n",
-			__func__);
+	if (ql_sem_spinlock(qdev, QL_NVRAM_SEM_MASK,
+			    (QL_RESOURCE_BITS_BASE_CODE | (qdev->mac_index) *
+			     2) << 10)) {
+		printk(KERN_ERR PFX "%s: Failed ql_sem_spinlock().\n",
+		       __func__);
 		spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
 		return -1;
 	}
@@ -566,7 +569,7 @@ static const u32 PHYAddr[2] = {
 static int ql_wait_for_mii_ready(struct ql3_adapter *qdev)
 {
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+	    qdev->mem_map_registers;
 	u32 temp;
 	int count = 1000;
 
@@ -583,7 +586,7 @@ static int ql_wait_for_mii_ready(struct 
 static void ql_mii_enable_scan_mode(struct ql3_adapter *qdev)
 {
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+	    qdev->mem_map_registers;
 	u32 scanControl;
 
 	if (qdev->numPorts > 1) {
@@ -611,7 +614,7 @@ static u8 ql_mii_disable_scan_mode(struc
 {
 	u8 ret;
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    				qdev->mem_map_registers;
+	    qdev->mem_map_registers;
 
 	/* See if scan mode is enabled before we turn it off */
 	if (ql_read_page0_reg(qdev, &port_regs->macMIIMgmtControlReg) &
@@ -641,7 +644,7 @@ static int ql_mii_write_reg_ex(struct ql
 			       u16 regAddr, u16 value, u32 mac_index)
 {
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+	    qdev->mem_map_registers;
 	u8 scanWasEnabled;
 
 	scanWasEnabled = ql_mii_disable_scan_mode(qdev);
@@ -680,7 +683,7 @@ static int ql_mii_read_reg_ex(struct ql3
 			      u16 * value, u32 mac_index)
 {
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+	    qdev->mem_map_registers;
 	u8 scanWasEnabled;
 	u32 temp;
 
@@ -726,7 +729,7 @@ static int ql_mii_read_reg_ex(struct ql3
 static int ql_mii_write_reg(struct ql3_adapter *qdev, u16 regAddr, u16
value)
 {
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+	    qdev->mem_map_registers;
 
 	ql_mii_disable_scan_mode(qdev);
 
@@ -759,11 +762,11 @@ static int ql_mii_write_reg(struct ql3_a
 	return 0;
 }
 
-static int ql_mii_read_reg(struct ql3_adapter *qdev, u16 regAddr, u16
*value)
+static int ql_mii_read_reg(struct ql3_adapter *qdev, u16 regAddr, u16 *
value)
 {
 	u32 temp;
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+	    qdev->mem_map_registers;
 
 	ql_mii_disable_scan_mode(qdev);
 
@@ -917,7 +920,7 @@ static int ql_is_phy_neg_pause(struct ql
 static void ql_mac_enable(struct ql3_adapter *qdev, u32 enable)
 {
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+	    qdev->mem_map_registers;
 	u32 value;
 
 	if (enable)
@@ -937,7 +940,7 @@ static void ql_mac_enable(struct ql3_ada
 static void ql_mac_cfg_soft_reset(struct ql3_adapter *qdev, u32 enable)
 {
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+	    qdev->mem_map_registers;
 	u32 value;
 
 	if (enable)
@@ -957,7 +960,7 @@ static void ql_mac_cfg_soft_reset(struct
 static void ql_mac_cfg_gig(struct ql3_adapter *qdev, u32 enable)
 {
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+	    qdev->mem_map_registers;
 	u32 value;
 
 	if (enable)
@@ -977,7 +980,7 @@ static void ql_mac_cfg_gig(struct ql3_ad
 static void ql_mac_cfg_full_dup(struct ql3_adapter *qdev, u32 enable)
 {
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+	    qdev->mem_map_registers;
 	u32 value;
 
 	if (enable)
@@ -997,7 +1000,7 @@ static void ql_mac_cfg_full_dup(struct q
 static void ql_mac_cfg_pause(struct ql3_adapter *qdev, u32 enable)
 {
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+	    qdev->mem_map_registers;
 	u32 value;
 
 	if (enable)
@@ -1019,7 +1022,7 @@ static void ql_mac_cfg_pause(struct ql3_
 static int ql_is_fiber(struct ql3_adapter *qdev)
 {
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+	    qdev->mem_map_registers;
 	u32 bitToCheck = 0;
 	u32 temp;
 
@@ -1049,7 +1052,7 @@ static int ql_is_auto_cfg(struct ql3_ada
 static int ql_is_auto_neg_complete(struct ql3_adapter *qdev)
 {
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+	    qdev->mem_map_registers;
 	u32 bitToCheck = 0;
 	u32 temp;
 
@@ -1092,7 +1095,7 @@ static int ql_is_neg_pause(struct ql3_ad
 static int ql_auto_neg_error(struct ql3_adapter *qdev)
 {
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+	    qdev->mem_map_registers;
 	u32 bitToCheck = 0;
 	u32 temp;
 
@@ -1130,7 +1133,7 @@ static int ql_is_link_full_dup(struct ql
 static int ql_link_down_detect(struct ql3_adapter *qdev)
 {
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+	    qdev->mem_map_registers;
 	u32 bitToCheck = 0;
 	u32 temp;
 
@@ -1154,7 +1157,7 @@ static int ql_link_down_detect(struct ql
 static int ql_link_down_detect_clear(struct ql3_adapter *qdev)
 {
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+	    qdev->mem_map_registers;
 
 	switch (qdev->mac_index) {
 	case 0:
@@ -1185,7 +1188,7 @@ static int ql_this_adapter_controls_port
 					 u32 mac_index)
 {
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+	    qdev->mem_map_registers;
 	u32 bitToCheck = 0;
 	u32 temp;
 
@@ -1243,7 +1246,7 @@ static void ql_phy_init_ex(struct ql3_ad
 static u32 ql_get_link_state(struct ql3_adapter *qdev)
 {
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+	    qdev->mem_map_registers;
 	u32 bitToCheck = 0;
 	u32 temp, linkState;
 
@@ -1269,9 +1272,9 @@ static u32 ql_get_link_state(struct ql3_
 
 static int ql_port_start(struct ql3_adapter *qdev)
 {
-	if(ql_sem_spinlock(qdev, QL_PHY_GIO_SEM_MASK,
-		(QL_RESOURCE_BITS_BASE_CODE | (qdev->mac_index) *
-			 2) << 7))
+	if (ql_sem_spinlock(qdev, QL_PHY_GIO_SEM_MASK,
+			    (QL_RESOURCE_BITS_BASE_CODE | (qdev->mac_index) *
+			     2) << 7))
 		return -1;
 
 	if (ql_is_fiber(qdev)) {
@@ -1288,38 +1291,29 @@ static int ql_port_start(struct ql3_adap
 static int ql_finish_auto_neg(struct ql3_adapter *qdev)
 {
 
-	if(ql_sem_spinlock(qdev, QL_PHY_GIO_SEM_MASK,
-		(QL_RESOURCE_BITS_BASE_CODE | (qdev->mac_index) *
-			 2) << 7))
+	if (ql_sem_spinlock(qdev, QL_PHY_GIO_SEM_MASK,
+			    (QL_RESOURCE_BITS_BASE_CODE | (qdev->mac_index) *
+			     2) << 7))
 		return -1;
 
 	if (!ql_auto_neg_error(qdev)) {
-		if (test_bit(QL_LINK_MASTER,&qdev->flags)) {
+		if (test_bit(QL_LINK_MASTER, &qdev->flags)) {
 			/* configure the MAC */
 			if (netif_msg_link(qdev))
 				printk(KERN_DEBUG PFX
 				       "%s: Configuring link.\n",
-				       qdev->ndev->
-				       name);
+				       qdev->ndev->name);
 			ql_mac_cfg_soft_reset(qdev, 1);
 			ql_mac_cfg_gig(qdev,
-				       (ql_get_link_speed
-					(qdev) ==
-					SPEED_1000));
-			ql_mac_cfg_full_dup(qdev,
-					    ql_is_link_full_dup
-					    (qdev));
-			ql_mac_cfg_pause(qdev,
-					 ql_is_neg_pause
-					 (qdev));
+				       (ql_get_link_speed(qdev) == SPEED_1000));
+			ql_mac_cfg_full_dup(qdev, ql_is_link_full_dup(qdev));
+			ql_mac_cfg_pause(qdev, ql_is_neg_pause(qdev));
 			ql_mac_cfg_soft_reset(qdev, 0);
 
 			/* enable the MAC */
 			if (netif_msg_link(qdev))
 				printk(KERN_DEBUG PFX
-				       "%s: Enabling mac.\n",
-				       qdev->ndev->
-					       name);
+				       "%s: Enabling mac.\n", qdev->ndev->name);
 			ql_mac_enable(qdev, 1);
 		}
 
@@ -1338,21 +1332,20 @@ static int ql_finish_auto_neg(struct ql3
 			       ql_is_link_full_dup(qdev)
 			       ? "full" : "half");
 
-	} else {	/* Remote error detected */
+	} else {		/* Remote error detected */
 
-		if (test_bit(QL_LINK_MASTER,&qdev->flags)) {
+		if (test_bit(QL_LINK_MASTER, &qdev->flags)) {
 			if (netif_msg_link(qdev))
 				printk(KERN_DEBUG PFX
 				       "%s: Remote error detected. "
 				       "Calling ql_port_start().\n",
-				       qdev->ndev->
-				       name);
+				       qdev->ndev->name);
 			/*
 			 * ql_port_start() is shared code and needs
 			 * to lock the PHY on it's own.
 			 */
 			ql_sem_unlock(qdev, QL_PHY_GIO_SEM_MASK);
-			if(ql_port_start(qdev))	{/* Restart port */
+			if (ql_port_start(qdev)) {	/* Restart port */
 				return -1;
 			} else
 				return 0;
@@ -1371,7 +1364,7 @@ static void ql_link_state_machine(struct
 
 	curr_link_state = ql_get_link_state(qdev);
 
-	if (test_bit(QL_RESET_ACTIVE,&qdev->flags)) {
+	if (test_bit(QL_RESET_ACTIVE, &qdev->flags)) {
 		if (netif_msg_link(qdev))
 			printk(KERN_INFO PFX
 			       "%s: Reset in progress, skip processing link "
@@ -1381,7 +1374,7 @@ static void ql_link_state_machine(struct
 
 	switch (qdev->port_link_state) {
 	default:
-		if (test_bit(QL_LINK_MASTER,&qdev->flags)) {
+		if (test_bit(QL_LINK_MASTER, &qdev->flags)) {
 			ql_port_start(qdev);
 		}
 		qdev->port_link_state = LS_DOWN;
@@ -1428,9 +1421,9 @@ static void ql_link_state_machine(struct
 static void ql_get_phy_owner(struct ql3_adapter *qdev)
 {
 	if (ql_this_adapter_controls_port(qdev, qdev->mac_index))
-		set_bit(QL_LINK_MASTER,&qdev->flags);
+		set_bit(QL_LINK_MASTER, &qdev->flags);
 	else
-		clear_bit(QL_LINK_MASTER,&qdev->flags);
+		clear_bit(QL_LINK_MASTER, &qdev->flags);
 }
 
 /*
@@ -1440,7 +1433,7 @@ static void ql_init_scan_mode(struct ql3
 {
 	ql_mii_enable_scan_mode(qdev);
 
-	if (test_bit(QL_LINK_OPTICAL,&qdev->flags)) {
+	if (test_bit(QL_LINK_OPTICAL, &qdev->flags)) {
 		if (ql_this_adapter_controls_port(qdev, qdev->mac_index))
 			ql_petbi_init_ex(qdev, qdev->mac_index);
 	} else {
@@ -1459,13 +1452,16 @@ static int ql_mii_setup(struct ql3_adapt
 {
 	u32 reg;
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+	    qdev->mem_map_registers;
 
-	if(ql_sem_spinlock(qdev, QL_PHY_GIO_SEM_MASK,
-			(QL_RESOURCE_BITS_BASE_CODE | (qdev->mac_index) *
-			 2) << 7))
+	if (ql_sem_spinlock(qdev, QL_PHY_GIO_SEM_MASK,
+			    (QL_RESOURCE_BITS_BASE_CODE | (qdev->mac_index) *
+			     2) << 7))
 		return -1;
 
+	if (qdev->device_id == QL3032_DEVICE_ID)
+		ql_write_page0_reg(qdev, &port_regs->macMIIMgmtControlReg,
0x0f00000);	/* clear bits 4-7 */
+
 	/* Divide 125MHz clock by 28 to meet PHY timing requirements */
 	reg = MAC_MII_CONTROL_CLK_SEL_DIV28;
 
@@ -1480,7 +1476,7 @@ static u32 ql_supported_modes(struct ql3
 {
 	u32 supported;
 
-	if (test_bit(QL_LINK_OPTICAL,&qdev->flags)) {
+	if (test_bit(QL_LINK_OPTICAL, &qdev->flags)) {
 		supported = SUPPORTED_1000baseT_Full | SUPPORTED_FIBRE
 		    | SUPPORTED_Autoneg;
 	} else {
@@ -1501,9 +1497,9 @@ static int ql_get_auto_cfg_status(struct
 	int status;
 	unsigned long hw_flags;
 	spin_lock_irqsave(&qdev->hw_lock, hw_flags);
-	if(ql_sem_spinlock(qdev, QL_PHY_GIO_SEM_MASK,
-		(QL_RESOURCE_BITS_BASE_CODE | (qdev->mac_index) *
-			 2) << 7))
+	if (ql_sem_spinlock(qdev, QL_PHY_GIO_SEM_MASK,
+			    (QL_RESOURCE_BITS_BASE_CODE | (qdev->mac_index) *
+			     2) << 7))
 		return 0;
 	status = ql_is_auto_cfg(qdev);
 	ql_sem_unlock(qdev, QL_PHY_GIO_SEM_MASK);
@@ -1516,9 +1512,9 @@ static u32 ql_get_speed(struct ql3_adapt
 	u32 status;
 	unsigned long hw_flags;
 	spin_lock_irqsave(&qdev->hw_lock, hw_flags);
-	if(ql_sem_spinlock(qdev, QL_PHY_GIO_SEM_MASK,
-		(QL_RESOURCE_BITS_BASE_CODE | (qdev->mac_index) *
-			 2) << 7))
+	if (ql_sem_spinlock(qdev, QL_PHY_GIO_SEM_MASK,
+			    (QL_RESOURCE_BITS_BASE_CODE | (qdev->mac_index) *
+			     2) << 7))
 		return 0;
 	status = ql_get_link_speed(qdev);
 	ql_sem_unlock(qdev, QL_PHY_GIO_SEM_MASK);
@@ -1531,9 +1527,9 @@ static int ql_get_full_dup(struct ql3_ad
 	int status;
 	unsigned long hw_flags;
 	spin_lock_irqsave(&qdev->hw_lock, hw_flags);
-	if(ql_sem_spinlock(qdev, QL_PHY_GIO_SEM_MASK,
-		(QL_RESOURCE_BITS_BASE_CODE | (qdev->mac_index) *
-			 2) << 7))
+	if (ql_sem_spinlock(qdev, QL_PHY_GIO_SEM_MASK,
+			    (QL_RESOURCE_BITS_BASE_CODE | (qdev->mac_index) *
+			     2) << 7))
 		return 0;
 	status = ql_is_link_full_dup(qdev);
 	ql_sem_unlock(qdev, QL_PHY_GIO_SEM_MASK);
@@ -1541,7 +1537,6 @@ static int ql_get_full_dup(struct ql3_ad
 	return status;
 }
 
-
 static int ql_get_settings(struct net_device *ndev, struct ethtool_cmd
*ecmd)
 {
 	struct ql3_adapter *qdev = netdev_priv(ndev);
@@ -1549,7 +1544,7 @@ static int ql_get_settings(struct net_de
 	ecmd->transceiver = XCVR_INTERNAL;
 	ecmd->supported = ql_supported_modes(qdev);
 
-	if (test_bit(QL_LINK_OPTICAL,&qdev->flags)) {
+	if (test_bit(QL_LINK_OPTICAL, &qdev->flags)) {
 		ecmd->port = PORT_FIBRE;
 	} else {
 		ecmd->port = PORT_TP;
@@ -1647,7 +1642,8 @@ static void ql_update_lrg_bufq_prod_inde
 	struct bufq_addr_element *lrg_buf_q_ele;
 	int i;
 	struct ql_rcv_buf_cb *lrg_buf_cb;
-	struct ql3xxx_port_registers __iomem *port_regs =
qdev->mem_map_registers;
+	struct ql3xxx_port_registers __iomem *port_regs =
+	    qdev->mem_map_registers;
 
 	if ((qdev->lrg_buf_free_count >= 8)
 	    && (qdev->lrg_buf_release_cnt >= 16)) {
@@ -1697,51 +1693,68 @@ static void ql_process_mac_tx_intr(struc
 				   struct ob_mac_iocb_rsp *mac_rsp)
 {
 	struct ql_tx_buf_cb *tx_cb;
+	int i;
 
 	tx_cb = &qdev->tx_buf[mac_rsp->transaction_id];
+
 	pci_unmap_single(qdev->pdev,
-			 pci_unmap_addr(tx_cb, mapaddr),
-			 pci_unmap_len(tx_cb, maplen), PCI_DMA_TODEVICE);
-	dev_kfree_skb_irq(tx_cb->skb);
+			 pci_unmap_addr(&tx_cb->map[0], mapaddr),
+			 pci_unmap_len(&tx_cb->map[0], maplen),
+			 PCI_DMA_TODEVICE);
+	tx_cb->seg_count--;
+	if (tx_cb->seg_count) {
+		for (i = 1; i < tx_cb->seg_count; i++) {
+			pci_unmap_page(qdev->pdev,
+				       pci_unmap_addr(&tx_cb->map[i],
+						      mapaddr),
+				       pci_unmap_len(&tx_cb->map[i], maplen),
+				       PCI_DMA_TODEVICE);
+		}
+	}
 	qdev->stats.tx_packets++;
 	qdev->stats.tx_bytes += tx_cb->skb->len;
+	dev_kfree_skb_irq(tx_cb->skb);
 	tx_cb->skb = NULL;
 	atomic_inc(&qdev->tx_count);
 }
 
+/*
+ * The difference between 3022 and 3032 for inbound completions:
+ * 3022 uses two buffers per completion.  The first buffer contains 
+ * (some) header info, the second the remainder of the headers plus 
+ * the data.  For this chip we reserve some space at the top of the 
+ * receive buffer so that the header info in buffer one can be 
+ * prepended to the buffer two.  Buffer two is the sent up while 
+ * buffer one is returned to the hardware to be reused.
+ * 3032 receives all of it's data and headers in one buffer for a 
+ * simpler process.  3032 also supports checksum verification as
+ * can be seen in ql_process_macip_rx_intr().
+ */
 static void ql_process_mac_rx_intr(struct ql3_adapter *qdev,
 				   struct ib_mac_iocb_rsp *ib_mac_rsp_ptr)
 {
-	long int offset;
-	u32 lrg_buf_phy_addr_low = 0;
 	struct ql_rcv_buf_cb *lrg_buf_cb1 = NULL;
 	struct ql_rcv_buf_cb *lrg_buf_cb2 = NULL;
-	u32 *curr_ial_ptr;
 	struct sk_buff *skb;
 	u16 length = le16_to_cpu(ib_mac_rsp_ptr->length);
 
 	/*
 	 * Get the inbound address list (small buffer).
 	 */
-	offset = qdev->small_buf_index * QL_SMALL_BUFFER_SIZE;
 	if (++qdev->small_buf_index == NUM_SMALL_BUFFERS)
 		qdev->small_buf_index = 0;
-
-	curr_ial_ptr = (u32 *) (qdev->small_buf_virt_addr + offset);
-	qdev->last_rsp_offset = qdev->small_buf_phy_addr_low + offset;
 	qdev->small_buf_release_cnt++;
 
-	/* start of first buffer */
-	lrg_buf_phy_addr_low = le32_to_cpu(*curr_ial_ptr);
-	lrg_buf_cb1 = &qdev->lrg_buf[qdev->lrg_buf_index];
-	qdev->lrg_buf_release_cnt++;
-	if (++qdev->lrg_buf_index == NUM_LARGE_BUFFERS)
-		qdev->lrg_buf_index = 0;
-	curr_ial_ptr++;		/* 64-bit pointers require two incs. */
-	curr_ial_ptr++;
+	if (qdev->device_id == QL3022_DEVICE_ID) {
+		/* start of first buffer (3022 only) */
+		lrg_buf_cb1 = &qdev->lrg_buf[qdev->lrg_buf_index];
+		qdev->lrg_buf_release_cnt++;
+		if (++qdev->lrg_buf_index == NUM_LARGE_BUFFERS) {
+			qdev->lrg_buf_index = 0;
+		}
+	}
 
 	/* start of second buffer */
-	lrg_buf_phy_addr_low = le32_to_cpu(*curr_ial_ptr);
 	lrg_buf_cb2 = &qdev->lrg_buf[qdev->lrg_buf_index];
 
 	/*
@@ -1769,19 +1782,17 @@ static void ql_process_mac_rx_intr(struc
 	qdev->ndev->last_rx = jiffies;
 	lrg_buf_cb2->skb = NULL;
 
-	ql_release_to_lrg_buf_free_list(qdev, lrg_buf_cb1);
+	if (qdev->device_id == QL3022_DEVICE_ID)
+		ql_release_to_lrg_buf_free_list(qdev, lrg_buf_cb1);
 	ql_release_to_lrg_buf_free_list(qdev, lrg_buf_cb2);
 }
 
 static void ql_process_macip_rx_intr(struct ql3_adapter *qdev,
 				     struct ib_ip_iocb_rsp *ib_ip_rsp_ptr)
 {
-	long int offset;
-	u32 lrg_buf_phy_addr_low = 0;
 	struct ql_rcv_buf_cb *lrg_buf_cb1 = NULL;
 	struct ql_rcv_buf_cb *lrg_buf_cb2 = NULL;
-	u32 *curr_ial_ptr;
-	struct sk_buff *skb1, *skb2;
+	struct sk_buff *skb1 = NULL, *skb2;
 	struct net_device *ndev = qdev->ndev;
 	u16 length = le16_to_cpu(ib_ip_rsp_ptr->length);
 	u16 size = 0;
@@ -1790,44 +1801,29 @@ static void ql_process_macip_rx_intr(str
 	 * Get the inbound address list (small buffer).
 	 */
 
-	offset = qdev->small_buf_index * QL_SMALL_BUFFER_SIZE;
 	if (++qdev->small_buf_index == NUM_SMALL_BUFFERS)
 		qdev->small_buf_index = 0;
-	curr_ial_ptr = (u32 *) (qdev->small_buf_virt_addr + offset);
-	qdev->last_rsp_offset = qdev->small_buf_phy_addr_low + offset;
 	qdev->small_buf_release_cnt++;
 
-	/* start of first buffer */
-	lrg_buf_phy_addr_low = le32_to_cpu(*curr_ial_ptr);
-	lrg_buf_cb1 = &qdev->lrg_buf[qdev->lrg_buf_index];
-
-	qdev->lrg_buf_release_cnt++;
-	if (++qdev->lrg_buf_index == NUM_LARGE_BUFFERS)
-		qdev->lrg_buf_index = 0;
-	skb1 = lrg_buf_cb1->skb;
-	curr_ial_ptr++;		/* 64-bit pointers require two incs. */
-	curr_ial_ptr++;
+	if (qdev->device_id == QL3022_DEVICE_ID) {
+		/* start of first buffer on 3022 */
+		lrg_buf_cb1 = &qdev->lrg_buf[qdev->lrg_buf_index];
+		qdev->lrg_buf_release_cnt++;
+		if (++qdev->lrg_buf_index == NUM_LARGE_BUFFERS)
+			qdev->lrg_buf_index = 0;
+		skb1 = lrg_buf_cb1->skb;
+		size = ETH_HLEN;
+		if (*((u16 *) skb1->data) != 0xFFFF)
+			size += VLAN_ETH_HLEN - ETH_HLEN;
+	}
 
 	/* start of second buffer */
-	lrg_buf_phy_addr_low = le32_to_cpu(*curr_ial_ptr);
 	lrg_buf_cb2 = &qdev->lrg_buf[qdev->lrg_buf_index];
 	skb2 = lrg_buf_cb2->skb;
 	qdev->lrg_buf_release_cnt++;
 	if (++qdev->lrg_buf_index == NUM_LARGE_BUFFERS)
 		qdev->lrg_buf_index = 0;
 
-	qdev->stats.rx_packets++;
-	qdev->stats.rx_bytes += length;
-
-	/*
-	 * Copy the ethhdr from first buffer to second. This
-	 * is necessary for IP completions.
-	 */
-	if (*((u16 *) skb1->data) != 0xFFFF)
-		size = VLAN_ETH_HLEN;
-	else
-		size = ETH_HLEN;
-
 	skb_put(skb2, length);	/* Just the second buffer length here. */
 	pci_unmap_single(qdev->pdev,
 			 pci_unmap_addr(lrg_buf_cb2, mapaddr),
@@ -1835,23 +1831,53 @@ static void ql_process_macip_rx_intr(str
 			 PCI_DMA_FROMDEVICE);
 	prefetch(skb2->data);
 
-	memcpy(skb_push(skb2, size), skb1->data + VLAN_ID_LEN, size);
+	if (qdev->device_id == QL3022_DEVICE_ID) {
+		/*
+		 * Copy the ethhdr from first buffer to second. This
+		 * is necessary for 3022 IP completions.
+		 */
+		memcpy(skb_push(skb2, size), skb1->data + VLAN_ID_LEN, size);
+		skb2->ip_summed = CHECKSUM_NONE;
+	} else {
+		skb2->ip_summed = CHECKSUM_COMPLETED;
+		if (ib_ip_rsp_ptr->checksum & IB_IP_IOCB_RSP_3032_ICE) {
+			skb2->ip_summed = CHECKSUM_NONE;
+			printk(KERN_ERR
+			       "%s: Bad checksum for this IP packet.\n",
+			       __func__);
+		} else if ((ib_ip_rsp_ptr->
+			    checksum & (IB_IP_IOCB_RSP_3032_TCP |
+					IB_IP_IOCB_RSP_3032_UDP))
+			   && (ib_ip_rsp_ptr->
+			       checksum & (IB_IP_IOCB_RSP_3032_NUC |
+					   IB_IP_IOCB_RSP_3032_CE))) {
+			skb2->ip_summed = CHECKSUM_NONE;
+			printk(KERN_ERR
+			       "%s: Bad checksum for this %s packet.\n",
+			       __func__,
+			       ((ib_ip_rsp_ptr->
+				 checksum & IB_IP_IOCB_RSP_3032_TCP) ? "TCP" :
+				"UDP"));
+		}
+	}
 	skb2->dev = qdev->ndev;
-	skb2->ip_summed = CHECKSUM_NONE;
 	skb2->protocol = eth_type_trans(skb2, qdev->ndev);
-
 	netif_receive_skb(skb2);
+	qdev->stats.rx_packets++;
+	qdev->stats.rx_bytes += length;
 	ndev->last_rx = jiffies;
 	lrg_buf_cb2->skb = NULL;
 
-	ql_release_to_lrg_buf_free_list(qdev, lrg_buf_cb1);
+	if (qdev->device_id == QL3022_DEVICE_ID)
+		ql_release_to_lrg_buf_free_list(qdev, lrg_buf_cb1);
 	ql_release_to_lrg_buf_free_list(qdev, lrg_buf_cb2);
 }
 
 static int ql_tx_rx_clean(struct ql3_adapter *qdev,
 			  int *tx_cleaned, int *rx_cleaned, int work_to_do)
 {
-	struct ql3xxx_port_registers __iomem *port_regs =
qdev->mem_map_registers;
+	struct ql3xxx_port_registers __iomem *port_regs =
+	    qdev->mem_map_registers;
 	struct net_rsp_iocb *net_rsp;
 	struct net_device *ndev = qdev->ndev;
 	unsigned long hw_flags;
@@ -1871,16 +1897,19 @@ static int ql_tx_rx_clean(struct ql3_ada
 			break;
 
 		case OPCODE_IB_MAC_IOCB:
+		case OPCODE_IB_3032_MAC_IOCB:
 			ql_process_mac_rx_intr(qdev, (struct ib_mac_iocb_rsp *)
 					       net_rsp);
 			(*rx_cleaned)++;
 			break;
 
 		case OPCODE_IB_IP_IOCB:
+		case OPCODE_IB_3032_IP_IOCB:
 			ql_process_macip_rx_intr(qdev, (struct ib_ip_iocb_rsp *)
 						 net_rsp);
 			(*rx_cleaned)++;
 			break;
+
 		default:
 			{
 				u32 *tmp = (u32 *) net_rsp;
@@ -1888,8 +1917,7 @@ static int ql_tx_rx_clean(struct ql3_ada
 				       "%s: Hit default case, not "
 				       "handled!\n"
 				       "	dropping the packet, opcode = "
-				       "%x.\n",
-				       ndev->name, net_rsp->opcode);
+				       "%x.\n", ndev->name, net_rsp->opcode);
 				printk(KERN_ERR PFX
 				       "0x%08lx 0x%08lx 0x%08lx 0x%08lx \n",
 				       (unsigned long int)tmp[0],
@@ -1970,7 +1998,8 @@ static irqreturn_t ql3xxx_isr(int irq, v
 
 	struct net_device *ndev = dev_id;
 	struct ql3_adapter *qdev = netdev_priv(ndev);
-	struct ql3xxx_port_registers __iomem *port_regs =
qdev->mem_map_registers;
+	struct ql3xxx_port_registers __iomem *port_regs =
+	    qdev->mem_map_registers;
 	u32 value;
 	int handled = 1;
 	u32 var;
@@ -1986,7 +2015,7 @@ static irqreturn_t ql3xxx_isr(int irq, v
 		netif_carrier_off(qdev->ndev);
 		ql_disable_interrupts(qdev);
 		qdev->port_link_state = LS_DOWN;
-		set_bit(QL_RESET_ACTIVE,&qdev->flags) ;
+		set_bit(QL_RESET_ACTIVE, &qdev->flags);
 
 		if (value & ISP_CONTROL_FE) {
 			/*
@@ -1994,16 +2023,16 @@ static irqreturn_t ql3xxx_isr(int irq, v
 			 */
 			var =
 			    ql_read_page0_reg_l(qdev,
-					      &port_regs->PortFatalErrStatus);
+						&port_regs->PortFatalErrStatus);
 			printk(KERN_WARNING PFX
 			       "%s: Resetting chip. PortFatalErrStatus "
 			       "register = 0x%x\n", ndev->name, var);
-			set_bit(QL_RESET_START,&qdev->flags) ;
+			set_bit(QL_RESET_START, &qdev->flags);
 		} else {
 			/*
 			 * Soft Reset Requested.
 			 */
-			set_bit(QL_RESET_PER_SCSI,&qdev->flags) ;
+			set_bit(QL_RESET_PER_SCSI, &qdev->flags);
 			printk(KERN_ERR PFX
 			       "%s: Another function issued a reset to the "
 			       "chip. ISR value = %x.\n", ndev->name, value);
@@ -2023,50 +2052,213 @@ static irqreturn_t ql3xxx_isr(int irq, v
 	return IRQ_RETVAL(handled);
 }
 
+/*
+ * Get the total number of segments needed for the 
+ * given number of fragments.  This is necessary because
+ * outbound address lists (OAL) will be used when more than
+ * two frags are given.  Each address list has 5 addr/len 
+ * pairs.  The 5th pair in each AOL is used to  point to
+ * the next AOL if more frags are coming.  
+ * That is why the frags:segment count  ratio is not linear.
+ */
+static int ql_get_seg_count(unsigned short frags)
+{
+	switch (frags) {
+	case 0:
+		return 1;	/* just the skb->data seg */
+	case 1:
+		return 2;	/* skb->data + 1 frag */
+	case 2:
+		return 3;	/* skb->data + 2 frags */
+	case 3:
+		return 5;	/* skb->data + 1 frag + 1 AOL containting 2 frags */
+	case 4:
+		return 6;
+	case 5:
+		return 7;
+	case 6:
+		return 8;
+	case 7:
+		return 10;
+	case 8:
+		return 11;
+	case 9:
+		return 12;
+	case 10:
+		return 13;
+	case 11:
+		return 15;
+	case 12:
+		return 16;
+	case 13:
+		return 17;
+	case 14:
+		return 18;
+	case 15:
+		return 20;
+	case 16:
+		return 21;
+	case 17:
+		return 22;
+	case 18:
+		return 23;
+	}
+	return -1;
+}
+
+static void ql_hw_csum_setup(struct sk_buff *skb,
+			     struct ob_mac_iocb_req *mac_iocb_ptr)
+{
+	struct ethhdr *eth;
+	struct iphdr *ip = NULL;
+	u8 offset = ETH_HLEN;
+
+	eth = (struct ethhdr *)(skb->data);
+
+	if (eth->h_proto == __constant_htons(ETH_P_IP)) {
+		ip = (struct iphdr *)&skb->data[ETH_HLEN];
+	} else if (eth->h_proto == htons(ETH_P_8021Q) &&
+		   ((struct vlan_ethhdr *)skb->data)->
+		   h_vlan_encapsulated_proto == __constant_htons(ETH_P_IP)) {
+		ip = (struct iphdr *)&skb->data[VLAN_ETH_HLEN];
+		offset = VLAN_ETH_HLEN;
+	}
+
+	if (ip) {
+		if (ip->protocol == IPPROTO_TCP) {
+			mac_iocb_ptr->flags1 |= OB_3032MAC_IOCB_REQ_TC;
+			mac_iocb_ptr->ip_hdr_off = offset;
+			mac_iocb_ptr->ip_hdr_len = ip->ihl;
+		} else if (ip->protocol == IPPROTO_UDP) {
+			mac_iocb_ptr->flags1 |= OB_3032MAC_IOCB_REQ_UC;
+			mac_iocb_ptr->ip_hdr_off = offset;
+			mac_iocb_ptr->ip_hdr_len = ip->ihl;
+		}
+	}
+}
+
+/*
+ * The difference between 3022 and 3032 sends:
+ * 3022 only supports a simple single segment transmission.
+ * 3032 supports checksumming and scatter/gather lists (fragments).
+ * The 3032 supports sglists by using the 3 addr/len pairs (ALP) 
+ * in the IOCB plus a chain of outbound address lists (OAL) that 
+ * each contain 5 ALPs.  The last ALP of the IOCB (3rd) or OAL (5th) 
+ * will used to point to an OAL when more ALP entries are required.  
+ * The IOCB is always the top of the chain followed by one or more 
+ * OALs (when necessary).
+ */
 static int ql3xxx_send(struct sk_buff *skb, struct net_device *ndev)
 {
 	struct ql3_adapter *qdev = (struct ql3_adapter *)netdev_priv(ndev);
-	struct ql3xxx_port_registers __iomem *port_regs =
qdev->mem_map_registers;
+	struct ql3xxx_port_registers __iomem *port_regs =
+	    qdev->mem_map_registers;
 	struct ql_tx_buf_cb *tx_cb;
+	u32 tot_len = skb->len;
+	struct oal *oal;
+	struct oal_entry *oal_entry;
+	int len;
 	struct ob_mac_iocb_req *mac_iocb_ptr;
 	u64 map;
+	int seg_cnt, seg = 0;
+	int frag_cnt = (int)skb_shinfo(skb)->nr_frags;
 
 	if (unlikely(atomic_read(&qdev->tx_count) < 2)) {
 		if (!netif_queue_stopped(ndev))
 			netif_stop_queue(ndev);
 		return NETDEV_TX_BUSY;
 	}
-	tx_cb = &qdev->tx_buf[qdev->req_producer_index] ;
+	tx_cb = &qdev->tx_buf[qdev->req_producer_index];
+	seg_cnt = tx_cb->seg_count =
+	    ql_get_seg_count((skb_shinfo(skb)->nr_frags));
+	if (seg_cnt == -1) {
+		printk(KERN_ERR PFX "%s: invalid segment count!\n", __func__);
+		return NETDEV_TX_OK;
+
+	}
 	mac_iocb_ptr = tx_cb->queue_entry;
 	memset((void *)mac_iocb_ptr, 0, sizeof(struct ob_mac_iocb_req));
 	mac_iocb_ptr->opcode = qdev->mac_ob_opcode;
 	mac_iocb_ptr->flags |= qdev->mb_bit_mask;
 	mac_iocb_ptr->transaction_id = qdev->req_producer_index;
-	mac_iocb_ptr->data_len = cpu_to_le16((u16) skb->len);
+	mac_iocb_ptr->data_len = cpu_to_le16((u16) tot_len);
 	tx_cb->skb = skb;
-	map = pci_map_single(qdev->pdev, skb->data, skb->len,
PCI_DMA_TODEVICE);
-	mac_iocb_ptr->buf_addr0_low = cpu_to_le32(LS_64BITS(map));
-	mac_iocb_ptr->buf_addr0_high = cpu_to_le32(MS_64BITS(map));
-	mac_iocb_ptr->buf_0_len = cpu_to_le32(skb->len | OB_MAC_IOCB_REQ_E);
-	pci_unmap_addr_set(tx_cb, mapaddr, map);
-	pci_unmap_len_set(tx_cb, maplen, skb->len);
-	atomic_dec(&qdev->tx_count);
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
+		ql_hw_csum_setup(skb, mac_iocb_ptr);
+	len = skb_headlen(skb);
+	map = pci_map_single(qdev->pdev, skb->data, len, PCI_DMA_TODEVICE);
+	oal_entry = (struct oal_entry *)&mac_iocb_ptr->buf_addr0_low;
+	oal_entry->dma_lo = cpu_to_le32(LS_64BITS(map));
+	oal_entry->dma_hi = cpu_to_le32(MS_64BITS(map));
+	oal_entry->len = cpu_to_le32(len);
+	pci_unmap_addr_set(&tx_cb->map[seg], mapaddr, map);
+	pci_unmap_len_set(&tx_cb->map[seg], maplen, len);
+	seg++;
+
+	if (!skb_shinfo(skb)->nr_frags) {
+		/* Terminate the last segment. */
+		oal_entry->len =
+		    cpu_to_le32(le32_to_cpu(oal_entry->len) | OAL_LAST_ENTRY);
+	} else {
+		int i;
+		oal = tx_cb->oal;
+		for (i = 0; i < frag_cnt; i++, seg++) {
+			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+			oal_entry++;
+			if ((seg == 2 && seg_cnt > 3) ||	/* Check for continuation */
+			    (seg == 7 && seg_cnt > 8) ||	/* requirements. It's strange */
+			    (seg == 12 && seg_cnt > 13) ||	/* but necessary. */
+			    (seg == 17 && seg_cnt > 18)) {
+				/* Continuation entry points to outbound address list. */
+				map = pci_map_single(qdev->pdev, oal,
+						     sizeof(struct oal),
+						     PCI_DMA_TODEVICE);
+				oal_entry->dma_lo = cpu_to_le32(LS_64BITS(map));
+				oal_entry->dma_hi = cpu_to_le32(MS_64BITS(map));
+				oal_entry->len =
+				    cpu_to_le32(sizeof(struct oal) |
+						OAL_CONT_ENTRY);
+				pci_unmap_addr_set(&tx_cb->map[seg], mapaddr,
+						   map);
+				pci_unmap_len_set(&tx_cb->map[seg], maplen,
+						  len);
+				oal_entry = (struct oal_entry *)oal;
+				oal++;
+				seg++;
+			}
 
+			map =
+			    pci_map_page(qdev->pdev, frag->page,
+					 frag->page_offset, frag->size,
+					 PCI_DMA_TODEVICE);
+			oal_entry->dma_lo = cpu_to_le32(LS_64BITS(map));
+			oal_entry->dma_hi = cpu_to_le32(MS_64BITS(map));
+			oal_entry->len = cpu_to_le32(frag->size);
+			pci_unmap_addr_set(&tx_cb->map[seg], mapaddr, map);
+			pci_unmap_len_set(&tx_cb->map[seg], maplen, frag->size);
+		}
+		/* Terminate the last segment. */
+		oal_entry->len =
+		    cpu_to_le32(le32_to_cpu(oal_entry->len) | OAL_LAST_ENTRY);
+	}
+	wmb();
 	qdev->req_producer_index++;
 	if (qdev->req_producer_index == NUM_REQ_Q_ENTRIES)
 		qdev->req_producer_index = 0;
 	wmb();
 	ql_write_common_reg_l(qdev,
-			    &port_regs->CommonRegs.reqQProducerIndex,
-			    qdev->req_producer_index);
+			      &port_regs->CommonRegs.reqQProducerIndex,
+			      qdev->req_producer_index);
 
 	ndev->trans_start = jiffies;
 	if (netif_msg_tx_queued(qdev))
 		printk(KERN_DEBUG PFX "%s: tx queued, slot %d, len %d\n",
 		       ndev->name, qdev->req_producer_index, skb->len);
 
+	atomic_dec(&qdev->tx_count);
 	return NETDEV_TX_OK;
 }
+
 static int ql_alloc_net_req_rsp_queues(struct ql3_adapter *qdev)
 {
 	qdev->req_q_size =
@@ -2079,8 +2271,7 @@ static int ql_alloc_net_req_rsp_queues(s
 
 	if ((qdev->req_q_virt_addr == NULL) ||
 	    LS_64BITS(qdev->req_q_phy_addr) & (qdev->req_q_size - 1)) {
-		printk(KERN_ERR PFX "%s: reqQ failed.\n",
-		       qdev->ndev->name);
+		printk(KERN_ERR PFX "%s: reqQ failed.\n", qdev->ndev->name);
 		return -ENOMEM;
 	}
 
@@ -2094,24 +2285,22 @@ static int ql_alloc_net_req_rsp_queues(s
 	if ((qdev->rsp_q_virt_addr == NULL) ||
 	    LS_64BITS(qdev->rsp_q_phy_addr) & (qdev->rsp_q_size - 1)) {
 		printk(KERN_ERR PFX
-		       "%s: rspQ allocation failed\n",
-		       qdev->ndev->name);
+		       "%s: rspQ allocation failed\n", qdev->ndev->name);
 		pci_free_consistent(qdev->pdev, (size_t) qdev->req_q_size,
 				    qdev->req_q_virt_addr,
 				    qdev->req_q_phy_addr);
 		return -ENOMEM;
 	}
 
-	set_bit(QL_ALLOC_REQ_RSP_Q_DONE,&qdev->flags);
+	set_bit(QL_ALLOC_REQ_RSP_Q_DONE, &qdev->flags);
 
 	return 0;
 }
 
 static void ql_free_net_req_rsp_queues(struct ql3_adapter *qdev)
 {
-	if (!test_bit(QL_ALLOC_REQ_RSP_Q_DONE,&qdev->flags)) {
-		printk(KERN_INFO PFX
-		       "%s: Already done.\n", qdev->ndev->name);
+	if (!test_bit(QL_ALLOC_REQ_RSP_Q_DONE, &qdev->flags)) {
+		printk(KERN_INFO PFX "%s: Already done.\n", qdev->ndev->name);
 		return;
 	}
 
@@ -2127,7 +2316,7 @@ static void ql_free_net_req_rsp_queues(s
 
 	qdev->rsp_q_virt_addr = NULL;
 
-	clear_bit(QL_ALLOC_REQ_RSP_Q_DONE,&qdev->flags);
+	clear_bit(QL_ALLOC_REQ_RSP_Q_DONE, &qdev->flags);
 }
 
 static int ql_alloc_buffer_queues(struct ql3_adapter *qdev)
@@ -2146,8 +2335,7 @@ static int ql_alloc_buffer_queues(struct
 				 &qdev->lrg_buf_q_alloc_phy_addr);
 
 	if (qdev->lrg_buf_q_alloc_virt_addr == NULL) {
-		printk(KERN_ERR PFX
-		       "%s: lBufQ failed\n", qdev->ndev->name);
+		printk(KERN_ERR PFX "%s: lBufQ failed\n", qdev->ndev->name);
 		return -ENOMEM;
 	}
 	qdev->lrg_buf_q_virt_addr = qdev->lrg_buf_q_alloc_virt_addr;
@@ -2178,15 +2366,14 @@ static int ql_alloc_buffer_queues(struct
 
 	qdev->small_buf_q_virt_addr = qdev->small_buf_q_alloc_virt_addr;
 	qdev->small_buf_q_phy_addr = qdev->small_buf_q_alloc_phy_addr;
-	set_bit(QL_ALLOC_BUFQS_DONE,&qdev->flags);
+	set_bit(QL_ALLOC_BUFQS_DONE, &qdev->flags);
 	return 0;
 }
 
 static void ql_free_buffer_queues(struct ql3_adapter *qdev)
 {
-	if (!test_bit(QL_ALLOC_BUFQS_DONE,&qdev->flags)) {
-		printk(KERN_INFO PFX
-		       "%s: Already done.\n", qdev->ndev->name);
+	if (!test_bit(QL_ALLOC_BUFQS_DONE, &qdev->flags)) {
+		printk(KERN_INFO PFX "%s: Already done.\n", qdev->ndev->name);
 		return;
 	}
 
@@ -2204,7 +2391,7 @@ static void ql_free_buffer_queues(struct
 
 	qdev->small_buf_q_virt_addr = NULL;
 
-	clear_bit(QL_ALLOC_BUFQS_DONE,&qdev->flags);
+	clear_bit(QL_ALLOC_BUFQS_DONE, &qdev->flags);
 }
 
 static int ql_alloc_small_buffers(struct ql3_adapter *qdev)
@@ -2234,8 +2421,6 @@ static int ql_alloc_small_buffers(struct
 
 	small_buf_q_entry = qdev->small_buf_q_virt_addr;
 
-	qdev->last_rsp_offset = qdev->small_buf_phy_addr_low;
-
 	/* Initialize the small buffer queue. */
 	for (i = 0; i < (QL_ADDR_ELE_PER_BUFQ_ENTRY * NUM_SBUFQ_ENTRIES); i++)
{
 		small_buf_q_entry->addr_high =
@@ -2246,15 +2431,14 @@ static int ql_alloc_small_buffers(struct
 		small_buf_q_entry++;
 	}
 	qdev->small_buf_index = 0;
-	set_bit(QL_ALLOC_SMALL_BUF_DONE,&qdev->flags);
+	set_bit(QL_ALLOC_SMALL_BUF_DONE, &qdev->flags);
 	return 0;
 }
 
 static void ql_free_small_buffers(struct ql3_adapter *qdev)
 {
-	if (!test_bit(QL_ALLOC_SMALL_BUF_DONE,&qdev->flags)) {
-		printk(KERN_INFO PFX
-		       "%s: Already done.\n", qdev->ndev->name);
+	if (!test_bit(QL_ALLOC_SMALL_BUF_DONE, &qdev->flags)) {
+		printk(KERN_INFO PFX "%s: Already done.\n", qdev->ndev->name);
 		return;
 	}
 	if (qdev->small_buf_virt_addr != NULL) {
@@ -2317,8 +2501,7 @@ static int ql_alloc_large_buffers(struct
 			printk(KERN_ERR PFX
 			       "%s: large buff alloc failed, "
 			       "for %d bytes at index %d.\n",
-			       qdev->ndev->name,
-			       qdev->lrg_buffer_len * 2, i);
+			       qdev->ndev->name, qdev->lrg_buffer_len * 2, i);
 			ql_free_large_buffers(qdev);
 			return -ENOMEM;
 		} else {
@@ -2350,20 +2533,39 @@ static int ql_alloc_large_buffers(struct
 	return 0;
 }
 
-static void ql_create_send_free_list(struct ql3_adapter *qdev)
+static void ql_free_send_free_list(struct ql3_adapter *qdev)
+{
+	struct ql_tx_buf_cb *tx_cb;
+	int i;
+
+	tx_cb = &qdev->tx_buf[0];
+	for (i = 0; i < NUM_REQ_Q_ENTRIES; i++) {
+		if (tx_cb->oal) {
+			kfree(tx_cb->oal);
+			tx_cb->oal = NULL;
+		}
+		tx_cb++;
+	}
+}
+
+static int ql_create_send_free_list(struct ql3_adapter *qdev)
 {
 	struct ql_tx_buf_cb *tx_cb;
 	int i;
-	struct ob_mac_iocb_req *req_q_curr =
-					qdev->req_q_virt_addr;
+	struct ob_mac_iocb_req *req_q_curr = qdev->req_q_virt_addr;
 
 	/* Create free list of transmit buffers */
 	for (i = 0; i < NUM_REQ_Q_ENTRIES; i++) {
+
 		tx_cb = &qdev->tx_buf[i];
 		tx_cb->skb = NULL;
 		tx_cb->queue_entry = req_q_curr;
 		req_q_curr++;
+		tx_cb->oal = kmalloc(512, GFP_KERNEL);
+		if (tx_cb->oal == NULL)
+			return -1;
 	}
+	return 0;
 }
 
 static int ql_alloc_mem_resources(struct ql3_adapter *qdev)
@@ -2438,12 +2640,14 @@ static int ql_alloc_mem_resources(struct
 
 	/* Initialize the large buffer queue. */
 	ql_init_large_buffers(qdev);
-	ql_create_send_free_list(qdev);
+	if (ql_create_send_free_list(qdev))
+		goto err_free_list;
 
 	qdev->rsp_current = qdev->rsp_q_virt_addr;
 
 	return 0;
-
+err_free_list:
+	ql_free_send_free_list(qdev);
 err_small_buffers:
 	ql_free_buffer_queues(qdev);
 err_buffer_queues:
@@ -2459,6 +2663,7 @@ err_req_rsp:
 
 static void ql_free_mem_resources(struct ql3_adapter *qdev)
 {
+	ql_free_send_free_list(qdev);
 	ql_free_large_buffers(qdev);
 	ql_free_small_buffers(qdev);
 	ql_free_buffer_queues(qdev);
@@ -2477,9 +2682,9 @@ static int ql_init_misc_registers(struct
 	struct ql3xxx_local_ram_registers __iomem *local_ram =
 	    (void __iomem *)qdev->mem_map_registers;
 
-	if(ql_sem_spinlock(qdev, QL_DDR_RAM_SEM_MASK,
-			(QL_RESOURCE_BITS_BASE_CODE | (qdev->mac_index) *
-			 2) << 4))
+	if (ql_sem_spinlock(qdev, QL_DDR_RAM_SEM_MASK,
+			    (QL_RESOURCE_BITS_BASE_CODE | (qdev->mac_index) *
+			     2) << 4))
 		return -1;
 
 	ql_write_page2_reg(qdev,
@@ -2533,13 +2738,14 @@ static int ql_init_misc_registers(struct
 static int ql_adapter_initialize(struct ql3_adapter *qdev)
 {
 	u32 value;
-	struct ql3xxx_port_registers __iomem *port_regs =
qdev->mem_map_registers;
+	struct ql3xxx_port_registers __iomem *port_regs =
+	    qdev->mem_map_registers;
 	struct ql3xxx_host_memory_registers __iomem *hmem_regs =
-						(void __iomem *)port_regs;
+	    (void __iomem *)port_regs;
 	u32 delay = 10;
 	int status = 0;
 
-	if(ql_mii_setup(qdev))
+	if (ql_mii_setup(qdev))
 		return -1;
 
 	/* Bring out PHY out of reset */
@@ -2557,7 +2763,7 @@ static int ql_adapter_initialize(struct 
 
 	/* Request Queue Registers */
 	*((u32 *) (qdev->preq_consumer_index)) = 0;
-	atomic_set(&qdev->tx_count,NUM_REQ_Q_ENTRIES);
+	atomic_set(&qdev->tx_count, NUM_REQ_Q_ENTRIES);
 	qdev->req_producer_index = 0;
 
 	ql_write_page1_reg(qdev,
@@ -2657,7 +2863,7 @@ static int ql_adapter_initialize(struct 
 	if ((value & PORT_STATUS_IC) == 0) {
 
 		/* Chip has not been configured yet, so let it rip. */
-		if(ql_init_misc_registers(qdev)) {
+		if (ql_init_misc_registers(qdev)) {
 			status = -1;
 			goto out;
 		}
@@ -2673,12 +2879,12 @@ static int ql_adapter_initialize(struct 
 
 		value = qdev->nvram_data.tcpMaxWindowSize;
 		ql_write_page0_reg(qdev, &port_regs->tcpMaxWindow, value);
-
 		value = (0xFFFF << 16) | qdev->nvram_data.extHwConfig;
 
-		if(ql_sem_spinlock(qdev, QL_FLASH_SEM_MASK,
-				(QL_RESOURCE_BITS_BASE_CODE | (qdev->mac_index)
-				 * 2) << 13)) {
+		if (ql_sem_spinlock(qdev, QL_FLASH_SEM_MASK,
+				    (QL_RESOURCE_BITS_BASE_CODE |
+				     (qdev->mac_index)
+				     * 2) << 13)) {
 			status = -1;
 			goto out;
 		}
@@ -2690,10 +2896,9 @@ static int ql_adapter_initialize(struct 
 		ql_sem_unlock(qdev, QL_FLASH_SEM_MASK);
 	}
 
-
-	if(ql_sem_spinlock(qdev, QL_PHY_GIO_SEM_MASK,
-			(QL_RESOURCE_BITS_BASE_CODE | (qdev->mac_index) *
-			 2) << 7)) {
+	if (ql_sem_spinlock(qdev, QL_PHY_GIO_SEM_MASK,
+			    (QL_RESOURCE_BITS_BASE_CODE | (qdev->mac_index) *
+			     2) << 7)) {
 		status = -1;
 		goto out;
 	}
@@ -2757,11 +2962,19 @@ static int ql_adapter_initialize(struct 
 	}
 
 	/* Enable Ethernet Function */
-	value =
-	    (PORT_CONTROL_EF | PORT_CONTROL_ET | PORT_CONTROL_EI |
-	     PORT_CONTROL_HH);
-	ql_write_page0_reg(qdev, &port_regs->portControl,
-			   ((value << 16) | value));
+	if (qdev->device_id == QL3032_DEVICE_ID) {
+		value =
+		    (QL3032_PORT_CONTROL_EF | QL3032_PORT_CONTROL_KIE |
+		     QL3032_PORT_CONTROL_EIv6 | QL3032_PORT_CONTROL_EIv4);
+		ql_write_page0_reg(qdev, &port_regs->functionControl,
+				   ((value << 16) | value));
+	} else {
+		value =
+		    (PORT_CONTROL_EF | PORT_CONTROL_ET | PORT_CONTROL_EI |
+		     PORT_CONTROL_HH);
+		ql_write_page0_reg(qdev, &port_regs->portControl,
+				   ((value << 16) | value));
+	}
 
 out:
 	return status;
@@ -2772,7 +2985,8 @@ out:
  */
 static int ql_adapter_reset(struct ql3_adapter *qdev)
 {
-	struct ql3xxx_port_registers __iomem *port_regs =
qdev->mem_map_registers;
+	struct ql3xxx_port_registers __iomem *port_regs =
+	    qdev->mem_map_registers;
 	int status = 0;
 	u16 value;
 	int max_wait_time;
@@ -2784,8 +2998,7 @@ static int ql_adapter_reset(struct ql3_a
 	 * Issue soft reset to chip.
 	 */
 	printk(KERN_DEBUG PFX
-	       "%s: Issue soft reset to chip.\n",
-	       qdev->ndev->name);
+	       "%s: Issue soft reset to chip.\n", qdev->ndev->name);
 	ql_write_common_reg(qdev,
 			    &port_regs->CommonRegs.ispControlStatus,
 			    ((ISP_CONTROL_SR << 16) | ISP_CONTROL_SR));
@@ -2855,7 +3068,8 @@ static int ql_adapter_reset(struct ql3_a
 
 static void ql_set_mac_info(struct ql3_adapter *qdev)
 {
-	struct ql3xxx_port_registers __iomem *port_regs =
qdev->mem_map_registers;
+	struct ql3xxx_port_registers __iomem *port_regs =
+	    qdev->mem_map_registers;
 	u32 value, port_status;
 	u8 func_number;
 
@@ -2868,27 +3082,23 @@ static void ql_set_mac_info(struct ql3_a
 	case ISP_CONTROL_FN0_NET:
 		qdev->mac_index = 0;
 		qdev->mac_ob_opcode = OUTBOUND_MAC_IOCB | func_number;
-		qdev->tcp_ob_opcode = OUTBOUND_TCP_IOCB | func_number;
-		qdev->update_ob_opcode = UPDATE_NCB_IOCB | func_number;
 		qdev->mb_bit_mask = FN0_MA_BITS_MASK;
 		qdev->PHYAddr = PORT0_PHY_ADDRESS;
 		if (port_status & PORT_STATUS_SM0)
-			set_bit(QL_LINK_OPTICAL,&qdev->flags);
+			set_bit(QL_LINK_OPTICAL, &qdev->flags);
 		else
-			clear_bit(QL_LINK_OPTICAL,&qdev->flags);
+			clear_bit(QL_LINK_OPTICAL, &qdev->flags);
 		break;
 
 	case ISP_CONTROL_FN1_NET:
 		qdev->mac_index = 1;
 		qdev->mac_ob_opcode = OUTBOUND_MAC_IOCB | func_number;
-		qdev->tcp_ob_opcode = OUTBOUND_TCP_IOCB | func_number;
-		qdev->update_ob_opcode = UPDATE_NCB_IOCB | func_number;
 		qdev->mb_bit_mask = FN1_MA_BITS_MASK;
 		qdev->PHYAddr = PORT1_PHY_ADDRESS;
 		if (port_status & PORT_STATUS_SM1)
-			set_bit(QL_LINK_OPTICAL,&qdev->flags);
+			set_bit(QL_LINK_OPTICAL, &qdev->flags);
 		else
-			clear_bit(QL_LINK_OPTICAL,&qdev->flags);
+			clear_bit(QL_LINK_OPTICAL, &qdev->flags);
 		break;
 
 	case ISP_CONTROL_FN0_SCSI:
@@ -2896,7 +3106,7 @@ static void ql_set_mac_info(struct ql3_a
 	default:
 		printk(KERN_DEBUG PFX
 		       "%s: Invalid function number, ispControlStatus = 0x%x\n",
-		       qdev->ndev->name,value);
+		       qdev->ndev->name, value);
 		break;
 	}
 	qdev->numPorts = qdev->nvram_data.numPorts;
@@ -2908,11 +3118,13 @@ static void ql_display_dev_info(struct n
 	struct pci_dev *pdev = qdev->pdev;
 
 	printk(KERN_INFO PFX
-	       "\n%s Adapter %d RevisionID %d found on PCI slot %d.\n",
-	       DRV_NAME, qdev->index, qdev->chip_rev_id, qdev->pci_slot);
+	       "\n%s Adapter %d RevisionID %d found %s on PCI slot %d.\n",
+	       DRV_NAME, qdev->index, qdev->chip_rev_id,
+	       (qdev->device_id == QL3032_DEVICE_ID) ? "QLA3032" : "QLA3022",
+	       qdev->pci_slot);
 	printk(KERN_INFO PFX
 	       "%s Interface.\n",
-	       test_bit(QL_LINK_OPTICAL,&qdev->flags) ? "OPTICAL" : "COPPER");
+	       test_bit(QL_LINK_OPTICAL, &qdev->flags) ? "OPTICAL" :
"COPPER");
 
 	/*
 	 * Print PCI bus width/type.
@@ -2943,17 +3155,17 @@ static int ql_adapter_down(struct ql3_ad
 	netif_stop_queue(ndev);
 	netif_carrier_off(ndev);
 
-	clear_bit(QL_ADAPTER_UP,&qdev->flags);
-	clear_bit(QL_LINK_MASTER,&qdev->flags);
+	clear_bit(QL_ADAPTER_UP, &qdev->flags);
+	clear_bit(QL_LINK_MASTER, &qdev->flags);
 
 	ql_disable_interrupts(qdev);
 
 	free_irq(qdev->pdev->irq, ndev);
 
-	if (qdev->msi && test_bit(QL_MSI_ENABLED,&qdev->flags)) {
+	if (qdev->msi && test_bit(QL_MSI_ENABLED, &qdev->flags)) {
 		printk(KERN_INFO PFX
 		       "%s: calling pci_disable_msi().\n", qdev->ndev->name);
-		clear_bit(QL_MSI_ENABLED,&qdev->flags);
+		clear_bit(QL_MSI_ENABLED, &qdev->flags);
 		pci_disable_msi(qdev->pdev);
 	}
 
@@ -2973,7 +3185,8 @@ static int ql_adapter_down(struct ql3_ad
 				       ndev->name, qdev->index);
 			}
 			printk(KERN_ERR PFX
-				"%s: Releaseing driver lock via chip reset.\n",ndev->name);
+			       "%s: Releaseing driver lock via chip reset.\n",
+			       ndev->name);
 		} else {
 			printk(KERN_ERR PFX
 			       "%s: Could not acquire driver lock to do "
@@ -3007,15 +3220,15 @@ static int ql_adapter_up(struct ql3_adap
 			       qdev->ndev->name);
 			qdev->msi = 0;
 		} else {
-			printk(KERN_INFO PFX "%s: MSI Enabled...\n", qdev->ndev->name);
-			set_bit(QL_MSI_ENABLED,&qdev->flags);
+			printk(KERN_INFO PFX "%s: MSI Enabled...\n",
+			       qdev->ndev->name);
+			set_bit(QL_MSI_ENABLED, &qdev->flags);
 			irq_flags &= ~SA_SHIRQ;
 		}
 	}
 
 	if ((err = request_irq(qdev->pdev->irq,
-			       ql3xxx_isr,
-			       irq_flags, ndev->name, ndev))) {
+			       ql3xxx_isr, irq_flags, ndev->name, ndev))) {
 		printk(KERN_ERR PFX
 		       "%s: Failed to reserve interrupt %d already in use.\n",
 		       ndev->name, qdev->pdev->irq);
@@ -3032,18 +3245,17 @@ static int ql_adapter_up(struct ql3_adap
 			goto err_init;
 		}
 		printk(KERN_ERR PFX
-				"%s: Releaseing driver lock.\n",ndev->name);
+		       "%s: Releaseing driver lock.\n", ndev->name);
 		ql_sem_unlock(qdev, QL_DRVR_SEM_MASK);
 	} else {
 		printk(KERN_ERR PFX
-		       "%s: Could not aquire driver lock.\n",
-		       ndev->name);
+		       "%s: Could not aquire driver lock.\n", ndev->name);
 		goto err_lock;
 	}
 
 	spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
 
-	set_bit(QL_ADAPTER_UP,&qdev->flags);
+	set_bit(QL_ADAPTER_UP, &qdev->flags);
 
 	mod_timer(&qdev->adapter_timer, jiffies + HZ * 1);
 
@@ -3056,11 +3268,10 @@ err_init:
 err_lock:
 	free_irq(qdev->pdev->irq, ndev);
 err_irq:
-	if (qdev->msi && test_bit(QL_MSI_ENABLED,&qdev->flags)) {
+	if (qdev->msi && test_bit(QL_MSI_ENABLED, &qdev->flags)) {
 		printk(KERN_INFO PFX
-		       "%s: calling pci_disable_msi().\n",
-		       qdev->ndev->name);
-		clear_bit(QL_MSI_ENABLED,&qdev->flags);
+		       "%s: calling pci_disable_msi().\n", qdev->ndev->name);
+		clear_bit(QL_MSI_ENABLED, &qdev->flags);
 		pci_disable_msi(qdev->pdev);
 	}
 	return err;
@@ -3068,10 +3279,10 @@ err_irq:
 
 static int ql_cycle_adapter(struct ql3_adapter *qdev, int reset)
 {
-	if( ql_adapter_down(qdev,reset) || ql_adapter_up(qdev)) {
+	if (ql_adapter_down(qdev, reset) || ql_adapter_up(qdev)) {
 		printk(KERN_ERR PFX
-				"%s: Driver up/down cycle failed, "
-				"closing device\n",qdev->ndev->name);
+		       "%s: Driver up/down cycle failed, "
+		       "closing device\n", qdev->ndev->name);
 		dev_close(qdev->ndev);
 		return -1;
 	}
@@ -3086,10 +3297,10 @@ static int ql3xxx_close(struct net_devic
 	 * Wait for device to recover from a reset.
 	 * (Rarely happens, but possible.)
 	 */
-	while (!test_bit(QL_ADAPTER_UP,&qdev->flags))
+	while (!test_bit(QL_ADAPTER_UP, &qdev->flags))
 		msleep(50);
 
-	ql_adapter_down(qdev,QL_DO_RESET);
+	ql_adapter_down(qdev, QL_DO_RESET);
 	return 0;
 }
 
@@ -3123,7 +3334,7 @@ static int ql3xxx_change_mtu(struct net_
 	}
 
 	ndev->mtu = new_mtu;
-	return ql_cycle_adapter(qdev,QL_DO_RESET);
+	return ql_cycle_adapter(qdev, QL_DO_RESET);
 }
 
 static void ql3xxx_set_multicast_list(struct net_device *ndev)
@@ -3138,7 +3349,7 @@ static int ql3xxx_set_mac_address(struct
 {
 	struct ql3_adapter *qdev = (struct ql3_adapter *)netdev_priv(ndev);
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+	    qdev->mem_map_registers;
 	struct sockaddr *addr = p;
 	unsigned long hw_flags;
 
@@ -3191,25 +3402,39 @@ static void ql_reset_work(struct ql3_ada
 	u32 value;
 	struct ql_tx_buf_cb *tx_cb;
 	int max_wait_time, i;
-	struct ql3xxx_port_registers __iomem *port_regs =
qdev->mem_map_registers;
+	struct ql3xxx_port_registers __iomem *port_regs =
+	    qdev->mem_map_registers;
 	unsigned long hw_flags;
 
-	if (test_bit((QL_RESET_PER_SCSI | QL_RESET_START),&qdev->flags)) {
-		clear_bit(QL_LINK_MASTER,&qdev->flags);
+	if (test_bit((QL_RESET_PER_SCSI | QL_RESET_START), &qdev->flags)) {
+		clear_bit(QL_LINK_MASTER, &qdev->flags);
 
 		/*
 		 * Loop through the active list and return the skb.
 		 */
 		for (i = 0; i < NUM_REQ_Q_ENTRIES; i++) {
+			int j;
 			tx_cb = &qdev->tx_buf[i];
 			if (tx_cb->skb) {
-
 				printk(KERN_DEBUG PFX
 				       "%s: Freeing lost SKB.\n",
 				       qdev->ndev->name);
 				pci_unmap_single(qdev->pdev,
-					pci_unmap_addr(tx_cb, mapaddr),
-					pci_unmap_len(tx_cb, maplen), PCI_DMA_TODEVICE);
+						 pci_unmap_addr(&tx_cb->map[0],
+								mapaddr),
+						 pci_unmap_len(&tx_cb->map[0],
+							       maplen),
+						 PCI_DMA_TODEVICE);
+				for (j = 1; j < tx_cb->seg_count; j++) {
+					pci_unmap_page(qdev->pdev,
+						       pci_unmap_addr(&tx_cb->
+								      map[j],
+								      mapaddr),
+						       pci_unmap_len(&tx_cb->
+								     map[j],
+								     maplen),
+						       PCI_DMA_TODEVICE);
+				}
 				dev_kfree_skb(tx_cb->skb);
 				tx_cb->skb = NULL;
 			}
@@ -3229,7 +3454,6 @@ static void ql_reset_work(struct ql3_ada
 		do {
 			value = ql_read_common_reg(qdev,
 						   &port_regs->CommonRegs.
-
 						   ispControlStatus);
 			if ((value & ISP_CONTROL_SR) == 0) {
 				printk(KERN_DEBUG PFX
@@ -3263,29 +3487,29 @@ static void ql_reset_work(struct ql3_ada
 			printk(KERN_ERR PFX
 			       "%s: Timed out waiting for reset to "
 			       "complete.\n", ndev->name);
-			printk(KERN_ERR PFX
-			       "%s: Do a reset.\n", ndev->name);
-			clear_bit(QL_RESET_PER_SCSI,&qdev->flags);
-			clear_bit(QL_RESET_START,&qdev->flags);
-			ql_cycle_adapter(qdev,QL_DO_RESET);
+			printk(KERN_ERR PFX "%s: Do a reset.\n", ndev->name);
+			clear_bit(QL_RESET_PER_SCSI, &qdev->flags);
+			clear_bit(QL_RESET_START, &qdev->flags);
+			ql_cycle_adapter(qdev, QL_DO_RESET);
 			return;
 		}
 
-		clear_bit(QL_RESET_ACTIVE,&qdev->flags);
-		clear_bit(QL_RESET_PER_SCSI,&qdev->flags);
-		clear_bit(QL_RESET_START,&qdev->flags);
-		ql_cycle_adapter(qdev,QL_NO_RESET);
+		clear_bit(QL_RESET_ACTIVE, &qdev->flags);
+		clear_bit(QL_RESET_PER_SCSI, &qdev->flags);
+		clear_bit(QL_RESET_START, &qdev->flags);
+		ql_cycle_adapter(qdev, QL_NO_RESET);
 	}
 }
 
 static void ql_tx_timeout_work(struct ql3_adapter *qdev)
 {
-	ql_cycle_adapter(qdev,QL_DO_RESET);
+	ql_cycle_adapter(qdev, QL_DO_RESET);
 }
 
 static void ql_get_board_info(struct ql3_adapter *qdev)
 {
-	struct ql3xxx_port_registers __iomem *port_regs =
qdev->mem_map_registers;
+	struct ql3xxx_port_registers __iomem *port_regs =
+	    qdev->mem_map_registers;
 	u32 value;
 
 	value = ql_read_page0_reg_l(qdev, &port_regs->portStatus);
@@ -3306,10 +3530,9 @@ static void ql3xxx_timer(unsigned long p
 {
 	struct ql3_adapter *qdev = (struct ql3_adapter *)ptr;
 
-	if (test_bit(QL_RESET_ACTIVE,&qdev->flags)) {
+	if (test_bit(QL_RESET_ACTIVE, &qdev->flags)) {
 		printk(KERN_DEBUG PFX
-		       "%s: Reset in progress.\n",
-		       qdev->ndev->name);
+		       "%s: Reset in progress.\n", qdev->ndev->name);
 		goto end;
 	}
 
@@ -3365,22 +3588,25 @@ static int __devinit ql3xxx_probe(struct
 	SET_MODULE_OWNER(ndev);
 	SET_NETDEV_DEV(ndev, &pdev->dev);
 
-	ndev->features = NETIF_F_LLTX;
-	if (pci_using_dac)
-		ndev->features |= NETIF_F_HIGHDMA;
-
 	pci_set_drvdata(pdev, ndev);
 
 	qdev = netdev_priv(ndev);
 	qdev->index = cards_found;
 	qdev->ndev = ndev;
 	qdev->pdev = pdev;
+	qdev->device_id = pci_entry->device;
 	qdev->port_link_state = LS_DOWN;
 	if (msi)
 		qdev->msi = 1;
 
 	qdev->msg_enable = netif_msg_init(debug, default_msg);
 
+	ndev->features |= NETIF_F_LLTX;
+	if (pci_using_dac)
+		ndev->features |= NETIF_F_HIGHDMA;
+	if (qdev->device_id == QL3032_DEVICE_ID)
+		ndev->features |= (NETIF_F_HW_CSUM | NETIF_F_SG);
+
 	qdev->mem_map_registers =
 	    ioremap_nocache(pci_resource_start(pdev, 1),
 			    pci_resource_len(qdev->pdev, 1));
@@ -3454,7 +3680,6 @@ static int __devinit ql3xxx_probe(struct
 	}
 
 	/* we're going to reset, so assume we have no link for now */
-
 	netif_carrier_off(ndev);
 	netif_stop_queue(ndev);
 
@@ -3468,10 +3693,10 @@ static int __devinit ql3xxx_probe(struct
 	qdev->adapter_timer.expires = jiffies + HZ * 2;	/* two second delay */
 	qdev->adapter_timer.data = (unsigned long)qdev;
 
-	if(!cards_found) {
+	if (!cards_found) {
 		printk(KERN_ALERT PFX "%s\n", DRV_STRING);
 		printk(KERN_ALERT PFX "Driver name: %s, Version: %s.\n",
-	    	   DRV_NAME, DRV_VERSION);
+		       DRV_NAME, DRV_VERSION);
 	}
 	ql_display_dev_info(ndev);
 
diff --git a/drivers/net/qla3xxx.h b/drivers/net/qla3xxx.h
index 65da2c0..3c4ceeb 100644
--- a/drivers/net/qla3xxx.h
+++ b/drivers/net/qla3xxx.h
@@ -21,7 +21,9 @@ #define OPCODE_UPDATE_NCB_IOCB_FN2      
 
 #define OPCODE_UPDATE_NCB_IOCB      0xF0
 #define OPCODE_IB_MAC_IOCB          0xF9
+#define OPCODE_IB_3032_MAC_IOCB     0x09
 #define OPCODE_IB_IP_IOCB           0xFA
+#define OPCODE_IB_3032_IP_IOCB      0x0A
 #define OPCODE_IB_TCP_IOCB          0xFB
 #define OPCODE_DUMP_PROTO_IOCB      0xFE
 #define OPCODE_BUFFER_ALERT_IOCB    0xFB
@@ -37,18 +39,23 @@ #define FN1_MA_BITS_MASK    0x80
 struct ob_mac_iocb_req {
 	u8 opcode;
 	u8 flags;
-#define OB_MAC_IOCB_REQ_MA  0xC0
-#define OB_MAC_IOCB_REQ_F   0x20
-#define OB_MAC_IOCB_REQ_X   0x10
+#define OB_MAC_IOCB_REQ_MA  0xe0
+#define OB_MAC_IOCB_REQ_F   0x10
+#define OB_MAC_IOCB_REQ_X   0x08
 #define OB_MAC_IOCB_REQ_D   0x02
 #define OB_MAC_IOCB_REQ_I   0x01
-	__le16 reserved0;
+	u8 flags1;
+#define OB_3032MAC_IOCB_REQ_IC	0x04
+#define OB_3032MAC_IOCB_REQ_TC	0x02
+#define OB_3032MAC_IOCB_REQ_UC	0x01
+	u8 reserved0;
 
 	__le32 transaction_id;
 	__le16 data_len;
-	__le16 reserved1;
+	u8 ip_hdr_off;
+	u8 ip_hdr_len;
+	__le32 reserved1;
 	__le32 reserved2;
-	__le32 reserved3;
 	__le32 buf_addr0_low;
 	__le32 buf_addr0_high;
 	__le32 buf_0_len;
@@ -58,8 +65,8 @@ #define OB_MAC_IOCB_REQ_I   0x01
 	__le32 buf_addr2_low;
 	__le32 buf_addr2_high;
 	__le32 buf_2_len;
+	__le32 reserved3;
 	__le32 reserved4;
-	__le32 reserved5;
 };
 /*
  * The following constants define control bits for buffer
@@ -74,6 +81,7 @@ struct ob_mac_iocb_rsp {
 	u8 opcode;
 	u8 flags;
 #define OB_MAC_IOCB_RSP_P   0x08
+#define OB_MAC_IOCB_RSP_L   0x04
 #define OB_MAC_IOCB_RSP_S   0x02
 #define OB_MAC_IOCB_RSP_I   0x01
 
@@ -85,6 +93,7 @@ #define OB_MAC_IOCB_RSP_I   0x01
 
 struct ib_mac_iocb_rsp {
 	u8 opcode;
+#define IB_MAC_IOCB_RSP_V   0x80
 	u8 flags;
 #define IB_MAC_IOCB_RSP_S   0x80
 #define IB_MAC_IOCB_RSP_H1  0x40
@@ -138,6 +147,7 @@ #define OB_IP_IOCB_REQ_R    0x10000000
 struct ob_ip_iocb_rsp {
 	u8 opcode;
 	u8 flags;
+#define OB_MAC_IOCB_RSP_H       0x10
 #define OB_MAC_IOCB_RSP_E       0x08
 #define OB_MAC_IOCB_RSP_L       0x04
 #define OB_MAC_IOCB_RSP_S       0x02
@@ -220,6 +230,10 @@ #define OB_TCP_IOCB_RSP_SHIFT   4
 
 struct ib_ip_iocb_rsp {
 	u8 opcode;
+#define IB_IP_IOCB_RSP_3032_V   0x80
+#define IB_IP_IOCB_RSP_3032_O   0x40
+#define IB_IP_IOCB_RSP_3032_I   0x20
+#define IB_IP_IOCB_RSP_3032_R   0x10
 	u8 flags;
 #define IB_IP_IOCB_RSP_S        0x80
 #define IB_IP_IOCB_RSP_H1       0x40
@@ -230,6 +244,12 @@ #define IB_IP_IOCB_RSP_MA       0x07
 
 	__le16 length;
 	__le16 checksum;
+#define IB_IP_IOCB_RSP_3032_ICE		0x01
+#define IB_IP_IOCB_RSP_3032_CE		0x02
+#define IB_IP_IOCB_RSP_3032_NUC		0x04
+#define IB_IP_IOCB_RSP_3032_UDP		0x08
+#define IB_IP_IOCB_RSP_3032_TCP		0x10
+#define IB_IP_IOCB_RSP_3032_IPE		0x20
 	__le16 reserved;
 #define IB_IP_IOCB_RSP_R        0x01
 	__le32 ial_low;
@@ -524,6 +544,23 @@ enum {
 	IP_ADDR_INDEX_REG_FUNC_2_SEC = 0x0005,
 	IP_ADDR_INDEX_REG_FUNC_3_PRI = 0x0006,
 	IP_ADDR_INDEX_REG_FUNC_3_SEC = 0x0007,
+	/* 3032 addition start */
+	IP_ADDR_INDEX_REG_6 = 0x0008,
+	IP_ADDR_INDEX_REG_OFFSET_MASK = 0x0030,
+	IP_ADDR_INDEX_REG_E = 0x0040,
+	/* 3032 addition end */
+};
+enum {
+	QL3032_PORT_CONTROL_DS = 0x0001,
+	QL3032_PORT_CONTROL_HH = 0x0002,
+	QL3032_PORT_CONTROL_EIv6 = 0x0004,
+	QL3032_PORT_CONTROL_EIv4 = 0x0008,
+	QL3032_PORT_CONTROL_ET = 0x0010,
+	QL3032_PORT_CONTROL_EF = 0x0020,
+	QL3032_PORT_CONTROL_DRM = 0x0040,
+	QL3032_PORT_CONTROL_RLB = 0x0080,
+	QL3032_PORT_CONTROL_RCB = 0x0100,
+	QL3032_PORT_CONTROL_KIE = 0x0200,
 };
 
 enum {
@@ -657,7 +694,10 @@ struct ql3xxx_port_registers {
 	u32 internalRamWDataReg;
 	u32 reclaimedBufferAddrRegLow;
 	u32 reclaimedBufferAddrRegHigh;
-	u32 reserved[2];
+	/* 3032 addition start */
+	u32 tcpConfiguration;
+	u32 functionControl;
+	/* 3032 addition end */
 	u32 fpgaRevID;
 	u32 localRamAddr;
 	u32 localRamDataAutoIncr;
@@ -831,7 +871,7 @@ enum {
 };
 enum {
 /* Auburn Bits */
-	    AUBURN_EEPROM_DI = 0x8,
+	AUBURN_EEPROM_DI = 0x8,
 	AUBURN_EEPROM_DI_0 = 0x0,
 	AUBURN_EEPROM_DI_1 = 0x8,
 	AUBURN_EEPROM_DO = 0x4,
@@ -843,7 +883,7 @@ enum {
 	AUBURN_EEPROM_CLK_RISE = 0x1,
 	AUBURN_EEPROM_CLK_FALL = 0x0,
 };
-enum {EEPROM_SIZE = FM93C86A_SIZE_16,
+enum { EEPROM_SIZE = FM93C86A_SIZE_16,
 	EEPROM_NO_ADDR_BITS = FM93C86A_NO_ADDR_BITS_16,
 	EEPROM_NO_DATA_BITS = FM93C56A_DATA_BITS_16,
 };
@@ -851,7 +891,7 @@ enum {EEPROM_SIZE = FM93C86A_SIZE_16,
 /*
  *  MAC Config data structure
  */
-    struct eeprom_port_cfg {
+struct eeprom_port_cfg {
 	u16 etherMtu_mac;
 	u16 pauseThreshold_mac;
 	u16 resumeThreshold_mac;
@@ -963,6 +1003,7 @@ #define IPSEC_CONFIG_PRESENT 0x0001
 
 #define QL3XXX_VENDOR_ID    0x1077
 #define QL3022_DEVICE_ID    0x3022
+#define QL3032_DEVICE_ID    0x3032
 
 /* MTU & Frame Size stuff */
 #define NORMAL_MTU_SIZE 		ETH_DATA_LEN
@@ -1038,11 +1079,40 @@ struct ql_rcv_buf_cb {
 	int index;
 };
 
+/*
+ * Original IOCB has 3 sg entries:
+ * first points to skb-data area
+ * second points to first frag
+ * third points to next oal.
+ * OAL has 5 entries:
+ * 1 thru 4 point to frags
+ * fifth points to next oal.
+ */
+#define MAX_OAL_CNT ((MAX_SKB_FRAGS-1)/4 + 1)
+
+struct oal_entry {
+	u32 dma_lo;
+	u32 dma_hi;
+	u32 len;
+#define OAL_LAST_ENTRY   0x80000000	/* Last valid buffer in list. */
+#define OAL_CONT_ENTRY   0x40000000	/* points to an OAL. (continuation)
*/
+};
+
+struct oal {
+	struct oal_entry oal_entry[5];
+};
+
+struct map_list {
+	DECLARE_PCI_UNMAP_ADDR(mapaddr);
+	DECLARE_PCI_UNMAP_LEN(maplen);
+};
+
 struct ql_tx_buf_cb {
 	struct sk_buff *skb;
-	struct ob_mac_iocb_req *queue_entry ;
-	 DECLARE_PCI_UNMAP_ADDR(mapaddr);
-	 DECLARE_PCI_UNMAP_LEN(maplen);
+	struct ob_mac_iocb_req *queue_entry;
+	int seg_count;
+	struct oal *oal;
+	struct map_list map[MAX_SKB_FRAGS + 1];
 };
 
 /* definitions for type field */
@@ -1059,7 +1129,7 @@ enum { QL_RESET_DONE = 1,	/* Reset finis
 	QL_LINK_MASTER = 6,	/* This driver controls the link. */
 	QL_ADAPTER_UP = 7,	/* Adapter has been brought up. */
 	QL_THREAD_UP = 8,	/* This flag is available. */
-	QL_LINK_UP = 9,	/* Link Status. */
+	QL_LINK_UP = 9,		/* Link Status. */
 	QL_ALLOC_REQ_RSP_Q_DONE = 10,
 	QL_ALLOC_BUFQS_DONE = 11,
 	QL_ALLOC_SMALL_BUF_DONE = 12,
@@ -1093,7 +1163,6 @@ struct ql3_adapter {
 	spinlock_t hw_lock;
 
 	/* PCI Bus Relative Register Addresses */
-	u8 __iomem *mmap_virt_base;	/* stores return value from ioremap() */
 	struct ql3xxx_port_registers __iomem *mem_map_registers;
 	u32 current_page;	/* tracks current register page */
 
@@ -1172,16 +1241,11 @@ struct ql3_adapter {
 	u32 control_status;
 
 	struct eeprom_data nvram_data;
-	struct timer_list ioctl_timer;
 	u32 port_link_state;
-	u32 last_rsp_offset;
 
-	/* 4022 specific */
 	u32 mac_index;		/* Driver's MAC number can be 0 or 1 for first and
second networking functions respectively */
 	u32 PHYAddr;		/* Address of PHY 0x1e00 Port 0 and 0x1f00 Port 1 */
 	u32 mac_ob_opcode;	/* Opcode to use on mac transmission */
-	u32 tcp_ob_opcode;	/* Opcode to use on tcp transmission */
-	u32 update_ob_opcode;	/* Opcode to use for updating NCB */
 	u32 mb_bit_mask;	/* MA Bits mask to use on transmission */
 	u32 numPorts;
 	struct net_device_stats stats;
@@ -1189,6 +1253,7 @@ struct ql3_adapter {
 	struct work_struct reset_work;
 	struct work_struct tx_timeout_work;
 	u32 max_frame_size;
+	u32 device_id;
 };
 
 #endif				/* _QLA3XXX_H_ */
-- 
1.4.2.rc2-dirty


