From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Subject: [PATCH net-next 5/7] cxgb4: add support to retrieve stats for hash filters
Date: Wed,  1 Nov 2017 08:53:03 +0530
Message-ID: <4e97338fcab60c4c19c85214091d8b83fe8a0df8.1509505160.git.rahul.lakkireddy@chelsio.com>
References: <cover.1509505160.git.rahul.lakkireddy@chelsio.com>
Cc: davem@davemloft.net, kumaras@chelsio.com, ganeshgr@chelsio.com,
        nirranjan@chelsio.com, indranil@chelsio.com,
        Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:29453 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751958AbdKADY4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 23:24:56 -0400
In-Reply-To: <cover.1509505160.git.rahul.lakkireddy@chelsio.com>
In-Reply-To: <cover.1509505160.git.rahul.lakkireddy@chelsio.com>
References: <cover.1509505160.git.rahul.lakkireddy@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Sanghvi <kumaras@chelsio.com>

Add support to retrieve packet-count and byte-count for hash-filters
by retrieving filter-entry appropriately based on whether the
request is for hash-filter or not.

Signed-off-by: Kumar Sanghvi <kumaras@chelsio.com>
Signed-off-by: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c  | 30 ++++++++++++++--------
 .../net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c   |  6 +++--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h     |  2 +-
 3 files changed, 25 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
index eb6ba9824501..9b3ff6209eb5 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
@@ -341,7 +341,7 @@ static int get_filter_steerq(struct net_device *dev,
 }
 
 static int get_filter_count(struct adapter *adapter, unsigned int fidx,
-			    u64 *pkts, u64 *bytes)
+			    u64 *pkts, u64 *bytes, bool hash)
 {
 	unsigned int tcb_base, tcbaddr;
 	unsigned int word_offset;
@@ -350,14 +350,24 @@ static int get_filter_count(struct adapter *adapter, unsigned int fidx,
 	int ret;
 
 	tcb_base = t4_read_reg(adapter, TP_CMM_TCB_BASE_A);
-	if ((fidx != (adapter->tids.nftids + adapter->tids.nsftids - 1)) &&
-	    fidx >= adapter->tids.nftids)
-		return -E2BIG;
-
-	f = &adapter->tids.ftid_tab[fidx];
-	if (!f->valid)
-		return -EINVAL;
+	if (is_hashfilter(adapter) && hash) {
+		if (fidx < adapter->tids.ntids) {
+			f = adapter->tids.tid_tab[fidx];
+			if (!f)
+				return -EINVAL;
+		} else {
+			return -E2BIG;
+		}
+	} else {
+		if ((fidx != (adapter->tids.nftids +
+			      adapter->tids.nsftids - 1)) &&
+		    fidx >= adapter->tids.nftids)
+			return -E2BIG;
 
+		f = &adapter->tids.ftid_tab[fidx];
+		if (!f->valid)
+			return -EINVAL;
+	}
 	tcbaddr = tcb_base + f->tid * TCB_SIZE;
 
 	spin_lock(&adapter->win0_lock);
@@ -409,11 +419,11 @@ static int get_filter_count(struct adapter *adapter, unsigned int fidx,
 }
 
 int cxgb4_get_filter_counters(struct net_device *dev, unsigned int fidx,
-			      u64 *hitcnt, u64 *bytecnt)
+			      u64 *hitcnt, u64 *bytecnt, bool hash)
 {
 	struct adapter *adapter = netdev2adap(dev);
 
-	return get_filter_count(adapter, fidx, hitcnt, bytecnt);
+	return get_filter_count(adapter, fidx, hitcnt, bytecnt, hash);
 }
 
 int cxgb4_get_free_ftid(struct net_device *dev, int family)
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c
index ed377e2e9f8a..a26acd183eef 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c
@@ -755,7 +755,8 @@ static void ch_flower_stats_cb(struct timer_list *t)
 	hash_for_each_rcu(adap->flower_anymatch_tbl, i, flower_entry, link) {
 		ret = cxgb4_get_filter_counters(adap->port[0],
 						flower_entry->filter_id,
-						&packets, &bytes);
+						&packets, &bytes,
+						flower_entry->fs.hash);
 		if (!ret) {
 			spin_lock(&flower_entry->lock);
 			ofld_stats = &flower_entry->stats;
@@ -788,7 +789,8 @@ int cxgb4_tc_flower_stats(struct net_device *dev,
 	}
 
 	ret = cxgb4_get_filter_counters(dev, ch_flower->filter_id,
-					&packets, &bytes);
+					&packets, &bytes,
+					ch_flower->fs.hash);
 	if (ret < 0)
 		goto err;
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
index a1c850861cbf..08e709ab6dd4 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
@@ -224,7 +224,7 @@ int cxgb4_set_filter(struct net_device *dev, int filter_id,
 int cxgb4_del_filter(struct net_device *dev, int filter_id,
 		     struct ch_filter_specification *fs);
 int cxgb4_get_filter_counters(struct net_device *dev, unsigned int fidx,
-			      u64 *hitcnt, u64 *bytecnt);
+			      u64 *hitcnt, u64 *bytecnt, bool hash);
 
 static inline void set_wr_txq(struct sk_buff *skb, int prio, int queue)
 {
-- 
2.14.1
