From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH RFC 30/30] net: fec: consolidate hwtstamp implementation
Date: Fri, 20 Jun 2014 13:14:16 +0100
Message-ID: <E1Wxxhw-0005Yn-Ey@rmk-PC.arm.linux.org.uk>
References: <20140620121118.GR32514@n2100.arm.linux.org.uk>
Cc: Fugang Duan <B38611@freescale.com>, netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:36409 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S967236AbaFTMOS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 08:14:18 -0400
In-Reply-To: <20140620121118.GR32514@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both transmit and receive use the same infrastructure for calculating
the packet timestamp.  Rather than duplicating the code, provide a
function to do this common work.  Model this function in the Intel
e1000e version which avoids calling ns_to_ktime() within the spinlock;
the spinlock is critical for timecounter_cyc2time() but not
ns_to_ktime().

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/freescale/fec_main.c | 37 ++++++++++++++++---------------
 1 file changed, 19 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 3dbba3354aef..551a2015b253 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1065,6 +1065,21 @@ static void fec_enet_timeout_work(struct work_struct *work)
 }
 
 static void
+fec_enet_hwtstamp(struct fec_enet_private *fep, unsigned ts,
+	struct skb_shared_hwtstamps *hwtstamps)
+{
+	unsigned long flags;
+	u64 ns;
+
+	spin_lock_irqsave(&fep->tmreg_lock, flags);
+	ns = timecounter_cyc2time(&fep->tc, ts);
+	spin_unlock_irqrestore(&fep->tmreg_lock, flags);
+
+	memset(hwtstamps, 0, sizeof(*hwtstamps));
+	hwtstamps->hwtstamp = ns_to_ktime(ns);
+}
+
+static void
 fec_enet_tx(struct net_device *ndev)
 {
 	struct	fec_enet_private *fep;
@@ -1122,14 +1137,9 @@ fec_enet_tx(struct net_device *ndev)
 		if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS) &&
 			fep->bufdesc_ex) {
 			struct skb_shared_hwtstamps shhwtstamps;
-			unsigned long flags;
 			struct bufdesc_ex *ebdp = (struct bufdesc_ex *)bdp;
 
-			memset(&shhwtstamps, 0, sizeof(shhwtstamps));
-			spin_lock_irqsave(&fep->tmreg_lock, flags);
-			shhwtstamps.hwtstamp = ns_to_ktime(
-				timecounter_cyc2time(&fep->tc, ebdp->ts));
-			spin_unlock_irqrestore(&fep->tmreg_lock, flags);
+			fec_enet_hwtstamp(fep, ebdp->ts, &shhwtstamps);
 			skb_tstamp_tx(skb, &shhwtstamps);
 		}
 
@@ -1289,18 +1299,9 @@ fec_enet_rx(struct net_device *ndev, int budget)
 			skb->protocol = eth_type_trans(skb, ndev);
 
 			/* Get receive timestamp from the skb */
-			if (fep->hwts_rx_en && fep->bufdesc_ex) {
-				struct skb_shared_hwtstamps *shhwtstamps =
-							    skb_hwtstamps(skb);
-				unsigned long flags;
-
-				memset(shhwtstamps, 0, sizeof(*shhwtstamps));
-
-				spin_lock_irqsave(&fep->tmreg_lock, flags);
-				shhwtstamps->hwtstamp = ns_to_ktime(
-				    timecounter_cyc2time(&fep->tc, ebdp->ts));
-				spin_unlock_irqrestore(&fep->tmreg_lock, flags);
-			}
+			if (fep->hwts_rx_en && fep->bufdesc_ex)
+				fec_enet_hwtstamp(fep, ebdp->ts,
+						  skb_hwtstamps(skb));
 
 			if (fep->bufdesc_ex &&
 			    (fep->csum_flags & FLAG_RX_CSUM_ENABLED)) {
-- 
1.8.3.1
