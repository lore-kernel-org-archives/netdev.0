From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: KASAN: use-after-free Write in detach_if_pending
Date: Sun, 29 Oct 2017 13:45:09 +0100 (CET)
Message-ID: <alpine.DEB.2.20.1710291327310.1922@nanos>
References: <089e0825d424dfce58055c84205f@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: John Stultz <john.stultz@linaro.org>,
        LKML <linux-kernel@vger.kernel.org>, sboyd@codeaurora.org,
        syzkaller-bugs@googlegroups.com, netdev@vger.kernel.org,
        Jason Wang <jasowang@redhat.com>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: syzbot
        <bot+c0733f3aab92fc116dc1d10d8a25f5bf1f739eff@syzkaller.appspotmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <089e0825d424dfce58055c84205f@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 27 Oct 2017, syzbot wrote:

Cc'ed network folks.

> syzkaller hit the following crash on e7989f973ae1b90ec7c0b671c81f7f553affccbe
> git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/master
> compiler: gcc (GCC) 7.1.1 20170620
> .config is attached
> Raw console output is attached.
> C reproducer is attached
> syzkaller reproducer is attached. See https://goo.gl/kgGztJ
> for information about syzkaller reproducers
> 
> 
> BUG: KASAN: use-after-free in __write_once_size include/linux/compiler.h:305
> [inline]
> BUG: KASAN: use-after-free in __hlist_del include/linux/list.h:648 [inline]
> BUG: KASAN: use-after-free in detach_timer kernel/time/timer.c:791 [inline]
> BUG: KASAN: use-after-free in detach_if_pending+0x557/0x610
> kernel/time/timer.c:808
> Write of size 8 at addr ffff8801d3bab780 by task syzkaller900516/2986

That's just the point where this gets detected.

> CPU: 1 PID: 2986 Comm: syzkaller900516 Not tainted 4.13.0+ #82

> __hlist_del include/linux/list.h:648 [inline]
> detach_timer kernel/time/timer.c:791 [inline]
> detach_if_pending+0x557/0x610 kernel/time/timer.c:808
> try_to_del_timer_sync+0xa2/0x120 kernel/time/timer.c:1182
> del_timer_sync+0x18a/0x240 kernel/time/timer.c:1247
> tun_flow_uninit drivers/net/tun.c:1104 [inline]
> tun_free_netdev+0x105/0x1b0 drivers/net/tun.c:1776

  ^^^^^^^^^^^^ This shouldn't be called I think

> netdev_run_todo+0x870/0xca0 net/core/dev.c:7864
> rtnl_unlock+0xe/0x10 net/core/rtnetlink.c:106
> tun_detach drivers/net/tun.c:588 [inline]
> tun_chr_close+0x49/0x60 drivers/net/tun.c:2609
> __fput+0x333/0x7f0 fs/file_table.c:210
> ____fput+0x15/0x20 fs/file_table.c:246
> task_work_run+0x199/0x270 kernel/task_work.c:112
> exit_task_work include/linux/task_work.h:21 [inline]
> do_exit+0xa52/0x1b40 kernel/exit.c:865

Here is the allocation path

> alloc_netdev_mqs+0x16e/0xed0 net/core/dev.c:8018
> tun_set_iff drivers/net/tun.c:2022 [inline]
> __tun_chr_ioctl+0x12be/0x3d20 drivers/net/tun.c:2276
> tun_chr_ioctl+0x2a/0x40 drivers/net/tun.c:2521
> vfs_ioctl fs/ioctl.c:45 [inline]
> do_vfs_ioctl+0x1b1/0x1530 fs/ioctl.c:685
> SYSC_ioctl fs/ioctl.c:700 [inline]
> SyS_ioctl+0x8f/0xc0 fs/ioctl.c:691
> entry_SYSCALL_64_fastpath+0x1f/0xbe


And this is free.

> netdev_freemem net/core/dev.c:7970 [inline]
> free_netdev+0x2cf/0x360 net/core/dev.c:8132
> tun_set_iff drivers/net/tun.c:2105 [inline]

err_free_flow:
        tun_flow_uninit(tun);	<--------

> __tun_chr_ioctl+0x2cf6/0x3d20 drivers/net/tun.c:2276
> tun_chr_ioctl+0x2a/0x40 drivers/net/tun.c:2521
> vfs_ioctl fs/ioctl.c:45 [inline]
> do_vfs_ioctl+0x1b1/0x1530 fs/ioctl.c:685
> SYSC_ioctl fs/ioctl.c:700 [inline]
> SyS_ioctl+0x8f/0xc0 fs/ioctl.c:691
> entry_SYSCALL_64_fastpath+0x1f/0xbe

So it's the TUNSETIFF ioctl which first allocates and then frees in the
errorpath of tun_set_iff.

But for some reason this sticks and the exit of that task does it again,
which triggers KASAN in the innocent timer code.

Thanks,

	tglx
