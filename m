From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 4/5] ntp/pps: use y2038 safe types in pps_event_time
Date: Mon, 28 Sep 2015 22:21:31 +0200
Message-ID: <1443471692-2946597-5-git-send-email-arnd@arndb.de>
References: <1443471692-2946597-1-git-send-email-arnd@arndb.de>
Cc: Thomas Gleixner <tglx@linutronix.de>,
	John Stultz <john.stultz@linaro.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Rodolfo Giometti <giometti@enneenne.com>,
	linux-net-drivers@solarflare.com,
	Shradha Shah <sshah@solarflare.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>
To: y2038@lists.linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443471692-2946597-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The pps_event_time uses two 'timespec' structures internally, which
suffer from the y2038 problem. The uses of this structure are
fairly self-contained in the pps code, so this replaces them all at
once.

Unfortunately, this includes the sfc ethernet driver aside from the
pps subsystem, so we change that one as well. Both touch the
same data structure, and there probably is no good way to split
the patch into smaller units.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/sfc/ptp.c | 16 ++++++++--------
 drivers/pps/kapi.c             |  4 ++--
 drivers/pps/kc.c               |  4 +---
 include/linux/pps_kernel.h     | 21 ++++++++-------------
 4 files changed, 19 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index ad62615a93dc..fe849dbf9f80 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -646,28 +646,28 @@ static void efx_ptp_send_times(struct efx_nic *efx,
 			       struct pps_event_time *last_time)
 {
 	struct pps_event_time now;
-	struct timespec limit;
+	struct timespec64 limit;
 	struct efx_ptp_data *ptp = efx->ptp_data;
-	struct timespec start;
+	struct timespec64 start;
 	int *mc_running = ptp->start.addr;
 
 	pps_get_ts(&now);
 	start = now.ts_real;
 	limit = now.ts_real;
-	timespec_add_ns(&limit, SYNCHRONISE_PERIOD_NS);
+	timespec64_add_ns(&limit, SYNCHRONISE_PERIOD_NS);
 
 	/* Write host time for specified period or until MC is done */
-	while ((timespec_compare(&now.ts_real, &limit) < 0) &&
+	while ((timespec64_compare(&now.ts_real, &limit) < 0) &&
 	       ACCESS_ONCE(*mc_running)) {
-		struct timespec update_time;
+		struct timespec64 update_time;
 		unsigned int host_time;
 
 		/* Don't update continuously to avoid saturating the PCIe bus */
 		update_time = now.ts_real;
-		timespec_add_ns(&update_time, SYNCHRONISATION_GRANULARITY_NS);
+		timespec64_add_ns(&update_time, SYNCHRONISATION_GRANULARITY_NS);
 		do {
 			pps_get_ts(&now);
-		} while ((timespec_compare(&now.ts_real, &update_time) < 0) &&
+		} while ((timespec64_compare(&now.ts_real, &update_time) < 0) &&
 			 ACCESS_ONCE(*mc_running));
 
 		/* Synchronise NIC with single word of time only */
@@ -723,7 +723,7 @@ efx_ptp_process_times(struct efx_nic *efx, MCDI_DECLARE_STRUCT_PTR(synch_buf),
 	struct efx_ptp_data *ptp = efx->ptp_data;
 	u32 last_sec;
 	u32 start_sec;
-	struct timespec delta;
+	struct timespec64 delta;
 	ktime_t mc_time;
 
 	if (number_readings == 0)
diff --git a/drivers/pps/kapi.c b/drivers/pps/kapi.c
index cdad4d95b20e..805c749ac1ad 100644
--- a/drivers/pps/kapi.c
+++ b/drivers/pps/kapi.c
@@ -179,8 +179,8 @@ void pps_event(struct pps_device *pps, struct pps_event_time *ts, int event,
 	/* check event type */
 	BUG_ON((event & (PPS_CAPTUREASSERT | PPS_CAPTURECLEAR)) == 0);
 
-	dev_dbg(pps->dev, "PPS event at %ld.%09ld\n",
-			ts->ts_real.tv_sec, ts->ts_real.tv_nsec);
+	dev_dbg(pps->dev, "PPS event at %lld.%09ld\n",
+			(s64)ts->ts_real.tv_sec, ts->ts_real.tv_nsec);
 
 	timespec_to_pps_ktime(&ts_real, ts->ts_real);
 
diff --git a/drivers/pps/kc.c b/drivers/pps/kc.c
index a16cea2ba980..e219db1f1c84 100644
--- a/drivers/pps/kc.c
+++ b/drivers/pps/kc.c
@@ -113,12 +113,10 @@ void pps_kc_event(struct pps_device *pps, struct pps_event_time *ts,
 		int event)
 {
 	unsigned long flags;
-	struct timespec64 real = timespec_to_timespec64(ts->ts_real);
-	struct timespec64 raw = timespec_to_timespec64(ts->ts_raw);
 
 	/* Pass some events to kernel consumer if activated */
 	spin_lock_irqsave(&pps_kc_hardpps_lock, flags);
 	if (pps == pps_kc_hardpps_dev && event & pps_kc_hardpps_mode)
-		hardpps(&real, &raw);
+		hardpps(&ts->ts_real, &ts->ts_raw);
 	spin_unlock_irqrestore(&pps_kc_hardpps_lock, flags);
 }
diff --git a/include/linux/pps_kernel.h b/include/linux/pps_kernel.h
index b2fbd62ab18d..54bf1484d41f 100644
--- a/include/linux/pps_kernel.h
+++ b/include/linux/pps_kernel.h
@@ -48,9 +48,9 @@ struct pps_source_info {
 
 struct pps_event_time {
 #ifdef CONFIG_NTP_PPS
-	struct timespec ts_raw;
+	struct timespec64 ts_raw;
 #endif /* CONFIG_NTP_PPS */
-	struct timespec ts_real;
+	struct timespec64 ts_real;
 };
 
 /* The main struct */
@@ -105,7 +105,7 @@ extern void pps_event(struct pps_device *pps,
 struct pps_device *pps_lookup_dev(void const *cookie);
 
 static inline void timespec_to_pps_ktime(struct pps_ktime *kt,
-		struct timespec ts)
+		struct timespec64 ts)
 {
 	kt->sec = ts.tv_sec;
 	kt->nsec = ts.tv_nsec;
@@ -115,29 +115,24 @@ static inline void timespec_to_pps_ktime(struct pps_ktime *kt,
 
 static inline void pps_get_ts(struct pps_event_time *ts)
 {
-	struct timespec64 raw, real;
-
-	ktime_get_raw_and_real_ts64(&raw, &real);
-
-	ts->ts_raw = timespec64_to_timespec(raw);
-	ts->ts_real = timespec64_to_timespec(real);
+	ktime_get_raw_and_real_ts64(&ts->ts_raw, &ts->ts_real);
 }
 
 #else /* CONFIG_NTP_PPS */
 
 static inline void pps_get_ts(struct pps_event_time *ts)
 {
-	getnstimeofday(&ts->ts_real);
+	ktime_get_real_ts64(&ts->ts_real);
 }
 
 #endif /* CONFIG_NTP_PPS */
 
 /* Subtract known time delay from PPS event time(s) */
-static inline void pps_sub_ts(struct pps_event_time *ts, struct timespec delta)
+static inline void pps_sub_ts(struct pps_event_time *ts, struct timespec64 delta)
 {
-	ts->ts_real = timespec_sub(ts->ts_real, delta);
+	ts->ts_real = timespec64_sub(ts->ts_real, delta);
 #ifdef CONFIG_NTP_PPS
-	ts->ts_raw = timespec_sub(ts->ts_raw, delta);
+	ts->ts_raw = timespec64_sub(ts->ts_raw, delta);
 #endif
 }
 
-- 
2.1.0.rc2
