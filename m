From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 1/2] pkt_sched: Fix gen_estimator locks
Date: Tue, 26 Aug 2008 01:08:48 +0200
Message-ID: <20080825230848.GB12082@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:42184 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753763AbYHYXHh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2008 19:07:37 -0400
Received: by nf-out-0910.google.com with SMTP id d3so838817nfc.21
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2008 16:07:35 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pkt_sched: Fix gen_estimator locks

While passing a qdisc root lock to gen_new_estimator() and
gen_replace_estimator() dev could be deactivated or even before
grafting proper root qdisc as qdisc_sleeping (e.g. qdisc_create),
so using qdisc_root_lock() is not enough. This patch adds
qdisc_root_sleeping_lock() for this, plus additional checks, where
necessary.


Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

 include/net/sch_generic.h |    8 ++++++++
 net/sched/sch_api.c       |   14 +++++++++++---
 net/sched/sch_cbq.c       |    4 ++--
 net/sched/sch_hfsc.c      |    4 ++--
 net/sched/sch_htb.c       |    4 ++--
 5 files changed, 25 insertions(+), 9 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index b1d2cfe..ef8a7e2 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -217,6 +217,14 @@ static inline spinlock_t *qdisc_root_lock(struct Qdisc *qdisc)
 	return qdisc_lock(root);
 }
 
+static inline spinlock_t *qdisc_root_sleeping_lock(struct Qdisc *qdisc)
+{
+	struct Qdisc *root = qdisc_root_sleeping(qdisc);
+
+	ASSERT_RTNL();
+	return qdisc_lock(root);
+}
+
 static inline struct net_device *qdisc_dev(struct Qdisc *qdisc)
 {
 	return qdisc->dev_queue->dev;
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index e7fb9e0..4f9397f 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -830,9 +830,16 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 			sch->stab = stab;
 		}
 		if (tca[TCA_RATE]) {
+			spinlock_t *root_lock;
+
+			if ((sch->parent != TC_H_ROOT) &&
+			    !(sch->flags & TCQ_F_INGRESS))
+				root_lock = qdisc_root_sleeping_lock(sch);
+			else
+				root_lock = qdisc_lock(sch);
+
 			err = gen_new_estimator(&sch->bstats, &sch->rate_est,
-						qdisc_root_lock(sch),
-						tca[TCA_RATE]);
+						root_lock, tca[TCA_RATE]);
 			if (err) {
 				/*
 				 * Any broken qdiscs that would require
@@ -884,7 +891,8 @@ static int qdisc_change(struct Qdisc *sch, struct nlattr **tca)
 
 	if (tca[TCA_RATE])
 		gen_replace_estimator(&sch->bstats, &sch->rate_est,
-				      qdisc_root_lock(sch), tca[TCA_RATE]);
+				      qdisc_root_sleeping_lock(sch),
+				      tca[TCA_RATE]);
 	return 0;
 }
 
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 8fa90d6..9b720ad 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1839,7 +1839,7 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **t
 
 		if (tca[TCA_RATE])
 			gen_replace_estimator(&cl->bstats, &cl->rate_est,
-					      qdisc_root_lock(sch),
+					      qdisc_root_sleeping_lock(sch),
 					      tca[TCA_RATE]);
 		return 0;
 	}
@@ -1930,7 +1930,7 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **t
 
 	if (tca[TCA_RATE])
 		gen_new_estimator(&cl->bstats, &cl->rate_est,
-				  qdisc_root_lock(sch), tca[TCA_RATE]);
+				  qdisc_root_sleeping_lock(sch), tca[TCA_RATE]);
 
 	*arg = (unsigned long)cl;
 	return 0;
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index c2b8d9c..c1e77da 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1045,7 +1045,7 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 
 		if (tca[TCA_RATE])
 			gen_replace_estimator(&cl->bstats, &cl->rate_est,
-					      qdisc_root_lock(sch),
+					      qdisc_root_sleeping_lock(sch),
 					      tca[TCA_RATE]);
 		return 0;
 	}
@@ -1104,7 +1104,7 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 
 	if (tca[TCA_RATE])
 		gen_new_estimator(&cl->bstats, &cl->rate_est,
-				  qdisc_root_lock(sch), tca[TCA_RATE]);
+				  qdisc_root_sleeping_lock(sch), tca[TCA_RATE]);
 	*arg = (unsigned long)cl;
 	return 0;
 }
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 0df0df2..97d4761 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1372,7 +1372,7 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 			goto failure;
 
 		gen_new_estimator(&cl->bstats, &cl->rate_est,
-				  qdisc_root_lock(sch),
+				  qdisc_root_sleeping_lock(sch),
 				  tca[TCA_RATE] ? : &est.nla);
 		cl->refcnt = 1;
 		cl->children = 0;
@@ -1427,7 +1427,7 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 	} else {
 		if (tca[TCA_RATE])
 			gen_replace_estimator(&cl->bstats, &cl->rate_est,
-					      qdisc_root_lock(sch),
+					      qdisc_root_sleeping_lock(sch),
 					      tca[TCA_RATE]);
 		sch_tree_lock(sch);
 	}
