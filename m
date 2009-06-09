From: Patrick McHardy <kaber@trash.net>
Subject: [RFC net 02/03]: allow to propagate errors through ->ndo_hard_start_xmit()
Date: Tue,  9 Jun 2009 18:17:01 +0200 (MEST)
Message-ID: <20090609161700.6730.4204.sendpatchset@x2.localnet>
References: <20090609161658.6730.59754.sendpatchset@x2.localnet>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33726 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756109AbZFIQRA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 12:17:00 -0400
In-Reply-To: <20090609161658.6730.59754.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit c2104095c3a1023b4f4809c90092145dff093c88
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue Jun 9 17:55:34 2009 +0200

    net: allow to propagate errors through ->ndo_hard_start_xmit()
    
    Currently the ->ndo_hard_start_xmit() callbacks are only permitted to return
    one of the NETDEV_TX codes. This prevents any kind of error propagation for
    virtual devices, like queue congestion of the underlying device in case of
    layered devices, or unreachability in case of tunnels.
    
    This patches changes the NET_XMIT codes to avoid clashes with the NETDEV_TX
    codes and changes the two callers of dev_hard_start_xmit() to expect either
    errno codes, NET_XMIT codes or NETDEV_TX codes as return value.
    
    In case of qdisc_restart(), all non NETDEV_TX codes are mapped to NETDEV_TX_OK
    since no error propagation is possible when using qdiscs. In case of
    dev_queue_xmit(), the error is propagated upwards.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9ea8d6d..ff76c3e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -63,11 +63,35 @@ struct wireless_dev;
 #define HAVE_FREE_NETDEV		/* free_netdev() */
 #define HAVE_NETDEV_PRIV		/* netdev_priv() */
 
-#define NET_XMIT_SUCCESS	0
-#define NET_XMIT_DROP		1	/* skb dropped			*/
-#define NET_XMIT_CN		2	/* congestion notification	*/
-#define NET_XMIT_POLICED	3	/* skb is shot by police	*/
-#define NET_XMIT_MASK		0xFFFF	/* qdisc flags in net/sch_generic.h */
+/*
+ * Transmit return codes: transmit return codes originate from three different
+ * namespaces:
+ *
+ * - qdisc return codes
+ * - driver transmit return codes
+ * - errno values
+ *
+ * Drivers are allowed to return any one of those in their hard_start_xmit()
+ * function. Real network devices commonly used with qdiscs should only return
+ * the driver transmit return codes though - when qdiscs are used, the actual
+ * transmission happens asynchronously, so the value is not propagated to
+ * higher layers. Virtual network devices transmit synchronously, in this case
+ * the driver transmit return codes are consumed by dev_queue_xmit(), all
+ * others are propagated to higher layers.
+ */
+
+/* qdisc ->enqueue() return codes. */
+#define NET_XMIT_SUCCESS	0x00
+#define NET_XMIT_DROP		0x10	/* skb dropped			*/
+#define NET_XMIT_CN		0x20	/* congestion notification	*/
+#define NET_XMIT_POLICED	0x30	/* skb is shot by police	*/
+#define NET_XMIT_MASK		0xf0	/* qdisc flags in net/sch_generic.h */
+
+/* Driver transmit return codes */
+#define NETDEV_TX_OK		0x0	/* driver took care of packet */
+#define NETDEV_TX_BUSY		0x1	/* driver tx path was busy*/
+#define NETDEV_TX_LOCKED	0x2	/* driver tx lock was already taken */
+#define NETDEV_TX_MASK		0xf
 
 /* Backlog congestion levels */
 #define NET_RX_SUCCESS		0   /* keep 'em coming, baby */
@@ -87,11 +111,6 @@ struct wireless_dev;
 
 #define MAX_ADDR_LEN	32		/* Largest hardware address length */
 
-/* Driver transmit return codes */
-#define NETDEV_TX_OK 0		/* driver took care of packet */
-#define NETDEV_TX_BUSY 1	/* driver tx path was busy*/
-#define NETDEV_TX_LOCKED -1	/* driver tx lock was already taken */
-
 #ifdef  __KERNEL__
 
 /*
diff --git a/net/core/dev.c b/net/core/dev.c
index 11560e3..b2e9953 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1731,6 +1731,8 @@ gso:
 		nskb->next = NULL;
 		rc = ops->ndo_start_xmit(nskb, dev);
 		if (unlikely(rc)) {
+			if (rc & ~NETDEV_TX_MASK)
+				return rc;
 			nskb->next = skb->next;
 			skb->next = nskb;
 			return rc;
@@ -1895,8 +1897,9 @@ gso:
 			HARD_TX_LOCK(dev, txq, cpu);
 
 			if (!netif_tx_queue_stopped(txq)) {
-				rc = 0;
-				if (!dev_hard_start_xmit(skb, dev, txq)) {
+				rc = dev_hard_start_xmit(skb, dev, txq);
+				if (rc == NETDEV_TX_OK || rc < 0 ||
+				    rc & NET_XMIT_MASK) {
 					HARD_TX_UNLOCK(dev, txq);
 					goto out;
 				}
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 27d0381..7e3e514 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -143,8 +143,16 @@ static inline int qdisc_restart(struct Qdisc *q)
 
 	HARD_TX_LOCK(dev, txq, smp_processor_id());
 	if (!netif_tx_queue_stopped(txq) &&
-	    !netif_tx_queue_frozen(txq))
+	    !netif_tx_queue_frozen(txq)) {
 		ret = dev_hard_start_xmit(skb, dev, txq);
+
+		/* an error implies that the skb was consumed */
+		if (ret < 0)
+			ret = NETDEV_TX_OK;
+
+		/* all NET_XMIT codes map to NETDEV_TX_OK */
+		ret &= ~NET_XMIT_MASK;
+	}
 	HARD_TX_UNLOCK(dev, txq);
 
 	spin_lock(root_lock);
