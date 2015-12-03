From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: use-after-free in sctp_do_sm
Date: Thu, 3 Dec 2015 15:43:56 -0200
Message-ID: <20151203174356.GE4164@mrl.redhat.com>
References: <CACT4Y+ZnWRZfQC25uW=GXHAJB=GX0L6tJQUy43P6WNR3=hwT8Q@mail.gmail.com>
 <CACT4Y+aAYy4-Ow+gt+1C46CK1+MbspBMM7qz9pVYsXvGXRJ1SQ@mail.gmail.com>
 <CACT4Y+YjAhRSYDFUZYydtWfRzi1yDEKtPrPsJqYN93Km91J=Cw@mail.gmail.com>
 <20151124204553.GB3364@hmsreliant.think-freely.org>
 <5655CFDC.4050206@gmail.com>
 <CACT4Y+aNgjykBXxEM0uv0MPOa=N6zkBuEp+vShR3KHqRE-tPAw@mail.gmail.com>
 <20151203165133.GD4164@mrl.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: syzkaller <syzkaller@googlegroups.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	linux-sctp@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Eric Dumazet <edumazet@google.com>,
	Maciej =?utf-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Dmitry Vyukov <dvyukov@google.com>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46016 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750894AbbLCRoE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 12:44:04 -0500
Content-Disposition: inline
In-Reply-To: <20151203165133.GD4164@mrl.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 03, 2015 at 02:51:33PM -0200, Marcelo Ricardo Leitner wrote:
> On Sat, Nov 28, 2015 at 04:50:56PM +0100, Dmitry Vyukov wrote:
> > This also seems to lead the the following WARNINGS:
> > 
> > ------------[ cut here ]------------
> > WARNING: CPU: 3 PID: 21734 at kernel/jump_label.c:77
> > __static_key_slow_dec+0xfb/0x120()
> > jump label: negative count!
> > Modules linked in:
> > CPU: 3 PID: 21734 Comm: executor Tainted: G    B   W       4.4.0-rc2+ #3
> > Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> >  00000000ffffffff ffff88006083f660 ffffffff82719fc6 ffff88006083f6d0
> >  ffff88003bbf8000 ffffffff85a612e0 ffff88006083f6a0 ffffffff81244ec9
> >  ffffffff8152c54b ffffed000c107ed6 ffffffff85a612e0 000000000000004d
> > Call Trace:
> >  [<     inline     >] __dump_stack lib/dump_stack.c:15
> >  [<ffffffff82719fc6>] dump_stack+0x68/0x92 lib/dump_stack.c:50
> >  [<ffffffff81244ec9>] warn_slowpath_common+0xd9/0x140 kernel/panic.c:460
> >  [<ffffffff81244fd9>] warn_slowpath_fmt+0xa9/0xd0 kernel/panic.c:472
> >  [<ffffffff8152c54b>] __static_key_slow_dec+0xfb/0x120 kernel/jump_label.c:76
> >  [<ffffffff8152c5c1>] static_key_slow_dec+0x51/0x90 kernel/jump_label.c:100
> >  [<ffffffff84962d9b>] net_disable_timestamp+0x3b/0x50 net/core/dev.c:1709
> >  [<ffffffff84914d43>] sock_disable_timestamp+0x93/0xb0 net/core/sock.c:444
> >  [<ffffffff8491f82c>] sk_destruct+0xec/0x440 net/core/sock.c:1457
> >  [<ffffffff8491fbd7>] __sk_free+0x57/0x200 net/core/sock.c:1476
> >  [<ffffffff8491fdb0>] sk_free+0x30/0x40 net/core/sock.c:1487
> >  [<     inline     >] sock_put include/net/sock.h:1623
> >  [<ffffffff854c8a18>] sctp_close+0x628/0x790 net/sctp/socket.c:1546
> >  [<ffffffff84d4b3ed>] inet_release+0xed/0x1c0 net/ipv4/af_inet.c:413
> >  [<ffffffff84e70240>] inet6_release+0x50/0x70 net/ipv6/af_inet6.c:406
> >  [<ffffffff84909bbd>] sock_release+0x8d/0x1d0 net/socket.c:571
> >  [<ffffffff84909d16>] sock_close+0x16/0x20 net/socket.c:1022
> >  [<ffffffff81663a00>] __fput+0x220/0x770 fs/file_table.c:208
> >  [<ffffffff81663fd5>] ____fput+0x15/0x20 fs/file_table.c:244
> >  [<ffffffff8129f673>] task_work_run+0x163/0x1f0 kernel/task_work.c:115
> >  [<     inline     >] exit_task_work include/linux/task_work.h:21
> >  [<ffffffff8124d9e9>] do_exit+0x809/0x2ae0 kernel/exit.c:750
> >  [<ffffffff8124fe38>] do_group_exit+0x108/0x320 kernel/exit.c:880
> >  [<ffffffff81271df7>] get_signal+0x597/0x1630 kernel/signal.c:2307
> >  [<ffffffff8114c77f>] do_signal+0x7f/0x18e0 arch/x86/kernel/signal.c:709
> >  [<ffffffff81003901>] exit_to_usermode_loop+0xf1/0x1a0
> > arch/x86/entry/common.c:247
> >  [<     inline     >] prepare_exit_to_usermode arch/x86/entry/common.c:282
> >  [<ffffffff8100616f>] syscall_return_slowpath+0x19f/0x210
> > arch/x86/entry/common.c:344
> >  [<ffffffff85955362>] int_ret_from_sys_call+0x25/0x9f
> > arch/x86/entry/entry_64.S:281
> > ---[ end trace 3e42717665ff2020 ]---
> > 
> > 
> > These WARNINGS always go with the original use-after-free reports. And
> > I was not able to reproduce this WARNING with commented out
> > sctp_association_destroy.
> > 
> > For the reference here is syzkaller program that triggers the WARNING.
> > 
> > r0 = socket(0xa, 0x1, 0x84)
> > mmap(&(0x7f0000000000)=nil, (0x10000), 0x3, 0x32, 0xffffffffffffffff, 0x0)
> > bind(r0, &(0x7f0000000000)="0a0033e049d02e70000000000000000000000000000000014c37ffc4",
> > 0x1c)
> > connect(r0, &(0x7f0000001000)="020033d97f000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
> > 0x80)
> > setsockopt$sock_int(r0, 0x1, 0x1d, &(0x7f0000001000+0x336)=0x1, 0x4)
> > listen(r0, 0xbb3)
> > r1 = accept(r0, &(0x7f0000003000+0xfd6)=nil, &(0x7f0000004000-0x2)=nil)
> 
> These two are unrelated, actually.
> 
> Do you know if this accept() returned something? Seems so.
> Seems to be originated on
> sctp_v6_create_accept_sk() -> sctp_copy_sock():
> 
> void sctp_copy_sock(struct sock *newsk, struct sock *sk,
>                     struct sctp_association *asoc)
> {
>         struct inet_sock *inet = inet_sk(sk);
>         struct inet_sock *newinet;
> 
>         newsk->sk_type = sk->sk_type;
>         newsk->sk_bound_dev_if = sk->sk_bound_dev_if;
>         newsk->sk_flags = sk->sk_flags;               <---
> 
> As it enabled SO_TIMESTAMP on listening socket, this flag will be copied and
> will trigger the second net_disable_timestamp() by the time the second
> socket is destroyed, because it never had its enable counterpart called.
> 
> This also happens via sctp peeloff operation.

Vlad, others,

It's been a long time but this was introduced by commit 914e1c8b6980
("sctp: Inherit all socket options from parent correctly."). This is not
very consistent with how other protocols work and it will be hard to
keep tracking a negative mask of flags that we can't copy.

I reviewed the list of options and I'm thinking that only
SO_BINDTODEVICE is worth copying, leaving the others for the application
to re-set, as it is for other protocols. So I'm thinking on simply:

-       newsk->sk_flags = sk->sk_flags;
+       newsk->sk_flags = sk->sk_flags & SO_BINDTODEVICE;

in the above.

What do you think?

  Marcelo
