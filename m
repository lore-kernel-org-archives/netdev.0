From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 7/8] net: dsa: bcm_sf2: cleanup resources in remove callback
Date: Mon, 12 Jan 2015 13:57:45 -0800
Message-ID: <1421099866-3184-8-git-send-email-f.fainelli@gmail.com>
References: <1421099866-3184-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, buytenh@wantstofly.org,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:54831 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751304AbbALV6C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 16:58:02 -0500
Received: by mail-pa0-f47.google.com with SMTP id kq14so34400585pab.6
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2015 13:58:01 -0800 (PST)
In-Reply-To: <1421099866-3184-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement a remove callback allowing the switch driver to cleanup
resources it used: interrupts and remapped register ranges.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 09f6b3cc1f66..a41b20c7d602 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -526,6 +526,25 @@ out_unmap:
 	return ret;
 }
 
+static void bcm_sf2_sw_remove(struct dsa_switch *ds)
+{
+	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	void __iomem **base;
+	unsigned int i;
+
+	/* Disable all interrupts and free them */
+	bcm_sf2_intr_disable(priv);
+
+	free_irq(priv->irq0, priv);
+	free_irq(priv->irq1, priv);
+
+	base = &priv->core;
+	for (i = 0; i < BCM_SF2_REGS_NUM; i++) {
+		iounmap(*base);
+		base++;
+	}
+}
+
 static int bcm_sf2_sw_set_addr(struct dsa_switch *ds, u8 *addr)
 {
 	return 0;
@@ -858,6 +877,7 @@ static struct dsa_switch_driver bcm_sf2_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_BRCM,
 	.priv_size		= sizeof(struct bcm_sf2_priv),
 	.probe			= bcm_sf2_sw_probe,
+	.remove			= bcm_sf2_sw_remove,
 	.setup			= bcm_sf2_sw_setup,
 	.set_addr		= bcm_sf2_sw_set_addr,
 	.get_phy_flags		= bcm_sf2_sw_get_phy_flags,
-- 
2.1.0
