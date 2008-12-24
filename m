From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH] [IPSEC]: Change the ICV length of sha256 to 128 bits
Date: Wed, 24 Dec 2008 11:33:55 -0700
Message-ID: <20081224183355.GB26084@obsidianresearch.com>
References: <20081224060225.GA26084@obsidianresearch.com> <20081224085940.GA24830@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([142.179.161.236]:48302 "EHLO
	quartz.edm.orcorp.ca" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750946AbYLXSd6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2008 13:33:58 -0500
Content-Disposition: inline
In-Reply-To: <20081224085940.GA24830@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 24, 2008 at 07:59:40PM +1100, Herbert Xu wrote:
> On Tue, Dec 23, 2008 at 11:02:25PM -0700, Jason Gunthorpe wrote:
> > The existing setting is 96 bits which does not match the RFCs and is
> > not negotiable via IKEv2. RFC 4868 says the ICV should be 128 bits,
> > and IKEv2 uses AUTH_HMAC_SHA2_256_128 = 12 to identify it.
> > 
> > git blame says this setting was made before RFC 4868 was published,
> > so I'm not sure that it was chosen with any standard in mind.
> > 
> > NOTE: This 'breaks' the user space API, however at least StrongSwan
> > 4.2.9's charon already associates AUTH_HMAC_SHA2_256_128 with
> > the transform name 'sha256'.
> > 
> > Signed-off-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
 
> The 96 bits is actually still correct for the auth algorithm IDs
> 5, 6, and 7.  The parameters in 4868 have been assigned new IDs
> starting from 12.

Oh? Ok, I didn't realize there was something that defined those usages
on PF_KEY. They are not defined for use with IKEv2 at all..

BTW, is there some reason why SADB_X_AALG_SHA2_384HMAC and
SADB_X_AALG_SHA2_512HMAC are absent from the table in xfrm_algos?

> This is easy to do for af_key as it uses IDs to identify the
> algorithms.  To make this work for xfrm, we need to extend the
> auth algorithm specification to include the truncation length,
> just like AEAD.

Yes, I was already thinking this was the best way to support the
128/160 bit ICV lens for MD5/SHA1 that are now defined.

> So if you feel adventurous, please prepare a patch to create a
> new xfrm attribute XFRMA_AUTH2 that uses xfrm_algo_aead instead
> of xfrm_algo, and allow that in place of XFRMA_AUTH.

Thats not too hard, I might have a little time to do that over the
break.

> After that we can restructure the auth algorithm list to be like
> AEAD and then you can add a new set of SHA algorithms for RFC 4868.

It seems like those can be added today, they already have unique
names: hmac(sha384), hmac(sha512)

BTW, Herbert, if this is the way to go can you fix StrongSwan?
Mapping AUTH_HMAC_SHA2_256_128 to 'sha256' in
src/charon/plugins/kernel_netlink/kernel_netlink_ipsec.c is not
correct based on this discussion. It needs to be 'hmac(sha256)' and
use this XFRMA_AUTH2 idea. Similarly for all the SHA-2 family of
functions I guess.

Thanks,
Jason
