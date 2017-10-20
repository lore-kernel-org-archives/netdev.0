From: Elena Reshetova <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 04/15] drivers, net,
 mlx4: convert mlx4_qp.refcount from atomic_t to refcount_t
Date: Fri, 20 Oct 2017 10:23:38 +0300
Message-ID: <1508484229-19706-5-git-send-email-elena.reshetova@intel.com>
References: <1508484229-19706-1-git-send-email-elena.reshetova@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org,
 zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org, Elena Reshetova <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org,
 linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ganeshgr-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
 ajk-iz34hMvxm2Hmj42eshorlhS11BummzK+@public.gmane.org, keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org,
 leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org,
 matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-hams-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-ppp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1508484229-19706-1-git-send-email-elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
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

The variable mlx4_qp.refcount is used as pure reference counter.
Convert it to refcount_t and fix up the operations.

Suggested-by: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Reviewed-by: David Windsor <dwindsor-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Reviewed-by: Hans Liljestrand <ishkamiel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Elena Reshetova <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx4/qp.c | 8 ++++----
 include/linux/mlx4/device.h             | 2 +-
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/qp.c b/drivers/net/ethernet/mellanox/mlx4/qp.c
index 2033209..769598f 100644
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
 
@@ -420,7 +420,7 @@ int mlx4_qp_alloc(struct mlx4_dev *dev, int qpn, struct mlx4_qp *qp)
 	if (err)
 		goto err_icm;
 
-	atomic_set(&qp->refcount, 1);
+	refcount_set(&qp->refcount, 1);
 	init_completion(&qp->free);
 
 	return 0;
@@ -520,7 +520,7 @@ EXPORT_SYMBOL_GPL(mlx4_qp_remove);
 
 void mlx4_qp_free(struct mlx4_dev *dev, struct mlx4_qp *qp)
 {
-	if (atomic_dec_and_test(&qp->refcount))
+	if (refcount_dec_and_test(&qp->refcount))
 		complete(&qp->free);
 	wait_for_completion(&qp->free);
 
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index daac2e3..b8e19c4 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -768,7 +768,7 @@ struct mlx4_qp {
 
 	int			qpn;
 
-	atomic_t		refcount;
+	refcount_t		refcount;
 	struct completion	free;
 	u8			usage;
 };
-- 
2.7.4
