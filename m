From: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Subject: Re: [GIT PULL] xhci: Regression fix for 3.13.
Date: Fri, 6 Dec 2013 09:03:25 -0800
Message-ID: <20131206170325.GA14254@xanatos>
References: <cover.1386017042.git.sarah.a.sharp@linux.intel.com>
 <20131202214205.GA26175@kroah.com>
 <52A166CB.4020508@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org, David Laight <David.Laight@ACULAB.COM>,
	netdev@vger.kernel.org
To: Mark Lord <mlord@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:10990 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753013Ab3LFREM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 12:04:12 -0500
Content-Disposition: inline
In-Reply-To: <52A166CB.4020508@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

Greg, can you please revert David's patch (commit 35773dac5f86 from your
usb-linus branch)?

David said the patch fixed this lock up issue with his USB ethernet
adapter, but Mark says it doesn't fix the issue.  The patch touches some
hairy ring code in the xHCI driver, and I would rather not make any
changes to that code unless we can prove there is an issue with that
code.  We can always add the patch back later if it does turn out to fix
an issue.

David, can you please revert any local changes you've made, revert the
offending commit Mark is talking about (I think it's
http://patchwork.ozlabs.org/patch/264021/, which is commit
f27070158d6754765f2f5fd1617e8e42a0ea2318), and retest?  I want to see if
reverting that commit without making changes to the xHCI ring handling
code fixes your issues.

Thanks,
Sarah Sharp

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
