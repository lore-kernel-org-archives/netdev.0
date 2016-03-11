From: Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Subject: [PATCH 3/6] net: arc_emac: support the phy reset for emac driver
Date: Fri, 11 Mar 2016 18:55:28 +0800
Message-ID: <1457693731-6966-4-git-send-email-wxt@rock-chips.com>
References: <1457693731-6966-1-git-send-email-wxt@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Alexander Kochetkov <al.kochet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 keescook-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, leozwang-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
To: Heiko Stuebner <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
 Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1457693731-6966-1-git-send-email-wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
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

1) phy-reset-gpios:
The phy-reset-gpios is an optional property for arc emac device tree boot.
Change the binding document to match the driver code.

2) phy-reset-duration:
Different boards may require different phy reset duration. Add property
phy-reset-duration for device tree probe, so that the boards that need
a longer reset duration can specify it in their device tree.

3) phy-reset-active-high:
We need that for a custom hardware that needs the reverse reset sequence.

Of course, this patch will fix the issue on
https://patchwork.kernel.org/patch/8186801/.

In some cases, the emac couldn't work if you don't have reset the phy.
Let's add it to happy work.

Signed-off-by: Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
---

 drivers/net/ethernet/arc/emac_main.c | 41 ++++++++++++++++++++++++++++++++++++
 1 file changed, 41 insertions(+)

diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index 6446af1..42384f6a 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -764,6 +764,45 @@ static const struct net_device_ops arc_emac_netdev_ops = {
 #endif
 };
 
+#ifdef CONFIG_OF
+static void emac_reset_phy(struct net_device *pdev)
+{
+	int err, phy_reset;
+	bool active_high = false;
+	int msec = 10;
+	struct device *dev = pdev->dev.parent;
+	struct device_node *np = dev->of_node;
+
+	if (!np)
+		return;
+
+	of_property_read_u32(np, "phy-reset-duration", &msec);
+	/* A sane reset duration should not be longer than 1s */
+	if (msec > 1000)
+		msec = 1;
+
+	phy_reset = of_get_named_gpio(np, "phy-reset-gpios", 0);
+	if (!gpio_is_valid(phy_reset))
+		return;
+
+	active_high = of_property_read_bool(np, "phy-reset-active-high");
+
+	err = devm_gpio_request_one(dev, phy_reset, active_high ?
+				    GPIOF_OUT_INIT_HIGH : GPIOF_OUT_INIT_LOW,
+				    "phy-reset");
+	if (err) {
+		dev_err(dev, "failed to get phy-reset-gpios: %d\n", err);
+		return;
+	}
+	msleep(msec);
+	gpio_set_value_cansleep(phy_reset, !active_high);
+}
+#else
+static void emac_reset_phy(struct platform_device *pdev)
+{
+}
+#endif /* CONFIG_OF */
+
 int arc_emac_probe(struct net_device *ndev, int interface)
 {
 	struct device *dev = ndev->dev.parent;
@@ -803,6 +842,8 @@ int arc_emac_probe(struct net_device *ndev, int interface)
 	/* FIXME :: no multicast support yet */
 	ndev->flags &= ~IFF_MULTICAST;
 
+	emac_reset_phy(ndev);
+
 	priv = netdev_priv(ndev);
 	priv->dev = dev;
 
-- 
1.9.1
