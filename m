From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: [PATCH v2] net/mv643xx: don't disable the mib timer too early and
	lock properly
Date: Mon, 16 Feb 2009 22:28:15 +0100
Message-ID: <20090216212815.GA21732@Chamillionaire.breakpoint.cc>
References: <20090215092719.GB12280@Chamillionaire.breakpoint.cc> <20090216082922.GA18030@Chamillionaire.breakpoint.cc> <20090216145610.GX17914@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:52433 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750727AbZBPV2U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2009 16:28:20 -0500
Content-Disposition: inline
In-Reply-To: <20090216145610.GX17914@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mib_counters_update() also restarts the timer.
So the timer is dequeued, the stats are read and then the timer is
enqueued again. This is "okay" unless someone unloads the module.
The locking here is also broken:
mib_counters_update() grabs just a simple spinlock. The only thing the
lock is good for is to protect the timer func against other callers
namely mv643xx_eth_stop() && mv643xx_eth_get_ethtool_stats(). That means
if the spinlock is taken via the ethtool path and than the timer kicks
in then the box will lock up.

Signed-off-by: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
---
 drivers/net/mv643xx_eth.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 6977abe..582b346 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1173,7 +1173,7 @@ static void mib_counters_update(struct mv643xx_eth_private *mp)
 {
 	struct mib_counters *p = &mp->mib_counters;
 
-	spin_lock(&mp->mib_counters_lock);
+	spin_lock_bh(&mp->mib_counters_lock);
 	p->good_octets_received += mib_read(mp, 0x00);
 	p->good_octets_received += (u64)mib_read(mp, 0x04) << 32;
 	p->bad_octets_received += mib_read(mp, 0x08);
@@ -1206,7 +1206,7 @@ static void mib_counters_update(struct mv643xx_eth_private *mp)
 	p->bad_crc_event += mib_read(mp, 0x74);
 	p->collision += mib_read(mp, 0x78);
 	p->late_collision += mib_read(mp, 0x7c);
-	spin_unlock(&mp->mib_counters_lock);
+	spin_unlock_bh(&mp->mib_counters_lock);
 
 	mod_timer(&mp->mib_counters_timer, jiffies + 30 * HZ);
 }
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
