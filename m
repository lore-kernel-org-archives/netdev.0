From: Damien Riegel <damien.riegel@savoirfairelinux.com>
Subject: [PATCH v2 1/3] can: sja1000: of: add per-compatible init hook
Date: Thu, 24 Dec 2015 12:42:51 -0500
Message-ID: <1450978973-30417-2-git-send-email-damien.riegel@savoirfairelinux.com>
References: <1450978973-30417-1-git-send-email-damien.riegel@savoirfairelinux.com>
Cc: Rob Herring <robh+dt@kernel.org>, Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	kernel@savoirfairelinux.com,
	Damien Riegel <damien.riegel@savoirfairelinux.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-can@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1450978973-30417-1-git-send-email-damien.riegel@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This commit adds the capability to allocate and init private data
embedded in the sja1000_priv structure on a per-compatible basis. The
device node is passed as a parameter of the init callback to allow
parsing of custom device tree properties.

Signed-off-by: Damien Riegel <damien.riegel@savoirfairelinux.com>
---
 drivers/net/can/sja1000/sja1000_platform.c | 39 ++++++++++++++++++++++++++++--
 1 file changed, 37 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/sja1000/sja1000_platform.c b/drivers/net/can/sja1000/sja1000_platform.c
index 0552ed4..e0572d0 100644
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
@@ -154,7 +159,8 @@ static void sp_populate_of(struct sja1000_priv *priv, struct device_node *of)
 		priv->cdr |= CDR_CBP; /* default */
 }
 
-static int sp_probe(struct platform_device *pdev)
+static int __sp_probe(struct platform_device *pdev,
+		      const struct sja1000_of_data *of_data)
 {
 	int err, irq = 0;
 	void __iomem *addr;
@@ -163,6 +169,7 @@ static int sp_probe(struct platform_device *pdev)
 	struct resource *res_mem, *res_irq = NULL;
 	struct sja1000_platform_data *pdata;
 	struct device_node *of = pdev->dev.of_node;
+	size_t priv_sz = of_data ? of_data->priv_sz : 0;
 
 	pdata = dev_get_platdata(&pdev->dev);
 	if (!pdata && !of) {
@@ -191,7 +198,7 @@ static int sp_probe(struct platform_device *pdev)
 	if (!irq && !res_irq)
 		return -ENODEV;
 
-	dev = alloc_sja1000dev(0);
+	dev = alloc_sja1000dev(priv_sz);
 	if (!dev)
 		return -ENOMEM;
 	priv = netdev_priv(dev);
@@ -213,6 +220,12 @@ static int sp_probe(struct platform_device *pdev)
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
 
@@ -248,6 +261,28 @@ static const struct of_device_id sp_of_table[] = {
 };
 MODULE_DEVICE_TABLE(of, sp_of_table);
 
+static const struct sja1000_of_data *sp_get_of_data(struct device_node *of)
+{
+	const struct of_device_id *id;
+
+	if (!of)
+		return NULL;
+
+	id = of_match_node(sp_of_table, of);
+	if (!id)
+		return NULL;
+
+	return id->data;
+}
+
+static int sp_probe(struct platform_device *pdev)
+{
+	struct device_node *of = pdev->dev.of_node;
+	const struct sja1000_of_data *of_data = sp_get_of_data(of);
+
+	return __sp_probe(pdev, of_data);
+}
+
 static struct platform_driver sp_driver = {
 	.probe = sp_probe,
 	.remove = sp_remove,
-- 
2.5.0
