From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 4/9] netem: add locking around changes
Date: Fri, 06 Aug 2010 12:35:52 -0700
Message-ID: <20100806193558.845268051@vyatta.com>
References: <20100806193548.007978639@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:35713 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761963Ab0HFTiH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Aug 2010 15:38:07 -0400
Content-Disposition: inline; filename=netem-cleanup.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some safety improvements to netem to make it safer to change paramters
while queue is running.

Use sch_tree_lock() to block all packets during change.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/sched/sch_netem.c	2010-08-02 16:22:42.389335747 -0700
+++ b/net/sched/sch_netem.c	2010-08-03 08:25:15.611820853 -0700
@@ -318,7 +318,6 @@ static int get_dist_table(struct Qdisc *
 	struct netem_sched_data *q = qdisc_priv(sch);
 	unsigned long n = nla_len(attr)/sizeof(__s16);
 	const __s16 *data = nla_data(attr);
-	spinlock_t *root_lock;
 	struct disttable *d;
 	int i;
 
@@ -333,12 +332,9 @@ static int get_dist_table(struct Qdisc *
 	for (i = 0; i < n; i++)
 		d->table[i] = data[i];
 
-	root_lock = qdisc_root_sleeping_lock(sch);
-
-	spin_lock_bh(root_lock);
 	kfree(q->delay_dist);
 	q->delay_dist = d;
-	spin_unlock_bh(root_lock);
+
 	return 0;
 }
 
@@ -412,6 +408,7 @@ static int netem_change(struct Qdisc *sc
 		return ret;
 	}
 
+	sch_tree_lock(sch);
 	q->latency = qopt->latency;
 	q->jitter = qopt->jitter;
 	q->limit = qopt->limit;
@@ -432,7 +429,7 @@ static int netem_change(struct Qdisc *sc
 	if (tb[TCA_NETEM_DELAY_DIST]) {
 		ret = get_dist_table(sch, tb[TCA_NETEM_DELAY_DIST]);
 		if (ret)
-			return ret;
+			goto out;
 	}
 
 	if (tb[TCA_NETEM_REORDER])
@@ -440,6 +437,8 @@ static int netem_change(struct Qdisc *sc
 
 	if (tb[TCA_NETEM_CORRUPT])
 		get_corrupt(sch, tb[TCA_NETEM_CORRUPT]);
+ out:
+	sch_tree_unlock(sch);
 
 	return 0;
 }


