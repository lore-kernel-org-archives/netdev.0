From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Revert netlink ABI change to gnet_stats_basic
Date: Sun, 16 Aug 2009 21:36:49 +0200
Message-ID: <4A885FD1.4030105@gmail.com>
References: <1250002683-28554-1-git-send-email-mspang@csclub.uwaterloo.ca>	 <4A87FCAC.5070705@gmail.com> <118a63b80908160642j73568637n2f3fa97fc33d8e57@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Michael Spang <mspang@csclub.uwaterloo.ca>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932543AbZHPThR@vger.kernel.org>
In-Reply-To: <118a63b80908160642j73568637n2f3fa97fc33d8e57@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Spang a =E9crit :
> On Sun, Aug 16, 2009 at 8:33 AM, Eric Dumazet<eric.dumazet@gmail.com>=
 wrote:
>> What exactly broke after patch was pushed ?
>=20
> The libnl library refuses to initialize with 2.6.30 with pre-2.6.30
> headers. With 2.6.30 I get
>=20
>   $ libnl-1.1/src/nl-qdisc-dump brief
>   Unable to retrieve qdisc cache
>=20
> whereas previously I would get
>=20
>   $ libnl-1.1/src/nl-qdisc-dump brief
>   htb qdisc dev eth0 handle 01: parent root r2q 10000 default :02
>=20
> It works fine if I use the headers from 2.6.30, but then I don't
> believe it would work with older kernels.
>=20

OK, then we are stuck to use a separate definition for user land
and kernel land, or risk various side effects, like performance hit
and security risk.

Thanks a lot Michael

[PATCH] net: restore gnet_stats_basic to previous definition

In 5e140dfc1fe87eae27846f193086724806b33c7d "net: reorder struct Qdisc
for better SMP performance" the definition of struct gnet_stats_basic
changed incompatibly, as copies of this struct are shipped to
userland via netlink.

Restoring old behavior is not welcome, for performance reason.

=46ix is to use a private structure for kernel, and
teach gnet_stats_copy_basic() to convert from kernel to user land,
using legacy structure (struct gnet_stats_basic)

Based on a report and initial patch from Michael Spang.

Reported-by: Michael Spang <mspang@csclub.uwaterloo.ca>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/gen_stats.h          |    5 +++++
 include/net/act_api.h              |    2 +-
 include/net/gen_stats.h            |   10 +++++-----
 include/net/netfilter/xt_rateest.h |    2 +-
 include/net/sch_generic.h          |    2 +-
 net/core/gen_estimator.c           |   12 ++++++------
 net/core/gen_stats.c               |   11 ++++++++---
 net/netfilter/xt_RATEEST.c         |    2 +-
 net/sched/sch_atm.c                |    2 +-
 net/sched/sch_cbq.c                |    2 +-
 net/sched/sch_drr.c                |    2 +-
 net/sched/sch_hfsc.c               |    2 +-
 net/sched/sch_htb.c                |    2 +-
 13 files changed, 33 insertions(+), 23 deletions(-)

diff --git a/include/linux/gen_stats.h b/include/linux/gen_stats.h
index 0ffa41d..710e901 100644
--- a/include/linux/gen_stats.h
+++ b/include/linux/gen_stats.h
@@ -22,6 +22,11 @@ struct gnet_stats_basic
 {
 	__u64	bytes;
 	__u32	packets;
+};
+struct gnet_stats_basic_packed
+{
+	__u64	bytes;
+	__u32	packets;
 } __attribute__ ((packed));
=20
 /**
diff --git a/include/net/act_api.h b/include/net/act_api.h
index 565eed8..c05fd71 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -16,7 +16,7 @@ struct tcf_common {
 	u32				tcfc_capab;
 	int				tcfc_action;
 	struct tcf_t			tcfc_tm;
-	struct gnet_stats_basic		tcfc_bstats;
+	struct gnet_stats_basic_packed	tcfc_bstats;
 	struct gnet_stats_queue		tcfc_qstats;
 	struct gnet_stats_rate_est	tcfc_rate_est;
 	spinlock_t			tcfc_lock;
diff --git a/include/net/gen_stats.h b/include/net/gen_stats.h
index d136b52..c148855 100644
--- a/include/net/gen_stats.h
+++ b/include/net/gen_stats.h
@@ -28,7 +28,7 @@ extern int gnet_stats_start_copy_compat(struct sk_buf=
f *skb, int type,
 					spinlock_t *lock, struct gnet_dump *d);
=20
 extern int gnet_stats_copy_basic(struct gnet_dump *d,
-				 struct gnet_stats_basic *b);
+				 struct gnet_stats_basic_packed *b);
 extern int gnet_stats_copy_rate_est(struct gnet_dump *d,
 				    struct gnet_stats_rate_est *r);
 extern int gnet_stats_copy_queue(struct gnet_dump *d,
@@ -37,14 +37,14 @@ extern int gnet_stats_copy_app(struct gnet_dump *d,=
 void *st, int len);
=20
 extern int gnet_stats_finish_copy(struct gnet_dump *d);
=20
-extern int gen_new_estimator(struct gnet_stats_basic *bstats,
+extern int gen_new_estimator(struct gnet_stats_basic_packed *bstats,
 			     struct gnet_stats_rate_est *rate_est,
 			     spinlock_t *stats_lock, struct nlattr *opt);
-extern void gen_kill_estimator(struct gnet_stats_basic *bstats,
+extern void gen_kill_estimator(struct gnet_stats_basic_packed *bstats,
 			       struct gnet_stats_rate_est *rate_est);
-extern int gen_replace_estimator(struct gnet_stats_basic *bstats,
+extern int gen_replace_estimator(struct gnet_stats_basic_packed *bstat=
s,
 				 struct gnet_stats_rate_est *rate_est,
 				 spinlock_t *stats_lock, struct nlattr *opt);
-extern bool gen_estimator_active(const struct gnet_stats_basic *bstats=
,
+extern bool gen_estimator_active(const struct gnet_stats_basic_packed =
*bstats,
 				 const struct gnet_stats_rate_est *rate_est);
 #endif
diff --git a/include/net/netfilter/xt_rateest.h b/include/net/netfilter=
/xt_rateest.h
index 65d594d..ddbf37e 100644
--- a/include/net/netfilter/xt_rateest.h
+++ b/include/net/netfilter/xt_rateest.h
@@ -8,7 +8,7 @@ struct xt_rateest {
 	spinlock_t			lock;
 	struct gnet_estimator		params;
 	struct gnet_stats_rate_est	rstats;
-	struct gnet_stats_basic		bstats;
+	struct gnet_stats_basic_packed	bstats;
 };
=20
 extern struct xt_rateest *xt_rateest_lookup(const char *name);
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 964ffa0..5482e95 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -72,7 +72,7 @@ struct Qdisc
 	 */
 	unsigned long		state;
 	struct sk_buff_head	q;
-	struct gnet_stats_basic bstats;
+	struct gnet_stats_basic_packed bstats;
 	struct gnet_stats_queue	qstats;
 };
=20
diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
index 78e5bfc..493775f 100644
--- a/net/core/gen_estimator.c
+++ b/net/core/gen_estimator.c
@@ -81,7 +81,7 @@
 struct gen_estimator
 {
 	struct list_head	list;
-	struct gnet_stats_basic	*bstats;
+	struct gnet_stats_basic_packed	*bstats;
 	struct gnet_stats_rate_est	*rate_est;
 	spinlock_t		*stats_lock;
 	int			ewma_log;
@@ -165,7 +165,7 @@ static void gen_add_node(struct gen_estimator *est)
 }
=20
 static
-struct gen_estimator *gen_find_node(const struct gnet_stats_basic *bst=
ats,
+struct gen_estimator *gen_find_node(const struct gnet_stats_basic_pack=
ed *bstats,
 				    const struct gnet_stats_rate_est *rate_est)
 {
 	struct rb_node *p =3D est_root.rb_node;
@@ -202,7 +202,7 @@ struct gen_estimator *gen_find_node(const struct gn=
et_stats_basic *bstats,
  *
  * NOTE: Called under rtnl_mutex
  */
-int gen_new_estimator(struct gnet_stats_basic *bstats,
+int gen_new_estimator(struct gnet_stats_basic_packed *bstats,
 		      struct gnet_stats_rate_est *rate_est,
 		      spinlock_t *stats_lock,
 		      struct nlattr *opt)
@@ -262,7 +262,7 @@ static void __gen_kill_estimator(struct rcu_head *h=
ead)
  *
  * NOTE: Called under rtnl_mutex
  */
-void gen_kill_estimator(struct gnet_stats_basic *bstats,
+void gen_kill_estimator(struct gnet_stats_basic_packed *bstats,
 			struct gnet_stats_rate_est *rate_est)
 {
 	struct gen_estimator *e;
@@ -292,7 +292,7 @@ EXPORT_SYMBOL(gen_kill_estimator);
  *
  * Returns 0 on success or a negative error code.
  */
-int gen_replace_estimator(struct gnet_stats_basic *bstats,
+int gen_replace_estimator(struct gnet_stats_basic_packed *bstats,
 			  struct gnet_stats_rate_est *rate_est,
 			  spinlock_t *stats_lock, struct nlattr *opt)
 {
@@ -308,7 +308,7 @@ EXPORT_SYMBOL(gen_replace_estimator);
  *
  * Returns true if estimator is active, and false if not.
  */
-bool gen_estimator_active(const struct gnet_stats_basic *bstats,
+bool gen_estimator_active(const struct gnet_stats_basic_packed *bstats=
,
 			  const struct gnet_stats_rate_est *rate_est)
 {
 	ASSERT_RTNL();
diff --git a/net/core/gen_stats.c b/net/core/gen_stats.c
index c3d0ffe..8569310 100644
--- a/net/core/gen_stats.c
+++ b/net/core/gen_stats.c
@@ -106,16 +106,21 @@ gnet_stats_start_copy(struct sk_buff *skb, int ty=
pe, spinlock_t *lock,
  * if the room in the socket buffer was not sufficient.
  */
 int
-gnet_stats_copy_basic(struct gnet_dump *d, struct gnet_stats_basic *b)
+gnet_stats_copy_basic(struct gnet_dump *d, struct gnet_stats_basic_pac=
ked *b)
 {
 	if (d->compat_tc_stats) {
 		d->tc_stats.bytes =3D b->bytes;
 		d->tc_stats.packets =3D b->packets;
 	}
=20
-	if (d->tail)
-		return gnet_stats_copy(d, TCA_STATS_BASIC, b, sizeof(*b));
+	if (d->tail) {
+		struct gnet_stats_basic sb;
=20
+		memset(&sb, 0, sizeof(sb));
+		sb.bytes =3D b->bytes;
+		sb.packets =3D b->packets;
+		return gnet_stats_copy(d, TCA_STATS_BASIC, &sb, sizeof(sb));
+	}
 	return 0;
 }
=20
diff --git a/net/netfilter/xt_RATEEST.c b/net/netfilter/xt_RATEEST.c
index 43f5676..d80b819 100644
--- a/net/netfilter/xt_RATEEST.c
+++ b/net/netfilter/xt_RATEEST.c
@@ -74,7 +74,7 @@ static unsigned int
 xt_rateest_tg(struct sk_buff *skb, const struct xt_target_param *par)
 {
 	const struct xt_rateest_target_info *info =3D par->targinfo;
-	struct gnet_stats_basic *stats =3D &info->est->bstats;
+	struct gnet_stats_basic_packed *stats =3D &info->est->bstats;
=20
 	spin_lock_bh(&info->est->lock);
 	stats->bytes +=3D skb->len;
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 2a8b83a..ab82f14 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -49,7 +49,7 @@ struct atm_flow_data {
 	struct socket		*sock;		/* for closing */
 	u32			classid;	/* x:y type ID */
 	int			ref;		/* reference count */
-	struct gnet_stats_basic	bstats;
+	struct gnet_stats_basic_packed	bstats;
 	struct gnet_stats_queue	qstats;
 	struct atm_flow_data	*next;
 	struct atm_flow_data	*excess;	/* flow for excess traffic;
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 23a1676..d5798e1 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -128,7 +128,7 @@ struct cbq_class
 	long			avgidle;
 	long			deficit;	/* Saved deficit for WRR */
 	psched_time_t		penalized;
-	struct gnet_stats_basic bstats;
+	struct gnet_stats_basic_packed bstats;
 	struct gnet_stats_queue qstats;
 	struct gnet_stats_rate_est rate_est;
 	struct tc_cbq_xstats	xstats;
diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index 7597fe1..12b2fb0 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -22,7 +22,7 @@ struct drr_class {
 	unsigned int			refcnt;
 	unsigned int			filter_cnt;
=20
-	struct gnet_stats_basic		bstats;
+	struct gnet_stats_basic_packed		bstats;
 	struct gnet_stats_queue		qstats;
 	struct gnet_stats_rate_est	rate_est;
 	struct list_head		alist;
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 362c281..dad0144 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -116,7 +116,7 @@ struct hfsc_class
 	struct Qdisc_class_common cl_common;
 	unsigned int	refcnt;		/* usage count */
=20
-	struct gnet_stats_basic bstats;
+	struct gnet_stats_basic_packed bstats;
 	struct gnet_stats_queue qstats;
 	struct gnet_stats_rate_est rate_est;
 	unsigned int	level;		/* class level in hierarchy */
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 88cd026..ec4d463 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -74,7 +74,7 @@ enum htb_cmode {
 struct htb_class {
 	struct Qdisc_class_common common;
 	/* general class parameters */
-	struct gnet_stats_basic bstats;
+	struct gnet_stats_basic_packed bstats;
 	struct gnet_stats_queue qstats;
 	struct gnet_stats_rate_est rate_est;
 	struct tc_htb_xstats xstats;	/* our special stats */
