From: jamal <hadi@cyberus.ca>
Subject: Re: Patch: Device operative state notification against 2.5.7
Date: Mon, 1 Apr 2002 11:25:17 -0500 (EST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0204010948580.12505-100000@shell.cyberus.ca>
References: <3CA87263.6FD1F1AF@isg.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
To: Stefan Rompf <srompf@isg.de>
In-Reply-To: <3CA87263.6FD1F1AF@isg.de>
List-Id: netdev.vger.kernel.org



Stefan,

On Mon, 1 Apr 2002, Stefan Rompf wrote:

> Hi Jamal,
>
> first thanks for your long reply. I've moved the last part of your mail
> to the front to answer on it first.
>
> > If we were to follow the BSD or CISCOish view of the world, then
> > removing a cable or death of allocated virtual circuit/tunnel would
> > mean !IFF_RUNNING.
>
> You've caught me, a lot of my networking experience involved cisco stuff
> ;-) Anyway, I thought the semantic decision has already been made during
> the development cycle from 2.2 to 2.4. In 2.4, IFF_RUNNING of the
> in-kernel dev->flags it totally unused except for broken drivers. What
> you see in fact as IFF_RUNNING when querying an interface from
> userspace, is the LINK_STATE_NOCARRIER bit. Look at
> net/core/dev.c::dev_ifsioc(), case SIOCGIFFLAGS or the rtnetlink
> equivalent. Consequently, dev_change_flags() does not touch the
> IFF_RUNNING flag (part of IFF_VOLATILE).

Ok, I didnt know of this decision. In that case get rid of any calls
directly modifying IFF_RUNNING in the drivers and have them make calls to
netcarrier_*. LINK_STATE_NOCARRIER is also good enough to provide
synchronization/serialization issue i mentioned earlier

>
> > NO_CARRIER | IFF_RUNNING | meaning
> > -----------|-------------|------------------------------------
> > !set       | !set        | There is carrier, but no cable
> >            |             | no sense for ethernet; but may be useful
> >            |             | for PPP (for example line protocol is not up)
>
> If LPCP in a PPP interface is not open and the interface is not waiting
> for dial on demand, I'd consider it admin down, !IFF_UP.

I agree.
Lets forget this now that i know there was a call to use
LINK_STATE_NOCARRIER to reflect IFF_RUNNING.

> May be the term
> "carrier" in the flag and functions is simply misnamed and we should
> have a three states instead. If the interface is admin up, it's
> operational state can be:
>
> -up
>  The driver is sure that it can transmit and receive packets over the
> line. Depending on the driver, that can be HDLC framing, HDLC
> keepalives, ethernet carrier, generically said some kind of heartbeat.
> This state does not include any protocols that might be used over the
> line, just that layer 1 is up -> IFF_RUNNING
> -down
>  The driver cannot transmit packets. This may be the inverse of one of
> the conditions above, but can also something like a stalled ethernet
> tranceiver (adding a fourth internal state) -> !IFF_RUNNING
> -unknown
>  Some dial on demand interface that is currently not bound to a physical
> or logical line, mostly your truth table entry quoted above. May be
> these interfaces should simply have an IFF_UNBOUND flag that is set in
> this mode

I think we should use SNMPs view of the world. RFC2863 still hasnt
been obsoleted, AFAIK.
Look at sections 3.1.12-14. There is a correlation between
admin/IFF_UP and oper/IFF_RUNNING.

> > Think of either a bonding, VLANs
>
> For these, operational state should follow the underlying interface(s).
>
> > or extreme case where PPP
> > circuit is up for one protocol but not for another.
>
> That's a completely different case. If negotiation for a specific
> protocol fails, the interface is still admin & operational up, but
> cannot have a valid address for the protocol in question. In this case,
> it is the users' decision if it makes sense to keep the interface admin
> up.
>

RFC 2863 covers these overlays well actually, look at it and then lets
review again.

> > > Is it possible to send (netlink) messages from a softirq?
> >
> > Why not?
>
> You are right, but my thread actually calls netdev_state_change(), and
> the event devinet.c::inetdev_event() requires holding the RTNL
> semaphore. As I want in kernel notification, so that f.e. the VLAN
> driver can react on state changes of underlying devices, some kind of
> process context is needed.

Not sure if this is true. But like i said no big deal right now ..

>
> > In regards to walking the whole dev list:
> > There is no point in polling when there is no work to be done (and
> > therefore no need for you to walk all the devices which have not shown
> > interest). A simple "registration" by devices raising or lowering carrier
> > would be the best way to do it (via netif_carrier_on/ff). The first
> > device on the list also wakes up the thread (or as you do right now
> > always wakes it up).
>
> I'll have a look if I can implement such a list. There are three reasons
> why I haven't done it in the current version:
>
> -netif_carrier_on()/_off() seems to be designed to be called from
> anywhere, interrupts, timers, processes, so I didn't want to add too
> much locking and memory allocation in this place. Also I have to admit
> that I'm not yet long enough in kernel programming to know which kind of
> memory I may safely allocate for list elements from an interrupt ;-)

Which is why it is a good thing. You can serialize..

> -When the thread goes through this list of events, it has either to
> check for every element if the device still exists (currently only
> possible by traversing the device list so that the thread would actually
> get _less_ efficient) or the event list has to be consulted on interface
> removal

Checking device still exists has to be done always.

> -A runaway driver must be kept from allocating *lots* of kernel memory
> by calling netif_carrier_on()/_off() in a tight loop
>
> And yes, I was lazy and didn't want to overoptimize stuff that lies
> dormant nearly all the time ;-)

You might have misunderstood me. Lets defer this to later, first step is
semantics
A first step could be to get rid of the timer you have. Only wake up the
thread when necessary.
You can then look at the NAPI code for an example of registration
and the concept of not going through the whole list.

cheers,
jamal
