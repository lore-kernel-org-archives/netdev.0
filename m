From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next] be2net: fix build dependency on VxLAN
Date: Tue, 1 Apr 2014 12:33:59 +0530
Message-ID: <1396335839-2193-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:55921 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751948AbaDAHAL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 03:00:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce a CONFIG_BE2NET_VXLAN define to control be2net's build
dependency on the VXLAN driver.

Without this fix, the kernel build fails when VxLAN driver is
selected to be built as a module while be2net is built-in.

fixes: c9c47142 ("be2net: csum, tso and rss steering offload support for VxLAN")

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/Kconfig   |    8 ++++++++
 drivers/net/ethernet/emulex/benet/be_main.c |   12 +++++++++++-
 2 files changed, 19 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/Kconfig b/drivers/net/ethernet/emulex/benet/Kconfig
index 231129d..ea94a8e 100644
--- a/drivers/net/ethernet/emulex/benet/Kconfig
+++ b/drivers/net/ethernet/emulex/benet/Kconfig
@@ -4,3 +4,11 @@ config BE2NET
 	---help---
 	  This driver implements the NIC functionality for ServerEngines'
 	  10Gbps network adapter - BladeEngine.
+
+config BE2NET_VXLAN
+        bool "VXLAN offload support on be2net driver"
+        default y
+        depends on BE2NET && VXLAN && !(BE2NET=y && VXLAN=m)
+        ---help---
+	  Say Y here if you want to enable VXLAN offload support on
+	  be2net driver.
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index c89dc85..3e6df47 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2862,8 +2862,11 @@ static int be_open(struct net_device *netdev)
 	netif_tx_start_all_queues(netdev);
 	be_roce_dev_open(adapter);
 
+#ifdef CONFIG_BE2NET_VXLAN
 	if (skyhawk_chip(adapter))
 		vxlan_get_rx_port(netdev);
+#endif
+
 	return 0;
 err:
 	be_close(adapter->netdev);
@@ -3019,6 +3022,7 @@ static void be_mac_clear(struct be_adapter *adapter)
 	}
 }
 
+#ifdef CONFIG_BE2NET_VXLAN
 static void be_disable_vxlan_offloads(struct be_adapter *adapter)
 {
 	if (adapter->flags & BE_FLAGS_VXLAN_OFFLOADS)
@@ -3031,6 +3035,7 @@ static void be_disable_vxlan_offloads(struct be_adapter *adapter)
 	adapter->flags &= ~BE_FLAGS_VXLAN_OFFLOADS;
 	adapter->vxlan_port = 0;
 }
+#endif
 
 static int be_clear(struct be_adapter *adapter)
 {
@@ -3039,8 +3044,9 @@ static int be_clear(struct be_adapter *adapter)
 	if (sriov_enabled(adapter))
 		be_vf_clear(adapter);
 
+#ifdef CONFIG_BE2NET_VXLAN
 	be_disable_vxlan_offloads(adapter);
-
+#endif
 	/* delete the primary mac along with the uc-mac list */
 	be_mac_clear(adapter);
 
@@ -4165,6 +4171,7 @@ static int be_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 				       BRIDGE_MODE_VEPA : BRIDGE_MODE_VEB);
 }
 
+#ifdef CONFIG_BE2NET_VXLAN
 static void be_add_vxlan_port(struct net_device *netdev, sa_family_t sa_family,
 			      __be16 port)
 {
@@ -4223,6 +4230,7 @@ static void be_del_vxlan_port(struct net_device *netdev, sa_family_t sa_family,
 		 "Disabled VxLAN offloads for UDP port %d\n",
 		 be16_to_cpu(port));
 }
+#endif
 
 static const struct net_device_ops be_netdev_ops = {
 	.ndo_open		= be_open,
@@ -4248,8 +4256,10 @@ static const struct net_device_ops be_netdev_ops = {
 #ifdef CONFIG_NET_RX_BUSY_POLL
 	.ndo_busy_poll		= be_busy_poll,
 #endif
+#ifdef CONFIG_BE2NET_VXLAN
 	.ndo_add_vxlan_port	= be_add_vxlan_port,
 	.ndo_del_vxlan_port	= be_del_vxlan_port,
+#endif
 };
 
 static void be_netdev_init(struct net_device *netdev)
-- 
1.7.1
