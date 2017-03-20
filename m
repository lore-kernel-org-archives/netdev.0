From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 21/22] netfilter: refcounter conversions
Date: Mon, 20 Mar 2017 11:08:49 +0100
Message-ID: <1490004530-9128-22-git-send-email-pablo@netfilter.org>
References: <1490004530-9128-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1490004530-9128-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Reshetova, Elena" <elena.reshetova@intel.com>

refcount_t type and corresponding API (see include/linux/refcount.h)
should be used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: David Windsor <dwindsor@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/ip_vs.h                          | 16 +++++++++-------
 include/net/netfilter/nf_conntrack_expect.h  |  4 +++-
 include/net/netfilter/nf_conntrack_timeout.h |  3 ++-
 net/ipv4/netfilter/ipt_CLUSTERIP.c           | 19 ++++++++++---------
 net/netfilter/ipvs/ip_vs_conn.c              | 24 ++++++++++++------------
 net/netfilter/ipvs/ip_vs_core.c              |  4 ++--
 net/netfilter/ipvs/ip_vs_ctl.c               | 12 ++++++------
 net/netfilter/ipvs/ip_vs_lblc.c              |  2 +-
 net/netfilter/ipvs/ip_vs_lblcr.c             |  6 +++---
 net/netfilter/ipvs/ip_vs_nq.c                |  2 +-
 net/netfilter/ipvs/ip_vs_proto_sctp.c        |  2 +-
 net/netfilter/ipvs/ip_vs_proto_tcp.c         |  2 +-
 net/netfilter/ipvs/ip_vs_rr.c                |  2 +-
 net/netfilter/ipvs/ip_vs_sed.c               |  2 +-
 net/netfilter/ipvs/ip_vs_wlc.c               |  2 +-
 net/netfilter/ipvs/ip_vs_wrr.c               |  2 +-
 net/netfilter/nf_conntrack_expect.c          | 10 +++++-----
 net/netfilter/nf_conntrack_netlink.c         |  4 ++--
 net/netfilter/nfnetlink_acct.c               | 16 +++++++++-------
 net/netfilter/nfnetlink_cttimeout.c          | 12 ++++++------
 net/netfilter/nfnetlink_log.c                | 14 ++++++++------
 21 files changed, 85 insertions(+), 75 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 7bdfa7d78363..8a4a57b887fb 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -12,6 +12,8 @@
 #include <linux/list.h>                 /* for struct list_head */
 #include <linux/spinlock.h>             /* for struct rwlock_t */
 #include <linux/atomic.h>               /* for struct atomic_t */
+#include <linux/refcount.h>             /* for struct refcount_t */
+
 #include <linux/compiler.h>
 #include <linux/timer.h>
 #include <linux/bug.h>
@@ -525,7 +527,7 @@ struct ip_vs_conn {
 	struct netns_ipvs	*ipvs;
 
 	/* counter and timer */
-	atomic_t		refcnt;		/* reference count */
+	refcount_t		refcnt;		/* reference count */
 	struct timer_list	timer;		/* Expiration timer */
 	volatile unsigned long	timeout;	/* timeout */
 
@@ -667,7 +669,7 @@ struct ip_vs_dest {
 	atomic_t		conn_flags;	/* flags to copy to conn */
 	atomic_t		weight;		/* server weight */
 
-	atomic_t		refcnt;		/* reference counter */
+	refcount_t		refcnt;		/* reference counter */
 	struct ip_vs_stats      stats;          /* statistics */
 	unsigned long		idle_start;	/* start time, jiffies */
 
@@ -1211,14 +1213,14 @@ struct ip_vs_conn * ip_vs_conn_out_get_proto(struct netns_ipvs *ipvs, int af,
  */
 static inline bool __ip_vs_conn_get(struct ip_vs_conn *cp)
 {
-	return atomic_inc_not_zero(&cp->refcnt);
+	return refcount_inc_not_zero(&cp->refcnt);
 }
 
 /* put back the conn without restarting its timer */
 static inline void __ip_vs_conn_put(struct ip_vs_conn *cp)
 {
 	smp_mb__before_atomic();
-	atomic_dec(&cp->refcnt);
+	refcount_dec(&cp->refcnt);
 }
 void ip_vs_conn_put(struct ip_vs_conn *cp);
 void ip_vs_conn_fill_cport(struct ip_vs_conn *cp, __be16 cport);
@@ -1410,18 +1412,18 @@ void ip_vs_try_bind_dest(struct ip_vs_conn *cp);
 
 static inline void ip_vs_dest_hold(struct ip_vs_dest *dest)
 {
-	atomic_inc(&dest->refcnt);
+	refcount_inc(&dest->refcnt);
 }
 
 static inline void ip_vs_dest_put(struct ip_vs_dest *dest)
 {
 	smp_mb__before_atomic();
-	atomic_dec(&dest->refcnt);
+	refcount_dec(&dest->refcnt);
 }
 
 static inline void ip_vs_dest_put_and_free(struct ip_vs_dest *dest)
 {
-	if (atomic_dec_and_test(&dest->refcnt))
+	if (refcount_dec_and_test(&dest->refcnt))
 		kfree(dest);
 }
 
diff --git a/include/net/netfilter/nf_conntrack_expect.h b/include/net/netfilter/nf_conntrack_expect.h
index 5ed33ea4718e..65cc2cb005d9 100644
--- a/include/net/netfilter/nf_conntrack_expect.h
+++ b/include/net/netfilter/nf_conntrack_expect.h
@@ -5,6 +5,8 @@
 #ifndef _NF_CONNTRACK_EXPECT_H
 #define _NF_CONNTRACK_EXPECT_H
 
+#include <linux/refcount.h>
+
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_conntrack_zones.h>
 
@@ -37,7 +39,7 @@ struct nf_conntrack_expect {
 	struct timer_list timeout;
 
 	/* Usage count. */
-	atomic_t use;
+	refcount_t use;
 
 	/* Flags */
 	unsigned int flags;
diff --git a/include/net/netfilter/nf_conntrack_timeout.h b/include/net/netfilter/nf_conntrack_timeout.h
index 5cc5e9e6171a..d40b89355fdd 100644
--- a/include/net/netfilter/nf_conntrack_timeout.h
+++ b/include/net/netfilter/nf_conntrack_timeout.h
@@ -4,6 +4,7 @@
 #include <net/net_namespace.h>
 #include <linux/netfilter/nf_conntrack_common.h>
 #include <linux/netfilter/nf_conntrack_tuple_common.h>
+#include <linux/refcount.h>
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_conntrack_extend.h>
 
@@ -12,7 +13,7 @@
 struct ctnl_timeout {
 	struct list_head	head;
 	struct rcu_head		rcu_head;
-	atomic_t		refcnt;
+	refcount_t		refcnt;
 	char			name[CTNL_TIMEOUT_NAME_MAX];
 	__u16			l3num;
 	struct nf_conntrack_l4proto *l4proto;
diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index 52f26459efc3..fcbdc0c49b0e 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -22,6 +22,7 @@
 #include <linux/icmp.h>
 #include <linux/if_arp.h>
 #include <linux/seq_file.h>
+#include <linux/refcount.h>
 #include <linux/netfilter_arp.h>
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter_ipv4/ip_tables.h>
@@ -40,8 +41,8 @@ MODULE_DESCRIPTION("Xtables: CLUSTERIP target");
 
 struct clusterip_config {
 	struct list_head list;			/* list of all configs */
-	atomic_t refcount;			/* reference count */
-	atomic_t entries;			/* number of entries/rules
+	refcount_t refcount;			/* reference count */
+	refcount_t entries;			/* number of entries/rules
 						 * referencing us */
 
 	__be32 clusterip;			/* the IP address */
@@ -77,7 +78,7 @@ struct clusterip_net {
 static inline void
 clusterip_config_get(struct clusterip_config *c)
 {
-	atomic_inc(&c->refcount);
+	refcount_inc(&c->refcount);
 }
 
 
@@ -89,7 +90,7 @@ static void clusterip_config_rcu_free(struct rcu_head *head)
 static inline void
 clusterip_config_put(struct clusterip_config *c)
 {
-	if (atomic_dec_and_test(&c->refcount))
+	if (refcount_dec_and_test(&c->refcount))
 		call_rcu_bh(&c->rcu, clusterip_config_rcu_free);
 }
 
@@ -103,7 +104,7 @@ clusterip_config_entry_put(struct clusterip_config *c)
 	struct clusterip_net *cn = net_generic(net, clusterip_net_id);
 
 	local_bh_disable();
-	if (atomic_dec_and_lock(&c->entries, &cn->lock)) {
+	if (refcount_dec_and_lock(&c->entries, &cn->lock)) {
 		list_del_rcu(&c->list);
 		spin_unlock(&cn->lock);
 		local_bh_enable();
@@ -149,10 +150,10 @@ clusterip_config_find_get(struct net *net, __be32 clusterip, int entry)
 			c = NULL;
 		else
 #endif
-		if (unlikely(!atomic_inc_not_zero(&c->refcount)))
+		if (unlikely(!refcount_inc_not_zero(&c->refcount)))
 			c = NULL;
 		else if (entry)
-			atomic_inc(&c->entries);
+			refcount_inc(&c->entries);
 	}
 	rcu_read_unlock_bh();
 
@@ -188,8 +189,8 @@ clusterip_config_init(const struct ipt_clusterip_tgt_info *i, __be32 ip,
 	clusterip_config_init_nodelist(c, i);
 	c->hash_mode = i->hash_mode;
 	c->hash_initval = i->hash_initval;
-	atomic_set(&c->refcount, 1);
-	atomic_set(&c->entries, 1);
+	refcount_set(&c->refcount, 1);
+	refcount_set(&c->entries, 1);
 
 	spin_lock_bh(&cn->lock);
 	if (__clusterip_config_find(net, ip)) {
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index e6a2753dff9e..3d2ac71a83ec 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -181,7 +181,7 @@ static inline int ip_vs_conn_hash(struct ip_vs_conn *cp)
 
 	if (!(cp->flags & IP_VS_CONN_F_HASHED)) {
 		cp->flags |= IP_VS_CONN_F_HASHED;
-		atomic_inc(&cp->refcnt);
+		refcount_inc(&cp->refcnt);
 		hlist_add_head_rcu(&cp->c_list, &ip_vs_conn_tab[hash]);
 		ret = 1;
 	} else {
@@ -215,7 +215,7 @@ static inline int ip_vs_conn_unhash(struct ip_vs_conn *cp)
 	if (cp->flags & IP_VS_CONN_F_HASHED) {
 		hlist_del_rcu(&cp->c_list);
 		cp->flags &= ~IP_VS_CONN_F_HASHED;
-		atomic_dec(&cp->refcnt);
+		refcount_dec(&cp->refcnt);
 		ret = 1;
 	} else
 		ret = 0;
@@ -242,13 +242,13 @@ static inline bool ip_vs_conn_unlink(struct ip_vs_conn *cp)
 	if (cp->flags & IP_VS_CONN_F_HASHED) {
 		ret = false;
 		/* Decrease refcnt and unlink conn only if we are last user */
-		if (atomic_cmpxchg(&cp->refcnt, 1, 0) == 1) {
+		if (refcount_dec_if_one(&cp->refcnt)) {
 			hlist_del_rcu(&cp->c_list);
 			cp->flags &= ~IP_VS_CONN_F_HASHED;
 			ret = true;
 		}
 	} else
-		ret = atomic_read(&cp->refcnt) ? false : true;
+		ret = refcount_read(&cp->refcnt) ? false : true;
 
 	spin_unlock(&cp->lock);
 	ct_write_unlock_bh(hash);
@@ -475,7 +475,7 @@ static void __ip_vs_conn_put_timer(struct ip_vs_conn *cp)
 void ip_vs_conn_put(struct ip_vs_conn *cp)
 {
 	if ((cp->flags & IP_VS_CONN_F_ONE_PACKET) &&
-	    (atomic_read(&cp->refcnt) == 1) &&
+	    (refcount_read(&cp->refcnt) == 1) &&
 	    !timer_pending(&cp->timer))
 		/* expire connection immediately */
 		__ip_vs_conn_put_notimer(cp);
@@ -617,8 +617,8 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
 		      IP_VS_DBG_ADDR(cp->af, &cp->vaddr), ntohs(cp->vport),
 		      IP_VS_DBG_ADDR(cp->daf, &cp->daddr), ntohs(cp->dport),
 		      ip_vs_fwd_tag(cp), cp->state,
-		      cp->flags, atomic_read(&cp->refcnt),
-		      atomic_read(&dest->refcnt));
+		      cp->flags, refcount_read(&cp->refcnt),
+		      refcount_read(&dest->refcnt));
 
 	/* Update the connection counters */
 	if (!(flags & IP_VS_CONN_F_TEMPLATE)) {
@@ -714,8 +714,8 @@ static inline void ip_vs_unbind_dest(struct ip_vs_conn *cp)
 		      IP_VS_DBG_ADDR(cp->af, &cp->vaddr), ntohs(cp->vport),
 		      IP_VS_DBG_ADDR(cp->daf, &cp->daddr), ntohs(cp->dport),
 		      ip_vs_fwd_tag(cp), cp->state,
-		      cp->flags, atomic_read(&cp->refcnt),
-		      atomic_read(&dest->refcnt));
+		      cp->flags, refcount_read(&cp->refcnt),
+		      refcount_read(&dest->refcnt));
 
 	/* Update the connection counters */
 	if (!(cp->flags & IP_VS_CONN_F_TEMPLATE)) {
@@ -863,10 +863,10 @@ static void ip_vs_conn_expire(unsigned long data)
 
   expire_later:
 	IP_VS_DBG(7, "delayed: conn->refcnt=%d conn->n_control=%d\n",
-		  atomic_read(&cp->refcnt),
+		  refcount_read(&cp->refcnt),
 		  atomic_read(&cp->n_control));
 
-	atomic_inc(&cp->refcnt);
+	refcount_inc(&cp->refcnt);
 	cp->timeout = 60*HZ;
 
 	if (ipvs->sync_state & IP_VS_STATE_MASTER)
@@ -941,7 +941,7 @@ ip_vs_conn_new(const struct ip_vs_conn_param *p, int dest_af,
 	 * it in the table, so that other thread run ip_vs_random_dropentry
 	 * but cannot drop this entry.
 	 */
-	atomic_set(&cp->refcnt, 1);
+	refcount_set(&cp->refcnt, 1);
 
 	cp->control = NULL;
 	atomic_set(&cp->n_control, 0);
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 9aaa49025cdc..b4a746d0e39b 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -542,7 +542,7 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 		      IP_VS_DBG_ADDR(cp->af, &cp->caddr), ntohs(cp->cport),
 		      IP_VS_DBG_ADDR(cp->af, &cp->vaddr), ntohs(cp->vport),
 		      IP_VS_DBG_ADDR(cp->daf, &cp->daddr), ntohs(cp->dport),
-		      cp->flags, atomic_read(&cp->refcnt));
+		      cp->flags, refcount_read(&cp->refcnt));
 
 	ip_vs_conn_stats(cp, svc);
 	return cp;
@@ -1193,7 +1193,7 @@ struct ip_vs_conn *ip_vs_new_conn_out(struct ip_vs_service *svc,
 		      IP_VS_DBG_ADDR(cp->af, &cp->caddr), ntohs(cp->cport),
 		      IP_VS_DBG_ADDR(cp->af, &cp->vaddr), ntohs(cp->vport),
 		      IP_VS_DBG_ADDR(cp->af, &cp->daddr), ntohs(cp->dport),
-		      cp->flags, atomic_read(&cp->refcnt));
+		      cp->flags, refcount_read(&cp->refcnt));
 	LeaveFunction(12);
 	return cp;
 }
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 5aeb0dde6ccc..541aa7694775 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -699,7 +699,7 @@ ip_vs_trash_get_dest(struct ip_vs_service *svc, int dest_af,
 			      dest->vfwmark,
 			      IP_VS_DBG_ADDR(dest->af, &dest->addr),
 			      ntohs(dest->port),
-			      atomic_read(&dest->refcnt));
+			      refcount_read(&dest->refcnt));
 		if (dest->af == dest_af &&
 		    ip_vs_addr_equal(dest_af, &dest->addr, daddr) &&
 		    dest->port == dport &&
@@ -934,7 +934,7 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
 	atomic_set(&dest->activeconns, 0);
 	atomic_set(&dest->inactconns, 0);
 	atomic_set(&dest->persistconns, 0);
-	atomic_set(&dest->refcnt, 1);
+	refcount_set(&dest->refcnt, 1);
 
 	INIT_HLIST_NODE(&dest->d_list);
 	spin_lock_init(&dest->dst_lock);
@@ -998,7 +998,7 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 		IP_VS_DBG_BUF(3, "Get destination %s:%u from trash, "
 			      "dest->refcnt=%d, service %u/%s:%u\n",
 			      IP_VS_DBG_ADDR(udest->af, &daddr), ntohs(dport),
-			      atomic_read(&dest->refcnt),
+			      refcount_read(&dest->refcnt),
 			      dest->vfwmark,
 			      IP_VS_DBG_ADDR(svc->af, &dest->vaddr),
 			      ntohs(dest->vport));
@@ -1074,7 +1074,7 @@ static void __ip_vs_del_dest(struct netns_ipvs *ipvs, struct ip_vs_dest *dest,
 	spin_lock_bh(&ipvs->dest_trash_lock);
 	IP_VS_DBG_BUF(3, "Moving dest %s:%u into trash, dest->refcnt=%d\n",
 		      IP_VS_DBG_ADDR(dest->af, &dest->addr), ntohs(dest->port),
-		      atomic_read(&dest->refcnt));
+		      refcount_read(&dest->refcnt));
 	if (list_empty(&ipvs->dest_trash) && !cleanup)
 		mod_timer(&ipvs->dest_trash_timer,
 			  jiffies + (IP_VS_DEST_TRASH_PERIOD >> 1));
@@ -1157,7 +1157,7 @@ static void ip_vs_dest_trash_expire(unsigned long data)
 
 	spin_lock(&ipvs->dest_trash_lock);
 	list_for_each_entry_safe(dest, next, &ipvs->dest_trash, t_list) {
-		if (atomic_read(&dest->refcnt) > 1)
+		if (refcount_read(&dest->refcnt) > 1)
 			continue;
 		if (dest->idle_start) {
 			if (time_before(now, dest->idle_start +
@@ -1545,7 +1545,7 @@ ip_vs_forget_dev(struct ip_vs_dest *dest, struct net_device *dev)
 			      dev->name,
 			      IP_VS_DBG_ADDR(dest->af, &dest->addr),
 			      ntohs(dest->port),
-			      atomic_read(&dest->refcnt));
+			      refcount_read(&dest->refcnt));
 		__ip_vs_dst_cache_reset(dest);
 	}
 	spin_unlock_bh(&dest->dst_lock);
diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index 5824927cf8e0..b6aa4a970c6e 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -448,7 +448,7 @@ __ip_vs_lblc_schedule(struct ip_vs_service *svc)
 		      IP_VS_DBG_ADDR(least->af, &least->addr),
 		      ntohs(least->port),
 		      atomic_read(&least->activeconns),
-		      atomic_read(&least->refcnt),
+		      refcount_read(&least->refcnt),
 		      atomic_read(&least->weight), loh);
 
 	return least;
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index 703f11877bee..c13ff575f9f7 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -204,7 +204,7 @@ static inline struct ip_vs_dest *ip_vs_dest_set_min(struct ip_vs_dest_set *set)
 		      IP_VS_DBG_ADDR(least->af, &least->addr),
 		      ntohs(least->port),
 		      atomic_read(&least->activeconns),
-		      atomic_read(&least->refcnt),
+		      refcount_read(&least->refcnt),
 		      atomic_read(&least->weight), loh);
 	return least;
 }
@@ -249,7 +249,7 @@ static inline struct ip_vs_dest *ip_vs_dest_set_max(struct ip_vs_dest_set *set)
 		      __func__,
 		      IP_VS_DBG_ADDR(most->af, &most->addr), ntohs(most->port),
 		      atomic_read(&most->activeconns),
-		      atomic_read(&most->refcnt),
+		      refcount_read(&most->refcnt),
 		      atomic_read(&most->weight), moh);
 	return most;
 }
@@ -612,7 +612,7 @@ __ip_vs_lblcr_schedule(struct ip_vs_service *svc)
 		      IP_VS_DBG_ADDR(least->af, &least->addr),
 		      ntohs(least->port),
 		      atomic_read(&least->activeconns),
-		      atomic_read(&least->refcnt),
+		      refcount_read(&least->refcnt),
 		      atomic_read(&least->weight), loh);
 
 	return least;
diff --git a/net/netfilter/ipvs/ip_vs_nq.c b/net/netfilter/ipvs/ip_vs_nq.c
index a8b63401e773..7d9d4ac596ca 100644
--- a/net/netfilter/ipvs/ip_vs_nq.c
+++ b/net/netfilter/ipvs/ip_vs_nq.c
@@ -110,7 +110,7 @@ ip_vs_nq_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 		      IP_VS_DBG_ADDR(least->af, &least->addr),
 		      ntohs(least->port),
 		      atomic_read(&least->activeconns),
-		      atomic_read(&least->refcnt),
+		      refcount_read(&least->refcnt),
 		      atomic_read(&least->weight), loh);
 
 	return least;
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index d952d67f904d..56f8e4b204ff 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -447,7 +447,7 @@ set_sctp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
 				ntohs(cp->cport),
 				sctp_state_name(cp->state),
 				sctp_state_name(next_state),
-				atomic_read(&cp->refcnt));
+				refcount_read(&cp->refcnt));
 		if (dest) {
 			if (!(cp->flags & IP_VS_CONN_F_INACTIVE) &&
 				(next_state != IP_VS_SCTP_S_ESTABLISHED)) {
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 5117bcb7d2f0..12dc8d5bc37d 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -557,7 +557,7 @@ set_tcp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
 			      ntohs(cp->cport),
 			      tcp_state_name(cp->state),
 			      tcp_state_name(new_state),
-			      atomic_read(&cp->refcnt));
+			      refcount_read(&cp->refcnt));
 
 		if (dest) {
 			if (!(cp->flags & IP_VS_CONN_F_INACTIVE) &&
diff --git a/net/netfilter/ipvs/ip_vs_rr.c b/net/netfilter/ipvs/ip_vs_rr.c
index 58bacfc461ee..ee0530d14c5f 100644
--- a/net/netfilter/ipvs/ip_vs_rr.c
+++ b/net/netfilter/ipvs/ip_vs_rr.c
@@ -97,7 +97,7 @@ ip_vs_rr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 		      "activeconns %d refcnt %d weight %d\n",
 		      IP_VS_DBG_ADDR(dest->af, &dest->addr), ntohs(dest->port),
 		      atomic_read(&dest->activeconns),
-		      atomic_read(&dest->refcnt), atomic_read(&dest->weight));
+		      refcount_read(&dest->refcnt), atomic_read(&dest->weight));
 
 	return dest;
 }
diff --git a/net/netfilter/ipvs/ip_vs_sed.c b/net/netfilter/ipvs/ip_vs_sed.c
index f8e2d00f528b..ab23cf203437 100644
--- a/net/netfilter/ipvs/ip_vs_sed.c
+++ b/net/netfilter/ipvs/ip_vs_sed.c
@@ -111,7 +111,7 @@ ip_vs_sed_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 		      IP_VS_DBG_ADDR(least->af, &least->addr),
 		      ntohs(least->port),
 		      atomic_read(&least->activeconns),
-		      atomic_read(&least->refcnt),
+		      refcount_read(&least->refcnt),
 		      atomic_read(&least->weight), loh);
 
 	return least;
diff --git a/net/netfilter/ipvs/ip_vs_wlc.c b/net/netfilter/ipvs/ip_vs_wlc.c
index 6b366fd90554..6add39e0ec20 100644
--- a/net/netfilter/ipvs/ip_vs_wlc.c
+++ b/net/netfilter/ipvs/ip_vs_wlc.c
@@ -83,7 +83,7 @@ ip_vs_wlc_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 		      IP_VS_DBG_ADDR(least->af, &least->addr),
 		      ntohs(least->port),
 		      atomic_read(&least->activeconns),
-		      atomic_read(&least->refcnt),
+		      refcount_read(&least->refcnt),
 		      atomic_read(&least->weight), loh);
 
 	return least;
diff --git a/net/netfilter/ipvs/ip_vs_wrr.c b/net/netfilter/ipvs/ip_vs_wrr.c
index 17e6d4406ca7..62258dd457ac 100644
--- a/net/netfilter/ipvs/ip_vs_wrr.c
+++ b/net/netfilter/ipvs/ip_vs_wrr.c
@@ -218,7 +218,7 @@ ip_vs_wrr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 		      "activeconns %d refcnt %d weight %d\n",
 		      IP_VS_DBG_ADDR(dest->af, &dest->addr), ntohs(dest->port),
 		      atomic_read(&dest->activeconns),
-		      atomic_read(&dest->refcnt),
+		      refcount_read(&dest->refcnt),
 		      atomic_read(&dest->weight));
 	mark->cl = dest;
 
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index 4b2e1fb28bb4..cb29e598605f 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -133,7 +133,7 @@ nf_ct_expect_find_get(struct net *net,
 
 	rcu_read_lock();
 	i = __nf_ct_expect_find(net, zone, tuple);
-	if (i && !atomic_inc_not_zero(&i->use))
+	if (i && !refcount_inc_not_zero(&i->use))
 		i = NULL;
 	rcu_read_unlock();
 
@@ -186,7 +186,7 @@ nf_ct_find_expectation(struct net *net,
 		return NULL;
 
 	if (exp->flags & NF_CT_EXPECT_PERMANENT) {
-		atomic_inc(&exp->use);
+		refcount_inc(&exp->use);
 		return exp;
 	} else if (del_timer(&exp->timeout)) {
 		nf_ct_unlink_expect(exp);
@@ -275,7 +275,7 @@ struct nf_conntrack_expect *nf_ct_expect_alloc(struct nf_conn *me)
 		return NULL;
 
 	new->master = me;
-	atomic_set(&new->use, 1);
+	refcount_set(&new->use, 1);
 	return new;
 }
 EXPORT_SYMBOL_GPL(nf_ct_expect_alloc);
@@ -348,7 +348,7 @@ static void nf_ct_expect_free_rcu(struct rcu_head *head)
 
 void nf_ct_expect_put(struct nf_conntrack_expect *exp)
 {
-	if (atomic_dec_and_test(&exp->use))
+	if (refcount_dec_and_test(&exp->use))
 		call_rcu(&exp->rcu, nf_ct_expect_free_rcu);
 }
 EXPORT_SYMBOL_GPL(nf_ct_expect_put);
@@ -361,7 +361,7 @@ static void nf_ct_expect_insert(struct nf_conntrack_expect *exp)
 	unsigned int h = nf_ct_expect_dst_hash(net, &exp->tuple);
 
 	/* two references : one for hash insert, one for the timer */
-	atomic_add(2, &exp->use);
+	refcount_add(2, &exp->use);
 
 	hlist_add_head(&exp->lnode, &master_help->expectations);
 	master_help->expecting[exp->class]++;
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 6806b5e73567..d49cc1e03c5b 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -2693,7 +2693,7 @@ ctnetlink_exp_dump_table(struct sk_buff *skb, struct netlink_callback *cb)
 						    cb->nlh->nlmsg_seq,
 						    IPCTNL_MSG_EXP_NEW,
 						    exp) < 0) {
-				if (!atomic_inc_not_zero(&exp->use))
+				if (!refcount_inc_not_zero(&exp->use))
 					continue;
 				cb->args[1] = (unsigned long)exp;
 				goto out;
@@ -2739,7 +2739,7 @@ ctnetlink_exp_ct_dump_table(struct sk_buff *skb, struct netlink_callback *cb)
 					    cb->nlh->nlmsg_seq,
 					    IPCTNL_MSG_EXP_NEW,
 					    exp) < 0) {
-			if (!atomic_inc_not_zero(&exp->use))
+			if (!refcount_inc_not_zero(&exp->use))
 				continue;
 			cb->args[1] = (unsigned long)exp;
 			goto out;
diff --git a/net/netfilter/nfnetlink_acct.c b/net/netfilter/nfnetlink_acct.c
index d44d89b56127..f44cbd35357f 100644
--- a/net/netfilter/nfnetlink_acct.c
+++ b/net/netfilter/nfnetlink_acct.c
@@ -11,6 +11,7 @@
 #include <linux/kernel.h>
 #include <linux/skbuff.h>
 #include <linux/atomic.h>
+#include <linux/refcount.h>
 #include <linux/netlink.h>
 #include <linux/rculist.h>
 #include <linux/slab.h>
@@ -32,7 +33,7 @@ struct nf_acct {
 	atomic64_t		bytes;
 	unsigned long		flags;
 	struct list_head	head;
-	atomic_t		refcnt;
+	refcount_t		refcnt;
 	char			name[NFACCT_NAME_MAX];
 	struct rcu_head		rcu_head;
 	char			data[0];
@@ -123,7 +124,7 @@ static int nfnl_acct_new(struct net *net, struct sock *nfnl,
 		atomic64_set(&nfacct->pkts,
 			     be64_to_cpu(nla_get_be64(tb[NFACCT_PKTS])));
 	}
-	atomic_set(&nfacct->refcnt, 1);
+	refcount_set(&nfacct->refcnt, 1);
 	list_add_tail_rcu(&nfacct->head, &net->nfnl_acct_list);
 	return 0;
 }
@@ -166,7 +167,7 @@ nfnl_acct_fill_info(struct sk_buff *skb, u32 portid, u32 seq, u32 type,
 			 NFACCT_PAD) ||
 	    nla_put_be64(skb, NFACCT_BYTES, cpu_to_be64(bytes),
 			 NFACCT_PAD) ||
-	    nla_put_be32(skb, NFACCT_USE, htonl(atomic_read(&acct->refcnt))))
+	    nla_put_be32(skb, NFACCT_USE, htonl(refcount_read(&acct->refcnt))))
 		goto nla_put_failure;
 	if (acct->flags & NFACCT_F_QUOTA) {
 		u64 *quota = (u64 *)acct->data;
@@ -325,11 +326,12 @@ static int nfnl_acct_get(struct net *net, struct sock *nfnl,
 static int nfnl_acct_try_del(struct nf_acct *cur)
 {
 	int ret = 0;
+	unsigned int refcount;
 
 	/* We want to avoid races with nfnl_acct_put. So only when the current
 	 * refcnt is 1, we decrease it to 0.
 	 */
-	if (atomic_cmpxchg(&cur->refcnt, 1, 0) == 1) {
+	if (refcount_dec_if_one(&cur->refcnt)) {
 		/* We are protected by nfnl mutex. */
 		list_del_rcu(&cur->head);
 		kfree_rcu(cur, rcu_head);
@@ -413,7 +415,7 @@ struct nf_acct *nfnl_acct_find_get(struct net *net, const char *acct_name)
 		if (!try_module_get(THIS_MODULE))
 			goto err;
 
-		if (!atomic_inc_not_zero(&cur->refcnt)) {
+		if (!refcount_inc_not_zero(&cur->refcnt)) {
 			module_put(THIS_MODULE);
 			goto err;
 		}
@@ -429,7 +431,7 @@ EXPORT_SYMBOL_GPL(nfnl_acct_find_get);
 
 void nfnl_acct_put(struct nf_acct *acct)
 {
-	if (atomic_dec_and_test(&acct->refcnt))
+	if (refcount_dec_and_test(&acct->refcnt))
 		kfree_rcu(acct, rcu_head);
 
 	module_put(THIS_MODULE);
@@ -502,7 +504,7 @@ static void __net_exit nfnl_acct_net_exit(struct net *net)
 	list_for_each_entry_safe(cur, tmp, &net->nfnl_acct_list, head) {
 		list_del_rcu(&cur->head);
 
-		if (atomic_dec_and_test(&cur->refcnt))
+		if (refcount_dec_and_test(&cur->refcnt))
 			kfree_rcu(cur, rcu_head);
 	}
 }
diff --git a/net/netfilter/nfnetlink_cttimeout.c b/net/netfilter/nfnetlink_cttimeout.c
index 139e0867e56e..baa75f3ab7e7 100644
--- a/net/netfilter/nfnetlink_cttimeout.c
+++ b/net/netfilter/nfnetlink_cttimeout.c
@@ -138,7 +138,7 @@ static int cttimeout_new_timeout(struct net *net, struct sock *ctnl,
 	strcpy(timeout->name, nla_data(cda[CTA_TIMEOUT_NAME]));
 	timeout->l3num = l3num;
 	timeout->l4proto = l4proto;
-	atomic_set(&timeout->refcnt, 1);
+	refcount_set(&timeout->refcnt, 1);
 	list_add_tail_rcu(&timeout->head, &net->nfct_timeout_list);
 
 	return 0;
@@ -172,7 +172,7 @@ ctnl_timeout_fill_info(struct sk_buff *skb, u32 portid, u32 seq, u32 type,
 	    nla_put_be16(skb, CTA_TIMEOUT_L3PROTO, htons(timeout->l3num)) ||
 	    nla_put_u8(skb, CTA_TIMEOUT_L4PROTO, timeout->l4proto->l4proto) ||
 	    nla_put_be32(skb, CTA_TIMEOUT_USE,
-			 htonl(atomic_read(&timeout->refcnt))))
+			 htonl(refcount_read(&timeout->refcnt))))
 		goto nla_put_failure;
 
 	if (likely(l4proto->ctnl_timeout.obj_to_nlattr)) {
@@ -339,7 +339,7 @@ static int ctnl_timeout_try_del(struct net *net, struct ctnl_timeout *timeout)
 	/* We want to avoid races with ctnl_timeout_put. So only when the
 	 * current refcnt is 1, we decrease it to 0.
 	 */
-	if (atomic_cmpxchg(&timeout->refcnt, 1, 0) == 1) {
+	if (refcount_dec_if_one(&timeout->refcnt)) {
 		/* We are protected by nfnl mutex. */
 		list_del_rcu(&timeout->head);
 		nf_ct_l4proto_put(timeout->l4proto);
@@ -536,7 +536,7 @@ ctnl_timeout_find_get(struct net *net, const char *name)
 		if (!try_module_get(THIS_MODULE))
 			goto err;
 
-		if (!atomic_inc_not_zero(&timeout->refcnt)) {
+		if (!refcount_inc_not_zero(&timeout->refcnt)) {
 			module_put(THIS_MODULE);
 			goto err;
 		}
@@ -550,7 +550,7 @@ ctnl_timeout_find_get(struct net *net, const char *name)
 
 static void ctnl_timeout_put(struct ctnl_timeout *timeout)
 {
-	if (atomic_dec_and_test(&timeout->refcnt))
+	if (refcount_dec_and_test(&timeout->refcnt))
 		kfree_rcu(timeout, rcu_head);
 
 	module_put(THIS_MODULE);
@@ -601,7 +601,7 @@ static void __net_exit cttimeout_net_exit(struct net *net)
 		list_del_rcu(&cur->head);
 		nf_ct_l4proto_put(cur->l4proto);
 
-		if (atomic_dec_and_test(&cur->refcnt))
+		if (refcount_dec_and_test(&cur->refcnt))
 			kfree_rcu(cur, rcu_head);
 	}
 }
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 08247bf7d7b8..ecd857b75ffe 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -40,6 +40,8 @@
 #include <net/netfilter/nfnetlink_log.h>
 
 #include <linux/atomic.h>
+#include <linux/refcount.h>
+
 
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 #include "../bridge/br_private.h"
@@ -57,7 +59,7 @@
 struct nfulnl_instance {
 	struct hlist_node hlist;	/* global list of instances */
 	spinlock_t lock;
-	atomic_t use;			/* use count */
+	refcount_t use;			/* use count */
 
 	unsigned int qlen;		/* number of nlmsgs in skb */
 	struct sk_buff *skb;		/* pre-allocatd skb */
@@ -115,7 +117,7 @@ __instance_lookup(struct nfnl_log_net *log, u_int16_t group_num)
 static inline void
 instance_get(struct nfulnl_instance *inst)
 {
-	atomic_inc(&inst->use);
+	refcount_inc(&inst->use);
 }
 
 static struct nfulnl_instance *
@@ -125,7 +127,7 @@ instance_lookup_get(struct nfnl_log_net *log, u_int16_t group_num)
 
 	rcu_read_lock_bh();
 	inst = __instance_lookup(log, group_num);
-	if (inst && !atomic_inc_not_zero(&inst->use))
+	if (inst && !refcount_inc_not_zero(&inst->use))
 		inst = NULL;
 	rcu_read_unlock_bh();
 
@@ -145,7 +147,7 @@ static void nfulnl_instance_free_rcu(struct rcu_head *head)
 static void
 instance_put(struct nfulnl_instance *inst)
 {
-	if (inst && atomic_dec_and_test(&inst->use))
+	if (inst && refcount_dec_and_test(&inst->use))
 		call_rcu_bh(&inst->rcu, nfulnl_instance_free_rcu);
 }
 
@@ -180,7 +182,7 @@ instance_create(struct net *net, u_int16_t group_num,
 	INIT_HLIST_NODE(&inst->hlist);
 	spin_lock_init(&inst->lock);
 	/* needs to be two, since we _put() after creation */
-	atomic_set(&inst->use, 2);
+	refcount_set(&inst->use, 2);
 
 	setup_timer(&inst->timer, nfulnl_timer, (unsigned long)inst);
 
@@ -1031,7 +1033,7 @@ static int seq_show(struct seq_file *s, void *v)
 		   inst->group_num,
 		   inst->peer_portid, inst->qlen,
 		   inst->copy_mode, inst->copy_range,
-		   inst->flushtimeout, atomic_read(&inst->use));
+		   inst->flushtimeout, refcount_read(&inst->use));
 
 	return 0;
 }
-- 
2.1.4

