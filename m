From: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Subject: [PATCH net-next 4/6] be2net: Avoid redundant addition of mac address in HW
Date: Wed,  7 Sep 2016 19:57:52 +0530
Message-ID: <20160907142754.13284-5-sriharsha.basavapatna@broadcom.com>
References: <20160907142754.13284-1-sriharsha.basavapatna@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [192.19.245.250] ([192.19.245.250]:51437 "EHLO
        CMRELAYP1.ad.emulex.com" rhost-flags-FAIL-FAIL-OK-FAIL)
        by vger.kernel.org with ESMTP id S935833AbcIGOpz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 10:45:55 -0400
In-Reply-To: <20160907142754.13284-1-sriharsha.basavapatna@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suresh Reddy <Suresh.Reddy@broadcom.com>

If a mac address is added to the uc_list and later the same mac address
is added via ndo_set_mac_address() or vice versa, the driver does not
detect this condition and tries to add it again. This results in a mac
address collision error when the FW rejects it.

Fix this by checking if the given mac address is present in uc_list while
setting the device mac address and vice versa. Similarly skip deletion if
the address is still in use in the other form.

Signed-off-by: Suresh Reddy <Suresh.Reddy@broadcom.com>
Signed-off-by: Sathya Perla <sathya.perla@broadcom.com>
Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 86 ++++++++++++++++++++++-------
 1 file changed, 66 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 95d2fa3..a1c9920 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -269,6 +269,38 @@ void be_cq_notify(struct be_adapter *adapter, u16 qid, bool arm, u16 num_popped)
 	iowrite32(val, adapter->db + DB_CQ_OFFSET);
 }
 
+static int be_dev_mac_add(struct be_adapter *adapter, u8 *mac)
+{
+	int i;
+
+	/* Check if mac has already been added as part of uc-list */
+	for (i = 0; i < adapter->uc_macs; i++) {
+		if (ether_addr_equal((u8 *)&adapter->uc_list[i * ETH_ALEN],
+				     mac)) {
+			/* mac already added, skip addition */
+			adapter->pmac_id[0] = adapter->pmac_id[i + 1];
+			return 0;
+		}
+	}
+
+	return be_cmd_pmac_add(adapter, mac, adapter->if_handle,
+			       &adapter->pmac_id[0], 0);
+}
+
+static void be_dev_mac_del(struct be_adapter *adapter, int pmac_id)
+{
+	int i;
+
+	/* Skip deletion if the programmed mac is
+	 * being used in uc-list
+	 */
+	for (i = 0; i < adapter->uc_macs; i++) {
+		if (adapter->pmac_id[i + 1] == pmac_id)
+			return;
+	}
+	be_cmd_pmac_del(adapter, adapter->if_handle, pmac_id, 0);
+}
+
 static int be_mac_addr_set(struct net_device *netdev, void *p)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
@@ -276,7 +308,7 @@ static int be_mac_addr_set(struct net_device *netdev, void *p)
 	struct sockaddr *addr = p;
 	int status;
 	u8 mac[ETH_ALEN];
-	u32 old_pmac_id = adapter->pmac_id[0], curr_pmac_id = 0;
+	u32 old_pmac_id = adapter->pmac_id[0];
 
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
@@ -297,23 +329,22 @@ static int be_mac_addr_set(struct net_device *netdev, void *p)
 	 * FILTMGMT privilege. This failure is OK, only if the PF programmed
 	 * the MAC for the VF.
 	 */
-	status = be_cmd_pmac_add(adapter, (u8 *)addr->sa_data,
-				 adapter->if_handle, &adapter->pmac_id[0], 0);
+	mutex_lock(&adapter->rx_filter_lock);
+	status = be_dev_mac_add(adapter, (u8 *)addr->sa_data);
 	if (!status) {
-		curr_pmac_id = adapter->pmac_id[0];
 
 		/* Delete the old programmed MAC. This call may fail if the
 		 * old MAC was already deleted by the PF driver.
 		 */
 		if (adapter->pmac_id[0] != old_pmac_id)
-			be_cmd_pmac_del(adapter, adapter->if_handle,
-					old_pmac_id, 0);
+			be_dev_mac_del(adapter, old_pmac_id);
 	}
 
+	mutex_unlock(&adapter->rx_filter_lock);
 	/* Decide if the new MAC is successfully activated only after
 	 * querying the FW
 	 */
-	status = be_cmd_get_active_mac(adapter, curr_pmac_id, mac,
+	status = be_cmd_get_active_mac(adapter, adapter->pmac_id[0], mac,
 				       adapter->if_handle, true, 0);
 	if (status)
 		goto err;
@@ -1628,6 +1659,28 @@ static void be_clear_mc_list(struct be_adapter *adapter)
 	adapter->mc_count = 0;
 }
 
+static int be_uc_mac_add(struct be_adapter *adapter, int uc_idx)
+{
+	if (ether_addr_equal((u8 *)&adapter->uc_list[uc_idx * ETH_ALEN],
+			     adapter->netdev->dev_addr)) {
+		adapter->pmac_id[uc_idx + 1] = adapter->pmac_id[0];
+		return 0;
+	}
+
+	return be_cmd_pmac_add(adapter,
+			       (u8 *)&adapter->uc_list[uc_idx * ETH_ALEN],
+			       adapter->if_handle,
+			       &adapter->pmac_id[uc_idx + 1], 0);
+}
+
+static void be_uc_mac_del(struct be_adapter *adapter, int pmac_id)
+{
+	if (pmac_id == adapter->pmac_id[0])
+		return;
+
+	be_cmd_pmac_del(adapter, adapter->if_handle, pmac_id, 0);
+}
+
 static void be_set_uc_list(struct be_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
@@ -1668,13 +1721,10 @@ static void be_set_uc_list(struct be_adapter *adapter)
 		be_clear_uc_promisc(adapter);
 
 		for (i = 0; i < adapter->uc_macs; i++)
-			be_cmd_pmac_del(adapter, adapter->if_handle,
-					adapter->pmac_id[i + 1], 0);
+			be_uc_mac_del(adapter, adapter->pmac_id[i + 1]);
 
 		for (i = 0; i < curr_uc_macs; i++)
-			be_cmd_pmac_add(adapter, adapter->uc_list[i].mac,
-					adapter->if_handle,
-					&adapter->pmac_id[i + 1], 0);
+			be_uc_mac_add(adapter, i);
 		adapter->uc_macs = curr_uc_macs;
 		adapter->update_uc_list = false;
 	}
@@ -1687,8 +1737,8 @@ static void be_clear_uc_list(struct be_adapter *adapter)
 
 	__dev_uc_unsync(netdev, NULL);
 	for (i = 0; i < adapter->uc_macs; i++)
-		be_cmd_pmac_del(adapter, adapter->if_handle,
-				adapter->pmac_id[i + 1], 0);
+		be_uc_mac_del(adapter, adapter->pmac_id[i + 1]);
+
 	adapter->uc_macs = 0;
 }
 
@@ -3566,9 +3616,7 @@ static void be_rx_qs_destroy(struct be_adapter *adapter)
 
 static void be_disable_if_filters(struct be_adapter *adapter)
 {
-	be_cmd_pmac_del(adapter, adapter->if_handle,
-			adapter->pmac_id[0], 0);
-
+	be_dev_mac_del(adapter, adapter->pmac_id[0]);
 	be_clear_uc_list(adapter);
 	be_clear_mc_list(adapter);
 
@@ -3723,9 +3771,7 @@ static int be_enable_if_filters(struct be_adapter *adapter)
 
 	/* For BE3 VFs, the PF programs the initial MAC address */
 	if (!(BEx_chip(adapter) && be_virtfn(adapter))) {
-		status = be_cmd_pmac_add(adapter, adapter->netdev->dev_addr,
-					 adapter->if_handle,
-					 &adapter->pmac_id[0], 0);
+		status = be_dev_mac_add(adapter, adapter->netdev->dev_addr);
 		if (status)
 			return status;
 	}
-- 
2.10.0.rc2.20.g5b18e70
