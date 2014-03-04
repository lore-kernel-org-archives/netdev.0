From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH net-next v6 2/10] xen-netback: Minor refactoring
	of netback code
Date: Tue, 4 Mar 2014 22:32:13 +0000
Message-ID: <1393972341-21135-3-git-send-email-zoltan.kiss@citrix.com>
References: <1393972341-21135-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Zoltan Kiss <zoltan.kiss@citrix.com>, jonathan.davies@citrix.com
To: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1393972341-21135-1-git-send-email-zoltan.kiss@citrix.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

This patch contains a few bits of refactoring before introducing the grant
mapping changes:
- introducing xenvif_tx_pending_slots_available(), as this is used several
  times, and will be used more often
- rename the thread to vifX.Y-guest-rx, to signify it does RX work from the
  guest point of view

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
---
 drivers/net/xen-netback/common.h    |   24 +++++++++++++++++++++++-
 drivers/net/xen-netback/interface.c |    4 ++--
 drivers/net/xen-netback/netback.c   |   22 +++-------------------
 3 files changed, 28 insertions(+), 22 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index ae413a2..f514818 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -108,6 +108,16 @@ struct xenvif_rx_meta {
  */
 #define MAX_GRANT_COPY_OPS (MAX_SKB_FRAGS * XEN_NETIF_RX_RING_SIZE)
 
+#define NETBACK_INVALID_HANDLE -1
+
+/*
+ * To avoid confusion, we define XEN_NETBK_LEGACY_SLOTS_MAX indicating
+ * the maximum slots a valid packet can use. Now this value is defined
+ * to be XEN_NETIF_NR_SLOTS_MIN, which is supposed to be supported by
+ * all backend.
+ */
+#define XEN_NETBK_LEGACY_SLOTS_MAX XEN_NETIF_NR_SLOTS_MIN
+
 struct xenvif {
 	/* Unique identifier for this interface. */
 	domid_t          domid;
@@ -216,7 +226,7 @@ void xenvif_carrier_off(struct xenvif *vif);
 
 int xenvif_tx_action(struct xenvif *vif, int budget);
 
-int xenvif_kthread(void *data);
+int xenvif_kthread_guest_rx(void *data);
 void xenvif_kick_thread(struct xenvif *vif);
 
 /* Determine whether the needed number of slots (req) are available,
@@ -226,6 +236,18 @@ bool xenvif_rx_ring_slots_available(struct xenvif *vif, int needed);
 
 void xenvif_stop_queue(struct xenvif *vif);
 
+static inline pending_ring_idx_t nr_pending_reqs(struct xenvif *vif)
+{
+	return MAX_PENDING_REQS -
+		vif->pending_prod + vif->pending_cons;
+}
+
+static inline bool xenvif_tx_pending_slots_available(struct xenvif *vif)
+{
+	return (nr_pending_reqs(vif) + XEN_NETBK_LEGACY_SLOTS_MAX
+		< MAX_PENDING_REQS);
+}
+
 extern bool separate_tx_rx_irq;
 
 #endif /* __XEN_NETBACK__COMMON_H__ */
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 7669d49..bc32627 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -421,8 +421,8 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
 		disable_irq(vif->rx_irq);
 	}
 
-	task = kthread_create(xenvif_kthread,
-			      (void *)vif, "%s", vif->dev->name);
+	task = kthread_create(xenvif_kthread_guest_rx,
+			      (void *)vif, "%s-guest-rx", vif->dev->name);
 	if (IS_ERR(task)) {
 		pr_warn("Could not allocate kthread for %s\n", vif->dev->name);
 		err = PTR_ERR(task);
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 5944f87..e600119 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -63,14 +63,6 @@ static unsigned int fatal_skb_slots = FATAL_SKB_SLOTS_DEFAULT;
 module_param(fatal_skb_slots, uint, 0444);
 
 /*
- * To avoid confusion, we define XEN_NETBK_LEGACY_SLOTS_MAX indicating
- * the maximum slots a valid packet can use. Now this value is defined
- * to be XEN_NETIF_NR_SLOTS_MIN, which is supposed to be supported by
- * all backend.
- */
-#define XEN_NETBK_LEGACY_SLOTS_MAX XEN_NETIF_NR_SLOTS_MIN
-
-/*
  * If head != INVALID_PENDING_RING_IDX, it means this tx request is head of
  * one or more merged tx requests, otherwise it is the continuation of
  * previous tx request.
@@ -131,12 +123,6 @@ static inline pending_ring_idx_t pending_index(unsigned i)
 	return i & (MAX_PENDING_REQS-1);
 }
 
-static inline pending_ring_idx_t nr_pending_reqs(struct xenvif *vif)
-{
-	return MAX_PENDING_REQS -
-		vif->pending_prod + vif->pending_cons;
-}
-
 bool xenvif_rx_ring_slots_available(struct xenvif *vif, int needed)
 {
 	RING_IDX prod, cons;
@@ -1108,8 +1094,7 @@ static unsigned xenvif_tx_build_gops(struct xenvif *vif, int budget)
 	struct sk_buff *skb;
 	int ret;
 
-	while ((nr_pending_reqs(vif) + XEN_NETBK_LEGACY_SLOTS_MAX
-		< MAX_PENDING_REQS) &&
+	while (xenvif_tx_pending_slots_available(vif) &&
 	       (skb_queue_len(&vif->tx_queue) < budget)) {
 		struct xen_netif_tx_request txreq;
 		struct xen_netif_tx_request txfrags[XEN_NETBK_LEGACY_SLOTS_MAX];
@@ -1479,8 +1464,7 @@ static inline int tx_work_todo(struct xenvif *vif)
 {
 
 	if (likely(RING_HAS_UNCONSUMED_REQUESTS(&vif->tx)) &&
-	    (nr_pending_reqs(vif) + XEN_NETBK_LEGACY_SLOTS_MAX
-	     < MAX_PENDING_REQS))
+	    xenvif_tx_pending_slots_available(vif))
 		return 1;
 
 	return 0;
@@ -1543,7 +1527,7 @@ static void xenvif_start_queue(struct xenvif *vif)
 		netif_wake_queue(vif->dev);
 }
 
-int xenvif_kthread(void *data)
+int xenvif_kthread_guest_rx(void *data)
 {
 	struct xenvif *vif = data;
 	struct sk_buff *skb;
