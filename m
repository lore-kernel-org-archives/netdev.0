From: Dean Jenkins <Dean_Jenkins-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v1 2/5] asix: Tidy-up 32-bit header word synchronisation
Date: Fri, 2 Oct 2015 14:29:05 +0100
Message-ID: <1443792548-2025-3-git-send-email-Dean_Jenkins@mentor.com>
References: <1443792548-2025-1-git-send-email-Dean_Jenkins@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <ben.hutchings-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>,
	<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <bjorn-yOkvZcmFvRU@public.gmane.org>, <linux-AegXhGwVzVhoAEGGzP886w@public.gmane.org>,
	Mark Craske <Mark_Craske-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>,
	Dean Jenkins <Dean_Jenkins-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1443792548-2025-1-git-send-email-Dean_Jenkins-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Tidy-up the Data header 32-bit word synchronisation logic in
asix_rx_fixup_internal() by removing redundant logic tests.

The code is looking at the following cases of the Data header
32-bit word that is present before each Ethernet frame:

a) all 32 bits of the Data header word are in the URB socket buffer
b) first 16 bits of the Data header word are at the end of the URB
   socket buffer
c) last 16 bits of the Data header word are at the start of the URB
   socket buffer eg. split_head = true

Note that the lifetime of rx->split_head exists outside of the
function call and is accessed per processing of each URB. Therefore,
split_head being true acts on the next URB to be processed.

To check for b) the offset will be 16 bits (2 bytes) from the end of
the buffer then indicate split_head is true.
To check for c) split_head must be true because the first 16 bits
have been found.
To check for a) else c)

Note that the || logic of the old code included the state
(skb->len - offset == sizeof(u16) && rx->split_head) which is not
possible because the split_head cannot be true whilst checking for b).
This is because the split_head indicates that the first 16 bits have
been found and that is not possible whilst checking for the first 16
bits. Therefore simplify the logic.

Signed-off-by: Dean Jenkins <Dean_Jenkins-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Mark Craske <Mark_Craske-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>
---
 drivers/net/usb/asix_common.c |   28 +++++++++++++---------------
 1 file changed, 13 insertions(+), 15 deletions(-)

diff --git a/drivers/net/usb/asix_common.c b/drivers/net/usb/asix_common.c
index 2bd5bdd..89efd6a 100644
--- a/drivers/net/usb/asix_common.c
+++ b/drivers/net/usb/asix_common.c
@@ -61,21 +61,19 @@ int asix_rx_fixup_internal(struct usbnet *dev, struct sk_buff *skb,
 		unsigned char *data;
 
 		if (!rx->remaining) {
-			if ((skb->len - offset == sizeof(u16)) ||
-			    rx->split_head) {
-				if(!rx->split_head) {
-					rx->header = get_unaligned_le16(
-							skb->data + offset);
-					rx->split_head = true;
-					offset += sizeof(u16);
-					break;
-				} else {
-					rx->header |= (get_unaligned_le16(
-							skb->data + offset)
-							<< 16);
-					rx->split_head = false;
-					offset += sizeof(u16);
-				}
+			if (skb->len - offset == sizeof(u16)) {
+				rx->header = get_unaligned_le16(
+						skb->data + offset);
+				rx->split_head = true;
+				offset += sizeof(u16);
+				break;
+			}
+
+			if (rx->split_head == true) {
+				rx->header |= (get_unaligned_le16(
+						skb->data + offset) << 16);
+				rx->split_head = false;
+				offset += sizeof(u16);
 			} else {
 				rx->header = get_unaligned_le32(skb->data +
 								offset);
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
