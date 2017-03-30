From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 9/9] net: dsa: mv88e6xxx: add cross-chip bridging
Date: Thu, 30 Mar 2017 17:37:15 -0400
Message-ID: <20170330213715.9666-10-vivien.didelot@savoirfairelinux.com>
References: <20170330213715.9666-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170330213715.9666-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Implement the DSA cross-chip bridging operations by remapping the local
ports an external source port can egress frames to, when this cross-chip
port joins or leaves a bridge.

The PVT is no longer configured with all ones allowing any external
frame to egress any local port. Only DSA and CPU ports, as well as
bridge group members, can egress frames on local ports.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 34 +++++++++++++++++++++++++++++++++-
 1 file changed, 33 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index c6f45a2a9335..44ba8cff5631 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1222,7 +1222,7 @@ static int mv88e6xxx_pvt_map(struct mv88e6xxx_chip *chip, int dev, int port)
 
 	/* Skip the local source device, which uses in-chip port VLAN */
 	if (dev != chip->ds->index)
-		pvlan = mv88e6xxx_port_mask(chip);
+		pvlan = mv88e6xxx_port_vlan(chip, dev, port);
 
 	return mv88e6xxx_g2_pvt_write(chip, dev, port, pvlan);
 }
@@ -2203,6 +2203,36 @@ static void mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port,
 	mutex_unlock(&chip->reg_lock);
 }
 
+static int mv88e6xxx_crosschip_bridge_join(struct dsa_switch *ds, int dev,
+					   int port, struct net_device *br)
+{
+	struct mv88e6xxx_chip *chip = ds->priv;
+	int err;
+
+	if (!mv88e6xxx_has_pvt(chip))
+		return 0;
+
+	mutex_lock(&chip->reg_lock);
+	err = mv88e6xxx_pvt_map(chip, dev, port);
+	mutex_unlock(&chip->reg_lock);
+
+	return err;
+}
+
+static void mv88e6xxx_crosschip_bridge_leave(struct dsa_switch *ds, int dev,
+					     int port, struct net_device *br)
+{
+	struct mv88e6xxx_chip *chip = ds->priv;
+
+	if (!mv88e6xxx_has_pvt(chip))
+		return;
+
+	mutex_lock(&chip->reg_lock);
+	if (mv88e6xxx_pvt_map(chip, dev, port))
+		dev_err(ds->dev, "failed to remap cross-chip Port VLAN\n");
+	mutex_unlock(&chip->reg_lock);
+}
+
 static int mv88e6xxx_software_reset(struct mv88e6xxx_chip *chip)
 {
 	if (chip->info->ops->reset)
@@ -4313,6 +4343,8 @@ static const struct dsa_switch_ops mv88e6xxx_switch_ops = {
 	.port_mdb_add           = mv88e6xxx_port_mdb_add,
 	.port_mdb_del           = mv88e6xxx_port_mdb_del,
 	.port_mdb_dump          = mv88e6xxx_port_mdb_dump,
+	.crosschip_bridge_join	= mv88e6xxx_crosschip_bridge_join,
+	.crosschip_bridge_leave	= mv88e6xxx_crosschip_bridge_leave,
 };
 
 static struct dsa_switch_driver mv88e6xxx_switch_drv = {
-- 
2.12.1
