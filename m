From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v1 net-next 7/7] dsa: mv88e6xxx: Handle eeprom-length property
Date: Tue, 10 May 2016 23:27:25 +0200
Message-ID: <1462915645-24674-8-git-send-email-andrew@lunn.ch>
References: <1462915645-24674-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35009 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751629AbcEJV3t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2016 17:29:49 -0400
In-Reply-To: <1462915645-24674-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A switch can export an attached EEPROM using the standard ethtool API.
However the switch itself cannot determine the size of the EEPROM, and
multiple sizes are allowed. Thus a device tree property is supported
to indicate the length of the EEPROM. Parse this property during
device probe, and implement a callback function to retrieve it.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx.c | 17 +++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h |  3 +++
 2 files changed, 20 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index c41ec38613c7..6f9be26d002f 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -879,6 +879,16 @@ error:
 	return ret;
 }
 
+static int mv88e6xxx_get_eeprom_len(struct dsa_switch *ds)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+
+	if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_EEPROM))
+		return ps->eeprom_len;
+
+	return 0;
+}
+
 static int mv88e6xxx_get_eeprom(struct dsa_switch *ds,
 				struct ethtool_eeprom *eeprom, u8 *data)
 {
@@ -3596,6 +3606,7 @@ struct dsa_switch_driver mv88e6xxx_switch_driver = {
 	.set_temp_limit		= mv88e6xxx_set_temp_limit,
 	.get_temp_alarm		= mv88e6xxx_get_temp_alarm,
 #endif
+	.get_eeprom_len		= mv88e6xxx_get_eeprom_len,
 	.get_eeprom		= mv88e6xxx_get_eeprom,
 	.set_eeprom		= mv88e6xxx_set_eeprom,
 	.get_regs_len		= mv88e6xxx_get_regs_len,
@@ -3617,9 +3628,11 @@ struct dsa_switch_driver mv88e6xxx_switch_driver = {
 int mv88e6xxx_probe(struct mdio_device *mdiodev)
 {
 	struct device *dev = &mdiodev->dev;
+	struct device_node *np = dev->of_node;
 	struct mv88e6xxx_priv_state *ps;
 	int id, prod_num, rev;
 	struct dsa_switch *ds;
+	u32 eeprom_len;
 	int err;
 
 	ds = devm_kzalloc(dev, sizeof(*ds) + sizeof(*ps), GFP_KERNEL);
@@ -3662,6 +3675,10 @@ int mv88e6xxx_probe(struct mdio_device *mdiodev)
 		}
 	}
 
+	if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_EEPROM) &&
+	    !of_property_read_u32(np, "eeprom-length", &eeprom_len))
+		ps->eeprom_len = eeprom_len;
+
 	dev_set_drvdata(dev, ds);
 
 	dev_info(dev, "switch 0x%x probed: %s, revision %u\n",
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index df226c151d9c..d83565ac684e 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -590,6 +590,9 @@ struct mv88e6xxx_priv_state {
 	 * switch soft reset.
 	 */
 	struct gpio_desc *reset;
+
+	/* set to size of eeprom if supported by the switch */
+	int		eeprom_len;
 };
 
 enum stat_type {
-- 
2.8.1
