From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 2/4] cxgb4: Differentiates between TIDs being used in TCAM and HASH
Date: Wed, 12 Aug 2015 16:55:05 +0530
Message-ID: <1439378707-14462-3-git-send-email-hariprasad@chelsio.com>
References: <1439378707-14462-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:23201 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750974AbbHLLZM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 07:25:12 -0400
In-Reply-To: <1439378707-14462-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For the tid info, differentiate from which region the TID is allocated
from. It can be from TCAM region or HASH region.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 32 +++++++++++++++++++++----
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |  9 ++++++-
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h    |  1 +
 3 files changed, 36 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 27e87b6..df6cba1 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -1654,20 +1654,25 @@ static void process_tid_release_list(struct work_struct *work)
  */
 void cxgb4_remove_tid(struct tid_info *t, unsigned int chan, unsigned int tid)
 {
-	void *old;
 	struct sk_buff *skb;
 	struct adapter *adap = container_of(t, struct adapter, tids);
 
-	old = t->tid_tab[tid];
+	WARN_ON(tid >= t->ntids);
+
+	if (t->tid_tab[tid]) {
+		t->tid_tab[tid] = NULL;
+		if (t->hash_base && (tid >= t->hash_base))
+			atomic_dec(&t->hash_tids_in_use);
+		else
+			atomic_dec(&t->tids_in_use);
+	}
+
 	skb = alloc_skb(sizeof(struct cpl_tid_release), GFP_ATOMIC);
 	if (likely(skb)) {
-		t->tid_tab[tid] = NULL;
 		mk_tid_release(skb, chan, tid);
 		t4_ofld_send(adap, skb);
 	} else
 		cxgb4_queue_tid_release(t, chan, tid);
-	if (old)
-		atomic_dec(&t->tids_in_use);
 }
 EXPORT_SYMBOL(cxgb4_remove_tid);
 
@@ -1705,6 +1710,7 @@ static int tid_init(struct tid_info *t)
 	t->afree = NULL;
 	t->atids_in_use = 0;
 	atomic_set(&t->tids_in_use, 0);
+	atomic_set(&t->hash_tids_in_use, 0);
 
 	/* Setup the free list for atid_tab and clear the stid bitmap. */
 	if (natids) {
@@ -4814,6 +4820,22 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		adapter->params.offload = 0;
 	}
 
+	if (is_offload(adapter)) {
+		if (t4_read_reg(adapter, LE_DB_CONFIG_A) & HASHEN_F) {
+			u32 hash_base, hash_reg;
+
+			if (chip <= CHELSIO_T5) {
+				hash_reg = LE_DB_TID_HASHBASE_A;
+				hash_base = t4_read_reg(adapter, hash_reg);
+				adapter->tids.hash_base = hash_base / 4;
+			} else {
+				hash_reg = T6_LE_DB_HASH_TID_BASE_A;
+				hash_base = t4_read_reg(adapter, hash_reg);
+				adapter->tids.hash_base = hash_base;
+			}
+		}
+	}
+
 	/* See what interrupts we'll be using */
 	if (msi > 1 && enable_msix(adapter) == 0)
 		adapter->flags |= USING_MSIX;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
index b27897d..f61fed1 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
@@ -96,6 +96,7 @@ struct tid_info {
 	unsigned long *stid_bmap;
 	unsigned int nstids;
 	unsigned int stid_base;
+	unsigned int hash_base;
 
 	union aopen_entry *atid_tab;
 	unsigned int natids;
@@ -117,7 +118,10 @@ struct tid_info {
 	spinlock_t stid_lock;
 	unsigned int stids_in_use;
 
+	/* TIDs in the TCAM */
 	atomic_t tids_in_use;
+	/* TIDs in the HASH */
+	atomic_t hash_tids_in_use;
 };
 
 static inline void *lookup_tid(const struct tid_info *t, unsigned int tid)
@@ -147,7 +151,10 @@ static inline void cxgb4_insert_tid(struct tid_info *t, void *data,
 				    unsigned int tid)
 {
 	t->tid_tab[tid] = data;
-	atomic_inc(&t->tids_in_use);
+	if (t->hash_base && (tid >= t->hash_base))
+		atomic_inc(&t->hash_tids_in_use);
+	else
+		atomic_inc(&t->tids_in_use);
 }
 
 int cxgb4_alloc_atid(struct tid_info *t, void *data);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index e444dc4..365ebd5 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -2736,6 +2736,7 @@
 #define LE_DB_HASH_TBL_BASE_ADDR_A 0x19c30
 #define LE_DB_INT_CAUSE_A 0x19c3c
 #define LE_DB_TID_HASHBASE_A 0x19df8
+#define T6_LE_DB_HASH_TID_BASE_A 0x19df8
 
 #define HASHEN_S    20
 #define HASHEN_V(x) ((x) << HASHEN_S)
-- 
2.3.4
