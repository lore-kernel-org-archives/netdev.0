From: Amit Kumar Salecha <amit@netxen.com>
Subject: [net-2.6 PATCH 3/3] netxen : fix BOND_MODE_TLB/ALB mode.
Date: Sat, 21 Nov 2009 00:08:57 -0800
Message-ID: <1258790937-19100-1-git-send-email-amit@netxen.com>
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com,
	Narender Kumar <narender.kumar@qlogic.com>,
	Amit Kumar Salecha <amit.salecha@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:3777 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751311AbZKUIIv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Nov 2009 03:08:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Narender Kumar <narender.kumar@qlogic.com>

o Along with netdev->perm_addr, mac address will be
  maintained in device private structure.

o Device limitation: We need to set mac address when ever
  interface comes up.

In ALB/TAL mode, bonding driver calls set_mac for all slave with bond mac address.
But bonding driver set netdev->dev_addr field to its original value,
after enslaving interfaces.

When ever active slave changes, it swap dev_addr of inactive slave with active.
Yet it doesn't notify driver about change in netdev->dev_addr.

As netxen driver need to set mac addr when ever interface comes up,
it can't rely on netdev->dev_addr field. Specially in case of bonding mode ALB/TLB.

Signed-off-by: Narender Kumar <narender.kumar@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic.h      |    2 ++
 drivers/net/netxen/netxen_nic_hw.c   |    6 +++---
 drivers/net/netxen/netxen_nic_main.c |    4 +++-
 3 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 7384f59..e1237b8 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -1163,6 +1163,8 @@ struct netxen_adapter {
 	u32 int_vec_bit;
 	u32 heartbit;
 
+	u8 mac_addr[ETH_ALEN];
+
 	struct netxen_adapter_stats stats;
 
 	struct netxen_recv_context recv_ctx;
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index e2c4a01..52a3798 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -463,7 +463,7 @@ netxen_nic_enable_mcast_filter(struct netxen_adapter *adapter)
 {
 	u32	val = 0;
 	u16 port = adapter->physical_port;
-	u8 *addr = adapter->netdev->dev_addr;
+	u8 *addr = adapter->mac_addr;
 
 	if (adapter->mc_enabled)
 		return 0;
@@ -492,7 +492,7 @@ netxen_nic_disable_mcast_filter(struct netxen_adapter *adapter)
 {
 	u32	val = 0;
 	u16 port = adapter->physical_port;
-	u8 *addr = adapter->netdev->dev_addr;
+	u8 *addr = adapter->mac_addr;
 
 	if (!adapter->mc_enabled)
 		return 0;
@@ -687,7 +687,7 @@ void netxen_p3_nic_set_multi(struct net_device *netdev)
 
 	list_splice_tail_init(&adapter->mac_list, &del_list);
 
-	nx_p3_nic_add_mac(adapter, netdev->dev_addr, &del_list);
+	nx_p3_nic_add_mac(adapter, adapter->mac_addr, &del_list);
 	nx_p3_nic_add_mac(adapter, bcast_addr, &del_list);
 
 	if (netdev->flags & IFF_PROMISC) {
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 0b4a56a..3bf78db 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -437,6 +437,7 @@ netxen_read_mac_addr(struct netxen_adapter *adapter)
 		netdev->dev_addr[i] = *(p + 5 - i);
 
 	memcpy(netdev->perm_addr, netdev->dev_addr, netdev->addr_len);
+	memcpy(adapter->mac_addr, netdev->dev_addr, netdev->addr_len);
 
 	/* set station address */
 
@@ -459,6 +460,7 @@ int netxen_nic_set_mac(struct net_device *netdev, void *p)
 		netxen_napi_disable(adapter);
 	}
 
+	memcpy(adapter->mac_addr, addr->sa_data, netdev->addr_len);
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
 	adapter->macaddr_set(adapter, addr->sa_data);
 
@@ -956,7 +958,7 @@ netxen_nic_up(struct netxen_adapter *adapter, struct net_device *netdev)
 		return err;
 	}
 	if (NX_IS_REVISION_P2(adapter->ahw.revision_id))
-		adapter->macaddr_set(adapter, netdev->dev_addr);
+		adapter->macaddr_set(adapter, adapter->mac_addr);
 
 	adapter->set_multi(netdev);
 	adapter->set_mtu(adapter, netdev->mtu);
-- 
1.5.6.1

