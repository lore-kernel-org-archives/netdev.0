From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 0/5] IPsec parallelization
Date: Tue, 2 Dec 2008 16:19:48 +0800
Message-ID: <20081202081948.GA30063@gondor.apana.org.au>
References: <20081201071614.GP476@secunet.com> <20081201084902.GA19904@gondor.apana.org.au> <20081201.022929.253639406.davem@davemloft.net> <20081201111501.GA20650@gondor.apana.org.au> <20081202075804.GD13998@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	klassert@mathematik.tu-chemnitz.de
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:48746 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751016AbYLBITz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2008 03:19:55 -0500
Content-Disposition: inline
In-Reply-To: <20081202075804.GD13998@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 02, 2008 at 08:58:04AM +0100, Steffen Klassert wrote:
> 
> The parallelization/serialization interface is generic, so the crypto
> layer can use it in the same way as xfrm.

I don't really have an opinion on the padata stuff.  What I'm
objecting to is the way you're putting the parallelism into
xfrm.

> The only network specific information that is used is the knowledge
> of the xfrm_state that a packet uses. On serialization, this helps
> to stay as parallel as possible. Packets that uses the same state must
> go to the same cpu (because of the replay window) packets that use
> different states can go to different cpus.

Maybe I'm missing somthing, but all you're doing is paralleising
based on xfrm_state objects.  You can already do that trivially
in the crypto layer with no network-specific knowledge at all
because each xfrm_state allocates its own tfm objects.

What I'm proposing is that you create a single parallel crypto
algorithm template similar to cryptd (FWIW you could even just
extend cryptd to do this) that does the parallel processing
based on tfms.

This achieves exactly the same thing as your current patch-set
plus:

1) The uesr no longer has to make a system-wide choice of whether
to enable this, instead the control is per-SA through the usual
algorithm selection mechanism which means that this no longer
conflicts with async crypto;

2) There is no change to the xfrm code;

3) The same mechanism can benefit other crypto users such as
disk encryption.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
