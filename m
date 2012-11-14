From: "Kamlakant Patel" <kamlakant.patel@broadcom.com>
Subject: [PATCH] net/smsc911x: Fix ready check in cases where WORD_SWAP
 is needed
Date: Wed, 14 Nov 2012 17:11:38 +0530
Message-ID: <1352893298-20058-1-git-send-email-kamlakant.patel@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: steve@shawell.net, davem@davemloft.net, linus.walleij@linaro.org,
	robert.marklund@stericsson.com,
	"Kamlakant Patel" <kamlakant.patel@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3711 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756720Ab2KNLnO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2012 06:43:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The chip ready check added by the commit 3ac3546e [Always wait for
the chip to be ready] does not work when the register read/write
is word swapped. This check has been added before the WORD_SWAP
register is programmed, so we need to check for swapped register
value as well.

Bit 16 is marked as RESERVED in SMSC datasheet, Steve Glendinning
<steve@shawell.net> checked with SMSC and wrote:

  The chip architects have concluded we should be reading PMT_CTRL
  until we see any of bits 0, 8, 16 or 24 set.  Then we should read
  BYTE_TEST to check the byte order is correct (as we already do).

  The rationale behind this is that some of the chip variants have
  word order swapping features too, so the READY bit could actually
  be in any of the 4 possible locations.  The architects have confirmed
  that if any of these 4 positions is set the chip is ready.  The other
  3 locations will either never be set or can only go high after READY
  does (so also indicate the device is ready).

This change will check for the READY bit at the 16th position. We do
not check the other two cases (bit 8 and 24) since the driver does not
support byte-swapped register read/write.

Signed-off-by: Kamlakant Patel <kamlakant.patel@broadcom.com>
---
 drivers/net/ethernet/smsc/smsc911x.c |   17 +++++++++++++++--
 1 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 62d1baf..c53c0f4 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -2110,7 +2110,7 @@ static void __devinit smsc911x_read_mac_address(struct net_device *dev)
 static int __devinit smsc911x_init(struct net_device *dev)
 {
 	struct smsc911x_data *pdata = netdev_priv(dev);
-	unsigned int byte_test;
+	unsigned int byte_test, mask;
 	unsigned int to = 100;
 
 	SMSC_TRACE(pdata, probe, "Driver Parameters:");
@@ -2130,9 +2130,22 @@ static int __devinit smsc911x_init(struct net_device *dev)
 	/*
 	 * poll the READY bit in PMT_CTRL. Any other access to the device is
 	 * forbidden while this bit isn't set. Try for 100ms
+	 *
+	 * Note that this test is done before the WORD_SWAP register is
+	 * programmed. So in some configurations the READY bit is at 16 before
+	 * WORD_SWAP is written to. This issue is worked around by waiting
+	 * until either bit 0 or bit 16 gets set in PMT_CTRL.
+	 *
+	 * SMSC has confirmed that checking bit 16 (marked as reserved in
+	 * the datasheet) is fine since these bits "will either never be set
+	 * or can only go high after READY does (so also indicate the device
+	 * is ready)".
 	 */
-	while (!(smsc911x_reg_read(pdata, PMT_CTRL) & PMT_CTRL_READY_) && --to)
+
+	mask = PMT_CTRL_READY_ | swahw32(PMT_CTRL_READY_);
+	while (!(smsc911x_reg_read(pdata, PMT_CTRL) & mask) && --to)
 		udelay(1000);
+
 	if (to == 0) {
 		pr_err("Device not READY in 100ms aborting\n");
 		return -ENODEV;
-- 
1.7.6
