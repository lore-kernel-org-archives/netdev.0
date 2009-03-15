From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH 6/7] tcp: cache result of earlier divides when mss-aligning things
Date: Sun, 15 Mar 2009 11:36:42 +0300
Message-ID: <20090315083642.GA31423@ioremap.net>
References: <1237075675426-git-send-email-ilpo.jarvinen@helsinki.fi> <12370756753599-git-send-email-ilpo.jarvinen@helsinki.fi> <12370756754094-git-send-email-ilpo.jarvinen@helsinki.fi> <12370756752410-git-send-email-ilpo.jarvinen@helsinki.fi> <12370756751028-git-send-email-ilpo.jarvinen@helsinki.fi> <12370756752721-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Ingo Molnar <mingo@elte.hu>
To: Ilpo =?utf-8?B?SsOkcnZpbmVu?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from genesysrack.ru ([195.178.208.66]:50465 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751838AbZCOIgy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Mar 2009 04:36:54 -0400
Content-Disposition: inline
In-Reply-To: <12370756752721-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ilpo.

On Sun, Mar 15, 2009 at 02:07:54AM +0200, Ilpo J=C3=A4rvinen (ilpo.jarv=
inen@helsinki.fi) wrote:
> @@ -676,7 +676,17 @@ static unsigned int tcp_xmit_size_goal(struct so=
ck *sk, u32 mss_now,
>  				  tp->tcp_header_len);
> =20
>  		xmit_size_goal =3D tcp_bound_to_half_wnd(tp, xmit_size_goal);
> -		xmit_size_goal -=3D (xmit_size_goal % mss_now);
> +
> +		/* We try hard to avoid divides here */
> +		old_size_goal =3D tp->xmit_size_goal_segs * mss_now;
> +
> +		if (old_size_goal <=3D xmit_size_goal &&
> +		    old_size_goal + mss_now > xmit_size_goal) {
> +			xmit_size_goal =3D old_size_goal;

If this is way more likely condition than changed xmit size, what about
wrapping it into likely()?

> +		} else {
> +			tp->xmit_size_goal_segs =3D xmit_size_goal / mss_now;
> +			xmit_size_goal =3D tp->xmit_size_goal_segs * mss_now;
> +		}
>  	}
> =20
>  	return xmit_size_goal;
> --=20
> 1.5.6.5

--=20
	Evgeniy Polyakov
