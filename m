From: Elad Raz <e@eladraz.com>
Subject: Re: [Patch net-next 2/2] netns: avoid disabling irq for netns id
Date: Wed, 19 Oct 2016 18:21:26 +0300
Message-ID: <CAA1AmC2KiuoDiuBmjFAS20UnzkfCCnvHYyXhm3MOrVBUty9EeQ@mail.gmail.com>
References: <1472792025-14702-1-git-send-email-xiyou.wangcong@gmail.com>
 <1472792025-14702-3-git-send-email-xiyou.wangcong@gmail.com> <7de98923-0cfb-5937-d32b-bdaee7ec10dc@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@resnulli.us>,
        Ido Schimmel <idosch@mellanox.com>,
        Yotam Gigi <yotamg@mellanox.com>
To: nicolas.dichtel@6wind.com, Cong Wang <xiyou.wangcong@gmail.com>,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f177.google.com ([209.85.216.177]:36606 "EHLO
        mail-qt0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S944814AbcJSPVg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 11:21:36 -0400
Received: by mail-qt0-f177.google.com with SMTP id m5so23738856qtb.3
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2016 08:21:35 -0700 (PDT)
In-Reply-To: <7de98923-0cfb-5937-d32b-bdaee7ec10dc@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 2, 2016 at 11:12 AM, Nicolas Dichtel
<nicolas.dichtel@6wind.com> wrote:
> Le 02/09/2016 =C3=A0 06:53, Cong Wang a =C3=A9crit :
>> We never read or change netns id in hardirq context,
>> the only place we read netns id in softirq context
>> is in vxlan_xmit(). So, it should be enough to just
>> disable BH.
>
> Are you sure? Did you audit all part of the code?
> peernet2id() is called from netlink core system (do_one_broadcast()). Are=
 you
> sure that no driver call this function from an hard irq context?
>
> I think that NETLINK_LISTEN_ALL_NSID is largely untested, so it will be h=
ard to
> detect a bug introduced in this feature.

I'm seeing strange things on our systems on boot time when trying to
mount autofs.
I bisected and got this patch as the bad one.
I can see that only when I'm using "debug" config file.

CONFIG_LOCKDEP =3Dy I can see on boot:

[  OK  ] Started OpenSSH server daemon.
        Starting OpenSSH server daemon...
[   23.498577] ------------[ cut here ]------------
[   23.503247] WARNING: CPU: 0 PID: 994 at kernel/softirq.c:150
__local_bh_enable_ip+0x9d/0xc0
[   23.511665] Modules linked in: xt_conntrack ebtable_nat
ebtable_broute bridge stp llc ebtable_filter ebtables iptable_nat
nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack
iptable_mangle iptable_security iptable_raw intel_rapl
x86_pkg_temp_thermal iTCO
_wdt coretemp iTCO_vendor_support kvm_intel kvm irqbypass
crct10dif_pclmul crc32_pclmul ghash_clmulni_intel pcspkr i2c_i801
i2c_smbus lpc_ich mfd_core mei_me mei video tpm_tis tpm_tis_core tpm
nfsd auth_rpcgss nfs_acl lockd grace sunrpc xfs libcrc32c crc32c_intel
e1000e
ptp pps_core
[   23.561125] CPU: 0 PID: 994 Comm: setsebool Not tainted 4.8.0-rc4eladr+ =
#51
[   23.568152] Hardware name: Mellanox Technologies Ltd. Mellanox
switch/Mellanox switch, BIOS 4.6.5 05/21/2015
[   23.578066]  0000000000000000 ffff8801161d3bb0 ffffffff81411b73
0000000000000000
[   23.585594]  0000000000000000 ffff8801161d3bf0 ffffffff810aa69b
00000096816dcda7
[   23.593118]  0000000000000200 ffffffff816dcdc5 ffffffff81f0fb00
ffff8801147a0000
[   23.600639] Call Trace:
[   23.603114]  [<ffffffff81411b73>] dump_stack+0x85/0xc2
[   23.608302]  [<ffffffff810aa69b>] __warn+0xcb/0xf0
[   23.613138]  [<ffffffff816dcdc5>] ? peernet2id+0x45/0x60
[   23.618502]  [<ffffffff810aa78d>] warn_slowpath_null+0x1d/0x20
[   23.624394]  [<ffffffff810b0a4d>] __local_bh_enable_ip+0x9d/0xc0
[   23.630453]  [<ffffffff8183e845>] _raw_spin_unlock_bh+0x35/0x40
[   23.636432]  [<ffffffff816dcdc5>] peernet2id+0x45/0x60
[   23.641626]  [<ffffffff81727ac5>] netlink_broadcast_filtered+0x265/0x3d0
[   23.648385]  [<ffffffff81727c4d>] netlink_broadcast+0x1d/0x20
[   23.654188]  [<ffffffff81165b21>] audit_log_end+0x2b1/0x2c0
[   23.659820]  [<ffffffff811658a0>] ? audit_log_end+0x30/0x2c0
[   23.665532]  [<ffffffff8116631a>] audit_log+0x5a/0x70
[   23.670631]  [<ffffffff813ab7ce>] security_set_bools+0xee/0x200
[   23.676602]  [<ffffffff8139cbc8>] sel_commit_bools_write+0xb8/0x100
[   23.682928]  [<ffffffff8126c1d8>] __vfs_write+0x28/0x120
[   23.688291]  [<ffffffff810fcc17>] ? update_fast_ctr+0x17/0x30
[   23.694087]  [<ffffffff810fcca9>] ? percpu_down_read+0x49/0x90
[   23.699980]  [<ffffffff81270567>] ? __sb_start_write+0xb7/0xf0
[   23.705872]  [<ffffffff81270567>] ? __sb_start_write+0xb7/0xf0
[   23.711758]  [<ffffffff8126d338>] vfs_write+0xb8/0x1b0
[   23.716949]  [<ffffffff81100e09>] ? trace_hardirqs_on_caller+0x129/0x1b0
[   23.723717]  [<ffffffff8126e689>] SyS_write+0x49/0xa0
[   23.728828]  [<ffffffff8183ef3c>] entry_SYSCALL_64_fastpath+0x1f/0xbd
[   23.735337] ---[ end trace 576457efb89c3ea5 ]---

and

        Starting NIS/YP (Network Informatio... Clients to NIS Domain Binder=
...
[   24.182895] FS-Cache: Netfs 'nfs' registered for caching
[  OK  ] Started rolekit - role server.
[   24.210512] Key type dns_resolver registered
[   24.243061] NFS: Registering the id_resolver key type
[   24.253951] Key type id_resolver registered
[   24.258215] Key type id_legacy registered
[   24.272025]
[   24.273545] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   24.277919] [ INFO: inconsistent lock state ]
[   24.282348] 4.8.0-rc4eladr+ #51 Tainted: G        W
[   24.287806] ---------------------------------
[   24.292234] inconsistent {SOFTIRQ-ON-W} -> {IN-SOFTIRQ-R} usage.
[   24.298301] dbus-daemon/673 [HC0[0]:SC1[1]:HE1:SE0] takes:
[   24.303898]  (policy_rwlock){+++?..}, at: [<ffffffff813ac742>]
security_netlbl_sid_to_secattr+0x32/0xc0
[   24.313456] {SOFTIRQ-ON-W} state was registered at:
[   24.318388]   [<ffffffff81100caf>] mark_held_locks+0x6f/0xa0
[   24.324134]   [<ffffffff81100e09>] trace_hardirqs_on_caller+0x129/0x1b0
[   24.330900]   [<ffffffff81100e9d>] trace_hardirqs_on+0xd/0x10
[   24.336708]   [<ffffffff810b0a20>] __local_bh_enable_ip+0x70/0xc0
[   24.342912]   [<ffffffff8183e845>] _raw_spin_unlock_bh+0x35/0x40
[   24.349005]   [<ffffffff816dcdc5>] peernet2id+0x45/0x60
[   24.354361]   [<ffffffff81727ac5>] netlink_broadcast_filtered+0x265/0x3d=
0
[   24.361285]   [<ffffffff81727c4d>] netlink_broadcast+0x1d/0x20
[   24.367222]   [<ffffffff81165b21>] audit_log_end+0x2b1/0x2c0
[   24.372957]   [<ffffffff8116631a>] audit_log+0x5a/0x70
[   24.378174]   [<ffffffff813ab7ce>] security_set_bools+0xee/0x200
[   24.384283]   [<ffffffff8139cbc8>] sel_commit_bools_write+0xb8/0x100
[   24.390733]   [<ffffffff8126c1d8>] __vfs_write+0x28/0x120
[   24.396208]   [<ffffffff8126d338>] vfs_write+0xb8/0x1b0
[   24.401537]   [<ffffffff8126e689>] SyS_write+0x49/0xa0
[   24.406746]   [<ffffffff8183ef3c>] entry_SYSCALL_64_fastpath+0x1f/0xbd
[   24.413375] irq event stamp: 73908
[   24.416878] hardirqs last  enabled at (73908): [<ffffffff812433be>]
__slab_alloc+0x5e/0x90
[   24.425215] hardirqs last disabled at (73907): [<ffffffff8124339c>]
__slab_alloc+0x3c/0x90
[   24.433621] softirqs last  enabled at (73890): [<ffffffff8173f89d>]
ip_finish_output2+0x1fd/0x610
[   24.442634] softirqs last disabled at (73891): [<ffffffff8183ffcc>]
do_softirq_own_stack+0x1c/0x30
[   24.451776]
[   24.451776] other info that might help us debug this:
[   24.458345]  Possible unsafe locking scenario:
[   24.458345]
[   24.464357]        CPU0
[   24.466854]        ----
[   24.469324]   lock(policy_rwlock);
[   24.472817]   <Interrupt>
[   24.475450]     lock(policy_rwlock);
[   24.479108]
[   24.479108]  *** DEADLOCK ***
[   24.479108]
[   24.485081] 4 locks held by dbus-daemon/673:
[   24.489386]  #0:  (sk_lock-AF_INET){+.+.+.}, at:
[<ffffffff8177dcb7>] inet_stream_connect+0x27/0x50
[   24.498659]  #1:  (rcu_read_lock){......}, at: [<ffffffff81740d65>]
ip_queue_xmit+0x5/0x560
[   24.507169]  #2:  (rcu_read_lock){......}, at: [<ffffffff816e949d>]
process_backlog+0xcd/0x230
[   24.515921]  #3:  (rcu_read_lock){......}, at: [<ffffffff8173a8af>]
ip_local_deliver_finish+0x2f/0x390
                       [29/1805]
[   24.525419]
[   24.525419] stack backtrace:
[   24.529833] CPU: 0 PID: 673 Comm: dbus-daemon Tainted: G        W
    4.8.0-rc4eladr+ #51
[   24.538323] Hardware name: Mellanox Technologies Ltd. Mellanox
switch/Mellanox switch, BIOS 4.6.5 05/21/2015
[   24.548246]  0000000000000000 ffff88011dc037d0 ffffffff81411b73
ffff880114955700
[   24.555777]  ffffffff828623a0 ffff88011dc03820 ffffffff81100605
0000000000000001
[   24.563308]  0000000000000001 ffff880100000000 0000000000000006
0000000000000005
[   24.570811] Call Trace:
[   24.573284]  <IRQ>  [<ffffffff81411b73>] dump_stack+0x85/0xc2
[   24.579093]  [<ffffffff81100605>] print_usage_bug+0x215/0x240
[   24.584889]  [<ffffffff81100b7a>] mark_lock+0x54a/0x610
[   24.590165]  [<ffffffff810ffa80>] ?
print_shortest_lock_dependencies+0x1a0/0x1a0
[   24.597655]  [<ffffffff8110174d>] __lock_acquire+0x59d/0x1490
[   24.603469]  [<ffffffff81241b0c>] ? new_slab+0x35c/0x670
[   24.608860]  [<ffffffff81102ab2>] lock_acquire+0xf2/0x1e0
[   24.614363]  [<ffffffff813ac742>] ? security_netlbl_sid_to_secattr+0x32/=
0xc0
[   24.621521]  [<ffffffff8183e924>] _raw_read_lock+0x34/0x50
[   24.627058]  [<ffffffff813ac742>] ? security_netlbl_sid_to_secattr+0x32/=
0xc0
[   24.634154]  [<ffffffff813ac742>] security_netlbl_sid_to_secattr+0x32/0x=
c0
[   24.641070]  [<ffffffff813af520>] selinux_netlbl_inet_conn_request+0x40/=
0xe0
[   24.648178]  [<ffffffff81393302>] selinux_inet_conn_request+0x62/0x90
[   24.654686]  [<ffffffff8138bf53>] security_inet_conn_request+0x43/0x60
[   24.661255]  [<ffffffff8175298a>] tcp_conn_request+0x32a/0xa50
[   24.667154]  [<ffffffff8139543e>] ? selinux_peerlbl_enabled+0x1e/0x40
[   24.673707]  [<ffffffff81397f89>] ? selinux_socket_sock_rcv_skb+0x89/0x2=
00
[   24.680675]  [<ffffffff81762726>] tcp_v4_conn_request+0x86/0xb0
[   24.686638]  [<ffffffff81757db4>] tcp_rcv_state_process+0x194/0xef0
[   24.692980]  [<ffffffff81763832>] tcp_v4_do_rcv+0xb2/0x200
[   24.698507]  [<ffffffff81764f50>] tcp_v4_rcv+0xba0/0xbf0
[   24.703884]  [<ffffffff8173a95a>] ip_local_deliver_finish+0xda/0x390
[   24.710303]  [<ffffffff8173a8af>] ? ip_local_deliver_finish+0x2f/0x390
[   24.716933]  [<ffffffff8173ae50>] ip_local_deliver+0x60/0xd0
[   24.722662]  [<ffffffff8173a880>] ? ip_rcv_finish+0x620/0x620
[   24.728476]  [<ffffffff8173a3ef>] ip_rcv_finish+0x18f/0x620
[   24.734118]  [<ffffffff8173b12c>] ip_rcv+0x26c/0x390
[   24.739129]  [<ffffffff8173a260>] ? inet_del_offload+0x40/0x40
[   24.745029]  [<ffffffff816e8a8a>] __netif_receive_skb_core+0x22a/0xb10
[   24.751630]  [<ffffffff816e949d>] ? process_backlog+0xcd/0x230
[   24.757525]  [<ffffffff816e9388>] __netif_receive_skb+0x18/0x60
[   24.763513]  [<ffffffff816e9442>] process_backlog+0x72/0x230
[   24.769213]  [<ffffffff816e949d>] ? process_backlog+0xcd/0x230
[   24.775090]  [<ffffffff816eb38f>] net_rx_action+0x21f/0x430
[   24.780699]  [<ffffffff81100caf>] ? mark_held_locks+0x6f/0xa0
[   24.786504]  [<ffffffff81841f29>] __do_softirq+0xc9/0x44d
[   24.791946]  [<ffffffff8173f89d>] ? ip_finish_output2+0x1fd/0x610
[   24.798091]  [<ffffffff8183ffcc>] do_softirq_own_stack+0x1c/0x30
[   24.804164]  <EOI>  [<ffffffff810b09a9>] do_softirq.part.17+0x59/0x60
[   24.810699]  [<ffffffff810b0a69>] __local_bh_enable_ip+0xb9/0xc0
[   24.816817]  [<ffffffff8173f8c6>] ip_finish_output2+0x226/0x610
[   24.822804]  [<ffffffff8174083e>] ? ip_finish_output+0x1ae/0x340
[   24.828897]  [<ffffffff8174083e>] ip_finish_output+0x1ae/0x340
[   24.834800]  [<ffffffff8172db12>] ? nf_hook_slow+0xd2/0x170
[   24.840433]  [<ffffffff81741614>] ip_output+0x74/0x120
[   24.845633]  [<ffffffff81740690>] ? ip_fragment.constprop.53+0x80/0x80
[   24.852236]  [<ffffffff81740b1d>] ip_local_out+0x3d/0x80
[   24.857607]  [<ffffffff81740f3d>] ip_queue_xmit+0x1dd/0x560
[   24.863259]  [<ffffffff81740d65>] ? ip_queue_xmit+0x5/0x560
[   24.868894]  [<ffffffff8175aeb4>] tcp_transmit_skb+0x4a4/0x950
[   24.874776]  [<ffffffff8175ceab>] tcp_connect+0x60b/0xa60
[   24.880287]  [<ffffffff816de8d4>] ? secure_tcp_sequence_number+0x74/0xc0
[   24.887099]  [<ffffffff817623e3>] tcp_v4_connect+0x323/0x520
[   24.892836]  [<ffffffff8177da35>] __inet_stream_connect+0x95/0x2f0
[   24.899104]  [<ffffffff81100e9d>] ? trace_hardirqs_on+0xd/0x10
[   24.904976]  [<ffffffff810b0a20>] ? __local_bh_enable_ip+0x70/0xc0
[   24.911217]  [<ffffffff8177dcc8>] inet_stream_connect+0x38/0x50
[   24.917259]  [<ffffffff816c8ec7>] SYSC_connect+0xb7/0xf0
[   24.922649]  [<ffffffff816c6357>] ? sock_alloc_file+0x97/0x110
[   24.928557]  [<ffffffff81100e09>] ? trace_hardirqs_on_caller+0x129/0x1b0
[   24.935309]  [<ffffffff8100301a>] ? trace_hardirqs_on_thunk+0x1a/0x1c
[   24.941819]  [<ffffffff816c9dfe>] SyS_connect+0xe/0x10
[   24.947050]  [<ffffffff8183ef3c>] entry_SYSCALL_64_fastpath+0x1f/0xbd
