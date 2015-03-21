From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [ipv4/FIB] BUG: unable to handle kernel NULL pointer dereference at
 0000000000000030
Date: Sat, 21 Mar 2015 19:12:48 +0800
Message-ID: <20150321111248.GB24707@wfg-t540p.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fengguang.wu@intel.com, LKP <lkp@01.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Greetings,

0day kernel testing robot got the below dmesg and the first bad commit is

git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master

commit 0ddcf43d5d4a03ded1ee3f6b3b72a0cbed4e90b1
Author:     Alexander Duyck <alexander.h.duyck@redhat.com>
AuthorDate: Fri Mar 6 13:47:00 2015 -0800
Commit:     David S. Miller <davem@davemloft.net>
CommitDate: Wed Mar 11 16:22:14 2015 -0400

    ipv4: FIB Local/MAIN table collapse
    
    This patch is meant to collapse local and main into one by converting
    tb_data from an array to a pointer.  Doing this allows us to point the
    local table into the main while maintaining the same variables in the
    table.
    
    As such the tb_data was converted from an array to a pointer, and a new
    array called data is added in order to still provide an object for tb_data
    to point to.
    
    In order to track the origin of the fib aliases a tb_id value was added in
    a hole that existed on 64b systems.  Using this we can also reverse the
    merge in the event that custom FIB rules are enabled.
    
    With this patch I am seeing an improvement of 20ns to 30ns for routing
    lookups as long as custom rules are not enabled, with custom rules enabled
    we fall back to split tables and the original behavior.
    
    Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>


testbox/testcase/testparams: vm-vp-quantal-x86_64/boot/1

169bf9121b19dd60  0ddcf43d5d4a03ded1ee3f6b3b
----------------  --------------------------
       fail:runs  %reproduction    fail:runs
           |             |             |
          0:80          12%          10:80    dmesg.BUG:unable_to_handle_kernel
          0:80          12%          10:80    dmesg.Kernel_panic-not_syncing:Fatal_exception
          0:80          12%          10:80    dmesg.Oops
          0:80          12%          10:80    dmesg.RIP:fib_trie_unmerge

[   14.975179] BUG: unable to handle kernel NULL pointer dereference at 0000000000000030
[   14.976015] IP: [<ffffffff817f77bd>] fib_trie_unmerge+0x1d/0x2f0
[   14.976015] PGD 0 
[   14.976015] Oops: 0000 [#1] SMP 
[   14.976015] Modules linked in:
[   14.976015] CPU: 1 PID: 52 Comm: kworker/u4:1 Not tainted 4.0.0-rc3-00503-g0ddcf43 #1
[   14.976015] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
[   14.976015] Workqueue: netns cleanup_net
[   14.976015] task: ffff88001605d880 ti: ffff880016064000 task.ti: ffff880016064000
[   14.976015] RIP: 0010:[<ffffffff817f77bd>]  [<ffffffff817f77bd>] fib_trie_unmerge+0x1d/0x2f0
[   14.976015] RSP: 0018:ffff880016067c38  EFLAGS: 00010292
[   14.976015] RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000038
[   14.976015] RDX: ffff880012200808 RSI: 00000000000000ff RDI: 0000000000000000
[   14.976015] RBP: ffff880016067c88 R08: ffff880012200600 R09: 00000001800c0003
[   14.976015] R10: ffff88001371a080 R11: ffff880014bfaa00 R12: ffff880015ac8000
[   14.976015] R13: ffff880012200780 R14: ffff880012200808 R15: ffff880015ac8008
[   14.976015] FS:  0000000000000000(0000) GS:ffff880013700000(0000) knlGS:0000000000000000
[   14.976015] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   14.976015] CR2: 0000000000000030 CR3: 0000000001cb3000 CR4: 00000000000007e0
[   14.976015] Stack:
[   14.976015]  ffff880016067c68 ffffffff811c724e ffff880014bfa838 ffff880014bfa7b0
[   14.976015]  ffff880014bfa838 0000000000000000 ffff880015ac8000 ffff880012200780
[   14.976015]  ffff880012200808 ffff880015ac8008 ffff880016067ca8 ffffffff817f11a4
[   14.976015] Call Trace:
[   14.976015]  [<ffffffff811c724e>] ? kmem_cache_free+0x1de/0x200
[   14.976015]  [<ffffffff817f11a4>] fib_unmerge+0x24/0xc0
[   14.976015]  [<ffffffff817fcb0f>] fib4_rule_delete+0x1f/0x60
[   14.976015]  [<ffffffff8178ea14>] fib_rules_unregister+0x84/0xe0
[   14.976015]  [<ffffffff817fcf45>] fib4_rules_exit+0x15/0x20
[   14.976015]  [<ffffffff817f05ab>] ip_fib_net_exit+0x1b/0x120
[   14.976015]  [<ffffffff817f06e5>] fib_net_exit+0x35/0x40
[   14.976015]  [<ffffffff81766759>] ops_exit_list+0x39/0x60
[   14.976015]  [<ffffffff81767538>] cleanup_net+0x158/0x260
[   14.976015]  [<ffffffff8108ba28>] process_one_work+0x158/0x490
[   14.976015]  [<ffffffff8108c673>] worker_thread+0x73/0x570
[   14.976015]  [<ffffffff8108c600>] ? rescuer_thread+0x400/0x400
[   14.976015]  [<ffffffff810919df>] kthread+0xef/0x110
[   14.976015]  [<ffffffff810918f0>] ? kthread_create_on_node+0x180/0x180
[   14.976015]  [<ffffffff818b4198>] ret_from_fork+0x58/0x90
[   14.976015]  [<ffffffff810918f0>] ? kthread_create_on_node+0x180/0x180
[   14.976015] Code: 9c ff 31 c0 eb 88 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 55 48 8d 4f 38 48 89 f8 48 89 e5 41 57 41 56 41 55 41 54 53 48 83 ec 28 <48> 8b 57 30 48 39 ca 48 89 55 c8 0f 84 12 01 00 00 31 f6 bf ff 
[   14.976015] RIP  [<ffffffff817f77bd>] fib_trie_unmerge+0x1d/0x2f0
[   14.976015]  RSP <ffff880016067c38>
[   14.976015] CR2: 0000000000000030
[   14.976015] ---[ end trace ada4f02c5ab95ed8 ]---
[   14.976015] Kernel panic - not syncing: Fatal exception

git bisect start 37285b9ce55cbcae5b9d7518d1bac23758c87458 06e5801b8cb3fc057d88cb4dc03c0b64b2744cda --
git bisect  bad 6b82c75d0066f2c34112e762b6092536ed254c0f  # 06:52      6-      8  Merge 'sound/for-linus' into devel-hourly-2015031900
git bisect  bad b3deac2ed0634c97400d60ff5cfb05c5160351ce  # 07:17      0-      5  Merge 'asoc/for-next' into devel-hourly-2015031900
git bisect good 95e609f09c92630e0e5f3a6c8a4b7a49b6f6790e  # 07:45     30+      0  Merge 'drm-intel/for-linux-next-fixes' into devel-hourly-2015031900
git bisect good e8c88e63721771b321a5d57a36b772d980c22b6b  # 08:07     30+      0  Merge 'perf/perf/core' into devel-hourly-2015031900
git bisect  bad a67305493317c2ce16096966b1ed56a4b5104829  # 08:25      0-      1  Merge 'jkirsher-next-queue/ixgbe-queue' into devel-hourly-2015031900
git bisect good 7589f65b32f4465e38cc1d71490ea6f3e170c08c  # 09:05     30+      0  i40e: Don't check operational or sync bit for App TLV
git bisect good 28c0f02ffe8a614bc7e1aa57319a62e7ce700d04  # 09:34     30+      0  Merge tag 'wireless-drivers-next-for-davem-2015-03-06' of git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next
git bisect good b40c82e6ae85f110d1b53ba24b2ac657cb7bec8c  # 09:53     30+      2  i40e: Fix inconsistent use of PF/VF vs pf/vf
git bisect good f8f2147150de303e814c0452075d467734d3544b  # 13:05     30+      0  switchdev: add netlink flags to IPv4 FIB add op
git bisect  bad aa34a6cb0478842452bac58edb50d3ef9e178c92  # 13:31      1-      3  rhashtable: Add arbitrary rehash function
git bisect good 34160ea3f9c96b5ae71a11459f9b9f6c298b8930  # 14:21     30+      0  inet_diag: add const to inet_diag_req_v2
git bisect good ddb4b9a1328ea89733133e86cf1972d23891abfc  # 14:27     30+      1  fib_trie: Address possible NULL pointer dereference in resize
git bisect  bad 0ddcf43d5d4a03ded1ee3f6b3b72a0cbed4e90b1  # 14:27      0-     10  ipv4: FIB Local/MAIN table collapse
git bisect good 169bf9121b19dd6029e0a354d33513f61bfbe3d3  # 14:27    103+      0  tipc: ensure that idle links are deleted when a bearer is disabled
# first bad commit: [0ddcf43d5d4a03ded1ee3f6b3b72a0cbed4e90b1] ipv4: FIB Local/MAIN table collapse
git bisect good 169bf9121b19dd6029e0a354d33513f61bfbe3d3  # 14:38    300+      2  tipc: ensure that idle links are deleted when a bearer is disabled
# extra tests with DEBUG_INFO
git bisect  bad 0ddcf43d5d4a03ded1ee3f6b3b72a0cbed4e90b1  # 14:46      4-      2  ipv4: FIB Local/MAIN table collapse
# extra tests on HEAD of linux-devel/devel-hourly-2015031900
git bisect  bad 10a59b3738fb23aa7a86b09530104fb38d6e750c  # 14:46      0-      3  0day head guard for 'devel-hourly-2015031900'
# extra tests on tree/branch net-next/master
git bisect good a998f712f77ea4892d3fcf24e0a67603e63da128  # 03:09    300+      3  rhashtable: Round up/down min/max_size to ensure we respect limit
# extra tests on tree/branch linus/master
git bisect good b314acaccd7e0d55314d96be4a33b5f50d0b3344  # 15:08    300+      1  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/dtor/input
# extra tests on tree/branch next/master
git bisect good 1cfef77614b0d18ee3ac9ff77f17d31bff5d519f  # 15:14    300+      9  Add linux-next specific files for 20150320



Thanks,
Fengguang
