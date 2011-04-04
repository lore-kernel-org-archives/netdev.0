From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 8/8] ewrk3: convert to set_phys_id
Date: Mon, 04 Apr 2011 14:06:42 -0700
Message-ID: <20110404210805.998401718@linuxplumber.net>
References: <20110404210634.840793593@linuxplumber.net>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:43894 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754631Ab1DDWST (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 18:18:19 -0400
Content-Disposition: inline; filename=ewrk3-set-phys.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Keep orginal locking and error handling.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/ewrk3.c	2011-04-04 13:41:41.717791151 -0700
+++ b/drivers/net/ewrk3.c	2011-04-04 13:46:55.425138028 -0700
@@ -1604,55 +1604,51 @@ static u32 ewrk3_get_link(struct net_dev
 	return !(cmr & CMR_LINK);
 }
 
-static int ewrk3_phys_id(struct net_device *dev, u32 data)
+static int ewrk3_set_phys_id(struct net_device *dev,
+			     enum ethtool_phys_id_state state)
 {
 	struct ewrk3_private *lp = netdev_priv(dev);
 	unsigned long iobase = dev->base_addr;
 	unsigned long flags;
 	u8 cr;
-	int count;
-
-	/* Toggle LED 4x per second */
-	count = data << 2;
 
 	spin_lock_irqsave(&lp->hw_lock, flags);
 
-	/* Bail if a PHYS_ID is already in progress */
-	if (lp->led_mask == 0) {
-		spin_unlock_irqrestore(&lp->hw_lock, flags);
-		return -EBUSY;
-	}
+	switch (state) {
+	case ETHTOOL_ID_ACTIVE:
+		/* Bail if a PHYS_ID is already in progress */
+		if (lp->led_mask == 0) {
+			spin_unlock_irqrestore(&lp->hw_lock, flags);
+			return -EBUSY;
+		}
 
-	/* Prevent ISR from twiddling the LED */
-	lp->led_mask = 0;
+		/* Prevent ISR from twiddling the LED */
+		lp->led_mask = 0;
+		spin_unlock_irqrestore(&lp->hw_lock, flags);
+		return -EINVAL;
 
-	while (count--) {
+	case ETHTOOL_ID_ON:
+	case ETHTOOL_ID_OFF:
 		/* Toggle the LED */
 		cr = inb(EWRK3_CR);
 		outb(cr ^ CR_LED, EWRK3_CR);
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
-
-	lp->led_mask = CR_LED;
-	cr = inb(EWRK3_CR);
-	outb(cr & ~CR_LED, EWRK3_CR);
 	spin_unlock_irqrestore(&lp->hw_lock, flags);
-	return signal_pending(current) ? -ERESTARTSYS : 0;
+
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
@@ -1660,7 +1656,7 @@ static const struct ethtool_ops ethtool_
 	.get_settings = ewrk3_get_settings,
 	.set_settings = ewrk3_set_settings,
 	.get_link = ewrk3_get_link,
-	.phys_id = ewrk3_phys_id,
+	.set_phys_id = ewrk3_set_phys_id,
 };
 
 /*


