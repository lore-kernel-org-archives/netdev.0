From: "Vlad Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-next 3/24] bnx2x: remove references to intr_sem
Date: Tue, 14 Jun 2011 14:32:53 +0300
Message-ID: <201106141432.54084.vladz@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Yaniv Rosner" <yaniv.rosner@broadcom.com>
To: "Dave Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3785 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756296Ab1FNLdh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2011 07:33:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

It's not needed any more since device always operates in interrupt-driven mode

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x.h      |    2 --
 drivers/net/bnx2x/bnx2x_cmn.c  |   23 +++++------------------
 drivers/net/bnx2x/bnx2x_main.c |   36 ------------------------------------
 3 files changed, 5 insertions(+), 56 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index 668a578..2b744b0 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -925,8 +925,6 @@ struct bnx2x {
 	struct iro		*iro_arr;
 #define IRO (bp->iro_arr)
 
-	atomic_t		intr_sem;
-
 	bnx2x_recovery_state_t	recovery_state;
 	int			is_leader;
 	struct msix_entry	*msix_table;
diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index ca2bbc0..d89a877 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -737,12 +737,6 @@ static irqreturn_t bnx2x_msix_fp_int(int irq, void *fp_cookie)
 	struct bnx2x_fastpath *fp = fp_cookie;
 	struct bnx2x *bp = fp->bp;
 
-	/* Return here if interrupt is disabled */
-	if (unlikely(atomic_read(&bp->intr_sem) != 0)) {
-		DP(NETIF_MSG_INTR, "called but intr_sem not 0, returning\n");
-		return IRQ_HANDLED;
-	}
-
 	DP(BNX2X_MSG_FP, "got an MSI-X interrupt on IDX:SB "
 			 "[fp %d fw_sd %d igusb %d]\n",
 	   fp->index, fp->fw_sb_id, fp->igu_sb_id);
@@ -1287,18 +1281,11 @@ static void bnx2x_napi_disable(struct bnx2x *bp)
 
 void bnx2x_netif_start(struct bnx2x *bp)
 {
-	int intr_sem;
-
-	intr_sem = atomic_dec_and_test(&bp->intr_sem);
-	smp_wmb(); /* Ensure that bp->intr_sem update is SMP-safe */
-
-	if (intr_sem) {
-		if (netif_running(bp->dev)) {
-			bnx2x_napi_enable(bp);
-			bnx2x_int_enable(bp);
-			if (bp->state == BNX2X_STATE_OPEN)
-				netif_tx_wake_all_queues(bp->dev);
-		}
+	if (netif_running(bp->dev)) {
+		bnx2x_napi_enable(bp);
+		bnx2x_int_enable(bp);
+		if (bp->state == BNX2X_STATE_OPEN)
+			netif_tx_wake_all_queues(bp->dev);
 	}
 }
 
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index f45c0ca..e5eb2a2 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -1285,10 +1285,6 @@ void bnx2x_int_disable_sync(struct bnx2x *bp, int disable_hw)
 	int msix = (bp->flags & USING_MSIX_FLAG) ? 1 : 0;
 	int i, offset;
 
-	/* disable interrupt handling */
-	atomic_inc(&bp->intr_sem);
-	smp_wmb(); /* Ensure that bp->intr_sem update is SMP-safe */
-
 	if (disable_hw)
 		/* prevent the HW from sending interrupts */
 		bnx2x_int_disable(bp);
@@ -1411,12 +1407,6 @@ irqreturn_t bnx2x_interrupt(int irq, void *dev_instance)
 	}
 	DP(NETIF_MSG_INTR, "got an interrupt  status 0x%x\n", status);
 
-	/* Return here if interrupt is disabled */
-	if (unlikely(atomic_read(&bp->intr_sem) != 0)) {
-		DP(NETIF_MSG_INTR, "called but intr_sem not 0, returning\n");
-		return IRQ_HANDLED;
-	}
-
 #ifdef BNX2X_STOP_ON_ERROR
 	if (unlikely(bp->panic))
 		return IRQ_HANDLED;
@@ -3808,12 +3798,6 @@ static void bnx2x_sp_task(struct work_struct *work)
 	struct bnx2x *bp = container_of(work, struct bnx2x, sp_task.work);
 	u16 status;
 
-	/* Return here if interrupt is disabled */
-	if (unlikely(atomic_read(&bp->intr_sem) != 0)) {
-		DP(NETIF_MSG_INTR, "called but intr_sem not 0, returning\n");
-		return;
-	}
-
 	status = bnx2x_update_dsb_idx(bp);
 /*	if (status == 0)				     */
 /*		BNX2X_ERR("spurious slowpath interrupt!\n"); */
@@ -3857,12 +3841,6 @@ irqreturn_t bnx2x_msix_sp_int(int irq, void *dev_instance)
 	struct net_device *dev = dev_instance;
 	struct bnx2x *bp = netdev_priv(dev);
 
-	/* Return here if interrupt is disabled */
-	if (unlikely(atomic_read(&bp->intr_sem) != 0)) {
-		DP(NETIF_MSG_INTR, "called but intr_sem not 0, returning\n");
-		return IRQ_HANDLED;
-	}
-
 	bnx2x_ack_sb(bp, bp->igu_dsb_id, USTORM_ID, 0,
 		     IGU_INT_DISABLE, 0);
 
@@ -3896,9 +3874,6 @@ static void bnx2x_timer(unsigned long data)
 	if (!netif_running(bp->dev))
 		return;
 
-	if (atomic_read(&bp->intr_sem) != 0)
-		goto timer_restart;
-
 	if (poll) {
 		struct bnx2x_fastpath *fp = &bp->fp[0];
 
@@ -3933,7 +3908,6 @@ static void bnx2x_timer(unsigned long data)
 	if (bp->state == BNX2X_STATE_OPEN)
 		bnx2x_stats_handle(bp, STATS_EVENT_UPDATE);
 
-timer_restart:
 	mod_timer(&bp->timer, jiffies + bp->current_interval);
 }
 
@@ -4503,9 +4477,6 @@ void bnx2x_nic_init(struct bnx2x *bp, u32 load_code)
 	bnx2x_init_ind_table(bp);
 	bnx2x_stats_init(bp);
 
-	/* At this point, we are ready for interrupts */
-	atomic_set(&bp->intr_sem, 0);
-
 	/* flush all before enabling interrupts */
 	mb();
 	mmiowb();
@@ -8700,10 +8671,6 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 	int timer_interval;
 	int rc;
 
-	/* Disable interrupt handling until HW is initialized */
-	atomic_set(&bp->intr_sem, 1);
-	smp_wmb(); /* Ensure that bp->intr_sem update is SMP-safe */
-
 	mutex_init(&bp->port.phy_mutex);
 	mutex_init(&bp->fw_mb_mutex);
 	spin_lock_init(&bp->stats_lock);
@@ -10221,9 +10188,6 @@ static int bnx2x_register_cnic(struct net_device *dev, struct cnic_ops *ops,
 	if (ops == NULL)
 		return -EINVAL;
 
-	if (atomic_read(&bp->intr_sem) != 0)
-		return -EBUSY;
-
 	bp->cnic_kwq = kzalloc(PAGE_SIZE, GFP_KERNEL);
 	if (!bp->cnic_kwq)
 		return -ENOMEM;
-- 
1.7.2.2


