From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 23/29] netfilter: conntrack: get rid of conntrack timer
Date: Mon,  5 Sep 2016 12:58:38 +0200
Message-ID: <1473073124-5015-24-git-send-email-pablo@netfilter.org>
References: <1473073124-5015-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35200 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933563AbcIEK7R (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Sep 2016 06:59:17 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 33F152EFEC6
        for <netdev@vger.kernel.org>; Mon,  5 Sep 2016 12:59:16 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 170971150DD
        for <netdev@vger.kernel.org>; Mon,  5 Sep 2016 12:59:16 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id A4F18114D6B
        for <netdev@vger.kernel.org>; Mon,  5 Sep 2016 12:59:13 +0200 (CEST)
In-Reply-To: <1473073124-5015-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

With stats enabled this eats 80 bytes on x86_64 per nf_conn entry, as
Eric Dumazet pointed out during netfilter workshop 2016.

Eric also says: "Another reason was the fact that Thomas was about to
change max timer range [..]" (500462a9de657f8, 'timers: Switch to
a non-cascading wheel').

Remove the timer and use a 32bit jiffies value containing timestamp until
entry is valid.

During conntrack lookup, even before doing tuple comparision, check
the timeout value and evict the entry in case it is too old.

The dying bit is used as a synchronization point to avoid races where
multiple cpus try to evict the same entry.

Because lookup is always lockless, we need to bump the refcnt once
when we evict, else we could try to evict already-dead entry that
is being recycled.

This is the standard/expected way when conntrack entries are destroyed.

Followup patches will introduce garbage colliction via work queue
and further places where we can reap obsoleted entries (e.g. during
netlink dumps), this is needed to avoid expired conntracks from hanging
around for too long when lookup rate is low after a busy period.

Signed-off-by: Florian Westphal <fw@strlen.de>
Acked-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack.h | 23 +++++++--
 net/netfilter/nf_conntrack_core.c    | 91 ++++++++++++++++++++----------------
 net/netfilter/nf_conntrack_netlink.c | 14 ++----
 net/netfilter/nf_conntrack_pptp.c    |  3 +-
 net/netfilter/nf_nat_core.c          |  6 ---
 5 files changed, 74 insertions(+), 63 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index 2a12748..7277751 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -42,7 +42,6 @@ union nf_conntrack_expect_proto {
 
 #include <linux/types.h>
 #include <linux/skbuff.h>
-#include <linux/timer.h>
 
 #ifdef CONFIG_NETFILTER_DEBUG
 #define NF_CT_ASSERT(x)		WARN_ON(!(x))
@@ -73,7 +72,7 @@ struct nf_conn_help {
 #include <net/netfilter/ipv6/nf_conntrack_ipv6.h>
 
 struct nf_conn {
-	/* Usage count in here is 1 for hash table/destruct timer, 1 per skb,
+	/* Usage count in here is 1 for hash table, 1 per skb,
 	 * plus 1 for any connection(s) we are `master' for
 	 *
 	 * Hint, SKB address this struct and refcnt via skb->nfct and
@@ -96,8 +95,8 @@ struct nf_conn {
 	/* Have we seen traffic both ways yet? (bitset) */
 	unsigned long status;
 
-	/* Timer function; drops refcnt when it goes off. */
-	struct timer_list timeout;
+	/* jiffies32 when this ct is considered dead */
+	u32 timeout;
 
 	possible_net_t ct_net;
 
@@ -291,14 +290,28 @@ static inline bool nf_is_loopback_packet(const struct sk_buff *skb)
 	return skb->dev && skb->skb_iif && skb->dev->flags & IFF_LOOPBACK;
 }
 
+#define nfct_time_stamp ((u32)(jiffies))
+
 /* jiffies until ct expires, 0 if already expired */
 static inline unsigned long nf_ct_expires(const struct nf_conn *ct)
 {
-	long timeout = (long)ct->timeout.expires - (long)jiffies;
+	s32 timeout = ct->timeout - nfct_time_stamp;
 
 	return timeout > 0 ? timeout : 0;
 }
 
+static inline bool nf_ct_is_expired(const struct nf_conn *ct)
+{
+	return (__s32)(ct->timeout - nfct_time_stamp) <= 0;
+}
+
+/* use after obtaining a reference count */
+static inline bool nf_ct_should_gc(const struct nf_conn *ct)
+{
+	return nf_ct_is_expired(ct) && nf_ct_is_confirmed(ct) &&
+	       !nf_ct_is_dying(ct);
+}
+
 struct kernel_param;
 
 int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp);
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 887926a..87ee6da 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -371,7 +371,6 @@ destroy_conntrack(struct nf_conntrack *nfct)
 
 	pr_debug("destroy_conntrack(%p)\n", ct);
 	NF_CT_ASSERT(atomic_read(&nfct->use) == 0);
-	NF_CT_ASSERT(!timer_pending(&ct->timeout));
 
 	if (unlikely(nf_ct_is_template(ct))) {
 		nf_ct_tmpl_free(ct);
@@ -434,35 +433,30 @@ bool nf_ct_delete(struct nf_conn *ct, u32 portid, int report)
 {
 	struct nf_conn_tstamp *tstamp;
 
+	if (test_and_set_bit(IPS_DYING_BIT, &ct->status))
+		return false;
+
 	tstamp = nf_conn_tstamp_find(ct);
 	if (tstamp && tstamp->stop == 0)
 		tstamp->stop = ktime_get_real_ns();
 
-	if (nf_ct_is_dying(ct))
-		goto delete;
-
 	if (nf_conntrack_event_report(IPCT_DESTROY, ct,
 				    portid, report) < 0) {
-		/* destroy event was not delivered */
+		/* destroy event was not delivered. nf_ct_put will
+		 * be done by event cache worker on redelivery.
+		 */
 		nf_ct_delete_from_lists(ct);
 		nf_conntrack_ecache_delayed_work(nf_ct_net(ct));
 		return false;
 	}
 
 	nf_conntrack_ecache_work(nf_ct_net(ct));
-	set_bit(IPS_DYING_BIT, &ct->status);
- delete:
 	nf_ct_delete_from_lists(ct);
 	nf_ct_put(ct);
 	return true;
 }
 EXPORT_SYMBOL_GPL(nf_ct_delete);
 
-static void death_by_timeout(unsigned long ul_conntrack)
-{
-	nf_ct_delete((struct nf_conn *)ul_conntrack, 0, 0);
-}
-
 static inline bool
 nf_ct_key_equal(struct nf_conntrack_tuple_hash *h,
 		const struct nf_conntrack_tuple *tuple,
@@ -480,6 +474,18 @@ nf_ct_key_equal(struct nf_conntrack_tuple_hash *h,
 	       net_eq(net, nf_ct_net(ct));
 }
 
+/* caller must hold rcu readlock and none of the nf_conntrack_locks */
+static void nf_ct_gc_expired(struct nf_conn *ct)
+{
+	if (!atomic_inc_not_zero(&ct->ct_general.use))
+		return;
+
+	if (nf_ct_should_gc(ct))
+		nf_ct_kill(ct);
+
+	nf_ct_put(ct);
+}
+
 /*
  * Warning :
  * - Caller must take a reference on returned object
@@ -499,6 +505,17 @@ begin:
 	bucket = reciprocal_scale(hash, hsize);
 
 	hlist_nulls_for_each_entry_rcu(h, n, &ct_hash[bucket], hnnode) {
+		struct nf_conn *ct;
+
+		ct = nf_ct_tuplehash_to_ctrack(h);
+		if (nf_ct_is_expired(ct)) {
+			nf_ct_gc_expired(ct);
+			continue;
+		}
+
+		if (nf_ct_is_dying(ct))
+			continue;
+
 		if (nf_ct_key_equal(h, tuple, zone, net)) {
 			NF_CT_STAT_INC_ATOMIC(net, found);
 			return h;
@@ -597,7 +614,6 @@ nf_conntrack_hash_check_insert(struct nf_conn *ct)
 				    zone, net))
 			goto out;
 
-	add_timer(&ct->timeout);
 	smp_wmb();
 	/* The caller holds a reference to this object */
 	atomic_set(&ct->ct_general.use, 2);
@@ -750,8 +766,7 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	/* Timer relative to confirmation time, not original
 	   setting time, otherwise we'd get timer wrap in
 	   weird delay cases. */
-	ct->timeout.expires += jiffies;
-	add_timer(&ct->timeout);
+	ct->timeout += nfct_time_stamp;
 	atomic_inc(&ct->ct_general.use);
 	ct->status |= IPS_CONFIRMED;
 
@@ -815,8 +830,16 @@ nf_conntrack_tuple_taken(const struct nf_conntrack_tuple *tuple,
 
 	hlist_nulls_for_each_entry_rcu(h, n, &ct_hash[hash], hnnode) {
 		ct = nf_ct_tuplehash_to_ctrack(h);
-		if (ct != ignored_conntrack &&
-		    nf_ct_key_equal(h, tuple, zone, net)) {
+
+		if (ct == ignored_conntrack)
+			continue;
+
+		if (nf_ct_is_expired(ct)) {
+			nf_ct_gc_expired(ct);
+			continue;
+		}
+
+		if (nf_ct_key_equal(h, tuple, zone, net)) {
 			NF_CT_STAT_INC_ATOMIC(net, found);
 			rcu_read_unlock();
 			return 1;
@@ -850,6 +873,11 @@ static unsigned int early_drop_list(struct net *net,
 	hlist_nulls_for_each_entry_rcu(h, n, head, hnnode) {
 		tmp = nf_ct_tuplehash_to_ctrack(h);
 
+		if (nf_ct_is_expired(tmp)) {
+			nf_ct_gc_expired(tmp);
+			continue;
+		}
+
 		if (test_bit(IPS_ASSURED_BIT, &tmp->status) ||
 		    !net_eq(nf_ct_net(tmp), net) ||
 		    nf_ct_is_dying(tmp))
@@ -867,7 +895,6 @@ static unsigned int early_drop_list(struct net *net,
 		 */
 		if (net_eq(nf_ct_net(tmp), net) &&
 		    nf_ct_is_confirmed(tmp) &&
-		    del_timer(&tmp->timeout) &&
 		    nf_ct_delete(tmp, 0, 0))
 			drops++;
 
@@ -937,8 +964,6 @@ __nf_conntrack_alloc(struct net *net,
 	/* save hash for reusing when confirming */
 	*(unsigned long *)(&ct->tuplehash[IP_CT_DIR_REPLY].hnnode.pprev) = hash;
 	ct->status = 0;
-	/* Don't set timer yet: wait for confirmation */
-	setup_timer(&ct->timeout, death_by_timeout, (unsigned long)ct);
 	write_pnet(&ct->ct_net, net);
 	memset(&ct->__nfct_init_offset[0], 0,
 	       offsetof(struct nf_conn, proto) -
@@ -1312,7 +1337,6 @@ void __nf_ct_refresh_acct(struct nf_conn *ct,
 			  unsigned long extra_jiffies,
 			  int do_acct)
 {
-	NF_CT_ASSERT(ct->timeout.data == (unsigned long)ct);
 	NF_CT_ASSERT(skb);
 
 	/* Only update if this is not a fixed timeout */
@@ -1320,18 +1344,10 @@ void __nf_ct_refresh_acct(struct nf_conn *ct,
 		goto acct;
 
 	/* If not in hash table, timer will not be active yet */
-	if (!nf_ct_is_confirmed(ct)) {
-		ct->timeout.expires = extra_jiffies;
-	} else {
-		unsigned long newtime = jiffies + extra_jiffies;
-
-		/* Only update the timeout if the new timeout is at least
-		   HZ jiffies from the old timeout. Need del_timer for race
-		   avoidance (may already be dying). */
-		if (newtime - ct->timeout.expires >= HZ)
-			mod_timer_pending(&ct->timeout, newtime);
-	}
+	if (nf_ct_is_confirmed(ct))
+		extra_jiffies += nfct_time_stamp;
 
+	ct->timeout = extra_jiffies;
 acct:
 	if (do_acct)
 		nf_ct_acct_update(ct, ctinfo, skb->len);
@@ -1346,11 +1362,7 @@ bool __nf_ct_kill_acct(struct nf_conn *ct,
 	if (do_acct)
 		nf_ct_acct_update(ct, ctinfo, skb->len);
 
-	if (del_timer(&ct->timeout)) {
-		ct->timeout.function((unsigned long)ct);
-		return true;
-	}
-	return false;
+	return nf_ct_delete(ct, 0, 0);
 }
 EXPORT_SYMBOL_GPL(__nf_ct_kill_acct);
 
@@ -1485,11 +1497,8 @@ void nf_ct_iterate_cleanup(struct net *net,
 
 	while ((ct = get_next_corpse(net, iter, data, &bucket)) != NULL) {
 		/* Time to push up daises... */
-		if (del_timer(&ct->timeout))
-			nf_ct_delete(ct, portid, report);
-
-		/* ... else the timer will get him soon. */
 
+		nf_ct_delete(ct, portid, report);
 		nf_ct_put(ct);
 		cond_resched();
 	}
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 68800c1..81fd34c 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1144,9 +1144,7 @@ static int ctnetlink_del_conntrack(struct net *net, struct sock *ctnl,
 		}
 	}
 
-	if (del_timer(&ct->timeout))
-		nf_ct_delete(ct, NETLINK_CB(skb).portid, nlmsg_report(nlh));
-
+	nf_ct_delete(ct, NETLINK_CB(skb).portid, nlmsg_report(nlh));
 	nf_ct_put(ct);
 
 	return 0;
@@ -1514,11 +1512,10 @@ static int ctnetlink_change_timeout(struct nf_conn *ct,
 {
 	u_int32_t timeout = ntohl(nla_get_be32(cda[CTA_TIMEOUT]));
 
-	if (!del_timer(&ct->timeout))
-		return -ETIME;
+	ct->timeout = nfct_time_stamp + timeout * HZ;
 
-	ct->timeout.expires = jiffies + timeout * HZ;
-	add_timer(&ct->timeout);
+	if (test_bit(IPS_DYING_BIT, &ct->status))
+		return -ETIME;
 
 	return 0;
 }
@@ -1716,9 +1713,8 @@ ctnetlink_create_conntrack(struct net *net,
 
 	if (!cda[CTA_TIMEOUT])
 		goto err1;
-	ct->timeout.expires = ntohl(nla_get_be32(cda[CTA_TIMEOUT]));
 
-	ct->timeout.expires = jiffies + ct->timeout.expires * HZ;
+	ct->timeout = nfct_time_stamp + ntohl(nla_get_be32(cda[CTA_TIMEOUT])) * HZ;
 
 	rcu_read_lock();
  	if (cda[CTA_HELP]) {
diff --git a/net/netfilter/nf_conntrack_pptp.c b/net/netfilter/nf_conntrack_pptp.c
index 5588c7a..f60a475 100644
--- a/net/netfilter/nf_conntrack_pptp.c
+++ b/net/netfilter/nf_conntrack_pptp.c
@@ -157,8 +157,7 @@ static int destroy_sibling_or_exp(struct net *net, struct nf_conn *ct,
 		pr_debug("setting timeout of conntrack %p to 0\n", sibling);
 		sibling->proto.gre.timeout	  = 0;
 		sibling->proto.gre.stream_timeout = 0;
-		if (del_timer(&sibling->timeout))
-			sibling->timeout.function((unsigned long)sibling);
+		nf_ct_kill(sibling);
 		nf_ct_put(sibling);
 		return 1;
 	} else {
diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index de31818..81ae41f 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -565,16 +565,10 @@ static int nf_nat_proto_clean(struct nf_conn *ct, void *data)
 	 * Else, when the conntrack is destoyed, nf_nat_cleanup_conntrack()
 	 * will delete entry from already-freed table.
 	 */
-	if (!del_timer(&ct->timeout))
-		return 1;
-
 	ct->status &= ~IPS_NAT_DONE_MASK;
-
 	rhashtable_remove_fast(&nf_nat_bysource_table, &ct->nat_bysource,
 			       nf_nat_bysource_params);
 
-	add_timer(&ct->timeout);
-
 	/* don't delete conntrack.  Although that would make things a lot
 	 * simpler, we'd end up flushing all conntracks on nat rmmod.
 	 */
-- 
2.1.4
