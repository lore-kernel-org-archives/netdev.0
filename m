From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 3/3] smsc911x: allow setting of mac address
Date: Thu, 19 Mar 2009 10:24:46 +0000
Message-ID: <1237458286-23421-3-git-send-email-steve.glendinning@smsc.com>
References: <1237458286-23421-1-git-send-email-steve.glendinning@smsc.com>
 <1237458286-23421-2-git-send-email-steve.glendinning@smsc.com>
Cc: Ian Saturley <ian.saturley@smsc.com>,
	David Miller <davem@davemloft.net>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from drevil.shawell.net ([86.54.240.115]:56041 "EHLO
	drevil2.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753929AbZCSKYx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 06:24:53 -0400
In-Reply-To: <1237458286-23421-2-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch replaces the generic eth_mac_addr function with one that
also updates the hardware mac address registers.  It also renames the
existing smsc911x_set_mac_address function to
smsc911x_hw_set_mac_address for clarity.

Newer LAN911x and all LAN921x devices also support changing the mac
address while the device is running, which is useful for some bonding
modes.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/smsc911x.c |   35 ++++++++++++++++++++++++++++++-----
 1 files changed, 30 insertions(+), 5 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index 82157cd..ad3cbc9 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -1119,7 +1119,7 @@ static int smsc911x_soft_reset(struct smsc911x_data *pdata)
 
 /* Sets the device MAC address to dev_addr, called with mac_lock held */
 static void
-smsc911x_set_mac_address(struct smsc911x_data *pdata, u8 dev_addr[6])
+smsc911x_set_hw_mac_address(struct smsc911x_data *pdata, u8 dev_addr[6])
 {
 	u32 mac_high16 = (dev_addr[5] << 8) | dev_addr[4];
 	u32 mac_low32 = (dev_addr[3] << 24) | (dev_addr[2] << 16) |
@@ -1174,7 +1174,7 @@ static int smsc911x_open(struct net_device *dev)
 	/* The soft reset above cleared the device's MAC address,
 	 * restore it from local copy (set in probe) */
 	spin_lock_irq(&pdata->mac_lock);
-	smsc911x_set_mac_address(pdata, dev->dev_addr);
+	smsc911x_set_hw_mac_address(pdata, dev->dev_addr);
 	spin_unlock_irq(&pdata->mac_lock);
 
 	/* Initialise irqs, but leave all sources disabled */
@@ -1508,6 +1508,31 @@ static void smsc911x_poll_controller(struct net_device *dev)
 }
 #endif				/* CONFIG_NET_POLL_CONTROLLER */
 
+static int smsc911x_set_mac_address(struct net_device *dev, void *p)
+{
+	struct smsc911x_data *pdata = netdev_priv(dev);
+	struct sockaddr *addr = p;
+
+	/* On older hardware revisions we cannot change the mac address
+	 * registers while receiving data.  Newer devices can safely change
+	 * this at any time. */
+	if (pdata->generation <= 1 && netif_running(dev))
+		return -EBUSY;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
+	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
+
+	spin_lock_irq(&pdata->mac_lock);
+	smsc911x_set_hw_mac_address(pdata, dev->dev_addr);
+	spin_unlock_irq(&pdata->mac_lock);
+
+	dev_info(&dev->dev, "MAC Address: %pM\n", dev->dev_addr);
+
+	return 0;
+}
+
 /* Standard ioctls for mii-tool */
 static int smsc911x_do_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
@@ -1738,7 +1763,7 @@ static const struct net_device_ops smsc911x_netdev_ops = {
 	.ndo_set_multicast_list	= smsc911x_set_multicast_list,
 	.ndo_do_ioctl		= smsc911x_do_ioctl,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_set_mac_address 	= smsc911x_set_mac_address,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= smsc911x_poll_controller,
 #endif
@@ -2026,7 +2051,7 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 
 	/* Check if mac address has been specified when bringing interface up */
 	if (is_valid_ether_addr(dev->dev_addr)) {
-		smsc911x_set_mac_address(pdata, dev->dev_addr);
+		smsc911x_set_hw_mac_address(pdata, dev->dev_addr);
 		SMSC_TRACE(PROBE, "MAC Address is specified by configuration");
 	} else {
 		/* Try reading mac address from device. if EEPROM is present
@@ -2040,7 +2065,7 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 		} else {
 			/* eeprom values are invalid, generate random MAC */
 			random_ether_addr(dev->dev_addr);
-			smsc911x_set_mac_address(pdata, dev->dev_addr);
+			smsc911x_set_hw_mac_address(pdata, dev->dev_addr);
 			SMSC_TRACE(PROBE,
 				"MAC Address is set to random_ether_addr");
 		}
-- 
1.6.0.6

