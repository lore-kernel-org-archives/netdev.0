From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Deadlock between bind and splice
Date: Fri, 06 Nov 2015 07:42:15 -0800
Message-ID: <1446824535.4184.69.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CACT4Y+brDX=C15jSs33zGaCBt2BDPPzBcgqtKA2dYMdviYjKww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	syzkaller <syzkaller@googlegroups.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Dmitry Vyukov <dvyukov@google.com>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	linux-fsdevel@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+brDX=C15jSs33zGaCBt2BDPPzBcgqtKA2dYMdviYjKww@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-11-06 at 13:58 +0100, Dmitry Vyukov wrote:
> Hello,
> 
> I am on revision d1e41ff11941784f469f17795a4d9425c2eb4b7a (Nov 5) and
> seeing the following lockdep reports. I don't have exact reproducer
> program as it is caused by several independent programs (state
> accumulated in kernel across invocations); if the report is not enough
> I can try to cook a reproducer.
> 
> Thanks.
> 
> [ INFO: possible circular locking dependency detected ]
> 4.3.0+ #30 Not tainted
> -------------------------------------------------------
> a.out/9972 is trying to acquire lock:
>  (&pipe->mutex/1){+.+.+.}, at: [<     inline     >] pipe_lock_nested
> fs/pipe.c:59
>  (&pipe->mutex/1){+.+.+.}, at: [<ffffffff814d6e46>]
> pipe_lock+0x56/0x70 fs/pipe.c:67
> 
> but task is already holding lock:
>  (sb_writers#5){.+.+.+}, at: [<ffffffff814c77ec>]
> __sb_start_write+0xec/0x130 fs/super.c:1198
> 
> which lock already depends on the new lock.
> 
> the existing dependency chain (in reverse order) is:
> 
> -> #2 (sb_writers#5){.+.+.+}:
>        [<ffffffff811f655d>] lock_acquire+0x16d/0x2f0
> kernel/locking/lockdep.c:3585
>        [<ffffffff811e434c>] percpu_down_read+0x3c/0xa0
> kernel/locking/percpu-rwsem.c:73
>        [<ffffffff814c77ec>] __sb_start_write+0xec/0x130 fs/super.c:1198
>        [<     inline     >] sb_start_write include/linux/fs.h:1449
>        [<ffffffff81526f4f>] mnt_want_write+0x3f/0xb0 fs/namespace.c:386
>        [<ffffffff814f43f6>] filename_create+0x106/0x450 fs/namei.c:3425
>        [<ffffffff814f4773>] kern_path_create+0x33/0x40 fs/namei.c:3471
>        [<     inline     >] unix_mknod net/unix/af_unix.c:849
>        [<ffffffff82acb27b>] unix_bind+0x41b/0xa10 net/unix/af_unix.c:917
>        [<ffffffff827636da>] SYSC_bind+0x1ea/0x250 net/socket.c:1383
>        [<ffffffff82766164>] SyS_bind+0x24/0x30 net/socket.c:1369
>        [<ffffffff82f21951>] entry_SYSCALL_64_fastpath+0x31/0x9a
> arch/x86/entry/entry_64.S:187
> 
> -> #1 (&u->readlock){+.+.+.}:
>        [<ffffffff811f655d>] lock_acquire+0x16d/0x2f0
> kernel/locking/lockdep.c:3585
>        [<     inline     >] __mutex_lock_common kernel/locking/mutex.c:518
>        [<ffffffff82f196c9>] mutex_lock_interruptible_nested+0xa9/0xa30
> kernel/locking/mutex.c:647
>        [<ffffffff82ac32bc>] unix_stream_sendpage+0x23c/0x700
> net/unix/af_unix.c:1768
>        [<ffffffff82761690>] kernel_sendpage+0x90/0xe0 net/socket.c:3278
>        [<ffffffff82761785>] sock_sendpage+0xa5/0xd0 net/socket.c:765
>        [<ffffffff8155668a>] pipe_to_sendpage+0x26a/0x320 fs/splice.c:720
>        [<     inline     >] splice_from_pipe_feed fs/splice.c:772
>        [<ffffffff815579a8>] __splice_from_pipe+0x268/0x740 fs/splice.c:889
>        [<ffffffff8155c2f7>] splice_from_pipe+0xf7/0x140 fs/splice.c:924
>        [<ffffffff8155c380>] generic_splice_sendpage+0x40/0x50 fs/splice.c:1097
>        [<     inline     >] do_splice_from fs/splice.c:1116
>        [<     inline     >] do_splice fs/splice.c:1392
>        [<     inline     >] SYSC_splice fs/splice.c:1695
>        [<ffffffff8155d005>] SyS_splice+0x845/0x17c0 fs/splice.c:1678
>        [<ffffffff82f21951>] entry_SYSCALL_64_fastpath+0x31/0x9a
> arch/x86/entry/entry_64.S:187
> 
> -> #0 (&pipe->mutex/1){+.+.+.}:
>        [<     inline     >] check_prev_add kernel/locking/lockdep.c:1853
>        [<     inline     >] check_prevs_add kernel/locking/lockdep.c:1958
>        [<     inline     >] validate_chain kernel/locking/lockdep.c:2144
>        [<ffffffff811f3769>] __lock_acquire+0x36d9/0x40e0
> kernel/locking/lockdep.c:3206
>        [<ffffffff811f655d>] lock_acquire+0x16d/0x2f0
> kernel/locking/lockdep.c:3585
>        [<     inline     >] __mutex_lock_common kernel/locking/mutex.c:518
>        [<ffffffff82f18dcc>] mutex_lock_nested+0x9c/0x8f0
> kernel/locking/mutex.c:618
>        [<     inline     >] pipe_lock_nested fs/pipe.c:59
>        [<ffffffff814d6e46>] pipe_lock+0x56/0x70 fs/pipe.c:67
>        [<ffffffff815581c9>] iter_file_splice_write+0x199/0xb20 fs/splice.c:962
>        [<     inline     >] do_splice_from fs/splice.c:1116
>        [<     inline     >] do_splice fs/splice.c:1392
>        [<     inline     >] SYSC_splice fs/splice.c:1695
>        [<ffffffff8155d005>] SyS_splice+0x845/0x17c0 fs/splice.c:1678
>        [<ffffffff82f21951>] entry_SYSCALL_64_fastpath+0x31/0x9a
> arch/x86/entry/entry_64.S:187
> 
> other info that might help us debug this:
> 
> Chain exists of:
>   &pipe->mutex/1 --> &u->readlock --> sb_writers#5
> 
>  Possible unsafe locking scenario:
> 
>        CPU0                    CPU1
>        ----                    ----
>   lock(sb_writers#5);
>                                lock(&u->readlock);
>                                lock(sb_writers#5);
>   lock(&pipe->mutex/1);
> 
>  *** DEADLOCK ***
> 
> 1 lock held by a.out/9972:
>  #0:  (sb_writers#5){.+.+.+}, at: [<ffffffff814c77ec>]
> __sb_start_write+0xec/0x130 fs/super.c:1198
> 
> stack backtrace:
> CPU: 1 PID: 9972 Comm: a.out Not tainted 4.3.0+ #30
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>  00000000ffffffff ffff88003d777938 ffffffff81aad406 ffffffff846046a0
>  ffffffff84606860 ffffffff846086c0 ffff88003d777980 ffffffff811ec511
>  ffff88003d777a80 000000003cf79640 ffff88003cf79df0 ffff88003cf79e12
> Call Trace:
>  [<     inline     >] __dump_stack lib/dump_stack.c:15
>  [<ffffffff81aad406>] dump_stack+0x68/0x92 lib/dump_stack.c:50
>  [<ffffffff811ec511>] print_circular_bug+0x2d1/0x390
> kernel/locking/lockdep.c:1226
>  [<     inline     >] check_prev_add kernel/locking/lockdep.c:1853
>  [<     inline     >] check_prevs_add kernel/locking/lockdep.c:1958
>  [<     inline     >] validate_chain kernel/locking/lockdep.c:2144
>  [<ffffffff811f3769>] __lock_acquire+0x36d9/0x40e0 kernel/locking/lockdep.c:3206
>  [<ffffffff811f655d>] lock_acquire+0x16d/0x2f0 kernel/locking/lockdep.c:3585
>  [<     inline     >] __mutex_lock_common kernel/locking/mutex.c:518
>  [<ffffffff82f18dcc>] mutex_lock_nested+0x9c/0x8f0 kernel/locking/mutex.c:618
>  [<     inline     >] pipe_lock_nested fs/pipe.c:59
>  [<ffffffff814d6e46>] pipe_lock+0x56/0x70 fs/pipe.c:67
>  [<ffffffff815581c9>] iter_file_splice_write+0x199/0xb20 fs/splice.c:962
>  [<     inline     >] do_splice_from fs/splice.c:1116
>  [<     inline     >] do_splice fs/splice.c:1392
>  [<     inline     >] SYSC_splice fs/splice.c:1695
>  [<ffffffff8155d005>] SyS_splice+0x845/0x17c0 fs/splice.c:1678
>  [<ffffffff82f21951>] entry_SYSCALL_64_fastpath+0x31/0x9a
> arch/x86/entry/entry_64.S:187
> --

Thank you for this report.

pipe is part of fs, not net ;)

CC Al Viro.
