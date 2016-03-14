From: Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Subject: [PATCH v3 3/9] net: arc_emac: support the phy reset for emac driver
Date: Mon, 14 Mar 2016 16:01:54 +0800
Message-ID: <1457942520-12859-4-git-send-email-wxt@rock-chips.com>
References: <1457942520-12859-1-git-send-email-wxt@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org,
 Alexander Kochetkov <al.kochet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 keescook-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, leozwang-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
To: Heiko Stuebner <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
 Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1457942520-12859-1-git-send-email-wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-rockchip/>
List-Post: <mailto:linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-rockchip" <linux-rockchip-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds to support the emac phy reset.

Different boards may require different phy reset duration. Add property
phy-reset-duration for emac driver, so that the boards that need
a longer reset duration can specify it in their device tree.

Signed-off-by: Heiko Stuebner <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>
Signed-off-by: Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Alexander Kochetkov <al.kochet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>

---

Changes in v3:
- Caused the build error since the missing include head file.
- %s/reset/phy-reset to match the device tree.
- Add the Cc people

Changes in v2:
- As the pervious version, Sergei and Heiko comments on
  https://patchwork.kernel.org/patch/8564571/.
- Nevermind, add signed-off since Heiko the original patch,
  refer the Heiko's test patch on
  https://github.com/mmind/linux-rockchip/commit/a943c588783438ff1c508dfa8c79f1709aa5775e
  :)

 drivers/net/ethernet/arc/emac.h      |  6 ++++++
 drivers/net/ethernet/arc/emac_mdio.c | 37 ++++++++++++++++++++++++++++++++++++
 2 files changed, 43 insertions(+)

diff --git a/drivers/net/ethernet/arc/emac.h b/drivers/net/ethernet/arc/emac.h
index dae1ac3..1a40403 100644
--- a/drivers/net/ethernet/arc/emac.h
+++ b/drivers/net/ethernet/arc/emac.h
@@ -102,6 +102,11 @@ struct buffer_state {
 	DEFINE_DMA_UNMAP_LEN(len);
 };
 
+struct arc_emac_mdio_bus_data {
+	struct gpio_desc *reset_gpio;
+	int msec;
+};
+
 /**
  * struct arc_emac_priv - Storage of EMAC's private information.
  * @dev:	Pointer to the current device.
@@ -131,6 +136,7 @@ struct arc_emac_priv {
 	struct device *dev;
 	struct phy_device *phy_dev;
 	struct mii_bus *bus;
+	struct arc_emac_mdio_bus_data bus_data;
 
 	void __iomem *regs;
 	struct clk *clk;
diff --git a/drivers/net/ethernet/arc/emac_mdio.c b/drivers/net/ethernet/arc/emac_mdio.c
index d5ee986..caf7042 100644
--- a/drivers/net/ethernet/arc/emac_mdio.c
+++ b/drivers/net/ethernet/arc/emac_mdio.c
@@ -7,6 +7,7 @@
 #include <linux/delay.h>
 #include <linux/of_mdio.h>
 #include <linux/platform_device.h>
+#include <linux/gpio/consumer.h>
 
 #include "emac.h"
 
@@ -99,6 +100,25 @@ static int arc_mdio_write(struct mii_bus *bus, int phy_addr,
 }
 
 /**
+ * arc_mdio_reset
+ * @bus: points to the mii_bus structure
+ * Description: reset the MII bus
+ */
+int arc_mdio_reset(struct mii_bus *bus)
+{
+	struct arc_emac_priv *priv = bus->priv;
+	struct arc_emac_mdio_bus_data *data = &priv->bus_data;
+
+	if (data->reset_gpio) {
+		gpiod_set_value_cansleep(data->reset_gpio, 1);
+		msleep(data->msec);
+		gpiod_set_value_cansleep(data->reset_gpio, 0);
+	}
+
+	return 0;
+}
+
+/**
  * arc_mdio_probe - MDIO probe function.
  * @priv:	Pointer to ARC EMAC private data structure.
  *
@@ -109,6 +129,8 @@ static int arc_mdio_write(struct mii_bus *bus, int phy_addr,
  */
 int arc_mdio_probe(struct arc_emac_priv *priv)
 {
+	struct arc_emac_mdio_bus_data *data = &priv->bus_data;
+	struct device_node *np = priv->dev->of_node;
 	struct mii_bus *bus;
 	int error;
 
@@ -122,6 +144,21 @@ int arc_mdio_probe(struct arc_emac_priv *priv)
 	bus->name = "Synopsys MII Bus",
 	bus->read = &arc_mdio_read;
 	bus->write = &arc_mdio_write;
+	bus->reset = &arc_mdio_reset;
+
+	/* optional reset-related properties */
+	data->reset_gpio = devm_gpiod_get_optional(priv->dev, "phy-reset",
+						   GPIOD_OUT_LOW);
+	if (IS_ERR(data->reset_gpio)) {
+		error = PTR_ERR(data->reset_gpio);
+		dev_err(priv->dev, "Failed to request gpio: %d\n", error);
+		return error;
+	}
+
+	of_property_read_u32(np, "phy-reset-duration", &data->msec);
+	/* A sane reset duration should not be longer than 1s */
+	if (data->msec > 1000)
+		data->msec = 1;
 
 	snprintf(bus->id, MII_BUS_ID_SIZE, "%s", bus->name);
 
-- 
1.9.1
