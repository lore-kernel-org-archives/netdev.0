From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH RFC net-next 4/4] bridge: add ability to turn off fdb used
 updates
Date: Sat, 4 Feb 2017 17:45:14 +0100
Message-ID: <dbd755ac-bdb3-cc1e-0764-8fe460d0d4be@cumulusnetworks.com>
References: <1485876718-18091-1-git-send-email-nikolay@cumulusnetworks.com>
 <1485876718-18091-5-git-send-email-nikolay@cumulusnetworks.com>
 <20170202.214737.1978812863222769540.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        stephen@networkplumber.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:37273 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751070AbdBDQpR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 11:45:17 -0500
Received: by mail-wm0-f52.google.com with SMTP id v77so71425732wmv.0
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2017 08:45:16 -0800 (PST)
In-Reply-To: <20170202.214737.1978812863222769540.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/02/17 03:47, David Miller wrote:
> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Date: Tue, 31 Jan 2017 16:31:58 +0100
> 
>> @@ -197,7 +197,8 @@ int br_handle_frame_finish(struct net *net, struct sock *sk, struct sk_buff *skb
>>  		if (dst->is_local)
>>  			return br_pass_frame_up(skb);
>>  
>> -		dst->used = jiffies;
>> +		if (br->used_enabled)
>> +			dst->used = jiffies;
> 
> Have you tried:
> 
> 	if (dst->used != jiffies)
> 		dst->used = jiffies;
> 
> If that isn't effective, you can tweak the test to decrease the
> granularity of the value.  Basically, if dst->used is within
> 1 HZ of jiffies, don't do the write.
> 
> I suspect this might help a lot, and not require a new bridging
> option.
> 

After running a ton of tests with different granularity settings and improvements
similar to:

br->jiffy_update_mask = rounddown_pow_of_two(clock_t_to_jiffies(1)) - 1

fast_path:
if (!(jiffies & br->jiffy_update_mask) && dst->used != jiffies)
	dst->used = jiffies;

in order to bring down the updates even lower, it seems that just going with the
comparison is enough - I can't see any measurable win by bringing it even lower (e.g.
HZ / USER_HZ granularity).

So I'm going with the simpler approach and just doing the comparison.

Thanks,
 Nik
