From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next 2/3] tipc: byte-based overload control on socket
 receive queue
Date: Thu, 21 Feb 2013 13:16:56 -0500
Message-ID: <20130221181656.GC2730@shamino.rdu.redhat.com>
References: <20130218144757.GA26199@hmsreliant.think-freely.org>
 <512332DA.5040508@ericsson.com>
 <20130219142629.GA31871@hmsreliant.think-freely.org>
 <5123BC46.40909@ericsson.com>
 <20130219191833.GB31871@hmsreliant.think-freely.org>
 <5123DDA8.5090202@ericsson.com>
 <20130219214439.GC31871@hmsreliant.think-freely.org>
 <5125F5D3.1000509@ericsson.com>
 <20130221150746.GA2730@shamino.rdu.redhat.com>
 <51265134.5080001@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Ying Xue <ying.xue@windriver.com>,
	Jon Maloy <maloy@donjonn.com>
To: Jon Maloy <jon.maloy@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33797 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756520Ab3BUSRc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2013 13:17:32 -0500
Content-Disposition: inline
In-Reply-To: <51265134.5080001@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 21, 2013 at 05:54:12PM +0100, Jon Maloy wrote:
> On 02/21/2013 04:07 PM, Neil Horman wrote:
> > On Thu, Feb 21, 2013 at 11:24:19AM +0100, Jon Maloy wrote:
> >> On 02/19/2013 10:44 PM, Neil Horman wrote:
> >>> On Tue, Feb 19, 2013 at 09:16:40PM +0100, Jon Maloy wrote:
> >>>> On 02/19/2013 08:18 PM, Neil Horman wrote:
> >>>>> On Tue, Feb 19, 2013 at 06:54:14PM +0100, Jon Maloy wrote:
> >>>>>> On 02/19/2013 03:26 PM, Neil Horman wrote:
> >>>>>>> On Tue, Feb 19, 2013 at 09:07:54AM +0100, Jon Maloy wrote:
> >>>>>>>> On 02/18/2013 09:47 AM, Neil Horman wrote:
> >>>>>>>>> On Fri, Feb 15, 2013 at 05:57:46PM -0500, Paul Gortmaker wrote:
> >>>>>>>>>> From: Ying Xue <ying.xue@windriver.com>
> >>>> <snip>
> >>>
> >>>>>> 	
> >>>>>> There are two reasons for this. 
> >>>>>> The first one due to the message oriented nature of the flow control for 
> >>>>>> connections. Max message size is 65k, and max number of unacked messages 
> >>>>>> (at socket level, that is) before the sending process will take a break 
> >>>>>> is 1024. 
> >>>>>> So, simple maths gives that we must allow for 64MB + sk_overhead to guarantee 
> >>>>>> that a connection never is broken because of receiver overload. Contrary to TCP,
> >>>>> Note, this is false, due to the fact that, it presumes that the sender will
> >>>>> honor the congestion window.  Granted, that would be a sender violation, but its
> >>>>> still possible for packets to get lost due to receiver overrun.  
> >>>>
> >>>> The reason for this high limit is exactly to guard against crazy or malevolent 
> >>>> senders. If they respect their send window they will never hit this limit on
> >>>> connections.
> >>>>
> >>> Nope, You don't get to have it both ways - If a sender is malevolent or crazy,
> >>> what makes you think it will respect its send window?
> >>
> >> Nothing. That is why we need this extra security measure that this limit provides.
> >> The normal senders will never hit it, the crazy ones will, and have their 
> >> connections broken as a consequence. 
> >> Sorry I didn't express this clearly enough.
> > This isn't a security measure.  If a sender is well
> > behaved, then as you say, they won't violate their send window, and will
> > ostensibly behave properly (regardless of what limit you set on sk_rcvbuf, be it
> > the large one you currently employ, or something bigger or smaller).  If they
> > are malicious, then they will hit the limit, and they won't care (because
> > they're malicious).  They may have their connections broken, but so what?  Its the
> > receiver that needs to be able to protect itself.  The static limit you set using
> > this implementation is likely fine for many systems that have sufficient memory,
> > but consider a system that is memory constrained. 
> 
> The default limit is insanely high of course, but until we have introduced byte 
> oriented flow control this is what we have to deal with, for reasons I explained
> earlier.
> 
> If anybody want to turn it down, it will probably work well in most cases.
> The risk of having connections broken rises from 0 to some low percentage. 
> If somebody decides to do this, it is probably because he can accept
> that risk, or because he knows the apps he is running are nice, e.g. never send 
> out streams of 64k messages the way I described as a worst-case scenario.
> 
> > If a user administratively
> > tunes down sk_rcvbuf to avoid over-consumption of memory on a TIPC socket, that
> > condition will be ignored (or at least severly violated).  Thats bad, and may
> > lead to memory exhaustion despite having administratively taken action to fix
> > it.
> > 
> [...]
> 
> > Clearly sequential packet delivery implies the need to queue and postpone
> > application delivery of packets behind the reception of a lost packet in
> > sequence if it is dropped.  The problem I'm referring to here is that you seem
> > to have built TIPC around the notion of a single sequence namespace per system,
> > rather than one per socket.  
> 
> This is the way TIPC and other link-oriented protocols, e.g. LINX, are designed, 
> and they have this well-known flip-side. They were never intended to become 
> another TCP.
> Many users accept this, and value that the advantages you get from this design 
> more than outweigh the disadvantages. If they don't, then they should use TCP 
> or SCTP instead.
> 
> Anyway the design doesn't by necessity mean that we are bound to violate the 
> system limits; I think we have established that now.
> 
Agreed, you're not bound to deterministically violate the system limits - my
only request is that you honor them should you reach them.

> >> I could even show that your proposal would cause almost immediate
> >> deadlock, due to the order incoming and outgoing data paths are grabbing 
> >> the locks. But I would rather drop this part of the discussion; we can 
> >> achieve what we want anyway, with much simpler means. See below.
> >>
> > Perhaps you could, but if you were to deomonstrate how lowering your recieve
> > buffer limit (or even just honoring whatever is set), results in a deadlock
> > (ostensibly within the TIPC protocol code), how do you justify that as a reason
> > why you should be allowed to simply violate your set socket limits, rather than
> > recognizing the deadlock as a coding bug that needs to be fixed?  If you like,
> > we can begin a separate thread on that subject and look into fixing the issue.
> 
> I wouldn't call it a bug, because it doesn't cause deadlock in the current code,
> but it is clearly a design that can be improved.
I don't understand this - Above you said you could demonstrate how my proposal
(which was to drop packets when they surpassed the sk_rcvbuf limit), would cause
deadlock - if that happens, you have a locking bug.  If the only reason this
does not happen currently is because you allow for a large overrun of your
set sk_rcvbuf, then ostensibly a lockup can still be triggered if you have a
misbehaving sender that is willing to send frames past its congestion window.
So I think the root question here is: Does the code currently deadlock if you
drop frames in the receive path?  If not, then we should be ok, regardless of
what the rcvbuf value is set to.  If so, then we have a bug that needs fixing.

> We do have plans and prototypes ready to greatly simplify the locking structure, 
> e.g. by getting rid of the port lock and replace most of the other ones with 
> RCU-locks.
> There are however a few other changes we need to get in place first, notably to
> remove the remnants of the native interface, to make that possible. Stay tuned.
> 
Okey dokey.

> >>
> > As I noted above, as long as there is a method to change the administrative
> > default, thats fine.
> > 
> >> 2: Datagram messages are checked against fractions of this value, according to
> >>    their importance priority. E.g. LOW->sk_rcvbuf/16,  MEDIUM->sk_rcvbuf/8
> >>    HIGH->sk_rcvbuf/4 and CRITICAL->sk_rcvbuf/2.
> >>
> > Yes, this is what I proposed in my initial email.
> > 
> >> 3: In the unlikely event that anybody wants to change these limits, he can change
> >>    sk_rcvbuf via setsockopt(SOL_SOCK) either by first changing
> >>    /proc/sys/net/core/rmem_max as you suggest, or via a dedicated setsockopt(SOL_TIPC).
> >>    The latter option would have the advantage that it could enforce a lower limit of
> >>    skr_rcvbuf of 64MB, something that would be unthinkable with SOL_SOCK, because it 
> >>    would obviously affect other protocols.
> > Theres really no need for a private TIPC socket option here.  You do this at the
> > socket level, and if you want to set it higher than rmem_max, you adjust
> > rmem_max first.  Its just the way the system works.  Every other protocol
> > conforms to it, theres no reason TIPC shouldn't also.
> >>
> >> What do you think?
> >>
> > Yes, this is for the most part, good.
> 
> Happy to hear that. So we'll go ahead and make this change.
> 
> Thank you for your feedback.
Sounds good, thank you!
Neil

> ///jon
> 
> > Thanks
> > Neil
> >> ///jon
> >>
> >> If you set:
> >>>
> >>> /proc/sys/net/core/rmem_default
> >>
> >> But this will 
> >>>
> >>> to the value that you want all your sockets to have, any socket that gets
> >>> initalized with sock_init_data will inherit that value.  Note that, when doing
> >>> so, you may also have to set:
> >>>
> >>>
> >>>
> >>> As you can't adminstratively set your default socket rcvbuf value to something
> >>> larger than the maximum allowed value without raising the maximum allowed value
> >>> first.
> >>>
> >>> Then all you have to do is make sure those values are set during boot up, and for
> >>> users, it will appear as though nothing has changed.
> >>>
> >>> Neil
> >>>
> >>>>
> >>
> >>
> 
> 
