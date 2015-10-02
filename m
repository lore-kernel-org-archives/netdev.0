From: Dean Jenkins <Dean_Jenkins-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v1 5/5] asix: Continue processing URB if no RX netdev buffer
Date: Fri, 2 Oct 2015 14:29:08 +0100
Message-ID: <1443792548-2025-6-git-send-email-Dean_Jenkins@mentor.com>
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

Avoid a loss of synchronisation of the Ethernet Data header 32-bit
word due to a failure to get a netdev socket buffer.

The ASIX RX handling algorithm returned 0 upon a failure to get
an allocation of a netdev socket buffer. This causes the URB
processing to stop which potentially causes a loss of synchronisation
with the Ethernet Data header 32-bit word. Therefore, subsequent
processing of URBs may be rejected due to a loss of synchronisation.
This may cause additional good Ethernet frames to be discarded
along with outputting of synchronisation error messages.

Implement a solution which checks whether a netdev socket buffer
has been allocated before trying to copy the Ethernet frame into
the netdev socket buffer. But continue to process the URB so that
synchronisation is maintained. Therefore, only a single Ethernet
frame is discarded when no netdev socket buffer is available.

Signed-off-by: Dean Jenkins <Dean_Jenkins-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Mark Craske <Mark_Craske-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>
---
 drivers/net/usb/asix_common.c |   31 +++++++++++++++++++------------
 1 file changed, 19 insertions(+), 12 deletions(-)

diff --git a/drivers/net/usb/asix_common.c b/drivers/net/usb/asix_common.c
index 1e4768d..a186b0a 100644
--- a/drivers/net/usb/asix_common.c
+++ b/drivers/net/usb/asix_common.c
@@ -74,12 +74,14 @@ int asix_rx_fixup_internal(struct usbnet *dev, struct sk_buff *skb,
 		if (size != ((~rx->header >> 16) & 0x7ff)) {
 			netdev_err(dev->net, "asix_rx_fixup() Data Header synchronisation was lost, remaining %d\n",
 				   rx->remaining);
-			kfree_skb(rx->ax_skb);
-			rx->ax_skb = NULL;
-			/* Discard the incomplete netdev Ethernet frame and
-			 * assume the Data header is at the start of the current
-			 * URB socket buffer.
-			 */
+			if (rx->ax_skb) {
+				kfree_skb(rx->ax_skb);
+				rx->ax_skb = NULL;
+				/* Discard the incomplete netdev Ethernet frame
+				 * and assume the Data header is at the start of
+				 * the current URB socket buffer.
+				 */
+			}
 			rx->remaining = 0;
 		}
 	}
@@ -121,9 +123,12 @@ int asix_rx_fixup_internal(struct usbnet *dev, struct sk_buff *skb,
 				return 0;
 			}
 
+			/* Sometimes may fail to get a netdev socket buffer but
+			 * continue to process the URB socket buffer so that
+			 * synchronisation of the Ethernet frame Data header
+			 * word is maintained.
+			 */
 			rx->ax_skb = netdev_alloc_skb_ip_align(dev->net, size);
-			if (!rx->ax_skb)
-				return 0;
 
 			rx->remaining = size;
 		}
@@ -136,10 +141,12 @@ int asix_rx_fixup_internal(struct usbnet *dev, struct sk_buff *skb,
 			rx->remaining = 0;
 		}
 
-		data = skb_put(rx->ax_skb, copy_length);
-		memcpy(data, skb->data + offset, copy_length);
-		if (!rx->remaining)
-			usbnet_skb_return(dev, rx->ax_skb);
+		if (rx->ax_skb) {
+			data = skb_put(rx->ax_skb, copy_length);
+			memcpy(data, skb->data + offset, copy_length);
+			if (!rx->remaining)
+				usbnet_skb_return(dev, rx->ax_skb);
+		}
 
 		offset += (copy_length + 1) & 0xfffe;
 	}
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
