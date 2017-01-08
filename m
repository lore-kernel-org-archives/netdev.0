From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH 4/4] net: ethernet: ti: cpsw: don't duplicate common res in rx handler
Date: Sun,  8 Jan 2017 18:41:03 +0200
Message-ID: <1483893663-15673-5-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1483893663-15673-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org, grygorii.strashko@ti.com,
        linux-kernel@vger.kernel.org,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: netdev@vger.kernel.org, mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:33770 "EHLO
        mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754004AbdAHQlN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2017 11:41:13 -0500
Received: by mail-lf0-f54.google.com with SMTP id k86so81784706lfi.0
        for <netdev@vger.kernel.org>; Sun, 08 Jan 2017 08:41:13 -0800 (PST)
In-Reply-To: <1483893663-15673-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to duplicate the same function in rx handler to get info
if any interface is running.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c | 40 ++++++++++++++++------------------------
 1 file changed, 16 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index daae87f..458298d 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -671,6 +671,18 @@ static void cpsw_intr_disable(struct cpsw_common *cpsw)
 	return;
 }
 
+static int cpsw_common_res_usage_state(struct cpsw_common *cpsw)
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
+		    cpsw_common_res_usage_state(cpsw) &&
+		    (status >= 0)) {
 			/* The packet received is for the interface which
 			 * is already down and the other interface is up
 			 * and running, instead of freeing which results
@@ -1234,18 +1238,6 @@ static void cpsw_get_ethtool_stats(struct net_device *ndev,
 	}
 }
 
-static int cpsw_common_res_usage_state(struct cpsw_common *cpsw)
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
