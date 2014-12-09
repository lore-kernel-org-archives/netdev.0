From: Andrey Volkov <andrey.volkov@nexvision.fr>
Subject: [PATCH 1/1] net: dsa: Fix of kernel panic in case of missing PHY.
Date: Tue, 09 Dec 2014 18:31:49 +0100
Message-ID: <54873205.30401@nexvision.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 19.mo3.mail-out.ovh.net ([178.32.98.231]:40220 "EHLO
	mo3.mail-out.ovh.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751057AbaLIRvA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 12:51:00 -0500
Received: from mail436.ha.ovh.net (b9.ovh.net [213.186.33.59])
	by mo3.mail-out.ovh.net (Postfix) with SMTP id 011BAFFA106
	for <netdev@vger.kernel.org>; Tue,  9 Dec 2014 18:31:53 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix of kernel panic in case of missing PHY.

Signed-off-by: Andrey Volkov <andrey.volkov@nexvision.fr>
---
 net/dsa/slave.c |   19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 528380a..6f89caa 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -512,7 +512,7 @@ static int dsa_slave_fixed_link_update(struct net_device *dev,
 }
 
 /* slave device setup *******************************************************/
-static void dsa_slave_phy_setup(struct dsa_slave_priv *p,
+static int dsa_slave_phy_setup(struct dsa_slave_priv *p,
 				struct net_device *slave_dev)
 {
 	struct dsa_switch *ds = p->parent;
@@ -533,7 +533,7 @@ static void dsa_slave_phy_setup(struct dsa_slave_priv *p,
 		ret = of_phy_register_fixed_link(port_dn);
 		if (ret) {
 			netdev_err(slave_dev, "failed to register fixed PHY\n");
-			return;
+			return ret;
 		}
 		phy_is_fixed = true;
 		phy_dn = port_dn;
@@ -555,12 +555,17 @@ static void dsa_slave_phy_setup(struct dsa_slave_priv *p,
 	 */
 	if (!p->phy) {
 		p->phy = ds->slave_mii_bus->phy_map[p->port];
-		phy_connect_direct(slave_dev, p->phy, dsa_slave_adjust_link,
+		if(p->phy)
+			phy_connect_direct(slave_dev, p->phy, dsa_slave_adjust_link,
 				   p->phy_interface);
+		else
+			return -ENODEV;
+
 	} else {
 		netdev_info(slave_dev, "attached PHY at address %d [%s]\n",
 			    p->phy->addr, p->phy->drv->name);
 	}
+	return 0;
 }
 
 int dsa_slave_suspend(struct net_device *slave_dev)
@@ -653,7 +658,13 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	p->old_link = -1;
 	p->old_duplex = -1;
 
-	dsa_slave_phy_setup(p, slave_dev);
+	ret = dsa_slave_phy_setup(p, slave_dev);
+	if (ret) {
+		netdev_err(master, "error %d registering interface %s\n",
+			   ret, slave_dev->name);
+		free_netdev(slave_dev);
+		return NULL;
+	}
 
 	ret = register_netdev(slave_dev);
 	if (ret) {
