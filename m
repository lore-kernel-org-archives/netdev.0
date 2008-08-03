From: David Miller <davem@davemloft.net>
Subject: [PATCH]: wme qdisc locking tweak...
Date: Sat, 02 Aug 2008 23:54:50 -0700 (PDT)
Message-ID: <20080802.235450.193701541.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47299
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751845AbYHCGyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Aug 2008 02:54:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is as a result of what was discovered while fixing:

http://marc.info/?l=linux-netdev&m=121763401922311&w=2

I've checked this into net-2.6

--------------------

mac80211: Use queue_lock() in ieee80211_ht_agg_queue_remove().

qdisc_root_lock() is only %100 safe to use when the RTNL
semaphore is held.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/mac80211/wme.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/mac80211/wme.c b/net/mac80211/wme.c
index 28437f0..4310e2f 100644
--- a/net/mac80211/wme.c
+++ b/net/mac80211/wme.c
@@ -241,12 +241,14 @@ void ieee80211_ht_agg_queue_remove(struct ieee80211_local *local,
 	} else {
 		struct netdev_queue *txq;
 		spinlock_t *root_lock;
+		struct Qdisc *q;
 
 		txq = netdev_get_tx_queue(local->mdev, agg_queue);
-		root_lock = qdisc_root_lock(txq->qdisc);
+		q = rcu_dereference(txq->qdisc);
+		root_lock = qdisc_lock(q);
 
 		spin_lock_bh(root_lock);
-		qdisc_reset(txq->qdisc);
+		qdisc_reset(q);
 		spin_unlock_bh(root_lock);
 	}
 }
-- 
1.5.6.GIT

