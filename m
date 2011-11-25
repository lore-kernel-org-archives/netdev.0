From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next 2/5] be2net: Fix error recovery paths
Date: Fri, 25 Nov 2011 21:18:06 +0530
Message-ID: <c983ab9b-75ce-44b0-a53c-b9c9716cc527@exht2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:44961 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753267Ab1KYPtK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2011 10:49:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When TX queues are created again after error recovery,
netif_set_real_num_tx_queues() is invoked to update number of real
TX queues created. rtnl lock needs to be held when invoking this routine.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index c6fb7c3..a1b8ebc 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1666,9 +1666,12 @@ static int be_tx_queues_create(struct be_adapter *adapter)
 	u8 i;
 
 	adapter->num_tx_qs = be_num_txqs_want(adapter);
-	if (adapter->num_tx_qs != MAX_TX_QS)
+	if (adapter->num_tx_qs != MAX_TX_QS) {
+		rtnl_lock();
 		netif_set_real_num_tx_queues(adapter->netdev,
 			adapter->num_tx_qs);
+		rtnl_unlock();
+	}
 
 	adapter->tx_eq.max_eqd = 0;
 	adapter->tx_eq.min_eqd = 0;
-- 
1.6.0.2
