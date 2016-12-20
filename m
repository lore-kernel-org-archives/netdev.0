From: Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: [PATCH for bnxt_re V3 08/21] bnxt_re: Adding support for port related verbs
Date: Tue, 20 Dec 2016 01:13:18 -0800
Message-ID: <1482225211-22423-9-git-send-email-selvin.xavier@broadcom.com>
References: <1482225211-22423-1-git-send-email-selvin.xavier@broadcom.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, michael.chan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
        Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Eddie Wai <eddie.wai-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Devesh Sharma <devesh.sharma-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Somnath Kotur <somnath.kotur-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Sriharsha Basavapatna <sriharsha.basavapatna-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1482225211-22423-1-git-send-email-selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Implements query_port, modify_port and port_immutable verbs

Signed-off-by: Eddie Wai <eddie.wai-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Signed-off-by: Devesh Sharma <devesh.sharma-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Signed-off-by: Somnath Kotur <somnath.kotur-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Signed-off-by: Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
---
 drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.c | 122 ++++++++++++++++++++++++
 drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.h |   7 ++
 drivers/infiniband/hw/bnxtre/bnxt_re_main.c     |   4 +
 3 files changed, 133 insertions(+)

diff --git a/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.c b/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.c
index 1c18f61..ede0e54 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.c
+++ b/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.c
@@ -150,6 +150,128 @@ int bnxt_re_modify_device(struct ib_device *ibdev,
 	return 0;
 }
 
+static void __to_ib_speed_width(struct net_device *netdev, u8 *speed, u8 *width)
+{
+	struct ethtool_link_ksettings lksettings;
+	u32 espeed;
+
+	if (netdev->ethtool_ops && netdev->ethtool_ops->get_link_ksettings) {
+		memset(&lksettings, 0, sizeof(lksettings));
+		rtnl_lock();
+		netdev->ethtool_ops->get_link_ksettings(netdev, &lksettings);
+		rtnl_unlock();
+		espeed = lksettings.base.speed;
+	} else {
+		espeed = SPEED_UNKNOWN;
+	}
+	switch (espeed) {
+	case SPEED_1000:
+		*speed = IB_SPEED_SDR;
+		*width = IB_WIDTH_1X;
+		break;
+	case SPEED_10000:
+		*speed = IB_SPEED_QDR;
+		*width = IB_WIDTH_1X;
+		break;
+	case SPEED_20000:
+		*speed = IB_SPEED_DDR;
+		*width = IB_WIDTH_4X;
+		break;
+	case SPEED_25000:
+		*speed = IB_SPEED_EDR;
+		*width = IB_WIDTH_1X;
+		break;
+	case SPEED_40000:
+		*speed = IB_SPEED_QDR;
+		*width = IB_WIDTH_4X;
+		break;
+	case SPEED_50000:
+		break;
+	default:
+		*speed = IB_SPEED_SDR;
+		*width = IB_WIDTH_1X;
+		break;
+	}
+}
+
+/* Port */
+int bnxt_re_query_port(struct ib_device *ibdev, u8 port_num,
+		       struct ib_port_attr *port_attr)
+{
+	struct bnxt_re_dev *rdev = to_bnxt_re_dev(ibdev, ibdev);
+	struct bnxt_qplib_dev_attr *dev_attr = &rdev->dev_attr;
+
+	memset(port_attr, 0, sizeof(*port_attr));
+
+	if (netif_running(rdev->netdev) && netif_carrier_ok(rdev->netdev)) {
+		port_attr->state = IB_PORT_ACTIVE;
+		port_attr->phys_state = 5;
+	} else {
+		port_attr->state = IB_PORT_DOWN;
+		port_attr->phys_state = 3;
+	}
+	port_attr->max_mtu = IB_MTU_4096;
+	port_attr->active_mtu = iboe_get_mtu(rdev->netdev->mtu);
+	port_attr->gid_tbl_len = dev_attr->max_sgid;
+	port_attr->port_cap_flags = IB_PORT_CM_SUP | IB_PORT_REINIT_SUP |
+				    IB_PORT_DEVICE_MGMT_SUP |
+				    IB_PORT_VENDOR_CLASS_SUP |
+				    IB_PORT_IP_BASED_GIDS;
+
+	/* Max MSG size set to 2G for now */
+	port_attr->max_msg_sz = 0x80000000;
+	port_attr->bad_pkey_cntr = 0;
+	port_attr->qkey_viol_cntr = 0;
+	port_attr->pkey_tbl_len = dev_attr->max_pkey;
+	port_attr->lid = 0;
+	port_attr->sm_lid = 0;
+	port_attr->lmc = 0;
+	port_attr->max_vl_num = 4;
+	port_attr->sm_sl = 0;
+	port_attr->subnet_timeout = 0;
+	port_attr->init_type_reply = 0;
+	/* call the underlying netdev's ethtool hooks to query speed settings
+	 * for which we acquire rtnl_lock _only_ if it's registered with
+	 * IB stack to avoid race in the NETDEV_UNREG path
+	 */
+	if (test_bit(BNXT_RE_FLAG_IBDEV_REGISTERED, &rdev->flags))
+		__to_ib_speed_width(rdev->netdev, &port_attr->active_speed,
+				    &port_attr->active_width);
+	return 0;
+}
+
+int bnxt_re_modify_port(struct ib_device *ibdev, u8 port_num,
+			int port_modify_mask,
+			struct ib_port_modify *port_modify)
+{
+	switch (port_modify_mask) {
+	case IB_PORT_SHUTDOWN:
+		break;
+	case IB_PORT_INIT_TYPE:
+		break;
+	case IB_PORT_RESET_QKEY_CNTR:
+		break;
+	default:
+		break;
+	}
+	return 0;
+}
+
+int bnxt_re_get_port_immutable(struct ib_device *ibdev, u8 port_num,
+			       struct ib_port_immutable *immutable)
+{
+	struct ib_port_attr port_attr;
+
+	if (bnxt_re_query_port(ibdev, port_num, &port_attr))
+		return -EINVAL;
+
+	immutable->pkey_tbl_len = port_attr.pkey_tbl_len;
+	immutable->gid_tbl_len = port_attr.gid_tbl_len;
+	immutable->core_cap_flags = RDMA_CORE_PORT_IBA_ROCE;
+	immutable->core_cap_flags |= RDMA_CORE_CAP_PROT_ROCE_UDP_ENCAP;
+	immutable->max_mad_size = IB_MGMT_MAD_SIZE;
+	return 0;
+}
 /* Protection Domains */
 int bnxt_re_dealloc_pd(struct ib_pd *ib_pd)
 {
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.h b/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.h
index 45f9253..255a0ad 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.h
+++ b/drivers/infiniband/hw/bnxtre/bnxt_re_ib_verbs.h
@@ -60,6 +60,13 @@ int bnxt_re_query_device(struct ib_device *ibdev,
 int bnxt_re_modify_device(struct ib_device *ibdev,
 			  int device_modify_mask,
 			  struct ib_device_modify *device_modify);
+int bnxt_re_query_port(struct ib_device *ibdev, u8 port_num,
+		       struct ib_port_attr *port_attr);
+int bnxt_re_modify_port(struct ib_device *ibdev, u8 port_num,
+			int port_modify_mask,
+			struct ib_port_modify *port_modify);
+int bnxt_re_get_port_immutable(struct ib_device *ibdev, u8 port_num,
+			       struct ib_port_immutable *immutable);
 struct ib_pd *bnxt_re_alloc_pd(struct ib_device *ibdev,
 			       struct ib_ucontext *context,
 			       struct ib_udata *udata);
diff --git a/drivers/infiniband/hw/bnxtre/bnxt_re_main.c b/drivers/infiniband/hw/bnxtre/bnxt_re_main.c
index ec3fce2..afadf21 100644
--- a/drivers/infiniband/hw/bnxtre/bnxt_re_main.c
+++ b/drivers/infiniband/hw/bnxtre/bnxt_re_main.c
@@ -438,6 +438,10 @@ static int bnxt_re_register_ib(struct bnxt_re_dev *rdev)
 	ibdev->dma_device = &rdev->en_dev->pdev->dev;
 	ibdev->query_device		= bnxt_re_query_device;
 	ibdev->modify_device		= bnxt_re_modify_device;
+
+	ibdev->query_port		= bnxt_re_query_port;
+	ibdev->modify_port		= bnxt_re_modify_port;
+	ibdev->get_port_immutable	= bnxt_re_get_port_immutable;
 	ibdev->alloc_pd			= bnxt_re_alloc_pd;
 	ibdev->dealloc_pd		= bnxt_re_dealloc_pd;
 	ibdev->alloc_ucontext		= bnxt_re_alloc_ucontext;
-- 
2.5.5

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
