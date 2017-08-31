From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 31/31] timer: Switch to testing for .function instead of .data
Date: Thu, 31 Aug 2017 16:29:43 -0700
Message-ID: <1504222183-61202-32-git-send-email-keescook@chromium.org>
References: <1504222183-61202-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
        "Rafael J. Wysocki" <rjw@rjwysocki.net>,
        Pavel Machek <pavel@ucw.cz>, Len Brown <len.brown@intel.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Mike Marciniszyn <mike.marciniszyn@intel.com>,
        Dennis Dalessandro <dennis.dalessandro@intel.com>,
        Doug Ledford <dledford@redhat.com>,
        Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        Dmitry Torokhov <dmitry.torokhov@gmail.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        linux-pm@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-input@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33127 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751904AbdHaXj1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 19:39:27 -0400
Received: by mail-pf0-f170.google.com with SMTP id n73so3230307pfj.0
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 16:39:26 -0700 (PDT)
In-Reply-To: <1504222183-61202-1-git-send-email-keescook@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In several places, .data is checked for initialization to gate early
calls to del_timer_sync(). Checking for .function is equally valid, so
switch to this in all callers.

Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Pavel Machek <pavel@ucw.cz>
Cc: Len Brown <len.brown@intel.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Mike Marciniszyn <mike.marciniszyn@intel.com>
Cc: Dennis Dalessandro <dennis.dalessandro@intel.com>
Cc: Doug Ledford <dledford@redhat.com>
Cc: Sean Hefty <sean.hefty@intel.com>
Cc: Hal Rosenstock <hal.rosenstock@gmail.com>
Cc: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: linux-pm@vger.kernel.org
Cc: linux-rdma@vger.kernel.org
Cc: linux-input@vger.kernel.org
Cc: intel-wired-lan@lists.osuosl.org
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/base/power/wakeup.c                 |  3 +--
 drivers/infiniband/hw/hfi1/chip.c           |  6 ++----
 drivers/infiniband/hw/hfi1/init.c           |  2 +-
 drivers/infiniband/hw/qib/qib_iba7220.c     |  2 +-
 drivers/infiniband/hw/qib/qib_iba7322.c     |  2 +-
 drivers/infiniband/hw/qib/qib_init.c        | 14 +++++---------
 drivers/infiniband/hw/qib/qib_mad.c         |  2 +-
 drivers/input/input.c                       |  5 ++---
 drivers/net/ethernet/intel/i40e/i40e_main.c |  2 +-
 9 files changed, 15 insertions(+), 23 deletions(-)

diff --git a/drivers/base/power/wakeup.c b/drivers/base/power/wakeup.c
index 144e6d8fafc8..79a3c1b204af 100644
--- a/drivers/base/power/wakeup.c
+++ b/drivers/base/power/wakeup.c
@@ -479,8 +479,7 @@ static bool wakeup_source_not_registered(struct wakeup_source *ws)
 	 * Use timer struct to check if the given source is initialized
 	 * by wakeup_source_add.
 	 */
-	return ws->timer.function != pm_wakeup_timer_fn ||
-		   ws->timer.data != (unsigned long)ws;
+	return ws->timer.function != pm_wakeup_timer_fn;
 }
 
 /*
diff --git a/drivers/infiniband/hw/hfi1/chip.c b/drivers/infiniband/hw/hfi1/chip.c
index 94b54850ec75..53a6596cd7d6 100644
--- a/drivers/infiniband/hw/hfi1/chip.c
+++ b/drivers/infiniband/hw/hfi1/chip.c
@@ -5513,9 +5513,8 @@ static int init_rcverr(struct hfi1_devdata *dd)
 
 static void free_rcverr(struct hfi1_devdata *dd)
 {
-	if (dd->rcverr_timer.data)
+	if (dd->rcverr_timer.function)
 		del_timer_sync(&dd->rcverr_timer);
-	dd->rcverr_timer.data = 0;
 }
 
 static void handle_rxe_err(struct hfi1_devdata *dd, u32 unused, u64 reg)
@@ -11992,9 +11991,8 @@ static void free_cntrs(struct hfi1_devdata *dd)
 	struct hfi1_pportdata *ppd;
 	int i;
 
-	if (dd->synth_stats_timer.data)
+	if (dd->synth_stats_timer.function)
 		del_timer_sync(&dd->synth_stats_timer);
-	dd->synth_stats_timer.data = 0;
 	ppd = (struct hfi1_pportdata *)(dd + 1);
 	for (i = 0; i < dd->num_pports; i++, ppd++) {
 		kfree(ppd->cntrs);
diff --git a/drivers/infiniband/hw/hfi1/init.c b/drivers/infiniband/hw/hfi1/init.c
index 4a11d4da4c92..bc2af709c111 100644
--- a/drivers/infiniband/hw/hfi1/init.c
+++ b/drivers/infiniband/hw/hfi1/init.c
@@ -839,7 +839,7 @@ static void stop_timers(struct hfi1_devdata *dd)
 
 	for (pidx = 0; pidx < dd->num_pports; ++pidx) {
 		ppd = dd->pport + pidx;
-		if (ppd->led_override_timer.data) {
+		if (ppd->led_override_timer.function) {
 			del_timer_sync(&ppd->led_override_timer);
 			atomic_set(&ppd->led_override_timer_active, 0);
 		}
diff --git a/drivers/infiniband/hw/qib/qib_iba7220.c b/drivers/infiniband/hw/qib/qib_iba7220.c
index b1d512c7ff4b..22fd65fe7193 100644
--- a/drivers/infiniband/hw/qib/qib_iba7220.c
+++ b/drivers/infiniband/hw/qib/qib_iba7220.c
@@ -1662,7 +1662,7 @@ static void qib_7220_quiet_serdes(struct qib_pportdata *ppd)
 		       dd->control | QLOGIC_IB_C_FREEZEMODE);
 
 	ppd->cpspec->chase_end = 0;
-	if (ppd->cpspec->chase_timer.data) /* if initted */
+	if (ppd->cpspec->chase_timer.function) /* if initted */
 		del_timer_sync(&ppd->cpspec->chase_timer);
 
 	if (ppd->cpspec->ibsymdelta || ppd->cpspec->iblnkerrdelta ||
diff --git a/drivers/infiniband/hw/qib/qib_iba7322.c b/drivers/infiniband/hw/qib/qib_iba7322.c
index bb2439fff8fa..471aaf6bcbf2 100644
--- a/drivers/infiniband/hw/qib/qib_iba7322.c
+++ b/drivers/infiniband/hw/qib/qib_iba7322.c
@@ -2531,7 +2531,7 @@ static void qib_7322_mini_quiet_serdes(struct qib_pportdata *ppd)
 		cancel_delayed_work_sync(&ppd->cpspec->ipg_work);
 
 	ppd->cpspec->chase_end = 0;
-	if (ppd->cpspec->chase_timer.data) /* if initted */
+	if (ppd->cpspec->chase_timer.function) /* if initted */
 		del_timer_sync(&ppd->cpspec->chase_timer);
 
 	/*
diff --git a/drivers/infiniband/hw/qib/qib_init.c b/drivers/infiniband/hw/qib/qib_init.c
index 6c16ba1107ba..66fb0318660b 100644
--- a/drivers/infiniband/hw/qib/qib_init.c
+++ b/drivers/infiniband/hw/qib/qib_init.c
@@ -815,23 +815,19 @@ static void qib_stop_timers(struct qib_devdata *dd)
 	struct qib_pportdata *ppd;
 	int pidx;
 
-	if (dd->stats_timer.data) {
+	if (dd->stats_timer.function)
 		del_timer_sync(&dd->stats_timer);
-		dd->stats_timer.data = 0;
-	}
-	if (dd->intrchk_timer.data) {
+	if (dd->intrchk_timer.function)
 		del_timer_sync(&dd->intrchk_timer);
-		dd->intrchk_timer.data = 0;
-	}
 	for (pidx = 0; pidx < dd->num_pports; ++pidx) {
 		ppd = dd->pport + pidx;
-		if (ppd->hol_timer.data)
+		if (ppd->hol_timer.function)
 			del_timer_sync(&ppd->hol_timer);
-		if (ppd->led_override_timer.data) {
+		if (ppd->led_override_timer.function) {
 			del_timer_sync(&ppd->led_override_timer);
 			atomic_set(&ppd->led_override_timer_active, 0);
 		}
-		if (ppd->symerr_clear_timer.data)
+		if (ppd->symerr_clear_timer.function)
 			del_timer_sync(&ppd->symerr_clear_timer);
 	}
 }
diff --git a/drivers/infiniband/hw/qib/qib_mad.c b/drivers/infiniband/hw/qib/qib_mad.c
index f5a2aed31a89..37483f32935c 100644
--- a/drivers/infiniband/hw/qib/qib_mad.c
+++ b/drivers/infiniband/hw/qib/qib_mad.c
@@ -2496,7 +2496,7 @@ void qib_notify_free_mad_agent(struct rvt_dev_info *rdi, int port_idx)
 	struct qib_devdata *dd = container_of(ibdev,
 					      struct qib_devdata, verbs_dev);
 
-	if (dd->pport[port_idx].cong_stats.timer.data)
+	if (dd->pport[port_idx].cong_stats.timer.function)
 		del_timer_sync(&dd->pport[port_idx].cong_stats.timer);
 
 	if (dd->pport[port_idx].ibport_data.smi_ah)
diff --git a/drivers/input/input.c b/drivers/input/input.c
index 7e6842bd525c..a91fbbfc1b32 100644
--- a/drivers/input/input.c
+++ b/drivers/input/input.c
@@ -76,7 +76,7 @@ static void input_start_autorepeat(struct input_dev *dev, int code)
 {
 	if (test_bit(EV_REP, dev->evbit) &&
 	    dev->rep[REP_PERIOD] && dev->rep[REP_DELAY] &&
-	    dev->timer.data) {
+	    dev->timer.function) {
 		dev->repeat_key = code;
 		mod_timer(&dev->timer,
 			  jiffies + msecs_to_jiffies(dev->rep[REP_DELAY]));
@@ -1790,7 +1790,7 @@ struct input_dev *input_allocate_device(void)
 		device_initialize(&dev->dev);
 		mutex_init(&dev->mutex);
 		spin_lock_init(&dev->event_lock);
-		init_timer(&dev->timer);
+		setup_timer(&dev->timer, NULL, (unsigned long)dev);
 		INIT_LIST_HEAD(&dev->h_list);
 		INIT_LIST_HEAD(&dev->node);
 
@@ -2053,7 +2053,6 @@ static void devm_input_device_unregister(struct device *dev, void *res)
  */
 void input_enable_softrepeat(struct input_dev *dev, int delay, int period)
 {
-	dev->timer.data = (unsigned long) dev;
 	dev->timer.function = input_repeat_key;
 	dev->rep[REP_DELAY] = delay;
 	dev->rep[REP_PERIOD] = period;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 2db93d3f6d23..b9a4c1a6e4ba 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -11797,7 +11797,7 @@ static void i40e_remove(struct pci_dev *pdev)
 	/* no more scheduling of any task */
 	set_bit(__I40E_SUSPENDED, pf->state);
 	set_bit(__I40E_DOWN, pf->state);
-	if (pf->service_timer.data)
+	if (pf->service_timer.function)
 		del_timer_sync(&pf->service_timer);
 	if (pf->service_task.func)
 		cancel_work_sync(&pf->service_task);
-- 
2.7.4
