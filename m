From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v2 31/31] timer: Switch to testing for .function instead of .data
Date: Wed, 20 Sep 2017 16:27:55 -0700
Message-ID: <1505950075-50223-32-git-send-email-keescook@chromium.org>
References: <1505950075-50223-1-git-send-email-keescook@chromium.org>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505950075-50223-1-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is part of the work to support switching all struct timer_list
callbacks to get the timer pointer as the argument (like other modern
callback interfaces in the kernel) instead of from the .data field.
This patch is one of several steps in removing open-coded users of the
.data field:

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
Acked-by: Dmitry Torokhov <dmitry.torokhov@gmail.com> # for input part
Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com> # for i40e part
Acked-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com> # for power
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
index cdd6f256da59..7f030d79a438 100644
--- a/drivers/base/power/wakeup.c
+++ b/drivers/base/power/wakeup.c
@@ -481,8 +481,7 @@ static bool wakeup_source_not_registered(struct wakeup_source *ws)
 	 * Use timer struct to check if the given source is initialized
 	 * by wakeup_source_add.
 	 */
-	return ws->timer.function != pm_wakeup_timer_fn ||
-		   ws->timer.data != (unsigned long)ws;
+	return ws->timer.function != pm_wakeup_timer_fn;
 }
 
 /*
diff --git a/drivers/infiniband/hw/hfi1/chip.c b/drivers/infiniband/hw/hfi1/chip.c
index b2ed4b9cda6e..efd93521d7e4 100644
--- a/drivers/infiniband/hw/hfi1/chip.c
+++ b/drivers/infiniband/hw/hfi1/chip.c
@@ -5565,9 +5565,8 @@ static int init_rcverr(struct hfi1_devdata *dd)
 
 static void free_rcverr(struct hfi1_devdata *dd)
 {
-	if (dd->rcverr_timer.data)
+	if (dd->rcverr_timer.function)
 		del_timer_sync(&dd->rcverr_timer);
-	dd->rcverr_timer.data = 0;
 }
 
 static void handle_rxe_err(struct hfi1_devdata *dd, u32 unused, u64 reg)
@@ -12067,9 +12066,8 @@ static void free_cntrs(struct hfi1_devdata *dd)
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
index fba77001c3a7..e7042e8b5e5a 100644
--- a/drivers/infiniband/hw/hfi1/init.c
+++ b/drivers/infiniband/hw/hfi1/init.c
@@ -1006,7 +1006,7 @@ static void stop_timers(struct hfi1_devdata *dd)
 
 	for (pidx = 0; pidx < dd->num_pports; ++pidx) {
 		ppd = dd->pport + pidx;
-		if (ppd->led_override_timer.data) {
+		if (ppd->led_override_timer.function) {
 			del_timer_sync(&ppd->led_override_timer);
 			atomic_set(&ppd->led_override_timer_active, 0);
 		}
diff --git a/drivers/infiniband/hw/qib/qib_iba7220.c b/drivers/infiniband/hw/qib/qib_iba7220.c
index 51a9266eea78..6fd83b91a1db 100644
--- a/drivers/infiniband/hw/qib/qib_iba7220.c
+++ b/drivers/infiniband/hw/qib/qib_iba7220.c
@@ -1663,7 +1663,7 @@ static void qib_7220_quiet_serdes(struct qib_pportdata *ppd)
 		       dd->control | QLOGIC_IB_C_FREEZEMODE);
 
 	ppd->cpspec->chase_end = 0;
-	if (ppd->cpspec->chase_timer.data) /* if initted */
+	if (ppd->cpspec->chase_timer.function) /* if initted */
 		del_timer_sync(&ppd->cpspec->chase_timer);
 
 	if (ppd->cpspec->ibsymdelta || ppd->cpspec->iblnkerrdelta ||
diff --git a/drivers/infiniband/hw/qib/qib_iba7322.c b/drivers/infiniband/hw/qib/qib_iba7322.c
index 14cadf6d6214..1ac7afe32897 100644
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
index c5a4c65636d6..1e72522d5691 100644
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
index f3d451136248..b72185360d34 100644
--- a/drivers/infiniband/hw/qib/qib_mad.c
+++ b/drivers/infiniband/hw/qib/qib_mad.c
@@ -2491,7 +2491,7 @@ void qib_notify_free_mad_agent(struct rvt_dev_info *rdi, int port_idx)
 	struct qib_devdata *dd = container_of(ibdev,
 					      struct qib_devdata, verbs_dev);
 
-	if (dd->pport[port_idx].cong_stats.timer.data)
+	if (dd->pport[port_idx].cong_stats.timer.function)
 		del_timer_sync(&dd->pport[port_idx].cong_stats.timer);
 
 	if (dd->pport[port_idx].ibport_data.smi_ah)
diff --git a/drivers/input/input.c b/drivers/input/input.c
index d268fdc23c64..15153886253b 100644
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
index 6498da8806cb..74d550704013 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -11777,7 +11777,7 @@ static void i40e_remove(struct pci_dev *pdev)
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
