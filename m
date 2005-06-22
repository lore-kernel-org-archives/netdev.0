From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: RFC: NAPI packet weighting patch
Date: Thu, 23 Jun 2005 00:13:21 +0200
Message-ID: <42B9E281.1090109@cosmosbay.com>
References: <1119458226.6918.142.camel@localhost.localdomain>	<200506221801.j5MI11xS021866@guinness.s2io.com>	<20050622180654.GX14251@wotan.suse.de> <20050622.132241.21929037.davem@davemloft.net> <42B9DA4D.5090103@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>, ak@suse.de,
        leonid.grossman@neterion.com, hadi@cyberus.ca, becker@scyld.com,
        rick.jones2@hp.com, netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <42B9DA4D.5090103@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Eric Dumazet a =E9crit :

>=20
> Then maybe we could also play with prefetchw() in the case the incoming=
=20
> frame
> is small enough to be copied to a new skb.
>=20
> drivers/net/tg3.c
>=20
>     copy_skb =3D dev_alloc_skb(len + 2);
>     if (copy_skb =3D=3D NULL)
>         goto drop_it_no_recycle;
> +    prefetchw(copy_skb->data);
>=20
>     copy_skb->dev =3D tp->dev;
>     skb_reserve(copy_skb, 2);
>     skb_put(copy_skb, len);
>=20
>=20
>=20

I also found that the memcpy() done to copy the data to the new skb suffe=
rs from misalignment.

This is because of skb_reserve(skbs, 2) that was done on both skb, and me=
mcpy() (at least on x86_64) doing long word copies without checking=20
alignment of source or destination.

Maybe we could :

1) make sure both skbs had the same skb_reserve() of 2 (thats not clear b=
ecause tg3.c mixes the '2' and tp->rx_offset,
and according to a comment :
	rx_offset !=3D 2 iff this is a 5701 card running=20
                                          	in PCI-X mode

2) and do :

-	memcpy(copy_skb->data, skb->data, len);
+	memcpy(copy_skb->data-2, skb->data-2, len+2);

(That is copy 2 more bytes, but gain aligned copy to speedup memcpy())

Eric Dumazet
