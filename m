From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: net/sctp: recursive locking in sctp_do_peeloff
Date: Fri, 10 Mar 2017 16:46:26 -0300
Message-ID: <CAFSqH7xrmH2Bgq3Xckgb3mkj7j1qkApemEYOq3jbQEtj+TTEpQ@mail.gmail.com>
References: <CACT4Y+ZHGC6VNJUANgSdZnCfLQrRKtsQ-Dbn6goHScj=pq7xog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Vladislav Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        David Miller <davem@davemloft.net>, linux-sctp@vger.kernel.org,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f175.google.com ([209.85.220.175]:36036 "EHLO
        mail-qk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933101AbdCJTqa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 14:46:30 -0500
In-Reply-To: <CACT4Y+ZHGC6VNJUANgSdZnCfLQrRKtsQ-Dbn6goHScj=pq7xog@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 10, 2017 at 4:11 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> Hello,
>
> I've got the following recursive locking report while running
> syzkaller fuzzer on net-next/9c28286b1b4b9bce6e35dd4c8a1265f03802a89a:
>
> [ INFO: possible recursive locking detected ]
> 4.10.0+ #14 Not tainted
> ---------------------------------------------
> syz-executor3/5560 is trying to acquire lock:
>  (sk_lock-AF_INET6){+.+.+.}, at: [<ffffffff8401ebcd>] lock_sock
> include/net/sock.h:1460 [inline]
>  (sk_lock-AF_INET6){+.+.+.}, at: [<ffffffff8401ebcd>]
> sctp_close+0xcd/0x9d0 net/sctp/socket.c:1497
>
> but task is already holding lock:
>  (sk_lock-AF_INET6){+.+.+.}, at: [<ffffffff84038110>] lock_sock
> include/net/sock.h:1460 [inline]
>  (sk_lock-AF_INET6){+.+.+.}, at: [<ffffffff84038110>]
> sctp_getsockopt+0x450/0x67e0 net/sctp/socket.c:6611
>
> other info that might help us debug this:
>  Possible unsafe locking scenario:
>
>        CPU0
>        ----
>   lock(sk_lock-AF_INET6);
>   lock(sk_lock-AF_INET6);
>
>  *** DEADLOCK ***
>
>  May be due to missing lock nesting notation

Pretty much the case, I suppose. The lock held by sctp_getsockopt() is
on one socket, while the other lock that sctp_close() is getting later
is on the newly created (which failed) socket during peeloff
operation.

I don=C2=B4t know how to fix this nesting notation in this situation, but
any idea why sock_create failed? Seems security_socket_post_create()
failed in there, so sock_release was called with sock->ops still
valid.

>
> 1 lock held by syz-executor3/5560:
>  #0:  (sk_lock-AF_INET6){+.+.+.}, at: [<ffffffff84038110>] lock_sock
> include/net/sock.h:1460 [inline]
>  #0:  (sk_lock-AF_INET6){+.+.+.}, at: [<ffffffff84038110>]
> sctp_getsockopt+0x450/0x67e0 net/sctp/socket.c:6611
>
> stack backtrace:
> CPU: 0 PID: 5560 Comm: syz-executor3 Not tainted 4.10.0+ #14
> Hardware name: Google Google Compute Engine/Google Compute Engine,
> BIOS Google 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:16 [inline]
>  dump_stack+0x2ee/0x3ef lib/dump_stack.c:52
>  print_deadlock_bug kernel/locking/lockdep.c:1729 [inline]
>  check_deadlock kernel/locking/lockdep.c:1773 [inline]
>  validate_chain kernel/locking/lockdep.c:2251 [inline]
>  __lock_acquire+0xef2/0x3430 kernel/locking/lockdep.c:3340
>  lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3755
>  lock_sock_nested+0xcb/0x120 net/core/sock.c:2536
>  lock_sock include/net/sock.h:1460 [inline]
>  sctp_close+0xcd/0x9d0 net/sctp/socket.c:1497
>  inet_release+0xed/0x1c0 net/ipv4/af_inet.c:425
>  inet6_release+0x50/0x70 net/ipv6/af_inet6.c:432
>  sock_release+0x8d/0x1e0 net/socket.c:597
>  __sock_create+0x38b/0x870 net/socket.c:1226
>  sock_create+0x7f/0xa0 net/socket.c:1237
>  sctp_do_peeloff+0x1a2/0x440 net/sctp/socket.c:4879
>  sctp_getsockopt_peeloff net/sctp/socket.c:4914 [inline]
>  sctp_getsockopt+0x111a/0x67e0 net/sctp/socket.c:6628
>  sock_common_getsockopt+0x95/0xd0 net/core/sock.c:2690
>  SYSC_getsockopt net/socket.c:1817 [inline]
>  SyS_getsockopt+0x240/0x380 net/socket.c:1799
>  entry_SYSCALL_64_fastpath+0x1f/0xc2
> RIP: 0033:0x44fb79
> RSP: 002b:00007f35f232bb58 EFLAGS: 00000212 ORIG_RAX: 0000000000000037
> RAX: ffffffffffffffda RBX: 0000000000000084 RCX: 000000000044fb79
> RDX: 0000000000000066 RSI: 0000000000000084 RDI: 0000000000000006
> RBP: 0000000000000006 R08: 0000000020119000 R09: 0000000000000000
> R10: 000000002058dff8 R11: 0000000000000212 R12: 0000000000708000
> R13: 0000000000000103 R14: 0000000000000001 R15: 0000000000000000
