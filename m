From: Baolin Wang <baolin.wang@linaro.org>
Subject: [PATCH 4/4] ptp/ixp46x:Replace timespec with ktime_t in ptp_ixp46x.c
Date: Thu, 19 Mar 2015 13:45:09 +0800
Message-ID: <1426743909-24335-5-git-send-email-baolin.wang@linaro.org>
References: <1426743909-24335-1-git-send-email-baolin.wang@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	john.stultz@linaro.com, tglx@linutronix.de, arnd@linaro.org,
	baolin.wang@linaro.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:33823 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753015AbbCSFqq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 01:46:46 -0400
Received: by pdbni2 with SMTP id ni2so65733799pdb.1
        for <netdev@vger.kernel.org>; Wed, 18 Mar 2015 22:46:45 -0700 (PDT)
In-Reply-To: <1426743909-24335-1-git-send-email-baolin.wang@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the 32-bit time type (timespec) to the 64-bit one
(ktime_t), since 32-bit time types will break in the year 2038.

This patch implements the getktime/setktime interfaces with
"ktime_t" type, and removes the gettime/settime interfaces with
"timespec" type in ptp_ixp46x.c file.

Signed-off-by: Baolin Wang <baolin.wang@linaro.org>
---
 drivers/ptp/ptp_ixp46x.c |   21 ++++++---------------
 1 file changed, 6 insertions(+), 15 deletions(-)

diff --git a/drivers/ptp/ptp_ixp46x.c b/drivers/ptp/ptp_ixp46x.c
index 604d340..102b673 100644
--- a/drivers/ptp/ptp_ixp46x.c
+++ b/drivers/ptp/ptp_ixp46x.c
@@ -175,39 +175,30 @@ static int ptp_ixp_adjtime(struct ptp_clock_info *ptp, s64 delta)
 	return 0;
 }
 
-static int ptp_ixp_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
+static int ptp_ixp_getktime(struct ptp_clock_info *ptp, ktime_t *kt)
 {
-	u64 ns;
-	u32 remainder;
 	unsigned long flags;
 	struct ixp_clock *ixp_clock = container_of(ptp, struct ixp_clock, caps);
 	struct ixp46x_ts_regs *regs = ixp_clock->regs;
 
 	spin_lock_irqsave(&register_lock, flags);
 
-	ns = ixp_systime_read(regs);
+	*kt = ns_to_ktime(ixp_systime_read(regs));
 
 	spin_unlock_irqrestore(&register_lock, flags);
 
-	ts->tv_sec = div_u64_rem(ns, 1000000000, &remainder);
-	ts->tv_nsec = remainder;
 	return 0;
 }
 
-static int ptp_ixp_settime(struct ptp_clock_info *ptp,
-			   const struct timespec *ts)
+static int ptp_ixp_setktime(struct ptp_clock_info *ptp, ktime_t kt)
 {
-	u64 ns;
 	unsigned long flags;
 	struct ixp_clock *ixp_clock = container_of(ptp, struct ixp_clock, caps);
 	struct ixp46x_ts_regs *regs = ixp_clock->regs;
 
-	ns = ts->tv_sec * 1000000000ULL;
-	ns += ts->tv_nsec;
-
 	spin_lock_irqsave(&register_lock, flags);
 
-	ixp_systime_write(regs, ns);
+	ixp_systime_write(regs, ktime_to_ns(kt));
 
 	spin_unlock_irqrestore(&register_lock, flags);
 
@@ -248,8 +239,8 @@ static struct ptp_clock_info ptp_ixp_caps = {
 	.pps		= 0,
 	.adjfreq	= ptp_ixp_adjfreq,
 	.adjtime	= ptp_ixp_adjtime,
-	.gettime	= ptp_ixp_gettime,
-	.settime	= ptp_ixp_settime,
+	.getktime	= ptp_ixp_getktime,
+	.setktime	= ptp_ixp_setktime,
 	.enable		= ptp_ixp_enable,
 };
 
-- 
1.7.9.5
