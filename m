From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Hard freeze with 2.6.10-rc3 and QoS, worked fine with 2.6.9
Date: Tue, 7 Dec 2004 18:07:48 +0100
Message-ID: <20041207170748.GF1371@postel.suug.ch>
References: <1102380430.6103.6.camel@buffy> <20041206224441.628e7885.akpm@osdl.org> <1102422544.1088.98.camel@jzny.localdomain> <41B5E188.5050800@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, Andrew Morton <akpm@osdl.org>,
	Thomas Cataldo <tomc@compaqnet.fr>,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261868AbULGRHz@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <41B5E188.5050800@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Patrick McHardy <41B5E188.5050800@trash.net> 2004-12-07 17:59
> jamal wrote:
> 
> >Can you do a: 
> >tc -V
> >
> >This seems to point to probably be a backward compat issue which was
> >overlooked in the stats.
> >
> That's also what I thought at first. But the problem is in
> tcf_action_copy_stats, it assumes a->priv has the same layout as
> struct tcf_act_hdr, which is not true for struct tcf_police. This
> patch rearranges struct tcf_police to match tcf_act_hdr.

Hehe, see my post a few minutes back. I came up with nearly the same
solution ;-> The only difference to my patch is that I don't touch
tcf_police if the action code isn't compiled.


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
