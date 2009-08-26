From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [kmemcheck] WARNING: kmemcheck: Caught 32-bit read from
	uninitialized memory, in sock_init_data()
Date: Wed, 26 Aug 2009 10:27:09 +0200
Message-ID: <20090826082709.GA11057@elte.hu>
References: <20090826055659.GA6066@elte.hu> <19f34abd0908260013n4e701796j90fb2b1ab74495de@mail.gmail.com> <4A94ED74.6000200@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vegard Nossum <vegard.nossum@gmail.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:52569 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752021AbZHZI1S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Aug 2009 04:27:18 -0400
Content-Disposition: inline
In-Reply-To: <4A94ED74.6000200@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Vegard Nossum a ??crit :
> > 2009/8/26 Ingo Molnar <mingo@elte.hu>:
> >> -tip testing found another kmemcheck warning:
> >>
> >> calling  netlink_proto_init+0x0/0x1b0 @ 1
> >> NET: Registered protocol family 16
> >> initcall netlink_proto_init+0x0/0x1b0 returned 0 after 39062 usecs
> >> calling  olpc_init+0x0/0x110 @ 1
> >> WARNING: kmemcheck: Caught 32-bit read from uninitialized memory (f5c38304)
> >> 0100000002000000000000000000000000000000ad4eaddeffffffffffffffff
> >>  i i i i i i u u i i i i i i i i i i i i i i i i i i i i i i i i
> >>         ^
> >>
> >> Pid: 1, comm: swapper Not tainted (2.6.31-rc7-tip-01170-gaaea9cf-dirty #24) P4DC6
> >> EIP: 0060:[<c15c8ab1>] EFLAGS: 00010286 CPU: 0
> >> EIP is at sock_init_data+0xe1/0x220
> >> EAX: 0001b000 EBX: f606196c ECX: 00000000 EDX: c1a148d2
> >> ESI: f6061800 EDI: f5c38300 EBP: f606ef0c ESP: c1ceb9ac
> >>  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> >> CR0: 8005003b CR2: f60a8108 CR3: 01a61000 CR4: 000006f0
> >> DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
> >> DR6: ffff4ff0 DR7: 00000400
> >>  [<c15fac15>] __netlink_create+0x35/0xa0
> >>  [<c15fd01a>] netlink_kernel_create+0x5a/0x180
> >>  [<c15df55e>] rtnetlink_net_init+0x1e/0x50
> >>  [<c15d130a>] register_pernet_operations+0x6a/0xf0
> >>  [<c15d14fe>] register_pernet_subsys+0x1e/0x30
> >>  [<c1b3d84c>] rtnetlink_init+0x4c/0x100
> >>  [<c1b3e105>] netlink_proto_init+0x105/0x1b0
> >>  [<c1001037>] do_one_initcall+0x27/0x170
> >>  [<c1afea97>] kernel_init+0x157/0x210
> >>  [<c10039a7>] kernel_thread_helper+0x7/0x10
> >>  [<ffffffff>] 0xffffffff
> >> initcall olpc_init+0x0/0x110 returned 0 after 0 usecs
> >> calling  bdi_class_init+0x0/0x40 @ 1
> >>
> >> config attached.
> > 
> > Thanks. AFAICT, it's this one:
> > 
> > 1816 void sock_init_data(struct socket *sock, struct sock *sk)
> > 1817 {
> > ...
> > 1835         sock_set_flag(sk, SOCK_ZAPPED);
> 
> Are you sure it is not the 16 bit padding in 'struct sock', after 'type' field ?
> 
> struct socket {
> 	socket_state        state;
> 	short           type;
> // here, a 16 bits hole
> 	unsigned long       flags;
> 
> the warning is strange since I suspect it happens here :
> 
>     if (sock) {
> <<>>	sk->sk_type =   sock->type; // here, kmemcheck warning while reading sock->type
> 	sk->sk_sleep    =   &sock->wait;
> 	sock->sk    =   sk;
> 
> and sock->type is a 16 bit field, correctly initialized (with value = 2)
> (Yes the hole, right after, is not initialized)
> 
> WARNING: kmemcheck: Caught 32-bit read from uninitialized memory (f5c38304)
> 0100000002000000000000000000000000000000ad4eaddeffffffffffffffff
>  i i i i i i u u i i i i i i i i i i i i i i i i i i i i i i i i

if so then we could perhaps annotate that by initializing it to zero 
on kmemcheck only. (or initialize it unconditionally if possible - 
that's generally the cleanest, 16-bit accesses arent cheap on all 
platforms)

	Ingo
