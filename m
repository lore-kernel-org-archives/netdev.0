From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 1/4] net: dsa: mv88e6xxx: setup random mac address
Date: Thu, 12 Oct 2017 21:41:10 -0400
Message-ID: <20171013014113.29561-2-vivien.didelot@savoirfairelinux.com>
References: <20171013014113.29561-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171013014113.29561-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

An Ethernet switch may support having a MAC address, which can be used
as the switch's source address in transmitted full-duplex Pause frames.

If a DSA switch supports the related .set_addr operation, the DSA core
sets the master's MAC address on the switch. This won't make sense
anymore in a multi-CPU ports system, because there won't be a unique
master device assigned to a switch tree.

Instead, setup the switch from within the Marvell driver with a random
MAC address, and remove the .set_addr implementation.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 33 +++++++++++++++++----------------
 1 file changed, 17 insertions(+), 16 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index d74c7335c512..76cf383dcf90 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -932,6 +932,19 @@ static int mv88e6xxx_irl_setup(struct mv88e6xxx_chip *chip)
 	return 0;
 }
 
+static int mv88e6xxx_mac_setup(struct mv88e6xxx_chip *chip)
+{
+	if (chip->info->ops->set_switch_mac) {
+		u8 addr[ETH_ALEN];
+
+		eth_random_addr(addr);
+
+		return chip->info->ops->set_switch_mac(chip, addr);
+	}
+
+	return 0;
+}
+
 static int mv88e6xxx_pvt_map(struct mv88e6xxx_chip *chip, int dev, int port)
 {
 	u16 pvlan = 0;
@@ -2013,6 +2026,10 @@ static int mv88e6xxx_setup(struct dsa_switch *ds)
 	if (err)
 		goto unlock;
 
+	err = mv88e6xxx_mac_setup(chip);
+	if (err)
+		goto unlock;
+
 	err = mv88e6xxx_phy_setup(chip);
 	if (err)
 		goto unlock;
@@ -2043,21 +2060,6 @@ static int mv88e6xxx_setup(struct dsa_switch *ds)
 	return err;
 }
 
-static int mv88e6xxx_set_addr(struct dsa_switch *ds, u8 *addr)
-{
-	struct mv88e6xxx_chip *chip = ds->priv;
-	int err;
-
-	if (!chip->info->ops->set_switch_mac)
-		return -EOPNOTSUPP;
-
-	mutex_lock(&chip->reg_lock);
-	err = chip->info->ops->set_switch_mac(chip, addr);
-	mutex_unlock(&chip->reg_lock);
-
-	return err;
-}
-
 static int mv88e6xxx_mdio_read(struct mii_bus *bus, int phy, int reg)
 {
 	struct mv88e6xxx_mdio_bus *mdio_bus = bus->priv;
@@ -3785,7 +3787,6 @@ static const struct dsa_switch_ops mv88e6xxx_switch_ops = {
 	.probe			= mv88e6xxx_drv_probe,
 	.get_tag_protocol	= mv88e6xxx_get_tag_protocol,
 	.setup			= mv88e6xxx_setup,
-	.set_addr		= mv88e6xxx_set_addr,
 	.adjust_link		= mv88e6xxx_adjust_link,
 	.get_strings		= mv88e6xxx_get_strings,
 	.get_ethtool_stats	= mv88e6xxx_get_ethtool_stats,
-- 
2.14.2
