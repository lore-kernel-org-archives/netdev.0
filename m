From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 08/12] net: dsa: allow updating fixed PHY link information
Date: Sun, 24 Aug 2014 11:44:25 -0700
Message-ID: <1408905869-10471-9-git-send-email-f.fainelli@gmail.com>
References: <1408905869-10471-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemlof.net, jhs@mojatatu.com, linville@tuxdriver.com,
	alexander.h.duyck@intel.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:34499 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753188AbaHXSpN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Aug 2014 14:45:13 -0400
Received: by mail-pd0-f170.google.com with SMTP id g10so18411715pdj.15
        for <netdev@vger.kernel.org>; Sun, 24 Aug 2014 11:45:12 -0700 (PDT)
In-Reply-To: <1408905869-10471-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow switch drivers to hook a PHY link update callback to perform
port-specific link work.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/net/dsa.h |  3 +++
 net/dsa/slave.c   | 17 +++++++++++++++++
 2 files changed, 20 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 4507c50d29a6..9c0fd1b5e530 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -17,6 +17,7 @@
 #include <linux/workqueue.h>
 #include <linux/of.h>
 #include <linux/phy.h>
+#include <linux/phy_fixed.h>
 
 #define DSA_MAX_SWITCHES	4
 #define DSA_MAX_PORTS		12
@@ -184,6 +185,8 @@ struct dsa_switch_driver {
 	 */
 	void	(*adjust_link)(struct dsa_switch *ds, int port,
 				struct phy_device *phydev);
+	void	(*fixed_link_update)(struct dsa_switch *ds, int port,
+				struct fixed_phy_status *st);
 
 	/*
 	 * ethtool hardware statistics.
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 893afe9e60aa..ee019ec29dec 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -382,6 +382,18 @@ static void dsa_slave_adjust_link(struct net_device *dev)
 		phy_print_status(p->phy);
 }
 
+static int dsa_slave_fixed_link_update(struct net_device *dev,
+				       struct fixed_phy_status *status)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+
+	if (ds->drv->fixed_link_update)
+		ds->drv->fixed_link_update(ds, p->port, status);
+
+	return 0;
+}
+
 /* slave device setup *******************************************************/
 static void dsa_slave_phy_setup(struct dsa_slave_priv *p,
 				struct net_device *slave_dev)
@@ -389,6 +401,7 @@ static void dsa_slave_phy_setup(struct dsa_slave_priv *p,
 	struct dsa_switch *ds = p->parent;
 	struct dsa_chip_data *cd = ds->pd;
 	struct device_node *phy_dn, *port_dn;
+	unsigned int phy_is_fixed = 0;
 	int ret;
 
 	port_dn = cd->port_dn[p->port];
@@ -404,6 +417,7 @@ static void dsa_slave_phy_setup(struct dsa_slave_priv *p,
 			pr_err("failed to register fixed PHY\n");
 			return;
 		}
+		phy_is_fixed = 1;
 		phy_dn = port_dn;
 	}
 
@@ -412,6 +426,9 @@ static void dsa_slave_phy_setup(struct dsa_slave_priv *p,
 					dsa_slave_adjust_link, 0,
 					p->phy_interface);
 
+	if (p->phy && phy_is_fixed)
+		fixed_phy_set_link_update(p->phy, dsa_slave_fixed_link_update);
+
 	/* We could not connect to a designated PHY, so use the switch internal
 	 * MDIO bus instead
 	 */
-- 
1.9.1
