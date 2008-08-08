From: David Miller <davem@davemloft.net>
Subject: Re: qdisc and down links (regression)
Date: Thu, 07 Aug 2008 18:50:24 -0700 (PDT)
Message-ID: <20080807.185024.155026077.davem@davemloft.net>
References: <20080807143036.1ae10482@extreme>
	<20080807.154735.148985698.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vgr.kernel.org
To: stephen.hemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52359
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752778AbYHHBuX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 21:50:23 -0400
In-Reply-To: <20080807.154735.148985698.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Thu, 07 Aug 2008 15:47:35 -0700 (PDT)

> From: Stephen Hemminger <stephen.hemminger@vyatta.com>
> Date: Thu, 7 Aug 2008 14:30:36 -0700
> 
> > Before the mulitqueue changes in 2.6.27-rc it was possible to setup
> > queueing disciplines before the link came up (carrier active). This
> > no longer works. If link is down, the qdisc is the noop_qdisc and
> > any configuration changes don't seem to be shown.
> 
> I'll see why this happens, it wasn't an intentional change.

This should fix it, let me know if it doesn't:

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 83b23b5..ba1d121 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -189,7 +189,7 @@ struct Qdisc *qdisc_lookup(struct net_device *dev, u32 handle)
 
 	for (i = 0; i < dev->num_tx_queues; i++) {
 		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
-		struct Qdisc *q, *txq_root = txq->qdisc;
+		struct Qdisc *q, *txq_root = txq->qdisc_sleeping;
 
 		if (!(txq_root->flags & TCQ_F_BUILTIN) &&
 		    txq_root->handle == handle)
@@ -793,7 +793,7 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 			}
 		}
 		if ((parent != TC_H_ROOT) && !(sch->flags & TCQ_F_INGRESS))
-			list_add_tail(&sch->list, &dev_queue->qdisc->list);
+			list_add_tail(&sch->list, &dev_queue->qdisc_sleeping->list);
 
 		return sch;
 	}
@@ -1236,11 +1236,11 @@ static int tc_dump_qdisc(struct sk_buff *skb, struct netlink_callback *cb)
 		q_idx = 0;
 
 		dev_queue = netdev_get_tx_queue(dev, 0);
-		if (tc_dump_qdisc_root(dev_queue->qdisc, skb, cb, &q_idx, s_q_idx) < 0)
+		if (tc_dump_qdisc_root(dev_queue->qdisc_sleeping, skb, cb, &q_idx, s_q_idx) < 0)
 			goto done;
 
 		dev_queue = &dev->rx_queue;
-		if (tc_dump_qdisc_root(dev_queue->qdisc, skb, cb, &q_idx, s_q_idx) < 0)
+		if (tc_dump_qdisc_root(dev_queue->qdisc_sleeping, skb, cb, &q_idx, s_q_idx) < 0)
 			goto done;
 
 cont:
