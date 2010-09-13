From: Cyril Chemparathy <cyril@ti.com>
Subject: [PATCH 4/9] net: davinci_emac: fix rx error handling
Date: Mon, 13 Sep 2010 14:07:26 -0400
Message-ID: <1284401251-8846-5-git-send-email-cyril@ti.com>
References: <1284401251-8846-1-git-send-email-cyril@ti.com>
Cc: michael.williamson@criticallink.com, caglarakyuz@gmail.com,
	bparrot@ti.com, Cyril Chemparathy <cyril@ti.com>
To: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com,
	linux-omap@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:39557 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754614Ab0IMSHi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Sep 2010 14:07:38 -0400
In-Reply-To: <1284401251-8846-1-git-send-email-cyril@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the following fixes to the emac receive handler:

1. WARN_ON during interface shutdown.
   Although harmless, these complaints were quite disconcerting.  With this
   patch, the receive handler explicitly checks for the shutdown condition, in
   which case is bails quietly.

2. Update rx_error stats on dma receive error

3. Rate limit error messages on buffer allocation failures

Signed-off-by: Cyril Chemparathy <cyril@ti.com>
Signed-off-by: Michael Williamson <michael.williamson@criticallink.com>
Signed-off-by: Caglar Akyuz <caglarakyuz@gmail.com>
---
 drivers/net/davinci_emac.c |   25 +++++++++++++++++++------
 1 files changed, 19 insertions(+), 6 deletions(-)

diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index 363c970..9e866ae 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -1002,13 +1002,22 @@ static void emac_rx_handler(void *token, int len, int status)
 	struct sk_buff		*skb = token;
 	struct net_device	*ndev = skb->dev;
 	struct emac_priv	*priv = netdev_priv(ndev);
+	struct device		*emac_dev = &ndev->dev;
 	int			ret;
 
+	/* free and bail if we are shutting down */
+	if (unlikely(!netif_running(ndev))) {
+		dev_kfree_skb_any(skb);
+		return;
+	}
+
+	/* recycle on recieve error */
 	if (status < 0) {
-		/* error */
+		ndev->stats.rx_errors++;
 		goto recycle;
 	}
 
+	/* feed received packet up the stack */
 	skb_put(skb, len);
 	skb->protocol = eth_type_trans(skb, ndev);
 	netif_receive_skb(skb);
@@ -1017,13 +1026,17 @@ static void emac_rx_handler(void *token, int len, int status)
 
 	/* alloc a new packet for receive */
 	skb = emac_rx_alloc(priv);
+	if (!skb) {
+		if (netif_msg_rx_err(priv) && net_ratelimit())
+			dev_err(emac_dev, "failed rx buffer alloc\n");
+		return;
+	}
 
 recycle:
-	if (skb) {
-		ret = cpdma_chan_submit(priv->rxchan, skb, skb->data,
-					skb_tailroom(skb), GFP_KERNEL);
-		WARN_ON(ret < 0);
-	}
+	ret = cpdma_chan_submit(priv->rxchan, skb, skb->data,
+			skb_tailroom(skb), GFP_KERNEL);
+	if (WARN_ON(ret < 0))
+		dev_kfree_skb_any(skb);
 }
 
 static void emac_tx_handler(void *token, int len, int status)
-- 
1.7.0.4

