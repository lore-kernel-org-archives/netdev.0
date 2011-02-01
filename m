From: Sergiy Kibrik <sakib@meta.ua>
Subject: [PATCH] usb:smsc: preserve MAC address when resetting device
Date: Tue,  1 Feb 2011 12:34:17 +0200
Message-ID: <1296556457-4969-1-git-send-email-sakib@meta.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Sergiy Kibrik <sakib@meta.ua>
To: Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.meta.ua ([194.0.131.41]:49105 "EHLO smtp.meta.ua"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753113Ab1BAKvC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Feb 2011 05:51:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Initialize MAC address only once, when device opened first time
to avoid generation random addresses when failed to read one from ROM.

Some hardware hasn't hw address in ROM, e.g. Pandaboard  (http://pandaboard.org),
so every time device is up, its address is regenerated again.
It makeis impossible to set custom hw address and also makes DHCP servers and switches crazy.

Signed-off-by: Sergiy Kibrik <sakib@meta.ua>
---
 drivers/net/usb/smsc75xx.c |    6 +++++-
 drivers/net/usb/smsc95xx.c |    6 +++++-
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 753ee6e..a45dfa2 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -77,6 +77,7 @@ struct usb_context {
 };
 
 static int turbo_mode = true;
+static int first_reset = true;
 module_param(turbo_mode, bool, 0644);
 MODULE_PARM_DESC(turbo_mode, "Enable multiple frames per Rx transaction");
 
@@ -836,7 +837,10 @@ static int smsc75xx_reset(struct usbnet *dev)
 
 	netif_dbg(dev, ifup, dev->net, "PHY reset complete");
 
-	smsc75xx_init_mac_address(dev);
+	if (first_reset){
+		smsc75xx_init_mac_address(dev);
+		first_reset = false;
+	}
 
 	ret = smsc75xx_set_mac_address(dev);
 	check_warn_return(ret, "Failed to set mac address");
diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index bc86f4b..83008c1 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -59,6 +59,7 @@ struct usb_context {
 	struct usbnet *dev;
 };
 
+static int first_reset = true;
 static int turbo_mode = true;
 module_param(turbo_mode, bool, 0644);
 MODULE_PARM_DESC(turbo_mode, "Enable multiple frames per Rx transaction");
@@ -1045,7 +1046,10 @@ static int smsc95xx_bind(struct usbnet *dev, struct usb_interface *intf)
 	pdata->use_tx_csum = DEFAULT_TX_CSUM_ENABLE;
 	pdata->use_rx_csum = DEFAULT_RX_CSUM_ENABLE;
 
-	smsc95xx_init_mac_address(dev);
+	if (first_reset){
+		smsc95xx_init_mac_address(dev);
+		first_reset = false;
+	}
 
 	/* Init all registers */
 	ret = smsc95xx_reset(dev);
-- 
1.7.1

