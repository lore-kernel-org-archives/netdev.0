From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH RFC net-next 0/4] bridge: improve cache utilization
Date: Tue, 31 Jan 2017 19:45:21 +0100
Message-ID: <2f7ed09f-6ed9-2490-7814-3ebacf622da7@cumulusnetworks.com>
References: <1485876718-18091-1-git-send-email-nikolay@cumulusnetworks.com>
 <20170131083919.51a3ac9f@xeon-e3>
 <31c4c454-b0e5-5a84-ffce-c8b39fa2d301@cumulusnetworks.com>
 <2c59b56a-4a8b-0f32-31d1-1e8c44643958@cumulusnetworks.com>
 <20170131102137.5659d280@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        davem@davemloft.net
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:37824 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751585AbdAaSxy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 13:53:54 -0500
Received: by mail-wm0-f46.google.com with SMTP id v77so1563077wmv.0
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 10:53:44 -0800 (PST)
In-Reply-To: <20170131102137.5659d280@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31/01/17 19:21, Stephen Hemminger wrote:
> On Tue, 31 Jan 2017 19:09:09 +0100
> Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:
> 
>> On 31/01/17 17:41, Nikolay Aleksandrov wrote:
>>>>
>>>> I agree with the first 3 patches, but not the last one.
>>>> Changing the API just for a performance hack is not necessary. Instead make
>>>> the algorithm smarter and use per-cpu values.
>>>>  
>>>
>>> Thanks for the feedback, I would very much prefer any of the other two approaches
>>> I tried (per-cpu pool and per-cpu for each fdb), from the two the second one -
>>> per-cpu for each fdb is much simpler, so would it be acceptable to do per-cpu allocation
>>> for each fdb ?
>>>
>>>
>>>   
>>
>> Okay, after some more testing the version with per-cpu per-fdb allocations, at 300 000 fdb entries
>> I got 120 failed per-cpu allocs which seems okay. I'll wait a little more and will repost the series
>> with per-cpu allocations and without the RFC tag.
>>
>> Thanks,
>>  Nik
>>
> 
> You could also use a mark/sweep algorithm (rather than recording updated).
> It turns out that clearing is fast (can be unlocked).
> The timer workqueue can mark all fdb entries (during scan), then in forward
> function clear the bit if it is set. This would turn writes into reads.

The wq doesn't have a strict next call, it is floating depending on the soonest
expire, this can cause issues as we don't know when last we've reset the bit and
using the scan interval resolution will result in big offsets when purging entries.

> 
> To keep the API for last used, just change the resolution to be scan interval.
> 

With default 300 second resolution ? People will be angry. :-)
Also this has to happen for both "updated" and "used", they're both causing trouble.
In fact "used" is much worse than "updated", because it's written to by all who transmit
to that fdb.

Actually to start we can do something much simpler - just always update "used" at most
once per 1/10 of ageing_time for example. The default case would give us an update every
30 seconds if the fdb is actually used or we can cap it at 10 seconds.
The "updated" we move to its own cache line and with proper config (bind ports to CPUs)
it will be fine.

What do you think ?
