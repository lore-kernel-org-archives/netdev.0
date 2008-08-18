From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Sun, 17 Aug 2008 23:38:01 -0700 (PDT)
Message-ID: <20080817.233801.264840897.davem@davemloft.net>
References: <20080818013633.GA31653@gondor.apana.org.au>
	<20080817.184921.08829673.davem@davemloft.net>
	<20080818062747.GA2732@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55606
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751083AbYHRGiD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 02:38:03 -0400
In-Reply-To: <20080818062747.GA2732@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 18 Aug 2008 06:27:47 +0000

> But, there is probably something other to bother here. I didn't get
> the final version of this patch nor I can see this on the list, but
> in your git there is this change to "goto out_kfree_skb", which
> seems to skip rcu_read_unlock_bh().

That's a bug I added when I implemented Herber't suggestion
to just drop the packet.  Good spotting.

I've just pushed the following fix, thanks!

pkt_sched: Fix missed RCU unlock in dev_queue_xmit()

Noticed by Jarek Poplawski.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/dev.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 819f017..8d13380 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1805,14 +1805,12 @@ gso:
 		spin_lock(root_lock);
 
 		if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED, &q->state))) {
-			spin_unlock(root_lock);
+			kfree_skb(skb);
 			rc = NET_XMIT_DROP;
-			goto out_kfree_skb;
+		} else {
+			rc = qdisc_enqueue_root(skb, q);
+			qdisc_run(q);
 		}
-
-		rc = qdisc_enqueue_root(skb, q);
-		qdisc_run(q);
-
 		spin_unlock(root_lock);
 
 		goto out;
-- 
1.5.6.5.GIT

