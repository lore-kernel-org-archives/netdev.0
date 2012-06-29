From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net-next 2/6] qlge: Stand-up card should not report supporting wol.
Date: Fri, 29 Jun 2012 14:24:46 -0400
Message-ID: <1340994290-28832-3-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1340994290-28832-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, Ron@linux-zupk.site,
	"Mercer <ron.mercer"@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:30113 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S932072Ab2F2Sln (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2012 14:41:43 -0400
In-Reply-To: <1340994290-28832-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c |   43 ++++++++++++++--------
 1 files changed, 27 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c b/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
index 8e2c2a7..81672f5 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
@@ -388,10 +388,14 @@ static void ql_get_drvinfo(struct net_device *ndev,
 static void ql_get_wol(struct net_device *ndev, struct ethtool_wolinfo *wol)
 {
 	struct ql_adapter *qdev = netdev_priv(ndev);
-	/* What we support. */
-	wol->supported = WAKE_MAGIC;
-	/* What we've currently got set. */
-	wol->wolopts = qdev->wol;
+
+	if (qdev->pdev->subsystem_device == 0x0068 ||
+			qdev->pdev->subsystem_device == 0x0180) {
+		/* What we support. */
+		wol->supported = WAKE_MAGIC;
+		/* What we've currently got set. */
+		wol->wolopts = qdev->wol;
+	}
 }
 
 static int ql_set_wol(struct net_device *ndev, struct ethtool_wolinfo *wol)
@@ -399,19 +403,26 @@ static int ql_set_wol(struct net_device *ndev, struct ethtool_wolinfo *wol)
 	struct ql_adapter *qdev = netdev_priv(ndev);
 	int status;
 
-	if (wol->wolopts & ~WAKE_MAGIC)
-		return -EINVAL;
-	qdev->wol = wol->wolopts;
-
-	netif_info(qdev, drv, qdev->ndev, "Set wol option 0x%x\n", qdev->wol);
-	if (!qdev->wol) {
-		u32 wol = 0;
-		status = ql_mb_wol_mode(qdev, wol);
-		netif_err(qdev, drv, qdev->ndev, "WOL %s (wol code 0x%x)\n",
-			  status == 0 ? "cleared successfully" : "clear failed",
-			  wol);
+	if (qdev->pdev->subsystem_device == 0x0068 ||
+			qdev->pdev->subsystem_device == 0x0180) {
+		if (wol->wolopts & ~WAKE_MAGIC)
+			return -EINVAL;
+		qdev->wol = wol->wolopts;
+
+		netif_info(qdev, drv, qdev->ndev,
+				"Set wol option 0x%x\n", qdev->wol);
+		if (!qdev->wol) {
+			u32 wol = 0;
+			status = ql_mb_wol_mode(qdev, wol);
+			netif_err(qdev, drv, qdev->ndev,
+			"WOL %s (wol code 0x%x)\n",
+			status == 0 ? "cleared successfully" : "clear failed",
+			wol);
+		}
+	} else {
+		netif_info(qdev, drv, qdev->ndev,
+				"WOL is not supported on stand-up card\n");
 	}
-
 	return 0;
 }
 
-- 
1.7.1
