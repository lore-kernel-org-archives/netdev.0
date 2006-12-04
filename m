From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH][IPSEC][6/7] inter address family ipsec tunnel
Date: Mon, 4 Dec 2006 14:30:41 +1100
Message-ID: <20061204033041.GA11572@gondor.apana.org.au>
References: <20061203.175847.08320724.davem@davemloft.net> <20061203.182814.74748972.davem@davemloft.net> <45738CE1.3070304@miyazawa.org> <20061203.191208.74749805.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kazunori@miyazawa.org, miika@iki.fi, Diego.Beltrami@hiit.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35337 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1759209AbWLDDbp
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 22:31:45 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20061203.191208.74749805.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 03, 2006 at 07:12:08PM -0800, David Miller wrote:
> 
> For the time being I'm thinking of using the following
> patch.  I removed the xp->family clobbering, the AF_KEY
> changes don't do this, so there is no reason for the
> xfrm_user side to do it either.

This patch looks fine to me.

I am to blame for the genesis of this problem so here is a bit
of background :)

At the very start we had one family field and that was
xfrm_userpolicy_info->sel->family.  Since the only transforms
were of the same family it was sufficient.

I then added xfrm_user_tmpl->family in order to allow for the
possibility of inter-family transforms.  Unfortunately I didn't
add a check to the kernel to verify its value.  As a result,
Openswan was able to get away with leaving it as zero.

If anyone is overly worried about the potential of apps leaving
garbage rather than zero in this field, we can combine it with
xfrm_userpolicy_info->flags which should currently be zero.

So all we need to do is add a new flag (perhaps XFRM_POLICY_INTERFAMILY)
which must be set for the template family fields to be used.


As for xfrm_policy->family, it's an internal field that has lived
past its use-by date.  It should be replaced either by xp->sel.family
or xp->xfrm_vec[x].family where appropriate.

The family only makes sense when interpreted together with a layer
of address.  So we don't really need an overall family for a policy.

I hope that at the end of this patch series xp->family can be removed
altogether.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
