From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (5/12) skge: simplify definition of wake on lan support
Date: Thu, 3 Mar 2005 11:36:46 -0800
Message-ID: <20050303113646.0872b57a@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Add a simple encapsulation of wake on lan support predicate.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- skge-2.6.11/drivers/net/skge.c.orig	2005-03-02 17:22:30.000000000 -0800
+++ skge-2.6.11/drivers/net/skge.c	2005-03-02 17:24:23.000000000 -0800
@@ -147,17 +147,18 @@
 	}
 }
 
+/* Wake on Lan only supported on Yukon chps with rev 1 or above */
+static int wol_supported(const struct skge_hw *hw)
+{
+	return !((hw->chip_id == CHIP_ID_GENESIS ||
+		  (hw->chip_id == CHIP_ID_YUKON && chip_rev(hw) == 0)));
+}
 
 static void skge_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
 	struct skge_port *skge = netdev_priv(dev);
-	struct skge_hw *hw = skge->hw;
 
-	if (hw->chip_id == CHIP_ID_GENESIS ||
-	    (hw->chip_id == CHIP_ID_YUKON && chip_rev(hw) == 0))
-		wol->supported = 0;
-	else
-		wol->supported = WAKE_MAGIC;
+	wol->supported = wol_supported(skge->hw) ? WAKE_MAGIC : 0;
 	wol->wolopts = skge->wol ? WAKE_MAGIC : 0;
 }
 
@@ -169,9 +170,7 @@
 	if(wol->wolopts != WAKE_MAGIC && wol->wolopts != 0)
 		return -EOPNOTSUPP;
 
-	if (wol->wolopts == WAKE_MAGIC &&
-	    ((hw->chip_id == CHIP_ID_GENESIS ||
-	      (hw->chip_id == CHIP_ID_YUKON && chip_rev(hw) == 0))))
+	if (wol->wolopts == WAKE_MAGIC && !wol_supported(hw))
 		return -EOPNOTSUPP;
 
 	skge->wol = wol->wolopts == WAKE_MAGIC;
