From: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Subject: Help testing for USB ethernet/xHCI regression
Date: Tue, 28 Jan 2014 12:30:07 -0800
Message-ID: <20140128203007.GA3311@xanatos>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	David Laight <David.Laight@ACULAB.COM>
To: Mark Lord <mlord@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:14473 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755500AbaA1Ua1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jan 2014 15:30:27 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Mark,

You reported that you had an issue with a USB ethernet device on 3.12,
and that updating to 3.13-rc4 (which included commit 587194873820 "xhci:
convert TRB_CYCLE to le32 before using it to set Link TRB's cycle bit")
fixed the issue for you.  Later you said applying that patch on top of
3.12 didn't fix your issue.  It was unclear whether your issue was fixed
by another patch in 3.13-rc4.

That particular commit is causing regressions in the storage
layer (which we've fixed) and now also the usbfs layer (which has a
potential solution).  It also causes issues with 0.96 ASMedia xHCI hosts
(which also has a potential solution).

I'm concerned that there will be further regressions as well.  Before
applying additional regression fixes for David's patch, I'd like to slow
down and double check that the patch actually solved the issue it set
out to.

Can you please pull this branch, which contains a 3.13 kernel with
David's patch reverted, and test whether your USB ethernet device works
or fails?

git clone -b 3.13-td-changes-reverted git://git.kernel.org/pub/scm/linux/kernel/git/sarah/xhci.git

If it fails, please turn on xHCI debugging:
# echo -n 'module xhci_hcd =p' > /sys/kernel/debug/dynamic_debug/control
trigger the failure, and send me the resulting dmesg, along with the
procedure/commands you used to make the device fail.

Also, please double check to see if vanilla 3.13 works or fails.

David, please do the same and send me dmesg.

I know the log will be large due to "untransferred length" message, but
I need those messages, so please compress the files or stick the dmesg
up on pastebin.

Thanks,
Sarah Sharp

On Fri, Dec 06, 2013 at 12:55:23AM -0500, Mark Lord wrote:
> On 13-12-02 04:42 PM, Greg Kroah-Hartman wrote:
> > On Mon, Dec 02, 2013 at 12:49:08PM -0800, Sarah Sharp wrote:
> >> The following changes since commit c24cb6c8b501ebdf1aacec7960110a9741a45ced:
> >>
> >>   Merge tag 'fixes-for-v3.13-rc2' of git://git.kernel.org/pub/scm/linux/kernel/git/balbi/usb into usb-linus (2013-11-27 09:49:03 -0800)
> >>
> >> are available in the git repository at:
> >>
> >>
> >>   git://git.kernel.org/pub/scm/linux/kernel/git/sarah/xhci.git tags/for-usb-linus-2013-12-02
> > 
> > Pulled and pushed out, thanks.
> 
> Did this commit make it into linux-3.12.3 ?
> 
> I ask, because the NIC still locks up with that kernel,
> and even with the patch I had been using from David Laight.
> 
> Reverting the change that originally broke it still works though.
> Could we please get this reverted until such time as a reworked
> patch can be prepared for it?
> 
> This is what I am reverting locally to make it all work
> as it did prior to linux-3.12 was released.  Unmangled copy also attached:
> 
> --- linux/drivers/net/usb/ax88179_178a.c.orig	2013-11-03 18:41:51.000000000 -0500
> +++ linux/drivers/net/usb/ax88179_178a.c	2013-11-17 13:23:39.525734277 -0500
> @@ -1177,18 +1177,31 @@
>  	int frame_size = dev->maxpacket;
>  	int mss = skb_shinfo(skb)->gso_size;
>  	int headroom;
> +	int tailroom;
> 
>  	tx_hdr1 = skb->len;
>  	tx_hdr2 = mss;
>  	if (((skb->len + 8) % frame_size) == 0)
>  		tx_hdr2 |= 0x80008000;	/* Enable padding */
> 
> -	headroom = skb_headroom(skb) - 8;
> +	headroom = skb_headroom(skb);
> +	tailroom = skb_tailroom(skb);
> 
> -	if ((skb_header_cloned(skb) || headroom < 0) &&
> -	    pskb_expand_head(skb, headroom < 0 ? 8 : 0, 0, GFP_ATOMIC)) {
> +	if (!skb_header_cloned(skb) &&
> +	    !skb_cloned(skb) &&
> +	    (headroom + tailroom) >= 8) {
> +		if (headroom < 8) {
> +			skb->data = memmove(skb->head + 8, skb->data, skb->len);
> +			skb_set_tail_pointer(skb, skb->len);
> +		}
> +	} else {
> +		struct sk_buff *skb2;
> +
> +		skb2 = skb_copy_expand(skb, 8, 0, flags);
>  		dev_kfree_skb_any(skb);
> -		return NULL;
> +		skb = skb2;
> +		if (!skb)
> +			return NULL;
>  	}
> 
>  	skb_push(skb, 4);

> --- linux/drivers/net/usb/ax88179_178a.c.orig	2013-11-03 18:41:51.000000000 -0500
> +++ linux/drivers/net/usb/ax88179_178a.c	2013-11-17 13:23:39.525734277 -0500
> @@ -1177,18 +1177,31 @@
>  	int frame_size = dev->maxpacket;
>  	int mss = skb_shinfo(skb)->gso_size;
>  	int headroom;
> +	int tailroom;
>  
>  	tx_hdr1 = skb->len;
>  	tx_hdr2 = mss;
>  	if (((skb->len + 8) % frame_size) == 0)
>  		tx_hdr2 |= 0x80008000;	/* Enable padding */
>  
> -	headroom = skb_headroom(skb) - 8;
> +	headroom = skb_headroom(skb);
> +	tailroom = skb_tailroom(skb);
>  
> -	if ((skb_header_cloned(skb) || headroom < 0) &&
> -	    pskb_expand_head(skb, headroom < 0 ? 8 : 0, 0, GFP_ATOMIC)) {
> +	if (!skb_header_cloned(skb) &&
> +	    !skb_cloned(skb) &&
> +	    (headroom + tailroom) >= 8) {
> +		if (headroom < 8) {
> +			skb->data = memmove(skb->head + 8, skb->data, skb->len);
> +			skb_set_tail_pointer(skb, skb->len);
> +		}
> +	} else {
> +		struct sk_buff *skb2;
> +
> +		skb2 = skb_copy_expand(skb, 8, 0, flags);
>  		dev_kfree_skb_any(skb);
> -		return NULL;
> +		skb = skb2;
> +		if (!skb)
> +			return NULL;
>  	}
>  
>  	skb_push(skb, 4);
