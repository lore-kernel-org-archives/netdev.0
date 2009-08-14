From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] sky2: remove restarting workaround flag
Date: Fri, 14 Aug 2009 16:33:17 -0700
Message-ID: <20090814163317.3c5b5942@nehalam>
References: <20090814151511.992669598@vyatta.com>
	<20090814.154154.53636130.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60052 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932113AbZHNXdV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Aug 2009 19:33:21 -0400
In-Reply-To: <20090814.154154.53636130.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The whole restarting flag was introduced by Mike McCormack
and was a temporary duct tape patch around issues with transmits
inflight during restart. The problems it was covering are now
fixed and the code should have been reverted.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sky2.c	2009-08-14 16:29:56.716322334 -0700
+++ b/drivers/net/sky2.c	2009-08-14 16:30:05.681690475 -0700
@@ -1496,8 +1496,6 @@ static int sky2_up(struct net_device *de
 	sky2_set_vlan_mode(hw, port, sky2->vlgrp != NULL);
 #endif
 
-	sky2->restarting = 0;
-
 	err = sky2_rx_start(sky2);
 	if (err)
 		goto err_out;
@@ -1508,9 +1506,6 @@ static int sky2_up(struct net_device *de
 	sky2_write32(hw, B0_IMSK, imask);
 	sky2_read32(hw, B0_IMSK);
 
-	/* wake queue incase we are restarting */
-	netif_wake_queue(dev);
-
 	if (netif_msg_ifup(sky2))
 		printk(KERN_INFO PFX "%s: enabling interface\n", dev->name);
 
@@ -1545,8 +1540,6 @@ static inline int tx_dist(unsigned tail,
 /* Number of list elements available for next tx */
 static inline int tx_avail(const struct sky2_port *sky2)
 {
-	if (unlikely(sky2->restarting))
-		return 0;
 	return sky2->tx_pending - tx_dist(sky2->tx_cons, sky2->tx_prod);
 }
 
@@ -1850,10 +1843,6 @@ static int sky2_down(struct net_device *
 	if (netif_msg_ifdown(sky2))
 		printk(KERN_INFO PFX "%s: disabling interface\n", dev->name);
 
-	/* explicitly shut off tx incase we're restarting */
-	sky2->restarting = 1;
-	netif_tx_disable(dev);
-
 	/* Force flow control off */
 	sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_PAUSE_OFF);
 
@@ -2382,7 +2371,7 @@ static inline void sky2_tx_done(struct n
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
 
-	if (likely(netif_running(dev) && !sky2->restarting))
+	if (netif_running(dev))
 		sky2_tx_complete(sky2, last);
 }
 
@@ -4327,7 +4316,6 @@ static __devinit struct net_device *sky2
 	spin_lock_init(&sky2->phy_lock);
 	sky2->tx_pending = TX_DEF_PENDING;
 	sky2->rx_pending = RX_DEF_PENDING;
-	sky2->restarting = 0;
 
 	hw->dev[port] = dev;
 
--- a/drivers/net/sky2.h	2009-08-14 16:29:56.728439978 -0700
+++ b/drivers/net/sky2.h	2009-08-14 16:30:08.825275706 -0700
@@ -2053,7 +2053,6 @@ struct sky2_port {
 #define SKY2_FLAG_AUTO_SPEED		0x0002
 #define SKY2_FLAG_AUTO_PAUSE		0x0004
 
-	u8		     restarting;
  	enum flow_control    flow_mode;
  	enum flow_control    flow_status;
 



-- 
