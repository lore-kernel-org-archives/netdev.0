From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 2/5] net/cpsw: don't continue if we miss to allocate rx skbs
Date: Tue, 23 Apr 2013 19:31:36 +0200
Message-ID: <1366738299-21285-3-git-send-email-bigeasy@linutronix.de>
References: <1366738299-21285-1-git-send-email-bigeasy@linutronix.de>
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	tglx@linutronix.de,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:36068 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756793Ab3DWRbw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 13:31:52 -0400
In-Reply-To: <1366738299-21285-1-git-send-email-bigeasy@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

if during "ifconfig up" we run out of mem we continue regardless how
many skbs we got. In worst case we have zero RX skbs and can't ever
receive further packets since the RX skbs are never reallocated. If
cpdma_chan_submit() fails we even leak the skb.
This patch changes the behavior here:
If we fail to allocate an skb during bring up we don't continue and
report that error. Same goes for errors from cpdma_chan_submit().
While here I changed to __netdev_alloc_skb_ip_align() so GFP_KERNEL can
be used.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 drivers/net/ethernet/ti/cpsw.c |   35 ++++++++++++++++++++++-------------
 1 file changed, 22 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index e2ba702..29700fb 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -867,6 +867,15 @@ static void cpsw_init_host_port(struct cpsw_priv *priv)
 	}
 }
 
+static void cpsw_slave_stop(struct cpsw_slave *slave, struct cpsw_priv *priv)
+{
+	if (!slave->phy)
+		return;
+	phy_stop(slave->phy);
+	phy_disconnect(slave->phy);
+	slave->phy = NULL;
+}
+
 static int cpsw_ndo_open(struct net_device *ndev)
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
@@ -912,14 +921,16 @@ static int cpsw_ndo_open(struct net_device *ndev)
 			struct sk_buff *skb;
 
 			ret = -ENOMEM;
-			skb = netdev_alloc_skb_ip_align(priv->ndev,
-							priv->rx_packet_max);
+			skb = __netdev_alloc_skb_ip_align(priv->ndev,
+					priv->rx_packet_max, GFP_KERNEL);
 			if (!skb)
-				break;
+				goto err_cleanup;
 			ret = cpdma_chan_submit(priv->rxch, skb, skb->data,
 					skb_tailroom(skb), 0, GFP_KERNEL);
-			if (WARN_ON(ret < 0))
-				break;
+			if (ret < 0) {
+				kfree_skb(skb);
+				goto err_cleanup;
+			}
 		}
 		/* continue even if we didn't manage to submit all
 		 * receive descs
@@ -944,15 +955,13 @@ static int cpsw_ndo_open(struct net_device *ndev)
 	if (priv->data.dual_emac)
 		priv->slaves[priv->emac_port].open_stat = true;
 	return 0;
-}
 
-static void cpsw_slave_stop(struct cpsw_slave *slave, struct cpsw_priv *priv)
-{
-	if (!slave->phy)
-		return;
-	phy_stop(slave->phy);
-	phy_disconnect(slave->phy);
-	slave->phy = NULL;
+err_cleanup:
+	cpdma_ctlr_stop(priv->dma);
+	for_each_slave(priv, cpsw_slave_stop, priv);
+	pm_runtime_put_sync(&priv->pdev->dev);
+	netif_carrier_off(priv->ndev);
+	return ret;
 }
 
 static int cpsw_ndo_stop(struct net_device *ndev)
-- 
1.7.10.4
