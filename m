From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next RFC v3 2/2] ixgbe: Get and display the notifications from changes of the Rx vxlan UDP port
Date: Fri, 30 Aug 2013 00:43:39 -0700
Message-ID: <1377848619-25662-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1377848619-25662-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Joseph Gasparakis <joseph.gasparakis@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:37395 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752453Ab3H3HoY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Aug 2013 03:44:24 -0400
In-Reply-To: <1377848619-25662-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joseph Gasparakis <joseph.gasparakis@intel.com>

This RFC patch showcases how drivers can use the changes in
"vxlan: Notify drivers for listening UDP port changes", and its
sole purpose is to help people test the changes introduced there.
This is not meant to be submitted for inclusion in the kernel.

CC: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Joseph Gasparakis <joseph.gasparakis@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
v2: No changes in the code, just tracking version of main patch
v3: Changed the implementations of the ndo ops to return void as per
    the main patch.

---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 7aba452..9620cf2 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -47,6 +47,9 @@
 #include <linux/if_bridge.h>
 #include <linux/prefetch.h>
 #include <scsi/fc/fc_fcoe.h>
+#ifdef CONFIG_VXLAN_MODULE
+#include <net/vxlan.h>
+#endif
 
 #include "ixgbe.h"
 #include "ixgbe_common.h"
@@ -5178,6 +5181,9 @@ static int ixgbe_open(struct net_device *netdev)
 
 	ixgbe_up_complete(adapter);
 
+#ifdef CONFIG_VXLAN_MODULE
+	vxlan_get_rx_port(netdev);
+#endif
 	return 0;
 
 err_set_queues:
@@ -7290,6 +7296,19 @@ static int ixgbe_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 	return ndo_dflt_bridge_getlink(skb, pid, seq, dev, mode);
 }
 
+#ifdef CONFIG_VXLAN_MODULE
+static void ixgbe_add_vxlan_port(struct net_device *netdev,
+				__u16 port)
+{
+	netdev_info(netdev, ">>>>> Adding VXLAN port %d\n", port);
+}
+
+static void ixgbe_del_vxlan_port(struct net_device *netdev,
+				__u16 port)
+{
+	netdev_info(netdev, "<<<<< Removing VXLAN port %d\n", port);
+}
+#endif
 static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_open		= ixgbe_open,
 	.ndo_stop		= ixgbe_close,
@@ -7334,6 +7353,10 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_fdb_add		= ixgbe_ndo_fdb_add,
 	.ndo_bridge_setlink	= ixgbe_ndo_bridge_setlink,
 	.ndo_bridge_getlink	= ixgbe_ndo_bridge_getlink,
+#ifdef CONFIG_VXLAN_MODULE
+	.ndo_add_vxlan_port	= ixgbe_add_vxlan_port,
+	.ndo_del_vxlan_port	= ixgbe_del_vxlan_port,
+#endif
 };
 
 /**
-- 
1.8.3.1
