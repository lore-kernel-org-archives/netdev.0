From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] sky2: disable rx checksum on Yukon XL
Date: Wed, 21 Nov 2007 14:55:26 -0800
Message-ID: <20071121145526.1f0b9f06@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:44234 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752199AbXKUW5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 17:57:04 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Marvell Yukon XL chipset appears to have a hardware glitch
where it will repeat the checksum of the last packet. Of course, this is
timing sensitive and only happens sometimes...

More info: http://bugzilla.kernel.org/show_bug.cgi?id=9381

As a workaround just disable hardware checksumming by default on
this chip version. The earlier workaround for PCIX, dual port
was also on Yukon XL so don't need to disable checksumming there.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/sky2.c	2007-11-21 13:53:33.000000000 -0800
+++ b/drivers/net/sky2.c	2007-11-21 13:59:09.000000000 -0800
@@ -1320,15 +1320,11 @@ static int sky2_up(struct net_device *de
 	 */
 	if (otherdev && netif_running(otherdev) &&
  	    (cap = pci_find_capability(hw->pdev, PCI_CAP_ID_PCIX))) {
- 		struct sky2_port *osky2 = netdev_priv(otherdev);
  		u16 cmd;
 
 		pci_read_config_word(hw->pdev, cap + PCI_X_CMD, &cmd);
  		cmd &= ~PCI_X_CMD_MAX_SPLIT;
 		pci_write_config_word(hw->pdev, cap + PCI_X_CMD, cmd);
-
- 		sky2->rx_csum = 0;
- 		osky2->rx_csum = 0;
  	}
 
 	if (netif_msg_ifup(sky2))
@@ -4013,7 +4009,7 @@ static __devinit struct net_device *sky2
 	sky2->duplex = -1;
 	sky2->speed = -1;
 	sky2->advertising = sky2_supported_modes(hw);
-	sky2->rx_csum = 1;
+	sky2->rx_csum = (hw->chip_id != CHIP_ID_YUKON_XL);
 	sky2->wol = wol;
 
 	spin_lock_init(&sky2->phy_lock);
