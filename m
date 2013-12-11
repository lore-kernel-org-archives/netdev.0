From: Dean Jenkins <Dean_Jenkins@mentor.com>
Subject: [PATCH 3/4] asix: On RX avoid creating bad Ethernet frames
Date: Wed, 11 Dec 2013 10:50:27 +0000
Message-ID: <1386759028-3534-4-git-send-email-Dean_Jenkins@mentor.com>
References: <1386759028-3534-1-git-send-email-Dean_Jenkins@mentor.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway05.m3-connect.de ([88.79.237.15]:41875 "EHLO
	mail.mentor.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751436Ab3LKK7O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 05:59:14 -0500
In-Reply-To: <1386759028-3534-1-git-send-email-Dean_Jenkins@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Note that the C1 variant of the DUB-E100 USB Ethernet
adapter produces "Bad Header" errors. This modification
will reduce the number of those error messages and instead
provides a more informative reason for the error condition.
The consequences of the error are reduced by not consuming
bad Ethernet frames and unnecessarily discarding the next
Ethernet frame that is probably good.

When RX Ethernet frames span multiple socket buffers,
the data stream can suffer a discontinuity which will cause
the current Ethernet frame in the netdev socket buffer
to be incomplete. This frame needs to be discarded instead
of appending unrelated data from the current socket buffer
to the Ethernet frame in the netdev socket buffer.

A discontinuity can occur when the previous socket buffer
held an incomplete Ethernet frame due to truncation or a
socket buffer containing the end of the Ethernet frame
was missing.

Therefore, add a sanity test for when an Ethernet frame
spans multiple socket buffers to check that the remaining
bytes of the currently received Ethernet frame point to
a good Data header 32-bit word of the next Ethernet
frame. Upon error, reset the remaining byte variable to
zero and discard the current netdev socket buffer.
Assume that the Data header is located at the start of
the current socket buffer and attempt to process the next
Ethernet frame from there. This avoids unnecessarily
discarding a good socket buffer that contains a new
Ethernet frame.

Signed-off-by: Dean Jenkins <Dean_Jenkins@mentor.com>
---
 drivers/net/usb/asix_common.c |   26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/drivers/net/usb/asix_common.c b/drivers/net/usb/asix_common.c
index 1d44c1e..93423e1 100644
--- a/drivers/net/usb/asix_common.c
+++ b/drivers/net/usb/asix_common.c
@@ -57,6 +57,32 @@ int asix_rx_fixup_internal(struct usbnet *dev, struct sk_buff *skb,
 	int offset = 0;
 	u16 size;
 
+	/* When an Ethernet frame spans multiple socket buffers,
+	 * do a sanity test for the Data header synchronisation.
+	 * Attempt to detect the situation of the previous socket buffer having
+	 * been truncated or a socket buffer was missing. These situations
+	 * cause a discontinuity in the data stream and therefore need to avoid
+	 * appending bad data to the end of the current netdev socket buffer.
+	 * Also avoid unnecessarily discarding a good current socket buffer.
+	 */
+	if (rx->remaining && (rx->remaining + sizeof(u32) <= skb->len)) {
+		offset = ((rx->remaining + 1) & 0xfffe) + sizeof(u32);
+		rx->header = get_unaligned_le32(skb->data + offset);
+		offset = 0;
+
+		size = (u16) (rx->header & 0x7ff);
+		if (size != ((~rx->header >> 16) & 0x7ff)) {
+			netdev_err(dev->net, "asix_rx_fixup() Data Header synchronisation was lost, remaining %d\n",
+				   rx->remaining);
+			kfree_skb(rx->ax_skb);
+			rx->ax_skb = NULL;
+			/* Assume the Data header is at the start of
+			 * of the socket buffer.
+			 */
+			rx->remaining = 0;
+		}
+	}
+
 	while (offset + sizeof(u16) <= skb->len) {
 		u16 copy_length;
 		unsigned char *data;
-- 
1.7.9.5
