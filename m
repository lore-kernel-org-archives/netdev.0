From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: Re: [PATCH 4/9] AF_UNIX: find the recipients for multicast messages
Date: Tue, 23 Nov 2010 17:47:01 +0000
Message-ID: <20101123174701.1b2f6f16@chocolatine.cbg.collabora.co.uk>
References: <20101122183447.124afce5@chocolatine.cbg.collabora.co.uk>
	<1290450982-17480-4-git-send-email-alban.crequy@collabora.co.uk>
	<20101122.110519.39205345.davem@davemloft.net>
	<20101123150315.4e67a139@chocolatine.cbg.collabora.co.uk>
	<1290528517.3046.91.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	gorcunov@openvz.org, adobriyan@gmail.com, lennart@poettering.net,
	kay.sievers@vrfy.org, ian.molton@collabora.co.uk,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([93.93.128.226]:47012 "EHLO
	bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755218Ab0KWRs6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Nov 2010 12:48:58 -0500
In-Reply-To: <1290528517.3046.91.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Tue, 23 Nov 2010 17:08:37 +0100,
Eric Dumazet <eric.dumazet@gmail.com> a =C3=A9crit :

> (...)

Thanks for the explanations=20

> Le mardi 23 novembre 2010 =C3=A0 15:03 +0000, Alban Crequy a =C3=A9cr=
it :
> >=20
> > - Another idea would be to avoid completely the allocation by
> > inlining unix_find_multicast_recipients() inside
> > unix_dgram_sendmsg() and delivering the messages to the recipients
> > as long as the list is being iterated locklessly. But I want to
> > provide atomicity of delivery: the message must be delivered with
> > skb_queue_tail() either to all the recipients or to none of them in
> > case of interruption or memory pressure. I don't see how I can
> > achieve that without iterating several times on the list of
> > recipients, hence the allocation and the copy in the array. I also
> > want to guarantee the order of delivery as described in
> > multicast-unix-sockets.txt and for this, I am taking lots of
> > spinlocks anyway. I don't see how to avoid that, but I would be
> > happy to be wrong and have a better solution.
> >=20
>=20
>=20
> So if one destination has a full receive queue, you want nobody
> receive the message ? That seems a bit risky to me, if someone sends
> SIGSTOP to one of your process...

Yes. For the D-Bus usage, I want to have this guarantee. If random
remote procedure calls are lost, it will break applications built on
top of D-Bus with multicast Unix sockets. The current implementation of
D-Bus avoid this problem by having almost infinite receiving queues in
the process dbus-daemon: 1GB. But in the kernel,
/proc/sys/net/unix/max_dgram_qlen is 10 messages by default. Increasing
it a bit will not fix the problem and increasing it to 1GB is not
reasonable in kernel.

There is different actions the kernel can do when the queue is full:

1. block the sender. It is useful in RPC, we don't want random RPC to
   disappear unnoticed.
2. drop the message for recipients with a full queue. It could be
   acceptable for some slow monitoring tools that don't want to disturb
   the applications.
3. close the receiving socket as a punishment. At least the problem is
   not unnoticed and the user can have some error feedback.

I was thinking to make it configurable when a socket joins a multicast
group. So different multicast group members would behave differently.
The flag UNIX_MREQ_DROP_WHEN_FULL is there for that (but not fully
implemented in the patchset).

It makes things more complex for poll(POLLOUT). Before the buffer
reaches the kernel, it cannot run the socket filters, so it is not
possible to know the exact recipients. So poll(POLLOUT) has to block
as soon as only one receiving queue is full (unless the multicast
member has the flag UNIX_MREQ_DROP_WHEN_FULL).

When the peers install sockets filters and there is 2 flows of messages
from A to B and from C to D, if the receiving queue of D is full, it
will also block the communication from A to B: poll(A, POLLOUT) will
block. This is annoying but I don't see how to fix it.

> > To give an idea of the number of members in a multicast group for
> > the D-Bus use case, I have 90 D-Bus connections on my session bus:
> >=20
> > $ dbus-send --print-reply --dest=3Dorg.freedesktop.DBus \
> > /org/freedesktop/DBus org.freedesktop.DBus.ListNames | grep '":'|wc
> > -l 90
> >=20
> > In common cases, there should be only a few real recipients (1 or
> > 2?) after the socket filters eliminate most of them, but
> > unix_find_multicast_recipients() will still allocate an array of
> > about that size.
> >=20
>=20
> I am not sure if doing 90 clones of skb and filtering them one by one
> is going to be fast :-(

Yes... I think it can be optimized. Run the socket filter first by
calling sk_run_filter() directly and then call skb_clone() + pskb_trim(=
)
only on the few remaining sockets.


