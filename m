From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFC 5/7] neighbour: convert lookup to sequence lock
Date: Mon, 14 Aug 2006 14:20:09 -0700
Message-ID: <20060814212143.845202090@localhost.localdomain>
References: <20060814212004.606140865@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:61161 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964965AbWHNVY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 17:24:27 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline; filename=neighbour-seqlock.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The reading of the contents of a neighbour entry can be converted 
from a slow reader/writer lock to a fast lockless sequence number check.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


---
 include/net/neighbour.h |    2 
 net/core/neighbour.c    |  102 +++++++++++++++++++++++++++---------------------
 net/ipv4/arp.c          |  101 ++++++++++++++++++++++++++++-------------------
 net/ipv6/ndisc.c        |   16 +++----
 net/ipv6/route.c        |   12 ++---
 net/sched/sch_teql.c    |   11 +++--
 6 files changed, 142 insertions(+), 102 deletions(-)

--- net-2.6.19.orig/include/net/neighbour.h
+++ net-2.6.19/include/net/neighbour.h
@@ -100,7 +100,7 @@ struct neighbour
 	__u8			type;
 	__u8			dead;
 	atomic_t		probes;
-	rwlock_t		lock;
+	seqlock_t		lock;
 	unsigned char		ha[ALIGN(MAX_ADDR_LEN, sizeof(unsigned long))];
 	struct hh_cache		*hh;
 	atomic_t		refcnt;
--- net-2.6.19.orig/net/core/neighbour.c
+++ net-2.6.19/net/core/neighbour.c
@@ -143,17 +143,17 @@ static int neigh_forced_gc(struct neigh_
 			 * - nobody refers to it.
 			 * - it is not permanent
 			 */
-			write_lock(&n->lock);
+			write_seqlock(&n->lock);
 			if (atomic_read(&n->refcnt) == 1 &&
 			    !(n->nud_state & NUD_PERMANENT)) {
 				hlist_del_rcu(&n->hlist);
 				n->dead = 1;
 				shrunk	= 1;
-				write_unlock(&n->lock);
+				write_sequnlock(&n->lock);
 				call_rcu(&n->rcu, neigh_rcu_release);
 				continue;
 			}
-			write_unlock(&n->lock);
+			write_sequnlock(&n->lock);
 		}
 	}
 
@@ -198,7 +198,7 @@ static void neigh_flush_dev(struct neigh
 				continue;
 
 			hlist_del_rcu(&n->hlist);
-			write_lock(&n->lock);
+			write_seqlock(&n->lock);
 			neigh_del_timer(n);
 			n->dead = 1;
 
@@ -220,7 +220,7 @@ static void neigh_flush_dev(struct neigh
 					n->nud_state = NUD_NONE;
 				NEIGH_PRINTK2("neigh %p is stray.\n", n);
 			}
-			write_unlock(&n->lock);
+			write_sequnlock(&n->lock);
 			neigh_release(n);
 		}
 	}
@@ -267,7 +267,7 @@ static struct neighbour *neigh_alloc(str
 	memset(n, 0, tbl->entry_size);
 
 	skb_queue_head_init(&n->arp_queue);
-	rwlock_init(&n->lock);
+	seqlock_init(&n->lock);
 	n->updated	  = n->used = now;
 	n->nud_state	  = NUD_NONE;
 	n->output	  = neigh_blackhole;
@@ -615,7 +615,7 @@ void neigh_destroy(struct neighbour *nei
 /* Neighbour state is suspicious;
    disable fast path.
 
-   Called with write_locked neigh.
+   Called with locked neigh.
  */
 static void neigh_suspect(struct neighbour *neigh)
 {
@@ -632,7 +632,7 @@ static void neigh_suspect(struct neighbo
 /* Neighbour state is OK;
    enable fast path.
 
-   Called with write_locked neigh.
+   Called with locked neigh.
  */
 static void neigh_connect(struct neighbour *neigh)
 {
@@ -676,7 +676,7 @@ static void neigh_periodic_timer(unsigne
 	hlist_for_each_entry_safe(n, node, tmp, head, hlist) {
 		unsigned int state;
 
-		write_lock(&n->lock);
+		write_seqlock(&n->lock);
 
 		state = n->nud_state;
 		if (state & (NUD_PERMANENT | NUD_IN_TIMER))
@@ -690,12 +690,12 @@ static void neigh_periodic_timer(unsigne
 		     time_after(now, n->used + n->parms->gc_staletime))) {
 			hlist_del_rcu(&n->hlist);
 			n->dead = 1;
-			write_unlock(&n->lock);
+			write_sequnlock(&n->lock);
 			neigh_release(n);
 			continue;
 		}
 	next_elt:
-		write_unlock(&n->lock);
+		write_sequnlock(&n->lock);
 	}
 
  	/* Cycle through all hash buckets every base_reachable_time/2 ticks.
@@ -738,7 +738,7 @@ static void neigh_timer_handler(unsigned
 	unsigned state;
 	int notify = 0;
 
-	write_lock(&neigh->lock);
+	write_seqlock(&neigh->lock);
 
 	state = neigh->nud_state;
 	now = jiffies;
@@ -748,6 +748,7 @@ static void neigh_timer_handler(unsigned
 #ifndef CONFIG_SMP
 		printk(KERN_WARNING "neigh: timer & !nud_in_timer\n");
 #endif
+		write_sequnlock(&neigh->lock);
 		goto out;
 	}
 
@@ -808,9 +809,9 @@ static void neigh_timer_handler(unsigned
 		 */
 		while (neigh->nud_state == NUD_FAILED &&
 		       (skb = __skb_dequeue(&neigh->arp_queue)) != NULL) {
-			write_unlock(&neigh->lock);
+			write_sequnlock(&neigh->lock);
 			neigh->ops->error_report(neigh, skb);
-			write_lock(&neigh->lock);
+			write_sequnlock(&neigh->lock);
 		}
 		skb_queue_purge(&neigh->arp_queue);
 	}
@@ -821,20 +822,22 @@ static void neigh_timer_handler(unsigned
 		if (!mod_timer(&neigh->timer, next))
 			neigh_hold(neigh);
 	}
+
 	if (neigh->nud_state & (NUD_INCOMPLETE | NUD_PROBE)) {
 		struct sk_buff *skb = skb_peek(&neigh->arp_queue);
 		/* keep skb alive even if arp_queue overflows */
 		if (skb)
 			skb_get(skb);
-		write_unlock(&neigh->lock);
+		write_sequnlock(&neigh->lock);
 		neigh->ops->solicit(neigh, skb);
 		atomic_inc(&neigh->probes);
 		if (skb)
 			kfree_skb(skb);
 	} else {
-out:
-		write_unlock(&neigh->lock);
+		write_sequnlock(&neigh->lock);
 	}
+
+out:
 	if (notify)
 		call_netevent_notifiers(NETEVENT_NEIGH_UPDATE, neigh);
 
@@ -850,11 +853,11 @@ int __neigh_event_send(struct neighbour 
 	int rc;
 	unsigned long now;
 
-	write_lock_bh(&neigh->lock);
+	write_seqlock_bh(&neigh->lock);
 
 	rc = 0;
 	if (neigh->nud_state & (NUD_CONNECTED | NUD_DELAY | NUD_PROBE))
-		goto out_unlock_bh;
+		goto out;
 
 	now = jiffies;
 	
@@ -868,7 +871,7 @@ int __neigh_event_send(struct neighbour 
 		} else {
 			neigh->nud_state = NUD_FAILED;
 			neigh->updated = jiffies;
-			write_unlock_bh(&neigh->lock);
+			write_sequnlock_bh(&neigh->lock);
 
 			if (skb)
 				kfree_skb(skb);
@@ -896,8 +899,8 @@ int __neigh_event_send(struct neighbour 
 		}
 		rc = 1;
 	}
-out_unlock_bh:
-	write_unlock_bh(&neigh->lock);
+out:
+	write_sequnlock_bh(&neigh->lock);
 	return rc;
 }
 
@@ -948,7 +951,7 @@ int neigh_update(struct neighbour *neigh
 	struct net_device *dev;
 	int update_isrouter = 0;
 
-	write_lock_bh(&neigh->lock);
+	write_seqlock_bh(&neigh->lock);
 
 	dev    = neigh->dev;
 	old    = neigh->nud_state;
@@ -1052,22 +1055,23 @@ int neigh_update(struct neighbour *neigh
 		while (neigh->nud_state & NUD_VALID &&
 		       (skb = __skb_dequeue(&neigh->arp_queue)) != NULL) {
 			struct neighbour *n1 = neigh;
-			write_unlock_bh(&neigh->lock);
+			write_sequnlock_bh(&neigh->lock);
 			/* On shaper/eql skb->dst->neighbour != neigh :( */
 			if (skb->dst && skb->dst->neighbour)
 				n1 = skb->dst->neighbour;
 			n1->output(skb);
-			write_lock_bh(&neigh->lock);
+			write_seqlock_bh(&neigh->lock);
 		}
 		skb_queue_purge(&neigh->arp_queue);
 	}
-out:
+
 	if (update_isrouter) {
 		neigh->flags = (flags & NEIGH_UPDATE_F_ISROUTER) ?
 			(neigh->flags | NTF_ROUTER) :
 			(neigh->flags & ~NTF_ROUTER);
 	}
-	write_unlock_bh(&neigh->lock);
+out:
+	write_sequnlock_bh(&neigh->lock);
 
 	if (notify)
 		call_netevent_notifiers(NETEVENT_NEIGH_UPDATE, neigh);
@@ -1160,19 +1164,24 @@ int neigh_resolve_output(struct sk_buff 
 	if (!neigh_event_send(neigh, skb)) {
 		int err;
 		struct net_device *dev = neigh->dev;
+		unsigned short type = ntohs(skb->protocol);
+
 		if (dev->hard_header_cache && !dst->hh) {
-			write_lock_bh(&neigh->lock);
+			write_seqlock_bh(&neigh->lock);
 			if (!dst->hh)
 				neigh_hh_init(neigh, dst, dst->ops->protocol);
-			err = dev->hard_header(skb, dev, ntohs(skb->protocol),
+			err = dev->hard_header(skb, dev, type,
 					       neigh->ha, NULL, skb->len);
-			write_unlock_bh(&neigh->lock);
+			write_sequnlock_bh(&neigh->lock);
 		} else {
-			read_lock_bh(&neigh->lock);
-			err = dev->hard_header(skb, dev, ntohs(skb->protocol),
-					       neigh->ha, NULL, skb->len);
-			read_unlock_bh(&neigh->lock);
+			unsigned seq;
+			do {
+				seq = read_seqbegin(&neigh->lock);
+				err = dev->hard_header(skb, dev, type,
+						       neigh->ha, NULL, skb->len);
+			} while (read_seqretry(&neigh->lock, seq));
 		}
+
 		if (err >= 0)
 			rc = neigh->ops->queue_xmit(skb);
 		else
@@ -1197,13 +1206,16 @@ int neigh_connected_output(struct sk_buf
 	struct dst_entry *dst = skb->dst;
 	struct neighbour *neigh = dst->neighbour;
 	struct net_device *dev = neigh->dev;
+	unsigned seq;
 
 	__skb_pull(skb, skb->nh.raw - skb->data);
 
-	read_lock_bh(&neigh->lock);
-	err = dev->hard_header(skb, dev, ntohs(skb->protocol),
-			       neigh->ha, NULL, skb->len);
-	read_unlock_bh(&neigh->lock);
+	do {
+		seq = read_seqbegin(&neigh->lock);
+		err = dev->hard_header(skb, dev,  ntohs(skb->protocol),
+				       neigh->ha, NULL, skb->len);
+	} while (read_seqretry(&neigh->lock, seq));
+
 	if (err >= 0)
 		err = neigh->ops->queue_xmit(skb);
 	else {
@@ -1964,11 +1976,15 @@ static int neigh_fill_info(struct sk_buf
 
 	NLA_PUT(skb, NDA_DST, neigh->tbl->key_len, neigh->primary_key);
 
-	read_lock_bh(&neigh->lock);
 	ndm->ndm_state	 = neigh->nud_state;
+
+	/* Not really updating this neighbour but don't want to
+	 * deal with the unwind case when seqlock needs retry
+	 */
+	write_seqlock_bh(&neigh->lock);
 	if ((neigh->nud_state & NUD_VALID) &&
 	    nla_put(skb, NDA_LLADDR, neigh->dev->addr_len, neigh->ha) < 0) {
-		read_unlock_bh(&neigh->lock);
+		write_sequnlock_bh(&neigh->lock);
 		goto nla_put_failure;
 	}
 
@@ -1976,7 +1992,7 @@ static int neigh_fill_info(struct sk_buf
 	ci.ndm_confirmed = now - neigh->confirmed;
 	ci.ndm_updated	 = now - neigh->updated;
 	ci.ndm_refcnt	 = atomic_read(&neigh->refcnt) - 1;
-	read_unlock_bh(&neigh->lock);
+	write_sequnlock_bh(&neigh->lock);
 
 	NLA_PUT_U32(skb, NDA_PROBES, atomic_read(&neigh->probes));
 	NLA_PUT(skb, NDA_CACHEINFO, sizeof(ci), &ci);
@@ -2081,13 +2097,13 @@ void __neigh_for_each_release(struct nei
 					  &tbl->hash_buckets[chain], hlist) {
 			int release;
 
-			write_lock(&n->lock);
+			write_seqlock(&n->lock);
 			release = cb(n);
 			if (release) {
 				hlist_del_rcu(&n->hlist);
 				n->dead = 1;
 			}
-			write_unlock(&n->lock);
+			write_sequnlock(&n->lock);
 			if (release)
 				call_rcu(&n->rcu, neigh_rcu_release);
 		}
--- net-2.6.19.orig/net/ipv4/arp.c
+++ net-2.6.19/net/ipv4/arp.c
@@ -328,6 +328,31 @@ static void arp_error_report(struct neig
 	kfree_skb(skb);
 }
 
+
+static unsigned arp_state_to_flags(const struct neighbour *neigh)
+{
+	unsigned flags = 0;
+	if (neigh->nud_state&NUD_PERMANENT)
+		flags = ATF_PERM|ATF_COM;
+	else if (neigh->nud_state&NUD_VALID)
+		flags = ATF_COM;
+	return flags;
+}
+
+static void arp_get_neigh_addr(u8 *ha, const struct neighbour *neigh,
+			       unsigned len, unsigned *flags)
+{
+	unsigned seq;
+
+	do {
+		seq = read_seqbegin(&neigh->lock);
+		memcpy(ha, neigh->ha, len);
+		if (flags)
+			*flags = arp_state_to_flags(neigh);
+	} while (read_seqretry(&neigh->lock, seq));
+
+}
+
 static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
 {
 	u32 saddr = 0;
@@ -369,8 +394,12 @@ static void arp_solicit(struct neighbour
 	if ((probes -= neigh->parms->ucast_probes) < 0) {
 		if (!(neigh->nud_state&NUD_VALID))
 			printk(KERN_DEBUG "trying to ucast probe in NUD_INVALID\n");
-		dst_ha = neigh->ha;
-		read_lock_bh(&neigh->lock);
+
+		dst_ha = kmalloc(MAX_ADDR_LEN, GFP_ATOMIC);
+		if (!dst_ha)
+			return;
+
+		arp_get_neigh_addr(dst_ha, neigh, MAX_ADDR_LEN, NULL);
 	} else if ((probes -= neigh->parms->app_probes) < 0) {
 #ifdef CONFIG_ARPD
 		neigh_app_ns(neigh);
@@ -380,8 +409,9 @@ static void arp_solicit(struct neighbour
 
 	arp_send(ARPOP_REQUEST, ETH_P_ARP, target, dev, saddr,
 		 dst_ha, dev->dev_addr, NULL);
+
 	if (dst_ha)
-		read_unlock_bh(&neigh->lock);
+		kfree(dst_ha);
 }
 
 static int arp_ignore(struct in_device *in_dev, struct net_device *dev,
@@ -489,10 +519,7 @@ int arp_find(unsigned char *haddr, struc
 	if (n) {
 		n->used = jiffies;
 		if (n->nud_state&NUD_VALID || neigh_event_send(n, skb) == 0) {
-			read_lock_bh(&n->lock);
- 			memcpy(haddr, n->ha, dev->addr_len);
-			read_unlock_bh(&n->lock);
-			neigh_release(n);
+			arp_get_neigh_addr(haddr, n, dev->addr_len, NULL);
 			return 0;
 		}
 		neigh_release(n);
@@ -1047,16 +1074,6 @@ static int arp_req_set(struct arpreq *r,
 	return err;
 }
 
-static unsigned arp_state_to_flags(struct neighbour *neigh)
-{
-	unsigned flags = 0;
-	if (neigh->nud_state&NUD_PERMANENT)
-		flags = ATF_PERM|ATF_COM;
-	else if (neigh->nud_state&NUD_VALID)
-		flags = ATF_COM;
-	return flags;
-}
-
 /*
  *	Get an ARP cache entry.
  */
@@ -1069,10 +1086,8 @@ static int arp_req_get(struct arpreq *r,
 
 	neigh = neigh_lookup(&arp_tbl, &ip, dev);
 	if (neigh) {
-		read_lock_bh(&neigh->lock);
-		memcpy(r->arp_ha.sa_data, neigh->ha, dev->addr_len);
-		r->arp_flags = arp_state_to_flags(neigh);
-		read_unlock_bh(&neigh->lock);
+		arp_get_neigh_addr(r->arp_ha.sa_data, neigh, dev->addr_len,
+				   &r->arp_flags);
 		r->arp_ha.sa_family = dev->type;
 		strlcpy(r->arp_dev, dev->name, sizeof(r->arp_dev));
 		neigh_release(neigh);
@@ -1258,7 +1273,7 @@ void __init arp_init(void)
 /*
  *	ax25 -> ASCII conversion
  */
-static char *ax2asc2(ax25_address *a, char *buf)
+static char *ax2asc2(const ax25_address *a, char *buf)
 {
 	char c, *s;
 	int n;
@@ -1290,35 +1305,41 @@ static char *ax2asc2(ax25_address *a, ch
 #define HBUFFERLEN 30
 
 static void arp_format_neigh_entry(struct seq_file *seq,
-				   struct neighbour *n)
+				   const struct neighbour *n)
 {
 	char hbuffer[HBUFFERLEN];
 	const char hexbuf[] = "0123456789ABCDEF";
 	int k, j;
+	unsigned hflags, seqno;
 	char tbuf[16];
 	struct net_device *dev = n->dev;
 	int hatype = dev->type;
 
-	read_lock(&n->lock);
-	/* Convert hardware address to XX:XX:XX:XX ... form. */
-#if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
-	if (hatype == ARPHRD_AX25 || hatype == ARPHRD_NETROM)
-		ax2asc2((ax25_address *)n->ha, hbuffer);
-	else {
-#endif
-	for (k = 0, j = 0; k < HBUFFERLEN - 3 && j < dev->addr_len; j++) {
-		hbuffer[k++] = hexbuf[(n->ha[j] >> 4) & 15];
-		hbuffer[k++] = hexbuf[n->ha[j] & 15];
-		hbuffer[k++] = ':';
-	}
-	hbuffer[--k] = 0;
+	do {
+		seqno = read_seqbegin(&n->lock);
+
+		/* Convert hardware address to XX:XX:XX:XX ... form. */
 #if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
-	}
+		if (hatype == ARPHRD_AX25 || hatype == ARPHRD_NETROM)
+			ax2asc2((const ax25_address *)n->ha, hbuffer);
+		else
 #endif
-	sprintf(tbuf, "%u.%u.%u.%u", NIPQUAD(*(u32*)n->primary_key));
+		{
+			for (k = 0, j = 0; k < HBUFFERLEN - 3 && j < dev->addr_len; j++) {
+				hbuffer[k++] = hexbuf[(n->ha[j] >> 4) & 15];
+				hbuffer[k++] = hexbuf[n->ha[j] & 15];
+				hbuffer[k++] = ':';
+			}
+			hbuffer[--k] = 0;
+		}
+
+		sprintf(tbuf, "%u.%u.%u.%u", NIPQUAD(*(u32*)n->primary_key));
+		hflags = arp_state_to_flags(n);
+	} while (read_seqretry(&n->lock, seqno));
+
 	seq_printf(seq, "%-16s 0x%-10x0x%-10x%s     *        %s\n",
-		   tbuf, hatype, arp_state_to_flags(n), hbuffer, dev->name);
-	read_unlock(&n->lock);
+		   tbuf, hatype, hflags, hbuffer, dev->name);
+
 }
 
 static void arp_format_pneigh_entry(struct seq_file *seq,
--- net-2.6.19.orig/net/ipv6/ndisc.c
+++ net-2.6.19/net/ipv6/ndisc.c
@@ -1405,15 +1405,15 @@ void ndisc_send_redirect(struct sk_buff 
 		return;
 	}
 
-	if (dev->addr_len) {
-		read_lock_bh(&neigh->lock);
-		if (neigh->nud_state & NUD_VALID) {
+	if (dev->addr_len && (neigh->nud_state & NUD_VALID)) {
+		unsigned seq;
+		do {
+			seq = read_seqbegin(&neigh->lock);
 			memcpy(ha_buf, neigh->ha, dev->addr_len);
-			read_unlock_bh(&neigh->lock);
-			ha = ha_buf;
-			len += ndisc_opt_addr_space(dev);
-		} else
-			read_unlock_bh(&neigh->lock);
+		} while (read_seqretry(&neigh->lock, seq));
+
+		ha = ha_buf;
+		len += ndisc_opt_addr_space(dev);
 	}
 
 	rd_len = min_t(unsigned int,
--- net-2.6.19.orig/net/ipv6/route.c
+++ net-2.6.19/net/ipv6/route.c
@@ -280,20 +280,19 @@ static void rt6_probe(struct rt6_info *r
 	 */
 	if (!neigh || (neigh->nud_state & NUD_VALID))
 		return;
-	read_lock_bh(&neigh->lock);
+
 	if (!(neigh->nud_state & NUD_VALID) &&
-	    time_after(jiffies, neigh->updated + rt->rt6i_idev->cnf.rtr_probe_interval)) {
+	    time_after(jiffies,
+		       neigh->updated + rt->rt6i_idev->cnf.rtr_probe_interval)) {
 		struct in6_addr mcaddr;
 		struct in6_addr *target;
 
 		neigh->updated = jiffies;
-		read_unlock_bh(&neigh->lock);
 
 		target = (struct in6_addr *)&neigh->primary_key;
 		addrconf_addr_solict_mult(target, &mcaddr);
 		ndisc_send_ns(rt->rt6i_dev, NULL, target, &mcaddr, NULL);
-	} else
-		read_unlock_bh(&neigh->lock);
+	}
 }
 #else
 static inline void rt6_probe(struct rt6_info *rt)
@@ -324,10 +323,9 @@ static int inline rt6_check_neigh(struct
 	    !(rt->rt6i_flags & RTF_GATEWAY))
 		m = 1;
 	else if (neigh) {
-		read_lock_bh(&neigh->lock);
+		smp_rmb();
 		if (neigh->nud_state & NUD_VALID)
 			m = 2;
-		read_unlock_bh(&neigh->lock);
 	}
 	return m;
 }
--- net-2.6.19.orig/net/sched/sch_teql.c
+++ net-2.6.19/net/sched/sch_teql.c
@@ -248,9 +248,14 @@ __teql_resolve(struct sk_buff *skb, stru
 	}
 	if (neigh_event_send(n, skb_res) == 0) {
 		int err;
-		read_lock(&n->lock);
-		err = dev->hard_header(skb, dev, ntohs(skb->protocol), n->ha, NULL, skb->len);
-		read_unlock(&n->lock);
+		unsigned seq;
+
+		do {
+			seq = read_seqbegin(&n->lock);
+			err = dev->hard_header(skb, dev, ntohs(skb->protocol),
+					       n->ha, NULL, skb->len);
+		} while (read_seqretry(&n->lock, seq));
+
 		if (err < 0) {
 			neigh_release(n);
 			return -EINVAL;

--

