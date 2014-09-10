From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net PATCH v2 1/1] drivers: net: cpsw: dual_emac: fix reducing of rx descriptor during ifdown
Date: Wed, 10 Sep 2014 16:38:09 +0530
Message-ID: <1410347289-3555-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:44447 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751198AbaIJLIO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Sep 2014 07:08:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In Dual EMAC, when both interface are up and while doing ifdown with heavy
traffic then skbs already processed by DMA from that slave emac has to be
requeued as still the other interface is up and running.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---

Changes from initial version:
* fixed warn issue during suspend/resume by adding aditional check on
  status before requeueing the skb.
* Added more comments in requeue if statement.

---
 drivers/net/ethernet/ti/cpsw.c | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 999fb72..411232f 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -699,6 +699,28 @@ static void cpsw_rx_handler(void *token, int len, int status)
 	cpsw_dual_emac_src_port_detect(status, priv, ndev, skb);
 
 	if (unlikely(status < 0) || unlikely(!netif_running(ndev))) {
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
+		if (ndev_status && (status >= 0)) {
+			/* The packet received is for the interface which
+			 * is already down and the other interface is up
+			 * and running, intead of freeing which results
+			 * in reducing of the number of rx descriptor in
+			 * DMA engine, requeue skb back to cpdma.
+			 */
+			new_skb = skb;
+			goto requeue;
+		}
+
 		/* the interface is going down, skbs are purged */
 		dev_kfree_skb_any(skb);
 		return;
@@ -717,6 +739,7 @@ static void cpsw_rx_handler(void *token, int len, int status)
 		new_skb = skb;
 	}
 
+requeue:
 	ret = cpdma_chan_submit(priv->rxch, new_skb, new_skb->data,
 			skb_tailroom(new_skb), 0);
 	if (WARN_ON(ret < 0))
-- 
2.1.0
