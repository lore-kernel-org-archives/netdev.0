From: Nico Erfurth <ne@erfurth.eu>
Subject: [PATCH 1/1] [SMSC75xx] Fix incorrect usage of NET_IP_ALIGN
Date: Tue,  8 Nov 2011 18:30:40 +0100
Message-ID: <1320773440-30122-1-git-send-email-ne@erfurth.eu>
Cc: Phil Sutter <phil@nwl.cc>, stable@vger.kernel.org,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Nico Erfurth <ne@erfurth.eu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.erfurth.eu ([89.107.64.155]:52837 "EHLO mail.erfurth.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754415Ab1KHQ6i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Nov 2011 11:58:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver used NET_IP_ALIGN to remove some additional padding inside of
the rx_fixup function. On many architectures NET_IP_ALIGN defaults to 2
which removed the correct amount of bytes.

On MCORE2-machines commit ea812ca1b06113597adcd8e70c0f84a413d97544
introduces a change which sets NET_IP_ALIGN to 0 by default. Which
triggered the bug on these machines.

This fix introduces a new RXW_PADDING define and uses this instead of
NET_IP_ALIGN. The name was taken from the original SMSC7500 driver which
is provided by SMSC.

Signed-off-by: Nico Erfurth <ne@erfurth.eu>
Tested-by: Phil Sutter <phil@nwl.cc>
---
 drivers/net/usb/smsc75xx.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 22a7cf9..a5b9b12 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -51,6 +51,7 @@
 #define USB_VENDOR_ID_SMSC		(0x0424)
 #define USB_PRODUCT_ID_LAN7500		(0x7500)
 #define USB_PRODUCT_ID_LAN7505		(0x7505)
+#define RXW_PADDING			2
 
 #define check_warn(ret, fmt, args...) \
 	({ if (ret < 0) netdev_warn(dev->net, fmt, ##args); })
@@ -1088,13 +1089,13 @@ static int smsc75xx_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 
 		memcpy(&rx_cmd_b, skb->data, sizeof(rx_cmd_b));
 		le32_to_cpus(&rx_cmd_b);
-		skb_pull(skb, 4 + NET_IP_ALIGN);
+		skb_pull(skb, 4 + RXW_PADDING);
 
 		packet = skb->data;
 
 		/* get the packet length */
-		size = (rx_cmd_a & RX_CMD_A_LEN) - NET_IP_ALIGN;
-		align_count = (4 - ((size + NET_IP_ALIGN) % 4)) % 4;
+		size = (rx_cmd_a & RX_CMD_A_LEN) - RXW_PADDING;
+		align_count = (4 - ((size + RXW_PADDING) % 4)) % 4;
 
 		if (unlikely(rx_cmd_a & RX_CMD_A_RED)) {
 			netif_dbg(dev, rx_err, dev->net,
-- 
1.7.3.4
