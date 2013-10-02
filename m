From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH 2/3] net: mv643xx_eth: fix orphaned statistics timer crash
Date: Wed,  2 Oct 2013 12:57:21 +0200
Message-ID: <1380711442-24735-3-git-send-email-sebastian.hesselbarth@gmail.com>
References: <1380711442-24735-1-git-send-email-sebastian.hesselbarth@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f43.google.com ([209.85.214.43]:34966 "EHLO
	mail-bk0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753425Ab3JBK5u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 06:57:50 -0400
In-Reply-To: <1380711442-24735-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The periodic statistics timer gets started at port _probe() time, but
is stopped on _stop() only. In a modular environment, this can cause
the timer to access already deallocated memory, if the module is unloaded
without starting the eth device. To fix this, we add the timer right
before the port is started, instead of at _probe() time.

Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
---
Cc: David Miller <davem@davemloft.net>
Cc: Lennert Buytenhek <buytenh@wantstofly.org>
Cc: Jason Cooper <jason@lakedaemon.net>
Cc: netdev@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/ethernet/marvell/mv643xx_eth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 44a87e4..2364707 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -2235,6 +2235,7 @@ static int mv643xx_eth_open(struct net_device *dev)
 		mp->int_mask |= INT_TX_END_0 << i;
 	}
 
+	add_timer(&mp->mib_counters_timer);
 	port_start(mp);
 
 	wrlp(mp, INT_MASK_EXT, INT_EXT_LINK_PHY | INT_EXT_TX);
@@ -2914,7 +2915,6 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	mp->mib_counters_timer.data = (unsigned long)mp;
 	mp->mib_counters_timer.function = mib_counters_timer_wrapper;
 	mp->mib_counters_timer.expires = jiffies + 30 * HZ;
-	add_timer(&mp->mib_counters_timer);
 
 	spin_lock_init(&mp->mib_counters_lock);
 
-- 
1.7.10.4
