From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: [PATCH 1/3] NIU: Implement discard counters
Date: Thu, 18 Dec 2008 14:54:20 +0100
Message-ID: <1229608460.16904.25.camel@localhost.localdomain>
References: <1229608331.16904.23.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, hawk@comx.dk
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:36780 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751212AbYLRNyW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 08:54:22 -0500
In-Reply-To: <1229608331.16904.23.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Implementing discard counters for the NIU driver turned out to be more
complicated than first assumed.

The discard counters for the NIU neptune chip is only 16-bit
(eventhough this is a 64-bit chip).  These 16-bit counters can
overflow quickly, especially considering this is a 10Gbit/s ethernet
card.

The overflow indication bit is, unfortunatly, not usable as the
counter value does not wrap, but remains at max value 0xFFFF.
Resulting in lost counts until the counter is reset.

The read and reset scheme also poses a problem. Both in theory and in
praxis counters can be lost in between reading nr64() and clearing the
counter nw64().  For this reason, the number of counter clearings
nw64() is limited/reduced.  On the fash-path the counters are only
syncronized once it exceeds 0x7FFF.  When read by userspace, 
its syncronized fully.

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---

 drivers/net/niu.c |   51 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 51 insertions(+), 0 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 1b6f548..1bd7018 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -3529,6 +3529,51 @@ out:
 	}
 }
 
+static inline void niu_sync_rx_discard_stats(struct niu *np,
+					     struct rx_ring_info *rp,
+					     const int limit)
+{
+	/* This elaborate scheme is needed for reading the RX discard
+	 * counters, as they are only 16-bit and can overflow quickly,
+	 * and because the overflow indication bit is not usable as
+	 * the counter value does not wrap, but remains at max value
+	 * 0xFFFF.
+	 *
+	 * In theory and in praxis counters can be lost in between
+	 * reading nr64() and clearing the counter nw64().  For this
+	 * reason, the number of counter clearings nw64() is
+	 * limited/reduced though the limit parameter.
+	 */
+	int rx_channel = rp->rx_channel;
+	u32 misc, wred;
+
+	/* RXMISC (Receive Miscellaneous Discard Count), covers the
+	 * following discard events: IPP (Input Port Process),
+	 * FFLP/TCAM, Full RCR (Receive Completion Ring) RBR (Receive
+	 * Block Ring) prefetch buffer is empty.
+	 */
+	misc = nr64(RXMISC(rx_channel));
+	if (unlikely((misc & RXMISC_COUNT) > limit)) {
+		nw64(RXMISC(rx_channel), 0);
+		rp->rx_errors += misc & RXMISC_COUNT;
+
+		if (unlikely(misc & RXMISC_OFLOW))
+			dev_err(np->device, "rx-%d: Counter overflow "
+				"RXMISC discard\n", rx_channel);
+	}
+
+	/* WRED (Weighted Random Early Discard) by hardware */
+	wred = nr64(RED_DIS_CNT(rx_channel));
+	if (unlikely((wred & RED_DIS_CNT_COUNT) > limit)) {
+		nw64(RED_DIS_CNT(rx_channel), 0);
+		rp->rx_dropped += wred & RED_DIS_CNT_COUNT;
+
+		if (unlikely(wred & RED_DIS_CNT_OFLOW))
+			dev_err(np->device, "rx-%d: Counter overflow "
+				"WRED discard\n", rx_channel);
+	}
+}
+
 static int niu_rx_work(struct niu *np, struct rx_ring_info *rp, int budget)
 {
 	int qlen, rcr_done = 0, work_done = 0;
@@ -3569,6 +3614,8 @@ static int niu_rx_work(struct niu *np, struct rx_ring_info *rp, int budget)
 
 	nw64(RX_DMA_CTL_STAT(rp->rx_channel), stat);
 
+	niu_sync_rx_discard_stats(np, rp, 0x7FFF);
+
 	return work_done;
 }
 
@@ -6050,6 +6097,8 @@ static void niu_get_rx_stats(struct niu *np)
 	for (i = 0; i < np->num_rx_rings; i++) {
 		struct rx_ring_info *rp = &np->rx_rings[i];
 
+		niu_sync_rx_discard_stats(np, rp, 0);
+
 		pkts += rp->rx_packets;
 		bytes += rp->rx_bytes;
 		dropped += rp->rx_dropped;
@@ -6991,6 +7040,8 @@ static void niu_get_ethtool_stats(struct net_device *dev,
 	for (i = 0; i < np->num_rx_rings; i++) {
 		struct rx_ring_info *rp = &np->rx_rings[i];
 
+		niu_sync_rx_discard_stats(np, rp, 0);
+
 		data[0] = rp->rx_channel;
 		data[1] = rp->rx_packets;
 		data[2] = rp->rx_bytes;


