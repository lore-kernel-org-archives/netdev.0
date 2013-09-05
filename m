From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH] xen-netback: count number required slots for an skb more
 carefully
Date: Thu, 5 Sep 2013 11:27:48 +0100
Message-ID: <20130905102748.GX14104@zion.uk.xensource.com>
References: <1378229390-12919-1-git-send-email-david.vrabel@citrix.com>
 <20130903215328.GA13465@zion.uk.xensource.com>
 <52271DFF.3070008@citrix.com>
 <20130904131459.GO14104@zion.uk.xensource.com>
 <52273D59.2020205@citrix.com>
 <20130904154400.GS14104@zion.uk.xensource.com>
 <522858FB.807@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <xen-devel@lists.xen.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	<netdev@vger.kernel.org>, <msw@amazon.com>, <annie.li@oracle.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:34196 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935555Ab3IEK1u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 06:27:50 -0400
Content-Disposition: inline
In-Reply-To: <522858FB.807@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 05, 2013 at 11:12:11AM +0100, David Vrabel wrote:
> On 04/09/13 16:44, Wei Liu wrote:
> > On Wed, Sep 04, 2013 at 03:02:01PM +0100, David Vrabel wrote:
> > [...]
> >>>>
> >>>> I think I prefer fixing the counting for backporting to stable kernels.
> >>>
> >>> The original patch has coding style change. Sans that contextual change
> >>> it's not a very long patch.
> >>
> >> The size of the patch isn't the main concern for backport-ability.  It's
> >> the frontend visible changes and thus any (unexpected) impacts on
> >> frontends -- this is especially important as only a small fraction of
> >> frontends in use will be tested with these changes.
> >>
> >>>>  Xi's approach of packing the ring differently is a change in frontend
> >>>> visible behaviour and seems more risky. e.g., possible performance
> >>>> impact so I would like to see some performance analysis of that approach.
> >>>>
> >>>
> >>> With Xi's approach it is more efficient for backend to process. As we
> >>> now use one less grant copy operation which means we copy the same
> >>> amount of data with less grant ops.
> >>
> >> It think it uses more grant ops because the copies of the linear
> >> portion are in chunks that do not cross source page boundaries.
> >>
> >> i.e., in netbk_gop_skb():
> >>
> >> 	data = skb->data;
> >> 	while (data < skb_tail_pointer(skb)) {
> >> 		unsigned int offset = offset_in_page(data);
> >> 		unsigned int len = PAGE_SIZE - offset;
> >>                 [...]
> >>
> >> It wasn't clear from the patch that this had been considered and that
> >> any extra space needed in the grant op array was made available.
> >>
> > 
> > If I'm not mistaken the grant op array is already enormous. See the
> > comment in struct xen_netbk for grant_copy_op. The case that a buffer
> > straddles two slots was taken into consideration long ago -- that's
> > why you don't see any comment or code change WRT that..
> 
> I'm not convinced that even that is enough for the current
> implementation in the (very) worse case.
> 
> Consider a skb with 8 frags all 512 in length.  The linear data will be
> placed into 1 slot, and the frags will be packed into 1 slot so 9 grant
> ops and 2 slots.
> 

That is still less than 8 * 2 = 16 slots in the grant copy array, right?
Basically each paged buffer is allowed for 2 slots in the grant copy
array.

> I definitely think we do not want to potentially regress any further in
> this area.
> 

Sure.

> David
