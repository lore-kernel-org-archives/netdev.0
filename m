From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH] smsc911x: leave RX_STOP interrupt permanently enabled
Date: Mon, 26 Jan 2009 15:57:52 +0000
Message-ID: <1232985472-16995-1-git-send-email-steve.glendinning@smsc.com>
Cc: David Miller <davem@davemloft.net>,
	Ian Saturley <ian.saturley@smsc.com>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [86.54.240.114] ([86.54.240.114]:37019 "EHLO
	kensington.shawell.net" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751422AbZAZP5t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 10:57:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

smsc911x_set_multicast_list currently performs the only non-atomic
read-modify-write of INT_EN.  This patch permanently enables the
RXSTOP_INT interrupt, and changes the ISR to only conditionally run the
multicast filter workaround code.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/smsc911x.c |   13 +++----------
 1 files changed, 3 insertions(+), 10 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index f513bdf..29ffb0e 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -1246,7 +1246,7 @@ static int smsc911x_open(struct net_device *dev)
 	napi_enable(&pdata->napi);
 
 	temp = smsc911x_reg_read(pdata, INT_EN);
-	temp |= (INT_EN_TDFA_EN_ | INT_EN_RSFL_EN_);
+	temp |= (INT_EN_TDFA_EN_ | INT_EN_RSFL_EN_ | INT_EN_RXSTOP_INT_EN_);
 	smsc911x_reg_write(pdata, INT_EN, temp);
 
 	spin_lock_irq(&pdata->mac_lock);
@@ -1418,11 +1418,6 @@ static void smsc911x_set_multicast_list(struct net_device *dev)
 
 			/* Request the hardware to stop, then perform the
 			 * update when we get an RX_STOP interrupt */
-			smsc911x_reg_write(pdata, INT_STS, INT_STS_RXSTOP_INT_);
-			temp = smsc911x_reg_read(pdata, INT_EN);
-			temp |= INT_EN_RXSTOP_INT_EN_;
-			smsc911x_reg_write(pdata, INT_EN, temp);
-
 			temp = smsc911x_mac_read(pdata, MAC_CR);
 			temp &= ~(MAC_CR_RXEN_);
 			smsc911x_mac_write(pdata, MAC_CR, temp);
@@ -1461,11 +1456,9 @@ static irqreturn_t smsc911x_irqhandler(int irq, void *dev_id)
 		/* Called when there is a multicast update scheduled and
 		 * it is now safe to complete the update */
 		SMSC_TRACE(INTR, "RX Stop interrupt");
-		temp = smsc911x_reg_read(pdata, INT_EN);
-		temp &= (~INT_EN_RXSTOP_INT_EN_);
-		smsc911x_reg_write(pdata, INT_EN, temp);
 		smsc911x_reg_write(pdata, INT_STS, INT_STS_RXSTOP_INT_);
-		smsc911x_rx_multicast_update_workaround(pdata);
+		if (pdata->multicast_update_pending)
+			smsc911x_rx_multicast_update_workaround(pdata);
 		serviced = IRQ_HANDLED;
 	}
 
-- 
1.6.0.6

