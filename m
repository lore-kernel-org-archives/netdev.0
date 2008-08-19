From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Tue, 19 Aug 2008 04:02:00 -0700 (PDT)
Message-ID: <20080819.040200.155911269.davem@davemloft.net>
References: <20080819.035406.107673885.davem@davemloft.net>
	<20080819105551.GA30114@gondor.apana.org.au>
	<20080819105815.GA30148@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57443
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750882AbYHSLCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 07:02:00 -0400
In-Reply-To: <20080819105815.GA30148@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 19 Aug 2008 20:58:15 +1000

> On Tue, Aug 19, 2008 at 08:55:51PM +1000, Herbert Xu wrote:
> > On Tue, Aug 19, 2008 at 03:54:06AM -0700, David Miller wrote:
> > >
> > > Every qdisc_run() will invoke __netif_schedule() so it is
> > > a fast path I think :-)
> > 
> > Argh, I meant __netif_reschedule which shouldn't be the fast path.
> 
> Nevermind, both paths call __netif_reschedule :)
> 
> OK, how about just moving it to the else clause in net_tx_action?

I just checked the following into net-2.6

pkt_sched: Prevent livelock in TX queue running.

If dev_deactivate() is trying to quiesce the queue, it
is theoretically possible for another cpu to livelock
trying to process that queue.  This happens because
dev_deactivate() grabs the queue spinlock as it checks
the queue state, whereas net_tx_action() does a trylock
and reschedules the qdisc if it hits the lock.

This breaks the livelock by adding a check on
__QDISC_STATE_DEACTIVATED to net_tx_action() when
the trylock fails.

Based upon feedback from Herbert Xu and Jarek Poplawski.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/dev.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 8d13380..60c51f7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1990,7 +1990,9 @@ static void net_tx_action(struct softirq_action *h)
 				qdisc_run(q);
 				spin_unlock(root_lock);
 			} else {
-				__netif_reschedule(q);
+				if (!test_bit(__QDISC_STATE_DEACTIVATED,
+					      &q->state))
+					__netif_reschedule(q);
 			}
 		}
 	}
-- 
1.5.6.5.GIT

