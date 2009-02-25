From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 13/26] RDS/IB: Infiniband transport
Date: Tue, 24 Feb 2009 17:30:30 -0800
Message-ID: <1235525443-9007-14-git-send-email-andy.grover@oracle.com>
References: <1235525443-9007-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com, general@lists.openfabrics.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:48962 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755296AbZBYBbU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 20:31:20 -0500
In-Reply-To: <1235525443-9007-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Registers as an RDS transport and an IB client, and uses IB CM
API to allocate ids, queue pairs, and the rest of that fun stuff.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/ib.c    |  323 ++++++++++++++++++++++++
 net/rds/ib.h    |  367 ++++++++++++++++++++++++++++
 net/rds/ib_cm.c |  726 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 1416 insertions(+), 0 deletions(-)
 create mode 100644 net/rds/ib.c
 create mode 100644 net/rds/ib.h
 create mode 100644 net/rds/ib_cm.c

diff --git a/net/rds/ib.c b/net/rds/ib.c
new file mode 100644
index 0000000..06a7b79
--- /dev/null
+++ b/net/rds/ib.c
@@ -0,0 +1,323 @@
+/*
+ * Copyright (c) 2006 Oracle.  All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+#include <linux/kernel.h>
+#include <linux/in.h>
+#include <linux/if.h>
+#include <linux/netdevice.h>
+#include <linux/inetdevice.h>
+#include <linux/if_arp.h>
+#include <linux/delay.h>
+
+#include "rds.h"
+#include "ib.h"
+
+unsigned int fmr_pool_size = RDS_FMR_POOL_SIZE;
+unsigned int fmr_message_size = RDS_FMR_SIZE + 1; /* +1 allows for unaligned MRs */
+
+module_param(fmr_pool_size, int, 0444);
+MODULE_PARM_DESC(fmr_pool_size, " Max number of fmr per HCA");
+module_param(fmr_message_size, int, 0444);
+MODULE_PARM_DESC(fmr_message_size, " Max size of a RDMA transfer");
+
+struct list_head rds_ib_devices;
+
+DEFINE_SPINLOCK(ib_nodev_conns_lock);
+LIST_HEAD(ib_nodev_conns);
+
+void rds_ib_add_one(struct ib_device *device)
+{
+	struct rds_ib_device *rds_ibdev;
+	struct ib_device_attr *dev_attr;
+
+	/* Only handle IB (no iWARP) devices */
+	if (device->node_type != RDMA_NODE_IB_CA)
+		return;
+
+	dev_attr = kmalloc(sizeof *dev_attr, GFP_KERNEL);
+	if (!dev_attr)
+		return;
+
+	if (ib_query_device(device, dev_attr)) {
+		rdsdebug("Query device failed for %s\n", device->name);
+		goto free_attr;
+	}
+
+	rds_ibdev = kmalloc(sizeof *rds_ibdev, GFP_KERNEL);
+	if (!rds_ibdev)
+		goto free_attr;
+
+	spin_lock_init(&rds_ibdev->spinlock);
+
+	rds_ibdev->max_wrs = dev_attr->max_qp_wr;
+	rds_ibdev->max_sge = min(dev_attr->max_sge, RDS_IB_MAX_SGE);
+
+	rds_ibdev->fmr_page_shift = max(9, ffs(dev_attr->page_size_cap) - 1);
+	rds_ibdev->fmr_page_size  = 1 << rds_ibdev->fmr_page_shift;
+	rds_ibdev->fmr_page_mask  = ~((u64) rds_ibdev->fmr_page_size - 1);
+	rds_ibdev->fmr_max_remaps = dev_attr->max_map_per_fmr?: 32;
+	rds_ibdev->max_fmrs = dev_attr->max_fmr ?
+			min_t(unsigned int, dev_attr->max_fmr, fmr_pool_size) :
+			fmr_pool_size;
+
+	rds_ibdev->dev = device;
+	rds_ibdev->pd = ib_alloc_pd(device);
+	if (IS_ERR(rds_ibdev->pd))
+		goto free_dev;
+
+	rds_ibdev->mr = ib_get_dma_mr(rds_ibdev->pd,
+				      IB_ACCESS_LOCAL_WRITE);
+	if (IS_ERR(rds_ibdev->mr))
+		goto err_pd;
+
+	rds_ibdev->mr_pool = rds_ib_create_mr_pool(rds_ibdev);
+	if (IS_ERR(rds_ibdev->mr_pool)) {
+		rds_ibdev->mr_pool = NULL;
+		goto err_mr;
+	}
+
+	INIT_LIST_HEAD(&rds_ibdev->ipaddr_list);
+	INIT_LIST_HEAD(&rds_ibdev->conn_list);
+	list_add_tail(&rds_ibdev->list, &rds_ib_devices);
+
+	ib_set_client_data(device, &rds_ib_client, rds_ibdev);
+
+	goto free_attr;
+
+err_mr:
+	ib_dereg_mr(rds_ibdev->mr);
+err_pd:
+	ib_dealloc_pd(rds_ibdev->pd);
+free_dev:
+	kfree(rds_ibdev);
+free_attr:
+	kfree(dev_attr);
+}
+
+void rds_ib_remove_one(struct ib_device *device)
+{
+	struct rds_ib_device *rds_ibdev;
+	struct rds_ib_ipaddr *i_ipaddr, *i_next;
+
+	rds_ibdev = ib_get_client_data(device, &rds_ib_client);
+	if (!rds_ibdev)
+		return;
+
+	list_for_each_entry_safe(i_ipaddr, i_next, &rds_ibdev->ipaddr_list, list) {
+		list_del(&i_ipaddr->list);
+		kfree(i_ipaddr);
+	}
+
+	rds_ib_remove_conns(rds_ibdev);
+
+	if (rds_ibdev->mr_pool)
+		rds_ib_destroy_mr_pool(rds_ibdev->mr_pool);
+
+	ib_dereg_mr(rds_ibdev->mr);
+
+	while (ib_dealloc_pd(rds_ibdev->pd)) {
+		rdsdebug("Failed to dealloc pd %p\n", rds_ibdev->pd);
+		msleep(1);
+	}
+
+	list_del(&rds_ibdev->list);
+	kfree(rds_ibdev);
+}
+
+struct ib_client rds_ib_client = {
+	.name   = "rds_ib",
+	.add    = rds_ib_add_one,
+	.remove = rds_ib_remove_one
+};
+
+static int rds_ib_conn_info_visitor(struct rds_connection *conn,
+				    void *buffer)
+{
+	struct rds_info_rdma_connection *iinfo = buffer;
+	struct rds_ib_connection *ic;
+
+	/* We will only ever look at IB transports */
+	if (conn->c_trans != &rds_ib_transport)
+		return 0;
+
+	iinfo->src_addr = conn->c_laddr;
+	iinfo->dst_addr = conn->c_faddr;
+
+	memset(&iinfo->src_gid, 0, sizeof(iinfo->src_gid));
+	memset(&iinfo->dst_gid, 0, sizeof(iinfo->dst_gid));
+	if (rds_conn_state(conn) == RDS_CONN_UP) {
+		struct rds_ib_device *rds_ibdev;
+		struct rdma_dev_addr *dev_addr;
+
+		ic = conn->c_transport_data;
+		dev_addr = &ic->i_cm_id->route.addr.dev_addr;
+
+		ib_addr_get_sgid(dev_addr, (union ib_gid *) &iinfo->src_gid);
+		ib_addr_get_dgid(dev_addr, (union ib_gid *) &iinfo->dst_gid);
+
+		rds_ibdev = ib_get_client_data(ic->i_cm_id->device, &rds_ib_client);
+		iinfo->max_send_wr = ic->i_send_ring.w_nr;
+		iinfo->max_recv_wr = ic->i_recv_ring.w_nr;
+		iinfo->max_send_sge = rds_ibdev->max_sge;
+		rds_ib_get_mr_info(rds_ibdev, iinfo);
+	}
+	return 1;
+}
+
+static void rds_ib_ic_info(struct socket *sock, unsigned int len,
+			   struct rds_info_iterator *iter,
+			   struct rds_info_lengths *lens)
+{
+	rds_for_each_conn_info(sock, len, iter, lens,
+				rds_ib_conn_info_visitor,
+				sizeof(struct rds_info_rdma_connection));
+}
+
+
+/*
+ * Early RDS/IB was built to only bind to an address if there is an IPoIB
+ * device with that address set.
+ *
+ * If it were me, I'd advocate for something more flexible.  Sending and
+ * receiving should be device-agnostic.  Transports would try and maintain
+ * connections between peers who have messages queued.  Userspace would be
+ * allowed to influence which paths have priority.  We could call userspace
+ * asserting this policy "routing".
+ */
+static int rds_ib_laddr_check(__be32 addr)
+{
+	int ret;
+	struct rdma_cm_id *cm_id;
+	struct sockaddr_in sin;
+
+	/* Create a CMA ID and try to bind it. This catches both
+	 * IB and iWARP capable NICs.
+	 */
+	cm_id = rdma_create_id(NULL, NULL, RDMA_PS_TCP);
+	if (!cm_id)
+		return -EADDRNOTAVAIL;
+
+	memset(&sin, 0, sizeof(sin));
+	sin.sin_family = AF_INET;
+	sin.sin_addr.s_addr = addr;
+
+	/* rdma_bind_addr will only succeed for IB & iWARP devices */
+	ret = rdma_bind_addr(cm_id, (struct sockaddr *)&sin);
+	/* due to this, we will claim to support iWARP devices unless we
+	   check node_type. */
+	if (ret || cm_id->device->node_type != RDMA_NODE_IB_CA)
+		ret = -EADDRNOTAVAIL;
+
+	rdsdebug("addr %pI4 ret %d node type %d\n",
+		&addr, ret,
+		cm_id->device ? cm_id->device->node_type : -1);
+
+	rdma_destroy_id(cm_id);
+
+	return ret;
+}
+
+void rds_ib_exit(void)
+{
+	rds_info_deregister_func(RDS_INFO_IB_CONNECTIONS, rds_ib_ic_info);
+	rds_ib_remove_nodev_conns();
+	ib_unregister_client(&rds_ib_client);
+	rds_ib_sysctl_exit();
+	rds_ib_recv_exit();
+	rds_trans_unregister(&rds_ib_transport);
+}
+
+struct rds_transport rds_ib_transport = {
+	.laddr_check		= rds_ib_laddr_check,
+	.xmit_complete		= rds_ib_xmit_complete,
+	.xmit			= rds_ib_xmit,
+	.xmit_cong_map		= NULL,
+	.xmit_rdma		= rds_ib_xmit_rdma,
+	.recv			= rds_ib_recv,
+	.conn_alloc		= rds_ib_conn_alloc,
+	.conn_free		= rds_ib_conn_free,
+	.conn_connect		= rds_ib_conn_connect,
+	.conn_shutdown		= rds_ib_conn_shutdown,
+	.inc_copy_to_user	= rds_ib_inc_copy_to_user,
+	.inc_purge		= rds_ib_inc_purge,
+	.inc_free		= rds_ib_inc_free,
+	.cm_initiate_connect	= rds_ib_cm_initiate_connect,
+	.cm_handle_connect	= rds_ib_cm_handle_connect,
+	.cm_connect_complete	= rds_ib_cm_connect_complete,
+	.stats_info_copy	= rds_ib_stats_info_copy,
+	.exit			= rds_ib_exit,
+	.get_mr			= rds_ib_get_mr,
+	.sync_mr		= rds_ib_sync_mr,
+	.free_mr		= rds_ib_free_mr,
+	.flush_mrs		= rds_ib_flush_mrs,
+	.t_owner		= THIS_MODULE,
+	.t_name			= "infiniband",
+};
+
+int __init rds_ib_init(void)
+{
+	int ret;
+
+	INIT_LIST_HEAD(&rds_ib_devices);
+
+	ret = ib_register_client(&rds_ib_client);
+	if (ret)
+		goto out;
+
+	ret = rds_ib_sysctl_init();
+	if (ret)
+		goto out_ibreg;
+
+	ret = rds_ib_recv_init();
+	if (ret)
+		goto out_sysctl;
+
+	ret = rds_trans_register(&rds_ib_transport);
+	if (ret)
+		goto out_recv;
+
+	rds_info_register_func(RDS_INFO_IB_CONNECTIONS, rds_ib_ic_info);
+
+	goto out;
+
+out_recv:
+	rds_ib_recv_exit();
+out_sysctl:
+	rds_ib_sysctl_exit();
+out_ibreg:
+	ib_unregister_client(&rds_ib_client);
+out:
+	return ret;
+}
+
+MODULE_LICENSE("GPL");
+
diff --git a/net/rds/ib.h b/net/rds/ib.h
new file mode 100644
index 0000000..8be563a
--- /dev/null
+++ b/net/rds/ib.h
@@ -0,0 +1,367 @@
+#ifndef _RDS_IB_H
+#define _RDS_IB_H
+
+#include <rdma/ib_verbs.h>
+#include <rdma/rdma_cm.h>
+#include "rds.h"
+#include "rdma_transport.h"
+
+#define RDS_FMR_SIZE			256
+#define RDS_FMR_POOL_SIZE		4096
+
+#define RDS_IB_MAX_SGE			8
+#define RDS_IB_RECV_SGE 		2
+
+#define RDS_IB_DEFAULT_RECV_WR		1024
+#define RDS_IB_DEFAULT_SEND_WR		256
+
+#define RDS_IB_SUPPORTED_PROTOCOLS	0x00000003	/* minor versions supported */
+
+extern struct list_head rds_ib_devices;
+
+/*
+ * IB posts RDS_FRAG_SIZE fragments of pages to the receive queues to
+ * try and minimize the amount of memory tied up both the device and
+ * socket receive queues.
+ */
+/* page offset of the final full frag that fits in the page */
+#define RDS_PAGE_LAST_OFF (((PAGE_SIZE  / RDS_FRAG_SIZE) - 1) * RDS_FRAG_SIZE)
+struct rds_page_frag {
+	struct list_head	f_item;
+	struct page		*f_page;
+	unsigned long		f_offset;
+	dma_addr_t 		f_mapped;
+};
+
+struct rds_ib_incoming {
+	struct list_head	ii_frags;
+	struct rds_incoming	ii_inc;
+};
+
+struct rds_ib_connect_private {
+	/* Add new fields at the end, and don't permute existing fields. */
+	__be32			dp_saddr;
+	__be32			dp_daddr;
+	u8			dp_protocol_major;
+	u8			dp_protocol_minor;
+	__be16			dp_protocol_minor_mask; /* bitmask */
+	__be32			dp_reserved1;
+	__be64			dp_ack_seq;
+	__be32			dp_credit;		/* non-zero enables flow ctl */
+};
+
+struct rds_ib_send_work {
+	struct rds_message	*s_rm;
+	struct rds_rdma_op	*s_op;
+	struct ib_send_wr	s_wr;
+	struct ib_sge		s_sge[RDS_IB_MAX_SGE];
+	unsigned long		s_queued;
+};
+
+struct rds_ib_recv_work {
+	struct rds_ib_incoming 	*r_ibinc;
+	struct rds_page_frag	*r_frag;
+	struct ib_recv_wr	r_wr;
+	struct ib_sge		r_sge[2];
+};
+
+struct rds_ib_work_ring {
+	u32		w_nr;
+	u32		w_alloc_ptr;
+	u32		w_alloc_ctr;
+	u32		w_free_ptr;
+	atomic_t	w_free_ctr;
+};
+
+struct rds_ib_device;
+
+struct rds_ib_connection {
+
+	struct list_head	ib_node;
+	struct rds_ib_device	*rds_ibdev;
+	struct rds_connection	*conn;
+
+	/* alphabet soup, IBTA style */
+	struct rdma_cm_id	*i_cm_id;
+	struct ib_pd		*i_pd;
+	struct ib_mr		*i_mr;
+	struct ib_cq		*i_send_cq;
+	struct ib_cq		*i_recv_cq;
+
+	/* tx */
+	struct rds_ib_work_ring	i_send_ring;
+	struct rds_message	*i_rm;
+	struct rds_header	*i_send_hdrs;
+	u64			i_send_hdrs_dma;
+	struct rds_ib_send_work *i_sends;
+
+	/* rx */
+	struct mutex		i_recv_mutex;
+	struct rds_ib_work_ring	i_recv_ring;
+	struct rds_ib_incoming	*i_ibinc;
+	u32			i_recv_data_rem;
+	struct rds_header	*i_recv_hdrs;
+	u64			i_recv_hdrs_dma;
+	struct rds_ib_recv_work *i_recvs;
+	struct rds_page_frag	i_frag;
+	u64			i_ack_recv;	/* last ACK received */
+
+	/* sending acks */
+	unsigned long		i_ack_flags;
+	u64			i_ack_next;	/* next ACK to send */
+	struct rds_header	*i_ack;
+	struct ib_send_wr	i_ack_wr;
+	struct ib_sge		i_ack_sge;
+	u64			i_ack_dma;
+	unsigned long		i_ack_queued;
+
+	/* Flow control related information
+	 *
+	 * Our algorithm uses a pair variables that we need to access
+	 * atomically - one for the send credits, and one posted
+	 * recv credits we need to transfer to remote.
+	 * Rather than protect them using a slow spinlock, we put both into
+	 * a single atomic_t and update it using cmpxchg
+	 */
+	atomic_t		i_credits;
+
+	/* Protocol version specific information */
+	unsigned int		i_flowctl:1;	/* enable/disable flow ctl */
+
+	/* Batched completions */
+	unsigned int		i_unsignaled_wrs;
+	long			i_unsignaled_bytes;
+};
+
+/* This assumes that atomic_t is at least 32 bits */
+#define IB_GET_SEND_CREDITS(v)	((v) & 0xffff)
+#define IB_GET_POST_CREDITS(v)	((v) >> 16)
+#define IB_SET_SEND_CREDITS(v)	((v) & 0xffff)
+#define IB_SET_POST_CREDITS(v)	((v) << 16)
+
+struct rds_ib_ipaddr {
+	struct list_head	list;
+	__be32			ipaddr;
+};
+
+struct rds_ib_device {
+	struct list_head	list;
+	struct list_head	ipaddr_list;
+	struct list_head	conn_list;
+	struct ib_device	*dev;
+	struct ib_pd		*pd;
+	struct ib_mr		*mr;
+	struct rds_ib_mr_pool	*mr_pool;
+	int			fmr_page_shift;
+	int			fmr_page_size;
+	u64			fmr_page_mask;
+	unsigned int		fmr_max_remaps;
+	unsigned int		max_fmrs;
+	int			max_sge;
+	unsigned int		max_wrs;
+	spinlock_t		spinlock;	/* protect the above */
+};
+
+/* bits for i_ack_flags */
+#define IB_ACK_IN_FLIGHT	0
+#define IB_ACK_REQUESTED	1
+
+/* Magic WR_ID for ACKs */
+#define RDS_IB_ACK_WR_ID	(~(u64) 0)
+
+struct rds_ib_statistics {
+	uint64_t	s_ib_connect_raced;
+	uint64_t	s_ib_listen_closed_stale;
+	uint64_t	s_ib_tx_cq_call;
+	uint64_t	s_ib_tx_cq_event;
+	uint64_t	s_ib_tx_ring_full;
+	uint64_t	s_ib_tx_throttle;
+	uint64_t	s_ib_tx_sg_mapping_failure;
+	uint64_t	s_ib_tx_stalled;
+	uint64_t	s_ib_tx_credit_updates;
+	uint64_t	s_ib_rx_cq_call;
+	uint64_t	s_ib_rx_cq_event;
+	uint64_t	s_ib_rx_ring_empty;
+	uint64_t	s_ib_rx_refill_from_cq;
+	uint64_t	s_ib_rx_refill_from_thread;
+	uint64_t	s_ib_rx_alloc_limit;
+	uint64_t	s_ib_rx_credit_updates;
+	uint64_t	s_ib_ack_sent;
+	uint64_t	s_ib_ack_send_failure;
+	uint64_t	s_ib_ack_send_delayed;
+	uint64_t	s_ib_ack_send_piggybacked;
+	uint64_t	s_ib_ack_received;
+	uint64_t	s_ib_rdma_mr_alloc;
+	uint64_t	s_ib_rdma_mr_free;
+	uint64_t	s_ib_rdma_mr_used;
+	uint64_t	s_ib_rdma_mr_pool_flush;
+	uint64_t	s_ib_rdma_mr_pool_wait;
+	uint64_t	s_ib_rdma_mr_pool_depleted;
+};
+
+extern struct workqueue_struct *rds_ib_wq;
+
+/*
+ * Fake ib_dma_sync_sg_for_{cpu,device} as long as ib_verbs.h
+ * doesn't define it.
+ */
+static inline void rds_ib_dma_sync_sg_for_cpu(struct ib_device *dev,
+		struct scatterlist *sg, unsigned int sg_dma_len, int direction)
+{
+	unsigned int i;
+
+	for (i = 0; i < sg_dma_len; ++i) {
+		ib_dma_sync_single_for_cpu(dev,
+				ib_sg_dma_address(dev, &sg[i]),
+				ib_sg_dma_len(dev, &sg[i]),
+				direction);
+	}
+}
+#define ib_dma_sync_sg_for_cpu	rds_ib_dma_sync_sg_for_cpu
+
+static inline void rds_ib_dma_sync_sg_for_device(struct ib_device *dev,
+		struct scatterlist *sg, unsigned int sg_dma_len, int direction)
+{
+	unsigned int i;
+
+	for (i = 0; i < sg_dma_len; ++i) {
+		ib_dma_sync_single_for_device(dev,
+				ib_sg_dma_address(dev, &sg[i]),
+				ib_sg_dma_len(dev, &sg[i]),
+				direction);
+	}
+}
+#define ib_dma_sync_sg_for_device	rds_ib_dma_sync_sg_for_device
+
+
+/* ib.c */
+extern struct rds_transport rds_ib_transport;
+extern void rds_ib_add_one(struct ib_device *device);
+extern void rds_ib_remove_one(struct ib_device *device);
+extern struct ib_client rds_ib_client;
+
+extern unsigned int fmr_pool_size;
+extern unsigned int fmr_message_size;
+
+extern spinlock_t ib_nodev_conns_lock;
+extern struct list_head ib_nodev_conns;
+
+/* ib_cm.c */
+int rds_ib_conn_alloc(struct rds_connection *conn, gfp_t gfp);
+void rds_ib_conn_free(void *arg);
+int rds_ib_conn_connect(struct rds_connection *conn);
+void rds_ib_conn_shutdown(struct rds_connection *conn);
+void rds_ib_state_change(struct sock *sk);
+int __init rds_ib_listen_init(void);
+void rds_ib_listen_stop(void);
+void __rds_ib_conn_error(struct rds_connection *conn, const char *, ...);
+int rds_ib_cm_handle_connect(struct rdma_cm_id *cm_id,
+			     struct rdma_cm_event *event);
+int rds_ib_cm_initiate_connect(struct rdma_cm_id *cm_id);
+void rds_ib_cm_connect_complete(struct rds_connection *conn,
+				struct rdma_cm_event *event);
+
+
+#define rds_ib_conn_error(conn, fmt...) \
+	__rds_ib_conn_error(conn, KERN_WARNING "RDS/IB: " fmt)
+
+/* ib_rdma.c */
+int rds_ib_update_ipaddr(struct rds_ib_device *rds_ibdev, __be32 ipaddr);
+int rds_ib_add_conn(struct rds_ib_device *rds_ibdev, struct rds_connection *conn);
+void rds_ib_remove_nodev_conns(void);
+void rds_ib_remove_conns(struct rds_ib_device *rds_ibdev);
+struct rds_ib_mr_pool *rds_ib_create_mr_pool(struct rds_ib_device *);
+void rds_ib_get_mr_info(struct rds_ib_device *rds_ibdev, struct rds_info_rdma_connection *iinfo);
+void rds_ib_destroy_mr_pool(struct rds_ib_mr_pool *);
+void *rds_ib_get_mr(struct scatterlist *sg, unsigned long nents,
+		    struct rds_sock *rs, u32 *key_ret);
+void rds_ib_sync_mr(void *trans_private, int dir);
+void rds_ib_free_mr(void *trans_private, int invalidate);
+void rds_ib_flush_mrs(void);
+
+/* ib_recv.c */
+int __init rds_ib_recv_init(void);
+void rds_ib_recv_exit(void);
+int rds_ib_recv(struct rds_connection *conn);
+int rds_ib_recv_refill(struct rds_connection *conn, gfp_t kptr_gfp,
+		       gfp_t page_gfp, int prefill);
+void rds_ib_inc_purge(struct rds_incoming *inc);
+void rds_ib_inc_free(struct rds_incoming *inc);
+int rds_ib_inc_copy_to_user(struct rds_incoming *inc, struct iovec *iov,
+			     size_t size);
+void rds_ib_recv_cq_comp_handler(struct ib_cq *cq, void *context);
+void rds_ib_recv_init_ring(struct rds_ib_connection *ic);
+void rds_ib_recv_clear_ring(struct rds_ib_connection *ic);
+void rds_ib_recv_init_ack(struct rds_ib_connection *ic);
+void rds_ib_attempt_ack(struct rds_ib_connection *ic);
+void rds_ib_ack_send_complete(struct rds_ib_connection *ic);
+u64 rds_ib_piggyb_ack(struct rds_ib_connection *ic);
+
+/* ib_ring.c */
+void rds_ib_ring_init(struct rds_ib_work_ring *ring, u32 nr);
+void rds_ib_ring_resize(struct rds_ib_work_ring *ring, u32 nr);
+u32 rds_ib_ring_alloc(struct rds_ib_work_ring *ring, u32 val, u32 *pos);
+void rds_ib_ring_free(struct rds_ib_work_ring *ring, u32 val);
+void rds_ib_ring_unalloc(struct rds_ib_work_ring *ring, u32 val);
+int rds_ib_ring_empty(struct rds_ib_work_ring *ring);
+int rds_ib_ring_low(struct rds_ib_work_ring *ring);
+u32 rds_ib_ring_oldest(struct rds_ib_work_ring *ring);
+u32 rds_ib_ring_completed(struct rds_ib_work_ring *ring, u32 wr_id, u32 oldest);
+extern wait_queue_head_t rds_ib_ring_empty_wait;
+
+/* ib_send.c */
+void rds_ib_xmit_complete(struct rds_connection *conn);
+int rds_ib_xmit(struct rds_connection *conn, struct rds_message *rm,
+		unsigned int hdr_off, unsigned int sg, unsigned int off);
+void rds_ib_send_cq_comp_handler(struct ib_cq *cq, void *context);
+void rds_ib_send_init_ring(struct rds_ib_connection *ic);
+void rds_ib_send_clear_ring(struct rds_ib_connection *ic);
+int rds_ib_xmit_rdma(struct rds_connection *conn, struct rds_rdma_op *op);
+void rds_ib_send_add_credits(struct rds_connection *conn, unsigned int credits);
+void rds_ib_advertise_credits(struct rds_connection *conn, unsigned int posted);
+int rds_ib_send_grab_credits(struct rds_ib_connection *ic, u32 wanted,
+			     u32 *adv_credits, int need_posted);
+
+/* ib_stats.c */
+DECLARE_PER_CPU(struct rds_ib_statistics, rds_ib_stats);
+#define rds_ib_stats_inc(member) rds_stats_inc_which(rds_ib_stats, member)
+unsigned int rds_ib_stats_info_copy(struct rds_info_iterator *iter,
+				    unsigned int avail);
+
+/* ib_sysctl.c */
+int __init rds_ib_sysctl_init(void);
+void rds_ib_sysctl_exit(void);
+extern unsigned long rds_ib_sysctl_max_send_wr;
+extern unsigned long rds_ib_sysctl_max_recv_wr;
+extern unsigned long rds_ib_sysctl_max_unsig_wrs;
+extern unsigned long rds_ib_sysctl_max_unsig_bytes;
+extern unsigned long rds_ib_sysctl_max_recv_allocation;
+extern unsigned int rds_ib_sysctl_flow_control;
+extern ctl_table rds_ib_sysctl_table[];
+
+/*
+ * Helper functions for getting/setting the header and data SGEs in
+ * RDS packets (not RDMA)
+ */
+static inline struct ib_sge *
+rds_ib_header_sge(struct rds_ib_connection *ic, struct ib_sge *sge)
+{
+	return &sge[0];
+}
+
+static inline struct ib_sge *
+rds_ib_data_sge(struct rds_ib_connection *ic, struct ib_sge *sge)
+{
+	return &sge[1];
+}
+
+static inline void rds_ib_set_64bit(u64 *ptr, u64 val)
+{
+#if BITS_PER_LONG == 64
+	*ptr = val;
+#else
+	set_64bit(ptr, val);
+#endif
+}
+
+#endif
diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
new file mode 100644
index 0000000..0532237
--- /dev/null
+++ b/net/rds/ib_cm.c
@@ -0,0 +1,726 @@
+/*
+ * Copyright (c) 2006 Oracle.  All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+#include <linux/kernel.h>
+#include <linux/in.h>
+#include <linux/vmalloc.h>
+
+#include "rds.h"
+#include "ib.h"
+
+/*
+ * Set the selected protocol version
+ */
+static void rds_ib_set_protocol(struct rds_connection *conn, unsigned int version)
+{
+	conn->c_version = version;
+}
+
+/*
+ * Set up flow control
+ */
+static void rds_ib_set_flow_control(struct rds_connection *conn, u32 credits)
+{
+	struct rds_ib_connection *ic = conn->c_transport_data;
+
+	if (rds_ib_sysctl_flow_control && credits != 0) {
+		/* We're doing flow control */
+		ic->i_flowctl = 1;
+		rds_ib_send_add_credits(conn, credits);
+	} else {
+		ic->i_flowctl = 0;
+	}
+}
+
+/*
+ * Tune RNR behavior. Without flow control, we use a rather
+ * low timeout, but not the absolute minimum - this should
+ * be tunable.
+ *
+ * We already set the RNR retry count to 7 (which is the
+ * smallest infinite number :-) above.
+ * If flow control is off, we want to change this back to 0
+ * so that we learn quickly when our credit accounting is
+ * buggy.
+ *
+ * Caller passes in a qp_attr pointer - don't waste stack spacv
+ * by allocation this twice.
+ */
+static void
+rds_ib_tune_rnr(struct rds_ib_connection *ic, struct ib_qp_attr *attr)
+{
+	int ret;
+
+	attr->min_rnr_timer = IB_RNR_TIMER_000_32;
+	ret = ib_modify_qp(ic->i_cm_id->qp, attr, IB_QP_MIN_RNR_TIMER);
+	if (ret)
+		printk(KERN_NOTICE "ib_modify_qp(IB_QP_MIN_RNR_TIMER): err=%d\n", -ret);
+}
+
+/*
+ * Connection established.
+ * We get here for both outgoing and incoming connection.
+ */
+void rds_ib_cm_connect_complete(struct rds_connection *conn, struct rdma_cm_event *event)
+{
+	const struct rds_ib_connect_private *dp = NULL;
+	struct rds_ib_connection *ic = conn->c_transport_data;
+	struct rds_ib_device *rds_ibdev;
+	struct ib_qp_attr qp_attr;
+	int err;
+
+	if (event->param.conn.private_data_len) {
+		dp = event->param.conn.private_data;
+
+		rds_ib_set_protocol(conn,
+				RDS_PROTOCOL(dp->dp_protocol_major,
+					dp->dp_protocol_minor));
+		rds_ib_set_flow_control(conn, be32_to_cpu(dp->dp_credit));
+	}
+
+	printk(KERN_NOTICE "RDS/IB: connected to %pI4 version %u.%u%s\n",
+			&conn->c_laddr,
+			RDS_PROTOCOL_MAJOR(conn->c_version),
+			RDS_PROTOCOL_MINOR(conn->c_version),
+			ic->i_flowctl ? ", flow control" : "");
+
+	/* Tune RNR behavior */
+	rds_ib_tune_rnr(ic, &qp_attr);
+
+	qp_attr.qp_state = IB_QPS_RTS;
+	err = ib_modify_qp(ic->i_cm_id->qp, &qp_attr, IB_QP_STATE);
+	if (err)
+		printk(KERN_NOTICE "ib_modify_qp(IB_QP_STATE, RTS): err=%d\n", err);
+
+	/* update ib_device with this local ipaddr & conn */
+	rds_ibdev = ib_get_client_data(ic->i_cm_id->device, &rds_ib_client);
+	err = rds_ib_update_ipaddr(rds_ibdev, conn->c_laddr);
+	if (err)
+		printk(KERN_ERR "rds_ib_update_ipaddr failed (%d)\n", err);
+	err = rds_ib_add_conn(rds_ibdev, conn);
+	if (err)
+		printk(KERN_ERR "rds_ib_add_conn failed (%d)\n", err);
+
+	/* If the peer gave us the last packet it saw, process this as if
+	 * we had received a regular ACK. */
+	if (dp && dp->dp_ack_seq)
+		rds_send_drop_acked(conn, be64_to_cpu(dp->dp_ack_seq), NULL);
+
+	rds_connect_complete(conn);
+}
+
+static void rds_ib_cm_fill_conn_param(struct rds_connection *conn,
+			struct rdma_conn_param *conn_param,
+			struct rds_ib_connect_private *dp,
+			u32 protocol_version)
+{
+	memset(conn_param, 0, sizeof(struct rdma_conn_param));
+	/* XXX tune these? */
+	conn_param->responder_resources = 1;
+	conn_param->initiator_depth = 1;
+	conn_param->retry_count = 7;
+	conn_param->rnr_retry_count = 7;
+
+	if (dp) {
+		struct rds_ib_connection *ic = conn->c_transport_data;
+
+		memset(dp, 0, sizeof(*dp));
+		dp->dp_saddr = conn->c_laddr;
+		dp->dp_daddr = conn->c_faddr;
+		dp->dp_protocol_major = RDS_PROTOCOL_MAJOR(protocol_version);
+		dp->dp_protocol_minor = RDS_PROTOCOL_MINOR(protocol_version);
+		dp->dp_protocol_minor_mask = cpu_to_be16(RDS_IB_SUPPORTED_PROTOCOLS);
+		dp->dp_ack_seq = rds_ib_piggyb_ack(ic);
+
+		/* Advertise flow control */
+		if (ic->i_flowctl) {
+			unsigned int credits;
+
+			credits = IB_GET_POST_CREDITS(atomic_read(&ic->i_credits));
+			dp->dp_credit = cpu_to_be32(credits);
+			atomic_sub(IB_SET_POST_CREDITS(credits), &ic->i_credits);
+		}
+
+		conn_param->private_data = dp;
+		conn_param->private_data_len = sizeof(*dp);
+	}
+}
+
+static void rds_ib_cq_event_handler(struct ib_event *event, void *data)
+{
+	rdsdebug("event %u data %p\n", event->event, data);
+}
+
+static void rds_ib_qp_event_handler(struct ib_event *event, void *data)
+{
+	struct rds_connection *conn = data;
+	struct rds_ib_connection *ic = conn->c_transport_data;
+
+	rdsdebug("conn %p ic %p event %u\n", conn, ic, event->event);
+
+	switch (event->event) {
+	case IB_EVENT_COMM_EST:
+		rdma_notify(ic->i_cm_id, IB_EVENT_COMM_EST);
+		break;
+	default:
+		printk(KERN_WARNING "RDS/ib: unhandled QP event %u "
+		       "on connection to %pI4\n", event->event,
+		       &conn->c_faddr);
+		break;
+	}
+}
+
+/*
+ * This needs to be very careful to not leave IS_ERR pointers around for
+ * cleanup to trip over.
+ */
+static int rds_ib_setup_qp(struct rds_connection *conn)
+{
+	struct rds_ib_connection *ic = conn->c_transport_data;
+	struct ib_device *dev = ic->i_cm_id->device;
+	struct ib_qp_init_attr attr;
+	struct rds_ib_device *rds_ibdev;
+	int ret;
+
+	/* rds_ib_add_one creates a rds_ib_device object per IB device,
+	 * and allocates a protection domain, memory range and FMR pool
+	 * for each.  If that fails for any reason, it will not register
+	 * the rds_ibdev at all.
+	 */
+	rds_ibdev = ib_get_client_data(dev, &rds_ib_client);
+	if (rds_ibdev == NULL) {
+		if (printk_ratelimit())
+			printk(KERN_NOTICE "RDS/IB: No client_data for device %s\n",
+					dev->name);
+		return -EOPNOTSUPP;
+	}
+
+	if (rds_ibdev->max_wrs < ic->i_send_ring.w_nr + 1)
+		rds_ib_ring_resize(&ic->i_send_ring, rds_ibdev->max_wrs - 1);
+	if (rds_ibdev->max_wrs < ic->i_recv_ring.w_nr + 1)
+		rds_ib_ring_resize(&ic->i_recv_ring, rds_ibdev->max_wrs - 1);
+
+	/* Protection domain and memory range */
+	ic->i_pd = rds_ibdev->pd;
+	ic->i_mr = rds_ibdev->mr;
+
+	ic->i_send_cq = ib_create_cq(dev, rds_ib_send_cq_comp_handler,
+				     rds_ib_cq_event_handler, conn,
+				     ic->i_send_ring.w_nr + 1, 0);
+	if (IS_ERR(ic->i_send_cq)) {
+		ret = PTR_ERR(ic->i_send_cq);
+		ic->i_send_cq = NULL;
+		rdsdebug("ib_create_cq send failed: %d\n", ret);
+		goto out;
+	}
+
+	ic->i_recv_cq = ib_create_cq(dev, rds_ib_recv_cq_comp_handler,
+				     rds_ib_cq_event_handler, conn,
+				     ic->i_recv_ring.w_nr, 0);
+	if (IS_ERR(ic->i_recv_cq)) {
+		ret = PTR_ERR(ic->i_recv_cq);
+		ic->i_recv_cq = NULL;
+		rdsdebug("ib_create_cq recv failed: %d\n", ret);
+		goto out;
+	}
+
+	ret = ib_req_notify_cq(ic->i_send_cq, IB_CQ_NEXT_COMP);
+	if (ret) {
+		rdsdebug("ib_req_notify_cq send failed: %d\n", ret);
+		goto out;
+	}
+
+	ret = ib_req_notify_cq(ic->i_recv_cq, IB_CQ_SOLICITED);
+	if (ret) {
+		rdsdebug("ib_req_notify_cq recv failed: %d\n", ret);
+		goto out;
+	}
+
+	/* XXX negotiate max send/recv with remote? */
+	memset(&attr, 0, sizeof(attr));
+	attr.event_handler = rds_ib_qp_event_handler;
+	attr.qp_context = conn;
+	/* + 1 to allow for the single ack message */
+	attr.cap.max_send_wr = ic->i_send_ring.w_nr + 1;
+	attr.cap.max_recv_wr = ic->i_recv_ring.w_nr + 1;
+	attr.cap.max_send_sge = rds_ibdev->max_sge;
+	attr.cap.max_recv_sge = RDS_IB_RECV_SGE;
+	attr.sq_sig_type = IB_SIGNAL_REQ_WR;
+	attr.qp_type = IB_QPT_RC;
+	attr.send_cq = ic->i_send_cq;
+	attr.recv_cq = ic->i_recv_cq;
+
+	/*
+	 * XXX this can fail if max_*_wr is too large?  Are we supposed
+	 * to back off until we get a value that the hardware can support?
+	 */
+	ret = rdma_create_qp(ic->i_cm_id, ic->i_pd, &attr);
+	if (ret) {
+		rdsdebug("rdma_create_qp failed: %d\n", ret);
+		goto out;
+	}
+
+	ic->i_send_hdrs = ib_dma_alloc_coherent(dev,
+					   ic->i_send_ring.w_nr *
+						sizeof(struct rds_header),
+					   &ic->i_send_hdrs_dma, GFP_KERNEL);
+	if (ic->i_send_hdrs == NULL) {
+		ret = -ENOMEM;
+		rdsdebug("ib_dma_alloc_coherent send failed\n");
+		goto out;
+	}
+
+	ic->i_recv_hdrs = ib_dma_alloc_coherent(dev,
+					   ic->i_recv_ring.w_nr *
+						sizeof(struct rds_header),
+					   &ic->i_recv_hdrs_dma, GFP_KERNEL);
+	if (ic->i_recv_hdrs == NULL) {
+		ret = -ENOMEM;
+		rdsdebug("ib_dma_alloc_coherent recv failed\n");
+		goto out;
+	}
+
+	ic->i_ack = ib_dma_alloc_coherent(dev, sizeof(struct rds_header),
+				       &ic->i_ack_dma, GFP_KERNEL);
+	if (ic->i_ack == NULL) {
+		ret = -ENOMEM;
+		rdsdebug("ib_dma_alloc_coherent ack failed\n");
+		goto out;
+	}
+
+	ic->i_sends = vmalloc(ic->i_send_ring.w_nr * sizeof(struct rds_ib_send_work));
+	if (ic->i_sends == NULL) {
+		ret = -ENOMEM;
+		rdsdebug("send allocation failed\n");
+		goto out;
+	}
+	rds_ib_send_init_ring(ic);
+
+	ic->i_recvs = vmalloc(ic->i_recv_ring.w_nr * sizeof(struct rds_ib_recv_work));
+	if (ic->i_recvs == NULL) {
+		ret = -ENOMEM;
+		rdsdebug("recv allocation failed\n");
+		goto out;
+	}
+
+	rds_ib_recv_init_ring(ic);
+	rds_ib_recv_init_ack(ic);
+
+	/* Post receive buffers - as a side effect, this will update
+	 * the posted credit count. */
+	rds_ib_recv_refill(conn, GFP_KERNEL, GFP_HIGHUSER, 1);
+
+	rdsdebug("conn %p pd %p mr %p cq %p %p\n", conn, ic->i_pd, ic->i_mr,
+		 ic->i_send_cq, ic->i_recv_cq);
+
+out:
+	return ret;
+}
+
+static u32 rds_ib_protocol_compatible(const struct rds_ib_connect_private *dp)
+{
+	u16 common;
+	u32 version = 0;
+
+	/* rdma_cm private data is odd - when there is any private data in the
+	 * request, we will be given a pretty large buffer without telling us the
+	 * original size. The only way to tell the difference is by looking at
+	 * the contents, which are initialized to zero.
+	 * If the protocol version fields aren't set, this is a connection attempt
+	 * from an older version. This could could be 3.0 or 2.0 - we can't tell.
+	 * We really should have changed this for OFED 1.3 :-( */
+	if (dp->dp_protocol_major == 0)
+		return RDS_PROTOCOL_3_0;
+
+	common = be16_to_cpu(dp->dp_protocol_minor_mask) & RDS_IB_SUPPORTED_PROTOCOLS;
+	if (dp->dp_protocol_major == 3 && common) {
+		version = RDS_PROTOCOL_3_0;
+		while ((common >>= 1) != 0)
+			version++;
+	} else if (printk_ratelimit()) {
+		printk(KERN_NOTICE "RDS: Connection from %pI4 using "
+			"incompatible protocol version %u.%u\n",
+			&dp->dp_saddr,
+			dp->dp_protocol_major,
+			dp->dp_protocol_minor);
+	}
+	return version;
+}
+
+int rds_ib_cm_handle_connect(struct rdma_cm_id *cm_id,
+				    struct rdma_cm_event *event)
+{
+	__be64 lguid = cm_id->route.path_rec->sgid.global.interface_id;
+	__be64 fguid = cm_id->route.path_rec->dgid.global.interface_id;
+	const struct rds_ib_connect_private *dp = event->param.conn.private_data;
+	struct rds_ib_connect_private dp_rep;
+	struct rds_connection *conn = NULL;
+	struct rds_ib_connection *ic = NULL;
+	struct rdma_conn_param conn_param;
+	u32 version;
+	int err, destroy = 1;
+
+	/* Check whether the remote protocol version matches ours. */
+	version = rds_ib_protocol_compatible(dp);
+	if (!version)
+		goto out;
+
+	rdsdebug("saddr %pI4 daddr %pI4 RDSv%u.%u lguid 0x%llx fguid "
+		 "0x%llx\n", &dp->dp_saddr, &dp->dp_daddr,
+		 RDS_PROTOCOL_MAJOR(version), RDS_PROTOCOL_MINOR(version),
+		 (unsigned long long)be64_to_cpu(lguid),
+		 (unsigned long long)be64_to_cpu(fguid));
+
+	conn = rds_conn_create(dp->dp_daddr, dp->dp_saddr, &rds_ib_transport,
+			       GFP_KERNEL);
+	if (IS_ERR(conn)) {
+		rdsdebug("rds_conn_create failed (%ld)\n", PTR_ERR(conn));
+		conn = NULL;
+		goto out;
+	}
+
+	/*
+	 * The connection request may occur while the
+	 * previous connection exist, e.g. in case of failover.
+	 * But as connections may be initiated simultaneously
+	 * by both hosts, we have a random backoff mechanism -
+	 * see the comment above rds_queue_reconnect()
+	 */
+	mutex_lock(&conn->c_cm_lock);
+	if (!rds_conn_transition(conn, RDS_CONN_DOWN, RDS_CONN_CONNECTING)) {
+		if (rds_conn_state(conn) == RDS_CONN_UP) {
+			rdsdebug("incoming connect while connecting\n");
+			rds_conn_drop(conn);
+			rds_ib_stats_inc(s_ib_listen_closed_stale);
+		} else
+		if (rds_conn_state(conn) == RDS_CONN_CONNECTING) {
+			/* Wait and see - our connect may still be succeeding */
+			rds_ib_stats_inc(s_ib_connect_raced);
+		}
+		mutex_unlock(&conn->c_cm_lock);
+		goto out;
+	}
+
+	ic = conn->c_transport_data;
+
+	rds_ib_set_protocol(conn, version);
+	rds_ib_set_flow_control(conn, be32_to_cpu(dp->dp_credit));
+
+	/* If the peer gave us the last packet it saw, process this as if
+	 * we had received a regular ACK. */
+	if (dp->dp_ack_seq)
+		rds_send_drop_acked(conn, be64_to_cpu(dp->dp_ack_seq), NULL);
+
+	BUG_ON(cm_id->context);
+	BUG_ON(ic->i_cm_id);
+
+	ic->i_cm_id = cm_id;
+	cm_id->context = conn;
+
+	/* We got halfway through setting up the ib_connection, if we
+	 * fail now, we have to take the long route out of this mess. */
+	destroy = 0;
+
+	err = rds_ib_setup_qp(conn);
+	if (err) {
+		rds_ib_conn_error(conn, "rds_ib_setup_qp failed (%d)\n", err);
+		goto out;
+	}
+
+	rds_ib_cm_fill_conn_param(conn, &conn_param, &dp_rep, version);
+
+	/* rdma_accept() calls rdma_reject() internally if it fails */
+	err = rdma_accept(cm_id, &conn_param);
+	mutex_unlock(&conn->c_cm_lock);
+	if (err) {
+		rds_ib_conn_error(conn, "rdma_accept failed (%d)\n", err);
+		goto out;
+	}
+
+	return 0;
+
+out:
+	rdma_reject(cm_id, NULL, 0);
+	return destroy;
+}
+
+
+int rds_ib_cm_initiate_connect(struct rdma_cm_id *cm_id)
+{
+	struct rds_connection *conn = cm_id->context;
+	struct rds_ib_connection *ic = conn->c_transport_data;
+	struct rdma_conn_param conn_param;
+	struct rds_ib_connect_private dp;
+	int ret;
+
+	/* If the peer doesn't do protocol negotiation, we must
+	 * default to RDSv3.0 */
+	rds_ib_set_protocol(conn, RDS_PROTOCOL_3_0);
+	ic->i_flowctl = rds_ib_sysctl_flow_control;	/* advertise flow control */
+
+	ret = rds_ib_setup_qp(conn);
+	if (ret) {
+		rds_ib_conn_error(conn, "rds_ib_setup_qp failed (%d)\n", ret);
+		goto out;
+	}
+
+	rds_ib_cm_fill_conn_param(conn, &conn_param, &dp, RDS_PROTOCOL_VERSION);
+
+	ret = rdma_connect(cm_id, &conn_param);
+	if (ret)
+		rds_ib_conn_error(conn, "rdma_connect failed (%d)\n", ret);
+
+out:
+	/* Beware - returning non-zero tells the rdma_cm to destroy
+	 * the cm_id. We should certainly not do it as long as we still
+	 * "own" the cm_id. */
+	if (ret) {
+		if (ic->i_cm_id == cm_id)
+			ret = 0;
+	}
+	return ret;
+}
+
+int rds_ib_conn_connect(struct rds_connection *conn)
+{
+	struct rds_ib_connection *ic = conn->c_transport_data;
+	struct sockaddr_in src, dest;
+	int ret;
+
+	/* XXX I wonder what affect the port space has */
+	/* delegate cm event handler to rdma_transport */
+	ic->i_cm_id = rdma_create_id(rds_rdma_cm_event_handler, conn,
+				     RDMA_PS_TCP);
+	if (IS_ERR(ic->i_cm_id)) {
+		ret = PTR_ERR(ic->i_cm_id);
+		ic->i_cm_id = NULL;
+		rdsdebug("rdma_create_id() failed: %d\n", ret);
+		goto out;
+	}
+
+	rdsdebug("created cm id %p for conn %p\n", ic->i_cm_id, conn);
+
+	src.sin_family = AF_INET;
+	src.sin_addr.s_addr = (__force u32)conn->c_laddr;
+	src.sin_port = (__force u16)htons(0);
+
+	dest.sin_family = AF_INET;
+	dest.sin_addr.s_addr = (__force u32)conn->c_faddr;
+	dest.sin_port = (__force u16)htons(RDS_PORT);
+
+	ret = rdma_resolve_addr(ic->i_cm_id, (struct sockaddr *)&src,
+				(struct sockaddr *)&dest,
+				RDS_RDMA_RESOLVE_TIMEOUT_MS);
+	if (ret) {
+		rdsdebug("addr resolve failed for cm id %p: %d\n", ic->i_cm_id,
+			 ret);
+		rdma_destroy_id(ic->i_cm_id);
+		ic->i_cm_id = NULL;
+	}
+
+out:
+	return ret;
+}
+
+/*
+ * This is so careful about only cleaning up resources that were built up
+ * so that it can be called at any point during startup.  In fact it
+ * can be called multiple times for a given connection.
+ */
+void rds_ib_conn_shutdown(struct rds_connection *conn)
+{
+	struct rds_ib_connection *ic = conn->c_transport_data;
+	int err = 0;
+
+	rdsdebug("cm %p pd %p cq %p %p qp %p\n", ic->i_cm_id,
+		 ic->i_pd, ic->i_send_cq, ic->i_recv_cq,
+		 ic->i_cm_id ? ic->i_cm_id->qp : NULL);
+
+	if (ic->i_cm_id) {
+		struct ib_device *dev = ic->i_cm_id->device;
+
+		rdsdebug("disconnecting cm %p\n", ic->i_cm_id);
+		err = rdma_disconnect(ic->i_cm_id);
+		if (err) {
+			/* Actually this may happen quite frequently, when
+			 * an outgoing connect raced with an incoming connect.
+			 */
+			rdsdebug("failed to disconnect, cm: %p err %d\n",
+				ic->i_cm_id, err);
+		}
+
+		wait_event(rds_ib_ring_empty_wait,
+			rds_ib_ring_empty(&ic->i_send_ring) &&
+			rds_ib_ring_empty(&ic->i_recv_ring));
+
+		if (ic->i_send_hdrs)
+			ib_dma_free_coherent(dev,
+					   ic->i_send_ring.w_nr *
+						sizeof(struct rds_header),
+					   ic->i_send_hdrs,
+					   ic->i_send_hdrs_dma);
+
+		if (ic->i_recv_hdrs)
+			ib_dma_free_coherent(dev,
+					   ic->i_recv_ring.w_nr *
+						sizeof(struct rds_header),
+					   ic->i_recv_hdrs,
+					   ic->i_recv_hdrs_dma);
+
+		if (ic->i_ack)
+			ib_dma_free_coherent(dev, sizeof(struct rds_header),
+					     ic->i_ack, ic->i_ack_dma);
+
+		if (ic->i_sends)
+			rds_ib_send_clear_ring(ic);
+		if (ic->i_recvs)
+			rds_ib_recv_clear_ring(ic);
+
+		if (ic->i_cm_id->qp)
+			rdma_destroy_qp(ic->i_cm_id);
+		if (ic->i_send_cq)
+			ib_destroy_cq(ic->i_send_cq);
+		if (ic->i_recv_cq)
+			ib_destroy_cq(ic->i_recv_cq);
+		rdma_destroy_id(ic->i_cm_id);
+
+		/*
+		 * Move connection back to the nodev list.
+		 */
+		if (ic->rds_ibdev) {
+
+			spin_lock_irq(&ic->rds_ibdev->spinlock);
+			BUG_ON(list_empty(&ic->ib_node));
+			list_del(&ic->ib_node);
+			spin_unlock_irq(&ic->rds_ibdev->spinlock);
+
+			spin_lock_irq(&ib_nodev_conns_lock);
+			list_add_tail(&ic->ib_node, &ib_nodev_conns);
+			spin_unlock_irq(&ib_nodev_conns_lock);
+			ic->rds_ibdev = NULL;
+		}
+
+		ic->i_cm_id = NULL;
+		ic->i_pd = NULL;
+		ic->i_mr = NULL;
+		ic->i_send_cq = NULL;
+		ic->i_recv_cq = NULL;
+		ic->i_send_hdrs = NULL;
+		ic->i_recv_hdrs = NULL;
+		ic->i_ack = NULL;
+	}
+	BUG_ON(ic->rds_ibdev);
+
+	/* Clear pending transmit */
+	if (ic->i_rm) {
+		rds_message_put(ic->i_rm);
+		ic->i_rm = NULL;
+	}
+
+	/* Clear the ACK state */
+	clear_bit(IB_ACK_IN_FLIGHT, &ic->i_ack_flags);
+	rds_ib_set_64bit(&ic->i_ack_next, 0);
+	ic->i_ack_recv = 0;
+
+	/* Clear flow control state */
+	ic->i_flowctl = 0;
+	atomic_set(&ic->i_credits, 0);
+
+	rds_ib_ring_init(&ic->i_send_ring, rds_ib_sysctl_max_send_wr);
+	rds_ib_ring_init(&ic->i_recv_ring, rds_ib_sysctl_max_recv_wr);
+
+	if (ic->i_ibinc) {
+		rds_inc_put(&ic->i_ibinc->ii_inc);
+		ic->i_ibinc = NULL;
+	}
+
+	vfree(ic->i_sends);
+	ic->i_sends = NULL;
+	vfree(ic->i_recvs);
+	ic->i_recvs = NULL;
+}
+
+int rds_ib_conn_alloc(struct rds_connection *conn, gfp_t gfp)
+{
+	struct rds_ib_connection *ic;
+	unsigned long flags;
+
+	/* XXX too lazy? */
+	ic = kzalloc(sizeof(struct rds_ib_connection), GFP_KERNEL);
+	if (ic == NULL)
+		return -ENOMEM;
+
+	INIT_LIST_HEAD(&ic->ib_node);
+	mutex_init(&ic->i_recv_mutex);
+
+	/*
+	 * rds_ib_conn_shutdown() waits for these to be emptied so they
+	 * must be initialized before it can be called.
+	 */
+	rds_ib_ring_init(&ic->i_send_ring, rds_ib_sysctl_max_send_wr);
+	rds_ib_ring_init(&ic->i_recv_ring, rds_ib_sysctl_max_recv_wr);
+
+	ic->conn = conn;
+	conn->c_transport_data = ic;
+
+	spin_lock_irqsave(&ib_nodev_conns_lock, flags);
+	list_add_tail(&ic->ib_node, &ib_nodev_conns);
+	spin_unlock_irqrestore(&ib_nodev_conns_lock, flags);
+
+
+	rdsdebug("conn %p conn ic %p\n", conn, conn->c_transport_data);
+	return 0;
+}
+
+void rds_ib_conn_free(void *arg)
+{
+	struct rds_ib_connection *ic = arg;
+	rdsdebug("ic %p\n", ic);
+	list_del(&ic->ib_node);
+	kfree(ic);
+}
+
+
+/*
+ * An error occurred on the connection
+ */
+void
+__rds_ib_conn_error(struct rds_connection *conn, const char *fmt, ...)
+{
+	va_list ap;
+
+	rds_conn_drop(conn);
+
+	va_start(ap, fmt);
+	vprintk(fmt, ap);
+	va_end(ap);
+}
-- 
1.5.6.3

