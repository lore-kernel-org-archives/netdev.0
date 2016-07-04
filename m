From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next] hfsc: reduce hfsc_sched to 14 cachelines
Date: Mon,  4 Jul 2016 16:22:20 +0200
Message-ID: <1467642140-19156-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>, Michal Soltys <soltys@ziu.info>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:54872 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750789AbcGDOWJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 10:22:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hfsc_sched is huge (size: 920, cachelines: 15), but we can get it to 14
cachelines by placing level after filter_cnt (covering 4 byte hole) and
reducing period/nactive/flags to u32 (period is just a counter,
incremented when class becomes active -- 2**32 is plenty for this
purpose, also, long is only 32bit wide on 32bit platforms anyway).

cl_vtperiod is exported to userspace via tc_hfsc_stats, but its period
member is already u32, so no precision is lost there either.

Cc: Michal Soltys <soltys@ziu.info>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/sched/sch_hfsc.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 0fd8da7..6a6fb30 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -115,9 +115,9 @@ struct hfsc_class {
 	struct gnet_stats_basic_packed bstats;
 	struct gnet_stats_queue qstats;
 	struct gnet_stats_rate_est64 rate_est;
-	unsigned int	level;		/* class level in hierarchy */
 	struct tcf_proto __rcu *filter_list; /* filter list */
 	unsigned int	filter_cnt;	/* filter count */
+	unsigned int	level;		/* class level in hierarchy */
 
 	struct hfsc_sched *sched;	/* scheduler data */
 	struct hfsc_class *cl_parent;	/* parent class */
@@ -165,10 +165,10 @@ struct hfsc_class {
 	struct runtime_sc cl_virtual;	/* virtual curve */
 	struct runtime_sc cl_ulimit;	/* upperlimit curve */
 
-	unsigned long	cl_flags;	/* which curves are valid */
-	unsigned long	cl_vtperiod;	/* vt period sequence number */
-	unsigned long	cl_parentperiod;/* parent's vt period sequence number*/
-	unsigned long	cl_nactive;	/* number of active children */
+	u8		cl_flags;	/* which curves are valid */
+	u32		cl_vtperiod;	/* vt period sequence number */
+	u32		cl_parentperiod;/* parent's vt period sequence number*/
+	u32		cl_nactive;	/* number of active children */
 };
 
 struct hfsc_sched {
-- 
2.7.3
