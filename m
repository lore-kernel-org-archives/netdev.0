From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH net-next 0/2] net: lls cleanup patches
Date: Tue, 02 Jul 2013 11:45:29 +0300
Message-ID: <51D29329.4060004@linux.intel.com>
References: <20130628125918.14419.36214.stgit@ladj378.jer.intel.com> <20130701.140833.1705666564717621661.davem@davemloft.net> <51D2919F.7050007@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	willemb@google.com, erdnetdev@gmail.com, andi@firstfloor.org,
	hpa@zytor.com, devel-lists@codyps.com, eliezer@tamir.org.il
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51D2919F.7050007@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/07/2013 11:38, Eliezer Tamir wrote:
> On 02/07/2013 00:08, David Miller wrote:
>> From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
>> Date: Fri, 28 Jun 2013 15:59:18 +0300
>>
>>> Here are two cleanup patches.
>>>
>>> 1. fix warning from debug_smp_processor_id().
>>> - reported by Cody P Schafer.
>>>
>
>> Applied, but like Ben said perhaps you want to remember the last cpu you
>> got the sched_clock() measurement from and abort the ll poll if it
>> changes
>> on you instead of using a comparison between two cpus.
>>
>> But then again, since preemption is enabled, the cpu could change
>> back and forth during the sched_clock() call, so you wouldn't be able
>> to reliably detect this anyways.
>>
>> In the grand scheme of things all of this probably doesn't matter at
>> all.
>
> The only thing that really worries me, is the possibility of time
> on the new cpu to be completely random, then we could be back in the
> range where time_after() will be false again and end up polling for
> another year.
>
> A simple way to limit the damage would be to use time_in_range()
> instead of time_after(), then if we have a completely random time we
> would be out of the range and fail safely.
>
> would something like this be an acceptable solution?
>
> ---

actually, this code has a bug.

> -static inline bool can_poll_ll(u64 end_time)
> +static inline bool can_poll_ll(u64 start_time, u64 run_time)
>   {
> -    return !time_after64(ll_sched_clock(), end_time);
> +    return time_in_range64(ll_sched_clock(), start_time,
> +                   start_time + run_time);
>   }
>
this will call sched_clock() twice.

I will send a fix after I test it.

-Eliezer
