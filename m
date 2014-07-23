From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] xfrm: Fix refcount imbalance in xfrm_lookup
Date: Wed, 23 Jul 2014 15:09:38 -0700 (PDT)
Message-ID: <20140723.150938.1689093120175055002.davem@davemloft.net>
References: <1406103487-1656-1-git-send-email-steffen.klassert@secunet.com>
	<1406103487-1656-2-git-send-email-steffen.klassert@secunet.com>
	<1406136073.3363.14.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38310 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933711AbaGWWJj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 18:09:39 -0400
In-Reply-To: <1406136073.3363.14.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 23 Jul 2014 19:21:13 +0200

> On Wed, 2014-07-23 at 10:18 +0200, Steffen Klassert wrote:
>> xfrm_lookup must return a dst_entry with a refcount for the caller.
>> Git commit 1a1ccc96abb ("xfrm: Remove caching of xfrm_policy_sk_bundles")
>> removed this refcount for the socket policy case accidentally.
>> This patch restores it and sets DST_NOCACHE flag to make sure
>> that the dst_entry is freed when the refcount becomes null.
>> 
>> Fixes: 1a1ccc96abb ("xfrm: Remove caching of xfrm_policy_sk_bundles")
>> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
>> ---
>>  net/xfrm/xfrm_policy.c | 2 ++
>>  1 file changed, 2 insertions(+)
>> 
>> diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
>> index a8ef510..0525d78 100644
>> --- a/net/xfrm/xfrm_policy.c
>> +++ b/net/xfrm/xfrm_policy.c
>> @@ -2097,6 +2097,8 @@ struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
>>  				goto no_transform;
>>  			}
>>  
>> +			dst_hold(&xdst->u.dst);
>> +			xdst->u.dst.flags |= DST_NOCACHE;
>>  			route = xdst->route;
>>  		}
>>  	}
> 
> 
> Hmm... are you sure ?
> 
> Before 1a1ccc96abb we did a dst_hold() because we kept the dst in
> xfrm_policy_sk_bundles. So keeping a reference count was mandatory.
> 
> But after, I don't understand why it is needed at all.

It should be needed.

We create a new bundle here, from scratch, based upon the socket
policy.

Such new bundles make routes with dst refcount == 0.

All callers expect that the route given back to them is either
the original 'dst' passed into xfrm_lookup() unmolested, or a
new 'dst' having a refcount taken for this caller.

That's why all call sites expect that they can just go
"dst_release(dst)" and these objects it works.

So, if we returned 'dst' with refcount == 0 it would not work.
