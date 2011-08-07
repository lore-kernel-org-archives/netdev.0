From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 1/2] gianfar: fix fiper alignment after resetting the time
Date: Sun,  7 Aug 2011 09:03:03 +0200
Message-ID: <018b1f12e792c4758d1e601742f758a09dd10d62.1312699694.git.richard.cochran@omicron.at>
References: <cover.1312699693.git.richard.cochran@omicron.at>
Cc: <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>,
	<stable@kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:52931 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750826Ab1HGHI4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Aug 2011 03:08:56 -0400
In-Reply-To: <cover.1312699693.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1312699693.git.richard.cochran@omicron.at>
References: <cover.1312699693.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After resetting the time, the PPS signals on the FIPER output channels
are incorrectly offset from the clock time, as can be readily verified
by a looping back the FIPER to the external time stamp input.

Despite its name, setting the "Fiper Realignment Disable" bit seems to
fix the problem, at least on the P2020.

Also, following the example code from the Freescale BSP, it is not really
necessary to disable and re-enable the timer in order to reprogram the
FIPER. (The documentation is rather unclear on this point. It seems that
writing to the alarm register also disables the FIPER.)

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
Cc: <stable@kernel.org>
---
 drivers/net/gianfar_ptp.c |    9 ++-------
 1 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/gianfar_ptp.c b/drivers/net/gianfar_ptp.c
index 1c97861..f67b8ae 100644
--- a/drivers/net/gianfar_ptp.c
+++ b/drivers/net/gianfar_ptp.c
@@ -193,14 +193,9 @@ static void set_alarm(struct etsects *etsects)
 /* Caller must hold etsects->lock. */
 static void set_fipers(struct etsects *etsects)
 {
-	u32 tmr_ctrl = gfar_read(&etsects->regs->tmr_ctrl);
-
-	gfar_write(&etsects->regs->tmr_ctrl,   tmr_ctrl & (~TE));
-	gfar_write(&etsects->regs->tmr_prsc,   etsects->tmr_prsc);
+	set_alarm(etsects);
 	gfar_write(&etsects->regs->tmr_fiper1, etsects->tmr_fiper1);
 	gfar_write(&etsects->regs->tmr_fiper2, etsects->tmr_fiper2);
-	set_alarm(etsects);
-	gfar_write(&etsects->regs->tmr_ctrl,   tmr_ctrl|TE);
 }
 
 /*
@@ -511,7 +506,7 @@ static int gianfar_ptp_probe(struct platform_device *dev)
 	gfar_write(&etsects->regs->tmr_fiper1, etsects->tmr_fiper1);
 	gfar_write(&etsects->regs->tmr_fiper2, etsects->tmr_fiper2);
 	set_alarm(etsects);
-	gfar_write(&etsects->regs->tmr_ctrl,   tmr_ctrl|FS|RTPE|TE);
+	gfar_write(&etsects->regs->tmr_ctrl,   tmr_ctrl|FS|RTPE|TE|FRD);
 
 	spin_unlock_irqrestore(&etsects->lock, flags);
 
-- 
1.7.0.4

