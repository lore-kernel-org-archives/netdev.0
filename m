From: Thomas Graf <tgraf@suug.ch>
Subject: [RFC] neighbour tables configuration via rtnetlink
Date: Sat, 5 Mar 2005 18:22:57 +0100
Message-ID: <20050305172257.GN31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I have need to change multiple neighbour table parameters as a atomic operation
which lead me to make it available via rtnetlink. I started with the patch
below which extends the existing RTM_*NEIGH commands by a flag NTF_TABLES
changing the context from entries to the tables itself. I regard this as quite
hacky, the alternative would be to add a new RTM operation set, i.e.
RTM_*NEIGHTBL or alike.

It's only dumping for now but I plan to also allow modification of parameters.
One of the problem that arises is the fact that the interface identifier,
to differ the various parameters sets, is stored in the sysctl table which
would introduce quite a nasty depedency.

Before I go ahead, putting more effort into it, what is our preferred
interface for network configuration? My personal preference is to make
everything available via netlink with the long term plan to extend it
with distributive remote configuration protocol in userspace. If so,
shall we continue to push everything into rtnetlink regardless of the
association to routing? The only drawback of the currently "overloaded"
rtnetlink is the rtnl semaphore which has grown into something like
the BKL for networking. I'm not aware of any performance problems or
other issues because of this except for the module loading over nfs.
Does anyone?

Thoughts?


diff -Nru linux-2.6.11-rc3-bk3.orig/include/linux/rtnetlink.h linux-2.6.11-rc3-bk3/include/linux/rtnetlink.h
--- linux-2.6.11-rc3-bk3.orig/include/linux/rtnetlink.h	2005-02-11 04:04:22.000000000 +0100
+++ linux-2.6.11-rc3-bk3/include/linux/rtnetlink.h	2005-02-11 02:02:52.000000000 +0100
@@ -459,6 +459,7 @@
  *	Neighbor Cache Entry Flags
  */
 
+#define NTF_TABLES	0x01	/* Dump neighbour tables */
 #define NTF_PROXY	0x08	/* == ATF_PUBL */
 #define NTF_ROUTER	0x80
 
@@ -487,6 +488,71 @@
 	__u32		ndm_refcnt;
 };
 
+enum {
+	NDTA_UNSPEC,
+	NDTA_TABLE,
+	NDTA_PARAMS,
+	NDTA_STATS,
+	__NDTA_MAX
+};
+#define NDTA_MAX (__NDTA_MAX - 1)
+
+/*****
+ * Neighbour Tables Access
+ *****/
+
+struct nd_table_stats
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
+struct ndt_params
+{
+	__u32		ndtp_refcnt;
+	__u32		ndtp_base_reachable_time;
+	__u32		ndtp_reachable_time;
+	__u32		ndtp_retrans_time;
+	__u32		ndtp_gc_staletime;
+	__u32		ndtp_delay_probe_time;
+	__u32		ndtp_queue_len;
+	__u32		ndtp_app_probes;
+	__u32		ndtp_ucast_probes;
+	__u32		ndtp_mcast_probes;
+	__u32		ndtp_anycast_delay;
+	__u32		ndtp_proxy_delay;
+	__u32		ndtp_proxy_qlen;
+	__u32		ndtp_locktime;
+};
+
+#define NDT_TBLNAMSIZ 16
+
+struct nd_table
+{
+	char		ndt_id[NDT_TBLNAMSIZ];
+	__u16		ndt_key_len;
+	__u16		ndt_entry_size;
+	__u16		ndt_gc_interval;
+	__u16		ndt_gc_thresh1;
+	__u16		ndt_gc_thresh2;
+	__u16		ndt_gc_thresh3;
+	__u32		ndt_entries;
+	__u32		ndt_last_flush;
+	__u32		ndt_last_rand;
+	__u32		ndt_hash_rnd;
+	__u32		ndt_hash_mask;
+	__u32		ndt_hash_chain_gc;
+	__u32		ndt_proxy_qlen;
+};
+
 /****
  *		General form of address family dependent message.
  ****/
diff -Nru linux-2.6.11-rc3-bk3.orig/net/core/neighbour.c linux-2.6.11-rc3-bk3/net/core/neighbour.c
--- linux-2.6.11-rc3-bk3.orig/net/core/neighbour.c	2005-02-11 04:04:22.000000000 +0100
+++ linux-2.6.11-rc3-bk3/net/core/neighbour.c	2005-02-11 02:00:26.000000000 +0100
@@ -1623,13 +1623,109 @@
 	return rc;
 }
 
+static int neigh_dump_table_meta(struct neigh_table *tbl, struct sk_buff *skb,
+				 struct netlink_callback *cb)
+{
+	int i, locked = 0;
+	unsigned char *b = skb->tail;
+	struct nd_table ndtbl;
+	struct nd_table_stats st;
+	struct neigh_parms *p;
+	struct rtattr *rta;
+	int pid = NETLINK_CB(cb->skb).pid;
+	struct nlmsghdr *nlh = NLMSG_PUT(skb, pid, cb->nlh->nlmsg_seq,
+					 RTM_NEWNEIGH, sizeof(struct ndmsg));
+	struct ndmsg *ndm = NLMSG_DATA(nlh);
+
+	nlh->nlmsg_flags = pid ? NLM_F_MULTI : 0;
+	ndm->ndm_flags	 = NTF_TABLES;
+	ndm->ndm_type	 = 0;
+	ndm->ndm_state	 = 0;
+	ndm->ndm_ifindex = 0;
+
+	read_lock_bh(&tbl->lock);
+	locked = 1;
+
+	ndm->ndm_family		= tbl->family;
+	ndtbl.ndt_key_len	= tbl->key_len;
+	ndtbl.ndt_entry_size	= tbl->entry_size;
+	ndtbl.ndt_gc_interval	= tbl->gc_interval;
+	ndtbl.ndt_gc_thresh1	= tbl->gc_thresh1;
+	ndtbl.ndt_gc_thresh1	= tbl->gc_thresh2;
+	ndtbl.ndt_gc_thresh1	= tbl->gc_thresh3;
+	ndtbl.ndt_entries	= atomic_read(&tbl->entries);
+	ndtbl.ndt_last_flush	= tbl->last_flush;
+	ndtbl.ndt_last_rand	= tbl->last_rand;
+	ndtbl.ndt_hash_rnd	= tbl->hash_rnd;
+	ndtbl.ndt_hash_mask	= tbl->hash_mask;
+	ndtbl.ndt_hash_chain_gc	= tbl->hash_chain_gc;
+	ndtbl.ndt_proxy_qlen	= tbl->proxy_queue.qlen;
+
+	strncpy(ndtbl.ndt_id, tbl->id, sizeof(ndtbl.ndt_id));
+	RTA_PUT(skb, NDTA_TABLE, sizeof(ndtbl), &ndtbl);
+
+	st.ndts_allocs		 = tbl->stats->allocs;
+	st.ndts_destroys	 = tbl->stats->destroys;
+	st.ndts_hash_grows	 = tbl->stats->hash_grows;
+	st.ndts_res_failed	 = tbl->stats->res_failed;
+	st.ndts_lookups		 = tbl->stats->lookups;
+	st.ndts_hits		 = tbl->stats->hits;
+	st.ndts_rcv_probes_mcast = tbl->stats->rcv_probes_mcast;
+	st.ndts_rcv_probes_ucast = tbl->stats->rcv_probes_ucast;
+	st.ndts_periodic_gc_runs = tbl->stats->periodic_gc_runs;
+	st.ndts_forced_gc_runs	 = tbl->stats->forced_gc_runs;
+	RTA_PUT(skb, NDTA_STATS, sizeof(st), &st);
+
+	rta = (struct rtattr *) skb->tail;
+	RTA_PUT(skb, NDTA_PARAMS, 0, NULL);
+
+	for (p = &tbl->parms, i = 1; p ; p = p->next, i++) {
+		struct ndt_params pa;
+
+		/* FIXME: ifindex from sysctl table should be included
+		 * here to allow userspace to differ each parameter set */
+
+		pa.ndtp_refcnt			= atomic_read(&p->refcnt);
+		pa.ndtp_base_reachable_time	= p->base_reachable_time;
+		pa.ndtp_reachable_time		= p->reachable_time;
+		pa.ndtp_retrans_time		= p->retrans_time;
+		pa.ndtp_gc_staletime		= p->gc_staletime;
+		pa.ndtp_delay_probe_time	= p->delay_probe_time;
+		pa.ndtp_queue_len		= p->queue_len;
+		pa.ndtp_app_probes		= p->app_probes;
+		pa.ndtp_ucast_probes		= p->ucast_probes;
+		pa.ndtp_mcast_probes		= p->mcast_probes;
+		pa.ndtp_anycast_delay		= p->anycast_delay;
+		pa.ndtp_proxy_delay		= p->proxy_delay;
+		pa.ndtp_proxy_qlen		= p->proxy_qlen;
+		pa.ndtp_locktime		= p->locktime;
+		RTA_PUT(skb, i, sizeof(pa), &pa);
+	}
+
+	rta->rta_len = (skb->tail - (unsigned char *) rta);
+
+	read_unlock_bh(&tbl->lock);
+	locked = 0;
+
+	nlh->nlmsg_len	 = skb->tail - b;
+	return skb->len;
+
+nlmsg_failure:
+rtattr_failure:
+	if (locked)
+		read_unlock_bh(&tbl->lock);
+	skb_trim(skb, b - skb->data);
+	return -1;
+}
+
 int neigh_dump_info(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct neigh_table *tbl;
-	int t, family, s_t;
+	int t, family, s_t, flags;
 
 	read_lock(&neigh_tbl_lock);
 	family = ((struct rtgenmsg *)NLMSG_DATA(cb->nlh))->rtgen_family;
+	flags = ((struct ndmsg *)NLMSG_DATA(cb->nlh))->ndm_flags;
 	s_t = cb->args[0];
 
 	for (tbl = neigh_tables, t = 0; tbl; tbl = tbl->next, t++) {
@@ -1638,8 +1734,13 @@
 		if (t > s_t)
 			memset(&cb->args[1], 0, sizeof(cb->args) -
 						sizeof(cb->args[0]));
-		if (neigh_dump_table(tbl, skb, cb) < 0)
-			break;
+		if (flags & NTF_TABLES) {
+			if (neigh_dump_table_meta(tbl, skb, cb) < 0)
+				break;
+		} else {
+			if (neigh_dump_table(tbl, skb, cb) < 0)
+				break;
+		}
 	}
 	read_unlock(&neigh_tbl_lock);
 
