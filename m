From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net: BUG still has locks held in unix_stream_splice_read
Date: Sun, 9 Oct 2016 12:06:14 +0200
Message-ID: <CACT4Y+a6yDm28VYtNPSktYKs_T2UzLGb8jadpFpsdKfNzb7-tA@mail.gmail.com>
References: <CACT4Y+aPybMnXjiH+DdDWDAfz+L6PF-H-J3YT2+hjcDp3aw9SQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>
To: Al Viro <viro@zeniv.linux.org.uk>,
        David Miller <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Eric Dumazet <edumazet@google.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+aPybMnXjiH+DdDWDAfz+L6PF-H-J3YT2+hjcDp3aw9SQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

While running syzkaller fuzzer on commit
b66484cd74706fa8681d051840fe4b18a3da40ff (Oct 7), I am getting:

[ BUG: syz-executor/15138 still has locks held! ]
4.8.0+ #29 Not tainted
-------------------------------------
1 lock held by syz-executor/15138:
 #0:  (&pipe->mutex/1){+.+.+.}, at: [<     inline     >]
pipe_lock_nested fs/pipe.c:66
 #0:  (&pipe->mutex/1){+.+.+.}, at: [<ffffffff81844c8b>]
pipe_lock+0x5b/0x70 fs/pipe.c:74

stack backtrace:
CPU: 1 PID: 15138 Comm: syz-executor Not tainted 4.8.0+ #29
Hardware name: Google Google Compute Engine/Google Compute Engine,
BIOS Google 01/01/2011
 ffff880044d4fa38 ffffffff82d383c9 ffffffff00000000 fffffbfff1097248
 ffff88005a44a3c0 ffff88005a44a3c0 dffffc0000000000 ffff88005a44a3c0
 ffff8800541fb9b8 ffff880044d4fa58 ffffffff81463cd5 0000000000000000
Call Trace:
 [<     inline     >] __dump_stack lib/dump_stack.c:15
 [<ffffffff82d383c9>] dump_stack+0x12e/0x185 lib/dump_stack.c:51
 [<     inline     >] print_held_locks_bug kernel/locking/lockdep.c:4296
 [<ffffffff81463cd5>] debug_check_no_locks_held+0x125/0x140
kernel/locking/lockdep.c:4302
 [<     inline     >] try_to_freeze include/linux/freezer.h:65
 [<     inline     >] freezer_count include/linux/freezer.h:127
 [<     inline     >] freezable_schedule_timeout include/linux/freezer.h:192
 [<     inline     >] unix_stream_data_wait net/unix/af_unix.c:2223
 [<ffffffff860bae67>] unix_stream_read_generic+0x1317/0x1b70
net/unix/af_unix.c:2332
 [<ffffffff860bb81b>] unix_stream_splice_read+0x15b/0x1d0
net/unix/af_unix.c:2506
 [<ffffffff85afc56e>] sock_splice_read+0xbe/0x100 net/socket.c:775
 [<ffffffff818d121f>] do_splice_to+0x10f/0x170 fs/splice.c:908
 [<     inline     >] do_splice fs/splice.c:1196
 [<     inline     >] SYSC_splice fs/splice.c:1420
 [<ffffffff818d6aec>] SyS_splice+0x114c/0x15b0 fs/splice.c:1403
 [<ffffffff86da6d05>] entry_SYSCALL_64_fastpath+0x23/0xc6


I suspect this is:

commit 25869262ef7af24ccde988867ac3eb1c3d4b88d4
Author: Al Viro <viro@zeniv.linux.org.uk>
Date:   Sat Sep 17 21:02:10 2016 -0400
    skb_splice_bits(): get rid of callback
    since pipe_lock is the outermost now, we don't need to drop/regain
    socket locks around the call of splice_to_pipe() from skb_splice_bits(),
    which kills the need to have a socket-specific callback; we can just
    call splice_to_pipe() and be done with that.
