From: Kenzo Iwami <k-iwami@cj.jp.nec.com>
Subject: Re: watchdog timeout panic in e1000 driver
Date: Wed, 15 Nov 2006 19:33:41 +0900
Message-ID: <455AED05.9010607@cj.jp.nec.com>
References: <4538BFF2.2040207@cj.jp.nec.com> <4538F080.5020003@intel.com> <453DD678.4010606@cj.jp.nec.com> <453E3C0B.5030600@intel.com> <453F6983.6020307@cj.jp.nec.com> <453F7E1F.4020406@intel.com> <45408F7B.3050209@cj.jp.nec.com> <4540C765.4000800@intel.com> <4545E3A4.9090004@cj.jp.nec.com> <454636B0.1010004@intel.com> <20061031032218.GA7804@gmail.com> <45489F59.6030102@cj.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Shaw Vrana <shaw@vranix.com>, Auke Kok <auke-jan.h.kok@intel.com>,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([202.32.8.193]:28561 "EHLO
	tyo201.gate.nec.co.jp") by vger.kernel.org with ESMTP
	id S966752AbWKOKdz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Nov 2006 05:33:55 -0500
To: Kenzo Iwami <k-iwami@cj.jp.nec.com>
In-Reply-To: <45489F59.6030102@cj.jp.nec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

>>>> Even if the total lock time can be reduced, it's possible that interrupt
>>>> handler is executed while the interrupted code is still holding the 
>>>> semaphore.
>>>> I think your method only decrease the frequency of this problem.
>>>> Why does reducing the lock time solve this problem?
>>> there are several problems here that need addressing. It's not acceptable 
>>> for our driver to wait up to 15 seconds, and we can (presumably) reduce it 
>>> to milliseconds, so that would help a lot. We should in no case at all hold 
>>> it for any period longer than (give or take) half a second, so working 
>>> towards that is a very good step in the right direction.
>>>
>>> Adding the timer task back may also help, as we are no longer trying to 
>>> aqcuire the sw_fw_semaphore in interrupt context, but we removed it for a 
>>> reason, and I need to dig up what reason this exactly was before we can 
>>> revert it. Jesse might know, so I'll talk to him. But this will not fix the 
>>> fact that the semaphore is held for a long time :)
[...]
> I think this problem occurs because interrupt handler is executed in same
> CPU as process that acquires semaphore.
> How about disabling interrupt while the process is holding the semaphore?
> I think this is possible, if the total lock time has been reduced.

I created the attached patch based on the method described above.
This patch disables interrupt while the process is holding the semaphore.

I measured how long interrupts are being disabled 10,000 times using the
following method. TSC was read by rdtscll when interrupt was disabled
and interrupt was enabled again, then I subtract these two value.

The longest period interrupt was disabled is under 10usec, which seems
acceptable. The evaluation environment is;
  CPU    : Intel Xeon CPU 3.73GHz
  kernel : 2.6.19-rc5

I also ran the reproduction TP I sent previously and confirmed that the
system didn't panic.
  http://marc.theaimsgroup.com/?l=linux-netdev&m=116125332319850&w=2

How about this method?

I welcome any comments.
-- 
  Kenzo Iwami (k-iwami@cj.jp.nec.com)

Signed-off-by: Kenzo Iwami <k-iwami@cj.jp.nec.com>

diff -urpN linux-2.6.19-rc5_org/drivers/net/e1000/e1000_hw.c
linux-2.6.19-rc5/drivers/net/e1000/e1000_hw.c
--- linux-2.6.19-rc5_org/drivers/net/e1000/e1000_hw.c	2006-11-14
17:47:28.000000000 +0900
+++ linux-2.6.19-rc5/drivers/net/e1000/e1000_hw.c	2006-11-15 17:49:39.000000000
+0900
@@ -3379,6 +3379,7 @@ e1000_swfw_sync_acquire(struct e1000_hw
     uint32_t swmask = mask;
     uint32_t fwmask = mask << 16;
     int32_t timeout = 200;
+    unsigned long flags;

     DEBUGFUNC("e1000_swfw_sync_acquire");

@@ -3389,8 +3390,11 @@ e1000_swfw_sync_acquire(struct e1000_hw
         return e1000_get_hw_eeprom_semaphore(hw);

     while (timeout) {
-            if (e1000_get_hw_eeprom_semaphore(hw))
+            local_irq_save(flags);
+            if (e1000_get_hw_eeprom_semaphore(hw)) {
+                local_irq_restore(flags);
                 return -E1000_ERR_SWFW_SYNC;
+            }

             swfw_sync = E1000_READ_REG(hw, SW_FW_SYNC);
             if (!(swfw_sync & (fwmask | swmask))) {
@@ -3400,6 +3404,7 @@ e1000_swfw_sync_acquire(struct e1000_hw
             /* firmware currently using resource (fwmask) */
             /* or other software thread currently using resource (swmask) */
             e1000_put_hw_eeprom_semaphore(hw);
+            local_irq_restore(flags);
             mdelay(5);
             timeout--;
     }
@@ -3413,6 +3418,7 @@ e1000_swfw_sync_acquire(struct e1000_hw
     E1000_WRITE_REG(hw, SW_FW_SYNC, swfw_sync);

     e1000_put_hw_eeprom_semaphore(hw);
+    local_irq_restore(flags);
     return E1000_SUCCESS;
 }

@@ -3421,6 +3427,7 @@ e1000_swfw_sync_release(struct e1000_hw
 {
     uint32_t swfw_sync;
     uint32_t swmask = mask;
+    unsigned long flags;

     DEBUGFUNC("e1000_swfw_sync_release");

@@ -3434,6 +3441,7 @@ e1000_swfw_sync_release(struct e1000_hw
         return;
     }

+    local_irq_save(flags);
     /* if (e1000_get_hw_eeprom_semaphore(hw))
      *    return -E1000_ERR_SWFW_SYNC; */
     while (e1000_get_hw_eeprom_semaphore(hw) != E1000_SUCCESS);
@@ -3444,6 +3452,7 @@ e1000_swfw_sync_release(struct e1000_hw
     E1000_WRITE_REG(hw, SW_FW_SYNC, swfw_sync);

     e1000_put_hw_eeprom_semaphore(hw);
+    local_irq_restore(flags);
 }

 /*****************************************************************************
