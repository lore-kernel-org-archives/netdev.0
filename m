From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [PATCHv4 net-next-2.6 1/5] XFRM,IPv6: Remove xfrm_spi_hash() dependency on destination address
Date: Thu, 07 Oct 2010 22:13:04 +0200
Message-ID: <87fwwhoj73.fsf@small.ssi.corp>
References: <cover.1286139128.git.arno@natisbad.org>
	<5a0e320544e253cc903cfd3292600b6bec044a5f.1286139129.git.arno@natisbad.org>
	<20101004083306.GA17939@gondor.apana.org.au>
	<8739sl8yw5.fsf@small.ssi.corp>
	<20101005021114.GA25681@gondor.apana.org.au>
	<20101005041707.GA26458@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from copper.chdir.org ([88.191.97.87]:57835 "EHLO copper.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754900Ab0JGUMS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Oct 2010 16:12:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Herbert Xu <herbert@gondor.apana.org.au> writes:

> On Tue, Oct 05, 2010 at 10:11:14AM +0800, Herbert Xu wrote:
>>
>> I'm thinking about the case where each remote end (or one remote
>> end with many IP addresses) chooses to use a single SPI which then
>> all gets hashed to the same bucket.
>> 
>> Outbound SAs are hashed into the same SPI hash table as inbound SAs.
>
> Another solution would be to create a hash table for inbound SAs
> only.  Unfortunately I don't think we have anything in our current
> user-interface to indicate whether an SA is inbound or outbound.
>
> So to do this you'll need to use a heuristic such as doing a
> lookup on the source/destination address at insertion time.

I spent some time scratching my head trying to find a good solution. It
would indeed be perfect to have a specific hash table for inbound
SA. But as you point, this would only be via a heuristic at insertion
time and there are various cases which would not work: a SA can be
installed w/o any of the addresses being configured on the system.

I think I will try the following alternative approach based on your
comments and proposals:

 - drop my patch to change spi hash computation
 - handle destination address remapping during input upon failure of
   xfrm_state_lookup()
 - handle source address remapping as it is currently done in the patch,
   i.e. by comparing received one against x->props.saddr once the
   state found and do 

To support the destination address remapping, I will have to reverse the
logic I currently have for destination remapping states, to allow the
lookup to be done based on the on-wire address (CoA) instead of the
address in the SA (HoA). If a remapping state is found for the on-wire
address, then a new lookup is done using the associated HoA this time.

I think it would make the feature easier less intrusive for the IPsec
stack.

Thanks for your support and patience, Herbert.

a+
