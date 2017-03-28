From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 04/16] drivers, net,
 mlx4: convert mlx4_qp.refcount from atomic_t to refcount_t
Date: Tue, 28 Mar 2017 11:56:31 +0300
Message-ID: <1490691403-4016-5-git-send-email-elena.reshetova@intel.com>
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
 drivers/net/ethernet/mellanox/mlx4/qp.c | 8 ++++----
 include/linux/mlx4/device.h             | 2 +-
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/qp.c b/drivers/net/ethernet/mellanox/mlx4/qp.c
index 2d6abd4..6017316 100644
--- a/drivers/net/ethernet/mellanox/mlx4/qp.c
+++ b/drivers/net/ethernet/mellanox/mlx4/qp.c
@@ -55,7 +55,7 @@ void mlx4_qp_event(struct mlx4_dev *dev, u32 qpn, int event_type)
 
 	qp = __mlx4_qp_lookup(dev, qpn);
 	if (qp)
-		atomic_inc(&qp->refcount);
+		refcount_inc(&qp->refcount);
 
 	spin_unlock(&qp_table->lock);
 
@@ -66,7 +66,7 @@ void mlx4_qp_event(struct mlx4_dev *dev, u32 qpn, int event_type)
 
 	qp->event(qp, event_type);
 
-	if (atomic_dec_and_test(&qp->refcount))
+	if (refcount_dec_and_test(&qp->refcount))
 		complete(&qp->free);
 }
 
@@ -406,7 +406,7 @@ int mlx4_qp_alloc(struct mlx4_dev *dev, int qpn, struct mlx4_qp *qp, gfp_t gfp)
 	if (err)
 		goto err_icm;
 
-	atomic_set(&qp->refcount, 1);
+	refcount_set(&qp->refcount, 1);
 	init_completion(&qp->free);
 
 	return 0;
@@ -500,7 +500,7 @@ EXPORT_SYMBOL_GPL(mlx4_qp_remove);
 
 void mlx4_qp_free(struct mlx4_dev *dev, struct mlx4_qp *qp)
 {
-	if (atomic_dec_and_test(&qp->refcount))
+	if (refcount_dec_and_test(&qp->refcount))
 		complete(&qp->free);
 	wait_for_completion(&qp->free);
 
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 5fea001..756ca22 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -754,7 +754,7 @@ struct mlx4_qp {
 
 	int			qpn;
 
-	atomic_t		refcount;
+	refcount_t		refcount;
 	struct completion	free;
 };
 
-- 
2.7.4
