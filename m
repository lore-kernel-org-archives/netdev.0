From: jamal <hadi@cyberus.ca>
Subject: Re: Patch: Device operative state notification against 2.5.7
Date: Sun, 7 Apr 2002 16:16:59 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0204071538220.12041-100000@shell.cyberus.ca>
References: <3CACB9BC.4D585C25@isg.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
To: Stefan Rompf <srompf@isg.de>
In-Reply-To: <3CACB9BC.4D585C25@isg.de>
List-Id: netdev.vger.kernel.org


Stefan,

On Thu, 4 Apr 2002, Stefan Rompf wrote:

> Hi Jamal,
>
> > I think we should use SNMPs view of the world. RFC2863 still hasnt
> > been obsoleted, AFAIK.
> > Look at sections 3.1.12-14. There is a correlation between
> > admin/IFF_UP and oper/IFF_RUNNING.
>
> Agreed. If we want to be that specific, I'd prefer to go even further
> than the SNMP specification:
>
> -IFOP_UP
>  Interface is operational up.
> -IFOP_TESTING
>  Interface is just being tested
> -IFOP_UNKNOWN
>  Driver is not capable of testing the interface status
> -IFOP_DORMANT
>  Interface is sleeping, lower layer status may be unknown.

If i understand you correctly, this would still be something along the
lines of dial on demand PPP. It stays "dormant" until it receives outgoing
packet which initiates connection establishment activity. The type of
activity may vary ...
Cant remember what diald does, but if i am not mistaken it actually kills
the device and creates a new one everytime it detects activity

> -IFOP_DOWN_NOTPRESENT
>  Interface does not exist. This can be f.e. an USB device that has just
> been unplugged

What do you plan to do with this? eg, the name and stats for example wont
change. What do the USB people think?

> -IFOP_DOWN_LOWERLAYER
>  Lower layer is down, f.e. ethernet interfaces below a VLAN
> -IFOP_DOWN_NOCARRIER
>  Interface link beat/framing is missing (current netif_carrier_o* maps
> here)

Good naming convention for the above two.

> -IFOP_DOWN_KEEPALIVE
>  Another form of keepalive is missing

Not clear on this one.

> -IFOP_DOWN_TX_TIMEOUT
>  Transmit timeout signalled by scheduler

I take it you want to use this for informational purposes
i.e someone has to solicit for this information
(Note, it is legal to have transmit path timeout but receive
path just fine)

> Multiple down reasons can be active for an interface.
>

this could be tricky mostly because some of the DOWN values are
actually different states (in the state machine)
eg IFOP_DOWN_NOTPRESENT --> IFOP_DOWN_NOCARRIER when the USB hardware
is inserted
Also the only time IFOP_DOWN_LOWERLAYER makes sense is when the top
stacked device is actually admin up (but none of the lower devices are
operationally UP)

Maybe you mean there should be something generally refered to as IFOP_DOWN
and the reason would be one of IFOP_DOWN_* ?

> These states can be represented by atomic data types in the netdevice
> structure so that they can safely be set and queried from everywhere
> within the kernel. If IFOP_UP, IFOP_UNKNOWN or IFOP_DORMANT is set,
> IFF_RUNNING will be visible. If course it must be possible to get the
> detailed states from user mode and may be write to IFOP_DORMANT.
>

The only useful state transitions are to/from IFOP_DOWN_NOCARRIER
in my opinion. What do you think?
In which case you only set IFF_RUNNING when you transition from
IFOP_DOWN_NOCARRIER -> IFOP_UP and you clear it when
IFOP_UP -> IFOP_DOWN_NOCARRIER
Things like IFOP_DORMANT can probably be set only by the driver
and still retrieved via netlink or even ioctl when they are solicited
for. By default you only announce via netlink transitions to/from
IFOP_DOWN_NOCARRIER.

> Userspace notification via netlink should remain optional. Does it make
> sense to queue up events or is it enough to report the last state after
> a bunch of changes has happened? For me, the second would be ok,
> especially as all drivers that can do link beat detection now utilise a
> timer for this purpose and will lose too rapid changes anyway.

I think the transitions to/from IFOP_DOWN_NOCARRIER would be useful
for in kernel FIB or ARP updates as well; so maybe making these two
optional would not be a wise decision. And if you send within the kernel
then by default user space also gets it.

To avoid oscillations you only send the latest request _if it is still
valid_, otherwise dont send any. Your code structuring should be built
for this.
Also (this might be tricky to do), once you start flapping
like that, it would also make sense to ratelimit (in exponential manner)
the amount of netlink messages you send to announce carrier on/off.

One other thing you didnt talk about is the relation ship with IFF_UP;
essentially, !IFF_UP would also mean !IFF_RUNNING and generally
one of the DOWN states (NOCARRIER?).
when someone ifconfigs up, that should also invoke the device operational
discovery activity (eg via device open()), so no need to worry there.

Apologies for making life difficult Stefan; we need to get it right and we
have that opportunity ;->

cheers,
jamal
