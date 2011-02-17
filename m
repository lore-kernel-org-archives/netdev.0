From: Vasanthy Kolluri <vkolluri@cisco.com>
Subject: [net-next-2.6 PATCH 1/3] enic: Bug fix: Reset driver count of
	registered unicast addresses to zero during device reset
Date: Thu, 17 Feb 2011 10:53:12 -0800
Message-ID: <20110217185311.2476.27883.stgit@savbu-pc100.cisco.com>
References: <20110217185245.2476.60944.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3.cisco.com ([171.71.176.72]:45634 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757718Ab1BQSxN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 13:53:13 -0500
In-Reply-To: <20110217185245.2476.60944.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>

During a device reset, clear the counter for the no. of unicast addresses registered.
Also, rename the routines that update unicast and multicast address lists.

Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: Danny Guo <dannguo@cisco.com>
Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
---
 drivers/net/enic/enic.h      |    2 +-
 drivers/net/enic/enic_main.c |   13 +++++++------
 2 files changed, 8 insertions(+), 7 deletions(-)


diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index 57fcaee..5f4eb45 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -32,7 +32,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"2.1.1.6"
+#define DRV_VERSION		"2.1.1.7"
 #define DRV_COPYRIGHT		"Copyright 2008-2011 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 0c24370..a625a0e 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -874,9 +874,10 @@ static struct net_device_stats *enic_get_stats(struct net_device *netdev)
 	return net_stats;
 }
 
-static void enic_reset_multicast_list(struct enic *enic)
+static void enic_reset_addr_lists(struct enic *enic)
 {
 	enic->mc_count = 0;
+	enic->uc_count = 0;
 	enic->flags = 0;
 }
 
@@ -941,7 +942,7 @@ static int enic_set_mac_address(struct net_device *netdev, void *p)
 	return enic_dev_add_station_addr(enic);
 }
 
-static void enic_add_multicast_addr_list(struct enic *enic)
+static void enic_update_multicast_addr_list(struct enic *enic)
 {
 	struct net_device *netdev = enic->netdev;
 	struct netdev_hw_addr *ha;
@@ -996,7 +997,7 @@ static void enic_add_multicast_addr_list(struct enic *enic)
 	enic->mc_count = mc_count;
 }
 
-static void enic_add_unicast_addr_list(struct enic *enic)
+static void enic_update_unicast_addr_list(struct enic *enic)
 {
 	struct net_device *netdev = enic->netdev;
 	struct netdev_hw_addr *ha;
@@ -1073,9 +1074,9 @@ static void enic_set_rx_mode(struct net_device *netdev)
 	}
 
 	if (!promisc) {
-		enic_add_unicast_addr_list(enic);
+		enic_update_unicast_addr_list(enic);
 		if (!allmulti)
-			enic_add_multicast_addr_list(enic);
+			enic_update_multicast_addr_list(enic);
 	}
 }
 
@@ -2067,7 +2068,7 @@ static void enic_reset(struct work_struct *work)
 	enic_dev_hang_notify(enic);
 	enic_stop(enic->netdev);
 	enic_dev_hang_reset(enic);
-	enic_reset_multicast_list(enic);
+	enic_reset_addr_lists(enic);
 	enic_init_vnic_resources(enic);
 	enic_set_rss_nic_cfg(enic);
 	enic_dev_set_ig_vlan_rewrite_mode(enic);

