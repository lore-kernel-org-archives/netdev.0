From: Mark Lord <mlord@pobox.com>
Subject: Re: net/usb/ax88179_178a driver broken in linux-3.12
Date: Sun, 17 Nov 2013 13:56:56 -0500
Message-ID: <52891178.2080509@pobox.com>
References: <52890C7E.6000607@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060801080105030709050200"
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Ming Lei <ming.lei@canonical.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a-pb-sasl-quonix.pobox.com ([208.72.237.25]:39897 "EHLO
	sasl.smtp.pobox.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751446Ab3KQTCK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Nov 2013 14:02:10 -0500
In-Reply-To: <52890C7E.6000607@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060801080105030709050200
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

On 13-11-17 01:35 PM, Mark Lord wrote:
> The USB3 network adapter locks up consistently for me here in 3.12,
> but was working without issues in 3.11.x
> 
> Source of the problem is this patch:
>    http://patchwork.ozlabs.org/patch/264021/
> 
> Reverting the patch fixes the adapter.

Okay, upon closer inspection, the bug appears to be a math error.
Here's a simpler (non-revert) patch to fix the bug that was introduced in 3.12.

(un-mangled copy attached; reproduced below for ease of viewing).

Don't exceed more than the 8 bytes of reserved ("needed_headroom") space
when calling pskb_expand_head.  This fixes a bug introduced in linux-3.12.0.

Signed-off-by: Mark Lord <mlord@pobox.com>


--- ax88179_178a.c.orig 2013-11-03 18:41:51.000000000 -0500
+++ linux/drivers/net/usb/ax88179_178a.c        2013-11-17 13:47:26.127971404 -0500
@@ -1183,10 +1183,10 @@
        if (((skb->len + 8) % frame_size) == 0)
                tx_hdr2 |= 0x80008000;  /* Enable padding */

-       headroom = skb_headroom(skb) - 8;
+       headroom = skb_headroom(skb);

-       if ((skb_header_cloned(skb) || headroom < 0) &&
-           pskb_expand_head(skb, headroom < 0 ? 8 : 0, 0, GFP_ATOMIC)) {
+       if ((skb_header_cloned(skb) || headroom < 8) &&
+           pskb_expand_head(skb, headroom < 8 ? 8 - headroom : 0, 0, GFP_ATOMIC)) {
                dev_kfree_skb_any(skb);
                return NULL;
        }

-- 
Mark Lord
Real-Time Remedies Inc.
mlord@pobox.com

--------------060801080105030709050200
Content-Type: text/x-patch;
 name="51_ax88179_178a_fix_3.12_lockups.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="51_ax88179_178a_fix_3.12_lockups.patch"

Don't exceed more than the 8 bytes of reserved ("needed_headroom") space
when calling pskb_expand_head.  This fixes a bug introduced in linux-3.12.0.

Signed-off-by: Mark Lord <mlord@pobox.com>

--- ax88179_178a.c.orig	2013-11-03 18:41:51.000000000 -0500
+++ linux/drivers/net/usb/ax88179_178a.c	2013-11-17 13:47:26.127971404 -0500
@@ -1183,10 +1183,10 @@
 	if (((skb->len + 8) % frame_size) == 0)
 		tx_hdr2 |= 0x80008000;	/* Enable padding */
 
-	headroom = skb_headroom(skb) - 8;
+	headroom = skb_headroom(skb);
 
-	if ((skb_header_cloned(skb) || headroom < 0) &&
-	    pskb_expand_head(skb, headroom < 0 ? 8 : 0, 0, GFP_ATOMIC)) {
+	if ((skb_header_cloned(skb) || headroom < 8) &&
+	    pskb_expand_head(skb, headroom < 8 ? 8 - headroom : 0, 0, GFP_ATOMIC)) {
 		dev_kfree_skb_any(skb);
 		return NULL;
 	}

--------------060801080105030709050200--
