From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/2] sky2: dual-port pci-x checksum fix
Date: Wed, 21 Feb 2007 16:04:43 -0800
Message-ID: <20070222000621.769898000@linux-foundation.org>
References: <20070222000441.469009000@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:58981 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751372AbXBVAKr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Feb 2007 19:10:47 -0500
Content-Disposition: inline; filename=sky2-pcix-dual.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a workaround for dual port PCI-X card that returns status out of
order sometimes because of split transactions.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- linux-2.6.16.40.orig/drivers/net/sky2.c	2007-02-14 16:45:23.000000000 -0800
+++ linux-2.6.16.40/drivers/net/sky2.c	2007-02-14 16:47:06.000000000 -0800
@@ -1031,7 +1031,25 @@
 	struct sky2_hw *hw = sky2->hw;
 	unsigned port = sky2->port;
 	u32 ramsize, rxspace;
-	int err = -ENOMEM;
+	int cap, err = -ENOMEM;
+	struct net_device *otherdev = hw->dev[sky2->port^1];
+
+	/*
+ 	 * On dual port PCI-X card, there is an problem where status
+	 * can be received out of order due to split transactions
+	 */
+	if (otherdev && netif_running(otherdev) &&
+ 	    (cap = pci_find_capability(hw->pdev, PCI_CAP_ID_PCIX))) {
+ 		struct sky2_port *osky2 = netdev_priv(otherdev);
+ 		u16 cmd;
+
+ 		cmd = sky2_pci_read16(hw, cap + PCI_X_CMD);
+ 		cmd &= ~PCI_X_CMD_MAX_SPLIT;
+ 		sky2_pci_write16(hw, cap + PCI_X_CMD, cmd);
+
+ 		sky2->rx_csum = 0;
+ 		osky2->rx_csum = 0;
+ 	}
 
 	if (netif_msg_ifup(sky2))
 		printk(KERN_INFO PFX "%s: enabling interface\n", dev->name);

--
Stephen Hemminger <shemminger@linux-foundation.org>

