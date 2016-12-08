From: Dmitry Vyukov <dvyukov@google.com>
Subject: fs, net: deadlock between bind/splice on af_unix
Date: Thu, 8 Dec 2016 15:47:11 +0100
Message-ID: <CACT4Y+Z981V+QLHr=PnQy1Dvxrpp-nCDhQtf+5HuNAusH+Vqxw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>
To: Al Viro <viro@zeniv.linux.org.uk>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Rainer Weikusat <rweikusat@mobileactivedefense.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I am getting the following deadlock reports while running syzkaller
fuzzer on 318c8932ddec5c1c26a4af0f3c053784841c598e (Dec 7).


[ INFO: possible circular locking dependency detected ]
4.9.0-rc8+ #77 Not tainted
-------------------------------------------------------
syz-executor0/3155 is trying to acquire lock:
 (&u->bindlock){+.+.+.}, at: [<ffffffff871bca1a>]
unix_autobind.isra.26+0xca/0x8a0 net/unix/af_unix.c:852
but task is already holding lock:
 (&pipe->mutex/1){+.+.+.}, at: [<     inline     >] pipe_lock_nested
fs/pipe.c:66
 (&pipe->mutex/1){+.+.+.}, at: [<ffffffff81a8ea4b>]
pipe_lock+0x5b/0x70 fs/pipe.c:74
which lock already depends on the new lock.

the existing dependency chain (in reverse order) is:

       [  202.103497] [<     inline     >] validate_chain
kernel/locking/lockdep.c:2265
       [  202.103497] [<ffffffff81569576>]
__lock_acquire+0x2156/0x3380 kernel/locking/lockdep.c:3338
       [  202.103497] [<ffffffff8156b672>] lock_acquire+0x2a2/0x790
kernel/locking/lockdep.c:3749
       [  202.103497] [<     inline     >] __mutex_lock_common
kernel/locking/mutex.c:521
       [  202.103497] [<ffffffff88195bcf>]
mutex_lock_nested+0x23f/0xf20 kernel/locking/mutex.c:621
       [  202.103497] [<     inline     >] pipe_lock_nested fs/pipe.c:66
       [  202.103497] [<ffffffff81a8ea4b>] pipe_lock+0x5b/0x70 fs/pipe.c:74
       [  202.103497] [<ffffffff81b451f7>]
iter_file_splice_write+0x267/0xfa0 fs/splice.c:717
       [  202.103497] [<     inline     >] do_splice_from fs/splice.c:869
       [  202.103497] [<     inline     >] do_splice fs/splice.c:1160
       [  202.103497] [<     inline     >] SYSC_splice fs/splice.c:1410
       [  202.103497] [<ffffffff81b473c7>] SyS_splice+0x7d7/0x16a0
fs/splice.c:1393
       [  202.103497] [<ffffffff881a5f85>] entry_SYSCALL_64_fastpath+0x23/0xc6

       [  202.103497] [<     inline     >] validate_chain
kernel/locking/lockdep.c:2265
       [  202.103497] [<ffffffff81569576>]
__lock_acquire+0x2156/0x3380 kernel/locking/lockdep.c:3338
       [  202.103497] [<ffffffff8156b672>] lock_acquire+0x2a2/0x790
kernel/locking/lockdep.c:3749
       [  202.103497] [<     inline     >]
percpu_down_read_preempt_disable include/linux/percpu-rwsem.h:35
       [  202.103497] [<     inline     >] percpu_down_read
include/linux/percpu-rwsem.h:58
       [  202.103497] [<ffffffff81a7bb33>]
__sb_start_write+0x193/0x2a0 fs/super.c:1252
       [  202.103497] [<     inline     >] sb_start_write
include/linux/fs.h:1549
       [  202.103497] [<ffffffff81af9954>] mnt_want_write+0x44/0xb0
fs/namespace.c:389
       [  202.103497] [<ffffffff81ab09f6>] filename_create+0x156/0x620
fs/namei.c:3598
       [  202.103497] [<ffffffff81ab0ef8>] kern_path_create+0x38/0x50
fs/namei.c:3644
       [  202.103497] [<     inline     >] unix_mknod net/unix/af_unix.c:967
       [  202.103497] [<ffffffff871c0e11>] unix_bind+0x4d1/0xe60
net/unix/af_unix.c:1035
       [  202.103497] [<ffffffff86a76b7e>] SYSC_bind+0x20e/0x4c0
net/socket.c:1382
       [  202.103497] [<ffffffff86a7a509>] SyS_bind+0x29/0x30 net/socket.c:1368
       [  202.103497] [<ffffffff881a5f85>] entry_SYSCALL_64_fastpath+0x23/0xc6

       [  202.103497] [<     inline     >] check_prev_add
kernel/locking/lockdep.c:1828
       [  202.103497] [<ffffffff8156309b>]
check_prevs_add+0xaab/0x1c20 kernel/locking/lockdep.c:1938
       [  202.103497] [<     inline     >] validate_chain
kernel/locking/lockdep.c:2265
       [  202.103497] [<ffffffff81569576>]
__lock_acquire+0x2156/0x3380 kernel/locking/lockdep.c:3338
       [  202.103497] [<ffffffff8156b672>] lock_acquire+0x2a2/0x790
kernel/locking/lockdep.c:3749
       [  202.103497] [<     inline     >] __mutex_lock_common
kernel/locking/mutex.c:521
       [  202.103497] [<ffffffff88196b82>]
mutex_lock_interruptible_nested+0x2d2/0x11d0
kernel/locking/mutex.c:650
       [  202.103497] [<ffffffff871bca1a>]
unix_autobind.isra.26+0xca/0x8a0 net/unix/af_unix.c:852
       [  202.103497] [<ffffffff871c76dd>]
unix_dgram_sendmsg+0x105d/0x1730 net/unix/af_unix.c:1667
       [  202.103497] [<ffffffff871c7ea8>]
unix_seqpacket_sendmsg+0xf8/0x170 net/unix/af_unix.c:2071
       [  202.103497] [<     inline     >] sock_sendmsg_nosec net/socket.c:621
       [  202.103497] [<ffffffff86a7618f>] sock_sendmsg+0xcf/0x110
net/socket.c:631
       [  202.103497] [<ffffffff86a7683c>] kernel_sendmsg+0x4c/0x60
net/socket.c:639
       [  202.103497] [<ffffffff86a8101d>]
sock_no_sendpage+0x20d/0x310 net/core/sock.c:2321
       [  202.103497] [<ffffffff86a74c95>] kernel_sendpage+0x95/0xf0
net/socket.c:3289
       [  202.103497] [<ffffffff86a74d92>] sock_sendpage+0xa2/0xd0
net/socket.c:775
       [  202.103497] [<ffffffff81b3ee1e>]
pipe_to_sendpage+0x2ae/0x390 fs/splice.c:469
       [  202.103497] [<     inline     >] splice_from_pipe_feed fs/splice.c:520
       [  202.103497] [<ffffffff81b42f3f>]
__splice_from_pipe+0x31f/0x750 fs/splice.c:644
       [  202.103497] [<ffffffff81b4665c>]
splice_from_pipe+0x1dc/0x300 fs/splice.c:679
       [  202.103497] [<ffffffff81b467c5>]
generic_splice_sendpage+0x45/0x60 fs/splice.c:850
       [  202.103497] [<     inline     >] do_splice_from fs/splice.c:869
       [  202.103497] [<     inline     >] do_splice fs/splice.c:1160
       [  202.103497] [<     inline     >] SYSC_splice fs/splice.c:1410
       [  202.103497] [<ffffffff81b473c7>] SyS_splice+0x7d7/0x16a0
fs/splice.c:1393
       [  202.103497] [<ffffffff881a5f85>] entry_SYSCALL_64_fastpath+0x23/0xc6

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

1 lock held by syz-executor0/3155:
 #0:  (&pipe->mutex/1){+.+.+.}, at: [<     inline     >]
pipe_lock_nested fs/pipe.c:66
 #0:  (&pipe->mutex/1){+.+.+.}, at: [<ffffffff81a8ea4b>]
pipe_lock+0x5b/0x70 fs/pipe.c:74

stack backtrace:
CPU: 3 PID: 3155 Comm: syz-executor0 Not tainted 4.9.0-rc8+ #77
Hardware name: Google Google/Google, BIOS Google 01/01/2011
 ffff88004b1fe288 ffffffff834c44f9 ffffffff00000003 1ffff1000963fbe4
 ffffed000963fbdc 0000000041b58ab3 ffffffff895816f0 ffffffff834c420b
 0000000000000000 0000000000000000 0000000000000000 0000000000000000
Call Trace:
 [<     inline     >] __dump_stack lib/dump_stack.c:15
 [<ffffffff834c44f9>] dump_stack+0x2ee/0x3f5 lib/dump_stack.c:51
 [<ffffffff81560cb0>] print_circular_bug+0x310/0x3c0
kernel/locking/lockdep.c:1202
 [<     inline     >] check_prev_add kernel/locking/lockdep.c:1828
 [<ffffffff8156309b>] check_prevs_add+0xaab/0x1c20 kernel/locking/lockdep.c:1938
 [<     inline     >] validate_chain kernel/locking/lockdep.c:2265
 [<ffffffff81569576>] __lock_acquire+0x2156/0x3380 kernel/locking/lockdep.c:3338
 [<ffffffff8156b672>] lock_acquire+0x2a2/0x790 kernel/locking/lockdep.c:3749
 [<     inline     >] __mutex_lock_common kernel/locking/mutex.c:521
 [<ffffffff88196b82>] mutex_lock_interruptible_nested+0x2d2/0x11d0
kernel/locking/mutex.c:650
 [<ffffffff871bca1a>] unix_autobind.isra.26+0xca/0x8a0 net/unix/af_unix.c:852
 [<ffffffff871c76dd>] unix_dgram_sendmsg+0x105d/0x1730 net/unix/af_unix.c:1667
 [<ffffffff871c7ea8>] unix_seqpacket_sendmsg+0xf8/0x170 net/unix/af_unix.c:2071
 [<     inline     >] sock_sendmsg_nosec net/socket.c:621
 [<ffffffff86a7618f>] sock_sendmsg+0xcf/0x110 net/socket.c:631
 [<ffffffff86a7683c>] kernel_sendmsg+0x4c/0x60 net/socket.c:639
 [<ffffffff86a8101d>] sock_no_sendpage+0x20d/0x310 net/core/sock.c:2321
 [<ffffffff86a74c95>] kernel_sendpage+0x95/0xf0 net/socket.c:3289
 [<ffffffff86a74d92>] sock_sendpage+0xa2/0xd0 net/socket.c:775
 [<ffffffff81b3ee1e>] pipe_to_sendpage+0x2ae/0x390 fs/splice.c:469
 [<     inline     >] splice_from_pipe_feed fs/splice.c:520
 [<ffffffff81b42f3f>] __splice_from_pipe+0x31f/0x750 fs/splice.c:644
 [<ffffffff81b4665c>] splice_from_pipe+0x1dc/0x300 fs/splice.c:679
 [<ffffffff81b467c5>] generic_splice_sendpage+0x45/0x60 fs/splice.c:850
 [<     inline     >] do_splice_from fs/splice.c:869
 [<     inline     >] do_splice fs/splice.c:1160
 [<     inline     >] SYSC_splice fs/splice.c:1410
 [<ffffffff81b473c7>] SyS_splice+0x7d7/0x16a0 fs/splice.c:1393
 [<ffffffff881a5f85>] entry_SYSCALL_64_fastpath+0x23/0xc6
