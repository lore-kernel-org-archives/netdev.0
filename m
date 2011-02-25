From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] udp: avoid searching when no ports are available
Date: Fri, 25 Feb 2011 13:06:15 +0100
Message-ID: <1298635575.2659.65.camel@edumazet-laptop>
References: <1298633711-11924-1-git-send-email-dbaluta@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Rohan Chitradurga <rohan@ixiacom.com>
To: Daniel Baluta <dbaluta@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:61457 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753158Ab1BYMGX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 07:06:23 -0500
Received: by bwz15 with SMTP id 15so1880080bwz.19
        for <netdev@vger.kernel.org>; Fri, 25 Feb 2011 04:06:21 -0800 (PST)
In-Reply-To: <1298633711-11924-1-git-send-email-dbaluta@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 25 f=C3=A9vrier 2011 =C3=A0 13:35 +0200, Daniel Baluta a =C3=
=A9crit :
> udp_lib_get_port uses a bitmap to mark used ports.
>=20
> When no ports are available we spend a lot of time, searching
> for a port while holding hslot lock. Avoid this by checking if
> bitmap is full.
>=20
>=20
> Signed-off-by: Rohan Chitradurga <rohan@ixiacom.com>
> Signed-off-by: Daniel Baluta <dbaluta@ixiacom.com>
> ---
>  net/ipv4/udp.c |    6 ++++++
>  1 files changed, 6 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index d37baaa..3e3592d 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -225,6 +225,12 @@ int udp_lib_get_port(struct sock *sk, unsigned s=
hort snum,
>  			udp_lib_lport_inuse(net, snum, hslot, bitmap, sk,
>  					    saddr_comp, udptable->log);
> =20
> +			/* avoid searching when no ports are available */
> +			if (bitmap_full(bitmap, PORTS_PER_CHAIN)) {
> +				spin_unlock_bh(&hslot->lock);
> +				break;
> +			}
> +
>  			snum =3D first;
>  			/*
>  			 * Iterate on all possible values of snum for this hash.

Really ? I wonder how you got your performance numbers then.

=46irst, PORTS_PER_CHAIN is wrong here, since its value is the max
possible value (256 bits)

#define UDP_HTABLE_SIZE_MIN              (CONFIG_BASE_SMALL ? 128 : 256=
)
#define MAX_UDP_PORTS 65536
#define PORTS_PER_CHAIN (MAX_UDP_PORTS / UDP_HTABLE_SIZE_MIN)   -> 256

As soon as your machine (and most current machines have) has enough
memory, UDP hash table size is not 256, but 1024 or 2048

dmesg | grep "UDP hash"
[    1.735203] UDP hash table entries: 2048 (order: 6, 327680 bytes)

So real bitmap size is 64 or 32 bits.

Your call to bitmap_full() always return false.


I dont like this patch. If you have special UDP needs on a small
machine, just add to kernel boot param "uhash_entries=3D8192", so that =
the
bitmap has 8 bits only.



