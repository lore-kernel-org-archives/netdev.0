From: Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: bluetooth 6lowpan interfaces are not virtual anymore
Date: Wed, 19 Apr 2017 20:01:13 +0200
Message-ID: <11cf222a-0c1f-4136-091d-719ee68824e1@pengutronix.de>
References: <2d178eb8-3fbc-3385-6e0c-fa9941713959@pengutronix.de>
 <28530.1492534783@obiwan.sandelman.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Jukka Rissanen <jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
        Luiz Augusto von Dentz <luiz.dentz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Bluetooth <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Michael Richardson <mcr-SWp7JaYWvAQV+D8aMU/kSg@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <28530.1492534783-FKvY79KaN4jY2Mpo3neBCSwD8/FfD2ys@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Michael,

On 04/18/2017 06:59 PM, Michael Richardson wrote:
> 
> Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org> wrote:
>     > What does the 6LoWPAN interface?
> 
>     > It will do a protocol change (an adaptation, because 6LoWPAN should
>     > provide the same functionality as IPv6) from IPv6 to 6LoWPAN (tx) and
>     > vice versa for (rx). In my opinion this should be handled as a virtual
>     > interface and not as an interface with a queue.
> 
> I wonder if modeling all the 6lowpan work as a virtual interface is even
> the right abstraction anymore.  I think that it was certainly a good model at
> the time the interface was created, given no other clear thing to do.
> 
> We don't model IPv6 ND (or IPv4 ARP) or fragmentation in general as a
> virtual interface on top of a raw interface.
> 
> Really, it's a set of operations that happens on a packet.
> 802.15.4 is notable for it's current lack of an ethertype (IEEE is fixing
> that though), so you can't actually run different protocols on the
> same PANID.
> BT does have a variety of different protocols, and IPv6 is only one.
> 
> In a classic SVR4 STREAMS works, it would have been just another module.
> (No, I'm not a fan of *STREAMS* or of SVR4 in general,  although I liked
> some of the ideas).
> 

ok, I see you complain about "having a virtual on top of wpan
interface", or?

I wanted to talk at first about the queue handling which is introduced
when 6LoWPAN is not a virtual interface anymore. Or do you want to have
a queue in front of 6lowpan adaptation (see other mail reply with ASCII
graphics).

My definition of virtual interfaces:
 - Virtual interfaces: has no queue.
 - Non Virtual interfaces: has queue(s).

> At this time, things like PANID and channel are set on the wpanX interface.
> If they were set on the 6lowpan interface, such that one could (in theory,
> assuming the hardware could do it, which some can, and some can not) then
> one could have multiple 6lowpan interfaces on top of the same wpanX.
> Or one could run some non-IP protocol like pre-IP Zigbee on one PANID
> while one runs 6lowpan on another.  THEN, a virtual interface would make
> sense for the same reason VLAN interfaces make sense.
> 

We can change that you can run multiple interfaces on one PHY. Currently
we just allow one, because address filtering. Disable address filtering
-> we will loose ACK handling on hardware.

I can try to implement all stuff in software "for fun, maybe see what we
can do to handle ACK in software, etc" Then you can run multiple wpan
interfaces on different "source PANID". Then we need some additonal
parameter for creating 6lowpan interfaces in case of 802.15.4 to add a
destination PANID. Last one should not big deal, because this doesn't
require to turn address filtering off.

One question would be:
It's fine to have it as _per_ interface setting or do you want to have
that on sendmsg(2) level?

---

You complain also, maybe... because currently it's hard to deal with
configuration 6lowpan interfaces with 802.15.4 interfaces. Because you
need to have both down to change address filtering etc.

What we can do there is "make it easier" if wpan interface goes down,
then upper 6LoWPAN interface goes also down (we can do that). But here
is the question - a userspace programm can do the same job.

For setting channels/panid for 6lowpan interfaces -> we can make that
nl802154 will also accept net_device namens for 802.15.4 6lowpan
interfaces which makes changes to the "lower" wpan interface -> should
be possible.

Let me known if you like to have such solution, which should make it
just simpler to dealing with ifdown/ifup and changing interface naming
stuff.

Currently, we forbid much stuff - We can do some changes (tx parameters)
when interface is up, just need to besure we don't changes paramters
while transmit. But make everything at first forbidden and then allows
more will usally not break UAPI. :-)

- Alex
