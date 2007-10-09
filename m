From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: [PATCH] xen-netfront: rearrange netfront_info structure to separate
 tx and rx
Date: Tue, 09 Oct 2007 11:44:45 -0700
Message-ID: <470BCC1D.4080007@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Keir Fraser <Keir.Fraser@cl.cam.ac.uk>,
	Stephen Hemminger <shemminge@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:33145 "EHLO mail.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751232AbXJISpa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2007 14:45:30 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Keep tx and rx elements separate on different cachelines to prevent
bouncing.

Signed-off-by: Jeremy Fitzhardinge <jeremy@xensource.com>
Cc: Stephen Hemminger <shemminger@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>

---
 drivers/net/xen-netfront.c |   37 ++++++++++++++++++-------------------
 1 file changed, 18 insertions(+), 19 deletions(-)

===================================================================
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -72,22 +72,12 @@ struct netfront_info {
 	struct list_head list;
 	struct net_device *netdev;
 
+	unsigned int evtchn;
+	struct xenbus_device *xbdev;
+
+	spinlock_t   tx_lock;
 	struct xen_netif_tx_front_ring tx;
-	struct xen_netif_rx_front_ring rx;
-
-	spinlock_t   tx_lock;
-	spinlock_t   rx_lock;
-
-	unsigned int evtchn;
-
-	/* Receive-ring batched refills. */
-#define RX_MIN_TARGET 8
-#define RX_DFL_MIN_TARGET 64
-#define RX_MAX_TARGET min_t(int, NET_RX_RING_SIZE, 256)
-	unsigned rx_min_target, rx_max_target, rx_target;
-	struct sk_buff_head rx_batch;
-
-	struct timer_list rx_refill_timer;
+	int tx_ring_ref;
 
 	/*
 	 * {tx,rx}_skbs store outstanding skbuffs. Free tx_skb entries
@@ -106,13 +96,22 @@ struct netfront_info {
 	grant_ref_t grant_tx_ref[NET_TX_RING_SIZE];
 	unsigned tx_skb_freelist;
 
+	spinlock_t   rx_lock ____cacheline_aligned_in_smp;
+	struct xen_netif_rx_front_ring rx;
+	int rx_ring_ref;
+
+	/* Receive-ring batched refills. */
+#define RX_MIN_TARGET 8
+#define RX_DFL_MIN_TARGET 64
+#define RX_MAX_TARGET min_t(int, NET_RX_RING_SIZE, 256)
+	unsigned rx_min_target, rx_max_target, rx_target;
+	struct sk_buff_head rx_batch;
+
+	struct timer_list rx_refill_timer;
+
 	struct sk_buff *rx_skbs[NET_RX_RING_SIZE];
 	grant_ref_t gref_rx_head;
 	grant_ref_t grant_rx_ref[NET_RX_RING_SIZE];
-
-	struct xenbus_device *xbdev;
-	int tx_ring_ref;
-	int rx_ring_ref;
 
 	unsigned long rx_pfn_array[NET_RX_RING_SIZE];
 	struct multicall_entry rx_mcl[NET_RX_RING_SIZE+1];

