From: "Christopher Hall" <christopher.s.hall@intel.com>
Subject: Re: [PATCH v4 1/4] Produce system time from correlated clocksource
Date: Mon, 19 Oct 2015 17:18:39 -0700
Message-ID: <op.x6r25dza1774gr@chall-mobl2.amr.corp.intel.com>
References: <1444675522-4198-1-git-send-email-christopher.s.hall@intel.com>
 <1444675522-4198-2-git-send-email-christopher.s.hall@intel.com>
 <alpine.DEB.2.11.1510132116480.25029@nanos>
 <op.x6iyd7gq1774gr@chall-mobl2.amr.corp.intel.com>
 <alpine.DEB.2.11.1510151014330.3960@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, hpa@zytor.com, mingo@redhat.com,
	john.stultz@linaro.org, peterz@infradead.org, x86@kernel.org,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kevin.b.stanton@intel.com
To: "Thomas Gleixner" <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.11.1510151014330.3960@nanos>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas,

On Thu, 15 Oct 2015 01:15:57 -0700, Thomas Gleixner <tglx@linutronix.de>  
wrote:
>> >
>> > > +#define SHADOW_HISTORY_DEPTH 7
>> >
>> > And that number is 7 because?
>>
>> Due to power of 2 it will be 8 instead. As above the useful history is  
>> 8-2*1
>> ms (1 ms is the minimum jiffy length).  Array size 4 would not be enough
>> history for the DSP which requires 4 ms of history, in the worst case.
>
> And how exactly becomes 7 magically 8?

I'm making the array size a power of two, per your suggestion.

In my view, the candidate array sizes are 4 and 8.  But the DSP driver  
code requires that it be at least 8.  Here is my reasoning:

The number of shadow_timekeeper array elements that contain useful history  
is n-2 where n is the size of the shadow_timekeeper array.  This is true  
because shadow_timekeeper[shadow_index] is a copy of tk_core.timekeeper  
(this isn't history).  The next entry of the shadow_timekeeper array may  
be in-flight and contain invalid information, because update_wall_time()  
makes changes to the next entry of shadow timekeeper outside of the  
sequence lock.  If that occurs, get_correlated_timestamp() would not be  
notified of this change through a change in sequence number.

Combining these two requirements, the candidate array sizes and their  
effective history sizes is:

Array Size   Effective History (in elements)
==========   ===============================
4            2				
8            6
16           14

update_wall_clock() checks that the number of elapsed cycles is >=  
tk->cycle_interval before performing any updates to shadow_timekeeper.   
The minimum cycle count (and minimum time) that is contained in each  
history element is equal to cycle_interval which represents a time period  
of 1/HZ seconds.  The smallest configurable period for cycle_interval is 1  
ms (in cycles).  Each history element, therefore, is guaranteed to contain  
1 ms of history for all kernel configurations.  For correct operation of  
the DSP using the proposed ART->system time API we need at least 4 ms of  
history.  To guarantee this much history is available, the array size  
needs to be 8.

Array Size   Minimum Effective History (in ms)
==========   =================================
4            2				
8            6    <----
16           14

Does this make sense for the choice of array size 8?

> Make it a seperate function which can hand in the information and
> leave the PTP specific sample/conversion function alone.

OK.  The audio driver code will conform to the original correlated  
clocksource API.

FYI, I will be away from work and email until 10/28.  Any responses will  
be delayed until then.

Thanks,
Chris
