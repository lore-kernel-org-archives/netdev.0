From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: Re: [RFC] add rtnl semaphore to linux-atm
Date: Sat, 4 Oct 2003 12:42:42 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031004194242.GC94203@gaz.sfgoth.com>
References: <20031004065925.GB94203@gaz.sfgoth.com> <200310041250.h94Co0kT017402@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chas3@users.sourceforge.net
Content-Disposition: inline
In-Reply-To: <200310041250.h94Co0kT017402@ginger.cmf.nrl.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

chas williams wrote:
> atm_dev will become a netdevice in the future.  there is no good reason
> it shouldnt.

Agreed.  I'm not sure if it's a giant win (since atm devices are pretty
unique) but you seem pretty gung-ho about converting it so I'll trust
you on it.

> there are
> (currently) no atm devices with slow open routines so please dont bother
> with hypothetical devices.

Well that might be true in the tree.  I think as more DSL adpaters are
supported this will change.  The atm_dev->open() is really the only sane
place currently to kick-off DSL negotiation (so the link is brought up
when pppd or whatever is started)

> people who use ATM_ITF_ANY are going to pay
> a penalty.  that's just the way it is.  its a bit of a bad idea really.
> what if you want something like round-robin instead of in-order?

Exactly - its a userspace problem.

> i can see why you might want to sleep in close() -- like waiting
> for all the skb's to transmit/return, but this is only because vcc's dont
> hold a per skb reference count and dont know when its safe to go away

I can't speak for all the cards but at least lanai.c has to sleep in
->close() due to hardware issues.  Each VCC has its own cell buffers
allocated which the card DMAs into.  When you close a vcc you need to
wait for an internal RX queue to drain before you can safely free the
buffer or you might end up scribbling on random memory.

The only alternative I can think of would be to have the buffer free
kicked off later from a tasklet or someting but that could get pretty
gross.

Plus as I mentioned DSL adapters have good reason to sleep in open/close.
Since we require VCCs to be opened and closed from process context this
isn't a problem (as long as we do the locking correctly)

> serialization for open/change_qos/close should be handled in the
> driver (assuming we are discussing serialization across different
> vcc's and not a single vcc -- a single vcc case is already
> handled via lock_sock).  if your driver h/w doesnt need this, then 
> it shouldnt be thrust upon you.

Its a matter of opinion.  My feelings are:

  1. Serializing these operations through a semaphore shouldn't affect
     performance one bit - even in conditions where open/close happen
     relatively frequently (say, LANE) there would still be negligable
     contention on the semaphore

  2. Given the rather spotty history of ATM drivers and SMP I'd rather
     keep the driver API as safe as possible.  Basically the driver
     should only have to worry about locking when dealing with the
     rx/tx paths (and there are still lots of problems there I think)
     Everything else can be safely serialized by the ATM layer

> vcc_sklist holds a list of sockets active or otherwise.  the atm layer
> already has flags (ATM_VF_READY) that indicate if a vcc is ready to recv.

Unfortunately the flag is currently managed by the driver instead of the
ATM layer.  If you're willing to strip out all of the ATM_VF_* use inside
of the drivers then yes we can use that flag.

> it is unfortunate that the bh's of most drivers dont bother to check this
> bit

This is just a matter of adding an efficient API for searching for vpi/vci's
(as we recently discussed on l-a-g)  If that was done then we could get rid
of the duplicated data strucutres that exist in most of the drivers (and
get rid of a whole class of races in the rx paths)

Then the ATM layer can easily handle checking the ATM_VF_READY flag.

> in the future (and this
> isnt a hypothetical driver) vcc's will probably live slightly longer than
> the close routine (those outstanding skbs) and cant be removed from the
> vcc_sklist until every last reference is gone.  yes, this means that close
> could finish but you wouldnt be able to open the vpi/vci again right away.

I don't think that's the case at all - you could safely remove the vcc from
the list at ->close time (but not free its memory until the last reference
disappears)  Then an ->open would see the vpi/vci as free immediately (which
should be safe)

-Mitch
