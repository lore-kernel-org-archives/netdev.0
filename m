From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Subject: [PATCH net-next 4/4] cxgb4: fetch stats for offloaded tc flower flows
Date: Thu, 21 Sep 2017 13:03:37 +0530
Message-ID: <63b38f185f893bca43916cb797a8764cb524c7c1.1505977744.git.rahul.lakkireddy@chelsio.com>
References: <cover.1505977744.git.rahul.lakkireddy@chelsio.com>
Cc: davem@davemloft.net, kumaras@chelsio.com, ganeshgr@chelsio.com,
        nirranjan@chelsio.com, indranil@chelsio.com,
        Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:32210 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751911AbdIUHer (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 03:34:47 -0400
In-Reply-To: <cover.1505977744.git.rahul.lakkireddy@chelsio.com>
In-Reply-To: <cover.1505977744.git.rahul.lakkireddy@chelsio.com>
References: <cover.1505977744.git.rahul.lakkireddy@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Sanghvi <kumaras@chelsio.com>

Add support to retrieve stats from hardware for offloaded tc flower
flows.  Also, poll for the stats of offloaded flows via timer callback.

Signed-off-by: Kumar Sanghvi <kumaras@chelsio.com>
Signed-off-by: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |  1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c  | 76 +++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |  1 +
 .../net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c   | 79 +++++++++++++++++++++-
 .../net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.h   |  3 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h     |  2 +
 6 files changed, 161 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 26eac599ab2c..8a94d97df025 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -907,6 +907,7 @@ struct adapter {
 
 	/* TC flower offload */
 	DECLARE_HASHTABLE(flower_anymatch_tbl, 9);
+	struct timer_list flower_stats_timer;
 };
 
 /* Support for "sched-class" command to allow a TX Scheduling Class to be
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
index 07a4619e2164..c09c4de8c9fb 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
@@ -148,6 +148,82 @@ static int get_filter_steerq(struct net_device *dev,
 	return iq;
 }
 
+static int get_filter_count(struct adapter *adapter, unsigned int fidx,
+			    u64 *pkts, u64 *bytes)
+{
+	unsigned int tcb_base, tcbaddr;
+	unsigned int word_offset;
+	struct filter_entry *f;
+	__be64 be64_byte_count;
+	int ret;
+
+	tcb_base = t4_read_reg(adapter, TP_CMM_TCB_BASE_A);
+	if ((fidx != (adapter->tids.nftids + adapter->tids.nsftids - 1)) &&
+	    fidx >= adapter->tids.nftids)
+		return -E2BIG;
+
+	f = &adapter->tids.ftid_tab[fidx];
+	if (!f->valid)
+		return -EINVAL;
+
+	tcbaddr = tcb_base + f->tid * TCB_SIZE;
+
+	spin_lock(&adapter->win0_lock);
+	if (is_t4(adapter->params.chip)) {
+		__be64 be64_count;
+
+		/* T4 doesn't maintain byte counts in hw */
+		*bytes = 0;
+
+		/* Get pkts */
+		word_offset = 4;
+		ret = t4_memory_rw(adapter, MEMWIN_NIC, MEM_EDC0,
+				   tcbaddr + (word_offset * sizeof(__be32)),
+				   sizeof(be64_count),
+				   (__be32 *)&be64_count,
+				   T4_MEMORY_READ);
+		if (ret < 0)
+			goto out;
+		*pkts = be64_to_cpu(be64_count);
+	} else {
+		__be32 be32_count;
+
+		/* Get bytes */
+		word_offset = 4;
+		ret = t4_memory_rw(adapter, MEMWIN_NIC, MEM_EDC0,
+				   tcbaddr + (word_offset * sizeof(__be32)),
+				   sizeof(be64_byte_count),
+				   &be64_byte_count,
+				   T4_MEMORY_READ);
+		if (ret < 0)
+			goto out;
+		*bytes = be64_to_cpu(be64_byte_count);
+
+		/* Get pkts */
+		word_offset = 6;
+		ret = t4_memory_rw(adapter, MEMWIN_NIC, MEM_EDC0,
+				   tcbaddr + (word_offset * sizeof(__be32)),
+				   sizeof(be32_count),
+				   &be32_count,
+				   T4_MEMORY_READ);
+		if (ret < 0)
+			goto out;
+		*pkts = (u64)be32_to_cpu(be32_count);
+	}
+
+out:
+	spin_unlock(&adapter->win0_lock);
+	return ret;
+}
+
+int cxgb4_get_filter_counters(struct net_device *dev, unsigned int fidx,
+			      u64 *hitcnt, u64 *bytecnt)
+{
+	struct adapter *adapter = netdev2adap(dev);
+
+	return get_filter_count(adapter, fidx, hitcnt, bytecnt);
+}
+
 int cxgb4_get_free_ftid(struct net_device *dev, int family)
 {
 	struct adapter *adap = netdev2adap(dev);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 3ba4e1ff8486..d634098d52ab 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -4637,6 +4637,7 @@ static void free_some_resources(struct adapter *adapter)
 	kvfree(adapter->l2t);
 	t4_cleanup_sched(adapter);
 	kvfree(adapter->tids.tid_tab);
+	cxgb4_cleanup_tc_flower(adapter);
 	cxgb4_cleanup_tc_u32(adapter);
 	kfree(adapter->sge.egr_map);
 	kfree(adapter->sge.ingr_map);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c
index fddb0c419edc..7a47d4e88a57 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c
@@ -39,9 +39,12 @@
 #include "cxgb4.h"
 #include "cxgb4_tc_flower.h"
 
+#define STATS_CHECK_PERIOD (HZ / 2)
+
 static struct ch_tc_flower_entry *allocate_flower_entry(void)
 {
 	struct ch_tc_flower_entry *new = kzalloc(sizeof(*new), GFP_KERNEL);
+	spin_lock_init(&new->lock);
 	return new;
 }
 
@@ -369,13 +372,87 @@ int cxgb4_tc_flower_destroy(struct net_device *dev,
 	return ret;
 }
 
+void ch_flower_stats_cb(unsigned long data)
+{
+	struct adapter *adap = (struct adapter *)data;
+	struct ch_tc_flower_entry *flower_entry;
+	struct ch_tc_flower_stats *ofld_stats;
+	unsigned int i;
+	u64 packets;
+	u64 bytes;
+	int ret;
+
+	rcu_read_lock();
+	hash_for_each_rcu(adap->flower_anymatch_tbl, i, flower_entry, link) {
+		ret = cxgb4_get_filter_counters(adap->port[0],
+						flower_entry->filter_id,
+						&packets, &bytes);
+		if (!ret) {
+			spin_lock(&flower_entry->lock);
+			ofld_stats = &flower_entry->stats;
+
+			if (ofld_stats->prev_packet_count != packets) {
+				ofld_stats->prev_packet_count = packets;
+				ofld_stats->last_used = jiffies;
+			}
+			spin_unlock(&flower_entry->lock);
+		}
+	}
+	rcu_read_unlock();
+	mod_timer(&adap->flower_stats_timer, jiffies + STATS_CHECK_PERIOD);
+}
+
 int cxgb4_tc_flower_stats(struct net_device *dev,
 			  struct tc_cls_flower_offload *cls)
 {
-	return -EOPNOTSUPP;
+	struct adapter *adap = netdev2adap(dev);
+	struct ch_tc_flower_stats *ofld_stats;
+	struct ch_tc_flower_entry *ch_flower;
+	u64 packets;
+	u64 bytes;
+	int ret;
+
+	ch_flower = ch_flower_lookup(adap, cls->cookie);
+	if (!ch_flower) {
+		ret = -ENOENT;
+		goto err;
+	}
+
+	ret = cxgb4_get_filter_counters(dev, ch_flower->filter_id,
+					&packets, &bytes);
+	if (ret < 0)
+		goto err;
+
+	spin_lock_bh(&ch_flower->lock);
+	ofld_stats = &ch_flower->stats;
+	if (ofld_stats->packet_count != packets) {
+		if (ofld_stats->prev_packet_count != packets)
+			ofld_stats->last_used = jiffies;
+		tcf_exts_stats_update(cls->exts, bytes - ofld_stats->byte_count,
+				      packets - ofld_stats->packet_count,
+				      ofld_stats->last_used);
+
+		ofld_stats->packet_count = packets;
+		ofld_stats->byte_count = bytes;
+		ofld_stats->prev_packet_count = packets;
+	}
+	spin_unlock_bh(&ch_flower->lock);
+	return 0;
+
+err:
+	return ret;
 }
 
 void cxgb4_init_tc_flower(struct adapter *adap)
 {
 	hash_init(adap->flower_anymatch_tbl);
+	setup_timer(&adap->flower_stats_timer, ch_flower_stats_cb,
+		    (unsigned long)adap);
+	mod_timer(&adap->flower_stats_timer, jiffies + STATS_CHECK_PERIOD);
+}
+
+void cxgb4_cleanup_tc_flower(struct adapter *adap)
+{
+	if (adap->flower_stats_timer.function)
+		del_timer_sync(&adap->flower_stats_timer);
 }
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.h
index 6145a9e056eb..604feffc752e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.h
@@ -38,6 +38,7 @@
 #include <net/pkt_cls.h>
 
 struct ch_tc_flower_stats {
+	u64 prev_packet_count;
 	u64 packet_count;
 	u64 byte_count;
 	u64 last_used;
@@ -49,6 +50,7 @@ struct ch_tc_flower_entry {
 	unsigned long tc_flower_cookie;
 	struct hlist_node link;
 	struct rcu_head rcu;
+	spinlock_t lock; /* lock for stats */
 	u32 filter_id;
 };
 
@@ -60,4 +62,5 @@ int cxgb4_tc_flower_stats(struct net_device *dev,
 			  struct tc_cls_flower_offload *cls);
 
 void cxgb4_init_tc_flower(struct adapter *adap);
+void cxgb4_cleanup_tc_flower(struct adapter *adap);
 #endif /* __CXGB4_TC_FLOWER_H */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
index 88487095d14f..52324c77a4fe 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
@@ -221,6 +221,8 @@ int __cxgb4_del_filter(struct net_device *dev, int filter_id,
 int cxgb4_set_filter(struct net_device *dev, int filter_id,
 		     struct ch_filter_specification *fs);
 int cxgb4_del_filter(struct net_device *dev, int filter_id);
+int cxgb4_get_filter_counters(struct net_device *dev, unsigned int fidx,
+			      u64 *hitcnt, u64 *bytecnt);
 
 static inline void set_wr_txq(struct sk_buff *skb, int prio, int queue)
 {
-- 
2.14.1
