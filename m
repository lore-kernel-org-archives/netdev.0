From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 6/7] qla3xxx: Adding support for the Agere PHY (ET1011C)
Date: Mon, 26 Mar 2007 13:43:02 -0700
Message-ID: <11749417841975-git-send-email-ron.mercer@qlogic.com>
References: <20070326164650.GA3822@linux-7mw0.qlogic.org>
Cc: ron.mercer@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:9929 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753007AbXCZUnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2007 16:43:10 -0400
In-Reply-To: <20070326164650.GA3822@linux-7mw0.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This PHY support patch was written by Benjamin Li.
Signed-off-by: Benjamin Li <benjamin.li@qlogic.com>
Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qla3xxx.c |  347 +++++++++++++++++++++++++++++++++++++++++++------
 drivers/net/qla3xxx.h |   33 +++++-
 2 files changed, 335 insertions(+), 45 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 631bf9f..3a49fc9 100755
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -72,6 +72,30 @@ static struct pci_device_id ql3xxx_pci_tbl[] __devinitdata = {
 MODULE_DEVICE_TABLE(pci, ql3xxx_pci_tbl);
 
 /*
+ *  These are the known PHY's which are used
+ */
+typedef enum {
+   PHY_TYPE_UNKNOWN   = 0,
+   PHY_VITESSE_VSC8211,
+   PHY_AGERE_ET1011C,
+   MAX_PHY_DEV_TYPES
+} PHY_DEVICE_et;
+
+typedef struct {
+	PHY_DEVICE_et phyDevice; 
+	u32		phyIdOUI;
+	u16		phyIdModel;
+	char 		*name;
+} PHY_DEVICE_INFO_t;
+
+const PHY_DEVICE_INFO_t PHY_DEVICES[] =
+	{{PHY_TYPE_UNKNOWN,    0x000000, 0x0, "PHY_TYPE_UNKNOWN"},
+	 {PHY_VITESSE_VSC8211, 0x0003f1, 0xb, "PHY_VITESSE_VSC8211"},
+	 {PHY_AGERE_ET1011C,   0x00a0bc, 0x1, "PHY_AGERE_ET1011C"},
+};
+
+
+/*
  * Caller must take hw_lock.
  */
 static int ql_sem_spinlock(struct ql3_adapter *qdev,
@@ -662,7 +686,7 @@ static u8 ql_mii_disable_scan_mode(struct ql3_adapter *qdev)
 }
 
 static int ql_mii_write_reg_ex(struct ql3_adapter *qdev,
-			       u16 regAddr, u16 value, u32 mac_index)
+			       u16 regAddr, u16 value, u32 phyAddr)
 {
 	struct ql3xxx_port_registers __iomem *port_regs =
 	    		qdev->mem_map_registers;
@@ -680,7 +704,7 @@ static int ql_mii_write_reg_ex(struct ql3_adapter *qdev,
 	}
 
 	ql_write_page0_reg(qdev, &port_regs->macMIIMgmtAddrReg,
-			   PHYAddr[mac_index] | regAddr);
+			   phyAddr | regAddr);
 
 	ql_write_page0_reg(qdev, &port_regs->macMIIMgmtDataReg, value);
 
@@ -701,7 +725,7 @@ static int ql_mii_write_reg_ex(struct ql3_adapter *qdev,
 }
 
 static int ql_mii_read_reg_ex(struct ql3_adapter *qdev, u16 regAddr,
-			      u16 * value, u32 mac_index)
+			      u16 * value, u32 phyAddr)
 {
 	struct ql3xxx_port_registers __iomem *port_regs =
 	    		qdev->mem_map_registers;
@@ -720,7 +744,7 @@ static int ql_mii_read_reg_ex(struct ql3_adapter *qdev, u16 regAddr,
 	}
 
 	ql_write_page0_reg(qdev, &port_regs->macMIIMgmtAddrReg,
-			   PHYAddr[mac_index] | regAddr);
+			   phyAddr | regAddr);
 
 	ql_write_page0_reg(qdev, &port_regs->macMIIMgmtControlReg,
 			   (MAC_MII_CONTROL_RC << 16));
@@ -850,28 +874,31 @@ static void ql_petbi_start_neg(struct ql3_adapter *qdev)
 
 }
 
-static void ql_petbi_reset_ex(struct ql3_adapter *qdev, u32 mac_index)
+static void ql_petbi_reset_ex(struct ql3_adapter *qdev)
 {
 	ql_mii_write_reg_ex(qdev, PETBI_CONTROL_REG, PETBI_CTRL_SOFT_RESET,
-			    mac_index);
+			    PHYAddr[qdev->mac_index]);
 }
 
-static void ql_petbi_start_neg_ex(struct ql3_adapter *qdev, u32 mac_index)
+static void ql_petbi_start_neg_ex(struct ql3_adapter *qdev)
 {
 	u16 reg;
 
 	/* Enable Auto-negotiation sense */
-	ql_mii_read_reg_ex(qdev, PETBI_TBI_CTRL, &reg, mac_index);
+	ql_mii_read_reg_ex(qdev, PETBI_TBI_CTRL, &reg, 
+			   PHYAddr[qdev->mac_index]);
 	reg |= PETBI_TBI_AUTO_SENSE;
-	ql_mii_write_reg_ex(qdev, PETBI_TBI_CTRL, reg, mac_index);
+	ql_mii_write_reg_ex(qdev, PETBI_TBI_CTRL, reg, 
+			    PHYAddr[qdev->mac_index]);
 
 	ql_mii_write_reg_ex(qdev, PETBI_NEG_ADVER,
-			    PETBI_NEG_PAUSE | PETBI_NEG_DUPLEX, mac_index);
+			    PETBI_NEG_PAUSE | PETBI_NEG_DUPLEX, 
+			    PHYAddr[qdev->mac_index]);
 
 	ql_mii_write_reg_ex(qdev, PETBI_CONTROL_REG,
 			    PETBI_CTRL_AUTO_NEG | PETBI_CTRL_RESTART_NEG |
 			    PETBI_CTRL_FULL_DUPLEX | PETBI_CTRL_SPEED_1000,
-			    mac_index);
+			    PHYAddr[qdev->mac_index]);
 }
 
 static void ql_petbi_init(struct ql3_adapter *qdev)
@@ -880,10 +907,10 @@ static void ql_petbi_init(struct ql3_adapter *qdev)
 	ql_petbi_start_neg(qdev);
 }
 
-static void ql_petbi_init_ex(struct ql3_adapter *qdev, u32 mac_index)
+static void ql_petbi_init_ex(struct ql3_adapter *qdev)
 {
-	ql_petbi_reset_ex(qdev, mac_index);
-	ql_petbi_start_neg_ex(qdev, mac_index);
+	ql_petbi_reset_ex(qdev);
+	ql_petbi_start_neg_ex(qdev);
 }
 
 static int ql_is_petbi_neg_pause(struct ql3_adapter *qdev)
@@ -896,33 +923,128 @@ static int ql_is_petbi_neg_pause(struct ql3_adapter *qdev)
 	return (reg & PETBI_NEG_PAUSE_MASK) == PETBI_NEG_PAUSE;
 }
 
+static void phyAgereSpecificInit(struct ql3_adapter *qdev, u32 miiAddr)
+{
+	printk(KERN_INFO "%s: enabling Agere specific PHY\n", qdev->ndev->name);
+	/* power down device bit 11 = 1 */
+	ql_mii_write_reg_ex(qdev, 0x00, 0x1940, miiAddr);
+	/* enable diagnostic mode bit 2 = 1 */
+	ql_mii_write_reg_ex(qdev, 0x12, 0x840e, miiAddr);
+	/* 1000MB amplitude adjust (see Agere errata) */
+	ql_mii_write_reg_ex(qdev, 0x10, 0x8805, miiAddr);
+	/* 1000MB amplitude adjust (see Agere errata) */
+	ql_mii_write_reg_ex(qdev, 0x11, 0xf03e, miiAddr);
+	/* 100MB amplitude adjust (see Agere errata) */
+	ql_mii_write_reg_ex(qdev, 0x10, 0x8806, miiAddr);
+	/* 100MB amplitude adjust (see Agere errata) */
+	ql_mii_write_reg_ex(qdev, 0x11, 0x003e, miiAddr);
+	/* 10MB amplitude adjust (see Agere errata) */
+	ql_mii_write_reg_ex(qdev, 0x10, 0x8807, miiAddr);
+	/* 10MB amplitude adjust (see Agere errata) */
+	ql_mii_write_reg_ex(qdev, 0x11, 0x1f00, miiAddr);
+	/* point to hidden reg 0x2806 */
+	ql_mii_write_reg_ex(qdev, 0x10, 0x2806, miiAddr);
+	/* Write new PHYAD w/bit 5 set */
+	ql_mii_write_reg_ex(qdev, 0x11, 0x0020 | (PHYAddr[qdev->mac_index] >> 8), miiAddr);
+	/* 
+	 * Disable diagnostic mode bit 2 = 0
+	 * Power up device bit 11 = 0
+	 * Link up (on) and activity (blink)
+	 */
+	ql_mii_write_reg(qdev, 0x12, 0x840a);
+	ql_mii_write_reg(qdev, 0x00, 0x1140);
+	ql_mii_write_reg(qdev, 0x1c, 0xfaf0);
+}
+
+static PHY_DEVICE_et getPhyType (struct ql3_adapter *qdev, 
+				 u16 phyIdReg0, u16 phyIdReg1)
+{
+	PHY_DEVICE_et result = PHY_TYPE_UNKNOWN;
+	u32   oui;     
+	u16   model;
+	int i;   
+
+	if (phyIdReg0 == 0xffff) {
+		return result;
+	}
+   
+	if (phyIdReg1 == 0xffff) {
+		return result;
+	}
+
+	/* oui is split between two registers */
+	oui = (phyIdReg0 << 6) | ((phyIdReg1 & PHY_OUI_1_MASK) >> 10);
+
+	model = (phyIdReg1 & PHY_MODEL_MASK) >> 4;
+
+	/* Scan table for this PHY */
+	for(i = 0; i < MAX_PHY_DEV_TYPES; i++) {
+		if ((oui == PHY_DEVICES[i].phyIdOUI) && (model == PHY_DEVICES[i].phyIdModel))
+		{
+			result = PHY_DEVICES[i].phyDevice;
+
+			printk(KERN_INFO "%s: Phy: %s\n",
+				qdev->ndev->name, PHY_DEVICES[i].name);
+			
+		        break;
+		}
+	}
+
+	return result;
+}
+
 static int ql_phy_get_speed(struct ql3_adapter *qdev)
 {
 	u16 reg;
 
+	switch(qdev->phyType) {
+	case PHY_AGERE_ET1011C:
+	{
+		if (ql_mii_read_reg(qdev, 0x1A, &reg) < 0)
+			return 0;
+
+		reg = (reg >> 8) & 3;
+		break;
+	}
+	default:
 	if (ql_mii_read_reg(qdev, AUX_CONTROL_STATUS, &reg) < 0)
 		return 0;
 
 	reg = (((reg & 0x18) >> 3) & 3);
+	}
 
-	if (reg == 2)
+	switch(reg) {
+		case 2:
 		return SPEED_1000;
-	else if (reg == 1)
+		case 1:
 		return SPEED_100;
-	else if (reg == 0)
+		case 0:
 		return SPEED_10;
-	else
+		default:
 		return -1;
+	}
 }
 
 static int ql_is_full_dup(struct ql3_adapter *qdev)
 {
 	u16 reg;
 
-	if (ql_mii_read_reg(qdev, AUX_CONTROL_STATUS, &reg) < 0)
-		return 0;
-
-	return (reg & PHY_AUX_DUPLEX_STAT) != 0;
+	switch(qdev->phyType) {
+	case PHY_AGERE_ET1011C:
+	{
+		if (ql_mii_read_reg(qdev, 0x1A, &reg))
+			return 0;
+			
+		return ((reg & 0x0080) && (reg & 0x1000)) != 0;
+	}
+	case PHY_VITESSE_VSC8211:
+	default:
+	{
+		if (ql_mii_read_reg(qdev, AUX_CONTROL_STATUS, &reg) < 0)
+			return 0;
+		return (reg & PHY_AUX_DUPLEX_STAT) != 0;
+	}
+	}
 }
 
 static int ql_is_phy_neg_pause(struct ql3_adapter *qdev)
@@ -935,6 +1057,73 @@ static int ql_is_phy_neg_pause(struct ql3_adapter *qdev)
 	return (reg & PHY_NEG_PAUSE) != 0;
 }
 
+static int PHY_Setup(struct ql3_adapter *qdev)
+{
+	u16   reg1;
+	u16   reg2;
+	bool  agereAddrChangeNeeded = false;
+	u32 miiAddr = 0;
+	int err;
+
+	/*  Determine the PHY we are using by reading the ID's */
+	err = ql_mii_read_reg(qdev, PHY_ID_0_REG, &reg1);
+	if(err != 0) {
+		printk(KERN_ERR "%s: Could not read from reg PHY_ID_0_REG\n",
+		       qdev->ndev->name);
+                return err;
+	}
+
+	err = ql_mii_read_reg(qdev, PHY_ID_1_REG, &reg2);
+	if(err != 0) {
+		printk(KERN_ERR "%s: Could not read from reg PHY_ID_0_REG\n",
+		       qdev->ndev->name);
+                return err;
+	}
+
+	/*  Check if we have a Agere PHY */
+	if ((reg1 == 0xffff) || (reg2 == 0xffff)) {
+
+		/* Determine which MII address we should be using 
+		   determined by the index of the card */
+		if (qdev->mac_index == 0) {
+			miiAddr = MII_AGERE_ADDR_1;
+		} else {
+			miiAddr = MII_AGERE_ADDR_2;
+		}
+      
+		err =ql_mii_read_reg_ex(qdev, PHY_ID_0_REG, &reg1, miiAddr);
+		if(err != 0) {
+			printk(KERN_ERR "%s: Could not read from reg PHY_ID_0_REG after Agere detected\n",
+		       	       qdev->ndev->name);
+                	return err; 
+		}
+
+		err = ql_mii_read_reg_ex(qdev, PHY_ID_1_REG, &reg2, miiAddr);
+		if(err != 0) {
+			printk(KERN_ERR "%s: Could not read from reg PHY_ID_0_REG after Agere detected\n",
+			       qdev->ndev->name);
+        	        return err;
+		}
+   
+		/*  We need to remember to initialize the Agere PHY */
+         	agereAddrChangeNeeded = true; 
+	}
+
+	/*  Determine the particular PHY we have on board to apply
+	    PHY specific initializations */
+	qdev->phyType = getPhyType(qdev, reg1, reg2);
+
+	if ((qdev->phyType == PHY_AGERE_ET1011C) && agereAddrChangeNeeded) {
+		/* need this here so address gets changed */
+		phyAgereSpecificInit(qdev, miiAddr);  
+	} else if (qdev->phyType == PHY_TYPE_UNKNOWN) {
+		printk(KERN_ERR "%s: PHY is unknown\n", qdev->ndev->name);
+		return -EIO;
+	}
+
+	return 0;
+}
+
 /*
  * Caller holds hw_lock.
  */
@@ -1205,15 +1394,14 @@ static int ql_link_down_detect_clear(struct ql3_adapter *qdev)
 /*
  * Caller holds hw_lock.
  */
-static int ql_this_adapter_controls_port(struct ql3_adapter *qdev,
-					 u32 mac_index)
+static int ql_this_adapter_controls_port(struct ql3_adapter *qdev)
 {
 	struct ql3xxx_port_registers __iomem *port_regs =
 	    		qdev->mem_map_registers;
 	u32 bitToCheck = 0;
 	u32 temp;
 
-	switch (mac_index) {
+	switch (qdev->mac_index) {
 	case 0:
 		bitToCheck = PORT_STATUS_F1_ENABLED;
 		break;
@@ -1238,27 +1426,96 @@ static int ql_this_adapter_controls_port(struct ql3_adapter *qdev,
 	}
 }
 
-static void ql_phy_reset_ex(struct ql3_adapter *qdev, u32 mac_index)
+static void ql_phy_reset_ex(struct ql3_adapter *qdev)
 {
-	ql_mii_write_reg_ex(qdev, CONTROL_REG, PHY_CTRL_SOFT_RESET, mac_index);
+	ql_mii_write_reg_ex(qdev, CONTROL_REG, PHY_CTRL_SOFT_RESET, 
+			    PHYAddr[qdev->mac_index]);
 }
 
-static void ql_phy_start_neg_ex(struct ql3_adapter *qdev, u32 mac_index)
+static void ql_phy_start_neg_ex(struct ql3_adapter *qdev)
 {
 	u16 reg;
+	u16 portConfiguration;
 
-	ql_mii_write_reg_ex(qdev, PHY_NEG_ADVER,
-			    PHY_NEG_PAUSE | PHY_NEG_ADV_SPEED | 1, mac_index);
+	if(qdev->phyType == PHY_AGERE_ET1011C) {
+		/* turn off external loopback */
+		ql_mii_write_reg(qdev, 0x13, 0x0000); 
+	}
+
+	if(qdev->mac_index == 0)
+		portConfiguration = qdev->nvram_data.macCfg_port0.portConfiguration;
+	else
+		portConfiguration = qdev->nvram_data.macCfg_port1.portConfiguration;
+
+	/*  Some HBA's in the field are set to 0 and they need to
+	    be reinterpreted with a default value */
+	if(portConfiguration == 0)
+		portConfiguration = PORT_CONFIG_DEFAULT;
+
+	/* Set the 1000 advertisements */
+	ql_mii_read_reg_ex(qdev, PHY_GIG_CONTROL, &reg, 
+			   PHYAddr[qdev->mac_index]);
+	reg &= ~PHY_GIG_ALL_PARAMS;
+
+	if(portConfiguration & 
+	   PORT_CONFIG_FULL_DUPLEX_ENABLED &
+	   PORT_CONFIG_1000MB_SPEED) {
+		reg |= PHY_GIG_ADV_1000F;
+	}
+	 
+	if(portConfiguration & 
+	   PORT_CONFIG_HALF_DUPLEX_ENABLED &
+	   PORT_CONFIG_1000MB_SPEED) {
+		reg |= PHY_GIG_ADV_1000H;
+	}
+
+	ql_mii_write_reg_ex(qdev, PHY_GIG_CONTROL, reg, 
+			    PHYAddr[qdev->mac_index]);
+
+	/* Set the 10/100 & pause negotiation advertisements */
+	ql_mii_read_reg_ex(qdev, PHY_NEG_ADVER, &reg,
+			   PHYAddr[qdev->mac_index]);
+	reg &= ~PHY_NEG_ALL_PARAMS;
+
+	if(portConfiguration & PORT_CONFIG_SYM_PAUSE_ENABLED)
+		reg |= PHY_NEG_ASY_PAUSE | PHY_NEG_SYM_PAUSE;
+
+	if(portConfiguration & PORT_CONFIG_FULL_DUPLEX_ENABLED) {
+		if(portConfiguration & PORT_CONFIG_100MB_SPEED)
+			reg |= PHY_NEG_ADV_100F;
+		
+		if(portConfiguration & PORT_CONFIG_10MB_SPEED)
+			reg |= PHY_NEG_ADV_10F;
+	}
 
-	ql_mii_read_reg_ex(qdev, CONTROL_REG, &reg, mac_index);
-	ql_mii_write_reg_ex(qdev, CONTROL_REG, reg | PHY_CTRL_RESTART_NEG,
-			    mac_index);
+	if(portConfiguration & PORT_CONFIG_HALF_DUPLEX_ENABLED) {
+		if(portConfiguration & PORT_CONFIG_100MB_SPEED)
+			reg |= PHY_NEG_ADV_100H;
+		
+		if(portConfiguration & PORT_CONFIG_10MB_SPEED)
+			reg |= PHY_NEG_ADV_10H;
+	}
+
+	if(portConfiguration &
+	   PORT_CONFIG_1000MB_SPEED) {
+		reg |= 1;	
+	}
+
+	ql_mii_write_reg_ex(qdev, PHY_NEG_ADVER, reg, 
+			    PHYAddr[qdev->mac_index]);
+
+	ql_mii_read_reg_ex(qdev, CONTROL_REG, &reg, PHYAddr[qdev->mac_index]);
+	
+	ql_mii_write_reg_ex(qdev, CONTROL_REG, 
+			    reg | PHY_CTRL_RESTART_NEG | PHY_CTRL_AUTO_NEG,
+			    PHYAddr[qdev->mac_index]);
 }
 
-static void ql_phy_init_ex(struct ql3_adapter *qdev, u32 mac_index)
+static void ql_phy_init_ex(struct ql3_adapter *qdev)
 {
-	ql_phy_reset_ex(qdev, mac_index);
-	ql_phy_start_neg_ex(qdev, mac_index);
+	ql_phy_reset_ex(qdev);
+	PHY_Setup(qdev);
+	ql_phy_start_neg_ex(qdev);
 }
 
 /*
@@ -1295,14 +1552,17 @@ static int ql_port_start(struct ql3_adapter *qdev)
 {
 	if(ql_sem_spinlock(qdev, QL_PHY_GIO_SEM_MASK,
 		(QL_RESOURCE_BITS_BASE_CODE | (qdev->mac_index) *
-			 2) << 7))
+			 2) << 7)) {
+		printk(KERN_ERR "%s: Could not get hw lock for GIO\n",
+		       qdev->ndev->name);
 		return -1;
+	}
 
 	if (ql_is_fiber(qdev)) {
 		ql_petbi_init(qdev);
 	} else {
 		/* Copper port */
-		ql_phy_init_ex(qdev, qdev->mac_index);
+		ql_phy_init_ex(qdev);
 	}
 
 	ql_sem_unlock(qdev, QL_PHY_GIO_SEM_MASK);
@@ -1453,7 +1713,7 @@ static void ql_link_state_machine(struct ql3_adapter *qdev)
  */
 static void ql_get_phy_owner(struct ql3_adapter *qdev)
 {
-	if (ql_this_adapter_controls_port(qdev, qdev->mac_index))
+	if (ql_this_adapter_controls_port(qdev))
 		set_bit(QL_LINK_MASTER,&qdev->flags);
 	else
 		clear_bit(QL_LINK_MASTER,&qdev->flags);
@@ -1467,11 +1727,11 @@ static void ql_init_scan_mode(struct ql3_adapter *qdev)
 	ql_mii_enable_scan_mode(qdev);
 
 	if (test_bit(QL_LINK_OPTICAL,&qdev->flags)) {
-		if (ql_this_adapter_controls_port(qdev, qdev->mac_index))
-			ql_petbi_init_ex(qdev, qdev->mac_index);
+		if (ql_this_adapter_controls_port(qdev))
+			ql_petbi_init_ex(qdev);
 	} else {
-		if (ql_this_adapter_controls_port(qdev, qdev->mac_index))
-			ql_phy_init_ex(qdev, qdev->mac_index);
+		if (ql_this_adapter_controls_port(qdev))
+			ql_phy_init_ex(qdev);
 	}
 }
 
@@ -3093,6 +3353,7 @@ static int ql_adapter_initialize(struct ql3_adapter *qdev)
 		goto out;
 	}
 
+	PHY_Setup(qdev);
 	ql_init_scan_mode(qdev);
 	ql_get_phy_owner(qdev);
 
diff --git a/drivers/net/qla3xxx.h b/drivers/net/qla3xxx.h
index 0203f88..4a832c4 100755
--- a/drivers/net/qla3xxx.h
+++ b/drivers/net/qla3xxx.h
@@ -293,6 +293,16 @@ struct net_rsp_iocb {
 
 #define MII_SCAN_REGISTER 0x00000001
 
+#define PHY_ID_0_REG    2
+#define PHY_ID_1_REG    3
+
+#define PHY_OUI_1_MASK       0xfc00
+#define PHY_MODEL_MASK       0x03f0
+
+/*  Address for the Agere Phy */
+#define MII_AGERE_ADDR_1  0x00001000
+#define MII_AGERE_ADDR_2  0x00001100
+
 /* 32-bit ispControlStatus */
 enum {
 	ISP_CONTROL_NP_MASK = 0x0003,
@@ -789,6 +799,7 @@ enum {
 	PHY_CTRL_LOOPBACK = 0x4000,
 
 	PETBI_CONTROL_REG = 0x00,
+	PETBI_CTRL_ALL_PARAMS = 0x7140,
 	PETBI_CTRL_SOFT_RESET = 0x8000,
 	PETBI_CTRL_AUTO_NEG = 0x1000,
 	PETBI_CTRL_RESTART_NEG = 0x0200,
@@ -811,6 +822,23 @@ enum {
 	PETBI_EXPANSION_REG = 0x06,
 	PETBI_EXP_PAGE_RX = 0x0002,
 
+	PHY_GIG_CONTROL = 9,
+	PHY_GIG_ENABLE_MAN = 0x1000,  /* Enable Master/Slave Manual Config*/
+	PHY_GIG_SET_MASTER = 0x0800,  /* Set Master (slave if clear)*/
+	PHY_GIG_ALL_PARAMS = 0x0300,
+	PHY_GIG_ADV_1000F = 0x0200,
+	PHY_GIG_ADV_1000H = 0x0100,
+
+	PHY_NEG_ADVER = 4,
+	PHY_NEG_ALL_PARAMS = 0x0fe0,
+	PHY_NEG_ASY_PAUSE =  0x0800,
+	PHY_NEG_SYM_PAUSE =  0x0400,
+	PHY_NEG_ADV_SPEED =  0x01e0,
+	PHY_NEG_ADV_100F =   0x0100,
+	PHY_NEG_ADV_100H =   0x0080,
+	PHY_NEG_ADV_10F =    0x0040,
+	PHY_NEG_ADV_10H =    0x0020,
+
 	PETBI_TBI_CTRL = 0x11,
 	PETBI_TBI_RESET = 0x8000,
 	PETBI_TBI_AUTO_SENSE = 0x0100,
@@ -826,8 +854,7 @@ enum {
 	PHY_AUX_RESET_STICK = 0x0002,
 	PHY_NEG_PAUSE = 0x0400,
 	PHY_CTRL_SOFT_RESET = 0x8000,
-	PHY_NEG_ADVER = 4,
-	PHY_NEG_ADV_SPEED = 0x01e0,
+	PHY_CTRL_AUTO_NEG = 0x1000,
 	PHY_CTRL_RESTART_NEG = 0x0200,
 };
 enum {
@@ -892,6 +919,7 @@ enum {EEPROM_SIZE = FM93C86A_SIZE_16,
 	u16 pauseThreshold_mac;
 	u16 resumeThreshold_mac;
 	u16 portConfiguration;
+#define PORT_CONFIG_DEFAULT                 0xf700
 #define PORT_CONFIG_AUTO_NEG_ENABLED        0x8000
 #define PORT_CONFIG_SYM_PAUSE_ENABLED       0x4000
 #define PORT_CONFIG_FULL_DUPLEX_ENABLED     0x2000
@@ -1259,6 +1287,7 @@ struct ql3_adapter {
 	struct delayed_work tx_timeout_work;
 	u32 max_frame_size;
 	u32 device_id;
+	u16 phyType;
 };
 
 #endif				/* _QLA3XXX_H_ */
-- 
1.5.0.rc4.16.g9e258

