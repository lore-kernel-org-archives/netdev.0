From: Ram Amrani <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 09/11] qedr: Add LL2 RoCE interface
Date: Mon, 26 Sep 2016 17:16:45 +0300
Message-ID: <1474899407-12635-10-git-send-email-Ram.Amrani@cavium.com>
References: <1474899407-12635-1-git-send-email-Ram.Amrani@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>, <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>, <rajesh.borundia-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Ram Amrani <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1474899407-12635-1-git-send-email-Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add light L2 interface for RoCE.

Signed-off-by: Rajesh Borundia <rajesh.borundia-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Ram Amrani <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
---
 drivers/infiniband/hw/qedr/main.c          |  34 +++-
 drivers/infiniband/hw/qedr/qedr.h          |   2 +-
 drivers/net/ethernet/qlogic/qed/qed.h      |   1 +
 drivers/net/ethernet/qlogic/qed/qed_hsi.h  |   3 +
 drivers/net/ethernet/qlogic/qed/qed_ll2.c  |  20 ++-
 drivers/net/ethernet/qlogic/qed/qed_ll2.h  |   7 +
 drivers/net/ethernet/qlogic/qed/qed_roce.c | 241 +++++++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_roce.h |   1 +
 include/linux/qed/qed_roce_if.h            |  79 ++++++++++
 9 files changed, 384 insertions(+), 4 deletions(-)

diff --git a/drivers/infiniband/hw/qedr/main.c b/drivers/infiniband/hw/qedr/main.c
index b52cd8f..8ed1503 100644
--- a/drivers/infiniband/hw/qedr/main.c
+++ b/drivers/infiniband/hw/qedr/main.c
@@ -698,6 +698,38 @@ static void qedr_shutdown(struct qedr_dev *dev)
 	qedr_remove(dev);
 }
 
+static void qedr_mac_address_change(struct qedr_dev *dev)
+{
+	union ib_gid *sgid = &dev->sgid_tbl[0];
+	u8 guid[8], mac_addr[6];
+	int rc;
+
+	/* Update SGID */
+	ether_addr_copy(&mac_addr[0], dev->ndev->dev_addr);
+	guid[0] = mac_addr[0] ^ 2;
+	guid[1] = mac_addr[1];
+	guid[2] = mac_addr[2];
+	guid[3] = 0xff;
+	guid[4] = 0xfe;
+	guid[5] = mac_addr[3];
+	guid[6] = mac_addr[4];
+	guid[7] = mac_addr[5];
+	sgid->global.subnet_prefix = cpu_to_be64(0xfe80000000000000LL);
+	memcpy(&sgid->raw[8], guid, sizeof(guid));
+
+	/* Update LL2 */
+	rc = dev->ops->roce_ll2_set_mac_filter(dev->cdev,
+					       dev->gsi_ll2_mac_address,
+					       dev->ndev->dev_addr);
+
+	ether_addr_copy(dev->gsi_ll2_mac_address, dev->ndev->dev_addr);
+
+	qedr_ib_dispatch_event(dev, 1, IB_EVENT_GID_CHANGE);
+
+	if (rc)
+		DP_ERR(dev, "Error updating mac filter\n");
+}
+
 /* event handling via NIC driver ensures that all the NIC specific
  * initialization done before RoCE driver notifies
  * event to stack.
@@ -715,7 +747,7 @@ static void qedr_notify(struct qedr_dev *dev, enum qede_roce_event event)
 		qedr_shutdown(dev);
 		break;
 	case QEDE_CHANGE_ADDR:
-		qedr_ib_dispatch_event(dev, 1, IB_EVENT_GID_CHANGE);
+		qedr_mac_address_change(dev);
 		break;
 	default:
 		pr_err("Event not supported\n");
diff --git a/drivers/infiniband/hw/qedr/qedr.h b/drivers/infiniband/hw/qedr/qedr.h
index ba380d6..bdfc599 100644
--- a/drivers/infiniband/hw/qedr/qedr.h
+++ b/drivers/infiniband/hw/qedr/qedr.h
@@ -149,7 +149,7 @@ struct qedr_dev {
 	u8			dp_level;
 	u8			num_hwfns;
 	uint			wq_multiplier;
-
+	u8			gsi_ll2_mac_address[ETH_ALEN];
 };
 
 #define QEDR_MAX_SQ_PBL			(0x8000)
diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index a92aa80..3387f47 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -429,6 +429,7 @@ struct qed_hwfn {
 #endif
 
 	struct z_stream_s		*stream;
+	struct qed_roce_ll2_info	*ll2;
 };
 
 struct pci_params {
diff --git a/drivers/net/ethernet/qlogic/qed/qed_hsi.h b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
index 2777d5b..72eee29 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_hsi.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
@@ -727,6 +727,9 @@ struct core_tx_bd_flags {
 #define CORE_TX_BD_FLAGS_L4_PROTOCOL_SHIFT	6
 #define CORE_TX_BD_FLAGS_L4_PSEUDO_CSUM_MODE_MASK	0x1
 #define CORE_TX_BD_FLAGS_L4_PSEUDO_CSUM_MODE_SHIFT 7
+#define CORE_TX_BD_FLAGS_ROCE_FLAV_MASK		0x1
+#define CORE_TX_BD_FLAGS_ROCE_FLAV_SHIFT	12
+
 };
 
 struct core_tx_bd {
diff --git a/drivers/net/ethernet/qlogic/qed/qed_ll2.c b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
index e0ec8ed..c90f1fd 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_ll2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
@@ -1026,6 +1026,7 @@ static void qed_ll2_prepare_tx_packet_set_bd(struct qed_hwfn *p_hwfn,
 					     u16 vlan,
 					     u8 bd_flags,
 					     u16 l4_hdr_offset_w,
+					     enum core_roce_flavor_type type,
 					     dma_addr_t first_frag,
 					     u16 first_frag_len)
 {
@@ -1046,6 +1047,9 @@ static void qed_ll2_prepare_tx_packet_set_bd(struct qed_hwfn *p_hwfn,
 	DMA_REGPAIR_LE(start_bd->addr, first_frag);
 	start_bd->nbytes = cpu_to_le16(first_frag_len);
 
+	SET_FIELD(start_bd->bd_flags.as_bitfield, CORE_TX_BD_FLAGS_ROCE_FLAV,
+		  type);
+
 	DP_VERBOSE(p_hwfn,
 		   (NETIF_MSG_TX_QUEUED | QED_MSG_LL2),
 		   "LL2 [q 0x%02x cid 0x%08x type 0x%08x] Tx Producer at [0x%04x] - set with a %04x bytes %02x BDs buffer at %08x:%08x\n",
@@ -1137,11 +1141,13 @@ int qed_ll2_prepare_tx_packet(struct qed_hwfn *p_hwfn,
 			      u16 vlan,
 			      u8 bd_flags,
 			      u16 l4_hdr_offset_w,
+			      enum qed_ll2_roce_flavor_type qed_roce_flavor,
 			      dma_addr_t first_frag,
 			      u16 first_frag_len, void *cookie, u8 notify_fw)
 {
 	struct qed_ll2_tx_packet *p_curp = NULL;
 	struct qed_ll2_info *p_ll2_conn = NULL;
+	enum core_roce_flavor_type roce_flavor;
 	struct qed_ll2_tx_queue *p_tx;
 	struct qed_chain *p_tx_chain;
 	unsigned long flags;
@@ -1174,6 +1180,15 @@ int qed_ll2_prepare_tx_packet(struct qed_hwfn *p_hwfn,
 		goto out;
 	}
 
+	if (qed_roce_flavor == QED_LL2_ROCE) {
+		roce_flavor = CORE_ROCE;
+	} else if (qed_roce_flavor == QED_LL2_RROCE) {
+		roce_flavor = CORE_RROCE;
+	} else {
+		rc = -EINVAL;
+		goto out;
+	}
+
 	/* Prepare packet and BD, and perhaps send a doorbell to FW */
 	qed_ll2_prepare_tx_packet_set(p_hwfn, p_tx, p_curp,
 				      num_of_bds, first_frag,
@@ -1181,6 +1196,7 @@ int qed_ll2_prepare_tx_packet(struct qed_hwfn *p_hwfn,
 	qed_ll2_prepare_tx_packet_set_bd(p_hwfn, p_ll2_conn, p_curp,
 					 num_of_bds, CORE_TX_DEST_NW,
 					 vlan, bd_flags, l4_hdr_offset_w,
+					 roce_flavor,
 					 first_frag, first_frag_len);
 
 	qed_ll2_tx_packet_notify(p_hwfn, p_ll2_conn);
@@ -1625,8 +1641,8 @@ static int qed_ll2_start_xmit(struct qed_dev *cdev, struct sk_buff *skb)
 	rc = qed_ll2_prepare_tx_packet(QED_LEADING_HWFN(cdev),
 				       cdev->ll2->handle,
 				       1 + skb_shinfo(skb)->nr_frags,
-				       vlan, flags, 0, mapping,
-				       skb->len, skb, 1);
+				       vlan, flags, 0, 0 /* RoCE FLAVOR */,
+				       mapping, skb->len, skb, 1);
 	if (rc)
 		goto err;
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_ll2.h b/drivers/net/ethernet/qlogic/qed/qed_ll2.h
index a037c48..b3783fd 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_ll2.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_ll2.h
@@ -24,6 +24,12 @@
 
 #define QED_MAX_NUM_OF_LL2_CONNECTIONS                    (4)
 
+enum qed_ll2_roce_flavor_type {
+	QED_LL2_ROCE,
+	QED_LL2_RROCE,
+	MAX_QED_LL2_ROCE_FLAVOR_TYPE
+};
+
 enum qed_ll2_conn_type {
 	QED_LL2_TYPE_RESERVED,
 	QED_LL2_TYPE_ISCSI,
@@ -199,6 +205,7 @@ int qed_ll2_prepare_tx_packet(struct qed_hwfn *p_hwfn,
 			      u16 vlan,
 			      u8 bd_flags,
 			      u16 l4_hdr_offset_w,
+			      enum qed_ll2_roce_flavor_type qed_roce_flavor,
 			      dma_addr_t first_frag,
 			      u16 first_frag_len, void *cookie, u8 notify_fw);
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_roce.c b/drivers/net/ethernet/qlogic/qed/qed_roce.c
index 04e33ee..b4f851b 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_roce.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_roce.c
@@ -64,6 +64,7 @@
 #include "qed_reg_addr.h"
 #include "qed_sp.h"
 #include "qed_roce.h"
+#include "qed_ll2.h"
 
 void qed_async_roce_event(struct qed_hwfn *p_hwfn,
 			  struct event_ring_entry *p_eqe)
@@ -2632,6 +2633,240 @@ void qed_rdma_remove_user(void *rdma_cxt, u16 dpi)
 	spin_unlock_bh(&p_hwfn->p_rdma_info->lock);
 }
 
+static int qed_roce_ll2_set_mac_filter(struct qed_dev *cdev,
+				       u8 *old_mac_address,
+				       u8 *new_mac_address)
+{
+	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_ptt *p_ptt;
+	int rc = 0;
+
+	if (!hwfn->ll2 || hwfn->ll2->handle == QED_LL2_UNUSED_HANDLE) {
+		DP_ERR(cdev,
+		       "qed roce mac filter failed - roce_info/ll2 NULL\n");
+		return -EINVAL;
+	}
+
+	p_ptt = qed_ptt_acquire(QED_LEADING_HWFN(cdev));
+	if (!p_ptt) {
+		DP_ERR(cdev,
+		       "qed roce ll2 mac filter set: failed to acquire PTT\n");
+		return -EINVAL;
+	}
+
+	mutex_lock(&hwfn->ll2->lock);
+	if (old_mac_address)
+		qed_llh_remove_mac_filter(QED_LEADING_HWFN(cdev), p_ptt,
+					  old_mac_address);
+	if (new_mac_address)
+		rc = qed_llh_add_mac_filter(QED_LEADING_HWFN(cdev), p_ptt,
+					    new_mac_address);
+	mutex_unlock(&hwfn->ll2->lock);
+
+	qed_ptt_release(QED_LEADING_HWFN(cdev), p_ptt);
+
+	if (rc)
+		DP_ERR(cdev,
+		       "qed roce ll2 mac filter set: failed to add mac filter\n");
+
+	return rc;
+}
+
+static int qed_roce_ll2_start(struct qed_dev *cdev,
+			      struct qed_roce_ll2_params *params)
+{
+	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_roce_ll2_info *roce_ll2;
+	struct qed_ll2_info ll2_params;
+	int rc;
+
+	if (!params) {
+		DP_ERR(cdev, "qed roce ll2 start: failed due to NULL params\n");
+		return -EINVAL;
+	}
+	if (!params->cbs.tx_cb || !params->cbs.rx_cb) {
+		DP_ERR(cdev,
+		       "qed roce ll2 start: failed due to NULL tx/rx. tx_cb=%p, rx_cb=%p\n",
+		       params->cbs.tx_cb, params->cbs.rx_cb);
+		return -EINVAL;
+	}
+	if (!is_valid_ether_addr(params->mac_address)) {
+		DP_ERR(cdev,
+		       "qed roce ll2 start: failed due to invalid Ethernet address %pM\n",
+		       params->mac_address);
+		return -EINVAL;
+	}
+
+	/* Initialize */
+	roce_ll2 = kzalloc(sizeof(*roce_ll2), GFP_ATOMIC);
+	if (!roce_ll2) {
+		DP_ERR(cdev, "qed roce ll2 start: failed memory allocation\n");
+		return -ENOMEM;
+	}
+	memset(roce_ll2, 0, sizeof(*roce_ll2));
+	roce_ll2->handle = QED_LL2_UNUSED_HANDLE;
+	roce_ll2->cbs = params->cbs;
+	roce_ll2->cb_cookie = params->cb_cookie;
+	mutex_init(&roce_ll2->lock);
+
+	memset(&ll2_params, 0, sizeof(ll2_params));
+	ll2_params.conn_type = QED_LL2_TYPE_ROCE;
+	ll2_params.mtu = params->mtu;
+	ll2_params.rx_drop_ttl0_flg = true;
+	ll2_params.rx_vlan_removal_en = false;
+	ll2_params.tx_dest = CORE_TX_DEST_NW;
+	ll2_params.ai_err_packet_too_big = LL2_DROP_PACKET;
+	ll2_params.ai_err_no_buf = LL2_DROP_PACKET;
+
+	rc = qed_ll2_acquire_connection(QED_LEADING_HWFN(cdev), &ll2_params,
+					params->max_rx_buffers,
+					params->max_tx_buffers,
+					&roce_ll2->handle);
+	if (rc) {
+		DP_ERR(cdev,
+		       "qed roce ll2 start: failed to acquire LL2 connection (rc=%d)\n",
+		       rc);
+		goto err;
+	}
+
+	rc = qed_ll2_establish_connection(QED_LEADING_HWFN(cdev),
+					  roce_ll2->handle);
+	if (rc) {
+		DP_ERR(cdev,
+		       "qed roce ll2 start: failed to establish LL2 connection (rc=%d)\n",
+		       rc);
+		goto err1;
+	}
+
+	hwfn->ll2 = roce_ll2;
+
+	rc = qed_roce_ll2_set_mac_filter(cdev, NULL, params->mac_address);
+	if (rc) {
+		hwfn->ll2 = NULL;
+		goto err2;
+	}
+	ether_addr_copy(roce_ll2->mac_address, params->mac_address);
+
+	return 0;
+
+err2:
+	qed_ll2_terminate_connection(QED_LEADING_HWFN(cdev), roce_ll2->handle);
+err1:
+	qed_ll2_release_connection(QED_LEADING_HWFN(cdev), roce_ll2->handle);
+err:
+	kfree(roce_ll2);
+	return rc;
+}
+
+static int qed_roce_ll2_stop(struct qed_dev *cdev)
+{
+	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_roce_ll2_info *roce_ll2 = hwfn->ll2;
+	int rc;
+
+	if (!cdev) {
+		DP_ERR(cdev, "qed roce ll2 stop: invalid cdev\n");
+		return -EINVAL;
+	}
+
+	if (roce_ll2->handle == QED_LL2_UNUSED_HANDLE) {
+		DP_ERR(cdev, "qed roce ll2 stop: cannot stop an unused LL2\n");
+		return -EINVAL;
+	}
+
+	/* remove LL2 MAC address filter */
+	rc = qed_roce_ll2_set_mac_filter(cdev, roce_ll2->mac_address, NULL);
+	eth_zero_addr(roce_ll2->mac_address);
+
+	rc = qed_ll2_terminate_connection(QED_LEADING_HWFN(cdev),
+					  roce_ll2->handle);
+	if (rc)
+		DP_ERR(cdev,
+		       "qed roce ll2 stop: failed to terminate LL2 connection (rc=%d)\n",
+		       rc);
+
+	qed_ll2_release_connection(QED_LEADING_HWFN(cdev), roce_ll2->handle);
+
+	roce_ll2->handle = QED_LL2_UNUSED_HANDLE;
+
+	kfree(roce_ll2);
+
+	return rc;
+}
+
+static int qed_roce_ll2_tx(struct qed_dev *cdev,
+			   struct qed_roce_ll2_packet *pkt,
+			   struct qed_roce_ll2_tx_params *params)
+{
+	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_roce_ll2_info *roce_ll2 = hwfn->ll2;
+	enum qed_ll2_roce_flavor_type qed_roce_flavor;
+	u8 flags = 0;
+	int rc;
+	int i;
+
+	if (!cdev || !pkt || !params) {
+		DP_ERR(cdev,
+		       "roce ll2 tx: failed tx because one of the following is NULL - drv=%p, pkt=%p, params=%p\n",
+		       cdev, pkt, params);
+		return -EINVAL;
+	}
+
+	qed_roce_flavor = (pkt->roce_mode == ROCE_V1) ? QED_LL2_ROCE
+						      : QED_LL2_RROCE;
+
+	if (pkt->roce_mode == ROCE_V2_IPV4)
+		flags |= BIT(CORE_TX_BD_FLAGS_IP_CSUM_SHIFT);
+
+	/* Tx header */
+	rc = qed_ll2_prepare_tx_packet(QED_LEADING_HWFN(cdev), roce_ll2->handle,
+				       1 + pkt->n_seg, 0, flags, 0,
+				       qed_roce_flavor, pkt->header.baddr,
+				       pkt->header.len, pkt, 1);
+	if (rc) {
+		DP_ERR(cdev, "roce ll2 tx: header failed (rc=%d)\n", rc);
+		return QED_ROCE_TX_HEAD_FAILURE;
+	}
+
+	/* Tx payload */
+	for (i = 0; i < pkt->n_seg; i++) {
+		rc = qed_ll2_set_fragment_of_tx_packet(QED_LEADING_HWFN(cdev),
+						       roce_ll2->handle,
+						       pkt->payload[i].baddr,
+						       pkt->payload[i].len);
+		if (rc) {
+			/* If failed not much to do here, partial packet has
+			 * been posted * we can't free memory, will need to wait
+			 * for completion
+			 */
+			DP_ERR(cdev,
+			       "roce ll2 tx: payload failed (rc=%d)\n", rc);
+			return QED_ROCE_TX_FRAG_FAILURE;
+		}
+	}
+
+	return 0;
+}
+
+static int qed_roce_ll2_post_rx_buffer(struct qed_dev *cdev,
+				       struct qed_roce_ll2_buffer *buf,
+				       u64 cookie, u8 notify_fw)
+{
+	return qed_ll2_post_rx_buffer(QED_LEADING_HWFN(cdev),
+				      QED_LEADING_HWFN(cdev)->ll2->handle,
+				      buf->baddr, buf->len,
+				      (void *)(uintptr_t)cookie, notify_fw);
+}
+
+static int qed_roce_ll2_stats(struct qed_dev *cdev, struct qed_ll2_stats *stats)
+{
+	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_roce_ll2_info *roce_ll2 = hwfn->ll2;
+
+	return qed_ll2_get_stats(QED_LEADING_HWFN(cdev),
+				 roce_ll2->handle, stats);
+}
+
 static const struct qed_rdma_ops qed_rdma_ops_pass = {
 	.common = &qed_common_ops_pass,
 	.fill_dev_info = &qed_fill_rdma_dev_info,
@@ -2659,6 +2894,12 @@ static const struct qed_rdma_ops qed_rdma_ops_pass = {
 	.rdma_free_tid = &qed_rdma_free_tid,
 	.rdma_register_tid = &qed_rdma_register_tid,
 	.rdma_deregister_tid = &qed_rdma_deregister_tid,
+	.roce_ll2_start = &qed_roce_ll2_start,
+	.roce_ll2_stop = &qed_roce_ll2_stop,
+	.roce_ll2_tx = &qed_roce_ll2_tx,
+	.roce_ll2_post_rx_buffer = &qed_roce_ll2_post_rx_buffer,
+	.roce_ll2_set_mac_filter = &qed_roce_ll2_set_mac_filter,
+	.roce_ll2_stats = &qed_roce_ll2_stats,
 };
 
 const struct qed_rdma_ops *qed_get_rdma_ops()
diff --git a/drivers/net/ethernet/qlogic/qed/qed_roce.h b/drivers/net/ethernet/qlogic/qed/qed_roce.h
index 71b37fc..f688a47 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_roce.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_roce.h
@@ -42,6 +42,7 @@
 #include "qed.h"
 #include "qed_dev_api.h"
 #include "qed_hsi.h"
+#include "qed_ll2.h"
 
 #define QED_RDMA_MAX_FMR                    (RDMA_MAX_TIDS)
 #define QED_RDMA_MAX_P_KEY                  (1)
diff --git a/include/linux/qed/qed_roce_if.h b/include/linux/qed/qed_roce_if.h
index 0b6df6e..53047d3 100644
--- a/include/linux/qed/qed_roce_if.h
+++ b/include/linux/qed/qed_roce_if.h
@@ -39,6 +39,16 @@
 #include <linux/slab.h>
 #include <linux/qed/qed_if.h>
 #include <linux/qed/qed_ll2_if.h>
+#include <linux/qed/rdma_common.h>
+
+enum qed_roce_ll2_tx_dest {
+	/* Light L2 TX Destination to the Network */
+	QED_ROCE_LL2_TX_DEST_NW,
+
+	/* Light L2 TX Destination to the Loopback */
+	QED_ROCE_LL2_TX_DEST_LB,
+	QED_ROCE_LL2_TX_DEST_MAX
+};
 
 #define QED_RDMA_MAX_CNQ_SIZE               (0xFFFF)
 
@@ -461,6 +471,61 @@ struct qed_rdma_counters_out_params {
 #define QED_ROCE_TX_HEAD_FAILURE        (1)
 #define QED_ROCE_TX_FRAG_FAILURE        (2)
 
+struct qed_roce_ll2_header {
+	void *vaddr;
+	dma_addr_t baddr;
+	size_t len;
+};
+
+struct qed_roce_ll2_buffer {
+	dma_addr_t baddr;
+	size_t len;
+};
+
+struct qed_roce_ll2_packet {
+	struct qed_roce_ll2_header header;
+	int n_seg;
+	struct qed_roce_ll2_buffer payload[RDMA_MAX_SGE_PER_SQ_WQE];
+	int roce_mode;
+	enum qed_roce_ll2_tx_dest tx_dest;
+};
+
+struct qed_roce_ll2_tx_params {
+	int reserved;
+};
+
+struct qed_roce_ll2_rx_params {
+	u16 vlan_id;
+	u8 smac[ETH_ALEN];
+	int rc;
+};
+
+struct qed_roce_ll2_cbs {
+	void (*tx_cb)(void *pdev, struct qed_roce_ll2_packet *pkt);
+
+	void (*rx_cb)(void *pdev, struct qed_roce_ll2_packet *pkt,
+		      struct qed_roce_ll2_rx_params *params);
+};
+
+struct qed_roce_ll2_params {
+	u16 max_rx_buffers;
+	u16 max_tx_buffers;
+	u16 mtu;
+	u8 mac_address[ETH_ALEN];
+	struct qed_roce_ll2_cbs cbs;
+	void *cb_cookie;
+};
+
+struct qed_roce_ll2_info {
+	u8 handle;
+	struct qed_roce_ll2_cbs cbs;
+	u8 mac_address[ETH_ALEN];
+	void *cb_cookie;
+
+	/* Lock to protect ll2 */
+	struct mutex lock;
+};
+
 enum qed_rdma_type {
 	QED_RDMA_TYPE_ROCE,
 };
@@ -518,6 +583,20 @@ struct qed_rdma_ops {
 	int (*rdma_deregister_tid)(void *rdma_cxt, u32 itid);
 	int (*rdma_alloc_tid)(void *rdma_cxt, u32 *itid);
 	void (*rdma_free_tid)(void *rdma_cxt, u32 itid);
+	int (*roce_ll2_start)(struct qed_dev *cdev,
+			      struct qed_roce_ll2_params *params);
+	int (*roce_ll2_stop)(struct qed_dev *cdev);
+	int (*roce_ll2_tx)(struct qed_dev *cdev,
+			   struct qed_roce_ll2_packet *packet,
+			   struct qed_roce_ll2_tx_params *params);
+	int (*roce_ll2_post_rx_buffer)(struct qed_dev *cdev,
+				       struct qed_roce_ll2_buffer *buf,
+				       u64 cookie, u8 notify_fw);
+	int (*roce_ll2_set_mac_filter)(struct qed_dev *cdev,
+				       u8 *old_mac_address,
+				       u8 *new_mac_address);
+	int (*roce_ll2_stats)(struct qed_dev *cdev,
+			      struct qed_ll2_stats *stats);
 };
 
 const struct qed_rdma_ops *qed_get_rdma_ops(void);
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
