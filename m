From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH] xfrm: cache bundle lookup results in flow cache
Date: Tue, 23 Mar 2010 11:19:05 +0200
Message-ID: <4BA88789.7060104@iki.fi>
References: <20100319093210.GA23895@gondor.apana.org.au> <4BA349A8.9050105@iki.fi> <20100320151751.GB2950@gondor.apana.org.au> <4BA4F718.3020700@iki.fi> <20100321004659.GA5895@gondor.apana.org.au> <4BA5CC16.9040606@iki.fi> <4BA5D95B.4020004@iki.fi> <20100322035201.GA14457@gondor.apana.org.au> <4BA7B10A.1030302@iki.fi> <4BA86DA1.7090707@iki.fi> <20100323074252.GA27623@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:28661 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751870Ab0CWJTJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 05:19:09 -0400
Received: by ey-out-2122.google.com with SMTP id 9so242234eyd.5
        for <netdev@vger.kernel.org>; Tue, 23 Mar 2010 02:19:07 -0700 (PDT)
In-Reply-To: <20100323074252.GA27623@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Tue, Mar 23, 2010 at 09:28:33AM +0200, Timo Ter=E4s wrote:
>> So, should I go ahead and do the virtualization of the
>> getters and putters?
>=20
> If we're going to have indirect calls per packet then let's at
> least minimise them.  I think one should be enough, i.e., just
> add a ->stale() function pointer to be used in flow_cache_lookup.

Normally, only the getter is called per-packet. So I'm thinking
to have get() that would check for entry being stale or not,
and bump up the refcount.

The resolver can just swap the old entry and call appropriate
_put/_get, so we can avoid virtual calls there.

Thinking more about the flushing of the flow cache. It's basically
only needed to flush before the policies are garbage collected.
This is strictly needed so we can do the atomic_dec() without
turning policy's refcount to zero and causing a leak.

I'm now thinking if it'd be worth doing virtual _put(). This
way we would not need flushing at all for in policy garbage
collector (we could kill flow_cache_flush). We could also
call dst_release immediately in the flow cache _put, which
would release the memory faster. This way we would not need
at all any periodic xfrm_dst checker as flow cache is
regenerated regularly.

The code paths that would require calling the virtual put
are:
- randomization of flow cache (every 10 mins currently)
  from flow_cache_lookup() with bh disabled
- flow cache going too full, from flow_cache_lookup()
  with bh disabled
- cpu notifier

Do you think the virtual _put doing more work would be
too slow?

In that case the plain atomic_dec sounds ok, but we'd then
need to periodically check through the global bundle list
for garbage collection.

Cheers,
  Timo
