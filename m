From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH v2 1/3] ptp: introduce ptp auxiliary worker
Date: Tue, 25 Jul 2017 15:24:18 -0500
Message-ID: <20170725202420.28229-2-grygorii.strashko@ti.com>
References: <20170725202420.28229-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, Wingman Kwok <w-kwok2@ti.com>,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170725202420.28229-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Many PTP drivers required to perform some asynchronous or periodic work,
like periodically handling PHC counter overflow or handle delayed timestamp
for RX/TX network packets. In most of the cases, such work is implemented
using workqueues. Unfortunately, Kernel workqueues might introduce
significant delay in work scheduling under high system load and on -RT,
which could cause misbehavior of PTP drivers due to internal counter
overflow, for example, and there is no way to tune its execution policy and
priority manually.

Hence, The kthread_worker can be used instead of workqueues, as it creates
separate named kthread for each worker and its its execution policy and
priority can be configured using chrt tool.

This problem was reported for two drivers TI CPSW CPTS and dp83640, so
instead of modifying each of these driver it was proposed to add PTP
auxiliary worker to the PHC subsystem [1].

The patch adds PTP auxiliary worker in PHC subsystem using kthread_worker
and kthread_delayed_work and introduces two new PHC subsystem APIs:

- long (*do_aux_work)(struct ptp_clock_info *ptp) callback in
ptp_clock_info structure, which driver should assign if it require to
perform asynchronous or periodic work. Driver should return the delay of
the PTP next auxiliary work scheduling time (>=0) or negative value in case
further scheduling is not required.

- int ptp_schedule_worker(struct ptp_clock *ptp, unsigned long delay) which
allows schedule PTP auxiliary work.

The name of kthread_worker thread corresponds PTP PHC device name "ptp%d".

[1] https://www.spinics.net/lists/netdev/msg445392.html
Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/ptp/ptp_clock.c          | 40 ++++++++++++++++++++++++++++++++++++++++
 drivers/ptp/ptp_private.h        |  3 +++
 include/linux/ptp_clock_kernel.h | 19 +++++++++++++++++++
 3 files changed, 62 insertions(+)

diff --git a/drivers/ptp/ptp_clock.c b/drivers/ptp/ptp_clock.c
index b774357..7c6f3e1 100644
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
@@ -217,6 +231,19 @@ struct ptp_clock *ptp_clock_register(struct ptp_clock_info *info,
 	mutex_init(&ptp->pincfg_mux);
 	init_waitqueue_head(&ptp->tsev_wq);
 
+	if (ptp->info->do_aux_work) {
+		char *worker_name = kasprintf(GFP_KERNEL, "ptp%d", ptp->index);
+
+		kthread_init_delayed_work(&ptp->aux_work, ptp_aux_kworker);
+		ptp->kworker = kthread_create_worker(0, worker_name ?
+						     worker_name : info->name);
+		if (IS_ERR(ptp->kworker)) {
+			pr_err("failed to create ptp aux_worker task %ld\n",
+			       PTR_ERR(ptp->kworker));
+			return ERR_CAST(ptp->kworker);
+		}
+	}
+
 	err = ptp_populate_pin_groups(ptp);
 	if (err)
 		goto no_pin_groups;
@@ -274,6 +301,11 @@ int ptp_clock_unregister(struct ptp_clock *ptp)
 	ptp->defunct = 1;
 	wake_up_interruptible(&ptp->tsev_wq);
 
+	if (ptp->kworker) {
+		kthread_cancel_delayed_work_sync(&ptp->aux_work);
+		kthread_destroy_worker(ptp->kworker);
+	}
+
 	/* Release the clock's resources. */
 	if (ptp->pps_source)
 		pps_unregister_source(ptp->pps_source);
@@ -339,6 +371,14 @@ int ptp_find_pin(struct ptp_clock *ptp,
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
index a026bfd..ec86fd2 100644
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
@@ -225,6 +240,10 @@ static inline int ptp_clock_index(struct ptp_clock *ptp)
 static inline int ptp_find_pin(struct ptp_clock *ptp,
 			       enum ptp_pin_function func, unsigned int chan)
 { return -1; }
+static inline int ptp_schedule_worker(struct ptp_clock *ptp,
+				      unsigned long delay)
+{ return -EOPNOTSUPP; }
+
 #endif
 
 #endif
-- 
2.10.1
