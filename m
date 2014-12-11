From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 2/2] net: dsa: propagate error code from dsa_slave_phy_setup
Date: Thu, 11 Dec 2014 12:49:16 -0800
Message-ID: <1418330956-17151-3-git-send-email-f.fainelli@gmail.com>
References: <1418330956-17151-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, computersforpeace@gmail.com,
	andrey.volkov@nexvision.fr, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:50407 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758967AbaLKUtg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 15:49:36 -0500
Received: by mail-pd0-f178.google.com with SMTP id r10so5733628pdi.9
        for <netdev@vger.kernel.org>; Thu, 11 Dec 2014 12:49:36 -0800 (PST)
In-Reply-To: <1418330956-17151-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case we cannot attach to our slave netdevice PHY, error out and
propagate that error up to the caller: dsa_slave_create().

Fixes: 0d8bcdd383b8 ("net: dsa: allow for more complex PHY setups")
Signed-off-by: Andrey Volkov <andrey.volkov@nexvision.fr>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/slave.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 0efaab1e408b..646c24ce4501 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -448,7 +448,7 @@ static int dsa_slave_fixed_link_update(struct net_device *dev,
 }
 
 /* slave device setup *******************************************************/
-static void dsa_slave_phy_setup(struct dsa_slave_priv *p,
+static int dsa_slave_phy_setup(struct dsa_slave_priv *p,
 				struct net_device *slave_dev)
 {
 	struct dsa_switch *ds = p->parent;
@@ -469,7 +469,7 @@ static void dsa_slave_phy_setup(struct dsa_slave_priv *p,
 		ret = of_phy_register_fixed_link(port_dn);
 		if (ret) {
 			pr_err("failed to register fixed PHY\n");
-			return;
+			return ret;
 		}
 		phy_is_fixed = true;
 		phy_dn = port_dn;
@@ -492,7 +492,7 @@ static void dsa_slave_phy_setup(struct dsa_slave_priv *p,
 	if (!p->phy) {
 		p->phy = ds->slave_mii_bus->phy_map[p->port];
 		if (!p->phy)
-			return;
+			return -ENODEV;
 
 		phy_connect_direct(slave_dev, p->phy, dsa_slave_adjust_link,
 				   p->phy_interface);
@@ -500,6 +500,8 @@ static void dsa_slave_phy_setup(struct dsa_slave_priv *p,
 		pr_info("attached PHY at address %d [%s]\n",
 			p->phy->addr, p->phy->drv->name);
 	}
+
+	return 0;
 }
 
 int dsa_slave_suspend(struct net_device *slave_dev)
@@ -592,12 +594,17 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	p->old_link = -1;
 	p->old_duplex = -1;
 
-	dsa_slave_phy_setup(p, slave_dev);
+	ret = dsa_slave_phy_setup(p, slave_dev);
+	if (ret) {
+		free_netdev(slave_dev);
+		return NULL;
+	}
 
 	ret = register_netdev(slave_dev);
 	if (ret) {
 		printk(KERN_ERR "%s: error %d registering interface %s\n",
 				master->name, ret, slave_dev->name);
+		phy_disconnect(p->phy);
 		free_netdev(slave_dev);
 		return NULL;
 	}
-- 
2.1.0
