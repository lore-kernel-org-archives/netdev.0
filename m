From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] xen-netfront possibly rides the rocket too often
Date: Fri, 16 May 2014 11:32:39 +0100
Message-ID: <20140516103239.GF18551@zion.uk.xensource.com>
References: <537262AB.5010408@canonical.com>
 <5373C8D4.2010803@citrix.com>
 <1400143605.1006.1.camel@kazak.uk.xensource.com>
 <20140515110410.GD1117@zion.uk.xensource.com>
 <5374AF88.2070608@canonical.com>
 <20140516094842.GA18551@zion.uk.xensource.com>
 <5375E3EE.6010306@canonical.com>
 <5375E5CC.2080904@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>,
	netdev <netdev@vger.kernel.org>
To: Stefan Bader <stefan.bader@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:55043 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756600AbaEPKcp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2014 06:32:45 -0400
Content-Disposition: inline
In-Reply-To: <5375E5CC.2080904@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 16, 2014 at 12:17:48PM +0200, Stefan Bader wrote:
> On 16.05.2014 12:09, Stefan Bader wrote:
> > On 16.05.2014 11:48, Wei Liu wrote:
> >> On Thu, May 15, 2014 at 02:14:00PM +0200, Stefan Bader wrote:
> >> [...]
> >>>> Wei.
> >>>>
> >>> Reading more of the code I would agree. The definition of MAX_SKB_FRAGS (at
> >>> least now with compound pages) cannot be used in any way to derive the number of
> >>> 4k slots a transfer will require.
> >>>
> >>> Zoltan already commented on worst cases. Not sure it would get as bad as that or
> >>> "just" 16*4k frags all in the middle of compound pages. That would then end in
> >>> around 33 or 34 slots, depending on the header.
> >>>
> >>> Zoltan wrote:
> >>>> I think the worst case scenario is when every frag and the linear buffer contains 2 bytes,
> >>>> which are overlapping a page boundary (that's (17+1)*2=36 so far), plus 15 of
> >>> them have a 4k
> >>>> page in the middle of them, so, a 1+4096+1 byte buffer can span over 3 page.
> >>>> That's 51 individual pages.
> >>>
> >>> I cannot claim to really know what to expect worst case. Somewhat I was thinking
> >>> of a
> >>> worst case of (16+1)*2, which would be inconvenient enough.
> >>>
> >>> So without knowing exactly how to do it, but as Ian said it sounds best to come
> >>> up with some sort of exception coalescing in cases the slot count goes over 18
> >>> and we know the data size is below 64K.
> >>>
> >>
> >> I took a stab at it this morning and came up with this patch. Ran
> >> redis-benchmark, it seemed to fix that for me -- only saw one "failed to
> >> linearize skb" during
> >>
> >>   redis-benchmark -h XXX -d 1000 -t lrange
> >>
> >> And before this change, a lot of "rides rocket" were triggered.
> >>
> >> Thought?
> > 
> > It appears at least to me as something that nicely makes use of existing code. I
> > was wondering about what could or could not be used. Trying to get ones head
> > around the whole thing is kind of a lot to look at.
> > 
> > The change at least looks straight forward enough.
> 
> The only woe for me is that I am looking puzzled at the implementation of
> skb_linearize(). Somehow the data_len element decides whether a skb can be
> linearized and basically how much it tries to pull from the tail. It probably
> makes sense ... just not to me with not deep experience here.
> 

Data_len is the size of paged data (that's the size of data in frags).
If it pulls everything from frags to linear area then SKB is linearized.

Wei.

> -Stefan
> 
