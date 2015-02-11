From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 1/1] qlcnic: Delete existing multicast MAC list before adding new
Date: Wed, 11 Feb 2015 09:45:24 -0500
Message-ID: <1423665924-4403-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-GELinuxNICDev@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:47687 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751878AbbBKPYg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2015 10:24:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Driver keeps adding multicast addresses without deleting removed MACs and
worrying about adapters filter limit. This results into actual count of programmed
multicast addresses get accumulated over the time and overruns the adapter's
filter limit without putting device in ACCEPT_ALL_MULTI mode. This causes
newly added multicast traffic to fail after the sequence of addition - deletion
in certain pattern.

This issue is seen only when netdev's mcast list count is less than adapters
mcast filter limit.

e.g. If adapters multicast filter limit is 38 per function
     then following sequence would result in multicast traffic failure for
     newly added MACs.
     - add less than 38 multicast MACs
     - remove previously added multicast MACs
     - add new multicast MACs (less than 38)

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
Hi Dave,

please apply this patch to net.

Thanks,
Shahed
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |   11 ++++++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     |   34 +++++++++++++++++---
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   |   19 +++++++----
 3 files changed, 51 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index e56c1bb..fa43176 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -848,10 +848,17 @@ struct qlcnic_cardrsp_tx_ctx {
 #define QLCNIC_MAC_VLAN_ADD	3
 #define QLCNIC_MAC_VLAN_DEL	4
 
+enum qlcnic_mac_type {
+	QLCNIC_UNICAST_MAC,
+	QLCNIC_MULTICAST_MAC,
+	QLCNIC_BROADCAST_MAC,
+};
+
 struct qlcnic_mac_vlan_list {
 	struct list_head list;
 	uint8_t mac_addr[ETH_ALEN+2];
 	u16 vlan_id;
+	enum qlcnic_mac_type mac_type;
 };
 
 /* MAC Learn */
@@ -1615,7 +1622,9 @@ void qlcnic_watchdog_task(struct work_struct *work);
 void qlcnic_post_rx_buffers(struct qlcnic_adapter *adapter,
 		struct qlcnic_host_rds_ring *rds_ring, u8 ring_id);
 void qlcnic_set_multi(struct net_device *netdev);
-int qlcnic_nic_add_mac(struct qlcnic_adapter *, const u8 *, u16);
+void qlcnic_flush_mcast_mac(struct qlcnic_adapter *);
+int qlcnic_nic_add_mac(struct qlcnic_adapter *, const u8 *, u16,
+		       enum qlcnic_mac_type);
 int qlcnic_nic_del_mac(struct qlcnic_adapter *, const u8 *);
 void qlcnic_82xx_free_mac_list(struct qlcnic_adapter *adapter);
 int qlcnic_82xx_read_phys_port_id(struct qlcnic_adapter *);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index 69b46c0..3e0f705 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -487,7 +487,8 @@ int qlcnic_nic_del_mac(struct qlcnic_adapter *adapter, const u8 *addr)
 	return err;
 }
 
-int qlcnic_nic_add_mac(struct qlcnic_adapter *adapter, const u8 *addr, u16 vlan)
+int qlcnic_nic_add_mac(struct qlcnic_adapter *adapter, const u8 *addr, u16 vlan,
+		       enum qlcnic_mac_type mac_type)
 {
 	struct qlcnic_mac_vlan_list *cur;
 	struct list_head *head;
@@ -513,10 +514,29 @@ int qlcnic_nic_add_mac(struct qlcnic_adapter *adapter, const u8 *addr, u16 vlan)
 	}
 
 	cur->vlan_id = vlan;
+	cur->mac_type = mac_type;
+
 	list_add_tail(&cur->list, &adapter->mac_list);
 	return 0;
 }
 
+void qlcnic_flush_mcast_mac(struct qlcnic_adapter *adapter)
+{
+	struct qlcnic_mac_vlan_list *cur;
+	struct list_head *head, *tmp;
+
+	list_for_each_safe(head, tmp, &adapter->mac_list) {
+		cur = list_entry(head, struct qlcnic_mac_vlan_list, list);
+		if (cur->mac_type != QLCNIC_MULTICAST_MAC)
+			continue;
+
+		qlcnic_sre_macaddr_change(adapter, cur->mac_addr,
+					  cur->vlan_id, QLCNIC_MAC_DEL);
+		list_del(&cur->list);
+		kfree(cur);
+	}
+}
+
 static void __qlcnic_set_multi(struct net_device *netdev, u16 vlan)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
@@ -530,8 +550,9 @@ static void __qlcnic_set_multi(struct net_device *netdev, u16 vlan)
 	if (!test_bit(__QLCNIC_FW_ATTACHED, &adapter->state))
 		return;
 
-	qlcnic_nic_add_mac(adapter, adapter->mac_addr, vlan);
-	qlcnic_nic_add_mac(adapter, bcast_addr, vlan);
+	qlcnic_nic_add_mac(adapter, adapter->mac_addr, vlan,
+			   QLCNIC_UNICAST_MAC);
+	qlcnic_nic_add_mac(adapter, bcast_addr, vlan, QLCNIC_BROADCAST_MAC);
 
 	if (netdev->flags & IFF_PROMISC) {
 		if (!(adapter->flags & QLCNIC_PROMISC_DISABLED))
@@ -540,8 +561,10 @@ static void __qlcnic_set_multi(struct net_device *netdev, u16 vlan)
 		   (netdev_mc_count(netdev) > ahw->max_mc_count)) {
 		mode = VPORT_MISS_MODE_ACCEPT_MULTI;
 	} else if (!netdev_mc_empty(netdev)) {
+		qlcnic_flush_mcast_mac(adapter);
 		netdev_for_each_mc_addr(ha, netdev)
-			qlcnic_nic_add_mac(adapter, ha->addr, vlan);
+			qlcnic_nic_add_mac(adapter, ha->addr, vlan,
+					   QLCNIC_MULTICAST_MAC);
 	}
 
 	/* configure unicast MAC address, if there is not sufficient space
@@ -551,7 +574,8 @@ static void __qlcnic_set_multi(struct net_device *netdev, u16 vlan)
 		mode = VPORT_MISS_MODE_ACCEPT_ALL;
 	} else if (!netdev_uc_empty(netdev)) {
 		netdev_for_each_uc_addr(ha, netdev)
-			qlcnic_nic_add_mac(adapter, ha->addr, vlan);
+			qlcnic_nic_add_mac(adapter, ha->addr, vlan,
+					   QLCNIC_UNICAST_MAC);
 	}
 
 	if (mode == VPORT_MISS_MODE_ACCEPT_ALL &&
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
index 1659c80..e631246 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
@@ -1489,7 +1489,8 @@ out:
 	return ret;
 }
 
-static void qlcnic_vf_add_mc_list(struct net_device *netdev, const u8 *mac)
+static void qlcnic_vf_add_mc_list(struct net_device *netdev, const u8 *mac,
+				  enum qlcnic_mac_type mac_type)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_sriov *sriov = adapter->ahw->sriov;
@@ -1500,17 +1501,18 @@ static void qlcnic_vf_add_mc_list(struct net_device *netdev, const u8 *mac)
 	vf = &adapter->ahw->sriov->vf_info[0];
 
 	if (!qlcnic_sriov_check_any_vlan(vf)) {
-		qlcnic_nic_add_mac(adapter, mac, 0);
+		qlcnic_nic_add_mac(adapter, mac, 0, mac_type);
 	} else {
 		spin_lock(&vf->vlan_list_lock);
 		for (i = 0; i < sriov->num_allowed_vlans; i++) {
 			vlan_id = vf->sriov_vlans[i];
 			if (vlan_id)
-				qlcnic_nic_add_mac(adapter, mac, vlan_id);
+				qlcnic_nic_add_mac(adapter, mac, vlan_id,
+						   mac_type);
 		}
 		spin_unlock(&vf->vlan_list_lock);
 		if (qlcnic_84xx_check(adapter))
-			qlcnic_nic_add_mac(adapter, mac, 0);
+			qlcnic_nic_add_mac(adapter, mac, 0, mac_type);
 	}
 }
 
@@ -1549,10 +1551,12 @@ void qlcnic_sriov_vf_set_multi(struct net_device *netdev)
 		   (netdev_mc_count(netdev) > ahw->max_mc_count)) {
 		mode = VPORT_MISS_MODE_ACCEPT_MULTI;
 	} else {
-		qlcnic_vf_add_mc_list(netdev, bcast_addr);
+		qlcnic_vf_add_mc_list(netdev, bcast_addr, QLCNIC_BROADCAST_MAC);
 		if (!netdev_mc_empty(netdev)) {
+			qlcnic_flush_mcast_mac(adapter);
 			netdev_for_each_mc_addr(ha, netdev)
-				qlcnic_vf_add_mc_list(netdev, ha->addr);
+				qlcnic_vf_add_mc_list(netdev, ha->addr,
+						      QLCNIC_MULTICAST_MAC);
 		}
 	}
 
@@ -1563,7 +1567,8 @@ void qlcnic_sriov_vf_set_multi(struct net_device *netdev)
 		mode = VPORT_MISS_MODE_ACCEPT_ALL;
 	} else if (!netdev_uc_empty(netdev)) {
 		netdev_for_each_uc_addr(ha, netdev)
-			qlcnic_vf_add_mc_list(netdev, ha->addr);
+			qlcnic_vf_add_mc_list(netdev, ha->addr,
+					      QLCNIC_UNICAST_MAC);
 	}
 
 	if (adapter->pdev->is_virtfn) {
-- 
1.5.6
