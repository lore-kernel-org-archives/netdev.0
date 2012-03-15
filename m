From: Karsten Keil <kkeil@linux-pingi.de>
Subject: Re: 3.3-rc6 netjet.ko sleeping while in atomic.
Date: Thu, 15 Mar 2012 09:48:40 +0100
Message-ID: <20120315084840.GA20202@gw.linux-pingi.de>
References: <20120314191650.GB18135@digium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:52835 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760273Ab2COIsm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Mar 2012 04:48:42 -0400
Content-Disposition: inline
In-Reply-To: <20120314191650.GB18135@digium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the report.
I will have a look on this.

On Wed, Mar 14, 2012 at 02:16:50PM -0500, Shaun Ruffell wrote:
> Karsten,
> 
> I hit this today when unloading netjet.ko which was attached to a
> Digium TDM400 card. Looks like flush_work_sync() is called while in
> a spin_lock_irqsave() block. Not sure if it matters to you but I
> thought I would send it along:
> 
>   BUG: sleeping function called from invalid context at kernel/workqueue.c:2445
>   in_atomic(): 1, irqs_disabled(): 1, pid: 30652, name: modprobe
>   3 locks held by modprobe/30652:
>    #0:  (&__lockdep_no_validate__){......}, at: [<c0669fd2>] driver_detach+0x37/0x95
>    #1:  (&__lockdep_no_validate__){......}, at: [<c0669fde>] driver_detach+0x43/0x95
>    #2:  (&(&card->lock)->rlock){-.-...}, at: [<fa6f4657>] nj_release+0x14b/0x1b0 [netjet]
>   irq event stamp: 4262
>   hardirqs last  enabled at (4261): [<c0476648>] debug_check_no_locks_freed+0x7a/0x138
>   hardirqs last disabled at (4262): [<c07be2ea>] _raw_spin_lock_irqsave+0x18/0x7f
>   softirqs last  enabled at (1564): [<c0430cc1>] __do_softirq+0x10c/0x2fe
>   softirqs last disabled at (1517): [<c04040b2>] call_on_stack+0x12/0x18
>   Pid: 30652, comm: modprobe Tainted: G           O 3.3.0-rc6.sruffelldbg+ #35
>   Call Trace:
>    [<c04542ce>] __might_sleep+0x10b/0x197
>    [<c0444df1>] start_flush_work+0x26/0x132
>    [<c0474b1c>] ? trace_hardirqs_off_caller+0x18/0x92
>    [<c0444f19>] flush_work_sync+0x1c/0x50
>    [<c0474442>] ? lock_release_holdtime+0x68/0xca
>    [<c07beb5f>] ? _raw_spin_unlock_irqrestore+0x34/0x4c
>    [<c0474ba1>] ? trace_hardirqs_off+0xb/0xd
>    [<c07beb5f>] ? _raw_spin_unlock_irqrestore+0x34/0x4c
>    [<c06fe174>] ? skb_dequeue+0x47/0x52
>    [<fa63824c>] mISDN_freedchannel+0x5e/0x63 [mISDN_core]
>    [<fa69509a>] isac_release+0x9a/0xc0 [mISDNipac]
>    [<fa6f4683>] nj_release+0x177/0x1b0 [netjet]
>    [<c044fea8>] ? __blocking_notifier_call_chain+0x5c/0x89
>    [<fa6f5ad7>] nj_remove+0x17/0x2f [netjet]
>    [<c05e4bd4>] pci_device_remove+0x1e/0x3f
>    [<c06698fa>] __device_release_driver+0x4e/0x96
>    [<c066a02c>] driver_detach+0x91/0x95
>    [<c0668bce>] bus_remove_driver+0x6e/0xcf
>    [<c066a399>] driver_unregister+0x42/0x6c
>    [<c066a593>] ? driver_remove_file+0x14/0x16
>    [<c05e4924>] pci_unregister_driver+0x2d/0x78
>    [<fa6f5ab5>] nj_cleanup+0xd/0x18 [netjet]
>    [<c04833c8>] sys_delete_module+0x123/0x219
>    [<c045be28>] ? local_clock+0x29/0x42
>    [<c049586d>] ? __audit_syscall_exit+0x2a4/0x440
>    [<c07c468c>] sysenter_do_call+0x12/0x32
> 
> Cheers,
> Shaun
