From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 1/3 v2][NET] gen_estimator: faster gen_kill_estimator
Date: Tue, 22 Jan 2008 08:26:28 +0100
Message-ID: <20080122072627.GB977@ff.dom.local>
References: <20080121.162918.148129860.davem@davemloft.net> <20080122072152.GA977@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, slavon@bigtelecom.ru, kaber@trash.net,
	hadi@cyberus.ca
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hu-out-0506.google.com ([72.14.214.226]:4942 "EHLO
	hu-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750992AbYAVHTw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 02:19:52 -0500
Received: by hu-out-0506.google.com with SMTP id 19so940987hue.21
        for <netdev@vger.kernel.org>; Mon, 21 Jan 2008 23:19:50 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080122072152.GA977@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 22, 2008 at 08:21:52AM +0100, Jarek Poplawski wrote:
...

Part 2 of mini RFC:

HTB changes to use new, faster gen_estimator functions._

This is done against 2.6.24-rc8-mm1. 

Thanks,
Jarek P.

---

diff -Nurp 2.6.24-rc8-mm1-/net/sched/sch_htb.c 2.6.24-rc8-mm1+/net/sched/sch_htb.c
--- 2.6.24-rc8-mm1-/net/sched/sch_htb.c	2008-01-19 17:54:49.000000000 +0100
+++ 2.6.24-rc8-mm1+/net/sched/sch_htb.c	2008-01-22 00:00:31.000000000 +0100
@@ -127,6 +127,7 @@ struct htb_class {
 	int prio;		/* For parent to leaf return possible here */
 	int quantum;		/* we do backup. Finally full replacement  */
 				/* of un.leaf originals should be done. */
+	unsigned long	gen_estimator;	/* ngen_new_estimator() data */
 };
 
 static inline long L2T(struct htb_class *cl, struct qdisc_rate_table *rate,
@@ -1195,7 +1196,7 @@ static void htb_destroy_class(struct Qdi
 		BUG_TRAP(cl->un.leaf.q);
 		qdisc_destroy(cl->un.leaf.q);
 	}
-	gen_kill_estimator(&cl->bstats, &cl->rate_est);
+	ngen_kill_estimator(&cl->gen_estimator);
 	qdisc_put_rtab(cl->rate);
 	qdisc_put_rtab(cl->ceil);
 
@@ -1348,9 +1349,10 @@ static int htb_change_class(struct Qdisc
 		if ((cl = kzalloc(sizeof(*cl), GFP_KERNEL)) == NULL)
 			goto failure;
 
-		gen_new_estimator(&cl->bstats, &cl->rate_est,
-				  &sch->dev->queue_lock,
-				  tca[TCA_RATE-1] ? : &est.rta);
+		ngen_new_estimator(&cl->bstats, &cl->rate_est,
+				   &sch->dev->queue_lock,
+				   tca[TCA_RATE-1] ? : &est.rta,
+				   &cl->gen_estimator);
 		cl->refcnt = 1;
 		INIT_LIST_HEAD(&cl->sibling);
 		INIT_HLIST_NODE(&cl->hlist);
@@ -1404,9 +1406,10 @@ static int htb_change_class(struct Qdisc
 			      parent ? &parent->children : &q->root);
 	} else {
 		if (tca[TCA_RATE-1])
-			gen_replace_estimator(&cl->bstats, &cl->rate_est,
-					      &sch->dev->queue_lock,
-					      tca[TCA_RATE-1]);
+			ngen_replace_estimator(&cl->bstats, &cl->rate_est,
+					       &sch->dev->queue_lock,
+					       tca[TCA_RATE-1],
+					       &cl->gen_estimator);
 		sch_tree_lock(sch);
 	}
 
