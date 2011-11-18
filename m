From: Nick Bowler <nbowler@elliptictech.com>
Subject: Re: Occasional oops with IPSec and IPv6.
Date: Fri, 18 Nov 2011 16:21:29 -0500
Message-ID: <20111118212129.GA22495@elliptictech.com>
References: <20111117190925.GA23214@elliptictech.com>
 <20111118162709.GA8342@elliptictech.com>
 <1321634378.3277.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <4EC6A38E.6060404@iki.fi>
 <20111118192639.GA10531@elliptictech.com>
 <4EC6BAD7.3010200@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl-67-204-24-19.acanac.net ([67.204.24.19]:57904 "EHLO
	mail.ellipticsemi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756506Ab1KRVqN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 16:46:13 -0500
Content-Disposition: inline
In-Reply-To: <4EC6BAD7.3010200@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2011-11-18 22:06 +0200, Timo Ter=E4s wrote:
> It's still headroom underrun.
>=20
> I'm not too familiar with the relevant IPv6 code, but it seems to be
> mostly modelled after the IPv4 side. Looking at the back trace offset
> inside ipv6_fragment, I'd say it was taking the "fast path" for
> constructing the fragments. So first guess is that the headroom check
> for allowing fast path to happen is not right.
>=20
> Since the code seems to be treating separately hlen and struct frag_h=
dr,
> I'm wondering if the following patch would be in place?
>=20
> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index 1c9bf8b..c35d9fc 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -675,7 +675,7 @@ int ip6_fragment(struct sk_buff *skb, int
> (*output)(struct sk_buff *))
>  			/* Correct geometry. */
>  			if (frag->len > mtu ||
>  			    ((frag->len & 7) && frag->next) ||
> -			    skb_headroom(frag) < hlen)
> +			    skb_headroom(frag) < hlen + sizeof(struct frag_hdr))
>  				goto slow_path_clean;
>=20
>  			/* Partially cloned skb? */
>=20
>=20
> Alternatively, we could just run the "slow path" unconditionally with
> the test load to see if it fixes the issue. At least that'd be pretty
> good test if it's a problem in the ipv6 fragmentation code or somethi=
ng
> else.

Good call.  I replaced the "correct geometry" check with an
unconditional "goto slow_path_clean;", and I can no longer reproduce th=
e
crash.  So at the very least, I have a workaround now.  (I still have
Herbert Xu's six patches applied on top of Linus' master).

I then tried the smaller change above, but this does not correct the
issue.

Cheers,
--=20
Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)
