From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 2/6] net: dsa: Initialize ds->enabled_port_mask and ds->phys_mii_mask
Date: Tue,  7 Jun 2016 14:06:52 -0700
Message-ID: <1465333616-6351-3-git-send-email-f.fainelli@gmail.com>
References: <1465333616-6351-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33065 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754022AbcFGVJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 17:09:33 -0400
Received: by mail-pf0-f196.google.com with SMTP id u67so5167305pfu.0
        for <netdev@vger.kernel.org>; Tue, 07 Jun 2016 14:09:32 -0700 (PDT)
In-Reply-To: <1465333616-6351-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some drivers rely on these two bitmasks to contain the correct values
for them to successfully probe and initialize at drv->setup() time,
calculate correct values to put in both masks as early as possible in
dsa_get_ports_dn().

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa2.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 80dfe08db825..921a36fd139d 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -283,6 +283,7 @@ static void dsa_user_port_unapply(struct device_node *port, u32 index,
 	if (ds->ports[index].netdev) {
 		dsa_slave_destroy(ds->ports[index].netdev);
 		ds->ports[index].netdev = NULL;
+		ds->enabled_port_mask &= ~(1 << index);
 	}
 }
 
@@ -292,6 +293,13 @@ static int dsa_ds_apply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 	u32 index;
 	int err;
 
+	/* Initialize ds->phys_mii_mask before registering the slave MDIO bus
+	 * driver and before drv->setup() has run, since the switch drivers and
+	 * the slave MDIO bus driver rely on these values for probing PHY
+	 * devices or not
+	 */
+	ds->phys_mii_mask = ds->enabled_port_mask;
+
 	err = ds->drv->setup(ds);
 	if (err < 0)
 		return err;
@@ -511,6 +519,13 @@ static int dsa_parse_ports_dn(struct device_node *ports, struct dsa_switch *ds)
 			return -EINVAL;
 
 		ds->ports[reg].dn = port;
+
+		/* Initialize enabled_port_mask now for drv->setup()
+		 * to have access to a correct value, just like what
+		 * net/dsa/dsa.c::dsa_switch_setup_one does.
+		 */
+		if (!dsa_port_is_cpu(port))
+			ds->enabled_port_mask |= 1 << reg;
 	}
 
 	return 0;
-- 
2.7.4
