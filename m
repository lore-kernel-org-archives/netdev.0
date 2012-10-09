From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: compound skb frag pages appearing in start_xmit
Date: Tue, 9 Oct 2012 15:17:21 +0100
Message-ID: <1349792241.21847.199.camel@zakaz.uk.xensource.com>
References: <1349790467.21847.185.camel@zakaz.uk.xensource.com>
	 <1349790863.21172.4406.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	xen-devel <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Konrad Rzeszutek Wilk <konrad@kernel.org>,
	Sander Eikelenboom <linux@eikelenboom.it>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:44673 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752391Ab2JIOSN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2012 10:18:13 -0400
In-Reply-To: <1349790863.21172.4406.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-10-09 at 14:54 +0100, Eric Dumazet wrote:
> On Tue, 2012-10-09 at 14:47 +0100, Ian Campbell wrote:
> > Hi Eric,
> > 
> 
> Hi Ian
> 
> > Sander has discovered an issue where xen-netback is given a compound
> > page as one of the skb frag pages to transmit. Currently netback can
> > only handle PAGE_SIZE'd frags and bugs out.
> > 
> > I suspect this is something to do with 69b08f62e174 "net: use bigger
> > pages in __netdev_alloc_frag", although perhaps not because it looks
> > like only tg3 uses it and Sander has an r8169. Also tg3 seems to only
> > call netdev_alloc_frag for sizes < PAGE_SIZE. I'm probably missing
> > something.
> 
> 
> Its not the commit you want ;)
> 
> > 
> > Are all net drivers expected to be able to handle compound pages in the
> > frags? Obviously it is to their benefit to do so, so it is something
> > I'll want to look into for netback.
> > 
> 
> Not sure why a net driver would care of COMPOUND page at all ?
> 
> a Fragment has a struct page *, and a size.
> 
> a page can be order-0, order-1, order-2, order-3, ...

I keep falling into this trap that a struct page * can be order > 0.

The Xen PV interfaces deal in order-0 pages only. Also things which are
contiguous in physical space may not be contiguous in DMA space (which
we call "machine memory" in Xen terminology).

The first is probably a specific quirk of Xen, but I thought there were
other architectures where physical and DMA space we not necessarily
contiguous and which would therefore need special handling (I guess
those platforms all have IOMMUs)

> > I expect the main factor here is bridging/forwarding, since the
> > receiving NIC and its driver appear to support compound pages but the
> > outgoing NIC (netback in this case) does not.
> > 
> > I guess my question is should I be rushing to fix netback ASAP or should
> > I rather be looking for a bug somewhere which caused a frag of this type
> > to get as far as netback's start_xmit in the first place?
> > 
> > Or am I just barking up the wrong tree to start with?
> 
> 
> 
> The problem comes because of 
> 
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=commit;h=5640f7685831e088fe6c2e1f863a6805962f8e81
> 
> And yes, we must find a way to cope with this problem in your driver,
> because you can also benefit from increase of performance once fixed ;)
> 
> And yes I can certainly help, as I am the author of this patch ;)

I think I can mostly deal with this in the same way netback deals with
large skb heads i.e. by busting the multipage page into individual 4096
page chunks.

Does the higher order pages effectively reduce the number of frags which
are in use? e.g if MAX_SKB_FRAGS is 16, then for order-0 pages you could
have 64K worth of frag data.

If we switch to order-3 pages everywhere then can the skb contain 512K
of data, or does the effective maximum number of frags in an skb reduce
to 2?

If it's the latter then I think fixing netback is simple, if it's the
former then I might need to think a bit harder.

Ian.
