From: Damien Riegel <damien.riegel@savoirfairelinux.com>
Subject: [PATCH v3 1/3] can: sja1000: of: add per-compatible init hook
Date: Tue, 12 Jan 2016 17:31:18 -0500
Message-ID: <1452637880-9922-2-git-send-email-damien.riegel@savoirfairelinux.com>
References: <1452637880-9922-1-git-send-email-damien.riegel@savoirfairelinux.com>
Cc: Rob Herring <robh+dt@kernel.org>, Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	kernel@savoirfairelinux.com,
	Damien Riegel <damien.riegel@savoirfairelinux.com>
To: linux-kernel@vger.kernel.org, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452637880-9922-1-git-send-email-damien.riegel@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This commit adds the capability to allocate and init private data
embedded in the sja1000_priv structure on a per-compatible basis. The
device node is passed as a parameter of the init callback to allow
parsing of custom device tree properties.

Signed-off-by: Damien Riegel <damien.riegel@savoirfairelinux.com>
---
 drivers/net/can/sja1000/sja1000_platform.c | 28 +++++++++++++++++++++-------
 1 file changed, 21 insertions(+), 7 deletions(-)

diff --git a/drivers/net/can/sja1000/sja1000_platform.c b/drivers/net/can/sja1000/sja1000_platform.c
index 0552ed4..ea4e18b 100644
--- a/drivers/net/can/sja1000/sja1000_platform.c
+++ b/drivers/net/can/sja1000/sja1000_platform.c
@@ -40,6 +40,11 @@ MODULE_DESCRIPTION("Socket-CAN driver for SJA1000 on the platform bus");
 MODULE_ALIAS("platform:" DRV_NAME);
 MODULE_LICENSE("GPL v2");
 
+struct sja1000_of_data {
+	size_t  priv_sz;
+	int     (*init)(struct sja1000_priv *priv, struct device_node *of);
+};
+
 static u8 sp_read_reg8(const struct sja1000_priv *priv, int reg)
 {
 	return ioread8(priv->reg_base + reg);
@@ -154,6 +159,12 @@ static void sp_populate_of(struct sja1000_priv *priv, struct device_node *of)
 		priv->cdr |= CDR_CBP; /* default */
 }
 
+static const struct of_device_id sp_of_table[] = {
+	{.compatible = "nxp,sja1000"},
+	{},
+};
+MODULE_DEVICE_TABLE(of, sp_of_table);
+
 static int sp_probe(struct platform_device *pdev)
 {
 	int err, irq = 0;
@@ -163,6 +174,9 @@ static int sp_probe(struct platform_device *pdev)
 	struct resource *res_mem, *res_irq = NULL;
 	struct sja1000_platform_data *pdata;
 	struct device_node *of = pdev->dev.of_node;
+	const struct of_device_id *id = of_match_node(sp_of_table, of);
+	const struct sja1000_of_data *of_data = id ? id->data : NULL;
+	size_t priv_sz = of_data ? of_data->priv_sz : 0;
 
 	pdata = dev_get_platdata(&pdev->dev);
 	if (!pdata && !of) {
@@ -191,7 +205,7 @@ static int sp_probe(struct platform_device *pdev)
 	if (!irq && !res_irq)
 		return -ENODEV;
 
-	dev = alloc_sja1000dev(0);
+	dev = alloc_sja1000dev(priv_sz);
 	if (!dev)
 		return -ENOMEM;
 	priv = netdev_priv(dev);
@@ -213,6 +227,12 @@ static int sp_probe(struct platform_device *pdev)
 	else
 		sp_populate(priv, pdata, res_mem->flags);
 
+	if (of_data && of_data->init) {
+		err = of_data->init(priv, of);
+		if (err)
+			goto exit_free;
+	}
+
 	platform_set_drvdata(pdev, dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
@@ -242,12 +262,6 @@ static int sp_remove(struct platform_device *pdev)
 	return 0;
 }
 
-static const struct of_device_id sp_of_table[] = {
-	{.compatible = "nxp,sja1000"},
-	{},
-};
-MODULE_DEVICE_TABLE(of, sp_of_table);
-
 static struct platform_driver sp_driver = {
 	.probe = sp_probe,
 	.remove = sp_remove,
-- 
2.5.0
