From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] netlink: netlink_recvmsg() fix
Date: Wed, 21 Jul 2010 10:20:20 +0200
Message-ID: <1279700420.2452.15.camel@edumazet-laptop>
References: <1279631789.2498.71.camel@edumazet-laptop>
	 <1279639232.2498.82.camel@edumazet-laptop>
	 <1279699529.3707.5.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:51155 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762740Ab0GUIUY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 04:20:24 -0400
Received: by wwj40 with SMTP id 40so1968307wwj.1
        for <netdev@vger.kernel.org>; Wed, 21 Jul 2010 01:20:22 -0700 (PDT)
In-Reply-To: <1279699529.3707.5.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 21 juillet 2010 =C3=A0 10:05 +0200, Johannes Berg a =C3=A9c=
rit :
> On Tue, 2010-07-20 at 17:20 +0200, Eric Dumazet wrote:
>=20
> > [PATCH net-next-2.6 v2] netlink: netlink_recvmsg() fix
> >=20
> > commit 1dacc76d0014=20
> > (net/compat/wext: send different messages to compat tasks)
> > introduced a race condition on netlink, in case MSG_PEEK is used.
> >=20
> > An skb given by skb_recv_datagram() might be shared, we must copy i=
t
> > before any modification, or risk fatal corruption.
>=20
> Makes sense to me, seeing that if you MSG_PEEK it just increases
> skb->users. But nothing could touch the other skb at the same time?
> Although I guess with netlink multicast we have a similar situation.

Nothing can touch this skb at the same time but us and our friends
(consumers that did a skb_recv_datagram( MSG_PEEK ) operation).

Oh well, I see skb_unshare() tests skb_cloned(). This is not what we
want.

We probably wants something like :

if (skb_shared(skb)) {
	nsbk =3D skb_copy(skb, GFP_KERNEL);
	...
}



