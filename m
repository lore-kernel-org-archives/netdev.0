From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFT] proxy arp deadlock possible
Date: Wed, 4 Apr 2007 15:26:35 -0700
Message-ID: <20070404152635.7c3ba33e@localhost>
References: <20070404213050.GA19261@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:58280 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750782AbXDDW0q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2007 18:26:46 -0400
In-Reply-To: <20070404213050.GA19261@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks Dave, there is a classic AB BA deadlock here.
We should break the dependency like this.

Could someone who uses proxy ARP test this?
-----

Need to drop one of the locks to avoid deadlock between
proxy arp and incoming arp receive.
---
 net/core/neighbour.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index cfc6001..d6b3a62 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1212,6 +1212,7 @@ static void neigh_proxy_process(unsigned
 	unsigned long now = jiffies;
 	struct sk_buff *skb;
 
+rescan:
 	spin_lock(&tbl->proxy_queue.lock);
 
 	skb = tbl->proxy_queue.next;
@@ -1224,13 +1225,20 @@ static void neigh_proxy_process(unsigned
 		if (tdif <= 0) {
 			struct net_device *dev = back->dev;
 			__skb_unlink(back, &tbl->proxy_queue);
+
+			/* drop lock to avoid deadlock */
+			spin_unlock(&tbl->proxy_queue.lock);
+
 			if (tbl->proxy_redo && netif_running(dev))
 				tbl->proxy_redo(back);
 			else
 				kfree_skb(back);
 
 			dev_put(dev);
-		} else if (!sched_next || tdif < sched_next)
+			goto rescan;
+		}
+
+		if (!sched_next || tdif < sched_next)
 			sched_next = tdif;
 	}
 	del_timer(&tbl->proxy_timer);
-- 
1.4.1

