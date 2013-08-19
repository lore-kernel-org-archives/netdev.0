From: Hugh Dickins <hughd@google.com>
Subject: 3.11-rc6 genetlink locking fix offends lockdep
Date: Sun, 18 Aug 2013 22:04:57 -0700 (PDT)
Message-ID: <alpine.LNX.2.00.1308182143370.906@eggly.anvils>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Greg KH <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrei Otcheretianski <andrei.otcheretianski@intel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	stable@vger.kernel.org
To: Johannes Berg <johannes.berg@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

3.11-rc6's commit 58ad436fcf49 ("genetlink: fix family dump race")
gives me the lockdep trace below at startup.

I think it needs to be reverted until you can refine it.  And it has
already gone into today's stable review series, as 04/12 for 3.0.92,
26/34 for 3.4.59, 18/45 for 3.10.8: I raise an objection to those.

Hugh

[    4.004286] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
[    4.105671] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
[    4.106123] IPv6: ADDRCONF(NETDEV_UP): eth1: link is not ready
[    4.110096] 
[    4.110113] ======================================================
[    4.110146] [ INFO: possible circular locking dependency detected ]
[    4.110180] 3.11.0-rc6 #1 Not tainted
[    4.110201] -------------------------------------------------------
[    4.110234] NetworkManager/358 is trying to acquire lock:
[    4.110262]  (genl_mutex){+.+.+.}, at: [<ffffffff8148204d>] genl_lock+0x12/0x14
[    4.110315] 
[    4.110315] but task is already holding lock:
[    4.110346]  (nlk->cb_mutex){+.+.+.}, at: [<ffffffff8147f148>] netlink_dump+0x1c/0x1d7
[    4.110400] 
[    4.110400] which lock already depends on the new lock.
[    4.110400] 
[    4.110442] 
[    4.110442] the existing dependency chain (in reverse order) is:
[    4.110482] 
[    4.110482] -> #1 (nlk->cb_mutex){+.+.+.}:
[    4.110517]        [<ffffffff810b34d2>] __lock_acquire+0x865/0x956
[    4.110555]        [<ffffffff810b39fc>] lock_acquire+0x57/0x6d
[    4.110589]        [<ffffffff81583e42>] mutex_lock_nested+0x5e/0x345
[    4.110627]        [<ffffffff81480122>] __netlink_dump_start+0xae/0x14e
[    4.110665]        [<ffffffff81482143>] genl_rcv_msg+0xf4/0x252
[    4.110699]        [<ffffffff81481742>] netlink_rcv_skb+0x3e/0x8c
[    4.110734]        [<ffffffff8148199b>] genl_rcv+0x24/0x34
[    4.110766]        [<ffffffff814811ca>] netlink_unicast+0xed/0x17a
[    4.110801]        [<ffffffff814815d4>] netlink_sendmsg+0x2fb/0x345
[    4.110838]        [<ffffffff814503f7>] sock_sendmsg+0x79/0x8e
[    4.110871]        [<ffffffff81450707>] ___sys_sendmsg+0x231/0x2be
[    4.110907]        [<ffffffff81453228>] __sys_sendmsg+0x3d/0x5e
[    4.110942]        [<ffffffff81453256>] SyS_sendmsg+0xd/0x19
[    4.110975]        [<ffffffff81587c12>] system_call_fastpath+0x16/0x1b
[    4.111012] 
[    4.111012] -> #0 (genl_mutex){+.+.+.}:
[    4.111047]        [<ffffffff810b1fb0>] validate_chain.isra.21+0x836/0xe8e
[    4.111086]        [<ffffffff810b34d2>] __lock_acquire+0x865/0x956
[    4.111122]        [<ffffffff810b39fc>] lock_acquire+0x57/0x6d
[    4.111157]        [<ffffffff81583e42>] mutex_lock_nested+0x5e/0x345
[    4.111193]        [<ffffffff8148204d>] genl_lock+0x12/0x14
[    4.111226]        [<ffffffff814822d2>] ctrl_dumpfamily+0x31/0xfa
[    4.111260]        [<ffffffff8147f1b4>] netlink_dump+0x88/0x1d7
[    4.111295]        [<ffffffff8147f4b4>] netlink_recvmsg+0x1b1/0x2d1
[    4.111331]        [<ffffffff81450328>] sock_recvmsg+0x83/0x98
[    4.111365]        [<ffffffff814500c6>] ___sys_recvmsg+0x15d/0x207
[    4.111400]        [<ffffffff814533f7>] __sys_recvmsg+0x3d/0x5e
[    4.111434]        [<ffffffff81453425>] SyS_recvmsg+0xd/0x19
[    4.111467]        [<ffffffff81587c12>] system_call_fastpath+0x16/0x1b
[    4.111504] 
[    4.111504] other info that might help us debug this:
[    4.111504] 
[    4.111545]  Possible unsafe locking scenario:
[    4.111545] 
[    4.111577]        CPU0                    CPU1
[    4.111601]        ----                    ----
[    4.111625]   lock(nlk->cb_mutex);
[    4.112865]                                lock(genl_mutex);
[    4.114216]                                lock(nlk->cb_mutex);
[    4.115315]   lock(genl_mutex);
[    4.116500] 
[    4.116500]  *** DEADLOCK ***
[    4.116500] 
[    4.119670] 1 lock held by NetworkManager/358:
[    4.120906]  #0:  (nlk->cb_mutex){+.+.+.}, at: [<ffffffff8147f148>] netlink_dump+0x1c/0x1d7
[    4.122196] 
[    4.122196] stack backtrace:
[    4.124533] CPU: 0 PID: 358 Comm: NetworkManager Not tainted 3.11.0-rc6 #1
[    4.125779] Hardware name: LENOVO 4174EH1/4174EH1, BIOS 8CET51WW (1.31 ) 11/29/2011
[    4.126979]  ffffffff81d0a0f0 ffff88022b91d8c8 ffffffff8157cf80 0000000000000006
[    4.128274]  ffffffff81cc8750 ffff88022b91d918 ffffffff8157a898 ffff88022d798080
[    4.129472]  ffff88022d798080 ffff88022d798080 ffff88022d798750 ffff88022d798080
[    4.130645] Call Trace:
[    4.131801]  [<ffffffff8157cf80>] dump_stack+0x4f/0x84
[    4.132817]  [<ffffffff8157a898>] print_circular_bug+0x2ad/0x2be
[    4.133839]  [<ffffffff810b1fb0>] validate_chain.isra.21+0x836/0xe8e
[    4.134821]  [<ffffffff8145471a>] ? sock_def_write_space+0x1b5/0x1b5
[    4.135800]  [<ffffffff810b34d2>] __lock_acquire+0x865/0x956
[    4.136842]  [<ffffffff810b40bb>] ? mark_held_locks+0xce/0xfa
[    4.137828]  [<ffffffff8148204d>] ? genl_lock+0x12/0x14
[    4.138876]  [<ffffffff810b39fc>] lock_acquire+0x57/0x6d
[    4.139856]  [<ffffffff8148204d>] ? genl_lock+0x12/0x14
[    4.141027]  [<ffffffff81583e42>] mutex_lock_nested+0x5e/0x345
[    4.142194]  [<ffffffff8148204d>] ? genl_lock+0x12/0x14
[    4.143219]  [<ffffffff8111c594>] ? __kmalloc_node_track_caller+0x26/0x2d
[    4.144340]  [<ffffffff8148204d>] genl_lock+0x12/0x14
[    4.145387]  [<ffffffff814822d2>] ctrl_dumpfamily+0x31/0xfa
[    4.146387]  [<ffffffff8145ac41>] ? __alloc_skb+0x97/0x1a0
[    4.147454]  [<ffffffff8147f1b4>] netlink_dump+0x88/0x1d7
[    4.148448]  [<ffffffff8147f4b4>] netlink_recvmsg+0x1b1/0x2d1
[    4.149475]  [<ffffffff81450328>] sock_recvmsg+0x83/0x98
[    4.150494]  [<ffffffff810f86fa>] ? might_fault+0x52/0xa2
[    4.151471]  [<ffffffff814500c6>] ___sys_recvmsg+0x15d/0x207
[    4.152516]  [<ffffffff810b34d2>] ? __lock_acquire+0x865/0x956
[    4.153501]  [<ffffffff81148b2b>] ? fget_light+0x35c/0x377
[    4.154550]  [<ffffffff81148933>] ? fget_light+0x164/0x377
[    4.155521]  [<ffffffff814533f7>] __sys_recvmsg+0x3d/0x5e
[    4.156568]  [<ffffffff8145471a>] ? sock_def_write_space+0x1b5/0x1b5
[    4.157552]  [<ffffffff81453425>] SyS_recvmsg+0xd/0x19
[    4.158607]  [<ffffffff81587c12>] system_call_fastpath+0x16/0x1b
[    4.160507] iwlwifi 0000:03:00.0: L1 Enabled; Disabling L0S
[    4.160709] iwlwifi 0000:03:00.0: Radio type=0x0-0x3-0x1
