From: John Ogness <john.ogness@linutronix.de>
Subject: [PATCH] flexcan: fix NAPI for bus errors
Date: Tue, 23 Nov 2010 15:34:21 +0100
Message-ID: <80k4k45csy.fsf@merkur.tec.linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: socketcan-core@lists.berlios.de
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:50475 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754507Ab0KWOec (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Nov 2010 09:34:32 -0500
Cc: netdev@vger.kernel.org
Cc: kernel@pengutronix.de
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If bus error reporting is disabled and bus errors occur, the flexcan
driver will hog the system because it continually re-enables the IRQs
(work_done = 0). This patch changes the driver to only re-enable the
IRQs if some work was actually done. This allows the features of NAPI to
be used for bus errors as well (when bus error reporting is disabled).

This patch is against Linux next-20101123.

Signed-off-by: John Ogness <john.ogness@linutronix.de>
---
 drivers/net/can/flexcan.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

--- next-20101123-a/drivers/net/can/flexcan.c
+++ next-20101123-b/drivers/net/can/flexcan.c
@@ -535,9 +535,12 @@ static int flexcan_poll(struct napi_stru
 
 	if (work_done < quota) {
 		napi_complete(napi);
-		/* enable IRQs */
-		writel(FLEXCAN_IFLAG_DEFAULT, &regs->imask1);
-		writel(priv->reg_ctrl_default, &regs->ctrl);
+
+		if (work_done > 0) {
+			/* enable IRQs */
+			writel(FLEXCAN_IFLAG_DEFAULT, &regs->imask1);
+			writel(priv->reg_ctrl_default, &regs->ctrl);
+		}
 	}
 
 	return work_done;
