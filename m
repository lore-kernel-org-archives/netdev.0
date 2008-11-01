From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH] mv643xx_eth: fix SMI bus access timeouts
Date: Sat, 1 Nov 2008 06:32:20 +0100
Message-ID: <20081101053220.GA13348@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:53334 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750802AbYKAFcW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Nov 2008 01:32:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mv643xx_eth mii bus implementation uses wait_event_timeout() to
wait for SMI completion interrupts.

If wait_event_timeout() would return zero, mv643xx_eth would conclude
that the SMI access timed out, but this is not necessarily true --
wait_event_timeout() can also return zero in the case where the SMI
completion interrupt did happen in time but where it took longer than
the requested timeout for the process performing the SMI access to be
scheduled again.  This would lead to occasional SMI access timeouts
when the system would be under heavy load.

The fix is to ignore the return value of wait_event_timeout(), and
to re-check the SMI done bit after wait_event_timeout() returns to
determine whether or not the SMI access timed out.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
The commit that introduced this was added in the .28 dev cycle, so
this fix is for .28 only.  Thanks!

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index d25a302..0e94ed3 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1065,9 +1065,12 @@ static int smi_wait_ready(struct mv643xx_eth_shared_private *msp)
 		return 0;
 	}
 
-	if (!wait_event_timeout(msp->smi_busy_wait, smi_is_done(msp),
-				msecs_to_jiffies(100)))
-		return -ETIMEDOUT;
+	if (!smi_is_done(msp)) {
+		wait_event_timeout(msp->smi_busy_wait, smi_is_done(msp),
+				   msecs_to_jiffies(100));
+		if (!smi_is_done(msp))
+			return -ETIMEDOUT;
+	}
 
 	return 0;
 }
