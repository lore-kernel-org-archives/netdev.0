From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 33/58] net: sched: Convert timers to use timer_setup()
Date: Mon, 16 Oct 2017 17:29:17 -0700
Message-ID: <1508200182-104605-34-git-send-email-keescook@chromium.org>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508200182-104605-1-git-send-email-keescook@chromium.org>
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
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 net/sched/cls_flow.c    |  7 +++----
 net/sched/sch_generic.c |  6 +++---
 net/sched/sch_pie.c     | 10 ++++++----
 net/sched/sch_red.c     | 10 ++++++----
 net/sched/sch_sfq.c     | 10 +++++-----
 5 files changed, 23 insertions(+), 20 deletions(-)

diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 2a3a60ec5b86..ca9acce2d402 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -345,9 +345,9 @@ static int flow_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 	return -1;
 }
 
-static void flow_perturbation(unsigned long arg)
+static void flow_perturbation(struct timer_list *t)
 {
-	struct flow_filter *f = (struct flow_filter *)arg;
+	struct flow_filter *f = from_timer(f, t, perturb_timer);
 
 	get_random_bytes(&f->hashrnd, 4);
 	if (f->perturb_period)
@@ -502,8 +502,7 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 		get_random_bytes(&fnew->hashrnd, 4);
 	}
 
-	setup_deferrable_timer(&fnew->perturb_timer, flow_perturbation,
-			       (unsigned long)fnew);
+	timer_setup(&fnew->perturb_timer, flow_perturbation, TIMER_DEFERRABLE);
 
 	netif_keep_dst(qdisc_dev(tp->q));
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index a0a198768aad..6ced7c89c141 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -288,9 +288,9 @@ unsigned long dev_trans_start(struct net_device *dev)
 }
 EXPORT_SYMBOL(dev_trans_start);
 
-static void dev_watchdog(unsigned long arg)
+static void dev_watchdog(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *)arg;
+	struct net_device *dev = from_timer(dev, t, watchdog_timer);
 
 	netif_tx_lock(dev);
 	if (!qdisc_tx_is_noop(dev)) {
@@ -954,7 +954,7 @@ void dev_init_scheduler(struct net_device *dev)
 	if (dev_ingress_queue(dev))
 		dev_init_scheduler_queue(dev, dev_ingress_queue(dev), &noop_qdisc);
 
-	setup_timer(&dev->watchdog_timer, dev_watchdog, (unsigned long)dev);
+	timer_setup(&dev->watchdog_timer, dev_watchdog, 0);
 }
 
 static void shutdown_scheduler_queue(struct net_device *dev,
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
