From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] net: sched: Convert timers to use timer_setup()
Date: Wed, 4 Oct 2017 17:52:16 -0700
Message-ID: <20171005005216.GA23570@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly. Add pointer back to Qdisc.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
Cc: Jiri Pirko <jiri@resnulli.us>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
This requires commit 686fef928bba ("timer: Prepare to change timer
callback argument type") in v4.14-rc3, but should be otherwise
stand-alone.
---
 net/sched/sch_pie.c | 10 ++++++----
 net/sched/sch_red.c | 10 ++++++----
 net/sched/sch_sfq.c | 10 +++++-----
 3 files changed, 17 insertions(+), 13 deletions(-)

diff --git a/net/sched/sch_pie.c b/net/sched/sch_pie.c
index 6c2791d6102d..776c694c77c7 100644
--- a/net/sched/sch_pie.c
+++ b/net/sched/sch_pie.c
@@ -74,6 +74,7 @@ struct pie_sched_data {
 	struct pie_vars vars;
 	struct pie_stats stats;
 	struct timer_list adapt_timer;
+	struct Qdisc *sch;
 };
 
 static void pie_params_init(struct pie_params *params)
@@ -422,10 +423,10 @@ static void calculate_probability(struct Qdisc *sch)
 		pie_vars_init(&q->vars);
 }
 
-static void pie_timer(unsigned long arg)
+static void pie_timer(struct timer_list *t)
 {
-	struct Qdisc *sch = (struct Qdisc *)arg;
-	struct pie_sched_data *q = qdisc_priv(sch);
+	struct pie_sched_data *q = from_timer(q, t, adapt_timer);
+	struct Qdisc *sch = q->sch;
 	spinlock_t *root_lock = qdisc_lock(qdisc_root_sleeping(sch));
 
 	spin_lock(root_lock);
@@ -446,7 +447,8 @@ static int pie_init(struct Qdisc *sch, struct nlattr *opt)
 	pie_vars_init(&q->vars);
 	sch->limit = q->params.limit;
 
-	setup_timer(&q->adapt_timer, pie_timer, (unsigned long)sch);
+	q->sch = sch;
+	timer_setup(&q->adapt_timer, pie_timer, 0);
 
 	if (opt) {
 		int err = pie_change(sch, opt);
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index 93b9d70a9b28..fdfdb56aaae2 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -40,6 +40,7 @@ struct red_sched_data {
 	u32			limit;		/* HARD maximal queue length */
 	unsigned char		flags;
 	struct timer_list	adapt_timer;
+	struct Qdisc		*sch;
 	struct red_parms	parms;
 	struct red_vars		vars;
 	struct red_stats	stats;
@@ -221,10 +222,10 @@ static int red_change(struct Qdisc *sch, struct nlattr *opt)
 	return 0;
 }
 
-static inline void red_adaptative_timer(unsigned long arg)
+static inline void red_adaptative_timer(struct timer_list *t)
 {
-	struct Qdisc *sch = (struct Qdisc *)arg;
-	struct red_sched_data *q = qdisc_priv(sch);
+	struct red_sched_data *q = from_timer(q, t, adapt_timer);
+	struct Qdisc *sch = q->sch;
 	spinlock_t *root_lock = qdisc_lock(qdisc_root_sleeping(sch));
 
 	spin_lock(root_lock);
@@ -238,7 +239,8 @@ static int red_init(struct Qdisc *sch, struct nlattr *opt)
 	struct red_sched_data *q = qdisc_priv(sch);
 
 	q->qdisc = &noop_qdisc;
-	setup_timer(&q->adapt_timer, red_adaptative_timer, (unsigned long)sch);
+	q->sch = sch;
+	timer_setup(&q->adapt_timer, red_adaptative_timer, 0);
 	return red_change(sch, opt);
 }
 
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 74ea863b8240..42293412dc25 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -145,6 +145,7 @@ struct sfq_sched_data {
 	int		perturb_period;
 	unsigned int	quantum;	/* Allotment per round: MUST BE >= MTU */
 	struct timer_list perturb_timer;
+	struct Qdisc	*sch;
 };
 
 /*
@@ -604,10 +605,10 @@ static void sfq_rehash(struct Qdisc *sch)
 	qdisc_tree_reduce_backlog(sch, dropped, drop_len);
 }
 
-static void sfq_perturbation(unsigned long arg)
+static void sfq_perturbation(struct timer_list *t)
 {
-	struct Qdisc *sch = (struct Qdisc *)arg;
-	struct sfq_sched_data *q = qdisc_priv(sch);
+	struct sfq_sched_data *q = from_timer(q, t, perturb_timer);
+	struct Qdisc *sch = q->sch;
 	spinlock_t *root_lock = qdisc_lock(qdisc_root_sleeping(sch));
 
 	spin_lock(root_lock);
@@ -722,8 +723,7 @@ static int sfq_init(struct Qdisc *sch, struct nlattr *opt)
 	int i;
 	int err;
 
-	setup_deferrable_timer(&q->perturb_timer, sfq_perturbation,
-			       (unsigned long)sch);
+	timer_setup(&q->perturb_timer, sfq_perturbation, TIMER_DEFERRABLE);
 
 	err = tcf_block_get(&q->block, &q->filter_list);
 	if (err)
-- 
2.7.4


-- 
Kees Cook
Pixel Security
