From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] neighbour tables via rtnetlink v2
Date: Tue, 24 May 2005 19:02:07 +0200
Message-ID: <20050524170207.GL15391@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Setting of values is still untested due to missing userspace part but
reading of the configuration and the statistics works. Example libnl
output including full statistics:

arp_cache entries 2 reachable 26s 156msec retrans 1s
    thresh1 128 thresh2 512 thresh3 1024
    key-len 4 entry-size 152 last-flush 24m 19s 474msec
    hash-rand 0xC7089C95/0x00000003 gc 1 last-rand 4s 472msec
    refcnt 1 qlen 3 proxy-qlen 64 locktime 1s base-reachable 30s
    app-probes 0 ucast-probes 3 mcast-probes 3 gc-stale-time 1m
    probe-delay 5s anycast-delay 1s proxy-delay 800msec
    lookups 65 hits 62 failed 0 allocations 3 destroys 1
    hash-grows 1 forced-gc-runs 0 periodic-gc-runs 387
    rcv-unicast-probes 0 rcv-multicast-probes 0

and for device specific parameter sets:

arp_cache<eth0> reachable 22s 443msec retrans 1s
    refcnt 3 qlen 3 proxy-qlen 64 locktime 1s base-reachable 30s
    app-probes 0 ucast-probes 3 mcast-probes 3 gc-stale-time 1m
    probe-delay 5s anycast-delay 1s proxy-delay 800msec

I use msecs for all time values instead of user HZ and seconds
to allow for greater precision and less headache for userspace.

Attached are 3 patches, new netlink and rtnetlink shortcuts
for prettier message building and the actual new code.

[NETLINK] New message building macros

 NLMSG_NEW(skb, pid, sequence, type, length)
   Start a new netlink message, returns message header.
  
 NLMSG_NEW_ANSWER(skb, nlcb, type, length)
   Start a new netlink message as answer to a request,
   returns message header.

 NLMSG_END(skb, nlh)
   End a netlink message, fixes total message length,
   returns skb->len.

 NLMSG_CANCEL(skb, nlh)
   Cancel the building process and trim whole message
   from skb again, returns -1.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

---
commit 7250be2b3e192904e66ce314a3d2d2e46bc8bce2
tree 4f7a765c06386f20a3a9b68eea4efd57e2b354ad
parent d1faeaeb95a05275cf0c5b51b88f2fa833434625
author Thomas Graf <tgraf@suug.ch> Tue, 24 May 2005 14:26:10 +0200
committer Thomas Graf <tgraf@suug.ch> Tue, 24 May 2005 14:26:10 +0200

 include/linux/netlink.h |   22 ++++++++++++++++++++--
 1 files changed, 20 insertions(+), 2 deletions(-)

Index: include/linux/netlink.h
===================================================================
--- c6f827347b3c6c28bc55a8eb1e62ea2659202cab/include/linux/netlink.h  (mode:100644)
+++ 4f7a765c06386f20a3a9b68eea4efd57e2b354ad/include/linux/netlink.h  (mode:100644)
@@ -170,9 +170,27 @@
 	return nlh;
 }
 
+#define NLMSG_END(skb, nlh) \
+({	(nlh)->nlmsg_len = (skb)->tail - (unsigned char *) (nlh); \
+	skb->len; })
+
+#define NLMSG_CANCEL(skb, nlh) \
+({	skb_trim((skb), (unsigned char *) (nlh) - (skb)->data); \
+	-1; })
+
 #define NLMSG_PUT(skb, pid, seq, type, len) \
-({ if (skb_tailroom(skb) < (int)NLMSG_SPACE(len)) goto nlmsg_failure; \
-   __nlmsg_put(skb, pid, seq, type, len); })
+({	if (skb_tailroom(skb) < (int)NLMSG_SPACE(len)) \
+		goto nlmsg_failure; \
+	__nlmsg_put(skb, pid, seq, type, len); })
+
+#define NLMSG_NEW(skb, pid, seq, type, len) \
+({	struct nlmsghdr *_hdr = NLMSG_PUT(skb, pid, seq, type, len); \
+	_hdr->nlmsg_flags = pid ? NLM_F_MULTI : 0; \
+	_hdr; })
+
+#define NLMSG_NEW_ANSWER(skb, cb, type, len) \
+	NLMSG_NEW(skb, NETLINK_CB((cb)->skb).pid, \
+		  (cb)->nlh->nlmsg_seq, type, len)
 
 extern int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 			      struct nlmsghdr *nlh,


[RTNETLINK] Routing attribute related shortcuts

 RTA_GET_U(32|64)(tlv)
   Assumes tlv is a u32/u64 field and returns its value.

 RTA_GET_[M]SECS(tlv)
   Assumes tlv is a u64 and transports jiffies converted
   to seconds or milliseconds and returns its value.

 RTA_PUT_U(32|64)(skb, type, value)
   Appends %value as fixed u32/u64 to %skb as TLV %type.

 RTA_PUT_[M]SECS(skb, type, jiffies)
   Converts %jiffies to secs/msecs and appends it as u64
   to %skb as TLV %type.

 RTA_PUT_STRING(skb, type, string)
   Appends %NUL terminated %string to %skb as TLV %type.

 RTA_NEST(skb, type)
   Starts a nested TLV %type and returns the nesting handle.

 RTA_END_NEST(skb, nesting_handle)
   Finishes the nested TLV %nesting_handle, must be called
   symmetric to RTA_NEST().

Signed-off-by: Thomas Graf <tgraf@suug.ch>

---
commit edab564809178ad08753d8d620fc9b518898fd79
tree d3a4a96913f779af77cd3486cdeb701dc92efed0
parent 7250be2b3e192904e66ce314a3d2d2e46bc8bce2
author Thomas Graf <tgraf@suug.ch> Tue, 24 May 2005 18:47:38 +0200
committer Thomas Graf <tgraf@suug.ch> Tue, 24 May 2005 18:47:38 +0200

 include/linux/rtnetlink.h |   37 +++++++++++++++++++++++++++++++++++++
 1 files changed, 37 insertions(+)

Index: include/linux/rtnetlink.h
===================================================================
--- 4f7a765c06386f20a3a9b68eea4efd57e2b354ad/include/linux/rtnetlink.h  (mode:100644)
+++ d3a4a96913f779af77cd3486cdeb701dc92efed0/include/linux/rtnetlink.h  (mode:100644)
@@ -123,8 +123,20 @@
 #define RTA_DATA(rta)   ((void*)(((char*)(rta)) + RTA_LENGTH(0)))
 #define RTA_PAYLOAD(rta) ((int)((rta)->rta_len) - RTA_LENGTH(0))
 
+#define RTA_GET_U32(rta) \
+({	if (!rta || RTA_PAYLOAD(rta) < sizeof(u32)) \
+		goto rtattr_failure; \
+	*(u32 *) RTA_DATA(rta); })
 
+#define RTA_GET_U64(rta) \
+({	u64 _tmp; \
+	if (!rta || RTA_PAYLOAD(rta) < sizeof(u64)) \
+		goto rtattr_failure; \
+	memcpy(&_tmp, RTA_DATA(rta), sizeof(_tmp)); \
+	_tmp; })
 
+#define RTA_GET_SECS(rta) ((unsigned long) RTA_GET_U64(rta) * HZ)
+#define RTA_GET_MSECS(rta) (msecs_to_jiffies((unsigned long) RTA_GET_U64(rta)))
 
 /******************************************************************************
  *		Definitions used in routing table administration.
@@ -789,6 +801,31 @@
 ({	if (unlikely(skb_tailroom(skb) < (int)(attrlen))) \
 		goto rtattr_failure; \
 	memcpy(skb_put(skb, RTA_ALIGN(attrlen)), data, attrlen); })
+
+#define RTA_PUT_U32(skb, attrtype, value) \
+({	u32 _tmp = (value); \
+	RTA_PUT(skb, attrtype, sizeof(u32), &_tmp); })
+
+#define RTA_PUT_U64(skb, attrtype, value) \
+({	u64 _tmp = (value); \
+	RTA_PUT(skb, attrtype, sizeof(u64), &_tmp); })
+
+#define RTA_PUT_SECS(skb, attrtype, value) \
+	RTA_PUT_U64(skb, attrtype, (value) / HZ)
+
+#define RTA_PUT_MSECS(skb, attrtype, value) \
+	RTA_PUT_U64(skb, attrtype, jiffies_to_msecs(value))
+
+#define RTA_PUT_STRING(skb, attrtype, value) \
+	RTA_PUT(skb, attrtype, strlen(value) + 1, value)
+
+#define RTA_NEST(skb, type) \
+({	struct rtattr *__start = (struct rtattr *) (skb)->tail; \
+	RTA_PUT(skb, type, 0, NULL); \
+	__start;  })
+
+#define RTA_END_NEST(skb, start) \
+({	(start)->rta_len = ((skb)->tail - (unsigned char *) (start)); })
 		
 static inline struct rtattr *
 __rta_reserve(struct sk_buff *skb, int attrtype, int attrlen)


[NEIGH] neighbour table configuration and statistics via rtnetlink

Signed-off-by: Thomas Graf <tgraf@suug.ch>

---
commit 51565b40aef15f4e4b5748f9d71121e029bc4fe7
tree 7fdf80f0bf19d8ed075ee7f423173f0838c87683
parent edab564809178ad08753d8d620fc9b518898fd79
author Thomas Graf <tgraf@suug.ch> Tue, 24 May 2005 18:48:08 +0200
committer Thomas Graf <tgraf@suug.ch> Tue, 24 May 2005 18:48:08 +0200

 include/linux/rtnetlink.h   |   94 +++++++++++++
 include/net/neighbour.h     |    4 
 net/core/neighbour.c        |  310 +++++++++++++++++++++++++++++++++++++++++++-
 net/core/rtnetlink.c        |   20 +-
 security/selinux/nlmsgtab.c |    2 
 5 files changed, 419 insertions(+), 11 deletions(-)

Index: include/linux/rtnetlink.h
===================================================================
--- d3a4a96913f779af77cd3486cdeb701dc92efed0/include/linux/rtnetlink.h  (mode:100644)
+++ 7fdf80f0bf19d8ed075ee7f423173f0838c87683/include/linux/rtnetlink.h  (mode:100644)
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
@@ -505,6 +512,93 @@
 	__u32		ndm_refcnt;
 };
 
+
+/*****************************************************************
+ *		Neighbour tables specific messages.
+ *
+ * Message Ordering:
+ * Phase 1: foreach neighbour table
+ *          neighbour table base configuration and statistics
+ *          NDTA_NAME, NDTA_CONFIG, NDTA_THRESH[1-3], NDTA_STATS
+ *          NDTA_PARMS
+ *
+ * Phase 2: foreach neighbour table device parameter set
+ *          NDTA_NAME, NDTA_PARMS
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
+	NDTPA_IFINDEX,			/* u32, read-only */
+	NDTPA_REFCNT,			/* u32, read-only */
+	NDTPA_REACHABLE_TIME,		/* u64, msecs, read-only */
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
+	NDTA_NAME,			/* char * */
+	NDTA_THRESH1,			/* u32 */
+	NDTA_THRESH2,			/* u32 */
+	NDTA_THRESH3,			/* u32 */
+	NDTA_CONFIG,			/* struct ndt_config */
+	NDTA_PARMS,			/* NDTPA_* */
+	NDTA_STATS,			/* struct ndt_stats */
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
--- d3a4a96913f779af77cd3486cdeb701dc92efed0/include/net/neighbour.h  (mode:100644)
+++ 7fdf80f0bf19d8ed075ee7f423173f0838c87683/include/net/neighbour.h  (mode:100644)
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
--- d3a4a96913f779af77cd3486cdeb701dc92efed0/net/core/neighbour.c  (mode:100644)
+++ 7fdf80f0bf19d8ed075ee7f423173f0838c87683/net/core/neighbour.c  (mode:100644)
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
@@ -1546,6 +1553,301 @@
 	return err;
 }
 
+static int neightbl_fill_parms(struct sk_buff *skb, struct neigh_parms *parms)
+{
+	struct rtattr *nest_parms = RTA_NEST(skb, NDTA_PARMS);
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
+	RTA_END_NEST(skb, nest_parms);
+	return 0;
+
+rtattr_failure:
+	return -1;
+}
+
+static int neightbl_fill_info(struct neigh_table *tbl, struct sk_buff *skb,
+			      struct netlink_callback *cb)
+{
+	struct nlmsghdr *nlh;
+	struct ndtmsg *ndtmsg;
+
+	nlh = NLMSG_NEW_ANSWER(skb, cb, RTM_NEWNEIGHTBL, sizeof(struct ndtmsg));
+	ndtmsg = NLMSG_DATA(nlh);
+
+	read_lock_bh(&tbl->lock);
+	ndtmsg->ndtm_family = tbl->family;
+
+	RTA_PUT_STRING(skb, NDTA_NAME, tbl->id);
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
+	nlh = NLMSG_NEW_ANSWER(skb, cb, RTM_NEWNEIGHTBL, sizeof(struct ndtmsg));
+	ndtmsg = NLMSG_DATA(nlh);
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
@@ -2352,6 +2654,8 @@
 EXPORT_SYMBOL(neigh_update_hhs);
 EXPORT_SYMBOL(pneigh_enqueue);
 EXPORT_SYMBOL(pneigh_lookup);
+EXPORT_SYMBOL(neightbl_dump_info);
+EXPORT_SYMBOL(neightbl_set);
 
 #ifdef CONFIG_ARPD
 EXPORT_SYMBOL(neigh_app_ns);
Index: net/core/rtnetlink.c
===================================================================
--- d3a4a96913f779af77cd3486cdeb701dc92efed0/net/core/rtnetlink.c  (mode:100644)
+++ 7fdf80f0bf19d8ed075ee7f423173f0838c87683/net/core/rtnetlink.c  (mode:100644)
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
--- d3a4a96913f779af77cd3486cdeb701dc92efed0/security/selinux/nlmsgtab.c  (mode:100644)
+++ 7fdf80f0bf19d8ed075ee7f423173f0838c87683/security/selinux/nlmsgtab.c  (mode:100644)
@@ -63,6 +63,8 @@
 	{ RTM_GETPREFIX,	NETLINK_ROUTE_SOCKET__NLMSG_READ  },
 	{ RTM_GETMULTICAST,	NETLINK_ROUTE_SOCKET__NLMSG_READ  },
 	{ RTM_GETANYCAST,	NETLINK_ROUTE_SOCKET__NLMSG_READ  },
+	{ RTM_GETNEIGHTBL,	NETLINK_ROUTE_SOCKET__NLMSG_READ  },
+	{ RTM_SETNEIGHTBL,	NETLINK_ROUTE_SOCKET__NLMSG_WRITE },
 };
 
 static struct nlmsg_perm nlmsg_firewall_perms[] =
