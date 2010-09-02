From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] pkt_sched: Fix lockdep warning on est_tree_lock in
 gen_estimator
Date: Thu, 02 Sep 2010 22:53:33 +0200
Message-ID: <1283460813.3699.243.camel@edumazet-laptop>
References: <20100902201257.GA3089@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:48073 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757095Ab0IBUxk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 16:53:40 -0400
Received: by wyb35 with SMTP id 35so148063wyb.19
        for <netdev@vger.kernel.org>; Thu, 02 Sep 2010 13:53:39 -0700 (PDT)
In-Reply-To: <20100902201257.GA3089@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 02 septembre 2010 =C3=A0 22:12 +0200, Jarek Poplawski a =C3=A9=
crit :
> Hi,
>=20
> Almost any tc qdisc activity on 2.6.35 or later triggers this warning
> (the patch below):
>=20
> [  516.287584] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> [  516.288386] [ INFO: possible irq lock inversion dependency detecte=
d ]
> [  516.288386] 2.6.35b #7
> [  516.288386] ------------------------------------------------------=
---
> [  516.288386] swapper/0 just changed the state of lock:
> [  516.288386]  (&qdisc_tx_lock){+.-...}, at: [<c12eacda>] est_timer+=
0x62/0x1b4
> [  516.288386] but this lock took another, SOFTIRQ-unsafe lock in the=
 past:
> [  516.288386]  (est_tree_lock){+.+...}
> [  516.288386]=20
> [  516.288386] and interrupts could create inverse lock ordering betw=
een them.
> [  516.288386]=20
> [  516.288386]=20
> [  516.288386] other info that might help us debug this:
> [  516.288386] 2 locks held by swapper/0:
> [  516.288386]  #0:  (&elist[idx].timer){+.-...}, at: [<c10334b5>] ru=
n_timer_softirq+0x11d/0x263
> [  516.288386]  #1:  (rcu_read_lock){.+.+..}, at: [<c12eac78>] est_ti=
mer+0x0/0x1b4
> [  516.288386]=20
> [  516.288386] the shortest dependencies between 2nd lock and 1st loc=
k:
> [  516.288386]  -> (est_tree_lock){+.+...} ops: 5 {
> [  516.288386]     HARDIRQ-ON-W at:
> [  516.288386]                                          [<c104a421>] =
__lock_acquire+0x306/0xbd6
> [  516.288386]                                          [<c104ad9d>] =
lock_acquire+0xac/0xc8
> [  516.288386]                                          [<c13c53ce>] =
_raw_spin_lock+0x25/0x34
> [  516.288386]                                          [<c12ea985>] =
gen_estimator_active+0x39/0x74
> [  516.288386]                                          [<c12ea82a>] =
gnet_stats_copy_rate_est+0x16/0x4d
> [  516.288386]                                          [<c1300000>] =
tc_fill_qdisc+0x186/0x1e2
> [  516.288386]                                          [<c13001b2>] =
qdisc_notify+0x94/0xcf
> [  516.288386]                                          [<c1300385>] =
notify_and_destroy+0x27/0x3d
> [  516.288386]                                          [<c1300490>] =
qdisc_graft+0xf5/0x1c6
> [  516.288386]                                          [<c130110a>] =
tc_modify_qdisc+0x369/0x3b8
> [  516.288386]                                          [<c12f8d09>] =
rtnetlink_rcv_msg+0x197/0x1b1
> [  516.288386]                                          [<c1305cc0>] =
netlink_rcv_skb+0x30/0x75
> [  516.288386]                                          [<c12f8b6a>] =
rtnetlink_rcv+0x1e/0x26
> [  516.288386]                                          [<c1305b01>] =
netlink_unicast+0xc4/0x11a
> [  516.288386]                                          [<c13061a2>] =
netlink_sendmsg+0x23a/0x252
> [  516.288386]                                          [<c12e09fd>] =
__sock_sendmsg+0x4d/0x56
> [  516.288386]                                          [<c12e0e42>] =
sock_sendmsg+0x95/0xab
> [  516.288386]                                          [<c12e1024>] =
sys_sendmsg+0x13f/0x18f
> [  516.288386]                                          [<c12e2676>] =
sys_socketcall+0x155/0x1a3
> [  516.288386]                                          [<c13c5e25>] =
syscall_call+0x7/0xb
> [  516.288386]     SOFTIRQ-ON-W at:
> [  516.288386]                                          [<c104a442>] =
__lock_acquire+0x327/0xbd6
> [  516.288386]                                          [<c104ad9d>] =
lock_acquire+0xac/0xc8
> [  516.288386]                                          [<c13c53ce>] =
_raw_spin_lock+0x25/0x34
> [  516.288386]                                          [<c12ea9d8>] =
gen_kill_estimator+0x18/0x9b
> [  516.288386]                                          [<c12fea48>] =
qdisc_destroy+0x34/0x79
> [  516.288386]                                          [<c1300393>] =
notify_and_destroy+0x35/0x3d
> [  516.288386]                                          [<c1300490>] =
qdisc_graft+0xf5/0x1c6
> [  516.288386]                                          [<c1300686>] =
tc_get_qdisc+0x125/0x157
> [  516.288386]                                          [<c12f8d09>] =
rtnetlink_rcv_msg+0x197/0x1b1
> [  516.288386]                                          [<c1305cc0>] =
netlink_rcv_skb+0x30/0x75
> [  516.288386]                                          [<c12f8b6a>] =
rtnetlink_rcv+0x1e/0x26
> [  516.288386]                                          [<c1305b01>] =
netlink_unicast+0xc4/0x11a
> [  516.288386]                                          [<c13061a2>] =
netlink_sendmsg+0x23a/0x252
> [  516.288386]                                          [<c12e09fd>] =
__sock_sendmsg+0x4d/0x56
> [  516.288386]                                          [<c12e0e42>] =
sock_sendmsg+0x95/0xab
> [  516.288386]                                          [<c12e1024>] =
sys_sendmsg+0x13f/0x18f
> [  516.288386]                                          [<c12e2676>] =
sys_socketcall+0x155/0x1a3
> [  516.288386]                                          [<c13c5e25>] =
syscall_call+0x7/0xb
> [  516.288386]     INITIAL USE at:
> [  516.288386]                                         [<c104a49a>] _=
_lock_acquire+0x37f/0xbd6
> [  516.288386]                                         [<c104ad9d>] l=
ock_acquire+0xac/0xc8
> [  516.288386]                                         [<c13c53ce>] _=
raw_spin_lock+0x25/0x34
> [  516.288386]                                         [<c12ea985>] g=
en_estimator_active+0x39/0x74
> [  516.288386]                                         [<c12ea82a>] g=
net_stats_copy_rate_est+0x16/0x4d
> [  516.288386]                                         [<c1300000>] t=
c_fill_qdisc+0x186/0x1e2
> [  516.288386]                                         [<c13001b2>] q=
disc_notify+0x94/0xcf
> [  516.288386]                                         [<c1300385>] n=
otify_and_destroy+0x27/0x3d
> [  516.288386]                                         [<c1300490>] q=
disc_graft+0xf5/0x1c6
> [  516.288386]                                         [<c130110a>] t=
c_modify_qdisc+0x369/0x3b8
> [  516.288386]                                         [<c12f8d09>] r=
tnetlink_rcv_msg+0x197/0x1b1
> [  516.288386]                                         [<c1305cc0>] n=
etlink_rcv_skb+0x30/0x75
> [  516.288386]                                         [<c12f8b6a>] r=
tnetlink_rcv+0x1e/0x26
> [  516.288386]                                         [<c1305b01>] n=
etlink_unicast+0xc4/0x11a
> [  516.288386]                                         [<c13061a2>] n=
etlink_sendmsg+0x23a/0x252
> [  516.288386]                                         [<c12e09fd>] _=
_sock_sendmsg+0x4d/0x56
> [  516.288386]                                         [<c12e0e42>] s=
ock_sendmsg+0x95/0xab
> [  516.288386]                                         [<c12e1024>] s=
ys_sendmsg+0x13f/0x18f
> [  516.288386]                                         [<c12e2676>] s=
ys_socketcall+0x155/0x1a3
> [  516.288386]                                         [<c13c5e25>] s=
yscall_call+0x7/0xb
> [  516.288386]   }
> [  516.288386]   ... key      at: [<c15a70fc>] est_tree_lock+0x10/0x1=
c
> [  516.288386]   ... acquired at:
> [  516.288386]    [<c104ad9d>] lock_acquire+0xac/0xc8
> [  516.288386]    [<c13c53ce>] _raw_spin_lock+0x25/0x34
> [  516.288386]    [<c12ea985>] gen_estimator_active+0x39/0x74
> [  516.288386]    [<c12ea82a>] gnet_stats_copy_rate_est+0x16/0x4d
> [  516.288386]    [<c1300000>] tc_fill_qdisc+0x186/0x1e2
> [  516.288386]    [<c13001b2>] qdisc_notify+0x94/0xcf
> [  516.288386]    [<c1300385>] notify_and_destroy+0x27/0x3d
> [  516.288386]    [<c1300490>] qdisc_graft+0xf5/0x1c6
> [  516.288386]    [<c130110a>] tc_modify_qdisc+0x369/0x3b8
> [  516.288386]    [<c12f8d09>] rtnetlink_rcv_msg+0x197/0x1b1
> [  516.288386]    [<c1305cc0>] netlink_rcv_skb+0x30/0x75
> [  516.288386]    [<c12f8b6a>] rtnetlink_rcv+0x1e/0x26
> [  516.288386]    [<c1305b01>] netlink_unicast+0xc4/0x11a
> [  516.288386]    [<c13061a2>] netlink_sendmsg+0x23a/0x252
> [  516.288386]    [<c12e09fd>] __sock_sendmsg+0x4d/0x56
> [  516.288386]    [<c12e0e42>] sock_sendmsg+0x95/0xab
> [  516.288386]    [<c12e1024>] sys_sendmsg+0x13f/0x18f
> [  516.288386]    [<c12e2676>] sys_socketcall+0x155/0x1a3
> [  516.288386]    [<c13c5e25>] syscall_call+0x7/0xb
> [  516.288386]=20
> [  516.288386] -> (&qdisc_tx_lock){+.-...} ops: 10 {
> [  516.288386]    HARDIRQ-ON-W at:
> [  516.288386]                                        [<c104a421>] __=
lock_acquire+0x306/0xbd6
> [  516.288386]                                        [<c104ad9d>] lo=
ck_acquire+0xac/0xc8
> [  516.288386]                                        [<c13c55e1>] _r=
aw_spin_lock_bh+0x2a/0x39
> [  516.288386]                                        [<c12ea8f1>] gn=
et_stats_start_copy_compat+0x27/0x70
> [  516.288386]                                        [<c12fffc7>] tc=
_fill_qdisc+0x14d/0x1e2
> [  516.288386]                                        [<c13001b2>] qd=
isc_notify+0x94/0xcf
> [  516.288386]                                        [<c1300385>] no=
tify_and_destroy+0x27/0x3d
> [  516.288386]                                        [<c1300490>] qd=
isc_graft+0xf5/0x1c6
> [  516.288386]                                        [<c130110a>] tc=
_modify_qdisc+0x369/0x3b8
> [  516.288386]                                        [<c12f8d09>] rt=
netlink_rcv_msg+0x197/0x1b1
> [  516.288386]                                        [<c1305cc0>] ne=
tlink_rcv_skb+0x30/0x75
> [  516.288386]                                        [<c12f8b6a>] rt=
netlink_rcv+0x1e/0x26
> [  516.288386]                                        [<c1305b01>] ne=
tlink_unicast+0xc4/0x11a
> [  516.288386]                                        [<c13061a2>] ne=
tlink_sendmsg+0x23a/0x252
> [  516.288386]                                        [<c12e09fd>] __=
sock_sendmsg+0x4d/0x56
> [  516.288386]                                        [<c12e0e42>] so=
ck_sendmsg+0x95/0xab
> [  516.288386]                                        [<c12e1024>] sy=
s_sendmsg+0x13f/0x18f
> [  516.288386]                                        [<c12e2676>] sy=
s_socketcall+0x155/0x1a3
> [  516.288386]                                        [<c13c5e25>] sy=
scall_call+0x7/0xb
> [  516.288386]    IN-SOFTIRQ-W at:
> [  516.288386]                                        [<c104a3c3>] __=
lock_acquire+0x2a8/0xbd6
> [  516.288386]                                        [<c104ad9d>] lo=
ck_acquire+0xac/0xc8
> [  516.288386]                                        [<c13c53ce>] _r=
aw_spin_lock+0x25/0x34
> [  516.288386]                                        [<c12eacda>] es=
t_timer+0x62/0x1b4
> [  516.288386]                                        [<c1033536>] ru=
n_timer_softirq+0x19e/0x263
> [  516.288386]                                        [<c102d692>] __=
do_softirq+0xab/0x169
> [  516.288386]                                        [<c102d77a>] do=
_softirq+0x2a/0x42
> [  516.288386]                                        [<c102d8d6>] ir=
q_exit+0x36/0x42
> [  516.288386]                                        [<c1014705>] sm=
p_apic_timer_interrupt+0x66/0x71
> [  516.288386]                                        [<c13c5fdf>] ap=
ic_timer_interrupt+0x2f/0x34
> [  516.288386]                                        [<c1001c13>] cp=
u_idle+0x31/0x5a
> [  516.288386]                                        [<c13bc316>] re=
st_init+0xda/0xdf
> [  516.288386]                                        [<c15ba7c3>] st=
art_kernel+0x2d4/0x2d9
> [  516.288386]                                        [<c15ba09f>] i3=
86_start_kernel+0x9f/0xa7
> [  516.288386]    INITIAL USE at:
> [  516.288386]                                       [<c104a49a>] __l=
ock_acquire+0x37f/0xbd6
> [  516.288386]                                       [<c104ad9d>] loc=
k_acquire+0xac/0xc8
> [  516.288386]                                       [<c13c55e1>] _ra=
w_spin_lock_bh+0x2a/0x39
> [  516.288386]                                       [<c12ea8f1>] gne=
t_stats_start_copy_compat+0x27/0x70
> [  516.288386]                                       [<c12fffc7>] tc_=
fill_qdisc+0x14d/0x1e2
> [  516.288386]                                       [<c13001b2>] qdi=
sc_notify+0x94/0xcf
> [  516.288386]                                       [<c1300385>] not=
ify_and_destroy+0x27/0x3d
> [  516.288386]                                       [<c1300490>] qdi=
sc_graft+0xf5/0x1c6
> [  516.288386]                                       [<c130110a>] tc_=
modify_qdisc+0x369/0x3b8
> [  516.288386]                                       [<c12f8d09>] rtn=
etlink_rcv_msg+0x197/0x1b1
> [  516.288386]                                       [<c1305cc0>] net=
link_rcv_skb+0x30/0x75
> [  516.288386]                                       [<c12f8b6a>] rtn=
etlink_rcv+0x1e/0x26
> [  516.288386]                                       [<c1305b01>] net=
link_unicast+0xc4/0x11a
> [  516.288386]                                       [<c13061a2>] net=
link_sendmsg+0x23a/0x252
> [  516.288386]                                       [<c12e09fd>] __s=
ock_sendmsg+0x4d/0x56
> [  516.288386]                                       [<c12e0e42>] soc=
k_sendmsg+0x95/0xab
> [  516.288386]                                       [<c12e1024>] sys=
_sendmsg+0x13f/0x18f
> [  516.288386]                                       [<c12e2676>] sys=
_socketcall+0x155/0x1a3
> [  516.288386]                                       [<c13c5e25>] sys=
call_call+0x7/0xb
> [  516.288386]  }
> [  516.288386]  ... key      at: [<c1b8318c>] qdisc_tx_lock+0x0/0x8
> [  516.288386]  ... acquired at:
> [  516.288386]    [<c1049bf3>] check_usage_forwards+0x5d/0x68
> [  516.288386]    [<c1049575>] mark_lock+0x102/0x1e0
> [  516.288386]    [<c104a3c3>] __lock_acquire+0x2a8/0xbd6
> [  516.288386]    [<c104ad9d>] lock_acquire+0xac/0xc8
> [  516.288386]    [<c13c53ce>] _raw_spin_lock+0x25/0x34
> [  516.288386]    [<c12eacda>] est_timer+0x62/0x1b4
> [  516.288386]    [<c1033536>] run_timer_softirq+0x19e/0x263
> [  516.288386]    [<c102d692>] __do_softirq+0xab/0x169
> [  516.288386]    [<c102d77a>] do_softirq+0x2a/0x42
> [  516.288386]    [<c102d8d6>] irq_exit+0x36/0x42
> [  516.288386]    [<c1014705>] smp_apic_timer_interrupt+0x66/0x71
> [  516.288386]    [<c13c5fdf>] apic_timer_interrupt+0x2f/0x34
> [  516.288386]    [<c1001c13>] cpu_idle+0x31/0x5a
> [  516.288386]    [<c13bc316>] rest_init+0xda/0xdf
> [  516.288386]    [<c15ba7c3>] start_kernel+0x2d4/0x2d9
> [  516.288386]    [<c15ba09f>] i386_start_kernel+0x9f/0xa7
> [  516.288386]=20
> [  516.288386]=20
> [  516.288386] stack backtrace:
> [  516.288386] Pid: 0, comm: swapper Not tainted 2.6.35b #7
> [  516.288386] Call Trace:
> [  516.288386]  [<c13c3a01>] ? printk+0xf/0x16
> [  516.288386]  [<c1049b8b>] print_irq_inversion_bug+0xef/0xfa
> [  516.288386]  [<c1049bf3>] check_usage_forwards+0x5d/0x68
> [  516.288386]  [<c1049575>] mark_lock+0x102/0x1e0
> [  516.288386]  [<c1049b96>] ? check_usage_forwards+0x0/0x68
> [  516.288386]  [<c104a3c3>] __lock_acquire+0x2a8/0xbd6
> [  516.288386]  [<c104a49a>] ? __lock_acquire+0x37f/0xbd6
> [  516.288386]  [<c104ac2b>] ? __lock_acquire+0xb10/0xbd6
> [  516.288386]  [<c104ad9d>] lock_acquire+0xac/0xc8
> [  516.288386]  [<c12eacda>] ? est_timer+0x62/0x1b4
> [  516.288386]  [<c13c53ce>] _raw_spin_lock+0x25/0x34
> [  516.288386]  [<c12eacda>] ? est_timer+0x62/0x1b4
> [  516.288386]  [<c12eacda>] est_timer+0x62/0x1b4
> [  516.288386]  [<c10334b5>] ? run_timer_softirq+0x11d/0x263
> [  516.288386]  [<c1033536>] run_timer_softirq+0x19e/0x263
> [  516.288386]  [<c12eac78>] ? est_timer+0x0/0x1b4
> [  516.288386]  [<c102d692>] __do_softirq+0xab/0x169
> [  516.288386]  [<c102d77a>] do_softirq+0x2a/0x42
> [  516.288386]  [<c102d8d6>] irq_exit+0x36/0x42
> [  516.288386]  [<c1014705>] smp_apic_timer_interrupt+0x66/0x71
> [  516.288386]  [<c13c5fdf>] apic_timer_interrupt+0x2f/0x34
> [  516.288386]  [<c104007b>] ? create_new_namespaces+0x37/0x127
> [  516.288386]  [<c1007c0b>] ? default_idle+0x46/0x65
> [  516.288386]  [<c1001c13>] cpu_idle+0x31/0x5a
> [  516.288386]  [<c13bc316>] rest_init+0xda/0xdf
> [  516.288386]  [<c15ba7c3>] start_kernel+0x2d4/0x2d9
> [  516.288386]  [<c15ba09f>] i386_start_kernel+0x9f/0xa7
>=20
> ----------->
>=20
> This patch fixes a lockdep warning:
>=20
> [  516.287584] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> [  516.288386] [ INFO: possible irq lock inversion dependency detecte=
d ]
> [  516.288386] 2.6.35b #7
> [  516.288386] ------------------------------------------------------=
---
> [  516.288386] swapper/0 just changed the state of lock:
> [  516.288386]  (&qdisc_tx_lock){+.-...}, at: [<c12eacda>] est_timer+=
0x62/0x1b4
> [  516.288386] but this lock took another, SOFTIRQ-unsafe lock in the=
 past:
> [  516.288386]  (est_tree_lock){+.+...}
> [  516.288386]=20
> [  516.288386] and interrupts could create inverse lock ordering betw=
een them.
> ...
>=20
> So, est_tree_lock needs BH protection because it's taken by
> qdisc_tx_lock, which is used both in BH and process contexts.
> (Full warning with this patch at netdev, 02 Sep 2010.)
>=20
> Fixes commit: ae638c47dc040b8def16d05dc6acdd527628f231
>=20
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> ---
>=20
> diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
> index 9fbe7f7..6743146 100644
> --- a/net/core/gen_estimator.c
> +++ b/net/core/gen_estimator.c
> @@ -232,7 +232,7 @@ int gen_new_estimator(struct gnet_stats_basic_pac=
ked *bstats,
>  	est->last_packets =3D bstats->packets;
>  	est->avpps =3D rate_est->pps<<10;
> =20
> -	spin_lock(&est_tree_lock);
> +	spin_lock_bh(&est_tree_lock);
>  	if (!elist[idx].timer.function) {
>  		INIT_LIST_HEAD(&elist[idx].list);
>  		setup_timer(&elist[idx].timer, est_timer, idx);
> @@ -243,7 +243,7 @@ int gen_new_estimator(struct gnet_stats_basic_pac=
ked *bstats,
> =20
>  	list_add_rcu(&est->list, &elist[idx].list);
>  	gen_add_node(est);
> -	spin_unlock(&est_tree_lock);
> +	spin_unlock_bh(&est_tree_lock);
> =20
>  	return 0;
>  }
> @@ -270,7 +270,7 @@ void gen_kill_estimator(struct gnet_stats_basic_p=
acked *bstats,
>  {
>  	struct gen_estimator *e;
> =20
> -	spin_lock(&est_tree_lock);
> +	spin_lock_bh(&est_tree_lock);
>  	while ((e =3D gen_find_node(bstats, rate_est))) {
>  		rb_erase(&e->node, &est_root);
> =20

If you lock bh for est_tree_lock(), we dont need _bh for est_lock here

> @@ -281,7 +281,7 @@ void gen_kill_estimator(struct gnet_stats_basic_p=
acked *bstats,
>  		list_del_rcu(&e->list);
>  		call_rcu(&e->e_rcu, __gen_kill_estimator);
>  	}
> -	spin_unlock(&est_tree_lock);
> +	spin_unlock_bh(&est_tree_lock);
>  }
>  EXPORT_SYMBOL(gen_kill_estimator);
> =20
> @@ -320,9 +320,9 @@ bool gen_estimator_active(const struct gnet_stats=
_basic_packed *bstats,
> =20
>  	ASSERT_RTNL();
> =20
> -	spin_lock(&est_tree_lock);
> +	spin_lock_bh(&est_tree_lock);
>  	res =3D gen_find_node(bstats, rate_est) !=3D NULL;
> -	spin_unlock(&est_tree_lock);
> +	spin_unlock_bh(&est_tree_lock);
> =20
>  	return res;
>  }


I must be very tired, I dont understand this patch.

Maybe after a night, I'll understand ?

est_tree_lock is only taken by process context, and I dont see what can
be the problem. Are you sure its not a lockdep false positive, or that
the real bug is elsewhere ?

Sure, we can block BH everywhere, it will reduce bugs and lockdep
alarms, but I would like to understand before, why its needed.

If you believe est_tree_lock can be taken by a softirq handler, please
tell me ;)

Thanks


