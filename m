From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH v2 net-next] xen-netback: add support for multicast control
Date: Wed, 2 Sep 2015 17:58:36 +0100
Message-ID: <1441213116-9038-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:7693 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755647AbbIBQ6p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2015 12:58:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Xen's PV network protocol includes messages to add/remove ethernet
multicast addresses to/from a filter list in the backend. This allows
the frontend to request the backend only forward multicast packets
which are of interest thus preventing unnecessary noise on the shared
ring.

The canonical netif header in git://xenbits.xen.org/xen.git specifies
the message format (two more XEN_NETIF_EXTRA_TYPEs) so the minimal
necessary changes have been pulled into include/xen/interface/io/netif.h.

To prevent the frontend from extending the multicast filter list
arbitrarily a limit (XEN_NETBK_MCAST_MAX) has been set to 64 entries.
This limit is not specified by the protocol and so may change in future.
If the limit is reached then the next XEN_NETIF_EXTRA_TYPE_MCAST_ADD
sent by the frontend will be failed with NETIF_RSP_ERROR.

Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: Wei Liu <wei.liu2@citrix.com>
---

v2:
 - Fix commit comment
 - Cosmetic change requested by Wei
---
 drivers/net/xen-netback/common.h    |   15 ++++++
 drivers/net/xen-netback/interface.c |   10 ++++
 drivers/net/xen-netback/netback.c   |   99 +++++++++++++++++++++++++++++++++++
 drivers/net/xen-netback/xenbus.c    |   13 +++++
 include/xen/interface/io/netif.h    |    8 ++-
 5 files changed, 144 insertions(+), 1 deletion(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index c6cb85a..6dc76c1 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -210,12 +210,22 @@ enum state_bit_shift {
 	VIF_STATUS_CONNECTED,
 };
 
+struct xenvif_mcast_addr {
+	struct list_head entry;
+	struct rcu_head rcu;
+	u8 addr[6];
+};
+
+#define XEN_NETBK_MCAST_MAX 64
+
 struct xenvif {
 	/* Unique identifier for this interface. */
 	domid_t          domid;
 	unsigned int     handle;
 
 	u8               fe_dev_addr[6];
+	struct list_head fe_mcast_addr;
+	unsigned int     fe_mcast_count;
 
 	/* Frontend feature information. */
 	int gso_mask;
@@ -224,6 +234,7 @@ struct xenvif {
 	u8 can_sg:1;
 	u8 ip_csum:1;
 	u8 ipv6_csum:1;
+	u8 multicast_control:1;
 
 	/* Is this interface disabled? True when backend discovers
 	 * frontend is rogue.
@@ -341,4 +352,8 @@ void xenvif_skb_zerocopy_prepare(struct xenvif_queue *queue,
 				 struct sk_buff *skb);
 void xenvif_skb_zerocopy_complete(struct xenvif_queue *queue);
 
+/* Multicast control */
+bool xenvif_mcast_match(struct xenvif *vif, const u8 *addr);
+void xenvif_mcast_addr_list_free(struct xenvif *vif);
+
 #endif /* __XEN_NETBACK__COMMON_H__ */
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 28577a3..e7bd63e 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -171,6 +171,13 @@ static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	    !xenvif_schedulable(vif))
 		goto drop;
 
+	if (vif->multicast_control && skb->pkt_type == PACKET_MULTICAST) {
+		struct ethhdr *eth = (struct ethhdr *)skb->data;
+
+		if (!xenvif_mcast_match(vif, eth->h_dest))
+			goto drop;
+	}
+
 	cb = XENVIF_RX_CB(skb);
 	cb->expires = jiffies + vif->drain_timeout;
 
@@ -427,6 +434,7 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 	vif->num_queues = 0;
 
 	spin_lock_init(&vif->lock);
+	INIT_LIST_HEAD(&vif->fe_mcast_addr);
 
 	dev->netdev_ops	= &xenvif_netdev_ops;
 	dev->hw_features = NETIF_F_SG |
@@ -661,6 +669,8 @@ void xenvif_disconnect(struct xenvif *vif)
 
 		xenvif_unmap_frontend_rings(queue);
 	}
+
+	xenvif_mcast_addr_list_free(vif);
 }
 
 /* Reverse the relevant parts of xenvif_init_queue().
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 3f44b52..42569b9 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1157,6 +1157,80 @@ static bool tx_credit_exceeded(struct xenvif_queue *queue, unsigned size)
 	return false;
 }
 
+/* No locking is required in xenvif_mcast_add/del() as they are
+ * only ever invoked from NAPI poll. An RCU list is used because
+ * xenvif_mcast_match() is called asynchronously, during start_xmit.
+ */
+
+static int xenvif_mcast_add(struct xenvif *vif, const u8 *addr)
+{
+	struct xenvif_mcast_addr *mcast;
+
+	if (vif->fe_mcast_count == XEN_NETBK_MCAST_MAX) {
+		if (net_ratelimit())
+			netdev_err(vif->dev,
+				   "Too many multicast addresses\n");
+		return -ENOSPC;
+	}
+
+	mcast = kzalloc(sizeof(*mcast), GFP_ATOMIC);
+	if (!mcast)
+		return -ENOMEM;
+
+	ether_addr_copy(mcast->addr, addr);
+	list_add_tail_rcu(&mcast->entry, &vif->fe_mcast_addr);
+	vif->fe_mcast_count++;
+
+	return 0;
+}
+
+static void xenvif_mcast_del(struct xenvif *vif, const u8 *addr)
+{
+	struct xenvif_mcast_addr *mcast;
+
+	list_for_each_entry_rcu(mcast, &vif->fe_mcast_addr, entry) {
+		if (ether_addr_equal(addr, mcast->addr)) {
+			--vif->fe_mcast_count;
+			list_del_rcu(&mcast->entry);
+			kfree_rcu(mcast, rcu);
+			break;
+		}
+	}
+}
+
+bool xenvif_mcast_match(struct xenvif *vif, const u8 *addr)
+{
+	struct xenvif_mcast_addr *mcast;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(mcast, &vif->fe_mcast_addr, entry) {
+		if (ether_addr_equal(addr, mcast->addr)) {
+			rcu_read_unlock();
+			return true;
+		}
+	}
+	rcu_read_unlock();
+
+	return false;
+}
+
+void xenvif_mcast_addr_list_free(struct xenvif *vif)
+{
+	/* No need for locking or RCU here. NAPI poll and TX queue
+	 * are stopped.
+	 */
+	while (!list_empty(&vif->fe_mcast_addr)) {
+		struct xenvif_mcast_addr *mcast;
+
+		mcast = list_first_entry(&vif->fe_mcast_addr,
+					 struct xenvif_mcast_addr,
+					 entry);
+		--vif->fe_mcast_count;
+		list_del(&mcast->entry);
+		kfree(mcast);
+	}
+}
+
 static void xenvif_tx_build_gops(struct xenvif_queue *queue,
 				     int budget,
 				     unsigned *copy_ops,
@@ -1215,6 +1289,31 @@ static void xenvif_tx_build_gops(struct xenvif_queue *queue,
 				break;
 		}
 
+		if (extras[XEN_NETIF_EXTRA_TYPE_MCAST_ADD - 1].type) {
+			struct xen_netif_extra_info *extra;
+
+			extra = &extras[XEN_NETIF_EXTRA_TYPE_MCAST_ADD - 1];
+			ret = xenvif_mcast_add(queue->vif, extra->u.mcast.addr);
+
+			make_tx_response(queue, &txreq,
+					 (ret == 0) ?
+					 XEN_NETIF_RSP_OKAY :
+					 XEN_NETIF_RSP_ERROR);
+			push_tx_responses(queue);
+			continue;
+		}
+
+		if (extras[XEN_NETIF_EXTRA_TYPE_MCAST_DEL - 1].type) {
+			struct xen_netif_extra_info *extra;
+
+			extra = &extras[XEN_NETIF_EXTRA_TYPE_MCAST_DEL - 1];
+			xenvif_mcast_del(queue->vif, extra->u.mcast.addr);
+
+			make_tx_response(queue, &txreq, XEN_NETIF_RSP_OKAY);
+			push_tx_responses(queue);
+			continue;
+		}
+
 		ret = xenvif_count_requests(queue, &txreq, txfrags, work_to_do);
 		if (unlikely(ret < 0))
 			break;
diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index ec383b0..929a6e7 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -327,6 +327,14 @@ static int netback_probe(struct xenbus_device *dev,
 			goto abort_transaction;
 		}
 
+		/* We support multicast-control. */
+		err = xenbus_printf(xbt, dev->nodename,
+				    "feature-multicast-control", "%d", 1);
+		if (err) {
+			message = "writing feature-multicast-control";
+			goto abort_transaction;
+		}
+
 		err = xenbus_transaction_end(xbt, 0);
 	} while (err == -EAGAIN);
 
@@ -1016,6 +1024,11 @@ static int read_xenbus_vif_flags(struct backend_info *be)
 		val = 0;
 	vif->ipv6_csum = !!val;
 
+	if (xenbus_scanf(XBT_NIL, dev->otherend, "request-multicast-control",
+			 "%d", &val) < 0)
+		val = 0;
+	vif->multicast_control = !!val;
+
 	return 0;
 }
 
diff --git a/include/xen/interface/io/netif.h b/include/xen/interface/io/netif.h
index 70054cc..252ffd4 100644
--- a/include/xen/interface/io/netif.h
+++ b/include/xen/interface/io/netif.h
@@ -156,7 +156,9 @@ struct xen_netif_tx_request {
 /* Types of xen_netif_extra_info descriptors. */
 #define XEN_NETIF_EXTRA_TYPE_NONE	(0)  /* Never used - invalid */
 #define XEN_NETIF_EXTRA_TYPE_GSO	(1)  /* u.gso */
-#define XEN_NETIF_EXTRA_TYPE_MAX	(2)
+#define XEN_NETIF_EXTRA_TYPE_MCAST_ADD	(2)  /* u.mcast */
+#define XEN_NETIF_EXTRA_TYPE_MCAST_DEL	(3)  /* u.mcast */
+#define XEN_NETIF_EXTRA_TYPE_MAX	(4)
 
 /* xen_netif_extra_info flags. */
 #define _XEN_NETIF_EXTRA_FLAG_MORE	(0)
@@ -201,6 +203,10 @@ struct xen_netif_extra_info {
 			uint16_t features; /* XEN_NETIF_GSO_FEAT_* */
 		} gso;
 
+		struct {
+			uint8_t addr[6]; /* Address to add/remove. */
+		} mcast;
+
 		uint16_t pad[3];
 	} u;
 };
-- 
1.7.10.4
