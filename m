From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH] dp83640: don't recieve time stamps twice
Date: Tue, 18 Apr 2017 22:14:26 +0300
Message-ID: <20170418191426.GA17838@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>,
        Stefan =?iso-8859-1?Q?S=F8rensen?=
        <stefan.sorensen@spectralink.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch is prompted by a static checker warning about a potential
use after free.  The concern is that netif_rx_ni() can free "skb" and we
call it twice.

When I look at the commit that added this, it looks like some stray
lines were added accidentally.  It doesn't make sense to me that we
would recieve the same data two times.  I asked the author but never
recieved a response.

I can't test this code, but I'm pretty sure my patch is correct.

Fixes: 4b063258ab93 ("dp83640: Delay scheduled work.")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index e2460a57e4b1..ed0d10f54f26 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -1438,8 +1438,6 @@ static bool dp83640_rxtstamp(struct phy_device *phydev,
 		skb_info->tmo = jiffies + SKB_TIMESTAMP_TIMEOUT;
 		skb_queue_tail(&dp83640->rx_queue, skb);
 		schedule_delayed_work(&dp83640->ts_work, SKB_TIMESTAMP_TIMEOUT);
-	} else {
-		netif_rx_ni(skb);
 	}
 
 	return true;
