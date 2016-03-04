From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH net-next 3/3] ipv6: per netns FIB garbage collection
Date: Fri,  4 Mar 2016 11:59:35 +0100 (CET)
Message-ID: <6ede0941c804351a62d9ee7c049c97038c2af2a6.1457085016.git.mkubecek@suse.cz>
References: <cover.1457085016.git.mkubecek@suse.cz>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Martin KaFai Lau <kafai@fb.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1457085016.git.mkubecek@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

One of our customers observed issues with FIB6 garbage collectors
running in different network namespaces blocking each other, resulting
in soft lockups (fib6_run_gc() initiated from timer runs always in
forced mode).

Now that FIB6 walkers are separated per namespace, there is no more need
for instances of fib6_run_gc() in different namespaces blocking each
other. There is still a call to icmp6_dst_gc() which operates on shared
data but this function is protected by its own shared lock.

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 include/net/netns/ipv6.h | 1 +
 net/ipv6/ip6_fib.c       | 9 ++++-----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index f0109b973648..10d0848f5b8a 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -61,6 +61,7 @@ struct netns_ipv6 {
 	struct list_head	fib6_walkers;
 	struct dst_ops		ip6_dst_ops;
 	rwlock_t		fib6_walker_lock;
+	spinlock_t		fib6_gc_lock;
 	unsigned int		 ip6_rt_gc_expire;
 	unsigned long		 ip6_rt_last_gc;
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index af8a0fb39eda..5145841612b3 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1776,16 +1776,14 @@ static int fib6_age(struct rt6_info *rt, void *arg)
 	return 0;
 }
 
-static DEFINE_SPINLOCK(fib6_gc_lock);
-
 void fib6_run_gc(unsigned long expires, struct net *net, bool force)
 {
 	struct fib6_gc_args gc_args;
 	unsigned long now;
 
 	if (force) {
-		spin_lock_bh(&fib6_gc_lock);
-	} else if (!spin_trylock_bh(&fib6_gc_lock)) {
+		spin_lock_bh(&net->ipv6.fib6_gc_lock);
+	} else if (!spin_trylock_bh(&net->ipv6.fib6_gc_lock)) {
 		mod_timer(&net->ipv6.ip6_fib_timer, jiffies + HZ);
 		return;
 	}
@@ -1804,7 +1802,7 @@ void fib6_run_gc(unsigned long expires, struct net *net, bool force)
 					+ net->ipv6.sysctl.ip6_rt_gc_interval));
 	else
 		del_timer(&net->ipv6.ip6_fib_timer);
-	spin_unlock_bh(&fib6_gc_lock);
+	spin_unlock_bh(&net->ipv6.fib6_gc_lock);
 }
 
 static void fib6_gc_timer_cb(unsigned long arg)
@@ -1816,6 +1814,7 @@ static int __net_init fib6_net_init(struct net *net)
 {
 	size_t size = sizeof(struct hlist_head) * FIB6_TABLE_HASHSZ;
 
+	spin_lock_init(&net->ipv6.fib6_gc_lock);
 	rwlock_init(&net->ipv6.fib6_walker_lock);
 	INIT_LIST_HEAD(&net->ipv6.fib6_walkers);
 	setup_timer(&net->ipv6.ip6_fib_timer, fib6_gc_timer_cb, (unsigned long)net);
-- 
2.7.2
