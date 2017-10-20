From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 01/15] drivers, net, ethernet: convert clip_entry.refcnt from atomic_t to refcount_t
Date: Fri, 20 Oct 2017 10:23:35 +0300
Message-ID: <1508484229-19706-2-git-send-email-elena.reshetova@intel.com>
References: <1508484229-19706-1-git-send-email-elena.reshetova@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        linux-mediatek@lists.infradead.org, linux-rdma@vger.kernel.org,
        linux-hams@vger.kernel.org, linux-ppp@vger.kernel.org,
        ganeshgr@chelsio.com, nbd@openwrt.org, john@phrozen.org,
        sean.wang@mediatek.com, matthias.bgg@gmail.com,
        yishaih@mellanox.com, saeedm@mellanox.com, matanb@mellanox.com,
        tariqt@mellanox.com, leonro@mellanox.com,
        ajk@comnets.uni-bremen.de, paulus@samba.org, zbr@ioremap.net,
        peterz@infradead.org, keescook@chromium.org,
        Elena Reshetova <elena.reshetova@intel.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508484229-19706-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

atomic_t variables are currently used to implement reference
counters with the following properties:
 - counter is initialized to 1 using atomic_set()
 - a resource is freed upon counter reaching zero
 - once counter reaches zero, its further
   increments aren't allowed
 - counter schema uses basic atomic operations
   (set, inc, inc_not_zero, dec_and_test, etc.)

Such atomic variables should be converted to a newly provided
refcount_t type and API that prevents accidental counter overflows
and underflows. This is important since overflows and underflows
can lead to use-after-free situation and be exploitable.

The variable clip_entry.refcnt is used as pure reference counter.
Convert it to refcount_t and fix up the operations.

Suggested-by: Kees Cook <keescook@chromium.org>
Reviewed-by: David Windsor <dwindsor@gmail.com>
Reviewed-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
---
 drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c | 13 ++++++-------
 drivers/net/ethernet/chelsio/cxgb4/clip_tbl.h |  4 +++-
 2 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c b/drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c
index 3103ef9..2900390 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c
@@ -96,7 +96,8 @@ int cxgb4_clip_get(const struct net_device *dev, const u32 *lip, u8 v6)
 		if (!ret) {
 			ce = cte;
 			read_unlock_bh(&ctbl->lock);
-			goto found;
+			refcount_inc(&ce->refcnt);
+			return 0;
 		}
 	}
 	read_unlock_bh(&ctbl->lock);
@@ -108,7 +109,7 @@ int cxgb4_clip_get(const struct net_device *dev, const u32 *lip, u8 v6)
 		list_del(&ce->list);
 		INIT_LIST_HEAD(&ce->list);
 		spin_lock_init(&ce->lock);
-		atomic_set(&ce->refcnt, 0);
+		refcount_set(&ce->refcnt, 0);
 		atomic_dec(&ctbl->nfree);
 		list_add_tail(&ce->list, &ctbl->hash_list[hash]);
 		if (v6) {
@@ -138,9 +139,7 @@ int cxgb4_clip_get(const struct net_device *dev, const u32 *lip, u8 v6)
 		return -ENOMEM;
 	}
 	write_unlock_bh(&ctbl->lock);
-found:
-	atomic_inc(&ce->refcnt);
-
+	refcount_set(&ce->refcnt, 1);
 	return 0;
 }
 EXPORT_SYMBOL(cxgb4_clip_get);
@@ -179,7 +178,7 @@ void cxgb4_clip_release(const struct net_device *dev, const u32 *lip, u8 v6)
 found:
 	write_lock_bh(&ctbl->lock);
 	spin_lock_bh(&ce->lock);
-	if (atomic_dec_and_test(&ce->refcnt)) {
+	if (refcount_dec_and_test(&ce->refcnt)) {
 		list_del(&ce->list);
 		INIT_LIST_HEAD(&ce->list);
 		list_add_tail(&ce->list, &ctbl->ce_free_head);
@@ -266,7 +265,7 @@ int clip_tbl_show(struct seq_file *seq, void *v)
 			ip[0] = '\0';
 			sprintf(ip, "%pISc", &ce->addr);
 			seq_printf(seq, "%-25s   %u\n", ip,
-				   atomic_read(&ce->refcnt));
+				   refcount_read(&ce->refcnt));
 		}
 	}
 	seq_printf(seq, "Free clip entries : %d\n", atomic_read(&ctbl->nfree));
diff --git a/drivers/net/ethernet/chelsio/cxgb4/clip_tbl.h b/drivers/net/ethernet/chelsio/cxgb4/clip_tbl.h
index 35eb43c..a0e0ae1 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/clip_tbl.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/clip_tbl.h
@@ -10,9 +10,11 @@
  *  release for licensing terms and conditions.
  */
 
+#include <linux/refcount.h>
+
 struct clip_entry {
 	spinlock_t lock;	/* Hold while modifying clip reference */
-	atomic_t refcnt;
+	refcount_t refcnt;
 	struct list_head list;
 	union {
 		struct sockaddr_in addr;
-- 
2.7.4
