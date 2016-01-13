From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH v4 3/3] can: sja1000: of: add compatibility with Technologic Systems version
Date: Wed, 13 Jan 2016 12:46:06 +0100
Message-ID: <1452685566-27431-4-git-send-email-mkl@pengutronix.de>
References: <1452685566-27431-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org,
	Damien Riegel <damien.riegel@savoirfairelinux.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1452685566-27431-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Damien Riegel <damien.riegel@savoirfairelinux.com>

Technologic Systems provides an IP compatible with the SJA1000,
instantiated in an FPGA. Because of some bus widths issue, access to
registers is made through a "window" that works like this:

    base + 0x0: address to read/write
    base + 0x2: 8-bit register value

This commit adds a new compatible device, "technologic,sja1000", with
read and write functions using the window mechanism.

Signed-off-by: Damien Riegel <damien.riegel@savoirfairelinux.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/sja1000/sja1000_platform.c | 47 ++++++++++++++++++++++++++++++
 1 file changed, 47 insertions(+)

diff --git a/drivers/net/can/sja1000/sja1000_platform.c b/drivers/net/can/sja1000/sja1000_platform.c
index 46378c9dbb29..aad10e8f1de5 100644
--- a/drivers/net/can/sja1000/sja1000_platform.c
+++ b/drivers/net/can/sja1000/sja1000_platform.c
@@ -46,6 +46,10 @@ struct sja1000_of_data {
 	int     (*init)(struct sja1000_priv *priv, struct device_node *of);
 };
 
+struct technologic_priv {
+	spinlock_t      io_lock;
+};
+
 static u8 sp_read_reg8(const struct sja1000_priv *priv, int reg)
 {
 	return ioread8(priv->reg_base + reg);
@@ -76,6 +80,43 @@ static void sp_write_reg32(const struct sja1000_priv *priv, int reg, u8 val)
 	iowrite8(val, priv->reg_base + reg * 4);
 }
 
+static u8 sp_technologic_read_reg16(const struct sja1000_priv *priv, int reg)
+{
+	struct technologic_priv *tp = priv->priv;
+	unsigned long flags;
+	u8 val;
+
+	spin_lock_irqsave(&tp->io_lock, flags);
+	iowrite16(reg, priv->reg_base + 0);
+	val = ioread16(priv->reg_base + 2);
+	spin_unlock_irqrestore(&tp->io_lock, flags);
+
+	return val;
+}
+
+static void sp_technologic_write_reg16(const struct sja1000_priv *priv,
+				       int reg, u8 val)
+{
+	struct technologic_priv *tp = priv->priv;
+	unsigned long flags;
+
+	spin_lock_irqsave(&tp->io_lock, flags);
+	iowrite16(reg, priv->reg_base + 0);
+	iowrite16(val, priv->reg_base + 2);
+	spin_unlock_irqrestore(&tp->io_lock, flags);
+}
+
+static int sp_technologic_init(struct sja1000_priv *priv, struct device_node *of)
+{
+	struct technologic_priv *tp = priv->priv;
+
+	priv->read_reg = sp_technologic_read_reg16;
+	priv->write_reg = sp_technologic_write_reg16;
+	spin_lock_init(&tp->io_lock);
+
+	return 0;
+}
+
 static void sp_populate(struct sja1000_priv *priv,
 			struct sja1000_platform_data *pdata,
 			unsigned long resource_mem_flags)
@@ -162,8 +203,14 @@ static void sp_populate_of(struct sja1000_priv *priv, struct device_node *of)
 
 static struct sja1000_of_data nxp_data;
 
+static struct sja1000_of_data technologic_data = {
+	.priv_sz = sizeof(struct technologic_priv),
+	.init = sp_technologic_init,
+};
+
 static const struct of_device_id sp_of_table[] = {
 	{ .compatible = "nxp,sja1000", .data = &nxp_data },
+	{ .compatible = "technologic,sja1000", .data = &technologic_data },
 	{ /* sentinel */ },
 };
 MODULE_DEVICE_TABLE(of, sp_of_table);
-- 
2.6.4

