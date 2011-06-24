From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: SKB paged fragment lifecycle on receive
Date: Fri, 24 Jun 2011 23:44:37 +0100
Message-ID: <1308955477.5807.8.camel@dagon.hellion.org.uk>
References: <1308930202.32717.144.camel@zakaz.uk.xensource.com>
	 <4E04C961.9010302@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	xen-devel <xen-devel@lists.xensource.com>,
	Rusty Russell <rusty@rustcorp.com.au>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:38137 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753957Ab1FXWoj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 18:44:39 -0400
In-Reply-To: <4E04C961.9010302@goop.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-06-24 at 18:29 +0100, Jeremy Fitzhardinge wrote:
> On 06/24/2011 08:43 AM, Ian Campbell wrote:
> > We've previously looked into solutions using the skb destructor callback
> > but that falls over if the skb is cloned since you also need to know
> > when the clone is destroyed. Jeremy Fitzhardinge and I subsequently
> > looked at the possibility of a no-clone skb flag (i.e. always forcing a
> > copy instead of a clone) but IIRC honouring it universally turned into a
> > very twisty maze with a number of nasty corner cases etc. It also seemed
> > that the proportion of SKBs which get cloned at least once appeared as
> > if it could be quite high which would presumably make the performance
> > impact unacceptable when using the flag. Another issue with using the
> > skb destructor is that functions such as __pskb_pull_tail will eat (and
> > free) pages from the start of the frag array such that by the time the
> > skb destructor is called they are no longer there.
> >
> > AIUI Rusty Russell had previously looked into a per-page destructor in
> > the shinfo but found that it couldn't be made to work (I don't remember
> > why, or if I even knew at the time). Could that be an approach worth
> > reinvestigating?
> >
> > I can't really think of any other solution which doesn't involve some
> > sort of driver callback at the time a page is free()d.
> 
> One simple approach would be to simply make sure that we retain a page
> reference on any granted pages so that the network stack's put pages
> will never result in them being released back to the kernel.  We can
> also install an skb destructor.  If it sees a page being released with a
> refcount of 1, then we know its our own reference and can free the page
> immediately.  If the refcount is > 1 then we can add it to a queue of
> pending pages, which can be periodically polled to free pages whose
> other references have been dropped.

One problem with this is that some functions (__pskb_pull_tail) drop the
ref count and then remove the page from the skb's fraglist. So by the
time the destructor is called you have lost the page and cannot do the
refcount checking.

I suppose we could keep a queue of _all_ pages we ever put in an SKB
which we poll. We could still check for pages with count==1 in the
destructor. Apart from the other issues with the destructor not being
copied over clone etc which would cause us to fall-back to polling the
queue more often than not I reckon.

> That said, I think an event-based rather than polling based mechanism
> would be much more preferable.

Absolutely.

> > I expect that wrapping the uses of get/put_page in a network specific
> > wrapper (e.g. skb_{get,frag}_frag(skb, nr) would be a useful first step
> > in any solution. That's a pretty big task/patch in itself but could be
> > done. Might it be worthwhile in for its own sake?
> 
> Is there some way to do it so that you'd get compiler warnings/errors in
> missed cases?  I guess wrap "struct page" in some other type would go
> some way to helping.

I was thinking it could be done by changing the field name (e.g. even
just to _frag), add the wrapper and fixup everything grep could find and
then run an allBLAHconfig build, fix the compile errors, repeat.

Once the transition is complete we would have the option of putting the
name back -- since it would only mean changing the wrapper. Although I
don't know if we would necessarily want that since otherwise new
open-coded users will likely creep in.

> > Does anyone have any ideas or advice for other approaches I could try
> > (either on the driver or stack side)?
> >
> > FWIW I proposed a session on the subject for LPC this year. The proposal
> > was for the virtualisation track although as I say I think the class of
> > problem reaches a bit wider than that. Whether the session will be a
> > discussion around ways of solving the issue or a presentation on the
> > solution remains to be seen ;-)
> >
> > Ian.
> >
> > [0] at least with a mainline kernel, in the older out-of-tree Xen stuff
> > we had a PageForeign page-flag and a destructor function in a spare
> > struct page field which was called from the mm free routines
> > (free_pages_prepare and free_hot_cold_page). I'm under no illusions
> > about the upstreamability of this approach...
> 
> When I last asked AKPM about this - a long time ago - the problem was
> that we'd simply run out of page flags (at least on 32-bit x86), so it
> simply wasn't implementable.  But since then the page flags have been
> rearranged and I think there's less pressure on them - but they're still
> a valuable resource, so the justification would need to be strong (ie,
> multiple convincing users).
> 
>     J


