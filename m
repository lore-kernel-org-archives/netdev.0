From: Mark Lord <mlord-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [GIT PULL] xhci: Regression fix for 3.13.
Date: Fri, 06 Dec 2013 00:55:23 -0500
Message-ID: <52A166CB.4020508@pobox.com>
References: <cover.1386017042.git.sarah.a.sharp@linux.intel.com> <20131202214205.GA26175@kroah.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030102040702020206060200"
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20131202214205.GA26175-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030102040702020206060200
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

On 13-12-02 04:42 PM, Greg Kroah-Hartman wrote:
> On Mon, Dec 02, 2013 at 12:49:08PM -0800, Sarah Sharp wrote:
>> The following changes since commit c24cb6c8b501ebdf1aacec7960110a9741a45ced:
>>
>>   Merge tag 'fixes-for-v3.13-rc2' of git://git.kernel.org/pub/scm/linux/kernel/git/balbi/usb into usb-linus (2013-11-27 09:49:03 -0800)
>>
>> are available in the git repository at:
>>
>>
>>   git://git.kernel.org/pub/scm/linux/kernel/git/sarah/xhci.git tags/for-usb-linus-2013-12-02
> 
> Pulled and pushed out, thanks.

Did this commit make it into linux-3.12.3 ?

I ask, because the NIC still locks up with that kernel,
and even with the patch I had been using from David Laight.

Reverting the change that originally broke it still works though.
Could we please get this reverted until such time as a reworked
patch can be prepared for it?

This is what I am reverting locally to make it all work
as it did prior to linux-3.12 was released.  Unmangled copy also attached:

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

--------------030102040702020206060200
Content-Type: text/x-patch;
 name="51_ax88179_178a_revert_3.12_lockups.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="51_ax88179_178a_revert_3.12_lockups.patch"

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

--------------030102040702020206060200--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
