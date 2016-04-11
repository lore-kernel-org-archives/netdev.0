From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 7/7] dsa: mv88e6xxx: Use bus in mv88e6xxx_lookup_name()
Date: Mon, 11 Apr 2016 21:50:09 +0200
Message-ID: <1460404209-32083-8-git-send-email-andrew@lunn.ch>
References: <1460404209-32083-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53448 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750925AbcDKTwq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Apr 2016 15:52:46 -0400
In-Reply-To: <1460404209-32083-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mv88e6xxx_lookup_name() returns the model name of a switch at a given
address on an MII bus. Using mii_bus to identify the bus rather than
the host device is more logical, so change the parameter.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
v2: Check bus is valid before using it.
---
 drivers/net/dsa/mv88e6xxx.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index c242ffd8eb09..9985a0cf31f1 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -3068,11 +3068,10 @@ int mv88e6xxx_get_temp_alarm(struct dsa_switch *ds, bool *alarm)
 }
 #endif /* CONFIG_NET_DSA_HWMON */
 
-static char *mv88e6xxx_lookup_name(struct device *host_dev, int sw_addr,
+static char *mv88e6xxx_lookup_name(struct mii_bus *bus, int sw_addr,
 				   const struct mv88e6xxx_switch_id *table,
 				   unsigned int num)
 {
-	struct mii_bus *bus = dsa_host_dev_to_mii_bus(host_dev);
 	int i, ret;
 
 	if (!bus)
@@ -3090,7 +3089,8 @@ static char *mv88e6xxx_lookup_name(struct device *host_dev, int sw_addr,
 	/* Look up only the product number */
 	for (i = 0; i < num; ++i) {
 		if (table[i].id == (ret & PORT_SWITCH_ID_PROD_NUM_MASK)) {
-			dev_warn(host_dev, "unknown revision %d, using base switch 0x%x\n",
+			dev_warn(&bus->dev,
+				 "unknown revision %d, using base switch 0x%x\n",
 				 ret & PORT_SWITCH_ID_REV_MASK,
 				 ret & PORT_SWITCH_ID_PROD_NUM_MASK);
 			return table[i].name;
@@ -3106,9 +3106,13 @@ char *mv88e6xxx_drv_probe(struct device *dsa_dev, struct device *host_dev,
 			  unsigned int num)
 {
 	struct mv88e6xxx_priv_state *ps;
+	struct mii_bus *bus = dsa_host_dev_to_mii_bus(host_dev);
 	char *name;
 
-	name = mv88e6xxx_lookup_name(host_dev, sw_addr, table, num);
+	if (!bus)
+		return NULL;
+
+	name = mv88e6xxx_lookup_name(bus, sw_addr, table, num);
 	if (name) {
 		ps = devm_kzalloc(dsa_dev, sizeof(*ps), GFP_KERNEL);
 		if (!ps)
-- 
2.7.0
