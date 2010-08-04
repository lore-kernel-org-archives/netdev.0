From: Patrick McHardy <kaber@trash.net>
Subject: Re: Yet another bridge netfilter crash
Date: Wed, 04 Aug 2010 18:30:58 +0200
Message-ID: <4C5995C2.1010909@trash.net>
References: <20100723134208.GA6655@gondor.apana.org.au> <4C49A4C6.4070503@trash.net> <20100723150041.GA7301@gondor.apana.org.au> <4C49B296.10009@trash.net> <20100723152609.GA7576@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51619 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750921Ab0HDQbC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Aug 2010 12:31:02 -0400
In-Reply-To: <20100723152609.GA7576@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 23.07.2010 17:26, schrieb Herbert Xu:
> On Fri, Jul 23, 2010 at 05:17:42PM +0200, Patrick McHardy wrote:
>>
>>> There's also the matter of fragments jumping between bridges.
>>
>> Conntrack zones can be used to avoid that, but that currently needs
>> manual configuration.
> 
> I think this is something that we need to fix.  Because as it
> stands, it can still crash if you get the wrong nf_bridge.
> 
> The reason is that skb->dev does not hold a ref count.  So the
> reassembly code just throws it away and always uses the dev of
> the last fragment.
> 
> This breaks when two bridges combine to reassemble a single
> packet, as the nf_bridge attribute of the reassembled packet
> may come from an skb whose device is now dead.  This is then
> used to fill in the skb->dev (via nf_bridge->physindev).

We could perform a new device lookup on reassembly as we do
when expiring a fragment queue, but we probably shouldn't even
be reassembling fragments from different bridges. One way to
avoid this would be to automatically assign each bridge device
to a different conntrack zone, but conntrack zones are limited
to 2^16 and this might also have other unwanted side-effects.

Until we come up with something better the best fix seems to
be to perform the device lookup based on the iif.
