From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH net-next] dp83640: Make use of skb_queue_purge instead of
 reimplementing the code
Date: Mon, 08 Sep 2014 11:25:34 -0400
Message-ID: <20140908152226.4202.72383.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:10882 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753206AbaIHPeH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Sep 2014 11:34:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change makes it so that dp83640_remove can use skb_queue_purge
instead of looping through itself to flush any entries out of the queue.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 drivers/net/phy/dp83640.c |    8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index 87648b3..99b5d20 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -1136,7 +1136,6 @@ static void dp83640_remove(struct phy_device *phydev)
 	struct dp83640_clock *clock;
 	struct list_head *this, *next;
 	struct dp83640_private *tmp, *dp83640 = phydev->priv;
-	struct sk_buff *skb;
 
 	if (phydev->addr == BROADCAST_ADDR)
 		return;
@@ -1144,11 +1143,8 @@ static void dp83640_remove(struct phy_device *phydev)
 	enable_status_frames(phydev, false);
 	cancel_work_sync(&dp83640->ts_work);
 
-	while ((skb = skb_dequeue(&dp83640->rx_queue)) != NULL)
-		kfree_skb(skb);
-
-	while ((skb = skb_dequeue(&dp83640->tx_queue)) != NULL)
-		kfree_skb(skb);
+	skb_queue_purge(&dp83640->rx_queue);
+	skb_queue_purge(&dp83640->tx_queue);
 
 	clock = dp83640_clock_get(dp83640->clock);
 
