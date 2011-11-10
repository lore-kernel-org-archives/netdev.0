From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: creating netdev queues on the fly?
Date: Thu, 10 Nov 2011 15:35:13 +0100
Message-ID: <1320935713.2310.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1320933501.3967.68.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:39859 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934814Ab1KJOfS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2011 09:35:18 -0500
In-Reply-To: <1320933501.3967.68.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 10 novembre 2011 =C3=A0 14:58 +0100, Johannes Berg a =C3=A9cri=
t :
> Hi,
>=20
> I've been thinking about how we manage TX queues in wifi and right no=
w
> we just split things up by access category for QoS purposes.
>=20
> However we have the issue that we might be pushing data to stations w=
ith
> completely different speeds. Onn wired, where our outgoing speed is
> essentially constant and some router/switch has to drop packets for t=
he
> slow link:
>=20
> machine A =3D=3D=3D 1000mbps link =3D=3D=3D=3D [switch] =3D=3D=3D 100=
0mbps =3D=3D=3D machine B
>                                      |
>                                      +--- 100mbps link --- machine C
>=20
> But on wireless we really transmit to slow stations only with a slow
> speed, so our outgoing speed differs. I think the scenario is quite
> different, also because the speed can vary obviously.
>=20
> So to get to my question: What if we could create netdev queues on th=
e
> fly?
>=20
> The reason to do that is that we really don't want to reserve some 80=
00
> queues just because somebody could possibly try to create 2000
> connections (2007 is the theoretical max due to protocol restrictions=
)
> to the AP interface. We also don't really want to create a netdev for
> each peer (though you could implement it that way today).
>=20
> I looked at this and it doesn't seem terrible. Creating & destroying =
the
> queues might be tricky though. I think ndo_select_queue might return =
the
> queue pointer instead of an index, and then that queue could be used.
> The normal queues would still be in an array, with maybe a linked lis=
t
> of extra queues that were dynamically created. Obviously the driver
> would have to be able to manage that.
>=20
> Ultimately, all the frames will of course end up on the same four
> hardware queues again. But this would some better management, and pil=
ed
> up traffic to one station that suddenly dies wouldn't impact performa=
nce
> for all others as badly as it does today since we wouldn't let all th=
ose
> frames pile up on the hardware queues, they'd only get there with som=
e
> mechanism that might take airtime into account.
>=20
> I think this might also make implementing reservation (tspec) easier.
> Not sure if anyone wants/needs that though.
>=20
>=20
> Am I completely crazy?
>=20

In term of qdisc management I believe its a bit complex if we start to
dynamically add netdev queues :)

My first idea would be to extend Qdisc management so that a device can
callback qdisc when a frame is finaly delivered / consumed / discarded.

We currently only have qdisc->enqueue() and qdisc->dequeue(), we could
add qdisc->deliver_callback(skb)

You keep devices as they are, with a netdevqueue per hardware queue.

Then, using a Qdisc like existing ones, but with a limit of
outstanding(given to device but not yet consumed) packets per class.

external tc classifier would deliver a hash/index depending on remote
station.

As a bonus you can get all the existing rate estimators / QOS /
shapers ...
