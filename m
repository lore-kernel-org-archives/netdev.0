From: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
        <stefan.sorensen@spectralink.com>
Subject: [PATCH net-next] dp83640: don't hold spinlock while calling netif_rx_ni
Date: Wed, 30 Aug 2017 08:58:47 +0200
Message-ID: <20170830065847.2444-1-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
        <stefan.sorensen@spectralink.com>
To: richardcochran@gmail.com, netdev@vger.kernel.org,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0118.outbound.protection.outlook.com ([104.47.42.118]:23245
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750824AbdH3G7P (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Aug 2017 02:59:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should not hold a spinlock while pushing the skb into the networking
stack, so move the call to netif_rx_ni out of the critical region to where
we have dropped the spinlock.

Signed-off-by: Stefan Sørensen <stefan.sorensen@spectralink.com>
---
 drivers/net/phy/dp83640.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index c3065236ffcc..cbd629822f04 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -874,7 +874,6 @@ static void decode_rxts(struct dp83640_private *dp83640,
 			shhwtstamps = skb_hwtstamps(skb);
 			memset(shhwtstamps, 0, sizeof(*shhwtstamps));
 			shhwtstamps->hwtstamp = ns_to_ktime(rxts->ns);
-			netif_rx_ni(skb);
 			list_add(&rxts->list, &dp83640->rxpool);
 			break;
 		}
@@ -885,6 +884,9 @@ static void decode_rxts(struct dp83640_private *dp83640,
 		list_add_tail(&rxts->list, &dp83640->rxts);
 out:
 	spin_unlock_irqrestore(&dp83640->rx_lock, flags);
+
+	if (shhwtstamps)
+		netif_rx_ni(skb);
 }
 
 static void decode_txts(struct dp83640_private *dp83640,
@@ -1425,7 +1427,6 @@ static bool dp83640_rxtstamp(struct phy_device *phydev,
 			shhwtstamps = skb_hwtstamps(skb);
 			memset(shhwtstamps, 0, sizeof(*shhwtstamps));
 			shhwtstamps->hwtstamp = ns_to_ktime(rxts->ns);
-			netif_rx_ni(skb);
 			list_del_init(&rxts->list);
 			list_add(&rxts->list, &dp83640->rxpool);
 			break;
@@ -1438,6 +1439,8 @@ static bool dp83640_rxtstamp(struct phy_device *phydev,
 		skb_info->tmo = jiffies + SKB_TIMESTAMP_TIMEOUT;
 		skb_queue_tail(&dp83640->rx_queue, skb);
 		schedule_delayed_work(&dp83640->ts_work, SKB_TIMESTAMP_TIMEOUT);
+	} else {
+		netif_rx_ni(skb);
 	}
 
 	return true;
-- 
2.13.5
