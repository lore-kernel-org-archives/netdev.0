From: Damien Riegel <damien.riegel@savoirfairelinux.com>
Subject: [PATCH 2/2] can: sja1000: of: add compatibility with Technologic Systems version
Date: Fri, 18 Dec 2015 15:17:25 -0500
Message-ID: <1450469845-12900-2-git-send-email-damien.riegel@savoirfairelinux.com>
References: <1450469845-12900-1-git-send-email-damien.riegel@savoirfairelinux.com>
Cc: Rob Herring <robh+dt@kernel.org>, Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	kernel@savoirfairelinux.com,
	Damien Riegel <damien.riegel@savoirfairelinux.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, devicetree@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1450469845-12900-1-git-send-email-damien.riegel@savoirfairelinux.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Technologic Systems provides an IP compatible with the SJA1000,
instantiated in an FPGA. Because of some bus widths issue, access to
registers is made through a "window" that works like this:

    base + 0x0: address to read/write
    base + 0x2: 8-bit register value

This commit adds a new compatible device, "technologic,sja1000", with
read and write functions using the window mechanism.

Signed-off-by: Damien Riegel <damien.riegel@savoirfairelinux.com>
---
 drivers/net/can/sja1000/sja1000_platform.c | 30 ++++++++++++++++++++++++++++--
 1 file changed, 28 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/sja1000/sja1000_platform.c b/drivers/net/can/sja1000/sja1000_platform.c
index 0552ed4..6cbf251 100644
--- a/drivers/net/can/sja1000/sja1000_platform.c
+++ b/drivers/net/can/sja1000/sja1000_platform.c
@@ -70,6 +70,18 @@ static void sp_write_reg32(const struct sja1000_priv *priv, int reg, u8 val)
 	iowrite8(val, priv->reg_base + reg * 4);
 }
 
+static u8 ts4800_read_reg16(const struct sja1000_priv *priv, int reg)
+{
+	sp_write_reg16(priv, 0,  reg);
+	return sp_read_reg16(priv, 2);
+}
+
+static void ts4800_write_reg16(const struct sja1000_priv *priv, int reg, u8 val)
+{
+	sp_write_reg16(priv, 0, reg);
+	sp_write_reg16(priv, 2, val);
+}
+
 static void sp_populate(struct sja1000_priv *priv,
 			struct sja1000_platform_data *pdata,
 			unsigned long resource_mem_flags)
@@ -98,21 +110,34 @@ static void sp_populate(struct sja1000_priv *priv,
 
 static void sp_populate_of(struct sja1000_priv *priv, struct device_node *of)
 {
+	int is_technologic;
 	int err;
 	u32 prop;
 
+	is_technologic = of_device_is_compatible(of, "technologic,sja1000");
+
 	err = of_property_read_u32(of, "reg-io-width", &prop);
 	if (err)
 		prop = 1; /* 8 bit is default */
 
+	if (is_technologic && prop != 2) {
+		netdev_warn(priv->dev, "forcing reg-io-width to 2\n");
+		prop = 2;
+	}
+
 	switch (prop) {
 	case 4:
 		priv->read_reg = sp_read_reg32;
 		priv->write_reg = sp_write_reg32;
 		break;
 	case 2:
-		priv->read_reg = sp_read_reg16;
-		priv->write_reg = sp_write_reg16;
+		if (is_technologic) {
+			priv->read_reg = ts4800_read_reg16;
+			priv->write_reg = ts4800_write_reg16;
+		} else {
+			priv->read_reg = sp_read_reg16;
+			priv->write_reg = sp_write_reg16;
+		}
 		break;
 	case 1:	/* fallthrough */
 	default:
@@ -244,6 +269,7 @@ static int sp_remove(struct platform_device *pdev)
 
 static const struct of_device_id sp_of_table[] = {
 	{.compatible = "nxp,sja1000"},
+	{.compatible = "technologic,sja1000"},
 	{},
 };
 MODULE_DEVICE_TABLE(of, sp_of_table);
-- 
2.5.0

