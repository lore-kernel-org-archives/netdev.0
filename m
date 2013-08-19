From: Hugh Dickins <hughd@google.com>
Subject: Re: 3.11-rc6 genetlink locking fix offends lockdep
Date: Mon, 19 Aug 2013 11:52:54 -0700 (PDT)
Message-ID: <alpine.LNX.2.00.1308191147350.1505@eggly.anvils>
References: <alpine.LNX.2.00.1308182143370.906@eggly.anvils> <1376899214.14734.6.camel@jlt4.sipsolutions.net> <5211FAB3.7080400@huawei.com> <1376911362.14734.11.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ding Tianhong <dingtianhong@huawei.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Greg KH <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Otcheretianski, Andrei" <andrei.otcheretianski@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Thomas Graf <tgraf@suug.ch>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:59970 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966Ab3HSSxP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 14:53:15 -0400
Received: by mail-pd0-f175.google.com with SMTP id q10so5573768pdj.6
        for <netdev@vger.kernel.org>; Mon, 19 Aug 2013 11:53:15 -0700 (PDT)
In-Reply-To: <1376911362.14734.11.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 19 Aug 2013, Johannes Berg wrote:
> On Mon, 2013-08-19 at 19:00 +0800, Ding Tianhong wrote:
> > On 2013/8/19 16:00, Johannes Berg wrote:
> > > 
> > >> 3.11-rc6's commit 58ad436fcf49 ("genetlink: fix family dump race")
> > >> gives me the lockdep trace below at startup.
> > > 
> > > Hmm. Yes, I see now how this happens, not sure why I didn't run into it.
> > > 
> > > The problem is that genl_family_rcv_msg() is called with the genl_lock
> > > held, and then calls netlink_dump_start() with it held, creating a
> > > genl_lock->cb_mutex dependency, but obviously the dump continuation is
> > > the other way around.
> > > 
> > > We could use the semaphore instead, I believe, but I don't really
> > > understand the mutex vs. semaphore well enough to be sure that's
> > > correct.
> > > 
> > > johannes
> > > 
> > it is useless, the logic need to modify or otherwise it will still call lockdep trace.
> 
> I don't believe so, the semaphore and cb_mutex don't have a dependency
> yet, afaict.

The down_read(&cb_lock) patch you suggested gives the lockdep trace below.

> 
> > maybe i could send a patch for it, if you wish.
> 
> What do you mean?
> 
> johannes

[    4.027797] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
[    4.129749] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
[    4.130179] IPv6: ADDRCONF(NETDEV_UP): eth1: link is not ready
[    4.134629] 
[    4.134646] ======================================================
[    4.134680] [ INFO: possible circular locking dependency detected ]
[    4.134714] 3.11.0-rc6 #3 Not tainted
[    4.134735] -------------------------------------------------------
[    4.134767] NetworkManager/357 is trying to acquire lock:
[    4.134797]  (cb_lock){++++++}, at: [<ffffffff8148204a>] ctrl_dumpfamily+0x38/0x108
[    4.134853] 
[    4.134853] but task is already holding lock:
[    4.134883]  (nlk->cb_mutex){+.+.+.}, at: [<ffffffff8147f148>] netlink_dump+0x1c/0x1d7
[    4.134938] 
[    4.134938] which lock already depends on the new lock.
[    4.134938] 
[    4.134981] 
[    4.134981] the existing dependency chain (in reverse order) is:
[    4.135020] 
[    4.135020] -> #2 (nlk->cb_mutex){+.+.+.}:
[    4.135056]        [<ffffffff810b34d2>] __lock_acquire+0x865/0x956
[    4.135094]        [<ffffffff810b39fc>] lock_acquire+0x57/0x6d
[    4.135129]        [<ffffffff81583e52>] mutex_lock_nested+0x5e/0x345
[    4.135167]        [<ffffffff81480122>] __netlink_dump_start+0xae/0x14e
[    4.135205]        [<ffffffff8148224b>] genl_rcv_msg+0xf4/0x252
[    4.135239]        [<ffffffff81481742>] netlink_rcv_skb+0x3e/0x8c
[    4.135275]        [<ffffffff8148199b>] genl_rcv+0x24/0x34
[    4.135307]        [<ffffffff814811ca>] netlink_unicast+0xed/0x17a
[    4.135342]        [<ffffffff814815d4>] netlink_sendmsg+0x2fb/0x345
[    4.135378]        [<ffffffff814503f7>] sock_sendmsg+0x79/0x8e
[    4.135412]        [<ffffffff81450707>] ___sys_sendmsg+0x231/0x2be
[    4.135448]        [<ffffffff81453228>] __sys_sendmsg+0x3d/0x5e
[    4.135483]        [<ffffffff81453256>] SyS_sendmsg+0xd/0x19
[    4.135517]        [<ffffffff81587c12>] system_call_fastpath+0x16/0x1b
[    4.135555] 
[    4.135555] -> #1 (genl_mutex){+.+.+.}:
[    4.135589]        [<ffffffff810b34d2>] __lock_acquire+0x865/0x956
[    4.135626]        [<ffffffff810b39fc>] lock_acquire+0x57/0x6d
[    4.135661]        [<ffffffff81583e52>] mutex_lock_nested+0x5e/0x345
[    4.135697]        [<ffffffff81482155>] genl_lock+0x12/0x14
[    4.135730]        [<ffffffff8148249d>] genl_lock_all+0x15/0x17
[    4.135763]        [<ffffffff81482b2a>] genl_register_family+0x51/0x142
[    4.135801]        [<ffffffff8148305f>] genl_register_family_with_ops+0x23/0x70
[    4.135842]        [<ffffffff8195e610>] genl_init+0x41/0x80
[    4.135876]        [<ffffffff81000267>] do_one_initcall+0x7f/0x108
[    4.135912]        [<ffffffff81930e29>] kernel_init_freeable+0x106/0x195
[    4.135951]        [<ffffffff81574621>] kernel_init+0x9/0xd1
[    4.135985]        [<ffffffff81587b6c>] ret_from_fork+0x7c/0xb0
[    4.136019] 
[    4.136019] -> #0 (cb_lock){++++++}:
[    4.136052]        [<ffffffff810b1fb0>] validate_chain.isra.21+0x836/0xe8e
[    4.136091]        [<ffffffff810b34d2>] __lock_acquire+0x865/0x956
[    4.136127]        [<ffffffff810b39fc>] lock_acquire+0x57/0x6d
[    4.136161]        [<ffffffff81584629>] down_read+0x42/0x57
[    4.136194]        [<ffffffff8148204a>] ctrl_dumpfamily+0x38/0x108
[    4.136230]        [<ffffffff8147f1b4>] netlink_dump+0x88/0x1d7
[    4.136264]        [<ffffffff8147f4b4>] netlink_recvmsg+0x1b1/0x2d1
[    4.137410]        [<ffffffff81450328>] sock_recvmsg+0x83/0x98
[    4.138459]        [<ffffffff814500c6>] ___sys_recvmsg+0x15d/0x207
[    4.139692]        [<ffffffff814533f7>] __sys_recvmsg+0x3d/0x5e
[    4.140918]        [<ffffffff81453425>] SyS_recvmsg+0xd/0x19
[    4.141975]        [<ffffffff81587c12>] system_call_fastpath+0x16/0x1b
[    4.143042] 
[    4.143042] other info that might help us debug this:
[    4.143042] 
[    4.146007] Chain exists of:
[    4.146007]   cb_lock --> genl_mutex --> nlk->cb_mutex
[    4.146007] 
[    4.148919]  Possible unsafe locking scenario:
[    4.148919] 
[    4.150955]        CPU0                    CPU1
[    4.152060]        ----                    ----
[    4.153030]   lock(nlk->cb_mutex);
[    4.153950]                                lock(genl_mutex);
[    4.154912]                                lock(nlk->cb_mutex);
[    4.155832]   lock(cb_lock);
[    4.156732] 
[    4.156732]  *** DEADLOCK ***
[    4.156732] 
[    4.159477] 1 lock held by NetworkManager/357:
[    4.160354]  #0:  (nlk->cb_mutex){+.+.+.}, at: [<ffffffff8147f148>] netlink_dump+0x1c/0x1d7
[    4.161411] 
[    4.161411] stack backtrace:
[    4.163489] CPU: 0 PID: 357 Comm: NetworkManager Not tainted 3.11.0-rc6 #3
[    4.164527] Hardware name: LENOVO 4174EH1/4174EH1, BIOS 8CET51WW (1.31 ) 11/29/2011
[    4.165491]  ffffffff81d0a450 ffff88022bd61938 ffffffff8157cf90 0000000000000006
[    4.166520]  ffffffff81cc85a0 ffff88022bd61988 ffffffff8157a8a8 ffff880200000001
[    4.167486]  ffff8802313ae080 ffff8802313ae080 ffff8802313ae750 ffff8802313ae080
[    4.168532] Call Trace:
[    4.169491]  [<ffffffff8157cf90>] dump_stack+0x4f/0x84
[    4.170532]  [<ffffffff8157a8a8>] print_circular_bug+0x2ad/0x2be
[    4.171507]  [<ffffffff810b1fb0>] validate_chain.isra.21+0x836/0xe8e
[    4.172548]  [<ffffffff810b34d2>] __lock_acquire+0x865/0x956
[    4.173525]  [<ffffffff810b39fc>] lock_acquire+0x57/0x6d
[    4.174536]  [<ffffffff8148204a>] ? ctrl_dumpfamily+0x38/0x108
[    4.175535]  [<ffffffff81584629>] down_read+0x42/0x57
[    4.176523]  [<ffffffff8148204a>] ? ctrl_dumpfamily+0x38/0x108
[    4.177564]  [<ffffffff8148204a>] ctrl_dumpfamily+0x38/0x108
[    4.178556]  [<ffffffff8145ac41>] ? __alloc_skb+0x97/0x1a0
[    4.179611]  [<ffffffff8147f1b4>] netlink_dump+0x88/0x1d7
[    4.180594]  [<ffffffff8147f4b4>] netlink_recvmsg+0x1b1/0x2d1
[    4.181645]  [<ffffffff81450328>] sock_recvmsg+0x83/0x98
[    4.182628]  [<ffffffff810f86fa>] ? might_fault+0x52/0xa2
[    4.183683]  [<ffffffff814500c6>] ___sys_recvmsg+0x15d/0x207
[    4.184668]  [<ffffffff810b34d2>] ? __lock_acquire+0x865/0x956
[    4.185731]  [<ffffffff81148b2b>] ? fget_light+0x35c/0x377
[    4.186707]  [<ffffffff81148933>] ? fget_light+0x164/0x377
[    4.187744]  [<ffffffff814533f7>] __sys_recvmsg+0x3d/0x5e
[    4.188709]  [<ffffffff8145471a>] ? sock_def_write_space+0x1b5/0x1b5
[    4.189755]  [<ffffffff81453425>] SyS_recvmsg+0xd/0x19
[    4.190729]  [<ffffffff81587c12>] system_call_fastpath+0x16/0x1b
[    4.192674] iwlwifi 0000:03:00.0: L1 Enabled; Disabling L0S
[    4.192887] iwlwifi 0000:03:00.0: Radio type=0x0-0x3-0x1
