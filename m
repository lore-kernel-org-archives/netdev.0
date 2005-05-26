From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/4] [NEIGH] neighbour table configuration and statistics via rtnetlink
Date: Fri, 27 May 2005 00:24:15 +0200
Message-ID: <20050526222415.GC15391@postel.suug.ch>
References: <20050526185306.GW15391@postel.suug.ch> <20050526185526.GZ15391@postel.suug.ch> <20050526.151726.85409972.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050526.151726.85409972.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

To retrieve the neighbour tables send RTM_GETNEIGHTBL with the
NLM_F_DUMP flag set. Every neighbour table configuration is
spread over multiple messages to avoid running into message
size limits on systems with many interfaces. The first message
in the sequence transports all not device specific data such as
statistics, configuration, and the default parameter set.
This message is followed by 0..n messages carrying device
specific parameter sets.

Although the ordering should be sufficient, NDTA_NAME can be
used to identify sequences. The initial message can be identified
by checking for NDTA_CONFIG. The device specific messages do
not contain this TLV but have NDTPA_IFINDEX set to the
corresponding interface index.

To change neighbour table attributes, send RTM_SETNEIGHTBL
with NDTA_NAME set. Changeable attribute include NDTA_THRESH[1-3],
NDTA_GC_INTERVAL, and all TLVs in NDTA_PARMS unless marked
otherwise. Device specific parameter sets can be changed by
setting NDTPA_IFINDEX to the interface index of the corresponding
device.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

---
commit 6769b3b0603c632bda062e427178de8986900a52
tree 7e955d0e3c8fdef048336d0d7ba24a0539f28f9b
parent 98c3bc2e6320127cd96ef46d33f89ae127ce48fe
author Thomas Graf <tgraf@suug.ch> Wed, 25 May 2005 20:30:09 +0200
committer Thomas Graf <tgraf@suug.ch> Wed, 25 May 2005 20:30:09 +0200

 include/linux/rtnetlink.h   |  107 ++++++++++++++
 include/net/neighbour.h     |    4 
 net/core/neighbour.c        |  317 +++++++++++++++++++++++++++++++++++++++++++-
 net/core/rtnetlink.c        |   20 +-
 security/selinux/nlmsgtab.c |    2 
 5 files changed, 439 insertions(+), 11 deletions(-)

Index: include/linux/rtnetlink.h
===================================================================
--- 0ad944fa24c79b3eeaf06f85f5dd6d91ae1adbc9/include/linux/rtnetlink.h  (mode:100644)
+++ 7e955d0e3c8fdef048336d0d7ba24a0539f28f9b/include/linux/rtnetlink.h  (mode:100644)
@@ -89,6 +89,13 @@
 	RTM_GETANYCAST	= 62,
 #define RTM_GETANYCAST	RTM_GETANYCAST
 
+	RTM_NEWNEIGHTBL	= 64,
+#define RTM_NEWNEIGHTBL	RTM_NEWNEIGHTBL
+	RTM_GETNEIGHTBL	= 66,
+#define RTM_GETNEIGHTBL	RTM_GETNEIGHTBL
+	RTM_SETNEIGHTBL,
+#define RTM_SETNEIGHTBL	RTM_SETNEIGHTBL
+
 	__RTM_MAX,
 #define RTM_MAX		(((__RTM_MAX + 3) & ~3) - 1)
 };
@@ -493,6 +500,106 @@
 	__u32		ndm_refcnt;
 };
 
+
+/*****************************************************************
+ *		Neighbour tables specific messages.
+ *
+ * To retrieve the neighbour tables send RTM_GETNEIGHTBL with the
+ * NLM_F_DUMP flag set. Every neighbour table configuration is
+ * spread over multiple messages to avoid running into message
+ * size limits on systems with many interfaces. The first message
+ * in the sequence transports all not device specific data such as
+ * statistics, configuration, and the default parameter set.
+ * This message is followed by 0..n messages carrying device
+ * specific parameter sets.
+ * Although the ordering should be sufficient, NDTA_NAME can be
+ * used to identify sequences. The initial message can be identified
+ * by checking for NDTA_CONFIG. The device specific messages do
+ * not contain this TLV but have NDTPA_IFINDEX set to the
+ * corresponding interface index.
+ *
+ * To change neighbour table attributes, send RTM_SETNEIGHTBL
+ * with NDTA_NAME set. Changeable attribute include NDTA_THRESH[1-3],
+ * NDTA_GC_INTERVAL, and all TLVs in NDTA_PARMS unless marked
+ * otherwise. Device specific parameter sets can be changed by
+ * setting NDTPA_IFINDEX to the interface index of the corresponding
+ * device.
+ ****/
+
+struct ndt_stats
+{
+	__u64		ndts_allocs;
+	__u64		ndts_destroys;
+	__u64		ndts_hash_grows;
+	__u64		ndts_res_failed;
+	__u64		ndts_lookups;
+	__u64		ndts_hits;
+	__u64		ndts_rcv_probes_mcast;
+	__u64		ndts_rcv_probes_ucast;
+	__u64		ndts_periodic_gc_runs;
+	__u64		ndts_forced_gc_runs;
+};
+
+enum {
+	NDTPA_UNSPEC,
+	NDTPA_IFINDEX,			/* u32, unchangeable */
+	NDTPA_REFCNT,			/* u32, read-only */
+	NDTPA_REACHABLE_TIME,		/* u64, read-only, msecs */
+	NDTPA_BASE_REACHABLE_TIME,	/* u64, msecs */
+	NDTPA_RETRANS_TIME,		/* u64, msecs */
+	NDTPA_GC_STALETIME,		/* u64, msecs */
+	NDTPA_DELAY_PROBE_TIME,		/* u64, msecs */
+	NDTPA_QUEUE_LEN,		/* u32 */
+	NDTPA_APP_PROBES,		/* u32 */
+	NDTPA_UCAST_PROBES,		/* u32 */
+	NDTPA_MCAST_PROBES,		/* u32 */
+	NDTPA_ANYCAST_DELAY,		/* u64, msecs */
+	NDTPA_PROXY_DELAY,		/* u64, msecs */
+	NDTPA_PROXY_QLEN,		/* u32 */
+	NDTPA_LOCKTIME,			/* u64, msecs */
+	__NDTPA_MAX
+};
+#define NDTPA_MAX (__NDTPA_MAX - 1)
+
+struct ndtmsg
+{
+	__u8		ndtm_family;
+	__u8		ndtm_pad1;
+	__u16		ndtm_pad2;
+};
+
+struct ndt_config
+{
+	__u16		ndtc_key_len;
+	__u16		ndtc_entry_size;
+	__u32		ndtc_entries;
+	__u32		ndtc_last_flush;	/* delta to now in msecs */
+	__u32		ndtc_last_rand;		/* delta to now in msecs */
+	__u32		ndtc_hash_rnd;
+	__u32		ndtc_hash_mask;
+	__u32		ndtc_hash_chain_gc;
+	__u32		ndtc_proxy_qlen;
+};
+
+enum {
+	NDTA_UNSPEC,
+	NDTA_NAME,			/* char *, unchangeable */
+	NDTA_THRESH1,			/* u32 */
+	NDTA_THRESH2,			/* u32 */
+	NDTA_THRESH3,			/* u32 */
+	NDTA_CONFIG,			/* struct ndt_config, read-only */
+	NDTA_PARMS,			/* nested TLV NDTPA_* */
+	NDTA_STATS,			/* struct ndt_stats, read-only */
+	NDTA_GC_INTERVAL,		/* u64, msecs */
+	__NDTA_MAX
+};
+#define NDTA_MAX (__NDTA_MAX - 1)
+
+#define NDTA_RTA(r) ((struct rtattr*)(((char*)(r)) + \
+		     NLMSG_ALIGN(sizeof(struct ndtmsg))))
+#define NDTA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct ndtmsg))
+
+
 /****
  *		General form of address family dependent message.
  ****/
Index: include/net/neighbour.h
===================================================================
--- 0ad944fa24c79b3eeaf06f85f5dd6d91ae1adbc9/include/net/neighbour.h  (mode:100644)
+++ 7e955d0e3c8fdef048336d0d7ba24a0539f28f9b/include/net/neighbour.h  (mode:100644)
@@ -65,6 +65,7 @@
 
 struct neigh_parms
 {
+	struct net_device *dev;
 	struct neigh_parms *next;
 	int	(*neigh_setup)(struct neighbour *);
 	struct neigh_table *tbl;
@@ -252,6 +253,9 @@
 extern int neigh_delete(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg);
 extern void neigh_app_ns(struct neighbour *n);
 
+extern int neightbl_dump_info(struct sk_buff *skb, struct netlink_callback *cb);
+extern int neightbl_set(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg);
+
 extern void neigh_for_each(struct neigh_table *tbl, void (*cb)(struct neighbour *, void *), void *cookie);
 extern void __neigh_for_each_release(struct neigh_table *tbl, int (*cb)(struct neighbour *));
 extern void pneigh_for_each(struct neigh_table *tbl, void (*cb)(struct pneigh_entry *));
Index: net/core/neighbour.c
===================================================================
--- 0ad944fa24c79b3eeaf06f85f5dd6d91ae1adbc9/net/core/neighbour.c  (mode:100644)
+++ 7e955d0e3c8fdef048336d0d7ba24a0539f28f9b/net/core/neighbour.c  (mode:100644)
@@ -1276,9 +1276,14 @@
 		INIT_RCU_HEAD(&p->rcu_head);
 		p->reachable_time =
 				neigh_rand_reach_time(p->base_reachable_time);
-		if (dev && dev->neigh_setup && dev->neigh_setup(dev, p)) {
-			kfree(p);
-			return NULL;
+		if (dev) {
+			if (dev->neigh_setup && dev->neigh_setup(dev, p)) {
+				kfree(p);
+				return NULL;
+			}
+
+			dev_hold(dev);
+			p->dev = dev;
 		}
 		p->sysctl_table = NULL;
 		write_lock_bh(&tbl->lock);
@@ -1309,6 +1314,8 @@
 			*p = parms->next;
 			parms->dead = 1;
 			write_unlock_bh(&tbl->lock);
+			if (parms->dev)
+				dev_put(parms->dev);
 			call_rcu(&parms->rcu_head, neigh_rcu_free_parms);
 			return;
 		}
@@ -1546,6 +1553,308 @@
 	return err;
 }
 
+static int neightbl_fill_parms(struct sk_buff *skb, struct neigh_parms *parms)
+{
+	struct rtattr *nest = RTA_NEST(skb, NDTA_PARMS);
+
+	if (parms->dev)
+		RTA_PUT_U32(skb, NDTPA_IFINDEX, parms->dev->ifindex);
+
+	RTA_PUT_U32(skb, NDTPA_REFCNT, atomic_read(&parms->refcnt));
+	RTA_PUT_U32(skb, NDTPA_QUEUE_LEN, parms->queue_len);
+	RTA_PUT_U32(skb, NDTPA_PROXY_QLEN, parms->proxy_qlen);
+	RTA_PUT_U32(skb, NDTPA_APP_PROBES, parms->app_probes);
+	RTA_PUT_U32(skb, NDTPA_UCAST_PROBES, parms->ucast_probes);
+	RTA_PUT_U32(skb, NDTPA_MCAST_PROBES, parms->mcast_probes);
+	RTA_PUT_MSECS(skb, NDTPA_REACHABLE_TIME, parms->reachable_time);
+	RTA_PUT_MSECS(skb, NDTPA_BASE_REACHABLE_TIME,
+		      parms->base_reachable_time);
+	RTA_PUT_MSECS(skb, NDTPA_GC_STALETIME, parms->gc_staletime);
+	RTA_PUT_MSECS(skb, NDTPA_DELAY_PROBE_TIME, parms->delay_probe_time);
+	RTA_PUT_MSECS(skb, NDTPA_RETRANS_TIME, parms->retrans_time);
+	RTA_PUT_MSECS(skb, NDTPA_ANYCAST_DELAY, parms->anycast_delay);
+	RTA_PUT_MSECS(skb, NDTPA_PROXY_DELAY, parms->proxy_delay);
+	RTA_PUT_MSECS(skb, NDTPA_LOCKTIME, parms->locktime);
+
+	return RTA_NEST_END(skb, nest);
+
+rtattr_failure:
+	return RTA_NEST_CANCEL(skb, nest);
+}
+
+static int neightbl_fill_info(struct neigh_table *tbl, struct sk_buff *skb,
+			      struct netlink_callback *cb)
+{
+	struct nlmsghdr *nlh;
+	struct ndtmsg *ndtmsg;
+
+	nlh = NLMSG_PUT_ANSWER(skb, cb, RTM_NEWNEIGHTBL, sizeof(struct ndtmsg));
+	ndtmsg = NLMSG_DATA(nlh);
+
+	NLMSG_SET_MULTIPART(nlh);
+
+	read_lock_bh(&tbl->lock);
+	ndtmsg->ndtm_family = tbl->family;
+
+	RTA_PUT_STRING(skb, NDTA_NAME, tbl->id);
+	RTA_PUT_MSECS(skb, NDTA_GC_INTERVAL, tbl->gc_interval);
+	RTA_PUT_U32(skb, NDTA_THRESH1, tbl->gc_thresh1);
+	RTA_PUT_U32(skb, NDTA_THRESH2, tbl->gc_thresh2);
+	RTA_PUT_U32(skb, NDTA_THRESH3, tbl->gc_thresh3);
+
+	{
+		unsigned long now = jiffies;
+		unsigned int flush_delta = now - tbl->last_flush;
+		unsigned int rand_delta = now - tbl->last_rand;
+
+		struct ndt_config ndc = {
+			.ndtc_key_len		= tbl->key_len,
+			.ndtc_entry_size	= tbl->entry_size,
+			.ndtc_entries		= atomic_read(&tbl->entries),
+			.ndtc_last_flush	= jiffies_to_msecs(flush_delta),
+			.ndtc_last_rand		= jiffies_to_msecs(rand_delta),
+			.ndtc_hash_rnd		= tbl->hash_rnd,
+			.ndtc_hash_mask		= tbl->hash_mask,
+			.ndtc_hash_chain_gc	= tbl->hash_chain_gc,
+			.ndtc_proxy_qlen	= tbl->proxy_queue.qlen,
+		};
+
+		RTA_PUT(skb, NDTA_CONFIG, sizeof(ndc), &ndc);
+	}
+
+	{
+		int cpu;
+		struct ndt_stats ndst;
+
+		memset(&ndst, 0, sizeof(ndst));
+
+		for (cpu = 0; cpu < NR_CPUS; cpu++) {
+			struct neigh_statistics	*st;
+
+			if (!cpu_possible(cpu))
+				continue;
+
+			st = per_cpu_ptr(tbl->stats, cpu);
+			ndst.ndts_allocs		+= st->allocs;
+			ndst.ndts_destroys		+= st->destroys;
+			ndst.ndts_hash_grows		+= st->hash_grows;
+			ndst.ndts_res_failed		+= st->res_failed;
+			ndst.ndts_lookups		+= st->lookups;
+			ndst.ndts_hits			+= st->hits;
+			ndst.ndts_rcv_probes_mcast	+= st->rcv_probes_mcast;
+			ndst.ndts_rcv_probes_ucast	+= st->rcv_probes_ucast;
+			ndst.ndts_periodic_gc_runs	+= st->periodic_gc_runs;
+			ndst.ndts_forced_gc_runs	+= st->forced_gc_runs;
+		}
+
+		RTA_PUT(skb, NDTA_STATS, sizeof(ndst), &ndst);
+	}
+
+	BUG_ON(tbl->parms.dev);
+	if (neightbl_fill_parms(skb, &tbl->parms) < 0)
+		goto rtattr_failure;
+
+	read_unlock_bh(&tbl->lock);
+	return NLMSG_END(skb, nlh);
+
+rtattr_failure:
+	read_unlock_bh(&tbl->lock);
+	return NLMSG_CANCEL(skb, nlh);
+ 
+nlmsg_failure:
+	return -1;
+}
+
+static int neightbl_fill_param_info(struct neigh_table *tbl,
+				    struct neigh_parms *parms,
+				    struct sk_buff *skb,
+				    struct netlink_callback *cb)
+{
+	struct ndtmsg *ndtmsg;
+	struct nlmsghdr *nlh;
+
+	nlh = NLMSG_PUT_ANSWER(skb, cb, RTM_NEWNEIGHTBL, sizeof(struct ndtmsg));
+	ndtmsg = NLMSG_DATA(nlh);
+
+	NLMSG_SET_MULTIPART(nlh);
+
+	read_lock_bh(&tbl->lock);
+	ndtmsg->ndtm_family = tbl->family;
+	RTA_PUT_STRING(skb, NDTA_NAME, tbl->id);
+
+	if (neightbl_fill_parms(skb, parms) < 0)
+		goto rtattr_failure;
+
+	read_unlock_bh(&tbl->lock);
+	return NLMSG_END(skb, nlh);
+
+rtattr_failure:
+	read_unlock_bh(&tbl->lock);
+	return NLMSG_CANCEL(skb, nlh);
+
+nlmsg_failure:
+	return -1;
+}
+ 
+static inline struct neigh_parms *lookup_neigh_params(struct neigh_table *tbl,
+						      int ifindex)
+{
+	struct neigh_parms *p;
+	
+	for (p = &tbl->parms; p; p = p->next)
+		if ((p->dev && p->dev->ifindex == ifindex) ||
+		    (!p->dev && !ifindex))
+			return p;
+
+	return NULL;
+}
+
+int neightbl_set(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+{
+	struct neigh_table *tbl;
+	struct ndtmsg *ndtmsg = NLMSG_DATA(nlh);
+	struct rtattr **tb = arg;
+	int err = -EINVAL;
+
+	if (!tb[NDTA_NAME - 1] || !RTA_PAYLOAD(tb[NDTA_NAME - 1]))
+		return -EINVAL;
+
+	read_lock(&neigh_tbl_lock);
+	for (tbl = neigh_tables; tbl; tbl = tbl->next) {
+		if (ndtmsg->ndtm_family && tbl->family != ndtmsg->ndtm_family)
+			continue;
+
+		if (!rtattr_strcmp(tb[NDTA_NAME - 1], tbl->id))
+			break;
+	}
+
+	if (tbl == NULL) {
+		err = -ENOENT;
+		goto errout;
+	}
+
+	/* 
+	 * We acquire tbl->lock to be nice to the periodic timers and
+	 * make sure they always see a consistent set of values.
+	 */
+	write_lock_bh(&tbl->lock);
+
+	if (tb[NDTA_THRESH1 - 1])
+		tbl->gc_thresh1 = RTA_GET_U32(tb[NDTA_THRESH1 - 1]);
+
+	if (tb[NDTA_THRESH2 - 1])
+		tbl->gc_thresh2 = RTA_GET_U32(tb[NDTA_THRESH2 - 1]);
+
+	if (tb[NDTA_THRESH3 - 1])
+		tbl->gc_thresh3 = RTA_GET_U32(tb[NDTA_THRESH3 - 1]);
+
+	if (tb[NDTA_GC_INTERVAL - 1])
+		tbl->gc_interval = RTA_GET_MSECS(tb[NDTA_GC_INTERVAL - 1]);
+
+	if (tb[NDTA_PARMS - 1]) {
+		struct rtattr *tbp[NDTPA_MAX];
+		struct neigh_parms *p;
+		u32 ifindex = 0;
+
+		if (rtattr_parse_nested(tbp, NDTPA_MAX, tb[NDTA_PARMS - 1]) < 0)
+			goto rtattr_failure;
+
+		if (tbp[NDTPA_IFINDEX - 1])
+			ifindex = RTA_GET_U32(tbp[NDTPA_IFINDEX - 1]);
+
+		p = lookup_neigh_params(tbl, ifindex);
+		if (p == NULL) {
+			err = -ENOENT;
+			goto rtattr_failure;
+		}
+	
+		if (tbp[NDTPA_QUEUE_LEN - 1])
+			p->queue_len = RTA_GET_U32(tbp[NDTPA_QUEUE_LEN - 1]);
+
+		if (tbp[NDTPA_PROXY_QLEN - 1])
+			p->proxy_qlen = RTA_GET_U32(tbp[NDTPA_PROXY_QLEN - 1]);
+
+		if (tbp[NDTPA_APP_PROBES - 1])
+			p->app_probes = RTA_GET_U32(tbp[NDTPA_APP_PROBES - 1]);
+
+		if (tbp[NDTPA_UCAST_PROBES - 1])
+			p->ucast_probes =
+			   RTA_GET_U32(tbp[NDTPA_UCAST_PROBES - 1]);
+
+		if (tbp[NDTPA_MCAST_PROBES - 1])
+			p->mcast_probes =
+			   RTA_GET_U32(tbp[NDTPA_MCAST_PROBES - 1]);
+
+		if (tbp[NDTPA_BASE_REACHABLE_TIME - 1])
+			p->base_reachable_time =
+			   RTA_GET_MSECS(tbp[NDTPA_BASE_REACHABLE_TIME - 1]);
+
+		if (tbp[NDTPA_GC_STALETIME - 1])
+			p->gc_staletime =
+			   RTA_GET_MSECS(tbp[NDTPA_GC_STALETIME - 1]);
+
+		if (tbp[NDTPA_DELAY_PROBE_TIME - 1])
+			p->delay_probe_time =
+			   RTA_GET_MSECS(tbp[NDTPA_DELAY_PROBE_TIME - 1]);
+
+		if (tbp[NDTPA_RETRANS_TIME - 1])
+			p->retrans_time =
+			   RTA_GET_MSECS(tbp[NDTPA_RETRANS_TIME - 1]);
+
+		if (tbp[NDTPA_ANYCAST_DELAY - 1])
+			p->anycast_delay =
+			   RTA_GET_MSECS(tbp[NDTPA_ANYCAST_DELAY - 1]);
+
+		if (tbp[NDTPA_PROXY_DELAY - 1])
+			p->proxy_delay =
+			   RTA_GET_MSECS(tbp[NDTPA_PROXY_DELAY - 1]);
+
+		if (tbp[NDTPA_LOCKTIME - 1])
+			p->locktime = RTA_GET_MSECS(tbp[NDTPA_LOCKTIME - 1]);
+	}
+
+	err = 0;
+
+rtattr_failure:
+	write_unlock_bh(&tbl->lock);
+errout:
+	read_unlock(&neigh_tbl_lock);
+	return err;
+}
+
+int neightbl_dump_info(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	int idx, family;
+	int s_idx = cb->args[0];
+	struct neigh_table *tbl;
+
+	family = ((struct rtgenmsg *)NLMSG_DATA(cb->nlh))->rtgen_family;
+
+	read_lock(&neigh_tbl_lock);
+	for (tbl = neigh_tables, idx = 0; tbl; tbl = tbl->next) {
+		struct neigh_parms *p;
+
+		if (idx < s_idx || (family && tbl->family != family))
+			continue;
+
+		if (neightbl_fill_info(tbl, skb, cb) <= 0)
+			break;
+
+		for (++idx, p = tbl->parms.next; p; p = p->next, idx++) {
+			if (idx < s_idx)
+				continue;
+
+			if (neightbl_fill_param_info(tbl, p, skb, cb) <= 0)
+				goto out;
+		}
+
+	}
+out:
+	read_unlock(&neigh_tbl_lock);
+	cb->args[0] = idx;
+
+	return skb->len;
+}
 
 static int neigh_fill_info(struct sk_buff *skb, struct neighbour *n,
 			   u32 pid, u32 seq, int event)
@@ -2352,6 +2661,8 @@
 EXPORT_SYMBOL(neigh_update_hhs);
 EXPORT_SYMBOL(pneigh_enqueue);
 EXPORT_SYMBOL(pneigh_lookup);
+EXPORT_SYMBOL(neightbl_dump_info);
+EXPORT_SYMBOL(neightbl_set);
 
 #ifdef CONFIG_ARPD
 EXPORT_SYMBOL(neigh_app_ns);
Index: net/core/rtnetlink.c
===================================================================
--- 0ad944fa24c79b3eeaf06f85f5dd6d91ae1adbc9/net/core/rtnetlink.c  (mode:100644)
+++ 7e955d0e3c8fdef048336d0d7ba24a0539f28f9b/net/core/rtnetlink.c  (mode:100644)
@@ -100,6 +100,7 @@
 	[RTM_FAM(RTM_NEWPREFIX)]    = NLMSG_LENGTH(sizeof(struct rtgenmsg)),
 	[RTM_FAM(RTM_GETMULTICAST)] = NLMSG_LENGTH(sizeof(struct rtgenmsg)),
 	[RTM_FAM(RTM_GETANYCAST)]   = NLMSG_LENGTH(sizeof(struct rtgenmsg)),
+	[RTM_FAM(RTM_NEWNEIGHTBL)]  = NLMSG_LENGTH(sizeof(struct ndtmsg)),
 };
 
 static const int rta_max[RTM_NR_FAMILIES] =
@@ -113,6 +114,7 @@
 	[RTM_FAM(RTM_NEWTCLASS)]    = TCA_MAX,
 	[RTM_FAM(RTM_NEWTFILTER)]   = TCA_MAX,
 	[RTM_FAM(RTM_NEWACTION)]    = TCAA_MAX,
+	[RTM_FAM(RTM_NEWNEIGHTBL)]  = NDTA_MAX,
 };
 
 void __rta_fill(struct sk_buff *skb, int attrtype, int attrlen, const void *data)
@@ -649,14 +651,16 @@
 
 static struct rtnetlink_link link_rtnetlink_table[RTM_NR_MSGTYPES] =
 {
-	[RTM_GETLINK  - RTM_BASE] = { .dumpit = rtnetlink_dump_ifinfo },
-	[RTM_SETLINK  - RTM_BASE] = { .doit   = do_setlink	      },
-	[RTM_GETADDR  - RTM_BASE] = { .dumpit = rtnetlink_dump_all    },
-	[RTM_GETROUTE - RTM_BASE] = { .dumpit = rtnetlink_dump_all    },
-	[RTM_NEWNEIGH - RTM_BASE] = { .doit   = neigh_add	      },
-	[RTM_DELNEIGH - RTM_BASE] = { .doit   = neigh_delete	      },
-	[RTM_GETNEIGH - RTM_BASE] = { .dumpit = neigh_dump_info	      },
-	[RTM_GETRULE  - RTM_BASE] = { .dumpit = rtnetlink_dump_all    },
+	[RTM_GETLINK     - RTM_BASE] = { .dumpit = rtnetlink_dump_ifinfo },
+	[RTM_SETLINK     - RTM_BASE] = { .doit   = do_setlink		 },
+	[RTM_GETADDR     - RTM_BASE] = { .dumpit = rtnetlink_dump_all	 },
+	[RTM_GETROUTE    - RTM_BASE] = { .dumpit = rtnetlink_dump_all	 },
+	[RTM_NEWNEIGH    - RTM_BASE] = { .doit   = neigh_add		 },
+	[RTM_DELNEIGH    - RTM_BASE] = { .doit   = neigh_delete		 },
+	[RTM_GETNEIGH    - RTM_BASE] = { .dumpit = neigh_dump_info	 },
+	[RTM_GETRULE     - RTM_BASE] = { .dumpit = rtnetlink_dump_all	 },
+	[RTM_GETNEIGHTBL - RTM_BASE] = { .dumpit = neightbl_dump_info	 },
+	[RTM_SETNEIGHTBL - RTM_BASE] = { .doit   = neightbl_set		 },
 };
 
 static int rtnetlink_event(struct notifier_block *this, unsigned long event, void *ptr)
Index: security/selinux/nlmsgtab.c
===================================================================
--- 0ad944fa24c79b3eeaf06f85f5dd6d91ae1adbc9/security/selinux/nlmsgtab.c  (mode:100644)
+++ 7e955d0e3c8fdef048336d0d7ba24a0539f28f9b/security/selinux/nlmsgtab.c  (mode:100644)
@@ -63,6 +63,8 @@
 	{ RTM_GETPREFIX,	NETLINK_ROUTE_SOCKET__NLMSG_READ  },
 	{ RTM_GETMULTICAST,	NETLINK_ROUTE_SOCKET__NLMSG_READ  },
 	{ RTM_GETANYCAST,	NETLINK_ROUTE_SOCKET__NLMSG_READ  },
+	{ RTM_GETNEIGHTBL,	NETLINK_ROUTE_SOCKET__NLMSG_READ  },
+	{ RTM_SETNEIGHTBL,	NETLINK_ROUTE_SOCKET__NLMSG_WRITE },
 };
 
 static struct nlmsg_perm nlmsg_firewall_perms[] =
