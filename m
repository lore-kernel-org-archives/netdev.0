From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 1/1] net_sched: drr: warn when qdisc is not work conserving
Date: Wed, 11 Jun 2014 20:35:18 +0200
Message-ID: <1402511718-24203-1-git-send-email-fw@strlen.de>
Cc: kaber@trash.net, Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:53118 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753481AbaFKSlo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 14:41:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The DRR scheduler requires that items on the active list are work
conserving, i.e. do not hold on to skbs for throttling purposes, etc.
Attaching e.g. tbf renders DRR useless because all other classes on the
active list are delayed as well.

So, warn users that this configuration won't work as expected; we
already do this in couple of other qdiscs, see e.g.

commit b00355db3f88d96810a60011a30cfb2c3469409d
('pkt_sched: sch_hfsc: sch_htb: Add non-work-conserving warning handler')

The 'const' change is needed to avoid compiler warning ("discards 'const'
qualifier from pointer target type").

tested with:
drr_hier() {
        parent=$1
        classes=$2
        for i in  $(seq 1 $classes); do
                classid=$parent$(printf %x $i)
                tc class add dev eth0 parent $parent classid $classid drr
		tc qdisc add dev eth0 parent $classid tbf rate 64kbit burst 256kbit limit 64kbit
        done
}
tc qdisc add dev eth0 root handle 1: drr
drr_hier 1: 32
tc filter add dev eth0 protocol all pref 1 parent 1: handle 1 flow hash keys dst perturb 1 divisor 32

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/pkt_sched.h | 2 +-
 net/sched/sch_api.c     | 2 +-
 net/sched/sch_drr.c     | 4 +++-
 3 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 891d80d..ec030cd 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -96,7 +96,7 @@ struct qdisc_rate_table *qdisc_get_rtab(struct tc_ratespec *r,
 					struct nlattr *tab);
 void qdisc_put_rtab(struct qdisc_rate_table *tab);
 void qdisc_put_stab(struct qdisc_size_table *tab);
-void qdisc_warn_nonwc(char *txt, struct Qdisc *qdisc);
+void qdisc_warn_nonwc(const char *txt, struct Qdisc *qdisc);
 int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 		    struct net_device *dev, struct netdev_queue *txq,
 		    spinlock_t *root_lock);
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index fd14df5..58bed75 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -563,7 +563,7 @@ out:
 }
 EXPORT_SYMBOL(__qdisc_calculate_pkt_len);
 
-void qdisc_warn_nonwc(char *txt, struct Qdisc *qdisc)
+void qdisc_warn_nonwc(const char *txt, struct Qdisc *qdisc)
 {
 	if (!(qdisc->flags & TCQ_F_WARN_NONWC)) {
 		pr_warn("%s: %s qdisc %X: is non-work-conserving?\n",
diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index 8302717..7bbbfe1 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -391,8 +391,10 @@ static struct sk_buff *drr_dequeue(struct Qdisc *sch)
 	while (1) {
 		cl = list_first_entry(&q->active, struct drr_class, alist);
 		skb = cl->qdisc->ops->peek(cl->qdisc);
-		if (skb == NULL)
+		if (skb == NULL) {
+			qdisc_warn_nonwc(__func__, cl->qdisc);
 			goto out;
+		}
 
 		len = qdisc_pkt_len(skb);
 		if (len <= cl->deficit) {
-- 
1.8.1.5
