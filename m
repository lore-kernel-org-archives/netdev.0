From: Erez Shitrit <erezsh@mellanox.com>
Subject: [RFC v1 for accelerated IPoIB 05/25] IB/ipoib: Support ipoib acceleration options callbacks
Date: Mon, 13 Mar 2017 20:31:16 +0200
Message-ID: <1489429896-10781-6-git-send-email-erezsh@mellanox.com>
References: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        valex@mellanox.com, leonro@mellanox.com, saedm@mellanox.com,
        erezsh@dev.mellanox.co.il, Erez Shitrit <erezsh@mellanox.com>
To: dledford@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:49706 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752799AbdCMScC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 14:32:02 -0400
In-Reply-To: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


IPoIB driver now uses the new set of callback functions.
If the HW provider supports the new ipoib_options implementation, the
driver uses the callbacks in its datapath flows, otherwise it uses the
driver default implementation for all data flows in its code.
The default implementation is exactly the driver implementation as it
was without HW vendor support.

TODO: We added remote qkey to ipoib_send in order to match send op
signature.
In accel mode this param will be used but in regular mode this param is
redundant. Need to think about better solution.

Signed-off-by: Erez Shitrit <erezsh@mellanox.com>
---
 drivers/infiniband/ulp/ipoib/ipoib.h           |  30 ++--
 drivers/infiniband/ulp/ipoib/ipoib_cm.c        |  66 ++++----
 drivers/infiniband/ulp/ipoib/ipoib_ethtool.c   |   6 +-
 drivers/infiniband/ulp/ipoib/ipoib_fs.c        |   4 +-
 drivers/infiniband/ulp/ipoib/ipoib_ib.c        |  57 +++----
 drivers/infiniband/ulp/ipoib/ipoib_main.c      | 207 ++++++++++++++++---------
 drivers/infiniband/ulp/ipoib/ipoib_multicast.c |  39 +++--
 drivers/infiniband/ulp/ipoib/ipoib_netlink.c   |  12 +-
 drivers/infiniband/ulp/ipoib/ipoib_verbs.c     |  24 ++-
 drivers/infiniband/ulp/ipoib/ipoib_vlan.c      |   9 +-
 10 files changed, 275 insertions(+), 179 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib.h b/drivers/infiniband/ulp/ipoib/ipoib.h
index d94a7a953338..48da1b5be183 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib.h
+++ b/drivers/infiniband/ulp/ipoib/ipoib.h
@@ -51,8 +51,8 @@
 #include <rdma/ib_verbs.h>
 #include <rdma/ib_pack.h>
 #include <rdma/ib_sa.h>
+#include <rdma/ib_ipoib_accel_ops.h>
 #include <linux/sched.h>
-
 /* constants */
 
 enum ipoib_flush_level {
@@ -357,6 +357,7 @@ struct ipoib_dev_priv {
 	struct ib_cq	 *recv_cq;
 	struct ib_cq	 *send_cq;
 	struct ib_qp	 *qp;
+	u32		  qp_num;
 	u32		  qkey;
 
 	union ib_gid local_gid;
@@ -404,6 +405,7 @@ struct ipoib_dev_priv {
 	struct timer_list poll_timer;
 	unsigned max_send_sge;
 	bool sm_fullmember_sendonly_support;
+	const struct net_device_ops	*rn_ops;
 };
 
 struct ipoib_ah {
@@ -483,22 +485,26 @@ static inline void ipoib_put_ah(struct ipoib_ah *ah)
 int ipoib_add_umcast_attr(struct net_device *dev);
 
 void ipoib_send(struct net_device *dev, struct sk_buff *skb,
-		struct ipoib_ah *address, u32 dqpn);
+		struct ipoib_ah *address, u32 dqpn, u32 dqkey);
 void ipoib_reap_ah(struct work_struct *work);
 
 struct ipoib_path *__path_find(struct net_device *dev, void *gid);
 void ipoib_mark_paths_invalid(struct net_device *dev);
 void ipoib_flush_paths(struct net_device *dev);
 int ipoib_check_sm_sendonly_fullmember_support(struct ipoib_dev_priv *priv);
-struct ipoib_dev_priv *ipoib_intf_alloc(const char *format);
+struct ipoib_dev_priv *ipoib_intf_alloc(struct ib_device *hca, u8 port,
+					const char *format);
 void ipoib_ib_tx_timer_func(unsigned long ctx);
 void ipoib_ib_dev_flush_light(struct work_struct *work);
 void ipoib_ib_dev_flush_normal(struct work_struct *work);
 void ipoib_ib_dev_flush_heavy(struct work_struct *work);
 void ipoib_pkey_event(struct work_struct *work);
 void ipoib_ib_dev_cleanup(struct net_device *dev);
-void ipoib_dev_uninit_default(struct net_device *dev);
+void ipoib_dev_uninit_default(struct net_device *dev, struct ib_device *hca);
+int ipoib_ib_dev_open_default(struct net_device *dev);
+int ipoib_ib_dev_stop_default(struct net_device *dev);
 int ipoib_ib_dev_open(struct net_device *dev);
+int ipoib_ib_dev_stop(struct net_device *dev);
 void ipoib_ib_dev_up(struct net_device *dev);
 void ipoib_ib_dev_down(struct net_device *dev);
 int ipoib_ib_dev_stop_default(struct net_device *dev);
@@ -561,8 +567,10 @@ void ipoib_path_iter_read(struct ipoib_path_iter *iter,
 			  struct ipoib_path *path);
 #endif
 
-int ipoib_mcast_attach(struct net_device *dev, u16 mlid,
-		       union ib_gid *mgid, int set_qkey);
+int ipoib_mcast_attach(struct net_device *dev, struct ib_device *hca,
+		       union ib_gid *mgid, u16 mlid, int set_qkey);
+int ipoib_mcast_detach(struct net_device *dev, struct ib_device *hca,
+		       union ib_gid *mgid, u16 mlid);
 void ipoib_mcast_remove_list(struct list_head *remove_list);
 void ipoib_check_and_add_mcast_sendonly(struct ipoib_dev_priv *priv, u8 *mgid,
 				struct list_head *remove_list);
@@ -586,7 +594,7 @@ int __ipoib_vlan_add(struct ipoib_dev_priv *ppriv, struct ipoib_dev_priv *priv,
 void ipoib_set_umcast(struct net_device *ndev, int umcast_val);
 int  ipoib_set_mode(struct net_device *dev, const char *buf);
 
-void ipoib_setup(struct net_device *dev);
+void ipoib_setup_common(struct net_device *dev);
 
 void ipoib_pkey_open(struct ipoib_dev_priv *priv);
 void ipoib_drain_cq(struct net_device *dev);
@@ -606,14 +614,14 @@ int __ipoib_vlan_add(struct ipoib_dev_priv *ppriv, struct ipoib_dev_priv *priv,
 
 static inline int ipoib_cm_admin_enabled(struct net_device *dev)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	return IPOIB_CM_SUPPORTED(dev->dev_addr) &&
 		test_bit(IPOIB_FLAG_ADMIN_CM, &priv->flags);
 }
 
 static inline int ipoib_cm_enabled(struct net_device *dev, u8 *hwaddr)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	return IPOIB_CM_SUPPORTED(hwaddr) &&
 		test_bit(IPOIB_FLAG_ADMIN_CM, &priv->flags);
 }
@@ -636,13 +644,13 @@ static inline void ipoib_cm_set(struct ipoib_neigh *neigh, struct ipoib_cm_tx *t
 
 static inline int ipoib_cm_has_srq(struct net_device *dev)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	return !!priv->cm.srq;
 }
 
 static inline unsigned int ipoib_cm_max_mtu(struct net_device *dev)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	return priv->cm.max_cm_mtu;
 }
 
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_cm.c b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
index 53d69d7d9ad4..9593930454ef 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_cm.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
@@ -91,7 +91,7 @@ static void ipoib_cm_dma_unmap_rx(struct ipoib_dev_priv *priv, int frags,
 
 static int ipoib_cm_post_receive_srq(struct net_device *dev, int id)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	struct ib_recv_wr *bad_wr;
 	int i, ret;
 
@@ -117,7 +117,7 @@ static int ipoib_cm_post_receive_nonsrq(struct net_device *dev,
 					struct ib_recv_wr *wr,
 					struct ib_sge *sge, int id)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	struct ib_recv_wr *bad_wr;
 	int i, ret;
 
@@ -144,7 +144,7 @@ static struct sk_buff *ipoib_cm_alloc_rx_skb(struct net_device *dev,
 					     u64 mapping[IPOIB_CM_RX_SG],
 					     gfp_t gfp)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	struct sk_buff *skb;
 	int i;
 
@@ -195,7 +195,7 @@ static struct sk_buff *ipoib_cm_alloc_rx_skb(struct net_device *dev,
 static void ipoib_cm_free_rx_ring(struct net_device *dev,
 				  struct ipoib_cm_rx_buf *rx_ring)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	int i;
 
 	for (i = 0; i < ipoib_recvq_size; ++i)
@@ -234,7 +234,7 @@ static void ipoib_cm_start_rx_drain(struct ipoib_dev_priv *priv)
 static void ipoib_cm_rx_event_handler(struct ib_event *event, void *ctx)
 {
 	struct ipoib_cm_rx *p = ctx;
-	struct ipoib_dev_priv *priv = netdev_priv(p->dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(p->dev);
 	unsigned long flags;
 
 	if (event->event != IB_EVENT_QP_LAST_WQE_REACHED)
@@ -250,7 +250,7 @@ static void ipoib_cm_rx_event_handler(struct ib_event *event, void *ctx)
 static struct ib_qp *ipoib_cm_create_rx_qp(struct net_device *dev,
 					   struct ipoib_cm_rx *p)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	struct ib_qp_init_attr attr = {
 		.event_handler = ipoib_cm_rx_event_handler,
 		.send_cq = priv->recv_cq, /* For drain WR */
@@ -275,7 +275,7 @@ static int ipoib_cm_modify_rx_qp(struct net_device *dev,
 				 struct ib_cm_id *cm_id, struct ib_qp *qp,
 				 unsigned psn)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	struct ib_qp_attr qp_attr;
 	int qp_attr_mask, ret;
 
@@ -330,7 +330,7 @@ static void ipoib_cm_init_rx_wr(struct net_device *dev,
 				struct ib_recv_wr *wr,
 				struct ib_sge *sge)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	int i;
 
 	for (i = 0; i < priv->cm.num_frags; ++i)
@@ -348,7 +348,7 @@ static void ipoib_cm_init_rx_wr(struct net_device *dev,
 static int ipoib_cm_nonsrq_init_rx(struct net_device *dev, struct ib_cm_id *cm_id,
 				   struct ipoib_cm_rx *rx)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	struct {
 		struct ib_recv_wr wr;
 		struct ib_sge sge[IPOIB_CM_RX_SG];
@@ -419,7 +419,7 @@ static int ipoib_cm_send_rep(struct net_device *dev, struct ib_cm_id *cm_id,
 			     struct ib_qp *qp, struct ib_cm_req_event_param *req,
 			     unsigned psn)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	struct ipoib_cm_data data = {};
 	struct ib_cm_rep_param rep = {};
 
@@ -439,7 +439,7 @@ static int ipoib_cm_send_rep(struct net_device *dev, struct ib_cm_id *cm_id,
 static int ipoib_cm_req_handler(struct ib_cm_id *cm_id, struct ib_cm_event *event)
 {
 	struct net_device *dev = cm_id->context;
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	struct ipoib_cm_rx *p;
 	unsigned psn;
 	int ret;
@@ -512,7 +512,7 @@ static int ipoib_cm_rx_handler(struct ib_cm_id *cm_id,
 		/* Fall through */
 	case IB_CM_REJ_RECEIVED:
 		p = cm_id->context;
-		priv = netdev_priv(p->dev);
+		priv = ipoib_priv(p->dev);
 		if (ib_modify_qp(p->qp, &ipoib_cm_err_attr, IB_QP_STATE))
 			ipoib_warn(priv, "unable to move qp to error state\n");
 		/* Fall through */
@@ -556,7 +556,7 @@ static void skb_put_frags(struct sk_buff *skb, unsigned int hdr_space,
 
 void ipoib_cm_handle_rx_wc(struct net_device *dev, struct ib_wc *wc)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	struct ipoib_cm_rx_buf *rx_ring;
 	unsigned int wr_id = wc->wr_id & ~(IPOIB_OP_CM | IPOIB_OP_RECV);
 	struct sk_buff *skb, *newskb;
@@ -705,7 +705,7 @@ static inline int post_send(struct ipoib_dev_priv *priv,
 
 void ipoib_cm_send(struct net_device *dev, struct sk_buff *skb, struct ipoib_cm_tx *tx)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	struct ipoib_tx_buf *tx_req;
 	int rc;
 	unsigned usable_sge = tx->max_send_sge - !!skb_headlen(skb);
@@ -783,7 +783,7 @@ void ipoib_cm_send(struct net_device *dev, struct sk_buff *skb, struct ipoib_cm_
 
 void ipoib_cm_handle_tx_wc(struct net_device *dev, struct ib_wc *wc)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	struct ipoib_cm_tx *tx = wc->qp->qp_context;
 	unsigned int wr_id = wc->wr_id & ~IPOIB_OP_CM;
 	struct ipoib_tx_buf *tx_req;
@@ -852,7 +852,7 @@ void ipoib_cm_handle_tx_wc(struct net_device *dev, struct ib_wc *wc)
 
 int ipoib_cm_dev_open(struct net_device *dev)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	int ret;
 
 	if (!IPOIB_CM_SUPPORTED(dev->dev_addr))
@@ -884,7 +884,7 @@ int ipoib_cm_dev_open(struct net_device *dev)
 
 static void ipoib_cm_free_rx_reap_list(struct net_device *dev)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	struct ipoib_cm_rx *rx, *n;
 	LIST_HEAD(list);
 
@@ -907,7 +907,7 @@ static void ipoib_cm_free_rx_reap_list(struct net_device *dev)
 
 void ipoib_cm_dev_stop(struct net_device *dev)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	struct ipoib_cm_rx *p;
 	unsigned long begin;
 	int ret;
@@ -966,7 +966,7 @@ void ipoib_cm_dev_stop(struct net_device *dev)
 static int ipoib_cm_rep_handler(struct ib_cm_id *cm_id, struct ib_cm_event *event)
 {
 	struct ipoib_cm_tx *p = cm_id->context;
-	struct ipoib_dev_priv *priv = netdev_priv(p->dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(p->dev);
 	struct ipoib_cm_data *data = event->private_data;
 	struct sk_buff_head skqueue;
 	struct ib_qp_attr qp_attr;
@@ -1034,7 +1034,7 @@ static int ipoib_cm_rep_handler(struct ib_cm_id *cm_id, struct ib_cm_event *even
 
 static struct ib_qp *ipoib_cm_create_tx_qp(struct net_device *dev, struct ipoib_cm_tx *tx)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	struct ib_qp_init_attr attr = {
 		.send_cq		= priv->recv_cq,
 		.recv_cq		= priv->recv_cq,
@@ -1067,7 +1067,7 @@ static int ipoib_cm_send_req(struct net_device *dev,
 			     u32 qpn,
 			     struct ib_sa_path_rec *pathrec)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	struct ipoib_cm_data data = {};
 	struct ib_cm_req_param req = {};
 
@@ -1102,7 +1102,7 @@ static int ipoib_cm_send_req(struct net_device *dev,
 static int ipoib_cm_modify_tx_init(struct net_device *dev,
 				  struct ib_cm_id *cm_id, struct ib_qp *qp)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	struct ib_qp_attr qp_attr;
 	int qp_attr_mask, ret;
 	ret = ib_find_pkey(priv->ca, priv->port, priv->pkey, &qp_attr.pkey_index);
@@ -1127,7 +1127,7 @@ static int ipoib_cm_modify_tx_init(struct net_device *dev,
 static int ipoib_cm_tx_init(struct ipoib_cm_tx *p, u32 qpn,
 			    struct ib_sa_path_rec *pathrec)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(p->dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(p->dev);
 	int ret;
 
 	p->tx_ring = __vmalloc(ipoib_sendq_size * sizeof *p->tx_ring,
@@ -1184,7 +1184,7 @@ static int ipoib_cm_tx_init(struct ipoib_cm_tx *p, u32 qpn,
 
 static void ipoib_cm_tx_destroy(struct ipoib_cm_tx *p)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(p->dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(p->dev);
 	struct ipoib_tx_buf *tx_req;
 	unsigned long begin;
 
@@ -1234,7 +1234,7 @@ static int ipoib_cm_tx_handler(struct ib_cm_id *cm_id,
 			       struct ib_cm_event *event)
 {
 	struct ipoib_cm_tx *tx = cm_id->context;
-	struct ipoib_dev_priv *priv = netdev_priv(tx->dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(tx->dev);
 	struct net_device *dev = priv->dev;
 	struct ipoib_neigh *neigh;
 	unsigned long flags;
@@ -1285,7 +1285,7 @@ static int ipoib_cm_tx_handler(struct ib_cm_id *cm_id,
 struct ipoib_cm_tx *ipoib_cm_create_tx(struct net_device *dev, struct ipoib_path *path,
 				       struct ipoib_neigh *neigh)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	struct ipoib_cm_tx *tx;
 
 	tx = kzalloc(sizeof *tx, GFP_ATOMIC);
@@ -1304,7 +1304,7 @@ struct ipoib_cm_tx *ipoib_cm_create_tx(struct net_device *dev, struct ipoib_path
 
 void ipoib_cm_destroy_tx(struct ipoib_cm_tx *tx)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(tx->dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(tx->dev);
 	unsigned long flags;
 	if (test_and_clear_bit(IPOIB_FLAG_INITIALIZED, &tx->flags)) {
 		spin_lock_irqsave(&priv->lock, flags);
@@ -1439,7 +1439,7 @@ static void ipoib_cm_skb_reap(struct work_struct *work)
 void ipoib_cm_skb_too_long(struct net_device *dev, struct sk_buff *skb,
 			   unsigned int mtu)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	int e = skb_queue_empty(&priv->cm.skb_queue);
 
 	if (skb_dst(skb))
@@ -1488,7 +1488,7 @@ static void ipoib_cm_stale_task(struct work_struct *work)
 static ssize_t show_mode(struct device *d, struct device_attribute *attr,
 			 char *buf)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(to_net_dev(d));
+	struct ipoib_dev_priv *priv = ipoib_priv(to_net_dev(d));
 
 	if (test_bit(IPOIB_FLAG_ADMIN_CM, &priv->flags))
 		return sprintf(buf, "connected\n");
@@ -1501,7 +1501,7 @@ static ssize_t set_mode(struct device *d, struct device_attribute *attr,
 {
 	struct net_device *dev = to_net_dev(d);
 	int ret;
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 
 	if (test_bit(IPOIB_FLAG_GOING_DOWN, &priv->flags))
 		return -EPERM;
@@ -1530,7 +1530,7 @@ int ipoib_cm_add_mode_attr(struct net_device *dev)
 
 static void ipoib_cm_create_srq(struct net_device *dev, int max_sge)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	struct ib_srq_init_attr srq_init_attr = {
 		.srq_type = IB_SRQT_BASIC,
 		.attr = {
@@ -1559,7 +1559,7 @@ static void ipoib_cm_create_srq(struct net_device *dev, int max_sge)
 
 int ipoib_cm_dev_init(struct net_device *dev)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	int max_srq_sge, i;
 
 	INIT_LIST_HEAD(&priv->cm.passive_ids);
@@ -1620,7 +1620,7 @@ int ipoib_cm_dev_init(struct net_device *dev)
 
 void ipoib_cm_dev_cleanup(struct net_device *dev)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	int ret;
 
 	if (!priv->cm.srq)
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_ethtool.c b/drivers/infiniband/ulp/ipoib/ipoib_ethtool.c
index 7b6d40ff1acf..32ad805fc721 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_ethtool.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_ethtool.c
@@ -60,7 +60,7 @@ struct ipoib_stats {
 static void ipoib_get_drvinfo(struct net_device *netdev,
 			      struct ethtool_drvinfo *drvinfo)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(netdev);
+	struct ipoib_dev_priv *priv = ipoib_priv(netdev);
 
 	ib_get_device_fw_str(priv->ca, drvinfo->fw_version,
 			     sizeof(drvinfo->fw_version));
@@ -77,7 +77,7 @@ static void ipoib_get_drvinfo(struct net_device *netdev,
 static int ipoib_get_coalesce(struct net_device *dev,
 			      struct ethtool_coalesce *coal)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 
 	coal->rx_coalesce_usecs = priv->ethtool.coalesce_usecs;
 	coal->rx_max_coalesced_frames = priv->ethtool.max_coalesced_frames;
@@ -88,7 +88,7 @@ static int ipoib_get_coalesce(struct net_device *dev,
 static int ipoib_set_coalesce(struct net_device *dev,
 			      struct ethtool_coalesce *coal)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	int ret;
 
 	/*
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_fs.c b/drivers/infiniband/ulp/ipoib/ipoib_fs.c
index 6bd5740e2691..6e73450241bf 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_fs.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_fs.c
@@ -261,7 +261,7 @@ static int ipoib_path_open(struct inode *inode, struct file *file)
 
 void ipoib_create_debug_files(struct net_device *dev)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	char name[IFNAMSIZ + sizeof "_path"];
 
 	snprintf(name, sizeof name, "%s_mcg", dev->name);
@@ -279,7 +279,7 @@ void ipoib_create_debug_files(struct net_device *dev)
 
 void ipoib_delete_debug_files(struct net_device *dev)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 
 	debugfs_remove(priv->mcg_dentry);
 	debugfs_remove(priv->path_dentry);
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_ib.c b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
index dd5fb2964e63..b9ae9c9046d0 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_ib.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
@@ -72,7 +72,7 @@ struct ipoib_ah *ipoib_create_ah(struct net_device *dev,
 		ah = (struct ipoib_ah *)vah;
 	} else {
 		ah->ah = vah;
-		ipoib_dbg(netdev_priv(dev), "Created ah %p\n", ah->ah);
+		ipoib_dbg(ipoib_priv(dev), "Created ah %p\n", ah->ah);
 	}
 
 	return ah;
@@ -81,7 +81,7 @@ struct ipoib_ah *ipoib_create_ah(struct net_device *dev,
 void ipoib_free_ah(struct kref *kref)
 {
 	struct ipoib_ah *ah = container_of(kref, struct ipoib_ah, ref);
-	struct ipoib_dev_priv *priv = netdev_priv(ah->dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(ah->dev);
 
 	unsigned long flags;
 
@@ -100,7 +100,7 @@ static void ipoib_ud_dma_unmap_rx(struct ipoib_dev_priv *priv,
 
 static int ipoib_ib_post_receive(struct net_device *dev, int id)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	struct ib_recv_wr *bad_wr;
 	int ret;
 
@@ -122,7 +122,7 @@ static int ipoib_ib_post_receive(struct net_device *dev, int id)
 
 static struct sk_buff *ipoib_alloc_rx_skb(struct net_device *dev, int id)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	struct sk_buff *skb;
 	int buf_size;
 	u64 *mapping;
@@ -154,7 +154,7 @@ static struct sk_buff *ipoib_alloc_rx_skb(struct net_device *dev, int id)
 
 static int ipoib_ib_post_receives(struct net_device *dev)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	int i;
 
 	for (i = 0; i < ipoib_recvq_size; ++i) {
@@ -173,7 +173,7 @@ static int ipoib_ib_post_receives(struct net_device *dev)
 
 static void ipoib_ib_handle_rx_wc(struct net_device *dev, struct ib_wc *wc)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	unsigned int wr_id = wc->wr_id & ~IPOIB_OP_RECV;
 	struct sk_buff *skb;
 	u64 mapping[IPOIB_UD_RX_SG];
@@ -382,7 +382,7 @@ static void ipoib_qp_state_validate_work(struct work_struct *work)
 
 static void ipoib_ib_handle_tx_wc(struct net_device *dev, struct ib_wc *wc)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	unsigned int wr_id = wc->wr_id;
 	struct ipoib_tx_buf *tx_req;
 
@@ -486,14 +486,14 @@ int ipoib_poll(struct napi_struct *napi, int budget)
 void ipoib_ib_completion(struct ib_cq *cq, void *dev_ptr)
 {
 	struct net_device *dev = dev_ptr;
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 
 	napi_schedule(&priv->napi);
 }
 
 static void drain_tx_cq(struct net_device *dev)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 
 	netif_tx_lock(dev);
 	while (poll_tx(priv))
@@ -507,7 +507,7 @@ static void drain_tx_cq(struct net_device *dev)
 
 void ipoib_send_comp_handler(struct ib_cq *cq, void *dev_ptr)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev_ptr);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev_ptr);
 
 	mod_timer(&priv->poll_timer, jiffies);
 }
@@ -539,9 +539,9 @@ static inline int post_send(struct ipoib_dev_priv *priv,
 }
 
 void ipoib_send(struct net_device *dev, struct sk_buff *skb,
-		struct ipoib_ah *address, u32 dqpn)
+		struct ipoib_ah *address, u32 dqpn, u32 dqkey)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	struct ipoib_tx_buf *tx_req;
 	int hlen, rc;
 	void *phead;
@@ -644,7 +644,7 @@ void ipoib_send(struct net_device *dev, struct sk_buff *skb,
 
 static void __ipoib_reap_ah(struct net_device *dev)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	struct ipoib_ah *ah, *tah;
 	LIST_HEAD(remove_list);
 	unsigned long flags;
@@ -678,7 +678,7 @@ void ipoib_reap_ah(struct work_struct *work)
 
 static void ipoib_flush_ah(struct net_device *dev)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 
 	cancel_delayed_work(&priv->ah_reap_task);
 	flush_workqueue(priv->wq);
@@ -687,7 +687,7 @@ static void ipoib_flush_ah(struct net_device *dev)
 
 static void ipoib_stop_ah(struct net_device *dev)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 
 	set_bit(IPOIB_STOP_REAPER, &priv->flags);
 	ipoib_flush_ah(dev);
@@ -695,7 +695,7 @@ static void ipoib_stop_ah(struct net_device *dev)
 
 static int recvs_pending(struct net_device *dev)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	int pending = 0;
 	int i;
 
@@ -708,7 +708,7 @@ static int recvs_pending(struct net_device *dev)
 
 int ipoib_ib_dev_stop_default(struct net_device *dev)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	struct ib_qp_attr qp_attr;
 	unsigned long begin;
 	struct ipoib_tx_buf *tx_req;
@@ -783,7 +783,9 @@ int ipoib_ib_dev_stop_default(struct net_device *dev)
 
 int ipoib_ib_dev_stop(struct net_device *dev)
 {
-	ipoib_ib_dev_stop_default(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
+
+	priv->rn_ops->ndo_stop(dev);
 
 	ipoib_flush_ah(dev);
 
@@ -797,7 +799,7 @@ void ipoib_ib_tx_timer_func(unsigned long ctx)
 
 int ipoib_ib_dev_open_default(struct net_device *dev)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	int ret;
 
 	ret = ipoib_init_qp(dev);
@@ -831,7 +833,7 @@ int ipoib_ib_dev_open_default(struct net_device *dev)
 
 int ipoib_ib_dev_open(struct net_device *dev)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 
 	ipoib_pkey_dev_check_presence(dev);
 
@@ -845,7 +847,7 @@ int ipoib_ib_dev_open(struct net_device *dev)
 	queue_delayed_work(priv->wq, &priv->ah_reap_task,
 			   round_jiffies_relative(HZ));
 
-	if (ipoib_ib_dev_open_default(dev)) {
+	if (priv->rn_ops->ndo_open(dev)) {
 		pr_warn("%s: Failed to open dev\n", dev->name);
 		goto stop_ah_reap;
 	}
@@ -860,7 +862,7 @@ int ipoib_ib_dev_open(struct net_device *dev)
 
 void ipoib_pkey_dev_check_presence(struct net_device *dev)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 
 	if (!(priv->pkey & 0x7fff) ||
 	    ib_find_pkey(priv->ca, priv->port, priv->pkey,
@@ -872,7 +874,7 @@ void ipoib_pkey_dev_check_presence(struct net_device *dev)
 
 void ipoib_ib_dev_up(struct net_device *dev)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 
 	ipoib_pkey_dev_check_presence(dev);
 
@@ -888,7 +890,7 @@ void ipoib_ib_dev_up(struct net_device *dev)
 
 void ipoib_ib_dev_down(struct net_device *dev)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 
 	ipoib_dbg(priv, "downing ib_dev\n");
 
@@ -903,7 +905,7 @@ void ipoib_ib_dev_down(struct net_device *dev)
 
 void ipoib_drain_cq(struct net_device *dev)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	int i, n;
 
 	/*
@@ -1217,7 +1219,8 @@ void ipoib_ib_dev_flush_heavy(struct work_struct *work)
 
 void ipoib_ib_dev_cleanup(struct net_device *dev)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
+	struct rdma_netdev *rn = netdev_priv(dev);
 
 	ipoib_dbg(priv, "cleaning up ib_dev\n");
 	/*
@@ -1239,7 +1242,7 @@ void ipoib_ib_dev_cleanup(struct net_device *dev)
 
 	clear_bit(IPOIB_PKEY_ASSIGNED, &priv->flags);
 
-	ipoib_dev_uninit_default(dev);
+	rn->ib_dev_cleanup(dev, priv->ca);
 
 	if (priv->pd) {
 		ib_dealloc_pd(priv->pd);
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index be8dcea252f9..605f5673a6ca 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -110,7 +110,7 @@ static struct net_device *ipoib_get_net_dev_by_params(
 
 int ipoib_open(struct net_device *dev)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 
 	ipoib_dbg(priv, "bringing up interface\n");
 
@@ -157,7 +157,7 @@ int ipoib_open(struct net_device *dev)
 
 static int ipoib_stop(struct net_device *dev)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 
 	ipoib_dbg(priv, "stopping interface\n");
 
@@ -166,7 +166,7 @@ static int ipoib_stop(struct net_device *dev)
 	netif_stop_queue(dev);
 
 	ipoib_ib_dev_down(dev);
-	ipoib_ib_dev_stop_default(dev);
+	ipoib_ib_dev_stop(dev);
 
 	if (!test_bit(IPOIB_FLAG_SUBINTERFACE, &priv->flags)) {
 		struct ipoib_dev_priv *cpriv;
@@ -195,7 +195,7 @@ static void ipoib_uninit(struct net_device *dev)
 
 static netdev_features_t ipoib_fix_features(struct net_device *dev, netdev_features_t features)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 
 	if (test_bit(IPOIB_FLAG_ADMIN_CM, &priv->flags))
 		features &= ~(NETIF_F_IP_CSUM | NETIF_F_TSO);
@@ -205,7 +205,7 @@ static netdev_features_t ipoib_fix_features(struct net_device *dev, netdev_featu
 
 static int ipoib_change_mtu(struct net_device *dev, int new_mtu)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 
 	/* dev->mtu > 2K ==> connected mode */
 	if (ipoib_cm_admin_enabled(dev)) {
@@ -468,7 +468,7 @@ static struct net_device *ipoib_get_net_dev_by_params(
 
 int ipoib_set_mode(struct net_device *dev, const char *buf)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 
 	if ((test_bit(IPOIB_FLAG_ADMIN_CM, &priv->flags) &&
 	     !strcmp(buf, "connected\n")) ||
@@ -505,7 +505,7 @@ int ipoib_set_mode(struct net_device *dev, const char *buf)
 
 struct ipoib_path *__path_find(struct net_device *dev, void *gid)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	struct rb_node *n = priv->path_tree.rb_node;
 	struct ipoib_path *path;
 	int ret;
@@ -529,7 +529,7 @@ struct ipoib_path *__path_find(struct net_device *dev, void *gid)
 
 static int __path_add(struct net_device *dev, struct ipoib_path *path)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	struct rb_node **n = &priv->path_tree.rb_node;
 	struct rb_node *pn = NULL;
 	struct ipoib_path *tpath;
@@ -564,7 +564,7 @@ static void path_free(struct net_device *dev, struct ipoib_path *path)
 	while ((skb = __skb_dequeue(&path->queue)))
 		dev_kfree_skb_irq(skb);
 
-	ipoib_dbg(netdev_priv(dev), "path_free\n");
+	ipoib_dbg(ipoib_priv(dev), "path_free\n");
 
 	/* remove all neigh connected to this path */
 	ipoib_del_neighs_by_gid(dev, path->pathrec.dgid.raw);
@@ -598,7 +598,7 @@ struct ipoib_path_iter *ipoib_path_iter_init(struct net_device *dev)
 
 int ipoib_path_iter_next(struct ipoib_path_iter *iter)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(iter->dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(iter->dev);
 	struct rb_node *n;
 	struct ipoib_path *path;
 	int ret = 1;
@@ -635,7 +635,7 @@ void ipoib_path_iter_read(struct ipoib_path_iter *iter,
 
 void ipoib_mark_paths_invalid(struct net_device *dev)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	struct ipoib_path *path, *tp;
 
 	spin_lock_irq(&priv->lock);
@@ -731,7 +731,7 @@ static void push_pseudo_header(struct sk_buff *skb, const char *daddr)
 
 void ipoib_flush_paths(struct net_device *dev)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	struct ipoib_path *path, *tp;
 	LIST_HEAD(remove_list);
 	unsigned long flags;
@@ -765,7 +765,7 @@ static void path_rec_completion(int status,
 {
 	struct ipoib_path *path = path_ptr;
 	struct net_device *dev = path->dev;
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	struct ipoib_ah *ah = NULL;
 	struct ipoib_ah *old_ah = NULL;
 	struct ipoib_neigh *neigh, *tn;
@@ -858,7 +858,7 @@ static void path_rec_completion(int status,
 
 static struct ipoib_path *path_rec_create(struct net_device *dev, void *gid)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	struct ipoib_path *path;
 
 	if (!priv->broadcast)
@@ -886,7 +886,7 @@ static struct ipoib_path *path_rec_create(struct net_device *dev, void *gid)
 static int path_rec_start(struct net_device *dev,
 			  struct ipoib_path *path)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 
 	ipoib_dbg(priv, "Start path record lookup for %pI6\n",
 		  path->pathrec.dgid.raw);
@@ -917,7 +917,8 @@ static int path_rec_start(struct net_device *dev,
 static void neigh_add_path(struct sk_buff *skb, u8 *daddr,
 			   struct net_device *dev)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
+	struct rdma_netdev *rn = netdev_priv(dev);
 	struct ipoib_path *path;
 	struct ipoib_neigh *neigh;
 	unsigned long flags;
@@ -964,7 +965,9 @@ static void neigh_add_path(struct sk_buff *skb, u8 *daddr,
 			}
 		} else {
 			spin_unlock_irqrestore(&priv->lock, flags);
-			ipoib_send(dev, skb, path->ah, IPOIB_QPN(daddr));
+			rn->send(dev, skb, path->ah,
+						    IPOIB_QPN(daddr),
+						    priv->tx_wr.remote_qkey);
 			ipoib_neigh_put(neigh);
 			return;
 		}
@@ -998,7 +1001,8 @@ static void neigh_add_path(struct sk_buff *skb, u8 *daddr,
 static void unicast_arp_send(struct sk_buff *skb, struct net_device *dev,
 			     struct ipoib_pseudo_header *phdr)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
+	struct rdma_netdev *rn = netdev_priv(dev);
 	struct ipoib_path *path;
 	unsigned long flags;
 
@@ -1042,7 +1046,9 @@ static void unicast_arp_send(struct sk_buff *skb, struct net_device *dev,
 			  be16_to_cpu(path->pathrec.dlid));
 
 		spin_unlock_irqrestore(&priv->lock, flags);
-		ipoib_send(dev, skb, path->ah, IPOIB_QPN(phdr->hwaddr));
+		rn->send(dev, skb, path->ah,
+			 IPOIB_QPN(phdr->hwaddr),
+			 priv->tx_wr.remote_qkey);
 		return;
 	} else if ((path->query || !path_rec_start(dev, path)) &&
 		   skb_queue_len(&path->queue) < IPOIB_MAX_PATH_REC_QUEUE) {
@@ -1058,7 +1064,8 @@ static void unicast_arp_send(struct sk_buff *skb, struct net_device *dev,
 
 static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
+	struct rdma_netdev *rn = netdev_priv(dev);
 	struct ipoib_neigh *neigh;
 	struct ipoib_pseudo_header *phdr;
 	struct ipoib_header *header;
@@ -1122,7 +1129,9 @@ static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			goto unref;
 		}
 	} else if (neigh->ah) {
-		ipoib_send(dev, skb, neigh->ah, IPOIB_QPN(phdr->hwaddr));
+		rn->send(dev, skb, neigh->ah,
+			 IPOIB_QPN(phdr->hwaddr),
+			 priv->tx_wr.remote_qkey);
 		goto unref;
 	}
 
@@ -1144,7 +1153,7 @@ static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 static void ipoib_timeout(struct net_device *dev)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 
 	ipoib_warn(priv, "transmit timeout: latency %d msecs\n",
 		   jiffies_to_msecs(jiffies - dev_trans_start(dev)));
@@ -1178,7 +1187,7 @@ static int ipoib_hard_header(struct sk_buff *skb,
 
 static void ipoib_set_mcast_list(struct net_device *dev)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 
 	if (!test_bit(IPOIB_FLAG_OPER_UP, &priv->flags)) {
 		ipoib_dbg(priv, "IPOIB_FLAG_OPER_UP not set");
@@ -1190,7 +1199,7 @@ static void ipoib_set_mcast_list(struct net_device *dev)
 
 static int ipoib_get_iflink(const struct net_device *dev)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 
 	/* parent interface */
 	if (!test_bit(IPOIB_FLAG_SUBINTERFACE, &priv->flags))
@@ -1218,7 +1227,7 @@ static u32 ipoib_addr_hash(struct ipoib_neigh_hash *htbl, u8 *daddr)
 
 struct ipoib_neigh *ipoib_neigh_get(struct net_device *dev, u8 *daddr)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	struct ipoib_neigh_table *ntbl = &priv->ntbl;
 	struct ipoib_neigh_hash *htbl;
 	struct ipoib_neigh *neigh = NULL;
@@ -1347,7 +1356,7 @@ static struct ipoib_neigh *ipoib_neigh_ctor(u8 *daddr,
 struct ipoib_neigh *ipoib_neigh_alloc(u8 *daddr,
 				      struct net_device *dev)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	struct ipoib_neigh_table *ntbl = &priv->ntbl;
 	struct ipoib_neigh_hash *htbl;
 	struct ipoib_neigh *neigh;
@@ -1404,7 +1413,7 @@ void ipoib_neigh_dtor(struct ipoib_neigh *neigh)
 {
 	/* neigh reference count was dropprd to zero */
 	struct net_device *dev = neigh->dev;
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	struct sk_buff *skb;
 	if (neigh->ah)
 		ipoib_put_ah(neigh->ah);
@@ -1414,7 +1423,7 @@ void ipoib_neigh_dtor(struct ipoib_neigh *neigh)
 	}
 	if (ipoib_cm_get(neigh))
 		ipoib_cm_destroy_tx(ipoib_cm_get(neigh));
-	ipoib_dbg(netdev_priv(dev),
+	ipoib_dbg(ipoib_priv(dev),
 		  "neigh free for %06x %pI6\n",
 		  IPOIB_QPN(neigh->daddr),
 		  neigh->daddr + 4);
@@ -1436,7 +1445,7 @@ static void ipoib_neigh_reclaim(struct rcu_head *rp)
 void ipoib_neigh_free(struct ipoib_neigh *neigh)
 {
 	struct net_device *dev = neigh->dev;
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	struct ipoib_neigh_table *ntbl = &priv->ntbl;
 	struct ipoib_neigh_hash *htbl;
 	struct ipoib_neigh __rcu **np;
@@ -1519,7 +1528,7 @@ static void neigh_hash_free_rcu(struct rcu_head *head)
 
 void ipoib_del_neighs_by_gid(struct net_device *dev, u8 *gid)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	struct ipoib_neigh_table *ntbl = &priv->ntbl;
 	struct ipoib_neigh_hash *htbl;
 	unsigned long flags;
@@ -1605,7 +1614,7 @@ static void ipoib_flush_neighs(struct ipoib_dev_priv *priv)
 
 static void ipoib_neigh_hash_uninit(struct net_device *dev)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	int stopped;
 
 	ipoib_dbg(priv, "ipoib_neigh_hash_uninit\n");
@@ -1622,9 +1631,9 @@ static void ipoib_neigh_hash_uninit(struct net_device *dev)
 	wait_for_completion(&priv->ntbl.deleted);
 }
 
-void ipoib_dev_uninit_default(struct net_device *dev)
+void ipoib_dev_uninit_default(struct net_device *dev, struct ib_device *hca)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 
 	ipoib_transport_dev_cleanup(dev);
 
@@ -1637,10 +1646,12 @@ void ipoib_dev_uninit_default(struct net_device *dev)
 	priv->tx_ring = NULL;
 }
 
-static int ipoib_dev_init_default(struct net_device *dev, struct ib_device *ca,
-				  int port)
+static int ipoib_dev_init_default(struct net_device *dev,
+				  struct ib_device *hca, int *qp_num)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
+
+	netif_napi_add(dev, &priv->napi, ipoib_poll, NAPI_POLL_WEIGHT);
 
 	/* Allocate RX/TX "rings" to hold queued skbs */
 	priv->rx_ring =	kzalloc(ipoib_recvq_size * sizeof *priv->rx_ring,
@@ -1651,14 +1662,14 @@ static int ipoib_dev_init_default(struct net_device *dev, struct ib_device *ca,
 	priv->tx_ring = vzalloc(ipoib_sendq_size * sizeof *priv->tx_ring);
 	if (!priv->tx_ring) {
 		printk(KERN_WARNING "%s: failed to allocate TX ring (%d entries)\n",
-		       ca->name, ipoib_sendq_size);
+		       priv->ca->name, ipoib_sendq_size);
 		goto out_rx_ring_cleanup;
 	}
 
 	/* priv->tx_head, tx_tail & tx_outstanding are already 0 */
 
-	if (ipoib_transport_dev_init(dev, ca)) {
-		pr_warn("%s: ipoib_transport_dev_init failed\n", ca->name);
+	if (ipoib_transport_dev_init(dev, priv->ca)) {
+		pr_warn("%s: ipoib_transport_dev_init failed\n", priv->ca->name);
 		goto out_tx_ring_cleanup;
 	}
 
@@ -1679,7 +1690,8 @@ static int ipoib_dev_init_default(struct net_device *dev, struct ib_device *ca,
 
 int ipoib_dev_init(struct net_device *dev, struct ib_device *ca, int port)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
+	struct rdma_netdev *rn = netdev_priv(dev);
 	int ret = -ENOMEM;
 
 	priv->ca = ca;
@@ -1703,16 +1715,16 @@ int ipoib_dev_init(struct net_device *dev, struct ib_device *ca, int port)
 		goto clean_wq;
 	}
 
-	ret = ipoib_dev_init_default(dev, ca, port);
+	ret = rn->ib_dev_init(dev, ca, &priv->qp_num);
 	if (ret) {
 		pr_warn("%s failed to init HW resource\n", dev->name);
 		goto out_free_pd;
 	}
 
 	/* after qp created set dev address */
-	priv->dev->dev_addr[1] = (priv->qp->qp_num >> 16) & 0xff;
-	priv->dev->dev_addr[2] = (priv->qp->qp_num >>  8) & 0xff;
-	priv->dev->dev_addr[3] = (priv->qp->qp_num) & 0xff;
+	priv->dev->dev_addr[1] = (priv->qp_num >> 16) & 0xff;
+	priv->dev->dev_addr[2] = (priv->qp_num >>  8) & 0xff;
+	priv->dev->dev_addr[3] = (priv->qp_num) & 0xff;
 
 	if (ipoib_neigh_hash_init(priv) < 0) {
 		pr_warn("%s failed to init neigh hash\n", dev->name);
@@ -1750,7 +1762,7 @@ int ipoib_dev_init(struct net_device *dev, struct ib_device *ca, int port)
 
 void ipoib_dev_cleanup(struct net_device *dev)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev), *cpriv, *tcpriv;
+	struct ipoib_dev_priv *priv = ipoib_priv(dev), *cpriv, *tcpriv;
 	LIST_HEAD(head);
 
 	ASSERT_RTNL();
@@ -1780,7 +1792,7 @@ void ipoib_dev_cleanup(struct net_device *dev)
 
 static int ipoib_set_vf_link_state(struct net_device *dev, int vf, int link_state)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 
 	return ib_set_vf_link_state(priv->ca, vf, priv->port, link_state);
 }
@@ -1788,7 +1800,7 @@ static int ipoib_set_vf_link_state(struct net_device *dev, int vf, int link_stat
 static int ipoib_get_vf_config(struct net_device *dev, int vf,
 			       struct ifla_vf_info *ivf)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	int err;
 
 	err = ib_get_vf_config(priv->ca, vf, priv->port, ivf);
@@ -1802,7 +1814,7 @@ static int ipoib_get_vf_config(struct net_device *dev, int vf,
 
 static int ipoib_set_vf_guid(struct net_device *dev, int vf, u64 guid, int type)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 
 	if (type != IFLA_VF_IB_NODE_GUID && type != IFLA_VF_IB_PORT_GUID)
 		return -EINVAL;
@@ -1813,7 +1825,7 @@ static int ipoib_set_vf_guid(struct net_device *dev, int vf, u64 guid, int type)
 static int ipoib_get_vf_stats(struct net_device *dev, int vf,
 			      struct ifla_vf_stats *vf_stats)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 
 	return ib_get_vf_stats(priv->ca, vf, priv->port, vf_stats);
 }
@@ -1851,21 +1863,12 @@ static int ipoib_get_vf_stats(struct net_device *dev, int vf,
 	.ndo_get_iflink		 = ipoib_get_iflink,
 };
 
-void ipoib_setup(struct net_device *dev)
+void ipoib_setup_common(struct net_device *dev)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
-
-	if (priv->hca_caps & IB_DEVICE_VIRTUAL_FUNCTION)
-		dev->netdev_ops	= &ipoib_netdev_ops_vf;
-	else
-		dev->netdev_ops	= &ipoib_netdev_ops_pf;
-
 	dev->header_ops		 = &ipoib_header_ops;
 
 	ipoib_set_ethtool_ops(dev);
 
-	netif_napi_add(dev, &priv->napi, ipoib_poll, NAPI_POLL_WEIGHT);
-
 	dev->watchdog_timeo	 = HZ;
 
 	dev->flags		|= IFF_BROADCAST | IFF_MULTICAST;
@@ -1879,11 +1882,14 @@ void ipoib_setup(struct net_device *dev)
 	netif_keep_dst(dev);
 
 	memcpy(dev->broadcast, ipv4_bcast_addr, INFINIBAND_ALEN);
+}
 
-	priv->dev = dev;
+void ipoib_build_priv(struct net_device *dev)
+{
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 
+	priv->dev = dev;
 	spin_lock_init(&priv->lock);
-
 	init_rwsem(&priv->vlan_rwsem);
 
 	INIT_LIST_HEAD(&priv->path_list);
@@ -1901,22 +1907,80 @@ void ipoib_setup(struct net_device *dev)
 	INIT_DELAYED_WORK(&priv->neigh_reap_task, ipoib_reap_neigh);
 }
 
-struct ipoib_dev_priv *ipoib_intf_alloc(const char *name)
+static const struct net_device_ops ipoib_netdev_default_pf = {
+	.ndo_open		 = ipoib_ib_dev_open_default,
+	.ndo_stop		 = ipoib_ib_dev_stop_default,
+};
+
+static struct net_device *ipoib_create_netdev_default(struct ib_device *hca,
+						      const char *name,
+						      void (*setup)(struct net_device *))
 {
 	struct net_device *dev;
+	struct rdma_netdev *rn;
 
-	dev = alloc_netdev((int)sizeof(struct ipoib_dev_priv), name,
-			   NET_NAME_UNKNOWN, ipoib_setup);
+	dev = alloc_netdev((int)sizeof(struct ipoib_rdma_netdev),
+			   name,
+			   NET_NAME_UNKNOWN, setup);
 	if (!dev)
 		return NULL;
 
-	return netdev_priv(dev);
+	rn = netdev_priv(dev);
+
+	rn->ib_dev_init = ipoib_dev_init_default;
+	rn->ib_dev_cleanup = ipoib_dev_uninit_default;
+	rn->send = ipoib_send;
+	rn->attach_mcast = ipoib_mcast_attach;
+	rn->detach_mcast = ipoib_mcast_detach;
+
+	dev->netdev_ops = &ipoib_netdev_default_pf;
+
+	return dev;
+}
+
+struct ipoib_dev_priv *ipoib_intf_alloc(struct ib_device *hca, u8 port,
+					const char *name)
+{
+	struct net_device *dev;
+	struct ipoib_dev_priv *priv;
+	struct rdma_netdev *rn;
+
+	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
+	if (!priv) {
+		pr_err("%s failed allocting priv\n", __func__);
+		return NULL;
+	}
+
+	if (!hca->alloc_rdma_netdev)
+		dev = ipoib_create_netdev_default(hca, name, ipoib_setup_common);
+	else
+		dev = hca->alloc_rdma_netdev(hca, port, RDMA_NETDEV_IPOIB,
+					     name, NET_NAME_UNKNOWN,
+					     ipoib_setup_common);
+	if (!dev) {
+		kfree(priv);
+		return NULL;
+	}
+
+	priv->rn_ops = dev->netdev_ops;
+
+	/* fixme : should be after the query_cap */
+	if (priv->hca_caps & IB_DEVICE_VIRTUAL_FUNCTION)
+		dev->netdev_ops	= &ipoib_netdev_ops_vf;
+	else
+		dev->netdev_ops	= &ipoib_netdev_ops_pf;
+
+	rn = netdev_priv(dev);
+	rn->clnt_priv = priv;
+	ipoib_build_priv(dev);
+
+	return priv;
 }
 
 static ssize_t show_pkey(struct device *dev,
 			 struct device_attribute *attr, char *buf)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(to_net_dev(dev));
+	struct ipoib_dev_priv *priv = ipoib_priv(to_net_dev(dev));
 
 	return sprintf(buf, "0x%04x\n", priv->pkey);
 }
@@ -1925,14 +1989,14 @@ static ssize_t show_pkey(struct device *dev,
 static ssize_t show_umcast(struct device *dev,
 			   struct device_attribute *attr, char *buf)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(to_net_dev(dev));
+	struct ipoib_dev_priv *priv = ipoib_priv(to_net_dev(dev));
 
 	return sprintf(buf, "%d\n", test_bit(IPOIB_FLAG_UMCAST, &priv->flags));
 }
 
 void ipoib_set_umcast(struct net_device *ndev, int umcast_val)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(ndev);
+	struct ipoib_dev_priv *priv = ipoib_priv(ndev);
 
 	if (umcast_val > 0) {
 		set_bit(IPOIB_FLAG_UMCAST, &priv->flags);
@@ -2005,7 +2069,7 @@ static int ipoib_check_lladdr(struct net_device *dev,
 
 static int ipoib_set_mac(struct net_device *dev, void *addr)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	struct sockaddr_storage *ss = addr;
 	int ret;
 
@@ -2094,7 +2158,7 @@ static struct net_device *ipoib_add_port(const char *format,
 	struct ib_port_attr attr;
 	int result = -ENOMEM;
 
-	priv = ipoib_intf_alloc(format);
+	priv = ipoib_intf_alloc(hca, port, format);
 	if (!priv)
 		goto alloc_mem_failed;
 
@@ -2224,7 +2288,7 @@ static void ipoib_add_one(struct ib_device *device)
 			continue;
 		dev = ipoib_add_port("ib%d", device, p);
 		if (!IS_ERR(dev)) {
-			priv = netdev_priv(dev);
+			priv = ipoib_priv(dev);
 			list_add_tail(&priv->list, dev_list);
 			count++;
 		}
@@ -2264,6 +2328,7 @@ static void ipoib_remove_one(struct ib_device *device, void *client_data)
 
 		unregister_netdev(priv->dev);
 		free_netdev(priv->dev);
+		kfree(priv);
 	}
 
 	kfree(dev_list);
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
index 69e146cdc306..a557a5e993fd 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
@@ -114,7 +114,7 @@ static void ipoib_mcast_free(struct ipoib_mcast *mcast)
 	struct net_device *dev = mcast->dev;
 	int tx_dropped = 0;
 
-	ipoib_dbg_mcast(netdev_priv(dev), "deleting multicast group %pI6\n",
+	ipoib_dbg_mcast(ipoib_priv(dev), "deleting multicast group %pI6\n",
 			mcast->mcmember.mgid.raw);
 
 	/* remove all neigh connected to this mcast */
@@ -158,7 +158,7 @@ static struct ipoib_mcast *ipoib_mcast_alloc(struct net_device *dev,
 
 static struct ipoib_mcast *__ipoib_mcast_find(struct net_device *dev, void *mgid)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	struct rb_node *n = priv->multicast_tree.rb_node;
 
 	while (n) {
@@ -182,7 +182,7 @@ static struct ipoib_mcast *__ipoib_mcast_find(struct net_device *dev, void *mgid
 
 static int __ipoib_mcast_add(struct net_device *dev, struct ipoib_mcast *mcast)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	struct rb_node **n = &priv->multicast_tree.rb_node, *pn = NULL;
 
 	while (*n) {
@@ -212,7 +212,8 @@ static int ipoib_mcast_join_finish(struct ipoib_mcast *mcast,
 				   struct ib_sa_mcmember_rec *mcmember)
 {
 	struct net_device *dev = mcast->dev;
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
+	struct rdma_netdev *rn = netdev_priv(dev);
 	struct ipoib_ah *ah;
 	int ret;
 	int set_qkey = 0;
@@ -260,8 +261,9 @@ static int ipoib_mcast_join_finish(struct ipoib_mcast *mcast,
 			return 0;
 		}
 
-		ret = ipoib_mcast_attach(dev, be16_to_cpu(mcast->mcmember.mlid),
-					 &mcast->mcmember.mgid, set_qkey);
+		ret = rn->attach_mcast(dev, priv->ca, &mcast->mcmember.mgid,
+				       be16_to_cpu(mcast->mcmember.mlid),
+				       set_qkey);
 		if (ret < 0) {
 			ipoib_warn(priv, "couldn't attach QP to multicast group %pI6\n",
 				   mcast->mcmember.mgid.raw);
@@ -375,7 +377,7 @@ static int ipoib_mcast_join_complete(int status,
 {
 	struct ipoib_mcast *mcast = multicast->context;
 	struct net_device *dev = mcast->dev;
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 
 	ipoib_dbg_mcast(priv, "%sjoin completion for %pI6 (status %d)\n",
 			test_bit(IPOIB_MCAST_FLAG_SENDONLY, &mcast->flags) ?
@@ -477,7 +479,7 @@ static int ipoib_mcast_join_complete(int status,
  */
 static int ipoib_mcast_join(struct net_device *dev, struct ipoib_mcast *mcast)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	struct ib_sa_multicast *multicast;
 	struct ib_sa_mcmember_rec rec = {
 		.join_state = 1
@@ -678,7 +680,7 @@ void ipoib_mcast_join_task(struct work_struct *work)
 
 void ipoib_mcast_start_thread(struct net_device *dev)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	unsigned long flags;
 
 	ipoib_dbg_mcast(priv, "starting multicast thread\n");
@@ -690,7 +692,7 @@ void ipoib_mcast_start_thread(struct net_device *dev)
 
 int ipoib_mcast_stop_thread(struct net_device *dev)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	unsigned long flags;
 
 	ipoib_dbg_mcast(priv, "stopping multicast thread\n");
@@ -706,7 +708,8 @@ int ipoib_mcast_stop_thread(struct net_device *dev)
 
 static int ipoib_mcast_leave(struct net_device *dev, struct ipoib_mcast *mcast)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
+	struct rdma_netdev *rn = netdev_priv(dev);
 	int ret = 0;
 
 	if (test_and_clear_bit(IPOIB_MCAST_FLAG_BUSY, &mcast->flags))
@@ -720,8 +723,8 @@ static int ipoib_mcast_leave(struct net_device *dev, struct ipoib_mcast *mcast)
 				mcast->mcmember.mgid.raw);
 
 		/* Remove ourselves from the multicast group */
-		ret = ib_detach_mcast(priv->qp, &mcast->mcmember.mgid,
-				      be16_to_cpu(mcast->mcmember.mlid));
+		ret = rn->detach_mcast(dev, priv->ca, &mcast->mcmember.mgid,
+				       be16_to_cpu(mcast->mcmember.mlid));
 		if (ret)
 			ipoib_warn(priv, "ib_detach_mcast failed (result = %d)\n", ret);
 	} else if (!test_bit(IPOIB_MCAST_FLAG_SENDONLY, &mcast->flags))
@@ -762,7 +765,8 @@ void ipoib_mcast_remove_list(struct list_head *remove_list)
 
 void ipoib_mcast_send(struct net_device *dev, u8 *daddr, struct sk_buff *skb)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
+	struct rdma_netdev *rn = netdev_priv(dev);
 	struct ipoib_mcast *mcast;
 	unsigned long flags;
 	void *mgid = daddr + 4;
@@ -825,7 +829,8 @@ void ipoib_mcast_send(struct net_device *dev, u8 *daddr, struct sk_buff *skb)
 			}
 		}
 		spin_unlock_irqrestore(&priv->lock, flags);
-		ipoib_send(dev, skb, mcast->ah, IB_MULTICAST_QPN);
+		rn->send(dev, skb, mcast->ah, IB_MULTICAST_QPN,
+			 priv->tx_wr.remote_qkey);
 		if (neigh)
 			ipoib_neigh_put(neigh);
 		return;
@@ -837,7 +842,7 @@ void ipoib_mcast_send(struct net_device *dev, u8 *daddr, struct sk_buff *skb)
 
 void ipoib_mcast_dev_flush(struct net_device *dev)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	LIST_HEAD(remove_list);
 	struct ipoib_mcast *mcast, *tmcast;
 	unsigned long flags;
@@ -1029,7 +1034,7 @@ struct ipoib_mcast_iter *ipoib_mcast_iter_init(struct net_device *dev)
 
 int ipoib_mcast_iter_next(struct ipoib_mcast_iter *iter)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(iter->dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(iter->dev);
 	struct rb_node *n;
 	struct ipoib_mcast *mcast;
 	int ret = 1;
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_netlink.c b/drivers/infiniband/ulp/ipoib/ipoib_netlink.c
index cdc7df4fdb8a..5d795aaea92c 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_netlink.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_netlink.c
@@ -44,7 +44,7 @@
 
 static int ipoib_fill_info(struct sk_buff *skb, const struct net_device *dev)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	u16 val;
 
 	if (nla_put_u16(skb, IFLA_IPOIB_PKEY, priv->pkey))
@@ -107,7 +107,7 @@ static int ipoib_new_child_link(struct net *src_net, struct net_device *dev,
 	if (!pdev || pdev->type != ARPHRD_INFINIBAND)
 		return -ENODEV;
 
-	ppriv = netdev_priv(pdev);
+	ppriv = ipoib_priv(pdev);
 
 	if (test_bit(IPOIB_FLAG_SUBINTERFACE, &ppriv->flags)) {
 		ipoib_warn(ppriv, "child creation disallowed for child devices\n");
@@ -129,7 +129,7 @@ static int ipoib_new_child_link(struct net *src_net, struct net_device *dev,
 	 */
 	child_pkey |= 0x8000;
 
-	err = __ipoib_vlan_add(ppriv, netdev_priv(dev), child_pkey, IPOIB_RTNL_CHILD);
+	err = __ipoib_vlan_add(ppriv, ipoib_priv(dev), child_pkey, IPOIB_RTNL_CHILD);
 
 	if (!err && data)
 		err = ipoib_changelink(dev, tb, data);
@@ -140,8 +140,8 @@ static void ipoib_unregister_child_dev(struct net_device *dev, struct list_head
 {
 	struct ipoib_dev_priv *priv, *ppriv;
 
-	priv = netdev_priv(dev);
-	ppriv = netdev_priv(priv->parent);
+	priv = ipoib_priv(dev);
+	ppriv = ipoib_priv(priv->parent);
 
 	down_write(&ppriv->vlan_rwsem);
 	unregister_netdevice_queue(dev, head);
@@ -161,7 +161,7 @@ static size_t ipoib_get_size(const struct net_device *dev)
 	.maxtype	= IFLA_IPOIB_MAX,
 	.policy		= ipoib_policy,
 	.priv_size	= sizeof(struct ipoib_dev_priv),
-	.setup		= ipoib_setup,
+	.setup		= ipoib_setup_common,
 	.newlink	= ipoib_new_child_link,
 	.changelink	= ipoib_changelink,
 	.dellink	= ipoib_unregister_child_dev,
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_verbs.c b/drivers/infiniband/ulp/ipoib/ipoib_verbs.c
index 529b9509a2c4..5f3dba9041e0 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_verbs.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_verbs.c
@@ -35,9 +35,10 @@
 
 #include "ipoib.h"
 
-int ipoib_mcast_attach(struct net_device *dev, u16 mlid, union ib_gid *mgid, int set_qkey)
+int ipoib_mcast_attach(struct net_device *dev, struct ib_device *hca,
+		       union ib_gid *mgid, u16 mlid, int set_qkey)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	struct ib_qp_attr *qp_attr = NULL;
 	int ret;
 	u16 pkey_index;
@@ -74,9 +75,20 @@ int ipoib_mcast_attach(struct net_device *dev, u16 mlid, union ib_gid *mgid, int
 	return ret;
 }
 
+int ipoib_mcast_detach(struct net_device *dev, struct ib_device *hca,
+		       union ib_gid *mgid, u16 mlid)
+{
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
+	int ret;
+
+	ret = ib_detach_mcast(priv->qp, mgid, mlid);
+
+	return ret;
+}
+
 int ipoib_init_qp(struct net_device *dev)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	int ret;
 	struct ib_qp_attr qp_attr;
 	int attr_mask;
@@ -130,7 +142,7 @@ int ipoib_init_qp(struct net_device *dev)
 
 int ipoib_transport_dev_init(struct net_device *dev, struct ib_device *ca)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 	struct ib_qp_init_attr init_attr = {
 		.cap = {
 			.max_send_wr  = ipoib_sendq_size,
@@ -196,6 +208,8 @@ int ipoib_transport_dev_init(struct net_device *dev, struct ib_device *ca)
 		goto out_free_send_cq;
 	}
 
+	priv->qp_num = priv->qp->qp_num;
+
 	for (i = 0; i < MAX_SKB_FRAGS + 1; ++i)
 		priv->tx_sge[i].lkey = priv->pd->local_dma_lkey;
 
@@ -232,7 +246,7 @@ int ipoib_transport_dev_init(struct net_device *dev, struct ib_device *ca)
 
 void ipoib_transport_dev_cleanup(struct net_device *dev)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 
 	if (priv->qp) {
 		if (ib_destroy_qp(priv->qp))
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_vlan.c b/drivers/infiniband/ulp/ipoib/ipoib_vlan.c
index deedb6fc1b05..ce1a12ba2fd9 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_vlan.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_vlan.c
@@ -43,7 +43,7 @@ static ssize_t show_parent(struct device *d, struct device_attribute *attr,
 			   char *buf)
 {
 	struct net_device *dev = to_net_dev(d);
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	struct ipoib_dev_priv *priv = ipoib_priv(dev);
 
 	return sprintf(buf, "%s\n", priv->parent->name);
 }
@@ -127,14 +127,15 @@ int ipoib_vlan_add(struct net_device *pdev, unsigned short pkey)
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
 
-	ppriv = netdev_priv(pdev);
+	ppriv = ipoib_priv(pdev);
 
 	if (test_bit(IPOIB_FLAG_GOING_DOWN, &ppriv->flags))
 		return -EPERM;
 
 	snprintf(intf_name, sizeof intf_name, "%s.%04x",
 		 ppriv->dev->name, pkey);
-	priv = ipoib_intf_alloc(intf_name);
+
+	priv = ipoib_intf_alloc(ppriv->ca, ppriv->port, intf_name);
 	if (!priv)
 		return -ENOMEM;
 
@@ -182,7 +183,7 @@ int ipoib_vlan_delete(struct net_device *pdev, unsigned short pkey)
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
 
-	ppriv = netdev_priv(pdev);
+	ppriv = ipoib_priv(pdev);
 
 	if (test_bit(IPOIB_FLAG_GOING_DOWN, &ppriv->flags))
 		return -EPERM;
-- 
1.8.3.1
