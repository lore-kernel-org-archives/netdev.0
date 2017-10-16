From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 7/7] net: dsa: add dsa_to_port helper
Date: Mon, 16 Oct 2017 11:12:19 -0400
Message-ID: <20171016151219.22023-8-vivien.didelot@savoirfairelinux.com>
References: <20171016151219.22023-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171016151219.22023-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The dsa_port structure is part of DSA core data and must only be updated
by the later. It is OK and sometimes necessary for the DSA drivers to
access this data, but this has to be read only.

For that purpose, add a dsa_to_port() helper which returns a const
pointer to a dsa_port structure which must be used by DSA drivers from
now on instead of digging into ds->ports[] themselves.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/b53/b53_common.c | 4 ++--
 drivers/net/dsa/lan9303-core.c   | 2 +-
 drivers/net/dsa/mt7530.c         | 4 ++--
 drivers/net/dsa/mv88e6060.c      | 2 +-
 drivers/net/dsa/mv88e6xxx/chip.c | 8 ++++----
 drivers/net/dsa/qca8k.c          | 4 ++--
 include/net/dsa.h                | 5 +++++
 7 files changed, 17 insertions(+), 12 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index d4ce092def83..b48cf0487b43 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -1354,7 +1354,7 @@ int b53_br_join(struct dsa_switch *ds, int port, struct net_device *br)
 	b53_read16(dev, B53_PVLAN_PAGE, B53_PVLAN_PORT_MASK(port), &pvlan);
 
 	b53_for_each_port(dev, i) {
-		if (ds->ports[i].bridge_dev != br)
+		if (dsa_to_port(ds, i)->bridge_dev != br)
 			continue;
 
 		/* Add this local port to the remote port VLAN control
@@ -1390,7 +1390,7 @@ void b53_br_leave(struct dsa_switch *ds, int port, struct net_device *br)
 
 	b53_for_each_port(dev, i) {
 		/* Don't touch the remaining ports */
-		if (ds->ports[i].bridge_dev != br)
+		if (dsa_to_port(ds, i)->bridge_dev != br)
 			continue;
 
 		b53_read16(dev, B53_PVLAN_PAGE, B53_PVLAN_PORT_MASK(i), &reg);
diff --git a/drivers/net/dsa/lan9303-core.c b/drivers/net/dsa/lan9303-core.c
index fecfe1fe67ea..09a748327fc6 100644
--- a/drivers/net/dsa/lan9303-core.c
+++ b/drivers/net/dsa/lan9303-core.c
@@ -863,7 +863,7 @@ static int lan9303_port_bridge_join(struct dsa_switch *ds, int port,
 	struct lan9303 *chip = ds->priv;
 
 	dev_dbg(chip->dev, "%s(port %d)\n", __func__, port);
-	if (ds->ports[1].bridge_dev ==  ds->ports[2].bridge_dev) {
+	if (dsa_to_port(ds, 1)->bridge_dev == dsa_to_port(ds, 2)->bridge_dev) {
 		lan9303_bridge_ports(chip);
 		chip->is_bridged = true;  /* unleash stp_state_set() */
 	}
diff --git a/drivers/net/dsa/mt7530.c b/drivers/net/dsa/mt7530.c
index fea2e665d0cb..21431be2831e 100644
--- a/drivers/net/dsa/mt7530.c
+++ b/drivers/net/dsa/mt7530.c
@@ -782,7 +782,7 @@ mt7530_port_bridge_join(struct dsa_switch *ds, int port,
 		 * and not being setup until the port becomes enabled.
 		 */
 		if (ds->enabled_port_mask & BIT(i) && i != port) {
-			if (ds->ports[i].bridge_dev != bridge)
+			if (dsa_to_port(ds, i)->bridge_dev != bridge)
 				continue;
 			if (priv->ports[i].enable)
 				mt7530_set(priv, MT7530_PCR_P(i),
@@ -819,7 +819,7 @@ mt7530_port_bridge_leave(struct dsa_switch *ds, int port,
 		 * is kept and not being setup until the port becomes enabled.
 		 */
 		if (ds->enabled_port_mask & BIT(i) && i != port) {
-			if (ds->ports[i].bridge_dev != bridge)
+			if (dsa_to_port(ds, i)->bridge_dev != bridge)
 				continue;
 			if (priv->ports[i].enable)
 				mt7530_clear(priv, MT7530_PCR_P(i),
diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
index 6173be889d95..f78b9e13be1c 100644
--- a/drivers/net/dsa/mv88e6060.c
+++ b/drivers/net/dsa/mv88e6060.c
@@ -177,7 +177,7 @@ static int mv88e6060_setup_port(struct dsa_switch *ds, int p)
 		  ((p & 0xf) << PORT_VLAN_MAP_DBNUM_SHIFT) |
 		   (dsa_is_cpu_port(ds, p) ?
 			ds->enabled_port_mask :
-			BIT(ds->ports[p].cpu_dp->index)));
+			BIT(dsa_to_port(ds, p)->cpu_dp->index)));
 
 	/* Port Association Vector: when learning source addresses
 	 * of packets, add the address to the address database using
diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 88b47fa09b41..677d6902807e 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -851,7 +851,7 @@ static u16 mv88e6xxx_port_vlan(struct mv88e6xxx_chip *chip, int dev, int port)
 	for (i = 0; i < mv88e6xxx_num_ports(chip); ++i)
 		if (dsa_is_cpu_port(chip->ds, i) ||
 		    dsa_is_dsa_port(chip->ds, i) ||
-		    (br && chip->ds->ports[i].bridge_dev == br))
+		    (br && dsa_to_port(chip->ds, i)->bridge_dev == br))
 			pvlan |= BIT(i);
 
 	return pvlan;
@@ -1144,16 +1144,16 @@ static int mv88e6xxx_port_check_hw_vlan(struct dsa_switch *ds, int port,
 			    MV88E6XXX_G1_VTU_DATA_MEMBER_TAG_NON_MEMBER)
 				continue;
 
-			if (ds->ports[i].bridge_dev ==
+			if (dsa_to_port(ds, i)->bridge_dev ==
 			    ds->ports[port].bridge_dev)
 				break; /* same bridge, check next VLAN */
 
-			if (!ds->ports[i].bridge_dev)
+			if (!dsa_to_port(ds, i)->bridge_dev)
 				continue;
 
 			dev_err(ds->dev, "p%d: hw VLAN %d already used by %s\n",
 				port, vlan.vid,
-				netdev_name(ds->ports[i].bridge_dev));
+				netdev_name(dsa_to_port(ds, i)->bridge_dev));
 			err = -EOPNOTSUPP;
 			goto unlock;
 		}
diff --git a/drivers/net/dsa/qca8k.c b/drivers/net/dsa/qca8k.c
index 82f09711ac1a..d1b0b1fb632f 100644
--- a/drivers/net/dsa/qca8k.c
+++ b/drivers/net/dsa/qca8k.c
@@ -700,7 +700,7 @@ qca8k_port_bridge_join(struct dsa_switch *ds, int port, struct net_device *br)
 	int i;
 
 	for (i = 1; i < QCA8K_NUM_PORTS; i++) {
-		if (ds->ports[i].bridge_dev != br)
+		if (dsa_to_port(ds, i)->bridge_dev != br)
 			continue;
 		/* Add this port to the portvlan mask of the other ports
 		 * in the bridge
@@ -725,7 +725,7 @@ qca8k_port_bridge_leave(struct dsa_switch *ds, int port, struct net_device *br)
 	int i;
 
 	for (i = 1; i < QCA8K_NUM_PORTS; i++) {
-		if (ds->ports[i].bridge_dev != br)
+		if (dsa_to_port(ds, i)->bridge_dev != br)
 			continue;
 		/* Remove this port to the portvlan mask of the other ports
 		 * in the bridge
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 6ed1a17ed1bd..38961ef91d3d 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -269,6 +269,11 @@ static inline bool dsa_is_normal_port(struct dsa_switch *ds, int p)
 	return !dsa_is_cpu_port(ds, p) && !dsa_is_dsa_port(ds, p);
 }
 
+static inline const struct dsa_port *dsa_to_port(struct dsa_switch *ds, int p)
+{
+	return &ds->ports[p];
+}
+
 static inline u8 dsa_upstream_port(struct dsa_switch *ds)
 {
 	struct dsa_switch_tree *dst = ds->dst;
-- 
2.14.2
