From: "David Rivshin (Allworx)" <drivshin.allworx@gmail.com>
Subject: [PATCH] drivers: net: cpsw: fix RMII/RGMII mode when used with
 fixed-link PHY
Date: Wed, 9 Dec 2015 22:31:15 -0500
Message-ID: <20151209223115.6c5a400f.drivshin.allworx@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Markus Brunner <systemprogrammierung.brunner@gmail.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Pascal Speck <kernel@iktek.de>,
	Daniel Trautmann <dtrautmann@ibhsoftec-sps.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f66.google.com ([209.85.192.66]:34501 "EHLO
	mail-qg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751713AbbLJDbU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 22:31:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 1f71e8c96fc654724723ce987e0a8b2aeb81746d ("drivers: net: cpsw: Add
support for fixed-link PHY") used a 'goto no_phy_slave' to skip over the
processing of the mutually-exclusive "phy_id" property. Unfortunately that
also skipped the "phy-mode" property processing, leaving slave_data->phy_if
with its default of PHY_INTERFACE_MODE_NA(0). This later gets passed to
phy_connect() in cpsw_slave_open(), and eventually to cpsw_phy_sel() where
it hits a default case that configures the MAC for MII mode.

The user visible symptom is that while kernel log messages seem to indicate
that the interface is set up, there is no network communication. Eventually
a watchdog error occurs:
    NETDEV WATCHDOG: eth0 (cpsw): transmit queue 0 timed out

Signed-off-by: David Rivshin (Allworx) <drivshin.allworx@gmail.com>
Fixes: 1f71e8c96fc6 ("drivers: net: cpsw: Add support for fixed-link PHY")
---

This patch was originally developed in parallel with 1f71e8c96fc6 to
accomplish the same goal. When I replaced this patch with 1f71e8c96fc6,
I found that it did not work on my hardware (which uses RGMII), so I
am submitting this patch now as a bugfix. I have rebased this to the
current head of the net tree, but because of the different order of the
logic (see explanation below) it ends up replacing 1f71e8c96fc6's changes
in cpsw.c. If a minimal patch is preferred, I can do that instead.

Besides fixing the bug mentioned in the commit log, there are a few other
differences to note:
 * If both "phy_id" and a "fixed-link" subnode are present this patch will
   use the "phy_id" property. This should preserve current behavior with
   existing devicetrees that might incorrectly have both. This motivates
   the biggest difference in code organization from 1f71e8c96fc6.
 * Some error messages have been tweaked to reflect the slightly changed
   meanings of the checks.
 * of_node_get() is called on slave_node before passing the result to
   of_phy_find_device(). This increments the reference count, which I
   believe is correct for this situation, but I'm not certain of that.
 * Uses the phy_device's 'addr' instead of 'phy_id' field when constructing
   slave_data->phy_id. Pascal Speck separately came to the same conclusion
   in another patch [1].
 * [2] pointed out that the 'lenp' sanity check was wrong, and since this
   patch re-arranged that check anyways I incorporated that fix as well.
Although the last three items could be fixed separately, it seemed like that
would be unnecessary churn since those same lines were already touched in
this patch. Let me know if its preferred to fix them separately.

This patch is also very similar to one Daniel Trautmann submitted [3], with
the biggest difference being that Daniel's patch uses the new priv->phy_node
field and of_node_get(). While this seems like a better path overall it
does not work if more than once CPSW slave is used, due to struct cpsw_priv
being shared with all the slaves. I am under the impression that phy_node
should really be in struct cpsw_slave instead, but I will leave that for
another patch.

Checkpatch does flag 3 issues I've decided to leave, but I'd be happy to
resolve them if desired:
WARNING: line over 80 characters (cpsw.c:2046):
+                               dev_err(&pdev->dev, "Invalid slave[%d] phy_id property\n", i);
WARNING: line over 80 characters (cpsw.c:2077):
+                       dev_err(&pdev->dev, "No slave[%d] phy_id or fixed-link property\n", i);
    Both modifications of the same pre-existing messages that was already
    over 80 characters. Seemed more readable to leave them as 1-liners.
CHECK: spaces preferred around that '+' (ctx:VxV) (cpsw.c:2051):
+                       phyid = be32_to_cpup(parp+1);
    ALso pre-existing, and far enough from the purpose of this patch that it
    seemed gratuitous to change now.

[1] http://www.spinics.net/lists/netdev/msg355254.html
[2] http://www.spinics.net/lists/netdev/msg351703.html
[3] http://www.spinics.net/lists/netdev/msg351674.html

(Side note: This is my first patch submission, and any feedback on things 
to do differently in the future would be appreciated.)

 drivers/net/ethernet/ti/cpsw.c | 65 +++++++++++++++++++++++++-----------------
 1 file changed, 39 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 48b92c9..ba8d086 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -26,6 +26,7 @@
 #include <linux/netdevice.h>
 #include <linux/net_tstamp.h>
 #include <linux/phy.h>
+#include <linux/phy_fixed.h>
 #include <linux/workqueue.h>
 #include <linux/delay.h>
 #include <linux/pm_runtime.h>
@@ -2026,45 +2027,57 @@ static int cpsw_probe_dt(struct cpsw_priv *priv,
 	for_each_child_of_node(node, slave_node) {
 		struct cpsw_slave_data *slave_data = data->slave_data + i;
 		const void *mac_addr = NULL;
-		u32 phyid;
 		int lenp;
 		const __be32 *parp;
-		struct device_node *mdio_node;
-		struct platform_device *mdio;
 
 		/* This is no slave child node, continue */
 		if (strcmp(slave_node->name, "slave"))
 			continue;
 
 		priv->phy_node = of_parse_phandle(slave_node, "phy-handle", 0);
-		if (of_phy_is_fixed_link(slave_node)) {
-			struct phy_device *pd;
+		parp = of_get_property(slave_node, "phy_id", &lenp);
+
+		if (parp) {
+			u32 phyid;
+			struct device_node *mdio_node;
+			struct platform_device *mdio;
 
+			if (lenp != (sizeof(__be32) * 2)) {
+				dev_err(&pdev->dev, "Invalid slave[%d] phy_id property\n", i);
+				goto no_phy_slave;
+			}
+
+			mdio_node = of_find_node_by_phandle(be32_to_cpup(parp));
+			phyid = be32_to_cpup(parp+1);
+			mdio = of_find_device_by_node(mdio_node);
+			of_node_put(mdio_node);
+			if (!mdio) {
+				dev_err(&pdev->dev, "Missing mdio platform device\n");
+				return -EINVAL;
+			}
+			snprintf(slave_data->phy_id, sizeof(slave_data->phy_id),
+				 PHY_ID_FMT, mdio->name, phyid);
+		} else if (of_phy_is_fixed_link(slave_node)) {
+			struct device_node *phy_node;
+			struct phy_device *phy_dev;
+
+			/* In the case of a fixed PHY, the DT node associated
+			 * to the PHY is the Ethernet MAC DT node.
+			 */
 			ret = of_phy_register_fixed_link(slave_node);
-			if (ret)
-				return ret;
-			pd = of_phy_find_device(slave_node);
-			if (!pd)
-				return -ENODEV;
+			if (ret) {
+				dev_err(&pdev->dev, "Cannot register fixed PHY\n");
+				goto no_phy_slave;
+			}
+			phy_node = of_node_get(slave_node);
+			phy_dev = of_phy_find_device(phy_node);
 			snprintf(slave_data->phy_id, sizeof(slave_data->phy_id),
-				 PHY_ID_FMT, pd->bus->id, pd->phy_id);
-			goto no_phy_slave;
-		}
-		parp = of_get_property(slave_node, "phy_id", &lenp);
-		if ((parp == NULL) || (lenp != (sizeof(void *) * 2))) {
-			dev_err(&pdev->dev, "Missing slave[%d] phy_id property\n", i);
+				PHY_ID_FMT, phy_dev->bus->id, phy_dev->addr);
+		} else {
+			dev_err(&pdev->dev, "No slave[%d] phy_id or fixed-link property\n", i);
 			goto no_phy_slave;
 		}
-		mdio_node = of_find_node_by_phandle(be32_to_cpup(parp));
-		phyid = be32_to_cpup(parp+1);
-		mdio = of_find_device_by_node(mdio_node);
-		of_node_put(mdio_node);
-		if (!mdio) {
-			dev_err(&pdev->dev, "Missing mdio platform device\n");
-			return -EINVAL;
-		}
-		snprintf(slave_data->phy_id, sizeof(slave_data->phy_id),
-			 PHY_ID_FMT, mdio->name, phyid);
+
 		slave_data->phy_if = of_get_phy_mode(slave_node);
 		if (slave_data->phy_if < 0) {
 			dev_err(&pdev->dev, "Missing or malformed slave[%d] phy-mode property\n",
-- 
2.5.0
