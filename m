From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH net-next] net: Optimize hard_start_xmit() return checking
Date: Sun, 15 Nov 2009 18:20:12 +0100
Message-ID: <20091115172012.GA2976@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:45548 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752413AbZKORUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Nov 2009 12:20:23 -0500
Received: by bwz27 with SMTP id 27so4934279bwz.21
        for <netdev@vger.kernel.org>; Sun, 15 Nov 2009 09:20:27 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recent changes in the TX error propagation require additional checking
and masking of values returned from hard_start_xmit(), mainly to
separate cases where skb was consumed. This aim can be simplified by
changing the order of NETDEV_TX and NET_XMIT codes, because the latter
are treated similarly to negative (ERRNO) values.

After this change much simpler dev_xmit_complete() is also used in
sch_direct_xmit(), so it is moved to netdevice.h.

Additionally NET_RX definitions in netdevice.h are moved up from
between TX codes to avoid confusion while reading the TX comment.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 include/linux/netdevice.h |   42 ++++++++++++++++++++++++++++++------------
 net/core/dev.c            |   17 -----------------
 net/sched/sch_generic.c   |   23 +++++------------------
 3 files changed, 35 insertions(+), 47 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 61425d0..7043f85 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -63,6 +63,10 @@ struct wireless_dev;
 #define HAVE_FREE_NETDEV		/* free_netdev() */
 #define HAVE_NETDEV_PRIV		/* netdev_priv() */
 
+/* Backlog congestion levels */
+#define NET_RX_SUCCESS		0	/* keep 'em coming, baby */
+#define NET_RX_DROP		1	/* packet dropped */
+
 /*
  * Transmit return codes: transmit return codes originate from three different
  * namespaces:
@@ -82,14 +86,10 @@ struct wireless_dev;
 
 /* qdisc ->enqueue() return codes. */
 #define NET_XMIT_SUCCESS	0x00
-#define NET_XMIT_DROP		0x10	/* skb dropped			*/
-#define NET_XMIT_CN		0x20	/* congestion notification	*/
-#define NET_XMIT_POLICED	0x30	/* skb is shot by police	*/
-#define NET_XMIT_MASK		0xf0	/* qdisc flags in net/sch_generic.h */
-
-/* Backlog congestion levels */
-#define NET_RX_SUCCESS		0	/* keep 'em coming, baby */
-#define NET_RX_DROP		1	/* packet dropped */
+#define NET_XMIT_DROP		0x01	/* skb dropped			*/
+#define NET_XMIT_CN		0x02	/* congestion notification	*/
+#define NET_XMIT_POLICED	0x03	/* skb is shot by police	*/
+#define NET_XMIT_MASK		0x0f	/* qdisc flags in net/sch_generic.h */
 
 /* NET_XMIT_CN is special. It does not guarantee that this packet is lost. It
  * indicates that the device will soon be dropping packets, or already drops
@@ -98,16 +98,34 @@ struct wireless_dev;
 #define net_xmit_errno(e)	((e) != NET_XMIT_CN ? -ENOBUFS : 0)
 
 /* Driver transmit return codes */
-#define NETDEV_TX_MASK		0xf
+#define NETDEV_TX_MASK		0xf0
 
 enum netdev_tx {
 	__NETDEV_TX_MIN	 = INT_MIN,	/* make sure enum is signed */
-	NETDEV_TX_OK	 = 0,		/* driver took care of packet */
-	NETDEV_TX_BUSY	 = 1,		/* driver tx path was busy*/
-	NETDEV_TX_LOCKED = 2,		/* driver tx lock was already taken */
+	NETDEV_TX_OK	 = 0x00,	/* driver took care of packet */
+	NETDEV_TX_BUSY	 = 0x10,	/* driver tx path was busy*/
+	NETDEV_TX_LOCKED = 0x20,	/* driver tx lock was already taken */
 };
 typedef enum netdev_tx netdev_tx_t;
 
+/*
+ * Current order: NETDEV_TX_MASK > NET_XMIT_MASK >= 0 is significant;
+ * hard_start_xmit() return < NET_XMIT_MASK means skb was consumed.
+ */
+static inline bool dev_xmit_complete(int rc)
+{
+	/*
+	 * Positive cases with an skb consumed by a driver:
+	 * - successful transmission (rc == NETDEV_TX_OK)
+	 * - error while transmitting (rc < 0)
+	 * - error while queueing to a different device (rc & NET_XMIT_MASK)
+	 */
+	if (likely(rc < NET_XMIT_MASK))
+		return true;
+
+	return false;
+}
+
 #endif
 
 #define MAX_ADDR_LEN	32		/* Largest hardware address length */
diff --git a/net/core/dev.c b/net/core/dev.c
index 548340b..67669c4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1909,23 +1909,6 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 	return rc;
 }
 
-static inline bool dev_xmit_complete(int rc)
-{
-	/* successful transmission */
-	if (rc == NETDEV_TX_OK)
-		return true;
-
-	/* error while transmitting, driver consumed skb */
-	if (rc < 0)
-		return true;
-
-	/* error while queueing to a different device, driver consumed skb */
-	if (rc & NET_XMIT_MASK)
-		return true;
-
-	return false;
-}
-
 /**
  *	dev_queue_xmit - transmit a buffer
  *	@skb: buffer to transmit
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index b13821a..5173c1e 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -119,39 +119,26 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 	spin_unlock(root_lock);
 
 	HARD_TX_LOCK(dev, txq, smp_processor_id());
-	if (!netif_tx_queue_stopped(txq) &&
-	    !netif_tx_queue_frozen(txq)) {
+	if (!netif_tx_queue_stopped(txq) && !netif_tx_queue_frozen(txq))
 		ret = dev_hard_start_xmit(skb, dev, txq);
 
-		/* an error implies that the skb was consumed */
-		if (ret < 0)
-			ret = NETDEV_TX_OK;
-		/* all NET_XMIT codes map to NETDEV_TX_OK */
-		ret &= ~NET_XMIT_MASK;
-	}
 	HARD_TX_UNLOCK(dev, txq);
 
 	spin_lock(root_lock);
 
-	switch (ret) {
-	case NETDEV_TX_OK:
-		/* Driver sent out skb successfully */
+	if (dev_xmit_complete(ret)) {
+		/* Driver sent out skb successfully or skb was consumed */
 		ret = qdisc_qlen(q);
-		break;
-
-	case NETDEV_TX_LOCKED:
+	} else if (ret == NETDEV_TX_LOCKED) {
 		/* Driver try lock failed */
 		ret = handle_dev_cpu_collision(skb, txq, q);
-		break;
-
-	default:
+	} else {
 		/* Driver returned NETDEV_TX_BUSY - requeue skb */
 		if (unlikely (ret != NETDEV_TX_BUSY && net_ratelimit()))
 			printk(KERN_WARNING "BUG %s code %d qlen %d\n",
 			       dev->name, ret, q->q.qlen);
 
 		ret = dev_requeue_skb(skb, q);
-		break;
 	}
 
 	if (ret && (netif_tx_queue_stopped(txq) ||
