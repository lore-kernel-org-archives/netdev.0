From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 1/3] ptp: Introduce a high resolution frequency adjustment method.
Date: Tue,  8 Nov 2016 22:49:16 +0100
Message-ID: <daedc4519fddfe07770ff13bddbc72b878b48706.1478526333.git.richardcochran@gmail.com>
References: <cover.1478526333.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
        Jacob Keller <jacob.e.keller@intel.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        John Stultz <john.stultz@linaro.org>,
        Manfred Rudigier <Manfred.Rudigier@omicron.at>,
        =?UTF-8?q?Stefan=20S=C3=B8rensen?=
        <stefan.sorensen@spectralink.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Ulrik De Bie <ulrik.debie-os@e2big.org>,
        intel-wired-lan@lists.osuosl.org
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36027 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754075AbcKHVt0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2016 16:49:26 -0500
Received: by mail-wm0-f65.google.com with SMTP id c17so25324060wmc.3
        for <netdev@vger.kernel.org>; Tue, 08 Nov 2016 13:49:26 -0800 (PST)
In-Reply-To: <cover.1478526333.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The internal PTP Hardware Clock (PHC) interface limits the resolution for
frequency adjustments to one part per billion.  However, some hardware
devices allow finer adjustment, and making use of the increased resolution
improves synchronization measurably on such devices.

This patch adds an alternative method that allows finer frequency tuning
by passing the scaled ppm value to PHC drivers.  This value comes from
user space, and it has a resolution of about 0.015 ppb.  We also deprecate
the older method, anticipating its removal once existing drivers have been
converted over.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
Suggested-by: Ulrik De Bie <ulrik.debie-os@e2big.org>
---
 drivers/ptp/ptp_clock.c          | 5 ++++-
 include/linux/ptp_clock_kernel.h | 8 ++++++++
 2 files changed, 12 insertions(+), 1 deletion(-)

diff --git a/drivers/ptp/ptp_clock.c b/drivers/ptp/ptp_clock.c
index 86280b7..9c13381 100644
--- a/drivers/ptp/ptp_clock.c
+++ b/drivers/ptp/ptp_clock.c
@@ -153,7 +153,10 @@ static int ptp_clock_adjtime(struct posix_clock *pc, struct timex *tx)
 		s32 ppb = scaled_ppm_to_ppb(tx->freq);
 		if (ppb > ops->max_adj || ppb < -ops->max_adj)
 			return -ERANGE;
-		err = ops->adjfreq(ops, ppb);
+		if (ops->adjfine)
+			err = ops->adjfine(ops, tx->freq);
+		else
+			err = ops->adjfreq(ops, ppb);
 		ptp->dialed_frequency = tx->freq;
 	} else if (tx->modes == 0) {
 		tx->freq = ptp->dialed_frequency;
diff --git a/include/linux/ptp_clock_kernel.h b/include/linux/ptp_clock_kernel.h
index 5ad54fc6..b76d47a 100644
--- a/include/linux/ptp_clock_kernel.h
+++ b/include/linux/ptp_clock_kernel.h
@@ -58,7 +58,14 @@ struct system_device_crosststamp;
  *
  * clock operations
  *
+ * @adjfine:  Adjusts the frequency of the hardware clock.
+ *            parameter scaled_ppm: Desired frequency offset from
+ *            nominal frequency in parts per million, but with a
+ *            16 bit binary fractional field.
+ *
  * @adjfreq:  Adjusts the frequency of the hardware clock.
+ *            This method is deprecated.  New drivers should implement
+ *            the @adjfine method instead.
  *            parameter delta: Desired frequency offset from nominal frequency
  *            in parts per billion
  *
@@ -108,6 +115,7 @@ struct ptp_clock_info {
 	int n_pins;
 	int pps;
 	struct ptp_pin_desc *pin_config;
+	int (*adjfine)(struct ptp_clock_info *ptp, long scaled_ppm);
 	int (*adjfreq)(struct ptp_clock_info *ptp, s32 delta);
 	int (*adjtime)(struct ptp_clock_info *ptp, s64 delta);
 	int (*gettime64)(struct ptp_clock_info *ptp, struct timespec64 *ts);
-- 
2.1.4
