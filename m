From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH 3/3] net: fs_enet: make rx_copybreak value configurable
Date: Wed, 24 Aug 2016 12:36:44 +0200 (CEST)
Message-ID: <0609ecd8fa7ecaa99a386e17f47027349cc3fdda.1472033140.git.christophe.leroy@c-s.fr>
References: <cover.1472033140.git.christophe.leroy@c-s.fr>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        netdev@vger.kernel.org
To: Pantelis Antoniou <pantelis.antoniou@gmail.com>,
        Vitaly Bordug <vbordug@ru.mvista.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from pegase1.c-s.fr ([93.17.236.30]:6218 "EHLO pegase1.c-s.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753057AbcHXKjJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 24 Aug 2016 06:39:09 -0400
In-Reply-To: <cover.1472033140.git.christophe.leroy@c-s.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Measurement shows that on a MPC8xx running at 132MHz, the optimal
limit is 112:
* 114 bytes packets are processed in 147 TB ticks with higher copybreak
* 114 bytes packets are processed in 148 TB ticks with lower copybreak
* 128 bytes packets are processed in 154 TB ticks with higher copybreak
* 128 bytes packets are processed in 148 TB ticks with lower copybreak
* 238 bytes packets are processed in 172 TB ticks with higher copybreak
* 238 bytes packets are processed in 148 TB ticks with lower copybreak

However it might be different on other processors
and/or frequencies. So it is useful to make it configurable.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c | 8 +++++---
 include/linux/fs_enet_pd.h                            | 1 -
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
index addcae6..b59bbf8 100644
--- a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
+++ b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
@@ -60,6 +60,10 @@ module_param(fs_enet_debug, int, 0);
 MODULE_PARM_DESC(fs_enet_debug,
 		 "Freescale bitmapped debugging message enable value");
 
+static int rx_copybreak = 240;
+module_param(rx_copybreak, int, S_IRUGO | S_IWUSR);
+MODULE_PARM_DESC(rx_copybreak, "Receive copy threshold");
+
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void fs_enet_netpoll(struct net_device *dev);
 #endif
@@ -84,7 +88,6 @@ static int fs_enet_napi(struct napi_struct *napi, int budget)
 {
 	struct fs_enet_private *fep = container_of(napi, struct fs_enet_private, napi);
 	struct net_device *dev = fep->ndev;
-	const struct fs_platform_info *fpi = fep->fpi;
 	cbd_t __iomem *bdp;
 	struct sk_buff *skb, *skbn;
 	int received = 0;
@@ -232,7 +235,7 @@ static int fs_enet_napi(struct napi_struct *napi, int budget)
 			pkt_len = CBDR_DATLEN(bdp) - 4;	/* remove CRC */
 			fep->stats.rx_bytes += pkt_len + 4;
 
-			if (pkt_len <= fpi->rx_copybreak) {
+			if (pkt_len <= rx_copybreak) {
 				/* +2 to make IP header L1 cache aligned */
 				skbn = netdev_alloc_skb(dev, pkt_len + 2);
 				if (skbn != NULL) {
@@ -905,7 +908,6 @@ static int fs_enet_probe(struct platform_device *ofdev)
 
 	fpi->rx_ring = 32;
 	fpi->tx_ring = 64;
-	fpi->rx_copybreak = 240;
 	fpi->napi_weight = 17;
 	fpi->phy_node = of_parse_phandle(ofdev->dev.of_node, "phy-handle", 0);
 	if (!fpi->phy_node && of_phy_is_fixed_link(ofdev->dev.of_node)) {
diff --git a/include/linux/fs_enet_pd.h b/include/linux/fs_enet_pd.h
index 77d783f..376600e 100644
--- a/include/linux/fs_enet_pd.h
+++ b/include/linux/fs_enet_pd.h
@@ -138,7 +138,6 @@ struct fs_platform_info {
 
 	int rx_ring, tx_ring;	/* number of buffers on rx     */
 	__u8 macaddr[ETH_ALEN];	/* mac address                 */
-	int rx_copybreak;	/* limit we copy small frames  */
 	int napi_weight;	/* NAPI weight                 */
 
 	int use_rmii;		/* use RMII mode 	       */
-- 
2.1.0
