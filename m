From: =?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@gmail.com>
Subject: [RFC PATCH 11/14] veth: added support for PACKET_ZEROCOPY
Date: Tue, 31 Oct 2017 13:41:42 +0100
Message-ID: <20171031124145.9667-12-bjorn.topel@gmail.com>
References: <20171031124145.9667-1-bjorn.topel@gmail.com>
Cc: jesse.brandeburg@intel.com, anjali.singhai@intel.com,
        rami.rosen@intel.com, jeffrey.b.shaw@intel.com,
        ferruh.yigit@intel.com, qi.z.zhang@intel.com
To: bjorn.topel@gmail.com, magnus.karlsson@intel.com,
        alexander.h.duyck@intel.com, alexander.duyck@gmail.com,
        john.fastabend@gmail.com, ast@fb.com, brouer@redhat.com,
        michael.lundkvist@ericsson.com, ravineet.singh@ericsson.com,
        daniel@iogearbox.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:39598 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751651AbdJaMnJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 08:43:09 -0400
In-Reply-To: <20171031124145.9667-1-bjorn.topel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Magnus Karlsson <magnus.karlsson@intel.com>

Add AF_PACKET V4 zerocopy support for the veth driver.

Signed-off-by: Magnus Karlsson <magnus.karlsson@intel.com>
---
 drivers/net/veth.c       | 172 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/tpacket4.h | 131 ++++++++++++++++++++++++++++++++++++
 2 files changed, 303 insertions(+)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index f5438d0978ca..3dfb5fb89460 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -19,6 +19,7 @@
 #include <net/xfrm.h>
 #include <linux/veth.h>
 #include <linux/module.h>
+#include <linux/tpacket4.h>
 
 #define DRV_NAME	"veth"
 #define DRV_VERSION	"1.0"
@@ -33,6 +34,10 @@ struct veth_priv {
 	struct net_device __rcu	*peer;
 	atomic64_t		dropped;
 	unsigned		requested_headroom;
+	struct tp4_packet_array *tp4a_rx;
+	struct tp4_packet_array *tp4a_tx;
+	struct napi_struct      *napi;
+	bool                    tp4_zerocopy;
 };
 
 /*
@@ -104,6 +109,12 @@ static netdev_tx_t veth_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct net_device *rcv;
 	int length = skb->len;
 
+	/* Drop packets from stack if we are in zerocopy mode. */
+	if (unlikely(priv->tp4_zerocopy)) {
+		consume_skb(skb);
+		return NETDEV_TX_OK;
+	}
+
 	rcu_read_lock();
 	rcv = rcu_dereference(priv->peer);
 	if (unlikely(!rcv)) {
@@ -126,6 +137,64 @@ static netdev_tx_t veth_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
+static int veth_tp4_xmit(struct net_device *netdev, int queue_pair)
+{
+	struct veth_priv *priv = netdev_priv(netdev);
+
+	local_bh_disable();
+	napi_schedule(priv->napi);
+	local_bh_enable();
+
+	return NETDEV_TX_OK;
+}
+
+static int veth_napi_poll(struct napi_struct *napi, int budget)
+{
+	struct net_device *netdev = napi->dev;
+	struct pcpu_vstats *stats = this_cpu_ptr(netdev->vstats);
+	struct veth_priv *priv_rcv, *priv = netdev_priv(netdev);
+	struct tp4_packet_array *tp4a_tx = priv->tp4a_tx;
+	struct tp4_packet_array *tp4a_rx;
+	struct net_device *rcv;
+	int npackets = 0;
+	int length = 0;
+
+	rcu_read_lock();
+	rcv = rcu_dereference(priv->peer);
+	if (unlikely(!rcv))
+		goto exit;
+
+	priv_rcv = netdev_priv(rcv);
+	if (unlikely(!priv_rcv->tp4_zerocopy))
+		goto exit;
+
+	/* To make sure we do not read the tp4_queue pointers
+	 * before the other process has enabled zerocopy
+	 */
+	smp_rmb();
+
+	tp4a_rx = priv_rcv->tp4a_rx;
+
+	tp4a_populate(tp4a_tx);
+	tp4a_populate(tp4a_rx);
+
+	npackets = tp4a_copy(tp4a_rx, tp4a_tx, &length);
+
+	WARN_ON_ONCE(tp4a_flush(tp4a_tx));
+	WARN_ON_ONCE(tp4a_flush(tp4a_rx));
+
+	u64_stats_update_begin(&stats->syncp);
+	stats->bytes += length;
+	stats->packets += npackets;
+	u64_stats_update_end(&stats->syncp);
+
+exit:
+	rcu_read_unlock();
+	if (npackets < NAPI_POLL_WEIGHT)
+		napi_complete_done(priv->napi, 0);
+	return npackets;
+}
+
 /*
  * general routines
  */
@@ -276,6 +345,105 @@ static void veth_set_rx_headroom(struct net_device *dev, int new_hr)
 	rcu_read_unlock();
 }
 
+static int veth_tp4_disable(struct net_device *netdev,
+			    struct tp4_netdev_parms *params)
+{
+	struct veth_priv *priv_rcv, *priv = netdev_priv(netdev);
+	struct net_device *rcv;
+
+	if (!priv->tp4_zerocopy)
+		return 0;
+	priv->tp4_zerocopy = false;
+
+	/* Make sure other process sees zero copy as off before starting
+	 * to turn things off
+	 */
+	smp_wmb();
+
+	napi_disable(priv->napi);
+	netif_napi_del(priv->napi);
+
+	rcu_read_lock();
+	rcv = rcu_dereference(priv->peer);
+	if (!rcv) {
+		WARN_ON(!rcv);
+		goto exit;
+	}
+	priv_rcv = netdev_priv(rcv);
+
+	if (priv_rcv->tp4_zerocopy) {
+		/* Wait for other thread to complete
+		 * before removing tp4 queues
+		 */
+		napi_synchronize(priv_rcv->napi);
+	}
+exit:
+	rcu_read_unlock();
+
+	tp4a_free(priv->tp4a_rx);
+	tp4a_free(priv->tp4a_tx);
+	kfree(priv->napi);
+
+	return 0;
+}
+
+static int veth_tp4_enable(struct net_device *netdev,
+			   struct tp4_netdev_parms *params)
+{
+	struct veth_priv *priv = netdev_priv(netdev);
+	int err;
+
+	priv->napi = kzalloc(sizeof(*priv->napi), GFP_KERNEL);
+	if (!priv->napi)
+		return -ENOMEM;
+
+	netif_napi_add(netdev, priv->napi, veth_napi_poll,
+		       NAPI_POLL_WEIGHT);
+
+	priv->tp4a_rx = tp4a_rx_new(params->rx_opaque, NAPI_POLL_WEIGHT, NULL);
+	if (!priv->tp4a_rx) {
+		err = -ENOMEM;
+		goto rxa_err;
+	}
+
+	priv->tp4a_tx = tp4a_tx_new(params->tx_opaque, NAPI_POLL_WEIGHT, NULL);
+	if (!priv->tp4a_tx) {
+		err = -ENOMEM;
+		goto txa_err;
+	}
+
+	/* Make sure other process sees queues initialized before enabling
+	 * zerocopy mode
+	 */
+	smp_wmb();
+	priv->tp4_zerocopy = true;
+	napi_enable(priv->napi);
+
+	return 0;
+
+txa_err:
+	tp4a_free(priv->tp4a_rx);
+rxa_err:
+	netif_napi_del(priv->napi);
+	kfree(priv->napi);
+	return err;
+}
+
+static int veth_tp4_zerocopy(struct net_device *netdev,
+			     struct tp4_netdev_parms *params)
+{
+	switch (params->command) {
+	case TP4_ENABLE:
+		return veth_tp4_enable(netdev, params);
+
+	case TP4_DISABLE:
+		return veth_tp4_disable(netdev, params);
+
+	default:
+		return -ENOTSUPP;
+	}
+}
+
 static const struct net_device_ops veth_netdev_ops = {
 	.ndo_init            = veth_dev_init,
 	.ndo_open            = veth_open,
@@ -290,6 +458,8 @@ static const struct net_device_ops veth_netdev_ops = {
 	.ndo_get_iflink		= veth_get_iflink,
 	.ndo_features_check	= passthru_features_check,
 	.ndo_set_rx_headroom	= veth_set_rx_headroom,
+	.ndo_tp4_zerocopy	= veth_tp4_zerocopy,
+	.ndo_tp4_xmit           = veth_tp4_xmit,
 };
 
 #define VETH_FEATURES (NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_HW_CSUM | \
@@ -449,9 +619,11 @@ static int veth_newlink(struct net *src_net, struct net_device *dev,
 
 	priv = netdev_priv(dev);
 	rcu_assign_pointer(priv->peer, peer);
+	priv->tp4_zerocopy = false;
 
 	priv = netdev_priv(peer);
 	rcu_assign_pointer(priv->peer, dev);
+	priv->tp4_zerocopy = false;
 	return 0;
 
 err_register_dev:
diff --git a/include/linux/tpacket4.h b/include/linux/tpacket4.h
index beaf23f713eb..360d80086104 100644
--- a/include/linux/tpacket4.h
+++ b/include/linux/tpacket4.h
@@ -1074,6 +1074,19 @@ static inline unsigned int tp4a_max_data_size(struct tp4_packet_array *a)
 }
 
 /**
+ * tp4a_has_same_umem - Checks if two packet arrays have the same umem
+ * @a1: pointer to packet array
+ * @a2: pointer to packet array
+ *
+ * Returns true if arrays have the same umem, false otherwise
+ **/
+static inline bool tp4a_has_same_umem(struct tp4_packet_array *a1,
+				      struct tp4_packet_array *a2)
+{
+	return (a1->tp4q->umem == a2->tp4q->umem) ? true : false;
+}
+
+/**
  * tp4a_next_packet - Get next packet in array and advance curr pointer
  * @a: pointer to packet array
  * @p: supplied pointer to packet structure that is filled in by function
@@ -1188,6 +1201,124 @@ static inline bool tp4a_next_frame_populate(struct tp4_packet_array *a,
 }
 
 /**
+ * tp4a_add_packet - Adds a packet into a packet array without copying data
+ * @a: pointer to packet array to insert the packet into
+ * @pkt: pointer to packet to insert
+ * @len: returns the length in bytes of data added according to descriptor
+ *
+ * Note that this function does not copy the data. Instead it copies
+ * the address that points to the packet buffer.
+ *
+ * Returns 0 for success and -1 for failure
+ **/
+static inline int tp4a_add_packet(struct tp4_packet_array *a,
+				  struct tp4_frame_set *p, u32 *len)
+{
+	u32 free = a->end - a->curr;
+	u32 nframes = p->end - p->start;
+
+	if (nframes > free)
+		return -1;
+
+	tp4f_reset(p);
+	*len = 0;
+
+	do {
+		int frame_len = tp4f_get_frame_len(p);
+		int idx = a->curr & a->mask;
+
+		a->items[idx].idx = tp4f_get_frame_id(p);
+		a->items[idx].len = frame_len;
+		a->items[idx].offset = tp4f_get_data_offset(p);
+		a->items[idx].flags = tp4f_is_last_frame(p) ?
+						   0 : TP4_PKT_CONT;
+		a->items[idx].error = 0;
+
+		a->curr++;
+		*len += frame_len;
+	} while (tp4f_next_frame(p));
+
+	return 0;
+}
+
+/**
+ * tp4a_copy_packet - Copies a packet with data into a packet array
+ * @a: pointer to packet array to insert the packet into
+ * @pkt: pointer to packet to insert and copy
+ * @len: returns the length in bytes of data copied
+ *
+ * Puts the packet where curr is pointing
+ *
+ * Returns 0 for success and -1 for failure
+ **/
+static inline int tp4a_copy_packet(struct tp4_packet_array *a,
+				   struct tp4_frame_set *p, int *len)
+{
+	u32 free = a->end - a->curr;
+	u32 nframes = p->end - p->start;
+
+	if (nframes > free)
+		return -1;
+
+	tp4f_reset(p);
+	*len = 0;
+
+	do {
+		int frame_len = tp4f_get_frame_len(p);
+		int idx = a->curr & a->mask;
+
+		a->items[idx].len = frame_len;
+		a->items[idx].offset = tp4f_get_data_offset(p);
+		a->items[idx].flags = tp4f_is_last_frame(p) ?
+						   0 : TP4_PKT_CONT;
+		a->items[idx].error = 0;
+
+		memcpy(tp4q_get_data(a->tp4q, &a->items[idx]),
+		       tp4f_get_data(p), frame_len);
+		a->curr++;
+		*len += frame_len;
+	} while (tp4f_next_frame(p));
+
+	return 0;
+}
+
+/**
+ * tp4a_copy - Copy a packet array
+ * @dst: pointer to destination packet array
+ * @src: pointer to source packet array
+ * @len: returns the length in bytes of all packets copied
+ *
+ * Returns number of packets copied
+ **/
+static inline int tp4a_copy(struct tp4_packet_array *dst,
+			    struct tp4_packet_array *src, int *len)
+{
+	int npackets = 0;
+
+	*len = 0;
+	for (;;) {
+		struct tp4_frame_set src_pkt;
+		int pkt_len;
+
+		if (!tp4a_next_packet(src, &src_pkt))
+			break;
+
+		if (tp4a_has_same_umem(src, dst)) {
+			if (tp4a_add_packet(dst, &src_pkt, &pkt_len))
+				break;
+		} else {
+			if (tp4a_copy_packet(dst, &src_pkt, &pkt_len))
+				break;
+		}
+
+		npackets++;
+		*len += pkt_len;
+	}
+
+	return npackets;
+}
+
+/**
  * tp4a_return_packet - Return packet to the packet array
  *
  * @a: pointer to packet array
-- 
2.11.0
