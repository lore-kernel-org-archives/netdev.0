From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 2/2] ptp: reduce stack usage when measuring the system time offset
Date: Mon, 26 Nov 2012 12:44:35 +0100
Message-ID: <6151dfc7e5bb80d73563502a2a14c9f2aad8bdb0.1353929830.git.richardcochran@gmail.com>
References: <20121102020631.GI16883@yliu-dev.sh.intel.com>
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:62894 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753279Ab2KZLos (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 06:44:48 -0500
Received: by mail-ee0-f46.google.com with SMTP id e53so4407054eek.19
        for <netdev@vger.kernel.org>; Mon, 26 Nov 2012 03:44:47 -0800 (PST)
In-Reply-To: <20121102020631.GI16883@yliu-dev.sh.intel.com>
In-Reply-To: <1146e32bcb835ebf394bab91db3161600ab5213a.1353929829.git.richardcochran@gmail.com>
References: <1146e32bcb835ebf394bab91db3161600ab5213a.1353929829.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the large buffer from the stack of the system
offset ioctl and replaces it with a kmalloced buffer.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/ptp/ptp_chardev.c |   21 ++++++++++++++-------
 1 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/drivers/ptp/ptp_chardev.c b/drivers/ptp/ptp_chardev.c
index 9d7542e..34a0c60 100644
--- a/drivers/ptp/ptp_chardev.c
+++ b/drivers/ptp/ptp_chardev.c
@@ -34,7 +34,7 @@ long ptp_ioctl(struct posix_clock *pc, unsigned int cmd, unsigned long arg)
 {
 	struct ptp_clock_caps caps;
 	struct ptp_clock_request req;
-	struct ptp_sys_offset sysoff;
+	struct ptp_sys_offset *sysoff = NULL;
 	struct ptp_clock *ptp = container_of(pc, struct ptp_clock, clock);
 	struct ptp_clock_info *ops = ptp->info;
 	struct ptp_clock_time *pct;
@@ -94,17 +94,22 @@ long ptp_ioctl(struct posix_clock *pc, unsigned int cmd, unsigned long arg)
 		break;
 
 	case PTP_SYS_OFFSET:
-		if (copy_from_user(&sysoff, (void __user *)arg,
-				   sizeof(sysoff))) {
+		sysoff = kmalloc(sizeof(*sysoff), GFP_KERNEL);
+		if (!sysoff) {
+			err = -ENOMEM;
+			break;
+		}
+		if (copy_from_user(sysoff, (void __user *)arg,
+				   sizeof(*sysoff))) {
 			err = -EFAULT;
 			break;
 		}
-		if (sysoff.n_samples > PTP_MAX_SAMPLES) {
+		if (sysoff->n_samples > PTP_MAX_SAMPLES) {
 			err = -EINVAL;
 			break;
 		}
-		pct = &sysoff.ts[0];
-		for (i = 0; i < sysoff.n_samples; i++) {
+		pct = &sysoff->ts[0];
+		for (i = 0; i < sysoff->n_samples; i++) {
 			getnstimeofday(&ts);
 			pct->sec = ts.tv_sec;
 			pct->nsec = ts.tv_nsec;
@@ -117,7 +122,7 @@ long ptp_ioctl(struct posix_clock *pc, unsigned int cmd, unsigned long arg)
 		getnstimeofday(&ts);
 		pct->sec = ts.tv_sec;
 		pct->nsec = ts.tv_nsec;
-		if (copy_to_user((void __user *)arg, &sysoff, sizeof(sysoff)))
+		if (copy_to_user((void __user *)arg, sysoff, sizeof(*sysoff)))
 			err = -EFAULT;
 		break;
 
@@ -125,6 +130,8 @@ long ptp_ioctl(struct posix_clock *pc, unsigned int cmd, unsigned long arg)
 		err = -ENOTTY;
 		break;
 	}
+
+	kfree(sysoff);
 	return err;
 }
 
-- 
1.7.2.5
