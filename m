From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH v2 4/5] net: ethernet: ti: cpsw: don't duplicate common res in rx handler
Date: Thu, 19 Jan 2017 18:58:26 +0200
Message-ID: <1484845107-30331-5-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1484845107-30331-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: grygorii.strashko@ti.com, netdev@vger.kernel.org,
        linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:36272 "EHLO
        mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753568AbdASRHc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 12:07:32 -0500
Received: by mail-lf0-f47.google.com with SMTP id z134so41331070lff.3
        for <netdev@vger.kernel.org>; Thu, 19 Jan 2017 09:07:04 -0800 (PST)
In-Reply-To: <1484845107-30331-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to duplicate the same function in rx handler to get info
if any interface is running.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c | 40 ++++++++++++++++------------------------
 1 file changed, 16 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index c681d39..1f14afd 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -671,6 +671,18 @@ static void cpsw_intr_disable(struct cpsw_common *cpsw)
 	return;
 }
 
+static int cpsw_get_usage_count(struct cpsw_common *cpsw)
+{
+	u32 i;
+	u32 usage_count = 0;
+
+	for (i = 0; i < cpsw->data.slaves; i++)
+		if (netif_running(cpsw->slaves[i].ndev))
+			usage_count++;
+
+	return usage_count;
+}
+
 static void cpsw_tx_handler(void *token, int len, int status)
 {
 	struct netdev_queue	*txq;
@@ -703,18 +715,10 @@ static void cpsw_rx_handler(void *token, int len, int status)
 	cpsw_dual_emac_src_port_detect(cpsw, status, ndev, skb);
 
 	if (unlikely(status < 0) || unlikely(!netif_running(ndev))) {
-		bool ndev_status = false;
-		struct cpsw_slave *slave = cpsw->slaves;
-		int n;
-
-		if (cpsw->data.dual_emac) {
-			/* In dual emac mode check for all interfaces */
-			for (n = cpsw->data.slaves; n; n--, slave++)
-				if (netif_running(slave->ndev))
-					ndev_status = true;
-		}
-
-		if (ndev_status && (status >= 0)) {
+		/* In dual emac mode check for all interfaces */
+		if (cpsw->data.dual_emac &&
+		    cpsw_get_usage_count(cpsw) &&
+		    (status >= 0)) {
 			/* The packet received is for the interface which
 			 * is already down and the other interface is up
 			 * and running, instead of freeing which results
@@ -1234,18 +1238,6 @@ static void cpsw_get_ethtool_stats(struct net_device *ndev,
 	}
 }
 
-static int cpsw_get_usage_count(struct cpsw_common *cpsw)
-{
-	u32 i;
-	u32 usage_count = 0;
-
-	for (i = 0; i < cpsw->data.slaves; i++)
-		if (netif_running(cpsw->slaves[i].ndev))
-			usage_count++;
-
-	return usage_count;
-}
-
 static inline int cpsw_tx_packet_submit(struct cpsw_priv *priv,
 					struct sk_buff *skb,
 					struct cpdma_chan *txch)
-- 
2.7.4
