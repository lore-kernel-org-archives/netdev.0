From: freddy@asix.com.tw
Subject: [PATCH 1/1] TX throttling bug-fixing patch of AX88179_178A
Date: Sat, 20 Jul 2013 17:16:49 +0800
Message-ID: <1374311809-4155-1-git-send-email-freddy@asix.com.tw>
Cc: linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	louis@asix.com.tw, allan@asix.com.tw,
	Freddy Xin <freddy@asix.com.tw>
To: davem@davemloft.net, netdev@vger.kernel.org, grundler@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from asix.com.tw ([113.196.140.82]:65264 "EHLO freebsd2.asix.com.tw"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751768Ab3GTJuL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Jul 2013 05:50:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Freddy Xin <freddy@asix.com.tw>

Disable TSO and SG network features in reset() and bind() functions,
and check the return value of skb_linearize() in tx_fixup() to prevent
TX throttling.

Signed-off-by: Freddy Xin <freddy@asix.com.tw>
---
 drivers/net/usb/ax88179_178a.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/ax88179_178a.c b/drivers/net/usb/ax88179_178a.c
index 1e3c302..eb71331 100644
--- a/drivers/net/usb/ax88179_178a.c
+++ b/drivers/net/usb/ax88179_178a.c
@@ -1029,7 +1029,7 @@ static int ax88179_bind(struct usbnet *dev, struct usb_interface *intf)
 	dev->mii.supports_gmii = 1;
 
 	dev->net->features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
-			      NETIF_F_RXCSUM | NETIF_F_SG | NETIF_F_TSO;
+			      NETIF_F_RXCSUM;
 
 	dev->net->hw_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 				 NETIF_F_RXCSUM | NETIF_F_SG | NETIF_F_TSO;
@@ -1173,7 +1173,9 @@ ax88179_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags)
 	if (((skb->len + 8) % frame_size) == 0)
 		tx_hdr2 |= 0x80008000;	/* Enable padding */
 
-	skb_linearize(skb);
+	if (skb_linearize(skb))
+		return NULL;
+
 	headroom = skb_headroom(skb);
 	tailroom = skb_tailroom(skb);
 
@@ -1317,7 +1319,7 @@ static int ax88179_reset(struct usbnet *dev)
 			  1, 1, tmp);
 
 	dev->net->features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
-			      NETIF_F_RXCSUM | NETIF_F_SG | NETIF_F_TSO;
+			      NETIF_F_RXCSUM;
 
 	dev->net->hw_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 				 NETIF_F_RXCSUM | NETIF_F_SG | NETIF_F_TSO;
-- 
1.8.1.2
