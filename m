From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net 2/2] conntrack: enable to tune gc parameters
Date: Mon, 10 Oct 2016 12:18:24 +0200
Message-ID: <1476094704-17452-3-git-send-email-nicolas.dichtel@6wind.com>
References: <1476094704-17452-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
        fw@strlen.de, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net, pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:38668 "EHLO
        proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751986AbcJJKS6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2016 06:18:58 -0400
In-Reply-To: <1476094704-17452-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After commit b87a2f9199ea ("netfilter: conntrack: add gc worker to remove
timed-out entries"), netlink conntrack deletion events may be sent with a
huge delay. It could be interesting to let the user tweak gc parameters
depending on its use case.

CC: Florian Westphal <fw@strlen.de>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 Documentation/networking/nf_conntrack-sysctl.txt | 17 +++++++++++
 include/net/netfilter/nf_conntrack_core.h        |  5 ++++
 net/netfilter/nf_conntrack_core.c                | 17 +++++------
 net/netfilter/nf_conntrack_standalone.c          | 36 ++++++++++++++++++++++++
 4 files changed, 67 insertions(+), 8 deletions(-)

diff --git a/Documentation/networking/nf_conntrack-sysctl.txt b/Documentation/networking/nf_conntrack-sysctl.txt
index 399e4e866a9c..5b6ace93521d 100644
--- a/Documentation/networking/nf_conntrack-sysctl.txt
+++ b/Documentation/networking/nf_conntrack-sysctl.txt
@@ -37,6 +37,23 @@ nf_conntrack_expect_max - INTEGER
 	Maximum size of expectation table.  Default value is
 	nf_conntrack_buckets / 256. Minimum is 1.
 
+nf_conntrack_gc_interval - INTEGER
+	Maximum interval in second between two run of the conntrack gc. This
+	gc is in charge of removing stale entries. It also impacts the delay
+	before notifying the userland a conntrack deletion.
+	This sysctl is only writeable in the initial net namespace.
+
+nf_conntrack_gc_max_buckets - INTEGER
+nf_conntrack_gc_max_buckets_div - INTEGER
+	During a run, the conntrack gc processes at maximum
+	nf_conntrack_buckets/nf_conntrack_gc_max_buckets_div (and never more
+	than nf_conntrack_gc_max_buckets) entries.
+	These sysctl are only writeable in the initial net namespace.
+
+nf_conntrack_gc_max_evicts - INTEGER
+	The maximum number of entries to be evicted during a run of gc.
+	This sysctl is only writeable in the initial net namespace.
+
 nf_conntrack_frag6_high_thresh - INTEGER
 	default 262144
 
diff --git a/include/net/netfilter/nf_conntrack_core.h b/include/net/netfilter/nf_conntrack_core.h
index 62e17d1319ff..2a5ed368fb71 100644
--- a/include/net/netfilter/nf_conntrack_core.h
+++ b/include/net/netfilter/nf_conntrack_core.h
@@ -86,4 +86,9 @@ void nf_conntrack_lock(spinlock_t *lock);
 
 extern spinlock_t nf_conntrack_expect_lock;
 
+extern unsigned int nf_ct_gc_interval;
+extern unsigned int nf_ct_gc_max_buckets_div;
+extern unsigned int nf_ct_gc_max_buckets;
+extern unsigned int nf_ct_gc_max_evicts;
+
 #endif /* _NF_CONNTRACK_CORE_H */
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index ba6a1d421222..435b431e3449 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -83,10 +83,10 @@ static __read_mostly spinlock_t nf_conntrack_locks_all_lock;
 static __read_mostly DEFINE_SPINLOCK(nf_conntrack_locks_all_lock);
 static __read_mostly bool nf_conntrack_locks_all;
 
-#define GC_MAX_BUCKETS_DIV	64u
-#define GC_MAX_BUCKETS		8192u
-#define GC_INTERVAL		(5 * HZ)
-#define GC_MAX_EVICTS		256u
+unsigned int nf_ct_gc_interval = 5 * HZ;
+unsigned int nf_ct_gc_max_buckets = 8192;
+unsigned int nf_ct_gc_max_buckets_div = 64;
+unsigned int nf_ct_gc_max_evicts = 256;
 
 static struct conntrack_gc_work conntrack_gc_work;
 
@@ -936,13 +936,14 @@ static noinline int early_drop(struct net *net, unsigned int _hash)
 static void gc_worker(struct work_struct *work)
 {
 	unsigned int i, goal, buckets = 0, expired_count = 0;
-	unsigned long next_run = GC_INTERVAL;
+	unsigned long next_run = nf_ct_gc_interval;
 	unsigned int ratio, scanned = 0;
 	struct conntrack_gc_work *gc_work;
 
 	gc_work = container_of(work, struct conntrack_gc_work, dwork.work);
 
-	goal = min(nf_conntrack_htable_size / GC_MAX_BUCKETS_DIV, GC_MAX_BUCKETS);
+	goal = min(nf_conntrack_htable_size / nf_ct_gc_max_buckets_div,
+		   nf_ct_gc_max_buckets);
 	i = gc_work->last_bucket;
 
 	do {
@@ -977,7 +978,7 @@ static void gc_worker(struct work_struct *work)
 		rcu_read_unlock();
 		cond_resched_rcu_qs();
 	} while (++buckets < goal &&
-		 expired_count < GC_MAX_EVICTS);
+		 expired_count < nf_ct_gc_max_evicts);
 
 	if (gc_work->exiting)
 		return;
@@ -1885,7 +1886,7 @@ int nf_conntrack_init_start(void)
 	nf_ct_untracked_status_or(IPS_CONFIRMED | IPS_UNTRACKED);
 
 	conntrack_gc_work_init(&conntrack_gc_work);
-	schedule_delayed_work(&conntrack_gc_work.dwork, GC_INTERVAL);
+	schedule_delayed_work(&conntrack_gc_work.dwork, nf_ct_gc_interval);
 
 	return 0;
 
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 5f446cd9f3fd..c5310fb35eca 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -445,6 +445,8 @@ static void nf_conntrack_standalone_fini_proc(struct net *net)
 /* Sysctl support */
 
 #ifdef CONFIG_SYSCTL
+static int one = 1;
+static int int_max = INT_MAX;
 /* Log invalid packets of a given protocol */
 static int log_invalid_proto_min __read_mostly;
 static int log_invalid_proto_max __read_mostly = 255;
@@ -517,6 +519,40 @@ static struct ctl_table nf_ct_sysctl_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+	{
+		.procname	= "nf_conntrack_gc_interval",
+		.data		= &nf_ct_gc_interval,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
+	{
+		.procname	= "nf_conntrack_gc_max_buckets",
+		.data		= &nf_ct_gc_max_buckets,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &one,
+		.extra2		= &int_max,
+	},
+	{
+		.procname	= "nf_conntrack_gc_max_buckets_div",
+		.data		= &nf_ct_gc_max_buckets_div,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &one,
+		.extra2		= &int_max,
+	},
+	{
+		.procname	= "nf_conntrack_gc_max_evicts",
+		.data		= &nf_ct_gc_max_evicts,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &one,
+		.extra2		= &int_max,
+	},
 	{ }
 };
 
-- 
2.8.1
