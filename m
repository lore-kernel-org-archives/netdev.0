From: Patrick McHardy <kaber@trash.net>
Subject: [UPDATED PATCH]: Adjust qlen when grafting in multiple qdiscs
Date: Tue, 18 Nov 2003 01:34:56 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FB96930.9020300@trash.net>
References: <3FB3996A.6080008@trash.net> <1069076786.1075.19.camel@jzny.localdomain> <3FB8DDE0.1070105@trash.net> <1069081153.1022.20.camel@jzny.localdomain> <3FB8F3BF.6050509@trash.net> <1069090210.1022.64.camel@jzny.localdomain> <20031117163834.V1330@almesberger.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010300040207020401010302"
Cc: jamal <hadi@cyberus.ca>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031117163834.V1330@almesberger.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010300040207020401010302
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi Dave,

this patch fixes multiple qdiscs to adjust sch->q.qlen when
replacing a non-empty inner qdisc. The only change to the
first patch is in dsmark_graft: this patch directly sets
sch->q.qlen to 0 instead of subtracting the length of the
inner qdisc.

Best regards,
Patrick



--------------010300040207020401010302
Content-Type: text/plain;
 name="graft-adjust-qlen.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="graft-adjust-qlen.diff"

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1441  -> 1.1442 
#	 net/sched/sch_tbf.c	1.10    -> 1.11   
#	 net/sched/sch_cbq.c	1.13    -> 1.14   
#	net/sched/sch_dsmark.c	1.10    -> 1.11   
#	net/sched/sch_prio.c	1.9     -> 1.10   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/11/18	kaber@trash.net	1.1442
# Adjust qlen when grafting in multiple qdiscs
# --------------------------------------------
#
diff -Nru a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
--- a/net/sched/sch_cbq.c	Tue Nov 18 01:18:14 2003
+++ b/net/sched/sch_cbq.c	Tue Nov 18 01:18:14 2003
@@ -1670,6 +1670,7 @@
 		sch_tree_lock(sch);
 		*old = cl->q;
 		cl->q = new;
+		sch->q.qlen -= (*old)->q.qlen;
 		qdisc_reset(*old);
 		sch_tree_unlock(sch);
 
diff -Nru a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
--- a/net/sched/sch_dsmark.c	Tue Nov 18 01:18:14 2003
+++ b/net/sched/sch_dsmark.c	Tue Nov 18 01:18:14 2003
@@ -77,6 +77,7 @@
 	*old = xchg(&p->q,new);
 	if (*old)
 		qdisc_reset(*old);
+	sch->q.qlen = 0;
 	sch_tree_unlock(sch); /* @@@ move up ? */
         return 0;
 }
diff -Nru a/net/sched/sch_prio.c b/net/sched/sch_prio.c
--- a/net/sched/sch_prio.c	Tue Nov 18 01:18:14 2003
+++ b/net/sched/sch_prio.c	Tue Nov 18 01:18:14 2003
@@ -266,6 +266,7 @@
 	sch_tree_lock(sch);
 	*old = q->queues[band];
 	q->queues[band] = new;
+	sch->q.qlen -= (*old)->q.qlen;
 	qdisc_reset(*old);
 	sch_tree_unlock(sch);
 
diff -Nru a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
--- a/net/sched/sch_tbf.c	Tue Nov 18 01:18:14 2003
+++ b/net/sched/sch_tbf.c	Tue Nov 18 01:18:14 2003
@@ -455,6 +455,8 @@
 	sch_tree_lock(sch);	
 	*old = xchg(&q->qdisc, new);
 	qdisc_reset(*old);
+	sch->q.qlen = 0;
+	sch->stats.backlog = 0;
 	sch_tree_unlock(sch);
 	
 	return 0;

--------------010300040207020401010302--
