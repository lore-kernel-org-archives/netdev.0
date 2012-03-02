From: santosh nayak <santoshprasadnayak@gmail.com>
Subject: [PATCH 3/3] netxen: qlogic ethernet : Fix Endian Bug.
Date: Fri,  2 Mar 2012 20:41:39 +0530
Message-ID: <1330701099-18281-1-git-send-email-santoshprasadnayak@gmail.com>
Cc: rajesh.borundia@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Santosh Nayak <santoshprasadnayak@gmail.com>
To: sony.chacko@qlogic.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Santosh Nayak <santoshprasadnayak@gmail.com>

Fix endian bug.
Add a default case in 'netxen_list_config_vlan_ip'

Signed-off-by: Santosh Nayak <santoshprasadnayak@gmail.com>
---
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |   20 ++++++++++++--------
 1 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index 8dc4a134..971b286 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -818,7 +818,7 @@ netxen_check_options(struct netxen_adapter *adapter)
 			adapter->driver_mismatch = 1;
 			return;
 		}
-		ptr32[i] = cpu_to_le32(val);
+		ptr32[i] = val;
 		offset += sizeof(u32);
 	}
 
@@ -3028,7 +3028,7 @@ netxen_list_config_vlan_ip(struct netxen_adapter *adapter,
 		list_for_each(head, &adapter->vlan_ip_list) {
 			cur = list_entry(head, struct nx_vlan_ip_list, list);
 
-			if (cur->ip_addr == ifa->ifa_address)
+			if (cur->ip_addr == be32_to_cpu(ifa->ifa_address))
 				return;
 		}
 
@@ -3039,18 +3039,22 @@ netxen_list_config_vlan_ip(struct netxen_adapter *adapter,
 			return;
 		}
 
-		cur->ip_addr = ifa->ifa_address;
+		cur->ip_addr = be32_to_cpu(ifa->ifa_address);
 		list_add_tail(&cur->list, &adapter->vlan_ip_list);
 		break;
 	case NX_IP_DOWN:
 		list_for_each_entry_safe(cur, tmp_cur,
 					&adapter->vlan_ip_list, list) {
-			if (cur->ip_addr == ifa->ifa_address) {
+			if (cur->ip_addr == be32_to_cpu(ifa->ifa_address)) {
 				list_del(&cur->list);
 				kfree(cur);
 				break;
 			}
 		}
+		break;
+	default:
+		printk(KERN_ERR "%ld: Wrong event id \n", event);
+		break;
 	}
 }
 static void
@@ -3070,12 +3074,12 @@ netxen_config_indev_addr(struct netxen_adapter *adapter,
 		switch (event) {
 		case NETDEV_UP:
 			netxen_config_ipaddr(adapter,
-					ifa->ifa_address, NX_IP_UP);
+					be32_to_cpu(ifa->ifa_address), NX_IP_UP);
 			netxen_list_config_vlan_ip(adapter, ifa, NX_IP_UP);
 			break;
 		case NETDEV_DOWN:
 			netxen_config_ipaddr(adapter,
-					ifa->ifa_address, NX_IP_DOWN);
+					be32_to_cpu(ifa->ifa_address), NX_IP_DOWN);
 			netxen_list_config_vlan_ip(adapter, ifa, NX_IP_DOWN);
 			break;
 		default:
@@ -3167,11 +3171,11 @@ recheck:
 
 	switch (event) {
 	case NETDEV_UP:
-		netxen_config_ipaddr(adapter, ifa->ifa_address, NX_IP_UP);
+		netxen_config_ipaddr(adapter, be32_to_cpu(ifa->ifa_address), NX_IP_UP);
 		netxen_list_config_vlan_ip(adapter, ifa, NX_IP_UP);
 		break;
 	case NETDEV_DOWN:
-		netxen_config_ipaddr(adapter, ifa->ifa_address, NX_IP_DOWN);
+		netxen_config_ipaddr(adapter, be32_to_cpu(ifa->ifa_address), NX_IP_DOWN);
 		netxen_list_config_vlan_ip(adapter, ifa, NX_IP_DOWN);
 		break;
 	default:
-- 
1.7.4.4
