From: Kenzo Iwami <k-iwami@cj.jp.nec.com>
Subject: Re: watchdog timeout panic in e1000 driver
Date: Tue, 21 Nov 2006 19:16:39 +0900
Message-ID: <4562D207.60301@cj.jp.nec.com>
References: <36D9DB17C6DE9E40B059440DB8D95F52013ABFE9@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	Shaw Vrana <shaw@vranix.com>, netdev@vger.kernel.org,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([202.32.8.193]:15514 "EHLO
	tyo201.gate.nec.co.jp") by vger.kernel.org with ESMTP
	id S1030824AbWKUKQ6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Nov 2006 05:16:58 -0500
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F52013ABFE9@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Thank you for your comment.

>>   ethtool processing holding semaphore
>>     INTERRUPT
>>       e1000_watchdog waits for semaphore to be released
>>
>> The semaphore e1000_watchdog is waiting for can only be released when
>> ethtool resumes from interrupt after e1000_watchdog finishes
>> (basically a deadlock)
>>
>> In order to solve this problem, interrupts has to be disabled on the
>> interrupted side (during ethtool processing) and not during
>> e1000_watchdog within the interrupt handler.
>>
>> e1000_get_hw_eeprom_semaphore is called from both the interrupt level
>> and the normal level, and needs to be protected by irq code. The
>> reason the patch disables interrupts when freeing the semaphore is
>> because e1000_swfw_sync_release also calls
>> e1000_get_hw_eeprom_semaphore. 
> 
> Doesn't this just mean that we need a spinlock or some other kind of
> semaphore around acquiring, using, and releasing this resource?  We keep
> going around and around about this but I'm pretty sure spinlocks are
> meant to be able to solve exactly this issue.
> 
> The problem is going to get considerably more nasty if we need to hold a
> spinlock with interrupts disabled for a significant amount of time, at
> which point a semaphore of some kind with a spinlock around it would
> seem to be more useful.

Even if spin_lock() was used to protect this resource, it is still possible
for an interrupt to kick in and call e1000_watchdog. In this case,
e1000_get_software_semaphore() will be called from within the interrupt
handler and the problem will still occur.

In order to solve this problem, interrupt should be disabled (for example,
spin_lock_irqsave).
The interrupt handler can't run while the process is holding this resource,
and this problem doesn't occur.

> I'll work with Auke to see if we can come up with another try.

Do you have any updates about your test code?

-- 
  Kenzo Iwami (k-iwami@cj.jp.nec.com)
