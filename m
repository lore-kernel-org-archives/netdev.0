From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [RFC net-next 05/11] net: dsa: allow for more complex PHY setups
Date: Tue, 13 May 2014 22:00:31 -0700
Message-ID: <1400043637-9799-6-git-send-email-f.fainelli@gmail.com>
References: <1400043637-9799-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	nhorman@tuxdriver.com, andy@greyhouse.net, tgraf@suug.ch,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
	pshelar@nicira.com, azhou@nicira.com, ben@decadent.org.uk,
	stephen@networkplumber.org, jeffrey.t.kirsher@intel.com,
	vyasevic@redhat.com, xiyou.wangcong@gmail.com,
	john.r.fastabend@intel.com, edumazet@google.com, jhs@mojatatu.com,
	sfeldma@cumulusnetworks.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:44437 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751201AbaENFBX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 01:01:23 -0400
Received: by mail-pb0-f53.google.com with SMTP id md12so1187283pbc.40
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 22:01:22 -0700 (PDT)
In-Reply-To: <1400043637-9799-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Modify the DSA slave interface to be bound to an arbitray PHY, not just
the ones that are available as child PHY devices of the switch MDIO bus.

This allows us for instance to have external PHYs connected to a
separate MDIO bus, but yet also connected to a given switch port.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa_priv.h |  4 ++++
 net/dsa/slave.c    | 59 +++++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 62 insertions(+), 1 deletion(-)

diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index d4cf5cc747e3..a7f6f0c5fa31 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -33,6 +33,10 @@ struct dsa_slave_priv {
 	 * to this port.
 	 */
 	struct phy_device	*phy;
+	phy_interface_t		phy_interface;
+	int			old_link;
+	int			old_pause;
+	int			old_duplex;
 };
 
 /* dsa.c */
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 64c5af0a10dd..d2dbd271300a 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -12,6 +12,8 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/phy.h>
+#include <linux/of_net.h>
+#include <linux/of_mdio.h>
 #include "dsa_priv.h"
 
 /* slave mii_bus handling ***************************************************/
@@ -330,7 +332,60 @@ static const struct net_device_ops trailer_netdev_ops = {
 };
 #endif
 
+static void dsa_slave_adjust_link(struct net_device *dev)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	unsigned int status_changed = 0;
+
+	if (p->old_link != p->phy->link) {
+		status_changed = 1;
+		p->old_link = p->phy->link;
+	}
+
+	if (p->old_duplex != p->phy->duplex) {
+		status_changed = 1;
+		p->old_duplex = p->phy->duplex;
+	}
+
+	if (p->old_pause != p->phy->pause) {
+		status_changed = 1;
+		p->old_pause = p->phy->pause;
+	}
+
+	if (status_changed)
+		phy_print_status(p->phy);
+}
+
 /* slave device setup *******************************************************/
+static void dsa_slave_phy_setup(struct dsa_slave_priv *p,
+		struct net_device *slave_dev)
+{
+	struct dsa_switch *ds = p->parent;
+	struct dsa_chip_data *cd = ds->pd;
+	struct device_node *phy_dn;
+
+	p->phy_interface = of_get_phy_mode(cd->port_dn[p->port]);
+
+	phy_dn = of_parse_phandle(cd->port_dn[p->port], "phy-handle", 0);
+	if (phy_dn)
+		p->phy = of_phy_connect(slave_dev, phy_dn,
+				dsa_slave_adjust_link, 0,
+				p->phy_interface);
+	else
+		p->phy = of_phy_connect_fixed_link(slave_dev,
+				dsa_slave_adjust_link,
+				p->phy_interface);
+
+	/* We could not connect to a designated PHY, so use the switch internal
+	 * MDIO bus instead
+	 */
+	if (!p->phy)
+		p->phy = ds->slave_mii_bus->phy_map[p->port];
+	else
+		pr_info("attached PHY at address %d [%s]\n",
+			p->phy->addr, p->phy->drv->name);
+}
+
 struct net_device *
 dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 		 int port, char *name)
@@ -370,6 +425,7 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 		BUG();
 	}
 
+	parent->of_node = ds->pd->port_dn[port];
 	SET_NETDEV_DEV(slave_dev, parent);
 	slave_dev->vlan_features = master->vlan_features;
 
@@ -377,7 +433,8 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	p->dev = slave_dev;
 	p->parent = ds;
 	p->port = port;
-	p->phy = ds->slave_mii_bus->phy_map[port];
+
+	dsa_slave_phy_setup(p, slave_dev);
 
 	ret = register_netdev(slave_dev);
 	if (ret) {
-- 
1.9.1
