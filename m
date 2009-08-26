From: Vegard Nossum <vegard.nossum@gmail.com>
Subject: Re: [kmemcheck] WARNING: kmemcheck: Caught 32-bit read from
	uninitialized memory, in sock_init_data()
Date: Wed, 26 Aug 2009 10:44:26 +0200
Message-ID: <19f34abd0908260144n6a5ebf7ft18f48e44f04082ad@mail.gmail.com>
References: <20090826055659.GA6066@elte.hu>
	 <19f34abd0908260013n4e701796j90fb2b1ab74495de@mail.gmail.com>
	 <4A94ED74.6000200@gmail.com> <20090826082709.GA11057@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755335AbZHZIo2@vger.kernel.org>
In-Reply-To: <20090826082709.GA11057@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2009/8/26 Ingo Molnar <mingo@elte.hu>:
>
> * Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
>> Vegard Nossum a ??crit :
>> > 2009/8/26 Ingo Molnar <mingo@elte.hu>:
>> >> -tip testing found another kmemcheck warning:
>> >>
>> >> calling =C2=A0netlink_proto_init+0x0/0x1b0 @ 1
>> >> NET: Registered protocol family 16
>> >> initcall netlink_proto_init+0x0/0x1b0 returned 0 after 39062 usec=
s
>> >> calling =C2=A0olpc_init+0x0/0x110 @ 1
>> >> WARNING: kmemcheck: Caught 32-bit read from uninitialized memory =
(f5c38304)
>> >> 0100000002000000000000000000000000000000ad4eaddeffffffffffffffff
>> >> =C2=A0i i i i i i u u i i i i i i i i i i i i i i i i i i i i i i=
 i i
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 ^
>> >>
>> >> Pid: 1, comm: swapper Not tainted (2.6.31-rc7-tip-01170-gaaea9cf-=
dirty #24) P4DC6
>> >> EIP: 0060:[<c15c8ab1>] EFLAGS: 00010286 CPU: 0
>> >> EIP is at sock_init_data+0xe1/0x220
>> >> EAX: 0001b000 EBX: f606196c ECX: 00000000 EDX: c1a148d2
>> >> ESI: f6061800 EDI: f5c38300 EBP: f606ef0c ESP: c1ceb9ac
>> >> =C2=A0DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
>> >> CR0: 8005003b CR2: f60a8108 CR3: 01a61000 CR4: 000006f0
>> >> DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
>> >> DR6: ffff4ff0 DR7: 00000400
>> >> =C2=A0[<c15fac15>] __netlink_create+0x35/0xa0
>> >> =C2=A0[<c15fd01a>] netlink_kernel_create+0x5a/0x180
>> >> =C2=A0[<c15df55e>] rtnetlink_net_init+0x1e/0x50
>> >> =C2=A0[<c15d130a>] register_pernet_operations+0x6a/0xf0
>> >> =C2=A0[<c15d14fe>] register_pernet_subsys+0x1e/0x30
>> >> =C2=A0[<c1b3d84c>] rtnetlink_init+0x4c/0x100
>> >> =C2=A0[<c1b3e105>] netlink_proto_init+0x105/0x1b0
>> >> =C2=A0[<c1001037>] do_one_initcall+0x27/0x170
>> >> =C2=A0[<c1afea97>] kernel_init+0x157/0x210
>> >> =C2=A0[<c10039a7>] kernel_thread_helper+0x7/0x10
>> >> =C2=A0[<ffffffff>] 0xffffffff
>> >> initcall olpc_init+0x0/0x110 returned 0 after 0 usecs
>> >> calling =C2=A0bdi_class_init+0x0/0x40 @ 1
>> >>
>> >> config attached.
>> >
>> > Thanks. AFAICT, it's this one:
>> >
>> > 1816 void sock_init_data(struct socket *sock, struct sock *sk)
>> > 1817 {
>> > ...
>> > 1835 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sock_set_flag(sk, SOCK_ZAPPED);
>>
>> Are you sure it is not the 16 bit padding in 'struct sock', after 't=
ype' field ?
>>
>> struct socket {
>> =C2=A0 =C2=A0 =C2=A0 socket_state =C2=A0 =C2=A0 =C2=A0 =C2=A0state;
>> =C2=A0 =C2=A0 =C2=A0 short =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 type;
>> // here, a 16 bits hole
>> =C2=A0 =C2=A0 =C2=A0 unsigned long =C2=A0 =C2=A0 =C2=A0 flags;
>>
>> the warning is strange since I suspect it happens here :
>>
>> =C2=A0 =C2=A0 if (sock) {
>> <<>> =C2=A0sk->sk_type =3D =C2=A0 sock->type; // here, kmemcheck war=
ning while reading sock->type
>> =C2=A0 =C2=A0 =C2=A0 sk->sk_sleep =C2=A0 =C2=A0=3D =C2=A0 &sock->wai=
t;
>> =C2=A0 =C2=A0 =C2=A0 sock->sk =C2=A0 =C2=A0=3D =C2=A0 sk;
>>
>> and sock->type is a 16 bit field, correctly initialized (with value =
=3D 2)
>> (Yes the hole, right after, is not initialized)
>>

Ah, right, makes sense. There are just two uninitialized bytes, too,
we can see it in the shadow dump:

>> WARNING: kmemcheck: Caught 32-bit read from uninitialized memory (f5=
c38304)
>> 0100000002000000000000000000000000000000ad4eaddeffffffffffffffff
>> =C2=A0i i i i i i u u i i i i i i i i i i i i i i i i i i i i i i i =
i
>
> if so then we could perhaps annotate that by initializing it to zero
> on kmemcheck only. (or initialize it unconditionally if possible -
> that's generally the cleanest, 16-bit accesses arent cheap on all
> platforms)
>

We should have eliminated these padding-related false-positives by
droppnig the -Os / CONFIG_CC_OPTIMIZE_FOR_SIZE, which should emit a
movzwl instruction or so instead of movl, but it's admittedly somewhat
dependent on gcc anyway. I'm wondering whether it would be worth it to
(try to) patch gcc not to emit these "bigger-than-necessary" loads
with a new -fsomething flag.


Vegard
