From: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Subject: [PATCH net-next 1/8] be2net: return error status from be_set_phys_id()
Date: Tue,  2 Feb 2016 15:50:28 +0530
Message-ID: <1454408435-11575-2-git-send-email-sriharsha.basavapatna@broadcom.com>
References: <1454408435-11575-1-git-send-email-sriharsha.basavapatna@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:63466 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754116AbcBBKj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 05:39:27 -0500
In-Reply-To: <1454408435-11575-1-git-send-email-sriharsha.basavapatna@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suresh Reddy <suresh.reddy@broadcom.com>

be_set_phys_id() returns 0 to ethtool when the command fails in the FW.

This patch fixes the set_phys_id() to return -EIO in case the FW cmd fails.

Signed-off-by: Suresh Reddy <suresh.reddy@broadcom.com>
Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
---
 drivers/net/ethernet/emulex/benet/be_ethtool.c | 23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index a19ac44..2ff6916 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -720,29 +720,32 @@ static int be_set_phys_id(struct net_device *netdev,
 			  enum ethtool_phys_id_state state)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
+	int status = 0;
 
 	switch (state) {
 	case ETHTOOL_ID_ACTIVE:
-		be_cmd_get_beacon_state(adapter, adapter->hba_port_num,
-					&adapter->beacon_state);
-		return 1;	/* cycle on/off once per second */
+		status = be_cmd_get_beacon_state(adapter, adapter->hba_port_num,
+						 &adapter->beacon_state);
+		if (status)
+			return be_cmd_status(status);
+		return 1;       /* cycle on/off once per second */
 
 	case ETHTOOL_ID_ON:
-		be_cmd_set_beacon_state(adapter, adapter->hba_port_num, 0, 0,
-					BEACON_STATE_ENABLED);
+		status = be_cmd_set_beacon_state(adapter, adapter->hba_port_num,
+						 0, 0, BEACON_STATE_ENABLED);
 		break;
 
 	case ETHTOOL_ID_OFF:
-		be_cmd_set_beacon_state(adapter, adapter->hba_port_num, 0, 0,
-					BEACON_STATE_DISABLED);
+		status = be_cmd_set_beacon_state(adapter, adapter->hba_port_num,
+						 0, 0, BEACON_STATE_DISABLED);
 		break;
 
 	case ETHTOOL_ID_INACTIVE:
-		be_cmd_set_beacon_state(adapter, adapter->hba_port_num, 0, 0,
-					adapter->beacon_state);
+		status = be_cmd_set_beacon_state(adapter, adapter->hba_port_num,
+						 0, 0, adapter->beacon_state);
 	}
 
-	return 0;
+	return be_cmd_status(status);
 }
 
 static int be_set_dump(struct net_device *netdev, struct ethtool_dump *dump)
-- 
2.3.0.rc2
