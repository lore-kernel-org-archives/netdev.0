From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] drivers/net/qla3xxx.c: Checkpatch cleanups
Date: Thu, 22 Jul 2010 18:36:17 -0700
Message-ID: <118c687d97762e235ba61733ef1610f6443ae1eb.1279848705.git.joe@perches.com>
Cc: linux-driver@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ron Mercer <ron.mercer@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2055 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755913Ab0GWBgT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jul 2010 21:36:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove typedefs
Indentation and spacing
Use a temporary for a very long pointer variable
More 80 column compatible
Convert a switch to if/else if

Compile tested only, depends on patch "Update logging message style"

(old)
$ scripts/checkpatch.pl -f drivers/net/qla3xxx.c | grep "^total:"
total: 209 errors, 82 warnings, 3995 lines checked

(new)
$ scripts/checkpatch.pl -f drivers/net/qla3xxx.c | grep "^total:"
total: 2 errors, 0 warnings, 3970 lines checked

$ size drivers/net/qla3xxx.o.*
   text	   data	    bss	    dec	    hex	filename
  50413     212   13864   64489    fbe9 drivers/net/qla3xxx.o.old
  49959	    212	  13728	  63899	   f99b	drivers/net/qla3xxx.o.new

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/qla3xxx.c |  943 ++++++++++++++++++++++++-------------------------
 1 files changed, 459 insertions(+), 484 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 74debf1..6168a13 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -38,8 +38,8 @@
 
 #include "qla3xxx.h"
 
-#define DRV_NAME  	"qla3xxx"
-#define DRV_STRING 	"QLogic ISP3XXX Network Driver"
+#define DRV_NAME	"qla3xxx"
+#define DRV_STRING	"QLogic ISP3XXX Network Driver"
 #define DRV_VERSION	"v2.03.00-k5"
 
 static const char ql3xxx_driver_name[] = DRV_NAME;
@@ -77,24 +77,24 @@ MODULE_DEVICE_TABLE(pci, ql3xxx_pci_tbl);
 /*
  *  These are the known PHY's which are used
  */
-typedef enum {
+enum PHY_DEVICE_TYPE {
    PHY_TYPE_UNKNOWN   = 0,
    PHY_VITESSE_VSC8211,
    PHY_AGERE_ET1011C,
    MAX_PHY_DEV_TYPES
-} PHY_DEVICE_et;
-
-typedef struct {
-	PHY_DEVICE_et phyDevice;
-	u32		phyIdOUI;
-	u16		phyIdModel;
-	char 		*name;
-} PHY_DEVICE_INFO_t;
-
-static const PHY_DEVICE_INFO_t PHY_DEVICES[] =
-	{{PHY_TYPE_UNKNOWN,    0x000000, 0x0, "PHY_TYPE_UNKNOWN"},
-	 {PHY_VITESSE_VSC8211, 0x0003f1, 0xb, "PHY_VITESSE_VSC8211"},
-	 {PHY_AGERE_ET1011C,   0x00a0bc, 0x1, "PHY_AGERE_ET1011C"},
+};
+
+struct PHY_DEVICE_INFO {
+	const enum PHY_DEVICE_TYPE	phyDevice;
+	const u32		phyIdOUI;
+	const u16		phyIdModel;
+	const char		*name;
+};
+
+static const struct PHY_DEVICE_INFO PHY_DEVICES[] = {
+	{PHY_TYPE_UNKNOWN,    0x000000, 0x0, "PHY_TYPE_UNKNOWN"},
+	{PHY_VITESSE_VSC8211, 0x0003f1, 0xb, "PHY_VITESSE_VSC8211"},
+	{PHY_AGERE_ET1011C,   0x00a0bc, 0x1, "PHY_AGERE_ET1011C"},
 };
 
 
@@ -104,7 +104,8 @@ static const PHY_DEVICE_INFO_t PHY_DEVICES[] =
 static int ql_sem_spinlock(struct ql3_adapter *qdev,
 			    u32 sem_mask, u32 sem_bits)
 {
-	struct ql3xxx_port_registers __iomem *port_regs = qdev->mem_map_registers;
+	struct ql3xxx_port_registers __iomem *port_regs =
+		qdev->mem_map_registers;
 	u32 value;
 	unsigned int seconds = 3;
 
@@ -115,20 +116,22 @@ static int ql_sem_spinlock(struct ql3_adapter *qdev,
 		if ((value & (sem_mask >> 16)) == sem_bits)
 			return 0;
 		ssleep(1);
-	} while(--seconds);
+	} while (--seconds);
 	return -1;
 }
 
 static void ql_sem_unlock(struct ql3_adapter *qdev, u32 sem_mask)
 {
-	struct ql3xxx_port_registers __iomem *port_regs = qdev->mem_map_registers;
+	struct ql3xxx_port_registers __iomem *port_regs =
+		qdev->mem_map_registers;
 	writel(sem_mask, &port_regs->CommonRegs.semaphoreReg);
 	readl(&port_regs->CommonRegs.semaphoreReg);
 }
 
 static int ql_sem_lock(struct ql3_adapter *qdev, u32 sem_mask, u32 sem_bits)
 {
-	struct ql3xxx_port_registers __iomem *port_regs = qdev->mem_map_registers;
+	struct ql3xxx_port_registers __iomem *port_regs =
+		qdev->mem_map_registers;
 	u32 value;
 
 	writel((sem_mask | sem_bits), &port_regs->CommonRegs.semaphoreReg);
@@ -163,7 +166,8 @@ static int ql_wait_for_drvr_lock(struct ql3_adapter *qdev)
 
 static void ql_set_register_page(struct ql3_adapter *qdev, u32 page)
 {
-	struct ql3xxx_port_registers __iomem *port_regs = qdev->mem_map_registers;
+	struct ql3xxx_port_registers __iomem *port_regs =
+		qdev->mem_map_registers;
 
 	writel(((ISP_CONTROL_NP_MASK << 16) | page),
 			&port_regs->CommonRegs.ispControlStatus);
@@ -171,8 +175,7 @@ static void ql_set_register_page(struct ql3_adapter *qdev, u32 page)
 	qdev->current_page = page;
 }
 
-static u32 ql_read_common_reg_l(struct ql3_adapter *qdev,
-			      u32 __iomem * reg)
+static u32 ql_read_common_reg_l(struct ql3_adapter *qdev, u32 __iomem *reg)
 {
 	u32 value;
 	unsigned long hw_flags;
@@ -184,8 +187,7 @@ static u32 ql_read_common_reg_l(struct ql3_adapter *qdev,
 	return value;
 }
 
-static u32 ql_read_common_reg(struct ql3_adapter *qdev,
-			      u32 __iomem * reg)
+static u32 ql_read_common_reg(struct ql3_adapter *qdev, u32 __iomem *reg)
 {
 	return readl(reg);
 }
@@ -198,7 +200,7 @@ static u32 ql_read_page0_reg_l(struct ql3_adapter *qdev, u32 __iomem *reg)
 	spin_lock_irqsave(&qdev->hw_lock, hw_flags);
 
 	if (qdev->current_page != 0)
-		ql_set_register_page(qdev,0);
+		ql_set_register_page(qdev, 0);
 	value = readl(reg);
 
 	spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
@@ -208,7 +210,7 @@ static u32 ql_read_page0_reg_l(struct ql3_adapter *qdev, u32 __iomem *reg)
 static u32 ql_read_page0_reg(struct ql3_adapter *qdev, u32 __iomem *reg)
 {
 	if (qdev->current_page != 0)
-		ql_set_register_page(qdev,0);
+		ql_set_register_page(qdev, 0);
 	return readl(reg);
 }
 
@@ -242,7 +244,7 @@ static void ql_write_page0_reg(struct ql3_adapter *qdev,
 			       u32 __iomem *reg, u32 value)
 {
 	if (qdev->current_page != 0)
-		ql_set_register_page(qdev,0);
+		ql_set_register_page(qdev, 0);
 	writel(value, reg);
 	readl(reg);
 }
@@ -254,7 +256,7 @@ static void ql_write_page1_reg(struct ql3_adapter *qdev,
 			       u32 __iomem *reg, u32 value)
 {
 	if (qdev->current_page != 1)
-		ql_set_register_page(qdev,1);
+		ql_set_register_page(qdev, 1);
 	writel(value, reg);
 	readl(reg);
 }
@@ -266,14 +268,15 @@ static void ql_write_page2_reg(struct ql3_adapter *qdev,
 			       u32 __iomem *reg, u32 value)
 {
 	if (qdev->current_page != 2)
-		ql_set_register_page(qdev,2);
+		ql_set_register_page(qdev, 2);
 	writel(value, reg);
 	readl(reg);
 }
 
 static void ql_disable_interrupts(struct ql3_adapter *qdev)
 {
-	struct ql3xxx_port_registers __iomem *port_regs = qdev->mem_map_registers;
+	struct ql3xxx_port_registers __iomem *port_regs =
+		qdev->mem_map_registers;
 
 	ql_write_common_reg_l(qdev, &port_regs->CommonRegs.ispInterruptMaskReg,
 			    (ISP_IMR_ENABLE_INT << 16));
@@ -282,7 +285,8 @@ static void ql_disable_interrupts(struct ql3_adapter *qdev)
 
 static void ql_enable_interrupts(struct ql3_adapter *qdev)
 {
-	struct ql3xxx_port_registers __iomem *port_regs = qdev->mem_map_registers;
+	struct ql3xxx_port_registers __iomem *port_regs =
+		qdev->mem_map_registers;
 
 	ql_write_common_reg_l(qdev, &port_regs->CommonRegs.ispInterruptMaskReg,
 			    ((0xff << 16) | ISP_IMR_ENABLE_INT));
@@ -321,7 +325,7 @@ static void ql_release_to_lrg_buf_free_list(struct ql3_adapter *qdev,
 					     QL_HEADER_SPACE,
 					     PCI_DMA_FROMDEVICE);
 			err = pci_dma_mapping_error(qdev->pdev, map);
-			if(err) {
+			if (err) {
 				netdev_err(qdev->ndev,
 					   "PCI mapping failed with error: %d\n",
 					   err);
@@ -349,10 +353,11 @@ static void ql_release_to_lrg_buf_free_list(struct ql3_adapter *qdev,
 static struct ql_rcv_buf_cb *ql_get_from_lrg_buf_free_list(struct ql3_adapter
 							   *qdev)
 {
-	struct ql_rcv_buf_cb *lrg_buf_cb;
+	struct ql_rcv_buf_cb *lrg_buf_cb = qdev->lrg_buf_free_head;
 
-	if ((lrg_buf_cb = qdev->lrg_buf_free_head) != NULL) {
-		if ((qdev->lrg_buf_free_head = lrg_buf_cb->next) == NULL)
+	if (lrg_buf_cb != NULL) {
+		qdev->lrg_buf_free_head = lrg_buf_cb->next;
+		if (qdev->lrg_buf_free_head == NULL)
 			qdev->lrg_buf_free_tail = NULL;
 		qdev->lrg_buf_free_count--;
 	}
@@ -373,13 +378,13 @@ static void eeprom_readword(struct ql3_adapter *qdev, u32 eepromAddr,
 static void fm93c56a_select(struct ql3_adapter *qdev)
 {
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+			qdev->mem_map_registers;
+	u32 *spir = &port_regs->CommonRegs.serialPortInterfaceReg;
 
 	qdev->eeprom_cmd_data = AUBURN_EEPROM_CS_1;
-	ql_write_nvram_reg(qdev, &port_regs->CommonRegs.serialPortInterfaceReg,
-			    ISP_NVRAM_MASK | qdev->eeprom_cmd_data);
-	ql_write_nvram_reg(qdev, &port_regs->CommonRegs.serialPortInterfaceReg,
-			    ((ISP_NVRAM_MASK << 16) | qdev->eeprom_cmd_data));
+	ql_write_nvram_reg(qdev, spir, ISP_NVRAM_MASK | qdev->eeprom_cmd_data);
+	ql_write_nvram_reg(qdev, spir,
+			   ((ISP_NVRAM_MASK << 16) | qdev->eeprom_cmd_data));
 }
 
 /*
@@ -392,51 +397,40 @@ static void fm93c56a_cmd(struct ql3_adapter *qdev, u32 cmd, u32 eepromAddr)
 	u32 dataBit;
 	u32 previousBit;
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+			qdev->mem_map_registers;
+	u32 *spir = &port_regs->CommonRegs.serialPortInterfaceReg;
 
 	/* Clock in a zero, then do the start bit */
-	ql_write_nvram_reg(qdev, &port_regs->CommonRegs.serialPortInterfaceReg,
-			    ISP_NVRAM_MASK | qdev->eeprom_cmd_data |
-			    AUBURN_EEPROM_DO_1);
-	ql_write_nvram_reg(qdev, &port_regs->CommonRegs.serialPortInterfaceReg,
-			    ISP_NVRAM_MASK | qdev->
-			    eeprom_cmd_data | AUBURN_EEPROM_DO_1 |
-			    AUBURN_EEPROM_CLK_RISE);
-	ql_write_nvram_reg(qdev, &port_regs->CommonRegs.serialPortInterfaceReg,
-			    ISP_NVRAM_MASK | qdev->
-			    eeprom_cmd_data | AUBURN_EEPROM_DO_1 |
-			    AUBURN_EEPROM_CLK_FALL);
+	ql_write_nvram_reg(qdev, spir,
+			   (ISP_NVRAM_MASK | qdev->eeprom_cmd_data |
+			    AUBURN_EEPROM_DO_1));
+	ql_write_nvram_reg(qdev, spir,
+			   (ISP_NVRAM_MASK | qdev->eeprom_cmd_data |
+			    AUBURN_EEPROM_DO_1 | AUBURN_EEPROM_CLK_RISE));
+	ql_write_nvram_reg(qdev, spir,
+			   (ISP_NVRAM_MASK | qdev->eeprom_cmd_data |
+			    AUBURN_EEPROM_DO_1 | AUBURN_EEPROM_CLK_FALL));
 
 	mask = 1 << (FM93C56A_CMD_BITS - 1);
 	/* Force the previous data bit to be different */
 	previousBit = 0xffff;
 	for (i = 0; i < FM93C56A_CMD_BITS; i++) {
-		dataBit =
-		    (cmd & mask) ? AUBURN_EEPROM_DO_1 : AUBURN_EEPROM_DO_0;
+		dataBit = (cmd & mask)
+			? AUBURN_EEPROM_DO_1
+			: AUBURN_EEPROM_DO_0;
 		if (previousBit != dataBit) {
-			/*
-			 * If the bit changed, then change the DO state to
-			 * match
-			 */
-			ql_write_nvram_reg(qdev,
-					    &port_regs->CommonRegs.
-					    serialPortInterfaceReg,
-					    ISP_NVRAM_MASK | qdev->
-					    eeprom_cmd_data | dataBit);
+			/* If the bit changed, change the DO state to match */
+			ql_write_nvram_reg(qdev, spir,
+					   (ISP_NVRAM_MASK |
+					    qdev->eeprom_cmd_data | dataBit));
 			previousBit = dataBit;
 		}
-		ql_write_nvram_reg(qdev,
-				    &port_regs->CommonRegs.
-				    serialPortInterfaceReg,
-				    ISP_NVRAM_MASK | qdev->
-				    eeprom_cmd_data | dataBit |
-				    AUBURN_EEPROM_CLK_RISE);
-		ql_write_nvram_reg(qdev,
-				    &port_regs->CommonRegs.
-				    serialPortInterfaceReg,
-				    ISP_NVRAM_MASK | qdev->
-				    eeprom_cmd_data | dataBit |
-				    AUBURN_EEPROM_CLK_FALL);
+		ql_write_nvram_reg(qdev, spir,
+				   (ISP_NVRAM_MASK | qdev->eeprom_cmd_data |
+				    dataBit | AUBURN_EEPROM_CLK_RISE));
+		ql_write_nvram_reg(qdev, spir,
+				   (ISP_NVRAM_MASK | qdev->eeprom_cmd_data |
+				    dataBit | AUBURN_EEPROM_CLK_FALL));
 		cmd = cmd << 1;
 	}
 
@@ -444,33 +438,24 @@ static void fm93c56a_cmd(struct ql3_adapter *qdev, u32 cmd, u32 eepromAddr)
 	/* Force the previous data bit to be different */
 	previousBit = 0xffff;
 	for (i = 0; i < addrBits; i++) {
-		dataBit =
-		    (eepromAddr & mask) ? AUBURN_EEPROM_DO_1 :
-		    AUBURN_EEPROM_DO_0;
+		dataBit = (eepromAddr & mask) ? AUBURN_EEPROM_DO_1
+			: AUBURN_EEPROM_DO_0;
 		if (previousBit != dataBit) {
 			/*
 			 * If the bit changed, then change the DO state to
 			 * match
 			 */
-			ql_write_nvram_reg(qdev,
-					    &port_regs->CommonRegs.
-					    serialPortInterfaceReg,
-					    ISP_NVRAM_MASK | qdev->
-					    eeprom_cmd_data | dataBit);
+			ql_write_nvram_reg(qdev, spir,
+					   (ISP_NVRAM_MASK |
+					    qdev->eeprom_cmd_data | dataBit));
 			previousBit = dataBit;
 		}
-		ql_write_nvram_reg(qdev,
-				    &port_regs->CommonRegs.
-				    serialPortInterfaceReg,
-				    ISP_NVRAM_MASK | qdev->
-				    eeprom_cmd_data | dataBit |
-				    AUBURN_EEPROM_CLK_RISE);
-		ql_write_nvram_reg(qdev,
-				    &port_regs->CommonRegs.
-				    serialPortInterfaceReg,
-				    ISP_NVRAM_MASK | qdev->
-				    eeprom_cmd_data | dataBit |
-				    AUBURN_EEPROM_CLK_FALL);
+		ql_write_nvram_reg(qdev, spir,
+				   (ISP_NVRAM_MASK | qdev->eeprom_cmd_data |
+				    dataBit | AUBURN_EEPROM_CLK_RISE));
+		ql_write_nvram_reg(qdev, spir,
+				   (ISP_NVRAM_MASK | qdev->eeprom_cmd_data |
+				    dataBit | AUBURN_EEPROM_CLK_FALL));
 		eepromAddr = eepromAddr << 1;
 	}
 }
@@ -481,10 +466,11 @@ static void fm93c56a_cmd(struct ql3_adapter *qdev, u32 cmd, u32 eepromAddr)
 static void fm93c56a_deselect(struct ql3_adapter *qdev)
 {
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+			qdev->mem_map_registers;
+	u32 *spir = &port_regs->CommonRegs.serialPortInterfaceReg;
+
 	qdev->eeprom_cmd_data = AUBURN_EEPROM_CS_0;
-	ql_write_nvram_reg(qdev, &port_regs->CommonRegs.serialPortInterfaceReg,
-			    ISP_NVRAM_MASK | qdev->eeprom_cmd_data);
+	ql_write_nvram_reg(qdev, spir, ISP_NVRAM_MASK | qdev->eeprom_cmd_data);
 }
 
 /*
@@ -496,29 +482,23 @@ static void fm93c56a_datain(struct ql3_adapter *qdev, unsigned short *value)
 	u32 data = 0;
 	u32 dataBit;
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+			qdev->mem_map_registers;
+	u32 *spir = &port_regs->CommonRegs.serialPortInterfaceReg;
 
 	/* Read the data bits */
 	/* The first bit is a dummy.  Clock right over it. */
 	for (i = 0; i < dataBits; i++) {
-		ql_write_nvram_reg(qdev,
-				    &port_regs->CommonRegs.
-				    serialPortInterfaceReg,
-				    ISP_NVRAM_MASK | qdev->eeprom_cmd_data |
-				    AUBURN_EEPROM_CLK_RISE);
-		ql_write_nvram_reg(qdev,
-				    &port_regs->CommonRegs.
-				    serialPortInterfaceReg,
-				    ISP_NVRAM_MASK | qdev->eeprom_cmd_data |
-				    AUBURN_EEPROM_CLK_FALL);
-		dataBit =
-		    (ql_read_common_reg
-		     (qdev,
-		      &port_regs->CommonRegs.
-		      serialPortInterfaceReg) & AUBURN_EEPROM_DI_1) ? 1 : 0;
+		ql_write_nvram_reg(qdev, spir,
+				   ISP_NVRAM_MASK | qdev->eeprom_cmd_data |
+				   AUBURN_EEPROM_CLK_RISE);
+		ql_write_nvram_reg(qdev, spir,
+				   ISP_NVRAM_MASK | qdev->eeprom_cmd_data |
+				   AUBURN_EEPROM_CLK_FALL);
+		dataBit = (ql_read_common_reg(qdev, spir) &
+			   AUBURN_EEPROM_DI_1) ? 1 : 0;
 		data = (data << 1) | dataBit;
 	}
-	*value = (u16) data;
+	*value = (u16)data;
 }
 
 /*
@@ -550,9 +530,9 @@ static int ql_get_nvram_params(struct ql3_adapter *qdev)
 
 	spin_lock_irqsave(&qdev->hw_lock, hw_flags);
 
-	pEEPROMData = (u16 *) & qdev->nvram_data;
+	pEEPROMData = (u16 *)&qdev->nvram_data;
 	qdev->eeprom_cmd_data = 0;
-	if(ql_sem_spinlock(qdev, QL_NVRAM_SEM_MASK,
+	if (ql_sem_spinlock(qdev, QL_NVRAM_SEM_MASK,
 			(QL_RESOURCE_BITS_BASE_CODE | (qdev->mac_index) *
 			 2) << 10)) {
 		pr_err("%s: Failed ql_sem_spinlock()\n", __func__);
@@ -585,7 +565,7 @@ static const u32 PHYAddr[2] = {
 static int ql_wait_for_mii_ready(struct ql3_adapter *qdev)
 {
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+			qdev->mem_map_registers;
 	u32 temp;
 	int count = 1000;
 
@@ -602,7 +582,7 @@ static int ql_wait_for_mii_ready(struct ql3_adapter *qdev)
 static void ql_mii_enable_scan_mode(struct ql3_adapter *qdev)
 {
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+			qdev->mem_map_registers;
 	u32 scanControl;
 
 	if (qdev->numPorts > 1) {
@@ -630,7 +610,7 @@ static u8 ql_mii_disable_scan_mode(struct ql3_adapter *qdev)
 {
 	u8 ret;
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    				qdev->mem_map_registers;
+					qdev->mem_map_registers;
 
 	/* See if scan mode is enabled before we turn it off */
 	if (ql_read_page0_reg(qdev, &port_regs->macMIIMgmtControlReg) &
@@ -660,7 +640,7 @@ static int ql_mii_write_reg_ex(struct ql3_adapter *qdev,
 			       u16 regAddr, u16 value, u32 phyAddr)
 {
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+			qdev->mem_map_registers;
 	u8 scanWasEnabled;
 
 	scanWasEnabled = ql_mii_disable_scan_mode(qdev);
@@ -688,10 +668,10 @@ static int ql_mii_write_reg_ex(struct ql3_adapter *qdev,
 }
 
 static int ql_mii_read_reg_ex(struct ql3_adapter *qdev, u16 regAddr,
-			      u16 * value, u32 phyAddr)
+			      u16 *value, u32 phyAddr)
 {
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+			qdev->mem_map_registers;
 	u8 scanWasEnabled;
 	u32 temp;
 
@@ -729,7 +709,7 @@ static int ql_mii_read_reg_ex(struct ql3_adapter *qdev, u16 regAddr,
 static int ql_mii_write_reg(struct ql3_adapter *qdev, u16 regAddr, u16 value)
 {
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+			qdev->mem_map_registers;
 
 	ql_mii_disable_scan_mode(qdev);
 
@@ -758,7 +738,7 @@ static int ql_mii_read_reg(struct ql3_adapter *qdev, u16 regAddr, u16 *value)
 {
 	u32 temp;
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+			qdev->mem_map_registers;
 
 	ql_mii_disable_scan_mode(qdev);
 
@@ -884,7 +864,8 @@ static void phyAgereSpecificInit(struct ql3_adapter *qdev, u32 miiAddr)
 	/* point to hidden reg 0x2806 */
 	ql_mii_write_reg_ex(qdev, 0x10, 0x2806, miiAddr);
 	/* Write new PHYAD w/bit 5 set */
-	ql_mii_write_reg_ex(qdev, 0x11, 0x0020 | (PHYAddr[qdev->mac_index] >> 8), miiAddr);
+	ql_mii_write_reg_ex(qdev, 0x11,
+			    0x0020 | (PHYAddr[qdev->mac_index] >> 8), miiAddr);
 	/*
 	 * Disable diagnostic mode bit 2 = 0
 	 * Power up device bit 11 = 0
@@ -895,21 +876,19 @@ static void phyAgereSpecificInit(struct ql3_adapter *qdev, u32 miiAddr)
 	ql_mii_write_reg(qdev, 0x1c, 0xfaf0);
 }
 
-static PHY_DEVICE_et getPhyType (struct ql3_adapter *qdev,
-				 u16 phyIdReg0, u16 phyIdReg1)
+static enum PHY_DEVICE_TYPE getPhyType(struct ql3_adapter *qdev,
+				       u16 phyIdReg0, u16 phyIdReg1)
 {
-	PHY_DEVICE_et result = PHY_TYPE_UNKNOWN;
+	enum PHY_DEVICE_TYPE result = PHY_TYPE_UNKNOWN;
 	u32   oui;
 	u16   model;
 	int i;
 
-	if (phyIdReg0 == 0xffff) {
+	if (phyIdReg0 == 0xffff)
 		return result;
-	}
 
-	if (phyIdReg1 == 0xffff) {
+	if (phyIdReg1 == 0xffff)
 		return result;
-	}
 
 	/* oui is split between two registers */
 	oui = (phyIdReg0 << 6) | ((phyIdReg1 & PHY_OUI_1_MASK) >> 10);
@@ -917,15 +896,13 @@ static PHY_DEVICE_et getPhyType (struct ql3_adapter *qdev,
 	model = (phyIdReg1 & PHY_MODEL_MASK) >> 4;
 
 	/* Scan table for this PHY */
-	for(i = 0; i < MAX_PHY_DEV_TYPES; i++) {
+	for (i = 0; i < MAX_PHY_DEV_TYPES; i++) {
 		if ((oui == PHY_DEVICES[i].phyIdOUI) &&
 		    (model == PHY_DEVICES[i].phyIdModel)) {
-			result = PHY_DEVICES[i].phyDevice;
-
 			netdev_info(qdev->ndev, "Phy: %s\n",
 				    PHY_DEVICES[i].name);
-
-		        break;
+			result = PHY_DEVICES[i].phyDevice;
+			break;
 		}
 	}
 
@@ -936,9 +913,8 @@ static int ql_phy_get_speed(struct ql3_adapter *qdev)
 {
 	u16 reg;
 
-	switch(qdev->phyType) {
-	case PHY_AGERE_ET1011C:
-	{
+	switch (qdev->phyType) {
+	case PHY_AGERE_ET1011C: {
 		if (ql_mii_read_reg(qdev, 0x1A, &reg) < 0)
 			return 0;
 
@@ -946,20 +922,20 @@ static int ql_phy_get_speed(struct ql3_adapter *qdev)
 		break;
 	}
 	default:
-	if (ql_mii_read_reg(qdev, AUX_CONTROL_STATUS, &reg) < 0)
-		return 0;
+		if (ql_mii_read_reg(qdev, AUX_CONTROL_STATUS, &reg) < 0)
+			return 0;
 
-	reg = (((reg & 0x18) >> 3) & 3);
+		reg = (((reg & 0x18) >> 3) & 3);
 	}
 
-	switch(reg) {
-		case 2:
+	switch (reg) {
+	case 2:
 		return SPEED_1000;
-		case 1:
+	case 1:
 		return SPEED_100;
-		case 0:
+	case 0:
 		return SPEED_10;
-		default:
+	default:
 		return -1;
 	}
 }
@@ -968,17 +944,15 @@ static int ql_is_full_dup(struct ql3_adapter *qdev)
 {
 	u16 reg;
 
-	switch(qdev->phyType) {
-	case PHY_AGERE_ET1011C:
-	{
+	switch (qdev->phyType) {
+	case PHY_AGERE_ET1011C: {
 		if (ql_mii_read_reg(qdev, 0x1A, &reg))
 			return 0;
 
 		return ((reg & 0x0080) && (reg & 0x1000)) != 0;
 	}
 	case PHY_VITESSE_VSC8211:
-	default:
-	{
+	default: {
 		if (ql_mii_read_reg(qdev, AUX_CONTROL_STATUS, &reg) < 0)
 			return 0;
 		return (reg & PHY_AUX_DUPLEX_STAT) != 0;
@@ -1006,15 +980,15 @@ static int PHY_Setup(struct ql3_adapter *qdev)
 
 	/*  Determine the PHY we are using by reading the ID's */
 	err = ql_mii_read_reg(qdev, PHY_ID_0_REG, &reg1);
-	if(err != 0) {
+	if (err != 0) {
 		netdev_err(qdev->ndev, "Could not read from reg PHY_ID_0_REG\n");
-                return err;
+		return err;
 	}
 
 	err = ql_mii_read_reg(qdev, PHY_ID_1_REG, &reg2);
-	if(err != 0) {
+	if (err != 0) {
 		netdev_err(qdev->ndev, "Could not read from reg PHY_ID_1_REG\n");
-                return err;
+		return err;
 	}
 
 	/*  Check if we have a Agere PHY */
@@ -1022,23 +996,22 @@ static int PHY_Setup(struct ql3_adapter *qdev)
 
 		/* Determine which MII address we should be using
 		   determined by the index of the card */
-		if (qdev->mac_index == 0) {
+		if (qdev->mac_index == 0)
 			miiAddr = MII_AGERE_ADDR_1;
-		} else {
+		else
 			miiAddr = MII_AGERE_ADDR_2;
-		}
 
-		err =ql_mii_read_reg_ex(qdev, PHY_ID_0_REG, &reg1, miiAddr);
-		if(err != 0) {
+		err = ql_mii_read_reg_ex(qdev, PHY_ID_0_REG, &reg1, miiAddr);
+		if (err != 0) {
 			netdev_err(qdev->ndev,
 				   "Could not read from reg PHY_ID_0_REG after Agere detected\n");
 			return err;
 		}
 
 		err = ql_mii_read_reg_ex(qdev, PHY_ID_1_REG, &reg2, miiAddr);
-		if(err != 0) {
+		if (err != 0) {
 			netdev_err(qdev->ndev, "Could not read from reg PHY_ID_1_REG after Agere detected\n");
-        	        return err;
+			return err;
 		}
 
 		/*  We need to remember to initialize the Agere PHY */
@@ -1066,7 +1039,7 @@ static int PHY_Setup(struct ql3_adapter *qdev)
 static void ql_mac_enable(struct ql3_adapter *qdev, u32 enable)
 {
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+			qdev->mem_map_registers;
 	u32 value;
 
 	if (enable)
@@ -1086,7 +1059,7 @@ static void ql_mac_enable(struct ql3_adapter *qdev, u32 enable)
 static void ql_mac_cfg_soft_reset(struct ql3_adapter *qdev, u32 enable)
 {
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+			qdev->mem_map_registers;
 	u32 value;
 
 	if (enable)
@@ -1106,7 +1079,7 @@ static void ql_mac_cfg_soft_reset(struct ql3_adapter *qdev, u32 enable)
 static void ql_mac_cfg_gig(struct ql3_adapter *qdev, u32 enable)
 {
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+			qdev->mem_map_registers;
 	u32 value;
 
 	if (enable)
@@ -1126,7 +1099,7 @@ static void ql_mac_cfg_gig(struct ql3_adapter *qdev, u32 enable)
 static void ql_mac_cfg_full_dup(struct ql3_adapter *qdev, u32 enable)
 {
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+			qdev->mem_map_registers;
 	u32 value;
 
 	if (enable)
@@ -1146,7 +1119,7 @@ static void ql_mac_cfg_full_dup(struct ql3_adapter *qdev, u32 enable)
 static void ql_mac_cfg_pause(struct ql3_adapter *qdev, u32 enable)
 {
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+			qdev->mem_map_registers;
 	u32 value;
 
 	if (enable)
@@ -1168,7 +1141,7 @@ static void ql_mac_cfg_pause(struct ql3_adapter *qdev, u32 enable)
 static int ql_is_fiber(struct ql3_adapter *qdev)
 {
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+			qdev->mem_map_registers;
 	u32 bitToCheck = 0;
 	u32 temp;
 
@@ -1198,7 +1171,7 @@ static int ql_is_auto_cfg(struct ql3_adapter *qdev)
 static int ql_is_auto_neg_complete(struct ql3_adapter *qdev)
 {
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+			qdev->mem_map_registers;
 	u32 bitToCheck = 0;
 	u32 temp;
 
@@ -1234,7 +1207,7 @@ static int ql_is_neg_pause(struct ql3_adapter *qdev)
 static int ql_auto_neg_error(struct ql3_adapter *qdev)
 {
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+			qdev->mem_map_registers;
 	u32 bitToCheck = 0;
 	u32 temp;
 
@@ -1272,7 +1245,7 @@ static int ql_is_link_full_dup(struct ql3_adapter *qdev)
 static int ql_link_down_detect(struct ql3_adapter *qdev)
 {
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+			qdev->mem_map_registers;
 	u32 bitToCheck = 0;
 	u32 temp;
 
@@ -1296,7 +1269,7 @@ static int ql_link_down_detect(struct ql3_adapter *qdev)
 static int ql_link_down_detect_clear(struct ql3_adapter *qdev)
 {
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+			qdev->mem_map_registers;
 
 	switch (qdev->mac_index) {
 	case 0:
@@ -1326,7 +1299,7 @@ static int ql_link_down_detect_clear(struct ql3_adapter *qdev)
 static int ql_this_adapter_controls_port(struct ql3_adapter *qdev)
 {
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+			qdev->mem_map_registers;
 	u32 bitToCheck = 0;
 	u32 temp;
 
@@ -1363,19 +1336,20 @@ static void ql_phy_start_neg_ex(struct ql3_adapter *qdev)
 	u16 reg;
 	u16 portConfiguration;
 
-	if(qdev->phyType == PHY_AGERE_ET1011C) {
-		/* turn off external loopback */
+	if (qdev->phyType == PHY_AGERE_ET1011C)
 		ql_mii_write_reg(qdev, 0x13, 0x0000);
-	}
+					/* turn off external loopback */
 
-	if(qdev->mac_index == 0)
-		portConfiguration = qdev->nvram_data.macCfg_port0.portConfiguration;
+	if (qdev->mac_index == 0)
+		portConfiguration =
+			qdev->nvram_data.macCfg_port0.portConfiguration;
 	else
-		portConfiguration = qdev->nvram_data.macCfg_port1.portConfiguration;
+		portConfiguration =
+			qdev->nvram_data.macCfg_port1.portConfiguration;
 
 	/*  Some HBA's in the field are set to 0 and they need to
 	    be reinterpreted with a default value */
-	if(portConfiguration == 0)
+	if (portConfiguration == 0)
 		portConfiguration = PORT_CONFIG_DEFAULT;
 
 	/* Set the 1000 advertisements */
@@ -1383,8 +1357,8 @@ static void ql_phy_start_neg_ex(struct ql3_adapter *qdev)
 			   PHYAddr[qdev->mac_index]);
 	reg &= ~PHY_GIG_ALL_PARAMS;
 
-	if(portConfiguration & PORT_CONFIG_1000MB_SPEED) {
-		if(portConfiguration & PORT_CONFIG_FULL_DUPLEX_ENABLED)
+	if (portConfiguration & PORT_CONFIG_1000MB_SPEED) {
+		if (portConfiguration & PORT_CONFIG_FULL_DUPLEX_ENABLED)
 			reg |= PHY_GIG_ADV_1000F;
 		else
 			reg |= PHY_GIG_ADV_1000H;
@@ -1398,29 +1372,27 @@ static void ql_phy_start_neg_ex(struct ql3_adapter *qdev)
 			   PHYAddr[qdev->mac_index]);
 	reg &= ~PHY_NEG_ALL_PARAMS;
 
-	if(portConfiguration & PORT_CONFIG_SYM_PAUSE_ENABLED)
+	if (portConfiguration & PORT_CONFIG_SYM_PAUSE_ENABLED)
 		reg |= PHY_NEG_ASY_PAUSE | PHY_NEG_SYM_PAUSE;
 
-	if(portConfiguration & PORT_CONFIG_FULL_DUPLEX_ENABLED) {
-		if(portConfiguration & PORT_CONFIG_100MB_SPEED)
+	if (portConfiguration & PORT_CONFIG_FULL_DUPLEX_ENABLED) {
+		if (portConfiguration & PORT_CONFIG_100MB_SPEED)
 			reg |= PHY_NEG_ADV_100F;
 
-		if(portConfiguration & PORT_CONFIG_10MB_SPEED)
+		if (portConfiguration & PORT_CONFIG_10MB_SPEED)
 			reg |= PHY_NEG_ADV_10F;
 	}
 
-	if(portConfiguration & PORT_CONFIG_HALF_DUPLEX_ENABLED) {
-		if(portConfiguration & PORT_CONFIG_100MB_SPEED)
+	if (portConfiguration & PORT_CONFIG_HALF_DUPLEX_ENABLED) {
+		if (portConfiguration & PORT_CONFIG_100MB_SPEED)
 			reg |= PHY_NEG_ADV_100H;
 
-		if(portConfiguration & PORT_CONFIG_10MB_SPEED)
+		if (portConfiguration & PORT_CONFIG_10MB_SPEED)
 			reg |= PHY_NEG_ADV_10H;
 	}
 
-	if(portConfiguration &
-	   PORT_CONFIG_1000MB_SPEED) {
+	if (portConfiguration & PORT_CONFIG_1000MB_SPEED)
 		reg |= 1;
-	}
 
 	ql_mii_write_reg_ex(qdev, PHY_NEG_ADVER, reg,
 			    PHYAddr[qdev->mac_index]);
@@ -1445,7 +1417,7 @@ static void ql_phy_init_ex(struct ql3_adapter *qdev)
 static u32 ql_get_link_state(struct ql3_adapter *qdev)
 {
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+			qdev->mem_map_registers;
 	u32 bitToCheck = 0;
 	u32 temp, linkState;
 
@@ -1457,18 +1429,19 @@ static u32 ql_get_link_state(struct ql3_adapter *qdev)
 		bitToCheck = PORT_STATUS_UP1;
 		break;
 	}
+
 	temp = ql_read_page0_reg(qdev, &port_regs->portStatus);
-	if (temp & bitToCheck) {
+	if (temp & bitToCheck)
 		linkState = LS_UP;
-	} else {
+	else
 		linkState = LS_DOWN;
-	}
+
 	return linkState;
 }
 
 static int ql_port_start(struct ql3_adapter *qdev)
 {
-	if(ql_sem_spinlock(qdev, QL_PHY_GIO_SEM_MASK,
+	if (ql_sem_spinlock(qdev, QL_PHY_GIO_SEM_MASK,
 		(QL_RESOURCE_BITS_BASE_CODE | (qdev->mac_index) *
 			 2) << 7)) {
 		netdev_err(qdev->ndev, "Could not get hw lock for GIO\n");
@@ -1489,13 +1462,13 @@ static int ql_port_start(struct ql3_adapter *qdev)
 static int ql_finish_auto_neg(struct ql3_adapter *qdev)
 {
 
-	if(ql_sem_spinlock(qdev, QL_PHY_GIO_SEM_MASK,
+	if (ql_sem_spinlock(qdev, QL_PHY_GIO_SEM_MASK,
 		(QL_RESOURCE_BITS_BASE_CODE | (qdev->mac_index) *
 			 2) << 7))
 		return -1;
 
 	if (!ql_auto_neg_error(qdev)) {
-		if (test_bit(QL_LINK_MASTER,&qdev->flags)) {
+		if (test_bit(QL_LINK_MASTER, &qdev->flags)) {
 			/* configure the MAC */
 			netif_printk(qdev, link, KERN_DEBUG, qdev->ndev,
 				     "Configuring link\n");
@@ -1528,7 +1501,7 @@ static int ql_finish_auto_neg(struct ql3_adapter *qdev)
 
 	} else {	/* Remote error detected */
 
-		if (test_bit(QL_LINK_MASTER,&qdev->flags)) {
+		if (test_bit(QL_LINK_MASTER, &qdev->flags)) {
 			netif_printk(qdev, link, KERN_DEBUG, qdev->ndev,
 				     "Remote error detected. Calling ql_port_start()\n");
 			/*
@@ -1536,10 +1509,9 @@ static int ql_finish_auto_neg(struct ql3_adapter *qdev)
 			 * to lock the PHY on it's own.
 			 */
 			ql_sem_unlock(qdev, QL_PHY_GIO_SEM_MASK);
-			if(ql_port_start(qdev))	{/* Restart port */
+			if (ql_port_start(qdev))	/* Restart port */
 				return -1;
-			} else
-				return 0;
+			return 0;
 		}
 	}
 	ql_sem_unlock(qdev, QL_PHY_GIO_SEM_MASK);
@@ -1558,7 +1530,7 @@ static void ql_link_state_machine_work(struct work_struct *work)
 
 	curr_link_state = ql_get_link_state(qdev);
 
-	if (test_bit(QL_RESET_ACTIVE,&qdev->flags)) {
+	if (test_bit(QL_RESET_ACTIVE, &qdev->flags)) {
 		netif_info(qdev, link, qdev->ndev,
 			   "Reset in progress, skip processing link state\n");
 
@@ -1572,9 +1544,8 @@ static void ql_link_state_machine_work(struct work_struct *work)
 
 	switch (qdev->port_link_state) {
 	default:
-		if (test_bit(QL_LINK_MASTER,&qdev->flags)) {
+		if (test_bit(QL_LINK_MASTER, &qdev->flags))
 			ql_port_start(qdev);
-		}
 		qdev->port_link_state = LS_DOWN;
 		/* Fall Through */
 
@@ -1616,9 +1587,9 @@ static void ql_link_state_machine_work(struct work_struct *work)
 static void ql_get_phy_owner(struct ql3_adapter *qdev)
 {
 	if (ql_this_adapter_controls_port(qdev))
-		set_bit(QL_LINK_MASTER,&qdev->flags);
+		set_bit(QL_LINK_MASTER, &qdev->flags);
 	else
-		clear_bit(QL_LINK_MASTER,&qdev->flags);
+		clear_bit(QL_LINK_MASTER, &qdev->flags);
 }
 
 /*
@@ -1628,7 +1599,7 @@ static void ql_init_scan_mode(struct ql3_adapter *qdev)
 {
 	ql_mii_enable_scan_mode(qdev);
 
-	if (test_bit(QL_LINK_OPTICAL,&qdev->flags)) {
+	if (test_bit(QL_LINK_OPTICAL, &qdev->flags)) {
 		if (ql_this_adapter_controls_port(qdev))
 			ql_petbi_init_ex(qdev);
 	} else {
@@ -1638,18 +1609,18 @@ static void ql_init_scan_mode(struct ql3_adapter *qdev)
 }
 
 /*
- * MII_Setup needs to be called before taking the PHY out of reset so that the
- * management interface clock speed can be set properly.  It would be better if
- * we had a way to disable MDC until after the PHY is out of reset, but we
- * don't have that capability.
+ * MII_Setup needs to be called before taking the PHY out of reset
+ * so that the management interface clock speed can be set properly.
+ * It would be better if we had a way to disable MDC until after the
+ * PHY is out of reset, but we don't have that capability.
  */
 static int ql_mii_setup(struct ql3_adapter *qdev)
 {
 	u32 reg;
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+			qdev->mem_map_registers;
 
-	if(ql_sem_spinlock(qdev, QL_PHY_GIO_SEM_MASK,
+	if (ql_sem_spinlock(qdev, QL_PHY_GIO_SEM_MASK,
 			(QL_RESOURCE_BITS_BASE_CODE | (qdev->mac_index) *
 			 2) << 7))
 		return -1;
@@ -1668,24 +1639,24 @@ static int ql_mii_setup(struct ql3_adapter *qdev)
 	return 0;
 }
 
+#define SUPPORTED_OPTICAL_MODES	(SUPPORTED_1000baseT_Full |	\
+				 SUPPORTED_FIBRE |		\
+				 SUPPORTED_Autoneg)
+#define SUPPORTED_TP_MODES	(SUPPORTED_10baseT_Half |	\
+				 SUPPORTED_10baseT_Full |	\
+				 SUPPORTED_100baseT_Half |	\
+				 SUPPORTED_100baseT_Full |	\
+				 SUPPORTED_1000baseT_Half |	\
+				 SUPPORTED_1000baseT_Full |	\
+				 SUPPORTED_Autoneg |		\
+				 SUPPORTED_TP);			\
+
 static u32 ql_supported_modes(struct ql3_adapter *qdev)
 {
-	u32 supported;
-
-	if (test_bit(QL_LINK_OPTICAL,&qdev->flags)) {
-		supported = SUPPORTED_1000baseT_Full | SUPPORTED_FIBRE
-		    | SUPPORTED_Autoneg;
-	} else {
-		supported = SUPPORTED_10baseT_Half
-		    | SUPPORTED_10baseT_Full
-		    | SUPPORTED_100baseT_Half
-		    | SUPPORTED_100baseT_Full
-		    | SUPPORTED_1000baseT_Half
-		    | SUPPORTED_1000baseT_Full
-		    | SUPPORTED_Autoneg | SUPPORTED_TP;
-	}
+	if (test_bit(QL_LINK_OPTICAL, &qdev->flags))
+		return SUPPORTED_OPTICAL_MODES;
 
-	return supported;
+	return SUPPORTED_TP_MODES;
 }
 
 static int ql_get_auto_cfg_status(struct ql3_adapter *qdev)
@@ -1693,9 +1664,9 @@ static int ql_get_auto_cfg_status(struct ql3_adapter *qdev)
 	int status;
 	unsigned long hw_flags;
 	spin_lock_irqsave(&qdev->hw_lock, hw_flags);
-	if(ql_sem_spinlock(qdev, QL_PHY_GIO_SEM_MASK,
-		(QL_RESOURCE_BITS_BASE_CODE | (qdev->mac_index) *
-			 2) << 7)) {
+	if (ql_sem_spinlock(qdev, QL_PHY_GIO_SEM_MASK,
+			    (QL_RESOURCE_BITS_BASE_CODE |
+			     (qdev->mac_index) * 2) << 7)) {
 		spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
 		return 0;
 	}
@@ -1710,9 +1681,9 @@ static u32 ql_get_speed(struct ql3_adapter *qdev)
 	u32 status;
 	unsigned long hw_flags;
 	spin_lock_irqsave(&qdev->hw_lock, hw_flags);
-	if(ql_sem_spinlock(qdev, QL_PHY_GIO_SEM_MASK,
-		(QL_RESOURCE_BITS_BASE_CODE | (qdev->mac_index) *
-			 2) << 7)) {
+	if (ql_sem_spinlock(qdev, QL_PHY_GIO_SEM_MASK,
+			    (QL_RESOURCE_BITS_BASE_CODE |
+			     (qdev->mac_index) * 2) << 7)) {
 		spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
 		return 0;
 	}
@@ -1727,9 +1698,9 @@ static int ql_get_full_dup(struct ql3_adapter *qdev)
 	int status;
 	unsigned long hw_flags;
 	spin_lock_irqsave(&qdev->hw_lock, hw_flags);
-	if(ql_sem_spinlock(qdev, QL_PHY_GIO_SEM_MASK,
-		(QL_RESOURCE_BITS_BASE_CODE | (qdev->mac_index) *
-			 2) << 7)) {
+	if (ql_sem_spinlock(qdev, QL_PHY_GIO_SEM_MASK,
+			    (QL_RESOURCE_BITS_BASE_CODE |
+			     (qdev->mac_index) * 2) << 7)) {
 		spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
 		return 0;
 	}
@@ -1739,7 +1710,6 @@ static int ql_get_full_dup(struct ql3_adapter *qdev)
 	return status;
 }
 
-
 static int ql_get_settings(struct net_device *ndev, struct ethtool_cmd *ecmd)
 {
 	struct ql3_adapter *qdev = netdev_priv(ndev);
@@ -1747,7 +1717,7 @@ static int ql_get_settings(struct net_device *ndev, struct ethtool_cmd *ecmd)
 	ecmd->transceiver = XCVR_INTERNAL;
 	ecmd->supported = ql_supported_modes(qdev);
 
-	if (test_bit(QL_LINK_OPTICAL,&qdev->flags)) {
+	if (test_bit(QL_LINK_OPTICAL, &qdev->flags)) {
 		ecmd->port = PORT_FIBRE;
 	} else {
 		ecmd->port = PORT_TP;
@@ -1788,10 +1758,11 @@ static void ql_get_pauseparam(struct net_device *ndev,
 			      struct ethtool_pauseparam *pause)
 {
 	struct ql3_adapter *qdev = netdev_priv(ndev);
-	struct ql3xxx_port_registers __iomem *port_regs = qdev->mem_map_registers;
+	struct ql3xxx_port_registers __iomem *port_regs =
+		qdev->mem_map_registers;
 
 	u32 reg;
-	if(qdev->mac_index == 0)
+	if (qdev->mac_index == 0)
 		reg = ql_read_page0_reg(qdev, &port_regs->mac0ConfigReg);
 	else
 		reg = ql_read_page0_reg(qdev, &port_regs->mac1ConfigReg);
@@ -1818,8 +1789,9 @@ static int ql_populate_free_queue(struct ql3_adapter *qdev)
 
 	while (lrg_buf_cb) {
 		if (!lrg_buf_cb->skb) {
-			lrg_buf_cb->skb = netdev_alloc_skb(qdev->ndev,
-							   qdev->lrg_buffer_len);
+			lrg_buf_cb->skb =
+				netdev_alloc_skb(qdev->ndev,
+						 qdev->lrg_buffer_len);
 			if (unlikely(!lrg_buf_cb->skb)) {
 				netdev_printk(KERN_DEBUG, qdev->ndev,
 					      "Failed netdev_alloc_skb()\n");
@@ -1837,7 +1809,7 @@ static int ql_populate_free_queue(struct ql3_adapter *qdev)
 						     PCI_DMA_FROMDEVICE);
 
 				err = pci_dma_mapping_error(qdev->pdev, map);
-				if(err) {
+				if (err) {
 					netdev_err(qdev->ndev,
 						   "PCI mapping failed with error: %d\n",
 						   err);
@@ -1848,9 +1820,9 @@ static int ql_populate_free_queue(struct ql3_adapter *qdev)
 
 
 				lrg_buf_cb->buf_phy_addr_low =
-				    cpu_to_le32(LS_64BITS(map));
+					cpu_to_le32(LS_64BITS(map));
 				lrg_buf_cb->buf_phy_addr_high =
-				    cpu_to_le32(MS_64BITS(map));
+					cpu_to_le32(MS_64BITS(map));
 				dma_unmap_addr_set(lrg_buf_cb, mapaddr, map);
 				dma_unmap_len_set(lrg_buf_cb, maplen,
 						  qdev->lrg_buffer_len -
@@ -1870,7 +1842,9 @@ static int ql_populate_free_queue(struct ql3_adapter *qdev)
  */
 static void ql_update_small_bufq_prod_index(struct ql3_adapter *qdev)
 {
-	struct ql3xxx_port_registers __iomem *port_regs = qdev->mem_map_registers;
+	struct ql3xxx_port_registers __iomem *port_regs =
+		qdev->mem_map_registers;
+
 	if (qdev->small_buf_release_cnt >= 16) {
 		while (qdev->small_buf_release_cnt >= 16) {
 			qdev->small_buf_q_producer_index++;
@@ -1894,7 +1868,8 @@ static void ql_update_lrg_bufq_prod_index(struct ql3_adapter *qdev)
 	struct bufq_addr_element *lrg_buf_q_ele;
 	int i;
 	struct ql_rcv_buf_cb *lrg_buf_cb;
-	struct ql3xxx_port_registers __iomem *port_regs = qdev->mem_map_registers;
+	struct ql3xxx_port_registers __iomem *port_regs =
+		qdev->mem_map_registers;
 
 	if ((qdev->lrg_buf_free_count >= 8) &&
 	    (qdev->lrg_buf_release_cnt >= 16)) {
@@ -1922,7 +1897,8 @@ static void ql_update_lrg_bufq_prod_index(struct ql3_adapter *qdev)
 
 			qdev->lrg_buf_q_producer_index++;
 
-			if (qdev->lrg_buf_q_producer_index == qdev->num_lbufq_entries)
+			if (qdev->lrg_buf_q_producer_index ==
+			    qdev->num_lbufq_entries)
 				qdev->lrg_buf_q_producer_index = 0;
 
 			if (qdev->lrg_buf_q_producer_index ==
@@ -1944,7 +1920,7 @@ static void ql_process_mac_tx_intr(struct ql3_adapter *qdev,
 	int i;
 	int retval = 0;
 
-	if(mac_rsp->flags & OB_MAC_IOCB_RSP_S) {
+	if (mac_rsp->flags & OB_MAC_IOCB_RSP_S) {
 		netdev_warn(qdev->ndev,
 			    "Frame too short but it was padded and sent\n");
 	}
@@ -1952,7 +1928,7 @@ static void ql_process_mac_tx_intr(struct ql3_adapter *qdev,
 	tx_cb = &qdev->tx_buf[mac_rsp->transaction_id];
 
 	/*  Check the transmit response flags for any errors */
-	if(mac_rsp->flags & OB_MAC_IOCB_RSP_S) {
+	if (mac_rsp->flags & OB_MAC_IOCB_RSP_S) {
 		netdev_err(qdev->ndev,
 			   "Frame too short to be legal, frame not sent\n");
 
@@ -1961,7 +1937,7 @@ static void ql_process_mac_tx_intr(struct ql3_adapter *qdev,
 		goto frame_not_sent;
 	}
 
-	if(tx_cb->seg_count == 0) {
+	if (tx_cb->seg_count == 0) {
 		netdev_err(qdev->ndev, "tx_cb->seg_count == 0: %d\n",
 			   mac_rsp->transaction_id);
 
@@ -2009,7 +1985,7 @@ static struct ql_rcv_buf_cb *ql_get_lbuf(struct ql3_adapter *qdev)
 	qdev->lrg_buf_release_cnt++;
 	if (++qdev->lrg_buf_index == qdev->num_large_buffers)
 		qdev->lrg_buf_index = 0;
-	return(lrg_buf_cb);
+	return lrg_buf_cb;
 }
 
 /*
@@ -2150,8 +2126,8 @@ static int ql_tx_rx_clean(struct ql3_adapter *qdev,
 		net_rsp = qdev->rsp_current;
 		rmb();
 		/*
-		 * Fix 4032 chipe undocumented "feature" where bit-8 is set if the
-		 * inbound completion is for a VLAN.
+		 * Fix 4032 chip's undocumented "feature" where bit-8 is set
+		 * if the inbound completion is for a VLAN.
 		 */
 		if (qdev->device_id == QL3032_DEVICE_ID)
 			net_rsp->opcode &= 0x7f;
@@ -2177,19 +2153,18 @@ static int ql_tx_rx_clean(struct ql3_adapter *qdev,
 						 net_rsp);
 			(*rx_cleaned)++;
 			break;
-		default:
-			{
-				u32 *tmp = (u32 *) net_rsp;
-				netdev_err(ndev,
-					   "Hit default case, not handled!\n"
-					   "	dropping the packet, opcode = %x\n"
-					   "0x%08lx 0x%08lx 0x%08lx 0x%08lx\n",
-					   net_rsp->opcode,
-					   (unsigned long int)tmp[0],
-					   (unsigned long int)tmp[1],
-					   (unsigned long int)tmp[2],
-					   (unsigned long int)tmp[3]);
-			}
+		default: {
+			u32 *tmp = (u32 *)net_rsp;
+			netdev_err(ndev,
+				   "Hit default case, not handled!\n"
+				   "	dropping the packet, opcode = %x\n"
+				   "0x%08lx 0x%08lx 0x%08lx 0x%08lx\n",
+				   net_rsp->opcode,
+				   (unsigned long int)tmp[0],
+				   (unsigned long int)tmp[1],
+				   (unsigned long int)tmp[2],
+				   (unsigned long int)tmp[3]);
+		}
 		}
 
 		qdev->rsp_consumer_index++;
@@ -2212,7 +2187,8 @@ static int ql_poll(struct napi_struct *napi, int budget)
 	struct ql3_adapter *qdev = container_of(napi, struct ql3_adapter, napi);
 	int rx_cleaned = 0, tx_cleaned = 0;
 	unsigned long hw_flags;
-	struct ql3xxx_port_registers __iomem *port_regs = qdev->mem_map_registers;
+	struct ql3xxx_port_registers __iomem *port_regs =
+		qdev->mem_map_registers;
 
 	ql_tx_rx_clean(qdev, &tx_cleaned, &rx_cleaned, budget);
 
@@ -2235,15 +2211,14 @@ static irqreturn_t ql3xxx_isr(int irq, void *dev_id)
 
 	struct net_device *ndev = dev_id;
 	struct ql3_adapter *qdev = netdev_priv(ndev);
-	struct ql3xxx_port_registers __iomem *port_regs = qdev->mem_map_registers;
+	struct ql3xxx_port_registers __iomem *port_regs =
+		qdev->mem_map_registers;
 	u32 value;
 	int handled = 1;
 	u32 var;
 
-	port_regs = qdev->mem_map_registers;
-
-	value =
-	    ql_read_common_reg_l(qdev, &port_regs->CommonRegs.ispControlStatus);
+	value = ql_read_common_reg_l(qdev,
+				     &port_regs->CommonRegs.ispControlStatus);
 
 	if (value & (ISP_CONTROL_FE | ISP_CONTROL_RI)) {
 		spin_lock(&qdev->adapter_lock);
@@ -2251,7 +2226,7 @@ static irqreturn_t ql3xxx_isr(int irq, void *dev_id)
 		netif_carrier_off(qdev->ndev);
 		ql_disable_interrupts(qdev);
 		qdev->port_link_state = LS_DOWN;
-		set_bit(QL_RESET_ACTIVE,&qdev->flags) ;
+		set_bit(QL_RESET_ACTIVE, &qdev->flags) ;
 
 		if (value & ISP_CONTROL_FE) {
 			/*
@@ -2263,12 +2238,12 @@ static irqreturn_t ql3xxx_isr(int irq, void *dev_id)
 			netdev_warn(ndev,
 				    "Resetting chip. PortFatalErrStatus register = 0x%x\n",
 				    var);
-			set_bit(QL_RESET_START,&qdev->flags) ;
+			set_bit(QL_RESET_START, &qdev->flags) ;
 		} else {
 			/*
 			 * Soft Reset Requested.
 			 */
-			set_bit(QL_RESET_PER_SCSI,&qdev->flags) ;
+			set_bit(QL_RESET_PER_SCSI, &qdev->flags) ;
 			netdev_err(ndev,
 				   "Another function issued a reset to the chip. ISR value = %x\n",
 				   value);
@@ -2277,52 +2252,36 @@ static irqreturn_t ql3xxx_isr(int irq, void *dev_id)
 		spin_unlock(&qdev->adapter_lock);
 	} else if (value & ISP_IMR_DISABLE_CMPL_INT) {
 		ql_disable_interrupts(qdev);
-		if (likely(napi_schedule_prep(&qdev->napi))) {
+		if (likely(napi_schedule_prep(&qdev->napi)))
 			__napi_schedule(&qdev->napi);
-		}
-	} else {
+	} else
 		return IRQ_NONE;
-	}
 
 	return IRQ_RETVAL(handled);
 }
 
 /*
- * Get the total number of segments needed for the
- * given number of fragments.  This is necessary because
- * outbound address lists (OAL) will be used when more than
- * two frags are given.  Each address list has 5 addr/len
- * pairs.  The 5th pair in each AOL is used to  point to
- * the next AOL if more frags are coming.
- * That is why the frags:segment count  ratio is not linear.
+ * Get the total number of segments needed for the given number of fragments.
+ * This is necessary because outbound address lists (OAL) will be used when
+ * more than two frags are given.  Each address list has 5 addr/len pairs.
+ * The 5th pair in each OAL is used to  point to the next OAL if more frags
+ * are coming.  That is why the frags:segment count ratio is not linear.
  */
-static int ql_get_seg_count(struct ql3_adapter *qdev,
-			    unsigned short frags)
+static int ql_get_seg_count(struct ql3_adapter *qdev, unsigned short frags)
 {
 	if (qdev->device_id == QL3022_DEVICE_ID)
 		return 1;
 
-	switch(frags) {
-	case 0:	return 1;	/* just the skb->data seg */
-	case 1:	return 2;	/* skb->data + 1 frag */
-	case 2:	return 3;	/* skb->data + 2 frags */
-	case 3:	return 5;	/* skb->data + 1 frag + 1 AOL containting 2 frags */
-	case 4:	return 6;
-	case 5:	return 7;
-	case 6:	return 8;
-	case 7:	return 10;
-	case 8:	return 11;
-	case 9:	return 12;
-	case 10: return 13;
-	case 11: return 15;
-	case 12: return 16;
-	case 13: return 17;
-	case 14: return 18;
-	case 15: return 20;
-	case 16: return 21;
-	case 17: return 22;
-	case 18: return 23;
-	}
+	if (frags <= 2)
+		return frags + 1;
+	else if (frags <= 6)
+		return frags + 2;
+	else if (frags <= 10)
+		return frags + 3;
+	else if (frags <= 14)
+		return frags + 4;
+	else if (frags <= 18)
+		return frags + 5;
 	return -1;
 }
 
@@ -2345,8 +2304,8 @@ static void ql_hw_csum_setup(const struct sk_buff *skb,
 }
 
 /*
- * Map the buffers for this transmit.  This will return
- * NETDEV_TX_BUSY or NETDEV_TX_OK based on success.
+ * Map the buffers for this transmit.
+ * This will return NETDEV_TX_BUSY or NETDEV_TX_OK based on success.
  */
 static int ql_send_map(struct ql3_adapter *qdev,
 				struct ob_mac_iocb_req *mac_iocb_ptr,
@@ -2369,7 +2328,7 @@ static int ql_send_map(struct ql3_adapter *qdev,
 	map = pci_map_single(qdev->pdev, skb->data, len, PCI_DMA_TODEVICE);
 
 	err = pci_dma_mapping_error(qdev->pdev, map);
-	if(err) {
+	if (err) {
 		netdev_err(qdev->ndev, "PCI mapping failed with error: %d\n",
 			   err);
 
@@ -2387,67 +2346,67 @@ static int ql_send_map(struct ql3_adapter *qdev,
 	if (seg_cnt == 1) {
 		/* Terminate the last segment. */
 		oal_entry->len |= cpu_to_le32(OAL_LAST_ENTRY);
-	} else {
-		oal = tx_cb->oal;
-		for (completed_segs=0; completed_segs<frag_cnt; completed_segs++,seg++) {
-			skb_frag_t *frag = &skb_shinfo(skb)->frags[completed_segs];
-			oal_entry++;
-			if ((seg == 2 && seg_cnt > 3) ||	/* Check for continuation */
-			    (seg == 7 && seg_cnt > 8) ||	/* requirements. It's strange */
-			    (seg == 12 && seg_cnt > 13) ||	/* but necessary. */
-			    (seg == 17 && seg_cnt > 18)) {
-				/* Continuation entry points to outbound address list. */
-				map = pci_map_single(qdev->pdev, oal,
-						     sizeof(struct oal),
-						     PCI_DMA_TODEVICE);
-
-				err = pci_dma_mapping_error(qdev->pdev, map);
-				if(err) {
-
-					netdev_err(qdev->ndev,
-						   "PCI mapping outbound address list with error: %d\n",
-						   err);
-					goto map_error;
-				}
-
-				oal_entry->dma_lo = cpu_to_le32(LS_64BITS(map));
-				oal_entry->dma_hi = cpu_to_le32(MS_64BITS(map));
-				oal_entry->len =
-				    cpu_to_le32(sizeof(struct oal) |
-						OAL_CONT_ENTRY);
-				dma_unmap_addr_set(&tx_cb->map[seg], mapaddr,
-						   map);
-				dma_unmap_len_set(&tx_cb->map[seg], maplen,
-						  sizeof(struct oal));
-				oal_entry = (struct oal_entry *)oal;
-				oal++;
-				seg++;
-			}
-
-			map =
-			    pci_map_page(qdev->pdev, frag->page,
-					 frag->page_offset, frag->size,
-					 PCI_DMA_TODEVICE);
+		return NETDEV_TX_OK;
+	}
+	oal = tx_cb->oal;
+	for (completed_segs = 0;
+	     completed_segs < frag_cnt;
+	     completed_segs++, seg++) {
+		skb_frag_t *frag = &skb_shinfo(skb)->frags[completed_segs];
+		oal_entry++;
+		/*
+		 * Check for continuation requirements.
+		 * It's strange but necessary.
+		 * Continuation entry points to outbound address list.
+		 */
+		if ((seg == 2 && seg_cnt > 3) ||
+		    (seg == 7 && seg_cnt > 8) ||
+		    (seg == 12 && seg_cnt > 13) ||
+		    (seg == 17 && seg_cnt > 18)) {
+			map = pci_map_single(qdev->pdev, oal,
+					     sizeof(struct oal),
+					     PCI_DMA_TODEVICE);
 
 			err = pci_dma_mapping_error(qdev->pdev, map);
-			if(err) {
+			if (err) {
 				netdev_err(qdev->ndev,
-					   "PCI mapping frags failed with error: %d\n",
+					   "PCI mapping outbound address list with error: %d\n",
 					   err);
 				goto map_error;
 			}
 
 			oal_entry->dma_lo = cpu_to_le32(LS_64BITS(map));
 			oal_entry->dma_hi = cpu_to_le32(MS_64BITS(map));
-			oal_entry->len = cpu_to_le32(frag->size);
+			oal_entry->len = cpu_to_le32(sizeof(struct oal) |
+						     OAL_CONT_ENTRY);
 			dma_unmap_addr_set(&tx_cb->map[seg], mapaddr, map);
 			dma_unmap_len_set(&tx_cb->map[seg], maplen,
-					  frag->size);
+					  sizeof(struct oal));
+			oal_entry = (struct oal_entry *)oal;
+			oal++;
+			seg++;
 		}
-		/* Terminate the last segment. */
-		oal_entry->len |= cpu_to_le32(OAL_LAST_ENTRY);
-	}
 
+		map = pci_map_page(qdev->pdev, frag->page,
+				   frag->page_offset, frag->size,
+				   PCI_DMA_TODEVICE);
+
+		err = pci_dma_mapping_error(qdev->pdev, map);
+		if (err) {
+			netdev_err(qdev->ndev,
+				   "PCI mapping frags failed with error: %d\n",
+				   err);
+			goto map_error;
+		}
+
+		oal_entry->dma_lo = cpu_to_le32(LS_64BITS(map));
+		oal_entry->dma_hi = cpu_to_le32(MS_64BITS(map));
+		oal_entry->len = cpu_to_le32(frag->size);
+		dma_unmap_addr_set(&tx_cb->map[seg], mapaddr, map);
+		dma_unmap_len_set(&tx_cb->map[seg], maplen, frag->size);
+		}
+	/* Terminate the last segment. */
+	oal_entry->len |= cpu_to_le32(OAL_LAST_ENTRY);
 	return NETDEV_TX_OK;
 
 map_error:
@@ -2459,13 +2418,18 @@ map_error:
 	seg = 1;
 	oal_entry = (struct oal_entry *)&mac_iocb_ptr->buf_addr0_low;
 	oal = tx_cb->oal;
-	for (i=0; i<completed_segs; i++,seg++) {
+	for (i = 0; i < completed_segs; i++, seg++) {
 		oal_entry++;
 
-		if((seg == 2 && seg_cnt > 3) ||        /* Check for continuation */
-		   (seg == 7 && seg_cnt > 8) ||        /* requirements. It's strange */
-		   (seg == 12 && seg_cnt > 13) ||      /* but necessary. */
-		   (seg == 17 && seg_cnt > 18)) {
+		/*
+		 * Check for continuation requirements.
+		 * It's strange but necessary.
+		 */
+
+		if ((seg == 2 && seg_cnt > 3) ||
+		    (seg == 7 && seg_cnt > 8) ||
+		    (seg == 12 && seg_cnt > 13) ||
+		    (seg == 17 && seg_cnt > 18)) {
 			pci_unmap_single(qdev->pdev,
 				dma_unmap_addr(&tx_cb->map[seg], mapaddr),
 				dma_unmap_len(&tx_cb->map[seg], maplen),
@@ -2504,18 +2468,19 @@ static netdev_tx_t ql3xxx_send(struct sk_buff *skb,
 			       struct net_device *ndev)
 {
 	struct ql3_adapter *qdev = (struct ql3_adapter *)netdev_priv(ndev);
-	struct ql3xxx_port_registers __iomem *port_regs = qdev->mem_map_registers;
+	struct ql3xxx_port_registers __iomem *port_regs =
+			qdev->mem_map_registers;
 	struct ql_tx_buf_cb *tx_cb;
 	u32 tot_len = skb->len;
 	struct ob_mac_iocb_req *mac_iocb_ptr;
 
-	if (unlikely(atomic_read(&qdev->tx_count) < 2)) {
+	if (unlikely(atomic_read(&qdev->tx_count) < 2))
 		return NETDEV_TX_BUSY;
-	}
 
-	tx_cb = &qdev->tx_buf[qdev->req_producer_index] ;
-	if((tx_cb->seg_count = ql_get_seg_count(qdev,
-						(skb_shinfo(skb)->nr_frags))) == -1) {
+	tx_cb = &qdev->tx_buf[qdev->req_producer_index];
+	tx_cb->seg_count = ql_get_seg_count(qdev,
+					     skb_shinfo(skb)->nr_frags);
+	if (tx_cb->seg_count == -1) {
 		netdev_err(ndev, "%s: invalid segment count!\n", __func__);
 		return NETDEV_TX_OK;
 	}
@@ -2532,7 +2497,7 @@ static netdev_tx_t ql3xxx_send(struct sk_buff *skb,
 	    skb->ip_summed == CHECKSUM_PARTIAL)
 		ql_hw_csum_setup(skb, mac_iocb_ptr);
 
-	if(ql_send_map(qdev,mac_iocb_ptr,tx_cb,skb) != NETDEV_TX_OK) {
+	if (ql_send_map(qdev, mac_iocb_ptr, tx_cb, skb) != NETDEV_TX_OK) {
 		netdev_err(ndev, "%s: Could not map the segments!\n", __func__);
 		return NETDEV_TX_BUSY;
 	}
@@ -2586,14 +2551,14 @@ static int ql_alloc_net_req_rsp_queues(struct ql3_adapter *qdev)
 		return -ENOMEM;
 	}
 
-	set_bit(QL_ALLOC_REQ_RSP_Q_DONE,&qdev->flags);
+	set_bit(QL_ALLOC_REQ_RSP_Q_DONE, &qdev->flags);
 
 	return 0;
 }
 
 static void ql_free_net_req_rsp_queues(struct ql3_adapter *qdev)
 {
-	if (!test_bit(QL_ALLOC_REQ_RSP_Q_DONE,&qdev->flags)) {
+	if (!test_bit(QL_ALLOC_REQ_RSP_Q_DONE, &qdev->flags)) {
 		netdev_info(qdev->ndev, "Already done\n");
 		return;
 	}
@@ -2610,29 +2575,31 @@ static void ql_free_net_req_rsp_queues(struct ql3_adapter *qdev)
 
 	qdev->rsp_q_virt_addr = NULL;
 
-	clear_bit(QL_ALLOC_REQ_RSP_Q_DONE,&qdev->flags);
+	clear_bit(QL_ALLOC_REQ_RSP_Q_DONE, &qdev->flags);
 }
 
 static int ql_alloc_buffer_queues(struct ql3_adapter *qdev)
 {
 	/* Create Large Buffer Queue */
 	qdev->lrg_buf_q_size =
-	    qdev->num_lbufq_entries * sizeof(struct lrg_buf_q_entry);
+		qdev->num_lbufq_entries * sizeof(struct lrg_buf_q_entry);
 	if (qdev->lrg_buf_q_size < PAGE_SIZE)
 		qdev->lrg_buf_q_alloc_size = PAGE_SIZE;
 	else
 		qdev->lrg_buf_q_alloc_size = qdev->lrg_buf_q_size * 2;
 
-	qdev->lrg_buf = kmalloc(qdev->num_large_buffers * sizeof(struct ql_rcv_buf_cb),GFP_KERNEL);
+	qdev->lrg_buf =
+		kmalloc(qdev->num_large_buffers * sizeof(struct ql_rcv_buf_cb),
+			GFP_KERNEL);
 	if (qdev->lrg_buf == NULL) {
 		netdev_err(qdev->ndev, "qdev->lrg_buf alloc failed\n");
 		return -ENOMEM;
 	}
 
 	qdev->lrg_buf_q_alloc_virt_addr =
-	    pci_alloc_consistent(qdev->pdev,
-				 qdev->lrg_buf_q_alloc_size,
-				 &qdev->lrg_buf_q_alloc_phy_addr);
+		pci_alloc_consistent(qdev->pdev,
+				     qdev->lrg_buf_q_alloc_size,
+				     &qdev->lrg_buf_q_alloc_phy_addr);
 
 	if (qdev->lrg_buf_q_alloc_virt_addr == NULL) {
 		netdev_err(qdev->ndev, "lBufQ failed\n");
@@ -2643,16 +2610,16 @@ static int ql_alloc_buffer_queues(struct ql3_adapter *qdev)
 
 	/* Create Small Buffer Queue */
 	qdev->small_buf_q_size =
-	    NUM_SBUFQ_ENTRIES * sizeof(struct lrg_buf_q_entry);
+		NUM_SBUFQ_ENTRIES * sizeof(struct lrg_buf_q_entry);
 	if (qdev->small_buf_q_size < PAGE_SIZE)
 		qdev->small_buf_q_alloc_size = PAGE_SIZE;
 	else
 		qdev->small_buf_q_alloc_size = qdev->small_buf_q_size * 2;
 
 	qdev->small_buf_q_alloc_virt_addr =
-	    pci_alloc_consistent(qdev->pdev,
-				 qdev->small_buf_q_alloc_size,
-				 &qdev->small_buf_q_alloc_phy_addr);
+		pci_alloc_consistent(qdev->pdev,
+				     qdev->small_buf_q_alloc_size,
+				     &qdev->small_buf_q_alloc_phy_addr);
 
 	if (qdev->small_buf_q_alloc_virt_addr == NULL) {
 		netdev_err(qdev->ndev, "Small Buffer Queue allocation failed\n");
@@ -2664,17 +2631,17 @@ static int ql_alloc_buffer_queues(struct ql3_adapter *qdev)
 
 	qdev->small_buf_q_virt_addr = qdev->small_buf_q_alloc_virt_addr;
 	qdev->small_buf_q_phy_addr = qdev->small_buf_q_alloc_phy_addr;
-	set_bit(QL_ALLOC_BUFQS_DONE,&qdev->flags);
+	set_bit(QL_ALLOC_BUFQS_DONE, &qdev->flags);
 	return 0;
 }
 
 static void ql_free_buffer_queues(struct ql3_adapter *qdev)
 {
-	if (!test_bit(QL_ALLOC_BUFQS_DONE,&qdev->flags)) {
+	if (!test_bit(QL_ALLOC_BUFQS_DONE, &qdev->flags)) {
 		netdev_info(qdev->ndev, "Already done\n");
 		return;
 	}
-	if(qdev->lrg_buf) kfree(qdev->lrg_buf);
+	kfree(qdev->lrg_buf);
 	pci_free_consistent(qdev->pdev,
 			    qdev->lrg_buf_q_alloc_size,
 			    qdev->lrg_buf_q_alloc_virt_addr,
@@ -2689,7 +2656,7 @@ static void ql_free_buffer_queues(struct ql3_adapter *qdev)
 
 	qdev->small_buf_q_virt_addr = NULL;
 
-	clear_bit(QL_ALLOC_BUFQS_DONE,&qdev->flags);
+	clear_bit(QL_ALLOC_BUFQS_DONE, &qdev->flags);
 }
 
 static int ql_alloc_small_buffers(struct ql3_adapter *qdev)
@@ -2699,13 +2666,13 @@ static int ql_alloc_small_buffers(struct ql3_adapter *qdev)
 
 	/* Currently we allocate on one of memory and use it for smallbuffers */
 	qdev->small_buf_total_size =
-	    (QL_ADDR_ELE_PER_BUFQ_ENTRY * NUM_SBUFQ_ENTRIES *
-	     QL_SMALL_BUFFER_SIZE);
+		(QL_ADDR_ELE_PER_BUFQ_ENTRY * NUM_SBUFQ_ENTRIES *
+		 QL_SMALL_BUFFER_SIZE);
 
 	qdev->small_buf_virt_addr =
-	    pci_alloc_consistent(qdev->pdev,
-				 qdev->small_buf_total_size,
-				 &qdev->small_buf_phy_addr);
+		pci_alloc_consistent(qdev->pdev,
+				     qdev->small_buf_total_size,
+				     &qdev->small_buf_phy_addr);
 
 	if (qdev->small_buf_virt_addr == NULL) {
 		netdev_err(qdev->ndev, "Failed to get small buffer memory\n");
@@ -2727,13 +2694,13 @@ static int ql_alloc_small_buffers(struct ql3_adapter *qdev)
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
+	if (!test_bit(QL_ALLOC_SMALL_BUF_DONE, &qdev->flags)) {
 		netdev_info(qdev->ndev, "Already done\n");
 		return;
 	}
@@ -2819,7 +2786,7 @@ static int ql_alloc_large_buffers(struct ql3_adapter *qdev)
 					     PCI_DMA_FROMDEVICE);
 
 			err = pci_dma_mapping_error(qdev->pdev, map);
-			if(err) {
+			if (err) {
 				netdev_err(qdev->ndev,
 					   "PCI mapping failed with error: %d\n",
 					   err);
@@ -2847,10 +2814,8 @@ static void ql_free_send_free_list(struct ql3_adapter *qdev)
 
 	tx_cb = &qdev->tx_buf[0];
 	for (i = 0; i < NUM_REQ_Q_ENTRIES; i++) {
-		if (tx_cb->oal) {
-			kfree(tx_cb->oal);
-			tx_cb->oal = NULL;
-		}
+		kfree(tx_cb->oal);
+		tx_cb->oal = NULL;
 		tx_cb++;
 	}
 }
@@ -2859,8 +2824,7 @@ static int ql_create_send_free_list(struct ql3_adapter *qdev)
 {
 	struct ql_tx_buf_cb *tx_cb;
 	int i;
-	struct ob_mac_iocb_req *req_q_curr =
-					qdev->req_q_virt_addr;
+	struct ob_mac_iocb_req *req_q_curr = qdev->req_q_virt_addr;
 
 	/* Create free list of transmit buffers */
 	for (i = 0; i < NUM_REQ_Q_ENTRIES; i++) {
@@ -2881,8 +2845,7 @@ static int ql_alloc_mem_resources(struct ql3_adapter *qdev)
 	if (qdev->ndev->mtu == NORMAL_MTU_SIZE) {
 		qdev->num_lbufq_entries = NUM_LBUFQ_ENTRIES;
 		qdev->lrg_buffer_len = NORMAL_MTU_SIZE;
-	}
-	else if (qdev->ndev->mtu == JUMBO_MTU_SIZE) {
+	} else if (qdev->ndev->mtu == JUMBO_MTU_SIZE) {
 		/*
 		 * Bigger buffers, so less of them.
 		 */
@@ -2893,10 +2856,11 @@ static int ql_alloc_mem_resources(struct ql3_adapter *qdev)
 			   qdev->ndev->mtu, NORMAL_MTU_SIZE, JUMBO_MTU_SIZE);
 		return -ENOMEM;
 	}
-	qdev->num_large_buffers = qdev->num_lbufq_entries * QL_ADDR_ELE_PER_BUFQ_ENTRY;
+	qdev->num_large_buffers =
+		qdev->num_lbufq_entries * QL_ADDR_ELE_PER_BUFQ_ENTRY;
 	qdev->lrg_buffer_len += VLAN_ETH_HLEN + VLAN_ID_LEN + QL_HEADER_SPACE;
 	qdev->max_frame_size =
-	    (qdev->lrg_buffer_len - QL_HEADER_SPACE) + ETHERNET_CRC_SIZE;
+		(qdev->lrg_buffer_len - QL_HEADER_SPACE) + ETHERNET_CRC_SIZE;
 
 	/*
 	 * First allocate a page of shared memory and use it for shadow
@@ -2904,22 +2868,22 @@ static int ql_alloc_mem_resources(struct ql3_adapter *qdev)
 	 * Network Completion Queue Producer Index Register
 	 */
 	qdev->shadow_reg_virt_addr =
-	    pci_alloc_consistent(qdev->pdev,
-				 PAGE_SIZE, &qdev->shadow_reg_phy_addr);
+		pci_alloc_consistent(qdev->pdev,
+				     PAGE_SIZE, &qdev->shadow_reg_phy_addr);
 
 	if (qdev->shadow_reg_virt_addr != NULL) {
 		qdev->preq_consumer_index = (u16 *) qdev->shadow_reg_virt_addr;
 		qdev->req_consumer_index_phy_addr_high =
-		    MS_64BITS(qdev->shadow_reg_phy_addr);
+			MS_64BITS(qdev->shadow_reg_phy_addr);
 		qdev->req_consumer_index_phy_addr_low =
-		    LS_64BITS(qdev->shadow_reg_phy_addr);
+			LS_64BITS(qdev->shadow_reg_phy_addr);
 
 		qdev->prsp_producer_index =
-		    (__le32 *) (((u8 *) qdev->preq_consumer_index) + 8);
+			(__le32 *) (((u8 *) qdev->preq_consumer_index) + 8);
 		qdev->rsp_producer_index_phy_addr_high =
-		    qdev->req_consumer_index_phy_addr_high;
+			qdev->req_consumer_index_phy_addr_high;
 		qdev->rsp_producer_index_phy_addr_low =
-		    qdev->req_consumer_index_phy_addr_low + 8;
+			qdev->req_consumer_index_phy_addr_low + 8;
 	} else {
 		netdev_err(qdev->ndev, "shadowReg Alloc failed\n");
 		return -ENOMEM;
@@ -2989,7 +2953,7 @@ static int ql_init_misc_registers(struct ql3_adapter *qdev)
 	struct ql3xxx_local_ram_registers __iomem *local_ram =
 	    (void __iomem *)qdev->mem_map_registers;
 
-	if(ql_sem_spinlock(qdev, QL_DDR_RAM_SEM_MASK,
+	if (ql_sem_spinlock(qdev, QL_DDR_RAM_SEM_MASK,
 			(QL_RESOURCE_BITS_BASE_CODE | (qdev->mac_index) *
 			 2) << 4))
 		return -1;
@@ -3045,18 +3009,20 @@ static int ql_init_misc_registers(struct ql3_adapter *qdev)
 static int ql_adapter_initialize(struct ql3_adapter *qdev)
 {
 	u32 value;
-	struct ql3xxx_port_registers __iomem *port_regs = qdev->mem_map_registers;
+	struct ql3xxx_port_registers __iomem *port_regs =
+		qdev->mem_map_registers;
+	u32 *spir = &port_regs->CommonRegs.serialPortInterfaceReg;
 	struct ql3xxx_host_memory_registers __iomem *hmem_regs =
-						(void __iomem *)port_regs;
+		(void __iomem *)port_regs;
 	u32 delay = 10;
 	int status = 0;
 	unsigned long hw_flags = 0;
 
-	if(ql_mii_setup(qdev))
+	if (ql_mii_setup(qdev))
 		return -1;
 
 	/* Bring out PHY out of reset */
-	ql_write_common_reg(qdev, &port_regs->CommonRegs.serialPortInterfaceReg,
+	ql_write_common_reg(qdev, spir,
 			    (ISP_SERIAL_PORT_IF_WE |
 			     (ISP_SERIAL_PORT_IF_WE << 16)));
 	/* Give the PHY time to come out of reset. */
@@ -3065,13 +3031,13 @@ static int ql_adapter_initialize(struct ql3_adapter *qdev)
 	netif_carrier_off(qdev->ndev);
 
 	/* V2 chip fix for ARS-39168. */
-	ql_write_common_reg(qdev, &port_regs->CommonRegs.serialPortInterfaceReg,
+	ql_write_common_reg(qdev, spir,
 			    (ISP_SERIAL_PORT_IF_SDE |
 			     (ISP_SERIAL_PORT_IF_SDE << 16)));
 
 	/* Request Queue Registers */
-	*((u32 *) (qdev->preq_consumer_index)) = 0;
-	atomic_set(&qdev->tx_count,NUM_REQ_Q_ENTRIES);
+	*((u32 *)(qdev->preq_consumer_index)) = 0;
+	atomic_set(&qdev->tx_count, NUM_REQ_Q_ENTRIES);
 	qdev->req_producer_index = 0;
 
 	ql_write_page1_reg(qdev,
@@ -3121,7 +3087,9 @@ static int ql_adapter_initialize(struct ql3_adapter *qdev)
 			   &hmem_regs->rxLargeQBaseAddrLow,
 			   LS_64BITS(qdev->lrg_buf_q_phy_addr));
 
-	ql_write_page1_reg(qdev, &hmem_regs->rxLargeQLength, qdev->num_lbufq_entries);
+	ql_write_page1_reg(qdev,
+			   &hmem_regs->rxLargeQLength,
+			   qdev->num_lbufq_entries);
 
 	ql_write_page1_reg(qdev,
 			   &hmem_regs->rxLargeBufferLength,
@@ -3171,7 +3139,7 @@ static int ql_adapter_initialize(struct ql3_adapter *qdev)
 	if ((value & PORT_STATUS_IC) == 0) {
 
 		/* Chip has not been configured yet, so let it rip. */
-		if(ql_init_misc_registers(qdev)) {
+		if (ql_init_misc_registers(qdev)) {
 			status = -1;
 			goto out;
 		}
@@ -3181,7 +3149,7 @@ static int ql_adapter_initialize(struct ql3_adapter *qdev)
 
 		value = (0xFFFF << 16) | qdev->nvram_data.extHwConfig;
 
-		if(ql_sem_spinlock(qdev, QL_FLASH_SEM_MASK,
+		if (ql_sem_spinlock(qdev, QL_FLASH_SEM_MASK,
 				(QL_RESOURCE_BITS_BASE_CODE | (qdev->mac_index)
 				 * 2) << 13)) {
 			status = -1;
@@ -3204,7 +3172,7 @@ static int ql_adapter_initialize(struct ql3_adapter *qdev)
 					   &port_regs->mac0MaxFrameLengthReg,
 					   qdev->max_frame_size);
 
-	if(ql_sem_spinlock(qdev, QL_PHY_GIO_SEM_MASK,
+	if (ql_sem_spinlock(qdev, QL_PHY_GIO_SEM_MASK,
 			(QL_RESOURCE_BITS_BASE_CODE | (qdev->mac_index) *
 			 2) << 7)) {
 		status = -1;
@@ -3297,7 +3265,8 @@ out:
  */
 static int ql_adapter_reset(struct ql3_adapter *qdev)
 {
-	struct ql3xxx_port_registers __iomem *port_regs = qdev->mem_map_registers;
+	struct ql3xxx_port_registers __iomem *port_regs =
+		qdev->mem_map_registers;
 	int status = 0;
 	u16 value;
 	int max_wait_time;
@@ -3357,13 +3326,11 @@ static int ql_adapter_reset(struct ql3_adapter *qdev)
 		 */
 		max_wait_time = 5;
 		do {
-			value =
-			    ql_read_common_reg(qdev,
-					       &port_regs->CommonRegs.
-					       ispControlStatus);
-			if ((value & ISP_CONTROL_FSR) == 0) {
+			value = ql_read_common_reg(qdev,
+						   &port_regs->CommonRegs.
+						   ispControlStatus);
+			if ((value & ISP_CONTROL_FSR) == 0)
 				break;
-			}
 			ssleep(1);
 		} while ((--max_wait_time));
 	}
@@ -3377,7 +3344,8 @@ static int ql_adapter_reset(struct ql3_adapter *qdev)
 
 static void ql_set_mac_info(struct ql3_adapter *qdev)
 {
-	struct ql3xxx_port_registers __iomem *port_regs = qdev->mem_map_registers;
+	struct ql3xxx_port_registers __iomem *port_regs =
+		qdev->mem_map_registers;
 	u32 value, port_status;
 	u8 func_number;
 
@@ -3393,9 +3361,9 @@ static void ql_set_mac_info(struct ql3_adapter *qdev)
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
@@ -3404,9 +3372,9 @@ static void ql_set_mac_info(struct ql3_adapter *qdev)
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
@@ -3428,7 +3396,7 @@ static void ql_display_dev_info(struct net_device *ndev)
 	netdev_info(ndev,
 		    "%s Adapter %d RevisionID %d found %s on PCI slot %d\n",
 		    DRV_NAME, qdev->index, qdev->chip_rev_id,
-		    (qdev->device_id == QL3032_DEVICE_ID) ? "QLA3032" : "QLA3022",
+		    qdev->device_id == QL3032_DEVICE_ID ? "QLA3032" : "QLA3022",
 		    qdev->pci_slot);
 	netdev_info(ndev, "%s Interface\n",
 		test_bit(QL_LINK_OPTICAL, &qdev->flags) ? "OPTICAL" : "COPPER");
@@ -3455,16 +3423,16 @@ static int ql_adapter_down(struct ql3_adapter *qdev, int do_reset)
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
 		netdev_info(qdev->ndev, "calling pci_disable_msi()\n");
-		clear_bit(QL_MSI_ENABLED,&qdev->flags);
+		clear_bit(QL_MSI_ENABLED, &qdev->flags);
 		pci_disable_msi(qdev->pdev);
 	}
 
@@ -3478,7 +3446,8 @@ static int ql_adapter_down(struct ql3_adapter *qdev, int do_reset)
 
 		spin_lock_irqsave(&qdev->hw_lock, hw_flags);
 		if (ql_wait_for_drvr_lock(qdev)) {
-			if ((soft_reset = ql_adapter_reset(qdev))) {
+			soft_reset = ql_adapter_reset(qdev);
+			if (soft_reset) {
 				netdev_err(ndev, "ql_adapter_reset(%d) FAILED!\n",
 					   qdev->index);
 			}
@@ -3514,24 +3483,26 @@ static int ql_adapter_up(struct ql3_adapter *qdev)
 			qdev->msi = 0;
 		} else {
 			netdev_info(ndev, "MSI Enabled...\n");
-			set_bit(QL_MSI_ENABLED,&qdev->flags);
+			set_bit(QL_MSI_ENABLED, &qdev->flags);
 			irq_flags &= ~IRQF_SHARED;
 		}
 	}
 
-	if ((err = request_irq(qdev->pdev->irq,
-			       ql3xxx_isr,
-			       irq_flags, ndev->name, ndev))) {
+	err = request_irq(qdev->pdev->irq, ql3xxx_isr,
+			  irq_flags, ndev->name, ndev);
+	if (err) {
 		netdev_err(ndev,
-			   "Failed to reserve interrupt %d already in use\n",
+			   "Failed to reserve interrupt %d - already in use\n",
 			   qdev->pdev->irq);
 		goto err_irq;
 	}
 
 	spin_lock_irqsave(&qdev->hw_lock, hw_flags);
 
-	if ((err = ql_wait_for_drvr_lock(qdev))) {
-		if ((err = ql_adapter_initialize(qdev))) {
+	err = ql_wait_for_drvr_lock(qdev);
+	if (err) {
+		err = ql_adapter_initialize(qdev);
+		if (err) {
 			netdev_err(ndev, "Unable to initialize adapter\n");
 			goto err_init;
 		}
@@ -3544,7 +3515,7 @@ static int ql_adapter_up(struct ql3_adapter *qdev)
 
 	spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
 
-	set_bit(QL_ADAPTER_UP,&qdev->flags);
+	set_bit(QL_ADAPTER_UP, &qdev->flags);
 
 	mod_timer(&qdev->adapter_timer, jiffies + HZ * 1);
 
@@ -3558,9 +3529,9 @@ err_lock:
 	spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
 	free_irq(qdev->pdev->irq, ndev);
 err_irq:
-	if (qdev->msi && test_bit(QL_MSI_ENABLED,&qdev->flags)) {
+	if (qdev->msi && test_bit(QL_MSI_ENABLED, &qdev->flags)) {
 		netdev_info(ndev, "calling pci_disable_msi()\n");
-		clear_bit(QL_MSI_ENABLED,&qdev->flags);
+		clear_bit(QL_MSI_ENABLED, &qdev->flags);
 		pci_disable_msi(qdev->pdev);
 	}
 	return err;
@@ -3568,7 +3539,7 @@ err_irq:
 
 static int ql_cycle_adapter(struct ql3_adapter *qdev, int reset)
 {
-	if( ql_adapter_down(qdev,reset) || ql_adapter_up(qdev)) {
+	if (ql_adapter_down(qdev, reset) || ql_adapter_up(qdev)) {
 		netdev_err(qdev->ndev,
 			   "Driver up/down cycle failed, closing device\n");
 		rtnl_lock();
@@ -3587,24 +3558,24 @@ static int ql3xxx_close(struct net_device *ndev)
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
 
 static int ql3xxx_open(struct net_device *ndev)
 {
 	struct ql3_adapter *qdev = netdev_priv(ndev);
-	return (ql_adapter_up(qdev));
+	return ql_adapter_up(qdev);
 }
 
 static int ql3xxx_set_mac_address(struct net_device *ndev, void *p)
 {
 	struct ql3_adapter *qdev = (struct ql3_adapter *)netdev_priv(ndev);
 	struct ql3xxx_port_registers __iomem *port_regs =
-	    		qdev->mem_map_registers;
+			qdev->mem_map_registers;
 	struct sockaddr *addr = p;
 	unsigned long hw_flags;
 
@@ -3659,11 +3630,12 @@ static void ql_reset_work(struct work_struct *work)
 	u32 value;
 	struct ql_tx_buf_cb *tx_cb;
 	int max_wait_time, i;
-	struct ql3xxx_port_registers __iomem *port_regs = qdev->mem_map_registers;
+	struct ql3xxx_port_registers __iomem *port_regs =
+		qdev->mem_map_registers;
 	unsigned long hw_flags;
 
-	if (test_bit((QL_RESET_PER_SCSI | QL_RESET_START),&qdev->flags)) {
-		clear_bit(QL_LINK_MASTER,&qdev->flags);
+	if (test_bit((QL_RESET_PER_SCSI | QL_RESET_START), &qdev->flags)) {
+		clear_bit(QL_LINK_MASTER, &qdev->flags);
 
 		/*
 		 * Loop through the active list and return the skb.
@@ -3675,13 +3647,16 @@ static void ql_reset_work(struct work_struct *work)
 				netdev_printk(KERN_DEBUG, ndev,
 					      "Freeing lost SKB\n");
 				pci_unmap_single(qdev->pdev,
-					 dma_unmap_addr(&tx_cb->map[0], mapaddr),
+					 dma_unmap_addr(&tx_cb->map[0],
+							mapaddr),
 					 dma_unmap_len(&tx_cb->map[0], maplen),
 					 PCI_DMA_TODEVICE);
-				for(j=1;j<tx_cb->seg_count;j++) {
+				for (j = 1; j < tx_cb->seg_count; j++) {
 					pci_unmap_page(qdev->pdev,
-					       dma_unmap_addr(&tx_cb->map[j],mapaddr),
-					       dma_unmap_len(&tx_cb->map[j],maplen),
+					       dma_unmap_addr(&tx_cb->map[j],
+							      mapaddr),
+					       dma_unmap_len(&tx_cb->map[j],
+							     maplen),
 					       PCI_DMA_TODEVICE);
 				}
 				dev_kfree_skb(tx_cb->skb);
@@ -3736,16 +3711,16 @@ static void ql_reset_work(struct work_struct *work)
 			netdev_err(ndev,
 				   "Timed out waiting for reset to complete\n");
 			netdev_err(ndev, "Do a reset\n");
-			clear_bit(QL_RESET_PER_SCSI,&qdev->flags);
-			clear_bit(QL_RESET_START,&qdev->flags);
-			ql_cycle_adapter(qdev,QL_DO_RESET);
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
 
@@ -3759,7 +3734,8 @@ static void ql_tx_timeout_work(struct work_struct *work)
 
 static void ql_get_board_info(struct ql3_adapter *qdev)
 {
-	struct ql3xxx_port_registers __iomem *port_regs = qdev->mem_map_registers;
+	struct ql3xxx_port_registers __iomem *port_regs =
+		qdev->mem_map_registers;
 	u32 value;
 
 	value = ql_read_page0_reg_l(qdev, &port_regs->portStatus);
@@ -3798,7 +3774,7 @@ static int __devinit ql3xxx_probe(struct pci_dev *pdev,
 {
 	struct net_device *ndev = NULL;
 	struct ql3_adapter *qdev = NULL;
-	static int cards_found = 0;
+	static int cards_found;
 	int uninitialized_var(pci_using_dac), err;
 
 	err = pci_enable_device(pdev);
@@ -3903,9 +3879,8 @@ static int __devinit ql3xxx_probe(struct pci_dev *pdev,
 	 * Set the Maximum Memory Read Byte Count value. We do this to handle
 	 * jumbo frames.
 	 */
-	if (qdev->pci_x) {
+	if (qdev->pci_x)
 		pci_write_config_word(pdev, (int)0x4e, (u16) 0x0036);
-	}
 
 	err = register_netdev(ndev);
 	if (err) {
-- 
1.7.2

