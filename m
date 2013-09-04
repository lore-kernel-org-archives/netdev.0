From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH] xen-netback: count number required slots for an skb more
 carefully
Date: Wed, 4 Sep 2013 16:44:00 +0100
Message-ID: <20130904154400.GS14104@zion.uk.xensource.com>
References: <1378229390-12919-1-git-send-email-david.vrabel@citrix.com>
 <20130903215328.GA13465@zion.uk.xensource.com>
 <52271DFF.3070008@citrix.com>
 <20130904131459.GO14104@zion.uk.xensource.com>
 <52273D59.2020205@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <xen-devel@lists.xen.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	<netdev@vger.kernel.org>, <msw@amazon.com>, <annie.li@oracle.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:39046 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934868Ab3IDPoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 11:44:04 -0400
Content-Disposition: inline
In-Reply-To: <52273D59.2020205@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 04, 2013 at 03:02:01PM +0100, David Vrabel wrote:
[...]
> >>
> >> I think I prefer fixing the counting for backporting to stable kernels.
> > 
> > The original patch has coding style change. Sans that contextual change
> > it's not a very long patch.
> 
> The size of the patch isn't the main concern for backport-ability.  It's
> the frontend visible changes and thus any (unexpected) impacts on
> frontends -- this is especially important as only a small fraction of
> frontends in use will be tested with these changes.
> 
> >>  Xi's approach of packing the ring differently is a change in frontend
> >> visible behaviour and seems more risky. e.g., possible performance
> >> impact so I would like to see some performance analysis of that approach.
> >>
> > 
> > With Xi's approach it is more efficient for backend to process. As we
> > now use one less grant copy operation which means we copy the same
> > amount of data with less grant ops.
> 
> It think it uses more grant ops because the copies of the linear
> portion are in chunks that do not cross source page boundaries.
> 
> i.e., in netbk_gop_skb():
> 
> 	data = skb->data;
> 	while (data < skb_tail_pointer(skb)) {
> 		unsigned int offset = offset_in_page(data);
> 		unsigned int len = PAGE_SIZE - offset;
>                 [...]
> 
> It wasn't clear from the patch that this had been considered and that
> any extra space needed in the grant op array was made available.
> 

If I'm not mistaken the grant op array is already enormous. See the
comment in struct xen_netbk for grant_copy_op. The case that a buffer
straddles two slots was taken into consideration long ago -- that's
why you don't see any comment or code change WRT that...

> > From frontend's PoV I think the impact is minimal. Frontend is involved
> > in assembling the packets. It only takes what's in the ring and chain
> > them together. The operation involves copying so far is the
> > __pskb_pull_tail which happens a) in rare case when there's more frags
> > than frontend's MAX_SKB_FRAGS, b) when pull_to > skb_headlen which
> > happens. With Xi's change the rare case a) will even be rarer than
> > before as we use less slots. b) happens the same as it happens before
> > Xi's change, because the pull is guarded by "if (pull_to >
> > skb_headlen(skb))" and Xi's change doesn't affect skb_headlen.
> > 
> > So overall I don't see obvious downside.
> 
> The obvious downside is it doesn't exist (in a form that can be applied
> now), it hasn't been tested and I think there may well be a subtle bug
> that would need a careful review or testing to confirm/deny.
> 

It does exist and apply cleanly on top of net tree. I haven't posted
it yet because we haven't reached concensus which path to take. :-)

The only reason that last version didn't get upstreamed is that the
commit message wasn't clear enough. From the technical PoV it's quite
sound and I believe Amazon has been using it for a long time -- the
older reference dates back to Aug 2012 IIRC. It's just never properly
upstreamed.

> You are free to work on this as a future improvements but I really don't
> see why this critical bug fix needs to be delayed any further.
> 

True. I don't mean to hold off critical fix. Just want to make sure that
every option is presented and considered.

Wei.

> David
