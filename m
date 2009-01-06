From: Wu Fengguang <wfg@linux.intel.com>
Subject: [PATCH] dm9601: warn on invalid mac address
Date: Tue, 6 Jan 2009 17:10:50 +0800
Message-ID: <20090106091050.GA19316@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Korsgaard <jacmet@sunsite.dk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga12.intel.com ([143.182.124.36]:58209 "EHLO
	azsmga102.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750931AbZAFJKx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 04:10:53 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add warnings on invalid mac address to help disclose/debug problems.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 drivers/net/usb/dm9601.c |   12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

--- linux-2.6.orig/drivers/net/usb/dm9601.c
+++ linux-2.6/drivers/net/usb/dm9601.c
@@ -401,8 +401,12 @@ static int dm9601_set_mac_address(struct
 	struct sockaddr *addr = p;
 	struct usbnet *dev = netdev_priv(net);
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!is_valid_ether_addr(addr->sa_data)) {
+		DECLARE_MAC_BUF(mac_buf);
+		print_mac(mac_buf, addr->sa_data);
+		dev_warn(&net->dev, "not setting invalid mac address %s\n", mac_buf);
 		return -EINVAL;
+	}
 
 	memcpy(net->dev_addr, addr->sa_data, net->addr_len);
 	dm_write_async(dev, DM_PHY_ADDR, net->addr_len, net->dev_addr);
@@ -449,6 +453,12 @@ static int dm9601_bind(struct usbnet *de
 	 */
 	if (is_valid_ether_addr(mac))
 		memcpy(dev->net->dev_addr, mac, ETH_ALEN);
+	else {
+		DECLARE_MAC_BUF(mac_buf);
+		print_mac(mac_buf, mac);
+		devdbg(dev, "EEPROM reported mac address %s is invalid,"
+				" use the randomly generated one.", mac_buf);
+	}
 
 	/* power up phy */
 	dm_write_reg(dev, DM_GPR_CTRL, 1);
