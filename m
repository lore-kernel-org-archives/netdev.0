From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH 4/5] sky2: Refactor sky2_down into two functions
Date: Wed, 10 Feb 2010 23:12:16 +0900
Message-ID: <4B72BEC0.7090200@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f202.google.com ([209.85.216.202]:46984 "EHLO
	mail-px0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754424Ab0BJOR3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 09:17:29 -0500
Received: by pxi40 with SMTP id 40so12303pxi.21
        for <netdev@vger.kernel.org>; Wed, 10 Feb 2010 06:17:28 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Create a sky2_hw_down that brings the hardware down.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |   28 +++++++++++++++++-----------
 1 files changed, 17 insertions(+), 11 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index c41a2ed..9ecc129 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1926,21 +1926,12 @@ static void sky2_tx_reset(struct sky2_hw *hw, unsigned port)
 	sky2_write8(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_RST_SET);
 }
 
-/* Network shutdown */
-static int sky2_down(struct net_device *dev)
+static void sky2_hw_down(struct sky2_port *sky2)
 {
-	struct sky2_port *sky2 = netdev_priv(dev);
 	struct sky2_hw *hw = sky2->hw;
 	unsigned port = sky2->port;
-	u16 ctrl;
 	u32 imask;
-
-	/* Never really got started! */
-	if (!sky2->tx_le)
-		return 0;
-
-	if (netif_msg_ifdown(sky2))
-		printk(KERN_INFO PFX "%s: disabling interface\n", dev->name);
+	u16 ctrl;
 
 	/* Force flow control off */
 	sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_PAUSE_OFF);
@@ -1990,6 +1981,21 @@ static int sky2_down(struct net_device *dev)
 
 	/* Free any pending frames stuck in HW queue */
 	sky2_tx_complete(sky2, sky2->tx_prod);
+}
+
+/* Network shutdown */
+static int sky2_down(struct net_device *dev)
+{
+	struct sky2_port *sky2 = netdev_priv(dev);
+
+	/* Never really got started! */
+	if (!sky2->tx_le)
+		return 0;
+
+	if (netif_msg_ifdown(sky2))
+		printk(KERN_INFO PFX "%s: disabling interface\n", dev->name);
+
+	sky2_hw_down(sky2);
 
 	sky2_free_buffers(sky2);
 
-- 
1.5.6.5


