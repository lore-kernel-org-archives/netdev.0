From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/4] crypto: af_alg - Allow arbitrarily long algorithm
 names
Date: Fri, 7 Apr 2017 13:25:32 +0800
Message-ID: <20170407052532.GA2023@gondor.apana.org.au>
References: <20170406081509.GB30557@gondor.apana.org.au>
 <E1cw2aP-00085S-Q4@gondobar>
 <32d123fa-5c5f-4db6-d333-24b71639b738@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: Alexander Sverdlin <alexander.sverdlin@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orcrist.hmeau.com ([104.223.48.154]:41228 "EHLO
        deadmen.hmeau.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752083AbdDGFZv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 01:25:51 -0400
Content-Disposition: inline
In-Reply-To: <32d123fa-5c5f-4db6-d333-24b71639b738@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 06, 2017 at 02:32:27PM +0200, Alexander Sverdlin wrote:
>
> > diff --git a/crypto/af_alg.c b/crypto/af_alg.c
> > index 690deca..3556d8e 100644
> > --- a/crypto/af_alg.c
> > +++ b/crypto/af_alg.c
> > @@ -160,11 +160,11 @@ static int alg_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
> >  	if (sock->state == SS_CONNECTED)
> >  		return -EINVAL;
> >  
> > -	if (addr_len != sizeof(*sa))
> > +	if (addr_len < sizeof(*sa))
> >  		return -EINVAL;
> >  
> >  	sa->salg_type[sizeof(sa->salg_type) - 1] = 0;
> > -	sa->salg_name[sizeof(sa->salg_name) - 1] = 0;
> > +	sa->salg_name[sizeof(sa->salg_name) + addr_len - sizeof(*sa) - 1] = 0;
> >  
> >  	type = alg_get_type(sa->salg_type);
> >  	if (IS_ERR(type) && PTR_ERR(type) == -ENOENT) {
> 
> Why should userspace ever extend the structure if salg_name is hardcoded to 64 in if_alg.h?
> This patch doesn't change the behavior at all, or am I missing something?

We cannot change the structure in the user-space API by increasing
its length because that would break backwards compatibility.

What this patch does is relax the size check so that user-space can
pass in a name that is longer than 64 bytes.  This would fail on
older kernels with EINVAL.  Of course, user-space must be modified
to allow for such longer names.  That is beyond the scope of this
patch.

For names shorter than 64 bytes the existing API needs be respected
and user-space must pad it to exactly 64 bytes.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
