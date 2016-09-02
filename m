From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: possible circular locking dependency detected
Date: Fri, 2 Sep 2016 10:10:12 -0700
Message-ID: <CA+55aFyENghfAe6gquZq34tUB+Lwbmtd28k+Qk2SZt+2awBTUQ@mail.gmail.com>
References: <CA+55aFy0cQq569m=0umnqZe6HJp8eQX2ed-yi=Fmntuhd2AM=Q@mail.gmail.com>
 <CA+55aFyNJg_brA4rGF0S2ve0V_2vuhZCFKEMFDNhHKEXoVCRGA@mail.gmail.com>
 <20160901204746.GR2356@ZenIV.linux.org.uk> <CA+55aFxzRnLCev6i_ehw9LFf-dw3s0znF+nP_c86i=219OZhfg@mail.gmail.com>
 <20160901210142.GS2356@ZenIV.linux.org.uk> <CA+55aFzxJM4pbS_jySERnCoOvvPbo+FgM7FZEATLJnCseD0j0g@mail.gmail.com>
 <CA+55aFwntZpaAutp_C=sLBg8ravfYGRoF4TTG1cfE3SjaJEOtw@mail.gmail.com>
 <1891948343.1299163.1472827400124.JavaMail.zimbra@redhat.com> <2036499187.1329780.1472831518842.JavaMail.zimbra@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Al Viro <viro@zeniv.linux.org.uk>,
        Miklos Szeredi <miklos@szeredi.hu>,
        Rainer Weikusat <rweikusat@cyberadapt.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Rainer Weikusat <rweikusat@mobileactivedefense.com>,
        Eric Sandeen <esandeen@redhat.com>,
        Network Development <netdev@vger.kernel.org>
To: CAI Qian <caiqian@redhat.com>, Dave Chinner <dchinner@redhat.com>,
        Christoph Hellwig <hch@lst.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:35352 "EHLO
        mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932826AbcIBRKO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 13:10:14 -0400
Received: by mail-oi0-f42.google.com with SMTP id p186so135095548oia.2
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2016 10:10:13 -0700 (PDT)
In-Reply-To: <2036499187.1329780.1472831518842.JavaMail.zimbra@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 2, 2016 at 8:51 AM, CAI Qian <caiqian@redhat.com> wrote:
>
> Actually, I took it back, and now spice seems start to deadlock using the reproducer,
>
> https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/syscalls/splice/splice01.c

This is a different deadlock, though. This is a deadlock due to mixed
lock ordering between the pipe mutex, the XFS "mr_lock", and the inode
mutex.

If I read the lockdep trace correctly, we have:

Normally we have write doing inode->i_mutex -> i_iolock.mr_lock fro
the regular write path.

But the normal splice "write()" case has

  pipe->mutex -> filesystem write lock (normally i_mutex)

(in iter_file_splice_write() that calls vfs_iter_write() that calls
->write_iter())

and then the XFS splice case as

    mr_lock -> pipe->mutex

in xfs_file_splice_read() calling splice_to_pipe().

So you end up with a A->B->C->A chain.

I think it's new to the new iomap based buffered write path in 4.8.

Dave, Christoph?

                 Linus

> [ 1749.956818]
> [ 1749.958492] ======================================================
> [ 1749.965386] [ INFO: possible circular locking dependency detected ]
> [ 1749.972381] 4.8.0-rc4+ #34 Not tainted
> [ 1749.976560] -------------------------------------------------------
> [ 1749.983554] splice01/35921 is trying to acquire lock:
> [ 1749.989188]  (&sb->s_type->i_mutex_key#14){+.+.+.}, at: [<ffffffffa083c1f7>] xfs_file_buffered_aio_write+0x127/0x840 [xfs]
> [ 1750.001644]
> [ 1750.001644] but task is already holding lock:
> [ 1750.008151]  (&pipe->mutex/1){+.+.+.}, at: [<ffffffff8169e7c1>] pipe_lock+0x51/0x60
> [ 1750.016753]
> [ 1750.016753] which lock already depends on the new lock.
> [ 1750.016753]
> [ 1750.025880]
> [ 1750.025880] the existing dependency chain (in reverse order) is:
> [ 1750.034229]
> -> #2 (&pipe->mutex/1){+.+.+.}:
> [ 1750.039139]        [<ffffffff812af52a>] lock_acquire+0x1fa/0x440
> [ 1750.045857]        [<ffffffff8266448d>] mutex_lock_nested+0xdd/0x850
> [ 1750.052963]        [<ffffffff8169e7c1>] pipe_lock+0x51/0x60
> [ 1750.059190]        [<ffffffff8171ee25>] splice_to_pipe+0x75/0x9e0
> [ 1750.066001]        [<ffffffff81723991>] __generic_file_splice_read+0xa71/0xe90
> [ 1750.074071]        [<ffffffff81723e71>] generic_file_splice_read+0xc1/0x1f0
> [ 1750.081849]        [<ffffffffa0838628>] xfs_file_splice_read+0x368/0x7b0 [xfs]
> [ 1750.089940]        [<ffffffff8171fa7e>] do_splice_to+0xee/0x150
> [ 1750.096555]        [<ffffffff817262f4>] SyS_splice+0x1144/0x1c10
> [ 1750.103269]        [<ffffffff81007b66>] do_syscall_64+0x1a6/0x500
> [ 1750.110084]        [<ffffffff8266ea7f>] return_from_SYSCALL_64+0x0/0x7a
> [ 1750.117479]
> -> #1 (&(&ip->i_iolock)->mr_lock#2){++++++}:
> [ 1750.123649]        [<ffffffff812af52a>] lock_acquire+0x1fa/0x440
> [ 1750.130362]        [<ffffffff8129b93e>] down_write_nested+0x5e/0xe0
> [ 1750.137371]        [<ffffffffa086772e>] xfs_ilock+0x2fe/0x550 [xfs]
> [ 1750.144397]        [<ffffffffa083c204>] xfs_file_buffered_aio_write+0x134/0x840 [xfs]
> [ 1750.153175]        [<ffffffffa083cb7d>] xfs_file_write_iter+0x26d/0x6d0 [xfs]
> [ 1750.161177]        [<ffffffff8168374e>] __vfs_write+0x2be/0x640
> [ 1750.167799]        [<ffffffff816876e2>] vfs_write+0x152/0x4b0
> [ 1750.174220]        [<ffffffff8168b0df>] SyS_write+0xdf/0x1d0
> [ 1750.180547]        [<ffffffff8266e9bc>] entry_SYSCALL_64_fastpath+0x1f/0xbd
> [ 1750.188328]
> -> #0 (&sb->s_type->i_mutex_key#14){+.+.+.}:
> [ 1750.194508]        [<ffffffff812adbc3>] __lock_acquire+0x3043/0x3dd0
> [ 1750.201609]        [<ffffffff812af52a>] lock_acquire+0x1fa/0x440
> [ 1750.208321]        [<ffffffff82668cda>] down_write+0x5a/0xe0
> [ 1750.214645]        [<ffffffffa083c1f7>] xfs_file_buffered_aio_write+0x127/0x840 [xfs]
> [ 1750.223421]        [<ffffffffa083cb7d>] xfs_file_write_iter+0x26d/0x6d0 [xfs]
> [ 1750.231423]        [<ffffffff816859be>] vfs_iter_write+0x29e/0x550
> [ 1750.238330]        [<ffffffff81722729>] iter_file_splice_write+0x529/0xb70
> [ 1750.246012]        [<ffffffff817258d4>] SyS_splice+0x724/0x1c10
> [ 1750.252627]        [<ffffffff81007b66>] do_syscall_64+0x1a6/0x500
> [ 1750.259438]        [<ffffffff8266ea7f>] return_from_SYSCALL_64+0x0/0x7a
> [ 1750.266830]
> [ 1750.266830] other info that might help us debug this:
> [ 1750.266830]
> [ 1750.275764] Chain exists of:
>   &sb->s_type->i_mutex_key#14 --> &(&ip->i_iolock)->mr_lock#2 --> &pipe->mutex/1
>
> [ 1750.287213]  Possible unsafe locking scenario:
> [ 1750.287213]
> [ 1750.293817]        CPU0                    CPU1
> [ 1750.298871]        ----                    ----
> [ 1750.303924]   lock(&pipe->mutex/1);
> [ 1750.307845]                                lock(&(&ip->i_iolock)->mr_lock#2);
> [ 1750.315836]                                lock(&pipe->mutex/1);
> [ 1750.322567]   lock(&sb->s_type->i_mutex_key#14);
> [ 1750.327748]
> [ 1750.327748]  *** DEADLOCK ***
> [ 1750.327748]
> [ 1750.334355] 2 locks held by splice01/35921:
> [ 1750.339019]  #0:  (sb_writers#8){.+.+.+}, at: [<ffffffff8168f444>] __sb_start_write+0xb4/0xf0
> [ 1750.348595]  #1:  (&pipe->mutex/1){+.+.+.}, at: [<ffffffff8169e7c1>] pipe_lock+0x51/0x60
> [ 1750.357686]
> [ 1750.357686] stack backtrace:
> [ 1750.362548] CPU: 50 PID: 35921 Comm: splice01 Not tainted 4.8.0-rc4+ #34
> [ 1750.370026] Hardware name: Intel Corporation S2600WTT/S2600WTT, BIOS GRNDSDP1.86B.0044.R00.1501191641 01/19/2015
> [ 1750.381382]  0000000000000000 000000003bca9477 ffff88044c4176e0 ffffffff81a3d191
> [ 1750.389675]  ffffffff84292880 ffffffff842b9e30 ffff88044c417730 ffffffff812a6aa6
> [ 1750.397968]  ffffffff84292880 ffff880414a28cd0 ffff88044c417850 ffff880414a28cd0
> [ 1750.406261] Call Trace:
> [ 1750.408992]  [<ffffffff81a3d191>] dump_stack+0x85/0xc4
> [ 1750.414725]  [<ffffffff812a6aa6>] print_circular_bug+0x356/0x460
> [ 1750.421428]  [<ffffffff812adbc3>] __lock_acquire+0x3043/0x3dd0
> [ 1750.427942]  [<ffffffff81414fe9>] ? is_ftrace_trampoline+0x99/0xe0
> [ 1750.434840]  [<ffffffff812aab80>] ? debug_check_no_locks_freed+0x2c0/0x2c0
> [ 1750.442512]  [<ffffffff812a0272>] ? add_lock_to_list.isra.29.constprop.45+0x142/0x1d0
> [ 1750.451249]  [<ffffffff812acd9e>] ? __lock_acquire+0x221e/0x3dd0
> [ 1750.457952]  [<ffffffff812aa3ce>] ? trace_hardirqs_on_caller+0x3fe/0x580
> [ 1750.465430]  [<ffffffff812af52a>] lock_acquire+0x1fa/0x440
> [ 1750.471578]  [<ffffffffa083c1f7>] ? xfs_file_buffered_aio_write+0x127/0x840 [xfs]
> [ 1750.479929]  [<ffffffff82668cda>] down_write+0x5a/0xe0
> [ 1750.485691]  [<ffffffffa083c1f7>] ? xfs_file_buffered_aio_write+0x127/0x840 [xfs]
> [ 1750.494070]  [<ffffffffa083c1f7>] xfs_file_buffered_aio_write+0x127/0x840 [xfs]
> [ 1750.502226]  [<ffffffff81007b66>] ? do_syscall_64+0x1a6/0x500
> [ 1750.508666]  [<ffffffffa083c0d0>] ? xfs_file_dio_aio_write+0xca0/0xca0 [xfs]
> [ 1750.516532]  [<ffffffff812a9f72>] ? mark_held_locks+0xd2/0x130
> [ 1750.523044]  [<ffffffff812f5887>] ? debug_lockdep_rcu_enabled+0x77/0x90
> [ 1750.530417]  [<ffffffff82664873>] ? mutex_lock_nested+0x4c3/0x850
> [ 1750.537243]  [<ffffffffa083cb7d>] xfs_file_write_iter+0x26d/0x6d0 [xfs]
> [ 1750.544625]  [<ffffffff8169e7c1>] ? pipe_lock+0x51/0x60
> [ 1750.550456]  [<ffffffff816859be>] vfs_iter_write+0x29e/0x550
> [ 1750.556770]  [<ffffffff81685720>] ? vfs_iter_read+0x540/0x540
> [ 1750.563181]  [<ffffffff81722729>] iter_file_splice_write+0x529/0xb70
> [ 1750.570271]  [<ffffffff81722200>] ? page_cache_pipe_buf_confirm+0x1f0/0x1f0
> [ 1750.578041]  [<ffffffff812f5a33>] ? rcu_read_lock_sched_held+0xa3/0x120
> [ 1750.585423]  [<ffffffff812f6055>] ? rcu_sync_lockdep_assert+0x75/0xb0
> [ 1750.592609]  [<ffffffff8129bd6c>] ? percpu_down_read+0x5c/0xa0
> [ 1750.599118]  [<ffffffff8168f444>] ? __sb_start_write+0xb4/0xf0
> [ 1750.605627]  [<ffffffff817258d4>] SyS_splice+0x724/0x1c10
> [ 1750.611651]  [<ffffffff812f5a33>] ? rcu_read_lock_sched_held+0xa3/0x120
> [ 1750.619033]  [<ffffffff817251b0>] ? compat_SyS_vmsplice+0x1f0/0x1f0
> [ 1750.626025]  [<ffffffff81007a12>] ? do_syscall_64+0x52/0x500
> [ 1750.632338]  [<ffffffff817251b0>] ? compat_SyS_vmsplice+0x1f0/0x1f0
> [ 1750.639330]  [<ffffffff81007b66>] do_syscall_64+0x1a6/0x500
> [ 1750.645549]  [<ffffffff8100401a>] ? trace_hardirqs_on_thunk+0x1a/0x1c
> [ 1750.652737]  [<ffffffff8266ea7f>] entry_SYSCALL64_slow_path+0x25/0x25
