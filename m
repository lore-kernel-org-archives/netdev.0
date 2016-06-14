From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v2 net-next v2 08/12] net: dsa: mv88e6xxx: read switch ID from info
Date: Tue, 14 Jun 2016 14:31:49 -0400
Message-ID: <20160614183153.32327-9-vivien.didelot@savoirfairelinux.com>
References: <20160614183153.32327-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:58447 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932574AbcFNSc3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 14:32:29 -0400
In-Reply-To: <20160614183153.32327-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Retrieve the info structure of the compatible of device in the new probe
function, in order to know how to access the switch ID register.

That way, a compatible info can be used to describe how to access the
switch registers on models with different registers layout or addressing
modes.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 8c39dd0..8ac9f9a 100644
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
@@ -3745,6 +3746,8 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
 {
 	struct device *dev = &mdiodev->dev;
 	struct device_node *np = dev->of_node;
+	const struct of_device_id *of_id;
+	const struct mv88e6xxx_info *info;
 	struct mv88e6xxx_priv_state *ps;
 	int id, prod_num, rev;
 	u32 eeprom_len;
@@ -3759,7 +3762,13 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
 	ps->sw_addr = mdiodev->addr;
 	mutex_init(&ps->smi_mutex);
 
-	id = mv88e6xxx_reg_read(ps, REG_PORT(0), PORT_SWITCH_ID);
+	of_id = of_match_node(mv88e6xxx_of_id_table, np);
+	if (!of_id)
+		return -EINVAL;
+
+	info = (const struct mv88e6xxx_info *)of_id->data;
+
+	id = mv88e6xxx_reg_read(ps, info->port_base_addr, PORT_SWITCH_ID);
 	if (id < 0)
 		return id;
 
-- 
2.8.3
