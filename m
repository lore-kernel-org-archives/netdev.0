From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] rtnetlink & address family problem
Date: Tue, 7 Dec 2004 17:55:01 +0100
Message-ID: <20041207165501.GE1371@postel.suug.ch>
References: <41B0A5B4.6060108@suse.cz> <20041206140214.GA749@postel.suug.ch> <1102386461.1093.26.camel@jzny.localdomain> <20041207124922.GA1371@postel.suug.ch> <1102424568.1089.120.camel@jzny.localdomain> <20041207131706.GB1371@postel.suug.ch> <1102425618.1089.133.camel@jzny.localdomain> <20041207141033.GD1371@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michal Ludvig <mludvig@suse.cz>, Andrew Morton <akpm@osdl.org>,
        Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com,
        Jan Kara <jack@suse.cz>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <20041207141033.GD1371@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Thomas Graf <20041207141033.GD1371@postel.suug.ch> 2004-12-07 15:10
> * jamal <1102425618.1089.133.camel@jzny.localdomain> 2004-12-07 08:20
> > On Tue, 2004-12-07 at 08:17, Thomas Graf wrote:
> > 
> > > It's not really related to the gnet_stats code.  stats_lock isn't set
> > > in the action code when using an older iproute2. I haven't tested this
> > > case because it was marked as broken anyway. 
> > 
> > Can you ping my memory on this? Is this tc with initial support
> > for actions or something much older than that.
> 
> I'm not sure, I'm testing with a version having no action support at
> all. It should be fairly easy to find the bug once I have the time to
> really look into it. I'm still getting interrupted all the time at
> the moment.

One major problem is that the tc_dump_action path doesn't take
care of TCA_OLD_COMPAT resulting in calling tcf_action_copy_stats
for policers which is a bad thing since their a->priv is set to
tcf_police instead of the generic header and thus causes random
behaviour.

One solution would be to make tcf_police compatible to tca_gen.

Thoughts?


--- linux-2.6.10-rc2-bk13.orig/include/net/act_api.h	2004-11-30 14:01:11.000000000 +0100
+++ linux-2.6.10-rc2-bk13/include/net/act_api.h	2004-12-07 17:49:50.000000000 +0100
@@ -8,15 +8,42 @@
 #include <net/sch_generic.h>
 #include <net/pkt_sched.h>
 
+#ifdef CONFIG_NET_CLS_ACT
+
+#define ACT_P_CREATED 1
+#define ACT_P_DELETED 1
+#define tca_gen(name) \
+struct tcf_##name *next; \
+	u32 index; \
+	int refcnt; \
+	int bindcnt; \
+	u32 capab; \
+	int action; \
+	struct tcf_t tm; \
+	struct gnet_stats_basic bstats; \
+	struct gnet_stats_queue qstats; \
+	struct gnet_stats_rate_est rate_est; \
+	spinlock_t *stats_lock; \
+	spinlock_t lock
+
+#endif
+
 struct tcf_police
 {
+#ifdef CONFIG_NET_CLS_ACT
+	tca_gen(police);
+#else
 	struct tcf_police *next;
 	int		refcnt;
-#ifdef CONFIG_NET_CLS_ACT
-	int		bindcnt;
-#endif
 	u32		index;
 	int		action;
+	spinlock_t	lock;
+	struct gnet_stats_basic bstats;
+	struct gnet_stats_queue qstats;
+	struct gnet_stats_rate_est rate_est;
+	spinlock_t	*stats_lock;
+#endif
+
 	int		result;
 	u32		ewma_rate;
 	u32		burst;
@@ -24,34 +51,12 @@
 	u32		toks;
 	u32		ptoks;
 	psched_time_t	t_c;
-	spinlock_t	lock;
 	struct qdisc_rate_table *R_tab;
 	struct qdisc_rate_table *P_tab;
-
-	struct gnet_stats_basic bstats;
-	struct gnet_stats_queue qstats;
-	struct gnet_stats_rate_est rate_est;
-	spinlock_t	*stats_lock;
 };
 
 #ifdef CONFIG_NET_CLS_ACT
 
-#define ACT_P_CREATED 1
-#define ACT_P_DELETED 1
-#define tca_gen(name) \
-struct tcf_##name *next; \
-	u32 index; \
-	int refcnt; \
-	int bindcnt; \
-	u32 capab; \
-	int action; \
-	struct tcf_t tm; \
-	struct gnet_stats_basic bstats; \
-	struct gnet_stats_queue qstats; \
-	struct gnet_stats_rate_est rate_est; \
-	spinlock_t *stats_lock; \
-	spinlock_t lock
-
 struct tcf_act_hdr
 {
 	tca_gen(act_hdr);
