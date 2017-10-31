From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: Using the aesni generic gcm(aes) aead in atomic context
Date: Tue, 31 Oct 2017 10:13:45 +0100
Message-ID: <20171031091345.GF30509@secunet.com>
References: <AM4PR0501MB2723742986C5098642C50D01D4590@AM4PR0501MB2723.eurprd05.prod.outlook.com>
 <20171031041015.GB24806@gondor.apana.org.au>
 <AM4PR0501MB27232A20751B0443EBA7B446D45E0@AM4PR0501MB2723.eurprd05.prod.outlook.com>
 <20171031071729.GA25871@gondor.apana.org.au>
 <AM4PR0501MB27231A649C20C10E024C83DBD45E0@AM4PR0501MB2723.eurprd05.prod.outlook.com>
 <20171031073239.GA25958@gondor.apana.org.au>
 <AM4PR0501MB2723C23EAC7467B09587C2C9D45E0@AM4PR0501MB2723.eurprd05.prod.outlook.com>
 <20171031074438.GA26042@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Ilya Lesokhin <ilyal@mellanox.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "sd@queasysnail.net" <sd@queasysnail.net>,
        "Boris Pismenny" <borisp@mellanox.com>,
        "davejwatson@fb.com" <davejwatson@fb.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:40304 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750848AbdJaJNs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 05:13:48 -0400
Content-Disposition: inline
In-Reply-To: <20171031074438.GA26042@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 31, 2017 at 03:44:38PM +0800, Herbert Xu wrote:
> On Tue, Oct 31, 2017 at 07:39:08AM +0000, Ilya Lesokhin wrote:
> > 
> > I think we should consider having a synchronous implementation that falls back
> > to integer implementation when the FPU is not available.
> > This would spare the users from having to handle the asynchronous case.
> > 
> > Hopefully the situation where the FPU is not available is rare enough 
> > So it won't hurt the performance too much.
> 
> For your intended use case I think async processing should work just
> fine as it does for IPsec.

I think Ilya talks about the case where the TLS crypto is intended
to be offloaded to a NIC. In this case we need a software crypto
fallback e.g. if a packet got rerouted to a device that does not
support crypto offloading. For IPsec, we catch these cases in
validate_xmit_skb() either with the ESP GSO handler, or in the non
GSO case with validate_xmit_xfrm(). We currently request for
a sync algorithm to avoid the async handling for this case.

Allowing for async crypto would require some way to handle
async returnes or the -EBUSY case from the crypto layer inside
of a qdisc. Also, in the GSO case it is not clear how to unwind
the GSO call stack on a async return.

I had a discussion with davem at the netfilter workshop about
this. Based on this discussion, I prepared some patches that
I hope to be (RFC) ready until the netdev2.2 next week.
