From: Joe Perches <joe@perches.com>
Subject: [PATCH] atl1c_main.c: add wait_for_idle routine
Date: Sun, 31 May 2009 23:44:54 -0700
Message-ID: <1243838695.3402.17.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Yang Hongyang <yanghy@cn.fujitsu.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: Jie Yang <jie.yang@atheros.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:1165 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752520AbZFAGo6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2009 02:44:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Slight refactoring of duplicated wait for idle checks
Spelling fix

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/drivers/net/atl1c/atl1c_main.c b/drivers/net/atl1c/atl1c_main.c
index fc1092b..5d2c8f7 100644
--- a/drivers/net/atl1c/atl1c_main.c
+++ b/drivers/net/atl1c/atl1c_main.c
@@ -164,6 +164,24 @@ static inline void atl1c_irq_reset(struct atl1c_adapter *adapter)
 }
 
 /*
+ * atl1c_wait_until_idle - wait up to AT_HW_MAX_IDLE_DELAY reads
+ * of the idle status register until the device is actually idle
+ */
+static u32 atl1c_wait_until_idle(struct atl1c_hw *hw)
+{
+	int timeout;
+	u32 data;
+
+	for (timeout = 0; timeout < AT_HW_MAX_IDLE_DELAY; timeout++) {
+		AT_READ_REG(hw, REG_IDLE_STATUS, &data);
+		if ((data & IDLE_STATUS_MASK) == 0)
+			return 0;
+		msleep(1);
+	}
+	return data;
+}
+
+/*
  * atl1c_phy_config - Timer Call-back
  * @data: pointer to netdev cast into an unsigned long
  */
@@ -1106,7 +1124,6 @@ static void atl1c_configure_dma(struct atl1c_adapter *adapter)
 static int atl1c_stop_mac(struct atl1c_hw *hw)
 {
 	u32 data;
-	int timeout;
 
 	AT_READ_REG(hw, REG_RXQ_CTRL, &data);
 	data &= ~(RXQ1_CTRL_EN | RXQ2_CTRL_EN |
@@ -1117,25 +1134,13 @@ static int atl1c_stop_mac(struct atl1c_hw *hw)
 	data &= ~TXQ_CTRL_EN;
 	AT_WRITE_REG(hw, REG_TWSI_CTRL, data);
 
-	for (timeout = 0; timeout < AT_HW_MAX_IDLE_DELAY; timeout++) {
-		AT_READ_REG(hw, REG_IDLE_STATUS, &data);
-		if ((data & (IDLE_STATUS_RXQ_NO_IDLE |
-			IDLE_STATUS_TXQ_NO_IDLE)) == 0)
-			break;
-		msleep(1);
-	}
+	atl1c_wait_until_idle(hw);
 
 	AT_READ_REG(hw, REG_MAC_CTRL, &data);
 	data &= ~(MAC_CTRL_TX_EN | MAC_CTRL_RX_EN);
 	AT_WRITE_REG(hw, REG_MAC_CTRL, data);
 
-	for (timeout = 0; timeout < AT_HW_MAX_IDLE_DELAY; timeout++) {
-		AT_READ_REG(hw, REG_IDLE_STATUS, &data);
-		if ((data & IDLE_STATUS_MASK) == 0)
-			return 0;
-		msleep(1);
-	}
-	return data;
+	return (int)atl1c_wait_until_idle(hw);
 }
 
 static void atl1c_enable_rx_ctrl(struct atl1c_hw *hw)
@@ -1178,8 +1183,6 @@ static int atl1c_reset_mac(struct atl1c_hw *hw)
 {
 	struct atl1c_adapter *adapter = (struct atl1c_adapter *)hw->adapter;
 	struct pci_dev *pdev = adapter->pdev;
-	u32 idle_status_data = 0;
-	int timeout = 0;
 	int ret;
 
 	AT_WRITE_REG(hw, REG_IMR, 0);
@@ -1198,15 +1201,10 @@ static int atl1c_reset_mac(struct atl1c_hw *hw)
 	AT_WRITE_FLUSH(hw);
 	msleep(10);
 	/* Wait at least 10ms for All module to be Idle */
-	for (timeout = 0; timeout < AT_HW_MAX_IDLE_DELAY; timeout++) {
-		AT_READ_REG(hw, REG_IDLE_STATUS, &idle_status_data);
-		if ((idle_status_data & IDLE_STATUS_MASK) == 0)
-			break;
-		msleep(1);
-	}
-	if (timeout >= AT_HW_MAX_IDLE_DELAY) {
+
+	if (atl1c_wait_until_idle(hw)) {
 		dev_err(&pdev->dev,
-			"MAC state machine cann't be idle since"
+			"MAC state machine can't be idle since"
 			" disabled for 10ms second\n");
 		return -1;
 	}


