From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH v2 12/14] net: ethernet: ti: cpsw: fix int dbg message
Date: Sat,  6 Aug 2016 13:48:42 +0300
Message-ID: <1470480524-6851-13-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1470480524-6851-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org,
	dlide@ti.com, Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: netdev@vger.kernel.org, mugunthanvnm@ti.com,
	grygorii.strashko@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f44.google.com ([209.85.215.44]:36025 "EHLO
	mail-lf0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751665AbcHFULT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Aug 2016 16:11:19 -0400
Received: by mail-lf0-f44.google.com with SMTP id g62so223798466lfe.3
        for <netdev@vger.kernel.org>; Sat, 06 Aug 2016 13:11:19 -0700 (PDT)
In-Reply-To: <1470480524-6851-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While poll handlers there is no possibility to figure out
which network device is handling packets, as cpdma channels
are common for both network devices in dual_emac mode. Currently,
the messages are printed only for one device, in fact, there is two.
So, better to print integrated num_tx value for both devices if
any of them is allowed to.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c | 36 ++++++++++++++++++++++++++++++++++--
 1 file changed, 34 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 29ff489..395531d 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -378,6 +378,7 @@ struct cpsw_common {
 	bool				rx_irq_disabled;
 	bool				tx_irq_disabled;
 	u32 irqs_table[IRQ_NUM];
+	int				intr_dbg_msg;
 };
 
 struct cpsw_priv {
@@ -802,7 +803,9 @@ static int cpsw_tx_poll(struct napi_struct *napi_tx, int budget)
 		}
 	}
 
-	cpsw_dbg(priv, intr, "poll %d tx pkts\n", num_tx);
+	if (cpsw->intr_dbg_msg && net_ratelimit())
+		dev_dbg(cpsw->dev, "poll %d tx pkts\n", num_tx);
+
 	return num_tx;
 }
 
@@ -822,7 +825,9 @@ static int cpsw_rx_poll(struct napi_struct *napi_rx, int budget)
 		}
 	}
 
-	cpsw_dbg(priv, intr, "poll %d rx pkts\n", num_rx);
+	if (cpsw->intr_dbg_msg && net_ratelimit())
+		dev_dbg(cpsw->dev, "poll %d tx pkts\n", num_rx);
+
 	return num_rx;
 }
 
@@ -1848,8 +1853,35 @@ static u32 cpsw_get_msglevel(struct net_device *ndev)
 
 static void cpsw_set_msglevel(struct net_device *ndev, u32 value)
 {
+	int i;
+	struct cpsw_priv *sl_priv;
 	struct cpsw_priv *priv = netdev_priv(ndev);
+	struct cpsw_common *cpsw = priv->cpsw;
+
 	priv->msg_enable = value;
+
+	/* There is no possibility to at napi poll level
+	 * to know which netdev is handled, so enable
+	 * common dbg msg print if any interface is enabled to
+	 */
+	cpsw->intr_dbg_msg = 0;
+	if (!cpsw->data.dual_emac) {
+		if (netif_msg_intr(priv))
+			cpsw->intr_dbg_msg = 1;
+		return;
+	}
+
+	for (i = 0; i < cpsw->data.slaves; i++) {
+		ndev = netdev_priv(cpsw->slaves[i].ndev);
+		if (!ndev)
+			continue;
+
+		sl_priv = netdev_priv(ndev);
+		if (netif_msg_intr(sl_priv)) {
+			cpsw->intr_dbg_msg = 1;
+			break;
+		}
+	}
 }
 
 static int cpsw_get_ts_info(struct net_device *ndev,
-- 
1.9.1
