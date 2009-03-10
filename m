From: Nicolas Dichtel <nicolas.dichtel@dev.6wind.com>
Subject: Re: XFRM state hash value
Date: Tue, 10 Mar 2009 15:08:16 +0100
Message-ID: <49B67450.1060002@dev.6wind.com>
References: <49B636DB.7010004@dev.6wind.com> <20090310.042051.107256879.davem@davemloft.net>
Reply-To: nicolas.dichtel@dev.6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:57697 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751044AbZCJOI3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2009 10:08:29 -0400
In-Reply-To: <20090310.042051.107256879.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is ok with my test case.
I'm asking me if we should perform the step with saddr_wildcard if we h=
ave=20
already found one. The state with a src address may have an higher prio=
rity than=20
the state with a wildcare address, no?

Nicolas

Le 10.03.2009 12:20, David Miller a =E9crit :
> From: Nicolas Dichtel <nicolas.dichtel@dev.6wind.com>
> Date: Tue, 10 Mar 2009 10:46:03 +0100
>=20
>> this commit: [XFRM]: Hash xfrm_state objects by source address too. =
(http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net-2.6.git;a=3Dcomm=
itdiff;h=3Dc1969f294e624d5b642fc8e6ab9468b7c7791fa8)
>> introduces src address in hash for state.
>> But in some cases, source address is a wildcard when state is insert=
ed. For example, we can have something like this:
>> # setkey -c
>> add :: ff02::9 ah 0x100 -m transport -A hmac-md5 "cle3goldorakcle3";
>>
>> In this case, __xfrm_state_insert() will calculate the hash value wi=
th src address set to 0, but xfrm_state_find() will use the real source=
 address to calculate this hash. At the end, no state will be found.
>> The most simple way to resolve this pb is to revert the previous pat=
ch, but maybe someone has a better idea...
>>
>=20
> Please try this patch:
>=20
> diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
> index e25ff62..86b9078 100644
> --- a/net/xfrm/xfrm_state.c
> +++ b/net/xfrm/xfrm_state.c
> @@ -748,12 +748,51 @@ static void xfrm_hash_grow_check(struct net *ne=
t, int have_hash_collision)
>  		schedule_work(&net->xfrm.state_hash_work);
>  }
> =20
> +static void xfrm_state_look_at(struct xfrm_policy *pol, struct xfrm_=
state *x,
> +			       struct flowi *fl, unsigned short family,
> +			       xfrm_address_t *daddr, xfrm_address_t *saddr,
> +			       struct xfrm_state **best, int *acq_in_progress,
> +			       int *error)
> +{
> +	/* Resolution logic:
> +	 * 1. There is a valid state with matching selector. Done.
> +	 * 2. Valid state with inappropriate selector. Skip.
> +	 *
> +	 * Entering area of "sysdeps".
> +	 *
> +	 * 3. If state is not valid, selector is temporary, it selects
> +	 *    only session which triggered previous resolution. Key
> +	 *    manager will do something to install a state with proper
> +	 *    selector.
> +	 */
> +	if (x->km.state =3D=3D XFRM_STATE_VALID) {
> +		if ((x->sel.family &&
> +		     !xfrm_selector_match(&x->sel, fl, x->sel.family)) ||
> +		    !security_xfrm_state_pol_flow_match(x, pol, fl))
> +			return;
> +
> +		if (!*best ||
> +		    (*best)->km.dying > x->km.dying ||
> +		    ((*best)->km.dying =3D=3D x->km.dying &&
> +		     (*best)->curlft.add_time < x->curlft.add_time))
> +			*best =3D x;
> +	} else if (x->km.state =3D=3D XFRM_STATE_ACQ) {
> +		*acq_in_progress =3D 1;
> +	} else if (x->km.state =3D=3D XFRM_STATE_ERROR ||
> +		   x->km.state =3D=3D XFRM_STATE_EXPIRED) {
> +		if (xfrm_selector_match(&x->sel, fl, x->sel.family) &&
> +		    security_xfrm_state_pol_flow_match(x, pol, fl))
> +			*error =3D -ESRCH;
> +	}
> +}
> +
>  struct xfrm_state *
>  xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
>  		struct flowi *fl, struct xfrm_tmpl *tmpl,
>  		struct xfrm_policy *pol, int *err,
>  		unsigned short family)
>  {
> +	static xfrm_address_t saddr_wildcard =3D { };
>  	struct net *net =3D xp_net(pol);
>  	unsigned int h;
>  	struct hlist_node *entry;
> @@ -773,38 +812,21 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_add=
ress_t *saddr,
>  		    xfrm_state_addr_check(x, daddr, saddr, family) &&
>  		    tmpl->mode =3D=3D x->props.mode &&
>  		    tmpl->id.proto =3D=3D x->id.proto &&
> -		    (tmpl->id.spi =3D=3D x->id.spi || !tmpl->id.spi)) {
> -			/* Resolution logic:
> -			   1. There is a valid state with matching selector.
> -			      Done.
> -			   2. Valid state with inappropriate selector. Skip.
> -
> -			   Entering area of "sysdeps".
> -
> -			   3. If state is not valid, selector is temporary,
> -			      it selects only session which triggered
> -			      previous resolution. Key manager will do
> -			      something to install a state with proper
> -			      selector.
> -			 */
> -			if (x->km.state =3D=3D XFRM_STATE_VALID) {
> -				if ((x->sel.family && !xfrm_selector_match(&x->sel, fl, x->sel.f=
amily)) ||
> -				    !security_xfrm_state_pol_flow_match(x, pol, fl))
> -					continue;
> -				if (!best ||
> -				    best->km.dying > x->km.dying ||
> -				    (best->km.dying =3D=3D x->km.dying &&
> -				     best->curlft.add_time < x->curlft.add_time))
> -					best =3D x;
> -			} else if (x->km.state =3D=3D XFRM_STATE_ACQ) {
> -				acquire_in_progress =3D 1;
> -			} else if (x->km.state =3D=3D XFRM_STATE_ERROR ||
> -				   x->km.state =3D=3D XFRM_STATE_EXPIRED) {
> -				if (xfrm_selector_match(&x->sel, fl, x->sel.family) &&
> -				    security_xfrm_state_pol_flow_match(x, pol, fl))
> -					error =3D -ESRCH;
> -			}
> -		}
> +		    (tmpl->id.spi =3D=3D x->id.spi || !tmpl->id.spi))
> +			xfrm_state_look_at(pol, x, fl, family, daddr, saddr,
> +					   &best, &acquire_in_progress, &error);
> +	}
> +	h =3D xfrm_dst_hash(net, daddr, &saddr_wildcard, tmpl->reqid, famil=
y);
> +	hlist_for_each_entry(x, entry, net->xfrm.state_bydst+h, bydst) {
> +		if (x->props.family =3D=3D family &&
> +		    x->props.reqid =3D=3D tmpl->reqid &&
> +		    !(x->props.flags & XFRM_STATE_WILDRECV) &&
> +		    xfrm_state_addr_check(x, daddr, saddr, family) &&
> +		    tmpl->mode =3D=3D x->props.mode &&
> +		    tmpl->id.proto =3D=3D x->id.proto &&
> +		    (tmpl->id.spi =3D=3D x->id.spi || !tmpl->id.spi))
> +			xfrm_state_look_at(pol, x, fl, family, daddr, saddr,
> +					   &best, &acquire_in_progress, &error);
>  	}
> =20
>  	x =3D best;
