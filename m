From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 6/7] [NEIGH]: Convert neighbour table dumping to new netlink api
Date: Mon, 07 Aug 2006 00:00:06 +0200
Message-ID: <20060807171051.145432807@postel.suug.ch>
References: <20060807170944.259251279@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:6606 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932142AbWHGRMg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2006 13:12:36 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=nl_neightbl_dump
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Also fixes skipping of already dumped neighbours.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19.git/net/core/neighbour.c
===================================================================
--- net-2.6.19.git.orig/net/core/neighbour.c
+++ net-2.6.19.git/net/core/neighbour.c
@@ -1594,56 +1594,59 @@ out:
 
 static int neightbl_fill_parms(struct sk_buff *skb, struct neigh_parms *parms)
 {
-	struct rtattr *nest = NULL;
-	
-	nest = RTA_NEST(skb, NDTA_PARMS);
+	struct nlattr *nest;
+
+	nest = nla_nest_start(skb, NDTA_PARMS);
+	if (nest == NULL)
+		return -ENOBUFS;
 
 	if (parms->dev)
-		RTA_PUT_U32(skb, NDTPA_IFINDEX, parms->dev->ifindex);
+		NLA_PUT_U32(skb, NDTPA_IFINDEX, parms->dev->ifindex);
 
-	RTA_PUT_U32(skb, NDTPA_REFCNT, atomic_read(&parms->refcnt));
-	RTA_PUT_U32(skb, NDTPA_QUEUE_LEN, parms->queue_len);
-	RTA_PUT_U32(skb, NDTPA_PROXY_QLEN, parms->proxy_qlen);
-	RTA_PUT_U32(skb, NDTPA_APP_PROBES, parms->app_probes);
-	RTA_PUT_U32(skb, NDTPA_UCAST_PROBES, parms->ucast_probes);
-	RTA_PUT_U32(skb, NDTPA_MCAST_PROBES, parms->mcast_probes);
-	RTA_PUT_MSECS(skb, NDTPA_REACHABLE_TIME, parms->reachable_time);
-	RTA_PUT_MSECS(skb, NDTPA_BASE_REACHABLE_TIME,
+	NLA_PUT_U32(skb, NDTPA_REFCNT, atomic_read(&parms->refcnt));
+	NLA_PUT_U32(skb, NDTPA_QUEUE_LEN, parms->queue_len);
+	NLA_PUT_U32(skb, NDTPA_PROXY_QLEN, parms->proxy_qlen);
+	NLA_PUT_U32(skb, NDTPA_APP_PROBES, parms->app_probes);
+	NLA_PUT_U32(skb, NDTPA_UCAST_PROBES, parms->ucast_probes);
+	NLA_PUT_U32(skb, NDTPA_MCAST_PROBES, parms->mcast_probes);
+	NLA_PUT_MSECS(skb, NDTPA_REACHABLE_TIME, parms->reachable_time);
+	NLA_PUT_MSECS(skb, NDTPA_BASE_REACHABLE_TIME,
 		      parms->base_reachable_time);
-	RTA_PUT_MSECS(skb, NDTPA_GC_STALETIME, parms->gc_staletime);
-	RTA_PUT_MSECS(skb, NDTPA_DELAY_PROBE_TIME, parms->delay_probe_time);
-	RTA_PUT_MSECS(skb, NDTPA_RETRANS_TIME, parms->retrans_time);
-	RTA_PUT_MSECS(skb, NDTPA_ANYCAST_DELAY, parms->anycast_delay);
-	RTA_PUT_MSECS(skb, NDTPA_PROXY_DELAY, parms->proxy_delay);
-	RTA_PUT_MSECS(skb, NDTPA_LOCKTIME, parms->locktime);
+	NLA_PUT_MSECS(skb, NDTPA_GC_STALETIME, parms->gc_staletime);
+	NLA_PUT_MSECS(skb, NDTPA_DELAY_PROBE_TIME, parms->delay_probe_time);
+	NLA_PUT_MSECS(skb, NDTPA_RETRANS_TIME, parms->retrans_time);
+	NLA_PUT_MSECS(skb, NDTPA_ANYCAST_DELAY, parms->anycast_delay);
+	NLA_PUT_MSECS(skb, NDTPA_PROXY_DELAY, parms->proxy_delay);
+	NLA_PUT_MSECS(skb, NDTPA_LOCKTIME, parms->locktime);
 
-	return RTA_NEST_END(skb, nest);
+	return nla_nest_end(skb, nest);
 
-rtattr_failure:
-	return RTA_NEST_CANCEL(skb, nest);
+nla_put_failure:
+	return nla_nest_cancel(skb, nest);
 }
 
-static int neightbl_fill_info(struct neigh_table *tbl, struct sk_buff *skb,
-			      struct netlink_callback *cb)
+static int neightbl_fill_info(struct sk_buff *skb, struct neigh_table *tbl,
+			      u32 pid, u32 seq, int type, int flags)
 {
 	struct nlmsghdr *nlh;
 	struct ndtmsg *ndtmsg;
 
-	nlh = NLMSG_NEW_ANSWER(skb, cb, RTM_NEWNEIGHTBL, sizeof(struct ndtmsg),
-			       NLM_F_MULTI);
+	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*ndtmsg), flags);
+	if (nlh == NULL)
+		return -ENOBUFS;
 
-	ndtmsg = NLMSG_DATA(nlh);
+	ndtmsg = nlmsg_data(nlh);
 
 	read_lock_bh(&tbl->lock);
 	ndtmsg->ndtm_family = tbl->family;
 	ndtmsg->ndtm_pad1   = 0;
 	ndtmsg->ndtm_pad2   = 0;
 
-	RTA_PUT_STRING(skb, NDTA_NAME, tbl->id);
-	RTA_PUT_MSECS(skb, NDTA_GC_INTERVAL, tbl->gc_interval);
-	RTA_PUT_U32(skb, NDTA_THRESH1, tbl->gc_thresh1);
-	RTA_PUT_U32(skb, NDTA_THRESH2, tbl->gc_thresh2);
-	RTA_PUT_U32(skb, NDTA_THRESH3, tbl->gc_thresh3);
+	NLA_PUT_STRING(skb, NDTA_NAME, tbl->id);
+	NLA_PUT_MSECS(skb, NDTA_GC_INTERVAL, tbl->gc_interval);
+	NLA_PUT_U32(skb, NDTA_THRESH1, tbl->gc_thresh1);
+	NLA_PUT_U32(skb, NDTA_THRESH2, tbl->gc_thresh2);
+	NLA_PUT_U32(skb, NDTA_THRESH3, tbl->gc_thresh3);
 
 	{
 		unsigned long now = jiffies;
@@ -1662,7 +1665,7 @@ static int neightbl_fill_info(struct nei
 			.ndtc_proxy_qlen	= tbl->proxy_queue.qlen,
 		};
 
-		RTA_PUT(skb, NDTA_CONFIG, sizeof(ndc), &ndc);
+		NLA_PUT(skb, NDTA_CONFIG, sizeof(ndc), &ndc);
 	}
 
 	{
@@ -1687,55 +1690,50 @@ static int neightbl_fill_info(struct nei
 			ndst.ndts_forced_gc_runs	+= st->forced_gc_runs;
 		}
 
-		RTA_PUT(skb, NDTA_STATS, sizeof(ndst), &ndst);
+		NLA_PUT(skb, NDTA_STATS, sizeof(ndst), &ndst);
 	}
 
 	BUG_ON(tbl->parms.dev);
 	if (neightbl_fill_parms(skb, &tbl->parms) < 0)
-		goto rtattr_failure;
+		goto nla_put_failure;
 
 	read_unlock_bh(&tbl->lock);
-	return NLMSG_END(skb, nlh);
+	return nlmsg_end(skb, nlh);
 
-rtattr_failure:
+nla_put_failure:
 	read_unlock_bh(&tbl->lock);
-	return NLMSG_CANCEL(skb, nlh);
- 
-nlmsg_failure:
-	return -1;
+	return nlmsg_cancel(skb, nlh);
 }
 
-static int neightbl_fill_param_info(struct neigh_table *tbl,
+static int neightbl_fill_param_info(struct sk_buff *skb,
+				    struct neigh_table *tbl,
 				    struct neigh_parms *parms,
-				    struct sk_buff *skb,
-				    struct netlink_callback *cb)
+				    u32 pid, u32 seq, int type,
+				    unsigned int flags)
 {
 	struct ndtmsg *ndtmsg;
 	struct nlmsghdr *nlh;
 
-	nlh = NLMSG_NEW_ANSWER(skb, cb, RTM_NEWNEIGHTBL, sizeof(struct ndtmsg),
-			       NLM_F_MULTI);
+	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*ndtmsg), flags);
+	if (nlh == NULL)
+		return -ENOBUFS;
 
-	ndtmsg = NLMSG_DATA(nlh);
+	ndtmsg = nlmsg_data(nlh);
 
 	read_lock_bh(&tbl->lock);
 	ndtmsg->ndtm_family = tbl->family;
 	ndtmsg->ndtm_pad1   = 0;
 	ndtmsg->ndtm_pad2   = 0;
-	RTA_PUT_STRING(skb, NDTA_NAME, tbl->id);
 
-	if (neightbl_fill_parms(skb, parms) < 0)
-		goto rtattr_failure;
+	if (nla_put_string(skb, NDTA_NAME, tbl->id) < 0 ||
+	    neightbl_fill_parms(skb, parms) < 0)
+		goto errout;
 
 	read_unlock_bh(&tbl->lock);
-	return NLMSG_END(skb, nlh);
-
-rtattr_failure:
+	return nlmsg_end(skb, nlh);
+errout:
 	read_unlock_bh(&tbl->lock);
-	return NLMSG_CANCEL(skb, nlh);
-
-nlmsg_failure:
-	return -1;
+	return nlmsg_cancel(skb, nlh);
 }
  
 static inline struct neigh_parms *lookup_neigh_params(struct neigh_table *tbl,
@@ -1902,34 +1900,43 @@ errout:
 
 int neightbl_dump_info(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	int idx, family;
-	int s_idx = cb->args[0];
+	int family, tidx, nidx = 0;
+	int tbl_skip = cb->args[0];
+	int neigh_skip = cb->args[1];
 	struct neigh_table *tbl;
 
-	family = ((struct rtgenmsg *)NLMSG_DATA(cb->nlh))->rtgen_family;
+	family = ((struct rtgenmsg *) nlmsg_data(cb->nlh))->rtgen_family;
 
 	read_lock(&neigh_tbl_lock);
-	for (tbl = neigh_tables, idx = 0; tbl; tbl = tbl->next) {
+	for (tbl = neigh_tables, tidx = 0; tbl; tbl = tbl->next, tidx++) {
 		struct neigh_parms *p;
 
-		if (idx < s_idx || (family && tbl->family != family))
+		if (tidx < tbl_skip || (family && tbl->family != family))
 			continue;
 
-		if (neightbl_fill_info(tbl, skb, cb) <= 0)
+		if (neightbl_fill_info(skb, tbl, NETLINK_CB(cb->skb).pid,
+				       cb->nlh->nlmsg_seq, RTM_NEWNEIGHTBL,
+				       NLM_F_MULTI) <= 0)
 			break;
 
-		for (++idx, p = tbl->parms.next; p; p = p->next, idx++) {
-			if (idx < s_idx)
+		for (nidx = 0, p = tbl->parms.next; p; p = p->next, nidx++) {
+			if (nidx < neigh_skip)
 				continue;
 
-			if (neightbl_fill_param_info(tbl, p, skb, cb) <= 0)
+			if (neightbl_fill_param_info(skb, tbl, p,
+						     NETLINK_CB(cb->skb).pid,
+						     cb->nlh->nlmsg_seq,
+						     RTM_NEWNEIGHTBL,
+						     NLM_F_MULTI) <= 0)
 				goto out;
 		}
 
+		neigh_skip = 0;
 	}
 out:
 	read_unlock(&neigh_tbl_lock);
-	cb->args[0] = idx;
+	cb->args[0] = tidx;
+	cb->args[1] = nidx;
 
 	return skb->len;
 }

