From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 2/3] via-rhine: balance interrupt acknowledge and events retrieval.
Date: Fri, 30 Dec 2011 19:04:04 +0100
Message-ID: <20111230180404.GC3647@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org, rl@hellgate.ch
To: Bjarke Istrup Pedersen <gurligebis@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:47060 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751704Ab1L3SMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Dec 2011 13:12:47 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/via/via-rhine.c |   22 ++++++++++++++--------
 1 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 93987e8..716fd42 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -508,9 +508,8 @@ do {								\
 			1024 - i, __func__, __LINE__);		\
 } while (0)
 
-static inline u32 get_intr_status(struct net_device *dev)
+static u32 rhine_get_events(struct rhine_private *rp)
 {
-	struct rhine_private *rp = netdev_priv(dev);
 	void __iomem *ioaddr = rp->base;
 	u32 intr_status;
 
@@ -521,6 +520,16 @@ static inline u32 get_intr_status(struct net_device *dev)
 	return intr_status;
 }
 
+static void rhine_ack_events(struct rhine_private *rp, u32 mask)
+{
+	void __iomem *ioaddr = rp->base;
+
+	if (rp->quirks & rqStatusWBRace)
+		iowrite8(mask >> 16, ioaddr + IntrStatus2);
+	iowrite16(mask, ioaddr + IntrStatus);
+	IOSYNC;
+}
+
 /*
  * Get power related registers into sane state.
  * Notify user about past WOL event.
@@ -1580,14 +1589,11 @@ static irqreturn_t rhine_interrupt(int irq, void *dev_instance)
 	int boguscnt = max_interrupt_work;
 	int handled = 0;
 
-	while ((intr_status = get_intr_status(dev))) {
+	while ((intr_status = rhine_get_events(rp))) {
 		handled = 1;
 
 		/* Acknowledge all of the current interrupt sources ASAP. */
-		if (intr_status & IntrTxDescRace)
-			iowrite8(0x08, ioaddr + IntrStatus2);
-		iowrite16(intr_status & 0xffff, ioaddr + IntrStatus);
-		IOSYNC;
+		rhine_ack_events(rp, intr_status);
 
 		if (debug > 4)
 			netdev_dbg(dev, "Interrupt, status %08x\n",
@@ -1872,7 +1878,7 @@ static void rhine_restart_tx(struct net_device *dev) {
 	 * If new errors occurred, we need to sort them out before doing Tx.
 	 * In that case the ISR will be back here RSN anyway.
 	 */
-	intr_status = get_intr_status(dev);
+	intr_status = rhine_get_events(rp);
 
 	if ((intr_status & IntrTxErrSummary) == 0) {
 
-- 
1.7.6.4
