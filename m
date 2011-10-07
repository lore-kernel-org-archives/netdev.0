From: Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com>
Subject: [RFC PATCH net 0/2] bonding: fix panics for making bonding device up
 and down repeatedly
Date: Fri, 07 Oct 2011 21:49:25 +0900
Message-ID: <20111007124925.7089.27260.stgit@ltc219.sdl.hitachi.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	yrl.pp-manager.tt@hitachi.com
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I hit a kernel BUG when I made a bonding interface up and down
repeatedly, as below.

# while true; do ifconfig bond0 down; done &
# while true; do ifconfig bond0 up; done &

(panic messages are bottom of this mail)

I investigated it and found the below commit tries to address 
this kind of parallel up&down problem.

a0db2dad0935e798973bb79676e722b82f177206 "bonding: properly stop
queuing work when requested"

However, above fix is not enough. I've found two different BUG
patterns.

They happens as follows:

(1) NULL pointer dereference in bond_handle_frame()
1. bond_close() sets bond->recv_probe to NULL.
2. bond_handle_frame() calls bond->recv_probe.
3. a panic happens when running bond_close() in parallel
   with bond_handle_frame().

(2) NULL pointer dereference in proccess_one_work()
1. bond_close() calls cancel_delayed_work() but its last works
   are not cancelled because they were already queued in workqueue.
2. bond_open() initializes work->data.
3. process_one_work() refers get_work_cwq(work)->wq->flags in
   workqueue.c:1850, but get_work_cwq() returns NULL when work->data
   has been initialized.
4. a panic happens when running process_one_work() in parallel with
   bond_open().

Each log is shown below. 

The following two patches addresses these panics in detail:
 [PATCH 1/2] use local function pointer of bond->recv_probe
		in bond_handle_frame
 [PATCH 2/2] use flush_delayed_work_sync in bond_close

Thanks,

============== log for a panic in bond_handle_frame=========

# while true; do ifconfig bond0 down; done &
[1] 1441
# while true; do ifconfig bond0 up; done &
[2] 3383
# [  296.794817] BUG: unable to handle kernel NULL pointer dereference at           (null)
[  296.795761] IP: [<          (null)>]           (null)
[  296.795761] PGD 79515067 PUD 375e9067 PMD 0 
[  296.795761] Oops: 0010 [#1] SMP 
[  296.795761] CPU 0 
[  296.795761] Modules linked in: nfs lockd fscache auth_rpcgss nfs_acl sunrpc bonding snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm pcspkr virtio_balloon microcode i2c_piix4 joydev snd_timer snd virtio_net i2c_core soundcore snd_page_alloc ipv6 xfs exportfs virtio_blk [last unloaded: speedstep_lib]
[  296.795761] 
[  296.795761] Pid: 0, comm: swapper Not tainted 3.1.0-rc9+ #4 Bochs Bochs
[  296.795761] RIP: 0010:[<0000000000000000>]  [<          (null)>]           (null)
[  296.795761] RSP: 0018:ffff88007fc03d28  EFLAGS: 00010286
[  296.795761] RAX: ffff88007b1e6500 RBX: ffff88007b1e6a00 RCX: 0000000000000000
[  296.795761] RDX: ffff880037670e00 RSI: ffff88007b522740 RDI: ffff88007b1e6500
[  296.795761] RBP: ffff88007fc03d50 R08: 0000000000000000 R09: 0000000180100001
[  296.795761] R10: ffffffff81a01fd8 R11: ffffffff81a01fd8 R12: ffff88007b522740
[  296.795761] R13: ffff880037670e00 R14: ffff88007b1e6500 R15: ffffe8ffffc02578
[  296.795761] FS:  0000000000000000(0000) GS:ffff88007fc00000(0000) knlGS:0000000000000000
[  296.795761] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  296.795761] CR2: 0000000000000000 CR3: 00000000794f9000 CR4: 00000000000006f0
[  296.795761] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  296.795761] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  296.795761] Process swapper (pid: 0, threadinfo ffffffff81a00000, task ffffffff81a0d020)
[  296.795761] Stack:
[  296.795761]  ffffffffa00b64d0 ffffffffa00b642e 0000000000000001 ffff880037a3f000
[  296.795761]  0000000000000000 ffff88007fc03db0 ffffffff813e2996 000000000000002e
[  296.795761]  ffff88007b1e6a00 ffff88007fc03d90 ffffffff81b5be40 ffff88007b1e6a00
[  296.795761] Call Trace:
[  296.795761]  <IRQ> 
[  296.795761]  [<ffffffffa00b64d0>] ? bond_handle_frame+0xa2/0x160 [bonding]
[  296.795761]  [<ffffffffa00b642e>] ? skb_cow_head+0x70/0x70 [bonding]
[  296.795761]  [<ffffffff813e2996>] __netif_receive_skb+0x2c5/0x417
[  296.795761]  [<ffffffff813e5c22>] netif_receive_skb+0x6c/0x73
[  296.795761]  [<ffffffffa0155360>] virtnet_poll+0x49a/0x562 [virtio_net]
[  296.795761]  [<ffffffff813e623b>] net_rx_action+0xa9/0x1b8
[  296.795761]  [<ffffffff8105c61b>] __do_softirq+0xc9/0x1b5
[  296.795761]  [<ffffffff81014fa0>] ? sched_clock+0x9/0xd
[  296.795761]  [<ffffffff814b8c2c>] call_softirq+0x1c/0x30
[  296.795761]  [<ffffffff81010af9>] do_softirq+0x46/0x81
[  296.795761]  [<ffffffff8105c8e3>] irq_exit+0x57/0xb1
[  296.795761]  [<ffffffff814b950e>] do_IRQ+0x8e/0xa5
[  296.795761]  [<ffffffff814b062e>] common_interrupt+0x6e/0x6e
[  296.795761]  <EOI> 
[  296.795761]  [<ffffffff810b27c3>] ? rcu_needs_cpu+0x11a/0x1cb
[  296.795761]  [<ffffffff8102f2f1>] ? native_safe_halt+0xb/0xd
[  296.795761]  [<ffffffff81015b32>] default_idle+0x4e/0x86
[  296.795761]  [<ffffffff8100e2ed>] cpu_idle+0xae/0xe8
[  296.795761]  [<ffffffff8148cd6e>] rest_init+0x72/0x74
[  296.795761]  [<ffffffff81b74b7d>] start_kernel+0x3ab/0x3b6
[  296.795761]  [<ffffffff81b742c4>] x86_64_start_reservations+0xaf/0xb3
[  296.795761]  [<ffffffff81b74140>] ? early_idt_handlers+0x140/0x140
[  296.795761]  [<ffffffff81b743ca>] x86_64_start_kernel+0x102/0x111
[  296.795761] Code:  Bad RIP value.
[  296.795761] RIP  [<          (null)>]           (null)
[  296.795761]  RSP <ffff88007fc03d28>
[  296.795761] CR2: 0000000000000000
[  296.846940] ---[ end trace 2d2403022cca4fe1 ]---
[  296.847691] Kernel panic - not syncing: Fatal exception in interrupt
[  296.848701] Pid: 0, comm: swapper Tainted: G      D     3.1.0-rc9+ #4
[  296.849717] Call Trace:
[  296.850122]  <IRQ>  [<ffffffff814a6f2b>] panic+0x91/0x1a5
[  296.851080]  [<ffffffff814b13e6>] oops_end+0xb4/0xc5
[  296.851856]  [<ffffffff814a67d5>] no_context+0x203/0x212
[  296.852710]  [<ffffffff813e7601>] ? dev_queue_xmit+0x44b/0x472
[  296.853641]  [<ffffffff814a69af>] __bad_area_nosemaphore+0x1cb/0x1ec
[  296.854654]  [<ffffffffa00bc52c>] ? bond_3ad_xmit_xor+0x130/0x156 [bonding]
[  296.855747]  [<ffffffff814a69e3>] bad_area_nosemaphore+0x13/0x15
[  296.856705]  [<ffffffff814b33a3>] do_page_fault+0x1b8/0x37e
[  296.857602]  [<ffffffff811131d5>] ? virt_to_head_page+0xe/0x31
[  296.858533]  [<ffffffff81114f7a>] ? __cmpxchg_double_slab+0x2c/0x9e
[  296.859538]  [<ffffffff814a9d74>] ? __slab_alloc+0x39f/0x3b4
[  296.860453]  [<ffffffff813dcde0>] ? skb_clone+0x77/0x97
[  296.861277]  [<ffffffff8102fdbd>] ? pvclock_clocksource_read+0x48/0xb4
[  296.862325]  [<ffffffff814b08f5>] page_fault+0x25/0x30
[  296.863148]  [<ffffffffa00b64d0>] ? bond_handle_frame+0xa2/0x160 [bonding]
[  296.864235]  [<ffffffffa00b642e>] ? skb_cow_head+0x70/0x70 [bonding]
[  296.865242]  [<ffffffff813e2996>] __netif_receive_skb+0x2c5/0x417
[  296.866218]  [<ffffffff813e5c22>] netif_receive_skb+0x6c/0x73
[  296.867134]  [<ffffffffa0155360>] virtnet_poll+0x49a/0x562 [virtio_net]
[  296.868166]  [<ffffffff813e623b>] net_rx_action+0xa9/0x1b8
[  296.869037]  [<ffffffff8105c61b>] __do_softirq+0xc9/0x1b5
[  296.869888]  [<ffffffff81014fa0>] ? sched_clock+0x9/0xd
[  296.870726]  [<ffffffff814b8c2c>] call_softirq+0x1c/0x30
[  296.871584]  [<ffffffff81010af9>] do_softirq+0x46/0x81
[  296.872402]  [<ffffffff8105c8e3>] irq_exit+0x57/0xb1
[  296.873192]  [<ffffffff814b950e>] do_IRQ+0x8e/0xa5
[  296.873940]  [<ffffffff814b062e>] common_interrupt+0x6e/0x6e
[  296.874846]  <EOI>  [<ffffffff810b27c3>] ? rcu_needs_cpu+0x11a/0x1cb
[  296.875881]  [<ffffffff8102f2f1>] ? native_safe_halt+0xb/0xd
[  296.876771]  [<ffffffff81015b32>] default_idle+0x4e/0x86
[  296.877615]  [<ffffffff8100e2ed>] cpu_idle+0xae/0xe8
[  296.878412]  [<ffffffff8148cd6e>] rest_init+0x72/0x74
[  296.879215]  [<ffffffff81b74b7d>] start_kernel+0x3ab/0x3b6
[  296.880096]  [<ffffffff81b742c4>] x86_64_start_reservations+0xaf/0xb3
[  296.881189]  [<ffffffff81b74140>] ? early_idt_handlers+0x140/0x140
[  296.882169]  [<ffffffff81b743ca>] x86_64_start_kernel+0x102/0x111



============== log for a panic in proccess_one_work=========

# while true; do ifconfig bond0 down; done &
[1] 1463
# while true; do ifconfig bond0 up; done &
[2] 7093
# [  734.859163] BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
[  734.862624] IP: [<ffffffff8106da2e>] process_one_work+0x104/0x2a9
[  734.862624] PGD 0 
[  734.862624] Oops: 0000 [#1] SMP 
[  734.862624] CPU 3 
[  734.862624] Modules linked in: fuse nfs lockd fscache auth_rpcgss nfs_acl sunrpc bonding snd_hda_intel snd_hda_codec snd_hwdep joydev snd_seq snd_seq_device snd_pcm pcspkr microcode virtio_net virtio_balloon snd_timer snd soundcore snd_page_alloc i2c_piix4 i2c_core ipv6 xfs exportfs virtio_blk [last unloaded: speedstep_lib]
[  734.862624] 
[  734.862624] Pid: 47, comm: kworker/u:1 Not tainted 3.1.0-rc9+ #4 Bochs Bochs
[  734.862624] RIP: 0010:[<ffffffff8106da2e>]  [<ffffffff8106da2e>] process_one_work+0x104/0x2a9
[  734.862624] RSP: 0018:ffff880078f95e50  EFLAGS: 00010046
[  734.862624] RAX: 0000000000000000 RBX: ffff880078f5af00 RCX: 0000000000010000
[  734.862624] RDX: 0000000000010000 RSI: ffff88007bcada50 RDI: ffff88007bcad8f8
[  734.862624] RBP: ffff880078f95ea0 R08: ffff88007bcad900 R09: ffff880076c1bf00
[  734.862624] R10: ffff880076c1bf00 R11: ffff88007fd92e40 R12: ffffffff81cc3dc0
[  734.862624] R13: ffff88007a81f600 R14: ffffffffa00b8759 R15: ffff88007a81f607
[  734.862624] FS:  0000000000000000(0000) GS:ffff88007fd80000(0000) knlGS:0000000000000000
[  734.862624] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  734.862624] CR2: 0000000000000008 CR3: 0000000001a05000 CR4: 00000000000006e0
[  734.862624] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  734.862624] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  734.862624] Process kworker/u:1 (pid: 47, threadinfo ffff880078f94000, task ffff880078f3ae40)
[  734.862624] Stack:
[  734.862624]  ffffffff81cc3dc8 ffff88007bcad900 0000009a7bc54a70 ffff88007bcad8f8
[  734.862624]  ffffffff81cc3dc0 ffff880078f5af00 ffffffff81cc3dc0 ffff880078f5af20
[  734.862624]  ffff880078f3ae40 ffff880078f5af20 ffff880078f95ee0 ffffffff8106e5aa
[  734.862624] Call Trace:
[  734.862624]  [<ffffffff8106e5aa>] worker_thread+0xda/0x15d
[  734.862624]  [<ffffffff8106e4d0>] ? manage_workers+0x176/0x176
[  734.862624]  [<ffffffff810719f7>] kthread+0x84/0x8c
[  734.862624]  [<ffffffff814b8b34>] kernel_thread_helper+0x4/0x10
[  734.862624]  [<ffffffff81071973>] ? kthread_worker_fn+0x148/0x148
[  734.862624]  [<ffffffff814b8b30>] ? gs_change+0x13/0x13
[  734.862624] Code: 8b 55 c8 48 89 42 08 48 89 42 10 41 f6 44 24 1c 10 74 31 49 8b 7c 24 08 49 8d 44 24 08 48 39 c7 74 1c 48 83 ef 08 e8 6a e0 ff ff 
[  734.862624]  8b 40 08 f6 00 10 74 0a 4c 89 e7 e8 85 e4 ff ff eb 06 41 83 
[  734.862624] RIP  [<ffffffff8106da2e>] process_one_work+0x104/0x2a9
[  734.862624]  RSP <ffff880078f95e50>
[  734.862624] CR2: 0000000000000008
[  734.862624] ---[ end trace 7cf0d13647b8711b ]---
[  734.997227] BUG: unable to handle kernel paging request at fffffffffffffff8

Mess[age  fr om734.998114] IP:

---

Mitsuo Hayasaka (2):
      [BUGFIX] bonding: use flush_delayed_work_sync in bond_close
      [BUGFIX] bonding: use local function pointer of bond->recv_probe in bond_handle_frame


 drivers/net/bonding/bond_main.c |   17 ++++++++++-------
 1 files changed, 10 insertions(+), 7 deletions(-)

-- 
Mitsuo Hayasaka (mitsuo.hayasaka.hu@hitachi.com)
