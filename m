From: chas williams <chas@cmf.nrl.navy.mil>
Subject: Re: [RFC] add rtnl semaphore to linux-atm
Date: Sun, 05 Oct 2003 08:52:58 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310051252.h95CqvkT022363@ginger.cmf.nrl.navy.mil>
References: <20031004194242.GC94203@gaz.sfgoth.com>
Reply-To: chas3@users.sourceforge.net
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitchell Blank Jr <mitch@sfgoth.com>
In-reply-to: Your message of "Sat, 04 Oct 2003 12:42:42 PDT."
             <20031004194242.GC94203@gaz.sfgoth.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20031004194242.GC94203@gaz.sfgoth.com>,Mitchell Blank Jr writes:
>Agreed.  I'm not sure if it's a giant win (since atm devices are pretty
>unique) but you seem pretty gung-ho about converting it so I'll trust
>you on it.

well if you ignore the sysfs and notifier handling provided by netdevice
and rtnetlink then no you dont really gain anything.  but i can see
a use for both of these things.  like to watching the carrier status
of an atm card.

>Well that might be true in the tree.  I think as more DSL adpaters are
>supported this will change.  The atm_dev->open() is really the only sane
>place currently to kick-off DSL negotiation (so the link is brought up
>when pppd or whatever is started)

i am not sure the negotiation should be handled by the kernel.
we will cross this bridge when we get there.  i dont see a
rush of people trying to add dsl drivers.  in fact, the
community seems to be pretty stingy with documentation about
the dsl hardware.

>> people who use ATM_ITF_ANY are going to pay a penalty
>Exactly - its a userspace problem.

so the idea is to fix it minimally.  people who use it should be
encouraged to change.  i would either get rid of completely or
make it work as before.  not change the way it works.

>I can't speak for all the cards but at least lanai.c has to sleep in
>->close() due to hardware issues.  Each VCC has its own cell buffers
>allocated which the card DMAs into.  When you close a vcc you need to
>wait for an internal RX queue to drain before you can safely free the
>buffer or you might end up scribbling on random memory.

right.  the he has the same problem.  however, you should be sleeping
in close.  the vcc/sk should have a count of the outstanding skb's (i.e.
loaned to the card).  the he sends an interrupt when its done with
a skb so you drop the refcount on the vcc/sk.  when this reaches 
0 the vcc/sk they go away and you dont have a problem.  no sleeping
in the vcc->close() since the removal of all outstanding skb's would
be handled asychronously.  currently this is impossible since the 
skb's coming in to the atm card's are typically owned by other layer.
(which sort of explains vcc->pop()).

>  2. Given the rather spotty history of ATM drivers and SMP I'd rather
>     keep the driver API as safe as possible.  Basically the driver
>     should only have to worry about locking when dealing with the
>     rx/tx paths (and there are still lots of problems there I think)
>     Everything else can be safely serialized by the ATM layer

i dont believe any of the smp problems have come from open/close/change_qos.
almost all smp problems can be traced to a lack of locking on the 
appropriate data structures and the improper handling of skb's in the
tx/rx paths.  (and YOU CANT SLEEP IN SEND!)  smp actually seems to be
pretty stable now (however we do have a local 2.4 tree that is more
2.6 as far as atm).  2-way, 4-way, 128-way (this one has 4 adapters
with a preliminary version of load-balancing).  these hosts are atm only.

>Unfortunately the flag is currently managed by the driver instead of the
>ATM layer.  If you're willing to strip out all of the ATM_VF_* use inside
>of the drivers then yes we can use that flag.

i believe that was the plan.

>This is just a matter of adding an efficient API for searching for vpi/vci's
>(as we recently discussed on l-a-g)  If that was done then we could get rid
>of the duplicated data strucutres that exist in most of the drivers (and
>get rid of a whole class of races in the rx paths)

well the linear seach is already fairly efficient for most people since
most people dont have more than a handful of vcc's open at a time.
my machine is pure atm and typically i only have about 12 vcc's open
at a time.

>I don't think that's the case at all - you could safely remove the vcc from
>the list at ->close time (but not free its memory until the last reference
>disappears)  Then an ->open would see the vpi/vci as free immediately (which
>should be safe)

not sure about this.  the fore200e seems to have a problem with
reopening on a vcc while there still might be outstanding skb's on a
vcc from a previos open/close.
