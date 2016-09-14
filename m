From: <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next v2 3/7] net: ethernet: mediatek: cleanup error path
 inside mtk_hw_init
Date: Wed, 14 Sep 2016 23:13:17 +0800
Message-ID: <1473866001-9805-4-git-send-email-sean.wang@mediatek.com>
References: <1473866001-9805-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, keyhaede-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>, linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 objelf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1473866001-9805-1-git-send-email-sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>

This cleans up the error path inside mtk_hw_init call, causing it able
to exit appropriately when something fails and also includes refactoring
mtk_cleanup call to make the partial logic reusable on the error path.

Signed-off-by: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 34 ++++++++++++++++++++++++-----
 1 file changed, 29 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index c71b0b3..917a49c6 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -1564,17 +1564,36 @@ static void mtk_pending_work(struct work_struct *work)
 	rtnl_unlock();
 }
 
-static int mtk_cleanup(struct mtk_eth *eth)
+static int mtk_free_dev(struct mtk_eth *eth)
 {
 	int i;
 
 	for (i = 0; i < MTK_MAC_COUNT; i++) {
 		if (!eth->netdev[i])
 			continue;
+		free_netdev(eth->netdev[i]);
+	}
+
+	return 0;
+}
 
+static int mtk_unreg_dev(struct mtk_eth *eth)
+{
+	int i;
+
+	for (i = 0; i < MTK_MAC_COUNT; i++) {
+		if (!eth->netdev[i])
+			continue;
 		unregister_netdev(eth->netdev[i]);
-		free_netdev(eth->netdev[i]);
 	}
+
+	return 0;
+}
+
+static int mtk_cleanup(struct mtk_eth *eth)
+{
+	mtk_unreg_dev(eth);
+	mtk_free_dev(eth);
 	cancel_work_sync(&eth->pending_work);
 
 	return 0;
@@ -1872,7 +1891,7 @@ static int mtk_probe(struct platform_device *pdev)
 
 		err = mtk_add_mac(eth, mac_np);
 		if (err)
-			goto err_free_dev;
+			goto err_deinit_hw;
 	}
 
 	err = devm_request_irq(eth->dev, eth->irq[1], mtk_handle_irq_tx, 0,
@@ -1896,7 +1915,7 @@ static int mtk_probe(struct platform_device *pdev)
 		err = register_netdev(eth->netdev[i]);
 		if (err) {
 			dev_err(eth->dev, "error bringing up device\n");
-			goto err_free_dev;
+			goto err_deinit_mdio;
 		} else
 			netif_info(eth, probe, eth->netdev[i],
 				   "mediatek frame engine at 0x%08lx, irq %d\n",
@@ -1916,8 +1935,13 @@ static int mtk_probe(struct platform_device *pdev)
 
 	return 0;
 
+err_deinit_mdio:
+	mtk_mdio_cleanup(eth);
 err_free_dev:
-	mtk_cleanup(eth);
+	mtk_free_dev(eth);
+err_deinit_hw:
+	mtk_hw_deinit(eth);
+
 	return err;
 }
 
-- 
1.9.1
