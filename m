From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH net-next 1/3] ipv6: replace global gc_args with local variable
Date: Fri,  4 Mar 2016 11:59:15 +0100 (CET)
Message-ID: <10c0ebdbf7d9199fc942bedf3cb2154aff2b6084.1457085016.git.mkubecek@suse.cz>
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

Global variable gc_args is only used in fib6_run_gc() and functions
called from it. As fib6_run_gc() makes sure there is at most one
instance of fib6_clean_all() running at any moment, we can replace
gc_args with a local variable which will be needed once multiple
instances (per netns) of garbage collector are allowed.

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 net/ipv6/ip6_fib.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 0c7e276c230e..d7c715accac9 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1725,14 +1725,15 @@ static void fib6_flush_trees(struct net *net)
  *	Garbage collection
  */
 
-static struct fib6_gc_args
+struct fib6_gc_args
 {
 	int			timeout;
 	int			more;
-} gc_args;
+};
 
 static int fib6_age(struct rt6_info *rt, void *arg)
 {
+	struct fib6_gc_args *gc_args = arg;
 	unsigned long now = jiffies;
 
 	/*
@@ -1748,10 +1749,10 @@ static int fib6_age(struct rt6_info *rt, void *arg)
 			RT6_TRACE("expiring %p\n", rt);
 			return -1;
 		}
-		gc_args.more++;
+		gc_args->more++;
 	} else if (rt->rt6i_flags & RTF_CACHE) {
 		if (atomic_read(&rt->dst.__refcnt) == 0 &&
-		    time_after_eq(now, rt->dst.lastuse + gc_args.timeout)) {
+		    time_after_eq(now, rt->dst.lastuse + gc_args->timeout)) {
 			RT6_TRACE("aging clone %p\n", rt);
 			return -1;
 		} else if (rt->rt6i_flags & RTF_GATEWAY) {
@@ -1769,7 +1770,7 @@ static int fib6_age(struct rt6_info *rt, void *arg)
 				return -1;
 			}
 		}
-		gc_args.more++;
+		gc_args->more++;
 	}
 
 	return 0;
@@ -1779,6 +1780,7 @@ static DEFINE_SPINLOCK(fib6_gc_lock);
 
 void fib6_run_gc(unsigned long expires, struct net *net, bool force)
 {
+	struct fib6_gc_args gc_args;
 	unsigned long now;
 
 	if (force) {
@@ -1792,7 +1794,7 @@ void fib6_run_gc(unsigned long expires, struct net *net, bool force)
 
 	gc_args.more = icmp6_dst_gc();
 
-	fib6_clean_all(net, fib6_age, NULL);
+	fib6_clean_all(net, fib6_age, &gc_args);
 	now = jiffies;
 	net->ipv6.ip6_rt_last_gc = now;
 
-- 
2.7.2
