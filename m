From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH 1/2] net: ethernet: ti: cpts: convert to use
 kthread_worker
Date: Mon, 24 Jul 2017 19:34:38 -0500
Message-ID: <bc4bf624-e58e-657c-0520-9fd50d6666a6@ti.com>
References: <20170721234943.3841-1-grygorii.strashko@ti.com>
 <20170721234943.3841-2-grygorii.strashko@ti.com>
 <20170722052914.yo62jqdqsdv4hc5q@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, Wingman Kwok <w-kwok2@ti.com>,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx210.ext.ti.com ([198.47.19.17]:27470 "EHLO
        fllnx210.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752261AbdGYAel (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 20:34:41 -0400
In-Reply-To: <20170722052914.yo62jqdqsdv4hc5q@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Richard,

On 07/22/2017 12:29 AM, Richard Cochran wrote:
> On Fri, Jul 21, 2017 at 06:49:42PM -0500, Grygorii Strashko wrote:
>> There could be significant delay in CPTS work schedule under high system
>> load and on -RT which could cause CPTS misbehavior due to internal counter
>> overflow. Usage of own kthread_worker allows to avoid such kind of issues
>> and makes it possible to tune priority of CPTS kthread_worker thread on -RT
>> (thread name "cpts").
> 
> I have also seen excessive delays in the time stamp work from the
> dp83640 under certain loads.  Can we please implement this time stamp
> kthread_worker in the PHC subsystem?  That way, the facility can be
> used by other drivers without code duplication.

Below if pure TBD/RFC version of patch which add kthread worker to PTP core.
I'm sending it to get you opinion about implementation in general, before 
continue with more changes. Pls, take a look if you have time?
- are you ok with names (API, callbacks, ptp structs members)?

I can prepare, update and resend proper patches tom if feedback is positive.
I also can convert dp83640 driver to use new feature, but I can't test it.

>From 48212c4564ae38d633d95723b1f4616dee195b47 Mon Sep 17 00:00:00 2001
From: Grygorii Strashko <grygorii.strashko@ti.com>
Date: Mon, 24 Jul 2017 19:19:50 -0500
Subject: [PATCH] [rfc] ptp: add auxiliary worker

Add auxiliary kthread worker to PTP core so drivers can
re-use it and benefit from common implementation which is RT
friendly... TBD

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/cpts.c   | 53 +++++++++++++++-------------------------
 drivers/net/ethernet/ti/cpts.h   |  2 --
 drivers/ptp/ptp_clock.c          | 42 +++++++++++++++++++++++++++++++
 drivers/ptp/ptp_private.h        |  3 +++
 include/linux/ptp_clock_kernel.h | 15 ++++++++++++
 5 files changed, 80 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
index 746dd1d..e05a1b4 100644
--- a/drivers/net/ethernet/ti/cpts.c
+++ b/drivers/net/ethernet/ti/cpts.c
@@ -280,23 +280,9 @@ static int cpts_ptp_enable(struct ptp_clock_info *ptp,
 	return -EOPNOTSUPP;
 }
 
-static struct ptp_clock_info cpts_info = {
-	.owner		= THIS_MODULE,
-	.name		= "CTPS timer",
-	.max_adj	= 1000000,
-	.n_ext_ts	= 0,
-	.n_pins		= 0,
-	.pps		= 0,
-	.adjfreq	= cpts_ptp_adjfreq,
-	.adjtime	= cpts_ptp_adjtime,
-	.gettime64	= cpts_ptp_gettime,
-	.settime64	= cpts_ptp_settime,
-	.enable		= cpts_ptp_enable,
-};
-
-static void cpts_overflow_check(struct kthread_work *work)
+static long cpts_overflow_check(struct ptp_clock_info *ptp)
 {
-	struct cpts *cpts = container_of(work, struct cpts, overflow_work.work);
+	struct cpts *cpts = container_of(ptp, struct cpts, info);
 	unsigned long delay = cpts->ov_check_period;
 	struct timespec64 ts;
 	unsigned long flags;
@@ -309,9 +295,24 @@ static void cpts_overflow_check(struct kthread_work *work)
 	spin_unlock_irqrestore(&cpts->lock, flags);
 
 	pr_debug("cpts overflow check at %lld.%09lu\n", ts.tv_sec, ts.tv_nsec);
-	kthread_queue_delayed_work(cpts->kworker, &cpts->overflow_work, delay);
+	return (long)delay;
 }
 
+static struct ptp_clock_info cpts_info = {
+	.owner		= THIS_MODULE,
+	.name		= "CTPS timer",
+	.max_adj	= 1000000,
+	.n_ext_ts	= 0,
+	.n_pins		= 0,
+	.pps		= 0,
+	.adjfreq	= cpts_ptp_adjfreq,
+	.adjtime	= cpts_ptp_adjtime,
+	.gettime64	= cpts_ptp_gettime,
+	.settime64	= cpts_ptp_settime,
+	.enable		= cpts_ptp_enable,
+	.do_aux_work	= cpts_overflow_check,
+};
+
 static int cpts_match(struct sk_buff *skb, unsigned int ptp_class,
 		      u16 ts_seqid, u8 ts_msgtype)
 {
@@ -392,8 +393,7 @@ static u64 cpts_find_ts(struct cpts *cpts, struct sk_buff *skb, int ev_type)
 		/* get the timestamp for timeouts */
 		skb_cb->tmo = jiffies + msecs_to_jiffies(100);
 		__skb_queue_tail(&cpts->txq, skb);
-		kthread_mod_delayed_work(cpts->kworker,
-					 &cpts->overflow_work, 0);
+		ptp_schedule_worker(cpts->clock, 0);
 	}
 	spin_unlock_irqrestore(&cpts->lock, flags);
 
@@ -457,8 +457,7 @@ int cpts_register(struct cpts *cpts)
 	}
 	cpts->phc_index = ptp_clock_index(cpts->clock);
 
-	kthread_queue_delayed_work(cpts->kworker, &cpts->overflow_work,
-				   cpts->ov_check_period);
+	ptp_schedule_worker(cpts->clock, cpts->ov_check_period);
 	return 0;
 
 err_ptp:
@@ -472,8 +471,6 @@ void cpts_unregister(struct cpts *cpts)
 	if (WARN_ON(!cpts->clock))
 		return;
 
-	kthread_cancel_delayed_work_sync(&cpts->overflow_work);
-
 	ptp_clock_unregister(cpts->clock);
 	cpts->clock = NULL;
 
@@ -570,14 +567,6 @@ struct cpts *cpts_create(struct device *dev, void __iomem *regs,
 		return ERR_PTR(PTR_ERR(cpts->refclk));
 	}
 
-	kthread_init_delayed_work(&cpts->overflow_work, cpts_overflow_check);
-	cpts->kworker = kthread_create_worker(0, "cpts");
-	if (IS_ERR(cpts->kworker)) {
-		dev_err(dev, "failed to create cpts overflow_work task %ld\n",
-			PTR_ERR(cpts->kworker));
-		return ERR_CAST(cpts->kworker);
-	}
-
 	clk_prepare(cpts->refclk);
 
 	cpts->cc.read = cpts_systim_read;
@@ -603,8 +592,6 @@ void cpts_release(struct cpts *cpts)
 		return;
 
 	clk_unprepare(cpts->refclk);
-
-	kthread_destroy_worker(cpts->kworker);
 }
 EXPORT_SYMBOL_GPL(cpts_release);
 
diff --git a/drivers/net/ethernet/ti/cpts.h b/drivers/net/ethernet/ti/cpts.h
index e94b829..a9f4eec 100644
--- a/drivers/net/ethernet/ti/cpts.h
+++ b/drivers/net/ethernet/ti/cpts.h
@@ -126,8 +126,6 @@ struct cpts {
 	struct list_head pool;
 	struct cpts_event pool_data[CPTS_MAX_EVENTS];
 	unsigned long ov_check_period;
-	struct kthread_worker *kworker;
-	struct kthread_delayed_work overflow_work;
 	struct sk_buff_head txq;
 };
 
diff --git a/drivers/ptp/ptp_clock.c b/drivers/ptp/ptp_clock.c
index b774357..9bea56a 100644
--- a/drivers/ptp/ptp_clock.c
+++ b/drivers/ptp/ptp_clock.c
@@ -28,6 +28,7 @@
 #include <linux/slab.h>
 #include <linux/syscalls.h>
 #include <linux/uaccess.h>
+#include <uapi/linux/sched/types.h>
 
 #include "ptp_private.h"
 
@@ -184,6 +185,19 @@ static void delete_ptp_clock(struct posix_clock *pc)
 	kfree(ptp);
 }
 
+static void ptp_aux_kworker(struct kthread_work *work)
+{
+	struct ptp_clock *ptp = container_of(work, struct ptp_clock,
+					     aux_work.work);
+	struct ptp_clock_info *info = ptp->info;
+	long delay;
+
+	delay = info->do_aux_work(info);
+
+	if (delay >= 0)
+		kthread_queue_delayed_work(ptp->kworker, &ptp->aux_work, delay);
+}
+
 /* public interface */
 
 struct ptp_clock *ptp_clock_register(struct ptp_clock_info *info,
@@ -217,6 +231,23 @@ struct ptp_clock *ptp_clock_register(struct ptp_clock_info *info,
 	mutex_init(&ptp->pincfg_mux);
 	init_waitqueue_head(&ptp->tsev_wq);
 
+	if (ptp->info->do_aux_work) {
+		struct sched_param param = {
+			.sched_priority = MAX_RT_PRIO - 1 };
+
+		kthread_init_delayed_work(&ptp->aux_work, ptp_aux_kworker);
+		ptp->kworker = kthread_create_worker(0, info->name);
+		if (IS_ERR(ptp->kworker)) {
+			pr_err("failed to create ptp aux_worker task %ld\n",
+			       PTR_ERR(ptp->kworker));
+			return ERR_CAST(ptp->kworker);
+		}
+		err = sched_setscheduler_nocheck(ptp->kworker->task,
+						 SCHED_FIFO, &param);
+		if (err)
+			pr_err("sched_setscheduler_nocheck err %d\n", err);
+	}
+
 	err = ptp_populate_pin_groups(ptp);
 	if (err)
 		goto no_pin_groups;
@@ -274,6 +305,9 @@ int ptp_clock_unregister(struct ptp_clock *ptp)
 	ptp->defunct = 1;
 	wake_up_interruptible(&ptp->tsev_wq);
 
+	kthread_cancel_delayed_work_sync(&ptp->aux_work);
+	kthread_destroy_worker(ptp->kworker);
+
 	/* Release the clock's resources. */
 	if (ptp->pps_source)
 		pps_unregister_source(ptp->pps_source);
@@ -339,6 +373,14 @@ int ptp_find_pin(struct ptp_clock *ptp,
 }
 EXPORT_SYMBOL(ptp_find_pin);
 
+int ptp_schedule_worker(struct ptp_clock *ptp, unsigned long delay)
+{
+	if (!ptp->kworker)
+		return -EOPNOTSUPP;
+	return kthread_mod_delayed_work(ptp->kworker, &ptp->aux_work, delay);
+}
+EXPORT_SYMBOL(ptp_schedule_worker);
+
 /* module operations */
 
 static void __exit ptp_exit(void)
diff --git a/drivers/ptp/ptp_private.h b/drivers/ptp/ptp_private.h
index d958889..b86f1bf 100644
--- a/drivers/ptp/ptp_private.h
+++ b/drivers/ptp/ptp_private.h
@@ -22,6 +22,7 @@
 
 #include <linux/cdev.h>
 #include <linux/device.h>
+#include <linux/kthread.h>
 #include <linux/mutex.h>
 #include <linux/posix-clock.h>
 #include <linux/ptp_clock.h>
@@ -56,6 +57,8 @@ struct ptp_clock {
 	struct attribute_group pin_attr_group;
 	/* 1st entry is a pointer to the real group, 2nd is NULL terminator */
 	const struct attribute_group *pin_attr_groups[2];
+	struct kthread_worker *kworker;
+	struct kthread_delayed_work aux_work;
 };
 
 /*
diff --git a/include/linux/ptp_clock_kernel.h b/include/linux/ptp_clock_kernel.h
index a026bfd..1b8832a 100644
--- a/include/linux/ptp_clock_kernel.h
+++ b/include/linux/ptp_clock_kernel.h
@@ -98,6 +98,10 @@ struct system_device_crosststamp;
  *            parameter pin: index of the pin in question.
  *            parameter func: the desired function to use.
  *            parameter chan: the function channel index to use.
+ * @do_work:  Request driver to perform auxiliary (periodic) operations
+ *	      Driver should return delay of the next auxiliary work scheduling
+ *	      time (>=0) or negative value in case further scheduling
+ *	      is not required.
  *
  * Drivers should embed their ptp_clock_info within a private
  * structure, obtaining a reference to it using container_of().
@@ -126,6 +130,7 @@ struct ptp_clock_info {
 		      struct ptp_clock_request *request, int on);
 	int (*verify)(struct ptp_clock_info *ptp, unsigned int pin,
 		      enum ptp_pin_function func, unsigned int chan);
+	long (*do_aux_work)(struct ptp_clock_info *ptp);
 };
 
 struct ptp_clock;
@@ -211,6 +216,16 @@ extern int ptp_clock_index(struct ptp_clock *ptp);
 int ptp_find_pin(struct ptp_clock *ptp,
 		 enum ptp_pin_function func, unsigned int chan);
 
+/**
+ * ptp_schedule_worker() - schedule ptp auxiliary work
+ *
+ * @ptp:    The clock obtained from ptp_clock_register().
+ * @delay:  number of jiffies to wait before queuing
+ *          See kthread_queue_delayed_work() for more info.
+ */
+
+int ptp_schedule_worker(struct ptp_clock *ptp, unsigned long delay);
+
 #else
 static inline struct ptp_clock *ptp_clock_register(struct ptp_clock_info *info,
 						   struct device *parent)
-- 
2.10.1

-- 
regards,
-grygorii
