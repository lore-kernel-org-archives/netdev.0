From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 0/2] pktgen: Clone skb to avoid corruption of skbs in
 ndo_start_xmit methods (v3)
Date: Tue, 23 Aug 2011 11:13:54 -0400
Message-ID: <20110823151354.GA21473@hmsreliant.think-freely.org>
References: <1311105179-26408-1-git-send-email-nhorman@tuxdriver.com>
 <1311696338-4739-1-git-send-email-nhorman@tuxdriver.com>
 <1313593637.2776.9.camel@bwh-desktop>
 <20110822002641.GA2550@neilslaptop.think-freely.org>
 <1314029857.2803.6.camel@bwh-desktop>
 <20110822181420.GD12337@hmsreliant.think-freely.org>
 <1314108084.2821.5.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:35554 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753448Ab1HWPOM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2011 11:14:12 -0400
Content-Disposition: inline
In-Reply-To: <1314108084.2821.5.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 23, 2011 at 03:01:24PM +0100, Ben Hutchings wrote:
> On Mon, 2011-08-22 at 14:14 -0400, Neil Horman wrote:
> > On Mon, Aug 22, 2011 at 05:17:37PM +0100, Ben Hutchings wrote:
> > > On Sun, 2011-08-21 at 20:27 -0400, Neil Horman wrote:
> > > > On Wed, Aug 17, 2011 at 04:07:17PM +0100, Ben Hutchings wrote:
> > > > > On Tue, 2011-07-26 at 12:05 -0400, Neil Horman wrote:
> > > > > > Ok, after considering all your comments, Dave suggested this as an alternate
> > > > > > approach:
> > > > > > 
> > > > > > 1) We create a new priv_flag, IFF_SKB_TX_SHARED, to identify drivers capable of
> > > > > > handling shared skbs.  Default is to not set this flag
> > > > > > 
> > > > > > 2) Modify ether_setup to enable this flag, under the assumption that any driver
> > > > > > calling this  function is initalizing a real ethernet device and as such can
> > > > > > handle shared skbs since they don't tend to store state in the skb struct.
> > > > > > Pktgen can then query this flag when a user script attempts to issue the
> > > > > > clone_skb command and decide if it is to be alowed or not.
> > > > > [...]
> > > > > 
> > > > > A bunch of Ethernet drivers do skb_pad() or skb_padto() in their
> > > > > ndo_start_xmit implementations, either to avoid hardware bugs or because
> > > > > the MAC doesn't automatically pad to the minimum frame length.  This
> > > > > presumably means they can't generally handle shared skbs, though in the
> > > > > specific case of pktgen it should be safe as long as a single skb is not
> > > > > submitted by multiple threads at once.
> > > > > 
> > > > Agreed, given that pktgen is doing skb sharing in a serialized manner (i.e. one
> > > > thread of execution increasing skb->users rather than in multiple threads), the
> > > > skb_pad[to] cases are safe.  Are there cases in which shared skbs are
> > > > transmitted in parallel threads that we need to check for?
> > > 
> > > Not that I'm aware of.  However, you have defined the flag to mean 'safe
> > > to send shared skbs', and this is not generally true for those drivers.
> > > 
> > > So please decide whether:
> > > a. The flag means 'safe to send shared skbs' (i.e. the TX path does not
> > > modify the skb) and drivers which pad must clear it on their devices.
> > > b. The flag means 'safe to send shared skbs in the way ptkgen does', and
> > > the restrictions this places on the user and driver should be specified.
> > > 
> > 
> > The flag means safe to send shared skbs.
> > 
> > Actually looking closer at this, I don't think this is much of a problem at all.
> > The flag is cleared on devices for which it is unsafe to send shared skbs, not
> > because there are multiple users of the skb in parallel, but because the driver
> > expects to have continued exclusive access to the skb after the drivers
> > ndo_start_xmit method returns.
> > 
> > In the pktgen case, skbs have skb->users > 1, but all users exist in the same
> > execution context, making their transmission serialized.
> [...]
> 
> So it is not *generally* safe to send shared skbs to drivers that make
> idempotent changes to the skb.  There is a restriction and while pktgen
> operates within it today I don't want it to be an unwritten assumption.
> 
It _is_ generally safe to make idempotent changes to an skb when their shared,
thats what I was explaining in my previous post.  The only restriction we need
to concern ourselves with is the drivers assumption that any modifications
(idempotent or not) will be preserved after the return from ndo_start_xmit.

> > So even though drivers that call skb_pad[to] modify the skb, its perfectly ok to
> > do so, as long as they don't assume that the struct skb will remain in that
> > state after the driver is done with it.
> > 
> > This works out perfectly well for skb_padto calls, since the function reduces to
> > a no-op after the minimal tail size has been reached.
> [...]
> 
> Right, that's what I want to be specified.  Did you miss my own
> follow-up?  I proposed this description for the interface flag:
> 
>         The ndo_start_xmit operation for this interface either does not
>         modify the given skb or modifies it idempotently. A single skb
>         may be transmitted repeatedly on a single queue of this
>         interface, but not on multiple queues or on multiple interfaces.
> 
No, I read it, I just don't agree with it. :).  Specifically I disagree with the
langauge indicating that you cannot transmit a shared skb on multiple queues or
on multiple interfaces.  You can in fact do that sanely with shared skbs,
because to do so you are required to serialize their transmission anyway.  By
definition they're shared, and you can't send them to multiple devices without
modifing data in the skb that may be read in parallel in an alternate execution
context.

In short, what I'm saying is that there is no way to safely send a shared skb in
parallel to multiple queues/interfaces without introducing other bugs orthogonal
to the one prevented by the flag I added.  The only thing the flag indicates is
that the driver can't handle non-idempotent changes to skbs (like being added to
an sk_buff_head list)

I think if you really want to clarify the meaning of the flag, I would add
language to it like:
	The ndo_start_xmit operation either makes no changes to the skb data,
	or makes only idempotent changes, and does not expect any changes to 
	persist after the return from nod_start_xmit

Its really the expectation of persistence that we need to worry about here.  If
a driver adds an skb to a list for deferred transmission, for example, it
assumes that it owns the skb, and that its state will remain unchanged after the
return from ndo_start_xmit, but in the shared case thats not a safe assumption
to make because in the shared case teh network stack is once again free to
modify the skb.

If you're ok with my language, I'll put a patch together for that.
Neil
 
> Ben.
> 
> -- 
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
> 
> 
