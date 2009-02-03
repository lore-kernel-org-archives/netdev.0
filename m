From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Tue, 3 Feb 2009 23:12:09 +1100
Message-ID: <20090203121209.GA9154@gondor.apana.org.au>
References: <20090202080855.GA4129@ff.dom.local> <20090202.001854.261399333.davem@davemloft.net> <20090202084358.GB4129@ff.dom.local> <20090202.235017.253437221.davem@davemloft.net> <20090203094108.GA4639@ff.dom.local> <20090203111012.GA16878@ioremap.net> <20090203112431.GA8746@gondor.apana.org.au> <20090203114944.GA21957@ioremap.net> <20090203115313.GA9018@gondor.apana.org.au> <20090203120715.GA22427@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, w@1wt.eu,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33568 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753229AbZBCMNG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 07:13:06 -0500
Content-Disposition: inline
In-Reply-To: <20090203120715.GA22427@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 03, 2009 at 03:07:15PM +0300, Evgeniy Polyakov wrote:
>
> How many? A hundred or so descriptors (or even several thousands) -
> this really does not scale for the somewhat loaded IO servers, that's
> why we frequently get questions why dmesg is filler with order-3 and
> higher allocation failure dumps.

I think you've misunderstood my suggested scheme.

I'm suggesting that we keep the driver initialisation path as is,
so however many skb's the driver is allocating at open() time
remains unchanged.  Usually this would be the number of entries
on the ring buffer.  We can't do any better than that since if
the hardware can't do SG then you'll just have to find this many
contiguous buffers.

The only change we need to make is at receive time.  Instead of
always pushing the received skb into the stack, we should try to
allocate a linear replacement skb, and if that fails, allocate
a fragmented skb and copy the data into it.  That way we can
always push a linear skb back into the ring buffer.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
