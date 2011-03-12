From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 11/21] ixgbe: enable ndo_tc_setup
Date: Sat, 12 Mar 2011 04:20:18 -0800
Message-ID: <1299932428-3114-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299932428-3114-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:58767 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751895Ab1CLMU4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Mar 2011 07:20:56 -0500
In-Reply-To: <1299932428-3114-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

This patch adds the ndo_tc_setup to ixgbe. By default we set
the device to use strict priority.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain.@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_main.c |   24 +++++++++++++++++++++++-
 1 files changed, 23 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 3694226..3ce0f4f 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4606,7 +4606,10 @@ int ixgbe_setup_tc(struct net_device *dev, u8 tc)
 	if (!tc) {
 		netdev_reset_tc(dev);
 	} else {
-		if (netdev_set_num_tc(dev, tc))
+		struct ixgbe_adapter *adapter = netdev_priv(dev);
+
+		/* Hardware supports up to 8 traffic classes */
+		if (tc > MAX_TRAFFIC_CLASS || netdev_set_num_tc(dev, tc))
 			return -EINVAL;
 
 		/* Partition Tx queues evenly amongst traffic classes */
@@ -4616,6 +4619,22 @@ int ixgbe_setup_tc(struct net_device *dev, u8 tc)
 			netdev_set_tc_queue(dev, i, q, offset);
 			offset += q;
 		}
+
+		/* This enables multiple traffic class support in the hardware
+		 * which defaults to strict priority transmission by default.
+		 * If traffic classes are already enabled perhaps through DCB
+		 * code path then existing configuration will be used.
+		 */
+		if (!(adapter->flags & IXGBE_FLAG_DCB_ENABLED) &&
+		    dev->dcbnl_ops && dev->dcbnl_ops->setdcbx) {
+			struct ieee_ets ets = {
+					.prio_tc = {0, 1, 2, 3, 4, 5, 6, 7},
+					      };
+			u8 mode = DCB_CAP_DCBX_HOST | DCB_CAP_DCBX_VER_IEEE;
+
+			dev->dcbnl_ops->setdcbx(dev, mode);
+			dev->dcbnl_ops->ieee_setets(dev, &ets);
+		}
 	}
 	return 0;
 }
@@ -7022,6 +7041,9 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_set_vf_tx_rate	= ixgbe_ndo_set_vf_bw,
 	.ndo_get_vf_config	= ixgbe_ndo_get_vf_config,
 	.ndo_get_stats64	= ixgbe_get_stats64,
+#ifdef CONFIG_IXGBE_DCB
+	.ndo_setup_tc		= ixgbe_setup_tc,
+#endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= ixgbe_netpoll,
 #endif
-- 
1.7.4

