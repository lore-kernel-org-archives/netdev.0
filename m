From: Peter Tyser <ptyser@xes-inc.com>
Subject: [PATCH] sky2: RX lockup fix
Date: Wed, 05 Dec 2007 12:51:03 -0600
Message-ID: <1196880663.2816.149.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xes-mad.com ([216.165.139.214]:59234 "EHLO xes-mad.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755459AbXLETo3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2007 14:44:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
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
disabled (see dev. #4.115)".  Nice.   I implemented this same change in
the sky2 driver and verified that the RX lockup I was seeing was
resolved.


I didn't see the problem mentioned in the netdev list, so I've included
a patch against the
git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6 tree
which disables RX flushing for the Yukon XL chips.

Please CC replies to me as I am not subscribed to the list.

Thanks,
Peter Tyser


Signed-off-by: Peter Tyser <ptyser@xes-inc.com>

--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -822,8 +822,13 @@ static void sky2_mac_init(struct sky2_hw *hw,
unsigned port)
 
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


