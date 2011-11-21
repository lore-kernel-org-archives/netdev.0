From: Nick Bowler <nbowler@elliptictech.com>
Subject: Re: Occasional oops with IPSec and IPv6.
Date: Mon, 21 Nov 2011 10:12:42 -0500
Message-ID: <20111121151242.GA29494@elliptictech.com>
References: <20111117190925.GA23214@elliptictech.com>
 <20111118162709.GA8342@elliptictech.com>
 <1321634378.3277.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <4EC6A38E.6060404@iki.fi>
 <20111118192639.GA10531@elliptictech.com>
 <4EC6BAD7.3010200@iki.fi>
 <20111118212129.GA22495@elliptictech.com>
 <4EC75C99.4000304@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl-67-204-24-19.acanac.net ([67.204.24.19]:59013 "EHLO
	mail.ellipticsemi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754903Ab1KUPM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 10:12:57 -0500
Content-Disposition: inline
In-Reply-To: <4EC75C99.4000304@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2011-11-19 09:36 +0200, Timo Ter=E4s wrote:
> On 11/18/2011 11:21 PM, Nick Bowler wrote:
> > On 2011-11-18 22:06 +0200, Timo Ter=E4s wrote:
> >> Alternatively, we could just run the "slow path" unconditionally w=
ith
> >> the test load to see if it fixes the issue. At least that'd be pre=
tty
> >> good test if it's a problem in the ipv6 fragmentation code or some=
thing
> >> else.
> >=20
> > Good call.  I replaced the "correct geometry" check with an
> > unconditional "goto slow_path_clean;", and I can no longer reproduc=
e the
> > crash.  So at the very least, I have a workaround now.  (I still ha=
ve
> > Herbert Xu's six patches applied on top of Linus' master).
>=20
> Ok, so it's most likely ipv6 code issue then. My change just happened=
 to
> trigger it.
>=20
> > I then tried the smaller change above, but this does not correct th=
e
> > issue.
>=20
> That's not it then (likely).
>=20
> I did notice that the headroom of the main skb is never checked. So m=
y
> other suggestion is to try something like:
>=20
> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index 1c9bf8b..735c4dc 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -668,7 +668,8 @@ int ip6_fragment(struct sk_buff *skb, int
> (*output)(struct sk_buff *))
>=20
>  		if (first_len - hlen > mtu ||
>  		    ((first_len - hlen) & 7) ||
> -		    skb_cloned(skb))
> +		    skb_cloned(skb) ||
> +		    skb_headroom(skb) < sizeof(struct frag_hdr))
>  			goto slow_path;
>=20
>  		skb_walk_frags(skb, frag) {

Tried this (still on top of Herbert Xu's patch set) to no avail; the
crash still occurs :(.

Using the unconditional slow path workaround, I ran the test over the
weekend and it did not crash, so that seems to be stable.

> Other than that, I hope some of the ipv6 people could take a look at =
it.
> But the problem is that somewhere some headroom check isn't taking
> place, or is checking for too little of headroom.

Thanks,
--=20
Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)
