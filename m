From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 8/8] net: dsa: mv88e6xxx: fail on mismatching probe
Date: Wed,  8 Jun 2016 20:44:56 -0400
Message-ID: <20160609004456.5441-9-vivien.didelot@savoirfairelinux.com>
References: <20160609004456.5441-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:48705 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1424902AbcFIApc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 20:45:32 -0400
In-Reply-To: <20160609004456.5441-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that we have access at probe time to the chip info described in the
device tree, check if the probed device matches the device node,
otherwise warn the user and fail.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 4f07110..8244757 100644
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
@@ -3746,6 +3747,28 @@ static const struct of_device_id mv88e6xxx_of_id_table[] = {
 
 MODULE_DEVICE_TABLE(of, mv88e6xxx_of_id_table);
 
+static bool mv88e6xxx_of_matches(struct mv88e6xxx_priv_state *ps)
+{
+	const struct mv88e6xxx_info *info;
+	const struct of_device_id *id;
+	enum mv88e6xxx_model model;
+
+	id = of_match_device(mv88e6xxx_of_id_table, ps->dev);
+	if (!id)
+		return false;
+
+	model = (enum mv88e6xxx_model)id->data;
+	info = &mv88e6xxx_table[model];
+
+	if (ps->info->prod_num == info->prod_num)
+		return true;
+
+	dev_err(ps->dev, "described node %s mismatches probed model %s\n",
+		id->compatible, ps->info->name);
+
+	return false;
+}
+
 int mv88e6xxx_probe(struct mdio_device *mdiodev)
 {
 	struct device *dev = &mdiodev->dev;
@@ -3758,6 +3781,9 @@ int mv88e6xxx_probe(struct mdio_device *mdiodev)
 	if (!ps)
 		return -ENODEV;
 
+	if (!mv88e6xxx_of_matches(ps))
+		return -EINVAL;
+
 	ps->reset = devm_gpiod_get(dev, "reset", GPIOD_ASIS);
 	if (IS_ERR(ps->reset)) {
 		err = PTR_ERR(ps->reset);
-- 
2.8.3
