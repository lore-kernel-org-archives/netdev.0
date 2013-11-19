From: Mark Lord <mlord@pobox.com>
Subject: Re: net/usb/ax88179_178a driver broken in linux-3.12
Date: Tue, 19 Nov 2013 08:44:58 -0500
Message-ID: <528B6B5A.8000003@pobox.com>
References: <52890C7E.6000607@pobox.com> <52891178.2080509@pobox.com> <52891341.4020403@pobox.com> <AE90C24D6B3A694183C094C60CF0A2F6026B742B@saturn3.aculab.com> <AE90C24D6B3A694183C094C60CF0A2F6026B742F@saturn3.aculab.com> <528A9A36.50903@pobox.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7431@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030303050805070405050404"
To: David Laight <David.Laight@ACULAB.COM>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ming Lei <ming.lei@canonical.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a-pb-sasl-quonix.pobox.com ([208.72.237.25]:45578 "EHLO
	sasl.smtp.pobox.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752119Ab3KSNpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Nov 2013 08:45:14 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7431@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030303050805070405050404
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

On 13-11-19 05:04 AM, David Laight wrote:
>
> Which changes did you revert?

Just the bits that changed how the headroom/tailroom sizes
were checked and adjusted.  See attachment for the revert patch
I am using here.  My mailer unfortunately likes to mangle inline patches.

=========snip===========
Revert USB 3.0 network driver changes that break the adapter (lockups)
in 3.12.  This just puts back the original code from previous kernels.

Signed-off-by: Mark Lord <mlord@pobox.com>

--- linux/drivers/net/usb/ax88179_178a.c.orig   2013-11-03 18:41:51.000000000 -0500
+++ linux/drivers/net/usb/ax88179_178a.c        2013-11-17 13:23:39.525734277 -0500
@@ -1177,18 +1177,31 @@
        int frame_size = dev->maxpacket;
        int mss = skb_shinfo(skb)->gso_size;
        int headroom;
+       int tailroom;

        tx_hdr1 = skb->len;
        tx_hdr2 = mss;
        if (((skb->len + 8) % frame_size) == 0)
                tx_hdr2 |= 0x80008000;  /* Enable padding */

-       headroom = skb_headroom(skb) - 8;
+       headroom = skb_headroom(skb);
+       tailroom = skb_tailroom(skb);

-       if ((skb_header_cloned(skb) || headroom < 0) &&
-           pskb_expand_head(skb, headroom < 0 ? 8 : 0, 0, GFP_ATOMIC)) {
+       if (!skb_header_cloned(skb) &&
+           !skb_cloned(skb) &&
+           (headroom + tailroom) >= 8) {
+               if (headroom < 8) {
+                       skb->data = memmove(skb->head + 8, skb->data, skb->len);
+                       skb_set_tail_pointer(skb, skb->len);
+               }
+       } else {
+               struct sk_buff *skb2;
+
+               skb2 = skb_copy_expand(skb, 8, 0, flags);
                dev_kfree_skb_any(skb);
-               return NULL;
+               skb = skb2;
+               if (!skb)
+                       return NULL;
        }

        skb_push(skb, 4);
-- 
Mark Lord
Real-Time Remedies Inc.
mlord@pobox.com

--------------030303050805070405050404
Content-Type: text/x-patch;
 name="51_ax88179_178a_revert_3.12_lockups.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="51_ax88179_178a_revert_3.12_lockups.patch"

Revert USB 3.0 network driver changes that break the adapter (lockups)
in 3.12.  This just puts back the original code from previous kernels.

Signed-off-by: Mark Lord <mlord@pobox.com>

--- linux/drivers/net/usb/ax88179_178a.c.orig	2013-11-03 18:41:51.000000000 -0500
+++ linux/drivers/net/usb/ax88179_178a.c	2013-11-17 13:23:39.525734277 -0500
@@ -1177,18 +1177,31 @@
 	int frame_size = dev->maxpacket;
 	int mss = skb_shinfo(skb)->gso_size;
 	int headroom;
+	int tailroom;
 
 	tx_hdr1 = skb->len;
 	tx_hdr2 = mss;
 	if (((skb->len + 8) % frame_size) == 0)
 		tx_hdr2 |= 0x80008000;	/* Enable padding */
 
-	headroom = skb_headroom(skb) - 8;
+	headroom = skb_headroom(skb);
+	tailroom = skb_tailroom(skb);
 
-	if ((skb_header_cloned(skb) || headroom < 0) &&
-	    pskb_expand_head(skb, headroom < 0 ? 8 : 0, 0, GFP_ATOMIC)) {
+	if (!skb_header_cloned(skb) &&
+	    !skb_cloned(skb) &&
+	    (headroom + tailroom) >= 8) {
+		if (headroom < 8) {
+			skb->data = memmove(skb->head + 8, skb->data, skb->len);
+			skb_set_tail_pointer(skb, skb->len);
+		}
+	} else {
+		struct sk_buff *skb2;
+
+		skb2 = skb_copy_expand(skb, 8, 0, flags);
 		dev_kfree_skb_any(skb);
-		return NULL;
+		skb = skb2;
+		if (!skb)
+			return NULL;
 	}
 
 	skb_push(skb, 4);

--------------030303050805070405050404--
