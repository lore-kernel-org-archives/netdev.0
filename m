From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: [PATCH net] qlge: Fix qlge_update_hw_vlan_features to handle if interface is down
Date: Fri, 30 Jan 2015 09:56:01 -0200
Message-ID: <10e24de024f81e60ab64a6f0bf9647d27eb40be1.1422618157.git.mleitner@redhat.com>
Cc: harish.patil@qlogic.com, cdupuis@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44285 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752160AbbA3L4J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jan 2015 06:56:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently qlge_update_hw_vlan_features() will always first put the
interface down, then update features and then bring it up again. But it
is possible to hit this code while the adapter is down and this causes a
non-paired call to napi_disable(), which will get stuck.

This patch fixes it by skipping these down/up actions if the interface
is already down.

Fixes: a45adbe8d352 ("qlge: Enhance nested VLAN (Q-in-Q) handling.")
Cc: Harish Patil <harish.patil@qlogic.com>
Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge_main.c | 26 ++++++++++++++++----------
 1 file changed, 16 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index dc0058f9037001b56eb816f0b3d3765089c919cd..8011ef3e7707f783f4caf9f1c16f3d7be3410c4f 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -2351,23 +2351,29 @@ static int qlge_update_hw_vlan_features(struct net_device *ndev,
 {
 	struct ql_adapter *qdev = netdev_priv(ndev);
 	int status = 0;
+	bool need_restart = netif_running(ndev);
 
-	status = ql_adapter_down(qdev);
-	if (status) {
-		netif_err(qdev, link, qdev->ndev,
-			  "Failed to bring down the adapter\n");
-		return status;
+	if (need_restart) {
+		status = ql_adapter_down(qdev);
+		if (status) {
+			netif_err(qdev, link, qdev->ndev,
+				  "Failed to bring down the adapter\n");
+			return status;
+		}
 	}
 
 	/* update the features with resent change */
 	ndev->features = features;
 
-	status = ql_adapter_up(qdev);
-	if (status) {
-		netif_err(qdev, link, qdev->ndev,
-			  "Failed to bring up the adapter\n");
-		return status;
+	if (need_restart) {
+		status = ql_adapter_up(qdev);
+		if (status) {
+			netif_err(qdev, link, qdev->ndev,
+				  "Failed to bring up the adapter\n");
+			return status;
+		}
 	}
+
 	return status;
 }
 
-- 
1.9.3
