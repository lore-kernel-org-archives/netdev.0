From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net PATCH 1/1] drivers: net: cpsw: dual_emac: fix reducing of rx descriptor during ifdown
Date: Fri, 29 Aug 2014 14:52:25 +0530
Message-ID: <1409304145-26179-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:42220 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751026AbaH2JWc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Aug 2014 05:22:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In Dual EMAC, when both interface are up and while doing ifdown with heavy
traffic then skbs already processed by DMA from that slave emac has to be
requeued as still the other interface is up and running.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 24 ++++++++++++++++++++++--
 1 file changed, 22 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 999fb72..04369cf 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -699,8 +699,27 @@ static void cpsw_rx_handler(void *token, int len, int status)
 	cpsw_dual_emac_src_port_detect(status, priv, ndev, skb);
 
 	if (unlikely(status < 0) || unlikely(!netif_running(ndev))) {
-		/* the interface is going down, skbs are purged */
-		dev_kfree_skb_any(skb);
+		bool ndev_status = false;
+		struct cpsw_slave *slave = priv->slaves;
+		int n;
+
+		if (priv->data.dual_emac) {
+			/* In dual emac mode check for all interfaces */
+			for (n = priv->data.slaves; n; n--, slave++)
+				if (netif_running(slave->ndev))
+					ndev_status = true;
+		}
+
+		if (ndev_status) {
+			/* Though this interface is down, other interface is up
+			 * and running so requeue skb back to cpdma.
+			 */
+			new_skb = skb;
+			goto requeue;
+		} else {
+			/* the interface is going down, skbs are purged */
+			dev_kfree_skb_any(skb);
+		}
 		return;
 	}
 
@@ -717,6 +736,7 @@ static void cpsw_rx_handler(void *token, int len, int status)
 		new_skb = skb;
 	}
 
+requeue:
 	ret = cpdma_chan_submit(priv->rxch, new_skb, new_skb->data,
 			skb_tailroom(new_skb), 0);
 	if (WARN_ON(ret < 0))
-- 
2.1.0
