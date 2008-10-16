From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when
	gc_elasticity is exceeded
Date: Thu, 16 Oct 2008 07:41:55 -0400
Message-ID: <20081016114155.GA15877@hmsreliant.think-freely.org>
References: <20081006225210.GA29794@hmsreliant.think-freely.org> <48EAEFF9.1000606@cosmosbay.com> <20081013182655.GA9505@hmsreliant.think-freely.org> <20081015.235556.61915120.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dada1@cosmosbay.com, billfink@mindspring.com,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	johnpol@2ka.mipt.ru
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37504 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752828AbYJPLoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2008 07:44:11 -0400
Content-Disposition: inline
In-Reply-To: <20081015.235556.61915120.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 15, 2008 at 11:55:56PM -0700, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Mon, 13 Oct 2008 14:26:55 -0400
> 
> > If this meets everyones approval I think we can follow up with a
> > patch to remove the secret interval code entirely.
> 
> This patch looks pretty good to me.
> 
> Just some minor coding style nits:
> 
> > +static void rt_secret_rebuild_oneshot(struct net *net) {
> 
> Openning brace on new line please.
> 
> > +static void rt_emergency_hash_rebuild(struct net *net) {
> 
> Likewise.
> 

Thanks Dave, new patch, with those nits fixed up.  I also cleaned up a few
checkpatch errors (all trailing whitespace and 80 col errors)

Best
Neil

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 include/linux/sysctl.h     |    1 
 include/net/netns/ipv4.h   |    2 
 kernel/sysctl_check.c      |    1 
 net/ipv4/route.c           |  117 ++++++++++++++++++++++++++++++++++++++++++++-
 net/ipv4/sysctl_net_ipv4.c |   12 ++++
 5 files changed, 131 insertions(+), 2 deletions(-)


diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index d0437f3..481aa44 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -435,6 +435,7 @@ enum
 	NET_TCP_ALLOWED_CONG_CONTROL=123,
 	NET_TCP_MAX_SSTHRESH=124,
 	NET_TCP_FRTO_RESPONSE=125,
+	NET_IPV4_RT_CACHE_REBUILD_COUNT=126,
 };
 
 enum {
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index a6ed838..4fef762 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -46,6 +46,8 @@ struct netns_ipv4 {
 	int sysctl_icmp_ratelimit;
 	int sysctl_icmp_ratemask;
 	int sysctl_icmp_errors_use_inbound_ifaddr;
+	int sysctl_rt_cache_rebuild_count;
+	int current_rt_cache_rebuild_count;
 
 	struct timer_list rt_secret_timer;
 	atomic_t rt_genid;
diff --git a/kernel/sysctl_check.c b/kernel/sysctl_check.c
index c35da23..eb9fb57 100644
--- a/kernel/sysctl_check.c
+++ b/kernel/sysctl_check.c
@@ -389,6 +389,7 @@ static const struct trans_ctl_table trans_net_ipv4_table[] = {
 	{ NET_TCP_ALLOWED_CONG_CONTROL,		"tcp_allowed_congestion_control" },
 	{ NET_TCP_MAX_SSTHRESH,			"tcp_max_ssthresh" },
 	{ NET_TCP_FRTO_RESPONSE,		"tcp_frto_response" },
+	{ NET_IPV4_RT_CACHE_REBUILD_COUNT,	"rt_cache_rebuild_count" },
 	{ 2088 /* NET_IPQ_QMAX */,		"ip_queue_maxlen" },
 	{}
 };
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 6ee5354..623b633 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -129,6 +129,7 @@ static int ip_rt_mtu_expires __read_mostly	= 10 * 60 * HZ;
 static int ip_rt_min_pmtu __read_mostly		= 512 + 20 + 20;
 static int ip_rt_min_advmss __read_mostly	= 256;
 static int ip_rt_secret_interval __read_mostly	= 10 * 60 * HZ;
+static int rt_chain_length_max __read_mostly	= 8;
 
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
@@ -669,6 +672,19 @@ static inline u32 rt_score(struct rtable *rt)
 	return score;
 }
 
+static inline int rt_caching(struct net *net)
+{
+	return net->ipv4.current_rt_cache_rebuild_count <=
+		net->ipv4.sysctl_rt_cache_rebuild_count;
+}
+
+static inline int compare_hash_inputs(struct flowi *fl1, struct flowi *fl2)
+{
+	return (__force u32)(((fl1->nl_u.ip4_u.daddr ^ fl2->nl_u.ip4_u.daddr) |
+		(fl1->nl_u.ip4_u.saddr ^ fl2->nl_u.ip4_u.saddr) |
+		(fl1->iif ^ fl2->iif)) == 0);
+}
+
 static inline int compare_keys(struct flowi *fl1, struct flowi *fl2)
 {
 	return ((__force u32)((fl1->nl_u.ip4_u.daddr ^ fl2->nl_u.ip4_u.daddr) |
@@ -748,11 +764,23 @@ static void rt_do_flush(int process_context)
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
+	unsigned long length;
 	u64 mult;
 
 	mult = ((u64)ip_rt_gc_interval) << rt_hash_log;
@@ -784,11 +812,29 @@ static void rt_check_expire(void)
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
+					if (*rthp &&
+					    !compare_hash_inputs(&(*rthp)->fl,
+								 &rth->fl))
+						length += ONE;
 					continue;
 				}
 			} else if (!rt_may_expire(rth, tmo, ip_rt_gc_timeout)) {
 				tmo >>= 1;
 				rthp = &rth->u.dst.rt_next;
+				if (*rthp &&
+				    !compare_hash_inputs(&(*rthp)->fl,
+							 &rth->fl))
+					length += ONE;
 				continue;
 			}
 
@@ -846,6 +892,26 @@ static void rt_secret_rebuild(unsigned long __net)
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
 
@@ -984,6 +1050,7 @@ out:	return 0;
 static int rt_intern_hash(unsigned hash, struct rtable *rt, struct rtable **rp)
 {
 	struct rtable	*rth, **rthp;
+	struct rtable	*rthi;
 	unsigned long	now;
 	struct rtable *cand, **candp;
 	u32 		min_score;
@@ -997,7 +1064,13 @@ restart:
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
@@ -1043,6 +1116,17 @@ restart:
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
@@ -1056,6 +1140,16 @@ restart:
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
@@ -1093,7 +1187,11 @@ restart:
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
@@ -1104,7 +1202,10 @@ restart:
 		printk("\n");
 	}
 #endif
-	rt_hash_table[hash].chain = rt;
+	if (rthi)
+		rthi->u.dst.rt_next = rt;
+	else
+		rt_hash_table[hash].chain = rt;
 	spin_unlock_bh(rt_hash_lock_addr(hash));
 	*rp = rt;
 	return 0;
@@ -1207,6 +1308,9 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 	    || ipv4_is_zeronet(new_gw))
 		goto reject_redirect;
 
+	if (!rt_caching(net))
+		goto reject_redirect;
+
 	if (!IN_DEV_SHARED_MEDIA(in_dev)) {
 		if (!inet_addr_onlink(in_dev, new_gw, old_gw))
 			goto reject_redirect;
@@ -2120,6 +2224,10 @@ int ip_route_input(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	struct net *net;
 
 	net = dev_net(dev);
+
+	if (!rt_caching(net))
+		goto skip_cache;
+
 	tos &= IPTOS_RT_MASK;
 	hash = rt_hash(daddr, saddr, iif, rt_genid(net));
 
@@ -2144,6 +2252,7 @@ int ip_route_input(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	}
 	rcu_read_unlock();
 
+skip_cache:
 	/* Multicast recognition logic is moved from route cache to here.
 	   The problem was that too many Ethernet cards have broken/missing
 	   hardware multicast filters :-( As result the host on multicasting
@@ -2523,6 +2632,9 @@ int __ip_route_output_key(struct net *net, struct rtable **rp,
 	unsigned hash;
 	struct rtable *rth;
 
+	if (!rt_caching(net))
+		goto slow_output;
+
 	hash = rt_hash(flp->fl4_dst, flp->fl4_src, flp->oif, rt_genid(net));
 
 	rcu_read_lock_bh();
@@ -2547,6 +2659,7 @@ int __ip_route_output_key(struct net *net, struct rtable **rp,
 	}
 	rcu_read_unlock_bh();
 
+slow_output:
 	return ip_route_output_slow(net, rp, flp);
 }
 
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index e0689fd..6d9ab73 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -798,6 +798,14 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec
 	},
+	{
+		.ctl_name	= NET_IPV4_RT_CACHE_REBUILD_COUNT,
+		.procname	= "rt_cache_rebuild_count",
+		.data		= &init_net.ipv4.sysctl_rt_cache_rebuild_count,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec
+	},
 	{ }
 };
 
@@ -830,8 +838,12 @@ static __net_init int ipv4_sysctl_init_net(struct net *net)
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
-- 
/****************************************************
 * Neil Horman <nhorman@tuxdriver.com>
 * Software Engineer, Red Hat
 ****************************************************/
