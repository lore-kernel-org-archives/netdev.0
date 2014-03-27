From: clsoto@linux.vnet.ibm.com
Subject: [Patch 3/3] IB/ib_cm: hang in cm_destroy_id during PCI error injection
Date: Thu, 27 Mar 2014 09:28:16 -0500
Message-ID: <20140327142939.460692817@linux.vnet.ibm.com>
References: <20140327142813.535289178@linux.vnet.ibm.com>
Cc: brking@linux.vnet.ibm.com
To: clsoto@linux.vnet.ibm.com, roland@kernel.org, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [32.97.110.57] ([32.97.110.57]:60990 "HELO
	jupiter1-lp2.austin.ibm.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with SMTP id S1756895AbaC0Ocq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 10:32:46 -0400
Content-Disposition: inline; filename=cm_destroy_id_hangs.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to avoid this hang:
kernel:  Call Trace:
kernel:  [c0000003ea9faa70] [c0000000000144f0] .__switch_to+0x1c0/0x390
kernel:  [c0000003ea9fab20] [c0000000006d5528] .__schedule+0x328/0x920
kernel:  [c0000003ea9fada0] [c0000000006d2da4] .schedule_timeout+0x244/0x2e0
kernel:  [c0000003ea9faea0] [c0000000006d61dc] .wait_for_common+0x18c/0x210
kernel:  [c0000003ea9faf70] [d00000000cee45a0] .cm_destroy_id+0x190/0x590 [ib_cm]
kernel:  [c0000003ea9fb040] [d00000000d6ac3d8] .ipoib_cm_free_rx_reap_list+0xc8/0x1b0 [ib_ipoib]
kernel:  [c0000003ea9fb100] [d00000000d6af870] .ipoib_cm_dev_stop+0x210/0x340 [ib_ipoib]
kernel:  [c0000003ea9fb1c0] [d00000000d6a67b0] .ipoib_ib_dev_stop+0x100/0x500 [ib_ipoib]
kernel:  [c0000003ea9fb320] [d00000000d6a0ce4] .ipoib_stop+0x94/0x1a0 [ib_ipoib]
kernel:  [c0000003ea9fb3b0] [c00000000059db58] .__dev_close_many+0xc8/0x140
kernel:  [c0000003ea9fb440] [c00000000059dc24] .__dev_close+0x54/0x90
kernel:  [c0000003ea9fb4e0] [c0000000005a6940] .__dev_change_flags+0x170/0x1f0
kernel:  [c0000003ea9fb580] [c0000000005a6aa4] .dev_change_flags+0x24/0x90
kernel:  [c0000003ea9fb610] [d00000000d6a1604] .ipoib_remove_one+0xc4/0x160 [ib_ipoib]
kernel:  [c0000003ea9fb6b0] [d00000000c285174] .ib_unregister_device+0x74/0x150 [ib_core]
kernel:  [c0000003ea9fb750] [d00000000c857af4] .mlx4_ib_remove+0x44/0x220 [mlx4_ib]
kernel:  [c0000003ea9fb7e0] [d000000003b6d07c] .mlx4_remove_device+0xdc/0x120 [mlx4_core]
kernel:  [c0000003ea9fb870] [d000000003b6d6ec] .mlx4_unregister_device+0x7c/0xf0 [mlx4_core]
kernel:  [c0000003ea9fb900] [d000000003b6ec20] .mlx4_remove_one+0x60/0x3e0 [mlx4_core]
kernel:  [c0000003ea9fb9a0] [d000000003b6efb8] .mlx4_pci_err_detected+0x18/0x40 [mlx4_core]
kernel:  [c0000003ea9fba20] [c000000000035630] .eeh_report_error+0xa0/0x120
kernel:  [c0000003ea9fbab0] [c00000000003431c] .eeh_pe_dev_traverse+0x9c/0x190
kernel:  [c0000003ea9fbb60] [c000000000035c4c] .eeh_handle_normal_event+0x11c/0x3c0
kernel:  [c0000003ea9fbbf0] [c000000000035f20] .eeh_handle_event+0x30/0x2b0
kernel:  [c0000003ea9fbc90] [c0000000000362f4] .eeh_event_handler+0x154/0x170
kernel:  [c0000003ea9fbd30] [c0000000000c0018] .kthread+0xe8/0xf0
kernel:  [c0000003ea9fbe30] [c00000000000a168] .ret_from_kernel_thread+0x5c/0x74

The approach in this patch is to send the IB_EVENT_DEVICE_FATAL to cm, after this
cm will not try to send a message so it will not increase the counter that is causing this hang.
If cm tries to send a packet after receiving the Fatal event, the adapter may not create a
completion event and it will cause this hang.

Signed-off-by: Carol Soto <clsoto@linux.vnet.ibm.com>
---
 drivers/infiniband/core/cm.c |   43 +++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 43 insertions(+)

Index: b/drivers/infiniband/core/cm.c
===================================================================
--- a/drivers/infiniband/core/cm.c
+++ b/drivers/infiniband/core/cm.c
@@ -161,6 +161,7 @@ struct cm_port {
 	struct ib_mad_agent *mad_agent;
 	struct kobject port_obj;
 	u8 port_num;
+	u8 device_fatal;
 	struct cm_counter_group counter_group[CM_COUNTER_GROUPS];
 };
 
@@ -168,6 +169,7 @@ struct cm_device {
 	struct list_head list;
 	struct ib_device *ib_device;
 	struct device *device;
+	struct ib_event_handler event_handler;
 	u8 ack_delay;
 	struct cm_port *port[0];
 };
@@ -258,6 +260,10 @@ static int cm_alloc_msg(struct cm_id_pri
 	struct ib_mad_agent *mad_agent;
 	struct ib_mad_send_buf *m;
 	struct ib_ah *ah;
+	struct cm_port *port = cm_id_priv->av.port;
+
+	if (port->device_fatal)
+		return -EIO;
 
 	mad_agent = cm_id_priv->av.port->mad_agent;
 	ah = ib_create_ah(mad_agent->qp->pd, &cm_id_priv->av.ah_attr);
@@ -290,6 +296,9 @@ static int cm_alloc_response_msg(struct 
 	struct ib_mad_send_buf *m;
 	struct ib_ah *ah;
 
+	if (port->device_fatal)
+		return -EIO;
+
 	ah = ib_create_ah_from_wc(port->mad_agent->qp->pd, mad_recv_wc->wc,
 				  mad_recv_wc->recv_buf.grh, port->port_num);
 	if (IS_ERR(ah))
@@ -3764,6 +3773,33 @@ static void cm_remove_port_fs(struct cm_
 	kobject_put(&port->port_obj);
 }
 
+static void ib_cm_event_handler(struct ib_event_handler *handler,
+				struct ib_event *event)
+{
+	struct cm_device *cm_dev;
+	struct cm_port *port = NULL;
+
+	cm_dev = container_of(handler, struct cm_device, event_handler);
+	switch (event->event) {
+	case IB_EVENT_PORT_ACTIVE:
+		port = cm_dev->port[event->element.port_num - 1];
+		if (port == NULL)
+			return;
+		if (port->port_num == event->element.port_num)
+			port->device_fatal = 0;
+		break;
+	case IB_EVENT_DEVICE_FATAL:
+		port = cm_dev->port[event->element.port_num - 1];
+		if (port == NULL)
+			return;
+		if (port->port_num == event->element.port_num)
+			port->device_fatal = 1;
+		break;
+	default:
+		break;
+	}
+}
+
 static void cm_add_one(struct ib_device *ib_device)
 {
 	struct cm_device *cm_dev;
@@ -3828,6 +3864,12 @@ static void cm_add_one(struct ib_device 
 	}
 	ib_set_client_data(ib_device, &cm_client, cm_dev);
 
+	INIT_IB_EVENT_HANDLER(&cm_dev->event_handler,
+				ib_device, ib_cm_event_handler);
+	ret = ib_register_event_handler(&cm_dev->event_handler);
+	if (ret)
+		goto error3;
+
 	write_lock_irqsave(&cm.device_lock, flags);
 	list_add_tail(&cm_dev->list, &cm.device_list);
 	write_unlock_irqrestore(&cm.device_lock, flags);
@@ -3864,6 +3906,7 @@ static void cm_remove_one(struct ib_devi
 	if (!cm_dev)
 		return;
 
+	ib_unregister_event_handler(&cm_dev->event_handler);
 	write_lock_irqsave(&cm.device_lock, flags);
 	list_del(&cm_dev->list);
 	write_unlock_irqrestore(&cm.device_lock, flags);

-- 
