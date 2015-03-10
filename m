From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next 2/3] net: dsa: move PHY setup on DSA MII bus to its own function
Date: Tue, 10 Mar 2015 16:57:12 -0700
Message-ID: <1426031833-5113-3-git-send-email-f.fainelli@gmail.com>
References: <1426031833-5113-1-git-send-email-f.fainelli@gmail.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1426031833-5113-1-git-send-email-f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

In preparation for dealing with indirect reads and writes towards
certain PHY devices, move the code which deals with binding the PHY
device to the slave MII bus created by DSA to its own function:
dsa_slave_phy_connect().

Signed-off-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/dsa/slave.c | 28 ++++++++++++++++++++--------
 1 file changed, 20 insertions(+), 8 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index a47305c72fcc..19bc2b39c9d1 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -617,6 +617,23 @@ static int dsa_slave_fixed_link_update(struct net_device *dev,
 }
 
 /* slave device setup *******************************************************/
+static int dsa_slave_phy_connect(struct dsa_slave_priv *p,
+				 struct net_device *slave_dev)
+{
+	struct dsa_switch *ds = p->parent;
+
+	p->phy = ds->slave_mii_bus->phy_map[p->port];
+	if (!p->phy)
+		return -ENODEV;
+
+	/* Use already configured phy mode */
+	p->phy_interface = p->phy->interface;
+	phy_connect_direct(slave_dev, p->phy, dsa_slave_adjust_link,
+			   p->phy_interface);
+
+	return 0;
+}
+
 static int dsa_slave_phy_setup(struct dsa_slave_priv *p,
 				struct net_device *slave_dev)
 {
@@ -662,14 +679,9 @@ static int dsa_slave_phy_setup(struct dsa_slave_priv *p,
 	 * MDIO bus instead
 	 */
 	if (!p->phy) {
-		p->phy = ds->slave_mii_bus->phy_map[p->port];
-		if (!p->phy)
-			return -ENODEV;
-
-		/* Use already configured phy mode */
-		p->phy_interface = p->phy->interface;
-		phy_connect_direct(slave_dev, p->phy, dsa_slave_adjust_link,
-				   p->phy_interface);
+		ret = dsa_slave_phy_connect(p, slave_dev);
+		if (ret)
+			return ret;
 	} else {
 		netdev_info(slave_dev, "attached PHY at address %d [%s]\n",
 			    p->phy->addr, p->phy->drv->name);
-- 
2.1.0

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
