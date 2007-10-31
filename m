From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [UDP6]: Restore sk_filter optimisation
Date: Wed, 31 Oct 2007 22:42:57 +0800
Message-ID: <20071031144256.GA28137@gondor.apana.org.au>
References: <20070306012010.GA25763@gondor.apana.org.au> <20071029153320.d2c00f62.mitch@linux.vnet.ibm.com> <20071029125328.GA5453@gondor.apana.org.au> <20071031230545.9be711d4.mitch@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1465 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755129AbXJaOnb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 10:43:31 -0400
Content-Disposition: inline
In-Reply-To: <20071031230545.9be711d4.mitch@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 31, 2007 at 11:05:45PM +0900, Mitsuru Chinen wrote:
>
> > >  1. udp6InDatagrams is incremented instead of udpInErrors
> > >  2. In userland, recvfrom() replies an error with EAGAIN.
> > >     recvfrom() wasn't aware of such a packet before.
> > > 
> > > Are these changes intentional?
>
> As far as I tested, this doesn't happen with the old code even if
> a filter is attached. However, this happen with the new code
> without a filter and I don't see this rather when a filter is
> attached. So, I'm afraid it's new.

Sorry, I read the patch the wrong way around :)

1) is just an accounting issue.  It shouldn't be too difficult
to fix it up.  In fact, I think udpInErrors will still be
incremented once we detect the error.

2) shouldn't be an issue because we've already solved the
problem by making poll/select do the checksum verification
before indiciating that the socket is readable.

> > And, we're not sure how much the "optimization"'s benefit is.
> > It is even worse when we are hand

The checksum verification is costly because we have to bring
the payload into cache.  Since filters are very rare it's
worthwhile to postpone the checksum verification for the common
case.

Also as a general rule, we want to avoid divergent behaviour
between IPv4 and IPv6.  So for changes like this we should
really modify both stacks in future rather than have each
stack do its own thing.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
