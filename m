From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [patch] tg3: Fix 'scheduling while atomic' errors
Date: Mon, 4 Aug 2008 22:13:48 -0700
Message-ID: <20080805051348.GA16736@HP-xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2939 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751314AbYHEE1a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Aug 2008 00:27:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the 'scheduling while atomic' errors introduced by
commit 12dac0756d357325b107fe6ec24921ec38661839.

The first hunk of the patch removes an unnecessary
tg3_set_power_state() call.  The chip will already be in the D0 state
either due to a chip reset or through a previous call to
tg3_set_power_state().

The second hunk of the patch moves the tg3_set_power_state() call
outside the critical section guarded by tg3_full_lock() and
tg3_full_unlock() functions.  The power state of the device is and
should be outside the lock's domain and all other tg3_set_power_state()
calls support this.


Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 26aa37a..576199b 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -7687,21 +7687,11 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
  */
 static int tg3_init_hw(struct tg3 *tp, int reset_phy)
 {
-	int err;
-
-	/* Force the chip into D0. */
-	err = tg3_set_power_state(tp, PCI_D0);
-	if (err)
-		goto out;
-
 	tg3_switch_clocks(tp);
 
 	tw32(TG3PCI_MEM_WIN_BASE_ADDR, 0);
 
-	err = tg3_reset_hw(tp, reset_phy);
-
-out:
-	return err;
+	return tg3_reset_hw(tp, reset_phy);
 }
 
 #define TG3_STAT_ADD32(PSTAT, REG) \
@@ -8016,13 +8006,11 @@ static int tg3_open(struct net_device *dev)
 
 	netif_carrier_off(tp->dev);
 
-	tg3_full_lock(tp, 0);
-
 	err = tg3_set_power_state(tp, PCI_D0);
-	if (err) {
-		tg3_full_unlock(tp);
+	if (err)
 		return err;
-	}
+
+	tg3_full_lock(tp, 0);
 
 	tg3_disable_ints(tp);
 	tp->tg3_flags &= ~TG3_FLAG_INIT_COMPLETE;


