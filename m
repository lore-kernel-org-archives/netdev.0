From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [netlink_lookup] BUG: unable to handle kernel NULL pointer dereference
 at (null)
Date: Thu, 13 Jun 2013 09:44:09 +0800
Message-ID: <51B923E9.7060609@cn.fujitsu.com>
References: <20130613012216.GA6788@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Fengguang Wu <fengguang.wu@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130613012216.GA6788@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/13/2013 09:22 AM, Fengguang Wu wrote:
> Greetings,
> 
> I got the below dmesg and the first bad commit is
> 
> commit da12c90e099789a63073fc82a19542ce54d4efb9
> Author: Gao feng <gaofeng@cn.fujitsu.com>
> Date:   Thu Jun 6 14:49:11 2013 +0800
> 
>     netlink: Add compare function for netlink_table
>     
>     As we know, netlink sockets are private resource of
>     net namespace, they can communicate with each other
>     only when they in the same net namespace. this works
>     well until we try to add namespace support for other
>     subsystems which use netlink.
>     
>     Don't like ipv4 and route table.., it is not suited to
>     make these subsytems belong to net namespace, Such as
>     audit and crypto subsystems,they are more suitable to
>     user namespace.
>     
>     So we must have the ability to make the netlink sockets
>     in same user namespace can communicate with each other.
>     
>     This patch adds a new function pointer "compare" for
>     netlink_table, we can decide if the netlink sockets can
>     communicate with each other through this netlink_table
>     self-defined compare function.
>     
>     The behavior isn't changed if we don't provide the compare
>     function for netlink_table.
>     
>     Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
>     Acked-by: Serge E. Hallyn <serge.hallyn@ubuntu.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> cat: /proc/1/maps: No such file or directory
> cat: /proc/1/maps: No such file or directory
> [   75.052517] BUG: unable to handle kernel NULL pointer dereference at           (null)
> [   75.053342] IP: [<          (null)>]           (null)


OK...
Seems I shouldn't reset netlink_table->compare to NULL.
netlink_lookup want it exist always.

Thanks for your report, I will send a patch to fix this problem.

> [   75.053342] PGD f015067 PUD f000067 PMD 0 
> [   75.053342] Oops: 0010 [#1] 
> [   75.053342] CPU: 0 PID: 206 Comm: trinity-child0 Not tainted 3.10.0-rc4-00590-g130d3d6 #32
> [   75.053342] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
> [   75.053342] task: ffff88000f0a1840 ti: ffff88000f04c000 task.ti: ffff88000f04c000
> [   75.053342] RIP: 0010:[<0000000000000000>]  [<          (null)>]           (null)
> [   75.053342] RSP: 0018:ffff88000f04dc50  EFLAGS: 00010282
> [   75.053342] RAX: ffff88000f1d9438 RBX: ffff88000f1d9400 RCX: 0000000022b5ec40
> [   75.053342] RDX: 0000000000000000 RSI: ffff88000f1d9400 RDI: ffffffff81dab900
> [   75.053342] RBP: ffff88000f04dc78 R08: 0000000000000000 R09: 0000000000000000
> [   75.053342] R10: 0000000000000000 R11: 0000000000000000 R12: ffff8800000210d0
> [   75.053342] R13: ffffffff81dab900 R14: 0000000000000000 R15: 0000000000000000
> [   75.053342] FS:  00007fc54dccf700(0000) GS:ffffffff81c9b000(0000) knlGS:0000000000000000
> [   75.053342] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [   75.053342] CR2: 0000000000000000 CR3: 0000000006eb0000 CR4: 00000000000006b0
> [   75.053342] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [   75.053342] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [   75.053342] Stack:
> [   75.053342]  ffffffff818d304f 0000000000000000 ffff88000f1d9400 ffff88000f007600
> [   75.053342]  ffff88000f007600 ffff88000f04dcc8 ffffffff818d48ba 0000000000001000
> [   75.053342]  0000000000f54220 ffff88000f04dfd8 7fffffffffffffff ffff88000f04dd70
> [   75.053342] Call Trace:
> [   75.053342]  [<ffffffff818d304f>] ? netlink_lookup+0xaf/0xf0
> [   75.053342]  [<ffffffff818d48ba>] netlink_unicast+0xba/0x1d0
> [   75.053342]  [<ffffffff818d512a>] netlink_sendmsg+0x32a/0x3e0
> [   75.053342]  [<ffffffff818a678b>] sock_aio_write+0xfb/0x130
> [   75.053342]  [<ffffffff81100e72>] ? kmem_cache_free+0x32/0x180
> [   75.053342]  [<ffffffff811069ea>] do_sync_write+0x7a/0xb0
> [   75.053342]  [<ffffffff81106cbd>] vfs_write+0x16d/0x1d0
> [   75.053342]  [<ffffffff81106e0d>] SyS_write+0x4d/0xa0
> [   75.053342]  [<ffffffff818eefd0>] system_call_fastpath+0x16/0x1b
> [   75.053342] Code:  Bad RIP value.
> [   75.053342] RIP  [<          (null)>]           (null)
> [   75.053342]  RSP <ffff88000f04dc50>
> [   75.053342] CR2: 0000000000000000
> [   75.099392] ---[ end trace fe29140019c40c80 ]---
> 
> git bisect start 130d3d68b52097c7ae081109f700b02776adcb9c dbbffe6898fd0d7bac66ded5d3c58835b13ddefc --
> git bisect good 3acfeac351c6ab2fe1139ee13d780729af0c8145  # 19:11     50+  Merge branch 'fec_regulator_suspend_resume'
> git bisect good 8764d86100fe58e69877753faa44fc1d9276c624  # 19:24     50+  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/mszeredi/fuse
> git bisect good 1612e111e4e565422242727efb59499cce8738e4  # 19:44     50+  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
> git bisect good bd118b6e9509a19bfb82925152d9ae8fa398d567  # 20:02     50+  ibm-ethernet: delete stale MCA and duplicate PSERIES dependency
> git bisect good 143554ace8919d5ef3cc8424c0b06dbd3d671b4e  # 22:50     50+  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next
> git bisect good 589ebdef7e3107401bf96a9c660753d397329ee9  # 22:59     50+  sh_eth: get R8A777x support out of #ifdef
> git bisect good af12fa6e46aa651e7b86a4c4117b562518fef184  # 23:08     50+  net: add napi_id and hash
> git bisect good 30f3a40f9a2a2869a560a9cb9ef488d10c803e14  # 23:14     50+  net: remove last caller of skb_tail_offset() and itself
> git bisect good 8249152c472e10c18936b774737fd58c60335154  # 23:24     50+  xen-netfront: use skb_partial_csum_set() to simplify the codes
> git bisect  bad b41abb42bf62a85a32c41dab873220598a6ee266  # 23:29     10-  net: pass correct parameter to skb_headers_offset_update()
> git bisect  bad da12c90e099789a63073fc82a19542ce54d4efb9  # 23:33      2-  netlink: Add compare function for netlink_table
> git bisect good 8249152c472e10c18936b774737fd58c60335154  # 23:55    195+  xen-netfront: use skb_partial_csum_set() to simplify the codes
> git bisect  bad 130d3d68b52097c7ae081109f700b02776adcb9c  # 23:55      0-  net_sched: psched_ratecfg_precompute() improvements
> git bisect good 27016b825ef907d8d8446fc500bb8d23b57546a6  # 00:12    195+  Revert "netlink: Add compare function for netlink_table"
> git bisect good 77293e215edef7871a39de4b326f777bc39278ca  # 03:03    195+  Merge branch 'fixes-3.10' of git://git.infradead.org/users/willy/linux-nvme
> git bisect good c04efed734409f5a44715b54a6ca1b54b0ccf215  # 06:02    195+  Add linux-next specific files for 20130607
> 
> Thanks,
> Fengguang
> 
