From: Auke Kok <sofar@foo-projects.org>
Subject: Re: watchdog timeout panic in e1000 driver
Date: Thu, 19 Oct 2006 08:39:00 -0700
Message-ID: <45379C14.5050901@foo-projects.org>
References: <45375135.5050206@cj.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:31387 "EHLO
	fmsmga101.fm.intel.com") by vger.kernel.org with ESMTP
	id S1946124AbWJSPlV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Oct 2006 11:41:21 -0400
To: Kenzo Iwami <k-iwami@cj.jp.nec.com>
In-Reply-To: <45375135.5050206@cj.jp.nec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kenzo Iwami wrote:
> A watchdog timeout panic occurred in e1000 driver (7.2.9-NAPI).

where's the panic message ?

Please CC the maintainers of the driver at all times. Our e-mail addresses are widely 
visible everywhere.

> If e1000_watchdog is called when processing ioctl from ethtool, the system
> could stop inside e1000_watchdog interrupt handler for about 16 seconds
 >
> and the system panicked as a result of a watchdog timeout.
> 
> This problem only occurs on a server using ethernet controller inside
> 631xESB/632xESB, and NMI watchdog enabled.

why only this system? have you seen/tried it on other machines?

> Environment:
>   OS     : RHEL4U3(x86_64)
>   kernel : 2.6.9-34.ELsmp
>   e1000  : 7.2.9-NAPI
>   Ethernet controller : Intel Corporation 631x/632xESB DPT LAN Controller
>                         Copper (rev 01)
>   Watchdog timer should be enabled with a timeout period of less than 16
>   seconds.
> Steps to reproduce:
>   Please apply the attached patch (ethtool.patch) to ethtool (VERSION 5) source
>   code. Run make, and rename the freshly built ethtool as gsetloop.
>   Put gsetloop and the attached shell script (gloop.sh) in the same directory,
>   and execute gloop.sh. The problem should occur within about 5 minutes.
 >
> 
> Cause:
>   The problem occurs in the following steps.
>    - ioctl is executed in ethtool.
>       - e1000_read_phy_reg() is called from ioctl to read the value from phy
>         register.
>       - e1000_get_hw_eeprom_semaphore() is called from e1000_read_phy_reg() to
>         acquire a semaphore.
>       - E1000_SWSM_SWESMBI bit that is FW semaphore bit is set in
>         e1000_get_hw_eeprom_semaphore().
>       - When this bit was set, E1000_SWSM_SMBI bit that is driver's semaphore
>         bit is also set.
>    - e1000_watchdog() of interrupt handler is executed before the
>      E1000_SWSM_SMBI bit is unset.
>       - e1000_read_phy_reg() is called from e1000_watchdog() to read the value
>         from phy register.
>       - e1000_get_software_semaphore() is called from e1000_watchdog to confirm
>         whether interruption handler can acquire a semaphore.
>         This function confirms whether E1000_SWSM_SMBI bit is being set.
>       - Therefore the process does loop for "hw->eeprom.word_size + 1" msec
>         in e1000_get_software_semaphore().
>         The value of "hw->eeprom.word_size + 1" was 16385 on my system.
>         In other words it loops for 16.385 sec in
>         e1000_get_software_semaphore().
>         If NMI watchdog is enabled, the system will panic by NMI watchdog
>         within this loop.
> 
> Fix:
>   In kernels before 2.6.17, the e1000_watchdog() interrupt handler schedules
>   e1000_watchdog_task(). The semaphore is acquired within this task, after
>   ioctl processing for ethtool is finished, and this problem is avoided.
> 
>   e1000_watchdog_task() was remove by the following patch.
> 
> http://kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=2db10a081c5c1082d58809a1bcf1a6073f4db160
>      e1000: rework driver hardware reset locking
>      >After studying the driver mac reset code it was found that there
>      >were multiple race conditions possible to reset the unit twice or
>      >bring it e1000_up() double. This fixes all occurences where the
>      >driver needs to reset the mac.
>      >
>      >We also remove irq requesting/releasing into _open and _close so
>      >that while the device is _up we will never touch the irq's. This fixes
>      >the double free irq bug that people saw.
>      >
>      >To make sure that the watchdog task doesn't cause another race we let
>      >it run as a non-scheduled task.
> 
>   I'm not sure whether there was any reason to actively remove
>   e1000_watchdog_task(). I think that removing e1000_watchdog_task() was a
>   mistake, and it should be brought back in.


Reverting this could would not be a fix, but only a workaround that leaves the problem 
still in the code, and as such not progress in the right direction.

I find this report extremely edgy, but I'll look into the fact that the driver attempts 
to sleep for 16384 + 1 msec, which seems overly long :)

As a side note, most other e1000 NIC's use hardcoded word_size numbers, but esb2 systems 
read it from a register/eeprom. Can you send me the output of `ethtool -e ethX` ? 
off-list is OK, it might be large.

Thanks,

Auke
