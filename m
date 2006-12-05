From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: watchdog timeout panic in e1000 driver
Date: Mon, 04 Dec 2006 16:46:06 -0800
Message-ID: <4574C14E.2060108@intel.com>
References: <36D9DB17C6DE9E40B059440DB8D95F52013ABFE9@orsmsx418.amr.corp.intel.com> <4562D207.60301@cj.jp.nec.com> <4573E6FD.3030905@cj.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Shaw Vrana <shaw@vranix.com>, netdev@vger.kernel.org,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:22730 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967922AbWLEAw6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 19:52:58 -0500
To: Kenzo Iwami <k-iwami@cj.jp.nec.com>
In-Reply-To: <4573E6FD.3030905@cj.jp.nec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kenzo Iwami wrote:
> Hi,
> 
>>> Doesn't this just mean that we need a spinlock or some other kind of
>>> semaphore around acquiring, using, and releasing this resource?  We keep
>>> going around and around about this but I'm pretty sure spinlocks are
>>> meant to be able to solve exactly this issue.
>>>
>>> The problem is going to get considerably more nasty if we need to hold a
>>> spinlock with interrupts disabled for a significant amount of time, at
>>> which point a semaphore of some kind with a spinlock around it would
>>> seem to be more useful.
>> Even if spin_lock() was used to protect this resource, it is still possible
>> for an interrupt to kick in and call e1000_watchdog. In this case,
>> e1000_get_software_semaphore() will be called from within the interrupt
>> handler and the problem will still occur.
>>
>> In order to solve this problem, interrupt should be disabled (for example,
>> spin_lock_irqsave).
>> The interrupt handler can't run while the process is holding this resource,
>> and this problem doesn't occur.
>>
>>> I'll work with Auke to see if we can come up with another try.
>> Do you have any updates about your test code?
> 
> Does the fix I previously proposed have problems?
> If it does, I'd like to help find investigate another fix to solve
> this problem.

There are several issues that are conflicting and mixing that make it less than 
intuitive to decide what the better fix is.

Most of all, we discussed that adding a spinlock is not going to fix the underlying 
problem of contention, as the code that would need to be spinlocked can sleep. Not a 
good thing.

Adding state tracking code in the form of atomics might solve the issue too, but then we 
need to do this in quite a few locations. And it comes down to the fact that we really 
want all users of the semaphore to halt in case it is in use.

Reducing the swfw semaphore time is a usefull exercise, but requires an amazing amount 
of changes to all of the phy code to make sure we're not locking it too long, and even 
then I doubt that we will reduce the maximum lock time to acceptable levels.

The watchdog then, appears to needlessly lock the semaphore every two seconds. this is 
because even though the link is up and we're already setup, we go through the trouble of 
doing all the PHY reads, which are protected by the semaphores.

I'm currently testing a watchdog version which completely bypasses these checks in case 
the MAC didn't detect a link change, and we already are setup completely. In that case, 
all we need to do is update stats and reschedule the timer.

I'll keep you posted on progress.

Cheers,

Auke
