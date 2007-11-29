From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: + xfrm_policy-warning-fix.patch added to -mm tree
Date: Thu, 29 Nov 2007 09:32:02 -0800
Message-ID: <20071129093202.c638b45a.akpm@linux-foundation.org>
References: <200711281056.lASAupF5028450@imap1.linux-foundation.org>
	<20071129135132.GI8487@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:48104 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758455AbXK2Rcn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 12:32:43 -0500
In-Reply-To: <20071129135132.GI8487@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 30 Nov 2007 00:51:33 +1100 Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Wed, Nov 28, 2007 at 02:56:51AM -0800, akpm@linux-foundation.org wrote:
> > 
> > The patch titled
> >      xfrm_policy warning fix
> > has been added to the -mm tree.  Its filename is
> >      xfrm_policy-warning-fix.patch
> > 
> > *** Remember to use Documentation/SubmitChecklist when testing your code ***
> > 
> > See http://www.zip.com.au/~akpm/linux/patches/stuff/added-to-mm.txt to find
> > out what to do about this
> > 
> > ------------------------------------------------------
> > Subject: xfrm_policy warning fix
> > From: Andrew Morton <akpm@linux-foundation.org>
> > 
> > Fix this:
> > 
> > net/xfrm/xfrm_policy.c: In function '__xfrm_lookup':
> > net/xfrm/xfrm_policy.c:1449: warning: 'dst' may be used uninitialized in this function
> > 
> > by checking for impossible values in the switch().
> 
> Thanks Andrew.  I've added the following patch to net-2.6.
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> --
> commit 5e5234ff17ef98932688116025b30958bd28a940
> Author: Herbert Xu <herbert@gondor.apana.org.au>
> Date:   Fri Nov 30 00:50:31 2007 +1100
> 
>     [IPSEC]: Fix uninitialised dst warning in __xfrm_lookup
>     
>     Andrew Morton reported that __xfrm_lookup generates this warning:
>     
>     net/xfrm/xfrm_policy.c: In function '__xfrm_lookup':
>     net/xfrm/xfrm_policy.c:1449: warning: 'dst' may be used uninitialized in this function
>     
>     This is because if policy->action is of an unexpected value then dst will
>     not be initialised.  Of course, in practice this should never happen since
>     the input layer xfrm_user/af_key will filter out all illegal values.  But
>     the compiler doesn't know that of course.
>     
>     So this patch fixes this by taking the conservative approach and treat all
>     unknown actions the same as a blocking action.
>     
>     Thanks to Andrew for finding this and providing an initial fix.
>     
>     Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
> index b702bd8..9a4cf2e 100644
> --- a/net/xfrm/xfrm_policy.c
> +++ b/net/xfrm/xfrm_policy.c
> @@ -1344,6 +1344,7 @@ restart:
>  	xfrm_nr += pols[0]->xfrm_nr;
>  
>  	switch (policy->action) {
> +	default:
>  	case XFRM_POLICY_BLOCK:
>  		/* Prohibit the flow */
>  		err = -EPERM;

hm.  If someone feeds a bad value into here we want to know about it rather
than silently fixing it up, don't we?

