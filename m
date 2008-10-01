From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when
	gc_elasticity is exceeded
Date: Wed, 1 Oct 2008 14:08:46 -0400
Message-ID: <20081001180846.GB3566@hmsreliant.think-freely.org>
References: <48E141F3.9000903@cosmosbay.com> <20080929223801.GA3157@hmsreliant.think-freely.org> <48E1C104.2080801@cosmosbay.com> <20080930.071023.07946874.davem@davemloft.net> <48E25F02.8030303@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:47631 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753357AbYJASK7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 14:10:59 -0400
Content-Disposition: inline
In-Reply-To: <48E25F02.8030303@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey all-
	Since Eric mentioned the use of statistical analysis to determine if
hash chains were growing improperly, I thought I would take a stab at such an
approach.  I'm no statistics expert, but it would seem to me that simply
computing the standard deviation of all the non-zero chain lengths would give a
good guide point to determine if we needed to invalidate our hash table.  I've
written the below implementation.  I've not tested it (I'll be doing that here
shortly for the next few days), but I wanted to post it to get feedback from you
all on the subject.  The highlights are:

1) We add a counter to rt_hash_bucket structure to track the length of each
individual chain.  I realize this is sub-optimal, as it adds potentially lots of
memory to hash table as a whole (4 bytes * number of hash buckets).  I'm afraid
I've not come up with a better way to track that yet.  We also track the total
number of route entries and the number of non-zero length chains.  Lastly we
also maintain a global maximum chain length which defines the longest chain we
will tolerate in the route table.  This patch defines it as the mean chain
length plus one standard deviation.

2) The above new counters are updated as we add/delete entries from the hash
table

3) in rt_intern_hash if we don't find an entry to delete while walking a given
chain that is over its elasticity, we check the chain length against the maximum
length, which we defined in 1.  If it exceeds the max length, we recompute the
mean and standard deviation value, and check the length again (see
rt_hash_sd_update).  If the length is still longer than the new max length, we
execute an emergency hash rebuild.

Again, I've not started testing it, but if this works, we should be able to
eliminate the need for periodic cache rebuilds entirely, replacing it with on
demand detection.  I could see a usefulness for add a control to tweak the
multiple count of standard deviations allowed from the mean, for environments
where route entries just happened to hash to the same bucket, but I figure, let
me get this working properly first.

I'll be doing basic testing over the next few days.  Any thoughts & comments are
appreciated, as well as testing in more strenuous, high route entry/high
throughput environments.

Thanks & Regards
Neil

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 route.c |  102 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 100 insertions(+), 2 deletions(-)


diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 6ee5354..8e59900 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -145,6 +145,7 @@ static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst);
 static void		 ipv4_link_failure(struct sk_buff *skb);
 static void		 ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu);
 static int rt_garbage_collect(struct dst_ops *ops);
+static void rt_emergency_hash_rebuild(struct net *net);
 
 
 static struct dst_ops ipv4_dst_ops = {
@@ -200,7 +201,14 @@ const __u8 ip_tos2prio[16] = {
 
 struct rt_hash_bucket {
 	struct rtable	*chain;
+	atomic_t	chain_length;
 };
+
+atomic_t rt_hash_total_count;
+atomic_t rt_hash_nz_count;
+
+static int rt_chain_length_max;
+
 #if defined(CONFIG_SMP) || defined(CONFIG_DEBUG_SPINLOCK) || \
 	defined(CONFIG_PROVE_LOCKING)
 /*
@@ -601,6 +609,53 @@ static inline int ip_rt_proc_init(void)
 }
 #endif /* CONFIG_PROC_FS */
 
+static void rt_hash_sd_update(void)
+{
+	int temp, i;
+	unsigned long long sd;
+	int average = atomic_read(&rt_hash_total_count);
+	int nzcount = atomic_read(&rt_hash_nz_count);
+
+	average = DIV_ROUND_UP(average, nzcount);
+
+	sd = 0;
+	for (i = 0; i < (1 << rt_hash_log); i++) {
+		temp = atomic_read(&rt_hash_table[i].chain_length);
+		if (unlikely(temp))
+			sd += (temp-average)^2;
+	}
+
+	sd = DIV_ROUND_UP(sd, nzcount);
+
+	/*
+	 * Note: 46340 squared is 0x7fffffff
+	 */
+	for (i = 1; i < 46340; i++)
+		if ((i^2) > sd)
+			break;
+
+	/*
+	 * The maximum allowable length of a hash
+	 * chain is the average plus one standard
+	 * deviation
+	 */
+	rt_chain_length_max = average + sd;
+}
+
+static inline void rt_hash_sd_dec(int hash)
+{
+	atomic_dec(&rt_hash_table[hash].chain_length);
+	if (atomic_dec_and_test(&rt_hash_total_count))
+		atomic_dec(&rt_hash_nz_count);
+}
+
+static inline void rt_hash_sd_inc(int hash)
+{
+	atomic_inc(&rt_hash_table[hash].chain_length);
+	if (atomic_inc_return(&rt_hash_total_count) == 1)
+		atomic_inc(&rt_hash_nz_count);
+}
+
 static inline void rt_free(struct rtable *rt)
 {
 	call_rcu_bh(&rt->u.dst.rcu_head, dst_rcu_free);
@@ -731,6 +786,7 @@ static void rt_do_flush(int process_context)
 			} else {
 				*prev = next;
 				rt_free(p);
+				rt_hash_sd_dec(i);
 			}
 		}
 		}
@@ -744,7 +800,9 @@ static void rt_do_flush(int process_context)
 		for (; rth != tail; rth = next) {
 			next = rth->u.dst.rt_next;
 			rt_free(rth);
+			rt_hash_sd_dec(i);
 		}
+
 	}
 }
 
@@ -777,6 +835,7 @@ static void rt_check_expire(void)
 			if (rt_is_expired(rth)) {
 				*rthp = rth->u.dst.rt_next;
 				rt_free(rth);
+				rt_hash_sd_dec(i);
 				continue;
 			}
 			if (rth->u.dst.expires) {
@@ -795,6 +854,7 @@ static void rt_check_expire(void)
 			/* Cleanup aged off entries. */
 			*rthp = rth->u.dst.rt_next;
 			rt_free(rth);
+			rt_hash_sd_dec(i);
 		}
 		spin_unlock_bh(rt_hash_lock_addr(i));
 	}
@@ -927,6 +987,7 @@ static int rt_garbage_collect(struct dst_ops *ops)
 				}
 				*rthp = rth->u.dst.rt_next;
 				rt_free(rth);
+				rt_hash_sd_dec(i);
 				goal--;
 			}
 			spin_unlock_bh(rt_hash_lock_addr(k));
@@ -991,7 +1052,6 @@ static int rt_intern_hash(unsigned hash, struct rtable *rt, struct rtable **rp)
 	int attempts = !in_softirq();
 
 restart:
-	chain_length = 0;
 	min_score = ~(u32)0;
 	cand = NULL;
 	candp = NULL;
@@ -1004,6 +1064,7 @@ restart:
 		if (rt_is_expired(rth)) {
 			*rthp = rth->u.dst.rt_next;
 			rt_free(rth);
+			rt_hash_sd_dec(hash);
 			continue;
 		}
 		if (compare_keys(&rth->fl, &rt->fl) && compare_netns(rth, rt)) {
@@ -1040,11 +1101,11 @@ restart:
 			}
 		}
 
-		chain_length++;
 
 		rthp = &rth->u.dst.rt_next;
 	}
 
+	chain_length = atomic_read(&rt_hash_table[hash].chain_length);
 	if (cand) {
 		/* ip_rt_gc_elasticity used to be average length of chain
 		 * length, when exceeded gc becomes really aggressive.
@@ -1055,6 +1116,23 @@ restart:
 		if (chain_length > ip_rt_gc_elasticity) {
 			*candp = cand->u.dst.rt_next;
 			rt_free(cand);
+			rt_hash_sd_dec(hash);
+		}
+	} else {
+		if (chain_length && (chain_length > rt_chain_length_max)) {
+			/*
+			 * This chain is longer than our computed
+			 * max allowable length, lets recompute to 
+			 * be sure its still up to date
+			 */
+			rt_hash_sd_update();
+			if (chain_length > rt_chain_length_max) {
+				/*
+				 * We're still to long, do an emergency rebuild
+				 */
+				rt_emergency_hash_rebuild(dev_net(rt->u.dst.dev));
+			}
+			
 		}
 	}
 
@@ -1106,6 +1184,7 @@ restart:
 #endif
 	rt_hash_table[hash].chain = rt;
 	spin_unlock_bh(rt_hash_lock_addr(hash));
+	rt_hash_sd_inc(hash);
 	*rp = rt;
 	return 0;
 }
@@ -1180,6 +1259,7 @@ static void rt_del(unsigned hash, struct rtable *rt)
 		if (aux == rt || rt_is_expired(aux)) {
 			*rthp = aux->u.dst.rt_next;
 			rt_free(aux);
+			rt_hash_sd_dec(hash);
 			continue;
 		}
 		rthp = &aux->u.dst.rt_next;
@@ -2946,6 +3026,24 @@ static void rt_secret_reschedule(int old)
 	rtnl_unlock();
 }
 
+static void rt_secret_rebuild_oneshot(struct net *net) {
+	del_timer_sync(&net->ipv4.rt_secret_timer);
+	rt_cache_invalidate(net);
+	if (ip_rt_secret_interval) {
+		net->ipv4.rt_secret_timer.expires += ip_rt_secret_interval;
+		add_timer(&net->ipv4.rt_secret_timer);
+	}
+}
+
+static void rt_emergency_hash_rebuild(struct net *net) {
+	if (net_ratelimit()) {
+		printk(KERN_WARNING "Route hash chain too long!\n");
+		printk(KERN_WARNING "Adjust your secret_interval!\n");
+	}
+
+	rt_secret_rebuild_oneshot(net);
+}
+
 static int ipv4_sysctl_rt_secret_interval(ctl_table *ctl, int write,
 					  struct file *filp,
 					  void __user *buffer, size_t *lenp,
-- 
/****************************************************
 * Neil Horman <nhorman@tuxdriver.com>
 * Software Engineer, Red Hat
 ****************************************************/
