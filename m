From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] GRO scalability
Date: Sat, 6 Oct 2012 12:11:55 +0800
Message-ID: <20121006041155.GA27134@gondor.apana.org.au>
References: <1348750130.5093.1227.camel@edumazet-glaptop>
 <CAEP_g=-JAYHXM86AYNp7BhDV+eqfkKVgC+SJS1MVdo0K8fRLSQ@mail.gmail.com>
 <1348769294.5093.1566.camel@edumazet-glaptop>
 <1348769990.5093.1584.camel@edumazet-glaptop>
 <CAEP_g=8B7xZPxye0Kuu-EVKpTDt1a3nsJKb61aaYaqOGsYGx8w@mail.gmail.com>
 <1348841041.5093.2477.camel@edumazet-glaptop>
 <CAEP_g=_nSb-ite51PM-E8SY53yOPiZs8N3gDrYNc0L4OU2Ht=A@mail.gmail.com>
 <1349448747.21172.113.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@nicira.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sting.hengli.com.au ([178.18.18.71]:60552 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752580Ab2JFEME (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Oct 2012 00:12:04 -0400
Content-Disposition: inline
In-Reply-To: <1349448747.21172.113.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 05, 2012 at 04:52:27PM +0200, Eric Dumazet wrote:
> Current GRO cell is somewhat limited :
> 
> - It uses a single list (napi->gro_list) of pending skbs
> 
> - This list has a limit of 8 skbs (MAX_GRO_SKBS)
> 
> - Workloads with lot of concurrent flows have small GRO hit rate but
>   pay high overhead (in inet_gro_receive())
> 
> - Increasing MAX_GRO_SKBS is not an option, because GRO
>   overhead becomes too high.

Yeah these were all meant to be addressed at some point.

> - Packets can stay a long time held in GRO cell (there is
>   no flush if napi never completes on a stressed cpu)

This should never happen though.  NAPI runs must always be
punctuated just to guarantee one card never hogs a CPU.  Which
driver causes these behaviour?

>   Some elephant flows can stall interactive ones (if we receive
>   flood of non TCP frames, we dont flush tcp packets waiting in
> gro_list)

Again this should never be a problem given the natural limit
on backlog processing.

> What we could do :
> 
> 1) Use a hash to avoid expensive gro_list management and allow
>    much more concurrent flows.
> 
> Use skb_get_rxhash(skb) to compute rxhash
> 
> If l4_rxhash not set -> not a GRO candidate.
> 
> If l4_rxhash set, use a hash lookup to immediately finds a 'same flow'
> candidates.
> 
> (tcp stack could eventually use rxhash instead of its custom hash
> computation ...)

Sounds good to me.

> 2) Use a LRU list to eventually be able to 'flush' too old packets,
>    even if the napi never completes. Each time we process a new packet,
>    being a GRO candidate or not, we increment a napi->sequence, and we
>    flush the oldest packet in gro_lru_list if its own sequence is too
>    old.
> 
>   That would give a latency guarantee.

I don't think this should ever be necessary.  IOW, if we need this
for GRO, then it means that we also need it for NAPI for the exact
same reasons.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
