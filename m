From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH v4 2/3] net: ethernet: ti: cpts: convert to use ptp auxiliary worker
Date: Wed, 26 Jul 2017 17:11:37 -0500
Message-ID: <20170726221138.12986-3-grygorii.strashko@ti.com>
References: <20170726221138.12986-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, Wingman Kwok <w-kwok2@ti.com>,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
        John Stultz <john.stultz@linaro.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170726221138.12986-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There could be significant delay in CPTS work schedule under high system
load and on -RT which could cause CPTS misbehavior due to internal counter
overflow. Usage of own kthread_worker allows to avoid such kind of issues
and makes it possible to tune priority of CPTS kthread_worker thread on -RT.

Hence, the CPTS driver is converted to use PTP auxiliary worker as PHC
subsystem implements such functionality in a generic way now.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/cpts.c | 27 +++++++++++++--------------
 drivers/net/ethernet/ti/cpts.h |  1 -
 2 files changed, 13 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
index 32279d2..3ed438e 100644
--- a/drivers/net/ethernet/ti/cpts.c
+++ b/drivers/net/ethernet/ti/cpts.c
@@ -224,6 +224,17 @@ static int cpts_ptp_enable(struct ptp_clock_info *ptp,
 	return -EOPNOTSUPP;
 }
 
+static long cpts_overflow_check(struct ptp_clock_info *ptp)
+{
+	struct cpts *cpts = container_of(ptp, struct cpts, info);
+	unsigned long delay = cpts->ov_check_period;
+	struct timespec64 ts;
+
+	cpts_ptp_gettime(&cpts->info, &ts);
+	pr_debug("cpts overflow check at %lld.%09lu\n", ts.tv_sec, ts.tv_nsec);
+	return (long)delay;
+}
+
 static struct ptp_clock_info cpts_info = {
 	.owner		= THIS_MODULE,
 	.name		= "CTPS timer",
@@ -236,18 +247,9 @@ static struct ptp_clock_info cpts_info = {
 	.gettime64	= cpts_ptp_gettime,
 	.settime64	= cpts_ptp_settime,
 	.enable		= cpts_ptp_enable,
+	.do_aux_work	= cpts_overflow_check,
 };
 
-static void cpts_overflow_check(struct work_struct *work)
-{
-	struct timespec64 ts;
-	struct cpts *cpts = container_of(work, struct cpts, overflow_work.work);
-
-	cpts_ptp_gettime(&cpts->info, &ts);
-	pr_debug("cpts overflow check at %lld.%09lu\n", ts.tv_sec, ts.tv_nsec);
-	schedule_delayed_work(&cpts->overflow_work, cpts->ov_check_period);
-}
-
 static int cpts_match(struct sk_buff *skb, unsigned int ptp_class,
 		      u16 ts_seqid, u8 ts_msgtype)
 {
@@ -378,7 +380,7 @@ int cpts_register(struct cpts *cpts)
 	}
 	cpts->phc_index = ptp_clock_index(cpts->clock);
 
-	schedule_delayed_work(&cpts->overflow_work, cpts->ov_check_period);
+	ptp_schedule_worker(cpts->clock, cpts->ov_check_period);
 	return 0;
 
 err_ptp:
@@ -392,8 +394,6 @@ void cpts_unregister(struct cpts *cpts)
 	if (WARN_ON(!cpts->clock))
 		return;
 
-	cancel_delayed_work_sync(&cpts->overflow_work);
-
 	ptp_clock_unregister(cpts->clock);
 	cpts->clock = NULL;
 
@@ -476,7 +476,6 @@ struct cpts *cpts_create(struct device *dev, void __iomem *regs,
 	cpts->dev = dev;
 	cpts->reg = (struct cpsw_cpts __iomem *)regs;
 	spin_lock_init(&cpts->lock);
-	INIT_DELAYED_WORK(&cpts->overflow_work, cpts_overflow_check);
 
 	ret = cpts_of_parse(cpts, node);
 	if (ret)
diff --git a/drivers/net/ethernet/ti/cpts.h b/drivers/net/ethernet/ti/cpts.h
index 01ea82b..586edd9 100644
--- a/drivers/net/ethernet/ti/cpts.h
+++ b/drivers/net/ethernet/ti/cpts.h
@@ -119,7 +119,6 @@ struct cpts {
 	u32 cc_mult; /* for the nominal frequency */
 	struct cyclecounter cc;
 	struct timecounter tc;
-	struct delayed_work overflow_work;
 	int phc_index;
 	struct clk *refclk;
 	struct list_head events;
-- 
2.10.1
