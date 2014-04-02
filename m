From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 1/1] sxgbe: fix driver probe error path and driver
 removal leaks
Date: Thu, 3 Apr 2014 01:13:43 +0200
Message-ID: <20140402231343.GC5013@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'David Miller'" <davem@davemloft.net>, dan.carpenter@oracle.com,
	ks.giri@samsung.com, siva.kallam@samsung.com,
	vipul.pandya@samsung.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Byungho An <bh74.an@samsung.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

sxgbe_drv_probe:  mdio and priv->hw leaks
sxgbe_drv_remove: clk and priv->hw leaks

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---

 Compiled, untested.

 drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c | 27 ++++++++++++++++---------
 1 file changed, 17 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
index a72688e..27e8c82 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
@@ -2113,11 +2113,11 @@ struct sxgbe_priv_data *sxgbe_drv_probe(struct device *device,
 	/* allocate memory resources for Descriptor rings */
 	ret = txring_mem_alloc(priv);
 	if (ret)
-		goto error_free_netdev;
+		goto error_free_hw;
 
 	ret = rxring_mem_alloc(priv);
 	if (ret)
-		goto error_free_netdev;
+		goto error_free_hw;
 
 	ndev->netdev_ops = &sxgbe_netdev_ops;
 
@@ -2163,7 +2163,7 @@ struct sxgbe_priv_data *sxgbe_drv_probe(struct device *device,
 	if (IS_ERR(priv->sxgbe_clk)) {
 		netdev_warn(ndev, "%s: warning: cannot get CSR clock\n",
 			    __func__);
-		goto error_clk_get;
+		goto error_napi_del;
 	}
 
 	/* If a specific clk_csr value is passed from the platform
@@ -2182,24 +2182,27 @@ struct sxgbe_priv_data *sxgbe_drv_probe(struct device *device,
 	if (ret < 0) {
 		netdev_dbg(ndev, "%s: MDIO bus (id: %d) registration failed\n",
 			   __func__, priv->plat->bus_id);
-		goto error_mdio_register;
+		goto error_clk_put;
 	}
 
 	ret = register_netdev(ndev);
 	if (ret) {
 		pr_err("%s: ERROR %i registering the device\n", __func__, ret);
-		goto error_netdev_register;
+		goto error_mdio_unregister;
 	}
 
 	sxgbe_check_ether_addr(priv);
 
 	return priv;
 
-error_mdio_register:
+error_mdio_unregister:
+	sxgbe_mdio_unregister(ndev);
+error_clk_put:
 	clk_put(priv->sxgbe_clk);
-error_clk_get:
-error_netdev_register:
+error_napi_del:
 	netif_napi_del(&priv->napi);
+error_free_hw:
+	kfree(priv->hw);
 error_free_netdev:
 	free_netdev(ndev);
 
@@ -2224,11 +2227,15 @@ int sxgbe_drv_remove(struct net_device *ndev)
 	priv->hw->mac->enable_tx(priv->ioaddr, false);
 	priv->hw->mac->enable_rx(priv->ioaddr, false);
 
-	netif_napi_del(&priv->napi);
+	unregister_netdev(ndev);
 
 	sxgbe_mdio_unregister(ndev);
 
-	unregister_netdev(ndev);
+	clk_put(priv->sxgbe_clk);
+
+	netif_napi_del(&priv->napi);
+
+	kfree(priv->hw);
 
 	free_netdev(ndev);
 
-- 
1.9.0

