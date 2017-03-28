From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 01/16] drivers, net,
 ethernet: convert clip_entry.refcnt from atomic_t to refcount_t
Date: Tue, 28 Mar 2017 11:56:28 +0300
Message-ID: <1490691403-4016-2-git-send-email-elena.reshetova@intel.com>
References: <1490691403-4016-1-git-send-email-elena.reshetova@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: peterz@infradead.org, matanb@mellanox.com, paulus@samba.org,
 Elena Reshetova <elena.reshetova@intel.com>, nbd@openwrt.org,
 linux-rdma@vger.kernel.org, saeedm@mellanox.com, ganeshgr@chelsio.com,
 Hans Liljestrand <ishkamiel@gmail.com>, David Windsor <dwindsor@gmail.com>,
 keescook@chromium.org, j@w1.fi, ajk@comnets.uni-bremen.de, leonro@mellanox.com,
 matthias.bgg@gmail.com, linux-hams@vger.kernel.org, kvalo@codeaurora.org,
 blogic@openwrt.org, linux-arm-kernel@lists.infradead.org,
 linux-ppp@vger.kernel.org, yishaih@mellanox.com,
 linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
 gregkh@linuxfoundation.org
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1490691403-4016-1-git-send-email-elena.reshetova@intel.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

refcount_t type and corresponding API should be
used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: David Windsor <dwindsor@gmail.com>
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
