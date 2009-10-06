From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: query: TCPCT setsockopt kmalloc's
Date: Tue, 06 Oct 2009 18:31:16 +0200
Message-ID: <4ACB70D4.7010108@gmail.com>
References: <4ACB67EB.6080000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:59216 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932208AbZJFQby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 12:31:54 -0400
In-Reply-To: <4ACB67EB.6080000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

William Allen Simpson a =E9crit :
> On both the client and server side, the setsockopt does a kmalloc(). =
 Only
> once per connect on the client side, once per listen on the server si=
de.

But if server has to generate a random data for a connection, you'll ha=
ve to clone
the data to be able to give it at application request ?

>=20
> However, after Miller's expressed concern, it seems possible to reorg=
anize
> the code to do the kmalloc() before the lock_sock().  Does that mean
> that it
> should be GFP_KERNEL?  Or should it still be GFP_ATOMIC?

GFP_KERNEL is better in this context, it allows the requestor to sleep =
a bit if necessary.

>=20
> [Not that anybody cares, but based on recent discussion on the list a=
bout
> internal kernel coding standards, I've changed Adam's old sizeof(stru=
ct)
> to sizeof(*tcvp).  Previously, I was trying to make as few changes as
> possible, thinking everything was already correct.]



>=20
> =3D=3D=3D
> new:
>=20
> +        /* Allocate ancillary memory before locking.
> +         */
> +        if ((0 < tcd.tcpcd_used

Ah, could you please reverse all your conditions ?

Their form are unusual in linux kernel.

if (tcd.tcpcd_used > 0)


> ...
> +         && NULL =3D=3D (tcvp =3D kmalloc(sizeof(*tcvp) + tcd.tcpcd_=
used,
> +                        GFP_KERNEL))) {
> +            return -ENOMEM;
> +        }
>
=20
tcvp =3D kmalloc(sizeof(*tcvp) + tcd.tcpcd_used, GFP_KERNEL));
if (tcvp =3D=3D NULL) ...

