From: Luiz Augusto von Dentz <luiz.dentz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: bluetooth 6lowpan interfaces are not virtual anymore
Date: Tue, 18 Apr 2017 13:43:42 +0300
Message-ID: <CABBYNZLqTvd5cnG4fKJgPKJGvS6hsk8vOM+7NQ_RhLJ-WOszmg@mail.gmail.com>
References: <2d178eb8-3fbc-3385-6e0c-fa9941713959@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Jukka Rissanen <jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
        "linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Bluetooth <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <2d178eb8-3fbc-3385-6e0c-fa9941713959-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Alex,

On Mon, Apr 17, 2017 at 8:56 PM, Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org> wrote:
> Hi,
>
> bluetooth-next contains patches which introduces a queue for bluetooth
> 6LoWPAN interfaces. [0]
>
> At first, the current behaviour is now that 802.15.4 6LoWPAN interfaces
> are virtual and bluetooth 6LoWPAN interfaces are not virtual anymore.
> To have a different handling in both subsystems is _definitely_ wrong.

Well 15.4 and Bluetooth have very different handling, iirc in 15.4 you
do have a real interface which has, in fact, queueing support:

net/mac802154/iface.c:ieee802154_if_setup:
dev->tx_queue_len = 300;

> What does the 6LoWPAN interface?
>
> It will do a protocol change (an adaptation, because 6LoWPAN should
> provide the same functionality as IPv6) from IPv6 to 6LoWPAN (tx) and
> vice versa for (rx). In my opinion this should be handled as a virtual
> interface and not as an interface with a queue.

Then we need a real netif for Bluetooth as well, one that does
queueing since introducing for l2cap_chan makes no sense when most of
time the userspace has a socket which does its own queueing. Btw, I
have the opinion that doing a second interface just to make Bluetooth
behave like 15.4 is very wasteful since we don't have any other
network support except for bnep, which in fact does the same thing
regarding queueing.

> What makes a queue on 6LoWPAN interfaces?
>
> It will queue IPv6 packets which waits for it adaptation (the protocol
> change) with some additional qdisc handling.
> If finally the xmit_do callback will occur it will replace IPv6 header
> with 6LoWPAN, etc. After that it should be queued into some queue on
> link layer side which should be do the transmit finally.

In case of Bluetooth it does the Link Layer using L2CAP, which is not
exactly at Link Layer, in fact it is one of the major problems of
having this in Kernel space since it is similar of doing IP over TCP
tunnel.

> Why I think bluetooth introduced a queue handling on 6LoWPAN interfaces?
>
> Because I think they don't like their own *qdisc* handling on their link
> layer interface. I write *qdisc* here because, they have no net_devices
> and use some kind of own qdisc handling.

No we don't, and except we do change the whole architecture of
Bluetooth to work as a net_device I don't think we can have a similar
design as 15.4. Anyway Bluetooth is not really designed to carry IP,
the L2CAP and other profiles above are mostly a Bluetooth thing so
having a net_device would not buy us much more than queueing for bnep
and ipsp.

> My question: is this correct?
>
> How to fix that (In my opinion):
>
> So commit [0] says something "out of credits" that's what I think it's
> the *qdisc* handling. If you cannot queue anymore -> you need to drop
> it. If you don't like how the current behaviour is, you need to change
> your *qdisc* handling on your link layer interface. Introducing queue at
> 6LoWPAN interfaces will introduce "buffer bloating".

That is not what the code comments says, eg. netif_stop_queue:

 * Stop upper layers calling the device hard_start_xmit routine.
 * Used for flow control when transmit resources are unavailable.

The fact 15.4, and bnep, uses these APIs makes me believe this is the
proper way of using qdisc handling, the only difference here is at
what level we would be using them.

> ---
>
> I don't care what bluetooth does with the 6LoWPAN interface. If bluetooth
> people wants such behaviour, then I am okay with that.
>
> I will bookmark this mail for the time when somebody reverts it to a
> virtual interface again. I think somebody will change it again, or maybe
> somebody will argument why we need a queue here.

>From what I could grasp from the code except if 6LoWPAN start creating
its own interface, which it doesn't currently, it should never assume
any specific behavior for an interface. 6LoWPAN right now only have
helper functions which the interface code call on TX/RX, and by
looking at code under 15.4 the only thing we would be doing is to set
skb->dev = wdev; (wdev being the real device) as Bluetooth don't use
6lowpan fragmentation.

Btw, another big different in terms of design that it seems 15.4 does
create interfaces to each and every link, in Bluetooth the interface
is per adapter so it is in fact multi-link, I guess in practice 15.4
shall only have one 6lowpan link since it is connected to mesh, but in
Bluetooth we may have more than one Link and I don't think it would be
a good idea to have each of these links as a different interface,
especially not with the same mac address as it seems to be what 15.4
code is doing:

/* Set the lowpan hardware address to the wpan hardware address. */
memcpy(ldev->dev_addr, wdev->dev_addr, IEEE802154_ADDR_LEN);

So at least with IPSP/RFC-7668 the topology is completely different
from what we can see in 15.4, it may happen that this changes with
upcoming changes to Bluetooth, adding yet another topology that we
will need to support. Personally I wouldn't mind if 15.4 and Bluetooth
had more in common, at least at 6lowpan level, so we wouldn't have the
need to create separated modules just to deal with their differences,
but in reality, these technologies are competing for the same market
so I don't think it will happen, unfortunately.

> - Alex
>
> [0] https://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.git/commit/?id=814f1b243d2c63928f6aa72d66bec0e5fae2f4a9



-- 
Luiz Augusto von Dentz
