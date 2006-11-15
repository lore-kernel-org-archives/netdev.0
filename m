From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: watchdog timeout panic in e1000 driver
Date: Wed, 15 Nov 2006 08:11:39 -0800
Message-ID: <455B3C3B.2070308@intel.com>
References: <4538BFF2.2040207@cj.jp.nec.com> <4538F080.5020003@intel.com> <453DD678.4010606@cj.jp.nec.com> <453E3C0B.5030600@intel.com> <453F6983.6020307@cj.jp.nec.com> <453F7E1F.4020406@intel.com> <45408F7B.3050209@cj.jp.nec.com> <4540C765.4000800@intel.com> <4545E3A4.9090004@cj.jp.nec.com> <454636B0.1010004@intel.com> <20061031032218.GA7804@gmail.com> <45489F59.6030102@cj.jp.nec.com> <455AED05.9010607@cj.jp.nec.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030408090209090502000308"
Cc: Shaw Vrana <shaw@vranix.com>, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:33310 "EHLO mga03.intel.com")
	by vger.kernel.org with ESMTP id S1030626AbWKOQL4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Nov 2006 11:11:56 -0500
To: Kenzo Iwami <k-iwami@cj.jp.nec.com>
In-Reply-To: <455AED05.9010607@cj.jp.nec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030408090209090502000308
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Kenzo Iwami wrote:
> Hi,
> 
>>>>> Even if the total lock time can be reduced, it's possible that interrupt
>>>>> handler is executed while the interrupted code is still holding the 
>>>>> semaphore.
>>>>> I think your method only decrease the frequency of this problem.
>>>>> Why does reducing the lock time solve this problem?
>>>> there are several problems here that need addressing. It's not acceptable 
>>>> for our driver to wait up to 15 seconds, and we can (presumably) reduce it 
>>>> to milliseconds, so that would help a lot. We should in no case at all hold 
>>>> it for any period longer than (give or take) half a second, so working 
>>>> towards that is a very good step in the right direction.
>>>>
>>>> Adding the timer task back may also help, as we are no longer trying to 
>>>> aqcuire the sw_fw_semaphore in interrupt context, but we removed it for a 
>>>> reason, and I need to dig up what reason this exactly was before we can 
>>>> revert it. Jesse might know, so I'll talk to him. But this will not fix the 
>>>> fact that the semaphore is held for a long time :)
> [...]
>> I think this problem occurs because interrupt handler is executed in same
>> CPU as process that acquires semaphore.
>> How about disabling interrupt while the process is holding the semaphore?
>> I think this is possible, if the total lock time has been reduced.
> 
> I created the attached patch based on the method described above.
> This patch disables interrupt while the process is holding the semaphore.
> 
> I measured how long interrupts are being disabled 10,000 times using the
> following method. TSC was read by rdtscll when interrupt was disabled
> and interrupt was enabled again, then I subtract these two value.
> 
> The longest period interrupt was disabled is under 10usec, which seems
> acceptable. The evaluation environment is;
>   CPU    : Intel Xeon CPU 3.73GHz
>   kernel : 2.6.19-rc5
> 
> I also ran the reproduction TP I sent previously and confirmed that the
> system didn't panic.
>   http://marc.theaimsgroup.com/?l=linux-netdev&m=116125332319850&w=2
> 
> How about this method?

I'm not sure why you would have to disable interrupts when freeing the semaphore, but 
more importantly I don't want to introduce irq code in the swfw handling functions.

Since the major (only) user running this piece of code in intterupt context is the 
watchdog, we might as well see if we can only disable interrupts for that code path, 
which would only be once per 2 seconds. We don't need to protect the ethtool path into 
this code as it doesn't run in irq context.

Would you mind giving attached patch a try and let me know if it works for you? It will 
disable irqs for a bit longer time than your patch, and it begs for a special 
check-link-in-watchdog function that doesn't take so damn long :(

Thanks,

Auke


--------------030408090209090502000308
Content-Type: text/x-patch;
 name*0="e1000_git_disable_irqs_in_watchdog_link_status_check.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="e1000_git_disable_irqs_in_watchdog_link_status_check.patch"


Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index a2f1464..0b52ded 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2430,8 +2430,12 @@ e1000_watchdog(unsigned long data)
 	struct e1000_tx_ring *txdr = adapter->tx_ring;
 	uint32_t link, tctl;
 	int32_t ret_val;
+	unsigned long flags;
 
+	local_irq_save(flags);
 	ret_val = e1000_check_for_link(&adapter->hw);
+	local_irq_restore(flags);
+
 	if ((ret_val == E1000_ERR_PHY) &&
 	    (adapter->hw.phy_type == e1000_phy_igp_3) &&
 	    (E1000_READ_REG(&adapter->hw, CTRL) & E1000_PHY_CTRL_GBE_DISABLE)) {

--------------030408090209090502000308--
