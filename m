From: Neal Cardwell <ncardwell@google.com>
Subject: Re: inconsistent lock/deadlock crash, vanilla 3.3.4, 32bit, tcp
Date: Sun, 29 Apr 2012 17:32:48 -0400
Message-ID: <CADVnQymbDGwY2NJns729BcaGixhxDgq4rLBAUSx7nyaYSnUt3w@mail.gmail.com>
References: <13fc59c8e3be34ddb3c7bb5c17b1bdf8@visp.net.lb>
	<1335688036.2900.80.camel@edumazet-glaptop>
	<4ba0969cecac9a8e677d1b1eed1a5742@visp.net.lb>
	<1335691316.2900.100.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Denys Fedoryshchenko <denys@visp.net.lb>, netdev@vger.kernel.org,
	davem@davemloft.net, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, linux-kernel@vger.kernel.org,
	Glauber Costa <glommer@parallels.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:64005 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753873Ab2D2Vct convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Apr 2012 17:32:49 -0400
Received: by iadi9 with SMTP id i9so3336480iad.19
        for <netdev@vger.kernel.org>; Sun, 29 Apr 2012 14:32:49 -0700 (PDT)
In-Reply-To: <1335691316.2900.100.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 29, 2012 at 5:21 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
>
> [PATCH] net: fix sk_sockets_allocated_read_positive
>
> Denys Fedoryshchenko reported frequent crashes on a proxy server and =
kindly
> provided a lockdep report that explains it all :
>
>
> =A0[ =A0762.903868]
> =A0[ =A0762.903880] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> =A0[ =A0762.903890] [ INFO: inconsistent lock state ]
> =A0[ =A0762.903903] 3.3.4-build-0061 #8 Not tainted
> =A0[ =A0762.904133] ---------------------------------
> =A0[ =A0762.904344] inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usa=
ge.
> =A0[ =A0762.904542] squid/1603 [HC0[0]:SC0[0]:HE1:SE1] takes:
> =A0[ =A0762.904542] =A0(key#3){+.?...}, at: [<c0232cc4>]
> __percpu_counter_sum+0xd/0x58
> =A0[ =A0762.904542] {IN-SOFTIRQ-W} state was registered at:
> =A0[ =A0762.904542] =A0 [<c0158b84>] __lock_acquire+0x284/0xc26
> =A0[ =A0762.904542] =A0 [<c01598e8>] lock_acquire+0x71/0x85
> =A0[ =A0762.904542] =A0 [<c0349765>] _raw_spin_lock+0x33/0x40
> =A0[ =A0762.904542] =A0 [<c0232c93>] __percpu_counter_add+0x58/0x7c
> =A0[ =A0762.904542] =A0 [<c02cfde1>] sk_clone_lock+0x1e5/0x200
> =A0[ =A0762.904542] =A0 [<c0303ee4>] inet_csk_clone_lock+0xe/0x78
> =A0[ =A0762.904542] =A0 [<c0315778>] tcp_create_openreq_child+0x1b/0x=
404
> =A0[ =A0762.904542] =A0 [<c031339c>] tcp_v4_syn_recv_sock+0x32/0x1c1
> =A0[ =A0762.904542] =A0 [<c031615a>] tcp_check_req+0x1fd/0x2d7
> =A0[ =A0762.904542] =A0 [<c0313f77>] tcp_v4_do_rcv+0xab/0x194
> =A0[ =A0762.904542] =A0 [<c03153bb>] tcp_v4_rcv+0x3b3/0x5cc
> =A0[ =A0762.904542] =A0 [<c02fc0c4>] ip_local_deliver_finish+0x13a/0x=
1e9
> =A0[ =A0762.904542] =A0 [<c02fc539>] NF_HOOK.clone.11+0x46/0x4d
> =A0[ =A0762.904542] =A0 [<c02fc652>] ip_local_deliver+0x41/0x45
> =A0[ =A0762.904542] =A0 [<c02fc4d1>] ip_rcv_finish+0x31a/0x33c
> =A0[ =A0762.904542] =A0 [<c02fc539>] NF_HOOK.clone.11+0x46/0x4d
> =A0[ =A0762.904542] =A0 [<c02fc857>] ip_rcv+0x201/0x23e
> =A0[ =A0762.904542] =A0 [<c02daa3a>] __netif_receive_skb+0x319/0x368
> =A0[ =A0762.904542] =A0 [<c02dac07>] netif_receive_skb+0x4e/0x7d
> =A0[ =A0762.904542] =A0 [<c02dacf6>] napi_skb_finish+0x1e/0x34
> =A0[ =A0762.904542] =A0 [<c02db122>] napi_gro_receive+0x20/0x24
> =A0[ =A0762.904542] =A0 [<f85d1743>] e1000_receive_skb+0x3f/0x45 [e10=
00e]
> =A0[ =A0762.904542] =A0 [<f85d3464>] e1000_clean_rx_irq+0x1f9/0x284 [=
e1000e]
> =A0[ =A0762.904542] =A0 [<f85d3926>] e1000_clean+0x62/0x1f4 [e1000e]
> =A0[ =A0762.904542] =A0 [<c02db228>] net_rx_action+0x90/0x160
> =A0[ =A0762.904542] =A0 [<c012a445>] __do_softirq+0x7b/0x118
> =A0[ =A0762.904542] irq event stamp: 156915469
> =A0[ =A0762.904542] hardirqs last =A0enabled at (156915469): [<c019b4=
f4>]
> __slab_alloc.clone.58.clone.63+0xc4/0x2de
> =A0[ =A0762.904542] hardirqs last disabled at (156915468): [<c019b452=
>]
> __slab_alloc.clone.58.clone.63+0x22/0x2de
> =A0[ =A0762.904542] softirqs last =A0enabled at (156915466): [<c02ce6=
77>]
> lock_sock_nested+0x64/0x6c
> =A0[ =A0762.904542] softirqs last disabled at (156915464): [<c0349914=
>]
> _raw_spin_lock_bh+0xe/0x45
> =A0[ =A0762.904542]
> =A0[ =A0762.904542] other info that might help us debug this:
> =A0[ =A0762.904542] =A0Possible unsafe locking scenario:
> =A0[ =A0762.904542]
> =A0[ =A0762.904542] =A0 =A0 =A0 =A0CPU0
> =A0[ =A0762.904542] =A0 =A0 =A0 =A0----
> =A0[ =A0762.904542] =A0 lock(key#3);
> =A0[ =A0762.904542] =A0 <Interrupt>
> =A0[ =A0762.904542] =A0 =A0 lock(key#3);
> =A0[ =A0762.904542]
> =A0[ =A0762.904542] =A0*** DEADLOCK ***
> =A0[ =A0762.904542]
> =A0[ =A0762.904542] 1 lock held by squid/1603:
> =A0[ =A0762.904542] =A0#0: =A0(sk_lock-AF_INET){+.+.+.}, at: [<c03055=
c0>]
> lock_sock+0xa/0xc
> =A0[ =A0762.904542]
> =A0[ =A0762.904542] stack backtrace:
> =A0[ =A0762.904542] Pid: 1603, comm: squid Not tainted 3.3.4-build-00=
61 #8
> =A0[ =A0762.904542] Call Trace:
> =A0[ =A0762.904542] =A0[<c0347b73>] ? printk+0x18/0x1d
> =A0[ =A0762.904542] =A0[<c015873a>] valid_state+0x1f6/0x201
> =A0[ =A0762.904542] =A0[<c0158816>] mark_lock+0xd1/0x1bb
> =A0[ =A0762.904542] =A0[<c015876b>] ? mark_lock+0x26/0x1bb
> =A0[ =A0762.904542] =A0[<c015805d>] ? check_usage_forwards+0x77/0x77
> =A0[ =A0762.904542] =A0[<c0158bf8>] __lock_acquire+0x2f8/0xc26
> =A0[ =A0762.904542] =A0[<c0159b8e>] ? mark_held_locks+0x5d/0x7b
> =A0[ =A0762.904542] =A0[<c0159cf6>] ? trace_hardirqs_on+0xb/0xd
> =A0[ =A0762.904542] =A0[<c0158dd4>] ? __lock_acquire+0x4d4/0xc26
> =A0[ =A0762.904542] =A0[<c01598e8>] lock_acquire+0x71/0x85
> =A0[ =A0762.904542] =A0[<c0232cc4>] ? __percpu_counter_sum+0xd/0x58
> =A0[ =A0762.904542] =A0[<c0349765>] _raw_spin_lock+0x33/0x40
> =A0[ =A0762.904542] =A0[<c0232cc4>] ? __percpu_counter_sum+0xd/0x58
> =A0[ =A0762.904542] =A0[<c0232cc4>] __percpu_counter_sum+0xd/0x58
> =A0[ =A0762.904542] =A0[<c02cebc4>] __sk_mem_schedule+0xdd/0x1c7
> =A0[ =A0762.904542] =A0[<c02d178d>] ? __alloc_skb+0x76/0x100
> =A0[ =A0762.904542] =A0[<c0305e8e>] sk_wmem_schedule+0x21/0x2d
> =A0[ =A0762.904542] =A0[<c0306370>] sk_stream_alloc_skb+0x42/0xaa
> =A0[ =A0762.904542] =A0[<c0306567>] tcp_sendmsg+0x18f/0x68b
> =A0[ =A0762.904542] =A0[<c031f3dc>] ? ip_fast_csum+0x30/0x30
> =A0[ =A0762.904542] =A0[<c0320193>] inet_sendmsg+0x53/0x5a
> =A0[ =A0762.904542] =A0[<c02cb633>] sock_aio_write+0xd2/0xda
> =A0[ =A0762.904542] =A0[<c015876b>] ? mark_lock+0x26/0x1bb
> =A0[ =A0762.904542] =A0[<c01a1017>] do_sync_write+0x9f/0xd9
> =A0[ =A0762.904542] =A0[<c01a2111>] ? file_free_rcu+0x2f/0x2f
> =A0[ =A0762.904542] =A0[<c01a17a1>] vfs_write+0x8f/0xab
> =A0[ =A0762.904542] =A0[<c01a284d>] ? fget_light+0x75/0x7c
> =A0[ =A0762.904542] =A0[<c01a1900>] sys_write+0x3d/0x5e
> =A0[ =A0762.904542] =A0[<c0349ec9>] syscall_call+0x7/0xb
> =A0[ =A0762.904542] =A0[<c0340000>] ? rp_sidt+0x41/0x83
>
>
> Bug is that sk_sockets_allocated_read_positive() calls
> percpu_counter_sum_positive() without BH being disabled.
>
> This bug was added in commit 180d8cd942ce33
> (foundations of per-cgroup memory pressure controlling.), since previ=
ous
> code was using percpu_counter_read_positive() which is IRQ safe.
>
> In __sk_mem_schedule() we dont need the precise count of allocated
> sockets and can revert to previous behavior.
>
> Reported-by: Denys Fedoryshchenko <denys@visp.net.lb>
> Sined-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Glauber Costa <glommer@parallels.com>
> ---

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
