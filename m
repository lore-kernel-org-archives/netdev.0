From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 0/2] pktgen: Clone skb to avoid corruption of skbs in
 ndo_start_xmit methods (v3)
Date: Tue, 23 Aug 2011 12:21:33 -0400
Message-ID: <20110823162133.GB21473@hmsreliant.think-freely.org>
References: <1311105179-26408-1-git-send-email-nhorman@tuxdriver.com>
 <1311696338-4739-1-git-send-email-nhorman@tuxdriver.com>
 <1313593637.2776.9.camel@bwh-desktop>
 <20110822002641.GA2550@neilslaptop.think-freely.org>
 <1314029857.2803.6.camel@bwh-desktop>
 <20110822181420.GD12337@hmsreliant.think-freely.org>
 <1314108084.2821.5.camel@bwh-desktop>
 <20110823151354.GA21473@hmsreliant.think-freely.org>
 <1314114785.2821.17.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:60490 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753135Ab1HWQVh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2011 12:21:37 -0400
Content-Disposition: inline
In-Reply-To: <1314114785.2821.17.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 23, 2011 at 04:53:05PM +0100, Ben Hutchings wrote:
> On Tue, 2011-08-23 at 11:13 -0400, Neil Horman wrote:
> > On Tue, Aug 23, 2011 at 03:01:24PM +0100, Ben Hutchings wrote:
> [...]
> > > Right, that's what I want to be specified.  Did you miss my own
> > > follow-up?  I proposed this description for the interface flag:
> > > 
> > >         The ndo_start_xmit operation for this interface either does not
> > >         modify the given skb or modifies it idempotently. A single skb
> > >         may be transmitted repeatedly on a single queue of this
> > >         interface, but not on multiple queues or on multiple interfaces.
> > > 
> > No, I read it, I just don't agree with it. :).  Specifically I disagree with the
> > langauge indicating that you cannot transmit a shared skb on multiple queues or
> > on multiple interfaces.  You can in fact do that sanely with shared skbs,
> > because to do so you are required to serialize their transmission anyway.  By
> > definition they're shared, and you can't send them to multiple devices without
> > modifing data in the skb that may be read in parallel in an alternate execution
> > context.
> >
> > In short, what I'm saying is that there is no way to safely send a shared skb in
> > parallel to multiple queues/interfaces without introducing other bugs orthogonal
> > to the one prevented by the flag I added.  The only thing the flag indicates is
> > that the driver can't handle non-idempotent changes to skbs (like being added to
> > an sk_buff_head list)
> 
> In fact the caller must commit to a particular queue by setting skb->dev
> and skb->queue_mapping.  So I really was talking nonsense.

Exactly, the fact that struct sk_buff holds output interface and queue
information implies that we need to serialize transmit operations in the shared
skb case, so we're safe even if we're talking about multiple contexts of
execution.

> 
> > I think if you really want to clarify the meaning of the flag, I would add
> > language to it like:
> > 	The ndo_start_xmit operation either makes no changes to the skb data,
> > 	or makes only idempotent changes, and does not expect any changes to 
> > 	persist after the return from nod_start_xmit
> >
> > Its really the expectation of persistence that we need to worry about here.  If
> > a driver adds an skb to a list for deferred transmission, for example, it
> > assumes that it owns the skb, and that its state will remain unchanged after the
> > return from ndo_start_xmit, but in the shared case thats not a safe assumption
> > to make because in the shared case teh network stack is once again free to
> > modify the skb.
> 
> The skb data (including padding) needs to persist until DMA is complete,
> even if the driver ignores the actual struct sk_buff from then on.  And
> pktgen certainly doesn't want to modify it.
> 
This is true, but we're still protected I think, at least in the case of using
skb_pad[to] in the driver.  A driver won't kfree_skb the skb until the DMA is
complete, so it will remained shared (i.e. skb->users > 1, and skb_shared will
consequently return true).  On iterated uses of skb_pad[to] be they in the same
driver or different drivers), any change that re-allocates or modifies the data
area of an skb goes through pskb_expand_head and/or __pskb_pull_tail.  In the
former case we BUG halt, because its already invalid to call pskb_expand_head on
a shared skb, and in the latter case shared skbs will get cloned automatically,
removing the shared state of the skb.

> > If you're ok with my language, I'll put a patch together for that.
> 
> I don't think we're quite there yet.
> 
Do you have other cases you're concerned about?

Neil

> Ben.
> 
> -- 
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
> 
> 
