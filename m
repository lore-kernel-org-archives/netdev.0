From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] sky2: RX lockup fix
Date: Fri, 7 Dec 2007 15:22:15 -0800
Message-ID: <20071207152215.0267c407@freepuppy.rosehill>
References: <1196880663.2816.149.camel@localhost.localdomain>
	<20071205164058.157275a9@shemminger-laptop>
	<1196900326.21996.1.camel@localhost.localdomain>
	<20071205225249.0f46672c@shemminger-laptop>
	<1196957697.24978.24.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Peter Tyser <ptyser@xes-inc.com>, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:49594 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751085AbXLGXZ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 18:25:26 -0500
In-Reply-To: <1196957697.24978.24.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm using a Marvell 88E8062 on a custom PPC64 blade and ran into RX
lockups while validating the sky2 driver.  The receive MAC FIFO would
become stuck during testing with high traffic.  One port of the 88E8062
would lockup, while the other port remained functional.  Re-inserting
the sky2 module would not fix the problem - only a power cycle would.

I looked over Marvell's most recent sk98lin driver and it looks like
they had a "workaround" for the Yukon XL that the sky2 doesn't have yet.
The sk98lin driver disables the RX MAC FIFO flush feature for all
revisions of the Yukon XL.

According to skgeinit.c of the sk98lin driver, "Flushing must be enabled
(needed for ASF see dev. #4.29), but the flushing mask should be
disabled (see dev. #4.115)".  Nice. I implemented this same change in
the sky2 driver and verified that the RX lockup I was seeing was
resolved.

Signed-off-by: Peter Tyser <ptyser@xes-inc.com>
Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
Original patch reformatted to remove line wrap.

--- a/drivers/net/sky2.c	2007-12-06 09:39:12.000000000 -0800
+++ b/drivers/net/sky2.c	2007-12-06 09:54:14.000000000 -0800
@@ -821,8 +821,13 @@ static void sky2_mac_init(struct sky2_hw
 
 	sky2_write32(hw, SK_REG(port, RX_GMF_CTRL_T), rx_reg);
 
-	/* Flush Rx MAC FIFO on any flow control or error */
-	sky2_write16(hw, SK_REG(port, RX_GMF_FL_MSK), GMR_FS_ANY_ERR);
+	if (hw->chip_id == CHIP_ID_YUKON_XL) {
+		/* Hardware errata - clear flush mask */
+		sky2_write16(hw, SK_REG(port, RX_GMF_FL_MSK), 0);
+	} else {
+		/* Flush Rx MAC FIFO on any flow control or error */
+		sky2_write16(hw, SK_REG(port, RX_GMF_FL_MSK), GMR_FS_ANY_ERR);
+	}
 
 	/* Set threshold to 0xa (64 bytes) + 1 to workaround pause bug  */
 	reg = RX_GMF_FL_THR_DEF + 1;
