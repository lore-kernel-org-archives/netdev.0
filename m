From: raj@tardy.usa.hp.com (Rick Jones)
Subject: [PATCH net-next] net: add explicit logging and stat for neighbour table overflow
Date: Fri,  7 Aug 2015 11:10:37 -0700 (PDT)
Message-ID: <20150807181038.2A32029003CC@tardy>
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3425.houston.hp.com ([15.201.208.53]:3839 "EHLO
	g4t3425.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945911AbbHGSKk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2015 14:10:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>

Add an explicit neighbour table overflow message (ratelimited) and
statistic to make diagnosing neighbour table overflows tractable in
the wild.

Diagnosing a neighbour table overflow can be quite difficult in the wild
because there is no explicit dmesg logged.  Callers to neighbour code
seem to use net_dbg_ratelimit when the neighbour call fails which means
the "base message" is not emitted and the callback suppressed messages
from the ratelimiting can end-up juxtaposed with unrelated messages.
Further, a forced garbage collection will increment a stat on each call
whether it was successful in freeing-up a table entry or not, so that
statistic is only a hint.  So, add a net_info_ratelimited message and
explicit statistic to the neighbour code.

Signed-off-by: Rick Jones <rick.jones2@hp.com>

---

Tested by cutting back the gc_threshN sysctls and attempting to ping a
number of target IPs greater than the maximum size of the ARP table.

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index bd33e66..8b68384 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -125,6 +125,7 @@ struct neigh_statistics {
 	unsigned long forced_gc_runs;	/* number of forced GC runs */
 
 	unsigned long unres_discards;	/* number of unresolved drops */
+	unsigned long table_fulls;      /* times even gc couldn't help */
 };
 
 #define NEIGH_CACHE_STAT_INC(tbl, field) this_cpu_inc((tbl)->stats->field)
diff --git a/include/uapi/linux/neighbour.h b/include/uapi/linux/neighbour.h
index 2e35c61..788655b 100644
--- a/include/uapi/linux/neighbour.h
+++ b/include/uapi/linux/neighbour.h
@@ -106,6 +106,7 @@ struct ndt_stats {
 	__u64		ndts_rcv_probes_ucast;
 	__u64		ndts_periodic_gc_runs;
 	__u64		ndts_forced_gc_runs;
+	__u64		ndts_table_fulls;
 };
 
 enum {
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 84195da..2b515ba 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -274,8 +274,12 @@ static struct neighbour *neigh_alloc(struct neigh_table *tbl, struct net_device
 	    (entries >= tbl->gc_thresh2 &&
 	     time_after(now, tbl->last_flush + 5 * HZ))) {
 		if (!neigh_forced_gc(tbl) &&
-		    entries >= tbl->gc_thresh3)
+		    entries >= tbl->gc_thresh3) {
+			net_info_ratelimited("%s: neighbor table overflow!\n",
+					     tbl->id);
+			NEIGH_CACHE_STAT_INC(tbl, table_fulls);
 			goto out_entries;
+		}
 	}
 
 	n = kzalloc(tbl->entry_size + dev->neigh_priv_len, GFP_ATOMIC);
@@ -1849,6 +1853,7 @@ static int neightbl_fill_info(struct sk_buff *skb, struct neigh_table *tbl,
 			ndst.ndts_rcv_probes_ucast	+= st->rcv_probes_ucast;
 			ndst.ndts_periodic_gc_runs	+= st->periodic_gc_runs;
 			ndst.ndts_forced_gc_runs	+= st->forced_gc_runs;
+			ndst.ndts_table_fulls		+= st->table_fulls;
 		}
 
 		if (nla_put(skb, NDTA_STATS, sizeof(ndst), &ndst))
@@ -2717,12 +2722,12 @@ static int neigh_stat_seq_show(struct seq_file *seq, void *v)
 	struct neigh_statistics *st = v;
 
 	if (v == SEQ_START_TOKEN) {
-		seq_printf(seq, "entries  allocs destroys hash_grows  lookups hits  res_failed  rcv_probes_mcast rcv_probes_ucast  periodic_gc_runs forced_gc_runs unresolved_discards\n");
+		seq_printf(seq, "entries  allocs destroys hash_grows  lookups hits  res_failed  rcv_probes_mcast rcv_probes_ucast  periodic_gc_runs forced_gc_runs unresolved_discards table_fulls\n");
 		return 0;
 	}
 
 	seq_printf(seq, "%08x  %08lx %08lx %08lx  %08lx %08lx  %08lx  "
-			"%08lx %08lx  %08lx %08lx %08lx\n",
+			"%08lx %08lx  %08lx %08lx %08lx %08lx\n",
 		   atomic_read(&tbl->entries),
 
 		   st->allocs,
@@ -2739,7 +2744,8 @@ static int neigh_stat_seq_show(struct seq_file *seq, void *v)
 
 		   st->periodic_gc_runs,
 		   st->forced_gc_runs,
-		   st->unres_discards
+		   st->unres_discards,
+		   st->table_fulls
 		   );
 
 	return 0;
