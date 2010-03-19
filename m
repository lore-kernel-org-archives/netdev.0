From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH] xfrm: cache bundle lookup results in flow cache
Date: Fri, 19 Mar 2010 09:48:17 +0200
Message-ID: <4BA32C41.2020000@iki.fi>
References: <1268655610-7845-1-git-send-email-timo.teras@iki.fi> <20100319072053.GA22913@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f216.google.com ([209.85.219.216]:59335 "EHLO
	mail-ew0-f216.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750999Ab0CSHsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 03:48:19 -0400
Received: by ewy8 with SMTP id 8so1590502ewy.28
        for <netdev@vger.kernel.org>; Fri, 19 Mar 2010 00:48:18 -0700 (PDT)
In-Reply-To: <20100319072053.GA22913@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Mon, Mar 15, 2010 at 02:20:10PM +0200, Timo Teras wrote:
>> -		policy = flow_cache_lookup(net, fl, dst_orig->ops->family,
>> -					   dir, xfrm_policy_lookup);
>> -		err = PTR_ERR(policy);
>> -		if (IS_ERR(policy)) {
>> -			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTPOLERROR);
>> -			goto dropdst;
>> +		fce = flow_cache_lookup(&net->xfrm.flow_cache,
>> +					fl, family, dir);
>> +		if (fce == NULL)
>> +			goto no_cache;
>> +
>> +		xf = container_of(fce, struct xfrm_flow_cache_entry, fce);
>> +		xfrm_flow_cache_entry_validate(&net->xfrm.flow_cache, fce);
> 
> This doesn't work.
> 
> The flow cache operates without locking as it is a per-cpu cache.
> To make this work you must ensure that you stay on the same CPU
> or use some other form of synchronoisation if you write to the
> object returned.
> 
> AFAICS there is no synchronisation here and you're writing to fce.
> 
> So you'll need to disable preemption around the bit that touches
> fce.

But flow_cache_lookup disables pre-emption until _put is called.
So it should work. Would there be a cleaner way?

However, now I figured that we need to make walk.dead atomic
because it's read some times without taking the policy lock.

- Timo
