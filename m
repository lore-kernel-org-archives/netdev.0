From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH v2] pkt_sched: Change misleading code in class delete.
Date: Sun, 15 Mar 2009 13:35:11 +0100
Message-ID: <20090315123511.GA2713@ami.dom.local>
References: <20090314144528.GA24995@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: m0sia <m0sia@m0sia.ru>, Patrick McHardy <kaber@trash.net>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f175.google.com ([209.85.218.175]:45714 "EHLO
	mail-bw0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751446AbZCOMfs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2009 08:35:48 -0400
Received: by bwz23 with SMTP id 23so631904bwz.37
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2009 05:35:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090314144528.GA24995@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A few words were missing...
----------------> take 2
While looking for a possible reason of bugzilla report on HTB oops:
http://bugzilla.kernel.org/show_bug.cgi?id=12858
I found the code in htb_delete calling htb_destroy_class on zero
refcount is very misleading: it can suggest this is a common path, and
destroy is called under sch_tree_lock. Actually, this can never happen
like this because before deletion cops->get() is done, and after
delete a class is still used by tclass_notify. The class destroy is
always called from cops->put(), so without sch_tree_lock.

This doesn't mean much now (since 2.6.27) because all vulnerable calls
were moved from htb_destroy_class to htb_delete, but there was a bug
in older kernels. The same change is done for other classful scheds,
which, it seems, didn't have similar locking problems here.

Reported-by: m0sia <m0sia@m0sia.ru>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 net/sched/sch_cbq.c  |    7 +++++--
 net/sched/sch_drr.c  |    7 +++++--
 net/sched/sch_hfsc.c |    7 +++++--
 net/sched/sch_htb.c  |    7 +++++--
 4 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 9e43ed9..002442a 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1960,8 +1960,11 @@ static int cbq_delete(struct Qdisc *sch, unsigned long arg)
 	cbq_rmprio(q, cl);
 	sch_tree_unlock(sch);
 
-	if (--cl->refcnt == 0)
-		cbq_destroy_class(sch, cl);
+	BUG_ON(--cl->refcnt == 0);
+	/*
+	 * This shouldn't happen: we "hold" one cops->get() when called
+	 * from tc_ctl_tclass; the destroy method is done from cops->put().
+	 */
 
 	return 0;
 }
diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index e36e94a..00e20d5 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -155,8 +155,11 @@ static int drr_delete_class(struct Qdisc *sch, unsigned long arg)
 	drr_purge_queue(cl);
 	qdisc_class_hash_remove(&q->clhash, &cl->common);
 
-	if (--cl->refcnt == 0)
-		drr_destroy_class(sch, cl);
+	BUG_ON(--cl->refcnt == 0);
+	/*
+	 * This shouldn't happen: we "hold" one cops->get() when called
+	 * from tc_ctl_tclass; the destroy method is done from cops->put().
+	 */
 
 	sch_tree_unlock(sch);
 	return 0;
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 74226b2..a516aa4 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1139,8 +1139,11 @@ hfsc_delete_class(struct Qdisc *sch, unsigned long arg)
 	hfsc_purge_queue(sch, cl);
 	qdisc_class_hash_remove(&q->clhash, &cl->cl_common);
 
-	if (--cl->refcnt == 0)
-		hfsc_destroy_class(sch, cl);
+	BUG_ON(--cl->refcnt == 0);
+	/*
+	 * This shouldn't happen: we "hold" one cops->get() when called
+	 * from tc_ctl_tclass; the destroy method is done from cops->put().
+	 */
 
 	sch_tree_unlock(sch);
 	return 0;
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 355974f..a4b682b 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1275,8 +1275,11 @@ static int htb_delete(struct Qdisc *sch, unsigned long arg)
 	if (last_child)
 		htb_parent_to_leaf(q, cl, new_q);
 
-	if (--cl->refcnt == 0)
-		htb_destroy_class(sch, cl);
+	BUG_ON(--cl->refcnt == 0);
+	/*
+	 * This shouldn't happen: we "hold" one cops->get() when called
+	 * from tc_ctl_tclass; the destroy method is done from cops->put().
+	 */
 
 	sch_tree_unlock(sch);
 	return 0;
