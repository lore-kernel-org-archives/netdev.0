From: Stefan Rompf <srompf@isg.de>
Subject: Re: Patch: Device operative state notification against 2.5.7
Date: Mon, 01 Apr 2002 16:44:51 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <3CA87263.6FD1F1AF@isg.de>
References: <Pine.GSO.4.30.0203310941120.9704-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: jamal <hadi@cyberus.ca>
List-Id: netdev.vger.kernel.org

Hi Jamal,

first thanks for your long reply. I've moved the last part of your mail
to the front to answer on it first.

> If we were to follow the BSD or CISCOish view of the world, then
> removing a cable or death of allocated virtual circuit/tunnel would
> mean !IFF_RUNNING.

You've caught me, a lot of my networking experience involved cisco stuff
;-) Anyway, I thought the semantic decision has already been made during
the development cycle from 2.2 to 2.4. In 2.4, IFF_RUNNING of the
in-kernel dev->flags it totally unused except for broken drivers. What
you see in fact as IFF_RUNNING when querying an interface from
userspace, is the LINK_STATE_NOCARRIER bit. Look at
net/core/dev.c::dev_ifsioc(), case SIOCGIFFLAGS or the rtnetlink
equivalent. Consequently, dev_change_flags() does not touch the
IFF_RUNNING flag (part of IFF_VOLATILE).

> NO_CARRIER | IFF_RUNNING | meaning
> -----------|-------------|------------------------------------
> !set       | !set        | There is carrier, but no cable
>            |             | no sense for ethernet; but may be useful
>            |             | for PPP (for example line protocol is not up)

If LPCP in a PPP interface is not open and the interface is not waiting
for dial on demand, I'd consider it admin down, !IFF_UP. May be the term
"carrier" in the flag and functions is simply misnamed and we should
have a three states instead. If the interface is admin up, it's
operational state can be:

-up
 The driver is sure that it can transmit and receive packets over the
line. Depending on the driver, that can be HDLC framing, HDLC
keepalives, ethernet carrier, generically said some kind of heartbeat.
This state does not include any protocols that might be used over the
line, just that layer 1 is up -> IFF_RUNNING
-down
 The driver cannot transmit packets. This may be the inverse of one of
the conditions above, but can also something like a stalled ethernet
tranceiver (adding a fourth internal state) -> !IFF_RUNNING
-unknown
 Some dial on demand interface that is currently not bound to a physical
or logical line, mostly your truth table entry quoted above. May be
these interfaces should simply have an IFF_UNBOUND flag that is set in
this mode

> Think of either a bonding, VLANs

For these, operational state should follow the underlying interface(s).

> or extreme case where PPP
> circuit is up for one protocol but not for another.

That's a completely different case. If negotiation for a specific
protocol fails, the interface is still admin & operational up, but
cannot have a valid address for the protocol in question. In this case,
it is the users' decision if it makes sense to keep the interface admin
up.

> > Is it possible to send (netlink) messages from a softirq?
> 
> Why not?

You are right, but my thread actually calls netdev_state_change(), and
the event devinet.c::inetdev_event() requires holding the RTNL
semaphore. As I want in kernel notification, so that f.e. the VLAN
driver can react on state changes of underlying devices, some kind of
process context is needed.

> In regards to walking the whole dev list:
> There is no point in polling when there is no work to be done (and
> therefore no need for you to walk all the devices which have not shown
> interest). A simple "registration" by devices raising or lowering carrier
> would be the best way to do it (via netif_carrier_on/ff). The first
> device on the list also wakes up the thread (or as you do right now
> always wakes it up).

I'll have a look if I can implement such a list. There are three reasons
why I haven't done it in the current version:

-netif_carrier_on()/_off() seems to be designed to be called from
anywhere, interrupts, timers, processes, so I didn't want to add too
much locking and memory allocation in this place. Also I have to admit
that I'm not yet long enough in kernel programming to know which kind of
memory I may safely allocate for list elements from an interrupt ;-)
-When the thread goes through this list of events, it has either to
check for every element if the device still exists (currently only
possible by traversing the device list so that the thread would actually
get _less_ efficient) or the event list has to be consulted on interface
removal
-A runaway driver must be kept from allocating *lots* of kernel memory
by calling netif_carrier_on()/_off() in a tight loop

And yes, I was lazy and didn't want to overoptimize stuff that lies
dormant nearly all the time ;-)

> Note, you want to report both transitions and you also want to make
> sure its not just simple noise.

A better solution should forward an op down immediatly and delay op up
by a defined time to check if no other op down arrives, but this would
have to be done before allocating list elements. Should be possible with
timers and extending the device structure to hold these elements... I'll
think about it.

Cheers, Stefan
