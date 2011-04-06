From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 8/8] ewrk3: convert to set_phys_id
Date: Wed, 6 Apr 2011 14:58:36 -0700
Message-ID: <20110406145836.35af537a@nehalam>
References: <20110404210634.840793593@linuxplumber.net>
	<20110404210805.998401718@linuxplumber.net>
	<20110406.143720.55846981.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36565 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755790Ab1DFV6j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Apr 2011 17:58:39 -0400
In-Reply-To: <20110406.143720.55846981.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use ethtool infrastructure for blinking, which is now does
locking at higher level.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/ewrk3.c	2011-04-06 14:50:45.905902923 -0700
+++ b/drivers/net/ewrk3.c	2011-04-06 14:56:00.249078160 -0700
@@ -1604,55 +1604,47 @@ static u32 ewrk3_get_link(struct net_dev
 	return !(cmr & CMR_LINK);
 }
 
-static int ewrk3_phys_id(struct net_device *dev, u32 data)
+static int ewrk3_set_phys_id(struct net_device *dev,
+			     enum ethtool_phys_id_state state)
 {
 	struct ewrk3_private *lp = netdev_priv(dev);
 	unsigned long iobase = dev->base_addr;
-	unsigned long flags;
 	u8 cr;
-	int count;
 
-	/* Toggle LED 4x per second */
-	count = data << 2;
+	spin_lock_irq(&lp->hw_lock);
 
-	spin_lock_irqsave(&lp->hw_lock, flags);
+	switch (state) {
+	case ETHTOOL_ID_ACTIVE:
+		/* Prevent ISR from twiddling the LED */
+		lp->led_mask = 0;
+		spin_unlock_irq(&lp->hw_lock);
+		return -EINVAL;
 
-	/* Bail if a PHYS_ID is already in progress */
-	if (lp->led_mask == 0) {
-		spin_unlock_irqrestore(&lp->hw_lock, flags);
-		return -EBUSY;
-	}
-
-	/* Prevent ISR from twiddling the LED */
-	lp->led_mask = 0;
+	case ETHTOOL_ID_ON:
+		cr = inb(EWRK3_CR);
+		outb(cr | CR_LED, EWRK3_CR);
+		break;
 
-	while (count--) {
-		/* Toggle the LED */
+	case ETHTOOL_ID_OFF:
 		cr = inb(EWRK3_CR);
-		outb(cr ^ CR_LED, EWRK3_CR);
+		outb(cr & ~CR_LED, EWRK3_CR);
+		break;
 
-		/* Wait a little while */
-		spin_unlock_irqrestore(&lp->hw_lock, flags);
-		msleep(250);
-		spin_lock_irqsave(&lp->hw_lock, flags);
-
-		/* Exit if we got a signal */
-		if (signal_pending(current))
-			break;
+	case ETHTOOL_ID_INACTIVE:
+		lp->led_mask = CR_LED;
+		cr = inb(EWRK3_CR);
+		outb(cr & ~CR_LED, EWRK3_CR);
 	}
+	spin_unlock_irq(&lp->hw_lock);
 
-	lp->led_mask = CR_LED;
-	cr = inb(EWRK3_CR);
-	outb(cr & ~CR_LED, EWRK3_CR);
-	spin_unlock_irqrestore(&lp->hw_lock, flags);
-	return signal_pending(current) ? -ERESTARTSYS : 0;
+	return 0;
 }
 
 static const struct ethtool_ops ethtool_ops_203 = {
 	.get_drvinfo = ewrk3_get_drvinfo,
 	.get_settings = ewrk3_get_settings,
 	.set_settings = ewrk3_set_settings,
-	.phys_id = ewrk3_phys_id,
+	.set_phys_id = ewrk3_set_phys_id,
 };
 
 static const struct ethtool_ops ethtool_ops = {
@@ -1660,7 +1652,7 @@ static const struct ethtool_ops ethtool_
 	.get_settings = ewrk3_get_settings,
 	.set_settings = ewrk3_set_settings,
 	.get_link = ewrk3_get_link,
-	.phys_id = ewrk3_phys_id,
+	.set_phys_id = ewrk3_set_phys_id,
 };
 
 /*
