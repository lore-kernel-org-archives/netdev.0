From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH 1/2] neigh: Store hash shift instead of mask.
Date: Mon, 11 Jul 2011 13:58:41 +0200
Message-ID: <CAHXqBFLk5ze9y7htyO+9z7=qcznNjXeuJK5Rs1t2ym=vLqDy5Q@mail.gmail.com>
References: <20110711.014841.1004194674075047305.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: roland@purestorage.com, johnwheffner@gmail.com, mj@ucw.cz,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:63714 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752964Ab1GKL7C convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 07:59:02 -0400
Received: by qwk3 with SMTP id 3so1815386qwk.19
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2011 04:59:01 -0700 (PDT)
In-Reply-To: <20110711.014841.1004194674075047305.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/7/11 David Miller <davem@davemloft.net>:
> And mask the hash function result by simply shifting
> down the "->hash_shift" most significant bits.
>
> Currently which bits we use is arbitrary since jhash
> produces entropy evenly across the whole hash function
> result.
>
> But soon we'll be using universal hashing functions,
> and in those cases more entropy exists in the higher
> bits than the lower bits, because they use multiplies.

You could use some evil shift tricks to cut some instructions if you li=
ke. ;-)
Examples below.

[...]
> - =C2=A0 =C2=A0 =C2=A0 for (i =3D 0; i <=3D nht->hash_mask; i++) {
> + =C2=A0 =C2=A0 =C2=A0 for (i =3D 0; i < (1 << nht->hash_shift); i++)=
 {

for (i =3D 0; !(i >> nth->hash_shift); i++)

[...]
> - =C2=A0 =C2=A0 =C2=A0 size_t size =3D entries * sizeof(struct neighb=
our *);
> + =C2=A0 =C2=A0 =C2=A0 size_t size =3D (1 << shift) * sizeof(struct n=
eighbour *);

size_t size =3D sizeof(struct neighbour *) << shift;

Or, since later get_order(size) is used:

unsinged int size_shift =3D shift + order_base_2(sizeof(struct neighbou=
r *));

Best Regards,
Micha=C5=82 Miros=C5=82aw
