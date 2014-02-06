From: Emil Goode <emilgoode@gmail.com>
Subject: [PATCH] net: asix: fix bad header length bug
Date: Thu,  6 Feb 2014 13:56:24 +0100
Message-ID: <1391691384-8486-1-git-send-email-emilgoode@gmail.com>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Emil Goode <emilgoode@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Ming Lei <ming.lei@canonical.com>,
	Mark Brown <broonie@linaro.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Glen Turner <gdt@gdt.id.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The AX88772B occasionally send rx packets that cross urb boundaries
and the remaining partial packet is sent with no header.
When the buffer with a partial packet is of less number of octets
than the value of hard_header_len the buffer is discarded by the
usbnet module. This is causing dropped packages and error messages
in dmesg.

This can be reproduced by using ping with a packet size
between 1965-1976.

The bug has been reported here:

https://bugzilla.kernel.org/show_bug.cgi?id=29082

Signed-off-by: Emil Goode <emilgoode@gmail.com>
---
 drivers/net/usb/asix_devices.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devices.c
index 9765a7d..120bb29 100644
--- a/drivers/net/usb/asix_devices.c
+++ b/drivers/net/usb/asix_devices.c
@@ -455,6 +455,7 @@ static int ax88772_bind(struct usbnet *dev, struct usb_interface *intf)
 	dev->net->ethtool_ops = &ax88772_ethtool_ops;
 	dev->net->needed_headroom = 4; /* cf asix_tx_fixup() */
 	dev->net->needed_tailroom = 4; /* cf asix_tx_fixup() */
+	dev->net->hard_header_len = 0; /* Partial packets have no header */
 
 	embd_phy = ((dev->mii.phy_id & 0x1f) == 0x10 ? 1 : 0);
 
-- 
1.7.10.4
