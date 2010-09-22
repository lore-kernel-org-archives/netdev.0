From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ip : take care of last fragment in ip_append_data
Date: Wed, 22 Sep 2010 06:44:06 +0200
Message-ID: <1285130646.6378.45.camel@edumazet-laptop>
References: <1285013853.2323.148.camel@edumazet-laptop>
	 <1285018272.2323.243.camel@edumazet-laptop>
	 <1285049787.2323.797.camel@edumazet-laptop>
	 <20100921.163856.71124744.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nbowler@elliptictech.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:59872 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750730Ab0IVEoM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 00:44:12 -0400
In-Reply-To: <20100921.163856.71124744.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 21 septembre 2010 =C3=A0 16:38 -0700, David Miller a =C3=A9cri=
t :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 21 Sep 2010 08:16:27 +0200
>=20
> > [PATCH] ip : take care of last fragment in ip_append_data
> >=20
> > While investigating a bit, I found ip_fragment() slow path was take=
n
> > because ip_append_data() provides following layout for a send(MTU +
> > N*(MTU - 20)) syscall :
> >=20
> > - one skb with 1500 (mtu) bytes
> > - N fragments of 1480 (mtu-20) bytes (before adding IP header)
> > last fragment gets 17 bytes of trail data because of following bit:
> >=20
> > 	if (datalen =3D=3D length + fraggap)
> > 		alloclen +=3D rt->dst.trailer_len;
> >=20
> > Then esp4 adds 16 bytes of data (while trailer_len is 17... hmm...
> > another bug ?)
> >=20
> > In ip_fragment(), we notice last fragment is too big (1496 + 20) > =
mtu,
> > so we take slow path, building another skb chain.
> >=20
> > In order to avoid taking slow path, we should correct ip_append_dat=
a()
> > to make sure last fragment has real trail space, under mtu...
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> This patch largely looks fine, but:
>=20
> 1) I want to find out where that "17" tailer_len comes from before
>    applying this, that doesn't make any sense.
>=20
> 2) Even with #1 addressed, this function is tricky so I want to revie=
w
>    this patch some more.



The "17" (instead of probable 16 need) comes from :

net/ipv4/esp4.c line 599 :

x->props.trailer_len =3D align + 1 + crypto_aead_authsize(esp->aead);

In my Nick ipsec script case,=20
crypto_aead_blocksize(aead) =3D 16,=20
crypto_aead_authsize(esp->aead) =3D 0

-> align =3D 16
trailer_len =3D 16 + 1 + 0;

I am not sure we need the "+ 1", but I know nothing about this stuff.

Same in net/ipv6/esp6.c ?


Anyway the last frag problem is for packets with lengths :
 MTU + N*(MTU - 20) + LAST

LAST being from [(MTU - trailer_len) ... MTU], not only MTU as I wrote
in changelog



