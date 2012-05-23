From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: fix the rcu race between free_fib_info and
 ip_route_output_slow
Date: Wed, 23 May 2012 08:37:18 +0200
Message-ID: <1337755038.3361.1878.camel@edumazet-glaptop>
References: <4FBB6105.2060808@intel.com>
	 <20120522.151554.106838106733194160.davem@davemloft.net>
	 <1337742123.14538.175.camel@ymzhang.sh.intel.com>
	 <20120522.232310.911242148705021745.davem@davemloft.net>
	 <1337747829.3361.1599.camel@edumazet-glaptop>
	 <1337748897.14538.184.camel@ymzhang.sh.intel.com>
	 <1337749339.3361.1655.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kunx.jiang@intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Yanmin Zhang <yanmin_zhang@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1337749339.3361.1655.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <edumazet@google.com>

I am testing following patch, could you test it too ?

Thanks

[PATCH] ipv4: nh_dev should be rcu protected

Yanmin Zhang reported an OOPS and provided a patch.

<3>[23898.789643] BUG: sleeping function called from invalid context at
/data/buildbot/workdir/ics/hardware/intel/linux-2.6/arch/x86/mm/fault.c:1103
<3>[23898.862215] in_atomic(): 0, irqs_disabled(): 0, pid: 10526, name:
Thread-6683
<4>[23898.967805] HSU serial 0000:00:05.1: 0000:00:05.2:HSU serial
prevented me
to suspend...
<4>[23899.258526] Pid: 10526, comm: Thread-6683 Tainted: G        W
3.0.8-137685-ge7742f9 #1
<4>[23899.357404] HSU serial 0000:00:05.1: 0000:00:05.2:HSU serial
prevented me
to suspend...
<4>[23899.904225] Call Trace:
<4>[23899.989209]  [<c1227f50>] ? pgtable_bad+0x130/0x130
<4>[23900.000416]  [<c1238c2a>] __might_sleep+0x10a/0x110
<4>[23900.007357]  [<c1228021>] do_page_fault+0xd1/0x3c0
<4>[23900.013764]  [<c18e9ba9>] ? restore_all+0xf/0xf
<4>[23900.024024]  [<c17c007b>] ? napi_complete+0x8b/0x690
<4>[23900.029297]  [<c1227f50>] ? pgtable_bad+0x130/0x130
<4>[23900.123739]  [<c1227f50>] ? pgtable_bad+0x130/0x130
<4>[23900.128955]  [<c18ea0c3>] error_code+0x5f/0x64
<4>[23900.133466]  [<c1227f50>] ? pgtable_bad+0x130/0x130
<4>[23900.138450]  [<c17f6298>] ? __ip_route_output_key+0x698/0x7c0
<4>[23900.144312]  [<c17f5f8d>] ? __ip_route_output_key+0x38d/0x7c0
<4>[23900.150730]  [<c17f63df>] ip_route_output_flow+0x1f/0x60
<4>[23900.156261]  [<c181de58>] ip4_datagram_connect+0x188/0x2b0
<4>[23900.161960]  [<c18e981f>] ? _raw_spin_unlock_bh+0x1f/0x30
<4>[23900.167834]  [<c18298d6>] inet_dgram_connect+0x36/0x80
<4>[23900.173224]  [<c14f9e88>] ? _copy_from_user+0x48/0x140
<4>[23900.178817]  [<c17ab9da>] sys_connect+0x9a/0xd0
<4>[23900.183538]  [<c132e93c>] ? alloc_file+0xdc/0x240
<4>[23900.189111]  [<c123925d>] ? sub_preempt_count+0x3d/0x50

But real fix is to provide appropriate RCU protection to nh_dev/fib_dev,
with appropriate __rcu annotation.

tested with CONFIG_PROVE_RCU and CONFIG_SPARSE_RCU_POINTER

Reported-by: Yanmin Zhang <yanmin_zhang@linux.intel.com>
Reported-by: Kun Jiang <kunx.jiang@intel.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/inetdevice.h        |    8 ++-
 include/net/ip_fib.h              |    2 
 net/ipv4/devinet.c                |   11 ++--
 net/ipv4/fib_frontend.c           |    6 +-
 net/ipv4/fib_semantics.c          |   66 ++++++++++++++++++----------
 net/ipv4/fib_trie.c               |   11 ++--
 net/ipv4/netfilter/ipt_rpfilter.c |    4 -
 net/ipv4/route.c                  |    4 -
 8 files changed, 71 insertions(+), 41 deletions(-)

diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index 597f4a9..8cfa569 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -172,7 +172,13 @@ extern int		inet_addr_onlink(struct in_device *in_dev, __be32 a, __be32 b);
 extern int		devinet_ioctl(struct net *net, unsigned int cmd, void __user *);
 extern void		devinet_init(void);
 extern struct in_device	*inetdev_by_index(struct net *, int);
-extern __be32		inet_select_addr(const struct net_device *dev, __be32 dst, int scope);
+
+extern __be32	__inet_select_addr(struct net *net,
+				   const struct net_device *dev,
+				   __be32 dst, int scope);
+#define inet_select_addr(dev, dst, scope) \
+	__inet_select_addr(dev_net(dev), (dev), (dst), (scope))
+
 extern __be32		inet_confirm_addr(struct in_device *in_dev, __be32 dst, __be32 local, int scope);
 extern struct in_ifaddr *inet_ifa_byprefix(struct in_device *in_dev, __be32 prefix, __be32 mask);
 
diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 78df0866..9d49426 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -46,7 +46,7 @@ struct fib_config {
 struct fib_info;
 
 struct fib_nh {
-	struct net_device	*nh_dev;
+	struct net_device __rcu	*nh_dev;
 	struct hlist_node	nh_hash;
 	struct fib_info		*nh_parent;
 	unsigned int		nh_flags;
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 10e15a1..be1e75c 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -164,7 +164,7 @@ struct net_device *__ip_dev_find(struct net *net, __be32 addr, bool devref)
 		if (local &&
 		    !fib_table_lookup(local, &fl4, &res, FIB_LOOKUP_NOREF) &&
 		    res.type == RTN_LOCAL)
-			result = FIB_RES_DEV(res);
+			result = rcu_dereference(FIB_RES_DEV(res));
 	}
 	if (result && devref)
 		dev_hold(result);
@@ -960,14 +960,15 @@ out:
 	return done;
 }
 
-__be32 inet_select_addr(const struct net_device *dev, __be32 dst, int scope)
+__be32 __inet_select_addr(struct net *net,
+			  const struct net_device *dev,
+			  __be32 dst, int scope)
 {
 	__be32 addr = 0;
 	struct in_device *in_dev;
-	struct net *net = dev_net(dev);
 
 	rcu_read_lock();
-	in_dev = __in_dev_get_rcu(dev);
+	in_dev = dev ? __in_dev_get_rcu(dev) : NULL;
 	if (!in_dev)
 		goto no_in_dev;
 
@@ -1007,7 +1008,7 @@ out_unlock:
 	rcu_read_unlock();
 	return addr;
 }
-EXPORT_SYMBOL(inet_select_addr);
+EXPORT_SYMBOL(__inet_select_addr);
 
 static __be32 confirm_addr_indev(struct in_device *in_dev, __be32 dst,
 			      __be32 local, int scope)
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 3854411..2479884 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -159,7 +159,7 @@ static inline unsigned int __inet_dev_addr_type(struct net *net,
 		ret = RTN_UNICAST;
 		rcu_read_lock();
 		if (!fib_table_lookup(local_table, &fl4, &res, FIB_LOOKUP_NOREF)) {
-			if (!dev || dev == res.fi->fib_dev)
+			if (!dev || dev == rcu_dereference(res.fi->fib_dev))
 				ret = res.type;
 		}
 		rcu_read_unlock();
@@ -237,13 +237,13 @@ int fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst, u8 tos,
 	for (ret = 0; ret < res.fi->fib_nhs; ret++) {
 		struct fib_nh *nh = &res.fi->fib_nh[ret];
 
-		if (nh->nh_dev == dev) {
+		if (rcu_dereference(nh->nh_dev) == dev) {
 			dev_match = true;
 			break;
 		}
 	}
 #else
-	if (FIB_RES_DEV(res) == dev)
+	if (rcu_dereference(FIB_RES_DEV(res)) == dev)
 		dev_match = true;
 #endif
 	if (dev_match) {
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index a8bdf74..a09f055 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -157,9 +157,13 @@ void free_fib_info(struct fib_info *fi)
 		return;
 	}
 	change_nexthops(fi) {
-		if (nexthop_nh->nh_dev)
-			dev_put(nexthop_nh->nh_dev);
-		nexthop_nh->nh_dev = NULL;
+		struct net_device *ndev;
+
+		ndev = rtnl_dereference(nexthop_nh->nh_dev);
+		if (ndev) {
+			dev_put(ndev);
+			RCU_INIT_POINTER(nexthop_nh->nh_dev, NULL);
+		}
 	} endfor_nexthops(fi);
 	fib_info_cnt--;
 	release_net(fi->fib_net);
@@ -273,7 +277,7 @@ int ip_fib_check_default(__be32 gw, struct net_device *dev)
 	hash = fib_devindex_hashfn(dev->ifindex);
 	head = &fib_info_devhash[hash];
 	hlist_for_each_entry(nh, node, head, nh_hash) {
-		if (nh->nh_dev == dev &&
+		if (rcu_access_pointer(nh->nh_dev) == dev &&
 		    nh->nh_gw == gw &&
 		    !(nh->nh_flags & RTNH_F_DEAD)) {
 			spin_unlock(&fib_info_lock);
@@ -360,13 +364,17 @@ struct fib_alias *fib_find_alias(struct list_head *fah, u8 tos, u32 prio)
 	return NULL;
 }
 
+/* called in rcu_read_lock() section */
 int fib_detect_death(struct fib_info *fi, int order,
 		     struct fib_info **last_resort, int *last_idx, int dflt)
 {
-	struct neighbour *n;
+	struct neighbour *n = NULL;
 	int state = NUD_NONE;
+	struct net_device *ndev = rcu_dereference(fi->fib_dev);
+
+	if (ndev)
+		n = neigh_lookup(&arp_tbl, &fi->fib_nh[0].nh_gw, ndev);
 
-	n = neigh_lookup(&arp_tbl, &fi->fib_nh[0].nh_gw, fi->fib_dev);
 	if (n) {
 		state = n->nud_state;
 		neigh_release(n);
@@ -551,7 +559,7 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
 				return -ENODEV;
 			if (!(dev->flags & IFF_UP))
 				return -ENETDOWN;
-			nh->nh_dev = dev;
+			rcu_assign_pointer(nh->nh_dev, dev);
 			dev_hold(dev);
 			nh->nh_scope = RT_SCOPE_LINK;
 			return 0;
@@ -578,7 +586,8 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
 			goto out;
 		nh->nh_scope = res.scope;
 		nh->nh_oif = FIB_RES_OIF(res);
-		nh->nh_dev = dev = FIB_RES_DEV(res);
+		dev = rcu_dereference(FIB_RES_DEV(res));
+		rcu_assign_pointer(nh->nh_dev, dev);
 		if (!dev)
 			goto out;
 		dev_hold(dev);
@@ -597,8 +606,8 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
 		err = -ENETDOWN;
 		if (!(in_dev->dev->flags & IFF_UP))
 			goto out;
-		nh->nh_dev = in_dev->dev;
-		dev_hold(nh->nh_dev);
+		rcu_assign_pointer(nh->nh_dev, in_dev->dev);
+		dev_hold(in_dev->dev);
 		nh->nh_scope = RT_SCOPE_HOST;
 		err = 0;
 	}
@@ -695,9 +704,14 @@ static void fib_info_hash_move(struct hlist_head *new_info_hash,
 
 __be32 fib_info_update_nh_saddr(struct net *net, struct fib_nh *nh)
 {
-	nh->nh_saddr = inet_select_addr(nh->nh_dev,
-					nh->nh_gw,
-					nh->nh_parent->fib_scope);
+	struct net_device *ndev;
+
+	rcu_read_lock();
+	ndev = rcu_dereference(nh->nh_dev);
+	nh->nh_saddr = __inet_select_addr(net, ndev,
+					  nh->nh_gw,
+					  nh->nh_parent->fib_scope);
+	rcu_read_unlock();
 	nh->nh_saddr_genid = atomic_read(&net->ipv4.dev_addr_genid);
 
 	return nh->nh_saddr;
@@ -843,7 +857,8 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 		if (nhs != 1 || nh->nh_gw)
 			goto err_inval;
 		nh->nh_scope = RT_SCOPE_NOWHERE;
-		nh->nh_dev = dev_get_by_index(net, fi->fib_nh->nh_oif);
+		RCU_INIT_POINTER(nh->nh_dev,
+				 dev_get_by_index(net, fi->fib_nh->nh_oif));
 		err = -ENODEV;
 		if (nh->nh_dev == NULL)
 			goto failure;
@@ -889,10 +904,11 @@ link_it:
 	change_nexthops(fi) {
 		struct hlist_head *head;
 		unsigned int hash;
+		struct net_device *ndev = rtnl_dereference(nexthop_nh->nh_dev);
 
-		if (!nexthop_nh->nh_dev)
+		if (!ndev)
 			continue;
-		hash = fib_devindex_hashfn(nexthop_nh->nh_dev->ifindex);
+		hash = fib_devindex_hashfn(ndev->ifindex);
 		head = &fib_info_devhash[hash];
 		hlist_add_head(&nexthop_nh->nh_hash, head);
 	} endfor_nexthops(fi)
@@ -1049,14 +1065,14 @@ int fib_sync_down_dev(struct net_device *dev, int force)
 		int dead;
 
 		BUG_ON(!fi->fib_nhs);
-		if (nh->nh_dev != dev || fi == prev_fi)
+		if (rtnl_dereference(nh->nh_dev) != dev || fi == prev_fi)
 			continue;
 		prev_fi = fi;
 		dead = 0;
 		change_nexthops(fi) {
 			if (nexthop_nh->nh_flags & RTNH_F_DEAD)
 				dead++;
-			else if (nexthop_nh->nh_dev == dev &&
+			else if (rtnl_dereference(nexthop_nh->nh_dev) == dev &&
 				 nexthop_nh->nh_scope != scope) {
 				nexthop_nh->nh_flags |= RTNH_F_DEAD;
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
@@ -1068,7 +1084,8 @@ int fib_sync_down_dev(struct net_device *dev, int force)
 				dead++;
 			}
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
-			if (force > 1 && nexthop_nh->nh_dev == dev) {
+			if (force > 1 &&
+			    rtnl_dereference(nexthop_nh->nh_dev) == dev) {
 				dead = fi->fib_nhs;
 				break;
 			}
@@ -1167,20 +1184,23 @@ int fib_sync_up(struct net_device *dev)
 		int alive;
 
 		BUG_ON(!fi->fib_nhs);
-		if (nh->nh_dev != dev || fi == prev_fi)
+		if (rtnl_dereference(nh->nh_dev) != dev || fi == prev_fi)
 			continue;
 
 		prev_fi = fi;
 		alive = 0;
 		change_nexthops(fi) {
+			struct net_device *ndev;
+
 			if (!(nexthop_nh->nh_flags & RTNH_F_DEAD)) {
 				alive++;
 				continue;
 			}
-			if (nexthop_nh->nh_dev == NULL ||
-			    !(nexthop_nh->nh_dev->flags & IFF_UP))
+			ndev = rtnl_dereference(nexthop_nh->nh_dev);
+			if (ndev == NULL ||
+			    !(ndev->flags & IFF_UP))
 				continue;
-			if (nexthop_nh->nh_dev != dev ||
+			if (ndev != dev ||
 			    !__in_dev_get_rtnl(dev))
 				continue;
 			alive++;
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 30b88d7..3861ba0 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -2556,11 +2556,14 @@ static int fib_route_seq_show(struct seq_file *seq, void *v)
 			    || fa->fa_type == RTN_MULTICAST)
 				continue;
 
-			if (fi)
+			if (fi) {
+				struct net_device *ndev;
+
+				ndev = rcu_dereference(fi->fib_dev);
 				seq_printf(seq,
 					 "%s\t%08X\t%08X\t%04X\t%d\t%u\t"
 					 "%d\t%08X\t%d\t%u\t%u%n",
-					 fi->fib_dev ? fi->fib_dev->name : "*",
+					 ndev ? ndev->name : "*",
 					 prefix,
 					 fi->fib_nh->nh_gw, flags, 0, 0,
 					 fi->fib_priority,
@@ -2569,13 +2572,13 @@ static int fib_route_seq_show(struct seq_file *seq, void *v)
 					  fi->fib_advmss + 40 : 0),
 					 fi->fib_window,
 					 fi->fib_rtt >> 3, &len);
-			else
+			} else {
 				seq_printf(seq,
 					 "*\t%08X\t%08X\t%04X\t%d\t%u\t"
 					 "%d\t%08X\t%d\t%u\t%u%n",
 					 prefix, 0, flags, 0, 0, 0,
 					 mask, 0, 0, 0, &len);
-
+			}
 			seq_printf(seq, "%*s\n", 127 - len, "");
 		}
 	}
diff --git a/net/ipv4/netfilter/ipt_rpfilter.c b/net/ipv4/netfilter/ipt_rpfilter.c
index 31371be..bdc9393 100644
--- a/net/ipv4/netfilter/ipt_rpfilter.c
+++ b/net/ipv4/netfilter/ipt_rpfilter.c
@@ -52,13 +52,13 @@ static bool rpfilter_lookup_reverse(struct flowi4 *fl4,
 	for (ret = 0; ret < res.fi->fib_nhs; ret++) {
 		struct fib_nh *nh = &res.fi->fib_nh[ret];
 
-		if (nh->nh_dev == dev) {
+		if (rcu_dereference(nh->nh_dev) == dev) {
 			dev_match = true;
 			break;
 		}
 	}
 #else
-	if (FIB_RES_DEV(res) == dev)
+	if (rcu_dereference(FIB_RES_DEV(res)) == dev)
 		dev_match = true;
 #endif
 	if (dev_match || flags & XT_RPFILTER_LOOSE)
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index ffcb3b0..b56b91e 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2127,7 +2127,7 @@ static int __mkroute_input(struct sk_buff *skb,
 	u32 itag;
 
 	/* get a working reference to the output device */
-	out_dev = __in_dev_get_rcu(FIB_RES_DEV(*res));
+	out_dev = __in_dev_get_rcu(rcu_dereference(FIB_RES_DEV(*res)));
 	if (out_dev == NULL) {
 		net_crit_ratelimited("Bug in ip_route_input_slow(). Please report.\n");
 		return -EINVAL;
@@ -2786,7 +2786,7 @@ static struct rtable *ip_route_output_slow(struct net *net, struct flowi4 *fl4)
 	if (!fl4->saddr)
 		fl4->saddr = FIB_RES_PREFSRC(net, res);
 
-	dev_out = FIB_RES_DEV(res);
+	dev_out = rcu_dereference(FIB_RES_DEV(res));
 	fl4->flowi4_oif = dev_out->ifindex;
 
 
