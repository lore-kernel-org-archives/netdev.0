From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/5] neigh: convert parms to an array
Date: Fri,  6 Dec 2013 19:29:00 +0100
Message-ID: <1386354544-19122-2-git-send-email-jiri@resnulli.us>
References: <1386354544-19122-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	hannes@stressinduktion.org, bcrl@kvack.org,
	william.manley@youview.com, gaofeng@cn.fujitsu.com,
	joe@perches.com, herbert@gondor.apana.org.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f42.google.com ([74.125.83.42]:36022 "EHLO
	mail-ee0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751894Ab3LFS3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 13:29:12 -0500
Received: by mail-ee0-f42.google.com with SMTP id e53so463806eek.29
        for <netdev@vger.kernel.org>; Fri, 06 Dec 2013 10:29:10 -0800 (PST)
In-Reply-To: <1386354544-19122-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch converts the neigh param members to an array. This allows easier
manipulation which will be needed later on to provide better management of
default values.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/net/neighbour.h |  48 +++++--
 net/802/hippi.c         |   4 +-
 net/core/neighbour.c    | 327 ++++++++++++++++++++----------------------------
 net/decnet/dn_neigh.c   |  28 +++--
 net/ipv4/arp.c          |  33 ++---
 net/ipv6/addrconf.c     |  12 +-
 net/ipv6/ndisc.c        |  43 ++++---
 7 files changed, 238 insertions(+), 257 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 536501a..4cb5478 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -37,6 +37,32 @@
 
 struct neighbour;
 
+enum {
+	NEIGH_VAR_MCAST_PROBES,
+	NEIGH_VAR_UCAST_PROBES,
+	NEIGH_VAR_APP_PROBES,
+	NEIGH_VAR_RETRANS_TIME,
+	NEIGH_VAR_BASE_REACHABLE_TIME,
+	NEIGH_VAR_DELAY_PROBE_TIME,
+	NEIGH_VAR_GC_STALETIME,
+	NEIGH_VAR_QUEUE_LEN_BYTES,
+	NEIGH_VAR_PROXY_QLEN,
+	NEIGH_VAR_ANYCAST_DELAY,
+	NEIGH_VAR_PROXY_DELAY,
+	NEIGH_VAR_LOCKTIME,
+#define NEIGH_VAR_DATA_MAX (NEIGH_VAR_LOCKTIME + 1)
+	/* Following are used as a second way to access one of the above */
+	NEIGH_VAR_QUEUE_LEN, /* same data as NEIGH_VAR_QUEUE_LEN_BYTES */
+	NEIGH_VAR_RETRANS_TIME_MS, /* same data as NEIGH_VAR_RETRANS_TIME */
+	NEIGH_VAR_BASE_REACHABLE_TIME_MS, /* same data as NEIGH_VAR_BASE_REACHABLE_TIME */
+	/* Following are used by "default" only */
+	NEIGH_VAR_GC_INTERVAL,
+	NEIGH_VAR_GC_THRESH1,
+	NEIGH_VAR_GC_THRESH2,
+	NEIGH_VAR_GC_THRESH3,
+	NEIGH_VAR_MAX
+};
+
 struct neigh_parms {
 #ifdef CONFIG_NET_NS
 	struct net *net;
@@ -53,22 +79,18 @@ struct neigh_parms {
 	atomic_t refcnt;
 	struct rcu_head rcu_head;
 
-	int	base_reachable_time;
-	int	retrans_time;
-	int	gc_staletime;
 	int	reachable_time;
-	int	delay_probe_time;
-
-	int	queue_len_bytes;
-	int	ucast_probes;
-	int	app_probes;
-	int	mcast_probes;
-	int	anycast_delay;
-	int	proxy_delay;
-	int	proxy_qlen;
-	int	locktime;
+	int	data[NEIGH_VAR_DATA_MAX];
 };
 
+static inline void neigh_var_set(struct neigh_parms *p, int index, int val)
+{
+	p->data[index] = val;
+}
+
+#define NEIGH_VAR(p, attr) ((p)->data[NEIGH_VAR_ ## attr])
+#define NEIGH_VAR_SET(p, attr, val) neigh_var_set(p, NEIGH_VAR_ ## attr, val)
+
 struct neigh_statistics {
 	unsigned long allocs;		/* number of allocated neighs */
 	unsigned long destroys;		/* number of destroyed neighs */
diff --git a/net/802/hippi.c b/net/802/hippi.c
index 51a1f53..a97a3bd 100644
--- a/net/802/hippi.c
+++ b/net/802/hippi.c
@@ -172,14 +172,14 @@ EXPORT_SYMBOL(hippi_mac_addr);
 int hippi_neigh_setup_dev(struct net_device *dev, struct neigh_parms *p)
 {
 	/* Never send broadcast/multicast ARP messages */
-	p->mcast_probes = 0;
+	NEIGH_VAR_SET(p, MCAST_PROBES, 0);
 
 	/* In IPv6 unicast probes are valid even on NBMA,
 	* because they are encapsulated in normal IPv6 protocol.
 	* Should be a generic flag.
 	*/
 	if (p->tbl->family != AF_INET6)
-		p->ucast_probes = 0;
+		NEIGH_VAR_SET(p, UCAST_PROBES, 0);
 	return 0;
 }
 EXPORT_SYMBOL(hippi_neigh_setup_dev);
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index ca15f32..742fa10 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -497,7 +497,7 @@ struct neighbour *__neigh_create(struct neigh_table *tbl, const void *pkey,
 		goto out_neigh_release;
 	}
 
-	n->confirmed = jiffies - (n->parms->base_reachable_time << 1);
+	n->confirmed = jiffies - (NEIGH_VAR(n->parms, BASE_REACHABLE_TIME) << 1);
 
 	write_lock_bh(&tbl->lock);
 	nht = rcu_dereference_protected(tbl->nht,
@@ -776,7 +776,7 @@ static void neigh_periodic_work(struct work_struct *work)
 		tbl->last_rand = jiffies;
 		for (p = &tbl->parms; p; p = p->next)
 			p->reachable_time =
-				neigh_rand_reach_time(p->base_reachable_time);
+				neigh_rand_reach_time(NEIGH_VAR(p, BASE_REACHABLE_TIME));
 	}
 
 	for (i = 0 ; i < (1 << nht->hash_shift); i++) {
@@ -799,7 +799,7 @@ static void neigh_periodic_work(struct work_struct *work)
 
 			if (atomic_read(&n->refcnt) == 1 &&
 			    (state == NUD_FAILED ||
-			     time_after(jiffies, n->used + n->parms->gc_staletime))) {
+			     time_after(jiffies, n->used + NEIGH_VAR(n->parms, GC_STALETIME)))) {
 				*np = n->next;
 				n->dead = 1;
 				write_unlock(&n->lock);
@@ -822,12 +822,12 @@ next_elt:
 						lockdep_is_held(&tbl->lock));
 	}
 out:
-	/* Cycle through all hash buckets every base_reachable_time/2 ticks.
-	 * ARP entry timeouts range from 1/2 base_reachable_time to 3/2
-	 * base_reachable_time.
+	/* Cycle through all hash buckets every BASE_REACHABLE_TIME/2 ticks.
+	 * ARP entry timeouts range from 1/2 BASE_REACHABLE_TIME to 3/2
+	 * BASE_REACHABLE_TIME.
 	 */
 	schedule_delayed_work(&tbl->gc_work,
-			      tbl->parms.base_reachable_time >> 1);
+			      NEIGH_VAR(&tbl->parms, BASE_REACHABLE_TIME) >> 1);
 	write_unlock_bh(&tbl->lock);
 }
 
@@ -835,8 +835,9 @@ static __inline__ int neigh_max_probes(struct neighbour *n)
 {
 	struct neigh_parms *p = n->parms;
 	return (n->nud_state & NUD_PROBE) ?
-		p->ucast_probes :
-		p->ucast_probes + p->app_probes + p->mcast_probes;
+		NEIGH_VAR(p, UCAST_PROBES) :
+		NEIGH_VAR(p, UCAST_PROBES) + NEIGH_VAR(p, APP_PROBES) +
+		NEIGH_VAR(p, MCAST_PROBES);
 }
 
 static void neigh_invalidate(struct neighbour *neigh)
@@ -901,12 +902,13 @@ static void neigh_timer_handler(unsigned long arg)
 			neigh_dbg(2, "neigh %p is still alive\n", neigh);
 			next = neigh->confirmed + neigh->parms->reachable_time;
 		} else if (time_before_eq(now,
-					  neigh->used + neigh->parms->delay_probe_time)) {
+					  neigh->used +
+					  NEIGH_VAR(neigh->parms, DELAY_PROBE_TIME))) {
 			neigh_dbg(2, "neigh %p is delayed\n", neigh);
 			neigh->nud_state = NUD_DELAY;
 			neigh->updated = jiffies;
 			neigh_suspect(neigh);
-			next = now + neigh->parms->delay_probe_time;
+			next = now + NEIGH_VAR(neigh->parms, DELAY_PROBE_TIME);
 		} else {
 			neigh_dbg(2, "neigh %p is suspected\n", neigh);
 			neigh->nud_state = NUD_STALE;
@@ -916,7 +918,8 @@ static void neigh_timer_handler(unsigned long arg)
 		}
 	} else if (state & NUD_DELAY) {
 		if (time_before_eq(now,
-				   neigh->confirmed + neigh->parms->delay_probe_time)) {
+				   neigh->confirmed +
+				   NEIGH_VAR(neigh->parms, DELAY_PROBE_TIME))) {
 			neigh_dbg(2, "neigh %p is now reachable\n", neigh);
 			neigh->nud_state = NUD_REACHABLE;
 			neigh->updated = jiffies;
@@ -928,11 +931,11 @@ static void neigh_timer_handler(unsigned long arg)
 			neigh->nud_state = NUD_PROBE;
 			neigh->updated = jiffies;
 			atomic_set(&neigh->probes, 0);
-			next = now + neigh->parms->retrans_time;
+			next = now + NEIGH_VAR(neigh->parms, RETRANS_TIME);
 		}
 	} else {
 		/* NUD_PROBE|NUD_INCOMPLETE */
-		next = now + neigh->parms->retrans_time;
+		next = now + NEIGH_VAR(neigh->parms, RETRANS_TIME);
 	}
 
 	if ((neigh->nud_state & (NUD_INCOMPLETE | NUD_PROBE)) &&
@@ -973,13 +976,16 @@ int __neigh_event_send(struct neighbour *neigh, struct sk_buff *skb)
 		goto out_unlock_bh;
 
 	if (!(neigh->nud_state & (NUD_STALE | NUD_INCOMPLETE))) {
-		if (neigh->parms->mcast_probes + neigh->parms->app_probes) {
+		if (NEIGH_VAR(neigh->parms, MCAST_PROBES) +
+		    NEIGH_VAR(neigh->parms, APP_PROBES)) {
 			unsigned long next, now = jiffies;
 
-			atomic_set(&neigh->probes, neigh->parms->ucast_probes);
+			atomic_set(&neigh->probes,
+				   NEIGH_VAR(neigh->parms, UCAST_PROBES));
 			neigh->nud_state     = NUD_INCOMPLETE;
 			neigh->updated = now;
-			next = now + max(neigh->parms->retrans_time, HZ/2);
+			next = now + max(NEIGH_VAR(neigh->parms, RETRANS_TIME),
+					 HZ/2);
 			neigh_add_timer(neigh, next);
 			immediate_probe = true;
 		} else {
@@ -994,14 +1000,14 @@ int __neigh_event_send(struct neighbour *neigh, struct sk_buff *skb)
 		neigh_dbg(2, "neigh %p is delayed\n", neigh);
 		neigh->nud_state = NUD_DELAY;
 		neigh->updated = jiffies;
-		neigh_add_timer(neigh,
-				jiffies + neigh->parms->delay_probe_time);
+		neigh_add_timer(neigh, jiffies +
+				NEIGH_VAR(neigh->parms, DELAY_PROBE_TIME));
 	}
 
 	if (neigh->nud_state == NUD_INCOMPLETE) {
 		if (skb) {
 			while (neigh->arp_queue_len_bytes + skb->truesize >
-			       neigh->parms->queue_len_bytes) {
+			       NEIGH_VAR(neigh->parms, QUEUE_LEN_BYTES)) {
 				struct sk_buff *buff;
 
 				buff = __skb_dequeue(&neigh->arp_queue);
@@ -1170,7 +1176,7 @@ int neigh_update(struct neighbour *neigh, const u8 *lladdr, u8 new,
 		neigh_update_hhs(neigh);
 		if (!(new & NUD_CONNECTED))
 			neigh->confirmed = jiffies -
-				      (neigh->parms->base_reachable_time << 1);
+				      (NEIGH_VAR(neigh->parms, BASE_REACHABLE_TIME) << 1);
 		notify = 1;
 	}
 	if (new == old)
@@ -1391,9 +1397,10 @@ void pneigh_enqueue(struct neigh_table *tbl, struct neigh_parms *p,
 		    struct sk_buff *skb)
 {
 	unsigned long now = jiffies;
-	unsigned long sched_next = now + (net_random() % p->proxy_delay);
+	unsigned long sched_next = now + (net_random() %
+					  NEIGH_VAR(p, PROXY_DELAY));
 
-	if (tbl->proxy_queue.qlen > p->proxy_qlen) {
+	if (tbl->proxy_queue.qlen > NEIGH_VAR(p, PROXY_QLEN)) {
 		kfree_skb(skb);
 		return;
 	}
@@ -1440,7 +1447,7 @@ struct neigh_parms *neigh_parms_alloc(struct net_device *dev,
 		p->tbl		  = tbl;
 		atomic_set(&p->refcnt, 1);
 		p->reachable_time =
-				neigh_rand_reach_time(p->base_reachable_time);
+				neigh_rand_reach_time(NEIGH_VAR(p, BASE_REACHABLE_TIME));
 		dev_hold(dev);
 		p->dev = dev;
 		write_pnet(&p->net, hold_net(net));
@@ -1509,7 +1516,7 @@ static void neigh_table_init_no_netlink(struct neigh_table *tbl)
 	write_pnet(&tbl->parms.net, &init_net);
 	atomic_set(&tbl->parms.refcnt, 1);
 	tbl->parms.reachable_time =
-			  neigh_rand_reach_time(tbl->parms.base_reachable_time);
+			  neigh_rand_reach_time(NEIGH_VAR(&tbl->parms, BASE_REACHABLE_TIME));
 
 	tbl->stats = alloc_percpu(struct neigh_statistics);
 	if (!tbl->stats)
@@ -1777,24 +1784,32 @@ static int neightbl_fill_parms(struct sk_buff *skb, struct neigh_parms *parms)
 	if ((parms->dev &&
 	     nla_put_u32(skb, NDTPA_IFINDEX, parms->dev->ifindex)) ||
 	    nla_put_u32(skb, NDTPA_REFCNT, atomic_read(&parms->refcnt)) ||
-	    nla_put_u32(skb, NDTPA_QUEUE_LENBYTES, parms->queue_len_bytes) ||
+	    nla_put_u32(skb, NDTPA_QUEUE_LENBYTES,
+			NEIGH_VAR(parms, QUEUE_LEN_BYTES)) ||
 	    /* approximative value for deprecated QUEUE_LEN (in packets) */
 	    nla_put_u32(skb, NDTPA_QUEUE_LEN,
-			parms->queue_len_bytes / SKB_TRUESIZE(ETH_FRAME_LEN)) ||
-	    nla_put_u32(skb, NDTPA_PROXY_QLEN, parms->proxy_qlen) ||
-	    nla_put_u32(skb, NDTPA_APP_PROBES, parms->app_probes) ||
-	    nla_put_u32(skb, NDTPA_UCAST_PROBES, parms->ucast_probes) ||
-	    nla_put_u32(skb, NDTPA_MCAST_PROBES, parms->mcast_probes) ||
+			NEIGH_VAR(parms, QUEUE_LEN_BYTES) / SKB_TRUESIZE(ETH_FRAME_LEN)) ||
+	    nla_put_u32(skb, NDTPA_PROXY_QLEN, NEIGH_VAR(parms, PROXY_QLEN)) ||
+	    nla_put_u32(skb, NDTPA_APP_PROBES, NEIGH_VAR(parms, APP_PROBES)) ||
+	    nla_put_u32(skb, NDTPA_UCAST_PROBES,
+			NEIGH_VAR(parms, UCAST_PROBES)) ||
+	    nla_put_u32(skb, NDTPA_MCAST_PROBES,
+			NEIGH_VAR(parms, MCAST_PROBES)) ||
 	    nla_put_msecs(skb, NDTPA_REACHABLE_TIME, parms->reachable_time) ||
 	    nla_put_msecs(skb, NDTPA_BASE_REACHABLE_TIME,
-			  parms->base_reachable_time) ||
-	    nla_put_msecs(skb, NDTPA_GC_STALETIME, parms->gc_staletime) ||
+			  NEIGH_VAR(parms, BASE_REACHABLE_TIME)) ||
+	    nla_put_msecs(skb, NDTPA_GC_STALETIME,
+			  NEIGH_VAR(parms, GC_STALETIME)) ||
 	    nla_put_msecs(skb, NDTPA_DELAY_PROBE_TIME,
-			  parms->delay_probe_time) ||
-	    nla_put_msecs(skb, NDTPA_RETRANS_TIME, parms->retrans_time) ||
-	    nla_put_msecs(skb, NDTPA_ANYCAST_DELAY, parms->anycast_delay) ||
-	    nla_put_msecs(skb, NDTPA_PROXY_DELAY, parms->proxy_delay) ||
-	    nla_put_msecs(skb, NDTPA_LOCKTIME, parms->locktime))
+			  NEIGH_VAR(parms, DELAY_PROBE_TIME)) ||
+	    nla_put_msecs(skb, NDTPA_RETRANS_TIME,
+			  NEIGH_VAR(parms, RETRANS_TIME)) ||
+	    nla_put_msecs(skb, NDTPA_ANYCAST_DELAY,
+			  NEIGH_VAR(parms, ANYCAST_DELAY)) ||
+	    nla_put_msecs(skb, NDTPA_PROXY_DELAY,
+			  NEIGH_VAR(parms, PROXY_DELAY)) ||
+	    nla_put_msecs(skb, NDTPA_LOCKTIME,
+			  NEIGH_VAR(parms, LOCKTIME)))
 		goto nla_put_failure;
 	return nla_nest_end(skb, nest);
 
@@ -2010,44 +2025,54 @@ static int neightbl_set(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 			switch (i) {
 			case NDTPA_QUEUE_LEN:
-				p->queue_len_bytes = nla_get_u32(tbp[i]) *
-						     SKB_TRUESIZE(ETH_FRAME_LEN);
+				NEIGH_VAR_SET(p, QUEUE_LEN_BYTES,
+					      nla_get_u32(tbp[i]) *
+					      SKB_TRUESIZE(ETH_FRAME_LEN));
 				break;
 			case NDTPA_QUEUE_LENBYTES:
-				p->queue_len_bytes = nla_get_u32(tbp[i]);
+				NEIGH_VAR_SET(p, QUEUE_LEN_BYTES,
+					      nla_get_u32(tbp[i]));
 				break;
 			case NDTPA_PROXY_QLEN:
-				p->proxy_qlen = nla_get_u32(tbp[i]);
+				NEIGH_VAR_SET(p, PROXY_QLEN,
+					      nla_get_u32(tbp[i]));
 				break;
 			case NDTPA_APP_PROBES:
-				p->app_probes = nla_get_u32(tbp[i]);
+				NEIGH_VAR_SET(p, APP_PROBES,
+					      nla_get_u32(tbp[i]));
 				break;
 			case NDTPA_UCAST_PROBES:
-				p->ucast_probes = nla_get_u32(tbp[i]);
+				NEIGH_VAR_SET(p, UCAST_PROBES,
+					      nla_get_u32(tbp[i]));
 				break;
 			case NDTPA_MCAST_PROBES:
-				p->mcast_probes = nla_get_u32(tbp[i]);
+				NEIGH_VAR_SET(p, MCAST_PROBES,
+					      nla_get_u32(tbp[i]));
 				break;
 			case NDTPA_BASE_REACHABLE_TIME:
-				p->base_reachable_time = nla_get_msecs(tbp[i]);
+				NEIGH_VAR_SET(p, BASE_REACHABLE_TIME,
+					      nla_get_msecs(tbp[i]));
 				break;
 			case NDTPA_GC_STALETIME:
-				p->gc_staletime = nla_get_msecs(tbp[i]);
+				NEIGH_VAR_SET(p, GC_STALETIME,
+					      nla_get_msecs(tbp[i]));
 				break;
 			case NDTPA_DELAY_PROBE_TIME:
-				p->delay_probe_time = nla_get_msecs(tbp[i]);
+				NEIGH_VAR_SET(p, DELAY_PROBE_TIME,
+					      nla_get_msecs(tbp[i]));
 				break;
 			case NDTPA_RETRANS_TIME:
-				p->retrans_time = nla_get_msecs(tbp[i]);
+				NEIGH_VAR_SET(p, RETRANS_TIME,
+					      nla_get_msecs(tbp[i]));
 				break;
 			case NDTPA_ANYCAST_DELAY:
-				p->anycast_delay = nla_get_msecs(tbp[i]);
+				NEIGH_VAR_SET(p, ANYCAST_DELAY, nla_get_msecs(tbp[i]));
 				break;
 			case NDTPA_PROXY_DELAY:
-				p->proxy_delay = nla_get_msecs(tbp[i]);
+				NEIGH_VAR_SET(p, PROXY_DELAY, nla_get_msecs(tbp[i]));
 				break;
 			case NDTPA_LOCKTIME:
-				p->locktime = nla_get_msecs(tbp[i]);
+				NEIGH_VAR_SET(p, LOCKTIME, nla_get_msecs(tbp[i]));
 				break;
 			}
 		}
@@ -2788,133 +2813,68 @@ static int proc_unres_qlen(struct ctl_table *ctl, int write,
 	return ret;
 }
 
-enum {
-	NEIGH_VAR_MCAST_PROBE,
-	NEIGH_VAR_UCAST_PROBE,
-	NEIGH_VAR_APP_PROBE,
-	NEIGH_VAR_RETRANS_TIME,
-	NEIGH_VAR_BASE_REACHABLE_TIME,
-	NEIGH_VAR_DELAY_PROBE_TIME,
-	NEIGH_VAR_GC_STALETIME,
-	NEIGH_VAR_QUEUE_LEN,
-	NEIGH_VAR_QUEUE_LEN_BYTES,
-	NEIGH_VAR_PROXY_QLEN,
-	NEIGH_VAR_ANYCAST_DELAY,
-	NEIGH_VAR_PROXY_DELAY,
-	NEIGH_VAR_LOCKTIME,
-	NEIGH_VAR_RETRANS_TIME_MS,
-	NEIGH_VAR_BASE_REACHABLE_TIME_MS,
-	NEIGH_VAR_GC_INTERVAL,
-	NEIGH_VAR_GC_THRESH1,
-	NEIGH_VAR_GC_THRESH2,
-	NEIGH_VAR_GC_THRESH3,
-	NEIGH_VAR_MAX
-};
+static int neigh_proc_dointvec_zero_intmax(struct ctl_table *ctl, int write,
+					   void __user *buffer,
+					   size_t *lenp, loff_t *ppos)
+{
+	struct ctl_table tmp = *ctl;
+
+	tmp.extra1 = &zero;
+	tmp.extra2 = &int_max;
+
+	return proc_dointvec_minmax(&tmp, write, buffer, lenp, ppos);
+}
+
+#define NEIGH_PARMS_DATA_OFFSET(index)	\
+	(&((struct neigh_parms *) 0)->data[index])
+
+#define NEIGH_SYSCTL_ENTRY(attr, data_attr, name, mval, proc) \
+	[NEIGH_VAR_ ## attr] = { \
+		.procname	= name, \
+		.data		= NEIGH_PARMS_DATA_OFFSET(NEIGH_VAR_ ## data_attr), \
+		.maxlen		= sizeof(int), \
+		.mode		= mval, \
+		.proc_handler	= proc, \
+	}
+
+#define NEIGH_SYSCTL_ZERO_INTMAX_ENTRY(attr, name) \
+	NEIGH_SYSCTL_ENTRY(attr, attr, name, 0644, neigh_proc_dointvec_zero_intmax)
+
+#define NEIGH_SYSCTL_JIFFIES_ENTRY(attr, name) \
+	NEIGH_SYSCTL_ENTRY(attr, attr, name, 0644, proc_dointvec_jiffies)
+
+#define NEIGH_SYSCTL_USERHZ_JIFFIES_ENTRY(attr, name) \
+	NEIGH_SYSCTL_ENTRY(attr, attr, name, 0644, proc_dointvec_userhz_jiffies)
+
+#define NEIGH_SYSCTL_MS_JIFFIES_ENTRY(attr, name) \
+	NEIGH_SYSCTL_ENTRY(attr, attr, name, 0644, proc_dointvec_ms_jiffies)
+
+#define NEIGH_SYSCTL_MS_JIFFIES_REUSED_ENTRY(attr, data_attr, name) \
+	NEIGH_SYSCTL_ENTRY(attr, data_attr, name, 0644, proc_dointvec_ms_jiffies)
+
+#define NEIGH_SYSCTL_UNRES_QLEN_REUSED_ENTRY(attr, data_attr, name) \
+	NEIGH_SYSCTL_ENTRY(attr, data_attr, name, 0644, proc_unres_qlen)
 
 static struct neigh_sysctl_table {
 	struct ctl_table_header *sysctl_header;
 	struct ctl_table neigh_vars[NEIGH_VAR_MAX + 1];
 } neigh_sysctl_template __read_mostly = {
 	.neigh_vars = {
-		[NEIGH_VAR_MCAST_PROBE] = {
-			.procname	= "mcast_solicit",
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.extra1 	= &zero,
-			.extra2		= &int_max,
-			.proc_handler	= proc_dointvec_minmax,
-		},
-		[NEIGH_VAR_UCAST_PROBE] = {
-			.procname	= "ucast_solicit",
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.extra1 	= &zero,
-			.extra2		= &int_max,
-			.proc_handler	= proc_dointvec_minmax,
-		},
-		[NEIGH_VAR_APP_PROBE] = {
-			.procname	= "app_solicit",
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.extra1 	= &zero,
-			.extra2		= &int_max,
-			.proc_handler	= proc_dointvec_minmax,
-		},
-		[NEIGH_VAR_RETRANS_TIME] = {
-			.procname	= "retrans_time",
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec_userhz_jiffies,
-		},
-		[NEIGH_VAR_BASE_REACHABLE_TIME] = {
-			.procname	= "base_reachable_time",
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec_jiffies,
-		},
-		[NEIGH_VAR_DELAY_PROBE_TIME] = {
-			.procname	= "delay_first_probe_time",
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec_jiffies,
-		},
-		[NEIGH_VAR_GC_STALETIME] = {
-			.procname	= "gc_stale_time",
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec_jiffies,
-		},
-		[NEIGH_VAR_QUEUE_LEN] = {
-			.procname	= "unres_qlen",
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_unres_qlen,
-		},
-		[NEIGH_VAR_QUEUE_LEN_BYTES] = {
-			.procname	= "unres_qlen_bytes",
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.extra1		= &zero,
-			.proc_handler   = proc_dointvec_minmax,
-		},
-		[NEIGH_VAR_PROXY_QLEN] = {
-			.procname	= "proxy_qlen",
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.extra1 	= &zero,
-			.extra2		= &int_max,
-			.proc_handler	= proc_dointvec_minmax,
-		},
-		[NEIGH_VAR_ANYCAST_DELAY] = {
-			.procname	= "anycast_delay",
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec_userhz_jiffies,
-		},
-		[NEIGH_VAR_PROXY_DELAY] = {
-			.procname	= "proxy_delay",
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec_userhz_jiffies,
-		},
-		[NEIGH_VAR_LOCKTIME] = {
-			.procname	= "locktime",
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec_userhz_jiffies,
-		},
-		[NEIGH_VAR_RETRANS_TIME_MS] = {
-			.procname	= "retrans_time_ms",
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec_ms_jiffies,
-		},
-		[NEIGH_VAR_BASE_REACHABLE_TIME_MS] = {
-			.procname	= "base_reachable_time_ms",
-			.maxlen		= sizeof(int),
-			.mode		= 0644,
-			.proc_handler	= proc_dointvec_ms_jiffies,
-		},
+		NEIGH_SYSCTL_ZERO_INTMAX_ENTRY(MCAST_PROBES, "mcast_solicit"),
+		NEIGH_SYSCTL_ZERO_INTMAX_ENTRY(UCAST_PROBES, "ucast_solicit"),
+		NEIGH_SYSCTL_ZERO_INTMAX_ENTRY(APP_PROBES, "app_solicit"),
+		NEIGH_SYSCTL_USERHZ_JIFFIES_ENTRY(RETRANS_TIME, "retrans_time"),
+		NEIGH_SYSCTL_JIFFIES_ENTRY(BASE_REACHABLE_TIME, "base_reachable_time"),
+		NEIGH_SYSCTL_JIFFIES_ENTRY(DELAY_PROBE_TIME, "delay_first_probe_time"),
+		NEIGH_SYSCTL_JIFFIES_ENTRY(GC_STALETIME, "gc_stale_time"),
+		NEIGH_SYSCTL_ZERO_INTMAX_ENTRY(QUEUE_LEN_BYTES, "unres_qlen_bytes"),
+		NEIGH_SYSCTL_ZERO_INTMAX_ENTRY(PROXY_QLEN, "proxy_qlen"),
+		NEIGH_SYSCTL_USERHZ_JIFFIES_ENTRY(ANYCAST_DELAY, "anycast_delay"),
+		NEIGH_SYSCTL_USERHZ_JIFFIES_ENTRY(PROXY_DELAY, "proxy_delay"),
+		NEIGH_SYSCTL_USERHZ_JIFFIES_ENTRY(LOCKTIME, "locktime"),
+		NEIGH_SYSCTL_UNRES_QLEN_REUSED_ENTRY(QUEUE_LEN, QUEUE_LEN_BYTES, "unres_qlen"),
+		NEIGH_SYSCTL_MS_JIFFIES_REUSED_ENTRY(RETRANS_TIME_MS, RETRANS_TIME, "retrans_time_ms"),
+		NEIGH_SYSCTL_MS_JIFFIES_REUSED_ENTRY(BASE_REACHABLE_TIME_MS, BASE_REACHABLE_TIME, "base_reachable_time_ms"),
 		[NEIGH_VAR_GC_INTERVAL] = {
 			.procname	= "gc_interval",
 			.maxlen		= sizeof(int),
@@ -2952,29 +2912,17 @@ static struct neigh_sysctl_table {
 int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
 			  char *p_name, proc_handler *handler)
 {
+	int i;
 	struct neigh_sysctl_table *t;
-	const char *dev_name_source = NULL;
+	const char *dev_name_source;
 	char neigh_path[ sizeof("net//neigh/") + IFNAMSIZ + IFNAMSIZ ];
 
 	t = kmemdup(&neigh_sysctl_template, sizeof(*t), GFP_KERNEL);
 	if (!t)
 		goto err;
 
-	t->neigh_vars[NEIGH_VAR_MCAST_PROBE].data  = &p->mcast_probes;
-	t->neigh_vars[NEIGH_VAR_UCAST_PROBE].data  = &p->ucast_probes;
-	t->neigh_vars[NEIGH_VAR_APP_PROBE].data  = &p->app_probes;
-	t->neigh_vars[NEIGH_VAR_RETRANS_TIME].data  = &p->retrans_time;
-	t->neigh_vars[NEIGH_VAR_BASE_REACHABLE_TIME].data  = &p->base_reachable_time;
-	t->neigh_vars[NEIGH_VAR_DELAY_PROBE_TIME].data  = &p->delay_probe_time;
-	t->neigh_vars[NEIGH_VAR_GC_STALETIME].data  = &p->gc_staletime;
-	t->neigh_vars[NEIGH_VAR_QUEUE_LEN].data  = &p->queue_len_bytes;
-	t->neigh_vars[NEIGH_VAR_QUEUE_LEN_BYTES].data  = &p->queue_len_bytes;
-	t->neigh_vars[NEIGH_VAR_PROXY_QLEN].data  = &p->proxy_qlen;
-	t->neigh_vars[NEIGH_VAR_ANYCAST_DELAY].data  = &p->anycast_delay;
-	t->neigh_vars[NEIGH_VAR_PROXY_DELAY].data = &p->proxy_delay;
-	t->neigh_vars[NEIGH_VAR_LOCKTIME].data = &p->locktime;
-	t->neigh_vars[NEIGH_VAR_RETRANS_TIME_MS].data  = &p->retrans_time;
-	t->neigh_vars[NEIGH_VAR_BASE_REACHABLE_TIME_MS].data  = &p->base_reachable_time;
+	for (i = 0; i < ARRAY_SIZE(t->neigh_vars); i++)
+		t->neigh_vars[i].data += (long) p;
 
 	if (dev) {
 		dev_name_source = dev->name;
@@ -2989,7 +2937,6 @@ int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
 		t->neigh_vars[NEIGH_VAR_GC_THRESH3].data = (int *)(p + 1) + 3;
 	}
 
-
 	if (handler) {
 		/* RetransTime */
 		t->neigh_vars[NEIGH_VAR_RETRANS_TIME].proc_handler = handler;
diff --git a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
index f8637f9..c8121ce 100644
--- a/net/decnet/dn_neigh.c
+++ b/net/decnet/dn_neigh.c
@@ -102,19 +102,21 @@ struct neigh_table dn_neigh_table = {
 	.id =				"dn_neigh_cache",
 	.parms ={
 		.tbl =			&dn_neigh_table,
-		.base_reachable_time =	30 * HZ,
-		.retrans_time =	1 * HZ,
-		.gc_staletime =	60 * HZ,
-		.reachable_time =		30 * HZ,
-		.delay_probe_time =	5 * HZ,
-		.queue_len_bytes =	64*1024,
-		.ucast_probes =	0,
-		.app_probes =		0,
-		.mcast_probes =	0,
-		.anycast_delay =	0,
-		.proxy_delay =		0,
-		.proxy_qlen =		0,
-		.locktime =		1 * HZ,
+		.reachable_time =	30 * HZ,
+		.data = {
+			[NEIGH_VAR_MCAST_PROBES] = 0,
+			[NEIGH_VAR_UCAST_PROBES] = 0,
+			[NEIGH_VAR_APP_PROBES] = 0,
+			[NEIGH_VAR_RETRANS_TIME] = 1 * HZ,
+			[NEIGH_VAR_BASE_REACHABLE_TIME] = 30 * HZ,
+			[NEIGH_VAR_DELAY_PROBE_TIME] = 5 * HZ,
+			[NEIGH_VAR_GC_STALETIME] = 60 * HZ,
+			[NEIGH_VAR_QUEUE_LEN_BYTES] = 64*1024,
+			[NEIGH_VAR_PROXY_QLEN] = 0,
+			[NEIGH_VAR_ANYCAST_DELAY] = 0,
+			[NEIGH_VAR_PROXY_DELAY] = 0,
+			[NEIGH_VAR_LOCKTIME] = 1 * HZ,
+		},
 	},
 	.gc_interval =			30 * HZ,
 	.gc_thresh1 =			128,
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 7808093..3a37c7d 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -166,18 +166,20 @@ struct neigh_table arp_tbl = {
 	.id		= "arp_cache",
 	.parms		= {
 		.tbl			= &arp_tbl,
-		.base_reachable_time	= 30 * HZ,
-		.retrans_time		= 1 * HZ,
-		.gc_staletime		= 60 * HZ,
 		.reachable_time		= 30 * HZ,
-		.delay_probe_time	= 5 * HZ,
-		.queue_len_bytes	= 64*1024,
-		.ucast_probes		= 3,
-		.mcast_probes		= 3,
-		.anycast_delay		= 1 * HZ,
-		.proxy_delay		= (8 * HZ) / 10,
-		.proxy_qlen		= 64,
-		.locktime		= 1 * HZ,
+		.data	= {
+			[NEIGH_VAR_MCAST_PROBES] = 3,
+			[NEIGH_VAR_UCAST_PROBES] = 3,
+			[NEIGH_VAR_RETRANS_TIME] = 1 * HZ,
+			[NEIGH_VAR_BASE_REACHABLE_TIME] = 30 * HZ,
+			[NEIGH_VAR_DELAY_PROBE_TIME] = 5 * HZ,
+			[NEIGH_VAR_GC_STALETIME] = 60 * HZ,
+			[NEIGH_VAR_QUEUE_LEN_BYTES] = 64 * 1024,
+			[NEIGH_VAR_PROXY_QLEN] = 64,
+			[NEIGH_VAR_ANYCAST_DELAY] = 1 * HZ,
+			[NEIGH_VAR_PROXY_DELAY]	= (8 * HZ) / 10,
+			[NEIGH_VAR_LOCKTIME] = 1 * HZ,
+		},
 	},
 	.gc_interval	= 30 * HZ,
 	.gc_thresh1	= 128,
@@ -359,14 +361,14 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
 	if (!saddr)
 		saddr = inet_select_addr(dev, target, RT_SCOPE_LINK);
 
-	probes -= neigh->parms->ucast_probes;
+	probes -= NEIGH_VAR(neigh->parms, UCAST_PROBES);
 	if (probes < 0) {
 		if (!(neigh->nud_state & NUD_VALID))
 			pr_debug("trying to ucast probe in NUD_INVALID\n");
 		neigh_ha_snapshot(dst_ha, neigh, dev);
 		dst_hw = dst_ha;
 	} else {
-		probes -= neigh->parms->app_probes;
+		probes -= NEIGH_VAR(neigh->parms, APP_PROBES);
 		if (probes < 0) {
 			neigh_app_ns(neigh);
 			return;
@@ -871,7 +873,7 @@ static int arp_process(struct sk_buff *skb)
 
 				if (NEIGH_CB(skb)->flags & LOCALLY_ENQUEUED ||
 				    skb->pkt_type == PACKET_HOST ||
-				    in_dev->arp_parms->proxy_delay == 0) {
+				    NEIGH_VAR(in_dev->arp_parms, PROXY_DELAY) == 0) {
 					arp_send(ARPOP_REPLY, ETH_P_ARP, sip,
 						 dev, tip, sha, dev->dev_addr,
 						 sha);
@@ -910,7 +912,8 @@ static int arp_process(struct sk_buff *skb)
 		   agents are active. Taking the first reply prevents
 		   arp trashing and chooses the fastest router.
 		 */
-		override = time_after(jiffies, n->updated + n->parms->locktime);
+		override = time_after(jiffies, n->updated +
+					       NEIGH_VAR(n->parms, LOCKTIME));
 
 		/* Broadcast replies and request packets
 		   do not assert neighbour reachability.
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index d5fa5b8..26b46e9 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1071,7 +1071,7 @@ retry:
 
 	regen_advance = idev->cnf.regen_max_retry *
 	                idev->cnf.dad_transmits *
-	                idev->nd_parms->retrans_time / HZ;
+	                NEIGH_VAR(idev->nd_parms, RETRANS_TIME) / HZ;
 	write_unlock(&idev->lock);
 
 	/* A temporary address is created only if this calculated Preferred
@@ -1888,7 +1888,8 @@ static void ipv6_regen_rndid(unsigned long data)
 
 	expires = jiffies +
 		idev->cnf.temp_prefered_lft * HZ -
-		idev->cnf.regen_max_retry * idev->cnf.dad_transmits * idev->nd_parms->retrans_time -
+		idev->cnf.regen_max_retry * idev->cnf.dad_transmits *
+		NEIGH_VAR(idev->nd_parms, RETRANS_TIME) -
 		idev->cnf.max_desync_factor * HZ;
 	if (time_before(expires, jiffies)) {
 		pr_warn("%s: too short regeneration interval; timer disabled for %s\n",
@@ -3176,7 +3177,8 @@ static void addrconf_dad_timer(unsigned long data)
 	}
 
 	ifp->dad_probes--;
-	addrconf_mod_dad_timer(ifp, ifp->idev->nd_parms->retrans_time);
+	addrconf_mod_dad_timer(ifp,
+			       NEIGH_VAR(ifp->idev->nd_parms, RETRANS_TIME));
 	spin_unlock(&ifp->lock);
 	write_unlock(&idev->lock);
 
@@ -3497,7 +3499,7 @@ restart:
 				   !(ifp->flags&IFA_F_TENTATIVE)) {
 				unsigned long regen_advance = ifp->idev->cnf.regen_max_retry *
 					ifp->idev->cnf.dad_transmits *
-					ifp->idev->nd_parms->retrans_time / HZ;
+					NEIGH_VAR(ifp->idev->nd_parms, RETRANS_TIME) / HZ;
 
 				if (age >= ifp->prefered_lft - regen_advance) {
 					struct inet6_ifaddr *ifpub = ifp->ifpub;
@@ -4196,7 +4198,7 @@ static int inet6_fill_ifla6_attrs(struct sk_buff *skb, struct inet6_dev *idev)
 	ci.max_reasm_len = IPV6_MAXPLEN;
 	ci.tstamp = cstamp_delta(idev->tstamp);
 	ci.reachable_time = jiffies_to_msecs(idev->nd_parms->reachable_time);
-	ci.retrans_time = jiffies_to_msecs(idev->nd_parms->retrans_time);
+	ci.retrans_time = jiffies_to_msecs(NEIGH_VAR(idev->nd_parms, RETRANS_TIME));
 	if (nla_put(skb, IFLA_INET6_CACHEINFO, sizeof(ci), &ci))
 		goto nla_put_failure;
 	nla = nla_reserve(skb, IFLA_INET6_CONF, DEVCONF_MAX * sizeof(s32));
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 3008651..0da0986 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -125,17 +125,19 @@ struct neigh_table nd_tbl = {
 	.id =		"ndisc_cache",
 	.parms = {
 		.tbl			= &nd_tbl,
-		.base_reachable_time	= ND_REACHABLE_TIME,
-		.retrans_time		= ND_RETRANS_TIMER,
-		.gc_staletime		= 60 * HZ,
 		.reachable_time		= ND_REACHABLE_TIME,
-		.delay_probe_time	= 5 * HZ,
-		.queue_len_bytes	= 64*1024,
-		.ucast_probes		= 3,
-		.mcast_probes		= 3,
-		.anycast_delay		= 1 * HZ,
-		.proxy_delay		= (8 * HZ) / 10,
-		.proxy_qlen		= 64,
+		.data = {
+			[NEIGH_VAR_MCAST_PROBES] = 3,
+			[NEIGH_VAR_UCAST_PROBES] = 3,
+			[NEIGH_VAR_RETRANS_TIME] = ND_RETRANS_TIMER,
+			[NEIGH_VAR_BASE_REACHABLE_TIME] = ND_REACHABLE_TIME,
+			[NEIGH_VAR_DELAY_PROBE_TIME] = 5 * HZ,
+			[NEIGH_VAR_GC_STALETIME] = 60 * HZ,
+			[NEIGH_VAR_QUEUE_LEN_BYTES] = 64 * 1024,
+			[NEIGH_VAR_PROXY_QLEN] = 64,
+			[NEIGH_VAR_ANYCAST_DELAY] = 1 * HZ,
+			[NEIGH_VAR_PROXY_DELAY] = (8 * HZ) / 10,
+		},
 	},
 	.gc_interval =	  30 * HZ,
 	.gc_thresh1 =	 128,
@@ -656,14 +658,14 @@ static void ndisc_solicit(struct neighbour *neigh, struct sk_buff *skb)
 	if (skb && ipv6_chk_addr(dev_net(dev), &ipv6_hdr(skb)->saddr, dev, 1))
 		saddr = &ipv6_hdr(skb)->saddr;
 
-	if ((probes -= neigh->parms->ucast_probes) < 0) {
+	if ((probes -= NEIGH_VAR(neigh->parms, UCAST_PROBES)) < 0) {
 		if (!(neigh->nud_state & NUD_VALID)) {
 			ND_PRINTK(1, dbg,
 				  "%s: trying to ucast probe in NUD_INVALID: %pI6\n",
 				  __func__, target);
 		}
 		ndisc_send_ns(dev, neigh, target, target, saddr);
-	} else if ((probes -= neigh->parms->app_probes) < 0) {
+	} else if ((probes -= NEIGH_VAR(neigh->parms, APP_PROBES)) < 0) {
 		neigh_app_ns(neigh);
 	} else {
 		addrconf_addr_solict_mult(target, &mcaddr);
@@ -790,7 +792,7 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 			if (!(NEIGH_CB(skb)->flags & LOCALLY_ENQUEUED) &&
 			    skb->pkt_type != PACKET_HOST &&
 			    inc &&
-			    idev->nd_parms->proxy_delay != 0) {
+			    NEIGH_VAR(idev->nd_parms, PROXY_DELAY) != 0) {
 				/*
 				 * for anycast or proxy,
 				 * sender should delay its response
@@ -1210,7 +1212,7 @@ skip_defrtr:
 			rtime = (rtime*HZ)/1000;
 			if (rtime < HZ/10)
 				rtime = HZ/10;
-			in6_dev->nd_parms->retrans_time = rtime;
+			NEIGH_VAR_SET(in6_dev->nd_parms, RETRANS_TIME, rtime);
 			in6_dev->tstamp = jiffies;
 			inet6_ifinfo_notify(RTM_NEWLINK, in6_dev);
 		}
@@ -1222,9 +1224,11 @@ skip_defrtr:
 			if (rtime < HZ/10)
 				rtime = HZ/10;
 
-			if (rtime != in6_dev->nd_parms->base_reachable_time) {
-				in6_dev->nd_parms->base_reachable_time = rtime;
-				in6_dev->nd_parms->gc_staletime = 3 * rtime;
+			if (rtime != NEIGH_VAR(in6_dev->nd_parms, BASE_REACHABLE_TIME)) {
+				NEIGH_VAR_SET(in6_dev->nd_parms,
+					      BASE_REACHABLE_TIME, rtime);
+				NEIGH_VAR_SET(in6_dev->nd_parms,
+					      GC_STALETIME, 3 * rtime);
 				in6_dev->nd_parms->reachable_time = neigh_rand_reach_time(rtime);
 				in6_dev->tstamp = jiffies;
 				inet6_ifinfo_notify(RTM_NEWLINK, in6_dev);
@@ -1665,8 +1669,9 @@ int ndisc_ifinfo_sysctl_change(struct ctl_table *ctl, int write, void __user *bu
 		ret = -1;
 
 	if (write && ret == 0 && dev && (idev = in6_dev_get(dev)) != NULL) {
-		if (ctl->data == &idev->nd_parms->base_reachable_time)
-			idev->nd_parms->reachable_time = neigh_rand_reach_time(idev->nd_parms->base_reachable_time);
+		if (ctl->data == &NEIGH_VAR(idev->nd_parms, BASE_REACHABLE_TIME))
+			idev->nd_parms->reachable_time =
+					neigh_rand_reach_time(NEIGH_VAR(idev->nd_parms, BASE_REACHABLE_TIME));
 		idev->tstamp = jiffies;
 		inet6_ifinfo_notify(RTM_NEWLINK, idev);
 		in6_dev_put(idev);
-- 
1.8.3.1
