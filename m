From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH 1/2] net: ethernet: ti: cpts: convert to use kthread_worker
Date: Fri, 21 Jul 2017 18:49:42 -0500
Message-ID: <20170721234943.3841-2-grygorii.strashko@ti.com>
References: <20170721234943.3841-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, Wingman Kwok <w-kwok2@ti.com>,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170721234943.3841-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There could be significant delay in CPTS work schedule under high system
load and on -RT which could cause CPTS misbehavior due to internal counter
overflow. Usage of own kthread_worker allows to avoid such kind of issues
and makes it possible to tune priority of CPTS kthread_worker thread on -RT
(thread name "cpts").

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/cpts.c | 23 +++++++++++++++++------
 drivers/net/ethernet/ti/cpts.h |  4 +++-
 2 files changed, 20 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
index 32279d2..6a520ae 100644
--- a/drivers/net/ethernet/ti/cpts.c
+++ b/drivers/net/ethernet/ti/cpts.c
@@ -20,12 +20,12 @@
 #include <linux/err.h>
 #include <linux/if.h>
 #include <linux/hrtimer.h>
+#include <linux/kthread.h>
 #include <linux/module.h>
 #include <linux/net_tstamp.h>
 #include <linux/ptp_classify.h>
 #include <linux/time.h>
 #include <linux/uaccess.h>
-#include <linux/workqueue.h>
 #include <linux/if_ether.h>
 #include <linux/if_vlan.h>
 
@@ -238,14 +238,15 @@ static struct ptp_clock_info cpts_info = {
 	.enable		= cpts_ptp_enable,
 };
 
-static void cpts_overflow_check(struct work_struct *work)
+static void cpts_overflow_check(struct kthread_work *work)
 {
 	struct timespec64 ts;
 	struct cpts *cpts = container_of(work, struct cpts, overflow_work.work);
 
 	cpts_ptp_gettime(&cpts->info, &ts);
 	pr_debug("cpts overflow check at %lld.%09lu\n", ts.tv_sec, ts.tv_nsec);
-	schedule_delayed_work(&cpts->overflow_work, cpts->ov_check_period);
+	kthread_queue_delayed_work(cpts->kworker, &cpts->overflow_work,
+				   cpts->ov_check_period);
 }
 
 static int cpts_match(struct sk_buff *skb, unsigned int ptp_class,
@@ -378,7 +379,8 @@ int cpts_register(struct cpts *cpts)
 	}
 	cpts->phc_index = ptp_clock_index(cpts->clock);
 
-	schedule_delayed_work(&cpts->overflow_work, cpts->ov_check_period);
+	kthread_queue_delayed_work(cpts->kworker, &cpts->overflow_work,
+				   cpts->ov_check_period);
 	return 0;
 
 err_ptp:
@@ -392,7 +394,7 @@ void cpts_unregister(struct cpts *cpts)
 	if (WARN_ON(!cpts->clock))
 		return;
 
-	cancel_delayed_work_sync(&cpts->overflow_work);
+	kthread_cancel_delayed_work_sync(&cpts->overflow_work);
 
 	ptp_clock_unregister(cpts->clock);
 	cpts->clock = NULL;
@@ -476,7 +478,6 @@ struct cpts *cpts_create(struct device *dev, void __iomem *regs,
 	cpts->dev = dev;
 	cpts->reg = (struct cpsw_cpts __iomem *)regs;
 	spin_lock_init(&cpts->lock);
-	INIT_DELAYED_WORK(&cpts->overflow_work, cpts_overflow_check);
 
 	ret = cpts_of_parse(cpts, node);
 	if (ret)
@@ -488,6 +489,14 @@ struct cpts *cpts_create(struct device *dev, void __iomem *regs,
 		return ERR_PTR(PTR_ERR(cpts->refclk));
 	}
 
+	kthread_init_delayed_work(&cpts->overflow_work, cpts_overflow_check);
+	cpts->kworker = kthread_create_worker(0, "cpts");
+	if (IS_ERR(cpts->kworker)) {
+		dev_err(dev, "failed to create cpts overflow_work task %ld\n",
+			PTR_ERR(cpts->kworker));
+		return ERR_CAST(cpts->kworker);
+	}
+
 	clk_prepare(cpts->refclk);
 
 	cpts->cc.read = cpts_systim_read;
@@ -513,6 +522,8 @@ void cpts_release(struct cpts *cpts)
 		return;
 
 	clk_unprepare(cpts->refclk);
+
+	kthread_destroy_worker(cpts->kworker);
 }
 EXPORT_SYMBOL_GPL(cpts_release);
 
diff --git a/drivers/net/ethernet/ti/cpts.h b/drivers/net/ethernet/ti/cpts.h
index 01ea82b..e8128e8 100644
--- a/drivers/net/ethernet/ti/cpts.h
+++ b/drivers/net/ethernet/ti/cpts.h
@@ -27,6 +27,7 @@
 #include <linux/clocksource.h>
 #include <linux/device.h>
 #include <linux/list.h>
+#include <linux/kthread.h>
 #include <linux/of.h>
 #include <linux/ptp_clock_kernel.h>
 #include <linux/skbuff.h>
@@ -119,13 +120,14 @@ struct cpts {
 	u32 cc_mult; /* for the nominal frequency */
 	struct cyclecounter cc;
 	struct timecounter tc;
-	struct delayed_work overflow_work;
 	int phc_index;
 	struct clk *refclk;
 	struct list_head events;
 	struct list_head pool;
 	struct cpts_event pool_data[CPTS_MAX_EVENTS];
 	unsigned long ov_check_period;
+	struct kthread_worker *kworker;
+	struct kthread_delayed_work overflow_work;
 };
 
 void cpts_rx_timestamp(struct cpts *cpts, struct sk_buff *skb);
-- 
2.10.1
