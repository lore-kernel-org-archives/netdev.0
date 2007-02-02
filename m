From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/4] skge: handle zero address at open
Date: Fri, 02 Feb 2007 08:22:51 -0800
Message-ID: <20070202162419.046994000@linux-foundation.org>
References: <20070202162250.980620000@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:56739 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1945968AbXBBQZb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Feb 2007 11:25:31 -0500
Content-Disposition: inline; filename=skge-bad-rom.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some motherboards are broken and have no address set. Failing at probe time 
prevents the device from ever being used (like to download a fixed BIOS). Instead
warn on probe and check again when device is brought up. That way the address
can be set.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- skge.orig/drivers/net/skge.c
+++ skge/drivers/net/skge.c
@@ -2373,6 +2373,9 @@ static int skge_up(struct net_device *de
 	size_t rx_size, tx_size;
 	int err;
 
+	if (!is_valid_ether_addr(dev->dev_addr))
+		return -EINVAL;
+
 	if (netif_msg_ifup(skge))
 		printk(KERN_INFO PFX "%s: enabling interface\n", dev->name);
 
@@ -3567,11 +3570,10 @@ static int __devinit skge_probe(struct p
 	if (!dev)
 		goto err_out_led_off;
 
+	/* Some motherboards are broken and has zero in ROM. */
 	if (!is_valid_ether_addr(dev->dev_addr)) {
-		printk(KERN_ERR PFX "%s: bad (zero?) ethernet address in rom\n",
+		printk(KERN_WARNING PFX "%s: bad (zero?) ethernet address in rom\n",
 		       pci_name(pdev));
-		err = -EIO;
-		goto err_out_free_netdev;
 	}
 
 	err = register_netdev(dev);

-- 

