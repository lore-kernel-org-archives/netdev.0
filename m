From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] asix: avoid copies in tx path
Date: Thu, 05 Jul 2012 16:31:01 +0200
Message-ID: <1341498661.2583.4162.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Allan Chou <allan@asix.com.tw>,
	Trond Wuellner <trond@chromium.org>,
	Grant Grundler <grundler@chromium.org>,
	Ming Lei <tom.leiming@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:42639 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751194Ab2GEObG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2012 10:31:06 -0400
Received: by eeit10 with SMTP id t10so3258635eei.19
        for <netdev@vger.kernel.org>; Thu, 05 Jul 2012 07:31:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

I noticed excess calls to skb_copy_expand() or memmove() in asix driver.

This driver needs to push 4 bytes in front of frame (packet_len)
and maybe add 4 bytes after the end (if padlen is 4)

So it should set needed_headroom & needed_tailroom to avoid
copies. But its not enough, because many packets are cloned
before entering asix_tx_fixup() and this driver use skb_cloned()
as a lazy way to check if it can push and put additional bytes in frame.

Avoid skb_copy_expand() expensive call, using following rules :

- We are allowed to push 4 bytes in headroom if skb_header_cloned()
  is false (and if we have 4 bytes of headroom)

- We are allowed to put 4 bytes at tail if skb_cloned()
  is false (and if we have 4 bytes of tailroom)

TCP packets for example are cloned, but skb_header_release()
was called in tcp stack, allowing us to use headroom for our needs.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Allan Chou <allan@asix.com.tw>
Cc: Trond Wuellner <trond@chromium.org>
Cc: Grant Grundler <grundler@chromium.org>
Cc: Paul Stewart <pstew@chromium.org>
Cc: Ming Lei <tom.leiming@gmail.com>
---
 drivers/net/usb/asix.c |   28 ++++++++++++++++++++++++----
 1 file changed, 24 insertions(+), 4 deletions(-)

diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
index 3ae80ec..6564c32 100644
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -358,14 +358,30 @@ static struct sk_buff *asix_tx_fixup(struct usbnet *dev, struct sk_buff *skb,
 
 	padlen = ((skb->len + 4) & (dev->maxpacket - 1)) ? 0 : 4;
 
-	if ((!skb_cloned(skb)) &&
-	    ((headroom + tailroom) >= (4 + padlen))) {
-		if ((headroom < 4) || (tailroom < padlen)) {
+	/* We need to push 4 bytes in front of frame (packet_len)
+	 * and maybe add 4 bytes after the end (if padlen is 4)
+	 *
+	 * Avoid skb_copy_expand() expensive call, using following rules :
+	 * - We are allowed to push 4 bytes in headroom if skb_header_cloned()
+	 *   is false (and if we have 4 bytes of headroom)
+	 * - We are allowed to put 4 bytes at tail if skb_cloned()
+	 *   is false (and if we have 4 bytes of tailroom)
+	 *
+	 * TCP packets for example are cloned, but skb_header_release()
+	 * was called in tcp stack, allowing us to use headroom for our needs.
+	 */
+	if (!skb_header_cloned(skb) &&
+	    !(padlen && skb_cloned(skb)) &&
+	    headroom + tailroom >= 4 + padlen) {
+		/* following should not happen, but better be safe */
+		if (headroom < 4 ||
+		    tailroom < padlen) {
 			skb->data = memmove(skb->head + 4, skb->data, skb->len);
 			skb_set_tail_pointer(skb, skb->len);
 		}
 	} else {
 		struct sk_buff *skb2;
+
 		skb2 = skb_copy_expand(skb, 4, padlen, flags);
 		dev_kfree_skb_any(skb);
 		skb = skb2;
@@ -373,8 +389,8 @@ static struct sk_buff *asix_tx_fixup(struct usbnet *dev, struct sk_buff *skb,
 			return NULL;
 	}
 
+	packet_len = ((skb->len ^ 0x0000ffff) << 16) + skb->len;
 	skb_push(skb, 4);
-	packet_len = (((skb->len - 4) ^ 0x0000ffff) << 16) + (skb->len - 4);
 	cpu_to_le32s(&packet_len);
 	skb_copy_to_linear_data(skb, &packet_len, sizeof(packet_len));
 
@@ -880,6 +896,8 @@ static int ax88172_bind(struct usbnet *dev, struct usb_interface *intf)
 
 	dev->net->netdev_ops = &ax88172_netdev_ops;
 	dev->net->ethtool_ops = &ax88172_ethtool_ops;
+	dev->net->needed_headroom = 4; /* cf asix_tx_fixup() */
+	dev->net->needed_tailroom = 4; /* cf asix_tx_fixup() */
 
 	asix_mdio_write(dev->net, dev->mii.phy_id, MII_BMCR, BMCR_RESET);
 	asix_mdio_write(dev->net, dev->mii.phy_id, MII_ADVERTISE,
@@ -1075,6 +1093,8 @@ static int ax88772_bind(struct usbnet *dev, struct usb_interface *intf)
 
 	dev->net->netdev_ops = &ax88772_netdev_ops;
 	dev->net->ethtool_ops = &ax88772_ethtool_ops;
+	dev->net->needed_headroom = 4; /* cf asix_tx_fixup() */
+	dev->net->needed_tailroom = 4; /* cf asix_tx_fixup() */
 
 	embd_phy = ((dev->mii.phy_id & 0x1f) == 0x10 ? 1 : 0);
 
