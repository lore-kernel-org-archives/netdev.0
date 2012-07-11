From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net-next 3/9] qlge: Fix ethtool WOL calls to operate only on devices that support WOL.
Date: Tue, 10 Jul 2012 20:57:33 -0400
Message-ID: <1341968259-18931-4-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1341968259-18931-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:45382 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752646Ab2GKBOh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2012 21:14:37 -0400
In-Reply-To: <1341968259-18931-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge.h         |    2 ++
 drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c |   20 ++++++++++++++++----
 2 files changed, 18 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge.h b/drivers/net/ethernet/qlogic/qlge/qlge.h
index 6e7050c..ae7dddc 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge.h
+++ b/drivers/net/ethernet/qlogic/qlge/qlge.h
@@ -25,6 +25,8 @@
 #define QLGE_VENDOR_ID    0x1077
 #define QLGE_DEVICE_ID_8012	0x8012
 #define QLGE_DEVICE_ID_8000	0x8000
+#define QLGE_MEZZ_SSYS_ID_068	0x0068
+#define QLGE_MEZZ_SSYS_ID_180	0x0180
 #define MAX_CPUS 8
 #define MAX_TX_RINGS MAX_CPUS
 #define MAX_RX_RINGS ((MAX_CPUS * 2) + 1)
diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c b/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
index 8e2c2a7..c2adfa2 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
@@ -388,17 +388,29 @@ static void ql_get_drvinfo(struct net_device *ndev,
 static void ql_get_wol(struct net_device *ndev, struct ethtool_wolinfo *wol)
 {
 	struct ql_adapter *qdev = netdev_priv(ndev);
-	/* What we support. */
-	wol->supported = WAKE_MAGIC;
-	/* What we've currently got set. */
-	wol->wolopts = qdev->wol;
+	unsigned short ssys_dev = qdev->pdev->subsystem_device;
+
+	/* WOL is only supported for mezz card. */
+	if (ssys_dev == QLGE_MEZZ_SSYS_ID_068 ||
+			ssys_dev == QLGE_MEZZ_SSYS_ID_180) {
+		wol->supported = WAKE_MAGIC;
+		wol->wolopts = qdev->wol;
+	}
 }
 
 static int ql_set_wol(struct net_device *ndev, struct ethtool_wolinfo *wol)
 {
 	struct ql_adapter *qdev = netdev_priv(ndev);
 	int status;
+	unsigned short ssys_dev = qdev->pdev->subsystem_device;
 
+	/* WOL is only supported for mezz card. */
+	if (ssys_dev != QLGE_MEZZ_SSYS_ID_068 ||
+			ssys_dev != QLGE_MEZZ_SSYS_ID_180) {
+		netif_info(qdev, drv, qdev->ndev,
+				"WOL is only supported for mezz card\n");
+		return -EOPNOTSUPP;
+	}
 	if (wol->wolopts & ~WAKE_MAGIC)
 		return -EINVAL;
 	qdev->wol = wol->wolopts;
-- 
1.7.1
