From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (3/4) packet scheduler - eliminate guard from TDIFF_SAFE
Date: Tue, 29 Jun 2004 14:00:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040629140019.2efbf6f6@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The last argument in the PSCHED_TDIFF_SAFE is no longer used;
only usage eliminated by previous patch. It gets rid of a bad macro
usage.

Also, can use the standard min_t macro which also eliminates the
macro problem of double evaluation of bound.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/include/net/pkt_sched.h b/include/net/pkt_sched.h
--- a/include/net/pkt_sched.h	2004-06-29 11:48:30 -07:00
+++ b/include/net/pkt_sched.h	2004-06-29 11:48:30 -07:00
@@ -308,13 +308,13 @@
 
 extern int psched_tod_diff(int delta_sec, int bound);
 
-#define PSCHED_TDIFF_SAFE(tv1, tv2, bound, guard) \
+#define PSCHED_TDIFF_SAFE(tv1, tv2, bound) \
 ({ \
 	   int __delta_sec = (tv1).tv_sec - (tv2).tv_sec; \
 	   int __delta = (tv1).tv_usec - (tv2).tv_usec; \
 	   switch (__delta_sec) { \
 	   default: \
-		   __delta = psched_tod_diff(__delta_sec, bound); guard; break; \
+		   __delta = psched_tod_diff(__delta_sec, bound);  break; \
 	   case 2: \
 		   __delta += 1000000; \
 	   case 1: \
@@ -355,12 +355,8 @@
 #else
 
 #define PSCHED_TDIFF(tv1, tv2) (long)((tv1) - (tv2))
-#define PSCHED_TDIFF_SAFE(tv1, tv2, bound, guard) \
-({ \
-	   long long __delta = (tv1) - (tv2); \
-	   if ( __delta > (long long)(bound)) {  __delta = (bound); guard; } \
-	   __delta; \
-})
+#define PSCHED_TDIFF_SAFE(tv1, tv2, bound) \
+	min_t(long long, (tv1) - (tv2), bound)
 
 
 #define PSCHED_TLESS(tv1, tv2) ((tv1) < (tv2))
diff -Nru a/net/sched/police.c b/net/sched/police.c
--- a/net/sched/police.c	2004-06-29 11:48:30 -07:00
+++ b/net/sched/police.c	2004-06-29 11:48:30 -07:00
@@ -321,7 +321,7 @@
 
 		PSCHED_GET_TIME(now);
 
-		toks = PSCHED_TDIFF_SAFE(now, p->t_c, p->burst, (void)0);
+		toks = PSCHED_TDIFF_SAFE(now, p->t_c, p->burst);
 
 		if (p->P_tab) {
 			ptoks = toks + p->ptoks;
@@ -523,7 +523,7 @@
 
 		PSCHED_GET_TIME(now);
 
-		toks = PSCHED_TDIFF_SAFE(now, p->t_c, p->burst, (void)0);
+		toks = PSCHED_TDIFF_SAFE(now, p->t_c, p->burst);
 
 		if (p->P_tab) {
 			ptoks = toks + p->ptoks;
diff -Nru a/net/sched/sch_gred.c b/net/sched/sch_gred.c
--- a/net/sched/sch_gred.c	2004-06-29 11:48:30 -07:00
+++ b/net/sched/sch_gred.c	2004-06-29 11:48:30 -07:00
@@ -155,7 +155,7 @@
 	if (!PSCHED_IS_PASTPERFECT(q->qidlestart)) {
 		long us_idle;
 		PSCHED_GET_TIME(now);
-		us_idle = PSCHED_TDIFF_SAFE(now, q->qidlestart, q->Scell_max, (void)0);
+		us_idle = PSCHED_TDIFF_SAFE(now, q->qidlestart, q->Scell_max);
 		PSCHED_SET_PASTPERFECT(q->qidlestart);
 
 		q->qave >>= q->Stab[(us_idle>>q->Scell_log)&0xFF];
@@ -551,7 +551,7 @@
 				long idle;
 				psched_time_t now;
 				PSCHED_GET_TIME(now);
-				idle = PSCHED_TDIFF_SAFE(now, q->qidlestart, q->Scell_max, (void)0);
+				idle = PSCHED_TDIFF_SAFE(now, q->qidlestart, q->Scell_max);
 				qave  = q->qave >> q->Stab[(idle>>q->Scell_log)&0xFF];
 				dst->qave = qave >> q->Wlog;
 
diff -Nru a/net/sched/sch_htb.c b/net/sched/sch_htb.c
--- a/net/sched/sch_htb.c	2004-06-29 11:48:30 -07:00
+++ b/net/sched/sch_htb.c	2004-06-29 11:48:30 -07:00
@@ -367,7 +367,7 @@
 		struct list_head *l;
 		list_for_each (l,q->hash+i) {
 			struct htb_class *cl = list_entry(l,struct htb_class,hlist);
-			long diff = PSCHED_TDIFF_SAFE(q->now, cl->t_c, (u32)cl->mbuffer, (void)0);
+			long diff = PSCHED_TDIFF_SAFE(q->now, cl->t_c, (u32)cl->mbuffer);
 			printk(KERN_DEBUG "htb*c%x m=%d t=%ld c=%ld pq=%lu df=%ld ql=%d "
 					"pa=%x f:",
 				cl->classid,cl->cmode,cl->tokens,cl->ctokens,
@@ -807,7 +807,7 @@
 
 	while (cl) {
 		HTB_CHCL(cl);
-		diff = PSCHED_TDIFF_SAFE(q->now, cl->t_c, (u32)cl->mbuffer, (void)0);
+		diff = PSCHED_TDIFF_SAFE(q->now, cl->t_c, (u32)cl->mbuffer);
 #ifdef HTB_DEBUG
 		if (diff > cl->mbuffer || diff < 0 || PSCHED_TLESS(q->now, cl->t_c)) {
 			if (net_ratelimit())
@@ -878,7 +878,7 @@
 			return cl->pq_key - q->jiffies;
 		}
 		htb_safe_rb_erase(p,q->wait_pq+level);
-		diff = PSCHED_TDIFF_SAFE(q->now, cl->t_c, (u32)cl->mbuffer, (void)0);
+		diff = PSCHED_TDIFF_SAFE(q->now, cl->t_c, (u32)cl->mbuffer);
 #ifdef HTB_DEBUG
 		if (diff > cl->mbuffer || diff < 0 || PSCHED_TLESS(q->now, cl->t_c)) {
 			if (net_ratelimit())
diff -Nru a/net/sched/sch_red.c b/net/sched/sch_red.c
--- a/net/sched/sch_red.c	2004-06-29 11:48:30 -07:00
+++ b/net/sched/sch_red.c	2004-06-29 11:48:30 -07:00
@@ -189,7 +189,7 @@
 		int  shift;
 
 		PSCHED_GET_TIME(now);
-		us_idle = PSCHED_TDIFF_SAFE(now, q->qidlestart, q->Scell_max, (void)0);
+		us_idle = PSCHED_TDIFF_SAFE(now, q->qidlestart, q->Scell_max);
 		PSCHED_SET_PASTPERFECT(q->qidlestart);
 
 /*
diff -Nru a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
--- a/net/sched/sch_tbf.c	2004-06-29 11:48:30 -07:00
+++ b/net/sched/sch_tbf.c	2004-06-29 11:48:30 -07:00
@@ -207,7 +207,7 @@
 
 		PSCHED_GET_TIME(now);
 
-		toks = PSCHED_TDIFF_SAFE(now, q->t_c, q->buffer, (void)0);
+		toks = PSCHED_TDIFF_SAFE(now, q->t_c, q->buffer);
 
 		if (q->P_tab) {
 			ptoks = toks + q->ptokens;
