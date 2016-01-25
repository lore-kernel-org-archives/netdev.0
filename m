From: Dmitry Vyukov <dvyukov@google.com>
Subject: net/irda: use-after-free in ircomm_param_request
Date: Mon, 25 Jan 2016 16:59:22 +0100
Message-ID: <CACT4Y+bP+_KTgjksXJbjOj-CjgUgKU=dR6BVuA81kmJ9b9kJ9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Eric Dumazet <edumazet@google.com>
To: Samuel Ortiz <samuel@sortiz.org>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I've hit the following use-after-free report while running syzkaller fuzzer:

==================================================================
BUG: KASAN: use-after-free in ircomm_param_request+0x514/0x570 at addr
ffff880035732c78
Read of size 4 by task syz-executor/10736
=============================================================================
BUG skbuff_head_cache (Not tainted): kasan: bad access detected
-----------------------------------------------------------------------------

INFO: Allocated in __alloc_skb+0xba/0x5f0 age=4 cpu=1 pid=10738
[<      none      >] kmem_cache_alloc_node+0x93/0x2f0 mm/slub.c:2632
[<      none      >] __alloc_skb+0xba/0x5f0 net/core/skbuff.c:216
[<     inline     >] alloc_skb include/linux/skbuff.h:894
[<      none      >] ircomm_param_request+0x34b/0x570
net/irda/ircomm/ircomm_param.c:115
[<      none      >] ircomm_port_raise_dtr_rts+0x6a/0xc0
net/irda/ircomm/ircomm_tty.c:122
[<      none      >] tty_port_raise_dtr_rts+0x6a/0x90 drivers/tty/tty_port.c:313
[<     inline     >] ircomm_tty_block_til_ready net/irda/ircomm/ircomm_tty.c:291
[<      none      >] ircomm_tty_open+0xad7/0x12f0
net/irda/ircomm/ircomm_tty.c:462
[<      none      >] tty_open+0x34d/0xf80 drivers/tty/tty_io.c:2099
[<      none      >] chrdev_open+0x22a/0x4c0 fs/char_dev.c:388
[<      none      >] do_dentry_open+0x6a2/0xcb0 fs/open.c:736
[<      none      >] vfs_open+0x17b/0x1f0 fs/open.c:853
[<     inline     >] do_last fs/namei.c:3254
[<      none      >] path_openat+0xde9/0x5e30 fs/namei.c:3386
[<      none      >] do_filp_open+0x18e/0x250 fs/namei.c:3421
[<      none      >] do_sys_open+0x1fc/0x420 fs/open.c:1022
[<     inline     >] SYSC_open fs/open.c:1040
[<      none      >] SyS_open+0x2d/0x40 fs/open.c:1035

INFO: Freed in kfree_skbmem+0xe6/0x100 age=10 cpu=1 pid=1362
[<      none      >] kmem_cache_free+0x2e4/0x360 mm/slub.c:2844
[<      none      >] kfree_skbmem+0xe6/0x100 net/core/skbuff.c:612
[<     inline     >] __kfree_skb net/core/skbuff.c:674
[<      none      >] consume_skb+0xe4/0x2c0 net/core/skbuff.c:746
[<      none      >] ircomm_tty_do_softint+0x131/0x280
net/irda/ircomm/ircomm_tty.c:552
[<      none      >] process_one_work+0x796/0x1440 kernel/workqueue.c:2037
[<      none      >] worker_thread+0xdb/0xfc0 kernel/workqueue.c:2171
[<      none      >] kthread+0x23f/0x2d0 drivers/block/aoe/aoecmd.c:1303
[<      none      >] ret_from_fork+0x3f/0x70 arch/x86/entry/entry_64.S:468

INFO: Slab 0xffffea0000d5cc00 objects=23 used=0 fp=0xffff880035732c00
flags=0x1fffc0000004080
INFO: Object 0xffff880035732c00 @offset=11264 fp=0xffff880035731340
CPU: 0 PID: 10736 Comm: syz-executor Tainted: G    B           4.5.0-rc1+ #280
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 00000000ffffffff ffff880000b174c8 ffffffff8299a06d ffff88003de85200
 ffff880035732c00 ffff880035730000 ffff880000b174f8 ffffffff81752854
 ffff88003de85200 ffffea0000d5cc00 ffff880035732c00 0000000000000001

Call Trace:
 [<ffffffff8175bebe>] __asan_report_load4_noabort+0x3e/0x40
mm/kasan/report.c:294
 [<ffffffff85a59704>] ircomm_param_request+0x514/0x570
net/irda/ircomm/ircomm_param.c:140
 [<ffffffff85a4f34a>] ircomm_port_raise_dtr_rts+0x6a/0xc0
net/irda/ircomm/ircomm_tty.c:122
 [<ffffffff82d0cd9a>] tty_port_raise_dtr_rts+0x6a/0x90
drivers/tty/tty_port.c:313
 [<     inline     >] ircomm_tty_block_til_ready
net/irda/ircomm/ircomm_tty.c:291
 [<ffffffff85a506c7>] ircomm_tty_open+0xad7/0x12f0
net/irda/ircomm/ircomm_tty.c:462
 [<ffffffff82cf6dcd>] tty_open+0x34d/0xf80 drivers/tty/tty_io.c:2099
 [<ffffffff817b91aa>] chrdev_open+0x22a/0x4c0 fs/char_dev.c:388
 [<ffffffff817a4b02>] do_dentry_open+0x6a2/0xcb0 fs/open.c:736
 [<ffffffff817a81db>] vfs_open+0x17b/0x1f0 fs/open.c:853
 [<     inline     >] do_last fs/namei.c:3254
 [<ffffffff817db389>] path_openat+0xde9/0x5e30 fs/namei.c:3386
 [<ffffffff817e3c0e>] do_filp_open+0x18e/0x250 fs/namei.c:3421
 [<ffffffff817a895c>] do_sys_open+0x1fc/0x420 fs/open.c:1022
 [<     inline     >] SYSC_open fs/open.c:1040
 [<ffffffff817a8bad>] SyS_open+0x2d/0x40 fs/open.c:1035
 [<ffffffff86359636>] entry_SYSCALL_64_fastpath+0x16/0x7a
arch/x86/entry/entry_64.S:185
==================================================================

It seems that skb can be freed after skb_put() and spinlock unlock,
but ircomm_param_request reads skb->len afterwards:

int ircomm_param_request(struct ircomm_tty_cb *self, __u8 pi, int flush)
{
    ...
    skb_put(skb, count);
    spin_unlock_irqrestore(&self->spinlock, flags);
    pr_debug("%s(), skb->len=%d\n", __func__ , skb->len);

On commit 92e963f50fc74041b5e9e744c330dca48e04f08d (Jan 24).
