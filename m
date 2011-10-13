From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 3/3] dp83640: free packet queues on remove
Date: Thu, 13 Oct 2011 11:46:29 +0200
Message-ID: <32e73bbe8141d803ebb58488e6cb60870bce4975.1318498805.git.richard.cochran@omicron.at>
References: <cover.1318498805.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Johannes Berg <johannes@sipsolutions.net>, <stable@kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:37737 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754305Ab1JMJqn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 05:46:43 -0400
Received: by mail-ey0-f174.google.com with SMTP id 27so1641047eye.19
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2011 02:46:42 -0700 (PDT)
In-Reply-To: <cover.1318498805.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1318498805.git.richard.cochran@omicron.at>
References: <56185ca8a7dc0223031ca0f0996302cac1b497eb.1318444117.git.richard.cochran@omicron.at> <cover.1318498805.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the PHY should disappear (for example, on an USB Ethernet MAC), then
the driver would leak any undelivered time stamp packets. This commit
fixes the issue by calling the appropriate functions to free any packets
left in the transmit and receive queues.

The driver first appeared in v3.0.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
Cc: <stable@kernel.org>
---
 drivers/net/phy/dp83640.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index 13e5713..9663e0b 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -1007,6 +1007,7 @@ static void dp83640_remove(struct phy_device *phydev)
 	struct dp83640_clock *clock;
 	struct list_head *this, *next;
 	struct dp83640_private *tmp, *dp83640 = phydev->priv;
+	struct sk_buff *skb;
 
 	if (phydev->addr == BROADCAST_ADDR)
 		return;
@@ -1014,6 +1015,12 @@ static void dp83640_remove(struct phy_device *phydev)
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
