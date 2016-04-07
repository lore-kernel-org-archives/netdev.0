From: John Crispin <blogic@openwrt.org>
Subject: [PATCH V2 7/8] net: mediatek: move the pending_work struct to the device generic struct
Date: Thu,  7 Apr 2016 21:26:49 +0200
Message-ID: <1460057210-55786-8-git-send-email-blogic@openwrt.org>
References: <1460057210-55786-1-git-send-email-blogic@openwrt.org>
Cc: Felix Fietkau <nbd@openwrt.org>,
	Matthias Brugger <matthias.bgg@gmail.com>,
	=?UTF-8?q?Sean=20Wang=20=28=E7=8E=8B=E5=BF=97=E4=BA=98=29?=
	<sean.wang@mediatek.com>, netdev@vger.kernel.org,
	linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org,
	John Crispin <blogic@openwrt.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460057210-55786-1-git-send-email-blogic@openwrt.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The worker always touches both netdevs. It is ethernet core and not MAC
specific. We only need one worker, which belongs into the ethernets core
struct.

Signed-off-by: John Crispin <blogic@openwrt.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |   10 ++++------
 drivers/net/ethernet/mediatek/mtk_eth_soc.h |    4 ++--
 2 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 8434355..f9f8851 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -1193,7 +1193,7 @@ static void mtk_tx_timeout(struct net_device *dev)
 	eth->netdev[mac->id]->stats.tx_errors++;
 	netif_err(eth, tx_err, dev,
 		  "transmit timed out\n");
-	schedule_work(&mac->pending_work);
+	schedule_work(&eth->pending_work);
 }
 
 static irqreturn_t mtk_handle_irq(int irq, void *_eth)
@@ -1438,7 +1438,7 @@ static void mtk_pending_work(struct work_struct *work)
 
 	/* stop all devices to make sure that dma is properly shut down */
 	for (i = 0; i < MTK_MAC_COUNT; i++) {
-		if (!netif_oper_up(eth->netdev[i]))
+		if (!eth->netdev[i])
 			continue;
 		mtk_stop(eth->netdev[i]);
 		__set_bit(i, &restart);
@@ -1463,15 +1463,13 @@ static int mtk_cleanup(struct mtk_eth *eth)
 	int i;
 
 	for (i = 0; i < MTK_MAC_COUNT; i++) {
-		struct mtk_mac *mac = netdev_priv(eth->netdev[i]);
-
 		if (!eth->netdev[i])
 			continue;
 
 		unregister_netdev(eth->netdev[i]);
 		free_netdev(eth->netdev[i]);
-		cancel_work_sync(&mac->pending_work);
 	}
+	cancel_work_sync(&eth->pending_work);
 
 	return 0;
 }
@@ -1659,7 +1657,6 @@ static int mtk_add_mac(struct mtk_eth *eth, struct device_node *np)
 	mac->id = id;
 	mac->hw = eth;
 	mac->of_node = np;
-	INIT_WORK(&mac->pending_work, mtk_pending_work);
 
 	mac->hw_stats = devm_kzalloc(eth->dev,
 				     sizeof(*mac->hw_stats),
@@ -1761,6 +1758,7 @@ static int mtk_probe(struct platform_device *pdev)
 
 	eth->dev = &pdev->dev;
 	eth->msg_enable = netif_msg_init(mtk_msg_level, MTK_DEFAULT_MSG_ENABLE);
+	INIT_WORK(&eth->pending_work, mtk_pending_work);
 
 	err = mtk_hw_init(eth);
 	if (err)
diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
index 48a5292..eed626d 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.h
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
@@ -363,6 +363,7 @@ struct mtk_rx_ring {
  * @clk_gp1:		The gmac1 clock
  * @clk_gp2:		The gmac2 clock
  * @mii_bus:		If there is a bus we need to create an instance for it
+ * @pending_work:	The workqueue used to reset the dma ring
  */
 
 struct mtk_eth {
@@ -389,6 +390,7 @@ struct mtk_eth {
 	struct clk			*clk_gp1;
 	struct clk			*clk_gp2;
 	struct mii_bus			*mii_bus;
+	struct work_struct		pending_work;
 };
 
 /* struct mtk_mac -	the structure that holds the info about the MACs of the
@@ -398,7 +400,6 @@ struct mtk_eth {
  * @hw:			Backpointer to our main datastruture
  * @hw_stats:		Packet statistics counter
  * @phy_dev:		The attached PHY if available
- * @pending_work:	The workqueue used to reset the dma ring
  */
 struct mtk_mac {
 	int				id;
@@ -406,7 +407,6 @@ struct mtk_mac {
 	struct mtk_eth			*hw;
 	struct mtk_hw_stats		*hw_stats;
 	struct phy_device		*phy_dev;
-	struct work_struct		pending_work;
 };
 
 /* the struct describing the SoC. these are declared in the soc_xyz.c files */
-- 
1.7.10.4
