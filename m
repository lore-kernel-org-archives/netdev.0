From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 4/4] rps: Inspect GRE encapsulated packets to get flow
 hash
Date: Thu, 19 May 2011 18:16:35 +0200
Message-ID: <1305821795.3028.82.camel@edumazet-laptop>
References: <alpine.DEB.2.00.1105190827420.12804@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:46261 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932732Ab1ESQQj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 12:16:39 -0400
Received: by wwa36 with SMTP id 36so3070559wwa.1
        for <netdev@vger.kernel.org>; Thu, 19 May 2011 09:16:38 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1105190827420.12804@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 19 mai 2011 =C3=A0 08:39 -0700, Tom Herbert a =C3=A9crit :
> Crack open GRE packets in __skb_get_rxhash to compute 4-tuple hash on
> in encapsulated packet.  Note that this is used only when the
> __skb_get_rxhash is taken, in particular only when the device does
> not compute provide the rxhash (ie. feature is disabled).
>=20
> This was tested by creating a single GRE tunnel between two 16 core
> AMD machines.  200 netperf TCP_RR streams were ran with 1 byte
> request and response size.
>=20
> Without patch: 157497 tps, 50/90/99% latencies 1250/1292/1364 usecs
> With patch: 325896 tps, 50/90/99% latencies 603/848/1169
>=20
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  net/core/dev.c |   22 ++++++++++++++++++++++
>  1 files changed, 22 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 0c83494..7799bbd 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2552,6 +2552,28 @@ again:
>  	}
> =20
>  	switch (ip_proto) {
> +	case IPPROTO_GRE:
> +		if (pskb_may_pull(skb, nhoff + 16)) {
> +			u8 *h =3D skb->data + nhoff;
> +			__be16 flags =3D *(__be16 *)h;
> +
> +			/*
> +			 * Only look inside GRE if version zero and no
> +			 * routing
> +			 */
> +			if (!(flags & (GRE_VERSION|GRE_ROUTING))) {
> +				proto =3D *(__be16 *)(h + 2);
> +				nhoff +=3D 4;
> +				if (flags & GRE_CSUM)
> +					nhoff +=3D 4;
> +				if (flags & GRE_KEY)
> +					nhoff +=3D 4;
> +				if (flags & GRE_SEQ)
> +					nhoff +=3D 4;
> +				goto again;
> +			}
> +		}
> +		break;
>  	default:
>  		break;
>  	}


Hi Tom

=46or sure it helps if this machine is the final host for these packets=
=2E

If I am a firewall or router [and not looking into GRE packets], maybe =
I
dont want to spread all packets received on a tunnel to several cpus an=
d
reorder them when forwarded.

Maybe we need to add a table, so that upper layer (GRE or IPIP tunnels)
can instruct __skb_get_rxhash() that we want to deep inspect packets.

1) Say we keep rxhash first evaluation be the one we have today.

2) Do a hash lookup in a new table to tell if upper layer handled a
previous packet for this first level flow and want more inspection.

3) table could contains 'pointers' to decoding function, that would
recompute a new rxhash function.

4) Find a way to "clean the table", garbage collect or expirations time=
s
can do.

This way we can add stuff in GRE and IPIP modules [and other kind of
tunnels], without layer violations ?



