From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net/ipv4: trying to register non-static key in ip_mc_clear_src
Date: Tue, 20 Jun 2017 10:17:17 -0700
Message-ID: <CAM_iQpXQfX9Dq865YsW1VknPBVMV4jgbHZjkOG44WVRfOtqC3g@mail.gmail.com>
References: <CAAeHK+xzcSvV+x3cBBFYu4vdCLHTPfL=sFpJB54_wbZx_0VJQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+xzcSvV+x3cBBFYu4vdCLHTPfL=sFpJB54_wbZx_0VJQg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 20, 2017 at 8:14 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
> Hi,
>
> I've got the following error report while fuzzing the kernel with syzkaller.
>
> On commit 9705596d08ac87c18aee32cc97f2783b7d14624e (4.12-rc6+).
>
> A reproducer and .config are attached.
>
> INFO: trying to register non-static key.
> the code is fine but needs lockdep annotation.
> turning off the locking correctness validator.
> CPU: 1 PID: 4099 Comm: a.out Not tainted 4.12.0-rc6+ #9
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:16
>  dump_stack+0x292/0x395 lib/dump_stack.c:52
>  register_lock_class+0x717/0x1aa0 kernel/locking/lockdep.c:755
>  ? 0xffffffffa0000000
>  __lock_acquire+0x269/0x3690 kernel/locking/lockdep.c:3255
>  lock_acquire+0x22d/0x560 kernel/locking/lockdep.c:3855
>  __raw_spin_lock_bh ./include/linux/spinlock_api_smp.h:135
>  _raw_spin_lock_bh+0x36/0x50 kernel/locking/spinlock.c:175
>  spin_lock_bh ./include/linux/spinlock.h:304
>  ip_mc_clear_src+0x27/0x1e0 net/ipv4/igmp.c:2076

Although triggered by my commit, but it is not fault of missing
spin_lock_init()... :-D

I will send a fix.

Thanks!


>  igmpv3_clear_delrec+0xee/0x4f0 net/ipv4/igmp.c:1194
>  ip_mc_destroy_dev+0x4e/0x190 net/ipv4/igmp.c:1736
>  inetdev_destroy net/ipv4/devinet.c:294
>  inetdev_event+0x5f5/0x1260 net/ipv4/devinet.c:1487
>  notifier_call_chain+0x14a/0x2e0 kernel/notifier.c:93
>  __raw_notifier_call_chain kernel/notifier.c:394
>  raw_notifier_call_chain+0x32/0x40 kernel/notifier.c:401
>  call_netdevice_notifiers_info+0x56/0x90 net/core/dev.c:1650
>  call_netdevice_notifiers net/core/dev.c:1666
>  dev_set_mtu+0x3be/0x5e0 net/core/dev.c:6733
>  dev_ifsioc+0x798/0x9f0 net/core/dev_ioctl.c:261
>  dev_ioctl+0x24e/0x1160 net/core/dev_ioctl.c:532
>  sock_do_ioctl+0x99/0xb0 net/socket.c:913
>  sock_ioctl+0x294/0x440 net/socket.c:1004
>  vfs_ioctl fs/ioctl.c:45
>  do_vfs_ioctl+0x1c4/0x1660 fs/ioctl.c:685
>  SYSC_ioctl fs/ioctl.c:700
>  SyS_ioctl+0x94/0xc0 fs/ioctl.c:691
>  entry_SYSCALL_64_fastpath+0x1f/0xbe arch/x86/entry/entry_64.S:203
> RIP: 0033:0x7efe2c1a4b79
> RSP: 002b:00007ffe2305a218 EFLAGS: 00000246 ORIG_RAX: 0000000000000010
> RAX: ffffffffffffffda RBX: 00007ffe2305a320 RCX: 00007efe2c1a4b79
> RDX: 0000000020dc4000 RSI: 0000000000008922 RDI: 0000000000000005
> RBP: 00000000004004e0 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000000
> R13: 00007ffe2305a320 R14: 0000000000000000 R15: 0000000000000000
> qemu: terminating on signal 15 from pid 174244
