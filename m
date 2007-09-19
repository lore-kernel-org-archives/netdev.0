From: David Miller <davem@davemloft.net>
Subject: Re: new NAPI quota synchronization issue
Date: Wed, 19 Sep 2007 15:10:32 -0700 (PDT)
Message-ID: <20070919.151032.118951762.davem@davemloft.net>
References: <20070919.095825.39465358.davem@davemloft.net>
	<20070919.103508.59469052.davem@davemloft.net>
	<20070919150129.7b0967f7@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52543
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750875AbXISWKc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 18:10:32 -0400
In-Reply-To: <20070919150129.7b0967f7@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 19 Sep 2007 15:01:29 -0700

> There might be a future problem if some driver decided to change
> weight often on the fly?  Perhaps you need to sample it once in
> start of napi_schedule.

Fair enough, I checked the following into net-2.6.24

commit 3b4eed9f46e4b0405a0d8921c2319f2b7c6a6b4a
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Wed Sep 19 15:09:55 2007 -0700

    [NAPI]: Sample weight into a local var in case it changes.
    
    Noted by Stephen Hemminger.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/core/dev.c b/net/core/dev.c
index 0b9f82e..91c31e6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2136,7 +2136,7 @@ static void net_rx_action(struct softirq_action *h)
 
 	while (!list_empty(list)) {
 		struct napi_struct *n;
-		int work;
+		int work, weight;
 
 		/* If softirq window is exhuasted then punt.
 		 *
@@ -2159,9 +2159,11 @@ static void net_rx_action(struct softirq_action *h)
 
 		have = netpoll_poll_lock(n);
 
-		work = n->poll(n, n->weight);
+		weight = n->weight;
 
-		WARN_ON_ONCE(work > n->weight);
+		work = n->poll(n, weight);
+
+		WARN_ON_ONCE(work > weight);
 
 		budget -= work;
 
@@ -2172,7 +2174,7 @@ static void net_rx_action(struct softirq_action *h)
 		 * still "owns" the NAPI instance and therefore can
 		 * move the instance around on the list at-will.
 		 */
-		if (unlikely(work == n->weight))
+		if (unlikely(work == weight))
 			list_move_tail(&n->poll_list, list);
 
 		netpoll_poll_unlock(have);
