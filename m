From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [net 8/8] gianfar: Replace eieio with wmb for non-PPC archs
Date: Fri, 3 Oct 2014 19:02:49 +0300
Message-ID: <1412352169-14414-9-git-send-email-claudiu.manoil@freescale.com>
References: <1412352169-14414-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Xiubo Li <Li.Xiubo@freescale.com>,
	Shruti Kanetkar <Shruti@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0142.outbound.protection.outlook.com ([157.56.111.142]:60463
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752668AbaJCQZY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Oct 2014 12:25:24 -0400
In-Reply-To: <1412352169-14414-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace PPC specific eieio() with arch independent wmb()
for other architectures, i.e. ARM.
The eieio() macro is not defined on ARM and generates
build error.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 13 +++----------
 drivers/net/ethernet/freescale/gianfar.h | 16 ++++++++++++++++
 2 files changed, 19 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 356a998..379b1a5 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -165,7 +165,7 @@ static void gfar_init_rxbdp(struct gfar_priv_rx_q *rx_queue, struct rxbd8 *bdp,
 	if (bdp == rx_queue->rx_bd_base + rx_queue->rx_ring_size - 1)
 		lstatus |= BD_LFLAG(RXBD_WRAP);
 
-	eieio();
+	gfar_wmb();
 
 	bdp->lstatus = lstatus;
 }
@@ -2371,18 +2371,11 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 */
 	spin_lock_irqsave(&tx_queue->txlock, flags);
 
-	/* The powerpc-specific eieio() is used, as wmb() has too strong
-	 * semantics (it requires synchronization between cacheable and
-	 * uncacheable mappings, which eieio doesn't provide and which we
-	 * don't need), thus requiring a more expensive sync instruction.  At
-	 * some point, the set of architecture-independent barrier functions
-	 * should be expanded to include weaker barriers.
-	 */
-	eieio();
+	gfar_wmb();
 
 	txbdp_start->lstatus = lstatus;
 
-	eieio(); /* force lstatus write before tx_skbuff */
+	gfar_wmb(); /* force lstatus write before tx_skbuff */
 
 	tx_queue->tx_skbuff[tx_queue->skb_curtx] = skb;
 
diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index 0b37722..2805cfb 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -1241,6 +1241,22 @@ static inline int gfar_is_rx_dma_stopped(struct gfar_private *priv)
 	return gfar_read(&regs->ievent) & IEVENT_GRSC;
 }
 
+static inline void gfar_wmb(void)
+{
+#if defined(CONFIG_PPC)
+	/* The powerpc-specific eieio() is used, as wmb() has too strong
+	 * semantics (it requires synchronization between cacheable and
+	 * uncacheable mappings, which eieio() doesn't provide and which we
+	 * don't need), thus requiring a more expensive sync instruction.  At
+	 * some point, the set of architecture-independent barrier functions
+	 * should be expanded to include weaker barriers.
+	 */
+	eieio();
+#else
+	wmb(); /* order write acesses for BD (or FCB) fields */
+#endif
+}
+
 irqreturn_t gfar_receive(int irq, void *dev_id);
 int startup_gfar(struct net_device *dev);
 void stop_gfar(struct net_device *dev);
-- 
1.7.11.7
