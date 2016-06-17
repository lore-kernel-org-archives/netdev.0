From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 08/18] if_ether.h: Add RoCE Ethertype
Date: Fri, 17 Jun 2016 17:43:49 +0300
Message-ID: <1466174639-14576-9-git-send-email-saeedm@mellanox.com>
References: <1466174639-14576-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Doug Ledford <dledford@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Huy Nguyen <huyn@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:57472 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933457AbcFQOrk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jun 2016 10:47:40 -0400
In-Reply-To: <1466174639-14576-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

Add the Ethertype for RoCE - RDMA over Converged Ethernet.
Refactor vendors' implementation to use this define.

RoCE was standartized by IBTA in InfiniBand Architecture Annex A16.

Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/infiniband/hw/mlx4/qp.c                    | 6 +-----
 drivers/infiniband/hw/ocrdma/ocrdma_ah.c           | 4 ++--
 drivers/infiniband/hw/ocrdma/ocrdma_hw.c           | 2 +-
 drivers/infiniband/hw/ocrdma/ocrdma_sli.h          | 4 ----
 drivers/infiniband/hw/usnic/usnic_common_pkt_hdr.h | 1 -
 drivers/infiniband/hw/usnic/usnic_fwd.h            | 2 +-
 include/uapi/linux/if_ether.h                      | 1 +
 7 files changed, 6 insertions(+), 14 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/qp.c b/drivers/infiniband/hw/mlx4/qp.c
index 81b0e1f..fd03cef 100644
--- a/drivers/infiniband/hw/mlx4/qp.c
+++ b/drivers/infiniband/hw/mlx4/qp.c
@@ -76,10 +76,6 @@ enum {
 	MLX4_IB_LSO_HEADER_SPARE	= 128,
 };
 
-enum {
-	MLX4_IB_IBOE_ETHERTYPE		= 0x8915
-};
-
 struct mlx4_ib_sqp {
 	struct mlx4_ib_qp	qp;
 	int			pkey_index;
@@ -2563,7 +2559,7 @@ static int build_mlx_header(struct mlx4_ib_sqp *sqp, struct ib_ud_wr *wr,
 		u16 ether_type;
 		u16 pcp = (be32_to_cpu(ah->av.ib.sl_tclass_flowlabel) >> 29) << 13;
 
-		ether_type = (!is_udp) ? MLX4_IB_IBOE_ETHERTYPE :
+		ether_type = (!is_udp) ? ETH_P_ROCE :
 			(ip_version == 4 ? ETH_P_IP : ETH_P_IPV6);
 
 		mlx->sched_prio = cpu_to_be16(pcp);
diff --git a/drivers/infiniband/hw/ocrdma/ocrdma_ah.c b/drivers/infiniband/hw/ocrdma/ocrdma_ah.c
index 797362a..3d5d841 100644
--- a/drivers/infiniband/hw/ocrdma/ocrdma_ah.c
+++ b/drivers/infiniband/hw/ocrdma/ocrdma_ah.c
@@ -59,7 +59,7 @@ static u16 ocrdma_hdr_type_to_proto_num(int devid, u8 hdr_type)
 {
 	switch (hdr_type) {
 	case OCRDMA_L3_TYPE_IB_GRH:
-		return (u16)0x8915;
+		return (u16)ETH_P_ROCE;
 	case OCRDMA_L3_TYPE_IPV4:
 		return (u16)0x0800;
 	case OCRDMA_L3_TYPE_IPV6:
@@ -94,7 +94,7 @@ static inline int set_av_attr(struct ocrdma_dev *dev, struct ocrdma_ah *ah,
 	proto_num = ocrdma_hdr_type_to_proto_num(dev->id, ah->hdr_type);
 	if (!proto_num)
 		return -EINVAL;
-	nxthdr = (proto_num == 0x8915) ? 0x1b : 0x11;
+	nxthdr = (proto_num == ETH_P_ROCE) ? 0x1b : 0x11;
 	/* VLAN */
 	if (!vlan_tag || (vlan_tag > 0xFFF))
 		vlan_tag = dev->pvid;
diff --git a/drivers/infiniband/hw/ocrdma/ocrdma_hw.c b/drivers/infiniband/hw/ocrdma/ocrdma_hw.c
index 16740dc..d45d1b4 100644
--- a/drivers/infiniband/hw/ocrdma/ocrdma_hw.c
+++ b/drivers/infiniband/hw/ocrdma/ocrdma_hw.c
@@ -2985,7 +2985,7 @@ static int ocrdma_parse_dcbxcfg_rsp(struct ocrdma_dev *dev, int ptype,
 				OCRDMA_APP_PARAM_APP_PROTO_MASK;
 
 		if (
-			valid && proto == OCRDMA_APP_PROTO_ROCE &&
+			valid && proto == ETH_P_ROCE &&
 			proto_sel == OCRDMA_PROTO_SELECT_L2) {
 			for (slindx = 0; slindx <
 				OCRDMA_MAX_SERVICE_LEVEL_INDEX; slindx++) {
diff --git a/drivers/infiniband/hw/ocrdma/ocrdma_sli.h b/drivers/infiniband/hw/ocrdma/ocrdma_sli.h
index 0efc966..1751a96 100644
--- a/drivers/infiniband/hw/ocrdma/ocrdma_sli.h
+++ b/drivers/infiniband/hw/ocrdma/ocrdma_sli.h
@@ -2175,10 +2175,6 @@ enum OCRDMA_DCBX_PARAM_TYPE {
 	OCRDMA_PARAMETER_TYPE_PEER	= 0x02
 };
 
-enum OCRDMA_DCBX_APP_PROTO {
-	OCRDMA_APP_PROTO_ROCE	= 0x8915
-};
-
 enum OCRDMA_DCBX_PROTO {
 	OCRDMA_PROTO_SELECT_L2	= 0x00,
 	OCRDMA_PROTO_SELECT_L4	= 0x01
diff --git a/drivers/infiniband/hw/usnic/usnic_common_pkt_hdr.h b/drivers/infiniband/hw/usnic/usnic_common_pkt_hdr.h
index 596e0ed..bf7d197 100644
--- a/drivers/infiniband/hw/usnic/usnic_common_pkt_hdr.h
+++ b/drivers/infiniband/hw/usnic/usnic_common_pkt_hdr.h
@@ -34,7 +34,6 @@
 #ifndef USNIC_CMN_PKT_HDR_H
 #define USNIC_CMN_PKT_HDR_H
 
-#define USNIC_ROCE_ETHERTYPE		(0x8915)
 #define USNIC_ROCE_GRH_VER              (8)
 #define USNIC_PROTO_VER                 (1)
 #define USNIC_ROCE_GRH_VER_SHIFT        (4)
diff --git a/drivers/infiniband/hw/usnic/usnic_fwd.h b/drivers/infiniband/hw/usnic/usnic_fwd.h
index 3a8add9..0f7baae 100644
--- a/drivers/infiniband/hw/usnic/usnic_fwd.h
+++ b/drivers/infiniband/hw/usnic/usnic_fwd.h
@@ -97,7 +97,7 @@ static inline void usnic_fwd_init_usnic_filter(struct filter *filter,
 						uint32_t usnic_id)
 {
 	filter->type = FILTER_USNIC_ID;
-	filter->u.usnic.ethtype = USNIC_ROCE_ETHERTYPE;
+	filter->u.usnic.ethtype = ETH_P_ROCE;
 	filter->u.usnic.flags = FILTER_FIELD_USNIC_ETHTYPE |
 				FILTER_FIELD_USNIC_ID |
 				FILTER_FIELD_USNIC_PROTO;
diff --git a/include/uapi/linux/if_ether.h b/include/uapi/linux/if_ether.h
index cec849a..8e69375 100644
--- a/include/uapi/linux/if_ether.h
+++ b/include/uapi/linux/if_ether.h
@@ -91,6 +91,7 @@
 #define ETH_P_FCOE	0x8906		/* Fibre Channel over Ethernet  */
 #define ETH_P_TDLS	0x890D          /* TDLS */
 #define ETH_P_FIP	0x8914		/* FCoE Initialization Protocol */
+#define ETH_P_ROCE	0x8915		/* RDMA over Converged Ethernet */
 #define ETH_P_80221	0x8917		/* IEEE 802.21 Media Independent Handover Protocol */
 #define ETH_P_HSR	0x892F		/* IEC 62439-3 HSRv1	*/
 #define ETH_P_LOOPBACK	0x9000		/* Ethernet loopback packet, per IEEE 802.3 */
-- 
2.8.0
