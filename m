From: Manfred Rudigier <manfred.rudigier@omicron.at>
Subject: [PATCH] net: dp83640: Fix tx timestamp overflow handling.
Date: Wed, 20 Jan 2016 11:22:28 +0100
Message-ID: <1453285348-16022-1-git-send-email-manfred.rudigier@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <richardcochran@gmail.com>, <netdev@vger.kernel.org>,
	Manfred Rudigier <manfred.rudigier@omicron.at>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.omicron.at ([212.183.10.25]:59952 "EHLO ns.omicron.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933862AbcATKoT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jan 2016 05:44:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PHY status frames are not reliable, the PHY may not be able to send them
during heavy receive traffic. This overflow condition is signaled by the
PHY in the next status frame, but the driver did not make use of it.
Instead it always reported wrong tx timestamps to user space after an
overflow happened because it assigned newly received tx timestamps to old
packets in the queue.

This commit fixes this issue by clearing the tx timestamp queue every time
an overflow happens, so that no timestamps are delivered for overflow
packets. This way time stamping will continue correctly after an overflow.

Signed-off-by: Manfred Rudigier <manfred.rudigier@omicron.at>
---
 drivers/net/phy/dp83640.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index 180f699..7a240fc 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -846,6 +846,11 @@ static void decode_rxts(struct dp83640_private *dp83640,
 	struct skb_shared_hwtstamps *shhwtstamps = NULL;
 	struct sk_buff *skb;
 	unsigned long flags;
+	u8 overflow;
+
+	overflow = (phy_rxts->ns_hi >> 14) & 0x3;
+	if (overflow)
+		pr_debug("rx timestamp queue overflow, count %d\n", overflow);
 
 	spin_lock_irqsave(&dp83640->rx_lock, flags);
 
@@ -888,6 +893,7 @@ static void decode_txts(struct dp83640_private *dp83640,
 	struct skb_shared_hwtstamps shhwtstamps;
 	struct sk_buff *skb;
 	u64 ns;
+	u8 overflow;
 
 	/* We must already have the skb that triggered this. */
 
@@ -897,6 +903,17 @@ static void decode_txts(struct dp83640_private *dp83640,
 		pr_debug("have timestamp but tx_queue empty\n");
 		return;
 	}
+
+	overflow = (phy_txts->ns_hi >> 14) & 0x3;
+	if (overflow) {
+		pr_debug("tx timestamp queue overflow, count %d\n", overflow);
+		while (skb) {
+			skb_complete_tx_timestamp(skb, NULL);
+			skb = skb_dequeue(&dp83640->tx_queue);
+		}
+		return;
+	}
+
 	ns = phy2txts(phy_txts);
 	memset(&shhwtstamps, 0, sizeof(shhwtstamps));
 	shhwtstamps.hwtstamp = ns_to_ktime(ns);
-- 
1.9.1
