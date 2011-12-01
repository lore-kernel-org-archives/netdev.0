From: David Miller <davem@davemloft.net>
Subject: [PATCH 7/7] atm: clip: Use device neigh support on top of
 "arp_tbl".
Date: Wed, 30 Nov 2011 22:41:56 -0500 (EST)
Message-ID: <20111130.224156.2082895087108185796.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58074 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753660Ab1LADl6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 22:41:58 -0500
Received: from localhost (cpe-66-65-61-233.nyc.res.rr.com [66.65.61.233])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id pB13fuW5027372
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 19:41:57 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Instead of instantiating an entire new neigh_table instance
just for ATM handling, use the neigh device private facility.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/atmclip.h |    5 ---
 net/atm/clip.c        |   86 ++++++++-----------------------------------------
 net/ipv4/arp.c        |    5 ---
 net/ipv4/route.c      |   10 +----
 4 files changed, 16 insertions(+), 90 deletions(-)

diff --git a/include/net/atmclip.h b/include/net/atmclip.h
index 852a3b2..5865924 100644
--- a/include/net/atmclip.h
+++ b/include/net/atmclip.h
@@ -41,17 +41,12 @@ struct atmarp_entry {
 	struct neighbour *neigh;	/* neighbour back-pointer */
 };
 
-
 #define PRIV(dev) ((struct clip_priv *) netdev_priv(dev))
 
-
 struct clip_priv {
 	int number;			/* for convenience ... */
 	spinlock_t xoff_lock;		/* ensures that pop is atomic (SMP) */
 	struct net_device *next;	/* next CLIP interface */
 };
 
-
-extern struct neigh_table *clip_tbl_hook;
-
 #endif
diff --git a/net/atm/clip.c b/net/atm/clip.c
index a9d3484..f3b3615 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -33,6 +33,7 @@
 #include <linux/slab.h>
 #include <net/route.h> /* for struct rtable and routing */
 #include <net/icmp.h> /* icmp_send */
+#include <net/arp.h>
 #include <linux/param.h> /* for HZ */
 #include <linux/uaccess.h>
 #include <asm/byteorder.h> /* for htons etc. */
@@ -287,70 +288,23 @@ static const struct neigh_ops clip_neigh_ops = {
 static int clip_constructor(struct neighbour *neigh)
 {
 	struct atmarp_entry *entry = neighbour_priv(neigh);
-	struct net_device *dev = neigh->dev;
-	struct in_device *in_dev;
-	struct neigh_parms *parms;
 
-	pr_debug("(neigh %p, entry %p)\n", neigh, entry);
-	neigh->type = inet_addr_type(&init_net, *((__be32 *) neigh->primary_key));
-	if (neigh->type != RTN_UNICAST)
+	if (neigh->tbl->family != AF_INET)
 		return -EINVAL;
 
-	rcu_read_lock();
-	in_dev = __in_dev_get_rcu(dev);
-	if (!in_dev) {
-		rcu_read_unlock();
+	if (neigh->type != RTN_UNICAST)
 		return -EINVAL;
-	}
-
-	parms = in_dev->arp_parms;
-	__neigh_parms_put(neigh->parms);
-	neigh->parms = neigh_parms_clone(parms);
-	rcu_read_unlock();
 
+	neigh->nud_state = NUD_NONE;
 	neigh->ops = &clip_neigh_ops;
-	neigh->output = neigh->nud_state & NUD_VALID ?
-	    neigh->ops->connected_output : neigh->ops->output;
+	neigh->output = neigh->ops->output;
 	entry->neigh = neigh;
 	entry->vccs = NULL;
 	entry->expires = jiffies - 1;
+
 	return 0;
 }
 
-static u32 clip_hash(const void *pkey, const struct net_device *dev, __u32 rnd)
-{
-	return jhash_2words(*(u32 *) pkey, dev->ifindex, rnd);
-}
-
-static struct neigh_table clip_tbl = {
-	.family 	= AF_INET,
-	.key_len 	= 4,
-	.hash 		= clip_hash,
-	.constructor 	= clip_constructor,
-	.id 		= "clip_arp_cache",
-
-	/* parameters are copied from ARP ... */
-	.parms = {
-		.tbl 			= &clip_tbl,
-		.base_reachable_time 	= 30 * HZ,
-		.retrans_time 		= 1 * HZ,
-		.gc_staletime 		= 60 * HZ,
-		.reachable_time 	= 30 * HZ,
-		.delay_probe_time 	= 5 * HZ,
-		.queue_len_bytes 	= 64 * 1024,
-		.ucast_probes 		= 3,
-		.mcast_probes 		= 3,
-		.anycast_delay 		= 1 * HZ,
-		.proxy_delay 		= (8 * HZ) / 10,
-		.proxy_qlen 		= 64,
-		.locktime 		= 1 * HZ,
-	},
-	.gc_interval 	= 30 * HZ,
-	.gc_thresh1 	= 128,
-	.gc_thresh2 	= 512,
-	.gc_thresh3 	= 1024,
-};
-
 /* @@@ copy bh locking from arp.c -- need to bh-enable atm code before */
 
 /*
@@ -508,7 +462,7 @@ static int clip_setentry(struct atm_vcc *vcc, __be32 ip)
 	rt = ip_route_output(&init_net, ip, 0, 1, 0);
 	if (IS_ERR(rt))
 		return PTR_ERR(rt);
-	neigh = __neigh_lookup(&clip_tbl, &ip, rt->dst.dev, 1);
+	neigh = __neigh_lookup(&arp_tbl, &ip, rt->dst.dev, 1);
 	ip_rt_put(rt);
 	if (!neigh)
 		return -ENOMEM;
@@ -529,7 +483,8 @@ static int clip_setentry(struct atm_vcc *vcc, __be32 ip)
 }
 
 static const struct net_device_ops clip_netdev_ops = {
-	.ndo_start_xmit = clip_start_xmit,
+	.ndo_start_xmit		= clip_start_xmit,
+	.ndo_neigh_construct	= clip_constructor,
 };
 
 static void clip_setup(struct net_device *dev)
@@ -590,10 +545,8 @@ static int clip_device_event(struct notifier_block *this, unsigned long event,
 	if (!net_eq(dev_net(dev), &init_net))
 		return NOTIFY_DONE;
 
-	if (event == NETDEV_UNREGISTER) {
-		neigh_ifdown(&clip_tbl, dev);
+	if (event == NETDEV_UNREGISTER)
 		return NOTIFY_DONE;
-	}
 
 	/* ignore non-CLIP devices */
 	if (dev->type != ARPHRD_ATM || dev->netdev_ops != &clip_netdev_ops)
@@ -867,6 +820,9 @@ static void *clip_seq_sub_iter(struct neigh_seq_state *_state,
 {
 	struct clip_seq_state *state = (struct clip_seq_state *)_state;
 
+	if (n->dev->type != ARPHRD_ATM)
+		return NULL;
+
 	return clip_seq_vcc_walk(state, neighbour_priv(n), pos);
 }
 
@@ -874,7 +830,7 @@ static void *clip_seq_start(struct seq_file *seq, loff_t * pos)
 {
 	struct clip_seq_state *state = seq->private;
 	state->ns.neigh_sub_iter = clip_seq_sub_iter;
-	return neigh_seq_start(seq, pos, &clip_tbl, NEIGH_SEQ_NEIGH_ONLY);
+	return neigh_seq_start(seq, pos, &arp_tbl, NEIGH_SEQ_NEIGH_ONLY);
 }
 
 static int clip_seq_show(struct seq_file *seq, void *v)
@@ -920,9 +876,6 @@ static void atm_clip_exit_noproc(void);
 
 static int __init atm_clip_init(void)
 {
-	neigh_table_init_no_netlink(&clip_tbl);
-
-	clip_tbl_hook = &clip_tbl;
 	register_atm_ioctl(&clip_ioctl_ops);
 	register_netdevice_notifier(&clip_dev_notifier);
 	register_inetaddr_notifier(&clip_inet_notifier);
@@ -959,12 +912,6 @@ static void atm_clip_exit_noproc(void)
 	 */
 	del_timer_sync(&idle_timer);
 
-	/* Next, purge the table, so that the device
-	 * unregister loop below does not hang due to
-	 * device references remaining in the table.
-	 */
-	neigh_ifdown(&clip_tbl, NULL);
-
 	dev = clip_devs;
 	while (dev) {
 		next = PRIV(dev)->next;
@@ -972,11 +919,6 @@ static void atm_clip_exit_noproc(void)
 		free_netdev(dev);
 		dev = next;
 	}
-
-	/* Now it is safe to fully shutdown whole table. */
-	neigh_table_clear(&clip_tbl);
-
-	clip_tbl_hook = NULL;
 }
 
 static void __exit atm_clip_exit(void)
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index fd4b3e8..ff324eb 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -112,11 +112,6 @@
 #include <net/arp.h>
 #include <net/ax25.h>
 #include <net/netrom.h>
-#if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
-#include <net/atmclip.h>
-struct neigh_table *clip_tbl_hook;
-EXPORT_SYMBOL(clip_tbl_hook);
-#endif
 
 #include <asm/system.h>
 #include <linux/uaccess.h>
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index fb47c8f..9a20663 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -108,7 +108,6 @@
 #ifdef CONFIG_SYSCTL
 #include <linux/sysctl.h>
 #endif
-#include <net/atmclip.h>
 #include <net/secure_seq.h>
 
 #define RT_FL_TOS(oldflp4) \
@@ -1013,23 +1012,18 @@ static int slow_chain_length(const struct rtable *head)
 
 static struct neighbour *ipv4_neigh_lookup(const struct dst_entry *dst, const void *daddr)
 {
-	struct neigh_table *tbl = &arp_tbl;
 	static const __be32 inaddr_any = 0;
 	struct net_device *dev = dst->dev;
 	const __be32 *pkey = daddr;
 	struct neighbour *n;
 
-#if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
-	if (dev->type == ARPHRD_ATM)
-		tbl = clip_tbl_hook;
-#endif
 	if (dev->flags & (IFF_LOOPBACK | IFF_POINTOPOINT))
 		pkey = &inaddr_any;
 
-	n = __ipv4_neigh_lookup(tbl, dev, *(__force u32 *)pkey);
+	n = __ipv4_neigh_lookup(&arp_tbl, dev, *(__force u32 *)pkey);
 	if (n)
 		return n;
-	return neigh_create(tbl, pkey, dev);
+	return neigh_create(&arp_tbl, pkey, dev);
 }
 
 static int rt_bind_neighbour(struct rtable *rt)
-- 
1.7.6.4
