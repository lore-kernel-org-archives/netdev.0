From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 3/6] net: dsa: Provide a slave MII bus if needed
Date: Tue,  7 Jun 2016 14:06:53 -0700
Message-ID: <1465333616-6351-4-git-send-email-f.fainelli@gmail.com>
References: <1465333616-6351-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33071 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756703AbcFGVJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 17:09:33 -0400
Received: by mail-pf0-f195.google.com with SMTP id u67so5167348pfu.0
        for <netdev@vger.kernel.org>; Tue, 07 Jun 2016 14:09:33 -0700 (PDT)
In-Reply-To: <1465333616-6351-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mimic what net/dsa/dsa.c does and provide a slave MII bus by default
which will be created if the driver implements a phy_read method.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa2.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 921a36fd139d..4e0f3c268103 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -312,6 +312,18 @@ static int dsa_ds_apply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 	if (err < 0)
 		return err;
 
+	if (!ds->slave_mii_bus && ds->drv->phy_read) {
+		ds->slave_mii_bus = devm_mdiobus_alloc(ds->dev);
+		if (!ds->slave_mii_bus)
+			return -ENOMEM;
+
+		dsa_slave_mii_bus_init(ds);
+
+		err = mdiobus_register(ds->slave_mii_bus);
+		if (err < 0)
+			return err;
+	}
+
 	for (index = 0; index < DSA_MAX_PORTS; index++) {
 		port = ds->ports[index].dn;
 		if (!port)
@@ -361,6 +373,9 @@ static void dsa_ds_unapply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 
 		dsa_user_port_unapply(port, index, ds);
 	}
+
+	if (ds->slave_mii_bus && ds->drv->phy_read)
+		mdiobus_unregister(ds->slave_mii_bus);
 }
 
 static int dsa_dst_apply(struct dsa_switch_tree *dst)
-- 
2.7.4
