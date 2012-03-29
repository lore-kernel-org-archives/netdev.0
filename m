From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: Re: [PATCH -3.2.y] igb: Fix locking to silence ASSERT_RTNL() warning
 during suspend/resume
Date: Thu, 29 Mar 2012 18:01:36 +0530
Message-ID: <4F745628.9070505@linux.vnet.ibm.com>
References: <4F705BF5.8050006@linux.vnet.ibm.com> <1332777648.3500.93.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Greg KH <gregkh@linuxfoundation.org>, zheng.z.yan@intel.com,
	aaron.f.brown@intel.com, jeffrey.t.kirsher@intel.com,
	"David S. Miller" <davem@davemloft.net>, stable@vger.kernel.org,
	srivatsa.bhat@linux.vnet.ibm.com,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	alexander.h.duyck@intel.com, carolyn.wyborny@intel.com,
	eric.dumazet@gmail.com, Ben Hutchings <ben@decadent.org.uk>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1332777648.3500.93.camel@deadeye>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ CC'ing netdev mailing list and lkml. I have put relevant info by hand to
  preserve the context, since I didn't find any archives for the stable
  mailing list, to give a link to. ]

On 03/26/2012 09:30 PM, Ben Hutchings wrote:

> On Mon, 2012-03-26 at 17:37 +0530, Srivatsa S. Bhat wrote:
>> From: Zheng Yan <zheng.z.yan@intel.com>
>>
>> [ Upstream commit 749ab2cd127046df79084b6b9165b23491b1db5f ]
>>
>> During suspend/resume (and possibly in other scenarios as well), the
>> ASSERT_RTNL() warning is triggered in netif_set_real_num_tx/rx_queues()
>> functions, something like:

[  374.073765] RTNL: assertion failed at net/core/dev.c (1718)
[  374.073767] Pid: 566, comm: kworker/u:4 Not tainted 3.2.13-0.0.0.2.0f8ab74-trace #1
[  374.073769] RTNL: assertion failed at net/core/dev.c (1718)
[  374.073771] Call Trace:
[  374.073772] Pid: 5271, comm: kworker/u:10 Not tainted 3.2.13-0.0.0.2.0f8ab74-trace #1
[  374.073775] Call Trace:
[  374.073780]  [<ffffffff81385e3e>] netif_set_real_num_tx_queues+0x1ae/0x1d0
[  374.073785]  [<ffffffff81385e3e>] netif_set_real_num_tx_queues+0x1ae/0x1d0
[  374.073792]  [<ffffffffa0323f92>] igb_set_interrupt_capability+0x152/0x1f0 [igb]
[  374.073797]  [<ffffffffa0323f92>] igb_set_interrupt_capability+0x152/0x1f0 [igb]
[  374.073814]  [<ffffffffa0328968>] igb_init_interrupt_scheme+0x28/0x330 [igb]
[  374.073819]  [<ffffffffa0328968>] igb_init_interrupt_scheme+0x28/0x330 [igb]
[  374.073823]  [<ffffffffa0329a9c>] igb_resume+0x9c/0x160 [igb]
[  374.073828]  [<ffffffffa0329a9c>] igb_resume+0x9c/0x160 [igb]
[  374.073831]  [<ffffffff812707b2>] pci_legacy_resume+0x42/0x60
[  374.073835]  [<ffffffff812707b2>] pci_legacy_resume+0x42/0x60
[  374.073837]  [<ffffffff812709c0>] pci_pm_resume+0x90/0xd0
[  374.073840]  [<ffffffff812709c0>] pci_pm_resume+0x90/0xd0
[  374.073843]  [<ffffffff8131b59c>] pm_op+0x10c/0x1e0
[  374.073847]  [<ffffffff8131b59c>] pm_op+0x10c/0x1e0
[  374.073849]  [<ffffffff8131c5ca>] device_resume+0x27a/0x2c0
[  374.073852]  [<ffffffff8131c5ca>] device_resume+0x27a/0x2c0
[  374.073854]  [<ffffffff8131c631>] async_resume+0x21/0x50
[  374.073857]  [<ffffffff8131c631>] async_resume+0x21/0x50
[  374.073860]  [<ffffffff8107e564>] async_run_entry_fn+0x84/0x180
[  374.073864]  [<ffffffff8107e564>] async_run_entry_fn+0x84/0x180
[  374.073867]  [<ffffffff8106ecb1>] process_one_work+0x171/0x350
[  374.073871]  [<ffffffff8106ecb1>] process_one_work+0x171/0x350
[  374.073874]  [<ffffffff8107e4e0>] ? async_schedule+0x20/0x20
[  374.073876]  [<ffffffff8107e4e0>] ? async_schedule+0x20/0x20
[  374.073879]  [<ffffffff81071eeb>] worker_thread+0x18b/0x430
[  374.073881]  [<ffffffff81071eeb>] worker_thread+0x18b/0x430
[  374.073884]  [<ffffffff81071d60>] ? manage_workers+0x120/0x120
[  374.073887]  [<ffffffff81071d60>] ? manage_workers+0x120/0x120
[  374.073890]  [<ffffffff8107683e>] kthread+0x9e/0xb0
[  374.073892]  [<ffffffff8107683e>] kthread+0x9e/0xb0
[  374.073896]  [<ffffffff81451e04>] kernel_thread_helper+0x4/0x10
[  374.073899]  [<ffffffff81451e04>] kernel_thread_helper+0x4/0x10
[  374.073902]  [<ffffffff81447c21>] ? retint_restore_args+0x13/0x13
[  374.073905]  [<ffffffff81447c21>] ? retint_restore_args+0x13/0x13
[  374.073907]  [<ffffffff810767a0>] ? kthread_worker_fn+0x1b0/0x1b0
[  374.073911]  [<ffffffff810767a0>] ? kthread_worker_fn+0x1b0/0x1b0
[  374.073913]  [<ffffffff81451e00>] ? gs_change+0x13/0x13
[  374.073915]  [<ffffffff81451e00>] ? gs_change+0x13/0x13

>> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
>> index 222954d..8775087 100644
>> --- a/drivers/net/ethernet/intel/igb/igb_main.c
>> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
>> @@ -6697,7 +6697,18 @@ static int igb_resume(struct pci_dev *pdev)
>>  	pci_enable_wake(pdev, PCI_D3hot, 0);
>>  	pci_enable_wake(pdev, PCI_D3cold, 0);
>>  
>> -	if (igb_init_interrupt_scheme(adapter)) {
>> +	if (!rtnl_is_locked()) {
> 
> This doesn't tell whether this process holds the lock.  So it suppresses
> the warning but doesn't fix the real bug.
> 
> Ben.

>
> You mean to say that this issue needs to be revisited in mainline too?

On 03/27/2012 07:57 PM, Ben Hutchings wrote:

| Oh, yes.  Because you said this was a smaller patch for stable, I didn't
| realise that mainline had this problem too.

> 
>> +		/*
>> +		 * shut up ASSERT_RTNL() warning in
>> +		 * netif_set_real_num_tx/rx_queues.
>> +		 */
>> +		rtnl_lock();
>> +		err = igb_init_interrupt_scheme(adapter);
>> +		rtnl_unlock();
>> +	} else {
>> +		err = igb_init_interrupt_scheme(adapter);
>> +	}
>> +	if (err) {
>>  		dev_err(&pdev->dev, "Unable to allocate memory for queues\n");
>>  		return -ENOMEM;
>>  	}
> 
> 

 
Regards,
Srivatsa S. Bhat
