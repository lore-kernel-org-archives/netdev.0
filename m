From: Dean Jenkins <Dean_Jenkins@mentor.com>
Subject: [PATCH v1 4/5] asix: On RX avoid creating bad Ethernet frames
Date: Fri, 2 Oct 2015 14:29:07 +0100
Message-ID: <1443792548-2025-5-git-send-email-Dean_Jenkins@mentor.com>
References: <1443792548-2025-1-git-send-email-Dean_Jenkins@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-usb@vger.kernel.org>, <ben.hutchings@codethink.co.uk>,
	<davem@davemloft.net>, <bjorn@mork.no>, <linux@davidrobins.net>,
	Mark Craske <Mark_Craske@mentor.com>,
	Dean Jenkins <Dean_Jenkins@mentor.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:47551 "EHLO
	relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753592AbbJBNbk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 09:31:40 -0400
In-Reply-To: <1443792548-2025-1-git-send-email-Dean_Jenkins@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When RX Ethernet frames span multiple URB socket buffers,
the data stream may suffer a discontinuity which will cause
the current Ethernet frame in the netdev socket buffer
to be incomplete. This frame needs to be discarded instead
of appending unrelated data from the current URB socket buffer
to the Ethernet frame in the netdev socket buffer. This avoids
creating a corrupted Ethernet frame in the netdev socket buffer.

A discontinuity can occur when the previous URB socket buffer
held an incomplete Ethernet frame due to truncation or a
URB socket buffer containing the end of the Ethernet frame
was missing.

Therefore, add a sanity test for when an Ethernet frame
spans multiple URB socket buffers to check that the remaining
bytes of the currently received Ethernet frame point to
a good Data header 32-bit word of the next Ethernet
frame. Upon error, reset the remaining bytes variable to
zero and discard the current netdev socket buffer.
Assume that the Data header is located at the start of
the current socket buffer and attempt to process the next
Ethernet frame from there. This avoids unnecessarily
discarding a good URB socket buffer that contains a new
Ethernet frame.

Signed-off-by: Dean Jenkins <Dean_Jenkins@mentor.com>
Signed-off-by: Mark Craske <Mark_Craske@mentor.com>
---
 drivers/net/usb/asix_common.c |   28 ++++++++++++++++++++++++++++
 1 file changed, 28 insertions(+)

diff --git a/drivers/net/usb/asix_common.c b/drivers/net/usb/asix_common.c
index 6a8eddf..1e4768d 100644
--- a/drivers/net/usb/asix_common.c
+++ b/drivers/net/usb/asix_common.c
@@ -56,6 +56,34 @@ int asix_rx_fixup_internal(struct usbnet *dev, struct sk_buff *skb,
 	int offset = 0;
 	u16 size;
 
+	/* When an Ethernet frame spans multiple URB socket buffers,
+	 * do a sanity test for the Data header synchronisation.
+	 * Attempt to detect the situation of the previous socket buffer having
+	 * been truncated or a socket buffer was missing. These situations
+	 * cause a discontinuity in the data stream and therefore need to avoid
+	 * appending bad data to the end of the current netdev socket buffer.
+	 * Also avoid unnecessarily discarding a good current netdev socket
+	 * buffer.
+	 */
+	if (rx->remaining && (rx->remaining + sizeof(u32) <= skb->len)) {
+		offset = ((rx->remaining + 1) & 0xfffe) + sizeof(u32);
+		rx->header = get_unaligned_le32(skb->data + offset);
+		offset = 0;
+
+		size = (u16)(rx->header & 0x7ff);
+		if (size != ((~rx->header >> 16) & 0x7ff)) {
+			netdev_err(dev->net, "asix_rx_fixup() Data Header synchronisation was lost, remaining %d\n",
+				   rx->remaining);
+			kfree_skb(rx->ax_skb);
+			rx->ax_skb = NULL;
+			/* Discard the incomplete netdev Ethernet frame and
+			 * assume the Data header is at the start of the current
+			 * URB socket buffer.
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
