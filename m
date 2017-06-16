From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [RFC 1/3] networking: make skb_put & friends return void pointers
Date: Fri, 16 Jun 2017 09:53:11 +0200
Message-ID: <871sqke5co.fsf@miraculix.mork.no>
References: <20170615221217.16510-1-johannes@sipsolutions.net>
        <20170615221217.16510-2-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, Johannes Berg <johannes.berg@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:41923 "EHLO canardo.mork.no"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752375AbdFPHxZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Jun 2017 03:53:25 -0400
In-Reply-To: <20170615221217.16510-2-johannes@sipsolutions.net> (Johannes
        Berg's message of "Fri, 16 Jun 2017 00:12:15 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg <johannes@sipsolutions.net> writes:

> From: Johannes Berg <johannes.berg@intel.com>
>
> It seems like a historic accident that these return unsigned char *,
> and in many places that means casts are required, more often than not.
>
> Make these functions (skb_put, __skb_put and pskb_put) return void *
> and remove all the casts across the tree, adding a (u8 *) cast only
> where the unsigned char pointer was used directly, all done with the
> following spatch:
>
>     @@
>     expression SKB, LEN;
>     typedef u8;
>     identifier fn =3D { skb_put, __skb_put };
>     @@
>     - *(fn(SKB, LEN))
>     + *(u8 *)fn(SKB, LEN)
>
>     @@


There seem to be a large number of places where the char pointer was
used directly. Not that I have any strong opinion either way, but adding
lots of ugly casts like this seems to contradict the whole purpose of
this change?:

>  			if (info->rx_count =3D=3D 0) {
> diff --git a/drivers/bluetooth/bt3c_cs.c b/drivers/bluetooth/bt3c_cs.c
> index 8165ef2fe877..be2d431aa366 100644
> --- a/drivers/bluetooth/bt3c_cs.c
> +++ b/drivers/bluetooth/bt3c_cs.c
> @@ -282,7 +282,7 @@ static void bt3c_receive(struct bt3c_info *info)
>=20=20
>  			__u8 x =3D inb(iobase + DATA_L);
>=20=20
> -			*skb_put(info->rx_skb, 1) =3D x;
> +			*(u8 *)skb_put(info->rx_skb, 1) =3D x;
>  			inb(iobase + DATA_H);
>  			info->rx_count--;
>=20=20

That does not look any better in my eyes, and there are ... what?
... hundreds of them?


No complaints about the other skb_* changes you are doing, Those are
nice cleanups.  But skb_put is different IMHO.


Bj=C3=B8rn
