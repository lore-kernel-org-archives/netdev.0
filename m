From: Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: introduce IPV6_PKTINFO_L2 socket-option?
Date: Mon, 17 Oct 2016 10:33:46 +0200
Message-ID: <c789cfba-13af-dfe4-5b5d-af179fb43fb6@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Michael Richardson <mcr-SWp7JaYWvAQV+D8aMU/kSg@public.gmane.org>,
        Martin Gergeleit <martin.gergeleit-6wGqcYweBVc@public.gmane.org>,
        Linux Bluetooth <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Jukka Rissanen <jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
        "kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org" <kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Hi all,

I am currently writing some userspace UDP Software for 6LoWPAN
subsystem. It will use UDP IPv6 sockets, the 6LoWPAN adaptation will be
done at kernelspace.

My problem is currently the following:

I need per recvmsg(2) the used source link-layer address for the
incoming UDP packet which used a multicast destination address.

There is currently no solution to get such information. Michael
Richardson told about IPV6_RECVPKTINFO and then we thought about to
introduce an IPV6_PKTINFO_L2 to get such information.

If somebody know already a solution how to get L2 information from
userspace IPv6 SOCK_DGRAM socket, I would be happy if somebody told me
the solution. :-)

The idea about IPV6_PKTINFO_L2 is to put L2 information in there which
depends on netdev type (on 6LoWPAN it even depends on sub netdev type of
6LoWPAN netdev type - sub netdev type will represent the used link-layer).

Now, here comes some design question...

What we put into the IPV6_PKTINFO_L2 which is an attribute of the control
messages. The socket-option IPV6_PKTINFO_L2 will turn it on/off only
like all others.

If we only need it for recvmsg(2) then maybe we could simple offer the
mac-header - which maybe works on all skb's by accessing skb_mac_header
and skb->mac_len. (btw: on 6LoWPAN this is currently broken and I need
to fix it). It works only if all IPv6 capable subsystem sets these
attributes and don't overwrite the mac space with other data (that's the
bug we have in 6LoWPAN).

The point is... it's useful also for sendmsg. Example: 802.15.4 6LoWPAN
can use two type of mac address: short or extended. On sendmsg you could
say which one you prefer to use for the L2 source/destination address
information. I heard from Michael, this is necessary on some protocols
to prefer extended than short. Currently we use short if short is
available, because it will produce less payload - which is very fine as
default handling. But sometimes you must have control over that.

Another option to implement this is a flag for a neighbour in ndisc
cache, but this works for destination L2 address then and per-neighbour
and not per sendmsg(2), so all running processes for the interface will
be manipulated by that. I think this is not an good option.

What I am thinking of is to have the control message attribute defined
per netdev type (in case of 6LoWPAN even link-layer 6LoWPAN netdev type)
and each link-layer can add what they want to have there. E.g.

struct in6_pktinfo_l2_802154 {
        /* sendmsg and recvmsg */
        __u8    src[MAX_ADDR_LEN];
        __u8    dst[MAX_ADDR_LEN];

        /* recvmsg */
        __u8    lqi;
};

The lqi is here some 802.15.4 L2 information about link quality. Some
another idea to add there, makes only sense for recvmsg and need to be
some average if fragmentation was done there. If the link-layer doesn't
support such handling -EOPNOTSUPP for setting the socket-option on will
be returned.

The src and dst address could maybe the same on all link-layers and
that's why we could split this attribute maybe in two attributes for
control message:

struct in6_pktinfo_l2 {
        /* sendmsg and recvmsg */
        __u8    src[MAX_ADDR_LEN];
        __u8    dst[MAX_ADDR_LEN];
};

struct in6_pktinfo_l2_802154 {
        /* recvmsg */
        __u8    lqi;
};

and introduce some IPV6_PKTINFO_L2 and IPV6_PKTINFO_L2_802154_LQI socket
option to enable/disable these attributes. The addresses which will be
placed into src and dst depends on used link-layer which need to be
evaluated somehow before.

I currently must implement the getting of source l2 address information
and I will try to implement it. For sendmsg side I need to figure out
how to get the information from socket interface through 6LoWPAN
implementation - maybe adding new attribute in sk_buff? Don't know yet.

I also want some mainline solution and I don't know if this is the right
way to implement it to have an acceptable solution for mainline. That's
why I start this discussion and hope I get some new inputs here.

- Alex
