From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
        <u.kleine-koenig@pengutronix.de>
Subject: [PATCH net] net: ethernet: ax88796: don't call free_irq without request_irq first
Date: Thu, 25 May 2017 22:54:53 +0200
Message-ID: <20170525205453.21999-1-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, kernel@pengutronix.de,
        Ben Dooks <ben.dooks@codethink.co.uk>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:36293 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S938984AbdEYUzE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 16:55:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function ax_init_dev (which is called only from the driver's .probe
function) calls free_irq in the error path without having requested the
irq in the first place. So drop the free_irq call in the error path.

Fixes: 825a2ff1896e ("AX88796 network driver")
Signed-off-by: Uwe Kleine-König <u.kleine-koenig@pengutronix.de>
---
 drivers/net/ethernet/8390/ax88796.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/8390/ax88796.c b/drivers/net/ethernet/8390/ax88796.c
index b0a3b85fc6f8..db02bc2fb4b2 100644
--- a/drivers/net/ethernet/8390/ax88796.c
+++ b/drivers/net/ethernet/8390/ax88796.c
@@ -748,13 +748,13 @@ static int ax_init_dev(struct net_device *dev)
 
 	ret = ax_mii_init(dev);
 	if (ret)
-		goto out_irq;
+		goto err_out;
 
 	ax_NS8390_init(dev, 0);
 
 	ret = register_netdev(dev);
 	if (ret)
-		goto out_irq;
+		goto err_out;
 
 	netdev_info(dev, "%dbit, irq %d, %lx, MAC: %pM\n",
 		    ei_local->word16 ? 16 : 8, dev->irq, dev->base_addr,
@@ -762,9 +762,6 @@ static int ax_init_dev(struct net_device *dev)
 
 	return 0;
 
- out_irq:
-	/* cleanup irq */
-	free_irq(dev->irq, dev);
  err_out:
 	return ret;
 }
-- 
2.11.0
