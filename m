From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6 v2] ftmac100: use GFP_ATOMIC allocations where
 needed
Date: Mon, 14 Mar 2011 15:26:31 +0100
Message-ID: <1300112791.3423.31.camel@edumazet-laptop>
References: <1299744517-1896-1-git-send-email-ratbert.chuang@gmail.com>
	 <1300047388.2761.48.camel@edumazet-laptop>
	 <1300048002.2761.53.camel@edumazet-laptop>
	 <1300048193.2761.55.camel@edumazet-laptop>
	 <AANLkTi=grwkfYpBFJEyQHXbFaTov5Tc+tAR2ebzw0Bht@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Po-Yu Chuang <ratbert@faraday-tech.com>
To: Po-Yu Chuang <ratbert.chuang@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=grwkfYpBFJEyQHXbFaTov5Tc+tAR2ebzw0Bht@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When running in softirq context, we should use GFP_ATOMIC allocations
instead of GFP_KERNEL ones.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Tested-by: Po-Yu Chuang <ratbert@faraday-tech.com>
Acked-by: Po-Yu Chuang <ratbert@faraday-tech.com>
---
v2: fixed a typo
 drivers/net/ftmac100.c |   12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ftmac100.c b/drivers/net/ftmac100.c
index df70368..1d6f4b8 100644
--- a/drivers/net/ftmac100.c
+++ b/drivers/net/ftmac100.c
@@ -80,7 +80,8 @@ struct ftmac100 {
 	struct mii_if_info mii;
 };
 
-static int ftmac100_alloc_rx_page(struct ftmac100 *priv, struct ftmac100_rxdes *rxdes);
+static int ftmac100_alloc_rx_page(struct ftmac100 *priv,
+				  struct ftmac100_rxdes *rxdes, gfp_t gfp);
 
 /******************************************************************************
  * internal functions (hardware register access)
@@ -441,7 +442,7 @@ static bool ftmac100_rx_packet(struct ftmac100 *priv, int *processed)
 	skb->truesize += length;
 	__pskb_pull_tail(skb, min(length, 64));
 
-	ftmac100_alloc_rx_page(priv, rxdes);
+	ftmac100_alloc_rx_page(priv, rxdes, GFP_ATOMIC);
 
 	ftmac100_rx_pointer_advance(priv);
 
@@ -659,13 +660,14 @@ static int ftmac100_xmit(struct ftmac100 *priv, struct sk_buff *skb,
 /******************************************************************************
  * internal functions (buffer)
  *****************************************************************************/
-static int ftmac100_alloc_rx_page(struct ftmac100 *priv, struct ftmac100_rxdes *rxdes)
+static int ftmac100_alloc_rx_page(struct ftmac100 *priv,
+				  struct ftmac100_rxdes *rxdes, gfp_t gfp)
 {
 	struct net_device *netdev = priv->netdev;
 	struct page *page;
 	dma_addr_t map;
 
-	page = alloc_page(GFP_KERNEL);
+	page = alloc_page(gfp);
 	if (!page) {
 		if (net_ratelimit())
 			netdev_err(netdev, "failed to allocate rx page\n");
@@ -736,7 +738,7 @@ static int ftmac100_alloc_buffers(struct ftmac100 *priv)
 	for (i = 0; i < RX_QUEUE_ENTRIES; i++) {
 		struct ftmac100_rxdes *rxdes = &priv->descs->rxdes[i];
 
-		if (ftmac100_alloc_rx_page(priv, rxdes))
+		if (ftmac100_alloc_rx_page(priv, rxdes, GFP_KERNEL))
 			goto err;
 	}
 
