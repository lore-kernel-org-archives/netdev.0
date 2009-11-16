From: Eli Cohen <eli-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: [PATCHv6 09/10] mlx4: Add support for RDMAoE - address resolution
Date: Mon, 16 Nov 2009 17:54:09 +0200
Message-ID: <20091116155408.GJ2463@mtls03>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux RDMA list <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, ewg <ewg-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org>
To: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The following patch handles address vectors creation for RDMAoE ports. mlx4
needs the MAC address of the remote node to include it in the WQE of a UD QP or
in the QP context of connected QPs. Address resolution is done atomically in
the case of a link local address or a multicast GID and otherwise -EINVAL is
returned.  mlx4 transport packets were changed too to accomodate for RDMAoE.

Signed-off-by: Eli Cohen <eli-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
---
 drivers/infiniband/hw/mlx4/ah.c      |  181 +++++++++++++++++++++++++++------
 drivers/infiniband/hw/mlx4/mad.c     |   32 ++++---
 drivers/infiniband/hw/mlx4/mlx4_ib.h |   18 +++-
 drivers/infiniband/hw/mlx4/qp.c      |  172 ++++++++++++++++++++++----------
 drivers/net/mlx4/fw.c                |    3 +-
 include/linux/mlx4/device.h          |   31 ++++++-
 include/linux/mlx4/qp.h              |    8 +-
 7 files changed, 340 insertions(+), 105 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/ah.c b/drivers/infiniband/hw/mlx4/ah.c
index c75ac94..3451929 100644
--- a/drivers/infiniband/hw/mlx4/ah.c
+++ b/drivers/infiniband/hw/mlx4/ah.c
@@ -31,63 +31,160 @@
  */
 
 #include "mlx4_ib.h"
+#include <rdma/ib_addr.h>
+#include <linux/inet.h>
+#include <linux/string.h>
 
-struct ib_ah *mlx4_ib_create_ah(struct ib_pd *pd, struct ib_ah_attr *ah_attr)
+int mlx4_ib_resolve_grh(struct mlx4_ib_dev *dev, const struct ib_ah_attr *ah_attr,
+			u8 *mac, int *is_mcast, u8 port)
 {
-	struct mlx4_dev *dev = to_mdev(pd->device)->dev;
-	struct mlx4_ib_ah *ah;
+	struct mlx4_ib_rdmaoe *rdmaoe = &dev->rdmaoe;
+	struct in6_addr in6;
 
-	ah = kmalloc(sizeof *ah, GFP_ATOMIC);
-	if (!ah)
-		return ERR_PTR(-ENOMEM);
+	*is_mcast = 0;
+	spin_lock(&rdmaoe->lock);
+	if (!rdmaoe->netdevs[port - 1]) {
+		spin_unlock(&rdmaoe->lock);
+		return -EINVAL;
+	}
+	spin_unlock(&rdmaoe->lock);
 
-	memset(&ah->av, 0, sizeof ah->av);
+	memcpy(&in6, ah_attr->grh.dgid.raw, sizeof in6);
+	if (rdma_link_local_addr(&in6))
+		rdma_get_ll_mac(&in6, mac);
+	else if (rdma_is_multicast_addr(&in6)) {
+		rdma_get_mcast_mac(&in6, mac);
+		*is_mcast = 1;
+	} else
+		return -EINVAL;
 
-	ah->av.port_pd = cpu_to_be32(to_mpd(pd)->pdn | (ah_attr->port_num << 24));
-	ah->av.g_slid  = ah_attr->src_path_bits;
-	ah->av.dlid    = cpu_to_be16(ah_attr->dlid);
-	if (ah_attr->static_rate) {
-		ah->av.stat_rate = ah_attr->static_rate + MLX4_STAT_RATE_OFFSET;
-		while (ah->av.stat_rate > IB_RATE_2_5_GBPS + MLX4_STAT_RATE_OFFSET &&
-		       !(1 << ah->av.stat_rate & dev->caps.stat_rate_support))
-			--ah->av.stat_rate;
-	}
-	ah->av.sl_tclass_flowlabel = cpu_to_be32(ah_attr->sl << 28);
+	return 0;
+}
+
+static struct ib_ah *create_ib_ah(struct ib_pd *pd, struct ib_ah_attr *ah_attr,
+				  struct mlx4_ib_ah *ah)
+{
+	struct mlx4_dev *dev = to_mdev(pd->device)->dev;
+
+	ah->av.ib.port_pd = cpu_to_be32(to_mpd(pd)->pdn | (ah_attr->port_num << 24));
+	ah->av.ib.g_slid  = ah_attr->src_path_bits;
 	if (ah_attr->ah_flags & IB_AH_GRH) {
-		ah->av.g_slid   |= 0x80;
-		ah->av.gid_index = ah_attr->grh.sgid_index;
-		ah->av.hop_limit = ah_attr->grh.hop_limit;
-		ah->av.sl_tclass_flowlabel |=
+		ah->av.ib.g_slid   |= 0x80;
+		ah->av.ib.gid_index = ah_attr->grh.sgid_index;
+		ah->av.ib.hop_limit = ah_attr->grh.hop_limit;
+		ah->av.ib.sl_tclass_flowlabel |=
 			cpu_to_be32((ah_attr->grh.traffic_class << 20) |
 				    ah_attr->grh.flow_label);
-		memcpy(ah->av.dgid, ah_attr->grh.dgid.raw, 16);
+		memcpy(ah->av.ib.dgid, ah_attr->grh.dgid.raw, 16);
+	}
+
+	ah->av.ib.dlid    = cpu_to_be16(ah_attr->dlid);
+	if (ah_attr->static_rate) {
+		ah->av.ib.stat_rate = ah_attr->static_rate + MLX4_STAT_RATE_OFFSET;
+		while (ah->av.ib.stat_rate > IB_RATE_2_5_GBPS + MLX4_STAT_RATE_OFFSET &&
+		       !(1 << ah->av.ib.stat_rate & dev->caps.stat_rate_support))
+			--ah->av.ib.stat_rate;
 	}
+	ah->av.ib.sl_tclass_flowlabel = cpu_to_be32(ah_attr->sl << 28);
 
 	return &ah->ibah;
 }
 
+static struct ib_ah *create_rdmaoe_ah(struct ib_pd *pd, struct ib_ah_attr *ah_attr,
+				   struct mlx4_ib_ah *ah)
+{
+	struct mlx4_ib_dev *ibdev = to_mdev(pd->device);
+	struct mlx4_dev *dev = ibdev->dev;
+	u8 mac[6];
+	int err;
+	int is_mcast;
+
+	err = mlx4_ib_resolve_grh(ibdev, ah_attr, mac, &is_mcast, ah_attr->port_num);
+	if (err)
+		return ERR_PTR(err);
+
+	memcpy(ah->av.eth.mac_0_1, mac, 2);
+	memcpy(ah->av.eth.mac_2_5, mac + 2, 4);
+	ah->av.ib.port_pd = cpu_to_be32(to_mpd(pd)->pdn | (ah_attr->port_num << 24));
+	ah->av.ib.g_slid = 0x80;
+	if (ah_attr->static_rate) {
+		ah->av.ib.stat_rate = ah_attr->static_rate + MLX4_STAT_RATE_OFFSET;
+		while (ah->av.ib.stat_rate > IB_RATE_2_5_GBPS + MLX4_STAT_RATE_OFFSET &&
+		       !(1 << ah->av.ib.stat_rate & dev->caps.stat_rate_support))
+			--ah->av.ib.stat_rate;
+	}
+
+	/*
+	 * HW requires multicast LID so we just choose one.
+	 */
+	if (is_mcast)
+		ah->av.ib.dlid = cpu_to_be16(0xc000);
+
+	memcpy(ah->av.ib.dgid, ah_attr->grh.dgid.raw, 16);
+	ah->av.ib.sl_tclass_flowlabel = cpu_to_be32(ah_attr->sl << 28);
+
+	return &ah->ibah;
+}
+
+struct ib_ah *mlx4_ib_create_ah(struct ib_pd *pd, struct ib_ah_attr *ah_attr)
+{
+	struct mlx4_ib_ah *ah;
+	enum rdma_transport_type transport;
+	struct ib_ah *ret;
+
+	ah = kzalloc(sizeof *ah, GFP_ATOMIC);
+	if (!ah)
+		return ERR_PTR(-ENOMEM);
+
+	transport = rdma_port_get_transport(pd->device, ah_attr->port_num);
+	if (transport == RDMA_TRANSPORT_RDMAOE) {
+		if (!(ah_attr->ah_flags & IB_AH_GRH)) {
+			ret = ERR_PTR(-EINVAL);
+			goto out;
+		} else {
+			/* TBD: need to handle the case when we get called
+			in an atomic context and there we might sleep. We
+			don't expect this currently since we're working with
+			link local addresses which we can translate without
+			going to sleep */
+			ret = create_rdmaoe_ah(pd, ah_attr, ah);
+			if (IS_ERR(ret))
+				goto out;
+			else
+				return ret;
+		}
+	} else
+		return create_ib_ah(pd, ah_attr, ah); /* never fails */
+
+out:
+	kfree(ah);
+	return ret;
+}
+
 int mlx4_ib_query_ah(struct ib_ah *ibah, struct ib_ah_attr *ah_attr)
 {
 	struct mlx4_ib_ah *ah = to_mah(ibah);
+	enum rdma_transport_type transport;
 
+	transport = rdma_port_get_transport(ibah->device, ah_attr->port_num);
 	memset(ah_attr, 0, sizeof *ah_attr);
-	ah_attr->dlid	       = be16_to_cpu(ah->av.dlid);
-	ah_attr->sl	       = be32_to_cpu(ah->av.sl_tclass_flowlabel) >> 28;
-	ah_attr->port_num      = be32_to_cpu(ah->av.port_pd) >> 24;
-	if (ah->av.stat_rate)
-		ah_attr->static_rate = ah->av.stat_rate - MLX4_STAT_RATE_OFFSET;
-	ah_attr->src_path_bits = ah->av.g_slid & 0x7F;
+	ah_attr->dlid = transport == RDMA_TRANSPORT_IB ? be16_to_cpu(ah->av.ib.dlid) : 0;
+	ah_attr->sl = be32_to_cpu(ah->av.ib.sl_tclass_flowlabel) >> 28;
+	ah_attr->port_num = be32_to_cpu(ah->av.ib.port_pd) >> 24;
+	if (ah->av.ib.stat_rate)
+		ah_attr->static_rate = ah->av.ib.stat_rate - MLX4_STAT_RATE_OFFSET;
+	ah_attr->src_path_bits = ah->av.ib.g_slid & 0x7F;
 
 	if (mlx4_ib_ah_grh_present(ah)) {
 		ah_attr->ah_flags = IB_AH_GRH;
 
 		ah_attr->grh.traffic_class =
-			be32_to_cpu(ah->av.sl_tclass_flowlabel) >> 20;
+			be32_to_cpu(ah->av.ib.sl_tclass_flowlabel) >> 20;
 		ah_attr->grh.flow_label =
-			be32_to_cpu(ah->av.sl_tclass_flowlabel) & 0xfffff;
-		ah_attr->grh.hop_limit  = ah->av.hop_limit;
-		ah_attr->grh.sgid_index = ah->av.gid_index;
-		memcpy(ah_attr->grh.dgid.raw, ah->av.dgid, 16);
+			be32_to_cpu(ah->av.ib.sl_tclass_flowlabel) & 0xfffff;
+		ah_attr->grh.hop_limit  = ah->av.ib.hop_limit;
+		ah_attr->grh.sgid_index = ah->av.ib.gid_index;
+		memcpy(ah_attr->grh.dgid.raw, ah->av.ib.dgid, 16);
 	}
 
 	return 0;
@@ -98,3 +195,21 @@ int mlx4_ib_destroy_ah(struct ib_ah *ah)
 	kfree(to_mah(ah));
 	return 0;
 }
+
+int mlx4_ib_get_mac(struct ib_device *device, u8 port, u8 *gid, u8 *mac)
+{
+	int err;
+	struct mlx4_ib_dev *ibdev = to_mdev(device);
+	struct ib_ah_attr ah_attr = {
+		.port_num = port,
+	};
+	int is_mcast;
+
+	memcpy(ah_attr.grh.dgid.raw, gid, 16);
+	err = mlx4_ib_resolve_grh(ibdev, &ah_attr, mac, &is_mcast, port);
+	if (err)
+		ERR_PTR(err);
+
+	return 0;
+}
+
diff --git a/drivers/infiniband/hw/mlx4/mad.c b/drivers/infiniband/hw/mlx4/mad.c
index 19e68ab..3df4f64 100644
--- a/drivers/infiniband/hw/mlx4/mad.c
+++ b/drivers/infiniband/hw/mlx4/mad.c
@@ -310,19 +310,25 @@ int mlx4_ib_mad_init(struct mlx4_ib_dev *dev)
 	struct ib_mad_agent *agent;
 	int p, q;
 	int ret;
+	enum rdma_transport_type tt;
 
-	for (p = 0; p < dev->num_ports; ++p)
+	for (p = 0; p < dev->num_ports; ++p) {
+		tt = rdma_port_get_transport(&dev->ib_dev, p + 1);
 		for (q = 0; q <= 1; ++q) {
-			agent = ib_register_mad_agent(&dev->ib_dev, p + 1,
-						      q ? IB_QPT_GSI : IB_QPT_SMI,
-						      NULL, 0, send_handler,
-						      NULL, NULL);
-			if (IS_ERR(agent)) {
-				ret = PTR_ERR(agent);
-				goto err;
-			}
-			dev->send_agent[p][q] = agent;
+			if (tt == RDMA_TRANSPORT_IB) {
+				agent = ib_register_mad_agent(&dev->ib_dev, p + 1,
+							      q ? IB_QPT_GSI : IB_QPT_SMI,
+							      NULL, 0, send_handler,
+							      NULL, NULL);
+				if (IS_ERR(agent)) {
+					ret = PTR_ERR(agent);
+					goto err;
+				}
+				dev->send_agent[p][q] = agent;
+			} else
+				dev->send_agent[p][q] = NULL;
 		}
+	}
 
 	return 0;
 
@@ -343,8 +349,10 @@ void mlx4_ib_mad_cleanup(struct mlx4_ib_dev *dev)
 	for (p = 0; p < dev->num_ports; ++p) {
 		for (q = 0; q <= 1; ++q) {
 			agent = dev->send_agent[p][q];
-			dev->send_agent[p][q] = NULL;
-			ib_unregister_mad_agent(agent);
+			if (agent) {
+				dev->send_agent[p][q] = NULL;
+				ib_unregister_mad_agent(agent);
+			}
 		}
 
 		if (dev->sm_ah[p])
diff --git a/drivers/infiniband/hw/mlx4/mlx4_ib.h b/drivers/infiniband/hw/mlx4/mlx4_ib.h
index 3486d76..a0435cd 100644
--- a/drivers/infiniband/hw/mlx4/mlx4_ib.h
+++ b/drivers/infiniband/hw/mlx4/mlx4_ib.h
@@ -138,6 +138,7 @@ struct mlx4_ib_qp {
 	u8			resp_depth;
 	u8			sq_no_prefetch;
 	u8			state;
+	int			mlx_type;
 };
 
 struct mlx4_ib_srq {
@@ -157,7 +158,14 @@ struct mlx4_ib_srq {
 
 struct mlx4_ib_ah {
 	struct ib_ah		ibah;
-	struct mlx4_av		av;
+	union mlx4_ext_av       av;
+};
+
+struct mlx4_ib_rdmaoe {
+	spinlock_t		lock;
+	struct net_device      *netdevs[MLX4_MAX_PORTS];
+	struct notifier_block 	nb;
+	union ib_gid		gid_table[MLX4_MAX_PORTS][128];
 };
 
 struct mlx4_ib_dev {
@@ -176,6 +184,7 @@ struct mlx4_ib_dev {
 
 	struct mutex		cap_mask_mutex;
 	bool			ib_active;
+	struct mlx4_ib_rdmaoe	rdmaoe;
 };
 
 static inline struct mlx4_ib_dev *to_mdev(struct ib_device *ibdev)
@@ -314,9 +323,14 @@ int mlx4_ib_map_phys_fmr(struct ib_fmr *ibfmr, u64 *page_list, int npages,
 int mlx4_ib_unmap_fmr(struct list_head *fmr_list);
 int mlx4_ib_fmr_dealloc(struct ib_fmr *fmr);
 
+int mlx4_ib_resolve_grh(struct mlx4_ib_dev *dev, const struct ib_ah_attr *ah_attr,
+			u8 *mac, int *is_mcast, u8 port);
+
+int mlx4_ib_get_mac(struct ib_device *device, u8 port, u8 *gid, u8 *mac);
+
 static inline int mlx4_ib_ah_grh_present(struct mlx4_ib_ah *ah)
 {
-	return !!(ah->av.g_slid & 0x80);
+	return !!(ah->av.ib.g_slid & 0x80);
 }
 
 #endif /* MLX4_IB_H */
diff --git a/drivers/infiniband/hw/mlx4/qp.c b/drivers/infiniband/hw/mlx4/qp.c
index 847030c..ce2a47e 100644
--- a/drivers/infiniband/hw/mlx4/qp.c
+++ b/drivers/infiniband/hw/mlx4/qp.c
@@ -32,6 +32,7 @@
  */
 
 #include <linux/log2.h>
+#include <linux/netdevice.h>
 
 #include <rdma/ib_cache.h>
 #include <rdma/ib_pack.h>
@@ -47,23 +48,33 @@ enum {
 
 enum {
 	MLX4_IB_DEFAULT_SCHED_QUEUE	= 0x83,
-	MLX4_IB_DEFAULT_QP0_SCHED_QUEUE	= 0x3f
+	MLX4_IB_DEFAULT_QP0_SCHED_QUEUE	= 0x3f,
+	MLX4_IB_LINK_TYPE_IB		= 0,
+	MLX4_IB_LINK_TYPE_ETH		= 1
 };
 
 enum {
 	/*
 	 * Largest possible UD header: send with GRH and immediate data.
+	 * 4 bytes added to accommodate for eth header instead of lrh
 	 */
-	MLX4_IB_UD_HEADER_SIZE		= 72,
+	MLX4_IB_UD_HEADER_SIZE		= 76,
 	MLX4_IB_LSO_HEADER_SPARE	= 128,
 };
 
+enum {
+	MLX4_RDMAOE_ETHERTYPE = 0x8915
+};
+
 struct mlx4_ib_sqp {
 	struct mlx4_ib_qp	qp;
 	int			pkey_index;
 	u32			qkey;
 	u32			send_psn;
-	struct ib_ud_header	ud_header;
+	union {
+		struct ib_ud_header	ib;
+		struct eth_ud_header	eth;
+	} hdr;
 	u8			header_buf[MLX4_IB_UD_HEADER_SIZE];
 };
 
@@ -548,9 +559,9 @@ static int create_qp_common(struct mlx4_ib_dev *dev, struct ib_pd *pd,
 		}
 	}
 
-	if (sqpn) {
+	if (sqpn)
 		qpn = sqpn;
-	} else {
+	else {
 		err = mlx4_qp_reserve_range(dev->dev, 1, 1, &qpn);
 		if (err)
 			goto err_wrid;
@@ -849,6 +860,12 @@ static void mlx4_set_sched(struct mlx4_qp_path *path, u8 port)
 static int mlx4_set_path(struct mlx4_ib_dev *dev, const struct ib_ah_attr *ah,
 			 struct mlx4_qp_path *path, u8 port)
 {
+	int err;
+	int is_eth = rdma_port_get_transport(&dev->ib_dev, port) ==
+		RDMA_TRANSPORT_RDMAOE ? 1 : 0;
+	u8 mac[6];
+	int is_mcast;
+
 	path->grh_mylmc     = ah->src_path_bits & 0x7f;
 	path->rlid	    = cpu_to_be16(ah->dlid);
 	if (ah->static_rate) {
@@ -879,6 +896,21 @@ static int mlx4_set_path(struct mlx4_ib_dev *dev, const struct ib_ah_attr *ah,
 	path->sched_queue = MLX4_IB_DEFAULT_SCHED_QUEUE |
 		((port - 1) << 6) | ((ah->sl & 0xf) << 2);
 
+	if (is_eth) {
+		if (!(ah->ah_flags & IB_AH_GRH))
+			return -1;
+
+		err = mlx4_ib_resolve_grh(dev, ah, mac, &is_mcast, port);
+		if (err)
+			return err;
+
+		memcpy(path->dmac_h, mac, 2);
+		memcpy(path->dmac_l, mac + 2, 4);
+		path->ackto = MLX4_IB_LINK_TYPE_ETH;
+		/* use index 0 into MAC table for RDMAoE */
+		path->grh_mylmc &= 0x80;
+	}
+
 	return 0;
 }
 
@@ -977,7 +1009,7 @@ static int __mlx4_ib_modify_qp(struct ib_qp *ibqp,
 	}
 
 	if (attr_mask & IB_QP_TIMEOUT) {
-		context->pri_path.ackto = attr->timeout << 3;
+		context->pri_path.ackto |= (attr->timeout << 3);
 		optpar |= MLX4_QP_OPTPAR_ACK_TIMEOUT;
 	}
 
@@ -1223,79 +1255,109 @@ static int build_mlx_header(struct mlx4_ib_sqp *sqp, struct ib_send_wr *wr,
 	int header_size;
 	int spc;
 	int i;
+	void *tmp;
+	struct ib_ud_header *ib = NULL;
+	struct eth_ud_header *eth = NULL;
+	struct ib_unpacked_grh *grh;
+	struct ib_unpacked_bth  *bth;
+	struct ib_unpacked_deth *deth;
 
 	send_size = 0;
 	for (i = 0; i < wr->num_sge; ++i)
 		send_size += wr->sg_list[i].length;
 
-	ib_ud_header_init(send_size, mlx4_ib_ah_grh_present(ah), &sqp->ud_header);
+	if (rdma_port_get_transport(sqp->qp.ibqp.device, sqp->qp.port) == RDMA_TRANSPORT_IB) {
+		ib = &sqp->hdr.ib;
+		grh = &ib->grh;
+		bth = &ib->bth;
+		deth = &ib->deth;
+		ib_ud_header_init(send_size, mlx4_ib_ah_grh_present(ah), ib);
+		ib->lrh.service_level   =
+			be32_to_cpu(ah->av.ib.sl_tclass_flowlabel) >> 28;
+		ib->lrh.destination_lid = ah->av.ib.dlid;
+		ib->lrh.source_lid      = cpu_to_be16(ah->av.ib.g_slid & 0x7f);
+	} else {
+		eth = &sqp->hdr.eth;
+		grh = &eth->grh;
+		bth = &eth->bth;
+		deth = &eth->deth;
+		ib_rdmaoe_ud_header_init(send_size, mlx4_ib_ah_grh_present(ah), eth);
+	}
 
-	sqp->ud_header.lrh.service_level   =
-		be32_to_cpu(ah->av.sl_tclass_flowlabel) >> 28;
-	sqp->ud_header.lrh.destination_lid = ah->av.dlid;
-	sqp->ud_header.lrh.source_lid      = cpu_to_be16(ah->av.g_slid & 0x7f);
 	if (mlx4_ib_ah_grh_present(ah)) {
-		sqp->ud_header.grh.traffic_class =
-			(be32_to_cpu(ah->av.sl_tclass_flowlabel) >> 20) & 0xff;
-		sqp->ud_header.grh.flow_label    =
-			ah->av.sl_tclass_flowlabel & cpu_to_be32(0xfffff);
-		sqp->ud_header.grh.hop_limit     = ah->av.hop_limit;
-		ib_get_cached_gid(ib_dev, be32_to_cpu(ah->av.port_pd) >> 24,
-				  ah->av.gid_index, &sqp->ud_header.grh.source_gid);
-		memcpy(sqp->ud_header.grh.destination_gid.raw,
-		       ah->av.dgid, 16);
+		grh->traffic_class =
+			(be32_to_cpu(ah->av.ib.sl_tclass_flowlabel) >> 20) & 0xff;
+		grh->flow_label    =
+			ah->av.ib.sl_tclass_flowlabel & cpu_to_be32(0xfffff);
+		grh->hop_limit     = ah->av.ib.hop_limit;
+		ib_get_cached_gid(ib_dev, be32_to_cpu(ah->av.ib.port_pd) >> 24,
+				  ah->av.ib.gid_index, &grh->source_gid);
+		memcpy(grh->destination_gid.raw,
+		       ah->av.ib.dgid, 16);
 	}
 
 	mlx->flags &= cpu_to_be32(MLX4_WQE_CTRL_CQ_UPDATE);
-	mlx->flags |= cpu_to_be32((!sqp->qp.ibqp.qp_num ? MLX4_WQE_MLX_VL15 : 0) |
-				  (sqp->ud_header.lrh.destination_lid ==
-				   IB_LID_PERMISSIVE ? MLX4_WQE_MLX_SLR : 0) |
-				  (sqp->ud_header.lrh.service_level << 8));
-	mlx->rlid   = sqp->ud_header.lrh.destination_lid;
+
+	if (ib) {
+		mlx->flags |= cpu_to_be32((!sqp->qp.ibqp.qp_num ? MLX4_WQE_MLX_VL15 : 0) |
+					  (ib->lrh.destination_lid ==
+					   IB_LID_PERMISSIVE ? MLX4_WQE_MLX_SLR : 0) |
+					  (ib->lrh.service_level << 8));
+		mlx->rlid   = ib->lrh.destination_lid;
+	}
 
 	switch (wr->opcode) {
 	case IB_WR_SEND:
-		sqp->ud_header.bth.opcode	 = IB_OPCODE_UD_SEND_ONLY;
-		sqp->ud_header.immediate_present = 0;
+		bth->opcode	 = IB_OPCODE_UD_SEND_ONLY;
+		if (ib)
+			ib->immediate_present = 0;
+		else
+			eth->immediate_present = 0;
 		break;
 	case IB_WR_SEND_WITH_IMM:
-		sqp->ud_header.bth.opcode	 = IB_OPCODE_UD_SEND_ONLY_WITH_IMMEDIATE;
-		sqp->ud_header.immediate_present = 1;
-		sqp->ud_header.immediate_data    = wr->ex.imm_data;
+		bth->opcode	 = IB_OPCODE_UD_SEND_ONLY_WITH_IMMEDIATE;
+		if (ib) {
+			ib->immediate_present = 1;
+			ib->immediate_data    = wr->ex.imm_data;
+		} else {
+			eth->immediate_present = 1;
+			eth->immediate_data    = wr->ex.imm_data;
+		}
 		break;
 	default:
 		return -EINVAL;
 	}
 
-	sqp->ud_header.lrh.virtual_lane    = !sqp->qp.ibqp.qp_num ? 15 : 0;
-	if (sqp->ud_header.lrh.destination_lid == IB_LID_PERMISSIVE)
-		sqp->ud_header.lrh.source_lid = IB_LID_PERMISSIVE;
-	sqp->ud_header.bth.solicited_event = !!(wr->send_flags & IB_SEND_SOLICITED);
+	if (ib) {
+		ib->lrh.virtual_lane    = !sqp->qp.ibqp.qp_num ? 15 : 0;
+		if (ib->lrh.destination_lid == IB_LID_PERMISSIVE)
+			ib->lrh.source_lid = IB_LID_PERMISSIVE;
+	} else {
+		memcpy(eth->eth.dmac_h, ah->av.eth.mac_0_1, 2);
+		memcpy(eth->eth.dmac_h + 2, ah->av.eth.mac_2_5, 2);
+		memcpy(eth->eth.dmac_l, ah->av.eth.mac_2_5 + 2, 2);
+		tmp = to_mdev(sqp->qp.ibqp.device)->rdmaoe.netdevs[sqp->qp.port - 1]->dev_addr;
+		memcpy(eth->eth.smac_h, tmp, 2);
+		memcpy(eth->eth.smac_l, tmp + 2, 4);
+		eth->eth.type = cpu_to_be16(MLX4_RDMAOE_ETHERTYPE);
+	}
+	bth->solicited_event = !!(wr->send_flags & IB_SEND_SOLICITED);
+
 	if (!sqp->qp.ibqp.qp_num)
 		ib_get_cached_pkey(ib_dev, sqp->qp.port, sqp->pkey_index, &pkey);
 	else
 		ib_get_cached_pkey(ib_dev, sqp->qp.port, wr->wr.ud.pkey_index, &pkey);
-	sqp->ud_header.bth.pkey = cpu_to_be16(pkey);
-	sqp->ud_header.bth.destination_qpn = cpu_to_be32(wr->wr.ud.remote_qpn);
-	sqp->ud_header.bth.psn = cpu_to_be32((sqp->send_psn++) & ((1 << 24) - 1));
-	sqp->ud_header.deth.qkey = cpu_to_be32(wr->wr.ud.remote_qkey & 0x80000000 ?
+	bth->pkey = cpu_to_be16(pkey);
+	bth->destination_qpn = cpu_to_be32(wr->wr.ud.remote_qpn);
+	bth->psn = cpu_to_be32((sqp->send_psn++) & ((1 << 24) - 1));
+	deth->qkey = cpu_to_be32(wr->wr.ud.remote_qkey & 0x80000000 ?
 					       sqp->qkey : wr->wr.ud.remote_qkey);
-	sqp->ud_header.deth.source_qpn = cpu_to_be32(sqp->qp.ibqp.qp_num);
-
-	header_size = ib_ud_header_pack(&sqp->ud_header, sqp->header_buf);
-
-	if (0) {
-		printk(KERN_ERR "built UD header of size %d:\n", header_size);
-		for (i = 0; i < header_size / 4; ++i) {
-			if (i % 8 == 0)
-				printk("  [%02x] ", i * 4);
-			printk(" %08x",
-			       be32_to_cpu(((__be32 *) sqp->header_buf)[i]));
-			if ((i + 1) % 8 == 0)
-				printk("\n");
-		}
-		printk("\n");
-	}
+	deth->source_qpn = cpu_to_be32(sqp->qp.ibqp.qp_num);
+
+	if (ib)
+		header_size = ib_ud_header_pack(ib, sqp->header_buf);
+	else
+		header_size = rdmaoe_ud_header_pack(eth, sqp->header_buf);
 
 	/*
 	 * Inline data segments may not cross a 64 byte boundary.  If
@@ -1419,6 +1481,8 @@ static void set_datagram_seg(struct mlx4_wqe_datagram_seg *dseg,
 	memcpy(dseg->av, &to_mah(wr->wr.ud.ah)->av, sizeof (struct mlx4_av));
 	dseg->dqpn = cpu_to_be32(wr->wr.ud.remote_qpn);
 	dseg->qkey = cpu_to_be32(wr->wr.ud.remote_qkey);
+	dseg->vlan = to_mah(wr->wr.ud.ah)->av.eth.vlan;
+	memcpy(dseg->mac_0_1, to_mah(wr->wr.ud.ah)->av.eth.mac_0_1, 6);
 }
 
 static void set_mlx_icrc_seg(void *dseg)
diff --git a/drivers/net/mlx4/fw.c b/drivers/net/mlx4/fw.c
index 7194be3..1a8d375 100644
--- a/drivers/net/mlx4/fw.c
+++ b/drivers/net/mlx4/fw.c
@@ -98,7 +98,8 @@ static void dump_dev_cap_flags(struct mlx4_dev *dev, u32 flags)
 		[20] = "Address vector port checking support",
 		[21] = "UD multicast support",
 		[24] = "Demand paging support",
-		[25] = "Router support"
+		[25] = "Router support",
+		[30] = "RDMAoE support"
 	};
 	int i;
 
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index e92d1bf..5412e94 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -67,7 +67,8 @@ enum {
 	MLX4_DEV_CAP_FLAG_ATOMIC	= 1 << 18,
 	MLX4_DEV_CAP_FLAG_RAW_MCAST	= 1 << 19,
 	MLX4_DEV_CAP_FLAG_UD_AV_PORT	= 1 << 20,
-	MLX4_DEV_CAP_FLAG_UD_MCAST	= 1 << 21
+	MLX4_DEV_CAP_FLAG_UD_MCAST	= 1 << 21,
+	MLX4_DEV_CAP_FLAG_RDMAOE	= 1 << 30
 };
 
 enum {
@@ -373,6 +374,28 @@ struct mlx4_av {
 	u8			dgid[16];
 };
 
+struct mlx4_eth_av {
+	__be32		port_pd;
+	u8		reserved1;
+	u8		smac_idx;
+	u16		reserved2;
+	u8		reserved3;
+	u8		gid_index;
+	u8		stat_rate;
+	u8		hop_limit;
+	__be32		sl_tclass_flowlabel;
+	u8		dgid[16];
+	u32		reserved4[2];
+	__be16		vlan;
+	u8		mac_0_1[2];
+	u8		mac_2_5[4];
+};
+
+union mlx4_ext_av {
+	struct mlx4_av		ib;
+	struct mlx4_eth_av	eth;
+};
+
 struct mlx4_dev {
 	struct pci_dev	       *pdev;
 	unsigned long		flags;
@@ -401,6 +424,12 @@ struct mlx4_init_port_param {
 		if (((type) == MLX4_PORT_TYPE_IB ? (dev)->caps.port_mask : \
 		     ~(dev)->caps.port_mask) & 1 << ((port) - 1))
 
+#define mlx4_foreach_ib_transport_port(port, dev)			\
+	for ((port) = 1; (port) <= (dev)->caps.num_ports; (port)++)	\
+		if (((dev)->caps.port_mask & 1 << ((port) - 1)) ||	\
+		    ((dev)->caps.flags & MLX4_DEV_CAP_FLAG_RDMAOE))
+
+
 int mlx4_buf_alloc(struct mlx4_dev *dev, int size, int max_direct,
 		   struct mlx4_buf *buf);
 void mlx4_buf_free(struct mlx4_dev *dev, int size, struct mlx4_buf *buf);
diff --git a/include/linux/mlx4/qp.h b/include/linux/mlx4/qp.h
index 9f29d86..43bfef2 100644
--- a/include/linux/mlx4/qp.h
+++ b/include/linux/mlx4/qp.h
@@ -112,7 +112,9 @@ struct mlx4_qp_path {
 	u8			snooper_flags;
 	u8			reserved3[2];
 	u8			counter_index;
-	u8			reserved4[7];
+	u8			reserved4;
+	u8			dmac_h[2];
+	u8			dmac_l[4];
 };
 
 struct mlx4_qp_context {
@@ -219,7 +221,9 @@ struct mlx4_wqe_datagram_seg {
 	__be32			av[8];
 	__be32			dqpn;
 	__be32			qkey;
-	__be32			reservd[2];
+	__be16			vlan;
+	u8			mac_0_1[2];
+	u8			mac_2_5[4];
 };
 
 struct mlx4_wqe_lso_seg {
-- 
1.6.5.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
