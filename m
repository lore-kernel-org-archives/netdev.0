From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 6/9] net: dsa: introduce dsa_user_ports helper
Date: Thu, 26 Oct 2017 11:22:56 -0400
Message-ID: <20171026152259.3123-7-vivien.didelot@savoirfairelinux.com>
References: <20171026152259.3123-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:44352 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932334AbdJZPXP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 11:23:15 -0400
In-Reply-To: <20171026152259.3123-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce a dsa_user_ports() helper to return the ds->enabled_port_mask
mask which is more explicit. This will also minimize diffs when touching
this internal mask.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mt7530.c    | 2 +-
 drivers/net/dsa/mv88e6060.c | 5 ++---
 drivers/net/dsa/qca8k.c     | 3 +--
 include/net/dsa.h           | 5 +++++
 net/dsa/dsa2.c              | 2 +-
 net/dsa/legacy.c            | 2 +-
 6 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/drivers/net/dsa/mt7530.c b/drivers/net/dsa/mt7530.c
index d1d4eea6a875..627c039f12ca 100644
--- a/drivers/net/dsa/mt7530.c
+++ b/drivers/net/dsa/mt7530.c
@@ -688,7 +688,7 @@ mt7530_cpu_port_enable(struct mt7530_priv *priv,
 	 * the switch
 	 */
 	mt7530_write(priv, MT7530_PCR_P(port),
-		     PCR_MATRIX(priv->ds->enabled_port_mask));
+		     PCR_MATRIX(dsa_user_ports(priv->ds)));
 
 	return 0;
 }
diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
index f78b9e13be1c..45768e3c5bc5 100644
--- a/drivers/net/dsa/mv88e6060.c
+++ b/drivers/net/dsa/mv88e6060.c
@@ -175,9 +175,8 @@ static int mv88e6060_setup_port(struct dsa_switch *ds, int p)
 	 */
 	REG_WRITE(addr, PORT_VLAN_MAP,
 		  ((p & 0xf) << PORT_VLAN_MAP_DBNUM_SHIFT) |
-		   (dsa_is_cpu_port(ds, p) ?
-			ds->enabled_port_mask :
-			BIT(dsa_to_port(ds, p)->cpu_dp->index)));
+		   (dsa_is_cpu_port(ds, p) ? dsa_user_ports(ds) :
+		    BIT(dsa_to_port(ds, p)->cpu_dp->index)));
 
 	/* Port Association Vector: when learning source addresses
 	 * of packets, add the address to the address database using
diff --git a/drivers/net/dsa/qca8k.c b/drivers/net/dsa/qca8k.c
index 37125858fe80..cf72e274275f 100644
--- a/drivers/net/dsa/qca8k.c
+++ b/drivers/net/dsa/qca8k.c
@@ -551,8 +551,7 @@ qca8k_setup(struct dsa_switch *ds)
 		/* CPU port gets connected to all user ports of the switch */
 		if (dsa_is_cpu_port(ds, i)) {
 			qca8k_rmw(priv, QCA8K_PORT_LOOKUP_CTRL(QCA8K_CPU_PORT),
-				  QCA8K_PORT_LOOKUP_MEMBER,
-				  ds->enabled_port_mask);
+				  QCA8K_PORT_LOOKUP_MEMBER, dsa_user_ports(ds));
 		}
 
 		/* Invividual user ports get connected to CPU port only */
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 49701d958663..dc7728062396 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -276,6 +276,11 @@ static inline bool dsa_is_user_port(struct dsa_switch *ds, int p)
 	return !!(ds->enabled_port_mask & BIT(p));
 }
 
+static inline u32 dsa_user_ports(struct dsa_switch *ds)
+{
+	return ds->enabled_port_mask;
+}
+
 static inline const struct dsa_port *dsa_to_port(struct dsa_switch *ds, int p)
 {
 	return &ds->ports[p];
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 62485a57dbfc..d43c59c91058 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -312,7 +312,7 @@ static int dsa_ds_apply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 	 * the slave MDIO bus driver rely on these values for probing PHY
 	 * devices or not
 	 */
-	ds->phys_mii_mask = ds->enabled_port_mask;
+	ds->phys_mii_mask |= dsa_user_ports(ds);
 
 	/* Add the switch to devlink before calling setup, so that setup can
 	 * add dpipe tables
diff --git a/net/dsa/legacy.c b/net/dsa/legacy.c
index 0b79c6171d0d..fa543c4a6061 100644
--- a/net/dsa/legacy.c
+++ b/net/dsa/legacy.c
@@ -136,7 +136,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds,
 	/* Make the built-in MII bus mask match the number of ports,
 	 * switch drivers can override this later
 	 */
-	ds->phys_mii_mask = ds->enabled_port_mask;
+	ds->phys_mii_mask |= dsa_user_ports(ds);
 
 	/*
 	 * If the CPU connects to this switch, set the switch tree
-- 
2.14.3
