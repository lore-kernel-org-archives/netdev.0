From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: panic 2.6.27-rc3-git2, qdisc_dequeue_head
Date: Sun, 17 Aug 2008 12:55:34 +0200
Message-ID: <20080817105534.GD2907@ami.dom.local>
References: <20080815190905.M56388@visp.net.lb> <200808171235.46413.denys@visp.net.lb> <20080817095220.GB2907@ami.dom.local> <200808171301.56002.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:41168 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751516AbYHQKzR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2008 06:55:17 -0400
Received: by ug-out-1314.google.com with SMTP id c2so96834ugf.37
        for <netdev@vger.kernel.org>; Sun, 17 Aug 2008 03:55:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200808171301.56002.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 17, 2008 at 01:01:55PM +0300, Denys Fedoryshchenko wrote:
> Ok, now things finally organized.
> fixing patch #1 was missing.
> 
> Rebooting system to this kernel. But strange thing, without fixing patch #1 it 
> didn't crash for whole night, and 1-3 hours now (with same options as 
> before).
> 
> Let's test now complete set of patches. I will keep around 2 hours on most 
> loaded pppoe NAS, then distribute to 2-3 servers more if it doesn't crash.

BTW, after you complete this testing (no hurry) I would be glad if you
could try one more patch which I send earlier to the list. IMHO, it's
needed to fix some other locking problems. This patch could be applied
and tested as an addition to all currently tested patches (but let's
first be sure they really work).

Thanks,
Jarek P.

------------->

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
 
--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

