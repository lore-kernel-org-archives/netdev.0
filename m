From: Alexander Holler <holler@ahsoftware.de>
Subject: Re: [PATCH] mv643xx_eth: Fix a possible deadlock upon ifdown
Date: Tue, 12 Mar 2013 10:04:03 +0100
Message-ID: <513EEF83.9070806@ahsoftware.de>
References: <1357308422-19639-1-git-send-email-lkundrak@v3.sk> <20130104202509.GX27530@wantstofly.org> <5130E5A5.90303@ahsoftware.de> <20130312024932.GF850@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lubomir Rintel <lkundrak@v3.sk>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Lubomir Rintel <lubo.rintel@gooddata.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h1446028.stratoserver.net ([85.214.92.142]:54394 "EHLO
	mail.ahsoftware.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932342Ab3CLJEU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 05:04:20 -0400
In-Reply-To: <20130312024932.GF850@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 12.03.2013 03:49, schrieb Lennert Buytenhek:
> On Fri, Mar 01, 2013 at 06:30:13PM +0100, Alexander Holler wrote:
>
>>>> From: Lubomir Rintel <lubo.rintel@gooddata.com>
>>>>
>>>> =================================
>>>> [ INFO: inconsistent lock state ]
>>>> 3.7.0-6.luboskovo.fc19.armv5tel.kirkwood #1 Tainted: G        W
>>>> ---------------------------------
>>>> inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usage.
>>>> NetworkManager/337 [HC0[0]:SC0[0]:HE1:SE1] takes:
>>>>   (_xmit_ETHER#2){+.?...}, at: [<bf07adfc>] txq_reclaim+0x54/0x264 [mv643xx_eth]
>>
>> I get the same annoying warning when the MTU gets changed (through dhcp).
>
> That is actually an issue.
>

I don't think so. Internally the driver calls mv643xx_eth_stop() 
therefore lockdep issues almost the same warning as when the interface 
is shut down (see below). And reading the code, I haven't seen how a 
deadlock could happen. I just wanted to mention that it happens too, 
when the MTU gets changed, in case someone else will see that warning 
after enabling lockdep and wonders if it actually is a problem.

> It fixes a bug (the MTU change thing) and a non-bug (the lockdep
> warning) at the expense of slowing down the much more common path,
> and I don't like it for that reason.

I don't see how something important is slowed down. The patch only 
affects code which is either used when the link goes down or when the 
interface will be polled. I'm not sure where poll is used, but I believe 
it is only used by netconsole, so nothing really important is slowed 
down by the patch. At least if I understood everything correct. ;)

> Can you make a __txq_reclaim() which is basically txq_reclaim()
> without grabbing the tx queue lock, and then move the lock grabbing
> to the caller?
>
> E.g. make __txq_reclaim() have two callers, txq_reclaim() and
> txq_reclaim_bh(), and then use the appropriate wrapper depending on
> the context.  (tx queue lock but no BH disable when called from
> mv643xx_eth_poll(), tx queue lock plus BH disable for MTU change,
> and no locking at all when called from ->ndo_stop().  Something
> like that.)

Hmm, I'm have to take a deep look at the driver to understand what you 
mean (it's some days ago I've last did), but I will try. ;)

For completeness, below is the full output (when the MTU will be changed 
and lockdep is enabled), I've just removed the dates to shorten it.

Regards,

Alexander

=================================
[ INFO: inconsistent lock state ]
3.8.1-dockstar-00023-g524f9cf #280 Not tainted
---------------------------------
inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usage.
ip/1169 [HC0[0]:SC0[0]:HE1:SE1] takes:
  (_xmit_ETHER#2){+.?...}, at: [<c0264f2c>] txq_reclaim+0x44/0x1c8
{IN-SOFTIRQ-W} state was registered at:
   [<c00504c0>] __lock_acquire+0x5ac/0x17cc
   [<c0051b54>] lock_acquire+0x64/0x78
   [<c03656e0>] _raw_spin_lock+0x40/0x50
   [<c0265764>] mv643xx_eth_poll+0x1e8/0x634
   [<c02bfd54>] net_rx_action+0x9c/0x218
   [<c001dc1c>] __do_softirq+0xb4/0x18c
   [<c001e0b0>] irq_exit+0x54/0xb8
   [<c00098ec>] handle_IRQ+0x64/0x84
   [<c0008b98>] __irq_svc+0x38/0xa0
   [<c00186e8>] console_unlock+0x194/0x398
   [<c0019934>] register_console+0x294/0x36c
   [<c04cc4ec>] init_netconsole+0x138/0x1d4
   [<c0008480>] do_one_initcall+0x90/0x16c
   [<c04b9858>] kernel_init_freeable+0xe8/0x1b0
   [<c035ca40>] kernel_init+0x8/0xe4
   [<c00090a8>] ret_from_fork+0x14/0x2c
irq event stamp: 3539
hardirqs last  enabled at (3539): [<c0360d78>] 
__slab_free.isra.53+0x1ac/0x2f8
hardirqs last disabled at (3538): [<c0360c98>] 
__slab_free.isra.53+0xcc/0x2f8
softirqs last  enabled at (3246): [<c0264d10>] 
mib_counters_update+0x56c/0x58c
softirqs last disabled at (3244): [<c0365a48>] _raw_spin_lock_bh+0x14/0x5c

other info that might help us debug this:
  Possible unsafe locking scenario:

        CPU0
        ----
   lock(_xmit_ETHER#2);
   <Interrupt>
     lock(_xmit_ETHER#2);

  *** DEADLOCK ***

1 lock held by ip/1169:
  #0:  (rtnl_mutex){+.+.+.}, at: [<c02cfe50>] rtnetlink_rcv+0xc/0x24

stack backtrace:
[<c000d650>] (unwind_backtrace+0x0/0xe0) from [<c035ff90>] 
(print_usage_bug.part.25+0x20c/0x26c)
[<c035ff90>] (print_usage_bug.part.25+0x20c/0x26c) from [<c004fd0c>] 
(mark_lock+0x404/0x60c)
[<c004fd0c>] (mark_lock+0x404/0x60c) from [<c0050544>] 
(__lock_acquire+0x630/0x17cc)
[<c0050544>] (__lock_acquire+0x630/0x17cc) from [<c0051b54>] 
(lock_acquire+0x64/0x78)
[<c0051b54>] (lock_acquire+0x64/0x78) from [<c03656e0>] 
(_raw_spin_lock+0x40/0x50)
[<c03656e0>] (_raw_spin_lock+0x40/0x50) from [<c0264f2c>] 
(txq_reclaim+0x44/0x1c8)
[<c0264f2c>] (txq_reclaim+0x44/0x1c8) from [<c02650d8>] 
(txq_deinit+0x28/0xc0)
[<c02650d8>] (txq_deinit+0x28/0xc0) from [<c0265284>] 
(mv643xx_eth_stop+0x114/0x130)
[<c0265284>] (mv643xx_eth_stop+0x114/0x130) from [<c02672b0>] 
(mv643xx_eth_change_mtu+0x4c/0x80)
[<c02672b0>] (mv643xx_eth_change_mtu+0x4c/0x80) from [<c02bf1e0>] 
(dev_set_mtu+0x3c/0x70)
[<c02bf1e0>] (dev_set_mtu+0x3c/0x70) from [<c02d0148>] 
(do_setlink+0x1ac/0x794)
[<c02d0148>] (do_setlink+0x1ac/0x794) from [<c02d1624>] 
(rtnl_newlink+0x24c/0x438)
[<c02d1624>] (rtnl_newlink+0x24c/0x438) from [<c02d117c>] 
(rtnetlink_rcv_msg+0x264/0x284)
[<c02d117c>] (rtnetlink_rcv_msg+0x264/0x284) from [<c02e36e4>] 
(netlink_rcv_skb+0x50/0xac)
[<c02e36e4>] (netlink_rcv_skb+0x50/0xac) from [<c02cfe5c>] 
(rtnetlink_rcv+0x18/0x24)
[<c02cfe5c>] (rtnetlink_rcv+0x18/0x24) from [<c02e30e8>] 
(netlink_unicast+0x14c/0x1fc)
[<c02e30e8>] (netlink_unicast+0x14c/0x1fc) from [<c02e3518>] 
(netlink_sendmsg+0x2e0/0x368)
[<c02e3518>] (netlink_sendmsg+0x2e0/0x368) from [<c02ab128>] 
(sock_sendmsg+0x80/0x9c)
[<c02ab128>] (sock_sendmsg+0x80/0x9c) from [<c02ab418>] 
(__sys_sendmsg+0x1c4/0x250)
[<c02ab418>] (__sys_sendmsg+0x1c4/0x250) from [<c02ad164>] 
(sys_sendmsg+0x3c/0x60)
[<c02ad164>] (sys_sendmsg+0x3c/0x60) from [<c0009000>] 
(ret_fast_syscall+0x0/0x38)
mv643xx_eth_port mv643xx_eth_port.0 eth0: link up, 1000 Mb/s, full 
duplex, flow control disabled
