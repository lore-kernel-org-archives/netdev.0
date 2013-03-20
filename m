From: Borislav Petkov <bp@alien8.de>
Subject: 3.9-rc3 forcedeth lockdep splat with netconsole
Date: Wed, 20 Mar 2013 12:01:51 +0100
Message-ID: <20130320110150.GB15471@pd.tnic>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lkml <linux-kernel@vger.kernel.org>
To: ML netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

when trying to log stuff with netconsole, I get the following:

[ =E2=80=A6 ]

[    2.036977] netpoll: netconsole: device eth0 not up yet, forcing it
[    2.037632] forcedeth 0000:00:08.0: irq 42 for MSI/MSI-X
[    2.037763] forcedeth 0000:00:08.0 eth0: MSI enabled
[    2.038074] forcedeth 0000:00:08.0 eth0: no link during initializati=
on
[    2.780061] forcedeth 0000:00:08.0 eth0: link up
[    2.780709]=20
[    2.780710] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[    2.780710] [ INFO: inconsistent lock state ]
[    2.780712] 3.9.0-rc3+ #2 Not tainted
[    2.780712] ---------------------------------
[    2.780713] inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usage.
[    2.780715] swapper/0/1 [HC0[0]:SC0[0]:HE1:SE1] takes:
[    2.780723]  (&(&napi->poll_lock)->rlock){+.?...}, at: [<ffffffff814=
7b045>] netpoll_poll_dev+0xe5/0xc80
[    2.780723] {IN-SOFTIRQ-W} state was registered at:
[    2.780728]   [<ffffffff8109ade8>] __lock_acquire+0x608/0x1de0
[    2.780730]   [<ffffffff8109cc9e>] lock_acquire+0x9e/0x1f0
[    2.780733]   [<ffffffff81529811>] _raw_spin_lock+0x41/0x80
[    2.780736]   [<ffffffff8145fc1e>] net_rx_action+0xbe/0x330
[    2.780739]   [<ffffffff81044949>] __do_softirq+0xe9/0x3d0
[    2.780740]   [<ffffffff81044c65>] run_ksoftirqd+0x35/0x50
[    2.780744]   [<ffffffff8106dba4>] smpboot_thread_fn+0x1d4/0x2e0
[    2.780749]   [<ffffffff81064b4b>] kthread+0xdb/0xe0
[    2.780751]   [<ffffffff8152b45c>] ret_from_fork+0x7c/0xb0
[    2.780752] irq event stamp: 576121
[    2.780754] hardirqs last  enabled at (576121): [<ffffffff8152aa20>]=
 restore_args+0x0/0x30
[    2.780756] hardirqs last disabled at (576120): [<ffffffff8152a96a>]=
 common_interrupt+0x6a/0x6f
[    2.780758] softirqs last  enabled at (576090): [<ffffffff810449d5>]=
 __do_softirq+0x175/0x3d0
[    2.780759] softirqs last disabled at (576085): [<ffffffff81044d96>]=
 irq_exit+0x96/0xb0
[    2.780760]=20
[    2.780760] other info that might help us debug this:
[    2.780760]  Possible unsafe locking scenario:
[    2.780760]=20
[    2.780761]        CPU0
[    2.780761]        ----
[    2.780762]   lock(&(&napi->poll_lock)->rlock);
[    2.780763]   <Interrupt>
[    2.780764]     lock(&(&napi->poll_lock)->rlock);
[    2.780764]=20
[    2.780764]  *** DEADLOCK ***
[    2.780764]=20
[    2.780765] 3 locks held by swapper/0/1:
[    2.780768]  #0:  (console_lock){+.+.+.}, at: [<ffffffff8103e96e>] r=
egister_console+0xfe/0x390
[    2.780772]  #1:  (target_list_lock){+.+...}, at: [<ffffffff81370033=
>] write_msg+0x53/0x110
[    2.780775]  #2:  (&npinfo->dev_lock){+.+...}, at: [<ffffffff8147afa=
6>] netpoll_poll_dev+0x46/0xc80
[    2.780776]=20
[    2.780776] stack backtrace:
[    2.780777] Pid: 1, comm: swapper/0 Not tainted 3.9.0-rc3+ #2
[    2.780778] Call Trace:
[    2.780781]  [<ffffffff81521b9a>] print_usage_bug.part.34+0x270/0x27=
f
[    2.780785]  [<ffffffff810108cf>] ? save_stack_trace+0x2f/0x50
[    2.780787]  [<ffffffff810792e3>] ? local_clock+0x43/0x50
[    2.780789]  [<ffffffff81097630>] ? print_shortest_lock_dependencies=
+0x1d0/0x1d0
[    2.780791]  [<ffffffff810984fb>] mark_lock+0x27b/0x600
[    2.780793]  [<ffffffff8109ae56>] __lock_acquire+0x676/0x1de0
[    2.780795]  [<ffffffff8152aa20>] ? retint_restore_args+0xe/0xe
[    2.780797]  [<ffffffff8152a3a7>] ? _raw_spin_unlock_irqrestore+0x67=
/0x80
[    2.780799]  [<ffffffff8109cc9e>] lock_acquire+0x9e/0x1f0
[    2.780801]  [<ffffffff8147b045>] ? netpoll_poll_dev+0xe5/0xc80
[    2.780803]  [<ffffffff8152a4e3>] _raw_spin_trylock+0x73/0x90
[    2.780804]  [<ffffffff8147b045>] ? netpoll_poll_dev+0xe5/0xc80
[    2.780806]  [<ffffffff8147b045>] netpoll_poll_dev+0xe5/0xc80
[    2.780808]  [<ffffffff810967ae>] ? put_lock_stats.isra.17+0xe/0x40
[    2.780810]  [<ffffffff8147bee4>] ? netpoll_send_skb_on_dev+0x304/0x=
400
[    2.780812]  [<ffffffff8147bef5>] netpoll_send_skb_on_dev+0x315/0x40=
0
[    2.780814]  [<ffffffff8147c267>] netpoll_send_udp+0x287/0x3a0
[    2.780815]  [<ffffffff81370033>] ? write_msg+0x53/0x110
[    2.780817]  [<ffffffff8137009f>] write_msg+0xbf/0x110
[    2.780818]  [<ffffffff8103d8c7>] ? console_unlock+0x3d7/0x450
[    2.780820]  [<ffffffff8103c9da>] call_console_drivers.constprop.15+=
0x9a/0x1d0
[    2.780822]  [<ffffffff8103d8d7>] console_unlock+0x3e7/0x450
[    2.780823]  [<ffffffff8103e9a7>] register_console+0x137/0x390
[    2.780826]  [<ffffffff81a18281>] init_netconsole+0x1a6/0x214
[    2.780828]  [<ffffffff8131db00>] ? driver_deferred_probe_trigger.pa=
rt.9+0x80/0x80
[    2.780830]  [<ffffffff81a180db>] ? option_setup+0x1f/0x1f
[    2.780832]  [<ffffffff81000312>] do_one_initcall+0x122/0x170
[    2.780836]  [<ffffffff819f5e2b>] kernel_init_freeable+0x103/0x192
[    2.780837]  [<ffffffff819f57e8>] ? do_early_param+0x8c/0x8c
[    2.780840]  [<ffffffff81512760>] ? rest_init+0x140/0x140
[    2.780842]  [<ffffffff8151276e>] kernel_init+0xe/0xe0
[    2.780844]  [<ffffffff8152b45c>] ret_from_fork+0x7c/0xb0
[    2.780845]  [<ffffffff81512760>] ? rest_init+0x140/0x140
[    2.780899] ------------[ cut here ]------------
[    2.780901] WARNING: at net/core/netpoll.c:412 netpoll_send_skb_on_d=
ev+0x3e9/0x400()
[    2.780903] Hardware name: =20
[    2.780905] netpoll_send_skb_on_dev(): eth0 enabled interrupts in po=
ll (nv_start_xmit_optimized+0x0/0x720)
[    2.780907] Modules linked in:
[    2.780908] Pid: 1, comm: swapper/0 Not tainted 3.9.0-rc3+ #2
[    2.780908] Call Trace:
[    2.780910]  [<ffffffff8147bfc9>] ? netpoll_send_skb_on_dev+0x3e9/0x=
400
[    2.780913]  [<ffffffff8103b4ff>] warn_slowpath_common+0x7f/0xc0
[    2.780915]  [<ffffffff8103b5f6>] warn_slowpath_fmt+0x46/0x50
[    2.780916]  [<ffffffff813752a0>] ? nv_get_drvinfo+0x80/0x80
[    2.780918]  [<ffffffff8147bfc9>] netpoll_send_skb_on_dev+0x3e9/0x40=
0
[    2.780920]  [<ffffffff8147c267>] netpoll_send_udp+0x287/0x3a0
[    2.780922]  [<ffffffff81370033>] ? write_msg+0x53/0x110
[    2.780924]  [<ffffffff8137009f>] write_msg+0xbf/0x110
[    2.780925]  [<ffffffff8103d8c7>] ? console_unlock+0x3d7/0x450
[    2.780927]  [<ffffffff8103c9da>] call_console_drivers.constprop.15+=
0x9a/0x1d0
[    2.780928]  [<ffffffff8103d8d7>] console_unlock+0x3e7/0x450
[    2.780931]  [<ffffffff8103e9a7>] register_console+0x137/0x390
[    2.780933]  [<ffffffff81a18281>] init_netconsole+0x1a6/0x214
[    2.780934]  [<ffffffff8131db00>] ? driver_deferred_probe_trigger.pa=
rt.9+0x80/0x80
[    2.780936]  [<ffffffff81a180db>] ? option_setup+0x1f/0x1f
[    2.780938]  [<ffffffff81000312>] do_one_initcall+0x122/0x170
[    2.780940]  [<ffffffff819f5e2b>] kernel_init_freeable+0x103/0x192
[    2.780941]  [<ffffffff819f57e8>] ? do_early_param+0x8c/0x8c
[    2.780943]  [<ffffffff81512760>] ? rest_init+0x140/0x140
[    2.780945]  [<ffffffff8151276e>] kernel_init+0xe/0xe0
[    2.780947]  [<ffffffff8152b45c>] ret_from_fork+0x7c/0xb0
[    2.780948]  [<ffffffff81512760>] ? rest_init+0x140/0x140
[    2.780950] ---[ end trace a7ed4414d27e5db1 ]---
[    2.789399] console [netcon0] enabled
[    2.789445] netconsole: network logging started

--=20
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--
