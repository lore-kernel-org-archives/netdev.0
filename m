From: Peter Wu <lekensteyn@gmail.com>
Subject: r8169: is the work queue is initialized at wrong place?
Date: Thu, 18 Jul 2013 11:17:24 +0200
Message-ID: <5838023.rAHnY47tlv@al>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f53.google.com ([209.85.214.53]:60546 "EHLO
	mail-bk0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752065Ab3GRJR3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jul 2013 05:17:29 -0400
Received: by mail-bk0-f53.google.com with SMTP id e11so1085645bkh.40
        for <netdev@vger.kernel.org>; Thu, 18 Jul 2013 02:17:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

While writing EEPROM dumping code for r8169, I encountered a lockdep warning 
after the following sequence:

(assume PCI device 03:00.0 to be bound to r8169)
sudo tee /sys/bus/pci/drivers/r8169/unbind <<<0000:03:00.0

The warning is:
[  809.907323] INFO: trying to register non-static key.
[  809.907336] the code is fine but needs lockdep annotation.
[  809.907339] turning off the locking correctness validator.
[  809.907345] CPU: 2 PID: 2207 Comm: tee Tainted: G        W    3.11.0-rc1-
cold-00021-g3aaf2fe-dirty #1
[  809.907349] Hardware name: Gigabyte Technology Co., Ltd. To be filled by 
O.E.M./Z68X-UD3H-B3, BIOS U1l 03/08/2013
[  809.907353]  ffff880601ba0000 ffff880600943b58 ffffffff8166d3e7 0000000000000000
[  809.907419]  ffff8806002cd8f8 ffff880600943bf8 ffffffff810ad6d6 ffff880600943bb8
[  809.907429]  ffffffff00000000 ffff880600000000 0000000600000000 ffff880600943ce0
[  809.907440] Call Trace:
[  809.907451]  [<ffffffff8166d3e7>] dump_stack+0x55/0x76
[  809.907459]  [<ffffffff810ad6d6>] __lock_acquire+0x9b6/0xab0
[  809.907465]  [<ffffffff810adf76>] ? lockdep_init_map.part.40+0x46/0x590
[  809.907473]  [<ffffffff81069f35>] ? flush_work+0x5/0xb0
[  809.907479]  [<ffffffff810ade80>] lock_acquire+0x90/0x140
[  809.907485]  [<ffffffff81069f35>] ? flush_work+0x5/0xb0
[  809.907491]  [<ffffffff81069f78>] flush_work+0x48/0xb0
[  809.907497]  [<ffffffff81069f35>] ? flush_work+0x5/0xb0
[  809.907502]  [<ffffffff810abbb4>] ? mark_held_locks+0x74/0x140
[  809.907508]  [<ffffffff8106afb1>] ? __cancel_work_timer+0x71/0x110
[  809.907514]  [<ffffffff810abe3d>] ? trace_hardirqs_on_caller+0x7d/0x150
[  809.907519]  [<ffffffff8106afbd>] __cancel_work_timer+0x7d/0x110
[  809.907526]  [<ffffffff8106b080>] cancel_work_sync+0x10/0x20
[  809.907537]  [<ffffffffa0142f73>] rtl_remove_one+0x63/0x150 [r8169]
[  809.907544]  [<ffffffff8134a626>] pci_device_remove+0x46/0xc0
[  809.907551]  [<ffffffff8141832f>] __device_release_driver+0x7f/0xf0
[  809.907556]  [<ffffffff814183ce>] device_release_driver+0x2e/0x40
[  809.907563]  [<ffffffff81417213>] driver_unbind+0xa3/0xc0
[  809.907569]  [<ffffffff814165f4>] drv_attr_store+0x24/0x40
[  809.907576]  [<ffffffff811fe0f6>] sysfs_write_file+0xe6/0x170
[  809.907582]  [<ffffffff81187f7e>] vfs_write+0xce/0x200
[  809.907588]  [<ffffffff81188485>] SyS_write+0x55/0xa0
[  809.907595]  [<ffffffff81682982>] system_call_fastpath+0x16/0x1b

(This is kernel v3.11-rc1-19-gc0d15cc with a66b2e5 and 2f7021a8 reverted due 
to another unrelated locking issue on suspend/resume [1])

rtl_remove_one calls:

    cancel_work_sync(&tp->wk.work);

However, this queue is only initialized in rtl_open:

6673         INIT_WORK(&tp->wk.work, rtl_task);
6674 
6675         smp_mb();

Shouldn't this INIT_WORK be done in rtl_init_one? I do not know what this 
smp_mb is used for in this context, so I leave an appropriate patch up to you.

Regards,
Peter

 [1]: https://lkml.org/lkml/2013/7/15/501
