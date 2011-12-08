From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next] sch_red: Adaptative RED AQM
Date: Thu, 08 Dec 2011 17:06:03 +0100
Message-ID: <1323360363.2521.30.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CAA93jw7kQYONQiAozatRmdRRJeK0GB9eNDWtRZ3AL+OVKn0OpA@mail.gmail.com>
	 <1323082774.2670.40.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: bloat <bloat-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org>,
	bloat-devel <bloat-devel-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Hagen Paul Pfeifer <hagen-GvnIQ6b/HdU@public.gmane.org>
To: Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1323082774.2670.40.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Adaptative RED AQM for linux, based on paper from Sally FLoyd,
Ramakrishna Gummadi, and Scott Shenker, August 2001 :

http://icir.org/floyd/papers/adaptiveRed.pdf

Goal of Adaptative RED is to make max_p a dynamic value between 1% and
50% to reach the target average queue : (max_th - min_th) / 2


Every 500 ms:
 if (avg > target and max_p <= 0.5)
  increase max_p : max_p += alpha;
 else if (avg < target and max_p >= 0.01)
  decrease max_p : max_p *= beta;

target :[min_th + 0.4*(min_th - max_th),
          min_th + 0.6*(min_th - max_th)].
alpha : min(0.01, max_p / 4)
beta : 0.9
max_P is a Q0.32 fixed point number (unsigned, with 32 bits mantissa)


Changes against our RED implementation are :

max_p is no longer a negative power of two (1/(2^Plog)), but a Q0.32
fixed point number, to allow full range described in Adatative paper.

To deliver a random number, we now use a reciprocal divide (thats really
a multiply), but this operation is done once per marked/droped packet
when in RED_BETWEEN_TRESH window, so added cost (compared to previous
AND operation) is near zero.

dump operation gives current max_p value in a new TCA_RED_MAX_P
attribute.

Example on a 10Mbit link :

tc qdisc add dev $DEV parent 1:1 handle 10: est 1sec 8sec red \
   limit 400000 min 30000 max 90000 avpkt 1000 \
   burst 55 ecn adaptative bandwidth 10Mbit

# tc -s -d qdisc show dev eth3
...
qdisc red 10: parent 1:1 limit 400000b min 30000b max 90000b ecn
adaptative ewma 5 max_p=0.113335 Scell_log 15
 Sent 50414282 bytes 34504 pkt (dropped 35, overlimits 1392 requeues 0) 
 rate 9749Kbit 831pps backlog 72056b 16p requeues 0 
  marked 1357 early 35 pdrop 0 other 0


Signed-off-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/linux/pkt_sched.h |    6 +-
 include/net/red.h         |  101 +++++++++++++++++++++++++++++-------
 lib/reciprocal_div.c      |    2 
 net/sched/sch_red.c       |   21 +++++++
 4 files changed, 111 insertions(+), 19 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index fb556dc..e41e0d4 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -181,6 +181,7 @@ enum {
 	TCA_RED_UNSPEC,
 	TCA_RED_PARMS,
 	TCA_RED_STAB,
+	TCA_RED_MAX_P,
 	__TCA_RED_MAX,
 };
 
@@ -194,8 +195,9 @@ struct tc_red_qopt {
 	unsigned char   Plog;		/* log(P_max/(qth_max-qth_min))	*/
 	unsigned char   Scell_log;	/* cell size for idle damping */
 	unsigned char	flags;
-#define TC_RED_ECN	1
-#define TC_RED_HARDDROP	2
+#define TC_RED_ECN		1
+#define TC_RED_HARDDROP		2
+#define TC_RED_ADAPTATIVE	4
 };
 
 struct tc_red_xstats {
diff --git a/include/net/red.h b/include/net/red.h
index b72a3b8..f4e9533 100644
--- a/include/net/red.h
+++ b/include/net/red.h
@@ -5,6 +5,7 @@
 #include <net/pkt_sched.h>
 #include <net/inet_ecn.h>
 #include <net/dsfield.h>
+#include <linux/reciprocal_div.h>
 
 /*	Random Early Detection (RED) algorithm.
 	=======================================
@@ -87,6 +88,29 @@
 	etc.
  */
 
+/*
+ * Adaptative RED : An Algorithm for Increasing the Robustness of RED's AQM
+ * (Sally FLoyd, Ramakrishna Gummadi, and Scott Shenker) August 2001
+ *
+ * Every 500 ms:
+ *  if (avg > target and max_p <= 0.5)
+ *   increase max_p : max_p += alpha;
+ *  else if (avg < target and max_p >= 0.01)
+ *   decrease max_p : max_p *= beta;
+ *
+ * target :[qth_min + 0.4*(qth_min - qth_max),
+ *          qth_min + 0.6*(qth_min - qth_max)].
+ * alpha : min(0.01, max_p / 4)
+ * beta : 0.9
+ * max_P is a Q0.32 fixed point number (with 32 bits mantissa)
+ * max_P between 0.01 and 0.5 (1% - 50%) [ Its no longer a negative power of two ]
+ */
+#define RED_ONE_PERCENT ((u32)DIV_ROUND_CLOSEST(1ULL<<32, 100))
+
+#define MAX_P_MIN (1 * RED_ONE_PERCENT)
+#define MAX_P_MAX (50 * RED_ONE_PERCENT)
+#define MAX_P_ALPHA(val) min(MAX_P_MIN, val / 4)
+
 #define RED_STAB_SIZE	256
 #define RED_STAB_MASK	(RED_STAB_SIZE - 1)
 
@@ -101,10 +125,14 @@ struct red_stats {
 
 struct red_parms {
 	/* Parameters */
-	u32		qth_min;	/* Min avg length threshold: A scaled */
-	u32		qth_max;	/* Max avg length threshold: A scaled */
+	u32		qth_min;	/* Min avg length threshold: Wlog scaled */
+	u32		qth_max;	/* Max avg length threshold: Wlog scaled */
 	u32		Scell_max;
-	u32		Rmask;		/* Cached random mask, see red_rmask */
+	u32		max_P;		/* probability, [0 .. 1.0] 32 scaled */
+	u32		max_P_reciprocal; /* reciprocal_value(max_P / qth_delta) */
+	u32		qth_delta;	/* max_th - min_th */
+	u32		target_min;	/* min_th + 0.4*(max_th - min_th) */
+	u32		target_max;	/* min_th + 0.6*(max_th - min_th) */
 	u8		Scell_log;
 	u8		Wlog;		/* log(W)		*/
 	u8		Plog;		/* random number bits	*/
@@ -115,19 +143,22 @@ struct red_parms {
 					   number generation */
 	u32		qR;		/* Cached random number */
 
-	unsigned long	qavg;		/* Average queue length: A scaled */
+	unsigned long	qavg;		/* Average queue length: Wlog scaled */
 	ktime_t		qidlestart;	/* Start of current idle period */
 };
 
-static inline u32 red_rmask(u8 Plog)
+static inline u32 red_maxp(u8 Plog)
 {
-	return Plog < 32 ? ((1 << Plog) - 1) : ~0UL;
+	return Plog < 32 ? (~0U >> Plog) : ~0U;
 }
 
+
 static inline void red_set_parms(struct red_parms *p,
 				 u32 qth_min, u32 qth_max, u8 Wlog, u8 Plog,
 				 u8 Scell_log, u8 *stab)
 {
+	int delta = qth_max - qth_min;
+
 	/* Reset average queue length, the value is strictly bound
 	 * to the parameters below, reseting hurts a bit but leaving
 	 * it might result in an unreasonable qavg for a while. --TGR
@@ -139,14 +170,29 @@ static inline void red_set_parms(struct red_parms *p,
 	p->qth_max	= qth_max << Wlog;
 	p->Wlog		= Wlog;
 	p->Plog		= Plog;
-	p->Rmask	= red_rmask(Plog);
+	if (delta < 0)
+		delta = 1;
+	p->qth_delta	= delta;
+	p->max_P	= red_maxp(Plog);
+	p->max_P	*= delta; /* max_P = (qth_max-qth_min)/2^Plog */
+
+	p->max_P_reciprocal  = reciprocal_value(p->max_P / delta);
+
+	/* RED Adaptative target :
+	 * [min_th + 0.4*(min_th - max_th),
+	 *  min_th + 0.6*(min_th - max_th)].
+	 */
+	delta /= 5;
+	p->target_min = qth_min + 2*delta;
+	p->target_max = qth_min + 3*delta;
+
 	p->Scell_log	= Scell_log;
 	p->Scell_max	= (255 << Scell_log);
 
 	memcpy(p->Stab, stab, sizeof(p->Stab));
 }
 
-static inline int red_is_idling(struct red_parms *p)
+static inline int red_is_idling(const struct red_parms *p)
 {
 	return p->qidlestart.tv64 != 0;
 }
@@ -168,7 +214,7 @@ static inline void red_restart(struct red_parms *p)
 	p->qcount = -1;
 }
 
-static inline unsigned long red_calc_qavg_from_idle_time(struct red_parms *p)
+static inline unsigned long red_calc_qavg_from_idle_time(const struct red_parms *p)
 {
 	s64 delta = ktime_us_delta(ktime_get(), p->qidlestart);
 	long us_idle = min_t(s64, delta, p->Scell_max);
@@ -215,7 +261,7 @@ static inline unsigned long red_calc_qavg_from_idle_time(struct red_parms *p)
 	}
 }
 
-static inline unsigned long red_calc_qavg_no_idle_time(struct red_parms *p,
+static inline unsigned long red_calc_qavg_no_idle_time(const struct red_parms *p,
 						       unsigned int backlog)
 {
 	/*
@@ -230,7 +276,7 @@ static inline unsigned long red_calc_qavg_no_idle_time(struct red_parms *p,
 	return p->qavg + (backlog - (p->qavg >> p->Wlog));
 }
 
-static inline unsigned long red_calc_qavg(struct red_parms *p,
+static inline unsigned long red_calc_qavg(const struct red_parms *p,
 					  unsigned int backlog)
 {
 	if (!red_is_idling(p))
@@ -239,23 +285,24 @@ static inline unsigned long red_calc_qavg(struct red_parms *p,
 		return red_calc_qavg_from_idle_time(p);
 }
 
-static inline u32 red_random(struct red_parms *p)
+
+static inline u32 red_random(const struct red_parms *p)
 {
-	return net_random() & p->Rmask;
+	return reciprocal_divide(net_random(), p->max_P_reciprocal);
 }
 
-static inline int red_mark_probability(struct red_parms *p, unsigned long qavg)
+static inline int red_mark_probability(const struct red_parms *p, unsigned long qavg)
 {
 	/* The formula used below causes questions.
 
-	   OK. qR is random number in the interval 0..Rmask
+	   OK. qR is random number in the interval
+		(0..1/max_P)*(qth_max-qth_min)
 	   i.e. 0..(2^Plog). If we used floating point
 	   arithmetics, it would be: (2^Plog)*rnd_num,
 	   where rnd_num is less 1.
 
 	   Taking into account, that qavg have fixed
-	   point at Wlog, and Plog is related to max_P by
-	   max_P = (qth_max-qth_min)/2^Plog; two lines
+	   point at Wlog, two lines
 	   below have the following floating point equivalent:
 
 	   max_P*(qavg - qth_min)/(qth_max-qth_min) < rnd/qcount
@@ -315,4 +362,24 @@ static inline int red_action(struct red_parms *p, unsigned long qavg)
 	return RED_DONT_MARK;
 }
 
+static inline void red_adaptative_algo(struct red_parms *p)
+{
+	unsigned long qavg;
+	u32 max_p_delta;
+
+	qavg = p->qavg;
+	if (red_is_idling(p))
+		qavg = red_calc_qavg_from_idle_time(p);
+
+	/* p->qavg is fixed point number with point at Wlog */
+	qavg >>= p->Wlog;
+
+	if (qavg > p->target_max && p->max_P <= MAX_P_MAX)
+		p->max_P += MAX_P_ALPHA(p->max_P); /* maxp = maxp + alpha */
+	else if (qavg < p->target_min && p->max_P >= MAX_P_MIN)
+		p->max_P = (p->max_P/10)*9; /* maxp = maxp * Beta */
+
+	max_p_delta = DIV_ROUND_CLOSEST(p->max_P, p->qth_delta);
+	p->max_P_reciprocal = reciprocal_value(max_p_delta);
+}
 #endif
diff --git a/lib/reciprocal_div.c b/lib/reciprocal_div.c
index 6a3bd48..75510e9 100644
--- a/lib/reciprocal_div.c
+++ b/lib/reciprocal_div.c
@@ -1,5 +1,6 @@
 #include <asm/div64.h>
 #include <linux/reciprocal_div.h>
+#include <linux/export.h>
 
 u32 reciprocal_value(u32 k)
 {
@@ -7,3 +8,4 @@ u32 reciprocal_value(u32 k)
 	do_div(val, k);
 	return (u32)val;
 }
+EXPORT_SYMBOL(reciprocal_value);
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index d617161..8f5a85b 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -39,6 +39,7 @@
 struct red_sched_data {
 	u32			limit;		/* HARD maximal queue length */
 	unsigned char		flags;
+	struct timer_list	adapt_timer;
 	struct red_parms	parms;
 	struct red_stats	stats;
 	struct Qdisc		*qdisc;
@@ -161,6 +162,8 @@ static void red_reset(struct Qdisc *sch)
 static void red_destroy(struct Qdisc *sch)
 {
 	struct red_sched_data *q = qdisc_priv(sch);
+
+	del_timer_sync(&q->adapt_timer);
 	qdisc_destroy(q->qdisc);
 }
 
@@ -209,6 +212,10 @@ static int red_change(struct Qdisc *sch, struct nlattr *opt)
 				 ctl->Plog, ctl->Scell_log,
 				 nla_data(tb[TCA_RED_STAB]));
 
+	del_timer(&q->adapt_timer);
+	if (ctl->flags & TC_RED_ADAPTATIVE)
+		mod_timer(&q->adapt_timer, jiffies + HZ/2);
+
 	if (!q->qdisc->q.qlen)
 		red_start_of_idle_period(&q->parms);
 
@@ -216,11 +223,24 @@ static int red_change(struct Qdisc *sch, struct nlattr *opt)
 	return 0;
 }
 
+static inline void red_adaptative_timer(unsigned long arg)
+{
+	struct Qdisc *sch = (struct Qdisc *)arg;
+	struct red_sched_data *q = qdisc_priv(sch);
+	spinlock_t *root_lock = qdisc_lock(qdisc_root_sleeping(sch));
+
+	spin_lock(root_lock);
+	red_adaptative_algo(&q->parms);
+	mod_timer(&q->adapt_timer, jiffies + HZ/2);
+	spin_unlock(root_lock);
+}
+
 static int red_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct red_sched_data *q = qdisc_priv(sch);
 
 	q->qdisc = &noop_qdisc;
+	setup_timer(&q->adapt_timer, red_adaptative_timer, (unsigned long)sch);
 	return red_change(sch, opt);
 }
 
@@ -243,6 +263,7 @@ static int red_dump(struct Qdisc *sch, struct sk_buff *skb)
 	if (opts == NULL)
 		goto nla_put_failure;
 	NLA_PUT(skb, TCA_RED_PARMS, sizeof(opt), &opt);
+	NLA_PUT_U32(skb, TCA_RED_MAX_P, q->parms.max_P);
 	return nla_nest_end(skb, opts);
 
 nla_put_failure:


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
