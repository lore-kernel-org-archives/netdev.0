From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 4/6] tg3: Enable support for timesync gpio
 output
Date: Mon, 29 Jul 2013 13:58:38 -0700
Message-ID: <1375131520-1746-5-git-send-email-nsujir@broadcom.com>
References: <1375131520-1746-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Nithin Nayak Sujir" <nsujir@broadcom.com>,
	"Richard Cochran" <richardcochran@gmail.com>,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2634 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754880Ab3G2U6y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jul 2013 16:58:54 -0400
In-Reply-To: <1375131520-1746-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PTP_CAPABLE tg3 devices have a gpio output that is toggled when the
free running counter matches a watchdog value. This patch adds support
to set the watchdog and enable this feature.

Since the output is controlled via bits in the EAV_REF_CLCK_CTL
register, we have to read-modify-write it when we stop/resume.

Cc: Richard Cochran <richardcochran@gmail.com>
Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 61 +++++++++++++++++++++++++++++++++++--
 drivers/net/ethernet/broadcom/tg3.h | 11 ++++++-
 2 files changed, 68 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 9351707..f077c8f 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -6093,10 +6093,12 @@ static u64 tg3_refclk_read(struct tg3 *tp)
 /* tp->lock must be held */
 static void tg3_refclk_write(struct tg3 *tp, u64 newval)
 {
-	tw32(TG3_EAV_REF_CLCK_CTL, TG3_EAV_REF_CLCK_CTL_STOP);
+	u32 clock_ctl = tr32(TG3_EAV_REF_CLCK_CTL);
+
+	tw32(TG3_EAV_REF_CLCK_CTL, clock_ctl | TG3_EAV_REF_CLCK_CTL_STOP);
 	tw32(TG3_EAV_REF_CLCK_LSB, newval & 0xffffffff);
 	tw32(TG3_EAV_REF_CLCK_MSB, newval >> 32);
-	tw32_f(TG3_EAV_REF_CLCK_CTL, TG3_EAV_REF_CLCK_CTL_RESUME);
+	tw32_f(TG3_EAV_REF_CLCK_CTL, clock_ctl | TG3_EAV_REF_CLCK_CTL_RESUME);
 }
 
 static inline void tg3_full_lock(struct tg3 *tp, int irq_sync);
@@ -6212,6 +6214,59 @@ static int tg3_ptp_settime(struct ptp_clock_info *ptp,
 static int tg3_ptp_enable(struct ptp_clock_info *ptp,
 			  struct ptp_clock_request *rq, int on)
 {
+	struct tg3 *tp = container_of(ptp, struct tg3, ptp_info);
+	u32 clock_ctl;
+	int rval = 0;
+
+	switch (rq->type) {
+	case PTP_CLK_REQ_PEROUT:
+		if (rq->perout.index != 0)
+			return -EINVAL;
+
+		tg3_full_lock(tp, 0);
+		clock_ctl = tr32(TG3_EAV_REF_CLCK_CTL);
+		clock_ctl &= ~TG3_EAV_CTL_TSYNC_GPIO_MASK;
+
+		if (on) {
+			u64 nsec;
+
+			nsec = rq->perout.start.sec * 1000000000ULL +
+			       rq->perout.start.nsec;
+
+			if (rq->perout.period.sec || rq->perout.period.nsec) {
+				netdev_warn(tp->dev,
+					    "Device supports only a one-shot timesync output, period must be 0\n");
+				rval = -EINVAL;
+				goto err_out;
+			}
+
+			if (nsec & (1ULL << 63)) {
+				netdev_warn(tp->dev,
+					    "Start value (nsec) is over limit. Maximum size of start is only 63 bits\n");
+				rval = -EINVAL;
+				goto err_out;
+			}
+
+			tw32(TG3_EAV_WATCHDOG0_LSB, (nsec & 0xffffffff));
+			tw32(TG3_EAV_WATCHDOG0_MSB,
+			     TG3_EAV_WATCHDOG0_EN |
+			     ((nsec >> 32) & TG3_EAV_WATCHDOG_MSB_MASK));
+
+			tw32(TG3_EAV_REF_CLCK_CTL,
+			     clock_ctl | TG3_EAV_CTL_TSYNC_WDOG0);
+		} else {
+			tw32(TG3_EAV_WATCHDOG0_MSB, 0);
+			tw32(TG3_EAV_REF_CLCK_CTL, clock_ctl);
+		}
+
+err_out:
+		tg3_full_unlock(tp);
+		return rval;
+
+	default:
+		break;
+	}
+
 	return -EOPNOTSUPP;
 }
 
@@ -6221,7 +6276,7 @@ static const struct ptp_clock_info tg3_ptp_caps = {
 	.max_adj	= 250000000,
 	.n_alarm	= 0,
 	.n_ext_ts	= 0,
-	.n_per_out	= 0,
+	.n_per_out	= 1,
 	.pps		= 0,
 	.adjfreq	= tg3_ptp_adjfreq,
 	.adjtime	= tg3_ptp_adjtime,
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index cd63d11..2e0f3d3 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -1818,12 +1818,21 @@
 #define TG3_EAV_REF_CLCK_CTL		0x00006908
 #define  TG3_EAV_REF_CLCK_CTL_STOP	 0x00000002
 #define  TG3_EAV_REF_CLCK_CTL_RESUME	 0x00000004
+#define  TG3_EAV_CTL_TSYNC_GPIO_MASK	 (0x3 << 16)
+#define  TG3_EAV_CTL_TSYNC_WDOG0	 (1 << 17)
+
+#define TG3_EAV_WATCHDOG0_LSB		0x00006918
+#define TG3_EAV_WATCHDOG0_MSB		0x0000691c
+#define  TG3_EAV_WATCHDOG0_EN		 (1 << 31)
+#define  TG3_EAV_WATCHDOG_MSB_MASK	0x7fffffff
+
 #define TG3_EAV_REF_CLK_CORRECT_CTL	0x00006928
 #define  TG3_EAV_REF_CLK_CORRECT_EN	 (1 << 31)
 #define  TG3_EAV_REF_CLK_CORRECT_NEG	 (1 << 30)
 
 #define TG3_EAV_REF_CLK_CORRECT_MASK	0xffffff
-/* 0x690c --> 0x7000 unused */
+
+/* 0x692c --> 0x7000 unused */
 
 /* NVRAM Control registers */
 #define NVRAM_CMD			0x00007000
-- 
1.8.1.4
