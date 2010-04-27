From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2] gianfar: Wait for both RX and TX to stop
Date: Tue, 27 Apr 2010 17:51:43 -0500
Message-ID: <1272408703-20931-1-git-send-email-afleming@freescale.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:48929 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755088Ab0D0Wvq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 18:51:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When gracefully stopping the controller, the driver was continuing if
*either* RX or TX had stopped.  We need to wait for both, or the
controller could get into an invalid state.

Signed-off-by: Andy Fleming <afleming@freescale.com>
---
Switched to use spin_event_timeout()

Kept the -1 timeout value, as that is the original behavior, and responding
to a timeout would require a much more substantial change, and such a change
would, at the least, require investigation of what, if anything, *can* be done.

 drivers/net/gianfar.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 0cef967..5267c27 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1567,9 +1567,9 @@ static void gfar_halt_nodisable(struct net_device *dev)
 		tempval |= (DMACTRL_GRS | DMACTRL_GTS);
 		gfar_write(&regs->dmactrl, tempval);
 
-		while (!(gfar_read(&regs->ievent) &
-			 (IEVENT_GRSC | IEVENT_GTSC)))
-			cpu_relax();
+		spin_event_timeout(((gfar_read(&regs->ievent) &
+			 (IEVENT_GRSC | IEVENT_GTSC)) ==
+			 (IEVENT_GRSC | IEVENT_GTSC)), -1, 0);
 	}
 }
 
-- 
1.6.5.2.g6ff9a

