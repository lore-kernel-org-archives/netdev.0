From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [net-next-2.6 PATCH 8/9] vxge: Acquire correct lock based on interrupt
 context.
Date: Mon, 5 Oct 2009 05:14:55 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10910050512580.2346-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, support@neterion.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:39210 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932287AbZJEJPf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 05:15:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Added macros that check if the thread is in interrupt context or not to
  acquire or release locks

Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
---
diff -urpN patch7/drivers/net/vxge/vxge-main.c patch8/drivers/net/vxge/vxge-main.c
--- patch7/drivers/net/vxge/vxge-main.c	2009-09-04 02:13:34.000000000 -0700
+++ patch8/drivers/net/vxge/vxge-main.c	2009-09-04 02:18:15.000000000 -0700
@@ -97,10 +97,10 @@ static inline void VXGE_COMPLETE_VPATH_T
 		more = 0;
 		skb_ptr = completed;
 
-		if (spin_trylock_irqsave(&fifo->tx_lock, flags)) {
+		if (vxge_spin_trylock(&fifo->tx_lock, flags)) {
 			vxge_hw_vpath_poll_tx(fifo->handle, &skb_ptr,
 						NR_SKB_COMPLETED, &more);
-			spin_unlock_irqrestore(&fifo->tx_lock, flags);
+			vxge_spin_unlock(&fifo->tx_lock, flags);
 		}
 		/* free SKBs */
 		for (temp = completed; temp != skb_ptr; temp++)
diff -urpN patch7/drivers/net/vxge/vxge-main.h patch8/drivers/net/vxge/vxge-main.h
--- patch7/drivers/net/vxge/vxge-main.h	2009-09-04 02:05:36.000000000 -0700
+++ patch8/drivers/net/vxge/vxge-main.h	2009-09-04 02:16:40.000000000 -0700
@@ -89,6 +89,26 @@
 
 #define VXGE_LL_MAX_FRAME_SIZE(dev) ((dev)->mtu + VXGE_HW_MAC_HEADER_MAX_SIZE)
 
+#define vxge_spin_lock(l, f) {                  \
+	if (in_interrupt())                     \
+		spin_lock(l);                   \
+	else                                    \
+		spin_lock_irqsave(l, f);        \
+}
+
+#define vxge_spin_trylock(l, f) \
+({ \
+	in_interrupt() ? \
+	spin_trylock(l) : spin_trylock_irqsave(l, f); \
+})
+
+#define vxge_spin_unlock(l, f) {                \
+	if (in_interrupt())                     \
+		spin_unlock(l);                 \
+	else                                    \
+		spin_unlock_irqrestore(l, f);   \
+}
+
 enum vxge_reset_event {
 	/* reset events */
 	VXGE_LL_VPATH_RESET	= 0,

