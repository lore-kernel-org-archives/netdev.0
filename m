From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Thu, 14 Aug 2008 11:24:33 +0000
Message-ID: <20080814112433.GA12476@ff.dom.local>
References: <20080813102701.GD5367@ff.dom.local> <20080813104238.GA11374@gondor.apana.org.au> <20080813105052.GA6838@ff.dom.local> <20080813.151918.61294677.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:46035 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752294AbYHNLYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 07:24:46 -0400
Received: by fg-out-1718.google.com with SMTP id 19so359718fgg.17
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2008 04:24:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080813.151918.61294677.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 13, 2008 at 03:19:18PM -0700, David Miller wrote:
...
> Ok, so what I'm going to do is check in my patch and then try
> to figure out how to resolve this "both bits clear" scenerio.

BTW, here is my older doubt revisited, where I hope to be re-considered/
re-convinced, if possible...

Thanks,
Jarek P.

---------------->

pkt_sched: Destroy qdiscs under rtnl_lock again.

We don't need to trigger __qdisc_destroy() as an RCU callback because
the use of qdisc isn't controlled by RCU alone: after querying RCU
with synchronize_rcu() in dev_deactivate() we additionaly wait in a
loop checking some flags. After the loop is done there could be no
outstanding use of the qdisc, so call_rcu() doesn't make any sense.

On the other hand, current calling Qdisc's ->destroy() from a softirq
context without locking (rtnl) can break various things like:
qdisc_put_rtab(), tcf_destroy_chain() (e.g. u32_destroy()), and
probably more.


Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

 net/sched/sch_generic.c |    8 ++------
 1 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 4685746..e7379d2 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -518,12 +518,8 @@ void qdisc_reset(struct Qdisc *qdisc)
 }
 EXPORT_SYMBOL(qdisc_reset);
 
-/* this is the rcu callback function to clean up a qdisc when there
- * are no further references to it */
-
-static void __qdisc_destroy(struct rcu_head *head)
+static void __qdisc_destroy(struct Qdisc *qdisc)
 {
-	struct Qdisc *qdisc = container_of(head, struct Qdisc, q_rcu);
 	const struct Qdisc_ops  *ops = qdisc->ops;
 
 #ifdef CONFIG_NET_SCHED
@@ -554,7 +550,7 @@ void qdisc_destroy(struct Qdisc *qdisc)
 	if (qdisc->parent)
 		list_del(&qdisc->list);
 
-	call_rcu(&qdisc->q_rcu, __qdisc_destroy);
+	__qdisc_destroy(qdisc);
 }
 EXPORT_SYMBOL(qdisc_destroy);
 
