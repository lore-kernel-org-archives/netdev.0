From: Joakim Koskela <joakim.koskela@hiit.fi>
Subject: Re: [PATCH net-2.6.22-rc7] xfrm beet interfamily support
Date: Thu, 19 Jul 2007 20:54:38 +0300
Message-ID: <200707192054.38945.joakim.koskela@hiit.fi>
References: <200707161506.47915.joakim.koskela@hiit.fi> <200707191708.58863.joakim.koskela@hiit.fi> <469F7952.207@trash.net>
Reply-To: joakim.koskela@hiit.fi
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pne-smtpout4-sn1.fre.skanova.net ([81.228.11.168]:49493 "EHLO
	pne-smtpout4-sn1.fre.skanova.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761895AbXGSTIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 15:08:53 -0400
In-Reply-To: <469F7952.207@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 19 July 2007 17:46:42 Patrick McHardy wrote:
> > -
> > +		if (xfrm[i]->props.mode != XFRM_MODE_TRANSPORT) {
> > +			encap_family = xfrm[i]->props.family;
> > +			if (encap_family == AF_INET) {
> > +				remote.in = (struct in_addr *)
> > +					&xfrm[i]->id.daddr.a4;
> > +				local.in  = (struct in_addr *)
> > +					&xfrm[i]->props.saddr.a4;
> > +#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
> > +			} else if (encap_family == AF_INET6) {
> > +				remote.in6 = (struct in6_addr *)
> > +					xfrm[i]->id.daddr.a6;
> > +				local.in6 = (struct in6_addr *)
> > +					xfrm[i]->props.saddr.a6;
> > +#endif
>
> You set the addresses above ..
>
..
>
> and don't seem to use them for anything.
>

Right. Thought I removed that [redundant code], but apparently only on the 
ipv6 side, thanks.

>
> > diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
> > +	/* Rule 5: select IPsec BEET */
> > +	for (i = 0; i < n; i++) {
> > +		if (src[i] &&
> > +		    src[i]->props.mode == XFRM_MODE_BEET) {
> > +			dst[j++] = src[i];
> > +			src[i] = NULL;
> > +		}
> > +	}
>
> Just out of interest, is there any particular logic behind the
> ordering of the "rules"?
>

Got me there. Not that familiar with the details of the other modes to make 
even any educated guesses..

> >  	if (likely(j == n))
> >  		goto end;
> >
> > diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
> > index 157bfbd..75fdb7d 100644
> > --- a/net/xfrm/xfrm_policy.c
> > +++ b/net/xfrm/xfrm_policy.c
> > @@ -1299,7 +1299,8 @@ xfrm_tmpl_resolve_one(struct xfrm_policy *policy,
> > struct flowi *fl, xfrm_address_t *local  = saddr;
> >  		struct xfrm_tmpl *tmpl = &policy->xfrm_vec[i];
> >
> > -		if (tmpl->mode == XFRM_MODE_TUNNEL) {
> > +		if (tmpl->mode == XFRM_MODE_TUNNEL ||
> > +		    tmpl->mode == XFRM_MODE_BEET) {
>
> Is this a bugfix?
>
> >  			remote = &tmpl->id.daddr;
> >  			local = &tmpl->saddr;
> >  			family = tmpl->encap_family;
> > diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
> > index dfacb9c..0a2ff8e 100644
> > --- a/net/xfrm/xfrm_state.c
> > +++ b/net/xfrm/xfrm_state.c
> > @@ -611,7 +611,7 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t
> > *saddr, selector.
> >  			 */
> >  			if (x->km.state == XFRM_STATE_VALID) {
> > -				if (!xfrm_selector_match(&x->sel, fl, family) ||
> > +				if (!xfrm_selector_match(&x->sel, fl, x->sel.family) ||
> >  				    !security_xfrm_state_pol_flow_match(x, pol, fl))
> >  					continue;
> >  				if (!best ||
> > @@ -623,7 +623,7 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t
> > *saddr, acquire_in_progress = 1;
> >  			} else if (x->km.state == XFRM_STATE_ERROR ||
> >  				   x->km.state == XFRM_STATE_EXPIRED) {
> > -				if (xfrm_selector_match(&x->sel, fl, family) &&
> > +				if (xfrm_selector_match(&x->sel, fl, x->sel.family) &&
> >  				    security_xfrm_state_pol_flow_match(x, pol, fl))
> >  					error = -ESRCH;
> >  			}
>
> And these two? Also look like bugfixes ..
> -

Well yes if we're using interfamily anywhere. D'you think they deserve a patch 
for themselves?

Thanks again for reviewing, I'll address the other issues asap. Sort of eager 
to get this out as its been dangling for such a long time, but seems I'm 
taking a lot of things for granted (..as its been sitting around 'ok' for so 
long). 

br, j
