From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] core: add stat to track unresolved discards in neighbor
	cache
Date: Tue, 15 Jul 2008 13:37:31 -0400
Message-ID: <20080715173731.GF4918@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4210 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751935AbYGORig (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2008 13:38:36 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

in __neigh_event_send, if we have a neighbour entry which is in NUD_INCOMPLETE
state, we enqueue any outbound frames to that neighbour to the neighbours
arp_queue, which is default capped to a length of 3 skbs.  If that queue exceeds
its set length, it will drop an skb on the queue to enqueue the newly arrived
skb.  This results in a drop for which we have no statistics incremented.  This
patch adds an unresolved_discards stat to /proc/net/stat/ndisc_cache to track
these lost frames.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 include/net/neighbour.h |    4 +++-
 net/core/neighbour.c    |    8 +++++---
 2 files changed, 8 insertions(+), 4 deletions(-)


diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index dc420fe..aa4b708 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -75,7 +75,7 @@ struct neigh_statistics
 	unsigned long destroys;		/* number of destroyed neighs */
 	unsigned long hash_grows;	/* number of hash resizes */
 
-	unsigned long res_failed;	/* nomber of failed resolutions */
+	unsigned long res_failed;	/* number of failed resolutions */
 
 	unsigned long lookups;		/* number of lookups */
 	unsigned long hits;		/* number of hits (among lookups) */
@@ -85,6 +85,8 @@ struct neigh_statistics
 
 	unsigned long periodic_gc_runs;	/* number of periodic GC runs */
 	unsigned long forced_gc_runs;	/* number of forced GC runs */
+
+	unsigned long unres_discards;	/* number of unresolved drops */
 };
 
 #define NEIGH_CACHE_STAT_INC(tbl, field)				\
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 65f01f7..f62c8af 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -930,6 +930,7 @@ int __neigh_event_send(struct neighbour *neigh, struct sk_buff *skb)
 				buff = neigh->arp_queue.next;
 				__skb_unlink(buff, &neigh->arp_queue);
 				kfree_skb(buff);
+				NEIGH_CACHE_STAT_INC(neigh->tbl, unres_discards);
 			}
 			__skb_queue_tail(&neigh->arp_queue, skb);
 		}
@@ -2462,12 +2463,12 @@ static int neigh_stat_seq_show(struct seq_file *seq, void *v)
 	struct neigh_statistics *st = v;
 
 	if (v == SEQ_START_TOKEN) {
-		seq_printf(seq, "entries  allocs destroys hash_grows  lookups hits  res_failed  rcv_probes_mcast rcv_probes_ucast  periodic_gc_runs forced_gc_runs\n");
+		seq_printf(seq, "entries  allocs destroys hash_grows  lookups hits  res_failed  rcv_probes_mcast rcv_probes_ucast  periodic_gc_runs forced_gc_runs unresolved_discards\n");
 		return 0;
 	}
 
 	seq_printf(seq, "%08x  %08lx %08lx %08lx  %08lx %08lx  %08lx  "
-			"%08lx %08lx  %08lx %08lx\n",
+			"%08lx %08lx  %08lx %08lx %08lx\n",
 		   atomic_read(&tbl->entries),
 
 		   st->allocs,
@@ -2483,7 +2484,8 @@ static int neigh_stat_seq_show(struct seq_file *seq, void *v)
 		   st->rcv_probes_ucast,
 
 		   st->periodic_gc_runs,
-		   st->forced_gc_runs
+		   st->forced_gc_runs,
+		   st->unres_discards
 		   );
 
 	return 0;
-- 
/****************************************************
 * Neil Horman <nhorman@tuxdriver.com>
 * Software Engineer, Red Hat
 ****************************************************/
