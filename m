From: "Kamlakant Patel" <kamlakant.patel@broadcom.com>
Subject: Resending patch: [PATCH] net/smsc911x: check chip ready bit
 with swapped data
Date: Wed, 17 Oct 2012 17:10:15 +0530
Message-ID: <1350474015-28832-1-git-send-email-kamlakant.patel@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Kamlakant Patel" <kamlakant.patel@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4071 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754373Ab2JQLk2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2012 07:40:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The chip ready check added by the commit 3ac3546e [Always wait for
the chip to be ready] does not work when the registers are swapped.
Since we have not programmed WORD_SWAP register before chip ready
bit check, we need to check for swapped register value as well.

Signed-off-by: Kamlakant Patel <kamlakant.patel@broadcom.com>
---
 drivers/net/ethernet/smsc/smsc911x.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 62d1baf..419bfb9 100644
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
@@ -2130,9 +2130,15 @@ static int __devinit smsc911x_init(struct net_device *dev)
 	/*
 	 * poll the READY bit in PMT_CTRL. Any other access to the device is
 	 * forbidden while this bit isn't set. Try for 100ms
+	 *
+	 * The register read may be swapped, since we have not programmed
+	 * WORD_SWAP register, check for swapped register value as well
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
