From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v5 net-next v5 12/14] net: dsa: mv88e6xxx: pass compatible info
Date: Mon, 20 Jun 2016 13:14:09 -0400
Message-ID: <20160620171411.13746-13-vivien.didelot@savoirfairelinux.com>
References: <20160620171411.13746-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Ben Dooks <ben.dooks@codethink.co.uk>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:48693 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932205AbcFTRPW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 13:15:22 -0400
In-Reply-To: <20160620171411.13746-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After allocating the chip structure, pass it a compatible info pointer.

The compatible info structure will be used later to describe how to
access the switch registers and where to read the switch ID.

For the standard MDIO probe, get it from the device node data. For the
legacy DSA driver probing, pass it the 88E6085 info.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx.c | 17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index de92add..cadd1e3 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -21,6 +21,7 @@
 #include <linux/list.h>
 #include <linux/mdio.h>
 #include <linux/module.h>
+#include <linux/of_device.h>
 #include <linux/of_mdio.h>
 #include <linux/netdevice.h>
 #include <linux/gpio/consumer.h>
@@ -3617,6 +3618,7 @@ static int mv88e6xxx_detect(struct mv88e6xxx_priv_state *ps)
 	if (!info)
 		return -ENODEV;
 
+	/* Update the compatible info with the probed one */
 	ps->info = info;
 
 	dev_info(ps->dev, "switch 0x%x detected: %s, revision %u\n",
@@ -3669,6 +3671,9 @@ static const char *mv88e6xxx_drv_probe(struct device *dsa_dev,
 	if (!ps)
 		return NULL;
 
+	/* Legacy SMI probing will only support chips similar to 88E6085 */
+	ps->info = &mv88e6xxx_table[MV88E6085];
+
 	err = mv88e6xxx_smi_init(ps, bus, sw_addr);
 	if (err)
 		goto free;
@@ -3754,14 +3759,21 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
 {
 	struct device *dev = &mdiodev->dev;
 	struct device_node *np = dev->of_node;
+	const struct mv88e6xxx_info *compat_info;
 	struct mv88e6xxx_priv_state *ps;
 	u32 eeprom_len;
 	int err;
 
+	compat_info = of_device_get_match_data(dev);
+	if (!compat_info)
+		return -EINVAL;
+
 	ps = mv88e6xxx_alloc_chip(dev);
 	if (!ps)
 		return -ENOMEM;
 
+	ps->info = compat_info;
+
 	err = mv88e6xxx_smi_init(ps, mdiodev->bus, mdiodev->addr);
 	if (err)
 		return err;
@@ -3801,7 +3813,10 @@ static void mv88e6xxx_remove(struct mdio_device *mdiodev)
 }
 
 static const struct of_device_id mv88e6xxx_of_match[] = {
-	{ .compatible = "marvell,mv88e6085" },
+	{
+		.compatible = "marvell,mv88e6085",
+		.data = &mv88e6xxx_table[MV88E6085],
+	},
 	{ /* sentinel */ },
 };
 
-- 
2.9.0
