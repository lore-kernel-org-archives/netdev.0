From: Chris Snook <csnook@redhat.com>
Subject: [PATCH] atl1: save mac address on remove
Date: Wed, 28 Mar 2007 20:51:51 -0400
Message-ID: <20070328205151.A22317@redline.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jacliburn@bellsouth.net, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:55422 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934282AbXC2Av5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2007 20:51:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Snook <csnook@redhat.com>

Some atl1 boards get their MAC address written directly to the register
by the BIOS during POST, rather than storing it in EEPROM that's
accessible to the driver.  If the MAC register on one of these boards
is changed and then the module is unloaded, the permanent MAC address
will be forgotten until the box is rebooted.  We should save the
permanent address during removal if we've been messing with it.

Signed-off-by: Chris Snook <csnook@redhat.com>

--- a/drivers/net/atl1/atl1_main.c	2007-03-01 14:14:48.000000000 -0500
+++ b/drivers/net/atl1/atl1_main.c	2007-03-01 16:59:59.000000000 -0500
@@ -2321,6 +2321,16 @@ static void __devexit atl1_remove(struct
 		return;
 
 	adapter = netdev_priv(netdev);
+
+	/* Some atl1 boards lack persistent storage for their MAC, and get it
+	 * from the BIOS during POST.  If we've been messing with the MAC
+	 * address, we need to save the permanent one.
+	 */
+	if (memcmp(adapter->hw.mac_addr, adapter->hw.perm_mac_addr, ETH_ALEN)) {
+		memcpy(adapter->hw.mac_addr, adapter->hw.perm_mac_addr, ETH_ALEN);
+		atl1_set_mac_addr(&adapter->hw);
+	}
+
 	iowrite16(0, adapter->hw.hw_addr + REG_GPHY_ENABLE);
 	unregister_netdev(netdev);
 	pci_iounmap(pdev, adapter->hw.hw_addr);
