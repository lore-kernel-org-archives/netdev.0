From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: Re: [RFC] add rtnl semaphore to linux-atm
Date: Mon, 6 Oct 2003 02:03:04 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031006090304.GD4651@gaz.sfgoth.com>
References: <20031004194242.GC94203@gaz.sfgoth.com> <200310051252.h95CqvkT022363@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chas williams <chas@cmf.nrl.navy.mil>
Content-Disposition: inline
In-Reply-To: <200310051252.h95CqvkT022363@ginger.cmf.nrl.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

chas williams wrote:
> i am not sure the negotiation should be handled by the kernel.
> we will cross this bridge when we get there.  i dont see a
> rush of people trying to add dsl drivers.  in fact, the
> community seems to be pretty stingy with documentation about
> the dsl hardware.

Yeah, I've been trying to get that resolved but so far noone is
anwering my emails.  There are two DSL drivers in some state of
completion that could be merged if the companies involved to
just release them.

> >> people who use ATM_ITF_ANY are going to pay a penalty
> >Exactly - its a userspace problem.
> 
> so the idea is to fix it minimally.  people who use it should be
> encouraged to change.  i would either get rid of completely or
> make it work as before.  not change the way it works.

I don't think there are any current users that would be broken by
a "just pick the first interface" policy.  I just don't want to
entirely remove it in case someone is using '*.0.50' in their clip
configs or something.

There are no users inside the atm tools that need ATM_ITF_ANY.  Anyone
using it directly in a PVC address is already broken and non-determanistic
if they have more than one interface, so I'm not worried if the semantics
in that case are only 90% identical instead of 100%

> i dont believe any of the smp problems have come from open/close/change_qos.

I doubt many crashes happen there (in practice mostly those operations
will be serialized by userland - it's rare to have multiple threads
opening/closing vccs at once) but that doesn't mean that races aren't
hiding.  Again, there's zero performance implication to serializing
them so we might as well make the driver API a little more foolproof.

> well the linear seach is already fairly efficient for most people since
> most people dont have more than a handful of vcc's open at a time.

Yes, but the worst-case is unacceptable.  There are at least some people
who have used the code to terminate VCCs coming from DSL customers (a
project like that is actually what got me started with hacking on
linux-atm 5 years ago :-).  They could have hundreds of VCCs active at
once.

> >I don't think that's the case at all - you could safely remove the vcc from
> >the list at ->close time (but not free its memory until the last reference
> >disappears)  Then an ->open would see the vpi/vci as free immediately (which
> >should be safe)
> 
> not sure about this.  the fore200e seems to have a problem with
> reopening on a vcc while there still might be outstanding skb's on a
> vcc from a previos open/close.

Hmmmm... ok.  I really believe that we need to sleep in close until the
VCC is truly free.  If userland can't do a close followed immediately by
an open on the same vci then something is busted.

-Mitch
