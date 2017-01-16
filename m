From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: fs, net: deadlock between bind/splice on af_unix
Date: Mon, 16 Jan 2017 10:32:40 +0100
Message-ID: <CACT4Y+ad1s6HPdw-ocQ5YfFx7qCeWb3z1k7F9+9KsNmw6+Tszw@mail.gmail.com>
References: <CACT4Y+Z981V+QLHr=PnQy1Dvxrpp-nCDhQtf+5HuNAusH+Vqxw@mail.gmail.com>
 <CACT4Y+a-fTzW95ViVP3knhNTa=h6XFB0bMddcyQVeeV+LbXKHw@mail.gmail.com>
 <CAM_iQpXu+fyjmvrYRB9+VJCdSLS=7Jiet762hqWDANfsOM0XWw@mail.gmail.com>
 <20161209013208.GW1555@ZenIV.linux.org.uk> <CAM_iQpXjeG5=wZyQP-yOKcB4WRfgGRjeQ+NDHyeSWwdU50Xh5g@mail.gmail.com>
 <20161209064144.GZ1555@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Rainer Weikusat <rweikusat@mobileactivedefense.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161209064144.GZ1555@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 9, 2016 at 7:41 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Thu, Dec 08, 2016 at 10:32:00PM -0800, Cong Wang wrote:
>
>> > Why do we do autobind there, anyway, and why is it conditional on
>> > SOCK_PASSCRED?  Note that e.g. for SOCK_STREAM we can bloody well get
>> > to sending stuff without autobind ever done - just use socketpair()
>> > to create that sucker and we won't be going through the connect()
>> > at all.
>>
>> In the case Dmitry reported, unix_dgram_sendmsg() calls unix_autobind(),
>> not SOCK_STREAM.
>
> Yes, I've noticed.  What I'm asking is what in there needs autobind triggered
> on sendmsg and why doesn't the same need affect the SOCK_STREAM case?
>
>> I guess some lock, perhaps the u->bindlock could be dropped before
>> acquiring the next one (sb_writer), but I need to double check.
>
> Bad idea, IMO - do you *want* autobind being able to come through while
> bind(2) is busy with mknod?


Ping. This is still happening on HEAD.


[ INFO: possible circular locking dependency detected ]
4.9.0 #1 Not tainted
-------------------------------------------------------
syz-executor6/25491 is trying to acquire lock:
 (&u->bindlock){+.+.+.}, at: [<ffffffff83962315>]
unix_autobind.isra.28+0xc5/0x880 net/unix/af_unix.c:852
but task is already holding lock:
 (&pipe->mutex/1){+.+.+.}, at: [<ffffffff81a45ac6>] pipe_lock_nested
fs/pipe.c:66 [inline]
 (&pipe->mutex/1){+.+.+.}, at: [<ffffffff81a45ac6>]
pipe_lock+0x56/0x70 fs/pipe.c:74
which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

       [  836.500536] [<ffffffff8156f989>] validate_chain
kernel/locking/lockdep.c:2265 [inline]
       [  836.500536] [<ffffffff8156f989>]
__lock_acquire+0x2149/0x3430 kernel/locking/lockdep.c:3338
       [  836.508456] [<ffffffff81571b11>] lock_acquire+0x2a1/0x630
kernel/locking/lockdep.c:3753
       [  836.516117] [<ffffffff8435f9be>] __mutex_lock_common
kernel/locking/mutex.c:521 [inline]
       [  836.516117] [<ffffffff8435f9be>]
mutex_lock_nested+0x24e/0xff0 kernel/locking/mutex.c:621
       [  836.524139] [<ffffffff81a45ac6>] pipe_lock_nested
fs/pipe.c:66 [inline]
       [  836.524139] [<ffffffff81a45ac6>] pipe_lock+0x56/0x70 fs/pipe.c:74
       [  836.531287] [<ffffffff81af63d2>]
iter_file_splice_write+0x262/0xf80 fs/splice.c:717
       [  836.539720] [<ffffffff81af84e0>] do_splice_from
fs/splice.c:869 [inline]
       [  836.539720] [<ffffffff81af84e0>] do_splice fs/splice.c:1160 [inline]
       [  836.539720] [<ffffffff81af84e0>] SYSC_splice fs/splice.c:1410 [inline]
       [  836.539720] [<ffffffff81af84e0>] SyS_splice+0x7c0/0x1690
fs/splice.c:1393
       [  836.547273] [<ffffffff84370981>] entry_SYSCALL_64_fastpath+0x1f/0xc2

       [  836.560730] [<ffffffff8156f989>] validate_chain
kernel/locking/lockdep.c:2265 [inline]
       [  836.560730] [<ffffffff8156f989>]
__lock_acquire+0x2149/0x3430 kernel/locking/lockdep.c:3338
       [  836.568655] [<ffffffff81571b11>] lock_acquire+0x2a1/0x630
kernel/locking/lockdep.c:3753
       [  836.576230] [<ffffffff81a326ca>]
percpu_down_read_preempt_disable include/linux/percpu-rwsem.h:35
[inline]
       [  836.576230] [<ffffffff81a326ca>] percpu_down_read
include/linux/percpu-rwsem.h:58 [inline]
       [  836.576230] [<ffffffff81a326ca>]
__sb_start_write+0x19a/0x2b0 fs/super.c:1252
       [  836.584168] [<ffffffff81ab1edf>] sb_start_write
include/linux/fs.h:1554 [inline]
       [  836.584168] [<ffffffff81ab1edf>] mnt_want_write+0x3f/0xb0
fs/namespace.c:389
       [  836.591744] [<ffffffff81a67581>] filename_create+0x151/0x610
fs/namei.c:3598
       [  836.599574] [<ffffffff81a67a73>] kern_path_create+0x33/0x40
fs/namei.c:3644
       [  836.607328] [<ffffffff83966683>] unix_mknod
net/unix/af_unix.c:967 [inline]
       [  836.607328] [<ffffffff83966683>] unix_bind+0x4c3/0xe00
net/unix/af_unix.c:1035
       [  836.614634] [<ffffffff834f047e>] SYSC_bind+0x20e/0x4a0
net/socket.c:1382
       [  836.621950] [<ffffffff834f3d84>] SyS_bind+0x24/0x30 net/socket.c:1368
       [  836.629015] [<ffffffff84370981>] entry_SYSCALL_64_fastpath+0x1f/0xc2

       [  836.642405] [<ffffffff815694cd>] check_prev_add
kernel/locking/lockdep.c:1828 [inline]
       [  836.642405] [<ffffffff815694cd>]
check_prevs_add+0xa8d/0x1c00 kernel/locking/lockdep.c:1938
       [  836.650348] [<ffffffff8156f989>] validate_chain
kernel/locking/lockdep.c:2265 [inline]
       [  836.650348] [<ffffffff8156f989>]
__lock_acquire+0x2149/0x3430 kernel/locking/lockdep.c:3338
       [  836.658315] [<ffffffff81571b11>] lock_acquire+0x2a1/0x630
kernel/locking/lockdep.c:3753
       [  836.665928] [<ffffffff84361ce1>] __mutex_lock_common
kernel/locking/mutex.c:521 [inline]
       [  836.665928] [<ffffffff84361ce1>]
mutex_lock_interruptible_nested+0x2e1/0x12a0
kernel/locking/mutex.c:650
       [  836.675287] [<ffffffff83962315>]
unix_autobind.isra.28+0xc5/0x880 net/unix/af_unix.c:852
       [  836.683571] [<ffffffff8396cdfc>]
unix_dgram_sendmsg+0x104c/0x1720 net/unix/af_unix.c:1667
       [  836.691870] [<ffffffff8396d5c3>]
unix_seqpacket_sendmsg+0xf3/0x160 net/unix/af_unix.c:2071
       [  836.700261] [<ffffffff834efaaa>] sock_sendmsg_nosec
net/socket.c:621 [inline]
       [  836.700261] [<ffffffff834efaaa>] sock_sendmsg+0xca/0x110
net/socket.c:631
       [  836.707758] [<ffffffff834f0137>] kernel_sendmsg+0x47/0x60
net/socket.c:639
       [  836.715327] [<ffffffff834faca6>]
sock_no_sendpage+0x216/0x300 net/core/sock.c:2321
       [  836.723278] [<ffffffff834ee5e0>] kernel_sendpage+0x90/0xe0
net/socket.c:3289
       [  836.730944] [<ffffffff834ee6bc>] sock_sendpage+0x8c/0xc0
net/socket.c:775
       [  836.738421] [<ffffffff81af011d>]
pipe_to_sendpage+0x29d/0x3e0 fs/splice.c:469
       [  836.746374] [<ffffffff81af4168>] splice_from_pipe_feed
fs/splice.c:520 [inline]
       [  836.746374] [<ffffffff81af4168>]
__splice_from_pipe+0x328/0x760 fs/splice.c:644
       [  836.754487] [<ffffffff81af77a7>]
splice_from_pipe+0x1d7/0x2f0 fs/splice.c:679
       [  836.762451] [<ffffffff81af7900>]
generic_splice_sendpage+0x40/0x50 fs/splice.c:850
       [  836.770826] [<ffffffff81af84e0>] do_splice_from
fs/splice.c:869 [inline]
       [  836.770826] [<ffffffff81af84e0>] do_splice fs/splice.c:1160 [inline]
       [  836.770826] [<ffffffff81af84e0>] SYSC_splice fs/splice.c:1410 [inline]
       [  836.770826] [<ffffffff81af84e0>] SyS_splice+0x7c0/0x1690
fs/splice.c:1393
       [  836.778307] [<ffffffff84370981>] entry_SYSCALL_64_fastpath+0x1f/0xc2

other info that might help us debug this:

Chain exists of:
 Possible unsafe locking scenario:

       CPU0                    CPU1
       ----                    ----
  lock(&pipe->mutex/1);
                               lock(sb_writers#5);
                               lock(&pipe->mutex/1);
  lock(&u->bindlock);

 *** DEADLOCK ***

1 lock held by syz-executor6/25491:
 #0:  (&pipe->mutex/1){+.+.+.}, at: [<ffffffff81a45ac6>]
pipe_lock_nested fs/pipe.c:66 [inline]
 #0:  (&pipe->mutex/1){+.+.+.}, at: [<ffffffff81a45ac6>]
pipe_lock+0x56/0x70 fs/pipe.c:74

stack backtrace:
CPU: 0 PID: 25491 Comm: syz-executor6 Not tainted 4.9.0 #1
Hardware name: Google Google Compute Engine/Google Compute Engine,
BIOS Google 01/01/2011
 ffff8801cacc6248 ffffffff8234654f ffffffff00000000 1ffff10039598bdc
 ffffed0039598bd4 0000000041b58ab3 ffffffff84b37a60 ffffffff82346261
 0000000000000000 0000000000000000 0000000000000000 0000000000000000
Call Trace:
 [<ffffffff8234654f>] __dump_stack lib/dump_stack.c:15 [inline]
 [<ffffffff8234654f>] dump_stack+0x2ee/0x3ef lib/dump_stack.c:51
 [<ffffffff81567147>] print_circular_bug+0x307/0x3b0
kernel/locking/lockdep.c:1202
 [<ffffffff815694cd>] check_prev_add kernel/locking/lockdep.c:1828 [inline]
 [<ffffffff815694cd>] check_prevs_add+0xa8d/0x1c00 kernel/locking/lockdep.c:1938
 [<ffffffff8156f989>] validate_chain kernel/locking/lockdep.c:2265 [inline]
 [<ffffffff8156f989>] __lock_acquire+0x2149/0x3430 kernel/locking/lockdep.c:3338
 [<ffffffff81571b11>] lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3753
 [<ffffffff84361ce1>] __mutex_lock_common kernel/locking/mutex.c:521 [inline]
 [<ffffffff84361ce1>] mutex_lock_interruptible_nested+0x2e1/0x12a0
kernel/locking/mutex.c:650
 [<ffffffff83962315>] unix_autobind.isra.28+0xc5/0x880 net/unix/af_unix.c:852
 [<ffffffff8396cdfc>] unix_dgram_sendmsg+0x104c/0x1720 net/unix/af_unix.c:1667
 [<ffffffff8396d5c3>] unix_seqpacket_sendmsg+0xf3/0x160 net/unix/af_unix.c:2071
 [<ffffffff834efaaa>] sock_sendmsg_nosec net/socket.c:621 [inline]
 [<ffffffff834efaaa>] sock_sendmsg+0xca/0x110 net/socket.c:631
 [<ffffffff834f0137>] kernel_sendmsg+0x47/0x60 net/socket.c:639
 [<ffffffff834faca6>] sock_no_sendpage+0x216/0x300 net/core/sock.c:2321
 [<ffffffff834ee5e0>] kernel_sendpage+0x90/0xe0 net/socket.c:3289
 [<ffffffff834ee6bc>] sock_sendpage+0x8c/0xc0 net/socket.c:775
 [<ffffffff81af011d>] pipe_to_sendpage+0x29d/0x3e0 fs/splice.c:469
 [<ffffffff81af4168>] splice_from_pipe_feed fs/splice.c:520 [inline]
 [<ffffffff81af4168>] __splice_from_pipe+0x328/0x760 fs/splice.c:644
 [<ffffffff81af77a7>] splice_from_pipe+0x1d7/0x2f0 fs/splice.c:679
 [<ffffffff81af7900>] generic_splice_sendpage+0x40/0x50 fs/splice.c:850
 [<ffffffff81af84e0>] do_splice_from fs/splice.c:869 [inline]
 [<ffffffff81af84e0>] do_splice fs/splice.c:1160 [inline]
 [<ffffffff81af84e0>] SYSC_splice fs/splice.c:1410 [inline]
 [<ffffffff81af84e0>] SyS_splice+0x7c0/0x1690 fs/splice.c:1393
 [<ffffffff84370981>] entry_SYSCALL_64_fastpath+0x1f/0xc2
QAT: Invalid ioctl
QAT: Invalid ioctl
QAT: Invalid ioctl
QAT: Invalid ioctl
FAULT_FLAG_ALLOW_RETRY missing 30
CPU: 1 PID: 25716 Comm: syz-executor3 Not tainted 4.9.0 #1
Hardware name: Google Google Compute Engine/Google Compute Engine,
BIOS Google 01/01/2011
 ffff8801b6a274a8 ffffffff8234654f ffffffff00000001 1ffff10036d44e28
 ffffed0036d44e20 0000000041b58ab3 ffffffff84b37a60 ffffffff82346261
 0000000000000000 ffff8801dc122980 ffff8801a36c2800 1ffff10036d44e2a
Call Trace:
 [<ffffffff8234654f>] __dump_stack lib/dump_stack.c:15 [inline]
 [<ffffffff8234654f>] dump_stack+0x2ee/0x3ef lib/dump_stack.c:51
 [<ffffffff81b6325d>] handle_userfault+0x115d/0x1fc0 fs/userfaultfd.c:381
 [<ffffffff8192f792>] do_anonymous_page mm/memory.c:2800 [inline]
 [<ffffffff8192f792>] handle_pte_fault mm/memory.c:3560 [inline]
 [<ffffffff8192f792>] __handle_mm_fault mm/memory.c:3652 [inline]
 [<ffffffff8192f792>] handle_mm_fault+0x24f2/0x2890 mm/memory.c:3689
 [<ffffffff81323df6>] __do_page_fault+0x4f6/0xb60 arch/x86/mm/fault.c:1397
 [<ffffffff813244b4>] do_page_fault+0x54/0x70 arch/x86/mm/fault.c:1460
 [<ffffffff84371d38>] page_fault+0x28/0x30 arch/x86/entry/entry_64.S:1012
 [<ffffffff81a65dfe>] getname_flags+0x10e/0x580 fs/namei.c:148
 [<ffffffff81a66f1d>] user_path_at_empty+0x2d/0x50 fs/namei.c:2556
 [<ffffffff81a385e1>] user_path_at include/linux/namei.h:55 [inline]
 [<ffffffff81a385e1>] vfs_fstatat+0xf1/0x1a0 fs/stat.c:106
 [<ffffffff81a3a12b>] vfs_lstat fs/stat.c:129 [inline]
 [<ffffffff81a3a12b>] SYSC_newlstat+0xab/0x140 fs/stat.c:283
 [<ffffffff81a3a51d>] SyS_newlstat+0x1d/0x30 fs/stat.c:277
 [<ffffffff84370981>] entry_SYSCALL_64_fastpath+0x1f/0xc2
FAULT_FLAG_ALLOW_RETRY missing 30
QAT: Invalid ioctl
QAT: Invalid ioctl
QAT: Invalid ioctl
CPU: 1 PID: 25716 Comm: syz-executor3 Not tainted 4.9.0 #1
Hardware name: Google Google Compute Engine/Google Compute Engine,
BIOS Google 01/01/2011
 ffff8801b6a27360 ffffffff8234654f ffffffff00000001 1ffff10036d44dff
 ffffed0036d44df7 0000000041b58ab3 ffffffff84b37a60 ffffffff82346261
 0000000000000082 ffff8801dc122980 ffff8801da622540 1ffff10036d44e01
Call Trace:
 [<ffffffff8234654f>] __dump_stack lib/dump_stack.c:15 [inline]
 [<ffffffff8234654f>] dump_stack+0x2ee/0x3ef lib/dump_stack.c:51
 [<ffffffff81b6325d>] handle_userfault+0x115d/0x1fc0 fs/userfaultfd.c:381
 [<ffffffff8192f792>] do_anonymous_page mm/memory.c:2800 [inline]
 [<ffffffff8192f792>] handle_pte_fault mm/memory.c:3560 [inline]
 [<ffffffff8192f792>] __handle_mm_fault mm/memory.c:3652 [inline]
 [<ffffffff8192f792>] handle_mm_fault+0x24f2/0x2890 mm/memory.c:3689
 [<ffffffff81323df6>] __do_page_fault+0x4f6/0xb60 arch/x86/mm/fault.c:1397
 [<ffffffff81324611>] trace_do_page_fault+0x141/0x6c0 arch/x86/mm/fault.c:1490
 [<ffffffff84371d08>] trace_page_fault+0x28/0x30 arch/x86/entry/entry_64.S:1012
 [<ffffffff81a65dfe>] getname_flags+0x10e/0x580 fs/namei.c:148
 [<ffffffff81a66f1d>] user_path_at_empty+0x2d/0x50 fs/namei.c:2556
 [<ffffffff81a385e1>] user_path_at include/linux/namei.h:55 [inline]
 [<ffffffff81a385e1>] vfs_fstatat+0xf1/0x1a0 fs/stat.c:106
 [<ffffffff81a3a12b>] vfs_lstat fs/stat.c:129 [inline]
 [<ffffffff81a3a12b>] SYSC_newlstat+0xab/0x140 fs/stat.c:283
 [<ffffffff81a3a51d>] SyS_newlstat+0x1d/0x30 fs/stat.c:277
 [<ffffffff84370981>] entry_SYSCALL_64_fastpath+0x1f/0xc2
