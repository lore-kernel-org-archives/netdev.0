From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 3/4] be2net: don't create multiple TXQs in BE2
Date: Mon, 24 Oct 2011 18:15:02 +0530
Message-ID: <84be8116-9e48-4bed-955b-5429006a7756@exht2.ad.emulex.com>
References: <1319460303-25560-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Vasundhara Volam <vasundhara.volam@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:57529 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932239Ab1JXMp0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2011 08:45:26 -0400
In-Reply-To: <1319460303-25560-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Multiple TXQ support is partially broken in BE2. It is fully
supported BE3 onwards and in Lancer.

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   26 ++++++++++++++++----------
 1 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 4ab182f..77ce24b 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1633,6 +1633,17 @@ static void be_tx_queues_destroy(struct be_adapter *adapter)
 	be_queue_free(adapter, q);
 }
 
+static int be_num_txqs_want(struct be_adapter *adapter)
+{
+	if ((num_vfs && adapter->sriov_enabled) ||
+		(adapter->function_mode & 0x400) ||
+		lancer_chip(adapter) || !be_physfn(adapter) ||
+		adapter->generation == BE_GEN2)
+		return 1;
+	else
+		return MAX_TX_QS;
+}
+
 /* One TX event queue is shared by all TX compl qs */
 static int be_tx_queues_create(struct be_adapter *adapter)
 {
@@ -1640,6 +1651,11 @@ static int be_tx_queues_create(struct be_adapter *adapter)
 	struct be_tx_obj *txo;
 	u8 i;
 
+	adapter->num_tx_qs = be_num_txqs_want(adapter);
+	if (adapter->num_tx_qs != MAX_TX_QS)
+		netif_set_real_num_tx_queues(adapter->netdev,
+			adapter->num_tx_qs);
+
 	adapter->tx_eq.max_eqd = 0;
 	adapter->tx_eq.min_eqd = 0;
 	adapter->tx_eq.cur_eqd = 96;
@@ -3180,16 +3196,6 @@ static int be_get_config(struct be_adapter *adapter)
 	if (status)
 		return status;
 
-	if ((num_vfs && adapter->sriov_enabled) ||
-		(adapter->function_mode & 0x400) ||
-		lancer_chip(adapter) || !be_physfn(adapter)) {
-		adapter->num_tx_qs = 1;
-		netif_set_real_num_tx_queues(adapter->netdev,
-			adapter->num_tx_qs);
-	} else {
-		adapter->num_tx_qs = MAX_TX_QS;
-	}
-
 	return 0;
 }
 
-- 
1.7.4
