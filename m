From: Trent Piepho <tpiepho@freescale.com>
Subject: [PATCH] gianfar: Fix error in mdio reset timeout
Date: Tue, 10 Jun 2008 16:36:46 -0700
Message-ID: <1213141006-12593-1-git-send-email-tpiepho@freescale.com>
Cc: Trent Piepho <tpiepho@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:55209 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751667AbYFJXhp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2008 19:37:45 -0400
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw01.freescale.net (8.12.11/az33egw01) with ESMTP id m5ANbgel010303
	for <netdev@vger.kernel.org>; Tue, 10 Jun 2008 16:37:43 -0700 (MST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The loop getting timed-out used "while (...  && timeout--)", which means
than when the timeout occurs, timeout will be -1 after the loop has exited.
Except timeout is unsigned, so it won't be negative!  The code that checks
if the looped exited because of a timeout used "if (timeout <= 0)", which
doesn't work, as (unsigned)-1 isn't <= 0.

Using "--timeout" in the loop fixes this problem.

This also fixes a bug in the existing code, where it will erroneously think
a timeout occurred if the condition the loop was waiting for was satisfied
on the final iteration before a timeout.

Signed-off-by: Trent Piepho <tpiepho@freescale.com>
---
 drivers/net/gianfar_mii.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/gianfar_mii.c b/drivers/net/gianfar_mii.c
index ebcfb27..906aba2 100644
--- a/drivers/net/gianfar_mii.c
+++ b/drivers/net/gianfar_mii.c
@@ -136,12 +136,12 @@ static int gfar_mdio_reset(struct mii_bus *bus)
 
 	/* Wait until the bus is free */
 	while ((gfar_read(&regs->miimind) & MIIMIND_BUSY) &&
-			timeout--)
+			--timeout)
 		cpu_relax();
 
 	mutex_unlock(&bus->mdio_lock);
 
-	if(timeout <= 0) {
+	if(timeout == 0) {
 		printk(KERN_ERR "%s: The MII Bus is stuck!\n",
 				bus->name);
 		return -EBUSY;
-- 
1.5.4.1

