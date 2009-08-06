From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 6/8] sky2: Lock tx queue when calling sky2_down locally
Date: Thu, 06 Aug 2009 09:12:19 -0700
Message-ID: <20090806161232.922207774@vyatta.com>
References: <20090806161213.148382653@vyatta.com>
Cc: netdev@vger.kernel.org, Mike McCormack <mikem@ring3k.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:38262 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756235AbZHFQor (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Aug 2009 12:44:47 -0400
Content-Disposition: inline; filename=sky2-tx5.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Mike McCormack <mikem@ring3k.org>
Acked-by: Stephen Hemminger <shemminger@vyatta.com>
---
 drivers/net/sky2.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index dbedee4..972c716 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -3078,10 +3078,13 @@ static void sky2_restart(struct work_struct *work)
 	int i, err;

 	rtnl_lock();
+
 	for (i = 0; i < hw->ports; i++) {
 		dev = hw->dev[i];
-		if (netif_running(dev))
+		if (netif_running(dev)) {
+			netif_tx_lock(dev);
 			sky2_down(dev);
+		}
 	}

 	napi_disable(&hw->napi);
@@ -3099,6 +3102,8 @@ static void sky2_restart(struct work_struct *work)
 				       dev->name, err);
 				dev_close(dev);
 			}
+			else
+				netif_tx_unlock(dev);
 		}
 	}

@@ -3697,8 +3702,10 @@ static int sky2_set_ringparam(struct net_device *dev,
 	    ering->tx_pending > TX_RING_SIZE - 1)
 		return -EINVAL;

-	if (netif_running(dev))
+	if (netif_running(dev)) {
+		netif_tx_lock(dev);
 		sky2_down(dev);
+	}

 	sky2->rx_pending = ering->rx_pending;
 	sky2->tx_pending = ering->tx_pending;
@@ -3707,6 +3714,8 @@ static int sky2_set_ringparam(struct net_device *dev,
 		err = sky2_up(dev);
 		if (err)
 			dev_close(dev);
+		else
+			netif_tx_unlock(dev);
 	}

 	return err;
-- 
1.5.6.5

-- 

