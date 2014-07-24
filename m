From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 7/9] inet: frag: remove periodic secret rebuild timer
Date: Thu, 24 Jul 2014 16:50:35 +0200
Message-ID: <1406213437-6155-8-git-send-email-nikolay@redhat.com>
References: <1406213437-6155-1-git-send-email-nikolay@redhat.com>
Cc: Florian Westphal <fw@strlen.de>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Alexander Aring <alex.aring@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22397 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933322AbaGXOwL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2014 10:52:11 -0400
In-Reply-To: <1406213437-6155-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

merge functionality into the eviction workqueue.

Instead of rebuilding every n seconds, take advantage of the upper
hash chain length limit.

If we hit it, mark table for rebuild and schedule workqueue.
To prevent frequent rebuilds when we're completely overloaded,
don't rebuild more than once every 5 seconds.

ipfrag_secret_interval sysctl is now obsolete and has been marked as
deprecated, it still can be changed so scripts won't be broken but it
won't have any effect. A comment is left above each unused secret_timer
variable to avoid confusion.

Joint work with Nikolay Aleksandrov.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 Documentation/networking/ip-sysctl.txt  | 10 --------
 include/net/inet_frag.h                 |  4 +--
 net/ieee802154/reassembly.c             |  5 ++--
 net/ipv4/inet_fragment.c                | 43 ++++++++++++++++++++++-----------
 net/ipv4/ip_fragment.c                  |  5 ++--
 net/ipv6/netfilter/nf_conntrack_reasm.c |  1 -
 net/ipv6/reassembly.c                   |  5 ++--
 7 files changed, 40 insertions(+), 33 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 625c8dda4be7..e8c304e37831 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -111,11 +111,6 @@ ipfrag_low_thresh - INTEGER
 ipfrag_time - INTEGER
 	Time in seconds to keep an IP fragment in memory.
 
-ipfrag_secret_interval - INTEGER
-	Regeneration interval (in seconds) of the hash secret (or lifetime
-	for the hash secret) for IP fragments.
-	Default: 600
-
 ipfrag_max_dist - INTEGER
 	ipfrag_max_dist is a non-negative integer value which defines the
 	maximum "disorder" which is allowed among fragments which share a
@@ -1164,11 +1159,6 @@ ip6frag_low_thresh - INTEGER
 ip6frag_time - INTEGER
 	Time in seconds to keep an IPv6 fragment in memory.
 
-ip6frag_secret_interval - INTEGER
-	Regeneration interval (in seconds) of the hash secret (or lifetime
-	for the hash secret) for IPv6 fragments.
-	Default: 600
-
 conf/default/*:
 	Change the interface-specific default settings.
 
diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 90d21ea62c59..d9cc5bb64854 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -58,11 +58,11 @@ struct inet_frags {
 	 * Its primarily a rebuild protection rwlock.
 	 */
 	rwlock_t		lock ____cacheline_aligned_in_smp;
-	int			secret_interval;
-	struct timer_list	secret_timer;
 
 	struct work_struct	frags_work;
 	unsigned int next_bucket;
+	unsigned long last_rebuild_jiffies;
+	bool rebuild;
 
 	/* The first call to hashfn is responsible to initialize
 	 * rnd. This is best done with net_get_random_once.
diff --git a/net/ieee802154/reassembly.c b/net/ieee802154/reassembly.c
index b4bc7a50eccf..20d219682d84 100644
--- a/net/ieee802154/reassembly.c
+++ b/net/ieee802154/reassembly.c
@@ -419,10 +419,12 @@ static struct ctl_table lowpan_frags_ns_ctl_table[] = {
 	{ }
 };
 
+/* secret interval has been deprecated */
+static int lowpan_frags_secret_interval_unused;
 static struct ctl_table lowpan_frags_ctl_table[] = {
 	{
 		.procname	= "6lowpanfrag_secret_interval",
-		.data		= &lowpan_frags.secret_interval,
+		.data		= &lowpan_frags_secret_interval_unused,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
@@ -562,7 +564,6 @@ int __init lowpan_net_frag_init(void)
 	lowpan_frags.qsize = sizeof(struct frag_queue);
 	lowpan_frags.match = lowpan_frag_match;
 	lowpan_frags.frag_expire = lowpan_frag_expire;
-	lowpan_frags.secret_interval = 10 * 60 * HZ;
 	inet_frags_init(&lowpan_frags);
 
 	return ret;
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index 198a5ed7a815..58d4c38534f6 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -28,6 +28,9 @@
 #define INETFRAGS_EVICT_BUCKETS   128
 #define INETFRAGS_EVICT_MAX	  512
 
+/* don't rebuild inetfrag table with new secret more often than this */
+#define INETFRAGS_MIN_REBUILD_INTERVAL (5 * HZ)
+
 /* Given the OR values of all fragments, apply RFC 3168 5.3 requirements
  * Value : 0xff if frame should be dropped.
  *         0 or INET_ECN_CE value, to be ORed in to final iph->tos field
@@ -55,16 +58,24 @@ inet_frag_hashfn(const struct inet_frags *f, const struct inet_frag_queue *q)
 	return f->hashfn(q) & (INETFRAGS_HASHSZ - 1);
 }
 
-static void inet_frag_secret_rebuild(unsigned long dummy)
+static bool inet_frag_may_rebuild(struct inet_frags *f)
+{
+	return time_after(jiffies,
+	       f->last_rebuild_jiffies + INETFRAGS_MIN_REBUILD_INTERVAL);
+}
+
+static void inet_frag_secret_rebuild(struct inet_frags *f)
 {
-	struct inet_frags *f = (struct inet_frags *)dummy;
-	unsigned long now = jiffies;
 	int i;
 
 	/* Per bucket lock NOT needed here, due to write lock protection */
-	write_lock(&f->lock);
+	write_lock_bh(&f->lock);
+
+	if (!inet_frag_may_rebuild(f))
+		goto out;
 
 	get_random_bytes(&f->rnd, sizeof(u32));
+
 	for (i = 0; i < INETFRAGS_HASHSZ; i++) {
 		struct inet_frag_bucket *hb;
 		struct inet_frag_queue *q;
@@ -85,9 +96,11 @@ static void inet_frag_secret_rebuild(unsigned long dummy)
 			}
 		}
 	}
-	write_unlock(&f->lock);
 
-	mod_timer(&f->secret_timer, now + f->secret_interval);
+	f->rebuild = false;
+	f->last_rebuild_jiffies = jiffies;
+out:
+	write_unlock_bh(&f->lock);
 }
 
 static bool inet_fragq_should_evict(const struct inet_frag_queue *q)
@@ -162,6 +175,8 @@ static void inet_frag_worker(struct work_struct *work)
 	f->next_bucket = i;
 
 	read_unlock_bh(&f->lock);
+	if (f->rebuild && inet_frag_may_rebuild(f))
+		inet_frag_secret_rebuild(f);
 }
 
 static void inet_frag_schedule_worker(struct inet_frags *f)
@@ -183,11 +198,7 @@ void inet_frags_init(struct inet_frags *f)
 		INIT_HLIST_HEAD(&hb->chain);
 	}
 	rwlock_init(&f->lock);
-
-	setup_timer(&f->secret_timer, inet_frag_secret_rebuild,
-			(unsigned long)f);
-	f->secret_timer.expires = jiffies + f->secret_interval;
-	add_timer(&f->secret_timer);
+	f->last_rebuild_jiffies = 0;
 }
 EXPORT_SYMBOL(inet_frags_init);
 
@@ -199,7 +210,6 @@ EXPORT_SYMBOL(inet_frags_init_net);
 
 void inet_frags_fini(struct inet_frags *f)
 {
-	del_timer(&f->secret_timer);
 	cancel_work_sync(&f->frags_work);
 }
 EXPORT_SYMBOL(inet_frags_fini);
@@ -399,8 +409,13 @@ struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
 
 	if (depth <= INETFRAGS_MAXDEPTH)
 		return inet_frag_create(nf, f, key);
-	else
-		return ERR_PTR(-ENOBUFS);
+
+	if (inet_frag_may_rebuild(f)) {
+		f->rebuild = true;
+		inet_frag_schedule_worker(f);
+	}
+
+	return ERR_PTR(-ENOBUFS);
 }
 EXPORT_SYMBOL(inet_frag_find);
 
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 8fbeee495037..44e591a7e03f 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -720,10 +720,12 @@ static struct ctl_table ip4_frags_ns_ctl_table[] = {
 	{ }
 };
 
+/* secret interval has been deprecated */
+static int ip4_frags_secret_interval_unused;
 static struct ctl_table ip4_frags_ctl_table[] = {
 	{
 		.procname	= "ipfrag_secret_interval",
-		.data		= &ip4_frags.secret_interval,
+		.data		= &ip4_frags_secret_interval_unused,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
@@ -853,6 +855,5 @@ void __init ipfrag_init(void)
 	ip4_frags.qsize = sizeof(struct ipq);
 	ip4_frags.match = ip4_frag_match;
 	ip4_frags.frag_expire = ip_expire;
-	ip4_frags.secret_interval = 10 * 60 * HZ;
 	inet_frags_init(&ip4_frags);
 }
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index fb0f72a0ff31..3b3ef9774cc2 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -669,7 +669,6 @@ int nf_ct_frag6_init(void)
 	nf_frags.qsize = sizeof(struct frag_queue);
 	nf_frags.match = ip6_frag_match;
 	nf_frags.frag_expire = nf_ct_frag6_expire;
-	nf_frags.secret_interval = 10 * 60 * HZ;
 	inet_frags_init(&nf_frags);
 
 	ret = register_pernet_subsys(&nf_ct_net_ops);
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index af85551682c2..987fea46b915 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -604,10 +604,12 @@ static struct ctl_table ip6_frags_ns_ctl_table[] = {
 	{ }
 };
 
+/* secret interval has been deprecated */
+static int ip6_frags_secret_interval_unused;
 static struct ctl_table ip6_frags_ctl_table[] = {
 	{
 		.procname	= "ip6frag_secret_interval",
-		.data		= &ip6_frags.secret_interval,
+		.data		= &ip6_frags_secret_interval_unused,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
@@ -737,7 +739,6 @@ int __init ipv6_frag_init(void)
 	ip6_frags.qsize = sizeof(struct frag_queue);
 	ip6_frags.match = ip6_frag_match;
 	ip6_frags.frag_expire = ip6_frag_expire;
-	ip6_frags.secret_interval = 10 * 60 * HZ;
 	inet_frags_init(&ip6_frags);
 out:
 	return ret;
-- 
1.9.3
