From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/4] net: dsa: bcm_sf2: Split fast age into a helper function
Date: Thu,  9 Jun 2016 17:42:05 -0700
Message-ID: <1465519328-14249-2-git-send-email-f.fainelli@gmail.com>
References: <1465519328-14249-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com, jiri@mellanox.com,
	idosch@mellanox.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33087 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751153AbcFJAmi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 20:42:38 -0400
Received: by mail-pf0-f195.google.com with SMTP id c74so3814086pfb.0
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2016 17:42:37 -0700 (PDT)
In-Reply-To: <1465519328-14249-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a helper function to fast age something that is controlled by the
caller: port, VLAN. We will use this to implement a VLAN fast age
operation.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c | 20 +++++++++++++-------
 1 file changed, 13 insertions(+), 7 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index d6625783703f..ad22caba51e5 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -461,17 +461,11 @@ static int bcm_sf2_sw_set_eee(struct dsa_switch *ds, int port,
 	return 0;
 }
 
-/* Fast-ageing of ARL entries for a given port, equivalent to an ARL
- * flush for that port.
- */
-static int bcm_sf2_sw_fast_age_port(struct dsa_switch  *ds, int port)
+static int bcm_sf2_fast_age_op(struct bcm_sf2_priv *priv)
 {
-	struct bcm_sf2_priv *priv = ds_to_priv(ds);
 	unsigned int timeout = 1000;
 	u32 reg;
 
-	core_writel(priv, port, CORE_FAST_AGE_PORT);
-
 	reg = core_readl(priv, CORE_FAST_AGE_CTRL);
 	reg |= EN_AGE_PORT | EN_AGE_DYNAMIC | FAST_AGE_STR_DONE;
 	core_writel(priv, reg, CORE_FAST_AGE_CTRL);
@@ -492,6 +486,18 @@ static int bcm_sf2_sw_fast_age_port(struct dsa_switch  *ds, int port)
 	return 0;
 }
 
+/* Fast-ageing of ARL entries for a given port, equivalent to an ARL
+ * flush for that port.
+ */
+static int bcm_sf2_sw_fast_age_port(struct dsa_switch *ds, int port)
+{
+	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+
+	core_writel(priv, port, CORE_FAST_AGE_PORT);
+
+	return bcm_sf2_fast_age_op(priv);
+}
+
 static int bcm_sf2_sw_br_join(struct dsa_switch *ds, int port,
 			      struct net_device *bridge)
 {
-- 
2.7.4
