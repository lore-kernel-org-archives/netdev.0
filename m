From: David Miller <davem@davemloft.net>
Subject: Re: [v1 PATCH 0/14] rhashtable: Kill shift/Key netlink
 namespace/Merge jhash
Date: Mon, 16 Mar 2015 00:01:13 -0400 (EDT)
Message-ID: <20150316.000113.1803291537029624713.davem@davemloft.net>
References: <20150315.013613.2034532005621627761.davem@davemloft.net>
	<20150315101004.GA21383@gondor.apana.org.au>
	<20150315104306.GA21999@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54494 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736AbbCPEBP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 00:01:15 -0400
In-Reply-To: <20150315104306.GA21999@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 15 Mar 2015 21:43:06 +1100

> PS I'd love to kill the indirect call on the hash but I think
> you guys need something other than jhash for sockets.  Presumably
> they are not exposed to untrusted parties.  But I really wonder
> whether that is still the case given things like namespaces where
> even root may be untrusted.

In my opinion the biggest architectural fault of rhashtables is
these damn callbacks, look at the assembler for a simple hash
lookup, it's disgusting.

Two callbacks, _two_.

That also means the hash lookup can't be a leaf function, and we take
two mispredicted indirect calls as well.  Not acceptable.

This is pure overhead from overengineering in my opinion and I'd much
rather have code duplication than this.

We should have rhashtable_lookup_compare() be a macro, for which the
caller provides the hash function and compare operation inline.

Otherwise when we convert things like inet_hashtables.c to rhashtable
it's going to be a regression that will definitely show up in
microbenchmarks.

So essentially I think the rhashtables interface to how the keys are
described to the user is inside out.  rhashtable should just provide
the outer-framework, and the user should provide the minute details of
the key hashing and comparison in something that gets expanded inline.
