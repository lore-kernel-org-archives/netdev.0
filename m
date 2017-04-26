From: Michael Richardson <mcr-SWp7JaYWvAQV+D8aMU/kSg@public.gmane.org>
Subject: Re: bluetooth 6lowpan interfaces are not virtual anymore
Date: Wed, 26 Apr 2017 11:05:52 -0400
Message-ID: <1193.1493219152@dooku.sandelman.ca>
References: <2d178eb8-3fbc-3385-6e0c-fa9941713959@pengutronix.de> <CABBYNZLqTvd5cnG4fKJgPKJGvS6hsk8vOM+7NQ_RhLJ-WOszmg@mail.gmail.com> <f3c04860-651e-c9f3-e7ab-db609d105436@pengutronix.de> <CABBYNZJqChBfB4jNCN3edmKSfhNd-haTKOjeYy1toK-Mn=qzoA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Jukka Rissanen <jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
        "linux-wpan\@vger.kernel.org" <linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Bluetooth <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Luiz Augusto von Dentz <luiz.dentz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-reply-to: <CABBYNZJqChBfB4jNCN3edmKSfhNd-haTKOjeYy1toK-Mn=qzoA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--=-=-=
Content-Type: text/plain


I said that BT people hadn't replied, but it was next in my inbox :-)

Luiz Augusto von Dentz <luiz.dentz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
    >> At least if you want to try to make a more efficient qdisc handling,
    >> means dropping skb's in queue when userspace sends too much. You will
    >> change it back, control two queues seems to be difficult.

    > It is wrong only if you look at 6LoWPAN interface as being owned by
    > 6lowpan modules, but it doesn't, in fact it won't anything by itself so
    > it basically acts as a library to that perform 6LoWPAN operation on the
    > packet level, thus why it is possible to switch from virtual to real
    > interface. Also in terms of 15.4, the 6LoWPAN interfaces you depicted
    > above is also no controlled by 6LoWPAN itself, in fact it seeems to
    > represent links in 15.4, and I also assume these links may not use
    > 6LoWPAN.

At present I do not think we support any 15.4 links which are not 6lowpan in the Kernel.
Perhaps a userspace can open the device in raw mode and do stuff with it
directly.  Do such users exist right now?

    >> This queue should have the same meaning like our queue in IEEE
    >> 802.15.4 interface which you mentioned above.  At this point, we have
    >> no difference. There exists already a queue for your real transeiver
    >> hardware.

    > The queue here is per channel, btw the queue size is not decided by us
    > it is the remote side that provides the tx credits so to some extend
    > the tx_queue is actually the remote queue in case of CoC. When testing
    > this it was quite clear this does not work in practice, with IPv6 at
    > least, because the remote side may not have enough credits for a single
    > packet (MPS * tx_credits < MTU) which means without proper queueing
    > support we would be dropping every packet.

Would a longer amortization interval help this?
It seems that if there isn't bandwidth to send the packet, that userspace has
to learn about this fact...

    >> At least, having a queue and don't put anything anymore into the queue
    >> when "tx credits" is at zero (because queue is full). _Is_ a kind of
    >> qdisc handling.

    > The tx_credits operate at L2CAP segment level (MPS), so it is at a
    > completely different level, there are no guarantees the credits will
    > attend to a single IP packet.

That seems like a problem.
I think that we need to either send the entire packet, or none.
Spreading the credits across two packets would just make the system stutter,
as an upper layer retransmits packets that were half-sent, but then delayed.

Is there someway we can wait, at the IP packet queue level, until there are
sufficient credits to send all the fragments?  That way, the IP qdisc layer
can decide to abort(drop,defer) an IP packet from the queue in favour of a more
important packet.

--
]               Never tell me the odds!                 | ipv6 mesh networks [
]   Michael Richardson, Sandelman Software Works        | network architect  [
]     mcr-SWp7JaYWvAQV+D8aMU/kSg@public.gmane.org  http://www.sandelman.ca/        |   ruby on rails    [


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJZALdQAAoJEJVM4Vb9/EKQkngH/2anNuQZEDvLZHuQ4QvoL6YH
vK+lZujnd0FcbIu8mCKiO3rWJFZCr2EXju7k0cehMDDKf/v5NwiPpKcxeBbgE9K/
9/34yn3g5Hua49NehmzwcBIAmSAljpr19Ijr37mbi37RUHT4JJ/15dSJtrJ8Hb+y
SPZXGZFC85TzpMpC9gYLcb/EBsxhe8XWrpjOdn3TlO8Hk9QA85mfd4JwWy/q7+v7
8W9WHIuGzdeigZ7ytse8oynrW1BRIR8SjxqGC57hIpfaJsPJbdn+FUoXvXEiw8f1
3yLjtQfVafTLygpQdFNEKIvhgaLkh/jZyJUNMvGx3zMywPKH0w4QQ3ERg+gAWRg=
=+mov
-----END PGP SIGNATURE-----
--=-=-=--
