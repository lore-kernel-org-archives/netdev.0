From: Michal Kalderon <Michal.Kalderon@cavium.com>
Subject: [RFC 14/19] RDMA/qedr: Add support for registering an iWARP device
Date: Mon, 26 Jun 2017 21:07:04 +0300
Message-ID: <1498500429-22557-15-git-send-email-Michal.Kalderon@cavium.com>
References: <1498500429-22557-1-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Michal Kalderon <Michal.Kalderon@cavium.com>,
        Ram Amrani <Ram.Amrani@cavium.com>,
        Ariel Elior <Ariel.Elior@cavium.com>
To: <michal.kalderon@cavium.com>, <ram.amrani@cavium.com>,
        <yuval.mintz@cavium.com>, <ariel.elior@cavium.com>,
        <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <linux-rdma@vger.kernel.org>, <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0058.outbound.protection.outlook.com ([104.47.37.58]:25120
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751393AbdFZSOD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 26 Jun 2017 14:14:03 -0400
In-Reply-To: <1498500429-22557-1-git-send-email-Michal.Kalderon@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are slight differences between iWARP and RoCE in the ibdev
registration. This patch handles the changes.

Signed-off-by: Michal Kalderon <Michal.Kalderon@cavium.com>
Signed-off-by: Ram Amrani <Ram.Amrani@cavium.com>
Signed-off-by: Ariel Elior <Ariel.Elior@cavium.com>

---
 drivers/infiniband/hw/qedr/main.c  | 84 +++++++++++++++++++++++++++++++++++---
 drivers/infiniband/hw/qedr/qedr.h  |  3 ++
 drivers/infiniband/hw/qedr/verbs.c | 34 +++++++--------
 drivers/infiniband/hw/qedr/verbs.h |  2 +
 4 files changed, 97 insertions(+), 26 deletions(-)

diff --git a/drivers/infiniband/hw/qedr/main.c b/drivers/infiniband/hw/qedr/main.c
index b5851fd..ad227b5 100644
--- a/drivers/infiniband/hw/qedr/main.c
+++ b/drivers/infiniband/hw/qedr/main.c
@@ -33,6 +33,8 @@
 #include <rdma/ib_verbs.h>
 #include <rdma/ib_addr.h>
 #include <rdma/ib_user_verbs.h>
+#include <rdma/iw_cm.h>
+#include <rdma/ib_mad.h>
 #include <linux/netdevice.h>
 #include <linux/iommu.h>
 #include <linux/pci.h>
@@ -94,8 +96,75 @@ static struct net_device *qedr_get_netdev(struct ib_device *dev, u8 port_num)
 	return qdev->ndev;
 }
 
+int qedr_roce_port_immutable(struct ib_device *ibdev, u8 port_num,
+			     struct ib_port_immutable *immutable)
+{
+	struct ib_port_attr attr;
+	int err;
+
+	err = qedr_query_port(ibdev, port_num, &attr);
+	if (err)
+		return err;
+
+	immutable->pkey_tbl_len = attr.pkey_tbl_len;
+	immutable->gid_tbl_len = attr.gid_tbl_len;
+	immutable->core_cap_flags = RDMA_CORE_PORT_IBA_ROCE |
+	    RDMA_CORE_PORT_IBA_ROCE_UDP_ENCAP;
+	immutable->max_mad_size = IB_MGMT_MAD_SIZE;
+
+	return 0;
+}
+
+int qedr_iw_port_immutable(struct ib_device *ibdev, u8 port_num,
+			   struct ib_port_immutable *immutable)
+{
+	struct ib_port_attr attr;
+	int err;
+
+	err = qedr_query_port(ibdev, port_num, &attr);
+	if (err)
+		return err;
+
+	immutable->pkey_tbl_len = 1;
+	immutable->gid_tbl_len = 1;
+	immutable->core_cap_flags = RDMA_CORE_PORT_IWARP;
+	immutable->max_mad_size = 0;
+
+	return 0;
+}
+
+int qedr_iw_register_device(struct qedr_dev *dev)
+{
+	dev->ibdev.node_type = RDMA_NODE_RNIC;
+	dev->ibdev.query_gid = qedr_iw_query_gid;
+
+	dev->ibdev.get_port_immutable = qedr_iw_port_immutable;
+
+	dev->ibdev.iwcm = kzalloc(sizeof(*dev->ibdev.iwcm), GFP_KERNEL);
+	if (!dev->ibdev.iwcm)
+		return -ENOMEM;
+
+	memcpy(dev->ibdev.iwcm->ifname,
+	       dev->ndev->name, sizeof(dev->ibdev.iwcm->ifname));
+
+	return 0;
+}
+
+void qedr_roce_register_device(struct qedr_dev *dev)
+{
+	dev->ibdev.node_type = RDMA_NODE_IB_CA;
+	dev->ibdev.query_gid = qedr_query_gid;
+
+	dev->ibdev.add_gid = qedr_add_gid;
+	dev->ibdev.del_gid = qedr_del_gid;
+
+	dev->ibdev.get_port_immutable = qedr_roce_port_immutable;
+}
+
 static int qedr_register_device(struct qedr_dev *dev)
 {
+	int rc;
+
 	strlcpy(dev->ibdev.name, "qedr%d", IB_DEVICE_NAME_MAX);
 
 	dev->ibdev.node_guid = dev->attr.node_guid;
@@ -123,18 +192,21 @@ static int qedr_register_device(struct qedr_dev *dev)
 				     QEDR_UVERBS(POST_SEND) |
 				     QEDR_UVERBS(POST_RECV);
 
+	if (IS_IWARP(dev)) {
+		rc = qedr_iw_register_device(dev);
+		if (rc)
+			return rc;
+	} else {
+		qedr_roce_register_device(dev);
+	}
+
 	dev->ibdev.phys_port_cnt = 1;
 	dev->ibdev.num_comp_vectors = dev->num_cnq;
-	dev->ibdev.node_type = RDMA_NODE_IB_CA;
 
 	dev->ibdev.query_device = qedr_query_device;
 	dev->ibdev.query_port = qedr_query_port;
 	dev->ibdev.modify_port = qedr_modify_port;
 
-	dev->ibdev.query_gid = qedr_query_gid;
-	dev->ibdev.add_gid = qedr_add_gid;
-	dev->ibdev.del_gid = qedr_del_gid;
-
 	dev->ibdev.alloc_ucontext = qedr_alloc_ucontext;
 	dev->ibdev.dealloc_ucontext = qedr_dealloc_ucontext;
 	dev->ibdev.mmap = qedr_mmap;
@@ -168,7 +240,7 @@ static int qedr_register_device(struct qedr_dev *dev)
 	dev->ibdev.post_recv = qedr_post_recv;
 
 	dev->ibdev.process_mad = qedr_process_mad;
-	dev->ibdev.get_port_immutable = qedr_port_immutable;
+
 	dev->ibdev.get_netdev = qedr_get_netdev;
 
 	dev->ibdev.dev.parent = &dev->pdev->dev;
diff --git a/drivers/infiniband/hw/qedr/qedr.h b/drivers/infiniband/hw/qedr/qedr.h
index ab7784b..c52fde0 100644
--- a/drivers/infiniband/hw/qedr/qedr.h
+++ b/drivers/infiniband/hw/qedr/qedr.h
@@ -44,6 +44,8 @@
 #define QEDR_MODULE_VERSION	"8.10.10.0"
 #define QEDR_NODE_DESC "QLogic 579xx RoCE HCA"
 #define DP_NAME(dev) ((dev)->ibdev.name)
+#define IS_IWARP(_dev) ((_dev)->rdma_type == QED_RDMA_TYPE_IWARP)
+#define IS_ROCE(_dev) ((_dev)->rdma_type == QED_RDMA_TYPE_ROCE)
 
 #define DP_DEBUG(dev, module, fmt, ...)					\
 	pr_debug("(%s) " module ": " fmt,				\
@@ -161,6 +163,7 @@ struct qedr_dev {
 	struct qedr_cq		*gsi_sqcq;
 	struct qedr_cq		*gsi_rqcq;
 	struct qedr_qp		*gsi_qp;
+	enum qed_rdma_type	rdma_type;
 
 	unsigned long enet_state;
 };
diff --git a/drivers/infiniband/hw/qedr/verbs.c b/drivers/infiniband/hw/qedr/verbs.c
index 16637ec..9b74015 100644
--- a/drivers/infiniband/hw/qedr/verbs.c
+++ b/drivers/infiniband/hw/qedr/verbs.c
@@ -62,6 +62,20 @@ int qedr_query_pkey(struct ib_device *ibdev, u8 port, u16 index, u16 *pkey)
 	return 0;
 }
 
+int qedr_iw_query_gid(struct ib_device *ibdev, u8 port,
+		      int index, union ib_gid *sgid)
+{
+	struct qedr_dev *dev = get_qedr_dev(ibdev);
+
+	memset(sgid->raw, 0, sizeof(sgid->raw));
+	ether_addr_copy(sgid->raw, dev->ndev->dev_addr);
+
+	DP_DEBUG(dev, QEDR_MSG_INIT, "QUERY sgid[%d]=%llx:%llx\n", index,
+		 sgid->global.interface_id, sgid->global.subnet_prefix);
+
+	return 0;
+}
+
 int qedr_query_gid(struct ib_device *ibdev, u8 port, int index,
 		   union ib_gid *sgid)
 {
@@ -3592,23 +3606,3 @@ int qedr_process_mad(struct ib_device *ibdev, int process_mad_flags,
 		 mad_hdr->method, mad_hdr->mgmt_class, mad_hdr->status);
 	return IB_MAD_RESULT_SUCCESS;
 }
-
-int qedr_port_immutable(struct ib_device *ibdev, u8 port_num,
-			struct ib_port_immutable *immutable)
-{
-	struct ib_port_attr attr;
-	int err;
-
-	immutable->core_cap_flags = RDMA_CORE_PORT_IBA_ROCE |
-				    RDMA_CORE_PORT_IBA_ROCE_UDP_ENCAP;
-
-	err = ib_query_port(ibdev, port_num, &attr);
-	if (err)
-		return err;
-
-	immutable->pkey_tbl_len = attr.pkey_tbl_len;
-	immutable->gid_tbl_len = attr.gid_tbl_len;
-	immutable->max_mad_size = IB_MGMT_MAD_SIZE;
-
-	return 0;
-}
diff --git a/drivers/infiniband/hw/qedr/verbs.h b/drivers/infiniband/hw/qedr/verbs.h
index 0f8ab49..1a94425 100644
--- a/drivers/infiniband/hw/qedr/verbs.h
+++ b/drivers/infiniband/hw/qedr/verbs.h
@@ -39,6 +39,8 @@ int qedr_modify_port(struct ib_device *, u8 port, int mask,
 		     struct ib_port_modify *props);
 
 int qedr_query_gid(struct ib_device *, u8 port, int index, union ib_gid *gid);
+int qedr_iw_query_gid(struct ib_device *ibdev, u8 port,
+		      int index, union ib_gid *gid);
 
 int qedr_query_pkey(struct ib_device *, u8 port, u16 index, u16 *pkey);
 
-- 
1.8.3.1
