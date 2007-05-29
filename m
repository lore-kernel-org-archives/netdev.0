From: Herbert Xu <herbert.xu@redhat.com>
Subject: Re: Definition and usage of NETIF_F_HW_SUM?
Date: Wed, 30 May 2007 07:36:18 +1000
Message-ID: <20070529213618.GA9360@gondor.apana.org.au>
References: <20070529135813.63303693@freepuppy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1226 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750815AbXE2VgZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 May 2007 17:36:25 -0400
Content-Disposition: inline
In-Reply-To: <20070529135813.63303693@freepuppy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 29, 2007 at 01:58:13PM -0700, Stephen Hemminger wrote:
> The flag NETIF_F_HW_SUM is being misused. The definition says that the device
> is capable of checksumming any packet. When in fact from usage it seems to
> imply that the device is capable of doing IPV6 as well as IPV4.

That would be a problem.

> Some devices like 8139too do "fake checksum offloading" because they always have to copy
> the packet.
> 
> Some devices like via-rhine, don't really checksum but if they see CHECKSUM_PARTIAL then they
> copy. This is bogus, they should just let higher layer do checksum/copy.

Actually this is OK because if they have to copy it then it's cheaper to
checksum it there.  Both of these should be able to support all protocols.

> Devices like e1000, and bnx2 are broken because they assume only TCP/UDP and IPV4/IPV6. 
> The definition of the flag says other protocols should work, but they probably send the
> hardware into a state of confusion.

I just checked e1000 and it's correct as it does use the csum_offset
when doing TX offload.  However, you're definitely right that bnx2
seems to be broken.

> A few devices take a offset, starting point, and insertion point. This looks like
> the correct model. But no upper layer protocols other than IPV4/IPV6 can do checksum
> offload at present, so it seems moot.

I could easily whip up a patch to get GRE to use it for a start :)

> IMHO the correct solution would be to get rid if NETIF_F_HW_SUM and make a new flag
> NETIF_F_IPV6_SUM. Devices that can checksum both could do NETIF_F_IPV4_SUM|NETI_F_IPV6_SUM.

We should definitely keep NETIF_F_HW_SUM for sane hardware such as the
e1000.  Unfortunately we may just have to invent IPV6_SUM for the broken
ones.

Ccing Michael to see if the bnx2 chip can actually do offset-based
checksum offload.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
