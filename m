From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 10/10]: kill jiffie conversion macros
Date: Fri, 16 Mar 2007 06:31:02 +0100 (MET)
Message-ID: <20070316053032.22744.77229.sendpatchset@localhost.localdomain>
References: <20070316053018.22744.76883.sendpatchset@localhost.localdomain>
Cc: devik@cdi.cz, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	shemminger@linux-foundation.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45289 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752505AbXCPFbD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2007 01:31:03 -0400
In-Reply-To: <20070316053018.22744.76883.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET_SCHED]: kill jiffie conversion macros

Now that all packet schedulers have been converted to hrtimers most users
of PSCHED_JIFFIE2US and PSCHED_US2JIFFIE are gone. The remaining users use
it to convert external time units to packet scheduler clock ticks, so use
PSCHED_TICKS_PER_SEC instead.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 32b945035419c2d458cd0bf7072acb335e5c4044
tree 6837d1c9419e1ada826701fbb1f9e93ff8ff5a33
parent a5eaa252c5da48fef25a308ebc99b4020dad7f64
author Patrick McHardy <kaber@trash.net> Fri, 16 Mar 2007 06:17:44 +0100
committer Patrick McHardy <kaber@trash.net> Fri, 16 Mar 2007 06:17:44 +0100

 include/net/pkt_sched.h |    3 ---
 net/sched/sch_hfsc.c    |   12 ++++++------
 net/sched/sch_htb.c     |    2 +-
 3 files changed, 7 insertions(+), 10 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index b090d55..6555e57 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -51,9 +51,6 @@ #define PSCHED_TICKS_PER_SEC		PSCHED_NS2
 #define PSCHED_GET_TIME(stamp) \
 	((stamp) = PSCHED_NS2US(ktime_to_ns(ktime_get())))
 
-#define PSCHED_US2JIFFIE(usecs)		usecs_to_jiffies(PSCHED_US2NS((usecs)) / NSEC_PER_USEC)
-#define PSCHED_JIFFIE2US(delay)		PSCHED_NS2US(jiffies_to_usecs((delay)) * NSEC_PER_USEC)
-
 #define PSCHED_TDIFF(tv1, tv2)		(long)((tv1) - (tv2))
 #define PSCHED_TDIFF_SAFE(tv1, tv2, bound) \
 					min_t(long long, (tv1) - (tv2), bound)
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 49cae7d..522018b 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -434,8 +434,8 @@ m2sm(u32 m)
 	u64 sm;
 
 	sm = ((u64)m << SM_SHIFT);
-	sm += PSCHED_JIFFIE2US(HZ) - 1;
-	do_div(sm, PSCHED_JIFFIE2US(HZ));
+	sm += PSCHED_TICKS_PER_SEC - 1;
+	do_div(sm, PSCHED_TICKS_PER_SEC);
 	return sm;
 }
 
@@ -448,7 +448,7 @@ m2ism(u32 m)
 	if (m == 0)
 		ism = HT_INFINITY;
 	else {
-		ism = ((u64)PSCHED_JIFFIE2US(HZ) << ISM_SHIFT);
+		ism = ((u64)PSCHED_TICKS_PER_SEC << ISM_SHIFT);
 		ism += m - 1;
 		do_div(ism, m);
 	}
@@ -461,7 +461,7 @@ d2dx(u32 d)
 {
 	u64 dx;
 
-	dx = ((u64)d * PSCHED_JIFFIE2US(HZ));
+	dx = ((u64)d * PSCHED_TICKS_PER_SEC);
 	dx += USEC_PER_SEC - 1;
 	do_div(dx, USEC_PER_SEC);
 	return dx;
@@ -473,7 +473,7 @@ sm2m(u64 sm)
 {
 	u64 m;
 
-	m = (sm * PSCHED_JIFFIE2US(HZ)) >> SM_SHIFT;
+	m = (sm * PSCHED_TICKS_PER_SEC) >> SM_SHIFT;
 	return (u32)m;
 }
 
@@ -484,7 +484,7 @@ dx2d(u64 dx)
 	u64 d;
 
 	d = dx * USEC_PER_SEC;
-	do_div(d, PSCHED_JIFFIE2US(HZ));
+	do_div(d, PSCHED_TICKS_PER_SEC);
 	return (u32)d;
 }
 
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index b00cef7..1721043 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1469,7 +1469,7 @@ static int htb_change_class(struct Qdisc
 		/* set class to be in HTB_CAN_SEND state */
 		cl->tokens = hopt->buffer;
 		cl->ctokens = hopt->cbuffer;
-		cl->mbuffer = PSCHED_JIFFIE2US(HZ * 60);	/* 1min */
+		cl->mbuffer = 60 * PSCHED_TICKS_PER_SEC;	/* 1min */
 		PSCHED_GET_TIME(cl->t_c);
 		cl->cmode = HTB_CAN_SEND;
 
