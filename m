From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: [PATCH 2.6.25 3/12][BNX2X]: Correct Link management
Date: Wed, 27 Feb 2008 14:24:29 +0200
Message-ID: <1204115069.8232.357.camel@lb-tlvb-eliezer.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, jeff@garzik.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4602 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754197AbYB0MYq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2008 07:24:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2X]: Correct Link management

Properly protect PHY access between two devices on the same board with a HW lock.
Use GPIO to clear all previous configurations before changing link parameters.
Shut down the external PHY in case of fan failure.
Reducing the MDC/MDIO clock to 2.5MHz due to problems with some devices.
Resolve the flow control response according to autoneg with external PHY.
Unmasking all PHY interrupts in single write to prevent a race in the interrupts order.
LASI indication fixes to work with peculiarities of PHYs.
Disable MAC RX to avoid a HW bug when closing the MAC under traffic.
Disable parallel detection on HiGig due to HW limitation.
Updating the shared memory structure to work with the current bootcode.

Signed-off-by: Eliezer Tamir <eliezert@broadcom.com>
---
 drivers/net/bnx2x.c         | 1707 ++++++++++++++++++++++++++++++++-----------
 drivers/net/bnx2x.h         |   34 +-
 drivers/net/bnx2x_fw_defs.h |    2 +-
 drivers/net/bnx2x_hsi.h     |  428 ++++++-----
 drivers/net/bnx2x_reg.h     |  212 ++++++-
 5 files changed, 1734 insertions(+), 649 deletions(-)

diff --git a/drivers/net/bnx2x.c b/drivers/net/bnx2x.c
index 7786716..5cd7850 100644
--- a/drivers/net/bnx2x.c
+++ b/drivers/net/bnx2x.c
@@ -1,6 +1,6 @@
 /* bnx2x.c: Broadcom Everest network driver.
  *
- * Copyright (c) 2007 Broadcom Corporation
+ * Copyright (c) 2007-2008 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -65,7 +65,7 @@
 
 #define DRV_MODULE_VERSION      "0.40.15"
 #define DRV_MODULE_RELDATE      "$DateTime: 2007/11/15 07:28:37 $"
-#define BNX2X_BC_VER    	0x040009
+#define BNX2X_BC_VER    	0x040200
 
 /* Time in jiffies before concluding the transmitter is hung. */
 #define TX_TIMEOUT      	(5*HZ)
@@ -78,7 +78,7 @@ MODULE_AUTHOR("Eliezer Tamir <eliezert@broadcom.com>");
 MODULE_DESCRIPTION("Broadcom NetXtreme II BCM57710 Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_MODULE_VERSION);
-MODULE_INFO(cvs_version, "$Revision: #356 $");
+MODULE_INFO(cvs_version, "$Revision: #404 $");
 
 static int use_inta;
 static int poll;
@@ -1181,12 +1181,175 @@ static u32 bnx2x_bits_dis(struct bnx2x *bp, u32 reg, u32 bits)
 	return val;
 }
 
+static int bnx2x_hw_lock(struct bnx2x *bp, u32 resource)
+{
+	u32 cnt;
+	u32 lock_status;
+	u32 resource_bit = (1 << resource);
+	u8 func = bp->port;
+
+	/* Validating that the resource is within range */
+	if (resource > HW_LOCK_MAX_RESOURCE_VALUE) {
+		DP(NETIF_MSG_HW,
+		   "resource(0x%x) > HW_LOCK_MAX_RESOURCE_VALUE(0x%x)\n",
+		   resource, HW_LOCK_MAX_RESOURCE_VALUE);
+		return -EINVAL;
+	}
+
+	/* Validating that the resource is not already taken */
+	lock_status = REG_RD(bp, MISC_REG_DRIVER_CONTROL_1 + func*8);
+	if (lock_status & resource_bit) {
+		DP(NETIF_MSG_HW, "lock_status 0x%x  resource_bit 0x%x\n",
+		   lock_status, resource_bit);
+		return -EEXIST;
+	}
+
+	/* Try for 1 second every 5ms */
+	for (cnt = 0; cnt < 200; cnt++) {
+		/* Try to acquire the lock */
+		REG_WR(bp, MISC_REG_DRIVER_CONTROL_1 + func*8 + 4,
+		       resource_bit);
+		lock_status = REG_RD(bp, MISC_REG_DRIVER_CONTROL_1 + func*8);
+		if (lock_status & resource_bit)
+			return 0;
+
+		msleep(5);
+	}
+	DP(NETIF_MSG_HW, "Timeout\n");
+	return -EAGAIN;
+}
+
+static int bnx2x_hw_unlock(struct bnx2x *bp, u32 resource)
+{
+	u32 lock_status;
+	u32 resource_bit = (1 << resource);
+	u8 func = bp->port;
+
+	/* Validating that the resource is within range */
+	if (resource > HW_LOCK_MAX_RESOURCE_VALUE) {
+		DP(NETIF_MSG_HW,
+		   "resource(0x%x) > HW_LOCK_MAX_RESOURCE_VALUE(0x%x)\n",
+		   resource, HW_LOCK_MAX_RESOURCE_VALUE);
+		return -EINVAL;
+	}
+
+	/* Validating that the resource is currently taken */
+	lock_status = REG_RD(bp, MISC_REG_DRIVER_CONTROL_1 + func*8);
+	if (!(lock_status & resource_bit)) {
+		DP(NETIF_MSG_HW, "lock_status 0x%x  resource_bit 0x%x\n",
+		   lock_status, resource_bit);
+		return -EFAULT;
+	}
+
+	REG_WR(bp, MISC_REG_DRIVER_CONTROL_1 + func*8, resource_bit);
+	return 0;
+}
+
+static int bnx2x_set_gpio(struct bnx2x *bp, int gpio_num, u32 mode)
+{
+	/* The GPIO should be swapped if swap register is set and active */
+	int gpio_port = (REG_RD(bp, NIG_REG_PORT_SWAP) &&
+			 REG_RD(bp, NIG_REG_STRAP_OVERRIDE)) ^ bp->port;
+	int gpio_shift = gpio_num +
+			(gpio_port ? MISC_REGISTERS_GPIO_PORT_SHIFT : 0);
+	u32 gpio_mask = (1 << gpio_shift);
+	u32 gpio_reg;
+
+	if (gpio_num > MISC_REGISTERS_GPIO_3) {
+		BNX2X_ERR("Invalid GPIO %d\n", gpio_num);
+		return -EINVAL;
+	}
+
+	bnx2x_hw_lock(bp, HW_LOCK_RESOURCE_GPIO);
+	/* read GPIO and mask except the float bits */
+	gpio_reg = (REG_RD(bp, MISC_REG_GPIO) & MISC_REGISTERS_GPIO_FLOAT);
+
+	switch (mode) {
+	case MISC_REGISTERS_GPIO_OUTPUT_LOW:
+		DP(NETIF_MSG_LINK, "Set GPIO %d (shift %d) -> output low\n",
+		   gpio_num, gpio_shift);
+		/* clear FLOAT and set CLR */
+		gpio_reg &= ~(gpio_mask << MISC_REGISTERS_GPIO_FLOAT_POS);
+		gpio_reg |=  (gpio_mask << MISC_REGISTERS_GPIO_CLR_POS);
+		break;
+
+	case MISC_REGISTERS_GPIO_OUTPUT_HIGH:
+		DP(NETIF_MSG_LINK, "Set GPIO %d (shift %d) -> output high\n",
+		   gpio_num, gpio_shift);
+		/* clear FLOAT and set SET */
+		gpio_reg &= ~(gpio_mask << MISC_REGISTERS_GPIO_FLOAT_POS);
+		gpio_reg |=  (gpio_mask << MISC_REGISTERS_GPIO_SET_POS);
+		break;
+
+	case MISC_REGISTERS_GPIO_INPUT_HI_Z :
+		DP(NETIF_MSG_LINK, "Set GPIO %d (shift %d) -> input\n",
+		   gpio_num, gpio_shift);
+		/* set FLOAT */
+		gpio_reg |= (gpio_mask << MISC_REGISTERS_GPIO_FLOAT_POS);
+		break;
+
+	default:
+		break;
+	}
+
+	REG_WR(bp, MISC_REG_GPIO, gpio_reg);
+	bnx2x_hw_unlock(bp, HW_LOCK_RESOURCE_GPIO);
+
+	return 0;
+}
+
+static int bnx2x_set_spio(struct bnx2x *bp, int spio_num, u32 mode)
+{
+	u32 spio_mask = (1 << spio_num);
+	u32 spio_reg;
+
+	if ((spio_num < MISC_REGISTERS_SPIO_4) ||
+	    (spio_num > MISC_REGISTERS_SPIO_7)) {
+		BNX2X_ERR("Invalid SPIO %d\n", spio_num);
+		return -EINVAL;
+	}
+
+	bnx2x_hw_lock(bp, HW_LOCK_RESOURCE_SPIO);
+	/* read SPIO and mask except the float bits */
+	spio_reg = (REG_RD(bp, MISC_REG_SPIO) & MISC_REGISTERS_SPIO_FLOAT);
+
+	switch (mode) {
+	case MISC_REGISTERS_SPIO_OUTPUT_LOW :
+		DP(NETIF_MSG_LINK, "Set SPIO %d -> output low\n", spio_num);
+		/* clear FLOAT and set CLR */
+		spio_reg &= ~(spio_mask << MISC_REGISTERS_SPIO_FLOAT_POS);
+		spio_reg |=  (spio_mask << MISC_REGISTERS_SPIO_CLR_POS);
+		break;
+
+	case MISC_REGISTERS_SPIO_OUTPUT_HIGH :
+		DP(NETIF_MSG_LINK, "Set SPIO %d -> output high\n", spio_num);
+		/* clear FLOAT and set SET */
+		spio_reg &= ~(spio_mask << MISC_REGISTERS_SPIO_FLOAT_POS);
+		spio_reg |=  (spio_mask << MISC_REGISTERS_SPIO_SET_POS);
+		break;
+
+	case MISC_REGISTERS_SPIO_INPUT_HI_Z:
+		DP(NETIF_MSG_LINK, "Set SPIO %d -> input\n", spio_num);
+		/* set FLOAT */
+		spio_reg |= (spio_mask << MISC_REGISTERS_SPIO_FLOAT_POS);
+		break;
+
+	default:
+		break;
+	}
+
+	REG_WR(bp, MISC_REG_SPIO, spio_reg);
+	bnx2x_hw_unlock(bp, HW_LOCK_RESOURCE_SPIO);
+
+	return 0;
+}
+
 static int bnx2x_mdio22_write(struct bnx2x *bp, u32 reg, u32 val)
 {
-	int rc;
-	u32 tmp, i;
 	int port = bp->port;
 	u32 emac_base = port ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
+	u32 tmp;
+	int i, rc;
 
 /*      DP(NETIF_MSG_HW, "phy_addr 0x%x  reg 0x%x  val 0x%08x\n",
 	   bp->phy_addr, reg, val); */
@@ -1238,8 +1401,8 @@ static int bnx2x_mdio22_read(struct bnx2x *bp, u32 reg, u32 *ret_val)
 {
 	int port = bp->port;
 	u32 emac_base = port ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
-	u32 val, i;
-	int rc;
+	u32 val;
+	int i, rc;
 
 	if (bp->phy_flags & PHY_INT_MODE_AUTO_POLLING_FLAG) {
 
@@ -1288,58 +1451,54 @@ static int bnx2x_mdio22_read(struct bnx2x *bp, u32 reg, u32 *ret_val)
 	return rc;
 }
 
-static int bnx2x_mdio45_write(struct bnx2x *bp, u32 reg, u32 addr, u32 val)
+static int bnx2x_mdio45_ctrl_write(struct bnx2x *bp, u32 mdio_ctrl,
+				   u32 phy_addr, u32 reg, u32 addr, u32 val)
 {
-	int rc = 0;
-	u32 tmp, i;
-	int port = bp->port;
-	u32 emac_base = port ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
-
-	if (bp->phy_flags & PHY_INT_MODE_AUTO_POLLING_FLAG) {
-
-		tmp = REG_RD(bp, emac_base + EMAC_REG_EMAC_MDIO_MODE);
-		tmp &= ~EMAC_MDIO_MODE_AUTO_POLL;
-		EMAC_WR(EMAC_REG_EMAC_MDIO_MODE, tmp);
-		REG_RD(bp, emac_base + EMAC_REG_EMAC_MDIO_MODE);
-		udelay(40);
-	}
+	u32 tmp;
+	int i, rc = 0;
 
-	/* set clause 45 mode */
-	tmp = REG_RD(bp, emac_base + EMAC_REG_EMAC_MDIO_MODE);
-	tmp |= EMAC_MDIO_MODE_CLAUSE_45;
-	EMAC_WR(EMAC_REG_EMAC_MDIO_MODE, tmp);
+	/* set clause 45 mode, slow down the MDIO clock to 2.5MHz
+	 * (a value of 49==0x31) and make sure that the AUTO poll is off
+	 */
+	tmp = REG_RD(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE);
+	tmp &= ~(EMAC_MDIO_MODE_AUTO_POLL | EMAC_MDIO_MODE_CLOCK_CNT);
+	tmp |= (EMAC_MDIO_MODE_CLAUSE_45 |
+		(49 << EMAC_MDIO_MODE_CLOCK_CNT_BITSHIFT));
+	REG_WR(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE, tmp);
+	REG_RD(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE);
+	udelay(40);
 
 	/* address */
-	tmp = ((bp->phy_addr << 21) | (reg << 16) | addr |
+	tmp = ((phy_addr << 21) | (reg << 16) | addr |
 	       EMAC_MDIO_COMM_COMMAND_ADDRESS |
 	       EMAC_MDIO_COMM_START_BUSY);
-	EMAC_WR(EMAC_REG_EMAC_MDIO_COMM, tmp);
+	REG_WR(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_COMM, tmp);
 
 	for (i = 0; i < 50; i++) {
 		udelay(10);
 
-		tmp = REG_RD(bp, emac_base + EMAC_REG_EMAC_MDIO_COMM);
+		tmp = REG_RD(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_COMM);
 		if (!(tmp & EMAC_MDIO_COMM_START_BUSY)) {
 			udelay(5);
 			break;
 		}
 	}
-
 	if (tmp & EMAC_MDIO_COMM_START_BUSY) {
 		BNX2X_ERR("write phy register failed\n");
 
 		rc = -EBUSY;
+
 	} else {
 		/* data */
-		tmp = ((bp->phy_addr << 21) | (reg << 16) | val |
+		tmp = ((phy_addr << 21) | (reg << 16) | val |
 		       EMAC_MDIO_COMM_COMMAND_WRITE_45 |
 		       EMAC_MDIO_COMM_START_BUSY);
-		EMAC_WR(EMAC_REG_EMAC_MDIO_COMM, tmp);
+		REG_WR(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_COMM, tmp);
 
 		for (i = 0; i < 50; i++) {
 			udelay(10);
 
-			tmp = REG_RD(bp, emac_base + EMAC_REG_EMAC_MDIO_COMM);
+			tmp = REG_RD(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_COMM);
 			if (!(tmp & EMAC_MDIO_COMM_START_BUSY)) {
 				udelay(5);
 				break;
@@ -1353,75 +1512,78 @@ static int bnx2x_mdio45_write(struct bnx2x *bp, u32 reg, u32 addr, u32 val)
 		}
 	}
 
-	/* unset clause 45 mode */
-	tmp = REG_RD(bp, emac_base + EMAC_REG_EMAC_MDIO_MODE);
-	tmp &= ~EMAC_MDIO_MODE_CLAUSE_45;
-	EMAC_WR(EMAC_REG_EMAC_MDIO_MODE, tmp);
-
-	if (bp->phy_flags & PHY_INT_MODE_AUTO_POLLING_FLAG) {
-
-		tmp = REG_RD(bp, emac_base + EMAC_REG_EMAC_MDIO_MODE);
+	/* unset clause 45 mode, set the MDIO clock to a faster value
+	 * (0x13 => 6.25Mhz) and restore the AUTO poll if needed
+	 */
+	tmp = REG_RD(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE);
+	tmp &= ~(EMAC_MDIO_MODE_CLAUSE_45 | EMAC_MDIO_MODE_CLOCK_CNT);
+	tmp |= (0x13 << EMAC_MDIO_MODE_CLOCK_CNT_BITSHIFT);
+	if (bp->phy_flags & PHY_INT_MODE_AUTO_POLLING_FLAG)
 		tmp |= EMAC_MDIO_MODE_AUTO_POLL;
-		EMAC_WR(EMAC_REG_EMAC_MDIO_MODE, tmp);
-	}
+	REG_WR(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE, tmp);
 
 	return rc;
 }
 
-static int bnx2x_mdio45_read(struct bnx2x *bp, u32 reg, u32 addr,
-			     u32 *ret_val)
+static int bnx2x_mdio45_write(struct bnx2x *bp, u32 phy_addr, u32 reg,
+			      u32 addr, u32 val)
 {
-	int port = bp->port;
-	u32 emac_base = port ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
-	u32 val, i;
-	int rc = 0;
+	u32 emac_base = bp->port ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
 
-	if (bp->phy_flags & PHY_INT_MODE_AUTO_POLLING_FLAG) {
+	return bnx2x_mdio45_ctrl_write(bp, emac_base, phy_addr,
+				       reg, addr, val);
+}
 
-		val = REG_RD(bp, emac_base + EMAC_REG_EMAC_MDIO_MODE);
-		val &= ~EMAC_MDIO_MODE_AUTO_POLL;
-		EMAC_WR(EMAC_REG_EMAC_MDIO_MODE, val);
-		REG_RD(bp, emac_base + EMAC_REG_EMAC_MDIO_MODE);
-		udelay(40);
-	}
+static int bnx2x_mdio45_ctrl_read(struct bnx2x *bp, u32 mdio_ctrl,
+				  u32 phy_addr, u32 reg, u32 addr,
+				  u32 *ret_val)
+{
+	u32 val;
+	int i, rc = 0;
 
-	/* set clause 45 mode */
-	val = REG_RD(bp, emac_base + EMAC_REG_EMAC_MDIO_MODE);
-	val |= EMAC_MDIO_MODE_CLAUSE_45;
-	EMAC_WR(EMAC_REG_EMAC_MDIO_MODE, val);
+	/* set clause 45 mode, slow down the MDIO clock to 2.5MHz
+	 * (a value of 49==0x31) and make sure that the AUTO poll is off
+	 */
+	val = REG_RD(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE);
+	val &= ~(EMAC_MDIO_MODE_AUTO_POLL | EMAC_MDIO_MODE_CLOCK_CNT);
+	val |= (EMAC_MDIO_MODE_CLAUSE_45 |
+		(49 << EMAC_MDIO_MODE_CLOCK_CNT_BITSHIFT));
+	REG_WR(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE, val);
+	REG_RD(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE);
+	udelay(40);
 
 	/* address */
-	val = ((bp->phy_addr << 21) | (reg << 16) | addr |
+	val = ((phy_addr << 21) | (reg << 16) | addr |
 	       EMAC_MDIO_COMM_COMMAND_ADDRESS |
 	       EMAC_MDIO_COMM_START_BUSY);
-	EMAC_WR(EMAC_REG_EMAC_MDIO_COMM, val);
+	REG_WR(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_COMM, val);
 
 	for (i = 0; i < 50; i++) {
 		udelay(10);
 
-		val = REG_RD(bp, emac_base + EMAC_REG_EMAC_MDIO_COMM);
+		val = REG_RD(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_COMM);
 		if (!(val & EMAC_MDIO_COMM_START_BUSY)) {
 			udelay(5);
 			break;
 		}
 	}
-
 	if (val & EMAC_MDIO_COMM_START_BUSY) {
 		BNX2X_ERR("read phy register failed\n");
 
 		*ret_val = 0;
 		rc = -EBUSY;
+
 	} else {
 		/* data */
-		val = ((bp->phy_addr << 21) | (reg << 16) |
+		val = ((phy_addr << 21) | (reg << 16) |
 		       EMAC_MDIO_COMM_COMMAND_READ_45 |
 		       EMAC_MDIO_COMM_START_BUSY);
-		EMAC_WR(EMAC_REG_EMAC_MDIO_COMM, val);
+		REG_WR(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_COMM, val);
 
 		for (i = 0; i < 50; i++) {
 			udelay(10);
 
-			val = REG_RD(bp, emac_base + EMAC_REG_EMAC_MDIO_COMM);
+			val = REG_RD(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_COMM);
 			if (!(val & EMAC_MDIO_COMM_START_BUSY)) {
 				val &= EMAC_MDIO_COMM_DATA;
 				break;
@@ -1438,31 +1600,39 @@ static int bnx2x_mdio45_read(struct bnx2x *bp, u32 reg, u32 addr,
 		*ret_val = val;
 	}
 
-	/* unset clause 45 mode */
-	val = REG_RD(bp, emac_base + EMAC_REG_EMAC_MDIO_MODE);
-	val &= ~EMAC_MDIO_MODE_CLAUSE_45;
-	EMAC_WR(EMAC_REG_EMAC_MDIO_MODE, val);
-
-	if (bp->phy_flags & PHY_INT_MODE_AUTO_POLLING_FLAG) {
-
-		val = REG_RD(bp, emac_base + EMAC_REG_EMAC_MDIO_MODE);
+	/* unset clause 45 mode, set the MDIO clock to a faster value
+	 * (0x13 => 6.25Mhz) and restore the AUTO poll if needed
+	 */
+	val = REG_RD(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE);
+	val &= ~(EMAC_MDIO_MODE_CLAUSE_45 | EMAC_MDIO_MODE_CLOCK_CNT);
+	val |= (0x13 << EMAC_MDIO_MODE_CLOCK_CNT_BITSHIFT);
+	if (bp->phy_flags & PHY_INT_MODE_AUTO_POLLING_FLAG)
 		val |= EMAC_MDIO_MODE_AUTO_POLL;
-		EMAC_WR(EMAC_REG_EMAC_MDIO_MODE, val);
-	}
+	REG_WR(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE, val);
 
 	return rc;
 }
 
-static int bnx2x_mdio45_vwrite(struct bnx2x *bp, u32 reg, u32 addr, u32 val)
+static int bnx2x_mdio45_read(struct bnx2x *bp, u32 phy_addr, u32 reg,
+			     u32 addr, u32 *ret_val)
+{
+	u32 emac_base = bp->port ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
+
+	return bnx2x_mdio45_ctrl_read(bp, emac_base, phy_addr,
+				      reg, addr, ret_val);
+}
+
+static int bnx2x_mdio45_vwrite(struct bnx2x *bp, u32 phy_addr, u32 reg,
+			       u32 addr, u32 val)
 {
 	int i;
 	u32 rd_val;
 
 	might_sleep();
 	for (i = 0; i < 10; i++) {
-		bnx2x_mdio45_write(bp, reg, addr, val);
+		bnx2x_mdio45_write(bp, phy_addr, reg, addr, val);
 		msleep(5);
-		bnx2x_mdio45_read(bp, reg, addr, &rd_val);
+		bnx2x_mdio45_read(bp, phy_addr, reg, addr, &rd_val);
 		/* if the read value is not the same as the value we wrote,
 		   we should write it again */
 		if (rd_val == val)
@@ -1476,10 +1646,73 @@ static int bnx2x_mdio45_vwrite(struct bnx2x *bp, u32 reg, u32 addr, u32 val)
  * link management
  */
 
+static void bnx2x_pause_resolve(struct bnx2x *bp, u32 pause_result)
+{
+	switch (pause_result) {			/* ASYM P ASYM P */
+	case 0xb:				/*   1  0   1  1 */
+		bp->flow_ctrl = FLOW_CTRL_TX;
+		break;
+
+	case 0xe:				/*   1  1   1  0 */
+		bp->flow_ctrl = FLOW_CTRL_RX;
+		break;
+
+	case 0x5:				/*   0  1   0  1 */
+	case 0x7:				/*   0  1   1  1 */
+	case 0xd:				/*   1  1   0  1 */
+	case 0xf:				/*   1  1   1  1 */
+		bp->flow_ctrl = FLOW_CTRL_BOTH;
+		break;
+
+	default:
+		break;
+	}
+}
+
+static u8 bnx2x_ext_phy_resove_fc(struct bnx2x *bp)
+{
+	u32 ext_phy_addr;
+	u32 ld_pause;	/* local */
+	u32 lp_pause;	/* link partner */
+	u32 an_complete; /* AN complete */
+	u32 pause_result;
+	u8 ret = 0;
+
+	ext_phy_addr = ((bp->ext_phy_config &
+			 PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
+					PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
+
+	/* read twice */
+	bnx2x_mdio45_read(bp, ext_phy_addr,
+			  EXT_PHY_KR_AUTO_NEG_DEVAD,
+			  EXT_PHY_KR_STATUS, &an_complete);
+	bnx2x_mdio45_read(bp, ext_phy_addr,
+			  EXT_PHY_KR_AUTO_NEG_DEVAD,
+			  EXT_PHY_KR_STATUS, &an_complete);
+
+	if (an_complete & EXT_PHY_KR_AUTO_NEG_COMPLETE) {
+		ret = 1;
+		bnx2x_mdio45_read(bp, ext_phy_addr,
+				  EXT_PHY_KR_AUTO_NEG_DEVAD,
+				  EXT_PHY_KR_AUTO_NEG_ADVERT, &ld_pause);
+		bnx2x_mdio45_read(bp, ext_phy_addr,
+				  EXT_PHY_KR_AUTO_NEG_DEVAD,
+				  EXT_PHY_KR_LP_AUTO_NEG, &lp_pause);
+		pause_result = (ld_pause &
+				EXT_PHY_KR_AUTO_NEG_ADVERT_PAUSE_MASK) >> 8;
+		pause_result |= (lp_pause &
+				 EXT_PHY_KR_AUTO_NEG_ADVERT_PAUSE_MASK) >> 10;
+		DP(NETIF_MSG_LINK, "Ext PHY pause result 0x%x \n",
+		   pause_result);
+		bnx2x_pause_resolve(bp, pause_result);
+	}
+	return ret;
+}
+
 static void bnx2x_flow_ctrl_resolve(struct bnx2x *bp, u32 gp_status)
 {
-	u32 ld_pause;   /* local driver */
-	u32 lp_pause;   /* link partner */
+	u32 ld_pause;	/* local driver */
+	u32 lp_pause;	/* link partner */
 	u32 pause_result;
 
 	bp->flow_ctrl = 0;
@@ -1501,45 +1734,57 @@ static void bnx2x_flow_ctrl_resolve(struct bnx2x *bp, u32 gp_status)
 		pause_result |= (lp_pause &
 				 MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_MASK)>>7;
 		DP(NETIF_MSG_LINK, "pause_result 0x%x\n", pause_result);
+		bnx2x_pause_resolve(bp, pause_result);
+	} else if (!(bp->req_autoneg & AUTONEG_FLOW_CTRL) ||
+		   !(bnx2x_ext_phy_resove_fc(bp))) {
+		/* forced speed */
+		if (bp->req_autoneg & AUTONEG_FLOW_CTRL) {
+			switch (bp->req_flow_ctrl) {
+			case FLOW_CTRL_AUTO:
+				if (bp->dev->mtu <= 4500)
+					bp->flow_ctrl = FLOW_CTRL_BOTH;
+				else
+					bp->flow_ctrl = FLOW_CTRL_TX;
+				break;
 
-		switch (pause_result) { 		/* ASYM P ASYM P */
-		case 0xb:       			/*   1  0   1  1 */
-			bp->flow_ctrl = FLOW_CTRL_TX;
-			break;
-
-		case 0xe:       			/*   1  1   1  0 */
-			bp->flow_ctrl = FLOW_CTRL_RX;
-			break;
+			case FLOW_CTRL_TX:
+				bp->flow_ctrl = FLOW_CTRL_TX;
+				break;
 
-		case 0x5:       			/*   0  1   0  1 */
-		case 0x7:       			/*   0  1   1  1 */
-		case 0xd:       			/*   1  1   0  1 */
-		case 0xf:       			/*   1  1   1  1 */
-			bp->flow_ctrl = FLOW_CTRL_BOTH;
-			break;
+			case FLOW_CTRL_RX:
+				if (bp->dev->mtu <= 4500)
+					bp->flow_ctrl = FLOW_CTRL_RX;
+				break;
 
-		default:
-			break;
-		}
+			case FLOW_CTRL_BOTH:
+				if (bp->dev->mtu <= 4500)
+					bp->flow_ctrl = FLOW_CTRL_BOTH;
+				else
+					bp->flow_ctrl = FLOW_CTRL_TX;
+				break;
 
-	} else { /* forced mode */
-		switch (bp->req_flow_ctrl) {
-		case FLOW_CTRL_AUTO:
-			if (bp->dev->mtu <= 4500)
-				bp->flow_ctrl = FLOW_CTRL_BOTH;
-			else
-				bp->flow_ctrl = FLOW_CTRL_TX;
-			break;
+			case FLOW_CTRL_NONE:
+			default:
+				break;
+			}
+		} else { /* forced mode */
+			switch (bp->req_flow_ctrl) {
+			case FLOW_CTRL_AUTO:
+				DP(NETIF_MSG_LINK, "req_flow_ctrl 0x%x while"
+						   " req_autoneg 0x%x\n",
+				   bp->req_flow_ctrl, bp->req_autoneg);
+				break;
 
-		case FLOW_CTRL_TX:
-		case FLOW_CTRL_RX:
-		case FLOW_CTRL_BOTH:
-			bp->flow_ctrl = bp->req_flow_ctrl;
-			break;
+			case FLOW_CTRL_TX:
+			case FLOW_CTRL_RX:
+			case FLOW_CTRL_BOTH:
+				bp->flow_ctrl = bp->req_flow_ctrl;
+				break;
 
-		case FLOW_CTRL_NONE:
-		default:
-			break;
+			case FLOW_CTRL_NONE:
+			default:
+				break;
+			}
 		}
 	}
 	DP(NETIF_MSG_LINK, "flow_ctrl 0x%x\n", bp->flow_ctrl);
@@ -1550,9 +1795,9 @@ static void bnx2x_link_settings_status(struct bnx2x *bp, u32 gp_status)
 	bp->link_status = 0;
 
 	if (gp_status & MDIO_GP_STATUS_TOP_AN_STATUS1_LINK_STATUS) {
-		DP(NETIF_MSG_LINK, "link up\n");
+		DP(NETIF_MSG_LINK, "phy link up\n");
 
-		bp->link_up = 1;
+		bp->phy_link_up = 1;
 		bp->link_status |= LINK_STATUS_LINK_UP;
 
 		if (gp_status & MDIO_GP_STATUS_TOP_AN_STATUS1_DUPLEX_STATUS)
@@ -1661,20 +1906,20 @@ static void bnx2x_link_settings_status(struct bnx2x *bp, u32 gp_status)
 		       bp->link_status |= LINK_STATUS_RX_FLOW_CONTROL_ENABLED;
 
 	} else { /* link_down */
-		DP(NETIF_MSG_LINK, "link down\n");
+		DP(NETIF_MSG_LINK, "phy link down\n");
 
-		bp->link_up = 0;
+		bp->phy_link_up = 0;
 
 		bp->line_speed = 0;
 		bp->duplex = DUPLEX_FULL;
 		bp->flow_ctrl = 0;
 	}
 
-	DP(NETIF_MSG_LINK, "gp_status 0x%x  link_up %d\n"
+	DP(NETIF_MSG_LINK, "gp_status 0x%x  phy_link_up %d\n"
 	   DP_LEVEL "  line_speed %d  duplex %d  flow_ctrl 0x%x"
 		    "  link_status 0x%x\n",
-	   gp_status, bp->link_up, bp->line_speed, bp->duplex, bp->flow_ctrl,
-	   bp->link_status);
+	   gp_status, bp->phy_link_up, bp->line_speed, bp->duplex,
+	   bp->flow_ctrl, bp->link_status);
 }
 
 static void bnx2x_link_int_ack(struct bnx2x *bp, int is_10g)
@@ -1684,38 +1929,38 @@ static void bnx2x_link_int_ack(struct bnx2x *bp, int is_10g)
 	/* first reset all status
 	 * we assume only one line will be change at a time */
 	bnx2x_bits_dis(bp, NIG_REG_STATUS_INTERRUPT_PORT0 + port*4,
-		       (NIG_XGXS0_LINK_STATUS |
-			NIG_SERDES0_LINK_STATUS |
-			NIG_STATUS_INTERRUPT_XGXS0_LINK10G));
-	if (bp->link_up) {
+		       (NIG_STATUS_XGXS0_LINK10G |
+			NIG_STATUS_XGXS0_LINK_STATUS |
+			NIG_STATUS_SERDES0_LINK_STATUS));
+	if (bp->phy_link_up) {
 		if (is_10g) {
 			/* Disable the 10G link interrupt
 			 * by writing 1 to the status register
 			 */
-			DP(NETIF_MSG_LINK, "10G XGXS link up\n");
+			DP(NETIF_MSG_LINK, "10G XGXS phy link up\n");
 			bnx2x_bits_en(bp,
 				      NIG_REG_STATUS_INTERRUPT_PORT0 + port*4,
-				      NIG_STATUS_INTERRUPT_XGXS0_LINK10G);
+				      NIG_STATUS_XGXS0_LINK10G);
 
 		} else if (bp->phy_flags & PHY_XGXS_FLAG) {
 			/* Disable the link interrupt
 			 * by writing 1 to the relevant lane
 			 * in the status register
 			 */
-			DP(NETIF_MSG_LINK, "1G XGXS link up\n");
+			DP(NETIF_MSG_LINK, "1G XGXS phy link up\n");
 			bnx2x_bits_en(bp,
 				      NIG_REG_STATUS_INTERRUPT_PORT0 + port*4,
 				      ((1 << bp->ser_lane) <<
-				       NIG_XGXS0_LINK_STATUS_SIZE));
+				       NIG_STATUS_XGXS0_LINK_STATUS_SIZE));
 
 		} else { /* SerDes */
-			DP(NETIF_MSG_LINK, "SerDes link up\n");
+			DP(NETIF_MSG_LINK, "SerDes phy link up\n");
 			/* Disable the link interrupt
 			 * by writing 1 to the status register
 			 */
 			bnx2x_bits_en(bp,
 				      NIG_REG_STATUS_INTERRUPT_PORT0 + port*4,
-				      NIG_SERDES0_LINK_STATUS);
+				      NIG_STATUS_SERDES0_LINK_STATUS);
 		}
 
 	} else { /* link_down */
@@ -1726,91 +1971,182 @@ static int bnx2x_ext_phy_is_link_up(struct bnx2x *bp)
 {
 	u32 ext_phy_type;
 	u32 ext_phy_addr;
-	u32 local_phy;
-	u32 val = 0;
+	u32 val1 = 0, val2;
 	u32 rx_sd, pcs_status;
 
 	if (bp->phy_flags & PHY_XGXS_FLAG) {
-		local_phy = bp->phy_addr;
 		ext_phy_addr = ((bp->ext_phy_config &
 				 PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
 				PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
-		bp->phy_addr = (u8)ext_phy_addr;
 
 		ext_phy_type = XGXS_EXT_PHY_TYPE(bp);
 		switch (ext_phy_type) {
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT:
 			DP(NETIF_MSG_LINK, "XGXS Direct\n");
-			val = 1;
+			val1 = 1;
 			break;
 
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705:
 			DP(NETIF_MSG_LINK, "XGXS 8705\n");
-			bnx2x_mdio45_read(bp, EXT_PHY_OPT_WIS_DEVAD,
-					  EXT_PHY_OPT_LASI_STATUS, &val);
-			DP(NETIF_MSG_LINK, "8705 LASI status is %d\n", val);
-
-			bnx2x_mdio45_read(bp, EXT_PHY_OPT_WIS_DEVAD,
-					  EXT_PHY_OPT_LASI_STATUS, &val);
-			DP(NETIF_MSG_LINK, "8705 LASI status is %d\n", val);
-
-			bnx2x_mdio45_read(bp, EXT_PHY_OPT_PMA_PMD_DEVAD,
+			bnx2x_mdio45_read(bp, ext_phy_addr,
+					  EXT_PHY_OPT_WIS_DEVAD,
+					  EXT_PHY_OPT_LASI_STATUS, &val1);
+			DP(NETIF_MSG_LINK, "8705 LASI status 0x%x\n", val1);
+
+			bnx2x_mdio45_read(bp, ext_phy_addr,
+					  EXT_PHY_OPT_WIS_DEVAD,
+					  EXT_PHY_OPT_LASI_STATUS, &val1);
+			DP(NETIF_MSG_LINK, "8705 LASI status 0x%x\n", val1);
+
+			bnx2x_mdio45_read(bp, ext_phy_addr,
+					  EXT_PHY_OPT_PMA_PMD_DEVAD,
 					  EXT_PHY_OPT_PMD_RX_SD, &rx_sd);
-			val = (rx_sd & 0x1);
+			DP(NETIF_MSG_LINK, "8705 rx_sd 0x%x\n", rx_sd);
+			val1 = (rx_sd & 0x1);
 			break;
 
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706:
 			DP(NETIF_MSG_LINK, "XGXS 8706\n");
-			bnx2x_mdio45_read(bp, EXT_PHY_OPT_PMA_PMD_DEVAD,
-					  EXT_PHY_OPT_LASI_STATUS, &val);
-			DP(NETIF_MSG_LINK, "8706 LASI status is %d\n", val);
-
-			bnx2x_mdio45_read(bp, EXT_PHY_OPT_PMA_PMD_DEVAD,
-					  EXT_PHY_OPT_LASI_STATUS, &val);
-			DP(NETIF_MSG_LINK, "8706 LASI status is %d\n", val);
-
-			bnx2x_mdio45_read(bp, EXT_PHY_OPT_PMA_PMD_DEVAD,
+			bnx2x_mdio45_read(bp, ext_phy_addr,
+					  EXT_PHY_OPT_PMA_PMD_DEVAD,
+					  EXT_PHY_OPT_LASI_STATUS, &val1);
+			DP(NETIF_MSG_LINK, "8706 LASI status 0x%x\n", val1);
+
+			bnx2x_mdio45_read(bp, ext_phy_addr,
+					  EXT_PHY_OPT_PMA_PMD_DEVAD,
+					  EXT_PHY_OPT_LASI_STATUS, &val1);
+			DP(NETIF_MSG_LINK, "8706 LASI status 0x%x\n", val1);
+
+			bnx2x_mdio45_read(bp, ext_phy_addr,
+					  EXT_PHY_OPT_PMA_PMD_DEVAD,
 					  EXT_PHY_OPT_PMD_RX_SD, &rx_sd);
-			bnx2x_mdio45_read(bp, EXT_PHY_OPT_PCS_DEVAD,
-					 EXT_PHY_OPT_PCS_STATUS, &pcs_status);
+			bnx2x_mdio45_read(bp, ext_phy_addr,
+					  EXT_PHY_OPT_PCS_DEVAD,
+					  EXT_PHY_OPT_PCS_STATUS, &pcs_status);
+			bnx2x_mdio45_read(bp, ext_phy_addr,
+					  EXT_PHY_AUTO_NEG_DEVAD,
+					  EXT_PHY_OPT_AN_LINK_STATUS, &val2);
+
 			DP(NETIF_MSG_LINK, "8706 rx_sd 0x%x"
-			   "  pcs_status 0x%x\n", rx_sd, pcs_status);
-			/* link is up if both bit 0 of pmd_rx and
-			 * bit 0 of pcs_status are set
+			   "  pcs_status 0x%x 1Gbps link_status 0x%x 0x%x\n",
+			   rx_sd, pcs_status, val2, (val2 & (1<<1)));
+			/* link is up if both bit 0 of pmd_rx_sd and
+			 * bit 0 of pcs_status are set, or if the autoneg bit
+			   1 is set
+			 */
+			val1 = ((rx_sd & pcs_status & 0x1) || (val2 & (1<<1)));
+			break;
+
+		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072:
+			bnx2x_hw_lock(bp, HW_LOCK_RESOURCE_8072_MDIO);
+
+			/* clear the interrupt LASI status register */
+			bnx2x_mdio45_ctrl_read(bp, GRCBASE_EMAC0,
+					       ext_phy_addr,
+					       EXT_PHY_KR_PCS_DEVAD,
+					       EXT_PHY_KR_LASI_STATUS, &val2);
+			bnx2x_mdio45_ctrl_read(bp, GRCBASE_EMAC0,
+					       ext_phy_addr,
+					       EXT_PHY_KR_PCS_DEVAD,
+					       EXT_PHY_KR_LASI_STATUS, &val1);
+			DP(NETIF_MSG_LINK, "KR LASI status 0x%x->0x%x\n",
+			   val2, val1);
+			/* Check the LASI */
+			bnx2x_mdio45_ctrl_read(bp, GRCBASE_EMAC0,
+					       ext_phy_addr,
+					       EXT_PHY_KR_PMA_PMD_DEVAD,
+					       0x9003, &val2);
+			bnx2x_mdio45_ctrl_read(bp, GRCBASE_EMAC0,
+					       ext_phy_addr,
+					       EXT_PHY_KR_PMA_PMD_DEVAD,
+					       0x9003, &val1);
+			DP(NETIF_MSG_LINK, "KR 0x9003 0x%x->0x%x\n",
+			   val2, val1);
+			/* Check the link status */
+			bnx2x_mdio45_ctrl_read(bp, GRCBASE_EMAC0,
+					       ext_phy_addr,
+					       EXT_PHY_KR_PCS_DEVAD,
+					       EXT_PHY_KR_PCS_STATUS, &val2);
+			DP(NETIF_MSG_LINK, "KR PCS status 0x%x\n", val2);
+			/* Check the link status on 1.1.2 */
+			bnx2x_mdio45_ctrl_read(bp, GRCBASE_EMAC0,
+					  ext_phy_addr,
+					  EXT_PHY_OPT_PMA_PMD_DEVAD,
+					  EXT_PHY_KR_STATUS, &val2);
+			bnx2x_mdio45_ctrl_read(bp, GRCBASE_EMAC0,
+					  ext_phy_addr,
+					  EXT_PHY_OPT_PMA_PMD_DEVAD,
+					  EXT_PHY_KR_STATUS, &val1);
+			DP(NETIF_MSG_LINK,
+			   "KR PMA status 0x%x->0x%x\n", val2, val1);
+			val1 = ((val1 & 4) == 4);
+			/* If 1G was requested assume the link is up */
+			if (!(bp->req_autoneg & AUTONEG_SPEED) &&
+			    (bp->req_line_speed == SPEED_1000))
+				val1 = 1;
+			bnx2x_hw_unlock(bp, HW_LOCK_RESOURCE_8072_MDIO);
+			break;
+
+		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101:
+			bnx2x_mdio45_read(bp, ext_phy_addr,
+					  EXT_PHY_OPT_PMA_PMD_DEVAD,
+					  EXT_PHY_OPT_LASI_STATUS, &val2);
+			bnx2x_mdio45_read(bp, ext_phy_addr,
+					  EXT_PHY_OPT_PMA_PMD_DEVAD,
+					  EXT_PHY_OPT_LASI_STATUS, &val1);
+			DP(NETIF_MSG_LINK,
+			   "10G-base-T LASI status 0x%x->0x%x\n", val2, val1);
+			bnx2x_mdio45_read(bp, ext_phy_addr,
+					  EXT_PHY_OPT_PMA_PMD_DEVAD,
+					  EXT_PHY_KR_STATUS, &val2);
+			bnx2x_mdio45_read(bp, ext_phy_addr,
+					  EXT_PHY_OPT_PMA_PMD_DEVAD,
+					  EXT_PHY_KR_STATUS, &val1);
+			DP(NETIF_MSG_LINK,
+			   "10G-base-T PMA status 0x%x->0x%x\n", val2, val1);
+			val1 = ((val1 & 4) == 4);
+			/* if link is up
+			 * print the AN outcome of the SFX7101 PHY
 			 */
-			val = (rx_sd & pcs_status);
+			if (val1) {
+				bnx2x_mdio45_read(bp, ext_phy_addr,
+						  EXT_PHY_KR_AUTO_NEG_DEVAD,
+						  0x21, &val2);
+				DP(NETIF_MSG_LINK,
+				   "SFX7101 AN status 0x%x->%s\n", val2,
+				   (val2 & (1<<14)) ? "Master" : "Slave");
+			}
 			break;
 
 		default:
 			DP(NETIF_MSG_LINK, "BAD XGXS ext_phy_config 0x%x\n",
 			   bp->ext_phy_config);
-			val = 0;
+			val1 = 0;
 			break;
 		}
-		bp->phy_addr = local_phy;
 
 	} else { /* SerDes */
 		ext_phy_type = SERDES_EXT_PHY_TYPE(bp);
 		switch (ext_phy_type) {
 		case PORT_HW_CFG_SERDES_EXT_PHY_TYPE_DIRECT:
 			DP(NETIF_MSG_LINK, "SerDes Direct\n");
-			val = 1;
+			val1 = 1;
 			break;
 
 		case PORT_HW_CFG_SERDES_EXT_PHY_TYPE_BCM5482:
 			DP(NETIF_MSG_LINK, "SerDes 5482\n");
-			val = 1;
+			val1 = 1;
 			break;
 
 		default:
 			DP(NETIF_MSG_LINK, "BAD SerDes ext_phy_config 0x%x\n",
 			   bp->ext_phy_config);
-			val = 0;
+			val1 = 0;
 			break;
 		}
 	}
 
-	return val;
+	return val1;
 }
 
 static void bnx2x_bmac_enable(struct bnx2x *bp, int is_lb)
@@ -1935,6 +2271,35 @@ static void bnx2x_bmac_enable(struct bnx2x *bp, int is_lb)
 	bp->stats_state = STATS_STATE_ENABLE;
 }
 
+static void bnx2x_bmac_rx_disable(struct bnx2x *bp)
+{
+	int port = bp->port;
+	u32 bmac_addr = port ? NIG_REG_INGRESS_BMAC1_MEM :
+			       NIG_REG_INGRESS_BMAC0_MEM;
+	u32 wb_write[2];
+
+	/* Only if the bmac is out of reset */
+	if (REG_RD(bp, MISC_REG_RESET_REG_2) &
+			(MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << port)) {
+		/* Clear Rx Enable bit in BMAC_CONTROL register */
+#ifdef BNX2X_DMAE_RD
+		bnx2x_read_dmae(bp, bmac_addr +
+				BIGMAC_REGISTER_BMAC_CONTROL, 2);
+		wb_write[0] = *bnx2x_sp(bp, wb_data[0]);
+		wb_write[1] = *bnx2x_sp(bp, wb_data[1]);
+#else
+		wb_write[0] = REG_RD(bp,
+				bmac_addr + BIGMAC_REGISTER_BMAC_CONTROL);
+		wb_write[1] = REG_RD(bp,
+				bmac_addr + BIGMAC_REGISTER_BMAC_CONTROL + 4);
+#endif
+		wb_write[0] &= ~BMAC_CONTROL_RX_ENABLE;
+		REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_BMAC_CONTROL,
+			    wb_write, 2);
+		msleep(1);
+	}
+}
+
 static void bnx2x_emac_enable(struct bnx2x *bp)
 {
 	int port = bp->port;
@@ -2233,7 +2598,7 @@ static void bnx2x_pbf_update(struct bnx2x *bp)
 static void bnx2x_update_mng(struct bnx2x *bp)
 {
 	if (!nomcp)
-		SHMEM_WR(bp, drv_fw_mb[bp->port].link_status,
+		SHMEM_WR(bp, port_mb[bp->port].link_status,
 			 bp->link_status);
 }
 
@@ -2295,19 +2660,19 @@ static void bnx2x_link_down(struct bnx2x *bp)
 		DP(BNX2X_MSG_STATS, "stats_state - STOP\n");
 	}
 
-	/* indicate link down */
+	/* indicate no mac active */
 	bp->phy_flags &= ~(PHY_BMAC_FLAG | PHY_EMAC_FLAG);
 
-	/* reset BigMac */
-	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_CLEAR,
-	       (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << port));
+	/* update shared memory */
+	bnx2x_update_mng(bp);
 
-	/* ignore drain flag interrupt */
 	/* activate nig drain */
 	NIG_WR(NIG_REG_EGRESS_DRAIN0_MODE + port*4, 1);
 
-	/* update shared memory */
-	bnx2x_update_mng(bp);
+	/* reset BigMac */
+	bnx2x_bmac_rx_disable(bp);
+	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_CLEAR,
+	       (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << port));
 
 	/* indicate link down */
 	bnx2x_link_report(bp);
@@ -2318,14 +2683,15 @@ static void bnx2x_init_mac_stats(struct bnx2x *bp);
 /* This function is called upon link interrupt */
 static void bnx2x_link_update(struct bnx2x *bp)
 {
-	u32 gp_status;
 	int port = bp->port;
 	int i;
+	u32 gp_status;
 	int link_10g;
 
-	DP(NETIF_MSG_LINK, "port %x, is xgxs %x, stat_mask 0x%x,"
+	DP(NETIF_MSG_LINK, "port %x, %s, int_status 0x%x,"
 	   " int_mask 0x%x, saved_mask 0x%x, MI_INT %x, SERDES_LINK %x,"
-	   " 10G %x, XGXS_LINK %x\n", port, (bp->phy_flags & PHY_XGXS_FLAG),
+	   " 10G %x, XGXS_LINK %x\n", port,
+	   (bp->phy_flags & PHY_XGXS_FLAG)? "XGXS":"SerDes",
 	   REG_RD(bp, NIG_REG_STATUS_INTERRUPT_PORT0 + port*4),
 	   REG_RD(bp, NIG_REG_MASK_INTERRUPT_PORT0 + port*4), bp->nig_mask,
 	   REG_RD(bp, NIG_REG_EMAC0_STATUS_MISC_MI_INT + port*0x18),
@@ -2337,7 +2703,7 @@ static void bnx2x_link_update(struct bnx2x *bp)
 	might_sleep();
 	MDIO_SET_REG_BANK(bp, MDIO_REG_BANK_GP_STATUS);
 	/* avoid fast toggling */
-	for (i = 0 ; i < 10 ; i++) {
+	for (i = 0; i < 10; i++) {
 		msleep(10);
 		bnx2x_mdio22_read(bp, MDIO_GP_STATUS_TOP_AN_STATUS1,
 				  &gp_status);
@@ -2352,7 +2718,8 @@ static void bnx2x_link_update(struct bnx2x *bp)
 	bnx2x_link_int_ack(bp, link_10g);
 
 	/* link is up only if both local phy and external phy are up */
-	if (bp->link_up && bnx2x_ext_phy_is_link_up(bp)) {
+	bp->link_up = (bp->phy_link_up && bnx2x_ext_phy_is_link_up(bp));
+	if (bp->link_up) {
 		if (link_10g) {
 			bnx2x_bmac_enable(bp, 0);
 			bnx2x_leds_set(bp, SPEED_10000);
@@ -2428,7 +2795,9 @@ static void bnx2x_reset_unicore(struct bnx2x *bp)
 		}
 	}
 
-	BNX2X_ERR("BUG! unicore is still in reset!\n");
+	BNX2X_ERR("BUG! %s (0x%x) is still in reset!\n",
+		  (bp->phy_flags & PHY_XGXS_FLAG)? "XGXS":"SerDes",
+		  bp->phy_addr);
 }
 
 static void bnx2x_set_swap_lanes(struct bnx2x *bp)
@@ -2476,12 +2845,12 @@ static void bnx2x_set_parallel_detection(struct bnx2x *bp)
 		MDIO_SET_REG_BANK(bp, MDIO_REG_BANK_10G_PARALLEL_DETECT);
 
 		bnx2x_mdio22_write(bp,
-				   MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_LINK,
+				MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_LINK,
 			       MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_LINK_CNT);
 
 		bnx2x_mdio22_read(bp,
-				 MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_CONTROL,
-				  &control2);
+				MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_CONTROL,
+				&control2);
 
 		if (bp->autoneg & AUTONEG_PARALLEL) {
 			control2 |=
@@ -2491,8 +2860,14 @@ static void bnx2x_set_parallel_detection(struct bnx2x *bp)
 		   ~MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_CONTROL_PARDET10G_EN;
 		}
 		bnx2x_mdio22_write(bp,
-				 MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_CONTROL,
-				   control2);
+				MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_CONTROL,
+				control2);
+
+		/* Disable parallel detection of HiG */
+		MDIO_SET_REG_BANK(bp, MDIO_REG_BANK_XGXS_BLOCK2);
+		bnx2x_mdio22_write(bp, MDIO_XGXS_BLOCK2_UNICORE_MODE_10G,
+				MDIO_XGXS_BLOCK2_UNICORE_MODE_10G_CX4_XGXS |
+				MDIO_XGXS_BLOCK2_UNICORE_MODE_10G_HIGIG_XGXS);
 	}
 }
 
@@ -2626,7 +3001,7 @@ static void bnx2x_set_brcm_cl37_advertisment(struct bnx2x *bp)
 	MDIO_SET_REG_BANK(bp, MDIO_REG_BANK_OVER_1G);
 
 	/* set extended capabilities */
-	if (bp->advertising & ADVERTISED_2500baseT_Full)
+	if (bp->advertising & ADVERTISED_2500baseX_Full)
 		val |= MDIO_OVER_1G_UP1_2_5G;
 	if (bp->advertising & ADVERTISED_10000baseT_Full)
 		val |= MDIO_OVER_1G_UP1_10G;
@@ -2642,20 +3017,91 @@ static void bnx2x_set_ieee_aneg_advertisment(struct bnx2x *bp)
 	/* for AN, we are always publishing full duplex */
 	an_adv = MDIO_COMBO_IEEE0_AUTO_NEG_ADV_FULL_DUPLEX;
 
-	/* set pause */
-	switch (bp->pause_mode) {
-	case PAUSE_SYMMETRIC:
-		an_adv |= MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_SYMMETRIC;
-		break;
-	case PAUSE_ASYMMETRIC:
-		an_adv |= MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_ASYMMETRIC;
-		break;
-	case PAUSE_BOTH:
-		an_adv |= MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH;
-		break;
-	case PAUSE_NONE:
-		an_adv |= MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_NONE;
-		break;
+	/* resolve pause mode and advertisement
+	 * Please refer to Table 28B-3 of the 802.3ab-1999 spec */
+	if (bp->req_autoneg & AUTONEG_FLOW_CTRL) {
+		switch (bp->req_flow_ctrl) {
+		case FLOW_CTRL_AUTO:
+			if (bp->dev->mtu <= 4500) {
+				an_adv |=
+				     MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH;
+				bp->advertising |= (ADVERTISED_Pause |
+						    ADVERTISED_Asym_Pause);
+			} else {
+				an_adv |=
+			       MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_ASYMMETRIC;
+				bp->advertising |= ADVERTISED_Asym_Pause;
+			}
+			break;
+
+		case FLOW_CTRL_TX:
+			an_adv |=
+			       MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_ASYMMETRIC;
+			bp->advertising |= ADVERTISED_Asym_Pause;
+			break;
+
+		case FLOW_CTRL_RX:
+			if (bp->dev->mtu <= 4500) {
+				an_adv |=
+				     MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH;
+				bp->advertising |= (ADVERTISED_Pause |
+						    ADVERTISED_Asym_Pause);
+			} else {
+				an_adv |=
+				     MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_NONE;
+				bp->advertising &= ~(ADVERTISED_Pause |
+						     ADVERTISED_Asym_Pause);
+			}
+			break;
+
+		case FLOW_CTRL_BOTH:
+			if (bp->dev->mtu <= 4500) {
+				an_adv |=
+				     MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH;
+				bp->advertising |= (ADVERTISED_Pause |
+						    ADVERTISED_Asym_Pause);
+			} else {
+				an_adv |=
+			       MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_ASYMMETRIC;
+				bp->advertising |= ADVERTISED_Asym_Pause;
+			}
+			break;
+
+		case FLOW_CTRL_NONE:
+		default:
+			an_adv |= MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_NONE;
+			bp->advertising &= ~(ADVERTISED_Pause |
+					     ADVERTISED_Asym_Pause);
+			break;
+		}
+	} else { /* forced mode */
+		switch (bp->req_flow_ctrl) {
+		case FLOW_CTRL_AUTO:
+			DP(NETIF_MSG_LINK, "req_flow_ctrl 0x%x while"
+					   " req_autoneg 0x%x\n",
+			   bp->req_flow_ctrl, bp->req_autoneg);
+			break;
+
+		case FLOW_CTRL_TX:
+			an_adv |=
+			       MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_ASYMMETRIC;
+			bp->advertising |= ADVERTISED_Asym_Pause;
+			break;
+
+		case FLOW_CTRL_RX:
+		case FLOW_CTRL_BOTH:
+			an_adv |= MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH;
+			bp->advertising |= (ADVERTISED_Pause |
+					    ADVERTISED_Asym_Pause);
+			break;
+
+		case FLOW_CTRL_NONE:
+		default:
+			an_adv |= MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_NONE;
+			bp->advertising &= ~(ADVERTISED_Pause |
+					     ADVERTISED_Asym_Pause);
+			break;
+		}
 	}
 
 	MDIO_SET_REG_BANK(bp, MDIO_REG_BANK_COMBO_IEEE0);
@@ -2753,47 +3199,162 @@ static void bnx2x_initialize_sgmii_process(struct bnx2x *bp)
 static void bnx2x_link_int_enable(struct bnx2x *bp)
 {
 	int port = bp->port;
+	u32 ext_phy_type;
+	u32 mask;
 
 	/* setting the status to report on link up
 	   for either XGXS or SerDes */
 	bnx2x_bits_dis(bp, NIG_REG_STATUS_INTERRUPT_PORT0 + port*4,
-		       (NIG_XGXS0_LINK_STATUS |
-			NIG_STATUS_INTERRUPT_XGXS0_LINK10G |
-			NIG_SERDES0_LINK_STATUS));
+		       (NIG_STATUS_XGXS0_LINK10G |
+			NIG_STATUS_XGXS0_LINK_STATUS |
+			NIG_STATUS_SERDES0_LINK_STATUS));
 
 	if (bp->phy_flags & PHY_XGXS_FLAG) {
-		/* TBD -
-		 * in force mode (not AN) we can enable just the relevant
-		 * interrupt
-		 * Even in AN we might enable only one according to the AN
-		 * speed mask
-		 */
-		bnx2x_bits_en(bp, NIG_REG_MASK_INTERRUPT_PORT0 + port*4,
-			      (NIG_MASK_XGXS0_LINK_STATUS |
-			       NIG_MASK_XGXS0_LINK10G));
-		DP(NETIF_MSG_LINK, "enable XGXS interrupt\n");
+		mask = (NIG_MASK_XGXS0_LINK10G |
+			NIG_MASK_XGXS0_LINK_STATUS);
+		DP(NETIF_MSG_LINK, "enabled XGXS interrupt\n");
+		ext_phy_type = XGXS_EXT_PHY_TYPE(bp);
+		if ((ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT) &&
+		    (ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE) &&
+		    (ext_phy_type !=
+				PORT_HW_CFG_XGXS_EXT_PHY_TYPE_NOT_CONN)) {
+			mask |= NIG_MASK_MI_INT;
+			DP(NETIF_MSG_LINK, "enabled external phy int\n");
+		}
 
 	} else { /* SerDes */
-		bnx2x_bits_en(bp, NIG_REG_MASK_INTERRUPT_PORT0 + port*4,
-			      NIG_MASK_SERDES0_LINK_STATUS);
-		DP(NETIF_MSG_LINK, "enable SerDes interrupt\n");
+		mask = NIG_MASK_SERDES0_LINK_STATUS;
+		DP(NETIF_MSG_LINK, "enabled SerDes interrupt\n");
+		ext_phy_type = SERDES_EXT_PHY_TYPE(bp);
+		if ((ext_phy_type !=
+				PORT_HW_CFG_SERDES_EXT_PHY_TYPE_DIRECT) &&
+		    (ext_phy_type !=
+				PORT_HW_CFG_SERDES_EXT_PHY_TYPE_NOT_CONN)) {
+			mask |= NIG_MASK_MI_INT;
+			DP(NETIF_MSG_LINK, "enabled external phy int\n");
+		}
 	}
+	bnx2x_bits_en(bp,
+		      NIG_REG_MASK_INTERRUPT_PORT0 + port*4,
+		      mask);
+	DP(NETIF_MSG_LINK, "port %x, %s, int_status 0x%x,"
+	   " int_mask 0x%x, MI_INT %x, SERDES_LINK %x,"
+	   " 10G %x, XGXS_LINK %x\n", port,
+	   (bp->phy_flags & PHY_XGXS_FLAG)? "XGXS":"SerDes",
+	   REG_RD(bp, NIG_REG_STATUS_INTERRUPT_PORT0 + port*4),
+	   REG_RD(bp, NIG_REG_MASK_INTERRUPT_PORT0 + port*4),
+	   REG_RD(bp, NIG_REG_EMAC0_STATUS_MISC_MI_INT + port*0x18),
+	   REG_RD(bp, NIG_REG_SERDES0_STATUS_LINK_STATUS + port*0x3c),
+	   REG_RD(bp, NIG_REG_XGXS0_STATUS_LINK10G + port*0x68),
+	   REG_RD(bp, NIG_REG_XGXS0_STATUS_LINK_STATUS + port*0x68)
+	);
+}
+
+static void bnx2x_bcm8072_external_rom_boot(struct bnx2x *bp)
+{
+	u32 ext_phy_addr = ((bp->ext_phy_config &
+			     PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
+			    PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
+	u32 fw_ver1, fw_ver2;
+
+	/* Need to wait 200ms after reset */
+	msleep(200);
+	/* Boot port from external ROM
+	 * Set ser_boot_ctl bit in the MISC_CTRL1 register
+	 */
+	bnx2x_mdio45_ctrl_write(bp, GRCBASE_EMAC0, ext_phy_addr,
+				EXT_PHY_KR_PMA_PMD_DEVAD,
+				EXT_PHY_KR_MISC_CTRL1, 0x0001);
+
+	/* Reset internal microprocessor */
+	bnx2x_mdio45_ctrl_write(bp, GRCBASE_EMAC0, ext_phy_addr,
+				EXT_PHY_KR_PMA_PMD_DEVAD, EXT_PHY_KR_GEN_CTRL,
+				EXT_PHY_KR_ROM_RESET_INTERNAL_MP);
+	/* set micro reset = 0 */
+	bnx2x_mdio45_ctrl_write(bp, GRCBASE_EMAC0, ext_phy_addr,
+				EXT_PHY_KR_PMA_PMD_DEVAD, EXT_PHY_KR_GEN_CTRL,
+				EXT_PHY_KR_ROM_MICRO_RESET);
+	/* Reset internal microprocessor */
+	bnx2x_mdio45_ctrl_write(bp, GRCBASE_EMAC0, ext_phy_addr,
+				EXT_PHY_KR_PMA_PMD_DEVAD, EXT_PHY_KR_GEN_CTRL,
+				EXT_PHY_KR_ROM_RESET_INTERNAL_MP);
+	/* wait for 100ms for code download via SPI port */
+	msleep(100);
+
+	/* Clear ser_boot_ctl bit */
+	bnx2x_mdio45_ctrl_write(bp, GRCBASE_EMAC0, ext_phy_addr,
+				EXT_PHY_KR_PMA_PMD_DEVAD,
+				EXT_PHY_KR_MISC_CTRL1, 0x0000);
+	/* Wait 100ms */
+	msleep(100);
+
+	/* Print the PHY FW version */
+	bnx2x_mdio45_ctrl_read(bp, GRCBASE_EMAC0, ext_phy_addr,
+			       EXT_PHY_KR_PMA_PMD_DEVAD,
+			       0xca19, &fw_ver1);
+	bnx2x_mdio45_ctrl_read(bp, GRCBASE_EMAC0, ext_phy_addr,
+			       EXT_PHY_KR_PMA_PMD_DEVAD,
+			       0xca1a, &fw_ver2);
+	DP(NETIF_MSG_LINK,
+	   "8072 FW version 0x%x:0x%x\n", fw_ver1, fw_ver2);
+}
+
+static void bnx2x_bcm8072_force_10G(struct bnx2x *bp)
+{
+	u32 ext_phy_addr = ((bp->ext_phy_config &
+			     PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
+			    PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
+
+	/* Force KR or KX */
+	bnx2x_mdio45_ctrl_write(bp, GRCBASE_EMAC0, ext_phy_addr,
+				EXT_PHY_KR_PMA_PMD_DEVAD, EXT_PHY_KR_CTRL,
+				0x2040);
+	bnx2x_mdio45_ctrl_write(bp, GRCBASE_EMAC0, ext_phy_addr,
+				EXT_PHY_KR_PMA_PMD_DEVAD, EXT_PHY_KR_CTRL2,
+				0x000b);
+	bnx2x_mdio45_ctrl_write(bp, GRCBASE_EMAC0, ext_phy_addr,
+				EXT_PHY_KR_PMA_PMD_DEVAD, EXT_PHY_KR_PMD_CTRL,
+				0x0000);
+	bnx2x_mdio45_ctrl_write(bp, GRCBASE_EMAC0, ext_phy_addr,
+				EXT_PHY_KR_AUTO_NEG_DEVAD, EXT_PHY_KR_CTRL,
+				0x0000);
 }
 
 static void bnx2x_ext_phy_init(struct bnx2x *bp)
 {
-	int port = bp->port;
 	u32 ext_phy_type;
 	u32 ext_phy_addr;
-	u32 local_phy;
+	u32 cnt;
+	u32 ctrl;
+	u32 val = 0;
 
 	if (bp->phy_flags & PHY_XGXS_FLAG) {
-		local_phy = bp->phy_addr;
 		ext_phy_addr = ((bp->ext_phy_config &
 				 PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
 				PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
 
 		ext_phy_type = XGXS_EXT_PHY_TYPE(bp);
+		/* Make sure that the soft reset is off (expect for the 8072:
+		 * due to the lock, it will be done inside the specific
+		 * handling)
+		 */
+		if ((ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT) &&
+		    (ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE) &&
+		   (ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_NOT_CONN) &&
+		    (ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072)) {
+			/* Wait for soft reset to get cleared upto 1 sec */
+			for (cnt = 0; cnt < 1000; cnt++) {
+				bnx2x_mdio45_read(bp, ext_phy_addr,
+						  EXT_PHY_OPT_PMA_PMD_DEVAD,
+						  EXT_PHY_OPT_CNTL, &ctrl);
+				if (!(ctrl & (1<<15)))
+					break;
+				msleep(1);
+			}
+			DP(NETIF_MSG_LINK,
+			   "control reg 0x%x (after %d ms)\n", ctrl, cnt);
+		}
+
 		switch (ext_phy_type) {
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT:
 			DP(NETIF_MSG_LINK, "XGXS Direct\n");
@@ -2801,49 +3362,235 @@ static void bnx2x_ext_phy_init(struct bnx2x *bp)
 
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705:
 			DP(NETIF_MSG_LINK, "XGXS 8705\n");
-			bnx2x_bits_en(bp,
-				      NIG_REG_MASK_INTERRUPT_PORT0 + port*4,
-				      NIG_MASK_MI_INT);
-			DP(NETIF_MSG_LINK, "enabled external phy int\n");
 
-			bp->phy_addr = ext_phy_type;
-			bnx2x_mdio45_vwrite(bp, EXT_PHY_OPT_PMA_PMD_DEVAD,
+			bnx2x_mdio45_vwrite(bp, ext_phy_addr,
+					    EXT_PHY_OPT_PMA_PMD_DEVAD,
 					    EXT_PHY_OPT_PMD_MISC_CNTL,
 					    0x8288);
-			bnx2x_mdio45_vwrite(bp, EXT_PHY_OPT_PMA_PMD_DEVAD,
+			bnx2x_mdio45_vwrite(bp, ext_phy_addr,
+					    EXT_PHY_OPT_PMA_PMD_DEVAD,
 					    EXT_PHY_OPT_PHY_IDENTIFIER,
 					    0x7fbf);
-			bnx2x_mdio45_vwrite(bp, EXT_PHY_OPT_PMA_PMD_DEVAD,
+			bnx2x_mdio45_vwrite(bp, ext_phy_addr,
+					    EXT_PHY_OPT_PMA_PMD_DEVAD,
 					    EXT_PHY_OPT_CMU_PLL_BYPASS,
 					    0x0100);
-			bnx2x_mdio45_vwrite(bp, EXT_PHY_OPT_WIS_DEVAD,
+			bnx2x_mdio45_vwrite(bp, ext_phy_addr,
+					    EXT_PHY_OPT_WIS_DEVAD,
 					    EXT_PHY_OPT_LASI_CNTL, 0x1);
 			break;
 
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706:
 			DP(NETIF_MSG_LINK, "XGXS 8706\n");
-			bnx2x_bits_en(bp,
-				      NIG_REG_MASK_INTERRUPT_PORT0 + port*4,
-				      NIG_MASK_MI_INT);
-			DP(NETIF_MSG_LINK, "enabled external phy int\n");
 
-			bp->phy_addr = ext_phy_type;
-			bnx2x_mdio45_vwrite(bp, EXT_PHY_OPT_PMA_PMD_DEVAD,
-					    EXT_PHY_OPT_PMD_DIGITAL_CNT,
-					    0x400);
-			bnx2x_mdio45_vwrite(bp, EXT_PHY_OPT_PMA_PMD_DEVAD,
+			if (!(bp->req_autoneg & AUTONEG_SPEED)) {
+				/* Force speed */
+				if (bp->req_line_speed == SPEED_10000) {
+					DP(NETIF_MSG_LINK,
+					   "XGXS 8706 force 10Gbps\n");
+					bnx2x_mdio45_vwrite(bp, ext_phy_addr,
+						EXT_PHY_OPT_PMA_PMD_DEVAD,
+						EXT_PHY_OPT_PMD_DIGITAL_CNT,
+						0x400);
+				} else {
+					/* Force 1Gbps */
+					DP(NETIF_MSG_LINK,
+					   "XGXS 8706 force 1Gbps\n");
+
+					bnx2x_mdio45_vwrite(bp, ext_phy_addr,
+						EXT_PHY_OPT_PMA_PMD_DEVAD,
+						EXT_PHY_OPT_CNTL,
+						0x0040);
+
+					bnx2x_mdio45_vwrite(bp, ext_phy_addr,
+						EXT_PHY_OPT_PMA_PMD_DEVAD,
+						EXT_PHY_OPT_CNTL2,
+						0x000D);
+				}
+
+				/* Enable LASI */
+				bnx2x_mdio45_vwrite(bp, ext_phy_addr,
+						    EXT_PHY_OPT_PMA_PMD_DEVAD,
+						    EXT_PHY_OPT_LASI_CNTL,
+						    0x1);
+			} else {
+				/* AUTONEG */
+				/* Allow CL37 through CL73 */
+				DP(NETIF_MSG_LINK, "XGXS 8706 AutoNeg\n");
+				bnx2x_mdio45_vwrite(bp, ext_phy_addr,
+						    EXT_PHY_AUTO_NEG_DEVAD,
+						    EXT_PHY_OPT_AN_CL37_CL73,
+						    0x040c);
+
+				/* Enable Full-Duplex advertisment on CL37 */
+				bnx2x_mdio45_vwrite(bp, ext_phy_addr,
+						    EXT_PHY_AUTO_NEG_DEVAD,
+						    EXT_PHY_OPT_AN_CL37_FD,
+						    0x0020);
+				/* Enable CL37 AN */
+				bnx2x_mdio45_vwrite(bp, ext_phy_addr,
+						    EXT_PHY_AUTO_NEG_DEVAD,
+						    EXT_PHY_OPT_AN_CL37_AN,
+						    0x1000);
+				/* Advertise 10G/1G support */
+				if (bp->advertising &
+				    ADVERTISED_1000baseT_Full)
+					val = (1<<5);
+				if (bp->advertising &
+				    ADVERTISED_10000baseT_Full)
+					val |= (1<<7);
+
+				bnx2x_mdio45_vwrite(bp, ext_phy_addr,
+						    EXT_PHY_AUTO_NEG_DEVAD,
+						    EXT_PHY_OPT_AN_ADV, val);
+				/* Enable LASI */
+				bnx2x_mdio45_vwrite(bp, ext_phy_addr,
+						    EXT_PHY_OPT_PMA_PMD_DEVAD,
+						    EXT_PHY_OPT_LASI_CNTL,
+						    0x1);
+
+				/* Enable clause 73 AN */
+				bnx2x_mdio45_write(bp, ext_phy_addr,
+						   EXT_PHY_AUTO_NEG_DEVAD,
+						   EXT_PHY_OPT_CNTL,
+						   0x1200);
+			}
+			break;
+
+		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072:
+			bnx2x_hw_lock(bp, HW_LOCK_RESOURCE_8072_MDIO);
+			/* Wait for soft reset to get cleared upto 1 sec */
+			for (cnt = 0; cnt < 1000; cnt++) {
+				bnx2x_mdio45_ctrl_read(bp, GRCBASE_EMAC0,
+						ext_phy_addr,
+						EXT_PHY_OPT_PMA_PMD_DEVAD,
+						EXT_PHY_OPT_CNTL, &ctrl);
+				if (!(ctrl & (1<<15)))
+					break;
+				msleep(1);
+			}
+			DP(NETIF_MSG_LINK,
+			   "8072 control reg 0x%x (after %d ms)\n",
+			   ctrl, cnt);
+
+			bnx2x_bcm8072_external_rom_boot(bp);
+			DP(NETIF_MSG_LINK, "Finshed loading 8072 KR ROM\n");
+
+			/* enable LASI */
+			bnx2x_mdio45_ctrl_write(bp, GRCBASE_EMAC0,
+						ext_phy_addr,
+						EXT_PHY_KR_PMA_PMD_DEVAD,
+						0x9000, 0x0400);
+			bnx2x_mdio45_ctrl_write(bp, GRCBASE_EMAC0,
+						ext_phy_addr,
+						EXT_PHY_KR_PMA_PMD_DEVAD,
+						EXT_PHY_KR_LASI_CNTL, 0x0004);
+
+			/* If this is forced speed, set to KR or KX
+			 * (all other are not supported)
+			 */
+			if (!(bp->req_autoneg & AUTONEG_SPEED)) {
+				if (bp->req_line_speed == SPEED_10000) {
+					bnx2x_bcm8072_force_10G(bp);
+					DP(NETIF_MSG_LINK,
+					   "Forced speed 10G on 8072\n");
+					/* unlock */
+					bnx2x_hw_unlock(bp,
+						HW_LOCK_RESOURCE_8072_MDIO);
+					break;
+				} else
+					val = (1<<5);
+			} else {
+
+				/* Advertise 10G/1G support */
+				if (bp->advertising &
+						ADVERTISED_1000baseT_Full)
+					val = (1<<5);
+				if (bp->advertising &
+						ADVERTISED_10000baseT_Full)
+					val |= (1<<7);
+			}
+			bnx2x_mdio45_ctrl_write(bp, GRCBASE_EMAC0,
+					ext_phy_addr,
+					EXT_PHY_KR_AUTO_NEG_DEVAD,
+					0x11, val);
+			/* Add support for CL37 ( passive mode ) I */
+			bnx2x_mdio45_ctrl_write(bp, GRCBASE_EMAC0,
+						ext_phy_addr,
+						EXT_PHY_KR_AUTO_NEG_DEVAD,
+						0x8370, 0x040c);
+			/* Add support for CL37 ( passive mode ) II */
+			bnx2x_mdio45_ctrl_write(bp, GRCBASE_EMAC0,
+						ext_phy_addr,
+						EXT_PHY_KR_AUTO_NEG_DEVAD,
+						0xffe4, 0x20);
+			/* Add support for CL37 ( passive mode ) III */
+			bnx2x_mdio45_ctrl_write(bp, GRCBASE_EMAC0,
+						ext_phy_addr,
+						EXT_PHY_KR_AUTO_NEG_DEVAD,
+						0xffe0, 0x1000);
+			/* Restart autoneg */
+			msleep(500);
+			bnx2x_mdio45_ctrl_write(bp, GRCBASE_EMAC0,
+					ext_phy_addr,
+					EXT_PHY_KR_AUTO_NEG_DEVAD,
+					EXT_PHY_KR_CTRL, 0x1200);
+			DP(NETIF_MSG_LINK, "8072 Autoneg Restart: "
+			   "1G %ssupported  10G %ssupported\n",
+			   (val & (1<<5)) ? "" : "not ",
+			   (val & (1<<7)) ? "" : "not ");
+
+			/* unlock */
+			bnx2x_hw_unlock(bp, HW_LOCK_RESOURCE_8072_MDIO);
+			break;
+
+		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101:
+			DP(NETIF_MSG_LINK,
+			   "Setting the SFX7101 LASI indication\n");
+			bnx2x_mdio45_vwrite(bp, ext_phy_addr,
+					    EXT_PHY_OPT_PMA_PMD_DEVAD,
 					    EXT_PHY_OPT_LASI_CNTL, 0x1);
+			DP(NETIF_MSG_LINK,
+			   "Setting the SFX7101 LED to blink on traffic\n");
+			bnx2x_mdio45_vwrite(bp, ext_phy_addr,
+					    EXT_PHY_OPT_PMA_PMD_DEVAD,
+					    0xC007, (1<<3));
+
+			/* read modify write pause advertizing */
+			bnx2x_mdio45_read(bp, ext_phy_addr,
+					  EXT_PHY_KR_AUTO_NEG_DEVAD,
+					  EXT_PHY_KR_AUTO_NEG_ADVERT, &val);
+			val &= ~EXT_PHY_KR_AUTO_NEG_ADVERT_PAUSE_BOTH;
+			/* Please refer to Table 28B-3 of 802.3ab-1999 spec. */
+			if (bp->advertising & ADVERTISED_Pause)
+				val |= EXT_PHY_KR_AUTO_NEG_ADVERT_PAUSE;
+
+			if (bp->advertising & ADVERTISED_Asym_Pause) {
+				val |=
+				 EXT_PHY_KR_AUTO_NEG_ADVERT_PAUSE_ASYMMETRIC;
+			}
+			DP(NETIF_MSG_LINK, "SFX7101 AN advertize 0x%x\n", val);
+			bnx2x_mdio45_vwrite(bp, ext_phy_addr,
+					    EXT_PHY_KR_AUTO_NEG_DEVAD,
+					    EXT_PHY_KR_AUTO_NEG_ADVERT, val);
+			/* Restart autoneg */
+			bnx2x_mdio45_read(bp, ext_phy_addr,
+					  EXT_PHY_KR_AUTO_NEG_DEVAD,
+					  EXT_PHY_KR_CTRL, &val);
+			val |= 0x200;
+			bnx2x_mdio45_write(bp, ext_phy_addr,
+					    EXT_PHY_KR_AUTO_NEG_DEVAD,
+					    EXT_PHY_KR_CTRL, val);
 			break;
 
 		default:
-			DP(NETIF_MSG_LINK, "BAD XGXS ext_phy_config 0x%x\n",
-			   bp->ext_phy_config);
+			BNX2X_ERR("BAD XGXS ext_phy_config 0x%x\n",
+				  bp->ext_phy_config);
 			break;
 		}
-		bp->phy_addr = local_phy;
 
 	} else { /* SerDes */
-/*      	ext_phy_addr = ((bp->ext_phy_config &
+/*		ext_phy_addr = ((bp->ext_phy_config &
 				 PORT_HW_CFG_SERDES_EXT_PHY_ADDR_MASK) >>
 				PORT_HW_CFG_SERDES_EXT_PHY_ADDR_SHIFT);
 */
@@ -2855,10 +3602,6 @@ static void bnx2x_ext_phy_init(struct bnx2x *bp)
 
 		case PORT_HW_CFG_SERDES_EXT_PHY_TYPE_BCM5482:
 			DP(NETIF_MSG_LINK, "SerDes 5482\n");
-			bnx2x_bits_en(bp,
-				      NIG_REG_MASK_INTERRUPT_PORT0 + port*4,
-				      NIG_MASK_MI_INT);
-			DP(NETIF_MSG_LINK, "enabled external phy int\n");
 			break;
 
 		default:
@@ -2872,8 +3615,22 @@ static void bnx2x_ext_phy_init(struct bnx2x *bp)
 static void bnx2x_ext_phy_reset(struct bnx2x *bp)
 {
 	u32 ext_phy_type;
-	u32 ext_phy_addr;
-	u32 local_phy;
+	u32 ext_phy_addr = ((bp->ext_phy_config &
+			     PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
+			    PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
+	u32 board = (bp->board & SHARED_HW_CFG_BOARD_TYPE_MASK);
+
+	/* The PHY reset is controled by GPIO 1
+	 * Give it 1ms of reset pulse
+	 */
+	if ((board != SHARED_HW_CFG_BOARD_TYPE_BCM957710T1002G) &&
+	    (board != SHARED_HW_CFG_BOARD_TYPE_BCM957710T1003G)) {
+		bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
+			       MISC_REGISTERS_GPIO_OUTPUT_LOW);
+		msleep(1);
+		bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
+			       MISC_REGISTERS_GPIO_OUTPUT_HIGH);
+	}
 
 	if (bp->phy_flags & PHY_XGXS_FLAG) {
 		ext_phy_type = XGXS_EXT_PHY_TYPE(bp);
@@ -2884,15 +3641,24 @@ static void bnx2x_ext_phy_reset(struct bnx2x *bp)
 
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705:
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706:
-			DP(NETIF_MSG_LINK, "XGXS 8705/6\n");
-			local_phy = bp->phy_addr;
-			ext_phy_addr = ((bp->ext_phy_config &
-					PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
-					PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
-			bp->phy_addr = (u8)ext_phy_addr;
-			bnx2x_mdio45_write(bp, EXT_PHY_OPT_PMA_PMD_DEVAD,
+			DP(NETIF_MSG_LINK, "XGXS 8705/8706\n");
+			bnx2x_mdio45_write(bp, ext_phy_addr,
+					   EXT_PHY_OPT_PMA_PMD_DEVAD,
 					   EXT_PHY_OPT_CNTL, 0xa040);
-			bp->phy_addr = local_phy;
+			break;
+
+		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072:
+			DP(NETIF_MSG_LINK, "XGXS 8072\n");
+			bnx2x_hw_lock(bp, HW_LOCK_RESOURCE_8072_MDIO);
+			bnx2x_mdio45_ctrl_write(bp, GRCBASE_EMAC0,
+						ext_phy_addr,
+						EXT_PHY_KR_PMA_PMD_DEVAD,
+						0, 1<<15);
+			bnx2x_hw_unlock(bp, HW_LOCK_RESOURCE_8072_MDIO);
+			break;
+
+		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101:
+			DP(NETIF_MSG_LINK, "XGXS SFX7101\n");
 			break;
 
 		default:
@@ -2931,6 +3697,7 @@ static void bnx2x_link_initialize(struct bnx2x *bp)
 			NIG_MASK_SERDES0_LINK_STATUS |
 			NIG_MASK_MI_INT));
 
+	/* Activate the external PHY */
 	bnx2x_ext_phy_reset(bp);
 
 	bnx2x_set_aer_mmd(bp);
@@ -3011,11 +3778,11 @@ static void bnx2x_link_initialize(struct bnx2x *bp)
 		bnx2x_initialize_sgmii_process(bp);
 	}
 
-	/* enable the interrupt */
-	bnx2x_link_int_enable(bp);
-
 	/* init ext phy and enable link state int */
 	bnx2x_ext_phy_init(bp);
+
+	/* enable the interrupt */
+	bnx2x_link_int_enable(bp);
 }
 
 static void bnx2x_phy_deassert(struct bnx2x *bp)
@@ -3074,6 +3841,11 @@ static int bnx2x_phy_init(struct bnx2x *bp)
 static void bnx2x_link_reset(struct bnx2x *bp)
 {
 	int port = bp->port;
+	u32 board = (bp->board & SHARED_HW_CFG_BOARD_TYPE_MASK);
+
+	/* update shared memory */
+	bp->link_status = 0;
+	bnx2x_update_mng(bp);
 
 	/* disable attentions */
 	bnx2x_bits_dis(bp, NIG_REG_MASK_INTERRUPT_PORT0 + port*4,
@@ -3082,21 +3854,45 @@ static void bnx2x_link_reset(struct bnx2x *bp)
 			NIG_MASK_SERDES0_LINK_STATUS |
 			NIG_MASK_MI_INT));
 
-	bnx2x_ext_phy_reset(bp);
+	/* activate nig drain */
+	NIG_WR(NIG_REG_EGRESS_DRAIN0_MODE + port*4, 1);
+
+	/* disable nig egress interface */
+	NIG_WR(NIG_REG_BMAC0_OUT_EN + port*4, 0);
+	NIG_WR(NIG_REG_EGRESS_EMAC0_OUT_EN + port*4, 0);
+
+	/* Stop BigMac rx */
+	bnx2x_bmac_rx_disable(bp);
+
+	/* disable emac */
+	NIG_WR(NIG_REG_NIG_EMAC0_EN + port*4, 0);
+
+	msleep(10);
+
+	/* The PHY reset is controled by GPIO 1
+	 * Hold it as output low
+	 */
+	if ((board != SHARED_HW_CFG_BOARD_TYPE_BCM957710T1002G) &&
+	    (board != SHARED_HW_CFG_BOARD_TYPE_BCM957710T1003G)) {
+		bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
+			       MISC_REGISTERS_GPIO_OUTPUT_LOW);
+		DP(NETIF_MSG_LINK, "reset external PHY\n");
+	}
 
 	/* reset the SerDes/XGXS */
 	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_3_CLEAR,
 	       (0x1ff << (port*16)));
 
-	/* reset EMAC / BMAC and disable NIG interfaces */
-	NIG_WR(NIG_REG_BMAC0_IN_EN + port*4, 0);
-	NIG_WR(NIG_REG_BMAC0_OUT_EN + port*4, 0);
+	/* reset BigMac */
+	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_CLEAR,
+	       (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << port));
 
-	NIG_WR(NIG_REG_NIG_EMAC0_EN + port*4, 0);
+	/* disable nig ingress interface */
+	NIG_WR(NIG_REG_BMAC0_IN_EN + port*4, 0);
 	NIG_WR(NIG_REG_EMAC0_IN_EN + port*4, 0);
-	NIG_WR(NIG_REG_EGRESS_EMAC0_OUT_EN + port*4, 0);
 
-	NIG_WR(NIG_REG_EGRESS_DRAIN0_MODE + port*4, 1);
+	/* set link down */
+	bp->link_up = 0;
 }
 
 #ifdef BNX2X_XGXS_LB
@@ -3177,6 +3973,7 @@ static int bnx2x_sp_post(struct bnx2x *bp, int command, int cid,
 		bnx2x_panic();
 		return -EBUSY;
 	}
+
 	/* CID needs port number to be encoded int it */
 	bp->spq_prod_bd->hdr.conn_and_cmd_data =
 			cpu_to_le32(((command << SPE_HDR_CMD_ID_SHIFT) |
@@ -4335,7 +5132,7 @@ static void bnx2x_timer(unsigned long data)
 		return;
 
 	if (atomic_read(&bp->intr_sem) != 0)
-		goto bnx2x_restart_timer;
+		goto timer_restart;
 
 	if (poll) {
 		struct bnx2x_fastpath *fp = &bp->fp[0];
@@ -4345,7 +5142,7 @@ static void bnx2x_timer(unsigned long data)
 		rc = bnx2x_rx_int(fp, 1000);
 	}
 
-	if (!nomcp && (bp->bc_ver >= 0x040003)) {
+	if (!nomcp) {
 		int port = bp->port;
 		u32 drv_pulse;
 		u32 mcp_pulse;
@@ -4354,9 +5151,9 @@ static void bnx2x_timer(unsigned long data)
 		bp->fw_drv_pulse_wr_seq &= DRV_PULSE_SEQ_MASK;
 		/* TBD - add SYSTEM_TIME */
 		drv_pulse = bp->fw_drv_pulse_wr_seq;
-		SHMEM_WR(bp, drv_fw_mb[port].drv_pulse_mb, drv_pulse);
+		SHMEM_WR(bp, func_mb[port].drv_pulse_mb, drv_pulse);
 
-		mcp_pulse = (SHMEM_RD(bp, drv_fw_mb[port].mcp_pulse_mb) &
+		mcp_pulse = (SHMEM_RD(bp, func_mb[port].mcp_pulse_mb) &
 			     MCP_PULSE_SEQ_MASK);
 		/* The delta between driver pulse and mcp response
 		 * should be 1 (before mcp response) or 0 (after mcp response)
@@ -4370,11 +5167,11 @@ static void bnx2x_timer(unsigned long data)
 	}
 
 	if (bp->stats_state == STATS_STATE_DISABLE)
-		goto bnx2x_restart_timer;
+		goto timer_restart;
 
 	bnx2x_update_stats(bp);
 
-bnx2x_restart_timer:
+timer_restart:
 	mod_timer(&bp->timer, jiffies + bp->current_interval);
 }
 
@@ -5266,8 +6063,10 @@ static int bnx2x_function_init(struct bnx2x *bp, int mode)
 	if (mode & 0x1) {       /* init common */
 		DP(BNX2X_MSG_MCP, "starting common init  func %d  mode %x\n",
 		   func, mode);
-		REG_WR(bp, MISC_REG_RESET_REG_1, 0xffffffff);
-		REG_WR(bp, MISC_REG_RESET_REG_2, 0xfffc);
+		REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_1_SET,
+		       0xffffffff);
+		REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_1_SET,
+		       0xfffc);
 		bnx2x_init_block(bp, MISC_COMMON_START, MISC_COMMON_END);
 
 		REG_WR(bp, MISC_REG_LCPLL_CTRL_REG_2, 0x100);
@@ -5487,6 +6286,28 @@ static int bnx2x_function_init(struct bnx2x *bp, int mode)
 		enable_blocks_attention(bp);
 		/* enable_blocks_parity(bp); */
 
+		switch (bp->board & SHARED_HW_CFG_BOARD_TYPE_MASK) {
+		case SHARED_HW_CFG_BOARD_TYPE_BCM957710A1022G:
+			/* Fan failure is indicated by SPIO 5 */
+			bnx2x_set_spio(bp, MISC_REGISTERS_SPIO_5,
+				       MISC_REGISTERS_SPIO_INPUT_HI_Z);
+
+			/* set to active low mode */
+			val = REG_RD(bp, MISC_REG_SPIO_INT);
+			val |= ((1 << MISC_REGISTERS_SPIO_5) <<
+					MISC_REGISTERS_SPIO_INT_OLD_SET_POS);
+			REG_WR(bp, MISC_REG_SPIO_INT, val);
+
+			/* enable interrupt to signal the IGU */
+			val = REG_RD(bp, MISC_REG_SPIO_EVENT_EN);
+			val |= (1 << MISC_REGISTERS_SPIO_5);
+			REG_WR(bp, MISC_REG_SPIO_EVENT_EN, val);
+			break;
+
+		default:
+			break;
+		}
+
 	} /* end of common init */
 
 	/* per port init */
@@ -5646,6 +6467,18 @@ static int bnx2x_function_init(struct bnx2x *bp, int mode)
 	/* Port MCP comes here */
 	/* Port DMAE comes here */
 
+	switch (bp->board & SHARED_HW_CFG_BOARD_TYPE_MASK) {
+	case SHARED_HW_CFG_BOARD_TYPE_BCM957710A1022G:
+		/* add SPIO 5 to group 0 */
+		val = REG_RD(bp, MISC_REG_AEU_ENABLE1_FUNC_0_OUT_0);
+		val |= AEU_INPUTS_ATTN_BITS_SPIO5;
+		REG_WR(bp, MISC_REG_AEU_ENABLE1_FUNC_0_OUT_0, val);
+		break;
+
+	default:
+		break;
+	}
+
 	bnx2x_link_reset(bp);
 
 	/* Reset PCIE errors for debug */
@@ -5670,9 +6503,9 @@ static int bnx2x_function_init(struct bnx2x *bp, int mode)
 		port = bp->port;
 
 		bp->fw_drv_pulse_wr_seq =
-				(SHMEM_RD(bp, drv_fw_mb[port].drv_pulse_mb) &
+				(SHMEM_RD(bp, func_mb[port].drv_pulse_mb) &
 				 DRV_PULSE_SEQ_MASK);
-		bp->fw_mb = SHMEM_RD(bp, drv_fw_mb[port].fw_mb_param);
+		bp->fw_mb = SHMEM_RD(bp, func_mb[port].fw_mb_param);
 		DP(BNX2X_MSG_MCP, "drv_pulse 0x%x  fw_mb 0x%x\n",
 		   bp->fw_drv_pulse_wr_seq, bp->fw_mb);
 	} else {
@@ -5685,12 +6518,12 @@ static int bnx2x_function_init(struct bnx2x *bp, int mode)
 /* send the MCP a request, block until there is a reply */
 static u32 bnx2x_fw_command(struct bnx2x *bp, u32 command)
 {
-	u32 rc = 0;
-	u32 seq = ++bp->fw_seq;
 	int port = bp->port;
+	u32 seq = ++bp->fw_seq;
+	u32 rc = 0;
 
-	SHMEM_WR(bp, drv_fw_mb[port].drv_mb_header, command|seq);
-	DP(BNX2X_MSG_MCP, "wrote command (%x) to FW MB\n", command|seq);
+	SHMEM_WR(bp, func_mb[port].drv_mb_header, (command | seq));
+	DP(BNX2X_MSG_MCP, "wrote command (%x) to FW MB\n", (command | seq));
 
 	/* let the FW do it's magic ... */
 	msleep(100); /* TBD */
@@ -5698,19 +6531,20 @@ static u32 bnx2x_fw_command(struct bnx2x *bp, u32 command)
 	if (CHIP_REV_IS_SLOW(bp))
 		msleep(900);
 
-	rc = SHMEM_RD(bp, drv_fw_mb[port].fw_mb_header);
-
+	rc = SHMEM_RD(bp, func_mb[port].fw_mb_header);
 	DP(BNX2X_MSG_MCP, "read (%x) seq is (%x) from FW MB\n", rc, seq);
 
 	/* is this a reply to our command? */
 	if (seq == (rc & FW_MSG_SEQ_NUMBER_MASK)) {
 		rc &= FW_MSG_CODE_MASK;
+
 	} else {
 		/* FW BUG! */
 		BNX2X_ERR("FW failed to respond!\n");
 		bnx2x_fw_dump(bp);
 		rc = 0;
 	}
+
 	return rc;
 }
 
@@ -6559,7 +7393,7 @@ static void bnx2x_link_settings_supported(struct bnx2x *bp, u32 switch_cfg)
 					  SUPPORTED_100baseT_Half |
 					  SUPPORTED_100baseT_Full |
 					  SUPPORTED_1000baseT_Full |
-					  SUPPORTED_2500baseT_Full |
+					  SUPPORTED_2500baseX_Full |
 					  SUPPORTED_TP | SUPPORTED_FIBRE |
 					  SUPPORTED_Autoneg |
 					  SUPPORTED_Pause |
@@ -6572,10 +7406,10 @@ static void bnx2x_link_settings_supported(struct bnx2x *bp, u32 switch_cfg)
 
 			bp->phy_flags |= PHY_SGMII_FLAG;
 
-			bp->supported |= (/* SUPPORTED_10baseT_Half |
-					     SUPPORTED_10baseT_Full |
-					     SUPPORTED_100baseT_Half |
-					     SUPPORTED_100baseT_Full |*/
+			bp->supported |= (SUPPORTED_10baseT_Half |
+					  SUPPORTED_10baseT_Full |
+					  SUPPORTED_100baseT_Half |
+					  SUPPORTED_100baseT_Full |
 					  SUPPORTED_1000baseT_Full |
 					  SUPPORTED_TP | SUPPORTED_FIBRE |
 					  SUPPORTED_Autoneg |
@@ -6611,7 +7445,7 @@ static void bnx2x_link_settings_supported(struct bnx2x *bp, u32 switch_cfg)
 					  SUPPORTED_100baseT_Half |
 					  SUPPORTED_100baseT_Full |
 					  SUPPORTED_1000baseT_Full |
-					  SUPPORTED_2500baseT_Full |
+					  SUPPORTED_2500baseX_Full |
 					  SUPPORTED_10000baseT_Full |
 					  SUPPORTED_TP | SUPPORTED_FIBRE |
 					  SUPPORTED_Autoneg |
@@ -6620,12 +7454,46 @@ static void bnx2x_link_settings_supported(struct bnx2x *bp, u32 switch_cfg)
 			break;
 
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705:
+			BNX2X_DEV_INFO("ext_phy_type 0x%x (8705)\n",
+					ext_phy_type);
+
+			bp->supported |= (SUPPORTED_10000baseT_Full |
+					  SUPPORTED_FIBRE |
+					  SUPPORTED_Pause |
+					  SUPPORTED_Asym_Pause);
+			break;
+
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706:
-			BNX2X_DEV_INFO("ext_phy_type 0x%x (8705/6)\n",
+			BNX2X_DEV_INFO("ext_phy_type 0x%x (8706)\n",
+				       ext_phy_type);
+
+			bp->supported |= (SUPPORTED_10000baseT_Full |
+					  SUPPORTED_1000baseT_Full |
+					  SUPPORTED_Autoneg |
+					  SUPPORTED_FIBRE |
+					  SUPPORTED_Pause |
+					  SUPPORTED_Asym_Pause);
+			break;
+
+		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072:
+			BNX2X_DEV_INFO("ext_phy_type 0x%x (8072)\n",
 				       ext_phy_type);
 
 			bp->supported |= (SUPPORTED_10000baseT_Full |
+					  SUPPORTED_1000baseT_Full |
 					  SUPPORTED_FIBRE |
+					  SUPPORTED_Autoneg |
+					  SUPPORTED_Pause |
+					  SUPPORTED_Asym_Pause);
+			break;
+
+		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101:
+			BNX2X_DEV_INFO("ext_phy_type 0x%x (SFX7101)\n",
+				       ext_phy_type);
+
+			bp->supported |= (SUPPORTED_10000baseT_Full |
+					  SUPPORTED_TP |
+					  SUPPORTED_Autoneg |
 					  SUPPORTED_Pause |
 					  SUPPORTED_Asym_Pause);
 			break;
@@ -6682,7 +7550,7 @@ static void bnx2x_link_settings_supported(struct bnx2x *bp, u32 switch_cfg)
 				   SUPPORTED_1000baseT_Full);
 
 	if (!(bp->speed_cap_mask & PORT_HW_CFG_SPEED_CAPABILITY_D0_2_5G))
-		bp->supported &= ~SUPPORTED_2500baseT_Full;
+		bp->supported &= ~SUPPORTED_2500baseX_Full;
 
 	if (!(bp->speed_cap_mask & PORT_HW_CFG_SPEED_CAPABILITY_D0_10G))
 		bp->supported &= ~SUPPORTED_10000baseT_Full;
@@ -6702,13 +7570,8 @@ static void bnx2x_link_settings_requested(struct bnx2x *bp)
 			bp->req_line_speed = 0;
 			bp->advertising = bp->supported;
 		} else {
-			u32 ext_phy_type;
-
-			ext_phy_type = XGXS_EXT_PHY_TYPE(bp);
-			if ((ext_phy_type ==
-				PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705) ||
-			    (ext_phy_type ==
-				PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706)) {
+			if (XGXS_EXT_PHY_TYPE(bp) ==
+				PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705) {
 				/* force 10G, no AN */
 				bp->req_line_speed = SPEED_10000;
 				bp->advertising =
@@ -6725,8 +7588,7 @@ static void bnx2x_link_settings_requested(struct bnx2x *bp)
 		break;
 
 	case PORT_FEATURE_LINK_SPEED_10M_FULL:
-		if (bp->speed_cap_mask &
-		    PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_FULL) {
+		if (bp->supported & SUPPORTED_10baseT_Full) {
 			bp->req_line_speed = SPEED_10;
 			bp->advertising = (ADVERTISED_10baseT_Full |
 					   ADVERTISED_TP);
@@ -6740,8 +7602,7 @@ static void bnx2x_link_settings_requested(struct bnx2x *bp)
 		break;
 
 	case PORT_FEATURE_LINK_SPEED_10M_HALF:
-		if (bp->speed_cap_mask &
-		    PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_HALF) {
+		if (bp->supported & SUPPORTED_10baseT_Half) {
 			bp->req_line_speed = SPEED_10;
 			bp->req_duplex = DUPLEX_HALF;
 			bp->advertising = (ADVERTISED_10baseT_Half |
@@ -6756,8 +7617,7 @@ static void bnx2x_link_settings_requested(struct bnx2x *bp)
 		break;
 
 	case PORT_FEATURE_LINK_SPEED_100M_FULL:
-		if (bp->speed_cap_mask &
-		    PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_FULL) {
+		if (bp->supported & SUPPORTED_100baseT_Full) {
 			bp->req_line_speed = SPEED_100;
 			bp->advertising = (ADVERTISED_100baseT_Full |
 					   ADVERTISED_TP);
@@ -6771,8 +7631,7 @@ static void bnx2x_link_settings_requested(struct bnx2x *bp)
 		break;
 
 	case PORT_FEATURE_LINK_SPEED_100M_HALF:
-		if (bp->speed_cap_mask &
-		    PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_HALF) {
+		if (bp->supported & SUPPORTED_100baseT_Half) {
 			bp->req_line_speed = SPEED_100;
 			bp->req_duplex = DUPLEX_HALF;
 			bp->advertising = (ADVERTISED_100baseT_Half |
@@ -6787,8 +7646,7 @@ static void bnx2x_link_settings_requested(struct bnx2x *bp)
 		break;
 
 	case PORT_FEATURE_LINK_SPEED_1G:
-		if (bp->speed_cap_mask &
-		    PORT_HW_CFG_SPEED_CAPABILITY_D0_1G) {
+		if (bp->supported & SUPPORTED_1000baseT_Full) {
 			bp->req_line_speed = SPEED_1000;
 			bp->advertising = (ADVERTISED_1000baseT_Full |
 					   ADVERTISED_TP);
@@ -6802,10 +7660,9 @@ static void bnx2x_link_settings_requested(struct bnx2x *bp)
 		break;
 
 	case PORT_FEATURE_LINK_SPEED_2_5G:
-		if (bp->speed_cap_mask &
-		    PORT_HW_CFG_SPEED_CAPABILITY_D0_2_5G) {
+		if (bp->supported & SUPPORTED_2500baseX_Full) {
 			bp->req_line_speed = SPEED_2500;
-			bp->advertising = (ADVERTISED_2500baseT_Full |
+			bp->advertising = (ADVERTISED_2500baseX_Full |
 					   ADVERTISED_TP);
 		} else {
 			BNX2X_ERR("NVRAM config error. "
@@ -6819,15 +7676,7 @@ static void bnx2x_link_settings_requested(struct bnx2x *bp)
 	case PORT_FEATURE_LINK_SPEED_10G_CX4:
 	case PORT_FEATURE_LINK_SPEED_10G_KX4:
 	case PORT_FEATURE_LINK_SPEED_10G_KR:
-		if (!(bp->phy_flags & PHY_XGXS_FLAG)) {
-			BNX2X_ERR("NVRAM config error. "
-				  "Invalid link_config 0x%x"
-				  "  phy_flags 0x%x\n",
-				  bp->link_config, bp->phy_flags);
-			return;
-		}
-		if (bp->speed_cap_mask &
-		    PORT_HW_CFG_SPEED_CAPABILITY_D0_10G) {
+		if (bp->supported & SUPPORTED_10000baseT_Full) {
 			bp->req_line_speed = SPEED_10000;
 			bp->advertising = (ADVERTISED_10000baseT_Full |
 					   ADVERTISED_FIBRE);
@@ -6854,43 +7703,13 @@ static void bnx2x_link_settings_requested(struct bnx2x *bp)
 
 	bp->req_flow_ctrl = (bp->link_config &
 			     PORT_FEATURE_FLOW_CONTROL_MASK);
-	/* Please refer to Table 28B-3 of the 802.3ab-1999 spec */
-	switch (bp->req_flow_ctrl) {
-	case FLOW_CTRL_AUTO:
+	if ((bp->req_flow_ctrl == FLOW_CTRL_AUTO) &&
+	    (bp->supported & SUPPORTED_Autoneg))
 		bp->req_autoneg |= AUTONEG_FLOW_CTRL;
-		if (bp->dev->mtu <= 4500) {
-			bp->pause_mode = PAUSE_BOTH;
-			bp->advertising |= (ADVERTISED_Pause |
-					    ADVERTISED_Asym_Pause);
-		} else {
-			bp->pause_mode = PAUSE_ASYMMETRIC;
-			bp->advertising |= ADVERTISED_Asym_Pause;
-		}
-		break;
-
-	case FLOW_CTRL_TX:
-		bp->pause_mode = PAUSE_ASYMMETRIC;
-		bp->advertising |= ADVERTISED_Asym_Pause;
-		break;
-
-	case FLOW_CTRL_RX:
-	case FLOW_CTRL_BOTH:
-		bp->pause_mode = PAUSE_BOTH;
-		bp->advertising |= (ADVERTISED_Pause |
-				    ADVERTISED_Asym_Pause);
-		break;
 
-	case FLOW_CTRL_NONE:
-	default:
-		bp->pause_mode = PAUSE_NONE;
-		bp->advertising &= ~(ADVERTISED_Pause |
-				     ADVERTISED_Asym_Pause);
-		break;
-	}
-	BNX2X_DEV_INFO("req_autoneg 0x%x  req_flow_ctrl 0x%x\n"
-	     KERN_INFO "  pause_mode %d  advertising 0x%x\n",
-		       bp->req_autoneg, bp->req_flow_ctrl,
-		       bp->pause_mode, bp->advertising);
+	BNX2X_DEV_INFO("req_autoneg 0x%x  req_flow_ctrl 0x%x"
+		       "  advertising 0x%x\n",
+		       bp->req_autoneg, bp->req_flow_ctrl, bp->advertising);
 }
 
 static void bnx2x_get_hwinfo(struct bnx2x *bp)
@@ -6923,16 +7742,16 @@ static void bnx2x_get_hwinfo(struct bnx2x *bp)
 
 	val = SHMEM_RD(bp, validity_map[port]);
 	if ((val & (SHR_MEM_VALIDITY_DEV_INFO | SHR_MEM_VALIDITY_MB))
-	    != (SHR_MEM_VALIDITY_DEV_INFO | SHR_MEM_VALIDITY_MB))
-		BNX2X_ERR("MCP validity signature bad\n");
+		!= (SHR_MEM_VALIDITY_DEV_INFO | SHR_MEM_VALIDITY_MB))
+		BNX2X_ERR("BAD MCP validity signature\n");
 
-	bp->fw_seq = (SHMEM_RD(bp, drv_fw_mb[port].drv_mb_header) &
+	bp->fw_seq = (SHMEM_RD(bp, func_mb[port].drv_mb_header) &
 		      DRV_MSG_SEQ_NUMBER_MASK);
 
 	bp->hw_config = SHMEM_RD(bp, dev_info.shared_hw_config.config);
-
+	bp->board = SHMEM_RD(bp, dev_info.shared_hw_config.board);
 	bp->serdes_config =
-		SHMEM_RD(bp, dev_info.port_hw_config[bp->port].serdes_config);
+		SHMEM_RD(bp, dev_info.port_hw_config[port].serdes_config);
 	bp->lane_config =
 		SHMEM_RD(bp, dev_info.port_hw_config[port].lane_config);
 	bp->ext_phy_config =
@@ -6945,13 +7764,13 @@ static void bnx2x_get_hwinfo(struct bnx2x *bp)
 	bp->link_config =
 		SHMEM_RD(bp, dev_info.port_feature_config[port].link_config);
 
-	BNX2X_DEV_INFO("hw_config (%08x)  serdes_config (%08x)\n"
+	BNX2X_DEV_INFO("hw_config (%08x) board (%08x)  serdes_config (%08x)\n"
 	     KERN_INFO "  lane_config (%08x)  ext_phy_config (%08x)\n"
 	     KERN_INFO "  speed_cap_mask (%08x)  link_config (%08x)"
 		       "  fw_seq (%08x)\n",
-		       bp->hw_config, bp->serdes_config, bp->lane_config,
-		       bp->ext_phy_config, bp->speed_cap_mask,
-		       bp->link_config, bp->fw_seq);
+		       bp->hw_config, bp->board, bp->serdes_config,
+		       bp->lane_config, bp->ext_phy_config,
+		       bp->speed_cap_mask, bp->link_config, bp->fw_seq);
 
 	switch_cfg = (bp->link_config & PORT_FEATURE_CONNECTED_SWITCH_MASK);
 	bnx2x_link_settings_supported(bp, switch_cfg);
@@ -7005,14 +7824,8 @@ static void bnx2x_get_hwinfo(struct bnx2x *bp)
 	return;
 
 set_mac: /* only supposed to happen on emulation/FPGA */
-	BNX2X_ERR("warning constant MAC workaround active\n");
-	bp->dev->dev_addr[0] = 0;
-	bp->dev->dev_addr[1] = 0x50;
-	bp->dev->dev_addr[2] = 0xc2;
-	bp->dev->dev_addr[3] = 0x2c;
-	bp->dev->dev_addr[4] = 0x71;
-	bp->dev->dev_addr[5] = port ? 0x0d : 0x0e;
-
+	BNX2X_ERR("warning rendom MAC workaround active\n");
+	random_ether_addr(bp->dev->dev_addr);
 	memcpy(bp->dev->perm_addr, bp->dev->dev_addr, 6);
 
 }
@@ -7039,19 +7852,34 @@ static int bnx2x_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	}
 
 	if (bp->phy_flags & PHY_XGXS_FLAG) {
-		cmd->port = PORT_FIBRE;
-	} else {
+		u32 ext_phy_type = XGXS_EXT_PHY_TYPE(bp);
+
+		switch (ext_phy_type) {
+		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT:
+		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705:
+		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706:
+		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072:
+			cmd->port = PORT_FIBRE;
+			break;
+
+		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101:
+			cmd->port = PORT_TP;
+			break;
+
+		default:
+			DP(NETIF_MSG_LINK, "BAD XGXS ext_phy_config 0x%x\n",
+			   bp->ext_phy_config);
+		}
+	} else
 		cmd->port = PORT_TP;
-	}
 
 	cmd->phy_address = bp->phy_addr;
 	cmd->transceiver = XCVR_INTERNAL;
 
-	if (bp->req_autoneg & AUTONEG_SPEED) {
+	if (bp->req_autoneg & AUTONEG_SPEED)
 		cmd->autoneg = AUTONEG_ENABLE;
-	} else {
+	else
 		cmd->autoneg = AUTONEG_DISABLE;
-	}
 
 	cmd->maxtxpkt = 0;
 	cmd->maxrxpkt = 0;
@@ -7082,8 +7910,10 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 	switch (cmd->port) {
 	case PORT_TP:
-		if (!(bp->supported & SUPPORTED_TP))
+		if (!(bp->supported & SUPPORTED_TP)) {
+			DP(NETIF_MSG_LINK, "TP not supported\n");
 			return -EINVAL;
+		}
 
 		if (bp->phy_flags & PHY_XGXS_FLAG) {
 			bnx2x_link_reset(bp);
@@ -7093,8 +7923,10 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		break;
 
 	case PORT_FIBRE:
-		if (!(bp->supported & SUPPORTED_FIBRE))
+		if (!(bp->supported & SUPPORTED_FIBRE)) {
+			DP(NETIF_MSG_LINK, "FIBRE not supported\n");
 			return -EINVAL;
+		}
 
 		if (!(bp->phy_flags & PHY_XGXS_FLAG)) {
 			bnx2x_link_reset(bp);
@@ -7104,12 +7936,15 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		break;
 
 	default:
+		DP(NETIF_MSG_LINK, "Unknown port type\n");
 		return -EINVAL;
 	}
 
 	if (cmd->autoneg == AUTONEG_ENABLE) {
-		if (!(bp->supported & SUPPORTED_Autoneg))
+		if (!(bp->supported & SUPPORTED_Autoneg)) {
+			DP(NETIF_MSG_LINK, "Aotoneg not supported\n");
 			return -EINVAL;
+		}
 
 		/* advertise the requested speed and duplex if supported */
 		cmd->advertising &= bp->supported;
@@ -7124,14 +7959,22 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		switch (cmd->speed) {
 		case SPEED_10:
 			if (cmd->duplex == DUPLEX_FULL) {
-				if (!(bp->supported & SUPPORTED_10baseT_Full))
+				if (!(bp->supported &
+				      SUPPORTED_10baseT_Full)) {
+					DP(NETIF_MSG_LINK,
+					   "10M full not supported\n");
 					return -EINVAL;
+				}
 
 				advertising = (ADVERTISED_10baseT_Full |
 					       ADVERTISED_TP);
 			} else {
-				if (!(bp->supported & SUPPORTED_10baseT_Half))
+				if (!(bp->supported &
+				      SUPPORTED_10baseT_Half)) {
+					DP(NETIF_MSG_LINK,
+					   "10M half not supported\n");
 					return -EINVAL;
+				}
 
 				advertising = (ADVERTISED_10baseT_Half |
 					       ADVERTISED_TP);
@@ -7141,15 +7984,21 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		case SPEED_100:
 			if (cmd->duplex == DUPLEX_FULL) {
 				if (!(bp->supported &
-						SUPPORTED_100baseT_Full))
+						SUPPORTED_100baseT_Full)) {
+					DP(NETIF_MSG_LINK,
+					   "100M full not supported\n");
 					return -EINVAL;
+				}
 
 				advertising = (ADVERTISED_100baseT_Full |
 					       ADVERTISED_TP);
 			} else {
 				if (!(bp->supported &
-						SUPPORTED_100baseT_Half))
+						SUPPORTED_100baseT_Half)) {
+					DP(NETIF_MSG_LINK,
+					   "100M half not supported\n");
 					return -EINVAL;
+				}
 
 				advertising = (ADVERTISED_100baseT_Half |
 					       ADVERTISED_TP);
@@ -7157,39 +8006,54 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 			break;
 
 		case SPEED_1000:
-			if (cmd->duplex != DUPLEX_FULL)
+			if (cmd->duplex != DUPLEX_FULL) {
+				DP(NETIF_MSG_LINK, "1G half not supported\n");
 				return -EINVAL;
+			}
 
-			if (!(bp->supported & SUPPORTED_1000baseT_Full))
+			if (!(bp->supported & SUPPORTED_1000baseT_Full)) {
+				DP(NETIF_MSG_LINK, "1G full not supported\n");
 				return -EINVAL;
+			}
 
 			advertising = (ADVERTISED_1000baseT_Full |
 				       ADVERTISED_TP);
 			break;
 
 		case SPEED_2500:
-			if (cmd->duplex != DUPLEX_FULL)
+			if (cmd->duplex != DUPLEX_FULL) {
+				DP(NETIF_MSG_LINK,
+				   "2.5G half not supported\n");
 				return -EINVAL;
+			}
 
-			if (!(bp->supported & SUPPORTED_2500baseT_Full))
+			if (!(bp->supported & SUPPORTED_2500baseX_Full)) {
+				DP(NETIF_MSG_LINK,
+				   "2.5G full not supported\n");
 				return -EINVAL;
+			}
 
-			advertising = (ADVERTISED_2500baseT_Full |
+			advertising = (ADVERTISED_2500baseX_Full |
 				       ADVERTISED_TP);
 			break;
 
 		case SPEED_10000:
-			if (cmd->duplex != DUPLEX_FULL)
+			if (cmd->duplex != DUPLEX_FULL) {
+				DP(NETIF_MSG_LINK, "10G half not supported\n");
 				return -EINVAL;
+			}
 
-			if (!(bp->supported & SUPPORTED_10000baseT_Full))
+			if (!(bp->supported & SUPPORTED_10000baseT_Full)) {
+				DP(NETIF_MSG_LINK, "10G full not supported\n");
 				return -EINVAL;
+			}
 
 			advertising = (ADVERTISED_10000baseT_Full |
 				       ADVERTISED_FIBRE);
 			break;
 
 		default:
+			DP(NETIF_MSG_LINK, "Unsupported speed\n");
 			return -EINVAL;
 		}
 
@@ -7389,8 +8253,7 @@ static void bnx2x_disable_nvram_access(struct bnx2x *bp)
 static int bnx2x_nvram_read_dword(struct bnx2x *bp, u32 offset, u32 *ret_val,
 				  u32 cmd_flags)
 {
-	int rc;
-	int count, i;
+	int count, i, rc;
 	u32 val;
 
 	/* build the command word */
@@ -7510,8 +8373,7 @@ static int bnx2x_get_eeprom(struct net_device *dev,
 static int bnx2x_nvram_write_dword(struct bnx2x *bp, u32 offset, u32 val,
 				   u32 cmd_flags)
 {
-	int rc;
-	int count, i;
+	int count, i, rc;
 
 	/* build the command word */
 	cmd_flags |= MCPR_NVM_COMMAND_DOIT | MCPR_NVM_COMMAND_WR;
@@ -7548,7 +8410,7 @@ static int bnx2x_nvram_write_dword(struct bnx2x *bp, u32 offset, u32 val,
 	return rc;
 }
 
-#define BYTE_OFFSET(offset)     	(8 * (offset & 0x03))
+#define BYTE_OFFSET(offset)		(8 * (offset & 0x03))
 
 static int bnx2x_nvram_write1(struct bnx2x *bp, u32 offset, u8 *data_buf,
 			      int buf_size)
@@ -7779,52 +8641,29 @@ static int bnx2x_set_pauseparam(struct net_device *dev,
 	   DP_LEVEL "  autoneg %d  rx_pause %d  tx_pause %d\n",
 	   epause->cmd, epause->autoneg, epause->rx_pause, epause->tx_pause);
 
-	bp->req_flow_ctrl = FLOW_CTRL_AUTO;
 	if (epause->autoneg) {
-		bp->req_autoneg |= AUTONEG_FLOW_CTRL;
-		if (bp->dev->mtu <= 4500) {
-			bp->pause_mode = PAUSE_BOTH;
-			bp->advertising |= (ADVERTISED_Pause |
-					    ADVERTISED_Asym_Pause);
-		} else {
-			bp->pause_mode = PAUSE_ASYMMETRIC;
-			bp->advertising |= ADVERTISED_Asym_Pause;
+		if (!(bp->supported & SUPPORTED_Autoneg)) {
+			DP(NETIF_MSG_LINK, "Aotoneg not supported\n");
+			return -EINVAL;
 		}
 
-	} else {
+		bp->req_autoneg |= AUTONEG_FLOW_CTRL;
+	} else
 		bp->req_autoneg &= ~AUTONEG_FLOW_CTRL;
 
-		if (epause->rx_pause)
-			bp->req_flow_ctrl |= FLOW_CTRL_RX;
-		if (epause->tx_pause)
-			bp->req_flow_ctrl |= FLOW_CTRL_TX;
-
-		switch (bp->req_flow_ctrl) {
-		case FLOW_CTRL_AUTO:
-			bp->req_flow_ctrl = FLOW_CTRL_NONE;
-			bp->pause_mode = PAUSE_NONE;
-			bp->advertising &= ~(ADVERTISED_Pause |
-					     ADVERTISED_Asym_Pause);
-			break;
+	bp->req_flow_ctrl = FLOW_CTRL_AUTO;
 
-		case FLOW_CTRL_TX:
-			bp->pause_mode = PAUSE_ASYMMETRIC;
-			bp->advertising |= ADVERTISED_Asym_Pause;
-			break;
+	if (epause->rx_pause)
+		bp->req_flow_ctrl |= FLOW_CTRL_RX;
+	if (epause->tx_pause)
+		bp->req_flow_ctrl |= FLOW_CTRL_TX;
 
-		case FLOW_CTRL_RX:
-		case FLOW_CTRL_BOTH:
-			bp->pause_mode = PAUSE_BOTH;
-			bp->advertising |= (ADVERTISED_Pause |
-					    ADVERTISED_Asym_Pause);
-			break;
-		}
-	}
+	if (!(bp->req_autoneg & AUTONEG_FLOW_CTRL) &&
+	    (bp->req_flow_ctrl == FLOW_CTRL_AUTO))
+		bp->req_flow_ctrl = FLOW_CTRL_NONE;
 
-	DP(NETIF_MSG_LINK, "req_autoneg 0x%x  req_flow_ctrl 0x%x\n"
-	   DP_LEVEL "  pause_mode %d  advertising 0x%x\n",
-	   bp->req_autoneg, bp->req_flow_ctrl, bp->pause_mode,
-	   bp->advertising);
+	DP(NETIF_MSG_LINK, "req_autoneg 0x%x  req_flow_ctrl 0x%x\n",
+	   bp->req_autoneg, bp->req_flow_ctrl);
 
 	bnx2x_stop_stats(bp);
 	bnx2x_link_initialize(bp);
diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index ea91008..dc423e5 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -24,6 +24,8 @@
 #define BNX2X_MSG_STATS 		0x20000 /* was: NETIF_MSG_TIMER */
 #define NETIF_MSG_NVM   		0x40000 /* was: NETIF_MSG_HW */
 #define NETIF_MSG_DMAE  		0x80000 /* was: NETIF_MSG_HW */
+#define BNX2X_MSG_SP			0x100000 /* was: NETIF_MSG_INTR */
+#define BNX2X_MSG_FP			0x200000 /* was: NETIF_MSG_INTR */
 
 #define DP_LEVEL			KERN_NOTICE     /* was: KERN_DEBUG */
 
@@ -40,6 +42,12 @@
 		__LINE__, bp->dev?(bp->dev->name):"?", ##__args); \
 	} while (0)
 
+/* for logging (never masked) */
+#define BNX2X_LOG(__fmt, __args...) do { \
+	printk(KERN_NOTICE "[%s:%d(%s)]" __fmt, __FUNCTION__, \
+		__LINE__, bp->dev?(bp->dev->name):"?", ##__args); \
+	} while (0)
+
 /* before we have a dev->name use dev_info() */
 #define BNX2X_DEV_INFO(__fmt, __args...) do { \
 	if (bp->msglevel & NETIF_MSG_PROBE) \
@@ -574,7 +582,8 @@ struct bnx2x {
 	u32     		fw_mb;
 
 	u32     		hw_config;
-	u32     		serdes_config;
+	u32			board;
+	u32			serdes_config;
 	u32     		lane_config;
 	u32     		ext_phy_config;
 #define XGXS_EXT_PHY_TYPE(bp)   	(bp->ext_phy_config & \
@@ -595,11 +604,11 @@ struct bnx2x {
 	u8      		tx_lane_swap;
 
 	u8      		link_up;
+	u8			phy_link_up;
 
 	u32     		supported;
 /* link settings - missing defines */
 #define SUPPORTED_2500baseT_Full	(1 << 15)
-#define SUPPORTED_CX4   		(1 << 16)
 
 	u32     		phy_flags;
 /*#define PHY_SERDES_FLAG       		0x1*/
@@ -644,16 +653,9 @@ struct bnx2x {
 #define FLOW_CTRL_BOTH  		PORT_FEATURE_FLOW_CONTROL_BOTH
 #define FLOW_CTRL_NONE  		PORT_FEATURE_FLOW_CONTROL_NONE
 
-	u32     		pause_mode;
-#define PAUSE_NONE      		0
-#define PAUSE_SYMMETRIC 		1
-#define PAUSE_ASYMMETRIC		2
-#define PAUSE_BOTH      		3
-
 	u32     		advertising;
 /* link settings - missing defines */
 #define ADVERTISED_2500baseT_Full       (1 << 15)
-#define ADVERTISED_CX4  		(1 << 16)
 
 	u32     		link_status;
 	u32     		line_speed;
@@ -667,6 +669,8 @@ struct bnx2x {
 #define NVRAM_TIMEOUT_COUNT     	30000
 #define NVRAM_PAGE_SIZE 		256
 
+	u8			wol;
+
 	int     		rx_ring_size;
 
 	u16     		tx_quick_cons_trip_int;
@@ -718,9 +722,6 @@ struct bnx2x {
 #endif
 
 	char    		*name;
-	u16     		bus_speed_mhz;
-	u8      		wol;
-	u8      		pad;
 
 	/* used to synchronize stats collecting */
 	int     		stats_state;
@@ -873,6 +874,7 @@ struct bnx2x {
 #define PCICFG_LINK_SPEED		0xf0000
 #define PCICFG_LINK_SPEED_SHIFT		16
 
+#define BMAC_CONTROL_RX_ENABLE		2
 /* stuff added to make the code fit 80Col */
 
 #define TPA_TYPE_START  		ETH_FAST_PATH_RX_CQE_START_FLG
@@ -944,13 +946,13 @@ struct bnx2x {
 #define LINK_16GTFD     		LINK_STATUS_SPEED_AND_DUPLEX_16GTFD
 #define LINK_16GXFD     		LINK_STATUS_SPEED_AND_DUPLEX_16GXFD
 
-#define NIG_STATUS_INTERRUPT_XGXS0_LINK10G \
+#define NIG_STATUS_XGXS0_LINK10G \
 		NIG_STATUS_INTERRUPT_PORT0_REG_STATUS_XGXS0_LINK10G
-#define NIG_XGXS0_LINK_STATUS \
+#define NIG_STATUS_XGXS0_LINK_STATUS \
 		NIG_STATUS_INTERRUPT_PORT0_REG_STATUS_XGXS0_LINK_STATUS
-#define NIG_XGXS0_LINK_STATUS_SIZE \
+#define NIG_STATUS_XGXS0_LINK_STATUS_SIZE \
 		NIG_STATUS_INTERRUPT_PORT0_REG_STATUS_XGXS0_LINK_STATUS_SIZE
-#define NIG_SERDES0_LINK_STATUS \
+#define NIG_STATUS_SERDES0_LINK_STATUS \
 		NIG_STATUS_INTERRUPT_PORT0_REG_STATUS_SERDES0_LINK_STATUS
 #define NIG_MASK_MI_INT \
 		NIG_MASK_INTERRUPT_PORT0_REG_MASK_EMAC0_MISC_MI_INT
diff --git a/drivers/net/bnx2x_fw_defs.h b/drivers/net/bnx2x_fw_defs.h
index 62a6eb8..3b96890 100644
--- a/drivers/net/bnx2x_fw_defs.h
+++ b/drivers/net/bnx2x_fw_defs.h
@@ -1,6 +1,6 @@
 /* bnx2x_fw_defs.h: Broadcom Everest network driver.
  *
- * Copyright (c) 2007 Broadcom Corporation
+ * Copyright (c) 2007-2008 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/bnx2x_hsi.h b/drivers/net/bnx2x_hsi.h
index 6fd959c..b21075c 100644
--- a/drivers/net/bnx2x_hsi.h
+++ b/drivers/net/bnx2x_hsi.h
@@ -1,6 +1,6 @@
 /* bnx2x_hsi.h: Broadcom Everest network driver.
  *
- * Copyright (c) 2007 Broadcom Corporation
+ * Copyright (c) 2007-2008 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -8,169 +8,9 @@
  */
 
 
-#define FUNC_0				0
-#define FUNC_1				1
-#define FUNC_MAX			2
-
-
-/* This value (in milliseconds) determines the frequency of the driver
- * issuing the PULSE message code.  The firmware monitors this periodic
- * pulse to determine when to switch to an OS-absent mode. */
-#define DRV_PULSE_PERIOD_MS		250
-
-/* This value (in milliseconds) determines how long the driver should
- * wait for an acknowledgement from the firmware before timing out.  Once
- * the firmware has timed out, the driver will assume there is no firmware
- * running and there won't be any firmware-driver synchronization during a
- * driver reset. */
-#define FW_ACK_TIME_OUT_MS		5000
-
-#define FW_ACK_POLL_TIME_MS		1
-
-#define FW_ACK_NUM_OF_POLL	(FW_ACK_TIME_OUT_MS/FW_ACK_POLL_TIME_MS)
-
-/* LED Blink rate that will achieve ~15.9Hz */
-#define LED_BLINK_RATE_VAL		480
-
-/****************************************************************************
- * Driver <-> FW Mailbox						    *
- ****************************************************************************/
-struct drv_fw_mb {
-	u32 drv_mb_header;
-#define DRV_MSG_CODE_MASK			0xffff0000
-#define DRV_MSG_CODE_LOAD_REQ			0x10000000
-#define DRV_MSG_CODE_LOAD_DONE			0x11000000
-#define DRV_MSG_CODE_UNLOAD_REQ_WOL_EN		0x20000000
-#define DRV_MSG_CODE_UNLOAD_REQ_WOL_DIS 	0x20010000
-#define DRV_MSG_CODE_UNLOAD_REQ_WOL_MCP 	0x20020000
-#define DRV_MSG_CODE_UNLOAD_DONE		0x21000000
-#define DRV_MSG_CODE_DIAG_ENTER_REQ		0x50000000
-#define DRV_MSG_CODE_DIAG_EXIT_REQ		0x60000000
-#define DRV_MSG_CODE_VALIDATE_KEY		0x70000000
-#define DRV_MSG_CODE_GET_CURR_KEY		0x80000000
-#define DRV_MSG_CODE_GET_UPGRADE_KEY		0x81000000
-#define DRV_MSG_CODE_GET_MANUF_KEY		0x82000000
-#define DRV_MSG_CODE_LOAD_L2B_PRAM		0x90000000
-
-#define DRV_MSG_SEQ_NUMBER_MASK 		0x0000ffff
-
-	u32 drv_mb_param;
-
-	u32 fw_mb_header;
-#define FW_MSG_CODE_MASK			0xffff0000
-#define FW_MSG_CODE_DRV_LOAD_COMMON		0x11000000
-#define FW_MSG_CODE_DRV_LOAD_PORT		0x12000000
-#define FW_MSG_CODE_DRV_LOAD_REFUSED		0x13000000
-#define FW_MSG_CODE_DRV_LOAD_DONE		0x14000000
-#define FW_MSG_CODE_DRV_UNLOAD_COMMON		0x21000000
-#define FW_MSG_CODE_DRV_UNLOAD_PORT		0x22000000
-#define FW_MSG_CODE_DRV_UNLOAD_DONE		0x23000000
-#define FW_MSG_CODE_DIAG_ENTER_DONE		0x50000000
-#define FW_MSG_CODE_DIAG_REFUSE 		0x51000000
-#define FW_MSG_CODE_VALIDATE_KEY_SUCCESS	0x70000000
-#define FW_MSG_CODE_VALIDATE_KEY_FAILURE	0x71000000
-#define FW_MSG_CODE_GET_KEY_DONE		0x80000000
-#define FW_MSG_CODE_NO_KEY			0x8f000000
-#define FW_MSG_CODE_LIC_INFO_NOT_READY		0x8f800000
-#define FW_MSG_CODE_L2B_PRAM_LOADED		0x90000000
-#define FW_MSG_CODE_L2B_PRAM_T_LOAD_FAILURE	0x91000000
-#define FW_MSG_CODE_L2B_PRAM_C_LOAD_FAILURE	0x92000000
-#define FW_MSG_CODE_L2B_PRAM_X_LOAD_FAILURE	0x93000000
-#define FW_MSG_CODE_L2B_PRAM_U_LOAD_FAILURE	0x94000000
-
-#define FW_MSG_SEQ_NUMBER_MASK			0x0000ffff
-
-	u32 fw_mb_param;
-
-	u32 link_status;
-	/* Driver should update this field on any link change event */
-
-#define LINK_STATUS_LINK_FLAG_MASK		0x00000001
-#define LINK_STATUS_LINK_UP			0x00000001
-#define LINK_STATUS_SPEED_AND_DUPLEX_MASK	0x0000001E
-#define LINK_STATUS_SPEED_AND_DUPLEX_AN_NOT_COMPLETE	(0<<1)
-#define LINK_STATUS_SPEED_AND_DUPLEX_10THD		(1<<1)
-#define LINK_STATUS_SPEED_AND_DUPLEX_10TFD		(2<<1)
-#define LINK_STATUS_SPEED_AND_DUPLEX_100TXHD		(3<<1)
-#define LINK_STATUS_SPEED_AND_DUPLEX_100T4		(4<<1)
-#define LINK_STATUS_SPEED_AND_DUPLEX_100TXFD		(5<<1)
-#define LINK_STATUS_SPEED_AND_DUPLEX_1000THD		(6<<1)
-#define LINK_STATUS_SPEED_AND_DUPLEX_1000TFD		(7<<1)
-#define LINK_STATUS_SPEED_AND_DUPLEX_1000XFD		(7<<1)
-#define LINK_STATUS_SPEED_AND_DUPLEX_2500THD		(8<<1)
-#define LINK_STATUS_SPEED_AND_DUPLEX_2500TFD		(9<<1)
-#define LINK_STATUS_SPEED_AND_DUPLEX_2500XFD		(9<<1)
-#define LINK_STATUS_SPEED_AND_DUPLEX_10GTFD		(10<<1)
-#define LINK_STATUS_SPEED_AND_DUPLEX_10GXFD		(10<<1)
-#define LINK_STATUS_SPEED_AND_DUPLEX_12GTFD		(11<<1)
-#define LINK_STATUS_SPEED_AND_DUPLEX_12GXFD		(11<<1)
-#define LINK_STATUS_SPEED_AND_DUPLEX_12_5GTFD		(12<<1)
-#define LINK_STATUS_SPEED_AND_DUPLEX_12_5GXFD		(12<<1)
-#define LINK_STATUS_SPEED_AND_DUPLEX_13GTFD		(13<<1)
-#define LINK_STATUS_SPEED_AND_DUPLEX_13GXFD		(13<<1)
-#define LINK_STATUS_SPEED_AND_DUPLEX_15GTFD		(14<<1)
-#define LINK_STATUS_SPEED_AND_DUPLEX_15GXFD		(14<<1)
-#define LINK_STATUS_SPEED_AND_DUPLEX_16GTFD		(15<<1)
-#define LINK_STATUS_SPEED_AND_DUPLEX_16GXFD		(15<<1)
-
-#define LINK_STATUS_AUTO_NEGOTIATE_FLAG_MASK		0x00000020
-#define LINK_STATUS_AUTO_NEGOTIATE_ENABLED		0x00000020
-
-#define LINK_STATUS_AUTO_NEGOTIATE_COMPLETE		0x00000040
-#define LINK_STATUS_PARALLEL_DETECTION_FLAG_MASK	0x00000080
-#define LINK_STATUS_PARALLEL_DETECTION_USED		0x00000080
-
-#define LINK_STATUS_LINK_PARTNER_1000TFD_CAPABLE	0x00000200
-#define LINK_STATUS_LINK_PARTNER_1000THD_CAPABLE	0x00000400
-#define LINK_STATUS_LINK_PARTNER_100T4_CAPABLE		0x00000800
-#define LINK_STATUS_LINK_PARTNER_100TXFD_CAPABLE	0x00001000
-#define LINK_STATUS_LINK_PARTNER_100TXHD_CAPABLE	0x00002000
-#define LINK_STATUS_LINK_PARTNER_10TFD_CAPABLE		0x00004000
-#define LINK_STATUS_LINK_PARTNER_10THD_CAPABLE		0x00008000
-
-#define LINK_STATUS_TX_FLOW_CONTROL_FLAG_MASK		0x00010000
-#define LINK_STATUS_TX_FLOW_CONTROL_ENABLED		0x00010000
-
-#define LINK_STATUS_RX_FLOW_CONTROL_FLAG_MASK		0x00020000
-#define LINK_STATUS_RX_FLOW_CONTROL_ENABLED		0x00020000
-
-#define LINK_STATUS_LINK_PARTNER_FLOW_CONTROL_MASK	0x000C0000
-#define LINK_STATUS_LINK_PARTNER_NOT_PAUSE_CAPABLE	(0<<18)
-#define LINK_STATUS_LINK_PARTNER_SYMMETRIC_PAUSE	(1<<18)
-#define LINK_STATUS_LINK_PARTNER_ASYMMETRIC_PAUSE	(2<<18)
-#define LINK_STATUS_LINK_PARTNER_BOTH_PAUSE		(3<<18)
-
-#define LINK_STATUS_SERDES_LINK 			0x00100000
-
-#define LINK_STATUS_LINK_PARTNER_2500XFD_CAPABLE	0x00200000
-#define LINK_STATUS_LINK_PARTNER_2500XHD_CAPABLE	0x00400000
-#define LINK_STATUS_LINK_PARTNER_10GXFD_CAPABLE 	0x00800000
-#define LINK_STATUS_LINK_PARTNER_12GXFD_CAPABLE 	0x01000000
-#define LINK_STATUS_LINK_PARTNER_12_5GXFD_CAPABLE	0x02000000
-#define LINK_STATUS_LINK_PARTNER_13GXFD_CAPABLE 	0x04000000
-#define LINK_STATUS_LINK_PARTNER_15GXFD_CAPABLE 	0x08000000
-#define LINK_STATUS_LINK_PARTNER_16GXFD_CAPABLE 	0x10000000
-
-	u32 drv_pulse_mb;
-#define DRV_PULSE_SEQ_MASK				0x00007fff
-#define DRV_PULSE_SYSTEM_TIME_MASK			0xffff0000
-	/* The system time is in the format of
-	 * (year-2001)*12*32 + month*32 + day. */
-#define DRV_PULSE_ALWAYS_ALIVE				0x00008000
-	/* Indicate to the firmware not to go into the
-	 * OS-absent when it is not getting driver pulse.
-	 * This is used for debugging as well for PXE(MBA). */
-
-	u32 mcp_pulse_mb;
-#define MCP_PULSE_SEQ_MASK				0x00007fff
-#define MCP_PULSE_ALWAYS_ALIVE				0x00008000
-	/* Indicates to the driver not to assert due to lack
-	 * of MCP response */
-#define MCP_EVENT_MASK					0xffff0000
-#define MCP_EVENT_OTHER_DRIVER_RESET_REQ		0x00010000
-
-};
-
+#define PORT_0				0
+#define PORT_1				1
+#define PORT_MAX			2
 
 /****************************************************************************
  * Shared HW configuration						    *
@@ -249,7 +89,7 @@ struct shared_hw_cfg {					 /* NVRAM Offset */
 #define SHARED_HW_CFG_SMBUS_TIMING_100KHZ	    0x00000000
 #define SHARED_HW_CFG_SMBUS_TIMING_400KHZ	    0x00001000
 
-#define SHARED_HW_CFG_HIDE_FUNC1		    0x00002000
+#define SHARED_HW_CFG_HIDE_PORT1		    0x00002000
 
 	u32 power_dissipated;					/* 0x11c */
 #define SHARED_HW_CFG_POWER_DIS_CMN_MASK	    0xff000000
@@ -290,6 +130,8 @@ struct shared_hw_cfg {					 /* NVRAM Offset */
 #define SHARED_HW_CFG_BOARD_TYPE_BCM957710T1015G    0x00000006
 #define SHARED_HW_CFG_BOARD_TYPE_BCM957710A1020G    0x00000007
 #define SHARED_HW_CFG_BOARD_TYPE_BCM957710T1003G    0x00000008
+#define SHARED_HW_CFG_BOARD_TYPE_BCM957710A1022G    0x00000009
+#define SHARED_HW_CFG_BOARD_TYPE_BCM957710A1021G    0x0000000a
 
 #define SHARED_HW_CFG_BOARD_VER_MASK		    0xffff0000
 #define SHARED_HW_CFG_BOARD_VER_SHIFT		    16
@@ -304,13 +146,12 @@ struct shared_hw_cfg {					 /* NVRAM Offset */
 
 };
 
+
 /****************************************************************************
  * Port HW configuration						    *
  ****************************************************************************/
-struct port_hw_cfg {	/* function 0: 0x12c-0x2bb, function 1: 0x2bc-0x44b */
+struct port_hw_cfg {			    /* port 0: 0x12c  port 1: 0x2bc */
 
-	/* Fields below are port specific (in anticipation of dual port
-	   devices */
 	u32 pci_id;
 #define PORT_HW_CFG_PCI_VENDOR_ID_MASK		    0xffff0000
 #define PORT_HW_CFG_PCI_DEVICE_ID_MASK		    0x0000ffff
@@ -420,6 +261,8 @@ struct port_hw_cfg {	/* function 0: 0x12c-0x2bb, function 1: 0x2bc-0x44b */
 #define PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706	    0x00000500
 #define PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8276	    0x00000600
 #define PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481	    0x00000700
+#define PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101	    0x00000800
+#define PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE	    0x0000fd00
 #define PORT_HW_CFG_XGXS_EXT_PHY_TYPE_NOT_CONN	    0x0000ff00
 
 #define PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK	    0x000000ff
@@ -462,11 +305,13 @@ struct port_hw_cfg {	/* function 0: 0x12c-0x2bb, function 1: 0x2bc-0x44b */
 
 };
 
+
 /****************************************************************************
  * Shared Feature configuration 					    *
  ****************************************************************************/
 struct shared_feat_cfg {				 /* NVRAM Offset */
-	u32 bmc_common; 					/* 0x450 */
+
+	u32 config;						/* 0x450 */
 #define SHARED_FEATURE_BMC_ECHO_MODE_EN 	    0x00000001
 
 };
@@ -475,7 +320,8 @@ struct shared_feat_cfg {				 /* NVRAM Offset */
 /****************************************************************************
  * Port Feature configuration						    *
  ****************************************************************************/
-struct port_feat_cfg {	/* function 0: 0x454-0x4c7, function 1: 0x4c8-0x53b */
+struct port_feat_cfg {			    /* port 0: 0x454  port 1: 0x4c8 */
+
 	u32 config;
 #define PORT_FEATURE_BAR1_SIZE_MASK		    0x0000000f
 #define PORT_FEATURE_BAR1_SIZE_SHIFT		    0
@@ -609,8 +455,7 @@ struct port_feat_cfg {	/* function 0: 0x454-0x4c7, function 1: 0x4c8-0x53b */
 #define PORT_FEATURE_SMBUS_ADDR_MASK		    0x000000fe
 #define PORT_FEATURE_SMBUS_ADDR_SHIFT		    1
 
-	u32 iscsib_boot_cfg;
-#define PORT_FEATURE_ISCSIB_SKIP_TARGET_BOOT	    0x00000001
+	u32 reserved1;
 
 	u32 link_config;    /* Used as HW defaults for the driver */
 #define PORT_FEATURE_CONNECTED_SWITCH_MASK	    0x03000000
@@ -657,20 +502,201 @@ struct port_feat_cfg {	/* function 0: 0x454-0x4c7, function 1: 0x4c8-0x53b */
 };
 
 
+/*****************************************************************************
+ * Device Information							     *
+ *****************************************************************************/
+struct dev_info {						     /* size */
+
+	u32    bc_rev; /* 8 bits each: major, minor, build */	        /* 4 */
+
+	struct shared_hw_cfg	 shared_hw_config;		       /* 40 */
+
+	struct port_hw_cfg	 port_hw_config[PORT_MAX];      /* 400*2=800 */
+
+	struct shared_feat_cfg	 shared_feature_config; 	        /* 4 */
+
+	struct port_feat_cfg	 port_feature_config[PORT_MAX]; /* 116*2=232 */
+
+};
+
+
+#define FUNC_0				0
+#define FUNC_1				1
+#define E1_FUNC_MAX			2
+#define FUNC_MAX			E1_FUNC_MAX
+
+
+/* This value (in milliseconds) determines the frequency of the driver
+ * issuing the PULSE message code.  The firmware monitors this periodic
+ * pulse to determine when to switch to an OS-absent mode. */
+#define DRV_PULSE_PERIOD_MS		250
+
+/* This value (in milliseconds) determines how long the driver should
+ * wait for an acknowledgement from the firmware before timing out.  Once
+ * the firmware has timed out, the driver will assume there is no firmware
+ * running and there won't be any firmware-driver synchronization during a
+ * driver reset. */
+#define FW_ACK_TIME_OUT_MS		5000
+
+#define FW_ACK_POLL_TIME_MS		1
+
+#define FW_ACK_NUM_OF_POLL	(FW_ACK_TIME_OUT_MS/FW_ACK_POLL_TIME_MS)
+
+/* LED Blink rate that will achieve ~15.9Hz */
+#define LED_BLINK_RATE_VAL		480
+
 /****************************************************************************
- * Device Information							    *
+ * Driver <-> FW Mailbox						    *
  ****************************************************************************/
-struct dev_info {						    /* size */
+struct drv_port_mb {
+
+	u32 link_status;
+	/* Driver should update this field on any link change event */
+
+#define LINK_STATUS_LINK_FLAG_MASK			0x00000001
+#define LINK_STATUS_LINK_UP				0x00000001
+#define LINK_STATUS_SPEED_AND_DUPLEX_MASK		0x0000001E
+#define LINK_STATUS_SPEED_AND_DUPLEX_AN_NOT_COMPLETE	(0<<1)
+#define LINK_STATUS_SPEED_AND_DUPLEX_10THD		(1<<1)
+#define LINK_STATUS_SPEED_AND_DUPLEX_10TFD		(2<<1)
+#define LINK_STATUS_SPEED_AND_DUPLEX_100TXHD		(3<<1)
+#define LINK_STATUS_SPEED_AND_DUPLEX_100T4		(4<<1)
+#define LINK_STATUS_SPEED_AND_DUPLEX_100TXFD		(5<<1)
+#define LINK_STATUS_SPEED_AND_DUPLEX_1000THD		(6<<1)
+#define LINK_STATUS_SPEED_AND_DUPLEX_1000TFD		(7<<1)
+#define LINK_STATUS_SPEED_AND_DUPLEX_1000XFD		(7<<1)
+#define LINK_STATUS_SPEED_AND_DUPLEX_2500THD		(8<<1)
+#define LINK_STATUS_SPEED_AND_DUPLEX_2500TFD		(9<<1)
+#define LINK_STATUS_SPEED_AND_DUPLEX_2500XFD		(9<<1)
+#define LINK_STATUS_SPEED_AND_DUPLEX_10GTFD		(10<<1)
+#define LINK_STATUS_SPEED_AND_DUPLEX_10GXFD		(10<<1)
+#define LINK_STATUS_SPEED_AND_DUPLEX_12GTFD		(11<<1)
+#define LINK_STATUS_SPEED_AND_DUPLEX_12GXFD		(11<<1)
+#define LINK_STATUS_SPEED_AND_DUPLEX_12_5GTFD		(12<<1)
+#define LINK_STATUS_SPEED_AND_DUPLEX_12_5GXFD		(12<<1)
+#define LINK_STATUS_SPEED_AND_DUPLEX_13GTFD		(13<<1)
+#define LINK_STATUS_SPEED_AND_DUPLEX_13GXFD		(13<<1)
+#define LINK_STATUS_SPEED_AND_DUPLEX_15GTFD		(14<<1)
+#define LINK_STATUS_SPEED_AND_DUPLEX_15GXFD		(14<<1)
+#define LINK_STATUS_SPEED_AND_DUPLEX_16GTFD		(15<<1)
+#define LINK_STATUS_SPEED_AND_DUPLEX_16GXFD		(15<<1)
+
+#define LINK_STATUS_AUTO_NEGOTIATE_FLAG_MASK		0x00000020
+#define LINK_STATUS_AUTO_NEGOTIATE_ENABLED		0x00000020
+
+#define LINK_STATUS_AUTO_NEGOTIATE_COMPLETE		0x00000040
+#define LINK_STATUS_PARALLEL_DETECTION_FLAG_MASK	0x00000080
+#define LINK_STATUS_PARALLEL_DETECTION_USED		0x00000080
+
+#define LINK_STATUS_LINK_PARTNER_1000TFD_CAPABLE	0x00000200
+#define LINK_STATUS_LINK_PARTNER_1000THD_CAPABLE	0x00000400
+#define LINK_STATUS_LINK_PARTNER_100T4_CAPABLE		0x00000800
+#define LINK_STATUS_LINK_PARTNER_100TXFD_CAPABLE	0x00001000
+#define LINK_STATUS_LINK_PARTNER_100TXHD_CAPABLE	0x00002000
+#define LINK_STATUS_LINK_PARTNER_10TFD_CAPABLE		0x00004000
+#define LINK_STATUS_LINK_PARTNER_10THD_CAPABLE		0x00008000
+
+#define LINK_STATUS_TX_FLOW_CONTROL_FLAG_MASK		0x00010000
+#define LINK_STATUS_TX_FLOW_CONTROL_ENABLED		0x00010000
+
+#define LINK_STATUS_RX_FLOW_CONTROL_FLAG_MASK		0x00020000
+#define LINK_STATUS_RX_FLOW_CONTROL_ENABLED		0x00020000
+
+#define LINK_STATUS_LINK_PARTNER_FLOW_CONTROL_MASK	0x000C0000
+#define LINK_STATUS_LINK_PARTNER_NOT_PAUSE_CAPABLE	(0<<18)
+#define LINK_STATUS_LINK_PARTNER_SYMMETRIC_PAUSE	(1<<18)
+#define LINK_STATUS_LINK_PARTNER_ASYMMETRIC_PAUSE	(2<<18)
+#define LINK_STATUS_LINK_PARTNER_BOTH_PAUSE		(3<<18)
+
+#define LINK_STATUS_SERDES_LINK 			0x00100000
+
+#define LINK_STATUS_LINK_PARTNER_2500XFD_CAPABLE	0x00200000
+#define LINK_STATUS_LINK_PARTNER_2500XHD_CAPABLE	0x00400000
+#define LINK_STATUS_LINK_PARTNER_10GXFD_CAPABLE 	0x00800000
+#define LINK_STATUS_LINK_PARTNER_12GXFD_CAPABLE 	0x01000000
+#define LINK_STATUS_LINK_PARTNER_12_5GXFD_CAPABLE	0x02000000
+#define LINK_STATUS_LINK_PARTNER_13GXFD_CAPABLE 	0x04000000
+#define LINK_STATUS_LINK_PARTNER_15GXFD_CAPABLE 	0x08000000
+#define LINK_STATUS_LINK_PARTNER_16GXFD_CAPABLE 	0x10000000
 
-	u32    bc_rev; /* 8 bits each: major, minor, build */	       /* 4 */
+	u32 reserved[3];
 
-	struct shared_hw_cfg	 shared_hw_config;		      /* 40 */
+};
+
+
+struct drv_func_mb {
+
+	u32 drv_mb_header;
+#define DRV_MSG_CODE_MASK				0xffff0000
+#define DRV_MSG_CODE_LOAD_REQ				0x10000000
+#define DRV_MSG_CODE_LOAD_DONE				0x11000000
+#define DRV_MSG_CODE_UNLOAD_REQ_WOL_EN			0x20000000
+#define DRV_MSG_CODE_UNLOAD_REQ_WOL_DIS 		0x20010000
+#define DRV_MSG_CODE_UNLOAD_REQ_WOL_MCP 		0x20020000
+#define DRV_MSG_CODE_UNLOAD_DONE			0x21000000
+#define DRV_MSG_CODE_DIAG_ENTER_REQ			0x50000000
+#define DRV_MSG_CODE_DIAG_EXIT_REQ			0x60000000
+#define DRV_MSG_CODE_VALIDATE_KEY			0x70000000
+#define DRV_MSG_CODE_GET_CURR_KEY			0x80000000
+#define DRV_MSG_CODE_GET_UPGRADE_KEY			0x81000000
+#define DRV_MSG_CODE_GET_MANUF_KEY			0x82000000
+#define DRV_MSG_CODE_LOAD_L2B_PRAM			0x90000000
+
+#define DRV_MSG_SEQ_NUMBER_MASK 			0x0000ffff
+
+	u32 drv_mb_param;
+
+	u32 fw_mb_header;
+#define FW_MSG_CODE_MASK				0xffff0000
+#define FW_MSG_CODE_DRV_LOAD_COMMON			0x10100000
+#define FW_MSG_CODE_DRV_LOAD_PORT			0x10110000
+#define FW_MSG_CODE_DRV_LOAD_FUNCTION			0x10120000
+#define FW_MSG_CODE_DRV_LOAD_REFUSED			0x10200000
+#define FW_MSG_CODE_DRV_LOAD_DONE			0x11100000
+#define FW_MSG_CODE_DRV_UNLOAD_COMMON			0x20100000
+#define FW_MSG_CODE_DRV_UNLOAD_PORT			0x20110000
+#define FW_MSG_CODE_DRV_UNLOAD_FUNCTION 		0x20120000
+#define FW_MSG_CODE_DRV_UNLOAD_DONE			0x21100000
+#define FW_MSG_CODE_DIAG_ENTER_DONE			0x50100000
+#define FW_MSG_CODE_DIAG_REFUSE 			0x50200000
+#define FW_MSG_CODE_DIAG_EXIT_DONE			0x60100000
+#define FW_MSG_CODE_VALIDATE_KEY_SUCCESS		0x70100000
+#define FW_MSG_CODE_VALIDATE_KEY_FAILURE		0x70200000
+#define FW_MSG_CODE_GET_KEY_DONE			0x80100000
+#define FW_MSG_CODE_NO_KEY				0x80f00000
+#define FW_MSG_CODE_LIC_INFO_NOT_READY			0x80f80000
+#define FW_MSG_CODE_L2B_PRAM_LOADED			0x90100000
+#define FW_MSG_CODE_L2B_PRAM_T_LOAD_FAILURE		0x90210000
+#define FW_MSG_CODE_L2B_PRAM_C_LOAD_FAILURE		0x90220000
+#define FW_MSG_CODE_L2B_PRAM_X_LOAD_FAILURE		0x90230000
+#define FW_MSG_CODE_L2B_PRAM_U_LOAD_FAILURE		0x90240000
+
+#define FW_MSG_SEQ_NUMBER_MASK				0x0000ffff
+
+	u32 fw_mb_param;
+
+	u32 drv_pulse_mb;
+#define DRV_PULSE_SEQ_MASK				0x00007fff
+#define DRV_PULSE_SYSTEM_TIME_MASK			0xffff0000
+	/* The system time is in the format of
+	 * (year-2001)*12*32 + month*32 + day. */
+#define DRV_PULSE_ALWAYS_ALIVE				0x00008000
+	/* Indicate to the firmware not to go into the
+	 * OS-absent when it is not getting driver pulse.
+	 * This is used for debugging as well for PXE(MBA). */
 
-	struct port_hw_cfg	 port_hw_config[FUNC_MAX];     /* 400*2=800 */
+	u32 mcp_pulse_mb;
+#define MCP_PULSE_SEQ_MASK				0x00007fff
+#define MCP_PULSE_ALWAYS_ALIVE				0x00008000
+	/* Indicates to the driver not to assert due to lack
+	 * of MCP response */
+#define MCP_EVENT_MASK					0xffff0000
+#define MCP_EVENT_OTHER_DRIVER_RESET_REQ		0x00010000
 
-	struct shared_feat_cfg	 shared_feature_config; 	       /* 4 */
+	u32 iscsi_boot_signature;
+	u32 iscsi_boot_block_offset;
 
-	struct port_feat_cfg	 port_feature_config[FUNC_MAX];/* 116*2=232 */
+	u32 reserved[3];
 
 };
 
@@ -678,9 +704,8 @@ struct dev_info {						    /* size */
 /****************************************************************************
  * Management firmware state						    *
  ****************************************************************************/
-/* Allocate 320 bytes for management firmware: still not known exactly
- * how much IMD needs. */
-#define MGMTFW_STATE_WORD_SIZE				    80
+/* Allocate 440 bytes for management firmware */
+#define MGMTFW_STATE_WORD_SIZE				    110
 
 struct mgmtfw_state {
 	u32 opaque[MGMTFW_STATE_WORD_SIZE];
@@ -691,31 +716,40 @@ struct mgmtfw_state {
  * Shared Memory Region 						    *
  ****************************************************************************/
 struct shmem_region {			       /*   SharedMem Offset (size) */
-	u32		    validity_map[FUNC_MAX];    /* 0x0 (4 * 2 = 0x8) */
-#define SHR_MEM_VALIDITY_PCI_CFG		    0x00000001
-#define SHR_MEM_VALIDITY_MB			    0x00000002
-#define SHR_MEM_VALIDITY_DEV_INFO		    0x00000004
+
+	u32			validity_map[PORT_MAX];  /* 0x0 (4*2 = 0x8) */
+#define SHR_MEM_FORMAT_REV_ID			    ('A'<<24)
+#define SHR_MEM_FORMAT_REV_MASK 		    0xff000000
+	/* validity bits */
+#define SHR_MEM_VALIDITY_PCI_CFG		    0x00100000
+#define SHR_MEM_VALIDITY_MB			    0x00200000
+#define SHR_MEM_VALIDITY_DEV_INFO		    0x00400000
+#define SHR_MEM_VALIDITY_RESERVED		    0x00000007
 	/* One licensing bit should be set */
 #define SHR_MEM_VALIDITY_LIC_KEY_IN_EFFECT_MASK     0x00000038
 #define SHR_MEM_VALIDITY_LIC_MANUF_KEY_IN_EFFECT    0x00000008
 #define SHR_MEM_VALIDITY_LIC_UPGRADE_KEY_IN_EFFECT  0x00000010
 #define SHR_MEM_VALIDITY_LIC_NO_KEY_IN_EFFECT	    0x00000020
+	/* Active MFW */
+#define SHR_MEM_VALIDITY_ACTIVE_MFW_UNKNOWN	    0x00000000
+#define SHR_MEM_VALIDITY_ACTIVE_MFW_IPMI	    0x00000040
+#define SHR_MEM_VALIDITY_ACTIVE_MFW_UMP 	    0x00000080
+#define SHR_MEM_VALIDITY_ACTIVE_MFW_NCSI	    0x000000c0
+#define SHR_MEM_VALIDITY_ACTIVE_MFW_NONE	    0x000001c0
+#define SHR_MEM_VALIDITY_ACTIVE_MFW_MASK	    0x000001c0
 
-	struct drv_fw_mb    drv_fw_mb[FUNC_MAX];     /* 0x8 (28 * 2 = 0x38) */
-
-	struct dev_info     dev_info;			    /* 0x40 (0x438) */
+	struct dev_info 	dev_info;		 /* 0x8     (0x438) */
 
-#ifdef _LICENSE_H
-	license_key_t	    drv_lic_key[FUNC_MAX]; /* 0x478 (52 * 2 = 0x68) */
-#else /* Linux! */
-	u8		    reserved[52*FUNC_MAX];
-#endif
+	u8			reserved[52*PORT_MAX];
 
 	/* FW information (for internal FW use) */
-	u32		    fw_info_fio_offset; 	   /* 0x4e0 (0x4)   */
-	struct mgmtfw_state mgmtfw_state;		   /* 0x4e4 (0x140) */
+	u32			fw_info_fio_offset;    /* 0x4a8       (0x4) */
+	struct mgmtfw_state	mgmtfw_state;	       /* 0x4ac     (0x1b8) */
+
+	struct drv_port_mb	port_mb[PORT_MAX];     /* 0x664 (16*2=0x20) */
+	struct drv_func_mb	func_mb[FUNC_MAX];     /* 0x684 (44*2=0x58) */
 
-};							   /* 0x624 */
+};						       /* 0x6dc */
 
 
 #define BCM_5710_FW_MAJOR_VERSION			4
diff --git a/drivers/net/bnx2x_reg.h b/drivers/net/bnx2x_reg.h
index 8605529..5a1aa0b 100644
--- a/drivers/net/bnx2x_reg.h
+++ b/drivers/net/bnx2x_reg.h
@@ -1,6 +1,6 @@
 /* bnx2x_reg.h: Broadcom Everest network driver.
  *
- * Copyright (c) 2007 Broadcom Corporation
+ * Copyright (c) 2007-2008 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -24,6 +24,8 @@
 #define BRB1_REG_BRB1_INT_STS					 0x6011c
 /* [RW 4] Parity mask register #0 read/write */
 #define BRB1_REG_BRB1_PRTY_MASK 				 0x60138
+/* [R 4] Parity register #0 read */
+#define BRB1_REG_BRB1_PRTY_STS					 0x6012c
 /* [RW 10] At address BRB1_IND_FREE_LIST_PRS_CRDT initialize free head. At
    address BRB1_IND_FREE_LIST_PRS_CRDT+1 initialize free tail. At address
    BRB1_IND_FREE_LIST_PRS_CRDT+2 initialize parser initial credit. */
@@ -281,6 +283,8 @@
 #define CDU_REG_CDU_INT_STS					 0x101030
 /* [RW 5] Parity mask register #0 read/write */
 #define CDU_REG_CDU_PRTY_MASK					 0x10104c
+/* [R 5] Parity register #0 read */
+#define CDU_REG_CDU_PRTY_STS					 0x101040
 /* [RC 32] logging of error data in case of a CDU load error:
    {expected_cid[15:0]; xpected_type[2:0]; xpected_region[2:0]; ctive_error;
    ype_error; ctual_active; ctual_compressed_context}; */
@@ -308,6 +312,8 @@
 #define CFC_REG_CFC_INT_STS_CLR 				 0x104100
 /* [RW 4] Parity mask register #0 read/write */
 #define CFC_REG_CFC_PRTY_MASK					 0x104118
+/* [R 4] Parity register #0 read */
+#define CFC_REG_CFC_PRTY_STS					 0x10410c
 /* [RW 21] CID cam access (21:1 - Data; alid - 0) */
 #define CFC_REG_CID_CAM 					 0x104800
 #define CFC_REG_CONTROL0					 0x104028
@@ -354,6 +360,8 @@
 #define CSDM_REG_CSDM_INT_MASK_1				 0xc22ac
 /* [RW 11] Parity mask register #0 read/write */
 #define CSDM_REG_CSDM_PRTY_MASK 				 0xc22bc
+/* [R 11] Parity register #0 read */
+#define CSDM_REG_CSDM_PRTY_STS					 0xc22b0
 #define CSDM_REG_ENABLE_IN1					 0xc2238
 #define CSDM_REG_ENABLE_IN2					 0xc223c
 #define CSDM_REG_ENABLE_OUT1					 0xc2240
@@ -438,6 +446,9 @@
 /* [RW 32] Parity mask register #0 read/write */
 #define CSEM_REG_CSEM_PRTY_MASK_0				 0x200130
 #define CSEM_REG_CSEM_PRTY_MASK_1				 0x200140
+/* [R 32] Parity register #0 read */
+#define CSEM_REG_CSEM_PRTY_STS_0				 0x200124
+#define CSEM_REG_CSEM_PRTY_STS_1				 0x200134
 #define CSEM_REG_ENABLE_IN					 0x2000a4
 #define CSEM_REG_ENABLE_OUT					 0x2000a8
 /* [RW 32] This address space contains all registers and memories that are
@@ -526,6 +537,8 @@
 #define CSEM_REG_TS_9_AS					 0x20005c
 /* [RW 1] Parity mask register #0 read/write */
 #define DBG_REG_DBG_PRTY_MASK					 0xc0a8
+/* [R 1] Parity register #0 read */
+#define DBG_REG_DBG_PRTY_STS					 0xc09c
 /* [RW 2] debug only: These bits indicate the credit for PCI request type 4
    interface; MUST be configured AFTER pci_ext_buffer_strt_addr_lsb/msb are
    configured */
@@ -543,6 +556,8 @@
 #define DMAE_REG_DMAE_INT_MASK					 0x102054
 /* [RW 4] Parity mask register #0 read/write */
 #define DMAE_REG_DMAE_PRTY_MASK 				 0x102064
+/* [R 4] Parity register #0 read */
+#define DMAE_REG_DMAE_PRTY_STS					 0x102058
 /* [RW 1] Command 0 go. */
 #define DMAE_REG_GO_C0						 0x102080
 /* [RW 1] Command 1 go. */
@@ -623,6 +638,8 @@
 #define DORQ_REG_DORQ_INT_STS_CLR				 0x170178
 /* [RW 2] Parity mask register #0 read/write */
 #define DORQ_REG_DORQ_PRTY_MASK 				 0x170190
+/* [R 2] Parity register #0 read */
+#define DORQ_REG_DORQ_PRTY_STS					 0x170184
 /* [RW 8] The address to write the DPM CID to STORM. */
 #define DORQ_REG_DPM_CID_ADDR					 0x170044
 /* [RW 5] The DPM mode CID extraction offset. */
@@ -692,6 +709,8 @@
 #define HC_REG_CONFIG_1 					 0x108004
 /* [RW 3] Parity mask register #0 read/write */
 #define HC_REG_HC_PRTY_MASK					 0x1080a0
+/* [R 3] Parity register #0 read */
+#define HC_REG_HC_PRTY_STS					 0x108094
 /* [RW 17] status block interrupt mask; one in each bit means unmask; zerow
    in each bit means mask; bit 0 - default SB; bit 1 - SB_0; bit 2 - SB_1...
    bit 16- SB_15; addr 0 - port 0; addr 1 - port 1 */
@@ -1127,6 +1146,7 @@
 #define MISC_REG_AEU_GENERAL_ATTN_17				 0xa044
 #define MISC_REG_AEU_GENERAL_ATTN_18				 0xa048
 #define MISC_REG_AEU_GENERAL_ATTN_19				 0xa04c
+#define MISC_REG_AEU_GENERAL_ATTN_10				 0xa028
 #define MISC_REG_AEU_GENERAL_ATTN_11				 0xa02c
 #define MISC_REG_AEU_GENERAL_ATTN_2				 0xa008
 #define MISC_REG_AEU_GENERAL_ATTN_20				 0xa050
@@ -1135,6 +1155,9 @@
 #define MISC_REG_AEU_GENERAL_ATTN_4				 0xa010
 #define MISC_REG_AEU_GENERAL_ATTN_5				 0xa014
 #define MISC_REG_AEU_GENERAL_ATTN_6				 0xa018
+#define MISC_REG_AEU_GENERAL_ATTN_7				 0xa01c
+#define MISC_REG_AEU_GENERAL_ATTN_8				 0xa020
+#define MISC_REG_AEU_GENERAL_ATTN_9				 0xa024
 /* [RW 32] first 32b for inverting the input for function 0; for each bit:
    0= do not invert; 1= invert; mapped as follows: [0] NIG attention for
    function0; [1] NIG attention for function1; [2] GPIO1 mcp; [3] GPIO2 mcp;
@@ -1183,6 +1206,40 @@
    starts at 0x0 for the A0 tape-out and increments by one for each
    all-layer tape-out. */
 #define MISC_REG_CHIP_REV					 0xa40c
+/* [RW 32] The following driver registers(1..6) represent 6 drivers and 32
+   clients. Each client can be controlled by one driver only. One in each
+   bit represent that this driver control the appropriate client (Ex: bit 5
+   is set means this driver control client number 5). addr1 = set; addr0 =
+   clear; read from both addresses will give the same result = status. write
+   to address 1 will set a request to control all the clients that their
+   appropriate bit (in the write command) is set. if the client is free (the
+   appropriate bit in all the other drivers is clear) one will be written to
+   that driver register; if the client isn't free the bit will remain zero.
+   if the appropriate bit is set (the driver request to gain control on a
+   client it already controls the ~MISC_REGISTERS_INT_STS.GENERIC_SW
+   interrupt will be asserted). write to address 0 will set a request to
+   free all the clients that their appropriate bit (in the write command) is
+   set. if the appropriate bit is clear (the driver request to free a client
+   it doesn't controls the ~MISC_REGISTERS_INT_STS.GENERIC_SW interrupt will
+   be asserted). */
+#define MISC_REG_DRIVER_CONTROL_1				 0xa510
+/* [RW 32] GPIO. [31-28] FLOAT port 0; [27-24] FLOAT port 0; When any of
+   these bits is written as a '1'; the corresponding SPIO bit will turn off
+   it's drivers and become an input. This is the reset state of all GPIO
+   pins. The read value of these bits will be a '1' if that last command
+   (#SET; #CLR; or #FLOAT) for this bit was a #FLOAT. (reset value 0xff).
+   [23-20] CLR port 1; 19-16] CLR port 0; When any of these bits is written
+   as a '1'; the corresponding GPIO bit will drive low. The read value of
+   these bits will be a '1' if that last command (#SET; #CLR; or #FLOAT) for
+   this bit was a #CLR. (reset value 0). [15-12] SET port 1; 11-8] port 0;
+   SET When any of these bits is written as a '1'; the corresponding GPIO
+   bit will drive high (if it has that capability). The read value of these
+   bits will be a '1' if that last command (#SET; #CLR; or #FLOAT) for this
+   bit was a #SET. (reset value 0). [7-4] VALUE port 1; [3-0] VALUE port 0;
+   RO; These bits indicate the read value of each of the eight GPIO pins.
+   This is the result value of the pin; not the drive value. Writing these
+   bits will have not effect. */
+#define MISC_REG_GPIO						 0xa490
 /* [RW 1] Setting this bit enables a timer in the GRC block to timeout any
    access that does not finish within
    ~misc_registers_grc_timout_val.grc_timeout_val cycles. When this bit is
@@ -1223,6 +1280,8 @@
 #define MISC_REG_MISC_INT_MASK					 0xa388
 /* [RW 1] Parity mask register #0 read/write */
 #define MISC_REG_MISC_PRTY_MASK 				 0xa398
+/* [R 1] Parity register #0 read */
+#define MISC_REG_MISC_PRTY_STS					 0xa38c
 /* [RW 32] 32 LSB of storm PLL first register; reset val = 0x 071d2911.
    inside order of the bits is: [0] P1 divider[0] (reset value 1); [1] P1
    divider[1] (reset value 0); [2] P1 divider[2] (reset value 0); [3] P1
@@ -1264,6 +1323,55 @@
 /* [RW 20] 20 bit GRC address where the scratch-pad of the MCP that is
    shared with the driver resides */
 #define MISC_REG_SHARED_MEM_ADDR				 0xa2b4
+/* [RW 32] SPIO. [31-24] FLOAT When any of these bits is written as a '1';
+   the corresponding SPIO bit will turn off it's drivers and become an
+   input. This is the reset state of all SPIO pins. The read value of these
+   bits will be a '1' if that last command (#SET; #CL; or #FLOAT) for this
+   bit was a #FLOAT. (reset value 0xff). [23-16] CLR When any of these bits
+   is written as a '1'; the corresponding SPIO bit will drive low. The read
+   value of these bits will be a '1' if that last command (#SET; #CLR; or
+#FLOAT) for this bit was a #CLR. (reset value 0). [15-8] SET When any of
+   these bits is written as a '1'; the corresponding SPIO bit will drive
+   high (if it has that capability). The read value of these bits will be a
+   '1' if that last command (#SET; #CLR; or #FLOAT) for this bit was a #SET.
+   (reset value 0). [7-0] VALUE RO; These bits indicate the read value of
+   each of the eight SPIO pins. This is the result value of the pin; not the
+   drive value. Writing these bits will have not effect. Each 8 bits field
+   is divided as follows: [0] VAUX Enable; when pulsed low; enables supply
+   from VAUX. (This is an output pin only; the FLOAT field is not applicable
+   for this pin); [1] VAUX Disable; when pulsed low; disables supply form
+   VAUX. (This is an output pin only; FLOAT field is not applicable for this
+   pin); [2] SEL_VAUX_B - Control to power switching logic. Drive low to
+   select VAUX supply. (This is an output pin only; it is not controlled by
+   the SET and CLR fields; it is controlled by the Main Power SM; the FLOAT
+   field is not applicable for this pin; only the VALUE fields is relevant -
+   it reflects the output value); [3] reserved; [4] spio_4; [5] spio_5; [6]
+   Bit 0 of UMP device ID select; read by UMP firmware; [7] Bit 1 of UMP
+   device ID select; read by UMP firmware. */
+#define MISC_REG_SPIO						 0xa4fc
+/* [RW 8] These bits enable the SPIO_INTs to signals event to the IGU/MC.
+   according to the following map: [3:0] reserved; [4] spio_4 [5] spio_5;
+   [7:0] reserved */
+#define MISC_REG_SPIO_EVENT_EN					 0xa2b8
+/* [RW 32] SPIO INT. [31-24] OLD_CLR Writing a '1' to these bit clears the
+   corresponding bit in the #OLD_VALUE register. This will acknowledge an
+   interrupt on the falling edge of corresponding SPIO input (reset value
+   0). [23-16] OLD_SET Writing a '1' to these bit sets the corresponding bit
+   in the #OLD_VALUE register. This will acknowledge an interrupt on the
+   rising edge of corresponding SPIO input (reset value 0). [15-8] OLD_VALUE
+   RO; These bits indicate the old value of the SPIO input value. When the
+   ~INT_STATE bit is set; this bit indicates the OLD value of the pin such
+   that if ~INT_STATE is set and this bit is '0'; then the interrupt is due
+   to a low to high edge. If ~INT_STATE is set and this bit is '1'; then the
+   interrupt is due to a high to low edge (reset value 0). [7-0] INT_STATE
+   RO; These bits indicate the current SPIO interrupt state for each SPIO
+   pin. This bit is cleared when the appropriate #OLD_SET or #OLD_CLR
+   command bit is written. This bit is set when the SPIO input does not
+   match the current value in #OLD_VALUE (reset value 0). */
+#define MISC_REG_SPIO_INT					 0xa500
+/* [RW 1] Set by the MCP to remember if one or more of the drivers is/are
+   loaded; 0-prepare; -unprepare */
+#define MISC_REG_UNPREPARED					 0xa424
 #define NIG_MASK_INTERRUPT_PORT0_REG_MASK_EMAC0_MISC_MI_INT	 (0x1<<0)
 #define NIG_MASK_INTERRUPT_PORT0_REG_MASK_SERDES0_LINK_STATUS	 (0x1<<9)
 #define NIG_MASK_INTERRUPT_PORT0_REG_MASK_XGXS0_LINK10G 	 (0x1<<15)
@@ -1392,6 +1500,9 @@
 #define NIG_REG_NIG_INGRESS_EMAC0_NO_CRC			 0x10044
 /* [RW 1] Input enable for RX PBF LP IF */
 #define NIG_REG_PBF_LB_IN_EN					 0x100b4
+/* [RW 1] Value of this register will be transmitted to port swap when
+   ~nig_registers_strap_override.strap_override =1 */
+#define NIG_REG_PORT_SWAP					 0x10394
 /* [RW 1] output enable for RX parser descriptor IF */
 #define NIG_REG_PRS_EOP_OUT_EN					 0x10104
 /* [RW 1] Input enable for RX parser request IF */
@@ -1410,6 +1521,10 @@
 #define NIG_REG_STAT2_BRB_OCTET 				 0x107e0
 #define NIG_REG_STATUS_INTERRUPT_PORT0				 0x10328
 #define NIG_REG_STATUS_INTERRUPT_PORT1				 0x1032c
+/* [RW 1] port swap mux selection. If this register equal to 0 then port
+   swap is equal to SPIO pin that inputs from ifmux_serdes_swap. If 1 then
+   ort swap is equal to ~nig_registers_port_swap.port_swap */
+#define NIG_REG_STRAP_OVERRIDE					 0x10398
 /* [RW 1] output enable for RX_XCM0 IF */
 #define NIG_REG_XCM0_OUT_EN					 0x100f0
 /* [RW 1] output enable for RX_XCM1 IF */
@@ -1499,6 +1614,8 @@
 #define PB_REG_PB_INT_STS					 0x1c
 /* [RW 4] Parity mask register #0 read/write */
 #define PB_REG_PB_PRTY_MASK					 0x38
+/* [R 4] Parity register #0 read */
+#define PB_REG_PB_PRTY_STS					 0x2c
 #define PRS_REG_A_PRSU_20					 0x40134
 /* [R 8] debug only: CFC load request current credit. Transaction based. */
 #define PRS_REG_CFC_LD_CURRENT_CREDIT				 0x40164
@@ -1590,6 +1707,8 @@
 #define PRS_REG_PRS_INT_STS					 0x40188
 /* [RW 8] Parity mask register #0 read/write */
 #define PRS_REG_PRS_PRTY_MASK					 0x401a4
+/* [R 8] Parity register #0 read */
+#define PRS_REG_PRS_PRTY_STS					 0x40198
 /* [RW 8] Context region for pure acknowledge packets. Used in CFC load
    request message */
 #define PRS_REG_PURE_REGIONS					 0x40024
@@ -1718,6 +1837,9 @@
 /* [RW 32] Parity mask register #0 read/write */
 #define PXP2_REG_PXP2_PRTY_MASK_0				 0x120588
 #define PXP2_REG_PXP2_PRTY_MASK_1				 0x120598
+/* [R 32] Parity register #0 read */
+#define PXP2_REG_PXP2_PRTY_STS_0				 0x12057c
+#define PXP2_REG_PXP2_PRTY_STS_1				 0x12058c
 /* [R 1] Debug only: The 'almost full' indication from each fifo (gives
    indication about backpressure) */
 #define PXP2_REG_RD_ALMOST_FULL_0				 0x120424
@@ -1911,6 +2033,8 @@
 #define PXP2_REG_RQ_HC_ENDIAN_M 				 0x1201a8
 /* [WB 53] Onchip address table */
 #define PXP2_REG_RQ_ONCHIP_AT					 0x122000
+/* [RW 13] Pending read limiter threshold; in Dwords */
+#define PXP2_REG_RQ_PDR_LIMIT					 0x12033c
 /* [RW 2] Endian mode for qm */
 #define PXP2_REG_RQ_QM_ENDIAN_M 				 0x120194
 /* [RW 3] page size in L2P table for QM module; -4k; -8k; -16k; -32k; -64k;
@@ -1921,6 +2045,9 @@
 /* [RW 3] Max burst size filed for read requests port 0; 000 - 128B;
    001:256B; 010: 512B; 11:1K:100:2K; 01:4K */
 #define PXP2_REG_RQ_RD_MBS0					 0x120160
+/* [RW 3] Max burst size filed for read requests port 1; 000 - 128B;
+   001:256B; 010: 512B; 11:1K:100:2K; 01:4K */
+#define PXP2_REG_RQ_RD_MBS1					 0x120168
 /* [RW 2] Endian mode for src */
 #define PXP2_REG_RQ_SRC_ENDIAN_M				 0x12019c
 /* [RW 3] page size in L2P table for SRC module; -4k; -8k; -16k; -32k; -64k;
@@ -2000,10 +2127,17 @@
 /* [RW 3] Max burst size filed for write requests port 0; 000 - 128B;
    001:256B; 010: 512B; */
 #define PXP2_REG_RQ_WR_MBS0					 0x12015c
+/* [RW 3] Max burst size filed for write requests port 1; 000 - 128B;
+   001:256B; 010: 512B; */
+#define PXP2_REG_RQ_WR_MBS1					 0x120164
 /* [RW 10] if Number of entries in dmae fifo will be higer than this
    threshold then has_payload indication will be asserted; the default value
    should be equal to &gt;  write MBS size! */
 #define PXP2_REG_WR_DMAE_TH					 0x120368
+/* [RW 10] if Number of entries in usdmdp fifo will be higer than this
+   threshold then has_payload indication will be asserted; the default value
+   should be equal to &gt;  write MBS size! */
+#define PXP2_REG_WR_USDMDP_TH					 0x120348
 /* [R 1] debug only: Indication if PSWHST arbiter is idle */
 #define PXP_REG_HST_ARB_IS_IDLE 				 0x103004
 /* [R 8] debug only: A bit mask for all PSWHST arbiter clients. '1' means
@@ -2021,6 +2155,8 @@
 #define PXP_REG_PXP_INT_STS_CLR_0				 0x10306c
 /* [RW 26] Parity mask register #0 read/write */
 #define PXP_REG_PXP_PRTY_MASK					 0x103094
+/* [R 26] Parity register #0 read */
+#define PXP_REG_PXP_PRTY_STS					 0x103088
 /* [RW 4] The activity counter initial increment value sent in the load
    request */
 #define QM_REG_ACTCTRINITVAL_0					 0x168040
@@ -2127,6 +2263,8 @@
 #define QM_REG_QM_INT_STS					 0x168438
 /* [RW 9] Parity mask register #0 read/write */
 #define QM_REG_QM_PRTY_MASK					 0x168454
+/* [R 9] Parity register #0 read */
+#define QM_REG_QM_PRTY_STS					 0x168448
 /* [R 32] Current queues in pipeline: Queues from 32 to 63 */
 #define QM_REG_QSTATUS_HIGH					 0x16802c
 /* [R 32] Current queues in pipeline: Queues from 0 to 31 */
@@ -2410,6 +2548,8 @@
 #define SRC_REG_SRC_INT_STS					 0x404ac
 /* [RW 3] Parity mask register #0 read/write */
 #define SRC_REG_SRC_PRTY_MASK					 0x404c8
+/* [R 3] Parity register #0 read */
+#define SRC_REG_SRC_PRTY_STS					 0x404bc
 /* [R 4] Used to read the value of the XX protection CAM occupancy counter. */
 #define TCM_REG_CAM_OCCUP					 0x5017c
 /* [RW 1] CDU AG read Interface enable. If 0 - the request input is
@@ -2730,6 +2870,8 @@
 #define TSDM_REG_TSDM_INT_MASK_1				 0x422ac
 /* [RW 11] Parity mask register #0 read/write */
 #define TSDM_REG_TSDM_PRTY_MASK 				 0x422bc
+/* [R 11] Parity register #0 read */
+#define TSDM_REG_TSDM_PRTY_STS					 0x422b0
 /* [RW 5] The number of time_slots in the arbitration cycle */
 #define TSEM_REG_ARB_CYCLE_SIZE 				 0x180034
 /* [RW 3] The source that is associated with arbitration element 0. Source
@@ -2854,6 +2996,9 @@
 /* [RW 32] Parity mask register #0 read/write */
 #define TSEM_REG_TSEM_PRTY_MASK_0				 0x180120
 #define TSEM_REG_TSEM_PRTY_MASK_1				 0x180130
+/* [R 32] Parity register #0 read */
+#define TSEM_REG_TSEM_PRTY_STS_0				 0x180114
+#define TSEM_REG_TSEM_PRTY_STS_1				 0x180124
 /* [R 5] Used to read the XX protection CAM occupancy counter. */
 #define UCM_REG_CAM_OCCUP					 0xe0170
 /* [RW 1] CDU AG read Interface enable. If 0 - the request input is
@@ -3155,6 +3300,8 @@
 #define USDM_REG_USDM_INT_MASK_1				 0xc42b0
 /* [RW 11] Parity mask register #0 read/write */
 #define USDM_REG_USDM_PRTY_MASK 				 0xc42c0
+/* [R 11] Parity register #0 read */
+#define USDM_REG_USDM_PRTY_STS					 0xc42b4
 /* [RW 5] The number of time_slots in the arbitration cycle */
 #define USEM_REG_ARB_CYCLE_SIZE 				 0x300034
 /* [RW 3] The source that is associated with arbitration element 0. Source
@@ -3279,6 +3426,9 @@
 /* [RW 32] Parity mask register #0 read/write */
 #define USEM_REG_USEM_PRTY_MASK_0				 0x300130
 #define USEM_REG_USEM_PRTY_MASK_1				 0x300140
+/* [R 32] Parity register #0 read */
+#define USEM_REG_USEM_PRTY_STS_0				 0x300124
+#define USEM_REG_USEM_PRTY_STS_1				 0x300134
 /* [RW 2] The queue index for registration on Aux1 counter flag. */
 #define XCM_REG_AUX1_Q						 0x20134
 /* [RW 2] Per each decision rule the queue index to register to. */
@@ -3684,6 +3834,8 @@
 #define XSDM_REG_XSDM_INT_MASK_1				 0x1662ac
 /* [RW 11] Parity mask register #0 read/write */
 #define XSDM_REG_XSDM_PRTY_MASK 				 0x1662bc
+/* [R 11] Parity register #0 read */
+#define XSDM_REG_XSDM_PRTY_STS					 0x1662b0
 /* [RW 5] The number of time_slots in the arbitration cycle */
 #define XSEM_REG_ARB_CYCLE_SIZE 				 0x280034
 /* [RW 3] The source that is associated with arbitration element 0. Source
@@ -3808,6 +3960,9 @@
 /* [RW 32] Parity mask register #0 read/write */
 #define XSEM_REG_XSEM_PRTY_MASK_0				 0x280130
 #define XSEM_REG_XSEM_PRTY_MASK_1				 0x280140
+/* [R 32] Parity register #0 read */
+#define XSEM_REG_XSEM_PRTY_STS_0				 0x280124
+#define XSEM_REG_XSEM_PRTY_STS_1				 0x280134
 #define MCPR_NVM_ACCESS_ENABLE_EN				 (1L<<0)
 #define MCPR_NVM_ACCESS_ENABLE_WR_EN				 (1L<<1)
 #define MCPR_NVM_ADDR_NVM_ADDR_VALUE				 (0xffffffL<<0)
@@ -3847,6 +4002,8 @@
 #define EMAC_MDIO_COMM_START_BUSY				 (1L<<29)
 #define EMAC_MDIO_MODE_AUTO_POLL				 (1L<<4)
 #define EMAC_MDIO_MODE_CLAUSE_45				 (1L<<31)
+#define EMAC_MDIO_MODE_CLOCK_CNT				 (0x3fL<<16)
+#define EMAC_MDIO_MODE_CLOCK_CNT_BITSHIFT			 16
 #define EMAC_MODE_25G_MODE					 (1L<<5)
 #define EMAC_MODE_ACPI_RCVD					 (1L<<20)
 #define EMAC_MODE_HALF_DUPLEX					 (1L<<1)
@@ -3874,6 +4031,17 @@
 #define EMAC_RX_MTU_SIZE_JUMBO_ENA				 (1L<<31)
 #define EMAC_TX_MODE_EXT_PAUSE_EN				 (1L<<3)
 #define EMAC_TX_MODE_RESET					 (1L<<0)
+#define MISC_REGISTERS_GPIO_1					 1
+#define MISC_REGISTERS_GPIO_2					 2
+#define MISC_REGISTERS_GPIO_3					 3
+#define MISC_REGISTERS_GPIO_CLR_POS				 16
+#define MISC_REGISTERS_GPIO_FLOAT				 (0xffL<<24)
+#define MISC_REGISTERS_GPIO_FLOAT_POS				 24
+#define MISC_REGISTERS_GPIO_INPUT_HI_Z				 2
+#define MISC_REGISTERS_GPIO_OUTPUT_HIGH 			 1
+#define MISC_REGISTERS_GPIO_OUTPUT_LOW				 0
+#define MISC_REGISTERS_GPIO_PORT_SHIFT				 4
+#define MISC_REGISTERS_GPIO_SET_POS				 8
 #define MISC_REGISTERS_RESET_REG_1_CLEAR			 0x588
 #define MISC_REGISTERS_RESET_REG_1_SET				 0x584
 #define MISC_REGISTERS_RESET_REG_2_CLEAR			 0x598
@@ -3891,6 +4059,25 @@
 #define MISC_REGISTERS_RESET_REG_3_MISC_NIG_MUX_XGXS0_RSTB_HW	 (0x1<<4)
 #define MISC_REGISTERS_RESET_REG_3_MISC_NIG_MUX_XGXS0_TXD_FIFO_RSTB (0x1<<8)
 #define MISC_REGISTERS_RESET_REG_3_SET				 0x5a4
+#define MISC_REGISTERS_SPIO_4					 4
+#define MISC_REGISTERS_SPIO_5					 5
+#define MISC_REGISTERS_SPIO_7					 7
+#define MISC_REGISTERS_SPIO_CLR_POS				 16
+#define MISC_REGISTERS_SPIO_FLOAT				 (0xffL<<24)
+#define GRC_MISC_REGISTERS_SPIO_FLOAT7				 0x80000000
+#define GRC_MISC_REGISTERS_SPIO_FLOAT6				 0x40000000
+#define GRC_MISC_REGISTERS_SPIO_FLOAT5				 0x20000000
+#define GRC_MISC_REGISTERS_SPIO_FLOAT4				 0x10000000
+#define MISC_REGISTERS_SPIO_FLOAT_POS				 24
+#define MISC_REGISTERS_SPIO_INPUT_HI_Z				 2
+#define MISC_REGISTERS_SPIO_INT_OLD_SET_POS			 16
+#define MISC_REGISTERS_SPIO_OUTPUT_HIGH 			 1
+#define MISC_REGISTERS_SPIO_OUTPUT_LOW				 0
+#define MISC_REGISTERS_SPIO_SET_POS				 8
+#define HW_LOCK_MAX_RESOURCE_VALUE				 31
+#define HW_LOCK_RESOURCE_8072_MDIO				 0
+#define HW_LOCK_RESOURCE_GPIO					 1
+#define HW_LOCK_RESOURCE_SPIO					 2
 #define AEU_INPUTS_ATTN_BITS_BRB_PARITY_ERROR		      (1<<18)
 #define AEU_INPUTS_ATTN_BITS_CCM_HW_INTERRUPT		      (1<<31)
 #define AEU_INPUTS_ATTN_BITS_CDU_HW_INTERRUPT		      (1<<9)
@@ -3918,6 +4105,7 @@
 #define AEU_INPUTS_ATTN_BITS_QM_HW_INTERRUPT		      (1<<3)
 #define AEU_INPUTS_ATTN_BITS_QM_PARITY_ERROR		      (1<<2)
 #define AEU_INPUTS_ATTN_BITS_SEARCHER_PARITY_ERROR	      (1<<22)
+#define AEU_INPUTS_ATTN_BITS_SPIO5			      (1<<15)
 #define AEU_INPUTS_ATTN_BITS_TCM_HW_INTERRUPT		      (1<<27)
 #define AEU_INPUTS_ATTN_BITS_TIMERS_HW_INTERRUPT	      (1<<5)
 #define AEU_INPUTS_ATTN_BITS_TSDM_HW_INTERRUPT		      (1<<25)
@@ -4206,6 +4394,9 @@
 #define MDIO_XGXS_BLOCK2_RX_LN_SWAP_FORCE_ENABLE	0x4000
 #define MDIO_XGXS_BLOCK2_TX_LN_SWAP			0x11
 #define MDIO_XGXS_BLOCK2_TX_LN_SWAP_ENABLE		0x8000
+#define MDIO_XGXS_BLOCK2_UNICORE_MODE_10G		0x14
+#define MDIO_XGXS_BLOCK2_UNICORE_MODE_10G_CX4_XGXS	0x0001
+#define MDIO_XGXS_BLOCK2_UNICORE_MODE_10G_HIGIG_XGXS	0x0010
 #define MDIO_XGXS_BLOCK2_TEST_MODE_LANE 		0x15
 
 #define MDIO_REG_BANK_GP_STATUS 			0x8120
@@ -4362,11 +4553,13 @@
 #define MDIO_COMBO_IEEE0_AUTO_NEG_LINK_PARTNER_ABILITY1_SGMII_MODE   0x0001
 
 
+#define EXT_PHY_AUTO_NEG_DEVAD				0x7
 #define EXT_PHY_OPT_PMA_PMD_DEVAD			0x1
 #define EXT_PHY_OPT_WIS_DEVAD				0x2
 #define EXT_PHY_OPT_PCS_DEVAD				0x3
 #define EXT_PHY_OPT_PHY_XS_DEVAD			0x4
 #define EXT_PHY_OPT_CNTL				0x0
+#define EXT_PHY_OPT_CNTL2				0x7
 #define EXT_PHY_OPT_PMD_RX_SD				0xa
 #define EXT_PHY_OPT_PMD_MISC_CNTL			0xca0a
 #define EXT_PHY_OPT_PHY_IDENTIFIER			0xc800
@@ -4378,11 +4571,24 @@
 #define EXT_PHY_OPT_LASI_STATUS 			0x9005
 #define EXT_PHY_OPT_PCS_STATUS				0x0020
 #define EXT_PHY_OPT_XGXS_LANE_STATUS			0x0018
+#define EXT_PHY_OPT_AN_LINK_STATUS			0x8304
+#define EXT_PHY_OPT_AN_CL37_CL73			0x8370
+#define EXT_PHY_OPT_AN_CL37_FD				0xffe4
+#define EXT_PHY_OPT_AN_CL37_AN				0xffe0
+#define EXT_PHY_OPT_AN_ADV				0x11
 
 #define EXT_PHY_KR_PMA_PMD_DEVAD			0x1
 #define EXT_PHY_KR_PCS_DEVAD				0x3
 #define EXT_PHY_KR_AUTO_NEG_DEVAD			0x7
 #define EXT_PHY_KR_CTRL 				0x0000
+#define EXT_PHY_KR_STATUS				0x0001
+#define EXT_PHY_KR_AUTO_NEG_COMPLETE		    	0x0020
+#define EXT_PHY_KR_AUTO_NEG_ADVERT			0x0010
+#define EXT_PHY_KR_AUTO_NEG_ADVERT_PAUSE	    	0x0400
+#define EXT_PHY_KR_AUTO_NEG_ADVERT_PAUSE_ASYMMETRIC 	0x0800
+#define EXT_PHY_KR_AUTO_NEG_ADVERT_PAUSE_BOTH	    	0x0C00
+#define EXT_PHY_KR_AUTO_NEG_ADVERT_PAUSE_MASK	    	0x0C00
+#define EXT_PHY_KR_LP_AUTO_NEG				0x0013
 #define EXT_PHY_KR_CTRL2				0x0007
 #define EXT_PHY_KR_PCS_STATUS				0x0020
 #define EXT_PHY_KR_PMD_CTRL				0x0096
@@ -4391,4 +4597,8 @@
 #define EXT_PHY_KR_MISC_CTRL1				0xca85
 #define EXT_PHY_KR_GEN_CTRL				0xca10
 #define EXT_PHY_KR_ROM_CODE				0xca19
+#define EXT_PHY_KR_ROM_RESET_INTERNAL_MP		0x0188
+#define EXT_PHY_KR_ROM_MICRO_RESET			0x018a
+
+#define EXT_PHY_SFX7101_XGXS_TEST1	    0xc00a
 
-- 
1.5.3.2




