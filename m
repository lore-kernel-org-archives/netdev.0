From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net] conntrack: perform a full scan in gc
Date: Tue, 18 Oct 2016 10:30:35 +0200
Message-ID: <1476779435-30503-1-git-send-email-nicolas.dichtel@6wind.com>
References: <20161014105327.GA8655@salvia>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        netfilter-devel@vger.kernel.org,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: pablo@netfilter.org, fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:41941 "EHLO
        proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755421AbcJRIaz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 04:30:55 -0400
In-Reply-To: <20161014105327.GA8655@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After commit b87a2f9199ea ("netfilter: conntrack: add gc worker to remove
timed-out entries"), netlink conntrack deletion events may be sent with a
huge delay (5 minutes).

There is two ways to evict conntrack:
 - during a conntrack lookup;
 - during a conntrack dump.
Let's do a full scan of conntrack entries after a period of inactivity
(no conntrack lookup).

CC: Florian Westphal <fw@strlen.de>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

Here is another proposal to try to fix the problem.
Comments are welcomed,
Nicolas

 net/netfilter/nf_conntrack_core.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index ba6a1d421222..3dbb27bd9582 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -87,6 +87,7 @@ static __read_mostly bool nf_conntrack_locks_all;
 #define GC_MAX_BUCKETS		8192u
 #define GC_INTERVAL		(5 * HZ)
 #define GC_MAX_EVICTS		256u
+static bool gc_full_scan = true;
 
 static struct conntrack_gc_work conntrack_gc_work;
 
@@ -511,6 +512,7 @@ ____nf_conntrack_find(struct net *net, const struct nf_conntrack_zone *zone,
 	unsigned int bucket, hsize;
 
 begin:
+	gc_full_scan = false;
 	nf_conntrack_get_ht(&ct_hash, &hsize);
 	bucket = reciprocal_scale(hash, hsize);
 
@@ -942,7 +944,11 @@ static void gc_worker(struct work_struct *work)
 
 	gc_work = container_of(work, struct conntrack_gc_work, dwork.work);
 
-	goal = min(nf_conntrack_htable_size / GC_MAX_BUCKETS_DIV, GC_MAX_BUCKETS);
+	if (gc_full_scan)
+		goal = nf_conntrack_htable_size;
+	else
+		goal = min(nf_conntrack_htable_size / GC_MAX_BUCKETS_DIV,
+			   GC_MAX_BUCKETS);
 	i = gc_work->last_bucket;
 
 	do {
@@ -977,7 +983,8 @@ static void gc_worker(struct work_struct *work)
 		rcu_read_unlock();
 		cond_resched_rcu_qs();
 	} while (++buckets < goal &&
-		 expired_count < GC_MAX_EVICTS);
+		 (gc_full_scan || expired_count < GC_MAX_EVICTS));
+	gc_full_scan = true;
 
 	if (gc_work->exiting)
 		return;
-- 
2.8.1
