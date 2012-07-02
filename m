From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net 2/7] qlge: Stand-up card should not report supporting wol.
Date: Mon,  2 Jul 2012 19:41:49 -0400
Message-ID: <1341272514-5156-3-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1341272514-5156-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:26506 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751502Ab2GBX6h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2012 19:58:37 -0400
In-Reply-To: <1341272514-5156-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c |   46 ++++++++++++++---------
 1 files changed, 28 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c b/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
index 8e2c2a7..98f04d7 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
@@ -388,30 +388,40 @@ static void ql_get_drvinfo(struct net_device *ndev,
 static void ql_get_wol(struct net_device *ndev, struct ethtool_wolinfo *wol)
 {
 	struct ql_adapter *qdev = netdev_priv(ndev);
-	/* What we support. */
-	wol->supported = WAKE_MAGIC;
-	/* What we've currently got set. */
-	wol->wolopts = qdev->wol;
+	unsigned short ssys_dev = qdev->pdev->subsystem_device;
+
+	if (ssys_dev == 0x0068 || ssys_dev == 0x0180) {
+		wol->supported = WAKE_MAGIC;
+		wol->wolopts = qdev->wol;
+	}
 }
 
 static int ql_set_wol(struct net_device *ndev, struct ethtool_wolinfo *wol)
 {
 	struct ql_adapter *qdev = netdev_priv(ndev);
-	int status;
+	unsigned short ssys_dev = qdev->pdev->subsystem_device;
 
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
-	}
+	if (ssys_dev == 0x0068 || ssys_dev == 0x0180) {
+		if (wol->wolopts & ~WAKE_MAGIC)
+			return -EINVAL;
+		qdev->wol = wol->wolopts;
+
+		netif_info(qdev, drv, qdev->ndev,
+				"Set wol option 0x%x\n", qdev->wol);
+		if (!qdev->wol) {
+			u32 wol = 0;
+			int status = 0;
 
+			status = ql_mb_wol_mode(qdev, wol);
+			netif_err(qdev, drv, qdev->ndev,
+			"WOL %s (wol code 0x%x)\n",
+			status == 0 ? "cleared successfully" : "clear failed",
+			wol);
+		}
+	} else {
+		netif_info(qdev, drv, qdev->ndev,
+				"WOL is not supported on stand-up card\n");
+	}
 	return 0;
 }
 
-- 
1.7.1
