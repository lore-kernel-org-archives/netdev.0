From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH] smsc911x: reset last known duplex and carrier on open
Date: Tue, 17 Mar 2009 18:06:39 +0000
Message-ID: <1237313199-18617-1-git-send-email-steve.glendinning@smsc.com>
Cc: Ian Saturley <ian.saturley@smsc.com>,
	David Miller <davem@davemloft.net>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from drevil.shawell.net ([86.54.240.115]:45837 "EHLO
	drevil2.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751116AbZCQSGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 14:06:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

smsc911x_phy_adjust_link is called periodically by the phy layer (as
it's run in polling mode), and it only updates the hardware when it sees
a change in duplex or carrier.  This patch clears the last known values
every time the interface is brought up, instead of only when the module
is loaded.

Without this patch the adjust_link function never updates the hardware
after an ifconfig down; ifconfig up.  On a full duplex link this causes
the tx error counter to increment, even though packets are correctly
transmitted, as the default MAC_CR register setting is for half duplex.

The tx errors are "no carrier" errors, which should be ignored in
full-duplex mode.  When MAC_CR is set to "full duplex" mode they are
correctly ignored by the hardware.

Note that even with this patch the tx error counter can increment if
packets are transmitted between "ifconfig up" and the first phy poll
interval.  An improved solution would use the phy interrupt with phylib,
but I haven't managed to make this work 100% robustly yet.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/smsc911x.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index 9a78dae..d1590ac 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -1225,6 +1225,10 @@ static int smsc911x_open(struct net_device *dev)
 	dev_info(&dev->dev, "SMSC911x/921x identified at %#08lx, IRQ: %d\n",
 		 (unsigned long)pdata->ioaddr, dev->irq);
 
+	/* Reset the last known duplex and carrier */
+	pdata->last_duplex = -1;
+	pdata->last_carrier = -1;
+
 	/* Bring the PHY up */
 	phy_start(pdata->phy_dev);
 
-- 
1.6.0.6

