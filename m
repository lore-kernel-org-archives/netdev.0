From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: 2.6.29.1: unregister_netdevice problem
Date: Fri, 15 May 2009 08:06:49 +0000
Message-ID: <20090515080649.GA5469@ff.dom.local>
References: <20090427054103.GA27529@night.netis.ru> <20090428125755.GA5242@night.netis.ru> <49F76BF6.4040709@gmail.com> <20090429054510.GA8267@night.netis.ru> <20090429090809.GA2995@ami.dom.local> <20090508062640.GA4555@night.netis.ru> <20090508104628.GA6287@ff.dom.local> <20090510073559.GA8929@night.netis.ru> <20090510124641.GA2978@ami.dom.local> <20090515071946.GA15669@night.netis.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Alexander V. Lukyanov" <lav@netis.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:5029 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754474AbZEOIG6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2009 04:06:58 -0400
Content-Disposition: inline
In-Reply-To: <20090515071946.GA15669@night.netis.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 15, 2009 at 11:19:46AM +0400, Alexander V. Lukyanov wrote:
...
> Looks like 2.6.28.10 does not have this refcnt problem. Also, after I have
> reversed net/ipv4/route.c changes from 2.6.29, the problem does not occur either.

Very nice work! It should be a piece of cake now - there were not much
changes. I'll look at it, as usual ;-), but, of course if it's
possible, it would be great to try "in the meantime" with reverted the
biggest of them append below.

Thanks,
Jarek P.
---

commit 1080d709fb9d8cd4392f93476ee46a9d6ea05a5b
Author: Neil Horman <nhorman@tuxdriver.com>
Date:   Mon Oct 27 12:28:25 2008 -0700

    net: implement emergency route cache rebulds when gc_elasticity is exceeded
    
    This is a patch to provide on demand route cache rebuilding.  Currently, our
    route cache is rebulid periodically regardless of need.  This introduced
    unneeded periodic latency.  This patch offers a better approach.  Using code
    provided by Eric Dumazet, we compute the standard deviation of the average hash
    bucket chain length while running rt_check_expire.  Should any given chain
    length grow to larger that average plus 4 standard deviations, we trigger an
    emergency hash table rebuild for that net namespace.  This allows for the common
    case in which chains are well behaved and do not grow unevenly to not incur any
    latency at all, while those systems (which may be being maliciously attacked),
    only rebuild when the attack is detected.  This patch take 2 other factors into
    account:
    1) chains with multiple entries that differ by attributes that do not affect the
    hash value are only counted once, so as not to unduly bias system to rebuilding
    if features like QOS are heavily used
    2) if rebuilding crosses a certain threshold (which is adjustable via the added
    sysctl in this patch), route caching is disabled entirely for that net
    namespace, since constant rebuilding is less efficient that no caching at all
    
    Tested successfully by me.
    
    Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
    Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index d849326..c771278 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -27,6 +27,12 @@ min_adv_mss - INTEGER
 	The advertised MSS depends on the first hop route MTU, but will
 	never be lower than this setting.
 
+rt_cache_rebuild_count - INTEGER
+	The per net-namespace route cache emergency rebuild threshold.
+	Any net-namespace having its route cache rebuilt due to
+	a hash bucket chain being too long more than this many times
+	will have its route caching disabled
+
 IP Fragmentation:
 
 ipfrag_high_thresh - INTEGER
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index ece1c92..977f482 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -49,6 +49,8 @@ struct netns_ipv4 {
 	int sysctl_icmp_ratelimit;
 	int sysctl_icmp_ratemask;
 	int sysctl_icmp_errors_use_inbound_ifaddr;
+	int sysctl_rt_cache_rebuild_count;
+	int current_rt_cache_rebuild_count;
 
 	struct timer_list rt_secret_timer;
 	atomic_t rt_genid;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 2ea6dcc..21ce7e1 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -129,6 +129,7 @@ static int ip_rt_mtu_expires __read_mostly	= 10 * 60 * HZ;
 static int ip_rt_min_pmtu __read_mostly		= 512 + 20 + 20;
 static int ip_rt_min_advmss __read_mostly	= 256;
 static int ip_rt_secret_interval __read_mostly	= 10 * 60 * HZ;
+static int rt_chain_length_max __read_mostly	= 20;
 
 static void rt_worker_func(struct work_struct *work);
 static DECLARE_DELAYED_WORK(expires_work, rt_worker_func);
@@ -145,6 +146,7 @@ static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst);
 static void		 ipv4_link_failure(struct sk_buff *skb);
 static void		 ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu);
 static int rt_garbage_collect(struct dst_ops *ops);
+static void rt_emergency_hash_rebuild(struct net *net);
 
 
 static struct dst_ops ipv4_dst_ops = {
@@ -201,6 +203,7 @@ const __u8 ip_tos2prio[16] = {
 struct rt_hash_bucket {
 	struct rtable	*chain;
 };
+
 #if defined(CONFIG_SMP) || defined(CONFIG_DEBUG_SPINLOCK) || \
 	defined(CONFIG_PROVE_LOCKING)
 /*
@@ -674,6 +677,20 @@ static inline u32 rt_score(struct rtable *rt)
 	return score;
 }
 
+static inline bool rt_caching(const struct net *net)
+{
+	return net->ipv4.current_rt_cache_rebuild_count <=
+		net->ipv4.sysctl_rt_cache_rebuild_count;
+}
+
+static inline bool compare_hash_inputs(const struct flowi *fl1,
+					const struct flowi *fl2)
+{
+	return (__force u32)(((fl1->nl_u.ip4_u.daddr ^ fl2->nl_u.ip4_u.daddr) |
+		(fl1->nl_u.ip4_u.saddr ^ fl2->nl_u.ip4_u.saddr) |
+		(fl1->iif ^ fl2->iif)) == 0);
+}
+
 static inline int compare_keys(struct flowi *fl1, struct flowi *fl2)
 {
 	return ((__force u32)((fl1->nl_u.ip4_u.daddr ^ fl2->nl_u.ip4_u.daddr) |
@@ -753,11 +770,24 @@ static void rt_do_flush(int process_context)
 	}
 }
 
+/*
+ * While freeing expired entries, we compute average chain length
+ * and standard deviation, using fixed-point arithmetic.
+ * This to have an estimation of rt_chain_length_max
+ *  rt_chain_length_max = max(elasticity, AVG + 4*SD)
+ * We use 3 bits for frational part, and 29 (or 61) for magnitude.
+ */
+
+#define FRACT_BITS 3
+#define ONE (1UL << FRACT_BITS)
+
 static void rt_check_expire(void)
 {
 	static unsigned int rover;
 	unsigned int i = rover, goal;
 	struct rtable *rth, **rthp;
+	unsigned long length = 0, samples = 0;
+	unsigned long sum = 0, sum2 = 0;
 	u64 mult;
 
 	mult = ((u64)ip_rt_gc_interval) << rt_hash_log;
@@ -766,6 +796,7 @@ static void rt_check_expire(void)
 	goal = (unsigned int)mult;
 	if (goal > rt_hash_mask)
 		goal = rt_hash_mask + 1;
+	length = 0;
 	for (; goal > 0; goal--) {
 		unsigned long tmo = ip_rt_gc_timeout;
 
@@ -775,6 +806,8 @@ static void rt_check_expire(void)
 		if (need_resched())
 			cond_resched();
 
+		samples++;
+
 		if (*rthp == NULL)
 			continue;
 		spin_lock_bh(rt_hash_lock_addr(i));
@@ -789,11 +822,29 @@ static void rt_check_expire(void)
 				if (time_before_eq(jiffies, rth->u.dst.expires)) {
 					tmo >>= 1;
 					rthp = &rth->u.dst.rt_next;
+					/*
+					 * Only bump our length if the hash
+					 * inputs on entries n and n+1 are not
+					 * the same, we only count entries on
+					 * a chain with equal hash inputs once
+					 * so that entries for different QOS
+					 * levels, and other non-hash input
+					 * attributes don't unfairly skew
+					 * the length computation
+					 */
+					if ((*rthp == NULL) ||
+					    !compare_hash_inputs(&(*rthp)->fl,
+								 &rth->fl))
+						length += ONE;
 					continue;
 				}
 			} else if (!rt_may_expire(rth, tmo, ip_rt_gc_timeout)) {
 				tmo >>= 1;
 				rthp = &rth->u.dst.rt_next;
+				if ((*rthp == NULL) ||
+				    !compare_hash_inputs(&(*rthp)->fl,
+							 &rth->fl))
+					length += ONE;
 				continue;
 			}
 
@@ -802,6 +853,15 @@ static void rt_check_expire(void)
 			rt_free(rth);
 		}
 		spin_unlock_bh(rt_hash_lock_addr(i));
+		sum += length;
+		sum2 += length*length;
+	}
+	if (samples) {
+		unsigned long avg = sum / samples;
+		unsigned long sd = int_sqrt(sum2 / samples - avg*avg);
+		rt_chain_length_max = max_t(unsigned long,
+					ip_rt_gc_elasticity,
+					(avg + 4*sd) >> FRACT_BITS);
 	}
 	rover = i;
 }
@@ -851,6 +911,26 @@ static void rt_secret_rebuild(unsigned long __net)
 	mod_timer(&net->ipv4.rt_secret_timer, jiffies + ip_rt_secret_interval);
 }
 
+static void rt_secret_rebuild_oneshot(struct net *net)
+{
+	del_timer_sync(&net->ipv4.rt_secret_timer);
+	rt_cache_invalidate(net);
+	if (ip_rt_secret_interval) {
+		net->ipv4.rt_secret_timer.expires += ip_rt_secret_interval;
+		add_timer(&net->ipv4.rt_secret_timer);
+	}
+}
+
+static void rt_emergency_hash_rebuild(struct net *net)
+{
+	if (net_ratelimit()) {
+		printk(KERN_WARNING "Route hash chain too long!\n");
+		printk(KERN_WARNING "Adjust your secret_interval!\n");
+	}
+
+	rt_secret_rebuild_oneshot(net);
+}
+
 /*
    Short description of GC goals.
 
@@ -989,6 +1069,7 @@ out:	return 0;
 static int rt_intern_hash(unsigned hash, struct rtable *rt, struct rtable **rp)
 {
 	struct rtable	*rth, **rthp;
+	struct rtable	*rthi;
 	unsigned long	now;
 	struct rtable *cand, **candp;
 	u32 		min_score;
@@ -1002,7 +1083,13 @@ restart:
 	candp = NULL;
 	now = jiffies;
 
+	if (!rt_caching(dev_net(rt->u.dst.dev))) {
+		rt_drop(rt);
+		return 0;
+	}
+
 	rthp = &rt_hash_table[hash].chain;
+	rthi = NULL;
 
 	spin_lock_bh(rt_hash_lock_addr(hash));
 	while ((rth = *rthp) != NULL) {
@@ -1048,6 +1135,17 @@ restart:
 		chain_length++;
 
 		rthp = &rth->u.dst.rt_next;
+
+		/*
+		 * check to see if the next entry in the chain
+		 * contains the same hash input values as rt.  If it does
+		 * This is where we will insert into the list, instead of
+		 * at the head.  This groups entries that differ by aspects not
+		 * relvant to the hash function together, which we use to adjust
+		 * our chain length
+		 */
+		if (*rthp && compare_hash_inputs(&(*rthp)->fl, &rt->fl))
+			rthi = rth;
 	}
 
 	if (cand) {
@@ -1061,6 +1159,16 @@ restart:
 			*candp = cand->u.dst.rt_next;
 			rt_free(cand);
 		}
+	} else {
+		if (chain_length > rt_chain_length_max) {
+			struct net *net = dev_net(rt->u.dst.dev);
+			int num = ++net->ipv4.current_rt_cache_rebuild_count;
+			if (!rt_caching(dev_net(rt->u.dst.dev))) {
+				printk(KERN_WARNING "%s: %d rebuilds is over limit, route caching disabled\n",
+					rt->u.dst.dev->name, num);
+			}
+			rt_emergency_hash_rebuild(dev_net(rt->u.dst.dev));
+		}
 	}
 
 	/* Try to bind route to arp only if it is output
@@ -1098,7 +1206,11 @@ restart:
 		}
 	}
 
-	rt->u.dst.rt_next = rt_hash_table[hash].chain;
+	if (rthi)
+		rt->u.dst.rt_next = rthi->u.dst.rt_next;
+	else
+		rt->u.dst.rt_next = rt_hash_table[hash].chain;
+
 #if RT_CACHE_DEBUG >= 2
 	if (rt->u.dst.rt_next) {
 		struct rtable *trt;
@@ -1114,7 +1226,11 @@ restart:
 	 * previous writes to rt are comitted to memory
 	 * before making rt visible to other CPUS.
 	 */
-	rcu_assign_pointer(rt_hash_table[hash].chain, rt);
+	if (rthi)
+		rcu_assign_pointer(rthi->u.dst.rt_next, rt);
+	else
+		rcu_assign_pointer(rt_hash_table[hash].chain, rt);
+
 	spin_unlock_bh(rt_hash_lock_addr(hash));
 	*rp = rt;
 	return 0;
@@ -1217,6 +1333,9 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 	    || ipv4_is_zeronet(new_gw))
 		goto reject_redirect;
 
+	if (!rt_caching(net))
+		goto reject_redirect;
+
 	if (!IN_DEV_SHARED_MEDIA(in_dev)) {
 		if (!inet_addr_onlink(in_dev, new_gw, old_gw))
 			goto reject_redirect;
@@ -2130,6 +2249,10 @@ int ip_route_input(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	struct net *net;
 
 	net = dev_net(dev);
+
+	if (!rt_caching(net))
+		goto skip_cache;
+
 	tos &= IPTOS_RT_MASK;
 	hash = rt_hash(daddr, saddr, iif, rt_genid(net));
 
@@ -2154,6 +2277,7 @@ int ip_route_input(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	}
 	rcu_read_unlock();
 
+skip_cache:
 	/* Multicast recognition logic is moved from route cache to here.
 	   The problem was that too many Ethernet cards have broken/missing
 	   hardware multicast filters :-( As result the host on multicasting
@@ -2539,6 +2663,9 @@ int __ip_route_output_key(struct net *net, struct rtable **rp,
 	unsigned hash;
 	struct rtable *rth;
 
+	if (!rt_caching(net))
+		goto slow_output;
+
 	hash = rt_hash(flp->fl4_dst, flp->fl4_src, flp->oif, rt_genid(net));
 
 	rcu_read_lock_bh();
@@ -2563,6 +2690,7 @@ int __ip_route_output_key(struct net *net, struct rtable **rp,
 	}
 	rcu_read_unlock_bh();
 
+slow_output:
 	return ip_route_output_slow(net, rp, flp);
 }
 
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 1bb10df..0cc8d31 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -795,6 +795,14 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec
 	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "rt_cache_rebuild_count",
+		.data		= &init_net.ipv4.sysctl_rt_cache_rebuild_count,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec
+	},
 	{ }
 };
 
@@ -827,8 +835,12 @@ static __net_init int ipv4_sysctl_init_net(struct net *net)
 			&net->ipv4.sysctl_icmp_ratelimit;
 		table[5].data =
 			&net->ipv4.sysctl_icmp_ratemask;
+		table[6].data =
+			&net->ipv4.sysctl_rt_cache_rebuild_count;
 	}
 
+	net->ipv4.sysctl_rt_cache_rebuild_count = 4;
+
 	net->ipv4.ipv4_hdr = register_net_sysctl_table(net,
 			net_ipv4_ctl_path, table);
 	if (net->ipv4.ipv4_hdr == NULL)
