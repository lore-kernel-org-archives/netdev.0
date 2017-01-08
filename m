From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 1/2] net: dsa: bcm_sf2: Do not clobber b53_switch_ops
Date: Sat,  7 Jan 2017 21:01:56 -0800
Message-ID: <20170108050157.16302-2-f.fainelli@gmail.com>
References: <20170108050157.16302-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35958 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754094AbdAHFCB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2017 00:02:01 -0500
Received: by mail-pg0-f66.google.com with SMTP id 75so10002763pgf.3
        for <netdev@vger.kernel.org>; Sat, 07 Jan 2017 21:02:01 -0800 (PST)
In-Reply-To: <20170108050157.16302-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We make the bcm_sf2 driver override ds->ops which points to
b53_switch_ops since b53_switch_alloc() did the assignent. This is all
well and good until a second b53 switch comes in, and ends up using the
bcm_sf2 operations. Make a proper local copy, substitute the ds->ops
pointer and then override the operations.

Fixes: f458995b9ad8 ("net: dsa: bcm_sf2: Utilize core B53 driver when possible")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 9ec33b51a0ed..2f9f910c0e40 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -982,6 +982,7 @@ static int bcm_sf2_sw_probe(struct platform_device *pdev)
 	const char *reg_names[BCM_SF2_REGS_NUM] = BCM_SF2_REGS_NAME;
 	struct device_node *dn = pdev->dev.of_node;
 	struct b53_platform_data *pdata;
+	struct dsa_switch_ops *ops;
 	struct bcm_sf2_priv *priv;
 	struct b53_device *dev;
 	struct dsa_switch *ds;
@@ -995,6 +996,10 @@ static int bcm_sf2_sw_probe(struct platform_device *pdev)
 	if (!priv)
 		return -ENOMEM;
 
+	ops = devm_kzalloc(&pdev->dev, sizeof(*ops), GFP_KERNEL);
+	if (!ops)
+		return -ENOMEM;
+
 	dev = b53_switch_alloc(&pdev->dev, &bcm_sf2_io_ops, priv);
 	if (!dev)
 		return -ENOMEM;
@@ -1014,6 +1019,8 @@ static int bcm_sf2_sw_probe(struct platform_device *pdev)
 	ds = dev->ds;
 
 	/* Override the parts that are non-standard wrt. normal b53 devices */
+	memcpy(ops, ds->ops, sizeof(*ops));
+	ds->ops = ops;
 	ds->ops->get_tag_protocol = bcm_sf2_sw_get_tag_protocol;
 	ds->ops->setup = bcm_sf2_sw_setup;
 	ds->ops->get_phy_flags = bcm_sf2_sw_get_phy_flags;
-- 
2.9.3
