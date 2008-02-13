From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND] [XFRM]: Speed up xfrm_policy and xfrm_state
 walking
Date: Tue, 12 Feb 2008 22:59:08 -0800 (PST)
Message-ID: <20080212.225908.92858029.davem@davemloft.net>
References: <47A3337C.1090004@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41844
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752268AbYBMG6g convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Feb 2008 01:58:36 -0500
In-Reply-To: <47A3337C.1090004@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo_Ter=E4s <timo.teras@iki.fi>
Date: Fri, 01 Feb 2008 16:58:04 +0200

> @@ -1780,6 +1786,7 @@ static int check_reqid(struct xfrm_policy *xp, =
int dir, int count, void *ptr)
> =20
>  static u32 gen_reqid(void)
>  {
> +	struct xfrm_policy_walk walk;
>  	u32 start;
>  	static u32 reqid =3D IPSEC_MANUAL_REQID_MAX;
> =20
> @@ -1788,9 +1795,10 @@ static u32 gen_reqid(void)
>  		++reqid;
>  		if (reqid =3D=3D 0)
>  			reqid =3D IPSEC_MANUAL_REQID_MAX+1;
> -		if (xfrm_policy_walk(XFRM_POLICY_TYPE_MAIN, check_reqid,
> -				     (void*)&reqid) !=3D -EEXIST)
> +		xfrm_policy_walk_init(&walk, XFRM_POLICY_TYPE_MAIN);
> +		if (xfrm_policy_walk(&walk, check_reqid, (void*)&reqid) !=3D -EEXI=
ST)
>  			return reqid;
> +		xfrm_policy_walk_done(&walk);
>  	} while (reqid !=3D start);
>  	return 0;
>  }

This will potentially leak walk->policy in the !=3D -EEXIST case.

I think what needs to happen is we invoke xfrm_policy_walk_done()
unconditionally, then we'll potentially return reqid.
