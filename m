From: Karthikeyan Ramasubramanian <kramasub@codeaurora.org>
Subject: [PATCH 3/3] net: msm_ipc: Add SMD Transport to the MSM_IPC Router
Date: Wed,  8 Jun 2011 11:51:32 -0600
Message-ID: <1307555492-1666-1-git-send-email-kramasub@codeaurora.org>
Cc: netdev@vger.kernel.org, linux-arm-msm@vger.kernel.org,
	Karthikeyan Ramasubramanian <kramasub@codeaurora.org>
To: davem@davemloft.net
Return-path: <linux-arm-msm-owner@vger.kernel.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a packet oriented SMD Transport to be used by the MSM_IPC Router.

Change-Id: Id992a23acad5b7ad262138163730dfd5b7a56ab1
Signed-off-by: Karthikeyan Ramasubramanian <kramasub@codeaurora.org>
---
 net/msm_ipc/Kconfig                   |    9 ++
 net/msm_ipc/Makefile                  |    1 +
 net/msm_ipc/msm_ipc_router.c          |   86 +++++++++++++
 net/msm_ipc/msm_ipc_router_smd_xprt.c |  226 +++++++++++++++++++++++++++++++++
 4 files changed, 322 insertions(+), 0 deletions(-)
 create mode 100644 net/msm_ipc/msm_ipc_router_smd_xprt.c

diff --git a/net/msm_ipc/Kconfig b/net/msm_ipc/Kconfig
index 9114d7d..5368a40 100644
--- a/net/msm_ipc/Kconfig
+++ b/net/msm_ipc/Kconfig
@@ -13,3 +13,12 @@ menuconfig MSM_IPC
 
 	Say Y (or M) here if you build for a phone product (e.g. Android)
 	that uses MSM_IPC as transport, if unsure say N.
+
+config MSM_IPC_ROUTER_SMD_XPRT
+	tristate "MSM_IPC_ROUTER SMD Transport"
+	depends on MSM_IPC
+	depends on MSM_SMD
+	default n
+	---help---
+	This will provide a packet interface to the MSM_IPC Router over SMD.
+	Say Y if you will be using a MSM_IPC over SMD transport.
diff --git a/net/msm_ipc/Makefile b/net/msm_ipc/Makefile
index b9a0dfb..4f73e67 100644
--- a/net/msm_ipc/Makefile
+++ b/net/msm_ipc/Makefile
@@ -1,3 +1,4 @@
 obj-$(CONFIG_MSM_IPC) := msm_ipc.o
+obj-$(CONFIG_MSM_IPC_ROUTER_SMD_XPRT) += msm_ipc_router_smd_xprt.o
 
 msm_ipc-y += msm_ipc_router.o msm_ipc_socket.o
diff --git a/net/msm_ipc/msm_ipc_router.c b/net/msm_ipc/msm_ipc_router.c
index 0cd0a02..80bd931 100644
--- a/net/msm_ipc/msm_ipc_router.c
+++ b/net/msm_ipc/msm_ipc_router.c
@@ -272,6 +272,7 @@ void release_pkt(struct rr_packet *pkt)
 	kfree(pkt);
 	return;
 }
+EXPORT_SYMBOL(release_pkt);
 
 static int post_control_ports(struct rr_packet *pkt)
 {
@@ -1636,6 +1637,91 @@ int msm_ipc_router_close(void)
 	return 0;
 }
 
+#if defined(CONFIG_MSM_IPC_ROUTER_SMD_XPRT)
+static int msm_ipc_router_add_xprt(struct msm_ipc_router_xprt *xprt)
+{
+	struct msm_ipc_router_xprt_info *xprt_info;
+	struct msm_ipc_routing_table_entry *rt_entry;
+
+	xprt_info = kmalloc(sizeof(struct msm_ipc_router_xprt_info),
+			    GFP_KERNEL);
+	if (!xprt_info)
+		return -ENOMEM;
+
+	xprt_info->xprt = xprt;
+	xprt_info->initialized = 0;
+	xprt_info->remote_node_id = -1;
+	INIT_LIST_HEAD(&xprt_info->pkt_list);
+	init_waitqueue_head(&xprt_info->read_wait);
+	mutex_init(&xprt_info->rx_lock);
+	mutex_init(&xprt_info->tx_lock);
+	xprt_info->need_len = 0;
+	INIT_WORK(&xprt_info->read_data, do_read_data);
+	INIT_LIST_HEAD(&xprt_info->list);
+
+	xprt_info->workqueue = create_singlethread_workqueue(xprt->name);
+	if (!xprt_info->workqueue) {
+		kfree(xprt_info);
+		return -ENOMEM;
+	}
+
+	if (!strcmp(xprt->name, "msm_ipc_router_loopback_xprt")) {
+		xprt_info->remote_node_id = IPC_ROUTER_NID_LOCAL;
+		xprt_info->initialized = 1;
+	}
+
+	mutex_lock(&xprt_info_list_lock);
+	list_add_tail(&xprt_info->list, &xprt_info_list);
+	mutex_unlock(&xprt_info_list_lock);
+
+	mutex_lock(&routing_table_lock);
+	if (!routing_table_inited) {
+		init_routing_table();
+		rt_entry = alloc_routing_table_entry(IPC_ROUTER_NID_LOCAL);
+		add_routing_table_entry(rt_entry);
+		routing_table_inited = 1;
+	}
+	mutex_unlock(&routing_table_lock);
+
+	queue_work(xprt_info->workqueue, &xprt_info->read_data);
+
+	xprt->priv = xprt_info;
+
+	return 0;
+}
+
+void msm_ipc_router_xprt_notify(struct msm_ipc_router_xprt *xprt,
+				unsigned event,
+				void *data)
+{
+	struct msm_ipc_router_xprt_info *xprt_info = xprt->priv;
+	struct rr_packet *pkt;
+
+	if (event == IPC_ROUTER_XPRT_EVENT_OPEN) {
+		msm_ipc_router_add_xprt(xprt);
+		return;
+	}
+
+	if (!data)
+		return;
+
+	while (!xprt_info) {
+		msleep(100);
+		xprt_info = xprt->priv;
+	}
+
+	pkt = clone_pkt((struct rr_packet *)data);
+	if (!pkt)
+		return;
+
+	mutex_lock(&xprt_info->rx_lock);
+	list_add_tail(&pkt->list, &xprt_info->pkt_list);
+	wake_up(&xprt_info->read_wait);
+	mutex_unlock(&xprt_info->rx_lock);
+}
+EXPORT_SYMBOL(msm_ipc_router_xprt_notify);
+#endif
+
 static int __init msm_ipc_router_init(void)
 {
 	int i, ret;
diff --git a/net/msm_ipc/msm_ipc_router_smd_xprt.c b/net/msm_ipc/msm_ipc_router_smd_xprt.c
new file mode 100644
index 0000000..1402a8b
--- /dev/null
+++ b/net/msm_ipc/msm_ipc_router_smd_xprt.c
@@ -0,0 +1,226 @@
+/* Copyright (c) 2011, Code Aurora Forum. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 and
+ * only version 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+/*
+ * IPC ROUTER SMD XPRT module.
+ */
+
+#include <linux/platform_device.h>
+#include <linux/types.h>
+
+#include <mach/msm_smd.h>
+
+#include "msm_ipc_router.h"
+
+#define MIN_FRAG_SZ (IPC_ROUTER_HDR_SIZE + sizeof(union rr_control_msg))
+
+struct msm_ipc_router_smd_xprt {
+	struct msm_ipc_router_xprt xprt;
+
+	smd_channel_t *channel;
+};
+
+static struct msm_ipc_router_smd_xprt smd_remote_xprt;
+
+static void smd_xprt_read_data(struct work_struct *work);
+static DECLARE_DELAYED_WORK(work_read_data, smd_xprt_read_data);
+static struct workqueue_struct *smd_xprt_workqueue;
+
+static wait_queue_head_t write_avail_wait_q;
+static struct rr_packet *in_pkt;
+static int is_partial_in_pkt;
+
+static int msm_ipc_router_smd_remote_write_avail(void)
+{
+	return smd_write_avail(smd_remote_xprt.channel);
+}
+
+static int msm_ipc_router_smd_remote_write(void *data,
+					   uint32_t len,
+					   uint32_t type)
+{
+	struct rr_packet *pkt = (struct rr_packet *)data;
+	struct sk_buff *ipc_rtr_pkt;
+	int align_sz, align_data = 0;
+	int offset, sz_written = 0;
+
+	if (!pkt)
+		return -EINVAL;
+
+	if (!len || pkt->length != len)
+		return -EINVAL;
+
+	align_sz = ALIGN_SIZE(pkt->length);
+
+	skb_queue_walk(pkt->pkt_fragment_q, ipc_rtr_pkt) {
+		offset = 0;
+		while (offset < ipc_rtr_pkt->len) {
+			wait_event_interruptible_timeout(write_avail_wait_q,
+				smd_write_avail(smd_remote_xprt.channel),
+				msecs_to_jiffies(50));
+
+			sz_written = smd_write(smd_remote_xprt.channel,
+					  ipc_rtr_pkt->data + offset,
+					  (ipc_rtr_pkt->len - offset));
+			offset += sz_written;
+			sz_written = 0;
+		}
+	}
+
+	if (align_sz) {
+		wait_event_interruptible_timeout(write_avail_wait_q,
+			(smd_write_avail(smd_remote_xprt.channel) >=
+			 align_sz), msecs_to_jiffies(50));
+
+		smd_write(smd_remote_xprt.channel, &align_data, align_sz);
+	}
+	return len;
+}
+
+static int msm_ipc_router_smd_remote_close(void)
+{
+	return smd_close(smd_remote_xprt.channel);
+}
+
+static void smd_xprt_read_data(struct work_struct *work)
+{
+	int pkt_size, sz_read, sz;
+	struct sk_buff *ipc_rtr_pkt;
+	void *data;
+
+	while ((pkt_size = smd_cur_packet_size(smd_remote_xprt.channel)) &&
+		smd_read_avail(smd_remote_xprt.channel)) {
+		if (!is_partial_in_pkt) {
+			in_pkt = kzalloc(sizeof(struct rr_packet), GFP_KERNEL);
+			if (!in_pkt) {
+				pr_err("%s: Couldn't alloc rr_packet\n",
+					__func__);
+				return;
+			}
+
+			in_pkt->pkt_fragment_q = kmalloc(
+						  sizeof(struct sk_buff_head),
+						  GFP_KERNEL);
+			if (!in_pkt->pkt_fragment_q) {
+				pr_err("%s: Couldn't alloc pkt_fragment_q\n",
+					__func__);
+				kfree(in_pkt);
+				return;
+			}
+			skb_queue_head_init(in_pkt->pkt_fragment_q);
+			is_partial_in_pkt = 1;
+		}
+
+		if ((pkt_size >= MIN_FRAG_SZ) &&
+		    (smd_read_avail(smd_remote_xprt.channel) < MIN_FRAG_SZ))
+			return;
+
+		sz = smd_read_avail(smd_remote_xprt.channel);
+		do {
+			ipc_rtr_pkt = alloc_skb(sz, GFP_KERNEL);
+			if (!ipc_rtr_pkt) {
+				if (sz <= (PAGE_SIZE/2)) {
+					queue_delayed_work(smd_xprt_workqueue,
+						   &work_read_data,
+						   msecs_to_jiffies(100));
+					return;
+				}
+				sz = sz / 2;
+			}
+		} while (!ipc_rtr_pkt);
+
+		data = skb_put(ipc_rtr_pkt, sz);
+		sz_read = smd_read(smd_remote_xprt.channel, data, sz);
+		if (sz_read != sz) {
+			pr_err("%s: Couldn't read completely\n", __func__);
+			kfree_skb(ipc_rtr_pkt);
+			release_pkt(in_pkt);
+			is_partial_in_pkt = 0;
+			return;
+		}
+		skb_queue_tail(in_pkt->pkt_fragment_q, ipc_rtr_pkt);
+		in_pkt->length += sz_read;
+		if (sz_read != pkt_size)
+			is_partial_in_pkt = 1;
+		else
+			is_partial_in_pkt = 0;
+
+		if (!is_partial_in_pkt) {
+			msm_ipc_router_xprt_notify(&smd_remote_xprt.xprt,
+					   IPC_ROUTER_XPRT_EVENT_DATA,
+					   (void *)in_pkt);
+			release_pkt(in_pkt);
+			in_pkt = NULL;
+		}
+	}
+}
+
+static void msm_ipc_router_smd_remote_notify(void *_dev, unsigned event)
+{
+	if (event == SMD_EVENT_DATA) {
+		if (smd_read_avail(smd_remote_xprt.channel))
+			queue_delayed_work(smd_xprt_workqueue,
+					   &work_read_data, 0);
+		if (smd_write_avail(smd_remote_xprt.channel))
+			wake_up(&write_avail_wait_q);
+	}
+}
+
+static int msm_ipc_router_smd_remote_probe(struct platform_device *pdev)
+{
+	int rc;
+
+	smd_xprt_workqueue = create_singlethread_workqueue("smd_xprt");
+	if (!smd_xprt_workqueue)
+		return -ENOMEM;
+
+	smd_remote_xprt.xprt.name = "msm_ipc_router_smd_xprt";
+	smd_remote_xprt.xprt.link_id = 1;
+	smd_remote_xprt.xprt.read_avail = NULL;
+	smd_remote_xprt.xprt.read = NULL;
+	smd_remote_xprt.xprt.write_avail =
+		msm_ipc_router_smd_remote_write_avail;
+	smd_remote_xprt.xprt.write = msm_ipc_router_smd_remote_write;
+	smd_remote_xprt.xprt.close = msm_ipc_router_smd_remote_close;
+	smd_remote_xprt.xprt.priv = NULL;
+
+	init_waitqueue_head(&write_avail_wait_q);
+
+	rc = smd_open("SMD_RPCRPY_CNTL", &smd_remote_xprt.channel, NULL,
+		      msm_ipc_router_smd_remote_notify);
+	if (rc < 0) {
+		destroy_workqueue(smd_xprt_workqueue);
+		return rc;
+	}
+
+	msm_ipc_router_xprt_notify(&smd_remote_xprt.xprt,
+				  IPC_ROUTER_XPRT_EVENT_OPEN,
+				  NULL);
+	return 0;
+}
+
+static struct platform_driver msm_ipc_router_smd_remote_driver = {
+	.probe		= msm_ipc_router_smd_remote_probe,
+	.driver		= {
+			.name	= "SMD_RPCRPY_CNTL",
+			.owner	= THIS_MODULE,
+	},
+};
+
+static int __init msm_ipc_router_smd_init(void)
+{
+	return platform_driver_register(&msm_ipc_router_smd_remote_driver);
+}
+
+module_init(msm_ipc_router_smd_init);
+MODULE_DESCRIPTION("RPC Router SMD XPRT");
+MODULE_LICENSE("GPL v2");
-- 
1.7.3.3

Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.
