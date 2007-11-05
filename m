From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 3/7] sky2: longer PHY delay
Date: Mon, 05 Nov 2007 15:52:10 -0800
Message-ID: <20071105235340.090185872@linux-foundation.org>
References: <20071105235207.799504040@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:54814 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752082AbXKEX4o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 18:56:44 -0500
Content-Disposition: inline; filename=sky2-phy-delay.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Increse phy delay and handle I/O errors.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/drivers/net/sky2.c	2007-11-05 15:04:55.000000000 -0800
+++ b/drivers/net/sky2.c	2007-11-05 15:05:00.000000000 -0800
@@ -156,7 +156,7 @@ static const char *yukon2_name[] = {
 
 static void sky2_set_multicast(struct net_device *dev);
 
-/* Access to external PHY */
+/* Access to PHY via serial interconnect */
 static int gm_phy_write(struct sky2_hw *hw, unsigned port, u16 reg, u16 val)
 {
 	int i;
@@ -166,13 +166,22 @@ static int gm_phy_write(struct sky2_hw *
 		    GM_SMI_CT_PHY_AD(PHY_ADDR_MARV) | GM_SMI_CT_REG_AD(reg));
 
 	for (i = 0; i < PHY_RETRIES; i++) {
-		if (!(gma_read16(hw, port, GM_SMI_CTRL) & GM_SMI_CT_BUSY))
+		u16 ctrl = gma_read16(hw, port, GM_SMI_CTRL);
+		if (ctrl == 0xffff)
+			goto io_error;
+
+		if (!(ctrl & GM_SMI_CT_BUSY))
 			return 0;
-		udelay(1);
+
+		udelay(10);
 	}
 
-	printk(KERN_WARNING PFX "%s: phy write timeout\n", hw->dev[port]->name);
+	dev_warn(&hw->pdev->dev,"%s: phy write timeout\n", hw->dev[port]->name);
 	return -ETIMEDOUT;
+
+io_error:
+	dev_err(&hw->pdev->dev, "%s: phy I/O error\n", hw->dev[port]->name);
+	return -EIO;
 }
 
 static int __gm_phy_read(struct sky2_hw *hw, unsigned port, u16 reg, u16 *val)
@@ -183,23 +192,29 @@ static int __gm_phy_read(struct sky2_hw 
 		    | GM_SMI_CT_REG_AD(reg) | GM_SMI_CT_OP_RD);
 
 	for (i = 0; i < PHY_RETRIES; i++) {
-		if (gma_read16(hw, port, GM_SMI_CTRL) & GM_SMI_CT_RD_VAL) {
+		u16 ctrl = gma_read16(hw, port, GM_SMI_CTRL);
+		if (ctrl == 0xffff)
+			goto io_error;
+
+		if (ctrl & GM_SMI_CT_RD_VAL) {
 			*val = gma_read16(hw, port, GM_SMI_DATA);
 			return 0;
 		}
 
-		udelay(1);
+		udelay(10);
 	}
 
+	dev_warn(&hw->pdev->dev, "%s: phy read timeout\n", hw->dev[port]->name);
 	return -ETIMEDOUT;
+io_error:
+	dev_err(&hw->pdev->dev, "%s: phy I/O error\n", hw->dev[port]->name);
+	return -EIO;
 }
 
-static u16 gm_phy_read(struct sky2_hw *hw, unsigned port, u16 reg)
+static inline u16 gm_phy_read(struct sky2_hw *hw, unsigned port, u16 reg)
 {
 	u16 v;
-
-	if (__gm_phy_read(hw, port, reg, &v) != 0)
-		printk(KERN_WARNING PFX "%s: phy read timeout\n", hw->dev[port]->name);
+	__gm_phy_read(hw, port, reg, &v);
 	return v;
 }
 

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

