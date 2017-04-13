From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>
Subject: [PATCH rdma-next v2 02/12] IB/opa-vnic: RDMA NETDEV interface
Date: Wed, 12 Apr 2017 20:29:20 -0700
Message-ID: <1492054170-23577-3-git-send-email-niranjana.vishwanathapura@intel.com>
References: <1492054170-23577-1-git-send-email-niranjana.vishwanathapura@intel.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        dennis.dalessandro@intel.com, ira.weiny@intel.com,
        Niranjana Vishwanathapura <niranjana.vishwanathapura@intel.com>
To: dledford@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:28888 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756014AbdDMD3k (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 23:29:40 -0400
In-Reply-To: <1492054170-23577-1-git-send-email-niranjana.vishwanathapura@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add rdma netdev interface to ib device structure allowing rdma netdev
devices to be allocated by ib clients.

Reviewed-by: Dennis Dalessandro <dennis.dalessandro@intel.com>
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Signed-off-by: Niranjana Vishwanathapura <niranjana.vishwanathapura@intel.com>
---
 include/rdma/ib_verbs.h | 33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)

diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index 3a8e058..5c6b8c0 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -55,6 +55,7 @@
 #include <net/ip.h>
 #include <linux/string.h>
 #include <linux/slab.h>
+#include <linux/netdevice.h>
 
 #include <linux/if_link.h>
 #include <linux/atomic.h>
@@ -1877,6 +1878,24 @@ struct ib_port_immutable {
 	u32                           max_mad_size;
 };
 
+/* rdma netdev type - specifies protocol type */
+enum rdma_netdev_t {
+	RDMA_NETDEV_OPA_VNIC
+};
+
+/**
+ * struct rdma_netdev - rdma netdev
+ * For cases where netstack interfacing is required.
+ */
+struct rdma_netdev {
+	void              *clnt_priv;
+	struct ib_device  *hca;
+	u8                 port_num;
+
+	/* control functions */
+	void (*set_id)(struct net_device *netdev, int id);
+};
+
 struct ib_device {
 	char                          name[IB_DEVICE_NAME_MAX];
 
@@ -2127,6 +2146,20 @@ struct ib_device {
 							   struct ib_rwq_ind_table_init_attr *init_attr,
 							   struct ib_udata *udata);
 	int                        (*destroy_rwq_ind_table)(struct ib_rwq_ind_table *wq_ind_table);
+	/**
+	 * rdma netdev operations
+	 *
+	 * Driver implementing alloc_rdma_netdev must return -EOPNOTSUPP if it
+	 * doesn't support the specified rdma netdev type.
+	 */
+	struct net_device *(*alloc_rdma_netdev)(
+					struct ib_device *device,
+					u8 port_num,
+					enum rdma_netdev_t type,
+					const char *name,
+					unsigned char name_assign_type,
+					void (*setup)(struct net_device *));
+	void (*free_rdma_netdev)(struct net_device *netdev);
 
 	struct module               *owner;
 	struct device                dev;
-- 
1.8.3.1
