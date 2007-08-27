From: James Chapman <jchapman@katalix.com>
Subject: Re: RFC: issues concerning the next NAPI interface
Date: Mon, 27 Aug 2007 22:41:43 +0100
Message-ID: <46D34517.4010505@katalix.com>
References: <46D1D634.7060007@katalix.com>	<20070826.185815.93042514.davem@davemloft.net>	<46D2F301.7050105@katalix.com> <20070827.140251.95055210.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, ossthema@de.ibm.com,
	akepner@sgi.com, netdev@vger.kernel.org, raisch@de.ibm.com,
	themann@de.ibm.com, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, meder@de.ibm.com, tklein@de.ibm.com,
	stefan.roscher@de.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933915AbXH0VxI@vger.kernel.org>
In-Reply-To: <20070827.140251.95055210.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: James Chapman <jchapman@katalix.com>
> Date: Mon, 27 Aug 2007 16:51:29 +0100
> 
>> To implement this, there's no need for timers, hrtimers or generic NAPI 
>> support that others have suggested. A driver's poll() would set an 
>> internal flag and record the current jiffies value when finding 
>> workdone=0 rather than doing an immediate napi_complete(). Early in 
>> poll() it would test this flag and if set, do a low-cost test to see if 
>> it had any work to do. If no work, it would check the saved jiffies 
>> value and do the napi_complete() only if no work has been done for a 
>> configurable number of jiffies. This keeps interrupts disabled longer at 
>> the expense of many more calls to poll() where no work is done. So 
>> critical to this scheme is modifying the driver's poll() to fastpath the 
>> case of having no work to do while waiting for its local jiffy count to 
>> expire.
>>
>> Here's an untested patch for tg3 that illustrates the idea.
> 
> It's only going to work with hrtimers, these interfaces can
> process at least 100,000 per jiffies tick.

I don't understand where hrtimers or interface speed comes in. If the 
CPU is fast enough to call poll() 100,000 times per jiffies tick, it 
means 100,000 wasted poll() calls while the netdev migrates from active 
to poll-off state. Hence the need to fastpath the "no work" case in the 
netdev's poll(). These extra poll() calls are tolerable if it avoids 
NAPI thrashing between poll-on and poll-off states for certain packet rates.

> And the hrtimer granularity is going to need to be significantly low,
> and futhermore you're adding a guaranteed extra interrupt (for the
> hrtimer firing) in these cases where we're exactly trying to avoid is
> more interrupts.
> 
> If you can make it work, fine, but it's going to need to be at a
> minimum disabled when the hrtimer granularity is not sufficient.
> 
> But there are huger fish to fry for you I think.  Talk to your
> platform maintainers and ask for an interface for obtaining
> a flat static distribution of interrupts to cpus in order to
> support multiqueue NAPI better.
> 
> In your previous postings you made arguments saying that the
> automatic placement of interrupts to cpus made everything
> bunch of to a single cpu and you wanted to propagate the
> NAPI work to other cpu's software interrupts from there.

I don't recall saying anything in previous posts about this. Are you 
confusing my posts with Jan-Bernd's? Jan-Bernd has been talking about 
using hrtimers to _reschedule_ NAPI. My posts are suggesting an 
alternative mechanism that keeps NAPI active (with interrupts disabled) 
for a jiffy or two after it would otherwise have gone idle in order to 
avoid too many interrupts when the packet rate is such that NAPI 
thrashes between poll-on and poll-off.

> That logic is bogus, because it merely proves that the hardware
> interrupt distribution is broken.  If it's a bad cpu to run
> software interrupts on, it's also a bad cpu to run hardware
> interrupts on.

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development
