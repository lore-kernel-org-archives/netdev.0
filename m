From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: af_key: fix sleeping under rcu
Date: Tue, 04 Mar 2014 16:40:14 -0500 (EST)
Message-ID: <20140304.164014.2134736768960109055.davem@davemloft.net>
References: <1393935984-8733-1-git-send-email-nikolay@redhat.com>
	<1393935984-8733-2-git-send-email-nikolay@redhat.com>
	<063D6719AE5E284EB5DD2968C1650D6D0F6D0092@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nikolay@redhat.com, netdev@vger.kernel.org, davej@redhat.com,
	steffen.klassert@secunet.com, fan.du@windriver.com
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37325 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756776AbaCDVkR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 16:40:17 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6D0092@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Laight <David.Laight@ACULAB.COM>
Date: Tue, 4 Mar 2014 12:46:48 +0000

> From: Nikolay Aleksandrov
>> There's a kmalloc with GFP_KERNEL in a helper
>> (pfkey_sadb2xfrm_user_sec_ctx) used in pfkey_compile_policy which is
>> called under rcu_read_lock. Adjust pfkey_sadb2xfrm_user_sec_ctx to have
>> a gfp argument and adjust the users.
> ...
>> @@ -3239,7 +3240,7 @@ static struct xfrm_policy *pfkey_compile_policy(struct sock *sk, int opt,
>>  		}
>>  		if ((*dir = verify_sec_ctx_len(p)))
>>  			goto out;
>> -		uctx = pfkey_sadb2xfrm_user_sec_ctx(sec_ctx);
>> +		uctx = pfkey_sadb2xfrm_user_sec_ctx(sec_ctx, GFP_ATOMIC);
>>  		*dir = security_xfrm_policy_alloc(&xp->security, uctx);
>>  		kfree(uctx);
> 
> This looks like the only one that isn't passed GFP_KERNEL.
> It looks as though it is missing the check for the allocation failing
> (there might be a check inside security_xfrm_policy_alloc()).
> 
> In any case it looks as though this ought to be codeable without
> the allocation of 'uctx' - since it is freed a line later.

Unfortunately, it is not possible to avoid allocations.  The uctx is
of a variable size, because it is a base struct, with a variable
length part afterwards.
