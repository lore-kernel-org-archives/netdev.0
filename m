From: Dean Jenkins <Dean_Jenkins@mentor.com>
Subject: [PATCH V1 1/3] asix: Add rx->ax_skb = NULL after usbnet_skb_return()
Date: Mon, 7 Aug 2017 09:50:14 +0100
Message-ID: <1502095816-3255-2-git-send-email-Dean_Jenkins@mentor.com>
References: <1502095816-3255-1-git-send-email-Dean_Jenkins@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-usb@vger.kernel.org>
To: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
        Dean Jenkins <Dean_Jenkins@mentor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:36324 "EHLO
        relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752495AbdHGIuk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 04:50:40 -0400
In-Reply-To: <1502095816-3255-1-git-send-email-Dean_Jenkins@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In asix_rx_fixup_internal() there is a risk that rx->ax_skb gets
reused after passing the Ethernet frame into the network stack via
usbnet_skb_return().

The risks include:

a) asynchronously freeing rx->ax_skb after passing the netdev buffer
   to the NAPI layer which might corrupt the backlog queue.

b) erroneously reusing rx->ax_skb such as calling skb_put_data() multiple
   times which causes writing off the end of the netdev buffer.

Therefore add a defensive rx->ax_skb = NULL after usbnet_skb_return()
so that it is not possible to free rx->ax_skb or to apply
skb_put_data() too many times.

Signed-off-by: Dean Jenkins <Dean_Jenkins@mentor.com>
---
 drivers/net/usb/asix_common.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/asix_common.c b/drivers/net/usb/asix_common.c
index 7847436..6983b6b 100644
--- a/drivers/net/usb/asix_common.c
+++ b/drivers/net/usb/asix_common.c
@@ -168,8 +168,10 @@ int asix_rx_fixup_internal(struct usbnet *dev, struct sk_buff *skb,
 		if (rx->ax_skb) {
 			skb_put_data(rx->ax_skb, skb->data + offset,
 				     copy_length);
-			if (!rx->remaining)
+			if (!rx->remaining) {
 				usbnet_skb_return(dev, rx->ax_skb);
+				rx->ax_skb = NULL;
+			}
 		}
 
 		offset += (copy_length + 1) & 0xfffe;
-- 
2.7.4
