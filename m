From: Bart Trojanowski <bart@jukie.net>
Subject: [BUG] 2.6.29-rc* QinQ vlan trunking regression
Date: Sat, 28 Feb 2009 13:05:41 -0500
Message-ID: <20090228180541.GA729@jukie.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bart@jukie.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>,
	"David S. Miller" <davem@redhat.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Frank Blaschka <frank.blasc
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754629AbZB1SGD@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

2.6.29-rc* introduces a bug that causes a crash when a vlan is put into
another vlan, so called vlan trunking or QinQ.

I can reproduce it reliably with:

  $ modprobe 8021q
  $ vconfig add eth1 5
  $ ifconfig eth1.5 up
  $ vconfig add eth1.5 4

I have seen crashes on all 2.6.29-rc kernels, but it does work for me on
2.6.28 (and prior).  All my testing was done on ia32 and amd64 systems.
I've reproduced it with various configs, but if you need my config let
me know.

I was tired of crashing my devel box, so this Ooops came from a kvm VM
(with the default 8139cp driver) where I attempted a bisect to find the
source of the bug.  Unfortunately I was unable to bisect it because of
other unrelated crashes in the history that made it too time consuming.

I have discovered that by doing:

  $ git reset --hard origin/master            # to HEAD of torvalds/linux-2.6.git
  $ git revert cc883d16c3b7434c7da2c45b54a49c2a99e83db7
  $ git revert f7d1b9f5aafa371d7f51f644aa3c38bc914e9205
  $ git revert 656299f706e52e0409733d704c2761f1b12d6954

... the crash goes away.  I just validated the procedure with Linus'
778ef1e6cbb049c9bcbf405936ee6f2b6e451892.  And other than seeing...

  [  154.094561] eth1.5 (): not using net_device_ops yet
  [  154.220840] eth1.5.4 (): not using net_device_ops yet

... there is no trace of this bug.  I suspect that only 656299f need to
be reverted/fixed, but the other two patches are prerequisites for it to
apply cleanly.

Hope that makes the source of the bug apparent to someone.

Cheers,
-Bart

PS: I see another problem with my KVM setup, but I think that has
something to do with my KVM host kernel, not the guest.  More
specifically, when I do QinQ I only see the inner VLAN tags on the
underlying bridge device (under the KVM), but the outer most VLAN tag is
missing.  But that's an exercise for another day.

--- 8< ---

[ 1201.822546] 802.1Q VLAN Support v1.8 Ben Greear <greearb@candelatech.com>
[ 1201.830944] All bugs added by David S. Miller <davem@redhat.com>
[ 1202.016124] PANIC: double fault, gdt at c364b000 [255 bytes]
[ 1202.016789] Slab corruption: size-32 start=f3da9a28, len=32
[ 1202.016793] Redzone: 0xf8163c85f3da9a2c/0xf3dda800f8163c85.
[ 1202.016795] Last user: [<f8163c85>](vlan_dev_neigh_setup+0x23/0x2a [8021q])
[ 1202.016812] 000: 00 a8 dd f3 38 9a da f3 85 3c 16 f8 00 a8 dd f3
[ 1202.016818] 010: 44 9a da f3 85 3c 16 f8 00 a8 dd f3 50 9a da f3
[ 1202.016825] Prev obj: start=f3da99c0, len=32
[ 1202.016826] Redzone: 0xf3dda800f8163c85/0xf3da99f0f3dda800.
[ 1202.016828] Last user: [<f3dda800>](0xf3dda800)
[ 1202.016831] 000: cc 99 da f3 85 3c 16 f8 00 a8 dd f3 d8 99 da f3
[ 1202.016836] 010: 85 3c 16 f8 00 a8 dd f3 e4 99 da f3 85 3c 16 f8
[ 1202.016842] Next obj: start=f3da9a30, len=32
[ 1202.016843] Redzone: 0xf3da9a38f3dda800/0xf8163c85f3da9a5c.
[ 1202.016845] Last user: [<f3da9a68>](0xf3da9a68)
[ 1202.016847] 000: 85 3c 16 f8 00 a8 dd f3 44 9a da f3 85 3c 16 f8
[ 1202.016852] 010: 00 a8 dd f3 50 9a da f3 85 3c 16 f8 00 a8 dd f3
[ 1202.016858] slab error in cache_alloc_debugcheck_after(): cache `size-32': double free, or memory outside object was overwritten
[ 1202.016863] Pid: 2229, comm: ps Tainted: G S         2.6.29-rc6-bisect-00121-g64e7130 #1
[ 1202.016865] Call Trace:
[ 1202.016874]  [<c03cb5a8>] ? printk+0xf/0x17
[ 1202.016880]  [<c018fea6>] __slab_error+0x17/0x1c
[ 1202.016884]  [<c01902c8>] cache_alloc_debugcheck_after+0xd0/0x1b8
[ 1202.016886]  [<c0191974>] kmem_cache_alloc+0xca/0x104
[ 1202.016889]  [<c0191390>] ? cache_alloc_refill+0x397/0x62a
[ 1202.016891]  [<c0191390>] ? cache_alloc_refill+0x397/0x62a
[ 1202.016893]  [<c0191390>] cache_alloc_refill+0x397/0x62a
[ 1202.016897]  [<c01a2598>] ? __d_lookup+0x0/0x11e
[ 1202.016899]  [<c019195a>] kmem_cache_alloc+0xb0/0x104
[ 1202.016902]  [<c01a28e4>] ? d_alloc+0x1e/0x16e
[ 1202.016904]  [<c01a28e4>] d_alloc+0x1e/0x16e
[ 1202.016906]  [<c019aaff>] do_lookup+0x9f/0x154
[ 1202.016909]  [<c019c9e0>] __link_path_walk+0x86a/0xc5e
[ 1202.016911]  [<c019cf67>] path_walk+0x50/0xa5
[ 1202.016913]  [<c019d180>] do_path_lookup+0x140/0x188
[ 1202.016916]  [<c019d20e>] path_lookup_open+0x46/0x77
[ 1202.016918]  [<c019dbfc>] do_filp_open+0xa3/0x6cd
[ 1202.016923]  [<c0288d64>] ? _raw_spin_unlock+0x74/0x78
[ 1202.016927]  [<c03cdf0a>] ? _spin_unlock+0x1d/0x20
[ 1202.016929]  [<c019296b>] do_sys_open+0x42/0xb7
[ 1202.016931]  [<c0192a22>] sys_open+0x1e/0x26
[ 1202.016935]  [<c0103507>] sysenter_do_call+0x12/0x3a
[ 1202.016938] f3da9a20: redzone 1:0xf8163c85f3da9a2c, redzone 2:0xf3dda800f8163c85
[ 1202.016953] ------------[ cut here ]------------
[ 1202.016955] WARNING: at lib/list_debug.c:26 __list_add+0x27/0x5c()
[ 1202.016958] Hardware name: 
[ 1202.016960] list_add corruption. next->prev should be prev (f704f650), but was f8163c85. (next=f3da9a98).
[ 1202.016961] Modules linked in: 8021q virtio_balloon virtio_pci thermal_sys
[ 1202.016967] Pid: 2229, comm: ps Tainted: G S         2.6.29-rc6-bisect-00121-g64e7130 #1
[ 1202.016969] Call Trace:
[ 1202.016972]  [<c0129769>] warn_slowpath+0x71/0xa8
[ 1202.016975]  [<c0288d64>] ? _raw_spin_unlock+0x74/0x78
[ 1202.016978]  [<c0288d64>] ? _raw_spin_unlock+0x74/0x78
[ 1202.016980]  [<c03cb4ab>] ? dump_stack+0x57/0x61
[ 1202.016983]  [<c02891e3>] __list_add+0x27/0x5c
[ 1202.016989]  [<f8163c85>] ? vlan_dev_neigh_setup+0x23/0x2a [8021q]
[ 1202.016994]  [<c0191220>] cache_alloc_refill+0x227/0x62a
[ 1202.016997]  [<c019195a>] kmem_cache_alloc+0xb0/0x104
[ 1202.016999]  [<c01a28e4>] ? d_alloc+0x1e/0x16e
[ 1202.017002]  [<c01a28e4>] d_alloc+0x1e/0x16e
[ 1202.017004]  [<c019aaff>] do_lookup+0x9f/0x154
[ 1202.017006]  [<c019c9e0>] __link_path_walk+0x86a/0xc5e
[ 1202.017008]  [<c019cf67>] path_walk+0x50/0xa5
[ 1202.017011]  [<c019d180>] do_path_lookup+0x140/0x188
[ 1202.017013]  [<c019d20e>] path_lookup_open+0x46/0x77
[ 1202.017015]  [<c019dbfc>] do_filp_open+0xa3/0x6cd
[ 1202.017018]  [<c0288d64>] ? _raw_spin_unlock+0x74/0x78
[ 1202.017020]  [<c03cdf0a>] ? _spin_unlock+0x1d/0x20
[ 1202.017023]  [<c019296b>] do_sys_open+0x42/0xb7
[ 1202.017025]  [<c0192a22>] sys_open+0x1e/0x26
[ 1202.017027]  [<c0103507>] sysenter_do_call+0x12/0x3a
[ 1202.017029] ---[ end trace 32f9f05d27403734 ]---
[ 1202.017057] Slab corruption: size-32 start=f3da99f0, len=32
[ 1202.017062] Redzone: 0xf3dda800f8163c85/0xf3da9a20f3dda800.
[ 1202.017064] Last user: [<f3dda800>](0xf3dda800)
[ 1202.017067] 000: fc 99 da f3 85 3c 16 f8 00 a8 dd f3 08 9a da f3
[ 1202.017072] 010: 85 3c 16 f8 00 a8 dd f3 14 9a da f3 85 3c 16 f8
[ 1202.017078] Prev obj: start=f3da9988, len=32
[ 1202.017079] Redzone: 0xf3da9990f3dda800/0xf8163c85f3da99b4.
[ 1202.017081] Last user: [<f3da99c0>](0xf3da99c0)
[ 1202.017083] 000: 85 3c 16 f8 00 a8 dd f3 9c 99 da f3 85 3c 16 f8
[ 1202.017088] 010: 00 a8 dd f3 a8 99 da f3 85 3c 16 f8 00 a8 dd f3
[ 1202.017093] Next obj: start=f3da99f8, len=32
[ 1202.017095] Redzone: 0xf8163c85f3da99fc/0xf3dda800f8163c85.
[ 1202.017098] Last user: [<d84156c5>](0xd84156c5)
[ 1202.017100] 000: 00 a8 dd f3 08 9a da f3 85 3c 16 f8 00 a8 dd f3
[ 1202.017105] 010: 14 9a da f3 85 3c 16 f8 00 a8 dd f3 20 9a da f3
[ 1202.017111] slab error in cache_alloc_debugcheck_after(): cache `size-32': double free, or memory outside object was overwritten
[ 1202.017114] Pid: 2229, comm: ps Tainted: G S      W  2.6.29-rc6-bisect-00121-g64e7130 #1
[ 1202.017116] Call Trace:
[ 1202.017119]  [<c03cb5a8>] ? printk+0xf/0x17
[ 1202.017122]  [<c018fea6>] __slab_error+0x17/0x1c
[ 1202.017125]  [<c01902c8>] cache_alloc_debugcheck_after+0xd0/0x1b8
[ 1202.017127]  [<c0191974>] kmem_cache_alloc+0xca/0x104
[ 1202.017129]  [<c0191390>] ? cache_alloc_refill+0x397/0x62a
[ 1202.017131]  [<c0191390>] ? cache_alloc_refill+0x397/0x62a
[ 1202.017133]  [<c0191390>] cache_alloc_refill+0x397/0x62a
[ 1202.017136]  [<c02891e3>] ? __list_add+0x27/0x5c
[ 1202.017138]  [<c019195a>] kmem_cache_alloc+0xb0/0x104
[ 1202.017144]  [<c01c622c>] ? proc_alloc_inode+0x16/0x67
[ 1202.017146]  [<c01c622c>] proc_alloc_inode+0x16/0x67
[ 1202.017149]  [<c01a4584>] alloc_inode+0x13/0x3a
[ 1202.017152]  [<c01a4825>] new_inode+0x17/0x7e
[ 1202.017154]  [<c01c71bf>] proc_pid_make_inode+0xc/0xb3
[ 1202.017157]  [<c01c9453>] proc_pident_instantiate+0x17/0x86
[ 1202.017159]  [<c01c95c3>] proc_pident_lookup+0x6a/0x8b
[ 1202.017167]  [<c01c9615>] proc_tgid_base_lookup+0xf/0x11
[ 1202.017169]  [<c019ab15>] do_lookup+0xb5/0x154
[ 1202.017171]  [<c019c9e0>] __link_path_walk+0x86a/0xc5e
[ 1202.017174]  [<c019cf67>] path_walk+0x50/0xa5
[ 1202.017176]  [<c019d180>] do_path_lookup+0x140/0x188
[ 1202.017178]  [<c019d20e>] path_lookup_open+0x46/0x77
[ 1202.017180]  [<c019dbfc>] do_filp_open+0xa3/0x6cd
[ 1202.017183]  [<c0288d64>] ? _raw_spin_unlock+0x74/0x78
[ 1202.017186]  [<c03cdf0a>] ? _spin_unlock+0x1d/0x20
[ 1202.017188]  [<c019296b>] do_sys_open+0x42/0xb7
[ 1202.017190]  [<c0192a22>] sys_open+0x1e/0x26
[ 1202.017193]  [<c0103507>] sysenter_do_call+0x12/0x3a
[ 1202.017195] f3da99e8: redzone 1:0xf3dda800f8163c85, redzone 2:0xf3da9a20f3dda800
[ 1202.017214] ------------[ cut here ]------------
[ 1202.017216] WARNING: at lib/list_debug.c:26 __list_add+0x27/0x5c()
[ 1202.017218] Hardware name: 
[ 1202.017219] list_add corruption. next->prev should be prev (f704f290), but was f3dda800. (next=f3da9a60).
[ 1202.017221] Modules linked in: 8021q virtio_balloon virtio_pci thermal_sys
[ 1202.017226] Pid: 2229, comm: ps Tainted: G S      W  2.6.29-rc6-bisect-00121-g64e7130 #1
[ 1202.017227] Call Trace:
[ 1202.017230]  [<c0129769>] warn_slowpath+0x71/0xa8
[ 1202.017232]  [<c0288d64>] ? _raw_spin_unlock+0x74/0x78
[ 1202.017235]  [<c0288d64>] ? _raw_spin_unlock+0x74/0x78
[ 1202.017238]  [<c03cb4ab>] ? dump_stack+0x57/0x61
[ 1202.017240]  [<c02891e3>] __list_add+0x27/0x5c
[ 1202.017242]  [<c0191220>] cache_alloc_refill+0x227/0x62a
[ 1202.017245]  [<c019195a>] kmem_cache_alloc+0xb0/0x104
[ 1202.017248]  [<c01c622c>] ? proc_alloc_inode+0x16/0x67
[ 1202.017251]  [<c01c622c>] proc_alloc_inode+0x16/0x67
[ 1202.017253]  [<c01a4584>] alloc_inode+0x13/0x3a
[ 1202.017256]  [<c01a4825>] new_inode+0x17/0x7e
[ 1202.017258]  [<c01c71bf>] proc_pid_make_inode+0xc/0xb3
[ 1202.017261]  [<c01c9453>] proc_pident_instantiate+0x17/0x86
[ 1202.017263]  [<c01c95c3>] proc_pident_lookup+0x6a/0x8b
[ 1202.017265]  [<c01c9615>] proc_tgid_base_lookup+0xf/0x11
[ 1202.017267]  [<c019ab15>] do_lookup+0xb5/0x154
[ 1202.017269]  [<c019c9e0>] __link_path_walk+0x86a/0xc5e
[ 1202.017272]  [<c019cf67>] path_walk+0x50/0xa5
[ 1202.017274]  [<c019d180>] do_path_lookup+0x140/0x188
[ 1202.017276]  [<c019d20e>] path_lookup_open+0x46/0x77
[ 1202.017278]  [<c019dbfc>] do_filp_open+0xa3/0x6cd
[ 1202.017281]  [<c0288d64>] ? _raw_spin_unlock+0x74/0x78
[ 1202.017284]  [<c03cdf0a>] ? _spin_unlock+0x1d/0x20
[ 1202.017286]  [<c019296b>] do_sys_open+0x42/0xb7
[ 1202.017288]  [<c0192a22>] sys_open+0x1e/0x26
[ 1202.017291]  [<c0103507>] sysenter_do_call+0x12/0x3a
[ 1202.017293] ---[ end trace 32f9f05d27403735 ]---
[ 1202.017312] Slab corruption: size-32 start=f3da99b8, len=32
[ 1202.017314] Redzone: 0xf3da99c0f3dda800/0xf8163c85f3da99e4.
[ 1202.017316] Last user: [<f3da99f0>](0xf3da99f0)
[ 1202.017319] 000: 85 3c 16 f8 00 a8 dd f3 cc 99 da f3 85 3c 16 f8
[ 1202.017324] 010: 00 a8 dd f3 d8 99 da f3 85 3c 16 f8 00 a8 dd f3
[ 1202.017330] Prev obj: start=f3da9950, len=32
[ 1202.017331] Redzone: 0xf8163c85f3da9954/0xf3dda800f8163c85.
[ 1202.017333] Last user: [<f8163c85>](vlan_dev_neigh_setup+0x23/0x2a [8021q])
[ 1202.017338] 000: 00 a8 dd f3 60 99 da f3 85 3c 16 f8 00 a8 dd f3
[ 1202.017343] 010: 6c 99 da f3 85 3c 16 f8 00 a8 dd f3 78 99 da f3
[ 1202.017348] Next obj: start=f3da99c0, len=32
[ 1202.017350] Redzone: 0xf3dda800f8163c85/0xf3da99f0f3dda800.
[ 1202.017351] Last user: [<d84156c5>](0xd84156c5)
[ 1202.017353] 000: cc 99 da f3 85 3c 16 f8 00 a8 dd f3 d8 99 da f3
[ 1202.017359] 010: 85 3c 16 f8 00 a8 dd f3 e4 99 da f3 85 3c 16 f8
[ 1202.017365] slab error in cache_alloc_debugcheck_after(): cache `size-32': double free, or memory outside object was overwritten
[ 1202.017367] Pid: 2229, comm: ps Tainted: G S      W  2.6.29-rc6-bisect-00121-g64e7130 #1
[ 1202.017369] Call Trace:
[ 1202.017372]  [<c03cb5a8>] ? printk+0xf/0x17
[ 1202.017376]  [<c018fea6>] __slab_error+0x17/0x1c
[ 1202.017379]  [<c01902c8>] cache_alloc_debugcheck_after+0xd0/0x1b8
[ 1202.017381]  [<c0191974>] kmem_cache_alloc+0xca/0x104
[ 1202.017384]  [<c01a8d8d>] ? single_open+0x25/0x74
[ 1202.017387]  [<c01a8d8d>] ? single_open+0x25/0x74
[ 1202.017390]  [<c01c84dd>] ? proc_single_show+0x0/0x6b
[ 1202.017392]  [<c01a8d8d>] single_open+0x25/0x74
[ 1202.017395]  [<c01c7164>] proc_single_open+0x17/0x2c
[ 1202.017397]  [<c0192b5b>] __dentry_open+0x11c/0x210
[ 1202.017399]  [<c0192ce9>] nameidata_to_filp+0x2c/0x43
[ 1202.017402]  [<c01c714d>] ? proc_single_open+0x0/0x2c
[ 1202.017404]  [<c019dee1>] do_filp_open+0x388/0x6cd
[ 1202.017407]  [<c0288d64>] ? _raw_spin_unlock+0x74/0x78
[ 1202.017410]  [<c03cdf0a>] ? _spin_unlock+0x1d/0x20
[ 1202.017412]  [<c019296b>] do_sys_open+0x42/0xb7
[ 1202.017414]  [<c0192a22>] sys_open+0x1e/0x26
[ 1202.017417]  [<c0103507>] sysenter_do_call+0x12/0x3a
[ 1202.017419] f3da99b0: redzone 1:0xf3da99c0f3dda800, redzone 2:0xf8163c85f3da99e4
[ 1202.017523] ------------[ cut here ]------------
[ 1202.017525] kernel BUG at mm/slab.c:2898!
[ 1202.017527] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
[ 1202.017530] last sysfs file: /sys/class/net/eth1.5/address
[ 1202.017532] Modules linked in: 8021q virtio_balloon virtio_pci thermal_sys
[ 1202.017536] 
[ 1202.017538] Pid: 2229, comm: ps Tainted: G S      W  (2.6.29-rc6-bisect-00121-g64e7130 #1) 
[ 1202.017541] EIP: 0060:[<c0190686>] EFLAGS: 00010006 CPU: 0
[ 1202.017544] EIP is at cache_free_debugcheck+0x1cd/0x2a4
[ 1202.017546] EAX: f3da9980 EBX: f3da9000 ECX: f3da9018 EDX: 0000002b
[ 1202.017548] ESI: d84156c5 EDI: f7000200 EBP: f5a99f34 ESP: f5a99f04
[ 1202.017550]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
[ 1202.017553] Process ps (pid: 2229, ti=f5a98000 task=f47e1708 task.ti=f5a98000)
[ 1202.017554] Stack:
[ 1202.017555]  c01a8388 00a88654 f3da9000 635688c0 d84156c5 c01a833a f3da99b0 f7020f30
[ 1202.017559]  f305af70 f7000200 f7028f30 f3da99b8 f5a99f4c c01908f8 00000282 00000000
[ 1202.017563]  f3da99b8 f4432f40 f5a99f5c c01a8388 00000010 f2b1ddb8 f5a99f7c c01950e1
[ 1202.017567] Call Trace:
[ 1202.017569]  [<c01a8388>] ? single_release+0x1c/0x22
[ 1202.017571]  [<c01a833a>] ? seq_release+0x18/0x1d
[ 1202.017574]  [<c01908f8>] ? kfree+0x99/0xe3
[ 1202.017576]  [<c01a8388>] ? single_release+0x1c/0x22
[ 1202.017579]  [<c01950e1>] ? __fput+0xca/0x175
[ 1202.017582]  [<c01951a5>] ? fput+0x19/0x1b
[ 1202.017584]  [<c019287b>] ? filp_close+0x51/0x5b
[ 1202.017586]  [<c01928ef>] ? sys_close+0x6a/0xa4
[ 1202.017588]  [<c0103507>] ? sysenter_do_call+0x12/0x3a
[ 1202.017591] Code: 5d e8 89 54 03 fc 8b 5d d8 8b 45 e8 8b 4b 0c 29 c8 f7 67 30 3b 57 38 72 04 0f 0b eb fe 89 d0 0f af 47 2c 8d 04 01 39 45 e8 74 04 <0f> 0b eb fe 8b 45 d8 c7 44 90 1c fe ff ff ff 8b 47 34 f6 c4 08 
[ 1202.017613] EIP: [<c0190686>] cache_free_debugcheck+0x1cd/0x2a4 SS:ESP 0068:f5a99f04
[ 1202.017619] ---[ end trace 32f9f05d27403736 ]---
[ 1202.017624] BUG: sleeping function called from invalid context at kernel/rwsem.c:21
[ 1202.017626] in_atomic(): 0, irqs_disabled(): 1, pid: 2229, name: ps
[ 1202.017628] INFO: lockdep is turned off.
[ 1202.017629] Pid: 2229, comm: ps Tainted: G S    D W  2.6.29-rc6-bisect-00121-g64e7130 #1
[ 1202.017631] Call Trace:
[ 1202.017635]  [<c01241b2>] __might_sleep+0xd6/0xdb
[ 1202.017638]  [<c03cd167>] down_read+0x15/0x3e
[ 1202.017643]  [<c0153fd0>] acct_collect+0x37/0x156
[ 1202.017646]  [<c012c671>] do_exit+0x13f/0x6af
[ 1202.017648]  [<c0288d64>] ? _raw_spin_unlock+0x74/0x78
[ 1202.017651]  [<c03cb5a8>] ? printk+0xf/0x17
[ 1202.017653]  [<c012989a>] ? oops_exit+0x23/0x28
[ 1202.017656]  [<c0105ffb>] oops_end+0xa1/0xa9
[ 1202.017659]  [<c0106187>] die+0x54/0x5a
[ 1202.017661]  [<c01040ab>] do_trap+0x89/0xa2
[ 1202.017664]  [<c01043b3>] ? do_invalid_op+0x0/0x84
[ 1202.017666]  [<c010442d>] do_invalid_op+0x7a/0x84
[ 1202.017669]  [<c0190686>] ? cache_free_debugcheck+0x1cd/0x2a4
[ 1202.017673]  [<c02c08bb>] ? n_tty_read+0x394/0x620
[ 1202.017678]  [<c011a5ac>] ? kernel_map_pages+0xde/0xfe
[ 1202.017681]  [<c03ce38a>] error_code+0x72/0x78
[ 1202.017684]  [<c0190686>] ? cache_free_debugcheck+0x1cd/0x2a4
[ 1202.017686]  [<c01a8388>] ? single_release+0x1c/0x22
[ 1202.017689]  [<c01a833a>] ? seq_release+0x18/0x1d
[ 1202.017691]  [<c01908f8>] kfree+0x99/0xe3
[ 1202.017693]  [<c01a8388>] single_release+0x1c/0x22
[ 1202.017696]  [<c01950e1>] __fput+0xca/0x175
[ 1202.017698]  [<c01951a5>] fput+0x19/0x1b
[ 1202.017700]  [<c019287b>] filp_close+0x51/0x5b
[ 1202.017702]  [<c01928ef>] sys_close+0x6a/0xa4
[ 1202.017704]  [<c0103507>] sysenter_do_call+0x12/0x3a
[ 1202.017858] BUG: unable to handle kernel paging request at 01454126
[ 1202.017861] IP: [<c011ef4a>] update_curr+0xc/0x17e
[ 1202.017865] *pde = 00000000 
[ 1202.017867] Oops: 0000 [#2] SMP DEBUG_PAGEALLOC
[ 1202.017870] last sysfs file: /sys/class/net/eth1.5/address
[ 1202.017871] Modules linked in: 8021q virtio_balloon virtio_pci thermal_sys
[ 1202.017874] 
[ 1202.017877] Pid: 2229, comm: ps Tainted: G S    D W  (2.6.29-rc6-bisect-00121-g64e7130 #1) 
[ 1202.017879] EIP: 0060:[<c011ef4a>] EFLAGS: 00010086 CPU: 0
[ 1202.017881] EIP is at update_curr+0xc/0x17e
[ 1202.017883] EAX: 014540f6 EBX: f8163c85 ECX: 00000000 EDX: f8163c85
[ 1202.017886] ESI: c985ffff EDI: 014540f6 EBP: f5a99be0 ESP: f5a99bb4
[ 1202.017888]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
[ 1202.017890] Process ps (pid: 2229, ti=f5a98000 task=f47e1708 task.ti=f5a98000)
[ 1202.017892] Stack:
[ 1202.017893]  f61c7000 00000000 014540f6 ddd69bd9 00000117 00000046 c3647d90 00000004
[ 1202.017897]  f8163c85 c985ffff 014540f6 f5a99c00 c011f642 014540f6 c3647d80 00000082
[ 1202.017901]  f8163c85 c985ffff 014540f6 f5a99c18 c0121100 00000004 f448fd38 00000000
[ 1202.017905] Call Trace:
[ 1202.017907]  [<f8163c85>] ? vlan_dev_neigh_setup+0x23/0x2a [8021q]
[ 1202.017912]  [<c011f642>] ? dequeue_entity+0x13/0x134
[ 1202.017915]  [<f8163c85>] ? vlan_dev_neigh_setup+0x23/0x2a [8021q]
[ 1202.017920]  [<c0121100>] ? __set_se_shares+0x23/0x44
[ 1202.017923]  [<c0121241>] ? tg_shares_up+0x120/0x153
[ 1202.017926]  [<c011e349>] ? walk_tg_tree+0x6b/0x96
[ 1202.017928]  [<c0121121>] ? tg_shares_up+0x0/0x153
[ 1202.017931]  [<c011d3c2>] ? tg_nop+0x0/0x7
[ 1202.017933]  [<c01242b4>] ? update_shares+0x53/0x59
[ 1202.017936]  [<c0124313>] ? try_to_wake_up+0x59/0x179
[ 1202.017939]  [<c012443e>] ? default_wake_function+0xb/0xd
[ 1202.017942]  [<c013a826>] ? autoremove_wake_function+0xf/0x33
[ 1202.017946]  [<c011dd04>] ? __wake_up_common+0x35/0x5b
[ 1202.017949]  [<c011ea88>] ? __wake_up_sync+0x31/0x44
[ 1202.017951]  [<c0199a55>] ? pipe_release+0x56/0x8b
[ 1202.017955]  [<c0199ab0>] ? pipe_write_release+0xf/0x11
[ 1202.017958]  [<c01950e1>] ? __fput+0xca/0x175
[ 1202.017960]  [<c01951a5>] ? fput+0x19/0x1b
[ 1202.017963]  [<c019287b>] ? filp_close+0x51/0x5b
[ 1202.017965]  [<c012af64>] ? put_files_struct+0x68/0xaa
[ 1202.017968]  [<c012afdd>] ? exit_files+0x37/0x3c
[ 1202.017970]  [<c012c6db>] ? do_exit+0x1a9/0x6af
[ 1202.017973]  [<c0288d64>] ? _raw_spin_unlock+0x74/0x78
[ 1202.017975]  [<c03cb5a8>] ? printk+0xf/0x17
[ 1202.017978]  [<c012989a>] ? oops_exit+0x23/0x28
[ 1202.017980]  [<c0105ffb>] ? oops_end+0xa1/0xa9
[ 1202.017983]  [<c0106187>] ? die+0x54/0x5a
[ 1202.017986]  [<c01040ab>] ? do_trap+0x89/0xa2
[ 1202.017989]  [<c01043b3>] ? do_invalid_op+0x0/0x84
[ 1202.017994]  [<c010442d>] ? do_invalid_op+0x7a/0x84
[ 1202.017997]  [<c0190686>] ? cache_free_debugcheck+0x1cd/0x2a4
[ 1202.018001]  [<c02c08bb>] ? n_tty_read+0x394/0x620
[ 1202.018004]  [<c011a5ac>] ? kernel_map_pages+0xde/0xfe
[ 1202.018007]  [<c03ce38a>] ? error_code+0x72/0x78
[ 1202.018009]  [<c0190686>] ? cache_free_debugcheck+0x1cd/0x2a4
[ 1202.018013]  [<c01a8388>] ? single_release+0x1c/0x22
[ 1202.018015]  [<c01a833a>] ? seq_release+0x18/0x1d
[ 1202.018018]  [<c01908f8>] ? kfree+0x99/0xe3
[ 1202.018021]  [<c01a8388>] ? single_release+0x1c/0x22
[ 1202.018023]  [<c01950e1>] ? __fput+0xca/0x175
[ 1202.018026]  [<c01951a5>] ? fput+0x19/0x1b
[ 1202.018028]  [<c019287b>] ? filp_close+0x51/0x5b
[ 1202.018030]  [<c01928ef>] ? sys_close+0x6a/0xa4
[ 1202.018033]  [<c0103507>] ? sysenter_do_call+0x12/0x3a
[ 1202.018035] Code: 85 a0 0c 54 c0 8d 04 16 39 c3 75 08 5a 89 d8 5b 5e 5f 5d c3 8b 17 89 d8 e8 81 ef 2a 00 eb a5 55 89 e5 57 56 53 83 ec 20 89 45 dc <8b> 40 30 8b 55 dc 89 45 e8 8b 42 40 83 7d e8 00 8b 88 40 04 00 
[ 1202.018062] EIP: [<c011ef4a>] update_curr+0xc/0x17e SS:ESP 0068:f5a99bb4
[ 1202.018066] ---[ end trace 32f9f05d27403737 ]---
[ 1202.018068] Fixing recursive fault but reboot is needed!
[ 1202.016619] double fault, tss at c364eae0
[ 1202.016619] eip = f8163c65, esp = f3d94000
[ 1202.016619] eax = f3dda800, ebx = f3dda800, ecx = f8163c62, edx = f6234e40
[ 1202.016619] esi = f6234e40, edi = c05218bc

-- 
				WebSig: http://www.jukie.net/~bart/sig/
