From: Karthikeyan Ramasubramanian <kramasub@codeaurora.org>
Subject: [PATCH 1/3] net: msm_ipc: Add Mobile Station Mode IPC Router
Date: Wed,  8 Jun 2011 11:50:48 -0600
Message-ID: <1307555448-970-1-git-send-email-kramasub@codeaurora.org>
Cc: netdev@vger.kernel.org, linux-arm-msm@vger.kernel.org,
	Karthikeyan Ramasubramanian <kramasub@codeaurora.org>
To: davem@davemloft.net
Return-path: <linux-arm-msm-owner@vger.kernel.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The MSM_IPC Router provides a connectionless message oriented
routing mechanism between the processes running in Qualcomm MSM.
The MSM_IPC Router uses the client/server model in order to provide
this routing service.

Change-Id: I0ad4e3453d4708956d732430aa341f201a81a41d
Signed-off-by: Karthikeyan Ramasubramanian <kramasub@codeaurora.org>
---
 include/linux/msm_ipc.h      |   27 +
 net/Kconfig                  |    2 +-
 net/Makefile                 |    1 +
 net/msm_ipc/Kconfig          |   15 +
 net/msm_ipc/Makefile         |    3 +
 net/msm_ipc/msm_ipc_router.c | 1671 ++++++++++++++++++++++++++++++++++++++++++
 net/msm_ipc/msm_ipc_router.h |  187 +++++
 7 files changed, 1905 insertions(+), 1 deletions(-)
 create mode 100644 include/linux/msm_ipc.h
 create mode 100644 net/msm_ipc/Kconfig
 create mode 100644 net/msm_ipc/Makefile
 create mode 100644 net/msm_ipc/msm_ipc_router.c
 create mode 100644 net/msm_ipc/msm_ipc_router.h

diff --git a/include/linux/msm_ipc.h b/include/linux/msm_ipc.h
new file mode 100644
index 0000000..47d678c
--- /dev/null
+++ b/include/linux/msm_ipc.h
@@ -0,0 +1,27 @@
+#ifndef _LINUX_MSM_IPC_H_
+#define _LINUX_MSM_IPC_H_
+
+#include <linux/types.h>
+
+#define MSM_IPC_ADDR_NAME               1
+#define MSM_IPC_ADDR_ID                 2
+
+struct msm_ipc_port_addr {
+	uint32_t node_id;
+	uint32_t port_id;
+};
+
+struct msm_ipc_port_name {
+	uint32_t service;
+	uint32_t instance;
+};
+
+struct msm_ipc_addr {
+	unsigned char  addrtype;
+	union {
+		struct msm_ipc_port_addr port_addr;
+		struct msm_ipc_port_name port_name;
+	} addr;
+};
+
+#endif
diff --git a/net/Kconfig b/net/Kconfig
index 79cabf1..b2d8e4e 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -308,6 +308,6 @@ source "net/rfkill/Kconfig"
 source "net/9p/Kconfig"
 source "net/caif/Kconfig"
 source "net/ceph/Kconfig"
-
+source "net/msm_ipc/Kconfig"
 
 endif   # if NET
diff --git a/net/Makefile b/net/Makefile
index a51d946..0820826 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -68,3 +68,4 @@ obj-$(CONFIG_WIMAX)		+= wimax/
 obj-$(CONFIG_DNS_RESOLVER)	+= dns_resolver/
 obj-$(CONFIG_CEPH_LIB)		+= ceph/
 obj-$(CONFIG_BATMAN_ADV)	+= batman-adv/
+obj-$(CONFIG_MSM_IPC)		+= msm_ipc/
diff --git a/net/msm_ipc/Kconfig b/net/msm_ipc/Kconfig
new file mode 100644
index 0000000..9114d7d
--- /dev/null
+++ b/net/msm_ipc/Kconfig
@@ -0,0 +1,15 @@
+#
+# MSM_IPC net configurations
+#
+
+menuconfig MSM_IPC
+	tristate "MSM_IPC support"
+	default n
+	---help---
+	The "Mobile Station Modem Inter-Process Communication" (MSM_IPC)
+	is a connectionless message/packet oriented Routing protocol
+	developed by Qualcomm for use with its modems. It is accessed
+	from user space as sockets (PF_MSM_IPC).
+
+	Say Y (or M) here if you build for a phone product (e.g. Android)
+	that uses MSM_IPC as transport, if unsure say N.
diff --git a/net/msm_ipc/Makefile b/net/msm_ipc/Makefile
new file mode 100644
index 0000000..461c510
--- /dev/null
+++ b/net/msm_ipc/Makefile
@@ -0,0 +1,3 @@
+obj-$(CONFIG_MSM_IPC) := msm_ipc.o
+
+msm_ipc-y += msm_ipc_router.o
diff --git a/net/msm_ipc/msm_ipc_router.c b/net/msm_ipc/msm_ipc_router.c
new file mode 100644
index 0000000..76deacb
--- /dev/null
+++ b/net/msm_ipc/msm_ipc_router.c
@@ -0,0 +1,1671 @@
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
+
+#include <linux/slab.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/init.h>
+#include <linux/types.h>
+#include <linux/delay.h>
+#include <linux/err.h>
+#include <linux/sched.h>
+#include <linux/poll.h>
+#include <linux/platform_device.h>
+#include <linux/uaccess.h>
+#include <linux/debugfs.h>
+#include <linux/uaccess.h>
+
+#include <asm/byteorder.h>
+
+#include "msm_ipc_router.h"
+
+static LIST_HEAD(control_ports);
+static DEFINE_MUTEX(control_ports_lock);
+
+#define LP_HASH_SIZE 32
+static struct list_head local_ports[LP_HASH_SIZE];
+static DEFINE_MUTEX(local_ports_lock);
+
+#define SRV_HASH_SIZE 32
+static struct list_head server_list[SRV_HASH_SIZE];
+static DEFINE_MUTEX(server_list_lock);
+static wait_queue_head_t newserver_wait;
+
+struct msm_ipc_server {
+	struct list_head list;
+	struct msm_ipc_port_name name;
+	struct list_head server_port_list;
+};
+
+struct msm_ipc_server_port {
+	struct list_head list;
+	struct msm_ipc_port_addr server_addr;
+};
+
+#define RP_HASH_SIZE 32
+struct msm_ipc_router_remote_port {
+	struct list_head list;
+	uint32_t node_id;
+	uint32_t port_id;
+	wait_queue_head_t quota_wait;
+	uint32_t tx_quota_cnt;
+	struct mutex quota_lock;
+};
+
+struct msm_ipc_router_xprt_info {
+	struct list_head list;
+
+	struct msm_ipc_router_xprt *xprt;
+	uint32_t remote_node_id;
+	uint32_t initialized;
+	struct list_head pkt_list;
+	wait_queue_head_t read_wait;
+	struct mutex rx_lock;
+	struct mutex tx_lock;
+	uint32_t need_len;
+	struct work_struct read_data;
+	struct workqueue_struct *workqueue;
+};
+
+#define RT_HASH_SIZE 4
+struct msm_ipc_routing_table_entry {
+	struct list_head list;
+	uint32_t node_id;
+	struct list_head remote_port_list[RP_HASH_SIZE];
+	struct msm_ipc_router_xprt_info *xprt_info;
+	struct mutex lock;
+	unsigned long num_tx_bytes;
+	unsigned long num_rx_bytes;
+};
+
+static struct list_head routing_table[RT_HASH_SIZE];
+static DEFINE_MUTEX(routing_table_lock);
+static int routing_table_inited;
+
+static LIST_HEAD(msm_ipc_board_dev_list);
+static DEFINE_MUTEX(msm_ipc_board_dev_list_lock);
+
+static void do_read_data(struct work_struct *work);
+
+static LIST_HEAD(xprt_info_list);
+static DEFINE_MUTEX(xprt_info_list_lock);
+
+static uint32_t next_port_id;
+static DEFINE_MUTEX(next_port_id_lock);
+
+enum {
+	CLIENT_PORT,
+	SERVER_PORT,
+	CONTROL_PORT,
+};
+
+enum {
+	DOWN,
+	UP,
+};
+
+static void init_routing_table(void)
+{
+	int i;
+	for (i = 0; i < RT_HASH_SIZE; i++)
+		INIT_LIST_HEAD(&routing_table[i]);
+}
+
+static struct msm_ipc_routing_table_entry *alloc_routing_table_entry(
+	uint32_t node_id)
+{
+	int i;
+	struct msm_ipc_routing_table_entry *rt_entry;
+
+	rt_entry = kmalloc(sizeof(struct msm_ipc_routing_table_entry),
+			   GFP_KERNEL);
+	if (!rt_entry) {
+		pr_err("%s: rt_entry allocation failed for %d\n",
+			__func__, node_id);
+		return NULL;
+	}
+
+	for (i = 0; i < RP_HASH_SIZE; i++)
+		INIT_LIST_HEAD(&rt_entry->remote_port_list[i]);
+
+	mutex_init(&rt_entry->lock);
+	rt_entry->node_id = node_id;
+	rt_entry->xprt_info = NULL;
+	return rt_entry;
+}
+
+/*Please take routing_table_lock before calling this function*/
+static int add_routing_table_entry(
+	struct msm_ipc_routing_table_entry *rt_entry)
+{
+	uint32_t key;
+
+	if (!rt_entry)
+		return -EINVAL;
+
+	key = (rt_entry->node_id % RT_HASH_SIZE);
+	list_add_tail(&rt_entry->list, &routing_table[key]);
+	return 0;
+}
+
+/*Please take routing_table_lock before calling this function*/
+static struct msm_ipc_routing_table_entry *lookup_routing_table(
+	uint32_t node_id)
+{
+	uint32_t key = (node_id % RT_HASH_SIZE);
+	struct msm_ipc_routing_table_entry *rt_entry;
+
+	list_for_each_entry(rt_entry, &routing_table[key], list) {
+		if (rt_entry->node_id == node_id)
+			return rt_entry;
+	}
+	return NULL;
+}
+
+struct rr_packet *rr_read(struct msm_ipc_router_xprt_info *xprt_info)
+{
+	struct rr_packet *temp_pkt;
+
+	if (!xprt_info)
+		return NULL;
+
+	mutex_lock(&xprt_info->rx_lock);
+	while (list_empty(&xprt_info->pkt_list)) {
+		mutex_unlock(&xprt_info->rx_lock);
+		wait_event(xprt_info->read_wait,
+			   !list_empty(&xprt_info->pkt_list));
+		mutex_lock(&xprt_info->rx_lock);
+	}
+	temp_pkt = list_first_entry(&xprt_info->pkt_list,
+				    struct rr_packet, list);
+	list_del(&temp_pkt->list);
+	mutex_unlock(&xprt_info->rx_lock);
+	return temp_pkt;
+}
+
+struct rr_packet *clone_pkt(struct rr_packet *pkt)
+{
+	struct rr_packet *cloned_pkt;
+	struct sk_buff *temp_skb, *cloned_skb;
+	struct sk_buff_head *pkt_fragment_q;
+
+	cloned_pkt = kzalloc(sizeof(struct rr_packet), GFP_KERNEL);
+	if (!cloned_pkt) {
+		pr_err("%s: failure\n", __func__);
+		return NULL;
+	}
+
+	pkt_fragment_q = kmalloc(sizeof(struct sk_buff_head), GFP_KERNEL);
+	if (!pkt_fragment_q) {
+		pr_err("%s: pkt_frag_q alloc failure\n", __func__);
+		kfree(cloned_pkt);
+		return NULL;
+	}
+	skb_queue_head_init(pkt_fragment_q);
+
+	skb_queue_walk(pkt->pkt_fragment_q, temp_skb) {
+		cloned_skb = skb_clone(temp_skb, GFP_KERNEL);
+		if (!cloned_skb)
+			goto fail_clone;
+		skb_queue_tail(pkt_fragment_q, cloned_skb);
+	}
+	cloned_pkt->pkt_fragment_q = pkt_fragment_q;
+	cloned_pkt->length = pkt->length;
+	return cloned_pkt;
+
+fail_clone:
+	while (!skb_queue_empty(pkt_fragment_q)) {
+		temp_skb = skb_dequeue(pkt_fragment_q);
+		kfree_skb(temp_skb);
+	}
+	kfree(pkt_fragment_q);
+	kfree(cloned_pkt);
+	return NULL;
+}
+
+struct rr_packet *create_pkt(struct sk_buff_head *data)
+{
+	struct rr_packet *pkt;
+	struct sk_buff *temp_skb;
+
+	pkt = kzalloc(sizeof(struct rr_packet), GFP_KERNEL);
+	if (!pkt) {
+		pr_err("%s: failure\n", __func__);
+		return NULL;
+	}
+
+	pkt->pkt_fragment_q = data;
+	skb_queue_walk(pkt->pkt_fragment_q, temp_skb)
+		pkt->length += temp_skb->len;
+	return pkt;
+}
+
+void release_pkt(struct rr_packet *pkt)
+{
+	struct sk_buff *temp_skb;
+
+	if (!pkt)
+		return;
+
+	if (!pkt->pkt_fragment_q) {
+		kfree(pkt);
+		return;
+	}
+
+	while (!skb_queue_empty(pkt->pkt_fragment_q)) {
+		temp_skb = skb_dequeue(pkt->pkt_fragment_q);
+		kfree_skb(temp_skb);
+	}
+	kfree(pkt->pkt_fragment_q);
+	kfree(pkt);
+	return;
+}
+
+static int post_control_ports(struct rr_packet *pkt)
+{
+	struct msm_ipc_port *port_ptr;
+	struct rr_packet *cloned_pkt;
+
+	if (!pkt)
+		return -EINVAL;
+
+	mutex_lock(&control_ports_lock);
+	list_for_each_entry(port_ptr, &control_ports, list) {
+		mutex_lock(&port_ptr->port_rx_q_lock);
+		cloned_pkt = clone_pkt(pkt);
+		list_add_tail(&cloned_pkt->list, &port_ptr->port_rx_q);
+		wake_up(&port_ptr->port_rx_wait_q);
+		mutex_unlock(&port_ptr->port_rx_q_lock);
+	}
+	mutex_unlock(&control_ports_lock);
+	return 0;
+}
+
+static uint32_t allocate_port_id(void)
+{
+	uint32_t port_id = 0, prev_port_id, key;
+	struct msm_ipc_port *port_ptr;
+
+	mutex_lock(&next_port_id_lock);
+	prev_port_id = next_port_id;
+	mutex_lock(&local_ports_lock);
+	do {
+		next_port_id++;
+		if ((next_port_id & 0xFFFFFFFE) == 0xFFFFFFFE)
+			next_port_id = 1;
+
+		key = (next_port_id & (LP_HASH_SIZE - 1));
+		if (list_empty(&local_ports[key])) {
+			port_id = next_port_id;
+			break;
+		}
+		list_for_each_entry(port_ptr, &local_ports[key], list) {
+			if (port_ptr->this_port.port_id == next_port_id) {
+				port_id = next_port_id;
+				break;
+			}
+		}
+		if (!port_id) {
+			port_id = next_port_id;
+			break;
+		}
+		port_id = 0;
+	} while (next_port_id != prev_port_id);
+	mutex_unlock(&local_ports_lock);
+	mutex_unlock(&next_port_id_lock);
+
+	return port_id;
+}
+
+void msm_ipc_router_add_local_port(struct msm_ipc_port *port_ptr)
+{
+	uint32_t key;
+
+	if (!port_ptr)
+		return;
+
+	key = (port_ptr->this_port.port_id & (LP_HASH_SIZE - 1));
+	mutex_lock(&local_ports_lock);
+	list_add_tail(&port_ptr->list, &local_ports[key]);
+	mutex_unlock(&local_ports_lock);
+}
+
+struct msm_ipc_port *msm_ipc_router_create_raw_port(void *endpoint,
+		void (*notify)(unsigned event, void *data,
+			       void *addr, void *priv),
+		void *priv)
+{
+	struct msm_ipc_port *port_ptr;
+
+	port_ptr = kzalloc(sizeof(struct msm_ipc_port), GFP_KERNEL);
+	if (!port_ptr)
+		return NULL;
+
+	port_ptr->this_port.node_id = IPC_ROUTER_NID_LOCAL;
+	port_ptr->this_port.port_id = allocate_port_id();
+	if (!port_ptr->this_port.port_id) {
+		pr_err("%s: All port ids are in use\n", __func__);
+		kfree(port_ptr);
+		return NULL;
+	}
+
+	spin_lock_init(&port_ptr->port_lock);
+	INIT_LIST_HEAD(&port_ptr->incomplete);
+	mutex_init(&port_ptr->incomplete_lock);
+	INIT_LIST_HEAD(&port_ptr->port_rx_q);
+	mutex_init(&port_ptr->port_rx_q_lock);
+	init_waitqueue_head(&port_ptr->port_rx_wait_q);
+
+	port_ptr->endpoint = endpoint;
+	port_ptr->notify = notify;
+	port_ptr->priv = priv;
+
+	msm_ipc_router_add_local_port(port_ptr);
+	return port_ptr;
+}
+
+static struct msm_ipc_port *msm_ipc_router_lookup_local_port(uint32_t port_id)
+{
+	int key = (port_id & (LP_HASH_SIZE - 1));
+	struct msm_ipc_port *port_ptr;
+
+	mutex_lock(&local_ports_lock);
+	list_for_each_entry(port_ptr, &local_ports[key], list) {
+		if (port_ptr->this_port.port_id == port_id) {
+			mutex_unlock(&local_ports_lock);
+			return port_ptr;
+		}
+	}
+	mutex_unlock(&local_ports_lock);
+	return NULL;
+}
+
+static struct msm_ipc_router_remote_port *msm_ipc_router_lookup_remote_port(
+						uint32_t node_id,
+						uint32_t port_id)
+{
+	struct msm_ipc_router_remote_port *rport_ptr;
+	struct msm_ipc_routing_table_entry *rt_entry;
+	int key = (port_id & (RP_HASH_SIZE - 1));
+
+	mutex_lock(&routing_table_lock);
+	rt_entry = lookup_routing_table(node_id);
+	if (!rt_entry) {
+		mutex_unlock(&routing_table_lock);
+		pr_err("%s: Node is not up\n", __func__);
+		return NULL;
+	}
+
+	mutex_lock(&rt_entry->lock);
+	list_for_each_entry(rport_ptr,
+			    &rt_entry->remote_port_list[key], list) {
+		if (rport_ptr->port_id == port_id) {
+			mutex_unlock(&rt_entry->lock);
+			mutex_unlock(&routing_table_lock);
+			return rport_ptr;
+		}
+	}
+	mutex_unlock(&rt_entry->lock);
+	mutex_unlock(&routing_table_lock);
+	return NULL;
+}
+
+static struct msm_ipc_router_remote_port *msm_ipc_router_create_remote_port(
+						uint32_t node_id,
+						uint32_t port_id)
+{
+	struct msm_ipc_router_remote_port *rport_ptr;
+	struct msm_ipc_routing_table_entry *rt_entry;
+	int key = (port_id & (RP_HASH_SIZE - 1));
+
+	mutex_lock(&routing_table_lock);
+	rt_entry = lookup_routing_table(node_id);
+	if (!rt_entry) {
+		mutex_unlock(&routing_table_lock);
+		pr_err("%s: Node is not up\n", __func__);
+		return NULL;
+	}
+
+	mutex_lock(&rt_entry->lock);
+	rport_ptr = kmalloc(sizeof(struct msm_ipc_router_remote_port),
+			    GFP_KERNEL);
+	if (!rport_ptr) {
+		mutex_unlock(&rt_entry->lock);
+		mutex_unlock(&routing_table_lock);
+		pr_err("%s: Remote port alloc failed\n", __func__);
+		return NULL;
+	}
+	rport_ptr->port_id = port_id;
+	rport_ptr->node_id = node_id;
+	rport_ptr->tx_quota_cnt = 0;
+	init_waitqueue_head(&rport_ptr->quota_wait);
+	mutex_init(&rport_ptr->quota_lock);
+	list_add_tail(&rport_ptr->list,
+		      &rt_entry->remote_port_list[key]);
+	mutex_unlock(&rt_entry->lock);
+	mutex_unlock(&routing_table_lock);
+	return rport_ptr;
+}
+
+static void msm_ipc_router_destroy_remote_port(
+	struct msm_ipc_router_remote_port *rport_ptr)
+{
+	uint32_t node_id;
+	struct msm_ipc_routing_table_entry *rt_entry;
+
+	if (!rport_ptr)
+		return;
+
+	node_id = rport_ptr->node_id;
+	mutex_lock(&routing_table_lock);
+	rt_entry = lookup_routing_table(node_id);
+	if (!rt_entry) {
+		mutex_unlock(&routing_table_lock);
+		pr_err("%s: Node %d is not up\n", __func__, node_id);
+		return;
+	}
+
+	mutex_lock(&rt_entry->lock);
+	list_del(&rport_ptr->list);
+	kfree(rport_ptr);
+	mutex_unlock(&rt_entry->lock);
+	mutex_unlock(&routing_table_lock);
+	return;
+}
+
+static struct msm_ipc_server *msm_ipc_router_lookup_server(
+				uint32_t service,
+				uint32_t instance,
+				uint32_t node_id,
+				uint32_t port_id)
+{
+	struct msm_ipc_server *server;
+	struct msm_ipc_server_port *server_port;
+	int key = (instance & (SRV_HASH_SIZE - 1));
+
+	mutex_lock(&server_list_lock);
+	list_for_each_entry(server, &server_list[key], list) {
+		if ((server->name.service != service) ||
+		    (server->name.instance != instance))
+			continue;
+		if ((node_id == 0) && (port_id == 0)) {
+			mutex_unlock(&server_list_lock);
+			return server;
+		}
+		list_for_each_entry(server_port, &server->server_port_list,
+				    list) {
+			if ((server_port->server_addr.node_id == node_id) &&
+			    (server_port->server_addr.port_id == port_id)) {
+				mutex_unlock(&server_list_lock);
+				return server;
+			}
+		}
+	}
+	mutex_unlock(&server_list_lock);
+	return NULL;
+}
+
+static struct msm_ipc_server *msm_ipc_router_create_server(
+					uint32_t service,
+					uint32_t instance,
+					uint32_t node_id,
+					uint32_t port_id)
+{
+	struct msm_ipc_server *server = NULL;
+	struct msm_ipc_server_port *server_port;
+	int key = (instance & (SRV_HASH_SIZE - 1));
+
+	mutex_lock(&server_list_lock);
+	list_for_each_entry(server, &server_list[key], list) {
+		if ((server->name.service == service) &&
+		    (server->name.instance == instance))
+			goto create_srv_port;
+	}
+
+	server = kmalloc(sizeof(struct msm_ipc_server), GFP_KERNEL);
+	if (!server) {
+		mutex_unlock(&server_list_lock);
+		pr_err("%s: Server allocation failed\n", __func__);
+		return NULL;
+	}
+	server->name.service = service;
+	server->name.instance = instance;
+	INIT_LIST_HEAD(&server->server_port_list);
+	list_add_tail(&server->list, &server_list[key]);
+
+create_srv_port:
+	server_port = kmalloc(sizeof(struct msm_ipc_server_port), GFP_KERNEL);
+	if (!server_port) {
+		if (list_empty(&server->server_port_list)) {
+			list_del(&server->list);
+			kfree(server);
+		}
+		mutex_unlock(&server_list_lock);
+		pr_err("%s: Server Port allocation failed\n", __func__);
+		return NULL;
+	}
+	server_port->server_addr.node_id = node_id;
+	server_port->server_addr.port_id = port_id;
+	list_add_tail(&server_port->list, &server->server_port_list);
+	mutex_unlock(&server_list_lock);
+
+	return server;
+}
+
+static void msm_ipc_router_destroy_server(struct msm_ipc_server *server,
+					  uint32_t node_id, uint32_t port_id)
+{
+	struct msm_ipc_server_port *server_port;
+
+	if (!server)
+		return;
+
+	mutex_lock(&server_list_lock);
+	list_for_each_entry(server_port, &server->server_port_list, list) {
+		if ((server_port->server_addr.node_id == node_id) &&
+		    (server_port->server_addr.port_id == port_id))
+			break;
+	}
+	if (server_port) {
+		list_del(&server_port->list);
+		kfree(server_port);
+	}
+	if (list_empty(&server->server_port_list)) {
+		list_del(&server->list);
+		kfree(server);
+	}
+	mutex_unlock(&server_list_lock);
+	return;
+}
+
+static int msm_ipc_router_send_control_msg(
+		struct msm_ipc_router_xprt_info *xprt_info,
+		union rr_control_msg *msg)
+{
+	struct rr_packet *pkt;
+	struct sk_buff *ipc_rtr_pkt;
+	struct rr_header *hdr;
+	int pkt_size;
+	void *data;
+	struct sk_buff_head *pkt_fragment_q;
+	int ret;
+
+	if (!xprt_info || ((msg->cmd != IPC_ROUTER_CTRL_CMD_HELLO) &&
+	    !xprt_info->initialized)) {
+		pr_err("%s: xprt_info not initialized\n", __func__);
+		return -EINVAL;
+	}
+
+	if (xprt_info->remote_node_id == IPC_ROUTER_NID_LOCAL)
+		return 0;
+
+	pkt = kzalloc(sizeof(struct rr_packet), GFP_KERNEL);
+	if (!pkt) {
+		pr_err("%s: pkt alloc failed\n", __func__);
+		return -ENOMEM;
+	}
+
+	pkt_fragment_q = kmalloc(sizeof(struct sk_buff_head), GFP_KERNEL);
+	if (!pkt_fragment_q) {
+		pr_err("%s: pkt_fragment_q alloc failed\n", __func__);
+		kfree(pkt);
+		return -ENOMEM;
+	}
+	skb_queue_head_init(pkt_fragment_q);
+
+	pkt_size = IPC_ROUTER_HDR_SIZE + sizeof(*msg);
+	ipc_rtr_pkt = alloc_skb(pkt_size, GFP_KERNEL);
+	if (!ipc_rtr_pkt) {
+		pr_err("%s: ipc_rtr_pkt alloc failed\n", __func__);
+		kfree(pkt_fragment_q);
+		kfree(pkt);
+		return -ENOMEM;
+	}
+
+	skb_reserve(ipc_rtr_pkt, IPC_ROUTER_HDR_SIZE);
+	data = skb_put(ipc_rtr_pkt, sizeof(*msg));
+	memcpy(data, msg, sizeof(*msg));
+	hdr = (struct rr_header *)skb_push(ipc_rtr_pkt, IPC_ROUTER_HDR_SIZE);
+	if (!hdr) {
+		pr_err("%s: skb_push failed\n", __func__);
+		kfree_skb(ipc_rtr_pkt);
+		kfree(pkt_fragment_q);
+		kfree(pkt);
+		return -ENOMEM;
+	}
+
+	hdr->version = IPC_ROUTER_VERSION;
+	hdr->type = msg->cmd;
+	hdr->src_node_id = IPC_ROUTER_NID_LOCAL;
+	hdr->src_port_id = IPC_ROUTER_ADDRESS;
+	hdr->confirm_rx = 0;
+	hdr->size = sizeof(*msg);
+	hdr->dst_node_id = xprt_info->remote_node_id;
+	hdr->dst_port_id = IPC_ROUTER_ADDRESS;
+	skb_queue_tail(pkt_fragment_q, ipc_rtr_pkt);
+	pkt->pkt_fragment_q = pkt_fragment_q;
+	pkt->length = pkt_size;
+
+	mutex_lock(&xprt_info->tx_lock);
+	ret = xprt_info->xprt->write(pkt, pkt_size, 0);
+	mutex_unlock(&xprt_info->tx_lock);
+
+	release_pkt(pkt);
+	return ret;
+}
+
+static int msm_ipc_router_send_server_list(
+		struct msm_ipc_router_xprt_info *xprt_info)
+{
+	union rr_control_msg ctl;
+	struct msm_ipc_server *server;
+	struct msm_ipc_server_port *server_port;
+	int i;
+
+	if (!xprt_info || !xprt_info->initialized) {
+		pr_err("%s: Xprt info not initialized\n", __func__);
+		return -EINVAL;
+	}
+
+	ctl.cmd = IPC_ROUTER_CTRL_CMD_NEW_SERVER;
+
+	mutex_lock(&server_list_lock);
+	for (i = 0; i < SRV_HASH_SIZE; i++) {
+		list_for_each_entry(server, &server_list[i], list) {
+			ctl.srv.service = server->name.service;
+			ctl.srv.instance = server->name.instance;
+			list_for_each_entry(server_port,
+					    &server->server_port_list, list) {
+				if (server_port->server_addr.node_id ==
+				    xprt_info->remote_node_id)
+					continue;
+
+				ctl.srv.node_id =
+					server_port->server_addr.node_id;
+				ctl.srv.port_id =
+					server_port->server_addr.port_id;
+				msm_ipc_router_send_control_msg(xprt_info,
+								&ctl);
+			}
+		}
+	}
+	mutex_unlock(&server_list_lock);
+
+	return 0;
+}
+
+static int broadcast_ctl_msg_locally(union rr_control_msg *msg)
+{
+	struct rr_packet *pkt;
+	struct sk_buff *ipc_rtr_pkt;
+	struct rr_header *hdr;
+	int pkt_size;
+	void *data;
+	struct sk_buff_head *pkt_fragment_q;
+	int ret;
+
+	pkt = kzalloc(sizeof(struct rr_packet), GFP_KERNEL);
+	if (!pkt) {
+		pr_err("%s: pkt alloc failed\n", __func__);
+		return -ENOMEM;
+	}
+
+	pkt_fragment_q = kmalloc(sizeof(struct sk_buff_head), GFP_KERNEL);
+	if (!pkt_fragment_q) {
+		pr_err("%s: pkt_fragment_q alloc failed\n", __func__);
+		kfree(pkt);
+		return -ENOMEM;
+	}
+	skb_queue_head_init(pkt_fragment_q);
+
+	pkt_size = IPC_ROUTER_HDR_SIZE + sizeof(*msg);
+	ipc_rtr_pkt = alloc_skb(pkt_size, GFP_KERNEL);
+	if (!ipc_rtr_pkt) {
+		pr_err("%s: ipc_rtr_pkt alloc failed\n", __func__);
+		kfree(pkt_fragment_q);
+		kfree(pkt);
+		return -ENOMEM;
+	}
+
+	skb_reserve(ipc_rtr_pkt, IPC_ROUTER_HDR_SIZE);
+	data = skb_put(ipc_rtr_pkt, sizeof(*msg));
+	memcpy(data, msg, sizeof(*msg));
+	hdr = (struct rr_header *)skb_push(ipc_rtr_pkt, IPC_ROUTER_HDR_SIZE);
+	if (!hdr) {
+		pr_err("%s: skb_push failed\n", __func__);
+		kfree_skb(ipc_rtr_pkt);
+		kfree(pkt_fragment_q);
+		kfree(pkt);
+		return -ENOMEM;
+	}
+	hdr->version = IPC_ROUTER_VERSION;
+	hdr->type = msg->cmd;
+	hdr->src_node_id = IPC_ROUTER_NID_LOCAL;
+	hdr->src_port_id = IPC_ROUTER_ADDRESS;
+	hdr->confirm_rx = 0;
+	hdr->size = sizeof(*msg);
+	hdr->dst_node_id = IPC_ROUTER_NID_LOCAL;
+	hdr->dst_port_id = IPC_ROUTER_ADDRESS;
+	skb_queue_tail(pkt_fragment_q, ipc_rtr_pkt);
+	pkt->pkt_fragment_q = pkt_fragment_q;
+	pkt->length = pkt_size;
+
+	ret = post_control_ports(pkt);
+	release_pkt(pkt);
+	return ret;
+}
+
+static int broadcast_ctl_msg(union rr_control_msg *ctl)
+{
+	struct msm_ipc_router_xprt_info *xprt_info;
+
+	mutex_lock(&xprt_info_list_lock);
+	list_for_each_entry(xprt_info, &xprt_info_list, list) {
+		msm_ipc_router_send_control_msg(xprt_info, ctl);
+	}
+	mutex_unlock(&xprt_info_list_lock);
+
+	return 0;
+}
+
+static int relay_msg(struct msm_ipc_router_xprt_info *xprt_info,
+		     struct rr_packet *pkt)
+{
+	struct msm_ipc_router_xprt_info *fwd_xprt_info;
+
+	if (!xprt_info || !pkt)
+		return -EINVAL;
+
+	mutex_lock(&xprt_info_list_lock);
+	list_for_each_entry(fwd_xprt_info, &xprt_info_list, list) {
+		mutex_lock(&fwd_xprt_info->tx_lock);
+		if (xprt_info->xprt->link_id != fwd_xprt_info->xprt->link_id)
+			fwd_xprt_info->xprt->write(pkt, pkt->length, 0);
+		mutex_unlock(&fwd_xprt_info->tx_lock);
+	}
+	mutex_unlock(&xprt_info_list_lock);
+	return 0;
+}
+
+static int forward_msg(struct msm_ipc_router_xprt_info *xprt_info,
+		       struct rr_packet *pkt)
+{
+	uint32_t dst_node_id;
+	struct sk_buff *head_pkt;
+	struct rr_header *hdr;
+	struct msm_ipc_router_xprt_info *fwd_xprt_info;
+	struct msm_ipc_routing_table_entry *rt_entry;
+
+	if (!xprt_info || !pkt)
+		return -EINVAL;
+
+	head_pkt = skb_peek(pkt->pkt_fragment_q);
+	if (!head_pkt)
+		return -EINVAL;
+
+	hdr = (struct rr_header *)head_pkt->data;
+	dst_node_id = hdr->dst_node_id;
+	mutex_lock(&routing_table_lock);
+	rt_entry = lookup_routing_table(dst_node_id);
+	if (!(rt_entry) || !(rt_entry->xprt_info)) {
+		mutex_unlock(&routing_table_lock);
+		pr_err("%s: Routing table not initialized\n", __func__);
+		return -ENODEV;
+	}
+
+	mutex_lock(&rt_entry->lock);
+	fwd_xprt_info = rt_entry->xprt_info;
+	mutex_lock(&fwd_xprt_info->tx_lock);
+	if (xprt_info->remote_node_id == fwd_xprt_info->remote_node_id) {
+		mutex_unlock(&fwd_xprt_info->tx_lock);
+		mutex_unlock(&rt_entry->lock);
+		mutex_unlock(&routing_table_lock);
+		pr_err("%s: Discarding Command to route back\n", __func__);
+		return -EINVAL;
+	}
+
+	if (xprt_info->xprt->link_id == fwd_xprt_info->xprt->link_id) {
+		mutex_unlock(&fwd_xprt_info->tx_lock);
+		mutex_unlock(&rt_entry->lock);
+		mutex_unlock(&routing_table_lock);
+		pr_err("%s: DST in the same cluster\n", __func__);
+		return 0;
+	}
+	fwd_xprt_info->xprt->write(pkt, pkt->length, 0);
+	mutex_unlock(&fwd_xprt_info->tx_lock);
+	mutex_unlock(&rt_entry->lock);
+	mutex_unlock(&routing_table_lock);
+
+	return 0;
+}
+
+static int process_control_msg(struct msm_ipc_router_xprt_info *xprt_info,
+			       struct rr_packet *pkt)
+{
+	union rr_control_msg ctl;
+	union rr_control_msg *msg;
+	struct msm_ipc_router_remote_port *rport_ptr;
+	int rc = 0;
+	struct sk_buff *temp_ptr;
+	struct rr_header *hdr;
+	struct msm_ipc_server *server;
+	struct msm_ipc_routing_table_entry *rt_entry;
+
+	if (pkt->length != (IPC_ROUTER_HDR_SIZE + sizeof(*msg))) {
+		pr_err("%s: r2r msg size %d != %d\n", __func__, pkt->length,
+			(IPC_ROUTER_HDR_SIZE + sizeof(*msg)));
+		return -EINVAL;
+	}
+
+	temp_ptr = skb_peek(pkt->pkt_fragment_q);
+	hdr = (struct rr_header *)temp_ptr->data;
+	msg = (union rr_control_msg *)((char *)hdr + IPC_ROUTER_HDR_SIZE);
+
+	switch (msg->cmd) {
+	case IPC_ROUTER_CTRL_CMD_HELLO:
+		xprt_info->remote_node_id = hdr->src_node_id;
+
+		mutex_lock(&routing_table_lock);
+		rt_entry = lookup_routing_table(hdr->src_node_id);
+		if (!rt_entry) {
+			rt_entry = alloc_routing_table_entry(hdr->src_node_id);
+			if (!rt_entry) {
+				mutex_unlock(&routing_table_lock);
+				pr_err("%s: rt_entry allocation failed\n",
+					__func__);
+				return -ENOMEM;
+			}
+		}
+		mutex_lock(&rt_entry->lock);
+		rt_entry->xprt_info = xprt_info;
+		mutex_unlock(&rt_entry->lock);
+		add_routing_table_entry(rt_entry);
+		mutex_unlock(&routing_table_lock);
+
+		memset(&ctl, 0, sizeof(ctl));
+		ctl.cmd = IPC_ROUTER_CTRL_CMD_HELLO;
+		msm_ipc_router_send_control_msg(xprt_info, &ctl);
+
+		xprt_info->initialized = 1;
+
+		/* Send list of servers one at a time */
+		msm_ipc_router_send_server_list(xprt_info);
+
+		break;
+	case IPC_ROUTER_CTRL_CMD_RESUME_TX:
+
+		rport_ptr = msm_ipc_router_lookup_remote_port(msg->cli.node_id,
+							msg->cli.port_id);
+		if (!rport_ptr) {
+			pr_err("%s: Unable to resume client\n", __func__);
+			break;
+		}
+		mutex_lock(&rport_ptr->quota_lock);
+		rport_ptr->tx_quota_cnt = 0;
+		mutex_unlock(&rport_ptr->quota_lock);
+		wake_up(&rport_ptr->quota_wait);
+		break;
+
+	case IPC_ROUTER_CTRL_CMD_NEW_SERVER:
+		if (msg->srv.instance == 0) {
+			pr_err(
+			"rpcrouter: Server create rejected, version = 0, "
+			"service = %08x\n", msg->srv.service);
+			break;
+		}
+
+		mutex_lock(&routing_table_lock);
+		rt_entry = lookup_routing_table(msg->srv.node_id);
+		if (!rt_entry) {
+			rt_entry = alloc_routing_table_entry(msg->srv.node_id);
+			if (!rt_entry) {
+				mutex_unlock(&routing_table_lock);
+				pr_err("%s: rt_entry allocation failed\n",
+					__func__);
+				return -ENOMEM;
+			}
+			mutex_lock(&rt_entry->lock);
+			rt_entry->xprt_info = xprt_info;
+			mutex_unlock(&rt_entry->lock);
+			add_routing_table_entry(rt_entry);
+		}
+		mutex_unlock(&routing_table_lock);
+
+		server = msm_ipc_router_lookup_server(msg->srv.service,
+						      msg->srv.instance,
+						      msg->srv.node_id,
+						      msg->srv.port_id);
+		if (!server) {
+			server = msm_ipc_router_create_server(
+				msg->srv.service, msg->srv.instance,
+				msg->srv.node_id, msg->srv.port_id);
+			if (!server) {
+				pr_err("%s: Server Create failed\n", __func__);
+				return -ENOMEM;
+			}
+
+			if (!msm_ipc_router_lookup_remote_port(
+					msg->srv.node_id, msg->srv.port_id)) {
+				rport_ptr = msm_ipc_router_create_remote_port(
+					msg->srv.node_id, msg->srv.port_id);
+				if (!rport_ptr)
+					pr_err("%s: Remote port create "
+					       "failed\n", __func__);
+			}
+			wake_up(&newserver_wait);
+		}
+
+		relay_msg(xprt_info, pkt);
+		post_control_ports(pkt);
+		break;
+	case IPC_ROUTER_CTRL_CMD_REMOVE_SERVER:
+		server = msm_ipc_router_lookup_server(msg->srv.service,
+						      msg->srv.instance,
+						      msg->srv.node_id,
+						      msg->srv.port_id);
+		if (server) {
+			msm_ipc_router_destroy_server(server,
+						      msg->srv.node_id,
+						      msg->srv.port_id);
+			relay_msg(xprt_info, pkt);
+			post_control_ports(pkt);
+		}
+		break;
+	case IPC_ROUTER_CTRL_CMD_REMOVE_CLIENT:
+		rport_ptr = msm_ipc_router_lookup_remote_port(msg->cli.node_id,
+							msg->cli.port_id);
+		if (rport_ptr)
+			msm_ipc_router_destroy_remote_port(rport_ptr);
+
+		relay_msg(xprt_info, pkt);
+		post_control_ports(pkt);
+		break;
+	case IPC_ROUTER_CTRL_CMD_PING:
+		/* No action needed for ping messages received */
+		break;
+	default:
+		rc = -ENOSYS;
+	}
+
+	return rc;
+}
+
+static void do_read_data(struct work_struct *work)
+{
+	struct rr_header *hdr;
+	struct rr_packet *pkt = NULL;
+	struct msm_ipc_port *port_ptr;
+	struct sk_buff *head_skb;
+	struct msm_ipc_port_addr *src_addr;
+	uint32_t resume_tx, resume_tx_node_id, resume_tx_port_id;
+
+	struct msm_ipc_router_xprt_info *xprt_info =
+		container_of(work,
+			     struct msm_ipc_router_xprt_info,
+			     read_data);
+
+	pkt = rr_read(xprt_info);
+	if (!pkt) {
+		pr_err("%s: rr_read failed\n", __func__);
+		goto fail_io;
+	}
+
+	if (pkt->length < IPC_ROUTER_HDR_SIZE ||
+	    pkt->length > MAX_IPC_PKT_SIZE) {
+		pr_err("%s: Invalid pkt length %d\n", __func__, pkt->length);
+		goto fail_data;
+	}
+
+	head_skb = skb_peek(pkt->pkt_fragment_q);
+	if (!head_skb) {
+		pr_err("%s: head_skb is invalid\n", __func__);
+		goto fail_data;
+	}
+
+	hdr = (struct rr_header *)(head_skb->data);
+
+	if (hdr->version != IPC_ROUTER_VERSION) {
+		pr_err("version %d != %d\n", hdr->version, IPC_ROUTER_VERSION);
+		goto fail_data;
+	}
+
+	if ((hdr->dst_node_id != IPC_ROUTER_NID_LOCAL) &&
+	    ((hdr->type == IPC_ROUTER_CTRL_CMD_RESUME_TX) ||
+	     (hdr->type == IPC_ROUTER_CTRL_CMD_DATA))) {
+		forward_msg(xprt_info, pkt);
+		release_pkt(pkt);
+		goto done;
+	}
+
+	if ((hdr->dst_port_id == IPC_ROUTER_ADDRESS) ||
+	    (hdr->type == IPC_ROUTER_CTRL_CMD_HELLO)) {
+		process_control_msg(xprt_info, pkt);
+		release_pkt(pkt);
+		goto done;
+	}
+
+	resume_tx = hdr->confirm_rx;
+	resume_tx_node_id = hdr->dst_node_id;
+	resume_tx_port_id = hdr->dst_port_id;
+
+	port_ptr = msm_ipc_router_lookup_local_port(hdr->dst_port_id);
+	if (!port_ptr) {
+		pr_err("%s: No local port id %08x\n", __func__,
+			hdr->dst_port_id);
+		release_pkt(pkt);
+		goto process_done;
+	}
+
+	if (!port_ptr->notify) {
+		mutex_lock(&port_ptr->port_rx_q_lock);
+		list_add_tail(&pkt->list, &port_ptr->port_rx_q);
+		wake_up(&port_ptr->port_rx_wait_q);
+		mutex_unlock(&port_ptr->port_rx_q_lock);
+	} else {
+		src_addr = kmalloc(sizeof(struct msm_ipc_port_addr),
+				   GFP_KERNEL);
+		if (src_addr) {
+			src_addr->node_id = hdr->src_node_id;
+			src_addr->port_id = hdr->src_port_id;
+		}
+		skb_pull(head_skb, IPC_ROUTER_HDR_SIZE);
+		port_ptr->notify(MSM_IPC_ROUTER_READ_CB, pkt->pkt_fragment_q,
+				 src_addr, port_ptr->priv);
+		pkt->pkt_fragment_q = NULL;
+		src_addr = NULL;
+		release_pkt(pkt);
+	}
+
+process_done:
+	if (resume_tx) {
+		union rr_control_msg msg;
+
+		msg.cmd = IPC_ROUTER_CTRL_CMD_RESUME_TX;
+		msg.cli.node_id = resume_tx_node_id;
+		msg.cli.port_id = resume_tx_port_id;
+
+		msm_ipc_router_send_control_msg(xprt_info, &msg);
+	}
+
+done:
+	queue_work(xprt_info->workqueue, &xprt_info->read_data);
+	return;
+
+fail_data:
+	release_pkt(pkt);
+fail_io:
+	pr_err("ipc_router has died\n");
+}
+
+int msm_ipc_router_register_server(struct msm_ipc_port *port_ptr,
+				   struct msm_ipc_addr *name)
+{
+	struct msm_ipc_server *server;
+	unsigned long flags;
+	union rr_control_msg ctl;
+
+	if (!port_ptr || !name)
+		return -EINVAL;
+
+	if (name->addrtype != MSM_IPC_ADDR_NAME)
+		return -EINVAL;
+
+	server = msm_ipc_router_lookup_server(name->addr.port_name.service,
+					      name->addr.port_name.instance,
+					      IPC_ROUTER_NID_LOCAL,
+					      port_ptr->this_port.port_id);
+	if (server) {
+		pr_err("%s: Server already present\n", __func__);
+		return -EINVAL;
+	}
+
+	server = msm_ipc_router_create_server(name->addr.port_name.service,
+					      name->addr.port_name.instance,
+					      IPC_ROUTER_NID_LOCAL,
+					      port_ptr->this_port.port_id);
+	if (!server) {
+		pr_err("%s: Server Creation failed\n", __func__);
+		return -EINVAL;
+	}
+
+	ctl.cmd = IPC_ROUTER_CTRL_CMD_NEW_SERVER;
+	ctl.srv.service = server->name.service;
+	ctl.srv.instance = server->name.instance;
+	ctl.srv.node_id = IPC_ROUTER_NID_LOCAL;
+	ctl.srv.port_id = port_ptr->this_port.port_id;
+	broadcast_ctl_msg(&ctl);
+	spin_lock_irqsave(&port_ptr->port_lock, flags);
+	port_ptr->type = SERVER_PORT;
+	port_ptr->port_name.service = server->name.service;
+	port_ptr->port_name.instance = server->name.instance;
+	spin_unlock_irqrestore(&port_ptr->port_lock, flags);
+	return 0;
+}
+
+int msm_ipc_router_unregister_server(struct msm_ipc_port *port_ptr)
+{
+	struct msm_ipc_server *server;
+	unsigned long flags;
+	union rr_control_msg ctl;
+
+	if (!port_ptr)
+		return -EINVAL;
+
+	if (port_ptr->type != SERVER_PORT) {
+		pr_err("%s: Trying to unregister a non-server port\n",
+			__func__);
+		return -EINVAL;
+	}
+
+	if (port_ptr->this_port.node_id != IPC_ROUTER_NID_LOCAL) {
+		pr_err("%s: Trying to unregister a remote server locally\n",
+			__func__);
+		return -EINVAL;
+	}
+
+	server = msm_ipc_router_lookup_server(port_ptr->port_name.service,
+					      port_ptr->port_name.instance,
+					      port_ptr->this_port.node_id,
+					      port_ptr->this_port.port_id);
+	if (!server) {
+		pr_err("%s: Server lookup failed\n", __func__);
+		return -ENODEV;
+	}
+
+	ctl.cmd = IPC_ROUTER_CTRL_CMD_REMOVE_SERVER;
+	ctl.srv.service = server->name.service;
+	ctl.srv.instance = server->name.instance;
+	ctl.srv.node_id = IPC_ROUTER_NID_LOCAL;
+	ctl.srv.port_id = port_ptr->this_port.port_id;
+	broadcast_ctl_msg(&ctl);
+	msm_ipc_router_destroy_server(server, port_ptr->this_port.node_id,
+				      port_ptr->this_port.port_id);
+	spin_lock_irqsave(&port_ptr->port_lock, flags);
+	port_ptr->type = CLIENT_PORT;
+	spin_unlock_irqrestore(&port_ptr->port_lock, flags);
+	return 0;
+}
+
+static int loopback_data(struct msm_ipc_port *src,
+			uint32_t port_id,
+			struct sk_buff_head *data)
+{
+	struct sk_buff *head_skb;
+	struct rr_header *hdr;
+	struct msm_ipc_port *port_ptr;
+	struct rr_packet *pkt;
+
+	if (!data) {
+		pr_err("%s: Invalid pkt pointer\n", __func__);
+		return -EINVAL;
+	}
+
+	pkt = create_pkt(data);
+	if (!pkt) {
+		pr_err("%s: New pkt create failed\n", __func__);
+		return -ENOMEM;
+	}
+
+	head_skb = skb_peek(pkt->pkt_fragment_q);
+	hdr = (struct rr_header *)skb_push(head_skb, IPC_ROUTER_HDR_SIZE);
+	if (!hdr) {
+		pr_err("%s: Prepend Header failed\n", __func__);
+		release_pkt(pkt);
+		return -ENOMEM;
+	}
+	hdr->version = IPC_ROUTER_VERSION;
+	hdr->type = IPC_ROUTER_CTRL_CMD_DATA;
+	hdr->src_node_id = src->this_port.node_id;
+	hdr->src_port_id = src->this_port.port_id;
+	hdr->size = pkt->length;
+	hdr->confirm_rx = 0;
+	hdr->dst_node_id = IPC_ROUTER_NID_LOCAL;
+	hdr->dst_port_id = port_id;
+	pkt->length += IPC_ROUTER_HDR_SIZE;
+
+	port_ptr = msm_ipc_router_lookup_local_port(port_id);
+	if (!port_ptr) {
+		pr_err("%s: Local port %d not present\n", __func__, port_id);
+		release_pkt(pkt);
+		return -ENODEV;
+	}
+
+	mutex_lock(&port_ptr->port_rx_q_lock);
+	list_add_tail(&pkt->list, &port_ptr->port_rx_q);
+	wake_up(&port_ptr->port_rx_wait_q);
+	mutex_unlock(&port_ptr->port_rx_q_lock);
+
+	return pkt->length;
+}
+
+static int msm_ipc_router_write_pkt(struct msm_ipc_port *src,
+				struct msm_ipc_router_remote_port *rport_ptr,
+				struct rr_packet *pkt)
+{
+	struct sk_buff *head_skb;
+	struct rr_header *hdr;
+	struct msm_ipc_router_xprt_info *xprt_info;
+	struct msm_ipc_routing_table_entry *rt_entry;
+	int ret;
+	DEFINE_WAIT(__wait);
+
+	if (!rport_ptr || !src || !pkt)
+		return -EINVAL;
+
+	head_skb = skb_peek(pkt->pkt_fragment_q);
+	hdr = (struct rr_header *)skb_push(head_skb, IPC_ROUTER_HDR_SIZE);
+	if (!hdr) {
+		pr_err("%s: Prepend Header failed\n", __func__);
+		return -ENOMEM;
+	}
+	hdr->version = IPC_ROUTER_VERSION;
+	hdr->type = IPC_ROUTER_CTRL_CMD_DATA;
+	hdr->src_node_id = src->this_port.node_id;
+	hdr->src_port_id = src->this_port.port_id;
+	hdr->size = pkt->length;
+	hdr->confirm_rx = 0;
+	hdr->dst_node_id = rport_ptr->node_id;
+	hdr->dst_port_id = rport_ptr->port_id;
+	pkt->length += IPC_ROUTER_HDR_SIZE;
+
+	for (;;) {
+		prepare_to_wait(&rport_ptr->quota_wait, &__wait,
+				TASK_INTERRUPTIBLE);
+		mutex_lock(&rport_ptr->quota_lock);
+		if (rport_ptr->tx_quota_cnt <
+		     IPC_ROUTER_DEFAULT_RX_QUOTA)
+			break;
+		if (signal_pending(current))
+			break;
+		mutex_unlock(&rport_ptr->quota_lock);
+		schedule();
+	}
+	finish_wait(&rport_ptr->quota_wait, &__wait);
+
+	if (signal_pending(current)) {
+		mutex_unlock(&rport_ptr->quota_lock);
+		return -ERESTARTSYS;
+	}
+	rport_ptr->tx_quota_cnt++;
+	if (rport_ptr->tx_quota_cnt == IPC_ROUTER_DEFAULT_RX_QUOTA)
+		hdr->confirm_rx = 1;
+	mutex_unlock(&rport_ptr->quota_lock);
+
+	mutex_lock(&routing_table_lock);
+	rt_entry = lookup_routing_table(hdr->dst_node_id);
+	if (!rt_entry || !rt_entry->xprt_info) {
+		mutex_unlock(&routing_table_lock);
+		pr_err("%s: Remote node %d not up\n",
+			__func__, hdr->dst_node_id);
+		return -ENODEV;
+	}
+	mutex_lock(&rt_entry->lock);
+	xprt_info = rt_entry->xprt_info;
+	mutex_lock(&xprt_info->tx_lock);
+	ret = xprt_info->xprt->write(pkt, pkt->length, 0);
+	mutex_unlock(&xprt_info->tx_lock);
+	mutex_unlock(&rt_entry->lock);
+	mutex_unlock(&routing_table_lock);
+
+	if (ret < 0) {
+		pr_err("%s: Write on XPRT failed\n", __func__);
+		return ret;
+	}
+
+	return pkt->length;
+}
+
+int msm_ipc_router_send_to(struct msm_ipc_port *src,
+			   struct sk_buff_head *data,
+			   struct msm_ipc_addr *dest)
+{
+	uint32_t dst_node_id = 0, dst_port_id = 0;
+	struct msm_ipc_server *server;
+	struct msm_ipc_server_port *server_port;
+	struct msm_ipc_router_remote_port *rport_ptr = NULL;
+	struct rr_packet *pkt;
+	int ret;
+
+	if (!src || !data || !dest) {
+		pr_err("%s: Invalid Parameters\n", __func__);
+		return -EINVAL;
+	}
+
+	/* Resolve Address*/
+	if (dest->addrtype == MSM_IPC_ADDR_ID) {
+		dst_node_id = dest->addr.port_addr.node_id;
+		dst_port_id = dest->addr.port_addr.port_id;
+	} else if (dest->addrtype == MSM_IPC_ADDR_NAME) {
+		server = msm_ipc_router_lookup_server(
+					dest->addr.port_name.service,
+					dest->addr.port_name.instance,
+					0, 0);
+		if (!server) {
+			pr_err("%s: Destination not reachable\n", __func__);
+			return -ENODEV;
+		}
+		mutex_lock(&server_list_lock);
+		server_port = list_first_entry(&server->server_port_list,
+					       struct msm_ipc_server_port,
+					       list);
+		dst_node_id = server_port->server_addr.node_id;
+		dst_port_id = server_port->server_addr.port_id;
+		mutex_unlock(&server_list_lock);
+	}
+	if (dst_node_id == IPC_ROUTER_NID_LOCAL) {
+		ret = loopback_data(src, dst_port_id, data);
+		return ret;
+	}
+
+	/* Achieve Flow control */
+	rport_ptr = msm_ipc_router_lookup_remote_port(dst_node_id,
+						      dst_port_id);
+	if (!rport_ptr) {
+		rport_ptr = msm_ipc_router_create_remote_port(dst_node_id,
+							      dst_port_id);
+		if (!rport_ptr) {
+			pr_err("%s: Could not create remote port\n", __func__);
+			return -ENOMEM;
+		}
+	}
+
+	pkt = create_pkt(data);
+	if (!pkt) {
+		pr_err("%s: Pkt creation failed\n", __func__);
+		return -ENOMEM;
+	}
+
+	ret = msm_ipc_router_write_pkt(src, rport_ptr, pkt);
+	release_pkt(pkt);
+
+	return ret;
+}
+
+int msm_ipc_router_read(struct msm_ipc_port *port_ptr,
+			struct sk_buff_head **data,
+			size_t buf_len)
+{
+	struct rr_packet *pkt;
+	int ret;
+
+	if (!port_ptr || !data)
+		return -EINVAL;
+
+	mutex_lock(&port_ptr->port_rx_q_lock);
+	if (list_empty(&port_ptr->port_rx_q)) {
+		mutex_unlock(&port_ptr->port_rx_q_lock);
+		return -EAGAIN;
+	}
+
+	pkt = list_first_entry(&port_ptr->port_rx_q, struct rr_packet, list);
+	if ((buf_len) && ((pkt->length - IPC_ROUTER_HDR_SIZE) > buf_len)) {
+		mutex_unlock(&port_ptr->port_rx_q_lock);
+		return -ETOOSMALL;
+	}
+	list_del(&pkt->list);
+	*data = pkt->pkt_fragment_q;
+	ret = pkt->length;
+	kfree(pkt);
+	mutex_unlock(&port_ptr->port_rx_q_lock);
+
+	return ret;
+}
+
+int msm_ipc_router_recv_from(struct msm_ipc_port *port_ptr,
+			     struct sk_buff_head **data,
+			     struct msm_ipc_addr *src,
+			     unsigned long timeout)
+{
+	int ret, data_len, align_size;
+	struct sk_buff *temp_skb;
+	struct rr_header *hdr = NULL;
+
+	if (!port_ptr || !data) {
+		pr_err("%s: Invalid pointers being passed\n", __func__);
+		return -EINVAL;
+	}
+
+	*data = NULL;
+	mutex_lock(&port_ptr->port_rx_q_lock);
+	while (list_empty(&port_ptr->port_rx_q)) {
+		mutex_unlock(&port_ptr->port_rx_q_lock);
+		if (timeout < 0) {
+			ret = wait_event_interruptible(
+					port_ptr->port_rx_wait_q,
+					!list_empty(&port_ptr->port_rx_q));
+			if (ret)
+				return ret;
+		} else if (timeout > 0) {
+			timeout = wait_event_interruptible_timeout(
+					port_ptr->port_rx_wait_q,
+					!list_empty(&port_ptr->port_rx_q),
+					timeout);
+			if (timeout < 0)
+				return -EFAULT;
+		}
+		if (timeout == 0)
+			return -ETIMEDOUT;
+		mutex_lock(&port_ptr->port_rx_q_lock);
+	}
+	mutex_unlock(&port_ptr->port_rx_q_lock);
+
+	ret = msm_ipc_router_read(port_ptr, data, 0);
+	if (ret <= 0 || !(*data))
+		return ret;
+
+	temp_skb = skb_peek(*data);
+	hdr = (struct rr_header *)(temp_skb->data);
+	if (src) {
+		src->addrtype = MSM_IPC_ADDR_ID;
+		src->addr.port_addr.node_id = hdr->src_node_id;
+		src->addr.port_addr.port_id = hdr->src_port_id;
+	}
+
+	data_len = hdr->size;
+	skb_pull(temp_skb, IPC_ROUTER_HDR_SIZE);
+	align_size = ALIGN_SIZE(data_len);
+	if (align_size) {
+		temp_skb = skb_peek_tail(*data);
+		skb_trim(temp_skb, (temp_skb->len - align_size));
+	}
+	return data_len;
+}
+
+struct msm_ipc_port *msm_ipc_router_create_port(
+	void (*notify)(unsigned event, void *data, void *addr, void *priv),
+	void *priv)
+{
+	struct msm_ipc_port *port_ptr;
+
+	port_ptr = msm_ipc_router_create_raw_port(NULL, notify, priv);
+	if (!port_ptr)
+		pr_err("%s: port_ptr alloc failed\n", __func__);
+
+	return port_ptr;
+}
+
+int msm_ipc_router_close_port(struct msm_ipc_port *port_ptr)
+{
+	union rr_control_msg msg;
+	struct rr_packet *pkt, *temp_pkt;
+	struct msm_ipc_server *server;
+
+	if (!port_ptr)
+		return -EINVAL;
+
+	if (port_ptr->type == SERVER_PORT || port_ptr->type == CLIENT_PORT) {
+		if (port_ptr->type == SERVER_PORT) {
+			msg.cmd = IPC_ROUTER_CTRL_CMD_REMOVE_SERVER;
+			msg.srv.service = port_ptr->port_name.service;
+			msg.srv.instance = port_ptr->port_name.instance;
+			msg.srv.node_id = port_ptr->this_port.node_id;
+			msg.srv.port_id = port_ptr->this_port.port_id;
+		} else if (port_ptr->type == CLIENT_PORT) {
+			msg.cmd = IPC_ROUTER_CTRL_CMD_REMOVE_CLIENT;
+			msg.cli.node_id = port_ptr->this_port.node_id;
+			msg.cli.port_id = port_ptr->this_port.port_id;
+		}
+		broadcast_ctl_msg(&msg);
+		broadcast_ctl_msg_locally(&msg);
+	}
+
+	mutex_lock(&port_ptr->port_rx_q_lock);
+	list_for_each_entry_safe(pkt, temp_pkt, &port_ptr->port_rx_q, list) {
+		list_del(&pkt->list);
+		release_pkt(pkt);
+	}
+	mutex_unlock(&port_ptr->port_rx_q_lock);
+
+	if (port_ptr->type == SERVER_PORT) {
+		server = msm_ipc_router_lookup_server(
+				port_ptr->port_name.service,
+				port_ptr->port_name.instance,
+				port_ptr->this_port.node_id,
+				port_ptr->this_port.port_id);
+		if (server)
+			msm_ipc_router_destroy_server(server,
+				port_ptr->this_port.node_id,
+				port_ptr->this_port.port_id);
+		mutex_lock(&local_ports_lock);
+		list_del(&port_ptr->list);
+		mutex_unlock(&local_ports_lock);
+	} else if (port_ptr->type == CLIENT_PORT) {
+		mutex_lock(&local_ports_lock);
+		list_del(&port_ptr->list);
+		mutex_unlock(&local_ports_lock);
+	} else if (port_ptr->type == CONTROL_PORT) {
+		mutex_lock(&control_ports_lock);
+		list_del(&port_ptr->list);
+		mutex_unlock(&control_ports_lock);
+	}
+
+	kfree(port_ptr);
+	return 0;
+}
+
+int msm_ipc_router_get_curr_pkt_size(struct msm_ipc_port *port_ptr)
+{
+	struct rr_packet *pkt;
+	int rc = 0;
+
+	if (!port_ptr)
+		return -EINVAL;
+
+	mutex_lock(&port_ptr->port_rx_q_lock);
+	if (!list_empty(&port_ptr->port_rx_q)) {
+		pkt = list_first_entry(&port_ptr->port_rx_q,
+					struct rr_packet, list);
+		rc = pkt->length;
+	}
+	mutex_unlock(&port_ptr->port_rx_q_lock);
+
+	return rc;
+}
+
+int msm_ipc_router_bind_control_port(struct msm_ipc_port *port_ptr)
+{
+	if (!port_ptr)
+		return -EINVAL;
+
+	mutex_lock(&local_ports_lock);
+	list_del(&port_ptr->list);
+	mutex_unlock(&local_ports_lock);
+	port_ptr->type = CONTROL_PORT;
+	mutex_lock(&control_ports_lock);
+	list_add_tail(&port_ptr->list, &control_ports);
+	mutex_unlock(&control_ports_lock);
+
+	return 0;
+}
+
+int msm_ipc_router_lookup_server_name(struct msm_ipc_port_name *srv_name,
+				struct msm_ipc_port_addr *srv_addr,
+				int num_entries_in_array)
+{
+	struct msm_ipc_server *server;
+	struct msm_ipc_server_port *server_port;
+	int i = 0; /*num_entries_found*/
+
+	if (!srv_name || !srv_addr) {
+		pr_err("%s: Invalid srv_addr/name\n", __func__);
+		return -EINVAL;
+	}
+
+	server = msm_ipc_router_lookup_server(srv_name->service,
+					srv_name->instance, 0, 0);
+	if (!server)
+		return -ENODEV;
+
+	mutex_lock(&server_list_lock);
+	list_for_each_entry(server_port, &server->server_port_list, list) {
+		if (i < num_entries_in_array) {
+			srv_addr[i].node_id = server_port->server_addr.node_id;
+			srv_addr[i].port_id = server_port->server_addr.port_id;
+		}
+		i++;
+	}
+	mutex_unlock(&server_list_lock);
+
+	return i;
+}
+
+int msm_ipc_router_close(void)
+{
+	struct msm_ipc_router_xprt_info *xprt_info, *tmp_xprt_info;
+
+	mutex_lock(&xprt_info_list_lock);
+	list_for_each_entry_safe(xprt_info, tmp_xprt_info,
+				 &xprt_info_list, list) {
+		xprt_info->xprt->close();
+		list_del(&xprt_info->list);
+		kfree(xprt_info);
+	}
+	mutex_unlock(&xprt_info_list_lock);
+	return 0;
+}
+
+static int __init msm_ipc_router_init(void)
+{
+	int i;
+	struct msm_ipc_routing_table_entry *rt_entry;
+#if !defined(CONFIG_MSM_IPC_ROUTER_SMD_XPRT)
+	struct work_struct dummy_work;
+
+	INIT_WORK(&dummy_work, do_read_data);
+#endif
+
+	for (i = 0; i < SRV_HASH_SIZE; i++)
+		INIT_LIST_HEAD(&server_list[i]);
+
+	for (i = 0; i < LP_HASH_SIZE; i++)
+		INIT_LIST_HEAD(&local_ports[i]);
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
+	init_waitqueue_head(&newserver_wait);
+
+	return 0;
+}
+
+module_init(msm_ipc_router_init);
+MODULE_DESCRIPTION("MSM IPC Router");
+MODULE_LICENSE("GPL v2");
diff --git a/net/msm_ipc/msm_ipc_router.h b/net/msm_ipc/msm_ipc_router.h
new file mode 100644
index 0000000..4d30c8f
--- /dev/null
+++ b/net/msm_ipc/msm_ipc_router.h
@@ -0,0 +1,187 @@
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
+#ifndef _MSM_IPC_ROUTER_H
+#define _MSM_IPC_ROUTER_H
+
+#include <linux/types.h>
+#include <linux/socket.h>
+#include <linux/errno.h>
+#include <linux/mm.h>
+#include <linux/list.h>
+#include <linux/cdev.h>
+#include <linux/platform_device.h>
+#include <net/sock.h>
+#include <linux/msm_ipc.h>
+
+#include <mach/msm_smd.h>
+
+/* definitions for the R2R wire protcol */
+#define IPC_ROUTER_VERSION			1
+#define IPC_ROUTER_PROCESSORS_MAX		4
+
+#define IPC_ROUTER_CLIENT_BCAST_ID		0xffffffff
+#define IPC_ROUTER_ADDRESS			0xfffffffe
+
+#define IPC_ROUTER_NID_LOCAL			1
+#define IPC_ROUTER_NID_REMOTE			0
+
+#define IPC_ROUTER_CTRL_CMD_DATA		1
+#define IPC_ROUTER_CTRL_CMD_HELLO		2
+#define IPC_ROUTER_CTRL_CMD_BYE			3
+#define IPC_ROUTER_CTRL_CMD_NEW_SERVER		4
+#define IPC_ROUTER_CTRL_CMD_REMOVE_SERVER	5
+#define IPC_ROUTER_CTRL_CMD_REMOVE_CLIENT	6
+#define IPC_ROUTER_CTRL_CMD_RESUME_TX		7
+#define IPC_ROUTER_CTRL_CMD_EXIT		8
+#define IPC_ROUTER_CTRL_CMD_PING		9
+
+#define IPC_ROUTER_DEFAULT_RX_QUOTA	5
+
+#define IPC_ROUTER_XPRT_EVENT_DATA  1
+#define IPC_ROUTER_XPRT_EVENT_OPEN  2
+#define IPC_ROUTER_XPRT_EVENT_CLOSE 3
+
+#define NUM_NODES 2
+
+#define IPC_ROUTER_INFINITY -1
+#define DEFAULT_RCV_TIMEO IPC_ROUTER_INFINITY
+
+#define ALIGN_SIZE(x) ((4 - ((x) & 3)) & 3)
+
+enum {
+	MSM_IPC_ROUTER_READ_CB = 0,
+	MSM_IPC_ROUTER_WRITE_DONE,
+};
+
+union rr_control_msg {
+	uint32_t cmd;
+	struct {
+		uint32_t cmd;
+		uint32_t service;
+		uint32_t instance;
+		uint32_t node_id;
+		uint32_t port_id;
+	} srv;
+	struct {
+		uint32_t cmd;
+		uint32_t node_id;
+		uint32_t port_id;
+	} cli;
+};
+
+struct rr_header {
+	uint32_t version;
+	uint32_t type;
+	uint32_t src_node_id;
+	uint32_t src_port_id;
+	uint32_t confirm_rx;
+	uint32_t size;
+	uint32_t dst_node_id;
+	uint32_t dst_port_id;
+};
+
+#define IPC_ROUTER_HDR_SIZE sizeof(struct rr_header)
+#define MAX_IPC_PKT_SIZE 66000
+/* internals */
+
+#define IPC_ROUTER_MAX_REMOTE_SERVERS		100
+
+struct rr_packet {
+	struct list_head list;
+	struct sk_buff_head *pkt_fragment_q;
+	uint32_t length;
+};
+
+struct msm_ipc_port {
+	struct list_head list;
+
+	struct msm_ipc_port_addr this_port;
+	struct msm_ipc_port_name port_name;
+	uint32_t type;
+	unsigned flags;
+	spinlock_t port_lock;
+
+	struct list_head incomplete;
+	struct mutex incomplete_lock;
+
+	struct list_head port_rx_q;
+	struct mutex port_rx_q_lock;
+	wait_queue_head_t port_rx_wait_q;
+
+	int restart_state;
+	spinlock_t restart_lock;
+	wait_queue_head_t restart_wait;
+
+	void *endpoint;
+	void (*notify)(unsigned event, void *data, void *addr, void *priv);
+
+	uint32_t num_tx;
+	uint32_t num_rx;
+	unsigned long num_tx_bytes;
+	unsigned long num_rx_bytes;
+	void *priv;
+};
+
+struct msm_ipc_router_xprt {
+	char *name;
+	uint32_t link_id;
+	void *priv;
+
+	int (*read_avail)(void);
+	int (*read)(void *data, uint32_t len);
+	int (*write_avail)(void);
+	int (*write)(void *data, uint32_t len, uint32_t type);
+	int (*close)(void);
+};
+
+extern struct completion msm_ipc_remote_router_up;
+
+void msm_ipc_router_xprt_notify(struct msm_ipc_router_xprt *xprt,
+				unsigned event,
+				void *data);
+
+
+struct rr_packet *clone_pkt(struct rr_packet *pkt);
+void release_pkt(struct rr_packet *pkt);
+
+
+struct msm_ipc_port *msm_ipc_router_create_raw_port(void *endpoint,
+		void (*notify)(unsigned event, void *data,
+			       void *addr, void *priv),
+		void *priv);
+int msm_ipc_router_send_to(struct msm_ipc_port *src,
+			   struct sk_buff_head *data,
+			   struct msm_ipc_addr *dest);
+int msm_ipc_router_read(struct msm_ipc_port *port_ptr,
+			struct sk_buff_head **data,
+			size_t buf_len);
+int msm_ipc_router_get_curr_pkt_size(struct msm_ipc_port *port_ptr);
+int msm_ipc_router_bind_control_port(struct msm_ipc_port *port_ptr);
+int msm_ipc_router_lookup_server_name(struct msm_ipc_port_name *srv_name,
+				      struct msm_ipc_port_addr *port_addr,
+				      int num_entries_in_array);
+int msm_ipc_router_close_port(struct msm_ipc_port *port_ptr);
+
+struct msm_ipc_port *msm_ipc_router_create_port(
+	void (*notify)(unsigned event, void *data,
+		       void *addr, void *priv),
+	void *priv);
+int msm_ipc_router_recv_from(struct msm_ipc_port *port_ptr,
+		      struct sk_buff_head **data,
+		      struct msm_ipc_addr *src_addr,
+		      unsigned long timeout);
+int msm_ipc_router_register_server(struct msm_ipc_port *server_port,
+			    struct msm_ipc_addr *name);
+int msm_ipc_router_unregister_server(struct msm_ipc_port *server_port);
+
+#endif
-- 
1.7.3.3

Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.
