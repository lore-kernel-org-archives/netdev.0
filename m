From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [Patch net-next] net: make neigh tables per netns
Date: Wed, 25 Jun 2014 17:04:53 -0700
Message-ID: <87d2dwsfh6.fsf@x220.int.ebiederm.org>
References: <1403561370-2876-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	stephen hemminger <stephen@networkplumber.org>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:41304 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754496AbaFZAIT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 20:08:19 -0400
In-Reply-To: <1403561370-2876-1-git-send-email-xiyou.wangcong@gmail.com> (Cong
	Wang's message of "Mon, 23 Jun 2014 15:09:30 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <xiyou.wangcong@gmail.com> writes:

> From: Cong Wang <cwang@twopensource.com>
>
> Different net namespaces have different devices, routes, neighbours,
> so their neigh table should be separated as well.

This justification doesn't work.  Neighbour entries are per network
device which are already per network device.

The only thing I see that you can gain by this work is getting around
global limits on neighbor table size.  Something that I think is most
unwise.

We may want a smarter limits infrastructure as it is possible to DOS one
interface by hitting the global neigh table limit on other interfaces.
That problem really isn't a network namespace problem except that with
network namespaces you typically have more interfaces and can see the
problem more easily.

> This patch makes
> gloable arp_tbl and nd_tbl etc. be per netns.

> Also, as we don't support multiple tables per family, there is no
> point to make tables chained by linked list, they can just be
> statically compiled. This will eliminate the global neigh_tbl_lock.

There might to this lock removal, but mixing the lock removal in with
everything else winds up with extra noise, and code that looks
suspiciously messy.

At the very least neigh_tbl_lock today protects against rmmod decnet
and rmmod ipv6, which while unlikely can oops they kernel if they aren't
handled carefully.  So it definitely feels inappropriate to mush these
all together.

If your goal is to deal with the issue of the limited set of neighbour
limits say so and let's look at that problem.

If your goal is just to kill neigh_tbl_lock please take that to a
separate patch where the pros and cons can be weighed, and people can
focus on the issue.

As it stands this patch does too much, and seems to do nothing except
bypass controls on global kernel memory consumption.

Eric


> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: stephen hemminger <stephen@networkplumber.org>
> Signed-off-by: Cong Wang <cwang@twopensource.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  drivers/net/vxlan.c         |  11 +-
>  include/net/addrconf.h      |   1 -
>  include/net/arp.h           |   5 +-
>  include/net/ndisc.h         |   5 +-
>  include/net/neighbour.h     |  10 +-
>  include/net/net_namespace.h |   4 +
>  include/net/netns/decnet.h  |  10 ++
>  include/net/netns/ipv4.h    |   1 +
>  include/net/netns/ipv6.h    |   1 +
>  net/atm/clip.c              |  12 ++-
>  net/core/neighbour.c        | 258 ++++++++++++++++++++------------------------
>  net/decnet/dn_dev.c         |  14 +--
>  net/decnet/dn_fib.c         |   4 +-
>  net/decnet/dn_neigh.c       | 103 +++++++++++-------
>  net/decnet/dn_route.c       |  12 +--
>  net/ipv4/arp.c              | 148 ++++++++++++++-----------
>  net/ipv4/devinet.c          |   7 +-
>  net/ipv4/fib_semantics.c    |   3 +-
>  net/ipv4/ip_output.c        |   2 +-
>  net/ipv4/route.c            |   2 +-
>  net/ipv6/addrconf.c         |  15 +--
>  net/ipv6/af_inet6.c         |   1 -
>  net/ipv6/ip6_output.c       |   5 +-
>  net/ipv6/ndisc.c            | 149 ++++++++++++-------------
>  net/ipv6/route.c            |   5 +-
>  25 files changed, 430 insertions(+), 358 deletions(-)
>  create mode 100644 include/net/netns/decnet.h
>
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index ade33ef..77012e2 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -1260,6 +1260,7 @@ static int arp_reduce(struct net_device *dev, struct sk_buff *skb)
>  	u8 *arpptr, *sha;
>  	__be32 sip, tip;
>  	struct neighbour *n;
> +	struct net *net = dev_net(dev);
>  
>  	if (dev->flags & IFF_NOARP)
>  		goto out;
> @@ -1289,7 +1290,7 @@ static int arp_reduce(struct net_device *dev, struct sk_buff *skb)
>  	    ipv4_is_multicast(tip))
>  		goto out;
>  
> -	n = neigh_lookup(&arp_tbl, &tip, dev);
> +	n = neigh_lookup(net->ipv4.arp_tbl, &tip, dev);
>  
>  	if (n) {
>  		struct vxlan_fdb *f;
> @@ -1433,6 +1434,7 @@ static int neigh_reduce(struct net_device *dev, struct sk_buff *skb)
>  	const struct in6_addr *saddr, *daddr;
>  	struct neighbour *n;
>  	struct inet6_dev *in6_dev;
> +	struct net *net = dev_net(dev);
>  
>  	in6_dev = __in6_dev_get(dev);
>  	if (!in6_dev)
> @@ -1454,7 +1456,7 @@ static int neigh_reduce(struct net_device *dev, struct sk_buff *skb)
>  	    ipv6_addr_is_multicast(&msg->target))
>  		goto out;
>  
> -	n = neigh_lookup(ipv6_stub->nd_tbl, &msg->target, dev);
> +	n = neigh_lookup(net->ipv6.nd_tbl, &msg->target, dev);
>  
>  	if (n) {
>  		struct vxlan_fdb *f;
> @@ -1501,6 +1503,7 @@ out:
>  static bool route_shortcircuit(struct net_device *dev, struct sk_buff *skb)
>  {
>  	struct vxlan_dev *vxlan = netdev_priv(dev);
> +	struct net *net = dev_net(dev);
>  	struct neighbour *n;
>  
>  	if (is_multicast_ether_addr(eth_hdr(skb)->h_dest))
> @@ -1515,7 +1518,7 @@ static bool route_shortcircuit(struct net_device *dev, struct sk_buff *skb)
>  		if (!pskb_may_pull(skb, sizeof(struct iphdr)))
>  			return false;
>  		pip = ip_hdr(skb);
> -		n = neigh_lookup(&arp_tbl, &pip->daddr, dev);
> +		n = neigh_lookup(net->ipv4.arp_tbl, &pip->daddr, dev);
>  		if (!n && (vxlan->flags & VXLAN_F_L3MISS)) {
>  			union vxlan_addr ipa = {
>  				.sin.sin_addr.s_addr = pip->daddr,
> @@ -1536,7 +1539,7 @@ static bool route_shortcircuit(struct net_device *dev, struct sk_buff *skb)
>  		if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
>  			return false;
>  		pip6 = ipv6_hdr(skb);
> -		n = neigh_lookup(ipv6_stub->nd_tbl, &pip6->daddr, dev);
> +		n = neigh_lookup(net->ipv6.nd_tbl, &pip6->daddr, dev);
>  		if (!n && (vxlan->flags & VXLAN_F_L3MISS)) {
>  			union vxlan_addr ipa = {
>  				.sin6.sin6_addr = pip6->daddr,
> diff --git a/include/net/addrconf.h b/include/net/addrconf.h
> index f679877..e2395e7 100644
> --- a/include/net/addrconf.h
> +++ b/include/net/addrconf.h
> @@ -161,7 +161,6 @@ struct ipv6_stub {
>  			      const struct in6_addr *daddr,
>  			      const struct in6_addr *solicited_addr,
>  			      bool router, bool solicited, bool override, bool inc_opt);
> -	struct neigh_table *nd_tbl;
>  };
>  extern const struct ipv6_stub *ipv6_stub __read_mostly;
>  
> diff --git a/include/net/arp.h b/include/net/arp.h
> index 73c4986..c1e4edb 100644
> --- a/include/net/arp.h
> +++ b/include/net/arp.h
> @@ -7,8 +7,6 @@
>  #include <net/neighbour.h>
>  
>  
> -extern struct neigh_table arp_tbl;
> -
>  static inline u32 arp_hashfn(u32 key, const struct net_device *dev, u32 hash_rnd)
>  {
>  	u32 val = key ^ hash32_ptr(dev);
> @@ -18,7 +16,8 @@ static inline u32 arp_hashfn(u32 key, const struct net_device *dev, u32 hash_rnd
>  
>  static inline struct neighbour *__ipv4_neigh_lookup_noref(struct net_device *dev, u32 key)
>  {
> -	struct neigh_hash_table *nht = rcu_dereference_bh(arp_tbl.nht);
> +	struct net *net = dev_net(dev);
> +	struct neigh_hash_table *nht = rcu_dereference_bh(net->ipv4.arp_tbl->nht);
>  	struct neighbour *n;
>  	u32 hash_val;
>  
> diff --git a/include/net/ndisc.h b/include/net/ndisc.h
> index 6bbda34..51cc1e5 100644
> --- a/include/net/ndisc.h
> +++ b/include/net/ndisc.h
> @@ -59,8 +59,6 @@ struct net_device;
>  struct net_proto_family;
>  struct sk_buff;
>  
> -extern struct neigh_table nd_tbl;
> -
>  struct nd_msg {
>          struct icmp6hdr	icmph;
>          struct in6_addr	target;
> @@ -157,11 +155,12 @@ static inline u32 ndisc_hashfn(const void *pkey, const struct net_device *dev, _
>  static inline struct neighbour *__ipv6_neigh_lookup_noref(struct net_device *dev, const void *pkey)
>  {
>  	struct neigh_hash_table *nht;
> +	struct net *net = dev_net(dev);
>  	const u32 *p32 = pkey;
>  	struct neighbour *n;
>  	u32 hash_val;
>  
> -	nht = rcu_dereference_bh(nd_tbl.nht);
> +	nht = rcu_dereference_bh(net->ipv6.nd_tbl->nht);
>  	hash_val = ndisc_hashfn(pkey, dev, nht->hash_rnd) >> (32 - nht->hash_shift);
>  	for (n = rcu_dereference_bh(nht->hash_buckets[hash_val]);
>  	     n != NULL;
> diff --git a/include/net/neighbour.h b/include/net/neighbour.h
> index 7277caf..38d89bf 100644
> --- a/include/net/neighbour.h
> +++ b/include/net/neighbour.h
> @@ -27,6 +27,7 @@
>  #include <linux/sysctl.h>
>  #include <linux/workqueue.h>
>  #include <net/rtnetlink.h>
> +#include <net/net_namespace.h>
>  
>  /*
>   * NUD stands for "neighbor unreachability detection"
> @@ -220,6 +221,13 @@ struct neigh_table {
>  	struct pneigh_entry	**phash_buckets;
>  };
>  
> +enum {
> +	NEIGH_ARP_TABLE = 0,
> +	NEIGH_ND_TABLE = 1,
> +	NEIGH_DN_TABLE = 2,
> +	NEIGH_NR_TABLES,
> +};
> +
>  static inline int neigh_parms_family(struct neigh_parms *p)
>  {
>  	return p->tbl->family;
> @@ -240,7 +248,7 @@ static inline void *neighbour_priv(const struct neighbour *n)
>  #define NEIGH_UPDATE_F_ISROUTER			0x40000000
>  #define NEIGH_UPDATE_F_ADMIN			0x80000000
>  
> -void neigh_table_init(struct neigh_table *tbl);
> +void neigh_table_init(struct net *net, struct neigh_table *tbl);
>  int neigh_table_clear(struct neigh_table *tbl);
>  struct neighbour *neigh_lookup(struct neigh_table *tbl, const void *pkey,
>  			       struct net_device *dev);
> diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
> index 361d260..4d76bf3 100644
> --- a/include/net/net_namespace.h
> +++ b/include/net/net_namespace.h
> @@ -19,6 +19,7 @@
>  #include <net/netns/ieee802154_6lowpan.h>
>  #include <net/netns/sctp.h>
>  #include <net/netns/dccp.h>
> +#include <net/netns/decnet.h>
>  #include <net/netns/netfilter.h>
>  #include <net/netns/x_tables.h>
>  #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
> @@ -101,6 +102,9 @@ struct net {
>  #if defined(CONFIG_IP_DCCP) || defined(CONFIG_IP_DCCP_MODULE)
>  	struct netns_dccp	dccp;
>  #endif
> +#if IS_ENABLED(CONFIG_DECNET)
> +	struct netns_decnet	decnet;
> +#endif
>  #ifdef CONFIG_NETFILTER
>  	struct netns_nf		nf;
>  	struct netns_xt		xt;
> diff --git a/include/net/netns/decnet.h b/include/net/netns/decnet.h
> new file mode 100644
> index 0000000..7dfb91a
> --- /dev/null
> +++ b/include/net/netns/decnet.h
> @@ -0,0 +1,10 @@
> +#ifndef __NETNS_DECNET_H__
> +#define __NETNS_DECNET_H__
> +
> +struct neigh_table;
> +
> +struct netns_decnet {
> +	struct neigh_table *dn_neigh_table;
> +};
> +
> +#endif
> diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
> index aec5e12..4cfc5ca 100644
> --- a/include/net/netns/ipv4.h
> +++ b/include/net/netns/ipv4.h
> @@ -96,6 +96,7 @@ struct netns_ipv4 {
>  	struct fib_rules_ops	*mr_rules_ops;
>  #endif
>  #endif
> +	struct neigh_table	*arp_tbl;
>  	atomic_t	rt_genid;
>  };
>  #endif
> diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
> index 19d3446..848c10e 100644
> --- a/include/net/netns/ipv6.h
> +++ b/include/net/netns/ipv6.h
> @@ -74,6 +74,7 @@ struct netns_ipv6 {
>  	struct fib_rules_ops	*mr6_rules_ops;
>  #endif
>  #endif
> +	struct neigh_table	*nd_tbl;
>  	atomic_t		dev_addr_genid;
>  	atomic_t		rt_genid;
>  };
> diff --git a/net/atm/clip.c b/net/atm/clip.c
> index ba291ce..24c46f5 100644
> --- a/net/atm/clip.c
> +++ b/net/atm/clip.c
> @@ -155,10 +155,12 @@ static int neigh_check_cb(struct neighbour *n)
>  
>  static void idle_timer_check(unsigned long dummy)
>  {
> -	write_lock(&arp_tbl.lock);
> -	__neigh_for_each_release(&arp_tbl, neigh_check_cb);
> +	struct neigh_table *tbl = init_net.ipv4.arp_tbl;
> +
> +	write_lock(&tbl->lock);
> +	__neigh_for_each_release(tbl, neigh_check_cb);
>  	mod_timer(&idle_timer, jiffies + CLIP_CHECK_INTERVAL * HZ);
> -	write_unlock(&arp_tbl.lock);
> +	write_unlock(&tbl->lock);
>  }
>  
>  static int clip_arp_rcv(struct sk_buff *skb)
> @@ -463,7 +465,7 @@ static int clip_setentry(struct atm_vcc *vcc, __be32 ip)
>  	rt = ip_route_output(&init_net, ip, 0, 1, 0);
>  	if (IS_ERR(rt))
>  		return PTR_ERR(rt);
> -	neigh = __neigh_lookup(&arp_tbl, &ip, rt->dst.dev, 1);
> +	neigh = __neigh_lookup(init_net.ipv4.arp_tbl, &ip, rt->dst.dev, 1);
>  	ip_rt_put(rt);
>  	if (!neigh)
>  		return -ENOMEM;
> @@ -833,7 +835,7 @@ static void *clip_seq_start(struct seq_file *seq, loff_t * pos)
>  {
>  	struct clip_seq_state *state = seq->private;
>  	state->ns.neigh_sub_iter = clip_seq_sub_iter;
> -	return neigh_seq_start(seq, pos, &arp_tbl, NEIGH_SEQ_NEIGH_ONLY);
> +	return neigh_seq_start(seq, pos, init_net.ipv4.arp_tbl, NEIGH_SEQ_NEIGH_ONLY);
>  }
>  
>  static int clip_seq_show(struct seq_file *seq, void *v)
> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
> index 32d872e..563c8cc 100644
> --- a/net/core/neighbour.c
> +++ b/net/core/neighbour.c
> @@ -56,7 +56,6 @@ static void __neigh_notify(struct neighbour *n, int type, int flags);
>  static void neigh_update_notify(struct neighbour *neigh);
>  static int pneigh_ifdown(struct neigh_table *tbl, struct net_device *dev);
>  
> -static struct neigh_table *neigh_tables;
>  #ifdef CONFIG_PROC_FS
>  static const struct file_operations neigh_stat_seq_fops;
>  #endif
> @@ -87,13 +86,8 @@ static const struct file_operations neigh_stat_seq_fops;
>     the most complicated procedure, which we allow is dev->hard_header.
>     It is supposed, that dev->hard_header is simplistic and does
>     not make callbacks to neighbour tables.
> -
> -   The last lock is neigh_tbl_lock. It is pure SMP lock, protecting
> -   list of neighbour tables. This list is used only in process context,
>   */
>  
> -static DEFINE_RWLOCK(neigh_tbl_lock);
> -
>  static int neigh_blackhole(struct neighbour *neigh, struct sk_buff *skb)
>  {
>  	kfree_skb(skb);
> @@ -1530,12 +1524,12 @@ static void neigh_parms_destroy(struct neigh_parms *parms)
>  
>  static struct lock_class_key neigh_table_proxy_queue_class;
>  
> -static void neigh_table_init_no_netlink(struct neigh_table *tbl)
> +void neigh_table_init(struct net *net, struct neigh_table *tbl)
>  {
>  	unsigned long now = jiffies;
>  	unsigned long phsize;
>  
> -	write_pnet(&tbl->parms.net, &init_net);
> +	write_pnet(&tbl->parms.net, net);
>  	atomic_set(&tbl->parms.refcnt, 1);
>  	tbl->parms.reachable_time =
>  			  neigh_rand_reach_time(NEIGH_VAR(&tbl->parms, BASE_REACHABLE_TIME));
> @@ -1545,7 +1539,7 @@ static void neigh_table_init_no_netlink(struct neigh_table *tbl)
>  		panic("cannot create neighbour cache statistics");
>  
>  #ifdef CONFIG_PROC_FS
> -	if (!proc_create_data(tbl->id, 0, init_net.proc_net_stat,
> +	if (!proc_create_data(tbl->id, 0, net->proc_net_stat,
>  			      &neigh_stat_seq_fops, tbl))
>  		panic("cannot create neighbour proc dir entry");
>  #endif
> @@ -1575,32 +1569,11 @@ static void neigh_table_init_no_netlink(struct neigh_table *tbl)
>  	tbl->last_flush = now;
>  	tbl->last_rand	= now + tbl->parms.reachable_time * 20;
>  }
> -
> -void neigh_table_init(struct neigh_table *tbl)
> -{
> -	struct neigh_table *tmp;
> -
> -	neigh_table_init_no_netlink(tbl);
> -	write_lock(&neigh_tbl_lock);
> -	for (tmp = neigh_tables; tmp; tmp = tmp->next) {
> -		if (tmp->family == tbl->family)
> -			break;
> -	}
> -	tbl->next	= neigh_tables;
> -	neigh_tables	= tbl;
> -	write_unlock(&neigh_tbl_lock);
> -
> -	if (unlikely(tmp)) {
> -		pr_err("Registering multiple tables for family %d\n",
> -		       tbl->family);
> -		dump_stack();
> -	}
> -}
>  EXPORT_SYMBOL(neigh_table_init);
>  
>  int neigh_table_clear(struct neigh_table *tbl)
>  {
> -	struct neigh_table **tp;
> +	struct net *net = tbl->parms.net;
>  
>  	/* It is not clean... Fix it to unload IPv6 module safely */
>  	cancel_delayed_work_sync(&tbl->gc_work);
> @@ -1609,14 +1582,6 @@ int neigh_table_clear(struct neigh_table *tbl)
>  	neigh_ifdown(tbl, NULL);
>  	if (atomic_read(&tbl->entries))
>  		pr_crit("neighbour leakage\n");
> -	write_lock(&neigh_tbl_lock);
> -	for (tp = &neigh_tables; *tp; tp = &(*tp)->next) {
> -		if (*tp == tbl) {
> -			*tp = tbl->next;
> -			break;
> -		}
> -	}
> -	write_unlock(&neigh_tbl_lock);
>  
>  	call_rcu(&rcu_dereference_protected(tbl->nht, 1)->rcu,
>  		 neigh_hash_free_rcu);
> @@ -1625,7 +1590,7 @@ int neigh_table_clear(struct neigh_table *tbl)
>  	kfree(tbl->phash_buckets);
>  	tbl->phash_buckets = NULL;
>  
> -	remove_proc_entry(tbl->id, init_net.proc_net_stat);
> +	remove_proc_entry(tbl->id, net->proc_net_stat);
>  
>  	free_percpu(tbl->stats);
>  	tbl->stats = NULL;
> @@ -1634,12 +1599,43 @@ int neigh_table_clear(struct neigh_table *tbl)
>  }
>  EXPORT_SYMBOL(neigh_table_clear);
>  
> +static struct neigh_table *neigh_find_table(struct net *net, unsigned int family)
> +{
> +	struct neigh_table *tbl = NULL;
> +
> +	switch (family) {
> +	case AF_INET:
> +		tbl = net->ipv4.arp_tbl;
> +		break;
> +#if IS_ENABLED(CONFIG_IPV6)
> +	case AF_INET6:
> +		tbl = net->ipv6.nd_tbl;
> +		break;
> +#endif
> +#if IS_ENABLED(CONFIG_DECNET)
> +	case AF_DECnet:
> +		tbl = net->decnet.dn_neigh_table;
> +		break;
> +#endif
> +	}
> +
> +	return tbl;
> +}
> +
> +static void neigh_get_all_tables(struct net *net, struct neigh_table **tbl)
> +{
> +	tbl[NEIGH_ARP_TABLE] = neigh_find_table(net, AF_INET);
> +	tbl[NEIGH_ND_TABLE] = neigh_find_table(net, AF_INET6);
> +	tbl[NEIGH_DN_TABLE] = neigh_find_table(net, AF_DECnet);
> +}
> +
>  static int neigh_delete(struct sk_buff *skb, struct nlmsghdr *nlh)
>  {
>  	struct net *net = sock_net(skb->sk);
>  	struct ndmsg *ndm;
>  	struct nlattr *dst_attr;
>  	struct neigh_table *tbl;
> +	struct neighbour *neigh;
>  	struct net_device *dev = NULL;
>  	int err = -EINVAL;
>  
> @@ -1660,39 +1656,30 @@ static int neigh_delete(struct sk_buff *skb, struct nlmsghdr *nlh)
>  		}
>  	}
>  
> -	read_lock(&neigh_tbl_lock);
> -	for (tbl = neigh_tables; tbl; tbl = tbl->next) {
> -		struct neighbour *neigh;
> +	tbl = neigh_find_table(net, ndm->ndm_family);
> +	if (tbl == NULL)
> +		return -EAFNOSUPPORT;
>  
> -		if (tbl->family != ndm->ndm_family)
> -			continue;
> -		read_unlock(&neigh_tbl_lock);
> -
> -		if (nla_len(dst_attr) < tbl->key_len)
> -			goto out;
> -
> -		if (ndm->ndm_flags & NTF_PROXY) {
> -			err = pneigh_delete(tbl, net, nla_data(dst_attr), dev);
> -			goto out;
> -		}
> +	if (nla_len(dst_attr) < tbl->key_len)
> +		goto out;
>  
> -		if (dev == NULL)
> -			goto out;
> +	if (ndm->ndm_flags & NTF_PROXY)
> +		err = pneigh_delete(tbl, net, nla_data(dst_attr), dev);
> +		goto out;
>  
> -		neigh = neigh_lookup(tbl, nla_data(dst_attr), dev);
> -		if (neigh == NULL) {
> -			err = -ENOENT;
> -			goto out;
> -		}
> +	if (dev == NULL)
> +		goto out;
>  
> -		err = neigh_update(neigh, NULL, NUD_FAILED,
> -				   NEIGH_UPDATE_F_OVERRIDE |
> -				   NEIGH_UPDATE_F_ADMIN);
> -		neigh_release(neigh);
> +	neigh = neigh_lookup(tbl, nla_data(dst_attr), dev);
> +	if (neigh == NULL) {
> +		err = -ENOENT;
>  		goto out;
>  	}
> -	read_unlock(&neigh_tbl_lock);
> -	err = -EAFNOSUPPORT;
> +
> +	err = neigh_update(neigh, NULL, NUD_FAILED,
> +			   NEIGH_UPDATE_F_OVERRIDE |
> +			   NEIGH_UPDATE_F_ADMIN);
> +	neigh_release(neigh);
>  
>  out:
>  	return err;
> @@ -1706,6 +1693,10 @@ static int neigh_add(struct sk_buff *skb, struct nlmsghdr *nlh)
>  	struct neigh_table *tbl;
>  	struct net_device *dev = NULL;
>  	int err;
> +	int flags = NEIGH_UPDATE_F_ADMIN | NEIGH_UPDATE_F_OVERRIDE;
> +	struct neighbour *neigh;
> +	void *dst, *lladdr;
> +
>  
>  	ASSERT_RTNL();
>  	err = nlmsg_parse(nlh, sizeof(*ndm), tb, NDA_MAX, NULL);
> @@ -1728,70 +1719,59 @@ static int neigh_add(struct sk_buff *skb, struct nlmsghdr *nlh)
>  			goto out;
>  	}
>  
> -	read_lock(&neigh_tbl_lock);
> -	for (tbl = neigh_tables; tbl; tbl = tbl->next) {
> -		int flags = NEIGH_UPDATE_F_ADMIN | NEIGH_UPDATE_F_OVERRIDE;
> -		struct neighbour *neigh;
> -		void *dst, *lladdr;
> +	tbl = neigh_find_table(net, ndm->ndm_family);
> +	if (tbl == NULL)
> +		return -EAFNOSUPPORT;
>  
> -		if (tbl->family != ndm->ndm_family)
> -			continue;
> -		read_unlock(&neigh_tbl_lock);
> +	if (nla_len(tb[NDA_DST]) < tbl->key_len)
> +		goto out;
> +	dst = nla_data(tb[NDA_DST]);
> +	lladdr = tb[NDA_LLADDR] ? nla_data(tb[NDA_LLADDR]) : NULL;
>  
> -		if (nla_len(tb[NDA_DST]) < tbl->key_len)
> -			goto out;
> -		dst = nla_data(tb[NDA_DST]);
> -		lladdr = tb[NDA_LLADDR] ? nla_data(tb[NDA_LLADDR]) : NULL;
> +	if (ndm->ndm_flags & NTF_PROXY) {
> +		struct pneigh_entry *pn;
>  
> -		if (ndm->ndm_flags & NTF_PROXY) {
> -			struct pneigh_entry *pn;
> +		err = -ENOBUFS;
> +		pn = pneigh_lookup(tbl, net, dst, dev, 1);
> +		if (pn) {
> +			pn->flags = ndm->ndm_flags;
> +			err = 0;
> +		}
> +		goto out;
> +	}
>  
> -			err = -ENOBUFS;
> -			pn = pneigh_lookup(tbl, net, dst, dev, 1);
> -			if (pn) {
> -				pn->flags = ndm->ndm_flags;
> -				err = 0;
> -			}
> +	if (dev == NULL)
> +		goto out;
> +
> +	neigh = neigh_lookup(tbl, dst, dev);
> +	if (neigh == NULL) {
> +		if (!(nlh->nlmsg_flags & NLM_F_CREATE)) {
> +			err = -ENOENT;
>  			goto out;
>  		}
>  
> -		if (dev == NULL)
> +		neigh = __neigh_lookup_errno(tbl, dst, dev);
> +		if (IS_ERR(neigh)) {
> +			err = PTR_ERR(neigh);
> +			goto out;
> +		}
> +	} else {
> +		if (nlh->nlmsg_flags & NLM_F_EXCL) {
> +			err = -EEXIST;
> +			neigh_release(neigh);
>  			goto out;
> -
> -		neigh = neigh_lookup(tbl, dst, dev);
> -		if (neigh == NULL) {
> -			if (!(nlh->nlmsg_flags & NLM_F_CREATE)) {
> -				err = -ENOENT;
> -				goto out;
> -			}
> -
> -			neigh = __neigh_lookup_errno(tbl, dst, dev);
> -			if (IS_ERR(neigh)) {
> -				err = PTR_ERR(neigh);
> -				goto out;
> -			}
> -		} else {
> -			if (nlh->nlmsg_flags & NLM_F_EXCL) {
> -				err = -EEXIST;
> -				neigh_release(neigh);
> -				goto out;
> -			}
> -
> -			if (!(nlh->nlmsg_flags & NLM_F_REPLACE))
> -				flags &= ~NEIGH_UPDATE_F_OVERRIDE;
>  		}
>  
> -		if (ndm->ndm_flags & NTF_USE) {
> -			neigh_event_send(neigh, NULL);
> -			err = 0;
> -		} else
> -			err = neigh_update(neigh, lladdr, ndm->ndm_state, flags);
> -		neigh_release(neigh);
> -		goto out;
> +		if (!(nlh->nlmsg_flags & NLM_F_REPLACE))
> +			flags &= ~NEIGH_UPDATE_F_OVERRIDE;
>  	}
>  
> -	read_unlock(&neigh_tbl_lock);
> -	err = -EAFNOSUPPORT;
> +	if (ndm->ndm_flags & NTF_USE) {
> +		neigh_event_send(neigh, NULL);
> +		err = 0;
> +	} else
> +		err = neigh_update(neigh, lladdr, ndm->ndm_state, flags);
> +	neigh_release(neigh);
>  out:
>  	return err;
>  }
> @@ -2003,18 +1983,10 @@ static int neightbl_set(struct sk_buff *skb, struct nlmsghdr *nlh)
>  	}
>  
>  	ndtmsg = nlmsg_data(nlh);
> -	read_lock(&neigh_tbl_lock);
> -	for (tbl = neigh_tables; tbl; tbl = tbl->next) {
> -		if (ndtmsg->ndtm_family && tbl->family != ndtmsg->ndtm_family)
> -			continue;
> -
> -		if (nla_strcmp(tb[NDTA_NAME], tbl->id) == 0)
> -			break;
> -	}
> -
> -	if (tbl == NULL) {
> +	tbl = neigh_find_table(net, ndtmsg->ndtm_family);
> +	if (tbl == NULL || nla_strcmp(tb[NDTA_NAME], tbl->id) != 0) {
>  		err = -ENOENT;
> -		goto errout_locked;
> +		goto errout;
>  	}
>  
>  	/*
> @@ -2126,8 +2098,6 @@ static int neightbl_set(struct sk_buff *skb, struct nlmsghdr *nlh)
>  
>  errout_tbl_lock:
>  	write_unlock_bh(&tbl->lock);
> -errout_locked:
> -	read_unlock(&neigh_tbl_lock);
>  errout:
>  	return err;
>  }
> @@ -2138,14 +2108,19 @@ static int neightbl_dump_info(struct sk_buff *skb, struct netlink_callback *cb)
>  	int family, tidx, nidx = 0;
>  	int tbl_skip = cb->args[0];
>  	int neigh_skip = cb->args[1];
> +	struct neigh_table *tbls[NEIGH_NR_TABLES];
>  	struct neigh_table *tbl;
>  
> -	family = ((struct rtgenmsg *) nlmsg_data(cb->nlh))->rtgen_family;
> +	neigh_get_all_tables(net, tbls);
>  
> -	read_lock(&neigh_tbl_lock);
> -	for (tbl = neigh_tables, tidx = 0; tbl; tbl = tbl->next, tidx++) {
> +	family = ((struct rtgenmsg *) nlmsg_data(cb->nlh))->rtgen_family;
> +	for (tidx = 0; tidx < NEIGH_NR_TABLES; tidx++) {
>  		struct neigh_parms *p;
>  
> +		tbl = tbls[tidx];
> +
> +		if (!tbl)
> +			continue;
>  		if (tidx < tbl_skip || (family && tbl->family != family))
>  			continue;
>  
> @@ -2174,7 +2149,6 @@ static int neightbl_dump_info(struct sk_buff *skb, struct netlink_callback *cb)
>  		neigh_skip = 0;
>  	}
>  out:
> -	read_unlock(&neigh_tbl_lock);
>  	cb->args[0] = tidx;
>  	cb->args[1] = nidx;
>  
> @@ -2352,12 +2326,14 @@ out:
>  
>  static int neigh_dump_info(struct sk_buff *skb, struct netlink_callback *cb)
>  {
> +	struct neigh_table *tbls[NEIGH_NR_TABLES];
> +	struct net *net = sock_net(skb->sk);
>  	struct neigh_table *tbl;
>  	int t, family, s_t;
>  	int proxy = 0;
>  	int err;
>  
> -	read_lock(&neigh_tbl_lock);
> +	neigh_get_all_tables(net, tbls);
>  	family = ((struct rtgenmsg *) nlmsg_data(cb->nlh))->rtgen_family;
>  
>  	/* check for full ndmsg structure presence, family member is
> @@ -2369,8 +2345,11 @@ static int neigh_dump_info(struct sk_buff *skb, struct netlink_callback *cb)
>  
>  	s_t = cb->args[0];
>  
> -	for (tbl = neigh_tables, t = 0; tbl;
> -	     tbl = tbl->next, t++) {
> +	for (t = 0; t < NEIGH_NR_TABLES; t++) {
> +		tbl = tbls[t];
> +
> +		if (!tbl)
> +			continue;
>  		if (t < s_t || (family && tbl->family != family))
>  			continue;
>  		if (t > s_t)
> @@ -2383,7 +2362,6 @@ static int neigh_dump_info(struct sk_buff *skb, struct netlink_callback *cb)
>  		if (err < 0)
>  			break;
>  	}
> -	read_unlock(&neigh_tbl_lock);
>  
>  	cb->args[0] = t;
>  	return skb->len;
> diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
> index 3b726f3..8e4f9cf 100644
> --- a/net/decnet/dn_dev.c
> +++ b/net/decnet/dn_dev.c
> @@ -61,8 +61,6 @@ static char dn_rt_all_rt_mcast[ETH_ALEN]  = {0xAB,0x00,0x00,0x03,0x00,0x00};
>  static char dn_hiord[ETH_ALEN]            = {0xAA,0x00,0x04,0x00,0x00,0x00};
>  static unsigned char dn_eco_version[3]    = {0x02,0x00,0x00};
>  
> -extern struct neigh_table dn_neigh_table;
> -
>  /*
>   * decnet_address is kept in network order.
>   */
> @@ -1076,6 +1074,7 @@ static struct dn_dev *dn_dev_create(struct net_device *dev, int *err)
>  	int i;
>  	struct dn_dev_parms *p = dn_dev_list;
>  	struct dn_dev *dn_db;
> +	struct net *net = dev_net(dev);
>  
>  	for(i = 0; i < DN_DEV_LIST_SIZE; i++, p++) {
>  		if (p->type == dev->type)
> @@ -1098,7 +1097,7 @@ static struct dn_dev *dn_dev_create(struct net_device *dev, int *err)
>  
>  	dn_db->uptime = jiffies;
>  
> -	dn_db->neigh_parms = neigh_parms_alloc(dev, &dn_neigh_table);
> +	dn_db->neigh_parms = neigh_parms_alloc(dev, net->decnet.dn_neigh_table);
>  	if (!dn_db->neigh_parms) {
>  		RCU_INIT_POINTER(dev->dn_ptr, NULL);
>  		kfree(dn_db);
> @@ -1107,7 +1106,7 @@ static struct dn_dev *dn_dev_create(struct net_device *dev, int *err)
>  
>  	if (dn_db->parms.up) {
>  		if (dn_db->parms.up(dev) < 0) {
> -			neigh_parms_release(&dn_neigh_table, dn_db->neigh_parms);
> +			neigh_parms_release(net->decnet.dn_neigh_table, dn_db->neigh_parms);
>  			dev->dn_ptr = NULL;
>  			kfree(dn_db);
>  			return NULL;
> @@ -1191,6 +1190,7 @@ void dn_dev_up(struct net_device *dev)
>  static void dn_dev_delete(struct net_device *dev)
>  {
>  	struct dn_dev *dn_db = rtnl_dereference(dev->dn_ptr);
> +	struct net *net = dev_net(dev);
>  
>  	if (dn_db == NULL)
>  		return;
> @@ -1198,15 +1198,15 @@ static void dn_dev_delete(struct net_device *dev)
>  	del_timer_sync(&dn_db->timer);
>  	dn_dev_sysctl_unregister(&dn_db->parms);
>  	dn_dev_check_default(dev);
> -	neigh_ifdown(&dn_neigh_table, dev);
> +	neigh_ifdown(net->decnet.dn_neigh_table, dev);
>  
>  	if (dn_db->parms.down)
>  		dn_db->parms.down(dev);
>  
>  	dev->dn_ptr = NULL;
>  
> -	neigh_parms_release(&dn_neigh_table, dn_db->neigh_parms);
> -	neigh_ifdown(&dn_neigh_table, dev);
> +	neigh_parms_release(net->decnet.dn_neigh_table, dn_db->neigh_parms);
> +	neigh_ifdown(net->decnet.dn_neigh_table, dev);
>  
>  	if (dn_db->router)
>  		neigh_release(dn_db->router);
> diff --git a/net/decnet/dn_fib.c b/net/decnet/dn_fib.c
> index d332aef..8a16285 100644
> --- a/net/decnet/dn_fib.c
> +++ b/net/decnet/dn_fib.c
> @@ -657,10 +657,12 @@ static void dn_fib_del_ifaddr(struct dn_ifaddr *ifa)
>  
>  static void dn_fib_disable_addr(struct net_device *dev, int force)
>  {
> +	struct net *net = dev_net(dev);
> +
>  	if (dn_fib_sync_down(0, dev, force))
>  		dn_fib_flush();
>  	dn_rt_cache_flush(0);
> -	neigh_ifdown(&dn_neigh_table, dev);
> +	neigh_ifdown(net->decnet.dn_neigh_table, dev);
>  }
>  
>  static int dn_fib_dnaddr_event(struct notifier_block *this, unsigned long event, void *ptr)
> diff --git a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
> index c8121ce..2010448 100644
> --- a/net/decnet/dn_neigh.c
> +++ b/net/decnet/dn_neigh.c
> @@ -93,37 +93,6 @@ static u32 dn_neigh_hash(const void *pkey,
>  	return jhash_2words(*(__u16 *)pkey, 0, hash_rnd[0]);
>  }
>  
> -struct neigh_table dn_neigh_table = {
> -	.family =			PF_DECnet,
> -	.entry_size =			NEIGH_ENTRY_SIZE(sizeof(struct dn_neigh)),
> -	.key_len =			sizeof(__le16),
> -	.hash =				dn_neigh_hash,
> -	.constructor =			dn_neigh_construct,
> -	.id =				"dn_neigh_cache",
> -	.parms ={
> -		.tbl =			&dn_neigh_table,
> -		.reachable_time =	30 * HZ,
> -		.data = {
> -			[NEIGH_VAR_MCAST_PROBES] = 0,
> -			[NEIGH_VAR_UCAST_PROBES] = 0,
> -			[NEIGH_VAR_APP_PROBES] = 0,
> -			[NEIGH_VAR_RETRANS_TIME] = 1 * HZ,
> -			[NEIGH_VAR_BASE_REACHABLE_TIME] = 30 * HZ,
> -			[NEIGH_VAR_DELAY_PROBE_TIME] = 5 * HZ,
> -			[NEIGH_VAR_GC_STALETIME] = 60 * HZ,
> -			[NEIGH_VAR_QUEUE_LEN_BYTES] = 64*1024,
> -			[NEIGH_VAR_PROXY_QLEN] = 0,
> -			[NEIGH_VAR_ANYCAST_DELAY] = 0,
> -			[NEIGH_VAR_PROXY_DELAY] = 0,
> -			[NEIGH_VAR_LOCKTIME] = 1 * HZ,
> -		},
> -	},
> -	.gc_interval =			30 * HZ,
> -	.gc_thresh1 =			128,
> -	.gc_thresh2 =			512,
> -	.gc_thresh3 =			1024,
> -};
> -
>  static int dn_neigh_construct(struct neighbour *neigh)
>  {
>  	struct net_device *dev = neigh->dev;
> @@ -369,11 +338,12 @@ int dn_neigh_router_hello(struct sk_buff *skb)
>  	struct neighbour *neigh;
>  	struct dn_neigh *dn;
>  	struct dn_dev *dn_db;
> +	struct net *net = dev_net(skb->dev);
>  	__le16 src;
>  
>  	src = dn_eth2dn(msg->id);
>  
> -	neigh = __neigh_lookup(&dn_neigh_table, &src, skb->dev, 1);
> +	neigh = __neigh_lookup(net->decnet.dn_neigh_table, &src, skb->dev, 1);
>  
>  	dn = (struct dn_neigh *)neigh;
>  
> @@ -429,11 +399,12 @@ int dn_neigh_endnode_hello(struct sk_buff *skb)
>  	struct endnode_hello_message *msg = (struct endnode_hello_message *)skb->data;
>  	struct neighbour *neigh;
>  	struct dn_neigh *dn;
> +	struct net *net = dev_net(skb->dev);
>  	__le16 src;
>  
>  	src = dn_eth2dn(msg->id);
>  
> -	neigh = __neigh_lookup(&dn_neigh_table, &src, skb->dev, 1);
> +	neigh = __neigh_lookup(net->decnet.dn_neigh_table, &src, skb->dev, 1);
>  
>  	dn = (struct dn_neigh *)neigh;
>  
> @@ -515,6 +486,7 @@ static void neigh_elist_cb(struct neighbour *neigh, void *_info)
>  int dn_neigh_elist(struct net_device *dev, unsigned char *ptr, int n)
>  {
>  	struct elist_cb_state state;
> +	struct net *net = dev_net(dev);
>  
>  	state.dev = dev;
>  	state.t = 0;
> @@ -522,7 +494,7 @@ int dn_neigh_elist(struct net_device *dev, unsigned char *ptr, int n)
>  	state.ptr = ptr;
>  	state.rs = ptr;
>  
> -	neigh_for_each(&dn_neigh_table, neigh_elist_cb, &state);
> +	neigh_for_each(net->decnet.dn_neigh_table, neigh_elist_cb, &state);
>  
>  	return state.t;
>  }
> @@ -562,7 +534,9 @@ static int dn_neigh_seq_show(struct seq_file *seq, void *v)
>  
>  static void *dn_neigh_seq_start(struct seq_file *seq, loff_t *pos)
>  {
> -	return neigh_seq_start(seq, pos, &dn_neigh_table,
> +	struct net *net = seq_file_net(seq);
> +
> +	return neigh_seq_start(seq, pos, net->decnet.dn_neigh_table,
>  			       NEIGH_SEQ_NEIGH_ONLY);
>  }
>  
> @@ -589,9 +563,64 @@ static const struct file_operations dn_neigh_seq_fops = {
>  
>  #endif
>  
> +struct neigh_table dft_dn_neigh_table = {
> +	.family =			PF_DECnet,
> +	.entry_size =			NEIGH_ENTRY_SIZE(sizeof(struct dn_neigh)),
> +	.key_len =			sizeof(__le16),
> +	.hash =				dn_neigh_hash,
> +	.constructor =			dn_neigh_construct,
> +	.id =				"dn_neigh_cache",
> +	.parms = {
> +		.tbl =			&dft_dn_neigh_table,
> +		.reachable_time =	30 * HZ,
> +		.data = {
> +			[NEIGH_VAR_MCAST_PROBES] = 0,
> +			[NEIGH_VAR_UCAST_PROBES] = 0,
> +			[NEIGH_VAR_APP_PROBES] = 0,
> +			[NEIGH_VAR_RETRANS_TIME] = 1 * HZ,
> +			[NEIGH_VAR_BASE_REACHABLE_TIME] = 30 * HZ,
> +			[NEIGH_VAR_DELAY_PROBE_TIME] = 5 * HZ,
> +			[NEIGH_VAR_GC_STALETIME] = 60 * HZ,
> +			[NEIGH_VAR_QUEUE_LEN_BYTES] = 64*1024,
> +			[NEIGH_VAR_PROXY_QLEN] = 0,
> +			[NEIGH_VAR_ANYCAST_DELAY] = 0,
> +			[NEIGH_VAR_PROXY_DELAY] = 0,
> +			[NEIGH_VAR_LOCKTIME] = 1 * HZ,
> +		},
> +	},
> +	.gc_interval =			30 * HZ,
> +	.gc_thresh1 =			128,
> +	.gc_thresh2 =			512,
> +	.gc_thresh3 =			1024,
> +};
> +
> +static int __net_init dn_neigh_net_init(struct net *net)
> +{
> +	net->decnet.dn_neigh_table = kmemdup(&dft_dn_neigh_table,
> +					     sizeof(dft_dn_neigh_table),
> +					     GFP_KERNEL);
> +	if (!net->decnet.dn_neigh_table)
> +		return -ENOMEM;
> +	net->decnet.dn_neigh_table->parms.tbl = net->decnet.dn_neigh_table;
> +	neigh_table_init(net, net->decnet.dn_neigh_table);
> +	return 0;
> +}
> +
> +static void __net_exit dn_neigh_net_exit(struct net *net)
> +{
> +	neigh_table_clear(net->decnet.dn_neigh_table);
> +	kfree(net->decnet.dn_neigh_table);
> +}
> +
> +static struct pernet_operations dn_neigh_net_ops = {
> +	.init = dn_neigh_net_init,
> +	.exit = dn_neigh_net_exit,
> +};
> +
> +
>  void __init dn_neigh_init(void)
>  {
> -	neigh_table_init(&dn_neigh_table);
> +	register_pernet_subsys(&dn_neigh_net_ops);
>  	proc_create("decnet_neigh", S_IRUGO, init_net.proc_net,
>  		    &dn_neigh_seq_fops);
>  }
> @@ -599,5 +628,5 @@ void __init dn_neigh_init(void)
>  void __exit dn_neigh_cleanup(void)
>  {
>  	remove_proc_entry("decnet_neigh", init_net.proc_net);
> -	neigh_table_clear(&dn_neigh_table);
> +	unregister_pernet_subsys(&dn_neigh_net_ops);
>  }
> diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
> index daccc4a..a2bfe32 100644
> --- a/net/decnet/dn_route.c
> +++ b/net/decnet/dn_route.c
> @@ -98,9 +98,6 @@ struct dn_rt_hash_bucket
>  	spinlock_t lock;
>  };
>  
> -extern struct neigh_table dn_neigh_table;
> -
> -
>  static unsigned char dn_hiord_addr[6] = {0xAA,0x00,0x04,0x00,0x00,0x00};
>  
>  static const int dn_rt_min_delay = 2 * HZ;
> @@ -878,13 +875,16 @@ static struct neighbour *dn_dst_neigh_lookup(const struct dst_entry *dst,
>  					     struct sk_buff *skb,
>  					     const void *daddr)
>  {
> -	return __neigh_lookup_errno(&dn_neigh_table, daddr, dst->dev);
> +	struct net *net = dev_net(dst->dev);
> +
> +	return __neigh_lookup_errno(net->decnet.dn_neigh_table, daddr, dst->dev);
>  }
>  
>  static int dn_rt_set_next_hop(struct dn_route *rt, struct dn_fib_res *res)
>  {
>  	struct dn_fib_info *fi = res->fi;
>  	struct net_device *dev = rt->dst.dev;
> +	struct net *net = dev_net(dev);
>  	unsigned int mss_metric;
>  	struct neighbour *n;
>  
> @@ -897,7 +897,7 @@ static int dn_rt_set_next_hop(struct dn_route *rt, struct dn_fib_res *res)
>  	rt->rt_type = res->type;
>  
>  	if (dev != NULL && rt->n == NULL) {
> -		n = __neigh_lookup_errno(&dn_neigh_table, &rt->rt_gateway, dev);
> +		n = __neigh_lookup_errno(net->decnet.dn_neigh_table, &rt->rt_gateway, dev);
>  		if (IS_ERR(n))
>  			return PTR_ERR(n);
>  		rt->n = n;
> @@ -1087,7 +1087,7 @@ source_ok:
>  		 * here
>  		 */
>  		if (!try_hard) {
> -			neigh = neigh_lookup_nodev(&dn_neigh_table, &init_net, &fld.daddr);
> +			neigh = neigh_lookup_nodev(init_net.decnet.dn_neigh_table, &init_net, &fld.daddr);
>  			if (neigh) {
>  				if ((oldflp->flowidn_oif &&
>  				    (neigh->dev->ifindex != oldflp->flowidn_oif)) ||
> diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
> index 1a9b99e..a274e33 100644
> --- a/net/ipv4/arp.c
> +++ b/net/ipv4/arp.c
> @@ -157,37 +157,6 @@ static const struct neigh_ops arp_broken_ops = {
>  	.connected_output =	neigh_compat_output,
>  };
>  
> -struct neigh_table arp_tbl = {
> -	.family		= AF_INET,
> -	.key_len	= 4,
> -	.hash		= arp_hash,
> -	.constructor	= arp_constructor,
> -	.proxy_redo	= parp_redo,
> -	.id		= "arp_cache",
> -	.parms		= {
> -		.tbl			= &arp_tbl,
> -		.reachable_time		= 30 * HZ,
> -		.data	= {
> -			[NEIGH_VAR_MCAST_PROBES] = 3,
> -			[NEIGH_VAR_UCAST_PROBES] = 3,
> -			[NEIGH_VAR_RETRANS_TIME] = 1 * HZ,
> -			[NEIGH_VAR_BASE_REACHABLE_TIME] = 30 * HZ,
> -			[NEIGH_VAR_DELAY_PROBE_TIME] = 5 * HZ,
> -			[NEIGH_VAR_GC_STALETIME] = 60 * HZ,
> -			[NEIGH_VAR_QUEUE_LEN_BYTES] = 64 * 1024,
> -			[NEIGH_VAR_PROXY_QLEN] = 64,
> -			[NEIGH_VAR_ANYCAST_DELAY] = 1 * HZ,
> -			[NEIGH_VAR_PROXY_DELAY]	= (8 * HZ) / 10,
> -			[NEIGH_VAR_LOCKTIME] = 1 * HZ,
> -		},
> -	},
> -	.gc_interval	= 30 * HZ,
> -	.gc_thresh1	= 128,
> -	.gc_thresh2	= 512,
> -	.gc_thresh3	= 1024,
> -};
> -EXPORT_SYMBOL(arp_tbl);
> -
>  int arp_mc_map(__be32 addr, u8 *haddr, struct net_device *dev, int dir)
>  {
>  	switch (dev->type) {
> @@ -480,7 +449,7 @@ int arp_find(unsigned char *haddr, struct sk_buff *skb)
>  			       paddr, dev))
>  		return 0;
>  
> -	n = __neigh_lookup(&arp_tbl, &paddr, dev, 1);
> +	n = __neigh_lookup(dev_net(dev)->ipv4.arp_tbl, &paddr, dev, 1);
>  
>  	if (n) {
>  		n->used = jiffies;
> @@ -855,7 +824,7 @@ static int arp_process(struct sk_buff *skb)
>  			if (!dont_send && IN_DEV_ARPFILTER(in_dev))
>  				dont_send = arp_filter(sip, tip, dev);
>  			if (!dont_send) {
> -				n = neigh_event_ns(&arp_tbl, sha, &sip, dev);
> +				n = neigh_event_ns(net->ipv4.arp_tbl, sha, &sip, dev);
>  				if (n) {
>  					arp_send(ARPOP_REPLY, ETH_P_ARP, sip,
>  						 dev, tip, sha, dev->dev_addr,
> @@ -869,8 +838,8 @@ static int arp_process(struct sk_buff *skb)
>  			    (arp_fwd_proxy(in_dev, dev, rt) ||
>  			     arp_fwd_pvlan(in_dev, dev, rt, sip, tip) ||
>  			     (rt->dst.dev != dev &&
> -			      pneigh_lookup(&arp_tbl, net, &tip, dev, 0)))) {
> -				n = neigh_event_ns(&arp_tbl, sha, &sip, dev);
> +			      pneigh_lookup(net->ipv4.arp_tbl, net, &tip, dev, 0)))) {
> +				n = neigh_event_ns(net->ipv4.arp_tbl, sha, &sip, dev);
>  				if (n)
>  					neigh_release(n);
>  
> @@ -881,7 +850,7 @@ static int arp_process(struct sk_buff *skb)
>  						 dev, tip, sha, dev->dev_addr,
>  						 sha);
>  				} else {
> -					pneigh_enqueue(&arp_tbl,
> +					pneigh_enqueue(net->ipv4.arp_tbl,
>  						       in_dev->arp_parms, skb);
>  					return 0;
>  				}
> @@ -892,7 +861,7 @@ static int arp_process(struct sk_buff *skb)
>  
>  	/* Update our ARP tables */
>  
> -	n = __neigh_lookup(&arp_tbl, &sip, dev, 0);
> +	n = __neigh_lookup(net->ipv4.arp_tbl, &sip, dev, 0);
>  
>  	if (IN_DEV_ARP_ACCEPT(in_dev)) {
>  		/* Unsolicited ARP is not accepted by default.
> @@ -905,7 +874,7 @@ static int arp_process(struct sk_buff *skb)
>  		if (n == NULL &&
>  		    ((arp->ar_op == htons(ARPOP_REPLY)  &&
>  		      inet_addr_type(net, sip) == RTN_UNICAST) || is_garp))
> -			n = __neigh_lookup(&arp_tbl, &sip, dev, 1);
> +			n = __neigh_lookup(net->ipv4.arp_tbl, &sip, dev, 1);
>  	}
>  
>  	if (n) {
> @@ -1016,7 +985,7 @@ static int arp_req_set_public(struct net *net, struct arpreq *r,
>  			return -ENODEV;
>  	}
>  	if (mask) {
> -		if (pneigh_lookup(&arp_tbl, net, &ip, dev, 1) == NULL)
> +		if (pneigh_lookup(dev_net(dev)->ipv4.arp_tbl, net, &ip, dev, 1) == NULL)
>  			return -ENOBUFS;
>  		return 0;
>  	}
> @@ -1068,7 +1037,7 @@ static int arp_req_set(struct net *net, struct arpreq *r,
>  		break;
>  	}
>  
> -	neigh = __neigh_lookup_errno(&arp_tbl, &ip, dev);
> +	neigh = __neigh_lookup_errno(net->ipv4.arp_tbl, &ip, dev);
>  	err = PTR_ERR(neigh);
>  	if (!IS_ERR(neigh)) {
>  		unsigned int state = NUD_STALE;
> @@ -1100,10 +1069,11 @@ static unsigned int arp_state_to_flags(struct neighbour *neigh)
>  static int arp_req_get(struct arpreq *r, struct net_device *dev)
>  {
>  	__be32 ip = ((struct sockaddr_in *) &r->arp_pa)->sin_addr.s_addr;
> +	struct net *net = dev_net(dev);
>  	struct neighbour *neigh;
>  	int err = -ENXIO;
>  
> -	neigh = neigh_lookup(&arp_tbl, &ip, dev);
> +	neigh = neigh_lookup(net->ipv4.arp_tbl, &ip, dev);
>  	if (neigh) {
>  		read_lock_bh(&neigh->lock);
>  		memcpy(r->arp_ha.sa_data, neigh->ha, dev->addr_len);
> @@ -1119,7 +1089,8 @@ static int arp_req_get(struct arpreq *r, struct net_device *dev)
>  
>  static int arp_invalidate(struct net_device *dev, __be32 ip)
>  {
> -	struct neighbour *neigh = neigh_lookup(&arp_tbl, &ip, dev);
> +	struct net *net = dev_net(dev);
> +	struct neighbour *neigh = neigh_lookup(net->ipv4.arp_tbl, &ip, dev);
>  	int err = -ENXIO;
>  
>  	if (neigh) {
> @@ -1140,7 +1111,7 @@ static int arp_req_delete_public(struct net *net, struct arpreq *r,
>  	__be32 mask = ((struct sockaddr_in *)&r->arp_netmask)->sin_addr.s_addr;
>  
>  	if (mask == htonl(0xFFFFFFFF))
> -		return pneigh_delete(&arp_tbl, net, &ip, dev);
> +		return pneigh_delete(net->ipv4.arp_tbl, net, &ip, dev);
>  
>  	if (mask)
>  		return -EINVAL;
> @@ -1243,16 +1214,17 @@ static int arp_netdev_event(struct notifier_block *this, unsigned long event,
>  {
>  	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
>  	struct netdev_notifier_change_info *change_info;
> +	struct net *net = dev_net(dev);
>  
>  	switch (event) {
>  	case NETDEV_CHANGEADDR:
> -		neigh_changeaddr(&arp_tbl, dev);
> +		neigh_changeaddr(net->ipv4.arp_tbl, dev);
>  		rt_cache_flush(dev_net(dev));
>  		break;
>  	case NETDEV_CHANGE:
>  		change_info = ptr;
>  		if (change_info->flags_changed & IFF_NOARP)
> -			neigh_changeaddr(&arp_tbl, dev);
> +			neigh_changeaddr(net->ipv4.arp_tbl, dev);
>  		break;
>  	default:
>  		break;
> @@ -1271,7 +1243,9 @@ static struct notifier_block arp_netdev_notifier = {
>   */
>  void arp_ifdown(struct net_device *dev)
>  {
> -	neigh_ifdown(&arp_tbl, dev);
> +	struct net *net = dev_net(dev);
> +
> +	neigh_ifdown(net->ipv4.arp_tbl, dev);
>  }
>  
>  
> @@ -1288,13 +1262,8 @@ static int arp_proc_init(void);
>  
>  void __init arp_init(void)
>  {
> -	neigh_table_init(&arp_tbl);
> -
>  	dev_add_pack(&arp_packet_type);
>  	arp_proc_init();
> -#ifdef CONFIG_SYSCTL
> -	neigh_sysctl_register(NULL, &arp_tbl.parms, NULL);
> -#endif
>  	register_netdevice_notifier(&arp_netdev_notifier);
>  }
>  
> @@ -1401,10 +1370,11 @@ static int arp_seq_show(struct seq_file *seq, void *v)
>  
>  static void *arp_seq_start(struct seq_file *seq, loff_t *pos)
>  {
> +	struct net *net = seq_file_net(seq);
>  	/* Don't want to confuse "arp -a" w/ magic entries,
>  	 * so we tell the generic iterator to skip NUD_NOARP.
>  	 */
> -	return neigh_seq_start(seq, pos, &arp_tbl, NEIGH_SEQ_SKIP_NOARP);
> +	return neigh_seq_start(seq, pos, net->ipv4.arp_tbl, NEIGH_SEQ_SKIP_NOARP);
>  }
>  
>  /* ------------------------------------------------------------------------ */
> @@ -1429,18 +1399,81 @@ static const struct file_operations arp_seq_fops = {
>  	.llseek         = seq_lseek,
>  	.release	= seq_release_net,
>  };
> +#endif /* CONFIG_PROC_FS */
>  
> +static struct neigh_table dft_arp_tbl = {
> +	.family		= AF_INET,
> +	.key_len	= 4,
> +	.hash		= arp_hash,
> +	.constructor	= arp_constructor,
> +	.proxy_redo	= parp_redo,
> +	.id		= "arp_cache",
> +	.parms		= {
> +		.tbl			= &dft_arp_tbl,
> +		.reachable_time		= 30 * HZ,
> +		.data	= {
> +			[NEIGH_VAR_MCAST_PROBES] = 3,
> +			[NEIGH_VAR_UCAST_PROBES] = 3,
> +			[NEIGH_VAR_RETRANS_TIME] = 1 * HZ,
> +			[NEIGH_VAR_BASE_REACHABLE_TIME] = 30 * HZ,
> +			[NEIGH_VAR_DELAY_PROBE_TIME] = 5 * HZ,
> +			[NEIGH_VAR_GC_STALETIME] = 60 * HZ,
> +			[NEIGH_VAR_QUEUE_LEN_BYTES] = 64 * 1024,
> +			[NEIGH_VAR_PROXY_QLEN] = 64,
> +			[NEIGH_VAR_ANYCAST_DELAY] = 1 * HZ,
> +			[NEIGH_VAR_PROXY_DELAY]	= (8 * HZ) / 10,
> +			[NEIGH_VAR_LOCKTIME] = 1 * HZ,
> +		},
> +	},
> +	.gc_interval	= 30 * HZ,
> +	.gc_thresh1	= 128,
> +	.gc_thresh2	= 512,
> +	.gc_thresh3	= 1024,
> +};
>  
>  static int __net_init arp_net_init(struct net *net)
>  {
> -	if (!proc_create("arp", S_IRUGO, net->proc_net, &arp_seq_fops))
> +	int err;
> +
> +	net->ipv4.arp_tbl = kmemdup(&dft_arp_tbl,
> +				    sizeof(dft_arp_tbl), GFP_KERNEL);
> +	if (!net->ipv4.arp_tbl)
>  		return -ENOMEM;
> +
> +	net->ipv4.arp_tbl->parms.tbl = net->ipv4.arp_tbl;
> +	neigh_table_init(net, net->ipv4.arp_tbl);
> +#ifdef CONFIG_SYSCTL
> +	err = neigh_sysctl_register(NULL, &net->ipv4.arp_tbl->parms, NULL);
> +	if (err) {
> +		kfree(net->ipv4.arp_tbl);
> +		return err;
> +	}
> +#endif
> +
> +#ifdef CONFIG_PROC_FS
> +	if (!proc_create("arp", S_IRUGO, net->proc_net, &arp_seq_fops))
> +		goto unregister;
> +#endif
>  	return 0;
> +
> +unregister:
> +#ifdef CONFIG_SYSCTL
> +	neigh_sysctl_unregister(&net->ipv4.arp_tbl->parms);
> +#endif
> +	kfree(net->ipv4.arp_tbl);
> +	return -ENOMEM;
>  }
>  
>  static void __net_exit arp_net_exit(struct net *net)
>  {
> +#ifdef CONFIG_PROC_FS
>  	remove_proc_entry("arp", net->proc_net);
> +#endif
> +#ifdef CONFIG_SYSCTL
> +	neigh_sysctl_unregister(&net->ipv4.arp_tbl->parms);
> +#endif
> +	neigh_table_clear(net->ipv4.arp_tbl);
> +	kfree(net->ipv4.arp_tbl);
>  }
>  
>  static struct pernet_operations arp_net_ops = {
> @@ -1452,12 +1485,3 @@ static int __init arp_proc_init(void)
>  {
>  	return register_pernet_subsys(&arp_net_ops);
>  }
> -
> -#else /* CONFIG_PROC_FS */
> -
> -static int __init arp_proc_init(void)
> -{
> -	return 0;
> -}
> -
> -#endif /* CONFIG_PROC_FS */
> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
> index e944937..36bbb5a3 100644
> --- a/net/ipv4/devinet.c
> +++ b/net/ipv4/devinet.c
> @@ -232,6 +232,7 @@ EXPORT_SYMBOL(in_dev_finish_destroy);
>  static struct in_device *inetdev_init(struct net_device *dev)
>  {
>  	struct in_device *in_dev;
> +	struct net *net = dev_net(dev);
>  
>  	ASSERT_RTNL();
>  
> @@ -242,7 +243,7 @@ static struct in_device *inetdev_init(struct net_device *dev)
>  			sizeof(in_dev->cnf));
>  	in_dev->cnf.sysctl = NULL;
>  	in_dev->dev = dev;
> -	in_dev->arp_parms = neigh_parms_alloc(dev, &arp_tbl);
> +	in_dev->arp_parms = neigh_parms_alloc(dev, net->ipv4.arp_tbl);
>  	if (!in_dev->arp_parms)
>  		goto out_kfree;
>  	if (IPV4_DEVCONF(in_dev->cnf, FORWARDING))
> @@ -277,10 +278,12 @@ static void inetdev_destroy(struct in_device *in_dev)
>  {
>  	struct in_ifaddr *ifa;
>  	struct net_device *dev;
> +	struct net *net;
>  
>  	ASSERT_RTNL();
>  
>  	dev = in_dev->dev;
> +	net = dev_net(dev);
>  
>  	in_dev->dead = 1;
>  
> @@ -294,7 +297,7 @@ static void inetdev_destroy(struct in_device *in_dev)
>  	RCU_INIT_POINTER(dev->ip_ptr, NULL);
>  
>  	devinet_sysctl_unregister(in_dev);
> -	neigh_parms_release(&arp_tbl, in_dev->arp_parms);
> +	neigh_parms_release(net->ipv4.arp_tbl, in_dev->arp_parms);
>  	arp_ifdown(dev);
>  
>  	call_rcu(&in_dev->rcu_head, in_dev_rcu_put);
> diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
> index b10cd43a..c31996a 100644
> --- a/net/ipv4/fib_semantics.c
> +++ b/net/ipv4/fib_semantics.c
> @@ -432,8 +432,9 @@ static int fib_detect_death(struct fib_info *fi, int order,
>  {
>  	struct neighbour *n;
>  	int state = NUD_NONE;
> +	struct net *net = fi->fib_net;
>  
> -	n = neigh_lookup(&arp_tbl, &fi->fib_nh[0].nh_gw, fi->fib_dev);
> +	n = neigh_lookup(net->ipv4.arp_tbl, &fi->fib_nh[0].nh_gw, fi->fib_dev);
>  	if (n) {
>  		state = n->nud_state;
>  		neigh_release(n);
> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> index 8d3b6b0..193247e 100644
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -196,7 +196,7 @@ static inline int ip_finish_output2(struct sk_buff *skb)
>  	nexthop = (__force u32) rt_nexthop(rt, ip_hdr(skb)->daddr);
>  	neigh = __ipv4_neigh_lookup_noref(dev, nexthop);
>  	if (unlikely(!neigh))
> -		neigh = __neigh_create(&arp_tbl, &nexthop, dev, false);
> +		neigh = __neigh_create(dev_net(dev)->ipv4.arp_tbl, &nexthop, dev, false);
>  	if (!IS_ERR(neigh)) {
>  		int res = dst_neigh_output(dst, neigh, skb);
>  
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 082239f..3f44ad2 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -454,7 +454,7 @@ static struct neighbour *ipv4_neigh_lookup(const struct dst_entry *dst,
>  	n = __ipv4_neigh_lookup(dev, *(__force u32 *)pkey);
>  	if (n)
>  		return n;
> -	return neigh_create(&arp_tbl, pkey, dev);
> +	return neigh_create(dev_net(dev)->ipv4.arp_tbl, pkey, dev);
>  }
>  
>  atomic_t *ip_idents __read_mostly;
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 5667b30..cbe6019 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -308,6 +308,8 @@ err_ip:
>  static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
>  {
>  	struct inet6_dev *ndev;
> +	struct net *net = dev_net(dev);
> +	struct neigh_table *tbl = net->ipv6.nd_tbl;
>  
>  	ASSERT_RTNL();
>  
> @@ -327,7 +329,7 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
>  	memcpy(&ndev->cnf, dev_net(dev)->ipv6.devconf_dflt, sizeof(ndev->cnf));
>  	ndev->cnf.mtu6 = dev->mtu;
>  	ndev->cnf.sysctl = NULL;
> -	ndev->nd_parms = neigh_parms_alloc(dev, &nd_tbl);
> +	ndev->nd_parms = neigh_parms_alloc(dev, tbl);
>  	if (ndev->nd_parms == NULL) {
>  		kfree(ndev);
>  		return NULL;
> @@ -341,7 +343,7 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
>  		ADBG(KERN_WARNING
>  			"%s: cannot allocate memory for statistics; dev=%s.\n",
>  			__func__, dev->name);
> -		neigh_parms_release(&nd_tbl, ndev->nd_parms);
> +		neigh_parms_release(tbl, ndev->nd_parms);
>  		dev_put(dev);
>  		kfree(ndev);
>  		return NULL;
> @@ -351,7 +353,7 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
>  		ADBG(KERN_WARNING
>  			"%s: cannot create /proc/net/dev_snmp6/%s\n",
>  			__func__, dev->name);
> -		neigh_parms_release(&nd_tbl, ndev->nd_parms);
> +		neigh_parms_release(tbl, ndev->nd_parms);
>  		ndev->dead = 1;
>  		in6_dev_finish_destroy(ndev);
>  		return NULL;
> @@ -2984,6 +2986,7 @@ static void addrconf_type_change(struct net_device *dev, unsigned long event)
>  static int addrconf_ifdown(struct net_device *dev, int how)
>  {
>  	struct net *net = dev_net(dev);
> +	struct neigh_table *tbl = net->ipv6.nd_tbl;
>  	struct inet6_dev *idev;
>  	struct inet6_ifaddr *ifa;
>  	int state, i;
> @@ -2991,7 +2994,7 @@ static int addrconf_ifdown(struct net_device *dev, int how)
>  	ASSERT_RTNL();
>  
>  	rt6_ifdown(net, dev);
> -	neigh_ifdown(&nd_tbl, dev);
> +	neigh_ifdown(tbl, dev);
>  
>  	idev = __in6_dev_get(dev);
>  	if (idev == NULL)
> @@ -3092,8 +3095,8 @@ static int addrconf_ifdown(struct net_device *dev, int how)
>  	/* Last: Shot the device (if unregistered) */
>  	if (how) {
>  		addrconf_sysctl_unregister(idev);
> -		neigh_parms_release(&nd_tbl, idev->nd_parms);
> -		neigh_ifdown(&nd_tbl, dev);
> +		neigh_parms_release(tbl, idev->nd_parms);
> +		neigh_ifdown(tbl, dev);
>  		in6_dev_put(idev);
>  	}
>  	return 0;
> diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
> index 7cb4392..92382a7 100644
> --- a/net/ipv6/af_inet6.c
> +++ b/net/ipv6/af_inet6.c
> @@ -815,7 +815,6 @@ static const struct ipv6_stub ipv6_stub_impl = {
>  	.ipv6_dst_lookup = ip6_dst_lookup,
>  	.udpv6_encap_enable = udpv6_encap_enable,
>  	.ndisc_send_na = ndisc_send_na,
> -	.nd_tbl	= &nd_tbl,
>  };
>  
>  static int __init inet6_init(void)
> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index cb9df0e..56741b0 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -60,6 +60,7 @@ static int ip6_finish_output2(struct sk_buff *skb)
>  {
>  	struct dst_entry *dst = skb_dst(skb);
>  	struct net_device *dev = dst->dev;
> +	struct net *net = dev_net(dev);
>  	struct neighbour *neigh;
>  	struct in6_addr *nexthop;
>  	int ret;
> @@ -108,7 +109,7 @@ static int ip6_finish_output2(struct sk_buff *skb)
>  	nexthop = rt6_nexthop((struct rt6_info *)dst);
>  	neigh = __ipv6_neigh_lookup_noref(dst->dev, nexthop);
>  	if (unlikely(!neigh))
> -		neigh = __neigh_create(&nd_tbl, nexthop, dst->dev, false);
> +		neigh = __neigh_create(net->ipv6.nd_tbl, nexthop, dst->dev, false);
>  	if (!IS_ERR(neigh)) {
>  		ret = dst_neigh_output(dst, neigh, skb);
>  		rcu_read_unlock_bh();
> @@ -419,7 +420,7 @@ int ip6_forward(struct sk_buff *skb)
>  
>  	/* XXX: idev->cnf.proxy_ndp? */
>  	if (net->ipv6.devconf_all->proxy_ndp &&
> -	    pneigh_lookup(&nd_tbl, net, &hdr->daddr, skb->dev, 0)) {
> +	    pneigh_lookup(net->ipv6.nd_tbl, net, &hdr->daddr, skb->dev, 0)) {
>  		int proxied = ip6_forward_proxy_check(skb);
>  		if (proxied > 0)
>  			return ip6_input(skb);
> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
> index ca8d4ea..ca8f1ce 100644
> --- a/net/ipv6/ndisc.c
> +++ b/net/ipv6/ndisc.c
> @@ -114,37 +114,6 @@ static const struct neigh_ops ndisc_direct_ops = {
>  	.connected_output =	neigh_direct_output,
>  };
>  
> -struct neigh_table nd_tbl = {
> -	.family =	AF_INET6,
> -	.key_len =	sizeof(struct in6_addr),
> -	.hash =		ndisc_hash,
> -	.constructor =	ndisc_constructor,
> -	.pconstructor =	pndisc_constructor,
> -	.pdestructor =	pndisc_destructor,
> -	.proxy_redo =	pndisc_redo,
> -	.id =		"ndisc_cache",
> -	.parms = {
> -		.tbl			= &nd_tbl,
> -		.reachable_time		= ND_REACHABLE_TIME,
> -		.data = {
> -			[NEIGH_VAR_MCAST_PROBES] = 3,
> -			[NEIGH_VAR_UCAST_PROBES] = 3,
> -			[NEIGH_VAR_RETRANS_TIME] = ND_RETRANS_TIMER,
> -			[NEIGH_VAR_BASE_REACHABLE_TIME] = ND_REACHABLE_TIME,
> -			[NEIGH_VAR_DELAY_PROBE_TIME] = 5 * HZ,
> -			[NEIGH_VAR_GC_STALETIME] = 60 * HZ,
> -			[NEIGH_VAR_QUEUE_LEN_BYTES] = 64 * 1024,
> -			[NEIGH_VAR_PROXY_QLEN] = 64,
> -			[NEIGH_VAR_ANYCAST_DELAY] = 1 * HZ,
> -			[NEIGH_VAR_PROXY_DELAY] = (8 * HZ) / 10,
> -		},
> -	},
> -	.gc_interval =	  30 * HZ,
> -	.gc_thresh1 =	 128,
> -	.gc_thresh2 =	 512,
> -	.gc_thresh3 =	1024,
> -};
> -
>  static void ndisc_fill_addr_option(struct sk_buff *skb, int type, void *data)
>  {
>  	int pad   = ndisc_addr_option_pad(skb->dev->type);
> @@ -676,14 +645,16 @@ static void ndisc_solicit(struct neighbour *neigh, struct sk_buff *skb)
>  static int pndisc_is_router(const void *pkey,
>  			    struct net_device *dev)
>  {
> +	struct net *net = dev_net(dev);
> +	struct neigh_table *tbl = net->ipv6.nd_tbl;
>  	struct pneigh_entry *n;
>  	int ret = -1;
>  
> -	read_lock_bh(&nd_tbl.lock);
> -	n = __pneigh_lookup(&nd_tbl, dev_net(dev), pkey, dev);
> +	read_lock_bh(&tbl->lock);
> +	n = __pneigh_lookup(tbl, dev_net(dev), pkey, dev);
>  	if (n)
>  		ret = !!(n->flags & NTF_ROUTER);
> -	read_unlock_bh(&nd_tbl.lock);
> +	read_unlock_bh(&tbl->lock);
>  
>  	return ret;
>  }
> @@ -698,6 +669,8 @@ static void ndisc_recv_ns(struct sk_buff *skb)
>  				    offsetof(struct nd_msg, opt));
>  	struct ndisc_options ndopts;
>  	struct net_device *dev = skb->dev;
> +	struct net *net = dev_net(dev);
> +	struct neigh_table *tbl = net->ipv6.nd_tbl;
>  	struct inet6_ifaddr *ifp;
>  	struct inet6_dev *idev = NULL;
>  	struct neighbour *neigh;
> @@ -802,7 +775,7 @@ static void ndisc_recv_ns(struct sk_buff *skb)
>  				 */
>  				struct sk_buff *n = skb_clone(skb, GFP_ATOMIC);
>  				if (n)
> -					pneigh_enqueue(&nd_tbl, idev->nd_parms, n);
> +					pneigh_enqueue(tbl, idev->nd_parms, n);
>  				goto out;
>  			}
>  		} else
> @@ -819,15 +792,15 @@ static void ndisc_recv_ns(struct sk_buff *skb)
>  	}
>  
>  	if (inc)
> -		NEIGH_CACHE_STAT_INC(&nd_tbl, rcv_probes_mcast);
> +		NEIGH_CACHE_STAT_INC(tbl, rcv_probes_mcast);
>  	else
> -		NEIGH_CACHE_STAT_INC(&nd_tbl, rcv_probes_ucast);
> +		NEIGH_CACHE_STAT_INC(tbl, rcv_probes_ucast);
>  
>  	/*
>  	 *	update / create cache entry
>  	 *	for the source address
>  	 */
> -	neigh = __neigh_lookup(&nd_tbl, saddr, dev,
> +	neigh = __neigh_lookup(tbl, saddr, dev,
>  			       !inc || lladdr || !dev->addr_len);
>  	if (neigh)
>  		neigh_update(neigh, lladdr, NUD_STALE,
> @@ -858,6 +831,8 @@ static void ndisc_recv_na(struct sk_buff *skb)
>  				    offsetof(struct nd_msg, opt));
>  	struct ndisc_options ndopts;
>  	struct net_device *dev = skb->dev;
> +	struct net *net = dev_net(dev);
> +	struct neigh_table *tbl = net->ipv6.nd_tbl;
>  	struct inet6_ifaddr *ifp;
>  	struct neighbour *neigh;
>  
> @@ -912,7 +887,7 @@ static void ndisc_recv_na(struct sk_buff *skb)
>  		in6_ifa_put(ifp);
>  		return;
>  	}
> -	neigh = neigh_lookup(&nd_tbl, &msg->target, dev);
> +	neigh = neigh_lookup(tbl, &msg->target, dev);
>  
>  	if (neigh) {
>  		u8 old_flags = neigh->flags;
> @@ -928,7 +903,7 @@ static void ndisc_recv_na(struct sk_buff *skb)
>  		 */
>  		if (lladdr && !memcmp(lladdr, dev->dev_addr, dev->addr_len) &&
>  		    net->ipv6.devconf_all->forwarding && net->ipv6.devconf_all->proxy_ndp &&
> -		    pneigh_lookup(&nd_tbl, net, &msg->target, dev, 0)) {
> +		    pneigh_lookup(tbl, net, &msg->target, dev, 0)) {
>  			/* XXX: idev->cnf.proxy_ndp */
>  			goto out;
>  		}
> @@ -961,6 +936,8 @@ static void ndisc_recv_rs(struct sk_buff *skb)
>  	const struct in6_addr *saddr = &ipv6_hdr(skb)->saddr;
>  	struct ndisc_options ndopts;
>  	u8 *lladdr = NULL;
> +	struct net *net = dev_net(skb->dev);
> +	struct neigh_table *tbl = net->ipv6.nd_tbl;
>  
>  	if (skb->len < sizeof(*rs_msg))
>  		return;
> @@ -995,7 +972,7 @@ static void ndisc_recv_rs(struct sk_buff *skb)
>  			goto out;
>  	}
>  
> -	neigh = __neigh_lookup(&nd_tbl, saddr, skb->dev, 1);
> +	neigh = __neigh_lookup(tbl, saddr, skb->dev, 1);
>  	if (neigh) {
>  		neigh_update(neigh, lladdr, NUD_STALE,
>  			     NEIGH_UPDATE_F_WEAK_OVERRIDE|
> @@ -1064,6 +1041,8 @@ static void ndisc_router_discovery(struct sk_buff *skb)
>  	struct ndisc_options ndopts;
>  	int optlen;
>  	unsigned int pref = 0;
> +	struct net *net = dev_net(skb->dev);
> +	struct neigh_table *tbl = net->ipv6.nd_tbl;
>  
>  	__u8 * opt = (__u8 *)(ra_msg + 1);
>  
> @@ -1240,7 +1219,7 @@ skip_linkparms:
>  	 */
>  
>  	if (!neigh)
> -		neigh = __neigh_lookup(&nd_tbl, &ipv6_hdr(skb)->saddr,
> +		neigh = __neigh_lookup(tbl, &ipv6_hdr(skb)->saddr,
>  				       skb->dev, 1);
>  	if (neigh) {
>  		u8 *lladdr = NULL;
> @@ -1594,11 +1573,12 @@ static int ndisc_netdev_event(struct notifier_block *this, unsigned long event,
>  {
>  	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
>  	struct net *net = dev_net(dev);
> +	struct neigh_table *tbl = net->ipv6.nd_tbl;
>  	struct inet6_dev *idev;
>  
>  	switch (event) {
>  	case NETDEV_CHANGEADDR:
> -		neigh_changeaddr(&nd_tbl, dev);
> +		neigh_changeaddr(tbl, dev);
>  		fib6_run_gc(0, net, false);
>  		idev = in6_dev_get(dev);
>  		if (!idev)
> @@ -1608,7 +1588,7 @@ static int ndisc_netdev_event(struct notifier_block *this, unsigned long event,
>  		in6_dev_put(idev);
>  		break;
>  	case NETDEV_DOWN:
> -		neigh_ifdown(&nd_tbl, dev);
> +		neigh_ifdown(tbl, dev);
>  		fib6_run_gc(0, net, false);
>  		break;
>  	case NETDEV_NOTIFY_PEERS:
> @@ -1679,15 +1659,62 @@ int ndisc_ifinfo_sysctl_change(struct ctl_table *ctl, int write, void __user *bu
>  
>  #endif
>  
> +static struct neigh_table dft_nd_tbl = {
> +	.family =	AF_INET6,
> +	.key_len =	sizeof(struct in6_addr),
> +	.hash =		ndisc_hash,
> +	.constructor =	ndisc_constructor,
> +	.pconstructor =	pndisc_constructor,
> +	.pdestructor =	pndisc_destructor,
> +	.proxy_redo =	pndisc_redo,
> +	.id =		"ndisc_cache",
> +	.parms = {
> +		.tbl			= &dft_nd_tbl,
> +		.reachable_time		= ND_REACHABLE_TIME,
> +		.data = {
> +			[NEIGH_VAR_MCAST_PROBES] = 3,
> +			[NEIGH_VAR_UCAST_PROBES] = 3,
> +			[NEIGH_VAR_RETRANS_TIME] = ND_RETRANS_TIMER,
> +			[NEIGH_VAR_BASE_REACHABLE_TIME] = ND_REACHABLE_TIME,
> +			[NEIGH_VAR_DELAY_PROBE_TIME] = 5 * HZ,
> +			[NEIGH_VAR_GC_STALETIME] = 60 * HZ,
> +			[NEIGH_VAR_QUEUE_LEN_BYTES] = 64 * 1024,
> +			[NEIGH_VAR_PROXY_QLEN] = 64,
> +			[NEIGH_VAR_ANYCAST_DELAY] = 1 * HZ,
> +			[NEIGH_VAR_PROXY_DELAY] = (8 * HZ) / 10,
> +		},
> +	},
> +	.gc_interval =	  30 * HZ,
> +	.gc_thresh1 =	 128,
> +	.gc_thresh2 =	 512,
> +	.gc_thresh3 =	1024,
> +};
> +
>  static int __net_init ndisc_net_init(struct net *net)
>  {
>  	struct ipv6_pinfo *np;
>  	struct sock *sk;
>  	int err;
>  
> +	net->ipv6.nd_tbl = kmemdup(&dft_nd_tbl, sizeof(dft_nd_tbl), GFP_KERNEL);
> +	if (!net->ipv6.nd_tbl)
> +		return -ENOMEM;
> +
> +	net->ipv6.nd_tbl->parms.tbl = net->ipv6.nd_tbl;
> +	neigh_table_init(net, net->ipv6.nd_tbl);
> +#ifdef CONFIG_SYSCTL
> +	err = neigh_sysctl_register(NULL, &net->ipv6.nd_tbl->parms,
> +				    &ndisc_ifinfo_sysctl_change);
> +	if (err) {
> +		kfree(net->ipv6.nd_tbl);
> +		return err;
> +	}
> +#endif
> +
>  	err = inet_ctl_sock_create(&sk, PF_INET6,
>  				   SOCK_RAW, IPPROTO_ICMPV6, net);
>  	if (err < 0) {
> +		kfree(net->ipv6.nd_tbl);
>  		ND_PRINTK(0, err,
>  			  "NDISC: Failed to initialize the control socket (err %d)\n",
>  			  err);
> @@ -1707,6 +1734,11 @@ static int __net_init ndisc_net_init(struct net *net)
>  static void __net_exit ndisc_net_exit(struct net *net)
>  {
>  	inet_ctl_sock_destroy(net->ipv6.ndisc_sk);
> +#ifdef CONFIG_SYSCTL
> +	neigh_sysctl_unregister(&net->ipv6.nd_tbl->parms);
> +#endif
> +	neigh_table_clear(net->ipv6.nd_tbl);
> +	kfree(net->ipv6.nd_tbl);
>  }
>  
>  static struct pernet_operations ndisc_net_ops = {
> @@ -1716,30 +1748,7 @@ static struct pernet_operations ndisc_net_ops = {
>  
>  int __init ndisc_init(void)
>  {
> -	int err;
> -
> -	err = register_pernet_subsys(&ndisc_net_ops);
> -	if (err)
> -		return err;
> -	/*
> -	 * Initialize the neighbour table
> -	 */
> -	neigh_table_init(&nd_tbl);
> -
> -#ifdef CONFIG_SYSCTL
> -	err = neigh_sysctl_register(NULL, &nd_tbl.parms,
> -				    &ndisc_ifinfo_sysctl_change);
> -	if (err)
> -		goto out_unregister_pernet;
> -out:
> -#endif
> -	return err;
> -
> -#ifdef CONFIG_SYSCTL
> -out_unregister_pernet:
> -	unregister_pernet_subsys(&ndisc_net_ops);
> -	goto out;
> -#endif
> +	return register_pernet_subsys(&ndisc_net_ops);
>  }
>  
>  int __init ndisc_late_init(void)
> @@ -1754,9 +1763,5 @@ void ndisc_late_cleanup(void)
>  
>  void ndisc_cleanup(void)
>  {
> -#ifdef CONFIG_SYSCTL
> -	neigh_sysctl_unregister(&nd_tbl.parms);
> -#endif
> -	neigh_table_clear(&nd_tbl);
>  	unregister_pernet_subsys(&ndisc_net_ops);
>  }
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index f23fbd2..21731b3 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -183,13 +183,14 @@ static struct neighbour *ip6_neigh_lookup(const struct dst_entry *dst,
>  					  const void *daddr)
>  {
>  	struct rt6_info *rt = (struct rt6_info *) dst;
> +	struct net *net = dev_net(dst->dev);
>  	struct neighbour *n;
>  
>  	daddr = choose_neigh_daddr(rt, skb, daddr);
>  	n = __ipv6_neigh_lookup(dst->dev, daddr);
>  	if (n)
>  		return n;
> -	return neigh_create(&nd_tbl, daddr, dst->dev);
> +	return neigh_create(net->ipv6.nd_tbl, daddr, dst->dev);
>  }
>  
>  static struct dst_ops ip6_dst_ops_template = {
> @@ -1825,7 +1826,7 @@ static void rt6_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_bu
>  	 */
>  	dst_confirm(&rt->dst);
>  
> -	neigh = __neigh_lookup(&nd_tbl, &msg->target, skb->dev, 1);
> +	neigh = __neigh_lookup(net->ipv6.nd_tbl, &msg->target, skb->dev, 1);
>  	if (!neigh)
>  		return;
