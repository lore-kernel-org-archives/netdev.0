From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [RFC PATCH v3 2/5] net: dsa: bcm_sf2: cleanup resources in remove
 callback
Date: Thu, 29 Oct 2015 15:45:30 +0100
Message-ID: <5632310A.8040406@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Implement a remove callback allowing the switch driver to cleanup
resources it used: interrupts and remapped register ranges.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 drivers/net/dsa/bcm_sf2.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 6f946fe..e0be318 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -1054,6 +1054,25 @@ out_unmap:
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
@@ -1367,6 +1386,7 @@ static struct dsa_switch_driver bcm_sf2_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_BRCM,
 	.priv_size		= sizeof(struct bcm_sf2_priv),
 	.probe			= bcm_sf2_sw_probe,
+	.remove			= bcm_sf2_sw_remove,
 	.setup			= bcm_sf2_sw_setup,
 	.set_addr		= bcm_sf2_sw_set_addr,
 	.get_phy_flags		= bcm_sf2_sw_get_phy_flags,
-- 
1.9.1
