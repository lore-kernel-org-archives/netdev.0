From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: [PATCH] net/mv643xx: don't disable the mib timer too early
Date: Sun, 15 Feb 2009 10:27:19 +0100
Message-ID: <20090215092719.GB12280@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:58017 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751512AbZBOJ1U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2009 04:27:20 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

because mib_counters_update() also restarts the timer.
So the timer is dequeued, the stats are read and then the timer is
enqueued again. This is okay, unless someone unloads the module.

Signed-off-by: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
---
 drivers/net/mv643xx_eth.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 6977abe..3c6847a 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -2213,8 +2213,6 @@ static int mv643xx_eth_stop(struct net_device *dev)
 	wrlp(mp, INT_MASK, 0x00000000);
 	rdlp(mp, INT_MASK);
 
-	del_timer_sync(&mp->mib_counters_timer);
-
 	napi_disable(&mp->napi);
 
 	del_timer_sync(&mp->rx_oom);
@@ -2226,6 +2224,7 @@ static int mv643xx_eth_stop(struct net_device *dev)
 	port_reset(mp);
 	mv643xx_eth_get_stats(dev);
 	mib_counters_update(mp);
+	del_timer_sync(&mp->mib_counters_timer);
 
 	skb_queue_purge(&mp->rx_recycle);
 
-- 
1.6.0.6

