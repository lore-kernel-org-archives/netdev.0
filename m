From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 6/13] bridge: Add core IGMP snooping support
Date: Fri, 5 Mar 2010 15:43:27 -0800
Message-ID: <20100305234327.GJ6764@linux.vnet.ibm.com>
References: <20100228054012.GA7583@gondor.apana.org.au> <E1NlbuT-00021C-0b@gondolin.me.apana.org.au>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:36796 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755424Ab0CEXn3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Mar 2010 18:43:29 -0500
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e7.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o25NZVox008730
	for <netdev@vger.kernel.org>; Fri, 5 Mar 2010 18:35:31 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o25NhRak143748
	for <netdev@vger.kernel.org>; Fri, 5 Mar 2010 18:43:27 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o25NhRj5026232
	for <netdev@vger.kernel.org>; Fri, 5 Mar 2010 18:43:27 -0500
Content-Disposition: inline
In-Reply-To: <E1NlbuT-00021C-0b@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 28, 2010 at 01:41:45PM +0800, Herbert Xu wrote:
> bridge: Add core IGMP snooping support
> 
> This patch adds the core functionality of IGMP snooping support
> without actually hooking it up.  So this patch should be a no-op
> as far as the bridge's external behaviour is concerned.
> 
> All the new code and data is controlled by the Kconfig option
> BRIDGE_IGMP_SNOOPING.  A run-time toggle is also available.
> 
> The multicast switching is done using an hash table that is
> lockless on the read-side through RCU.  On the write-side the
> new multicast_lock is used for all operations.  The hash table
> supports dynamic growth/rehashing.

Cool!!!  You use a pair of list_head structures, so that a given
element can be in both the old and the new hash table simultaneously.
Of course, an RCU grace period must elapse between consecutive resizings.
Which appears to be addressed.

The teardown needs an rcu_barrier_bh() rather than the current
synchronize_rcu_bh(), please see below.

Also, I don't see how the teardown code is preventing new readers from
finding the data structures before they are being passed to call_rcu_bh().
You can't safely start the RCU grace period until -after- all new readers
have been excluded.  (But I could easily be missing something here.)

The br_multicast_del_pg() looks to need rcu_read_lock_bh() and
rcu_read_unlock_bh() around its loop, if I understand the pointer-walking
scheme correctly.

It looks like all updates are protected by an appropriate lock, although
I don't claim to fully understand how the data structures are linked
together.  The key requirement is of course that you normally don't
get to protect insertion and deletion of a given data structure using a
lock located within that same data structure.  It looks to me that this
requirement is satisfied -- all the lists that you manipulate seem to
hang off of the net_bridge, which contains the lock protecting all of
those lists.

Hmmm...  Where is the read-side code?  Wherever it is, it cannot safely
dereference the ->old pointer.

> The hash table will be rehashed if any chain length exceeds a
> preset limit.  If rehashing does not reduce the maximum chain
> length then snooping will be disabled.
> 
> These features may be added in future (in no particular order):
> 
> * IGMPv3 source support
> * Non-querier router detection
> * IPv6

But the bugs all look fixable to me (assuming that they are in fact
bugs).  Very cool to see an RCU-protected resizeable hash table!!!  ;-)

						Thanx, Paul

> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> ---
> 
>  net/bridge/Kconfig        |   12 
>  net/bridge/Makefile       |    2 
>  net/bridge/br_multicast.c | 1135 ++++++++++++++++++++++++++++++++++++++++++++++
>  net/bridge/br_private.h   |  139 +++++
>  4 files changed, 1288 insertions(+)
> 
> diff --git a/net/bridge/Kconfig b/net/bridge/Kconfig
> index e143ca6..78dd549 100644
> --- a/net/bridge/Kconfig
> +++ b/net/bridge/Kconfig
> @@ -31,3 +31,15 @@ config BRIDGE
>  	  will be called bridge.
> 
>  	  If unsure, say N.
> +
> +config BRIDGE_IGMP_SNOOPING
> +	bool "IGMP snooping"
> +	default y
> +	---help---
> +	  If you say Y here, then the Ethernet bridge will be able selectively
> +	  forward multicast traffic based on IGMP traffic received from each
> +	  port.
> +
> +	  Say N to exclude this support and reduce the binary size.
> +
> +	  If unsure, say Y.
> diff --git a/net/bridge/Makefile b/net/bridge/Makefile
> index f444c12..d0359ea 100644
> --- a/net/bridge/Makefile
> +++ b/net/bridge/Makefile
> @@ -12,4 +12,6 @@ bridge-$(CONFIG_SYSFS) += br_sysfs_if.o br_sysfs_br.o
> 
>  bridge-$(CONFIG_BRIDGE_NETFILTER) += br_netfilter.o
> 
> +bridge-$(CONFIG_BRIDGE_IGMP_SNOOPING) += br_multicast.o
> +
>  obj-$(CONFIG_BRIDGE_NF_EBTABLES) += netfilter/
> diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
> new file mode 100644
> index 0000000..746b5a6
> --- /dev/null
> +++ b/net/bridge/br_multicast.c
> @@ -0,0 +1,1135 @@
> +/*
> + * Bridge multicast support.
> + *
> + * Copyright (c) 2010 Herbert Xu <herbert@gondor.apana.org.au>
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms of the GNU General Public License as published by the Free
> + * Software Foundation; either version 2 of the License, or (at your option)
> + * any later version.
> + *
> + */
> +
> +#include <linux/err.h>
> +#include <linux/if_ether.h>
> +#include <linux/igmp.h>
> +#include <linux/jhash.h>
> +#include <linux/kernel.h>
> +#include <linux/netdevice.h>
> +#include <linux/netfilter_bridge.h>
> +#include <linux/random.h>
> +#include <linux/rculist.h>
> +#include <linux/skbuff.h>
> +#include <linux/slab.h>
> +#include <linux/timer.h>
> +#include <net/ip.h>
> +
> +#include "br_private.h"
> +
> +static inline int br_ip_hash(struct net_bridge_mdb_htable *mdb, __be32 ip)
> +{
> +	return jhash_1word(mdb->secret, (u32)ip) & (mdb->max - 1);
> +}
> +
> +static struct net_bridge_mdb_entry *__br_mdb_ip_get(
> +	struct net_bridge_mdb_htable *mdb, __be32 dst, int hash)
> +{
> +	struct net_bridge_mdb_entry *mp;
> +	struct hlist_node *p;
> +
> +	hlist_for_each_entry(mp, p, &mdb->mhash[hash], hlist[mdb->ver]) {
> +		if (dst == mp->addr)
> +			return mp;
> +	}
> +
> +	return NULL;
> +}
> +
> +static struct net_bridge_mdb_entry *br_mdb_ip_get(
> +	struct net_bridge_mdb_htable *mdb, __be32 dst)
> +{
> +	return __br_mdb_ip_get(mdb, dst, br_ip_hash(mdb, dst));
> +}
> +
> +struct net_bridge_mdb_entry *br_mdb_get(struct net_bridge *br,
> +					struct sk_buff *skb)
> +{
> +	struct net_bridge_mdb_htable *mdb = br->mdb;
> +
> +	if (!mdb || br->multicast_disabled)
> +		return NULL;
> +
> +	switch (skb->protocol) {
> +	case htons(ETH_P_IP):
> +		if (BR_INPUT_SKB_CB(skb)->igmp)
> +			break;
> +		return br_mdb_ip_get(mdb, ip_hdr(skb)->daddr);
> +	}
> +
> +	return NULL;
> +}
> +
> +static void br_mdb_free(struct rcu_head *head)
> +{
> +	struct net_bridge_mdb_htable *mdb =
> +		container_of(head, struct net_bridge_mdb_htable, rcu);
> +	struct net_bridge_mdb_htable *old = mdb->old;
> +
> +	mdb->old = NULL;

So one way to figure out when it is safe to do another resize is when
the ->old pointer is NULLed out here.

> +	kfree(old->mhash);
> +	kfree(old);
> +}
> +
> +static int br_mdb_copy(struct net_bridge_mdb_htable *new,
> +		       struct net_bridge_mdb_htable *old,
> +		       int elasticity)
> +{
> +	struct net_bridge_mdb_entry *mp;
> +	struct hlist_node *p;
> +	int maxlen;
> +	int len;
> +	int i;
> +
> +	for (i = 0; i < old->max; i++)
> +		hlist_for_each_entry(mp, p, &old->mhash[i], hlist[old->ver])
> +			hlist_add_head(&mp->hlist[new->ver],
> +				       &new->mhash[br_ip_hash(new, mp->addr)]);
> +
> +	if (!elasticity)
> +		return 0;
> +
> +	maxlen = 0;
> +	for (i = 0; i < new->max; i++) {
> +		len = 0;
> +		hlist_for_each_entry(mp, p, &new->mhash[i], hlist[new->ver])
> +			len++;
> +		if (len > maxlen)
> +			maxlen = len;
> +	}
> +
> +	return maxlen > elasticity ? -EINVAL : 0;
> +}
> +
> +static void br_multicast_free_pg(struct rcu_head *head)
> +{
> +	struct net_bridge_port_group *p =
> +		container_of(head, struct net_bridge_port_group, rcu);
> +
> +	kfree(p);
> +}
> +
> +static void br_multicast_free_group(struct rcu_head *head)
> +{
> +	struct net_bridge_mdb_entry *mp =
> +		container_of(head, struct net_bridge_mdb_entry, rcu);
> +
> +	kfree(mp);
> +}
> +
> +static void br_multicast_group_expired(unsigned long data)
> +{
> +	struct net_bridge_mdb_entry *mp = (void *)data;
> +	struct net_bridge *br = mp->br;
> +	struct net_bridge_mdb_htable *mdb;
> +
> +	spin_lock(&br->multicast_lock);
> +	if (!netif_running(br->dev) || timer_pending(&mp->timer))
> +		goto out;
> +
> +	if (!hlist_unhashed(&mp->mglist))
> +		hlist_del_init(&mp->mglist);
> +
> +	if (mp->ports)
> +		goto out;
> +
> +	mdb = br->mdb;
> +	hlist_del_rcu(&mp->hlist[mdb->ver]);

Also protected by br->multicast_lock.

> +	mdb->size--;
> +
> +	del_timer(&mp->query_timer);
> +	call_rcu_bh(&mp->rcu, br_multicast_free_group);
> +
> +out:
> +	spin_unlock(&br->multicast_lock);
> +}
> +
> +static void br_multicast_del_pg(struct net_bridge *br,
> +				struct net_bridge_port_group *pg)
> +{
> +	struct net_bridge_mdb_htable *mdb = br->mdb;
> +	struct net_bridge_mdb_entry *mp;
> +	struct net_bridge_port_group *p;
> +	struct net_bridge_port_group **pp;
> +
> +	mp = br_mdb_ip_get(mdb, pg->addr);
> +	if (WARN_ON(!mp))
> +		return;
> +
> +	for (pp = &mp->ports; (p = *pp); pp = &p->next) {
> +		if (p != pg)
> +			continue;
> +
> +		*pp = p->next;

If I understand this code correctly, we are relying on the RCU-bh grace
period not completing until we process the next element.  But we don't
appear to be in an RCU-bh read-side critical section.

I believe that you need an rcu_read_lock_bh() and an rcu_read_unlock_bh()
around this loop or in all callers.  @@@

> +		hlist_del_init(&p->mglist);
> +		del_timer(&p->timer);
> +		del_timer(&p->query_timer);
> +		call_rcu_bh(&p->rcu, br_multicast_free_pg);
> +
> +		if (!mp->ports && hlist_unhashed(&mp->mglist) &&
> +		    netif_running(br->dev))
> +			mod_timer(&mp->timer, jiffies);
> +
> +		return;
> +	}
> +
> +	WARN_ON(1);
> +}
> +
> +static void br_multicast_port_group_expired(unsigned long data)
> +{
> +	struct net_bridge_port_group *pg = (void *)data;
> +	struct net_bridge *br = pg->port->br;
> +
> +	spin_lock(&br->multicast_lock);
> +	if (!netif_running(br->dev) || timer_pending(&pg->timer) ||
> +	    hlist_unhashed(&pg->mglist))
> +		goto out;
> +
> +	br_multicast_del_pg(br, pg);
> +
> +out:
> +	spin_unlock(&br->multicast_lock);
> +}
> +
> +static int br_mdb_rehash(struct net_bridge_mdb_htable **mdbp, int max,
> +			 int elasticity)
> +{
> +	struct net_bridge_mdb_htable *old = *mdbp;
> +	struct net_bridge_mdb_htable *mdb;
> +	int err;
> +
> +	mdb = kmalloc(sizeof(*mdb), GFP_ATOMIC);
> +	if (!mdb)
> +		return -ENOMEM;
> +
> +	mdb->max = max;
> +	mdb->old = old;

OK, so the current hash table points to the old one.

The way this is set up, it looks to be illegal for RCU readers to
traverse the ->old pointer, since it is NULLed after but one RCU
grace period.

> +	mdb->mhash = kzalloc(max * sizeof(*mdb->mhash), GFP_ATOMIC);
> +	if (!mdb->mhash) {
> +		kfree(mdb);
> +		return -ENOMEM;
> +	}
> +
> +	mdb->size = old ? old->size : 0;
> +	mdb->ver = old ? old->ver ^ 1 : 0;
> +
> +	if (!old || elasticity)
> +		get_random_bytes(&mdb->secret, sizeof(mdb->secret));
> +	else
> +		mdb->secret = old->secret;
> +
> +	if (!old)
> +		goto out;
> +
> +	err = br_mdb_copy(mdb, old, elasticity);
> +	if (err) {
> +		kfree(mdb->mhash);
> +		kfree(mdb);
> +		return err;
> +	}
> +
> +	call_rcu_bh(&mdb->rcu, br_mdb_free);

And we are using RCU-bh.  OK.

> +
> +out:
> +	rcu_assign_pointer(*mdbp, mdb);

Also protected by br->multicast_lock.

> +
> +	return 0;
> +}
> +
> +static struct sk_buff *br_multicast_alloc_query(struct net_bridge *br,
> +						__be32 group)
> +{
> +	struct sk_buff *skb;
> +	struct igmphdr *ih;
> +	struct ethhdr *eth;
> +	struct iphdr *iph;
> +
> +	skb = netdev_alloc_skb_ip_align(br->dev, sizeof(*eth) + sizeof(*iph) +
> +						 sizeof(*ih) + 4);
> +	if (!skb)
> +		goto out;
> +
> +	skb->protocol = htons(ETH_P_IP);
> +
> +	skb_reset_mac_header(skb);
> +	eth = eth_hdr(skb);
> +
> +	memcpy(eth->h_source, br->dev->dev_addr, 6);
> +	eth->h_dest[0] = 1;
> +	eth->h_dest[1] = 0;
> +	eth->h_dest[2] = 0x5e;
> +	eth->h_dest[3] = 0;
> +	eth->h_dest[4] = 0;
> +	eth->h_dest[5] = 1;
> +	eth->h_proto = htons(ETH_P_IP);
> +	skb_put(skb, sizeof(*eth));
> +
> +	skb_set_network_header(skb, skb->len);
> +	iph = ip_hdr(skb);
> +
> +	iph->version = 4;
> +	iph->ihl = 6;
> +	iph->tos = 0xc0;
> +	iph->tot_len = htons(sizeof(*iph) + sizeof(*ih) + 4);
> +	iph->id = 0;
> +	iph->frag_off = htons(IP_DF);
> +	iph->ttl = 1;
> +	iph->protocol = IPPROTO_IGMP;
> +	iph->saddr = 0;
> +	iph->daddr = htonl(INADDR_ALLHOSTS_GROUP);
> +	((u8 *)&iph[1])[0] = IPOPT_RA;
> +	((u8 *)&iph[1])[1] = 4;
> +	((u8 *)&iph[1])[2] = 0;
> +	((u8 *)&iph[1])[3] = 0;
> +	ip_send_check(iph);
> +	skb_put(skb, 24);
> +
> +	skb_set_transport_header(skb, skb->len);
> +	ih = igmp_hdr(skb);
> +	ih->type = IGMP_HOST_MEMBERSHIP_QUERY;
> +	ih->code = (group ? br->multicast_last_member_interval :
> +			    br->multicast_query_response_interval) /
> +		   (HZ / IGMP_TIMER_SCALE);
> +	ih->group = group;
> +	ih->csum = 0;
> +	ih->csum = ip_compute_csum((void *)ih, sizeof(struct igmphdr));
> +	skb_put(skb, sizeof(*ih));
> +
> +	__skb_pull(skb, sizeof(*eth));
> +
> +out:
> +	return skb;
> +}
> +
> +static void br_multicast_send_group_query(struct net_bridge_mdb_entry *mp)
> +{
> +	struct net_bridge *br = mp->br;
> +	struct sk_buff *skb;
> +
> +	skb = br_multicast_alloc_query(br, mp->addr);
> +	if (!skb)
> +		goto timer;
> +
> +	netif_rx(skb);
> +
> +timer:
> +	if (++mp->queries_sent < br->multicast_last_member_count)
> +		mod_timer(&mp->query_timer,
> +			  jiffies + br->multicast_last_member_interval);
> +}
> +
> +static void br_multicast_group_query_expired(unsigned long data)
> +{
> +	struct net_bridge_mdb_entry *mp = (void *)data;
> +	struct net_bridge *br = mp->br;
> +
> +	spin_lock(&br->multicast_lock);
> +	if (!netif_running(br->dev) || hlist_unhashed(&mp->mglist) ||
> +	    mp->queries_sent >= br->multicast_last_member_count)
> +		goto out;
> +
> +	br_multicast_send_group_query(mp);
> +
> +out:
> +	spin_unlock(&br->multicast_lock);
> +}
> +
> +static void br_multicast_send_port_group_query(struct net_bridge_port_group *pg)
> +{
> +	struct net_bridge_port *port = pg->port;
> +	struct net_bridge *br = port->br;
> +	struct sk_buff *skb;
> +
> +	skb = br_multicast_alloc_query(br, pg->addr);
> +	if (!skb)
> +		goto timer;
> +
> +	br_deliver(port, skb);
> +
> +timer:
> +	if (++pg->queries_sent < br->multicast_last_member_count)
> +		mod_timer(&pg->query_timer,
> +			  jiffies + br->multicast_last_member_interval);
> +}
> +
> +static void br_multicast_port_group_query_expired(unsigned long data)
> +{
> +	struct net_bridge_port_group *pg = (void *)data;
> +	struct net_bridge_port *port = pg->port;
> +	struct net_bridge *br = port->br;
> +
> +	spin_lock(&br->multicast_lock);
> +	if (!netif_running(br->dev) || hlist_unhashed(&pg->mglist) ||
> +	    pg->queries_sent >= br->multicast_last_member_count)
> +		goto out;
> +
> +	br_multicast_send_port_group_query(pg);
> +
> +out:
> +	spin_unlock(&br->multicast_lock);
> +}
> +
> +static struct net_bridge_mdb_entry *br_multicast_get_group(
> +	struct net_bridge *br, struct net_bridge_port *port, __be32 group,
> +	int hash)
> +{
> +	struct net_bridge_mdb_htable *mdb = br->mdb;
> +	struct net_bridge_mdb_entry *mp;
> +	struct hlist_node *p;
> +	unsigned count = 0;
> +	unsigned max;
> +	int elasticity;
> +	int err;
> +
> +	hlist_for_each_entry(mp, p, &mdb->mhash[hash], hlist[mdb->ver]) {
> +		count++;
> +		if (unlikely(group == mp->addr)) {
> +			return mp;
> +		}
> +	}
> +
> +	elasticity = 0;
> +	max = mdb->max;
> +
> +	if (unlikely(count > br->hash_elasticity && count)) {
> +		if (net_ratelimit())
> +			printk(KERN_INFO "%s: Multicast hash table "
> +			       "chain limit reached: %s\n",
> +			       br->dev->name, port ? port->dev->name :
> +						     br->dev->name);
> +
> +		elasticity = br->hash_elasticity;
> +	}
> +
> +	if (mdb->size >= max) {
> +		max *= 2;
> +		if (unlikely(max >= br->hash_max)) {
> +			printk(KERN_WARNING "%s: Multicast hash table maximum "
> +			       "reached, disabling snooping: %s, %d\n",
> +			       br->dev->name, port ? port->dev->name :
> +						     br->dev->name,
> +			       max);
> +			err = -E2BIG;
> +disable:
> +			br->multicast_disabled = 1;
> +			goto err;
> +		}
> +	}
> +
> +	if (max > mdb->max || elasticity) {
> +		if (mdb->old) {

And here is the ->old check, as required.

> +			if (net_ratelimit())
> +				printk(KERN_INFO "%s: Multicast hash table "
> +				       "on fire: %s\n",
> +				       br->dev->name, port ? port->dev->name :
> +							     br->dev->name);
> +			err = -EEXIST;
> +			goto err;
> +		}
> +
> +		err = br_mdb_rehash(&br->mdb, max, elasticity);
> +		if (err) {
> +			printk(KERN_WARNING "%s: Cannot rehash multicast "
> +			       "hash table, disabling snooping: "
> +			       "%s, %d, %d\n",
> +			       br->dev->name, port ? port->dev->name :
> +						     br->dev->name,
> +			       mdb->size, err);
> +			goto disable;
> +		}
> +
> +		err = -EAGAIN;
> +		goto err;
> +	}
> +
> +	return NULL;
> +
> +err:
> +	mp = ERR_PTR(err);
> +	return mp;
> +}
> +
> +static struct net_bridge_mdb_entry *br_multicast_new_group(
> +	struct net_bridge *br, struct net_bridge_port *port, __be32 group)
> +{
> +	struct net_bridge_mdb_htable *mdb = br->mdb;
> +	struct net_bridge_mdb_entry *mp;
> +	int hash;
> +
> +	if (!mdb) {
> +		if (br_mdb_rehash(&br->mdb, BR_HASH_SIZE, 0))
> +			return NULL;
> +		goto rehash;
> +	}
> +
> +	hash = br_ip_hash(mdb, group);
> +	mp = br_multicast_get_group(br, port, group, hash);
> +	switch (PTR_ERR(mp)) {
> +	case 0:
> +		break;
> +
> +	case -EAGAIN:
> +rehash:
> +		mdb = br->mdb;
> +		hash = br_ip_hash(mdb, group);
> +		break;
> +
> +	default:
> +		goto out;
> +	}
> +
> +	mp = kzalloc(sizeof(*mp), GFP_ATOMIC);
> +	if (unlikely(!mp))
> +		goto out;
> +
> +	mp->br = br;
> +	mp->addr = group;
> +	setup_timer(&mp->timer, br_multicast_group_expired,
> +		    (unsigned long)mp);
> +	setup_timer(&mp->query_timer, br_multicast_group_query_expired,
> +		    (unsigned long)mp);
> +
> +	hlist_add_head_rcu(&mp->hlist[mdb->ver], &mdb->mhash[hash]);

Protected by br->multicast_lock, so OK.

> +	mdb->size++;
> +
> +out:
> +	return mp;
> +}
> +
> +static int br_multicast_add_group(struct net_bridge *br,
> +				  struct net_bridge_port *port, __be32 group)
> +{
> +	struct net_bridge_mdb_entry *mp;
> +	struct net_bridge_port_group *p;
> +	struct net_bridge_port_group **pp;
> +	unsigned long now = jiffies;
> +	int err;
> +
> +	if (ipv4_is_local_multicast(group))
> +		return 0;
> +
> +	spin_lock(&br->multicast_lock);
> +	if (!netif_running(br->dev) ||
> +	    (port && port->state == BR_STATE_DISABLED))
> +		goto out;
> +
> +	mp = br_multicast_new_group(br, port, group);
> +	err = PTR_ERR(mp);
> +	if (unlikely(IS_ERR(mp) || !mp))
> +		goto err;
> +
> +	if (!port) {
> +		hlist_add_head(&mp->mglist, &br->mglist);
> +		mod_timer(&mp->timer, now + br->multicast_membership_interval);
> +		goto out;
> +	}
> +
> +	for (pp = &mp->ports; (p = *pp); pp = &p->next) {
> +		if (p->port == port)
> +			goto found;
> +		if ((unsigned long)p->port < (unsigned long)port)
> +			break;
> +	}
> +
> +	p = kzalloc(sizeof(*p), GFP_ATOMIC);
> +	err = -ENOMEM;
> +	if (unlikely(!p))
> +		goto err;
> +
> +	p->addr = group;
> +	p->port = port;
> +	p->next = *pp;
> +	hlist_add_head(&p->mglist, &port->mglist);
> +	setup_timer(&p->timer, br_multicast_port_group_expired,
> +		    (unsigned long)p);
> +	setup_timer(&p->query_timer, br_multicast_port_group_query_expired,
> +		    (unsigned long)p);
> +
> +	rcu_assign_pointer(*pp, p);

Also protected by br->multicast_lock.

> +
> +found:
> +	mod_timer(&p->timer, now + br->multicast_membership_interval);
> +out:
> +	err = 0;
> +
> +err:
> +	spin_unlock(&br->multicast_lock);
> +	return err;
> +}
> +
> +static void br_multicast_router_expired(unsigned long data)
> +{
> +	struct net_bridge_port *port = (void *)data;
> +	struct net_bridge *br = port->br;
> +
> +	spin_lock(&br->multicast_lock);
> +	if (port->multicast_router != 1 ||
> +	    timer_pending(&port->multicast_router_timer) ||
> +	    hlist_unhashed(&port->rlist))
> +		goto out;
> +
> +	hlist_del_init_rcu(&port->rlist);

Also protected by br->multicast_lock.

> +out:
> +	spin_unlock(&br->multicast_lock);
> +}
> +
> +static void br_multicast_local_router_expired(unsigned long data)
> +{
> +}
> +
> +static void br_multicast_send_query(struct net_bridge *br,
> +				    struct net_bridge_port *port, u32 sent)
> +{
> +	unsigned long time;
> +	struct sk_buff *skb;
> +
> +	if (!netif_running(br->dev) || br->multicast_disabled ||
> +	    timer_pending(&br->multicast_querier_timer))
> +		return;
> +
> +	skb = br_multicast_alloc_query(br, 0);
> +	if (!skb)
> +		goto timer;
> +
> +	if (port) {
> +		__skb_push(skb, sizeof(struct ethhdr));
> +		skb->dev = port->dev;
> +		NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_OUT, skb, NULL, skb->dev,
> +			dev_queue_xmit);
> +	} else
> +		netif_rx(skb);
> +
> +timer:
> +	time = jiffies;
> +	time += sent < br->multicast_startup_query_count ?
> +		br->multicast_startup_query_interval :
> +		br->multicast_query_interval;
> +	mod_timer(port ? &port->multicast_query_timer :
> +			 &br->multicast_query_timer, time);
> +}
> +
> +static void br_multicast_port_query_expired(unsigned long data)
> +{
> +	struct net_bridge_port *port = (void *)data;
> +	struct net_bridge *br = port->br;
> +
> +	spin_lock(&br->multicast_lock);
> +	if (port && (port->state == BR_STATE_DISABLED ||
> +		     port->state == BR_STATE_BLOCKING))
> +		goto out;
> +
> +	if (port->multicast_startup_queries_sent <
> +	    br->multicast_startup_query_count)
> +		port->multicast_startup_queries_sent++;
> +
> +	br_multicast_send_query(port->br, port,
> +				port->multicast_startup_queries_sent);
> +
> +out:
> +	spin_unlock(&br->multicast_lock);
> +}
> +
> +void br_multicast_add_port(struct net_bridge_port *port)
> +{
> +	port->multicast_router = 1;
> +
> +	setup_timer(&port->multicast_router_timer, br_multicast_router_expired,
> +		    (unsigned long)port);
> +	setup_timer(&port->multicast_query_timer,
> +		    br_multicast_port_query_expired, (unsigned long)port);
> +}
> +
> +void br_multicast_del_port(struct net_bridge_port *port)
> +{
> +	del_timer_sync(&port->multicast_router_timer);
> +}
> +
> +void br_multicast_enable_port(struct net_bridge_port *port)
> +{
> +	struct net_bridge *br = port->br;
> +
> +	spin_lock(&br->multicast_lock);
> +	if (br->multicast_disabled || !netif_running(br->dev))
> +		goto out;
> +
> +	port->multicast_startup_queries_sent = 0;
> +
> +	if (try_to_del_timer_sync(&port->multicast_query_timer) >= 0 ||
> +	    del_timer(&port->multicast_query_timer))
> +		mod_timer(&port->multicast_query_timer, jiffies);
> +
> +out:
> +	spin_unlock(&br->multicast_lock);
> +}
> +
> +void br_multicast_disable_port(struct net_bridge_port *port)
> +{
> +	struct net_bridge *br = port->br;
> +	struct net_bridge_port_group *pg;
> +	struct hlist_node *p, *n;
> +
> +	spin_lock(&br->multicast_lock);
> +	hlist_for_each_entry_safe(pg, p, n, &port->mglist, mglist)
> +		br_multicast_del_pg(br, pg);
> +
> +	if (!hlist_unhashed(&port->rlist))
> +		hlist_del_init_rcu(&port->rlist);

Also protected by br->multicast_lock.

> +	del_timer(&port->multicast_router_timer);
> +	del_timer(&port->multicast_query_timer);
> +	spin_unlock(&br->multicast_lock);
> +}
> +
> +static int br_multicast_igmp3_report(struct net_bridge *br,
> +				     struct net_bridge_port *port,
> +				     struct sk_buff *skb)
> +{
> +	struct igmpv3_report *ih;
> +	struct igmpv3_grec *grec;
> +	int i;
> +	int len;
> +	int num;
> +	int type;
> +	int err = 0;
> +	__be32 group;
> +
> +	if (!pskb_may_pull(skb, sizeof(*ih)))
> +		return -EINVAL;
> +
> +	ih = igmpv3_report_hdr(skb);
> +	num = ntohs(ih->ngrec);
> +	len = sizeof(*ih);
> +
> +	for (i = 0; i < num; i++) {
> +		len += sizeof(*grec);
> +		if (!pskb_may_pull(skb, len))
> +			return -EINVAL;
> +
> +		grec = (void *)(skb->data + len);
> +		group = grec->grec_mca;
> +		type = grec->grec_type;
> +
> +		len += grec->grec_nsrcs * 4;
> +		if (!pskb_may_pull(skb, len))
> +			return -EINVAL;
> +
> +		/* We treat this as an IGMPv2 report for now. */
> +		switch (type) {
> +		case IGMPV3_MODE_IS_INCLUDE:
> +		case IGMPV3_MODE_IS_EXCLUDE:
> +		case IGMPV3_CHANGE_TO_INCLUDE:
> +		case IGMPV3_CHANGE_TO_EXCLUDE:
> +		case IGMPV3_ALLOW_NEW_SOURCES:
> +		case IGMPV3_BLOCK_OLD_SOURCES:
> +			break;
> +
> +		default:
> +			continue;
> +		}
> +
> +		err = br_multicast_add_group(br, port, group);
> +		if (err)
> +			break;
> +	}
> +
> +	return err;
> +}
> +
> +static void br_multicast_mark_router(struct net_bridge *br,
> +				     struct net_bridge_port *port)
> +{
> +	unsigned long now = jiffies;
> +	struct hlist_node *p;
> +	struct hlist_node **h;
> +
> +	if (!port) {
> +		if (br->multicast_router == 1)
> +			mod_timer(&br->multicast_router_timer,
> +				  now + br->multicast_querier_interval);
> +		return;
> +	}
> +
> +	if (port->multicast_router != 1)
> +		return;
> +
> +	if (!hlist_unhashed(&port->rlist))
> +		goto timer;
> +
> +	for (h = &br->router_list.first;
> +	     (p = *h) &&
> +	     (unsigned long)container_of(p, struct net_bridge_port, rlist) >
> +	     (unsigned long)port;
> +	     h = &p->next)
> +		;
> +
> +	port->rlist.pprev = h;
> +	port->rlist.next = p;
> +	rcu_assign_pointer(*h, &port->rlist);

Also protected by br->multicast_lock.

> +	if (p)
> +		p->pprev = &port->rlist.next;
> +
> +timer:
> +	mod_timer(&port->multicast_router_timer,
> +		  now + br->multicast_querier_interval);
> +}
> +
> +static void br_multicast_query_received(struct net_bridge *br,
> +					struct net_bridge_port *port,
> +					__be32 saddr)
> +{
> +	if (saddr)
> +		mod_timer(&br->multicast_querier_timer,
> +			  jiffies + br->multicast_querier_interval);
> +	else if (timer_pending(&br->multicast_querier_timer))
> +		return;
> +
> +	br_multicast_mark_router(br, port);
> +}
> +
> +static int br_multicast_query(struct net_bridge *br,
> +			      struct net_bridge_port *port,
> +			      struct sk_buff *skb)
> +{
> +	struct iphdr *iph = ip_hdr(skb);
> +	struct igmphdr *ih = igmp_hdr(skb);
> +	struct net_bridge_mdb_entry *mp;
> +	struct igmpv3_query *ih3;
> +	struct net_bridge_port_group *p;
> +	struct net_bridge_port_group **pp;
> +	unsigned long max_delay;
> +	unsigned long now = jiffies;
> +	__be32 group;
> +
> +	spin_lock(&br->multicast_lock);
> +	if (!netif_running(br->dev) ||
> +	    (port && port->state == BR_STATE_DISABLED))
> +		goto out;
> +
> +	br_multicast_query_received(br, port, iph->saddr);
> +
> +	group = ih->group;
> +
> +	if (skb->len == sizeof(*ih)) {
> +		max_delay = ih->code * (HZ / IGMP_TIMER_SCALE);
> +
> +		if (!max_delay) {
> +			max_delay = 10 * HZ;
> +			group = 0;
> +		}
> +	} else {
> +		if (!pskb_may_pull(skb, sizeof(struct igmpv3_query)))
> +			return -EINVAL;
> +
> +		ih3 = igmpv3_query_hdr(skb);
> +		if (ih3->nsrcs)
> +			return 0;
> +
> +		max_delay = ih3->code ? 1 :
> +			    IGMPV3_MRC(ih3->code) * (HZ / IGMP_TIMER_SCALE);
> +	}
> +
> +	if (!group)
> +		goto out;
> +
> +	mp = br_mdb_ip_get(br->mdb, group);
> +	if (!mp)
> +		goto out;
> +
> +	max_delay *= br->multicast_last_member_count;
> +
> +	if (!hlist_unhashed(&mp->mglist) &&
> +	    (timer_pending(&mp->timer) ?
> +	     time_after(mp->timer.expires, now + max_delay) :
> +	     try_to_del_timer_sync(&mp->timer) >= 0))
> +		mod_timer(&mp->timer, now + max_delay);
> +
> +	for (pp = &mp->ports; (p = *pp); pp = &p->next) {
> +		if (timer_pending(&p->timer) ?
> +		    time_after(p->timer.expires, now + max_delay) :
> +		    try_to_del_timer_sync(&p->timer) >= 0)
> +			mod_timer(&mp->timer, now + max_delay);
> +	}
> +
> +out:
> +	spin_unlock(&br->multicast_lock);
> +	return 0;
> +}
> +
> +static void br_multicast_leave_group(struct net_bridge *br,
> +				     struct net_bridge_port *port,
> +				     __be32 group)
> +{
> +	struct net_bridge_mdb_htable *mdb;
> +	struct net_bridge_mdb_entry *mp;
> +	struct net_bridge_port_group *p;
> +	unsigned long now;
> +	unsigned long time;
> +
> +	if (ipv4_is_local_multicast(group))
> +		return;
> +
> +	spin_lock(&br->multicast_lock);
> +	if (!netif_running(br->dev) ||
> +	    (port && port->state == BR_STATE_DISABLED) ||
> +	    timer_pending(&br->multicast_querier_timer))
> +		goto out;
> +
> +	mdb = br->mdb;
> +	mp = br_mdb_ip_get(mdb, group);
> +	if (!mp)
> +		goto out;
> +
> +	now = jiffies;
> +	time = now + br->multicast_last_member_count *
> +		     br->multicast_last_member_interval;
> +
> +	if (!port) {
> +		if (!hlist_unhashed(&mp->mglist) &&
> +		    (timer_pending(&mp->timer) ?
> +		     time_after(mp->timer.expires, time) :
> +		     try_to_del_timer_sync(&mp->timer) >= 0)) {
> +			mod_timer(&mp->timer, time);
> +
> +			mp->queries_sent = 0;
> +			mod_timer(&mp->query_timer, now);
> +		}
> +
> +		goto out;
> +	}
> +
> +	for (p = mp->ports; p; p = p->next) {
> +		if (p->port != port)
> +			continue;
> +
> +		if (!hlist_unhashed(&p->mglist) &&
> +		    (timer_pending(&p->timer) ?
> +		     time_after(p->timer.expires, time) :
> +		     try_to_del_timer_sync(&p->timer) >= 0)) {
> +			mod_timer(&p->timer, time);
> +
> +			p->queries_sent = 0;
> +			mod_timer(&p->query_timer, now);
> +		}
> +
> +		break;
> +	}
> +
> +out:
> +	spin_unlock(&br->multicast_lock);
> +}
> +
> +static int br_multicast_ipv4_rcv(struct net_bridge *br,
> +				 struct net_bridge_port *port,
> +				 struct sk_buff *skb)
> +{
> +	struct sk_buff *skb2 = skb;
> +	struct iphdr *iph;
> +	struct igmphdr *ih;
> +	unsigned len;
> +	unsigned offset;
> +	int err;
> +
> +	BR_INPUT_SKB_CB(skb)->igmp = 0;
> +	BR_INPUT_SKB_CB(skb)->mrouters_only = 0;
> +
> +	/* We treat OOM as packet loss for now. */
> +	if (!pskb_may_pull(skb, sizeof(*iph)))
> +		return -EINVAL;
> +
> +	iph = ip_hdr(skb);
> +
> +	if (iph->ihl < 5 || iph->version != 4)
> +		return -EINVAL;
> +
> +	if (!pskb_may_pull(skb, ip_hdrlen(skb)))
> +		return -EINVAL;
> +
> +	iph = ip_hdr(skb);
> +
> +	if (unlikely(ip_fast_csum((u8 *)iph, iph->ihl)))
> +		return -EINVAL;
> +
> +	if (iph->protocol != IPPROTO_IGMP)
> +		return 0;
> +
> +	len = ntohs(iph->tot_len);
> +	if (skb->len < len || len < ip_hdrlen(skb))
> +		return -EINVAL;
> +
> +	if (skb->len > len) {
> +		skb2 = skb_clone(skb, GFP_ATOMIC);
> +		if (!skb2)
> +			return -ENOMEM;
> +
> +		err = pskb_trim_rcsum(skb2, len);
> +		if (err)
> +			return err;
> +	}
> +
> +	len -= ip_hdrlen(skb2);
> +	offset = skb_network_offset(skb2) + ip_hdrlen(skb2);
> +	__skb_pull(skb2, offset);
> +	skb_reset_transport_header(skb2);
> +
> +	err = -EINVAL;
> +	if (!pskb_may_pull(skb2, sizeof(*ih)))
> +		goto out;
> +
> +	iph = ip_hdr(skb2);
> +
> +	switch (skb2->ip_summed) {
> +	case CHECKSUM_COMPLETE:
> +		if (!csum_fold(skb2->csum))
> +			break;
> +		/* fall through */
> +	case CHECKSUM_NONE:
> +		skb2->csum = 0;
> +		if (skb_checksum_complete(skb2))
> +			return -EINVAL;
> +	}
> +
> +	err = 0;
> +
> +	BR_INPUT_SKB_CB(skb)->igmp = 1;
> +	ih = igmp_hdr(skb2);
> +
> +	switch (ih->type) {
> +	case IGMP_HOST_MEMBERSHIP_REPORT:
> +	case IGMPV2_HOST_MEMBERSHIP_REPORT:
> +		BR_INPUT_SKB_CB(skb2)->mrouters_only = 1;
> +		err = br_multicast_add_group(br, port, ih->group);
> +		break;
> +	case IGMPV3_HOST_MEMBERSHIP_REPORT:
> +		err = br_multicast_igmp3_report(br, port, skb2);
> +		break;
> +	case IGMP_HOST_MEMBERSHIP_QUERY:
> +		err = br_multicast_query(br, port, skb2);
> +		break;
> +	case IGMP_HOST_LEAVE_MESSAGE:
> +		br_multicast_leave_group(br, port, ih->group);
> +		break;
> +	}
> +
> +out:
> +	__skb_push(skb2, offset);
> +	if (skb2 != skb)
> +		kfree_skb(skb2);
> +	return err;
> +}
> +
> +int br_multicast_rcv(struct net_bridge *br, struct net_bridge_port *port,
> +		     struct sk_buff *skb)
> +{
> +	if (br->multicast_disabled)
> +		return 0;
> +
> +	switch (skb->protocol) {
> +	case htons(ETH_P_IP):
> +		return br_multicast_ipv4_rcv(br, port, skb);
> +	}
> +
> +	return 0;
> +}
> +
> +static void br_multicast_query_expired(unsigned long data)
> +{
> +	struct net_bridge *br = (void *)data;
> +
> +	spin_lock(&br->multicast_lock);
> +	if (br->multicast_startup_queries_sent <
> +	    br->multicast_startup_query_count)
> +		br->multicast_startup_queries_sent++;
> +
> +	br_multicast_send_query(br, NULL, br->multicast_startup_queries_sent);
> +
> +	spin_unlock(&br->multicast_lock);
> +}
> +
> +void br_multicast_init(struct net_bridge *br)
> +{
> +	br->hash_elasticity = 4;
> +	br->hash_max = 512;
> +
> +	br->multicast_router = 1;
> +	br->multicast_last_member_count = 2;
> +	br->multicast_startup_query_count = 2;
> +
> +	br->multicast_last_member_interval = HZ;
> +	br->multicast_query_response_interval = 10 * HZ;
> +	br->multicast_startup_query_interval = 125 * HZ / 4;
> +	br->multicast_query_interval = 125 * HZ;
> +	br->multicast_querier_interval = 255 * HZ;
> +	br->multicast_membership_interval = 260 * HZ;
> +
> +	spin_lock_init(&br->multicast_lock);
> +	setup_timer(&br->multicast_router_timer,
> +		    br_multicast_local_router_expired, 0);
> +	setup_timer(&br->multicast_querier_timer,
> +		    br_multicast_local_router_expired, 0);
> +	setup_timer(&br->multicast_query_timer, br_multicast_query_expired,
> +		    (unsigned long)br);
> +}
> +
> +void br_multicast_open(struct net_bridge *br)
> +{
> +	br->multicast_startup_queries_sent = 0;
> +
> +	if (br->multicast_disabled)
> +		return;
> +
> +	mod_timer(&br->multicast_query_timer, jiffies);
> +}
> +
> +void br_multicast_stop(struct net_bridge *br)
> +{
> +	struct net_bridge_mdb_htable *mdb;
> +	struct net_bridge_mdb_entry *mp;
> +	struct hlist_node *p, *n;
> +	u32 ver;
> +	int i;
> +
> +	del_timer_sync(&br->multicast_router_timer);
> +	del_timer_sync(&br->multicast_querier_timer);
> +	del_timer_sync(&br->multicast_query_timer);
> +
> +	spin_lock_bh(&br->multicast_lock);
> +	mdb = br->mdb;
> +	if (!mdb)
> +		goto out;
> +
> +	br->mdb = NULL;
> +
> +	ver = mdb->ver;
> +	for (i = 0; i < mdb->max; i++) {
> +		hlist_for_each_entry_safe(mp, p, n, &mdb->mhash[i],
> +					  hlist[ver]) {
> +			del_timer(&mp->timer);
> +			del_timer(&mp->query_timer);
> +			call_rcu_bh(&mp->rcu, br_multicast_free_group);

I don't see what prevents new readers from finding the net_bridge_mdb_entry
referenced by mp.  Unless you stop new readers, an RCU grace period
cannot help you!  @@@

> +		}
> +	}
> +
> +	if (mdb->old) {

And another ->old check for teardown purposes?

> +		spin_unlock_bh(&br->multicast_lock);
> +		synchronize_rcu_bh();

Ah, but the above only guarantees that the grace period has elapsed,
not that all of the callbacks have been invoked, so...

> +		spin_lock_bh(&br->multicast_lock);
> +		WARN_ON(mdb->old);

This WARN_ON() can fire!!!

Suggested fix: s/synchronize_rcu_bh()/rcu_barrier_bh()/ @@@

> +	}
> +
> +	mdb->old = mdb;

I can't say I understand how making mdb->old point back at mdb helps...

Ah, clever -- this arrangement causes the RCU callback to free up the
whole mess.  ;-)

> +	call_rcu_bh(&mdb->rcu, br_mdb_free);

I don't see prevents new readers from finding the net_bridge_mdb_htable
referenced by mdb.  Again, if new readers are permitted to reference
this structure, an RCU grace period won't help you -- you cannot start
the RCU grace period until after all new readers have been excluded.

> +
> +out:
> +	spin_unlock_bh(&br->multicast_lock);
> +}
> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
> index 7b0aed5..0871775 100644
> --- a/net/bridge/br_private.h
> +++ b/net/bridge/br_private.h
> @@ -57,6 +57,41 @@ struct net_bridge_fdb_entry
>  	unsigned char			is_static;
>  };
> 
> +struct net_bridge_port_group {
> +	struct net_bridge_port		*port;
> +	struct net_bridge_port_group	*next;
> +	struct hlist_node		mglist;
> +	struct rcu_head			rcu;
> +	struct timer_list		timer;
> +	struct timer_list		query_timer;
> +	__be32				addr;
> +	u32				queries_sent;
> +};
> +
> +struct net_bridge_mdb_entry
> +{
> +	struct hlist_node		hlist[2];
> +	struct hlist_node		mglist;
> +	struct net_bridge		*br;
> +	struct net_bridge_port_group	*ports;
> +	struct rcu_head			rcu;
> +	struct timer_list		timer;
> +	struct timer_list		query_timer;
> +	__be32				addr;
> +	u32				queries_sent;
> +};
> +
> +struct net_bridge_mdb_htable
> +{
> +	struct hlist_head		*mhash;
> +	struct rcu_head			rcu;
> +	struct net_bridge_mdb_htable	*old;
> +	u32				size;
> +	u32				max;
> +	u32				secret;
> +	u32				ver;
> +};
> +
>  struct net_bridge_port
>  {
>  	struct net_bridge		*br;
> @@ -84,6 +119,15 @@ struct net_bridge_port
> 
>  	unsigned long 			flags;
>  #define BR_HAIRPIN_MODE		0x00000001
> +
> +#ifdef CONFIG_BRIDGE_IGMP_SNOOPING
> +	u32				multicast_startup_queries_sent;
> +	unsigned char			multicast_router;
> +	struct timer_list		multicast_router_timer;
> +	struct timer_list		multicast_query_timer;
> +	struct hlist_head		mglist;
> +	struct hlist_node		rlist;
> +#endif
>  };
> 
>  struct net_bridge
> @@ -125,6 +169,35 @@ struct net_bridge
>  	unsigned char			topology_change;
>  	unsigned char			topology_change_detected;
> 
> +#ifdef CONFIG_BRIDGE_IGMP_SNOOPING
> +	unsigned char			multicast_router;
> +
> +	u8				multicast_disabled:1;
> +
> +	u32				hash_elasticity;
> +	u32				hash_max;
> +
> +	u32				multicast_last_member_count;
> +	u32				multicast_startup_queries_sent;
> +	u32				multicast_startup_query_count;
> +
> +	unsigned long			multicast_last_member_interval;
> +	unsigned long			multicast_membership_interval;
> +	unsigned long			multicast_querier_interval;
> +	unsigned long			multicast_query_interval;
> +	unsigned long			multicast_query_response_interval;
> +	unsigned long			multicast_startup_query_interval;
> +
> +	spinlock_t			multicast_lock;
> +	struct net_bridge_mdb_htable	*mdb;
> +	struct hlist_head		router_list;
> +	struct hlist_head		mglist;
> +
> +	struct timer_list		multicast_router_timer;
> +	struct timer_list		multicast_querier_timer;
> +	struct timer_list		multicast_query_timer;
> +#endif
> +
>  	struct timer_list		hello_timer;
>  	struct timer_list		tcn_timer;
>  	struct timer_list		topology_change_timer;
> @@ -134,6 +207,8 @@ struct net_bridge
> 
>  struct br_input_skb_cb {
>  	struct net_device *brdev;
> +	int igmp;
> +	int mrouters_only;
>  };
> 
>  #define BR_INPUT_SKB_CB(__skb)	((struct br_input_skb_cb *)(__skb)->cb)
> @@ -205,6 +280,70 @@ extern struct sk_buff *br_handle_frame(struct net_bridge_port *p,
>  extern int br_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
>  extern int br_ioctl_deviceless_stub(struct net *net, unsigned int cmd, void __user *arg);
> 
> +/* br_multicast.c */
> +#ifdef CONFIG_BRIDGE_IGMP_SNOOPING
> +extern int br_multicast_rcv(struct net_bridge *br,
> +			    struct net_bridge_port *port,
> +			    struct sk_buff *skb);
> +extern struct net_bridge_mdb_entry *br_mdb_get(struct net_bridge *br,
> +					       struct sk_buff *skb);
> +extern void br_multicast_add_port(struct net_bridge_port *port);
> +extern void br_multicast_del_port(struct net_bridge_port *port);
> +extern void br_multicast_enable_port(struct net_bridge_port *port);
> +extern void br_multicast_disable_port(struct net_bridge_port *port);
> +extern void br_multicast_init(struct net_bridge *br);
> +extern void br_multicast_open(struct net_bridge *br);
> +extern void br_multicast_stop(struct net_bridge *br);
> +#else
> +static inline int br_multicast_rcv(struct net_bridge *br,
> +				   struct net_bridge_port *port,
> +				   struct sk_buff *skb)
> +{
> +	return 0;
> +}
> +
> +static inline struct net_bridge_mdb_entry *br_mdb_get(struct net_bridge *br,
> +						      struct sk_buff *skb)
> +{
> +	return NULL;
> +}
> +
> +static inline void br_multicast_add_port(struct net_bridge_port *port)
> +{
> +}
> +
> +static inline void br_multicast_del_port(struct net_bridge_port *port)
> +{
> +}
> +
> +static inline void br_multicast_enable_port(struct net_bridge_port *port)
> +{
> +}
> +
> +static inline void br_multicast_disable_port(struct net_bridge_port *port)
> +{
> +}
> +
> +static inline void br_multicast_init(struct net_bridge *br)
> +{
> +}
> +
> +static inline void br_multicast_open(struct net_bridge *br)
> +{
> +}
> +
> +static inline void br_multicast_stop(struct net_bridge *br)
> +{
> +}
> +#endif
> +
> +static inline bool br_multicast_is_router(struct net_bridge *br)
> +{
> +	return br->multicast_router == 2 ||
> +	       (br->multicast_router == 1 &&
> +		timer_pending(&br->multicast_router_timer));
> +}
> +
>  /* br_netfilter.c */
>  #ifdef CONFIG_BRIDGE_NETFILTER
>  extern int br_netfilter_init(void);
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
