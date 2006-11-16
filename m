From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: watchdog timeout panic in e1000 driver
Date: Thu, 16 Nov 2006 09:20:01 -0800
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F52013ABFE9@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Shaw Vrana" <shaw@vranix.com>, <netdev@vger.kernel.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:17049 "EHLO mga02.intel.com")
	by vger.kernel.org with ESMTP id S1161219AbWKPRUD convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Nov 2006 12:20:03 -0500
Content-class: urn:content-classes:message
To: "Kenzo Iwami" <k-iwami@cj.jp.nec.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kenzo Iwami wrote:
>   ethtool processing holding semaphore
>     INTERRUPT
>       e1000_watchdog waits for semaphore to be released
> 
> The semaphore e1000_watchdog is waiting for can only be released when
> ethtool resumes from interrupt after e1000_watchdog finishes
> (basically a deadlock)
> 
> In order to solve this problem, interrupts has to be disabled on the
> interrupted side (during ethtool processing) and not during
> e1000_watchdog within the interrupt handler.
> 
> e1000_get_hw_eeprom_semaphore is called from both the interrupt level
> and the normal level, and needs to be protected by irq code. The
> reason the patch disables interrupts when freeing the semaphore is
> because e1000_swfw_sync_release also calls
> e1000_get_hw_eeprom_semaphore. 

Doesn't this just mean that we need a spinlock or some other kind of
semaphore around acquiring, using, and releasing this resource?  We keep
going around and around about this but I'm pretty sure spinlocks are
meant to be able to solve exactly this issue.

The problem is going to get considerably more nasty if we need to hold a
spinlock with interrupts disabled for a significant amount of time, at
which point a semaphore of some kind with a spinlock around it would
seem to be more useful.

I'll work with Auke to see if we can come up with another try.

Jesse
