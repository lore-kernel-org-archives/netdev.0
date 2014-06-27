From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH CFT 30/30] net: fec: consolidate hwtstamp implementation
Date: Fri, 27 Jun 2014 16:21:26 +0100
Message-ID: <E1X0Xxu-0001PB-Ia@rmk-PC.arm.linux.org.uk>
References: <20140627151542.GL32514@n2100.arm.linux.org.uk>
Cc: Fugang Duan <B38611@freescale.com>
To: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:45270 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753910AbaF0PV3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 11:21:29 -0400
In-Reply-To: <20140627151542.GL32514@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both transmit and receive use the same infrastructure for calculating
the packet timestamp.  Rather than duplicating the code, provide a
function to do this common work.  Model this function in the Intel
e1000e version which avoids calling ns_to_ktime() within the spinlock;
the spinlock is critical for timecounter_cyc2time() but not
ns_to_ktime().

Acked-by: Richard Cochran <richardcochran@gmail.com>
Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/freescale/fec_main.c | 37 ++++++++++++++++---------------
 1 file changed, 19 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 916b9ab97da4..dc925136ff01 100644
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
 
@@ -1288,18 +1298,9 @@ fec_enet_rx(struct net_device *ndev, int budget)
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
