From: "Mark A. Greer" <mgreer@animalcreek.com>
Subject: [PATCH] net: davinci_emac: Add pre_open, post_stop platform
 callbacks
Date: Wed, 2 May 2012 16:47:18 -0700
Message-ID: <20120502234718.GA5432@animalcreek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Mark A. Greer" <mgreer@animalcreek.com>

The davinci EMAC driver has been incorporated into the am35x
family of SoC's which is OMAP-based.  The incorporation is
incomplete in that the EMAC cannot unblock the [ARM] core if
its blocked on a 'wfi' instruction.  This is an issue with
the cpu_idle code because it has the core execute a 'wfi'
instruction.

To work around this issue, add platform data callbacks which
are called at the beginning of the open routine and at the
end of the stop routine of the davinci_emac driver.  The
callbacks allow the platform code to issue disable_hlt() and
enable_hlt() calls appropriately.  Calling disable_hlt()
prevents cpu_idle from issuing the 'wfi' instruction.

It is not sufficient to simply call disable_hlt() when
there is an EMAC present because it could be present but
not actually used in which case, we do want the 'wfi' to
be executed.

Signed-off-by: Mark A. Greer <mgreer@animalcreek.com>
---

I know adding platform_data callbacks are frowned upon
and I really don't want to add them but I don't see
any other way to accomplish what needs to be accomplished.

Any suggestions?

Thanks, Mark.

 drivers/net/ethernet/ti/davinci_emac.c |   14 ++++++++++++++
 include/linux/davinci_emac.h           |    2 ++
 2 files changed, 16 insertions(+)

diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 174a334..141a888 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -344,6 +344,8 @@ struct emac_priv {
 	/*platform specific members*/
 	void (*int_enable) (void);
 	void (*int_disable) (void);
+	void (*pre_open) (struct net_device *ndev);
+	void (*post_stop) (struct net_device *ndev);
 };
 
 /* clock frequency for EMAC */
@@ -1534,6 +1536,9 @@ static int emac_dev_open(struct net_device *ndev)
 	int k = 0;
 	struct emac_priv *priv = netdev_priv(ndev);
 
+	if (priv->pre_open)
+		priv->pre_open(ndev);
+
 	netif_carrier_off(ndev);
 	for (cnt = 0; cnt < ETH_ALEN; cnt++)
 		ndev->dev_addr[cnt] = priv->mac_addr[cnt];
@@ -1644,6 +1649,10 @@ rollback:
 		res = platform_get_resource(priv->pdev, IORESOURCE_IRQ, k-1);
 		m = res->end;
 	}
+
+	if (priv->post_stop)
+		priv->post_stop(ndev);
+
 	return -EBUSY;
 }
 
@@ -1686,6 +1695,9 @@ static int emac_dev_stop(struct net_device *ndev)
 	if (netif_msg_drv(priv))
 		dev_notice(emac_dev, "DaVinci EMAC: %s stopped\n", ndev->name);
 
+	if (priv->post_stop)
+		priv->post_stop(ndev);
+
 	return 0;
 }
 
@@ -1817,6 +1829,8 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 	priv->version = pdata->version;
 	priv->int_enable = pdata->interrupt_enable;
 	priv->int_disable = pdata->interrupt_disable;
+	priv->pre_open = pdata->pre_open;
+	priv->post_stop = pdata->post_stop;
 
 	priv->coal_intvl = 0;
 	priv->bus_freq_mhz = (u32)(emac_bus_frequency / 1000000);
diff --git a/include/linux/davinci_emac.h b/include/linux/davinci_emac.h
index 5428885..b61e6de 100644
--- a/include/linux/davinci_emac.h
+++ b/include/linux/davinci_emac.h
@@ -39,6 +39,8 @@ struct emac_platform_data {
 	bool no_bd_ram;
 	void (*interrupt_enable) (void);
 	void (*interrupt_disable) (void);
+	void (*pre_open) (struct net_device *ndev);
+	void (*post_stop) (struct net_device *ndev);
 };
 
 enum {
-- 
1.7.9.4

