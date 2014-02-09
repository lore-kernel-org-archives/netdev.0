From: Emil Goode <emilgoode@gmail.com>
Subject: [PATCH 1/2 v2] usbnet: fix bad header length bug
Date: Mon, 10 Feb 2014 00:06:13 +0100
Message-ID: <1391987174-21828-1-git-send-email-emilgoode@gmail.com>
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
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
and the remaining partial packet is sent with no hardware header.
When the buffer with a partial packet is of less number of octets
than the value of hard_header_len the buffer is discarded by the
usbnet module. This is causing dropped packages and error messages
in dmesg.

This can be reproduced by using ping with a packet size
between 1965-1976.

The bug has been reported here:

https://bugzilla.kernel.org/show_bug.cgi?id=29082

This patch introduces a new flag that enable minidrivers to disable
the cleaning up of small partial packets with no hardware header.
It is likely that other minidrivers will want to use this flag,
currently the cx82310_eth is describing the same problem and solving
it by setting the hard_header_len to 0. This patch also makes it more
obvious to minidriver writers that the usbnet module is discarding
small skbs, which I believe has caused some confusion.

Signed-off-by: Emil Goode <emilgoode@gmail.com>
Reported-by: Igor Gnatenko <i.gnatenko.brain@gmail.com>
---
v2: This patch solves the bug by introducing a new flag instead of
    setting hard_header_len to 0. I realize that there are already
    a lot of flags but hard_header_len is used to calculate the
    mtu values in the usbnet_change_mtu, usbnet_probe functions
    and I believe it's better not to change it.

 drivers/net/usb/asix_devices.c |   10 ++++++----
 drivers/net/usb/usbnet.c       |    3 ++-
 include/linux/usb/usbnet.h     |    3 +++
 3 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devices.c
index 9765a7d..7ced4ed 100644
--- a/drivers/net/usb/asix_devices.c
+++ b/drivers/net/usb/asix_devices.c
@@ -891,7 +891,8 @@ static const struct driver_info ax88772_info = {
 	.status = asix_status,
 	.link_reset = ax88772_link_reset,
 	.reset = ax88772_reset,
-	.flags = FLAG_ETHER | FLAG_FRAMING_AX | FLAG_LINK_INTR | FLAG_MULTI_PACKET,
+	.flags = FLAG_ETHER | FLAG_FRAMING_AX | FLAG_LINK_INTR |
+		 FLAG_MULTI_PACKET | FLAG_PARTIAL_RX_PKT,
 	.rx_fixup = asix_rx_fixup_common,
 	.tx_fixup = asix_tx_fixup,
 };
@@ -904,7 +905,7 @@ static const struct driver_info ax88772b_info = {
 	.link_reset = ax88772_link_reset,
 	.reset = ax88772_reset,
 	.flags = FLAG_ETHER | FLAG_FRAMING_AX | FLAG_LINK_INTR |
-	         FLAG_MULTI_PACKET,
+		 FLAG_MULTI_PACKET | FLAG_PARTIAL_RX_PKT,
 	.rx_fixup = asix_rx_fixup_common,
 	.tx_fixup = asix_tx_fixup,
 	.data = FLAG_EEPROM_MAC,
@@ -917,7 +918,8 @@ static const struct driver_info ax88178_info = {
 	.status = asix_status,
 	.link_reset = ax88178_link_reset,
 	.reset = ax88178_reset,
-	.flags = FLAG_ETHER | FLAG_FRAMING_AX | FLAG_LINK_INTR,
+	.flags = FLAG_ETHER | FLAG_FRAMING_AX | FLAG_LINK_INTR |
+		 FLAG_PARTIAL_RX_PKT,
 	.rx_fixup = asix_rx_fixup_common,
 	.tx_fixup = asix_tx_fixup,
 };
@@ -939,7 +941,7 @@ static const struct driver_info hg20f9_info = {
 	.link_reset = ax88772_link_reset,
 	.reset = ax88772_reset,
 	.flags = FLAG_ETHER | FLAG_FRAMING_AX | FLAG_LINK_INTR |
-	         FLAG_MULTI_PACKET,
+		 FLAG_MULTI_PACKET | FLAG_PARTIAL_RX_PKT,
 	.rx_fixup = asix_rx_fixup_common,
 	.tx_fixup = asix_tx_fixup,
 	.data = FLAG_EEPROM_MAC,
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 4671da7..a1e6964 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -574,7 +574,8 @@ static void rx_complete (struct urb *urb)
 	switch (urb_status) {
 	/* success */
 	case 0:
-		if (skb->len < dev->net->hard_header_len) {
+		if (skb->len < dev->net->hard_header_len &&
+		    !(dev->driver_info->flags & FLAG_PARTIAL_RX_PKT)) {
 			state = rx_cleanup;
 			dev->net->stats.rx_errors++;
 			dev->net->stats.rx_length_errors++;
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index e303eef..818da3b 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -117,6 +117,9 @@ struct driver_info {
 #define FLAG_RX_ASSEMBLE	0x4000	/* rx packets may span >1 frames */
 #define FLAG_NOARP		0x8000	/* device can't do ARP */
 
+/* Disables cleanup of small partial rx packets with no hardware header */
+#define FLAG_PARTIAL_RX_PKT    0x10000
+
 	/* init device ... can sleep, or cause probe() failure */
 	int	(*bind)(struct usbnet *, struct usb_interface *);
 
-- 
1.7.10.4
