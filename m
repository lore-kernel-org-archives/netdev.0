From: Xue Ying <ying.xue0@gmail.com>
Subject: Re: [PATCH] net: remove redundant checking for sock timer state
Date: Fri, 01 Feb 2013 15:14:19 +0800
Message-ID: <510B6B4B.8080205@gmail.com>
References: <1359697980-28613-1-git-send-email-ying.xue@windriver.com>	 <20130201.010946.584437309593473452.davem@davemloft.net> <1359700003.30177.32.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, ying.xue@windriver.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f47.google.com ([209.85.210.47]:37759 "EHLO
	mail-da0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754229Ab3BAHNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2013 02:13:53 -0500
Received: by mail-da0-f47.google.com with SMTP id s35so1625947dak.20
        for <netdev@vger.kernel.org>; Thu, 31 Jan 2013 23:13:53 -0800 (PST)
In-Reply-To: <1359700003.30177.32.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> On Fri, 2013-02-01 at 01:09 -0500, David Miller wrote:
>   
>> From: Ying Xue <ying.xue@windriver.com>
>> Date: Fri, 1 Feb 2013 13:53:00 +0800
>>
>>     
>>> It's unnecessary to check whether the sock timer to be stopped is
>>> pending or not in sk_stop_timer() as del_timer() will do the same
>>> thing later.
>>>
>>> Signed-off-by: Ying Xue <ying.xue@windriver.com>
>>>       
>> Did it even occur to you that when this code was written, this
>> "redundant" testing was also redundant, but that it might have been
>> done on purpose?
>>
>> If you are going to change this code, you must understand why it was
>> written this way, because that is the only context in which you will
>> be able to justify removing the test.
>>
>>     
>
> I had the same reaction but maybe its not anymore a valid thing.
>
> Before commit 55c888d6d ([PATCH] timers fixes/improvements) there was
> indeed a significant cost calling del_timer() because of unconditional
> spinlock acquisition.
>
> But nowadays del_timer() doesn't blindly lock the spinlock.
>
> So I guess we could change all occurrences of :
>
> if (timer_pending(X))
>     del_timer(X);
>
> It would save some bytes of code.
>   
Eric, thanks for your explanation and suggestion.

But I cannot understand why we should first call timer_pending() before 
del_timer() in your proposal.
By my understanding, we might get an unreal timer pending state out of 
timer base lock (ie, lock_timer_base()),
and the "unreal" is only for pending state, on the contrary, the value 
is real for inactive sate.
So calling timer_pending() out of timer base lock scope can make us 
avoid some unnecessary grabbing spin lock operations.
However, in del_timer() there already has placed a timer_pending() 
before lock_timer_base() is called. So why do we need
another before calling del_timer()?

Please you explain more.

Thanks,
Ying

> But please Ying, do a complete patch for net tree, don't send 30
> patches.
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>   
