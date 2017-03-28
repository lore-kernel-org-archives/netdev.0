From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 05/16] drivers, net,
 mlx4: convert mlx4_srq.refcount from atomic_t to refcount_t
Date: Tue, 28 Mar 2017 11:56:32 +0300
Message-ID: <1490691403-4016-6-git-send-email-elena.reshetova@intel.com>
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
 drivers/net/ethernet/mellanox/mlx4/srq.c | 8 ++++----
 include/linux/mlx4/device.h              | 2 +-
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/srq.c b/drivers/net/ethernet/mellanox/mlx4/srq.c
index f44d089..3369f65 100644
--- a/drivers/net/ethernet/mellanox/mlx4/srq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/srq.c
@@ -49,7 +49,7 @@ void mlx4_srq_event(struct mlx4_dev *dev, u32 srqn, int event_type)
 	srq = radix_tree_lookup(&srq_table->tree, srqn & (dev->caps.num_srqs - 1));
 	rcu_read_unlock();
 	if (srq)
-		atomic_inc(&srq->refcount);
+		refcount_inc(&srq->refcount);
 	else {
 		mlx4_warn(dev, "Async event for bogus SRQ %08x\n", srqn);
 		return;
@@ -57,7 +57,7 @@ void mlx4_srq_event(struct mlx4_dev *dev, u32 srqn, int event_type)
 
 	srq->event(srq, event_type);
 
-	if (atomic_dec_and_test(&srq->refcount))
+	if (refcount_dec_and_test(&srq->refcount))
 		complete(&srq->free);
 }
 
@@ -203,7 +203,7 @@ int mlx4_srq_alloc(struct mlx4_dev *dev, u32 pdn, u32 cqn, u16 xrcd,
 	if (err)
 		goto err_radix;
 
-	atomic_set(&srq->refcount, 1);
+	refcount_set(&srq->refcount, 1);
 	init_completion(&srq->free);
 
 	return 0;
@@ -232,7 +232,7 @@ void mlx4_srq_free(struct mlx4_dev *dev, struct mlx4_srq *srq)
 	radix_tree_delete(&srq_table->tree, srq->srqn);
 	spin_unlock_irq(&srq_table->lock);
 
-	if (atomic_dec_and_test(&srq->refcount))
+	if (refcount_dec_and_test(&srq->refcount))
 		complete(&srq->free);
 	wait_for_completion(&srq->free);
 
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 756ca22..8998807 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -766,7 +766,7 @@ struct mlx4_srq {
 	int			max_gs;
 	int			wqe_shift;
 
-	atomic_t		refcount;
+	refcount_t		refcount;
 	struct completion	free;
 };
 
-- 
2.7.4
