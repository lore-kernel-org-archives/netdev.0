From: Patrick McHardy <kaber@trash.net>
Subject: RFC: net: allow to propagate errors through ->ndo_hard_start_xmit()
Date: Mon, 09 Nov 2009 20:41:36 +0100
Message-ID: <4AF87070.6020007@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050709090809070600030808"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Jarek Poplawski <jarkao2@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48262 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751773AbZKITlg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 14:41:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050709090809070600030808
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

I've updated my patch to propagate error values (errno and NET_XMIT
codes) through ndo_hard_start_xmit() and incorporated the suggestions
made last time, namely:

- move slightly complicated return value check to inline function and
  add a few comments

- fix error handling while in the middle of transmitting GSO skbs

I've also audited the tree once again for invalid return values and
found a single remaining instance in a Wimax driver, I'll take care
of that later.

Two questions remain:

- I'm not sure the error handling in dev_hard_start_xmit() for GSO
  skbs is optimal. When the driver returns an error, it is assumed
  the current segment has been freed. The patch then frees the
  entire GSO skb, including all remaining segments. Alternatively
  it could try to transmit the remaining segments later.

- Stephen recently introduced an enum for the netdev_tx codes, with
  this patch drivers are allowed to return different values.
  The mainly useful part about Stephen's patch IMO is the netdev_tx
  typedef to make it easier to locate ndo_start_xmit() functions
  which are defined in different files than the netdev_ops.
  So we could remove the enum again and simply typedef an int.

Any opinions are welcome :)

--------------050709090809070600030808
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

commit 08a98f11bc1c1452df74c171409218d2243f0818
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon Nov 9 20:33:14 2009 +0100

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
index 465add6..ab2812c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -63,27 +63,48 @@ struct wireless_dev;
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
 
 /* Backlog congestion levels */
-#define NET_RX_SUCCESS		0   /* keep 'em coming, baby */
-#define NET_RX_DROP		1  /* packet dropped */
+#define NET_RX_SUCCESS		0	/* keep 'em coming, baby */
+#define NET_RX_DROP		1	/* packet dropped */
 
 /* NET_XMIT_CN is special. It does not guarantee that this packet is lost. It
  * indicates that the device will soon be dropping packets, or already drops
  * some packets of the same priority; prompting us to send less aggressively. */
-#define net_xmit_eval(e)	((e) == NET_XMIT_CN? 0 : (e))
+#define net_xmit_eval(e)	((e) == NET_XMIT_CN ? 0 : (e))
 #define net_xmit_errno(e)	((e) != NET_XMIT_CN ? -ENOBUFS : 0)
 
 /* Driver transmit return codes */
+#define NETDEV_TX_MASK		0xf
+
 enum netdev_tx {
-	NETDEV_TX_OK = 0,	/* driver took care of packet */
-	NETDEV_TX_BUSY,		/* driver tx path was busy*/
-	NETDEV_TX_LOCKED = -1,	/* driver tx lock was already taken */
+	__NETDEV_TX_MIN	 = INT_MIN,	/* make sure enum is signed */
+	NETDEV_TX_OK	 = 0,		/* driver took care of packet */
+	NETDEV_TX_BUSY	 = 1,		/* driver tx path was busy*/
+	NETDEV_TX_LOCKED = 2,		/* driver tx lock was already taken */
 };
 typedef enum netdev_tx netdev_tx_t;
 
diff --git a/net/core/dev.c b/net/core/dev.c
index bf629ac..1f5752d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1756,7 +1756,7 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			struct netdev_queue *txq)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
-	int rc;
+	int rc = NETDEV_TX_OK;
 
 	if (likely(!skb->next)) {
 		if (!list_empty(&ptype_all))
@@ -1804,6 +1804,8 @@ gso:
 		nskb->next = NULL;
 		rc = ops->ndo_start_xmit(nskb, dev);
 		if (unlikely(rc != NETDEV_TX_OK)) {
+			if (rc & ~NETDEV_TX_MASK)
+				goto out_kfree_gso_skb;
 			nskb->next = skb->next;
 			skb->next = nskb;
 			return rc;
@@ -1813,11 +1815,14 @@ gso:
 			return NETDEV_TX_BUSY;
 	} while (skb->next);
 
-	skb->destructor = DEV_GSO_CB(skb)->destructor;
+	rc = NETDEV_TX_OK;
 
+out_kfree_gso_skb:
+	if (likely(skb->next == NULL))
+		skb->destructor = DEV_GSO_CB(skb)->destructor;
 out_kfree_skb:
 	kfree_skb(skb);
-	return NETDEV_TX_OK;
+	return rc;
 }
 
 static u32 skb_tx_hashrnd;
@@ -1905,6 +1910,23 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 	return rc;
 }
 
+static inline bool dev_xmit_complete(int rc)
+{
+	/* successful transmission */
+	if (rc == NETDEV_TX_OK)
+		return true;
+
+	/* error while transmitting, driver consumed skb */
+	if (rc < 0)
+		return true;
+
+	/* error while queueing to a different device, driver consumed skb */
+	if (rc & NET_XMIT_MASK)
+		return true;
+
+	return false;
+}
+
 /**
  *	dev_queue_xmit - transmit a buffer
  *	@skb: buffer to transmit
@@ -2002,8 +2024,8 @@ gso:
 			HARD_TX_LOCK(dev, txq, cpu);
 
 			if (!netif_tx_queue_stopped(txq)) {
-				rc = NET_XMIT_SUCCESS;
-				if (!dev_hard_start_xmit(skb, dev, txq)) {
+				rc = dev_hard_start_xmit(skb, dev, txq);
+				if (dev_xmit_complete(rc)) {
 					HARD_TX_UNLOCK(dev, txq);
 					goto out;
 				}
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 4ae6aa5..b13821a 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -120,8 +120,15 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 
 	HARD_TX_LOCK(dev, txq, smp_processor_id());
 	if (!netif_tx_queue_stopped(txq) &&
-	    !netif_tx_queue_frozen(txq))
+	    !netif_tx_queue_frozen(txq)) {
 		ret = dev_hard_start_xmit(skb, dev, txq);
+
+		/* an error implies that the skb was consumed */
+		if (ret < 0)
+			ret = NETDEV_TX_OK;
+		/* all NET_XMIT codes map to NETDEV_TX_OK */
+		ret &= ~NET_XMIT_MASK;
+	}
 	HARD_TX_UNLOCK(dev, txq);
 
 	spin_lock(root_lock);

--------------050709090809070600030808--
