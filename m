From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net 2/3] be2net: avoid napi_disable() when it has not been enabled
Date: Thu, 2 May 2013 19:06:55 +0530
Message-ID: <38c3abc5-37e6-4055-aa06-2e9b4e4d9485@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Somnath Kotur <somnath.kotur@emulex.com>,
	Kalesh AP <kalesh.purayil@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:18895 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759396Ab3EBNiI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 May 2013 09:38:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When RQ creation fails in be_open(), driver jumps to be_close() where
napi_disable() is done without a prior napi_enable(); leading to a hang.
This change is needed as there is no way to see if napi is enable/disabled.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |    1 +
 drivers/net/ethernet/emulex/benet/be_main.c |    8 ++++++--
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 362efec..bdeb866 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -326,6 +326,7 @@ enum vf_state {
 
 #define BE_FLAGS_LINK_STATUS_INIT		1
 #define BE_FLAGS_WORKER_SCHEDULED		(1 << 3)
+#define BE_FLAGS_NAPI_ENABLED			(1 << 9)
 #define BE_UC_PMAC_COUNT		30
 #define BE_VF_UC_PMAC_COUNT		2
 #define BE_FLAGS_QNQ_ASYNC_EVT_RCVD		(1 << 11)
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 5544354..31d5982 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2526,8 +2526,11 @@ static int be_close(struct net_device *netdev)
 	if (!lancer_chip(adapter))
 		be_intr_set(adapter, false);
 
-	for_all_evt_queues(adapter, eqo, i)
-		napi_disable(&eqo->napi);
+	if (adapter->flags & BE_FLAGS_NAPI_ENABLED) {
+		for_all_evt_queues(adapter, eqo, i)
+			napi_disable(&eqo->napi);
+		adapter->flags &= ~BE_FLAGS_NAPI_ENABLED;
+	}
 
 	be_async_mcc_disable(adapter);
 
@@ -2628,6 +2631,7 @@ static int be_open(struct net_device *netdev)
 		napi_enable(&eqo->napi);
 		be_eq_notify(adapter, eqo->q.id, true, false, 0);
 	}
+	adapter->flags |= BE_FLAGS_NAPI_ENABLED;
 
 	status = be_cmd_link_status_query(adapter, NULL, &link_status, 0);
 	if (!status)
-- 
1.6.0.2
