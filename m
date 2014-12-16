From: David Miller <davem@davemloft.net>
Subject: Re: FIXED_PHY is broken...
Date: Tue, 16 Dec 2014 14:30:27 -0500 (EST)
Message-ID: <20141216.143027.1243798311589198629.davem@davemloft.net>
References: <20141216.112534.1684849738404064350.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55182 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751012AbaLPTaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 14:30:30 -0500
In-Reply-To: <20141216.112534.1684849738404064350.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 16 Dec 2014 11:25:34 -0500 (EST)

> I get this now when I run oldconfig:
> 
> warning: (NET_DSA_BCM_SF2 && BCMGENET && SYSTEMPORT) selects FIXED_PHY which has unmet direct dependencies (NETDEVICES && PHYLIB=y)

Here is how I'm going to fix this.

FIXED_PHY needs to be allowed to be modular, and built even if PHYLIB is
modular too.

====================
[PATCH] net: Allow FIXED_PHY to be modular.

Otherwise we get things like:

warning: (NET_DSA_BCM_SF2 && BCMGENET && SYSTEMPORT) selects FIXED_PHY which has unmet direct dependencies (NETDEVICES && PHYLIB=y)

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/phy/Kconfig   | 4 ++--
 include/linux/phy_fixed.h | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index b4b0f80..a3c251b 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -119,8 +119,8 @@ config MICREL_PHY
 	  Supports the KSZ9021, VSC8201, KS8001 PHYs.
 
 config FIXED_PHY
-	bool "Driver for MDIO Bus/PHY emulation with fixed speed/link PHYs"
-	depends on PHYLIB=y
+	tristate "Driver for MDIO Bus/PHY emulation with fixed speed/link PHYs"
+	depends on PHYLIB
 	---help---
 	  Adds the platform "fixed" MDIO Bus to cover the boards that use
 	  PHYs that are not connected to the real MDIO bus.
diff --git a/include/linux/phy_fixed.h b/include/linux/phy_fixed.h
index f2ca1b4..7e75bfe 100644
--- a/include/linux/phy_fixed.h
+++ b/include/linux/phy_fixed.h
@@ -11,7 +11,7 @@ struct fixed_phy_status {
 
 struct device_node;
 
-#ifdef CONFIG_FIXED_PHY
+#if IS_ENABLED(CONFIG_FIXED_PHY)
 extern int fixed_phy_add(unsigned int irq, int phy_id,
 			 struct fixed_phy_status *status);
 extern struct phy_device *fixed_phy_register(unsigned int irq,
-- 
1.7.11.7
