From: Ram Amrani <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: [RFC v2 10/12] qedr: Add GSI support
Date: Tue, 20 Sep 2016 13:36:02 +0300
Message-ID: <1474367764-9555-11-git-send-email-Ram.Amrani@cavium.com>
References: <1474367764-9555-1-git-send-email-Ram.Amrani@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>, <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>, <rajesh.borundia-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Ram amrani <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1474367764-9555-1-git-send-email-Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ram amrani <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>

Add support for GSI over light L2.

Signed-off-by: Rajesh Borundia <rajesh.borundia-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Ram Amrani <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
---
 drivers/infiniband/hw/qedr/Makefile        |   2 +-
 drivers/infiniband/hw/qedr/main.c          |   3 +
 drivers/infiniband/hw/qedr/qedr.h          |  15 +
 drivers/infiniband/hw/qedr/qedr_cm.c       | 626 +++++++++++++++++++++++++++++
 drivers/infiniband/hw/qedr/qedr_cm.h       |  21 +
 drivers/infiniband/hw/qedr/verbs.c         |  39 ++
 drivers/net/ethernet/qlogic/qed/qed_ll2.c  |  97 ++++-
 drivers/net/ethernet/qlogic/qed/qed_ll2.h  |  22 +-
 drivers/net/ethernet/qlogic/qed/qed_roce.c |  66 +++
 9 files changed, 878 insertions(+), 13 deletions(-)
 create mode 100644 drivers/infiniband/hw/qedr/qedr_cm.c

diff --git a/drivers/infiniband/hw/qedr/Makefile b/drivers/infiniband/hw/qedr/Makefile
index b10f2b1..ba7067c 100644
--- a/drivers/infiniband/hw/qedr/Makefile
+++ b/drivers/infiniband/hw/qedr/Makefile
@@ -1,3 +1,3 @@
 obj-$(CONFIG_INFINIBAND_QEDR) := qedr.o
 
-qedr-y := main.o verbs.o
+qedr-y := main.o verbs.o qedr_cm.o
diff --git a/drivers/infiniband/hw/qedr/main.c b/drivers/infiniband/hw/qedr/main.c
index fd602ad..d3555bf 100644
--- a/drivers/infiniband/hw/qedr/main.c
+++ b/drivers/infiniband/hw/qedr/main.c
@@ -140,6 +140,9 @@ static int qedr_register_device(struct qedr_dev *dev)
 
 	dev->ibdev.query_pkey = qedr_query_pkey;
 
+	dev->ibdev.create_ah = qedr_create_ah;
+	dev->ibdev.destroy_ah = qedr_destroy_ah;
+
 	dev->ibdev.get_dma_mr = qedr_get_dma_mr;
 	dev->ibdev.dereg_mr = qedr_dereg_mr;
 	dev->ibdev.reg_user_mr = qedr_reg_user_mr;
diff --git a/drivers/infiniband/hw/qedr/qedr.h b/drivers/infiniband/hw/qedr/qedr.h
index 18af842..37a7740 100644
--- a/drivers/infiniband/hw/qedr/qedr.h
+++ b/drivers/infiniband/hw/qedr/qedr.h
@@ -53,6 +53,7 @@ enum DP_QEDR_MODULE {
 	QEDR_MSG_SQ = 0x80000,
 	QEDR_MSG_QP = (QEDR_MSG_SQ | QEDR_MSG_RQ),
 	QEDR_MSG_MR = 0x100000,
+	QEDR_MSG_GSI = 0x200000,
 	QEDR_MSG_MISC = 0x400000,
 };
 
@@ -146,6 +147,10 @@ struct qedr_dev {
 	u8			num_hwfns;
 	uint			wq_multiplier;
 	u8			gsi_ll2_mac_address[ETH_ALEN];
+	int			gsi_qp_created;
+	struct qedr_cq		*gsi_sqcq;
+	struct qedr_cq		*gsi_rqcq;
+	struct qedr_qp		*gsi_qp;
 };
 
 #define QEDR_MAX_SQ_PBL			(0x8000)
@@ -244,6 +249,9 @@ struct qedr_cq {
 
 	u16 icid;
 
+	/* Lock to protect completion handler */
+	spinlock_t comp_handler_lock;
+
 	/* Lock to protect multiplem CQ's */
 	spinlock_t cq_lock;
 	u8 arm_flags;
@@ -290,6 +298,7 @@ struct qedr_qp_hwq_info {
 	u16 prod;
 	u16 cons;
 	u16 wqe_cons;
+	u16 gsi_cons;
 	u16 max_wr;
 
 	/* DB */
@@ -364,6 +373,7 @@ struct qedr_qp {
 		struct ib_sge sg_list[RDMA_MAX_SGE_PER_RQ_WQE];
 		u8 wqe_size;
 
+		u8 smac[ETH_ALEN];
 		u16 vlan_id;
 		int rc;
 	} *rqe_wr_id;
@@ -472,6 +482,11 @@ static inline struct qedr_qp *get_qedr_qp(struct ib_qp *ibqp)
 	return container_of(ibqp, struct qedr_qp, ibqp);
 }
 
+static inline struct qedr_ah *get_qedr_ah(struct ib_ah *ibah)
+{
+	return container_of(ibah, struct qedr_ah, ibah);
+}
+
 static inline struct qedr_mr *get_qedr_mr(struct ib_mr *ibmr)
 {
 	return container_of(ibmr, struct qedr_mr, ibmr);
diff --git a/drivers/infiniband/hw/qedr/qedr_cm.c b/drivers/infiniband/hw/qedr/qedr_cm.c
new file mode 100644
index 0000000..8ba6240
--- /dev/null
+++ b/drivers/infiniband/hw/qedr/qedr_cm.c
@@ -0,0 +1,626 @@
+/* QLogic qed NIC Driver
+ * Copyright (c) 2015 QLogic Corporation
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+#include <linux/dma-mapping.h>
+#include <linux/crc32.h>
+#include <linux/iommu.h>
+#include <net/ip.h>
+#include <net/ipv6.h>
+#include <net/udp.h>
+
+#include <rdma/ib_verbs.h>
+#include <rdma/ib_user_verbs.h>
+#include <rdma/iw_cm.h>
+#include <rdma/ib_umem.h>
+#include <rdma/ib_addr.h>
+#include <rdma/ib_cache.h>
+
+#include "qedr_hsi.h"
+#include <linux/qed/qed_if.h>
+#include <linux/qed/qed_roce_if.h>
+#include "qedr.h"
+#include "qedr_hsi.h"
+#include "verbs.h"
+#include <uapi/rdma/providers/qedr-abi.h>
+#include "qedr_hsi.h"
+#include "qedr_cm.h"
+
+void qedr_inc_sw_gsi_cons(struct qedr_qp_hwq_info *info)
+{
+	info->gsi_cons = (info->gsi_cons + 1) % info->max_wr;
+}
+
+void qedr_store_gsi_qp_cq(struct qedr_dev *dev, struct qedr_qp *qp,
+			  struct ib_qp_init_attr *attrs)
+{
+	dev->gsi_qp_created = 1;
+	dev->gsi_sqcq = get_qedr_cq(attrs->send_cq);
+	dev->gsi_rqcq = get_qedr_cq(attrs->recv_cq);
+	dev->gsi_qp = qp;
+}
+
+void qedr_ll2_tx_cb(void *_qdev, struct qed_roce_ll2_packet *pkt)
+{
+	struct qedr_dev *dev = (struct qedr_dev *)_qdev;
+	struct qedr_cq *cq = dev->gsi_sqcq;
+	struct qedr_qp *qp = dev->gsi_qp;
+	unsigned long flags;
+
+	DP_VERBOSE(dev, QEDR_MSG_GSI,
+		   "LL2 TX CB: gsi_sqcq=%p, gsi_rqcq=%p, gsi_cons=%d, ibcq_comp=%s\n",
+		   dev->gsi_sqcq, dev->gsi_rqcq, qp->sq.gsi_cons,
+		   cq->ibcq.comp_handler ? "Yes" : "No");
+
+	dma_free_coherent(&dev->pdev->dev, pkt->header.len, pkt->header.vaddr,
+			  pkt->header.baddr);
+	kfree(pkt);
+
+	spin_lock_irqsave(&qp->q_lock, flags);
+	qedr_inc_sw_gsi_cons(&qp->sq);
+	spin_unlock_irqrestore(&qp->q_lock, flags);
+
+	if (cq->ibcq.comp_handler) {
+		spin_lock_irqsave(&cq->comp_handler_lock, flags);
+		(*cq->ibcq.comp_handler) (&cq->ibcq, cq->ibcq.cq_context);
+		spin_unlock_irqrestore(&cq->comp_handler_lock, flags);
+	}
+}
+
+static inline void qedr_print_hex_dump(const char *str, void *buf, size_t size)
+{
+	print_hex_dump(KERN_INFO, str, DUMP_PREFIX_OFFSET, 32, 1, buf,
+		       size, false);
+}
+
+void qedr_ll2_rx_cb(void *_dev, struct qed_roce_ll2_packet *pkt,
+		    struct qed_roce_ll2_rx_params *params)
+{
+	struct qedr_dev *dev = (struct qedr_dev *)_dev;
+	struct qedr_cq *cq = dev->gsi_rqcq;
+	struct qedr_qp *qp = dev->gsi_qp;
+	unsigned long flags;
+
+	/* CM packet dump - supported unless IOMMU is enabled */
+	if (unlikely((dev->dp_level <= QED_LEVEL_VERBOSE) &&
+		     (dev->dp_module & QEDR_MSG_GSI) &&
+		     (!iommu_present(&pci_bus_type))))
+		qedr_print_hex_dump("RX CM ",
+				    phys_to_virt(pkt->payload[0].baddr),
+				    pkt->payload[0].len + IB_GRH_BYTES);
+
+	spin_lock_irqsave(&qp->q_lock, flags);
+
+	qp->rqe_wr_id[qp->rq.gsi_cons].rc = params->rc;
+	qp->rqe_wr_id[qp->rq.gsi_cons].vlan_id = params->vlan_id;
+	qp->rqe_wr_id[qp->rq.gsi_cons].sg_list[0].length = pkt->payload[0].len;
+	ether_addr_copy(qp->rqe_wr_id[qp->rq.gsi_cons].smac, params->smac);
+
+	qedr_inc_sw_gsi_cons(&qp->rq);
+
+	spin_unlock_irqrestore(&qp->q_lock, flags);
+
+	if (cq->ibcq.comp_handler) {
+		spin_lock_irqsave(&cq->comp_handler_lock, flags);
+		(*cq->ibcq.comp_handler) (&cq->ibcq, cq->ibcq.cq_context);
+		spin_unlock_irqrestore(&cq->comp_handler_lock, flags);
+	}
+}
+
+static void qedr_destroy_gsi_cq(struct qedr_dev *dev,
+				struct ib_qp_init_attr *attrs)
+{
+	struct qed_rdma_destroy_cq_in_params iparams;
+	struct qed_rdma_destroy_cq_out_params oparams;
+	struct qedr_cq *cq;
+
+	cq = get_qedr_cq(attrs->send_cq);
+	iparams.icid = cq->icid;
+	dev->ops->rdma_destroy_cq(dev->rdma_ctx, &iparams, &oparams);
+	dev->ops->common->chain_free(dev->cdev, &cq->pbl);
+
+	cq = get_qedr_cq(attrs->recv_cq);
+	/* if a dedicated recv_cq was used, delete it too */
+	if (iparams.icid != cq->icid) {
+		iparams.icid = cq->icid;
+		dev->ops->rdma_destroy_cq(dev->rdma_ctx, &iparams, &oparams);
+		dev->ops->common->chain_free(dev->cdev, &cq->pbl);
+	}
+}
+
+static inline int qedr_check_gsi_qp_attrs(struct qedr_dev *dev,
+					  struct ib_qp_init_attr *attrs)
+{
+	if (attrs->cap.max_recv_sge > QEDR_GSI_MAX_RECV_SGE) {
+		DP_ERR(dev,
+		       " create gsi qp: failed. max_recv_sge is larger the max %d>%d\n",
+		       attrs->cap.max_recv_sge, QEDR_GSI_MAX_RECV_SGE);
+		return -EINVAL;
+	}
+
+	if (attrs->cap.max_recv_wr > QEDR_GSI_MAX_RECV_WR) {
+		DP_ERR(dev,
+		       " create gsi qp: failed. max_recv_wr is too large %d>%d\n",
+		       attrs->cap.max_recv_wr, QEDR_GSI_MAX_RECV_WR);
+		return -EINVAL;
+	}
+
+	if (attrs->cap.max_send_wr > QEDR_GSI_MAX_SEND_WR) {
+		DP_ERR(dev,
+		       " create gsi qp: failed. max_send_wr is too large %d>%d\n",
+		       attrs->cap.max_send_wr, QEDR_GSI_MAX_SEND_WR);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+struct ib_qp *qedr_create_gsi_qp(struct qedr_dev *dev,
+				 struct ib_qp_init_attr *attrs,
+				 struct qedr_qp *qp)
+{
+	struct qed_roce_ll2_params ll2_params;
+	int rc;
+
+	rc = qedr_check_gsi_qp_attrs(dev, attrs);
+	if (rc)
+		return ERR_PTR(rc);
+
+	/* configure and start LL2 */
+	memset(&ll2_params, 0, sizeof(ll2_params));
+	ll2_params.max_tx_buffers = attrs->cap.max_send_wr;
+	ll2_params.max_rx_buffers = attrs->cap.max_recv_wr;
+	ll2_params.cbs.tx_cb = qedr_ll2_tx_cb;
+	ll2_params.cbs.rx_cb = qedr_ll2_rx_cb;
+	ll2_params.cb_cookie = (void *)dev;
+	ll2_params.mtu = dev->ndev->mtu;
+	ether_addr_copy(ll2_params.mac_address, dev->ndev->dev_addr);
+	rc = dev->ops->roce_ll2_start(dev->cdev, &ll2_params);
+	if (rc) {
+		DP_ERR(dev, "create gsi qp: failed on ll2 start. rc=%d\n", rc);
+		return ERR_PTR(rc);
+	}
+
+	/* create QP */
+	qp->ibqp.qp_num = 1;
+	qp->rq.max_wr = attrs->cap.max_recv_wr;
+	qp->sq.max_wr = attrs->cap.max_send_wr;
+
+	qp->rqe_wr_id = kcalloc(qp->rq.max_wr, sizeof(*qp->rqe_wr_id),
+				GFP_KERNEL);
+	if (!qp->rqe_wr_id) {
+		DP_ERR(dev, "create gsi qp: failed on rqe_wr_id allocation\n");
+		goto err;
+	}
+	qp->wqe_wr_id = kcalloc(qp->sq.max_wr, sizeof(*qp->wqe_wr_id),
+				GFP_KERNEL);
+	if (!qp->wqe_wr_id) {
+		DP_ERR(dev, "create gsi qp: failed on wqe_wr_id allocation\n");
+		goto err;
+	}
+
+	qedr_store_gsi_qp_cq(dev, qp, attrs);
+	ether_addr_copy(dev->gsi_ll2_mac_address, dev->ndev->dev_addr);
+
+	/* the GSI CQ is handled by the driver so remove it from the FW */
+	qedr_destroy_gsi_cq(dev, attrs);
+	dev->gsi_rqcq->cq_type = QEDR_CQ_TYPE_GSI;
+	dev->gsi_rqcq->cq_type = QEDR_CQ_TYPE_GSI;
+
+	DP_VERBOSE(dev, QEDR_MSG_GSI, "created GSI QP %p\n", qp); 
+
+	return &qp->ibqp;
+
+err:
+	kfree(qp->rqe_wr_id);
+
+	rc = dev->ops->roce_ll2_stop(dev->cdev);
+	if (rc)
+		DP_ERR(dev, "create gsi qp: failed destroy on create\n");
+
+	return ERR_PTR(-ENOMEM);
+}
+
+int qedr_destroy_gsi_qp(struct qedr_dev *dev)
+{
+	int rc;
+
+	rc = dev->ops->roce_ll2_stop(dev->cdev);
+	if (rc)
+		DP_ERR(dev, "destroy gsi qp: failed (rc=%d)\n", rc);
+	else
+		DP_VERBOSE(dev, (QEDR_MSG_QP | QEDR_MSG_GSI),
+			   "destroy gsi qp: success\n");
+
+	return rc;
+}
+
+#define QEDR_MAX_UD_HEADER_SIZE	(100)
+#define QEDR_GSI_QPN		(1)
+static inline int qedr_gsi_build_header(struct qedr_dev *dev,
+					struct qedr_qp *qp,
+					struct ib_send_wr *swr,
+					struct ib_ud_header *udh,
+					int *roce_mode)
+{
+	bool has_vlan = false, has_grh_ipv6 = true;
+	struct ib_ah_attr *ah_attr = &get_qedr_ah(ud_wr(swr)->ah)->attr;
+	struct ib_global_route *grh = &ah_attr->grh;
+	union ib_gid sgid;
+	int send_size = 0;
+	u16 vlan_id = 0;
+	u16 ether_type;
+	struct ib_gid_attr sgid_attr;
+	int rc;
+	int ip_ver = 0;
+
+	bool has_udp = false;
+	int i;
+
+	send_size = 0;
+	for (i = 0; i < swr->num_sge; ++i)
+		send_size += swr->sg_list[i].length;
+
+	rc = ib_get_cached_gid(qp->ibqp.device, ah_attr->port_num,
+			       grh->sgid_index, &sgid, &sgid_attr);
+	if (rc) {
+		DP_ERR(dev,
+		       "gsi post send: failed to get cached GID (port=%d, ix=%d)\n",
+		       ah_attr->port_num, grh->sgid_index);
+		return rc;
+	}
+
+	vlan_id = rdma_vlan_dev_vlan_id(sgid_attr.ndev);
+	if (vlan_id < VLAN_CFI_MASK)
+		has_vlan = true;
+	if (sgid_attr.ndev)
+		dev_put(sgid_attr.ndev);
+
+	if (!memcmp(&sgid, &zgid, sizeof(sgid))) {
+		DP_ERR(dev, "gsi post send: GID not found GID index %d\n",
+		       ah_attr->grh.sgid_index);
+		return -ENOENT;
+	}
+
+	has_udp = (sgid_attr.gid_type == IB_GID_TYPE_ROCE_UDP_ENCAP);
+	if (!has_udp) {
+		/* RoCE v1 */
+		ether_type = ETH_P_ROCE;
+		*roce_mode = ROCE_V1;
+	} else if (ipv6_addr_v4mapped((struct in6_addr *)&sgid)) {
+		/* RoCE v2 IPv4 */
+		ip_ver = 4;
+		ether_type = ETH_P_IP;
+		has_grh_ipv6 = false;
+		*roce_mode = ROCE_V2_IPV4;
+	} else {
+		/* RoCE v2 IPv6 */
+		ip_ver = 6;
+		ether_type = ETH_P_IPV6;
+		*roce_mode = ROCE_V2_IPV6;
+	}
+
+	rc = ib_ud_header_init(send_size, false, true, has_vlan,
+			       has_grh_ipv6, ip_ver, has_udp, 0, udh);
+	if (rc) {
+		DP_ERR(dev, "gsi post send: failed to init header\n");
+		return rc;
+	}
+
+	/* ENET + VLAN headers */
+	ether_addr_copy(udh->eth.dmac_h, ah_attr->dmac);
+	ether_addr_copy(udh->eth.smac_h, dev->ndev->dev_addr);
+	if (has_vlan) {
+		udh->eth.type = htons(ETH_P_8021Q);
+		udh->vlan.tag = htons(vlan_id);
+		udh->vlan.type = htons(ether_type);
+	} else {
+		udh->eth.type = htons(ether_type);
+	}
+
+	/* BTH */
+	udh->bth.solicited_event = !!(swr->send_flags & IB_SEND_SOLICITED);
+	udh->bth.pkey = QEDR_ROCE_PKEY_DEFAULT;
+	udh->bth.destination_qpn = htonl(ud_wr(swr)->remote_qpn);
+	udh->bth.psn = htonl((qp->sq_psn++) & ((1 << 24) - 1));
+	udh->bth.opcode = IB_OPCODE_UD_SEND_ONLY;
+
+	/* DETH */
+	udh->deth.qkey = htonl(0x80010000);
+	udh->deth.source_qpn = htonl(QEDR_GSI_QPN);
+
+	if (has_grh_ipv6) {
+		/* GRH / IPv6 header */
+		udh->grh.traffic_class = grh->traffic_class;
+		udh->grh.flow_label = grh->flow_label;
+		udh->grh.hop_limit = grh->hop_limit;
+		udh->grh.destination_gid = grh->dgid;
+		memcpy(&udh->grh.source_gid.raw, &sgid.raw,
+		       sizeof(udh->grh.source_gid.raw));
+	} else {
+		/* IPv4 header */
+		u32 ipv4_addr;
+
+		udh->ip4.protocol = IPPROTO_UDP;
+		udh->ip4.tos = htonl(ah_attr->grh.flow_label);
+		udh->ip4.frag_off = htons(IP_DF);
+		udh->ip4.ttl = ah_attr->grh.hop_limit;
+
+		ipv4_addr = qedr_get_ipv4_from_gid(sgid.raw);
+		udh->ip4.saddr = ipv4_addr;
+		ipv4_addr = qedr_get_ipv4_from_gid(ah_attr->grh.dgid.raw);
+		udh->ip4.daddr = ipv4_addr;
+		/* note: checksum is calculated by the device */
+	}
+
+	/* UDP */
+	if (has_udp) {
+		udh->udp.sport = htons(QEDR_ROCE_V2_UDP_SPORT);
+		udh->udp.dport = htons(ROCE_V2_UDP_DPORT);
+		udh->udp.csum = 0;
+		/* UDP length is untouched hence is zero */
+	}
+	return 0;
+}
+
+static inline int qedr_gsi_build_packet(struct qedr_dev *dev,
+					struct qedr_qp *qp,
+					struct ib_send_wr *swr,
+					struct qed_roce_ll2_packet **p_packet)
+{
+	u8 ud_header_buffer[QEDR_MAX_UD_HEADER_SIZE];
+	struct qed_roce_ll2_packet *packet;
+	struct pci_dev *pdev = dev->pdev;
+	int roce_mode, header_size;
+	struct ib_ud_header udh;
+	int i, rc;
+
+	*p_packet = NULL;
+
+	rc = qedr_gsi_build_header(dev, qp, swr, &udh, &roce_mode);
+	if (rc)
+		return rc;
+
+	header_size = ib_ud_header_pack(&udh, &ud_header_buffer);
+
+	packet = kzalloc(sizeof(*packet), GFP_ATOMIC);
+	if (!packet) {
+		DP_ERR(dev, "gsi post send: failed to allocate packet\n");
+		return -ENOMEM;
+	}
+
+	packet->header.vaddr = dma_alloc_coherent(&pdev->dev, header_size,
+						  &packet->header.baddr,
+						  GFP_ATOMIC);
+	if (!packet->header.vaddr) {
+		DP_ERR(dev,
+		       "cm header build: failed to allocate buffer for header\n");
+		kfree(packet);
+		return -ENOMEM;
+	}
+
+	if (ether_addr_equal(udh.eth.smac_h, udh.eth.dmac_h))
+		packet->tx_dest = QED_ROCE_LL2_TX_DEST_NW;
+	else
+		packet->tx_dest = QED_ROCE_LL2_TX_DEST_LB;
+
+	packet->roce_mode = roce_mode;
+	memcpy(packet->header.vaddr, ud_header_buffer, header_size);
+	packet->header.len = header_size;
+	packet->n_seg = swr->num_sge;
+	for (i = 0; i < packet->n_seg; i++) {
+		packet->payload[i].baddr = swr->sg_list[i].addr;
+		packet->payload[i].len = swr->sg_list[i].length;
+	}
+
+	*p_packet = packet;
+
+	return 0;
+}
+
+int qedr_gsi_post_send(struct ib_qp *ibqp, struct ib_send_wr *wr,
+		       struct ib_send_wr **bad_wr)
+{
+	struct qed_roce_ll2_packet *pkt = NULL;
+	struct qedr_qp *qp = get_qedr_qp(ibqp);
+	struct qed_roce_ll2_tx_params params;
+	struct qedr_dev *dev = qp->dev;
+	unsigned long flags;
+	int rc;
+
+	if (qp->state != QED_ROCE_QP_STATE_RTS) {
+		*bad_wr = wr;
+		DP_ERR(dev,
+		       "gsi post recv: failed to post rx buffer. state is %d and not QED_ROCE_QP_STATE_RTS\n",
+		       qp->state);
+		return -EINVAL;
+	}
+
+	if (wr->num_sge > RDMA_MAX_SGE_PER_SQ_WQE) {
+		DP_ERR(dev, "gsi post send: num_sge is too large (%d>%d)\n",
+		       wr->num_sge, RDMA_MAX_SGE_PER_SQ_WQE);
+		rc = -EINVAL;
+		goto err;
+	}
+
+	if (wr->opcode != IB_WR_SEND) {
+		DP_ERR(dev,
+		       "gsi post send: failed due to unsupported opcode %d\n",
+		       wr->opcode);
+		rc = -EINVAL;
+		goto err;
+	}
+
+	memset(&params, 0, sizeof(params));
+
+	spin_lock_irqsave(&qp->q_lock, flags);
+
+	rc = qedr_gsi_build_packet(dev, qp, wr, &pkt);
+	if (rc) {
+		spin_unlock_irqrestore(&qp->q_lock, flags);
+		goto err;
+	}
+
+	if (unlikely((dev->dp_level <= QED_LEVEL_VERBOSE) &&
+		     (dev->dp_module & QEDR_MSG_GSI)))
+		qedr_print_hex_dump("TX CM Header ", pkt->header.vaddr,
+				    pkt->header.len);
+
+	rc = dev->ops->roce_ll2_tx(dev->cdev, pkt, &params);
+	if (!rc) {
+		qp->wqe_wr_id[qp->sq.prod].wr_id = wr->wr_id;
+		qedr_inc_sw_prod(&qp->sq);
+		DP_VERBOSE(qp->dev, QEDR_MSG_GSI,
+			   "gsi post send: opcode=%d, in_irq=%ld, irqs_disabled=%d, wr_id=%llx\n",
+			   wr->opcode, in_irq(), irqs_disabled(), wr->wr_id);
+	} else {
+		if (rc == QED_ROCE_TX_HEAD_FAILURE) {
+			/* TX failed while posting header - release resources */
+			dma_free_coherent(&dev->pdev->dev, pkt->header.len,
+					  pkt->header.vaddr, pkt->header.baddr);
+			kfree(pkt);
+		} else if (rc == QED_ROCE_TX_FRAG_FAILURE) {
+			/* NTD since TX failed while posting a fragment. We will
+			 * release the resources on TX callback
+			 */
+		}
+
+		DP_ERR(dev, "gsi post send: failed to transmit (rc=%d)\n", rc);
+		rc = -EAGAIN;
+		*bad_wr = wr;
+	}
+
+	spin_unlock_irqrestore(&qp->q_lock, flags);
+
+	if (wr->next) {
+		DP_ERR(dev,
+		       "gsi post send: failed second WR. Only one WR may be passed at a time\n");
+		*bad_wr = wr->next;
+		rc = -EINVAL;
+	}
+
+	return rc;
+
+err:
+	*bad_wr = wr;
+	return rc;
+}
+
+int qedr_gsi_post_recv(struct ib_qp *ibqp, struct ib_recv_wr *wr,
+		       struct ib_recv_wr **bad_wr)
+{
+	struct qedr_dev *dev = get_qedr_dev(ibqp->device);
+	struct qedr_qp *qp = get_qedr_qp(ibqp);
+	struct qed_roce_ll2_buffer buf;
+	unsigned long flags;
+	int status = 0;
+	int rc;
+
+	if ((qp->state != QED_ROCE_QP_STATE_RTR) &&
+	    (qp->state != QED_ROCE_QP_STATE_RTS)) {
+		*bad_wr = wr;
+		DP_ERR(dev,
+		       "gsi post recv: failed to post rx buffer. state is %d and not QED_ROCE_QP_STATE_RTR/S\n",
+		       qp->state);
+		return -EINVAL;
+	}
+
+	memset(&buf, 0, sizeof(buf));
+
+	spin_lock_irqsave(&qp->q_lock, flags);
+
+	while (wr) {
+		if (wr->num_sge > QEDR_GSI_MAX_RECV_SGE) {
+			DP_ERR(dev,
+			       "gsi post recv: failed to post rx buffer. too many sges %d>%d\n",
+			       wr->num_sge, QEDR_GSI_MAX_RECV_SGE);
+			goto err;
+		}
+
+		buf.baddr = wr->sg_list[0].addr;
+		buf.len = wr->sg_list[0].length;
+
+		rc = dev->ops->roce_ll2_post_rx_buffer(dev->cdev, &buf, 0, 1);
+		if (rc) {
+			DP_ERR(dev,
+			       "gsi post recv: failed to post rx buffer (rc=%d)\n",
+			       rc);
+			goto err;
+		}
+
+		memset(&qp->rqe_wr_id[qp->rq.prod], 0,
+		       sizeof(qp->rqe_wr_id[qp->rq.prod]));
+		qp->rqe_wr_id[qp->rq.prod].sg_list[0] = wr->sg_list[0];
+		qp->rqe_wr_id[qp->rq.prod].wr_id = wr->wr_id;
+
+		qedr_inc_sw_prod(&qp->rq);
+
+		wr = wr->next;
+	}
+
+	spin_unlock_irqrestore(&qp->q_lock, flags);
+
+	return status;
+err:
+	spin_unlock_irqrestore(&qp->q_lock, flags);
+	*bad_wr = wr;
+	return -ENOMEM;
+}
+
+int qedr_gsi_poll_cq(struct ib_cq *ibcq, int num_entries, struct ib_wc *wc)
+{
+	struct qedr_dev *dev = get_qedr_dev(ibcq->device);
+	struct qedr_cq *cq = get_qedr_cq(ibcq);
+	struct qedr_qp *qp = dev->gsi_qp;
+	unsigned long flags;
+	int i = 0;
+
+	spin_lock_irqsave(&cq->cq_lock, flags);
+
+	while (i < num_entries && qp->rq.cons != qp->rq.gsi_cons) {
+		memset(&wc[i], 0, sizeof(*wc));
+
+		wc[i].qp = &qp->ibqp;
+		wc[i].wr_id = qp->rqe_wr_id[qp->rq.cons].wr_id;
+		wc[i].opcode = IB_WC_RECV;
+		wc[i].pkey_index = 0;
+		wc[i].status = (qp->rqe_wr_id[qp->rq.cons].rc) ?
+		    IB_WC_GENERAL_ERR : IB_WC_SUCCESS;
+		/* 0 - currently only one recv sg is supported */
+		wc[i].byte_len = qp->rqe_wr_id[qp->rq.cons].sg_list[0].length;
+		wc[i].wc_flags |= IB_WC_GRH | IB_WC_IP_CSUM_OK;
+		ether_addr_copy(wc[i].smac, qp->rqe_wr_id[qp->rq.cons].smac);
+		wc[i].wc_flags |= IB_WC_WITH_SMAC;
+		if (qp->rqe_wr_id[qp->rq.cons].vlan_id) {
+			wc[i].wc_flags |= IB_WC_WITH_VLAN;
+			wc[i].vlan_id = qp->rqe_wr_id[qp->rq.cons].vlan_id;
+		}
+
+		qedr_inc_sw_cons(&qp->rq);
+		i++;
+	}
+
+	while (i < num_entries && qp->sq.cons != qp->sq.gsi_cons) {
+		memset(&wc[i], 0, sizeof(*wc));
+
+		wc[i].qp = &qp->ibqp;
+		wc[i].wr_id = qp->wqe_wr_id[qp->sq.cons].wr_id;
+		wc[i].opcode = IB_WC_SEND;
+		wc[i].status = IB_WC_SUCCESS;
+
+		qedr_inc_sw_cons(&qp->sq);
+		i++;
+	}
+
+	spin_unlock_irqrestore(&cq->cq_lock, flags);
+
+	DP_VERBOSE(dev, (QEDR_MSG_CQ | QEDR_MSG_GSI),
+		   "gsi poll_cq: requested entries=%d, actual=%d, qp->rq.cons=%d, qp->rq.gsi_cons=%x, qp->sq.cons=%d, qp->sq.gsi_cons=%d, qp_num=%d\n",
+		   num_entries, i, qp->rq.cons, qp->rq.gsi_cons, qp->sq.cons,
+		   qp->sq.gsi_cons, qp->ibqp.qp_num);
+
+	return i;
+}
diff --git a/drivers/infiniband/hw/qedr/qedr_cm.h b/drivers/infiniband/hw/qedr/qedr_cm.h
index b8a8b76..9ba6e15 100644
--- a/drivers/infiniband/hw/qedr/qedr_cm.h
+++ b/drivers/infiniband/hw/qedr/qedr_cm.h
@@ -32,9 +32,30 @@
 #ifndef LINUX_QEDR_CM_H_
 #define LINUX_QEDR_CM_H_
 
+#define QEDR_GSI_MAX_RECV_WR	(4096)
+#define QEDR_GSI_MAX_SEND_WR	(4096)
+
+#define QEDR_GSI_MAX_RECV_SGE	(1)	/* LL2 FW limitation */
+
+#define ETH_P_ROCE		(0x8915)
+#define QEDR_ROCE_V2_UDP_SPORT	(0000)
+
 static inline u32 qedr_get_ipv4_from_gid(u8 *gid)
 {
 	return *(u32 *)(void *)&gid[12];
 }
 
+/* RDMA CM */
+int qedr_gsi_poll_cq(struct ib_cq *ibcq, int num_entries, struct ib_wc *wc);
+int qedr_gsi_post_recv(struct ib_qp *ibqp, struct ib_recv_wr *wr,
+		       struct ib_recv_wr **bad_wr);
+int qedr_gsi_post_send(struct ib_qp *ibqp, struct ib_send_wr *wr,
+		       struct ib_send_wr **bad_wr);
+struct ib_qp *qedr_create_gsi_qp(struct qedr_dev *dev,
+				 struct ib_qp_init_attr *attrs,
+				 struct qedr_qp *qp);
+void qedr_store_gsi_qp_cq(struct qedr_dev *dev,
+			  struct qedr_qp *qp, struct ib_qp_init_attr *attrs);
+int qedr_destroy_gsi_qp(struct qedr_dev *dev);
+void qedr_inc_sw_gsi_cons(struct qedr_qp_hwq_info *info);
 #endif
diff --git a/drivers/infiniband/hw/qedr/verbs.c b/drivers/infiniband/hw/qedr/verbs.c
index 30b71e3..5c5fdd1 100644
--- a/drivers/infiniband/hw/qedr/verbs.c
+++ b/drivers/infiniband/hw/qedr/verbs.c
@@ -1472,6 +1472,15 @@ struct ib_qp *qedr_create_qp(struct ib_pd *ibpd,
 
 	qedr_set_qp_init_params(dev, qp, pd, attrs);
 
+	if (attrs->qp_type == IB_QPT_GSI) {
+		if (udata) {
+			DP_ERR(dev,
+			       "create qp: unexpected udata when creating GSI QP\n");
+			goto err0;
+		}
+		return qedr_create_gsi_qp(dev, attrs, qp);
+	}
+
 	memset(&in_params, 0, sizeof(in_params));
 
 	if (udata) {
@@ -2037,6 +2046,8 @@ int qedr_destroy_qp(struct ib_qp *ibqp)
 		rc = dev->ops->rdma_destroy_qp(dev->rdma_ctx, qp->qed_qp);
 		if (rc)
 			return rc;
+	} else {
+		qedr_destroy_gsi_qp(dev);
 	}
 
 	if (ibqp->uobject && ibqp->uobject->context) {
@@ -2052,6 +2063,23 @@ int qedr_destroy_qp(struct ib_qp *ibqp)
 	return rc;
 }
 
+struct ib_ah *qedr_create_ah(struct ib_pd *ibpd, struct ib_ah_attr *attr)
+{
+	struct qedr_ah *ah = kzalloc(sizeof(*ah), GFP_ATOMIC);
+
+	ah->attr = *attr;
+
+	return &ah->ibah;
+}
+
+int qedr_destroy_ah(struct ib_ah *ibah)
+{
+	struct qedr_ah *ah = get_qedr_ah(ibah);
+
+	kfree(ah);
+	return 0;
+}
+
 static void free_mr_info(struct qedr_dev *dev, struct mr_info *info)
 {
 	struct qedr_pbl *pbl, *tmp;
@@ -2903,6 +2931,10 @@ int qedr_post_send(struct ib_qp *ibqp, struct ib_send_wr *wr,
 
 	*bad_wr = NULL;
 
+	if (qp->qp_type == IB_QPT_GSI) {
+		return qedr_gsi_post_send(ibqp, wr, bad_wr);
+	}
+
 	spin_lock_irqsave(&qp->q_lock, flags);
 
 	if ((qp->state == QED_ROCE_QP_STATE_RESET) ||
@@ -2959,6 +2991,10 @@ int qedr_post_recv(struct ib_qp *ibqp, struct ib_recv_wr *wr,
 	unsigned long flags;
 	int status = 0;
 
+	if (qp->qp_type == IB_QPT_GSI) {
+		return qedr_gsi_post_recv(ibqp, wr, bad_wr);
+	}
+
 	spin_lock_irqsave(&qp->q_lock, flags);
 
 	if ((qp->state == QED_ROCE_QP_STATE_RESET) ||
@@ -3394,6 +3430,9 @@ int qedr_poll_cq(struct ib_cq *ibcq, int num_entries, struct ib_wc *wc)
 	int update = 0;
 	int done = 0;
 
+	if (cq->cq_type == QEDR_CQ_TYPE_GSI)
+		return qedr_gsi_poll_cq(ibcq, num_entries, wc);
+
 	spin_lock_irqsave(&cq->cq_lock, flags);
 	old_cons = qed_chain_get_cons_idx_u32(&cq->pbl);
 	while (num_entries && is_valid_cqe(cq, cqe)) {
diff --git a/drivers/net/ethernet/qlogic/qed/qed_ll2.c b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
index 4ea6a07..f907569 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_ll2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
@@ -278,6 +278,7 @@ static void qed_ll2_txq_flush(struct qed_hwfn *p_hwfn, u8 connection_handle)
 	struct qed_ll2_tx_packet *p_pkt = NULL;
 	struct qed_ll2_info *p_ll2_conn;
 	struct qed_ll2_tx_queue *p_tx;
+	dma_addr_t tx_frag;
 
 	p_ll2_conn = qed_ll2_handle_sanity_inactive(p_hwfn, connection_handle);
 	if (!p_ll2_conn)
@@ -294,15 +295,25 @@ static void qed_ll2_txq_flush(struct qed_hwfn *p_hwfn, u8 connection_handle)
 		list_del(&p_pkt->list_entry);
 		b_last_packet = list_empty(&p_tx->active_descq);
 		list_add_tail(&p_pkt->list_entry, &p_tx->free_descq);
+
 		p_tx->cur_completing_packet = *p_pkt;
 		p_tx->cur_completing_bd_idx = 1;
 		b_last_frag = p_tx->cur_completing_bd_idx == p_pkt->bd_used;
-
-		qed_ll2b_complete_tx_packet(p_hwfn, p_ll2_conn->my_id,
-					    p_pkt->cookie,
-					    p_pkt->bds_set[0].tx_frag,
-					    b_last_frag,
-					    b_last_packet);
+		tx_frag = p_pkt->bds_set[0].tx_frag;
+		if (p_ll2_conn->gsi_enable)
+			qed_ll2b_release_tx_gsi_packet(p_hwfn,
+						       p_ll2_conn->my_id,
+						       p_pkt->cookie,
+						       tx_frag,
+						       b_last_frag,
+						       b_last_packet);
+		else
+			qed_ll2b_complete_tx_packet(p_hwfn,
+						    p_ll2_conn->my_id,
+						    p_pkt->cookie,
+						    tx_frag,
+						    b_last_frag,
+						    b_last_packet);
 	}
 }
 
@@ -314,6 +325,7 @@ static int qed_ll2_txq_completion(struct qed_hwfn *p_hwfn, void *p_cookie)
 	struct qed_ll2_tx_packet *p_pkt;
 	bool b_last_frag = false;
 	unsigned long flags;
+	dma_addr_t tx_frag;
 	int rc = -EINVAL;
 
 	spin_lock_irqsave(&p_tx->lock, flags);
@@ -354,11 +366,19 @@ static int qed_ll2_txq_completion(struct qed_hwfn *p_hwfn, void *p_cookie)
 		list_add_tail(&p_pkt->list_entry, &p_tx->free_descq);
 
 		spin_unlock_irqrestore(&p_tx->lock, flags);
-		qed_ll2b_complete_tx_packet(p_hwfn,
-					    p_ll2_conn->my_id,
-					    p_pkt->cookie,
-					    p_pkt->bds_set[0].tx_frag,
-					    b_last_frag, !num_bds);
+		tx_frag = p_pkt->bds_set[0].tx_frag;
+		if (p_ll2_conn->gsi_enable)
+			qed_ll2b_complete_tx_gsi_packet(p_hwfn,
+							p_ll2_conn->my_id,
+							p_pkt->cookie,
+							tx_frag,
+							b_last_frag, !num_bds);
+		else
+			qed_ll2b_complete_tx_packet(p_hwfn,
+						    p_ll2_conn->my_id,
+						    p_pkt->cookie,
+						    tx_frag,
+						    b_last_frag, !num_bds);
 		spin_lock_irqsave(&p_tx->lock, flags);
 	}
 
@@ -369,6 +389,54 @@ out:
 	return rc;
 }
 
+static int
+qed_ll2_rxq_completion_gsi(struct qed_hwfn *p_hwfn,
+			   struct qed_ll2_info *p_ll2_info,
+			   union core_rx_cqe_union *p_cqe,
+			   unsigned long lock_flags, bool b_last_cqe)
+{
+	struct qed_ll2_rx_queue *p_rx = &p_ll2_info->rx_queue;
+	struct qed_ll2_rx_packet *p_pkt = NULL;
+	u16 packet_length, parse_flags, vlan;
+	u32 src_mac_addrhi;
+	u16 src_mac_addrlo;
+
+	if (!list_empty(&p_rx->active_descq))
+		p_pkt = list_first_entry(&p_rx->active_descq,
+					 struct qed_ll2_rx_packet, list_entry);
+	if (!p_pkt) {
+		DP_NOTICE(p_hwfn,
+			  "GSI Rx completion but active_descq is empty\n");
+		return -EIO;
+	}
+
+	list_del(&p_pkt->list_entry);
+	parse_flags = le16_to_cpu(p_cqe->rx_cqe_gsi.parse_flags.flags);
+	packet_length = le16_to_cpu(p_cqe->rx_cqe_gsi.data_length);
+	vlan = le16_to_cpu(p_cqe->rx_cqe_gsi.vlan);
+	src_mac_addrhi = le32_to_cpu(p_cqe->rx_cqe_gsi.src_mac_addrhi);
+	src_mac_addrlo = le16_to_cpu(p_cqe->rx_cqe_gsi.src_mac_addrlo);
+	if (qed_chain_consume(&p_rx->rxq_chain) != p_pkt->rxq_bd)
+		DP_NOTICE(p_hwfn,
+			  "Mismatch between active_descq and the LL2 Rx chain\n");
+	list_add_tail(&p_pkt->list_entry, &p_rx->free_descq);
+
+	spin_unlock_irqrestore(&p_rx->lock, lock_flags);
+	qed_ll2b_complete_rx_gsi_packet(p_hwfn,
+					p_ll2_info->my_id,
+					p_pkt->cookie,
+					p_pkt->rx_buf_addr,
+					packet_length,
+					p_cqe->rx_cqe_gsi.data_length_error,
+					parse_flags,
+					vlan,
+					src_mac_addrhi,
+					src_mac_addrlo, b_last_cqe);
+	spin_lock_irqsave(&p_rx->lock, lock_flags);
+
+	return 0;
+}
+
 static int qed_ll2_rxq_completion_reg(struct qed_hwfn *p_hwfn,
 				      struct qed_ll2_info *p_ll2_conn,
 				      union core_rx_cqe_union *p_cqe,
@@ -430,6 +498,10 @@ static int qed_ll2_rxq_completion(struct qed_hwfn *p_hwfn, void *cookie)
 			DP_NOTICE(p_hwfn, "LL2 - unexpected Rx CQE slowpath\n");
 			rc = -EINVAL;
 			break;
+		case CORE_RX_CQE_TYPE_GSI_OFFLOAD:
+			rc = qed_ll2_rxq_completion_gsi(p_hwfn, p_ll2_conn,
+							cqe, flags, b_last_cqe);
+			break;
 		case CORE_RX_CQE_TYPE_REGULAR:
 			rc = qed_ll2_rxq_completion_reg(p_hwfn, p_ll2_conn,
 							cqe, flags, b_last_cqe);
@@ -527,6 +599,7 @@ static int qed_sp_ll2_rx_queue_start(struct qed_hwfn *p_hwfn,
 	}
 
 	p_ramrod->action_on_error.error_type = action_on_error;
+	p_ramrod->gsi_offload_flag = p_ll2_conn->gsi_enable;
 	return qed_spq_post(p_hwfn, p_ent, NULL);
 }
 
@@ -589,6 +662,7 @@ static int qed_sp_ll2_tx_queue_start(struct qed_hwfn *p_hwfn,
 		DP_NOTICE(p_hwfn, "Unknown connection type: %d\n", conn_type);
 	}
 
+	p_ramrod->gsi_offload_flag = p_ll2_conn->gsi_enable;
 	return qed_spq_post(p_hwfn, p_ent, NULL);
 }
 
@@ -775,6 +849,7 @@ int qed_ll2_acquire_connection(struct qed_hwfn *p_hwfn,
 	p_ll2_info->tx_dest = p_params->tx_dest;
 	p_ll2_info->ai_err_packet_too_big = p_params->ai_err_packet_too_big;
 	p_ll2_info->ai_err_no_buf = p_params->ai_err_no_buf;
+	p_ll2_info->gsi_enable = p_params->gsi_enable;
 
 	rc = qed_ll2_acquire_connection_rx(p_hwfn, p_ll2_info, rx_num_desc);
 	if (rc)
diff --git a/drivers/net/ethernet/qlogic/qed/qed_ll2.h b/drivers/net/ethernet/qlogic/qed/qed_ll2.h
index b3783fd..80a5dc2 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_ll2.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_ll2.h
@@ -125,6 +125,7 @@ struct qed_ll2_info {
 	u8 tx_stats_en;
 	struct qed_ll2_rx_queue rx_queue;
 	struct qed_ll2_tx_queue tx_queue;
+	u8 gsi_enable;
 };
 
 /**
@@ -292,5 +293,24 @@ void qed_ll2_setup(struct qed_hwfn *p_hwfn,
  */
 void qed_ll2_free(struct qed_hwfn *p_hwfn,
 		  struct qed_ll2_info *p_ll2_connections);
-
+void qed_ll2b_complete_rx_gsi_packet(struct qed_hwfn *p_hwfn,
+				     u8 connection_handle,
+				     void *cookie,
+				     dma_addr_t rx_buf_addr,
+				     u16 data_length,
+				     u8 data_length_error,
+				     u16 parse_flags,
+				     u16 vlan,
+				     u32 src_mac_addr_hi,
+				     u16 src_mac_addr_lo, bool b_last_packet);
+void qed_ll2b_complete_tx_gsi_packet(struct qed_hwfn *p_hwfn,
+				     u8 connection_handle,
+				     void *cookie,
+				     dma_addr_t first_frag_addr,
+				     bool b_last_fragment, bool b_last_packet);
+void qed_ll2b_release_tx_gsi_packet(struct qed_hwfn *p_hwfn,
+				    u8 connection_handle,
+				    void *cookie,
+				    dma_addr_t first_frag_addr,
+				    bool b_last_fragment, bool b_last_packet);
 #endif
diff --git a/drivers/net/ethernet/qlogic/qed/qed_roce.c b/drivers/net/ethernet/qlogic/qed/qed_roce.c
index b4f851b..83d841d 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_roce.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_roce.c
@@ -2633,6 +2633,71 @@ void qed_rdma_remove_user(void *rdma_cxt, u16 dpi)
 	spin_unlock_bh(&p_hwfn->p_rdma_info->lock);
 }
 
+void qed_ll2b_complete_tx_gsi_packet(struct qed_hwfn *p_hwfn,
+				     u8 connection_handle,
+				     void *cookie,
+				     dma_addr_t first_frag_addr,
+				     bool b_last_fragment, bool b_last_packet)
+{
+	struct qed_roce_ll2_packet *packet = cookie;
+	struct qed_roce_ll2_info *roce_ll2 = p_hwfn->ll2;
+
+	roce_ll2->cbs.tx_cb(roce_ll2->cb_cookie, packet);
+}
+
+void qed_ll2b_release_tx_gsi_packet(struct qed_hwfn *p_hwfn,
+				    u8 connection_handle,
+				    void *cookie,
+				    dma_addr_t first_frag_addr,
+				    bool b_last_fragment, bool b_last_packet)
+{
+	qed_ll2b_complete_tx_gsi_packet(p_hwfn, connection_handle,
+					cookie, first_frag_addr,
+					b_last_fragment, b_last_packet);
+}
+
+void qed_ll2b_complete_rx_gsi_packet(struct qed_hwfn *p_hwfn,
+				     u8 connection_handle,
+				     void *cookie,
+				     dma_addr_t rx_buf_addr,
+				     u16 data_length,
+				     u8 data_length_error,
+				     u16 parse_flags,
+				     u16 vlan,
+				     u32 src_mac_addr_hi,
+				     u16 src_mac_addr_lo, bool b_last_packet)
+{
+	struct qed_roce_ll2_info *roce_ll2 = p_hwfn->ll2;
+	struct qed_roce_ll2_rx_params params;
+	struct qed_dev *cdev = p_hwfn->cdev;
+	struct qed_roce_ll2_packet pkt;
+
+	DP_VERBOSE(cdev,
+		   QED_MSG_LL2,
+		   "roce ll2 rx complete: bus_addr=%p, len=%d, data_len_err=%d\n",
+		   (void *)(uintptr_t)rx_buf_addr,
+		   data_length, data_length_error);
+
+	memset(&pkt, 0, sizeof(pkt));
+	pkt.n_seg = 1;
+	pkt.payload[0].baddr = rx_buf_addr;
+	pkt.payload[0].len = data_length;
+
+	memset(&params, 0, sizeof(params));
+	params.vlan_id = vlan;
+	*((u32 *)&params.smac[0]) = ntohl(src_mac_addr_hi);
+	*((u16 *)&params.smac[4]) = ntohs(src_mac_addr_lo);
+
+	if (data_length_error) {
+		DP_ERR(cdev,
+		       "roce ll2 rx complete: data length error %d, length=%d\n",
+		       data_length_error, data_length);
+		params.rc = -EINVAL;
+	}
+
+	roce_ll2->cbs.rx_cb(roce_ll2->cb_cookie, &pkt, &params);
+}
+
 static int qed_roce_ll2_set_mac_filter(struct qed_dev *cdev,
 				       u8 *old_mac_address,
 				       u8 *new_mac_address)
@@ -2717,6 +2782,7 @@ static int qed_roce_ll2_start(struct qed_dev *cdev,
 	ll2_params.tx_dest = CORE_TX_DEST_NW;
 	ll2_params.ai_err_packet_too_big = LL2_DROP_PACKET;
 	ll2_params.ai_err_no_buf = LL2_DROP_PACKET;
+	ll2_params.gsi_enable = true;
 
 	rc = qed_ll2_acquire_connection(QED_LEADING_HWFN(cdev), &ll2_params,
 					params->max_rx_buffers,
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
