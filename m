From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH 5/5] sky2: Lock tx queue when calling sky2_down locally
Date: Mon, 3 Aug 2009 20:09:23 +0900
Message-ID: <392fb48f0908030409t5c3d2cafsd6fc25e9abe46f0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:8257 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753380AbZHCLJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2009 07:09:24 -0400
Received: by fg-out-1718.google.com with SMTP id e21so986107fga.17
        for <netdev@vger.kernel.org>; Mon, 03 Aug 2009 04:09:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Mike McCormack <mikem@ring3k.org>
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
