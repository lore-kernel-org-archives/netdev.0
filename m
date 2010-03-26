From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH RFC 1/2] flow: virtualize get and entry deletion methods
Date: Fri, 26 Mar 2010 08:17:39 +0200
Message-ID: <4BAC5183.9000308@iki.fi>
References: <1269509091-6440-1-git-send-email-timo.teras@iki.fi>	<1269509091-6440-2-git-send-email-timo.teras@iki.fi> <20100325.122611.267401605.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f221.google.com ([209.85.219.221]:61319 "EHLO
	mail-ew0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753113Ab0CZGRm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Mar 2010 02:17:42 -0400
Received: by ewy21 with SMTP id 21so2025260ewy.25
        for <netdev@vger.kernel.org>; Thu, 25 Mar 2010 23:17:41 -0700 (PDT)
In-Reply-To: <20100325.122611.267401605.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Timo Teras <timo.teras@iki.fi>
> Date: Thu, 25 Mar 2010 11:24:50 +0200
> 
>> This allows to validate the cached object before returning it.
>> It also allows to destruct object properly, if the last reference
>> was held in flow cache. This is also a prepartion for caching
>> bundles in the flow cache.
>>
>> In return for virtualizing the methods, we save on:
>> - not having to regenerate the whole flow cache on policy removal:
>>   each flow matching a killed policy gets refreshed as the getter
>>   function notices it smartly.
>> - we do not have to call flow_cache_flush from policy gc, since the
>>   flow cache now properly deletes the object if it had any references
>>
>> This also means the flow cache entry deletion does more work. If
>> it's too slow now, may have to implement delayed deletion of flow
>> cache entries. But this is a save because this enables immediate
>> deletion of policies and bundles.
>>
>> Signed-off-by: Timo Teras <timo.teras@iki.fi>
> 
> I'm concerned about the new costs being added here.
> 
> We have to now take the policy lock as a reader every time the flow
> cache wants to grab a reference.  So we now have this plus the
> indirect function call new overhead.

If we want to have the flow cache generic, we pretty much need
indirect calls. But considering that it might make sense to cache
bundles, or "xfrm cache entries" on all flow directions (so we can
track both the main and sub policies) we could make it specialized.

> Maybe we can make the dead state check safe to do asynchronously
> somehow?  I wonder if the policy layer is overdue for an RCU
> conversion or similar.

I looked at the code and the policy lock is not needed much anymore.
I think it was most heavily used to protected ->bundles which is
now removed. But yes, I also previously said that ->walk.dead should
probably be converted to atomic_t. It is only written once when
the policy is killed. So we can make it accessible without the lock.

Considering that the whole cache was broken previously, and we
needed to take write lock on policy for each forwarded packet,
it does not sound that bad. Apparently locally originating traffic
directly to xfrm destination (not via gre) would get cached on the
socket dst cache and avoids the xfrm_lookup on fast path entirely(?).

We can get away from the per-cpu design with RCU hash. But I think
we still need to track the hash entries similar to this. Though,
there's probably some other tricks doable with RCU which I'm not
all familiar with. I will take a quick look on the rcu thingy
Herbert mentioned earlier.

> Anyways, something to think about.  Otherwise I don't mind these
> changes.

Ok, I'll add "convert walk.dead to atomic_t" so we can access it
without a lock.

I did also notice that the policy locking is not right exactly.
E.g. migration can touch templates, and we read templates currently
without locks. So I think bundle creation should be protected
with policy read lock. But even this can probably be avoided by
RCU type bundle creation. We just take bundle genid before starting
to create it, create bundle, and check if genid was changed while
doing this we retry.

We might even get away from policy->lock all together. In most
places it's only used to protect walk.dead. And bundle creation
can be synchronizes as above. The only remaining place seems to
be the timer function. I think it's safe to remove locking there
too, and synchronize using timer deletion. All this is because
any changes to policy will result in xfrm_policy replacement:
the old is killed and new one inserted atomically.

Do you think this would work?

- Timo
