From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH 1/2] Remove netpoll blocking from uninit path
Date: Wed, 20 Oct 2010 15:47:11 +0800
Message-ID: <4CBE9E7F.60107@redhat.com>
References: <1287507866-25156-1-git-send-email-nhorman@tuxdriver.com> <1287507866-25156-2-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net,
	fubar@us.ibm.com, davem@davemloft.net, andy@greyhouse.net
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18153 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932307Ab0JTHmo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Oct 2010 03:42:44 -0400
In-Reply-To: <1287507866-25156-2-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/20/10 01:04, nhorman@tuxdriver.com wrote:
> From: Neil Horman<nhorman@tuxdriver.com>
>
> Some recent testing in netpoll with bonding showed this backtrace
>
>   ------------[ cut here ]------------
>   kernel BUG at drivers/net/bonding/bonding.h:134!
>   invalid opcode: 0000 [#1] SMP
>   last sysfs file: /sys/devices/pci0000:00/0000:00:1d.2/usb7/devnum
>   CPU 0
>   Pid: 1876, comm: rmmod Not tainted 2.6.36-rc3+ #10 D26928/
>   RIP: 0010:[<ffffffffa0514ba4>]  [<ffffffffa0514ba4>] bond_uninit+0x6f4/0x7a0
>   RSP: 0018:ffff88003b1b5d58  EFLAGS: 00010296
>   RAX: ffff88003b9b6200 RBX: ffff8800373e8e00 RCX: 00000000000f4240
>   RDX: 00000000ffffffff RSI: 0000000000000286 RDI: 0000000000000286
>   RBP: ffff88003b1b5dc8 R08: 0000000000000000 R09: 00000001af7de920
>   R10: 0000000000000000 R11: ffff880002495e98 R12: ffff880037922700
>   R13: ffff880038c31000 R14: ffff880037922730 R15: 0000000000000286
>   FS:  00007f90e6d72700(0000) GS:ffff880002400000(0000) knlGS:0000000000000000
>   CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>   CR2: 000000346f0d9ad0 CR3: 000000003b263000 CR4: 00000000000006f0
>   DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>   DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>   Process rmmod (pid: 1876, threadinfo ffff88003b1b4000, task ffff88003b36aa80)
>   Stack:
>   00000000ffffffff ffff88003b1b5d7a ffff8800379221e8 ffff880037922000
>   <0>  ffff88003b1b5dc8 ffffffff813eb5fb ffff88003b1b5da8 0000000031b177a3
>   <0>  ffff88003b1b5da8 ffff880037922000 ffff88003b1b5e48 ffff88003b1b5e48
>   Call Trace:
>   [<ffffffff813eb5fb>] ? rtmsg_ifinfo+0xcb/0xf0
>   [<ffffffff813daad8>] rollback_registered_many+0x168/0x280
>   [<ffffffff813dac09>] unregister_netdevice_many+0x19/0x80
>   [<ffffffff813e97b3>] __rtnl_kill_links+0x63/0x90
>   [<ffffffff813e980b>] __rtnl_link_unregister+0x2b/0x60
>   [<ffffffff813e9bde>] rtnl_link_unregister+0x1e/0x30
>   [<ffffffffa052124b>] bonding_exit+0x37/0x51 [bonding]
>   [<ffffffff81098b2e>] sys_delete_module+0x19e/0x270
>   [<ffffffff810bb2b2>] ? audit_syscall_entry+0x252/0x280
>   [<ffffffff8100b0b2>] system_call_fastpath+0x16/0x1b
>   RIP  [<ffffffffa0514ba4>] bond_uninit+0x6f4/0x7a0 [bonding]
>   RSP<ffff88003b1b5d58>
>   ---[ end trace 1395ad691cea24d1 ]---
>
> It occurs because of my recent netpoll blocking patches, which I added to avoid
> recursive deadlock in the bonding driver.  It relies on some per cpu bits, but
> the shutdown path forces some rescheduling as we cancel workqueues for the
> driver and wait for some device refcounts.  If after the forced reschedule, we
> wind up on a different cpu we trigger the bughalt in unblock_netpoll_tx.
>
> The fix is to remove the netpoll block/unblock calls from bond_release_all.
> This is safe to do because bond_uninit, which is called via ndo_uninit in
> rollback_registered_many, doesn't occur until we send a NETDEV_UNREGISTER event,
> which triggers netconsole to remove us as a netpoll client, so we are guaranteed
> not to recurse into our own tx path here.

Also bond_release_all() is called after bond_netpoll_cleanup()
in bond_uninit().

>
> Signed-off-by: Neil Horman<nhorman@tuxdriver.com>

Reviewed-by: WANG Cong <amwang@redhat.com>

Thanks.
