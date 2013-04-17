From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 5/5] net/cpsw: redo rx skb allocation in rx path
Date: Wed, 17 Apr 2013 23:52:16 +0200
Message-ID: <1366235536-15744-6-git-send-email-bigeasy@linutronix.de>
References: <1366235536-15744-1-git-send-email-bigeasy@linutronix.de>
Cc: netdev@vger.kernel.org, tglx@linutronix.de,
	"David S. Miller" <davem@davemloft.net>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:41225 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966383Ab3DQVwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 17:52:39 -0400
In-Reply-To: <1366235536-15744-1-git-send-email-bigeasy@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case that we run into OOM during the allocation of the new rx-skb we
don't get one and we have one skb less than we used to have. If this
continues to happen then we end up with no rx-skbs at all.
This patch changes the following:
- if we fail to allocate the new skb, then we treat the currently
  completed skb as the new one and so drop the currently received data.
- instead of testing multiple times if the device is gone we rely one
  the status field which is set to -ENOSYS in case the channel is going
  down and incomplete requests are purged.
  cpdma_chan_stop() removes most of the packages with -ENOSYS. The
  currently active packet which is removed has the "tear down" bit set.
  So if that bit is set, we send ENOSYS as well otherwise we pass the
  status bits which are required to figure out which of the two possible
  just finished.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 drivers/net/ethernet/ti/cpsw.c          |   33 ++++++++++++-------------------
 drivers/net/ethernet/ti/davinci_cpdma.c |    7 ++++++-
 2 files changed, 19 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 559b020..f684e9b 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -469,43 +469,36 @@ void cpsw_tx_handler(void *token, int len, int status)
 void cpsw_rx_handler(void *token, int len, int status)
 {
 	struct sk_buff		*skb = token;
+	struct sk_buff		*new_skb;
 	struct net_device	*ndev = skb->dev;
 	struct cpsw_priv	*priv = netdev_priv(ndev);
 	int			ret = 0;
 
 	cpsw_dual_emac_src_port_detect(status, priv, ndev, skb);
 
-	/* free and bail if we are shutting down */
-	if (unlikely(!netif_running(ndev)) ||
-			unlikely(!netif_carrier_ok(ndev))) {
+	if (unlikely(status < 0)) {
+		/* the interface is going down, skbs are purged */
 		dev_kfree_skb_any(skb);
 		return;
 	}
-	if (likely(status >= 0)) {
+
+	new_skb = netdev_alloc_skb_ip_align(ndev, priv->rx_packet_max);
+	if (new_skb) {
 		skb_put(skb, len);
 		cpts_rx_timestamp(priv->cpts, skb);
 		skb->protocol = eth_type_trans(skb, ndev);
 		netif_receive_skb(skb);
 		priv->stats.rx_bytes += len;
 		priv->stats.rx_packets++;
-		skb = NULL;
-	}
-
-	if (unlikely(!netif_running(ndev))) {
-		if (skb)
-			dev_kfree_skb_any(skb);
-		return;
+	} else {
+		priv->stats.rx_dropped++;
+		new_skb = skb;
 	}
 
-	if (likely(!skb)) {
-		skb = netdev_alloc_skb_ip_align(ndev, priv->rx_packet_max);
-		if (WARN_ON(!skb))
-			return;
-
-		ret = cpdma_chan_submit(priv->rxch, skb, skb->data,
-					skb_tailroom(skb), 0);
-	}
-	WARN_ON(ret < 0);
+	ret = cpdma_chan_submit(priv->rxch, new_skb, new_skb->data,
+			skb_tailroom(new_skb), 0);
+	if (WARN_ON(ret < 0))
+		dev_kfree_skb_any(new_skb);
 }
 
 static irqreturn_t cpsw_interrupt(int irq, void *dev_id)
diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index 3cc20e7..6b0a89f 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -776,6 +776,7 @@ static int __cpdma_chan_process(struct cpdma_chan *chan)
 	struct cpdma_ctlr		*ctlr = chan->ctlr;
 	struct cpdma_desc __iomem	*desc;
 	int				status, outlen;
+	int				cb_status = 0;
 	struct cpdma_desc_pool		*pool = ctlr->pool;
 	dma_addr_t			desc_dma;
 	unsigned long			flags;
@@ -811,8 +812,12 @@ static int __cpdma_chan_process(struct cpdma_chan *chan)
 	}
 
 	spin_unlock_irqrestore(&chan->lock, flags);
+	if (unlikely(status & CPDMA_DESC_TD_COMPLETE))
+		cb_status = -ENOSYS;
+	else
+		cb_status = status;
 
-	__cpdma_chan_free(chan, desc, outlen, status);
+	__cpdma_chan_free(chan, desc, outlen, cb_status);
 	return status;
 
 unlock_ret:
-- 
1.7.10.4
