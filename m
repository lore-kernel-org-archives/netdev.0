From: Marek Vasut <marek.vasut@gmail.com>
Subject: [PATCH 2/2] ASIX: Use only 11 bits of header for data size
Date: Wed, 27 Jul 2011 04:44:47 +0200
Message-ID: <1311734687-23551-2-git-send-email-marek.vasut@gmail.com>
References: <1311734687-23551-1-git-send-email-marek.vasut@gmail.com>
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org, gregkh@suse.de,
	Marek Vasut <marek.vasut@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1311734687-23551-1-git-send-email-marek.vasut@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The AX88772B uses only 11 bits of the header for the actual size. The other bits
are used for something else. This causes dmesg full of messages:

	asix_rx_fixup() Bad Header Length

This patch trims the check to only 11 bits. I believe on older chips, the
remaining 5 top bits are unused.

Signed-off-by: Marek Vasut <marek.vasut@gmail.com>
---
 drivers/net/usb/asix.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

NOTE: If possible, can someone test/verify this patch with other ASIX chips ?
NOTE2: If Ack-ed, Greg, can you get this into -stable?

diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
index d5b62a4..c5c4b4d 100644
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -314,11 +314,11 @@ static int asix_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 	skb_pull(skb, 4);
 
 	while (skb->len > 0) {
-		if ((header & 0xffff) != ((~header >> 16) & 0xffff))
+		if ((header & 0x07ff) != ((~header >> 16) & 0x07ff))
 			netdev_err(dev->net, "asix_rx_fixup() Bad Header Length\n");
 
 		/* get the packet length */
-		size = (u16) (header & 0x0000ffff);
+		size = (u16) (header & 0x000007ff);
 
 		if ((skb->len) - ((size + 1) & 0xfffe) == 0) {
 			u8 alignment = (unsigned long)skb->data & 0x3;
-- 
1.7.5.3
