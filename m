From: Patrick McHardy <kaber@trash.net>
Subject: Re: Hard freeze with 2.6.10-rc3 and QoS, worked fine with 2.6.9
Date: Tue, 07 Dec 2004 17:59:52 +0100
Message-ID: <41B5E188.5050800@trash.net>
References: <1102380430.6103.6.camel@buffy>	 <20041206224441.628e7885.akpm@osdl.org> <1102422544.1088.98.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010705030109060209080805"
Cc: Andrew Morton <akpm@osdl.org>, Thomas Cataldo <tomc@compaqnet.fr>,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com, tgraf@suug.ch,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261841AbULGRAa@vger.kernel.org>
To: hadi@cyberus.ca
In-Reply-To: <1102422544.1088.98.camel@jzny.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010705030109060209080805
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

jamal wrote:

>Can you do a: 
>tc -V
>
>This seems to point to probably be a backward compat issue which was
>overlooked in the stats.
>
That's also what I thought at first. But the problem is in
tcf_action_copy_stats, it assumes a->priv has the same layout as
struct tcf_act_hdr, which is not true for struct tcf_police. This
patch rearranges struct tcf_police to match tcf_act_hdr.

Signed-off-by: Patrick McHardy <kaber@trash.net>


--------------010705030109060209080805
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

===== include/net/act_api.h 1.4 vs edited =====
--- 1.4/include/net/act_api.h	2004-11-06 01:33:12 +01:00
+++ edited/include/net/act_api.h	2004-12-07 17:53:37 +01:00
@@ -8,15 +8,23 @@
 #include <net/sch_generic.h>
 #include <net/pkt_sched.h>
 
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
 struct tcf_police
 {
-	struct tcf_police *next;
-	int		refcnt;
-#ifdef CONFIG_NET_CLS_ACT
-	int		bindcnt;
-#endif
-	u32		index;
-	int		action;
+	tca_gen(police);
 	int		result;
 	u32		ewma_rate;
 	u32		burst;
@@ -24,33 +32,14 @@
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
 
 #define ACT_P_CREATED 1
 #define ACT_P_DELETED 1
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
 
 struct tcf_act_hdr
 {

--------------010705030109060209080805--
