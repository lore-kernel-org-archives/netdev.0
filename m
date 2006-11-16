From: Kenzo Iwami <k-iwami@cj.jp.nec.com>
Subject: Re: watchdog timeout panic in e1000 driver
Date: Thu, 16 Nov 2006 18:23:10 +0900
Message-ID: <455C2DFE.3050907@cj.jp.nec.com>
References: <4538BFF2.2040207@cj.jp.nec.com> <4538F080.5020003@intel.com> <453DD678.4010606@cj.jp.nec.com> <453E3C0B.5030600@intel.com> <453F6983.6020307@cj.jp.nec.com> <453F7E1F.4020406@intel.com> <45408F7B.3050209@cj.jp.nec.com> <4540C765.4000800@intel.com> <4545E3A4.9090004@cj.jp.nec.com> <454636B0.1010004@intel.com> <20061031032218.GA7804@gmail.com> <45489F59.6030102@cj.jp.nec.com> <455AED05.9010607@cj.jp.nec.com> <455B3C3B.2070308@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Shaw Vrana <shaw@vranix.com>, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([202.32.8.193]:40086 "EHLO
	tyo201.gate.nec.co.jp") by vger.kernel.org with ESMTP
	id S1031152AbWKPJX1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Nov 2006 04:23:27 -0500
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <455B3C3B.2070308@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Thank you for your comment.

>>> I think this problem occurs because interrupt handler is executed in same
>>> CPU as process that acquires semaphore.
>>> How about disabling interrupt while the process is holding the semaphore?
>>> I think this is possible, if the total lock time has been reduced.
>> I created the attached patch based on the method described above.
>> This patch disables interrupt while the process is holding the semaphore.
[...]
> I'm not sure why you would have to disable interrupts when freeing the semaphore, but 
> more importantly I don't want to introduce irq code in the swfw handling functions.
> 
> Since the major (only) user running this piece of code in intterupt context is the 
> watchdog, we might as well see if we can only disable interrupts for that code path, 
> which would only be once per 2 seconds. We don't need to protect the ethtool path into 
> this code as it doesn't run in irq context.
> 
> Would you mind giving attached patch a try and let me know if it works for you? It will 
> disable irqs for a bit longer time than your patch, and it begs for a special 
> check-link-in-watchdog function that doesn't take so damn long :(

I tried your patch, but the system panicked with the same symptom.

This problem occurs because e1000_watchdog is called from the interrupt
handler while ethtool processing is holding the semaphore.

  ethtool processing holding semaphore
    INTERRUPT
      e1000_watchdog waits for semaphore to be released

The semaphore e1000_watchdog is waiting for can only be released when
ethtool resumes from interrupt after e1000_watchdog finishes (basically
a deadlock)

In order to solve this problem, interrupts has to be disabled on the
interrupted side (during ethtool processing) and not during
e1000_watchdog within the interrupt handler.

e1000_get_hw_eeprom_semaphore is called from both the interrupt level
and the normal level, and needs to be protected by irq code. The reason
the patch disables interrupts when freeing the semaphore is because
e1000_swfw_sync_release also calls e1000_get_hw_eeprom_semaphore.

--
  Kenzo Iwami (k-iwami@cj.jp.nec.com)
