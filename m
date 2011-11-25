From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next 5/5] be2net: Fix non utilization of RX queues
Date: Fri, 25 Nov 2011 21:18:53 +0530
Message-ID: <42d96290-6e47-49e4-8a11-38914e4725fe@exht2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:44971 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753928Ab1KYPtf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2011 10:49:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When non power of two MSIX vectors are given to driver, some RX queues
are not utilized. Program RSS table in such a way that all queues
are utilized.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   16 ++++++++++------
 1 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 66429ea..7236280 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2312,8 +2312,8 @@ static int be_close(struct net_device *netdev)
 static int be_rx_queues_setup(struct be_adapter *adapter)
 {
 	struct be_rx_obj *rxo;
-	int rc, i;
-	u8 rsstable[MAX_RSS_QS];
+	int rc, i, j;
+	u8 rsstable[128];
 
 	for_all_rx_queues(adapter, rxo, i) {
 		rc = be_cmd_rxq_create(adapter, &rxo->q, rxo->cq.id,
@@ -2325,11 +2325,15 @@ static int be_rx_queues_setup(struct be_adapter *adapter)
 	}
 
 	if (be_multi_rxq(adapter)) {
-		for_all_rss_queues(adapter, rxo, i)
-			rsstable[i] = rxo->rss_id;
+		for (j = 0; j < 128; j += adapter->num_rx_qs - 1) {
+			for_all_rss_queues(adapter, rxo, i) {
+				if ((j + i) >= 128)
+					break;
+				rsstable[j + i] = rxo->rss_id;
+			}
+		}
+		rc = be_cmd_rss_config(adapter, rsstable, 128);
 
-		rc = be_cmd_rss_config(adapter, rsstable,
-			adapter->num_rx_qs - 1);
 		if (rc)
 			return rc;
 	}
-- 
1.6.0.2
