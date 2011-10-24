From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH v3 2/2] dp83640: free packet queues on remove
Date: Mon, 24 Oct 2011 19:55:32 +0200
Message-ID: <702220595edddaf7f2e6f0994e762b1a5404f793.1319478544.git.richard.cochran@omicron.at>
References: <cover.1319478544.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	<stable@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:51247 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755853Ab1JXRzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2011 13:55:50 -0400
In-Reply-To: <cover.1319478544.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1319478544.git.richard.cochran@omicron.at>
References: <cover.1319478544.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the PHY should disappear (for example, on an USB Ethernet MAC), then
the driver would leak any undelivered time stamp packets. This commit
fixes the issue by calling the appropriate functions to free any packets
left in the transmit and receive queues.

The driver first appeared in v3.0.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: <stable@vger.kernel.org>
---
 drivers/net/phy/dp83640.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index 311f5cb..dc44b73 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -875,6 +875,7 @@ static void dp83640_remove(struct phy_device *phydev)
 	struct dp83640_clock *clock;
 	struct list_head *this, *next;
 	struct dp83640_private *tmp, *dp83640 = phydev->priv;
+	struct sk_buff *skb;
 
 	if (phydev->addr == BROADCAST_ADDR)
 		return;
@@ -882,6 +883,12 @@ static void dp83640_remove(struct phy_device *phydev)
 	enable_status_frames(phydev, false);
 	cancel_work_sync(&dp83640->ts_work);
 
+	while ((skb = skb_dequeue(&dp83640->rx_queue)) != NULL)
+		kfree_skb(skb);
+
+	while ((skb = skb_dequeue(&dp83640->tx_queue)) != NULL)
+		skb_complete_tx_timestamp(skb, NULL);
+
 	clock = dp83640_clock_get(dp83640->clock);
 
 	if (dp83640 == clock->chosen) {
-- 
1.7.2.5
