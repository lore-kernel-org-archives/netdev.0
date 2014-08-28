From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v5 09/13] net: dsa: allow updating fixed PHY link information
Date: Wed, 27 Aug 2014 17:04:54 -0700
Message-ID: <1409184298-1793-10-git-send-email-f.fainelli@gmail.com>
References: <1409184298-1793-1-git-send-email-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, davem@davemloft.net,
	linville@tuxdriver.com, jhs@mojatatu.com, alexander.duyck@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:43769 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965640AbaH1AGM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 20:06:12 -0400
Received: by mail-pa0-f44.google.com with SMTP id rd3so104819pab.31
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 17:06:12 -0700 (PDT)
In-Reply-To: <1409184298-1793-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow switch drivers to hook a PHY link update callback to perform
port-specific link work.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v4:
- changed phy_is_fixed from 'unsigned int' to 'bool'

 include/net/dsa.h |  3 +++
 net/dsa/slave.c   | 17 +++++++++++++++++
 2 files changed, 20 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 2d3835924dd2..2c9563f0b2f4 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -17,6 +17,7 @@
 #include <linux/workqueue.h>
 #include <linux/of.h>
 #include <linux/phy.h>
+#include <linux/phy_fixed.h>
 
 #define DSA_MAX_SWITCHES	4
 #define DSA_MAX_PORTS		12
@@ -187,6 +188,8 @@ struct dsa_switch_driver {
 	 */
 	void	(*adjust_link)(struct dsa_switch *ds, int port,
 				struct phy_device *phydev);
+	void	(*fixed_link_update)(struct dsa_switch *ds, int port,
+				struct fixed_phy_status *st);
 
 	/*
 	 * ethtool hardware statistics.
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 398d0663d3dd..18ff53836fe3 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -358,6 +358,18 @@ static void dsa_slave_adjust_link(struct net_device *dev)
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
@@ -365,6 +377,7 @@ static void dsa_slave_phy_setup(struct dsa_slave_priv *p,
 	struct dsa_switch *ds = p->parent;
 	struct dsa_chip_data *cd = ds->pd;
 	struct device_node *phy_dn, *port_dn;
+	bool phy_is_fixed = false;
 	int ret;
 
 	port_dn = cd->port_dn[p->port];
@@ -380,6 +393,7 @@ static void dsa_slave_phy_setup(struct dsa_slave_priv *p,
 			pr_err("failed to register fixed PHY\n");
 			return;
 		}
+		phy_is_fixed = true;
 		phy_dn = port_dn;
 	}
 
@@ -388,6 +402,9 @@ static void dsa_slave_phy_setup(struct dsa_slave_priv *p,
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
