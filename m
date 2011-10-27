From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net-next-2.6 2/2] be2net: Changing MAC Address of a VF was broken.
Date: Thu, 27 Oct 2011 22:44:05 +0530
Message-ID: <63ed130f-41de-4f75-9c09-a191483c45df@exht2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:6246 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754405Ab1J0Lrl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2011 07:47:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow for MAC Address change of VF(SR-IOV case) on the fly- First add and then 
delete MAC Address to allow for 'out of pool' errors.
When MAC Addr configured from a VM, the MAC on the NIC will aleady have
the supplied MAC,so just copy the supplied MAC to the netdev structure
before returning success to the stack

Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    4 +++
 drivers/net/ethernet/emulex/benet/be_main.c |   28 ++++++++++++++------------
 2 files changed, 19 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 83b8a46..824b8e6 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -688,6 +688,10 @@ int be_cmd_pmac_add(struct be_adapter *adapter, u8 *mac_addr,
 
 err:
 	spin_unlock_bh(&adapter->mcc_lock);
+
+	 if (status == MCC_STATUS_UNAUTHORIZED_REQUEST)
+		status = -EPERM;
+
 	return status;
 }
 
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index d6a232a..2180497 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -229,27 +229,29 @@ static int be_mac_addr_set(struct net_device *netdev, void *p)
 	struct be_adapter *adapter = netdev_priv(netdev);
 	struct sockaddr *addr = p;
 	int status = 0;
+	u8 current_mac[ETH_ALEN];
+	u32 pmac_id = adapter->pmac_id;
 
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
-	/* MAC addr configuration will be done in hardware for VFs
-	 * by their corresponding PFs. Just copy to netdev addr here
-	 */
-	if (!be_physfn(adapter))
-		goto netdev_addr;
-
-	status = be_cmd_pmac_del(adapter, adapter->if_handle,
-				adapter->pmac_id, 0);
+	status = be_cmd_mac_addr_query(adapter, current_mac,
+			MAC_ADDRESS_TYPE_NETWORK, false, adapter->if_handle);
 	if (status)
-		return status;
+		goto err;
 
-	status = be_cmd_pmac_add(adapter, (u8 *)addr->sa_data,
+	if (memcmp(addr->sa_data, current_mac, ETH_ALEN)) {
+		status = be_cmd_pmac_add(adapter, (u8 *)addr->sa_data,
 				adapter->if_handle, &adapter->pmac_id, 0);
-netdev_addr:
-	if (!status)
-		memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
+		if (status)
+			goto err;
 
+		be_cmd_pmac_del(adapter, adapter->if_handle, pmac_id, 0);
+	}
+	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
+	return 0;
+err:
+	dev_err(&adapter->pdev->dev, "MAC %pM set Failed\n", addr->sa_data);
 	return status;
 }
 
-- 
1.5.6.1
