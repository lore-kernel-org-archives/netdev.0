From: clsoto@linux.vnet.ibm.com
Subject: [Patch 2/3] IB: hang in mcast_remove_one during PCI error injection
Date: Thu, 27 Mar 2014 09:28:15 -0500
Message-ID: <20140327142939.291787569@linux.vnet.ibm.com>
References: <20140327142813.535289178@linux.vnet.ibm.com>
Cc: brking@linux.vnet.ibm.com
To: clsoto@linux.vnet.ibm.com, roland@kernel.org, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [32.97.110.57] ([32.97.110.57]:60987 "HELO
	jupiter1-lp2.austin.ibm.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with SMTP id S1756894AbaC0Ocp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 10:32:45 -0400
Content-Disposition: inline; filename=mcast_remove_one_hang.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to avoid this hang:
kernel: Call Trace:
kernel: [C0000000FF9E34D0] [C0000000FF9E3560] 0xc0000000ff9e3560 (unreliable)
kernel: [C0000000FF9E36A0] [C00000000001070C] .__switch_to+0x124/0x148
kernel: [C0000000FF9E3730] [C0000000003E6D30] .schedule+0xc10/0xdc4
kernel: [C0000000FF9E3840] [C0000000003E7024] .wait_for_completion+0xcc/0x150
kernel: [C0000000FF9E3900] [D000000000882288] .mcast_remove_one+0x8c/0xe8 [ib_sa]
kernel: [C0000000FF9E39A0] [D0000000004E404C] .ib_unregister_device+0x64/0x15c [ib_core]
kernel: [C0000000FF9E3A40] [D000000000542A4C] .mlx4_ib_remove+0x50/0x148 [mlx4_ib]
kernel: [C0000000FF9E3AD0] [D0000000004A6EBC] .mlx4_remove_device+0xa0/0xf0 [mlx4_core]
kernel: [C0000000FF9E3B60] [D0000000004A73F0] .mlx4_unregister_device+0x44/0xa8 [mlx4_core]
kernel: [C0000000FF9E3BF0] [D0000000004AA0A8] .mlx4_remove_one+0x40/0x1bc [mlx4_core]
kernel: [C0000000FF9E3C80] [D0000000004AA240] .mlx4_pci_err_detected+0x1c/0x48 [mlx4_core]
kernel: [C0000000FF9E3D10] [C000000000053E84] .eeh_report_error+0x70/0xb4
kernel: [C0000000FF9E3DA0] [C0000000001DCB18] .pci_walk_bus+0xf8/0x168
kernel: [C0000000FF9E3E50] [C000000000054254] .handle_eeh_events+0x1a8/0x3d0
kernel: [C0000000FF9E3F00] [C000000000054580] .eeh_event_handler+0xc0/0x160
kernel: [C0000000FF9E3F90] [C000000000027A3C] .kernel_thread+0x4c/0x68

Add IB_EVENT_DEVICE_FATAL event to ib_sa, multicast and ipoib event handlers so 
the event handler will make the multicast group that are in joined state 
to move from that state so it will decrease the counter that will create this hang.

Signed-off-by: Carol Soto <clsoto@linux.vnet.ibm.com>

---
 drivers/infiniband/core/multicast.c        |    1 +
 drivers/infiniband/core/sa_query.c         |    1 +
 drivers/infiniband/ulp/ipoib/ipoib_verbs.c |    1 +
 3 files changed, 3 insertions(+)

Index: b/drivers/infiniband/core/multicast.c
===================================================================
--- a/drivers/infiniband/core/multicast.c
+++ b/drivers/infiniband/core/multicast.c
@@ -785,6 +785,7 @@ static void mcast_event_handler(struct i
 	case IB_EVENT_PORT_ERR:
 	case IB_EVENT_LID_CHANGE:
 	case IB_EVENT_SM_CHANGE:
+	case IB_EVENT_DEVICE_FATAL:
 	case IB_EVENT_CLIENT_REREGISTER:
 		mcast_groups_event(&dev->port[index], MCAST_GROUP_ERROR);
 		break;
Index: b/drivers/infiniband/core/sa_query.c
===================================================================
--- a/drivers/infiniband/core/sa_query.c
+++ b/drivers/infiniband/core/sa_query.c
@@ -443,6 +443,7 @@ static void ib_sa_event(struct ib_event_
 	    event->event == IB_EVENT_LID_CHANGE  ||
 	    event->event == IB_EVENT_PKEY_CHANGE ||
 	    event->event == IB_EVENT_SM_CHANGE   ||
+	    event->event == IB_EVENT_DEVICE_FATAL ||
 	    event->event == IB_EVENT_CLIENT_REREGISTER) {
 		unsigned long flags;
 		struct ib_sa_device *sa_dev =
Index: b/drivers/infiniband/ulp/ipoib/ipoib_verbs.c
===================================================================
--- a/drivers/infiniband/ulp/ipoib/ipoib_verbs.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_verbs.c
@@ -289,6 +289,7 @@ void ipoib_event(struct ib_event_handler
 		queue_work(ipoib_workqueue, &priv->flush_light);
 	} else if (record->event == IB_EVENT_PORT_ERR ||
 		   record->event == IB_EVENT_PORT_ACTIVE ||
+		   record->event == IB_EVENT_DEVICE_FATAL ||
 		   record->event == IB_EVENT_LID_CHANGE) {
 		queue_work(ipoib_workqueue, &priv->flush_normal);
 	} else if (record->event == IB_EVENT_PKEY_CHANGE) {

-- 
