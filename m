From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 9/9] net: dsa: b53: use dsa_port's bridge pointer
Date: Fri, 27 Jan 2017 15:29:44 -0500
Message-ID: <20170127202944.28598-10-vivien.didelot@savoirfairelinux.com>
References: <20170127202944.28598-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, John Crispin <john@phrozen.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170127202944.28598-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that DSA exposes the bridge device pointer to which a port belongs,
use it when programming the port based VLANs and thus remove the cache.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/b53/b53_common.c | 9 +++------
 drivers/net/dsa/b53/b53_priv.h   | 1 -
 2 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index 32fdcf5570c8..3a7d16b6c3eb 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -1308,7 +1308,7 @@ int b53_fdb_dump(struct dsa_switch *ds, int port,
 }
 EXPORT_SYMBOL(b53_fdb_dump);
 
-int b53_br_join(struct dsa_switch *ds, int port, struct net_device *bridge)
+int b53_br_join(struct dsa_switch *ds, int port, struct net_device *br)
 {
 	struct b53_device *dev = ds->priv;
 	s8 cpu_port = ds->dst->cpu_port;
@@ -1326,11 +1326,10 @@ int b53_br_join(struct dsa_switch *ds, int port, struct net_device *bridge)
 		b53_write16(dev, B53_VLAN_PAGE, B53_JOIN_ALL_VLAN_EN, reg);
 	}
 
-	dev->ports[port].bridge_dev = bridge;
 	b53_read16(dev, B53_PVLAN_PAGE, B53_PVLAN_PORT_MASK(port), &pvlan);
 
 	b53_for_each_port(dev, i) {
-		if (dev->ports[i].bridge_dev != bridge)
+		if (ds->ports[i].bridge_dev != br)
 			continue;
 
 		/* Add this local port to the remote port VLAN control
@@ -1357,7 +1356,6 @@ EXPORT_SYMBOL(b53_br_join);
 void b53_br_leave(struct dsa_switch *ds, int port, struct net_device *br)
 {
 	struct b53_device *dev = ds->priv;
-	struct net_device *bridge = dev->ports[port].bridge_dev;
 	struct b53_vlan *vl = &dev->vlans[0];
 	s8 cpu_port = ds->dst->cpu_port;
 	unsigned int i;
@@ -1367,7 +1365,7 @@ void b53_br_leave(struct dsa_switch *ds, int port, struct net_device *br)
 
 	b53_for_each_port(dev, i) {
 		/* Don't touch the remaining ports */
-		if (dev->ports[i].bridge_dev != bridge)
+		if (ds->ports[i].bridge_dev != br)
 			continue;
 
 		b53_read16(dev, B53_PVLAN_PAGE, B53_PVLAN_PORT_MASK(i), &reg);
@@ -1382,7 +1380,6 @@ void b53_br_leave(struct dsa_switch *ds, int port, struct net_device *br)
 
 	b53_write16(dev, B53_PVLAN_PAGE, B53_PVLAN_PORT_MASK(port), pvlan);
 	dev->ports[port].vlan_ctl_mask = pvlan;
-	dev->ports[port].bridge_dev = NULL;
 
 	if (is5325(dev) || is5365(dev))
 		pvid = 1;
diff --git a/drivers/net/dsa/b53/b53_priv.h b/drivers/net/dsa/b53/b53_priv.h
index 5dafb70e75fc..9d87889728ac 100644
--- a/drivers/net/dsa/b53/b53_priv.h
+++ b/drivers/net/dsa/b53/b53_priv.h
@@ -70,7 +70,6 @@ enum {
 
 struct b53_port {
 	u16		vlan_ctl_mask;
-	struct net_device *bridge_dev;
 };
 
 struct b53_vlan {
-- 
2.11.0
