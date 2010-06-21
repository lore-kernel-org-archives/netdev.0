From: John Fastabend <john.r.fastabend@intel.com>
Subject: [RFC net-2.6 PATCH] ixgbe: need to purge skb qdisc lists when
	changing real_num_tx_queues
Date: Sun, 20 Jun 2010 22:25:20 -0700
Message-ID: <20100621052520.2417.65984.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:31408 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752954Ab0FUFZK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jun 2010 01:25:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch exports dev_deactivate() symbol.

The qdisc needs to be purged when real_num_tx_queues is
changed so that skbs do not hit ndo_start_xmit with
queue_mappings corresponding to tx_rings already freed.

real_num_tx_queues is changed when dynamically enabling or
disabling DCB or FCoE.  To purge the qdisc use dev_deactivate().

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 drivers/net/ixgbe/ixgbe_dcb_nl.c |    9 +++++++--
 drivers/net/ixgbe/ixgbe_fcoe.c   |    9 +++++++--
 net/sched/sch_generic.c          |    1 +
 3 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index 71da325..0d6854c 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -28,6 +28,7 @@
 
 #include "ixgbe.h"
 #include <linux/dcbnl.h>
+#include <net/pkt_sched.h>
 #include "ixgbe_dcb_82598.h"
 #include "ixgbe_dcb_82599.h"
 
@@ -126,8 +127,10 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 			goto out;
 		}
 
-		if (netif_running(netdev))
+		if (netif_running(netdev)) {
+			dev_deactivate(netdev);
 			netdev->netdev_ops->ndo_stop(netdev);
+		}
 		ixgbe_clear_interrupt_scheme(adapter);
 
 		if (adapter->hw.mac.type == ixgbe_mac_82598EB) {
@@ -146,8 +149,10 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 	} else {
 		/* Turn off DCB */
 		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
-			if (netif_running(netdev))
+			if (netif_running(netdev)) {
+				dev_deactivate(netdev);
 				netdev->netdev_ops->ndo_stop(netdev);
+			}
 			ixgbe_clear_interrupt_scheme(adapter);
 
 			adapter->hw.fc.requested_mode = adapter->last_lfc_mode;
diff --git a/drivers/net/ixgbe/ixgbe_fcoe.c b/drivers/net/ixgbe/ixgbe_fcoe.c
index 45182ab..181f158 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ixgbe/ixgbe_fcoe.c
@@ -33,6 +33,7 @@
 #include <linux/if_ether.h>
 #include <linux/gfp.h>
 #include <linux/if_vlan.h>
+#include <net/sch_generic.h>
 #include <scsi/scsi_cmnd.h>
 #include <scsi/scsi_device.h>
 #include <scsi/fc/fc_fs.h>
@@ -615,8 +616,10 @@ int ixgbe_fcoe_enable(struct net_device *netdev)
 		goto out_enable;
 
 	DPRINTK(DRV, INFO, "Enabling FCoE offload features.\n");
-	if (netif_running(netdev))
+	if (netif_running(netdev)) {
+		dev_deactivate(netdev);
 		netdev->netdev_ops->ndo_stop(netdev);
+	}
 
 	ixgbe_clear_interrupt_scheme(adapter);
 
@@ -661,8 +664,10 @@ int ixgbe_fcoe_disable(struct net_device *netdev)
 		goto out_disable;
 
 	DPRINTK(DRV, INFO, "Disabling FCoE offload features.\n");
-	if (netif_running(netdev))
+	if (netif_running(netdev)) {
+		dev_deactivate(netdev);
 		netdev->netdev_ops->ndo_stop(netdev);
+	}
 
 	ixgbe_clear_interrupt_scheme(adapter);
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index a63029e..53ca3ac 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -804,6 +804,7 @@ void dev_deactivate(struct net_device *dev)
 	while (some_qdisc_is_busy(dev))
 		yield();
 }
+EXPORT_SYMBOL(dev_deactivate);
 
 static void dev_init_scheduler_queue(struct net_device *dev,
 				     struct netdev_queue *dev_queue,

