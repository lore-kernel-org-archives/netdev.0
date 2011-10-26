From: Linus Walleij <linus.walleij@stericsson.com>
Subject: [PATCH 1/2] net/smsc911x: Always wait for the chip to be ready
Date: Wed, 26 Oct 2011 10:05:43 +0200
Message-ID: <1319616343-6357-1-git-send-email-linus.walleij@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Mathieu Poirer <mathieu.poirier@linaro.org>,
	Robert Marklund <robert.marklund@stericsson.com>,
	Linus Walleij <linus.walleij@linaro.org>
To: <netdev@vger.kernel.org>,
	Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog109.obsmtp.com ([207.126.144.127]:39611 "EHLO
	eu1sys200aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754838Ab1JZIGB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2011 04:06:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Marklund <robert.marklund@stericsson.com>

Wait for the chip to be ready before any access to it. On the
Snowball platform we need to enable an external regulator before
the chip comes online, and then it happens that the device is
not yet ready at probe time, so let's wait for it.

Signed-off-by: Robert Marklund <robert.marklund@stericsson.com>
Signed-off-by: Linus Walleij <linus.walleij@linaro.org>
---
 drivers/net/ethernet/smsc/smsc911x.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index d2be42a..8843071 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -1937,6 +1937,7 @@ static int __devinit smsc911x_init(struct net_device *dev)
 {
 	struct smsc911x_data *pdata = netdev_priv(dev);
 	unsigned int byte_test;
+	unsigned int to = 100;
 
 	SMSC_TRACE(pdata, probe, "Driver Parameters:");
 	SMSC_TRACE(pdata, probe, "LAN base: 0x%08lX",
@@ -1952,6 +1953,17 @@ static int __devinit smsc911x_init(struct net_device *dev)
 		return -ENODEV;
 	}
 
+	/*
+	 * poll the READY bit in PMT_CTRL. Any other access to the device is
+	 * forbidden while this bit isn't set. Try for 100ms
+	 */
+	while (!(smsc911x_reg_read(pdata, PMT_CTRL) & PMT_CTRL_READY_) && --to)
+		udelay(1000);
+	if (to == 0) {
+		pr_err("Device not READY in 100ms aborting\n");
+		return -ENODEV;
+	}
+
 	/* Check byte ordering */
 	byte_test = smsc911x_reg_read(pdata, BYTE_TEST);
 	SMSC_TRACE(pdata, probe, "BYTE_TEST: 0x%08X", byte_test);
-- 
1.7.3.2
