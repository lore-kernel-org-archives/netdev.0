From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/22] i40e: use a mutex instead of spinlock in PTP user entry points
Date: Mon, 31 Oct 2016 15:29:44 -0700
Message-ID: <1477952992-125662-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1477952992-125662-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:4577 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034489AbcJaWaC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Oct 2016 18:30:02 -0400
In-Reply-To: <1477952992-125662-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

We need a locking mechanism to protect the hardware SYSTIME register
which is split over 2 values, and has internal hardware latching. We
can't allow multiple accesses at the same time. However....

The spinlock_t is overkill here, especially use of spin_lock_irqsave,
since every PTP access will halt hardirqs. Notice that the only places
which need the SYSTIME value are user context and are capable of sleeping.
Thus, it is safe to use a mutex here instead of the spinlock.

Change-ID: I971761a89b58c6aad953590162e85a327fbba232
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h     |  2 +-
 drivers/net/ethernet/intel/i40e/i40e_ptp.c | 20 +++++++-------------
 2 files changed, 8 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 60dbb5b..21f2bb3 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -430,7 +430,7 @@ struct i40e_pf {
 	struct sk_buff *ptp_tx_skb;
 	struct hwtstamp_config tstamp_config;
 	unsigned long last_rx_ptp_check;
-	spinlock_t tmreg_lock; /* Used to protect the device time registers. */
+	struct mutex tmreg_lock; /* Used to protect the SYSTIME registers. */
 	u64 ptp_base_adj;
 	u32 tx_hwtstamp_timeouts;
 	u32 rx_hwtstamp_cleared;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ptp.c b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
index f1fecea..177b7fb 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ptp.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
@@ -159,16 +159,15 @@ static int i40e_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
 {
 	struct i40e_pf *pf = container_of(ptp, struct i40e_pf, ptp_caps);
 	struct timespec64 now, then;
-	unsigned long flags;
 
 	then = ns_to_timespec64(delta);
-	spin_lock_irqsave(&pf->tmreg_lock, flags);
+	mutex_lock(&pf->tmreg_lock);
 
 	i40e_ptp_read(pf, &now);
 	now = timespec64_add(now, then);
 	i40e_ptp_write(pf, (const struct timespec64 *)&now);
 
-	spin_unlock_irqrestore(&pf->tmreg_lock, flags);
+	mutex_unlock(&pf->tmreg_lock);
 
 	return 0;
 }
@@ -184,11 +183,10 @@ static int i40e_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
 static int i40e_ptp_gettime(struct ptp_clock_info *ptp, struct timespec64 *ts)
 {
 	struct i40e_pf *pf = container_of(ptp, struct i40e_pf, ptp_caps);
-	unsigned long flags;
 
-	spin_lock_irqsave(&pf->tmreg_lock, flags);
+	mutex_lock(&pf->tmreg_lock);
 	i40e_ptp_read(pf, ts);
-	spin_unlock_irqrestore(&pf->tmreg_lock, flags);
+	mutex_unlock(&pf->tmreg_lock);
 
 	return 0;
 }
@@ -205,11 +203,10 @@ static int i40e_ptp_settime(struct ptp_clock_info *ptp,
 			    const struct timespec64 *ts)
 {
 	struct i40e_pf *pf = container_of(ptp, struct i40e_pf, ptp_caps);
-	unsigned long flags;
 
-	spin_lock_irqsave(&pf->tmreg_lock, flags);
+	mutex_lock(&pf->tmreg_lock);
 	i40e_ptp_write(pf, ts);
-	spin_unlock_irqrestore(&pf->tmreg_lock, flags);
+	mutex_unlock(&pf->tmreg_lock);
 
 	return 0;
 }
@@ -658,10 +655,7 @@ void i40e_ptp_init(struct i40e_pf *pf)
 		return;
 	}
 
-	/* we have to initialize the lock first, since we can't control
-	 * when the user will enter the PHC device entry points
-	 */
-	spin_lock_init(&pf->tmreg_lock);
+	mutex_init(&pf->tmreg_lock);
 
 	/* ensure we have a clock device */
 	err = i40e_ptp_create_clock(pf);
-- 
2.7.4
