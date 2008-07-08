From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH v2] xfrm: Fix inter family IPsec tunnel handling again
Date: Tue, 8 Jul 2008 11:53:35 +0200
Message-ID: <20080708095335.GP9549@secunet.com>
References: <20080705071950.GA26532@secunet.com> <20080705115654.GA18290@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([213.68.205.161]:43068 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751276AbYGHJxk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 05:53:40 -0400
Content-Disposition: inline
In-Reply-To: <20080705115654.GA18290@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 05, 2008 at 07:56:55PM +0800, Herbert Xu wrote:
> > 
> > diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
> > index 7527940..d220ecf 100644
> > --- a/net/xfrm/xfrm_input.c
> > +++ b/net/xfrm/xfrm_input.c
> > @@ -91,11 +91,9 @@ int xfrm_prepare_input(struct xfrm_state *x, struct sk_buff *skb)
> >  	if (err)
> >  		return err;
> >  
> > -	if (x->sel.family == AF_UNSPEC) {
> > -		inner_mode = xfrm_ip2inner_mode(x, XFRM_MODE_SKB_CB(skb)->protocol);
> > -		if (inner_mode == NULL)
> > -			return -EAFNOSUPPORT;
> > -	}
> > +	inner_mode = xfrm_ip2inner_mode(x, XFRM_MODE_SKB_CB(skb)->protocol);
> > +	if (inner_mode == NULL)
> > +		return -EAFNOSUPPORT;
> 
> If sel.family is specified, inner_mode should already be set, no?
> Overriding it would seem insecure.
> 

Actually we are setting sel.family to the outer mode family if it is 
unspecified from userspace, so it is always specified at this point. This was 
changed by 
commit bcf0dda8 ([XFRM]: xfrm_user: fix selector family initialization)
because openswan seems to have problems if sel.family is not initialized.

But now the checks for AF_UNSPEC that are introduced by 
commit df9dcb45 ([IPSEC]: Fix inter address family IPsec tunnel handling)
return false. So the code that tries to choose for the right inner mode if
sel.family was not specified from userspace is not executed and an 
inter family tunnel does not work in this case.

I tried to move the selector family initialization behind the check for 
AF_UNSPEC in xfrm_init_state(). This brings an inter family tunnel to work if 
no selector family is specified from userspace. But yes, if a selector family 
is specified we may send a packet that is not allowed to go. So this patch is 
probaply not what we want.

But what's the right thing to do for inter family tunnels?

Is it expected that the selector family is set explicitly from userspace in 
this case?
Unfortunalely many userspace applications don't do this by default.
In this case there is nothing to fix here but most of the code introduced by 
commit df9dcb45 is obsolete then. 

Or should the kernel try to do the right thing if the selector is not 
specified?
This was probaply the idea of commit df9dcb45. But if we have to initialize the
selector family with something that is not AF_UNSPEC at initialization time of
the xfrm_state, we can't know whether we got a selector family from userspace
or whether it was set by the kernel when we process packets with that 
xfrm_state.  Thus, we can't decide whether we are allowed to modify the 
inner mode. At the moment I don't see an easy solution for this case, 
but perhaps somebody else has an idea.

Steffen
