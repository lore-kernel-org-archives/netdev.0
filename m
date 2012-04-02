From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 26/51] neighbour: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:58:16 -0400
Message-ID: <1333335521-1348-27-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46760 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754292Ab2DBDAA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 23:00:00 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/neighbour.c |   75 ++++++++++++++++++++++++++-----------------------
 1 files changed, 40 insertions(+), 35 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 0a68045..ac71765 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1768,29 +1768,29 @@ static int neightbl_fill_parms(struct sk_buff *skb, struct neigh_parms *parms)
 	if (nest == NULL)
 		return -ENOBUFS;
 
-	if (parms->dev)
-		NLA_PUT_U32(skb, NDTPA_IFINDEX, parms->dev->ifindex);
-
-	NLA_PUT_U32(skb, NDTPA_REFCNT, atomic_read(&parms->refcnt));
-	NLA_PUT_U32(skb, NDTPA_QUEUE_LENBYTES, parms->queue_len_bytes);
-	/* approximative value for deprecated QUEUE_LEN (in packets) */
-	NLA_PUT_U32(skb, NDTPA_QUEUE_LEN,
-		    DIV_ROUND_UP(parms->queue_len_bytes,
-				 SKB_TRUESIZE(ETH_FRAME_LEN)));
-	NLA_PUT_U32(skb, NDTPA_PROXY_QLEN, parms->proxy_qlen);
-	NLA_PUT_U32(skb, NDTPA_APP_PROBES, parms->app_probes);
-	NLA_PUT_U32(skb, NDTPA_UCAST_PROBES, parms->ucast_probes);
-	NLA_PUT_U32(skb, NDTPA_MCAST_PROBES, parms->mcast_probes);
-	NLA_PUT_MSECS(skb, NDTPA_REACHABLE_TIME, parms->reachable_time);
-	NLA_PUT_MSECS(skb, NDTPA_BASE_REACHABLE_TIME,
-		      parms->base_reachable_time);
-	NLA_PUT_MSECS(skb, NDTPA_GC_STALETIME, parms->gc_staletime);
-	NLA_PUT_MSECS(skb, NDTPA_DELAY_PROBE_TIME, parms->delay_probe_time);
-	NLA_PUT_MSECS(skb, NDTPA_RETRANS_TIME, parms->retrans_time);
-	NLA_PUT_MSECS(skb, NDTPA_ANYCAST_DELAY, parms->anycast_delay);
-	NLA_PUT_MSECS(skb, NDTPA_PROXY_DELAY, parms->proxy_delay);
-	NLA_PUT_MSECS(skb, NDTPA_LOCKTIME, parms->locktime);
-
+	if ((parms->dev &&
+	     nla_put_u32(skb, NDTPA_IFINDEX, parms->dev->ifindex)) ||
+	    nla_put_u32(skb, NDTPA_REFCNT, atomic_read(&parms->refcnt)) ||
+	    nla_put_u32(skb, NDTPA_QUEUE_LENBYTES, parms->queue_len_bytes) ||
+	    /* approximative value for deprecated QUEUE_LEN (in packets) */
+	    nla_put_u32(skb, NDTPA_QUEUE_LEN,
+			DIV_ROUND_UP(parms->queue_len_bytes,
+				     SKB_TRUESIZE(ETH_FRAME_LEN))) ||
+	    nla_put_u32(skb, NDTPA_PROXY_QLEN, parms->proxy_qlen) ||
+	    nla_put_u32(skb, NDTPA_APP_PROBES, parms->app_probes) ||
+	    nla_put_u32(skb, NDTPA_UCAST_PROBES, parms->ucast_probes) ||
+	    nla_put_u32(skb, NDTPA_MCAST_PROBES, parms->mcast_probes) ||
+	    nla_put_msecs(skb, NDTPA_REACHABLE_TIME, parms->reachable_time) ||
+	    nla_put_msecs(skb, NDTPA_BASE_REACHABLE_TIME,
+			  parms->base_reachable_time) ||
+	    nla_put_msecs(skb, NDTPA_GC_STALETIME, parms->gc_staletime) ||
+	    nla_put_msecs(skb, NDTPA_DELAY_PROBE_TIME,
+			  parms->delay_probe_time) ||
+	    nla_put_msecs(skb, NDTPA_RETRANS_TIME, parms->retrans_time) ||
+	    nla_put_msecs(skb, NDTPA_ANYCAST_DELAY, parms->anycast_delay) ||
+	    nla_put_msecs(skb, NDTPA_PROXY_DELAY, parms->proxy_delay) ||
+	    nla_put_msecs(skb, NDTPA_LOCKTIME, parms->locktime))
+		goto nla_put_failure;
 	return nla_nest_end(skb, nest);
 
 nla_put_failure:
@@ -1815,12 +1815,12 @@ static int neightbl_fill_info(struct sk_buff *skb, struct neigh_table *tbl,
 	ndtmsg->ndtm_pad1   = 0;
 	ndtmsg->ndtm_pad2   = 0;
 
-	NLA_PUT_STRING(skb, NDTA_NAME, tbl->id);
-	NLA_PUT_MSECS(skb, NDTA_GC_INTERVAL, tbl->gc_interval);
-	NLA_PUT_U32(skb, NDTA_THRESH1, tbl->gc_thresh1);
-	NLA_PUT_U32(skb, NDTA_THRESH2, tbl->gc_thresh2);
-	NLA_PUT_U32(skb, NDTA_THRESH3, tbl->gc_thresh3);
-
+	if (nla_put_string(skb, NDTA_NAME, tbl->id) ||
+	    nla_put_msecs(skb, NDTA_GC_INTERVAL, tbl->gc_interval) ||
+	    nla_put_u32(skb, NDTA_THRESH1, tbl->gc_thresh1) ||
+	    nla_put_u32(skb, NDTA_THRESH2, tbl->gc_thresh2) ||
+	    nla_put_u32(skb, NDTA_THRESH3, tbl->gc_thresh3))
+		goto nla_put_failure;
 	{
 		unsigned long now = jiffies;
 		unsigned int flush_delta = now - tbl->last_flush;
@@ -1841,7 +1841,8 @@ static int neightbl_fill_info(struct sk_buff *skb, struct neigh_table *tbl,
 		ndc.ndtc_hash_mask = ((1 << nht->hash_shift) - 1);
 		rcu_read_unlock_bh();
 
-		NLA_PUT(skb, NDTA_CONFIG, sizeof(ndc), &ndc);
+		if (nla_put(skb, NDTA_CONFIG, sizeof(ndc), &ndc))
+			goto nla_put_failure;
 	}
 
 	{
@@ -1866,7 +1867,8 @@ static int neightbl_fill_info(struct sk_buff *skb, struct neigh_table *tbl,
 			ndst.ndts_forced_gc_runs	+= st->forced_gc_runs;
 		}
 
-		NLA_PUT(skb, NDTA_STATS, sizeof(ndst), &ndst);
+		if (nla_put(skb, NDTA_STATS, sizeof(ndst), &ndst))
+			goto nla_put_failure;
 	}
 
 	BUG_ON(tbl->parms.dev);
@@ -2137,7 +2139,8 @@ static int neigh_fill_info(struct sk_buff *skb, struct neighbour *neigh,
 	ndm->ndm_type	 = neigh->type;
 	ndm->ndm_ifindex = neigh->dev->ifindex;
 
-	NLA_PUT(skb, NDA_DST, neigh->tbl->key_len, neigh->primary_key);
+	if (nla_put(skb, NDA_DST, neigh->tbl->key_len, neigh->primary_key))
+		goto nla_put_failure;
 
 	read_lock_bh(&neigh->lock);
 	ndm->ndm_state	 = neigh->nud_state;
@@ -2157,8 +2160,9 @@ static int neigh_fill_info(struct sk_buff *skb, struct neighbour *neigh,
 	ci.ndm_refcnt	 = atomic_read(&neigh->refcnt) - 1;
 	read_unlock_bh(&neigh->lock);
 
-	NLA_PUT_U32(skb, NDA_PROBES, atomic_read(&neigh->probes));
-	NLA_PUT(skb, NDA_CACHEINFO, sizeof(ci), &ci);
+	if (nla_put_u32(skb, NDA_PROBES, atomic_read(&neigh->probes)) ||
+	    nla_put(skb, NDA_CACHEINFO, sizeof(ci), &ci))
+		goto nla_put_failure;
 
 	return nlmsg_end(skb, nlh);
 
@@ -2187,7 +2191,8 @@ static int pneigh_fill_info(struct sk_buff *skb, struct pneigh_entry *pn,
 	ndm->ndm_ifindex = pn->dev->ifindex;
 	ndm->ndm_state	 = NUD_NONE;
 
-	NLA_PUT(skb, NDA_DST, tbl->key_len, pn->key);
+	if (nla_put(skb, NDA_DST, tbl->key_len, pn->key))
+		goto nla_put_failure;
 
 	return nlmsg_end(skb, nlh);
 
-- 
1.7.7.6
