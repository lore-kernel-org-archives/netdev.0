From: David Ahern <dsa@cumulusnetworks.com>
Subject: more fallout from sch locking changes?
Date: Mon, 20 Jun 2016 22:02:02 -0600
Message-ID: <6bf6df76-4871-9408-a856-74410bdf7505@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34243 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750726AbcFUECe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 00:02:34 -0400
Received: by mail-pa0-f50.google.com with SMTP id bz2so1908423pad.1
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 21:02:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I just updated to top of next-net tree (697666eac66) and still seeing an 
occasional lockdep splat. It is not reliable to the point I would 
attempt a git bisect. 2 splats -- 1 for ipv4 (first login to VM after 
boot) and ipv6 (second login to VM after boot). Perhaps it is more 
fallout of the packet scheduling changes you have been making this 
iteration. Just a guess based on sch_direct_xmit in both traces.

IPv4 one:


[  189.120375] ------------[ cut here ]------------
[  189.121476] WARNING: CPU: 2 PID: 1463 at 
../kernel/locking/lockdep.c:2099 validate_chain.isra.37+0x25b/0xa5b
[  189.123420] DEBUG_LOCKS_WARN_ON(chain_hlocks[chain->base + j] != id)
[  189.124641] Modules linked in:
[  189.125353] CPU: 2 PID: 1463 Comm: sshd Not tainted 4.7.0-rc2+ #310
[  189.126614] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), 
BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
[  189.128600]  0000000000000000 ffff8800b977b718 ffffffff8127e51e 
ffff8800b977b768
[  189.130173]  0000000000000000 ffff8800b977b758 ffffffff8104d190 
00000833b977b7d0
[  189.131804]  ffffffff81decec0 0000000000006519 01a1c10e0898ad0c 
ffff8800bac64680
[  189.133277] Call Trace:
[  189.133759]  [<ffffffff8127e51e>] dump_stack+0x81/0xb6
[  189.134718]  [<ffffffff8104d190>] __warn+0xc5/0xe0
[  189.135611]  [<ffffffff8104d1f1>] warn_slowpath_fmt+0x46/0x4e
[  189.136681]  [<ffffffff81083ded>] validate_chain.isra.37+0x25b/0xa5b
[  189.137874]  [<ffffffff810398f6>] ? kvm_clock_read+0x25/0x2e
[  189.138932]  [<ffffffff81039913>] ? kvm_sched_clock_read+0x9/0x12
[  189.140084]  [<ffffffff8101c65c>] ? paravirt_sched_clock+0x9/0xd
[  189.141193]  [<ffffffff810853b7>] __lock_acquire+0x5e4/0x690
[  189.142130]  [<ffffffff810853b7>] ? __lock_acquire+0x5e4/0x690
[  189.143006]  [<ffffffff81085a32>] lock_acquire+0x140/0x1d8
[  189.143832]  [<ffffffff814287e6>] ? sch_direct_xmit+0x6f/0x167
[  189.144712]  [<ffffffff814f7066>] _raw_spin_lock+0x2f/0x65
[  189.145547]  [<ffffffff814287e6>] ? sch_direct_xmit+0x6f/0x167
[  189.146426]  [<ffffffff814287e6>] sch_direct_xmit+0x6f/0x167
[  189.147276]  [<ffffffff81408aad>] __dev_queue_xmit+0x43b/0x72d
[  189.148154]  [<ffffffff81427923>] ? eth_header+0x27/0xaf
[  189.148960]  [<ffffffff81408daa>] dev_queue_xmit+0xb/0xd
[  189.149768]  [<ffffffff814126d7>] neigh_resolve_output+0x113/0x12e
[  189.150722]  [<ffffffff81442b10>] ip_finish_output2+0x3c0/0x41c
[  189.151619]  [<ffffffff814433a3>] ip_finish_output+0x132/0x13e
[  189.152548]  [<ffffffff814433d0>] NF_HOOK_COND.constprop.43+0x21/0x8a
[  189.153557]  [<ffffffff81085ff7>] ? lock_is_held+0x69/0x70
[  189.154347]  [<ffffffff81096622>] ? rcu_read_lock_held+0x29/0x2f
[  189.155200]  [<ffffffff81444541>] ip_output+0x65/0x6a
[  189.155920]  [<ffffffff8144240b>] dst_output+0x2b/0x30
[  189.156649]  [<ffffffff81443e82>] ip_local_out+0x2a/0x31
[  189.157425]  [<ffffffff814442a6>] ip_queue_xmit+0x2c3/0x315
[  189.158223]  [<ffffffff814586c7>] tcp_transmit_skb+0x696/0x6c5
[  189.159048]  [<ffffffff81458f16>] tcp_write_xmit+0x820/0xb1c
[  189.159863]  [<ffffffff8112e82a>] ? __might_fault+0xa0/0xa2
[  189.160659]  [<ffffffff8128dba0>] ? copy_from_iter+0x1cb/0x296
[  189.161493]  [<ffffffff8145948c>] __tcp_push_pending_frames+0x2b/0x67
[  189.162409]  [<ffffffff8144bc00>] tcp_push+0x94/0xff
[  189.163176]  [<ffffffff8144e707>] tcp_sendmsg+0x775/0x83a
[  189.164006]  [<ffffffff81472dbf>] inet_sendmsg+0x35/0x5c
[  189.164760]  [<ffffffff813edaa0>] sock_sendmsg_nosec+0x12/0x1d
[  189.165556]  [<ffffffff813edb2b>] sock_write_iter+0x75/0x8d
[  189.166324]  [<ffffffff8115a127>] __vfs_write+0x77/0xa0
[  189.167040]  [<ffffffff8115ad1d>] vfs_write+0xa2/0xc6
[  189.167723]  [<ffffffff8115b918>] SyS_write+0x4b/0x79
[  189.168437]  [<ffffffff814f7b3c>] entry_SYSCALL_64_fastpath+0x1f/0xbd
[  189.169318]  [<ffffffff81081420>] ? trace_hardirqs_off_caller+0xbc/0x122
[  189.170247] ---[ end trace 24ee736782fa0dbd ]---
[  189.170870]
[  189.171084] ======================
[  189.171555] [chain_key collision ]
[  189.172020] 4.7.0-rc2+ #310 Tainted: G        W
[  189.172729] ----------------------
[  189.173192] sshd/1463: Hash chain already cached but the contents 
don't match!
[  189.174236] Held locks:depth: 6
[  189.174707]  class_idx:1253 -> chain_key:00000000000004e5 
(sk_lock-AF_INET){+.+.+.}, at: [<ffffffff8144a84c>] lock_sock+0xb/0xd
[  189.176376]  class_idx:26 -> chain_key:00000000009ca01a 
(rcu_read_lock){......}, at: [<ffffffff814421fb>] rcu_lock_acquire+0x0/0x20
[  189.178014]  class_idx:898 -> chain_key:0000001394034382 
(rcu_read_lock_bh){......}, at: [<ffffffff814421fb>] 
rcu_lock_acquire+0x0/0x20
[  189.179712]  class_idx:898 -> chain_key:0002728068704382 
(rcu_read_lock_bh){......}, at: [<ffffffff81400393>] 
rcu_lock_acquire+0x0/0x20
[  189.181374]  class_idx:1221 -> chain_key:4e500d0e087044c5 
(dev->qdisc_running_key ?: &qdisc_running_key){+.....}, at: 
[<ffffffff81408a7e>] __dev_queue_xmit+0x40c/0x72d
[  189.183400]  class_idx:1222 -> chain_key:01a1c10e0898ad0c 
(_xmit_ETHER#2){+.-...}, at: [<ffffffff814287e6>] sch_direct_xmit+0x6f/0x167
[  189.185178] Locks in cached chain:depth: 6
[  189.185791]  class_idx:1252 -> chain_key:00000000000004e4 
(((&ndev->rs_timer))){+.-...}
[  189.186957]  class_idx:26 -> chain_key:00000000009c801a 
(rcu_read_lock){......}
[  189.187991]  class_idx:898 -> chain_key:0000001390034382 
(rcu_read_lock_bh){......}
[  189.189023]  class_idx:898 -> chain_key:0002720068704382 
(rcu_read_lock_bh){......}
[  189.190050]  class_idx:1221 -> chain_key:4e400d0e087044c5 
(dev->qdisc_running_key ?: &qdisc_running_key){+.....}
[  189.191370]  class_idx:1220 -> chain_key:01a1c10e0898ad0c 
(&(&list->lock)->rlock#3){+.-...}
[  189.192503]
[  189.192503] stack backtrace:
[  189.193052] CPU: 2 PID: 1463 Comm: sshd Tainted: G        W 
4.7.0-rc2+ #310
[  189.193988] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), 
BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
[  189.195242]  0000000000000000 ffff8800b977b778 ffffffff8127e51e 
00000000000004c3
[  189.196237]  ffffffff81decec0 ffff8800b977b7c0 ffffffff81083212 
000000040000c410
[  189.197219]  ffff8800bac64ed8 ffffffff81decec0 0000000000006519 
01a1c10e0898ad0c
[  189.198215] Call Trace:
[  189.198535]  [<ffffffff8127e51e>] dump_stack+0x81/0xb6
[  189.199176]  [<ffffffff81083212>] print_collision+0x203/0x210
[  189.199909]  [<ffffffff8108407d>] validate_chain.isra.37+0x4eb/0xa5b
[  189.200696]  [<ffffffff810398f6>] ? kvm_clock_read+0x25/0x2e
[  189.201399]  [<ffffffff81039913>] ? kvm_sched_clock_read+0x9/0x12
[  189.202167]  [<ffffffff8101c65c>] ? paravirt_sched_clock+0x9/0xd
[  189.202917]  [<ffffffff810853b7>] __lock_acquire+0x5e4/0x690
[  189.203626]  [<ffffffff810853b7>] ? __lock_acquire+0x5e4/0x690
[  189.204359]  [<ffffffff81085a32>] lock_acquire+0x140/0x1d8
[  189.205046]  [<ffffffff814287e6>] ? sch_direct_xmit+0x6f/0x167
[  189.205781]  [<ffffffff814f7066>] _raw_spin_lock+0x2f/0x65
[  189.206464]  [<ffffffff814287e6>] ? sch_direct_xmit+0x6f/0x167
[  189.207199]  [<ffffffff814287e6>] sch_direct_xmit+0x6f/0x167
[  189.207912]  [<ffffffff81408aad>] __dev_queue_xmit+0x43b/0x72d
[  189.208638]  [<ffffffff81427923>] ? eth_header+0x27/0xaf
[  189.209299]  [<ffffffff81408daa>] dev_queue_xmit+0xb/0xd
[  189.209983]  [<ffffffff814126d7>] neigh_resolve_output+0x113/0x12e
[  189.210764]  [<ffffffff81442b10>] ip_finish_output2+0x3c0/0x41c
[  189.211505]  [<ffffffff814433a3>] ip_finish_output+0x132/0x13e
[  189.212233]  [<ffffffff814433d0>] NF_HOOK_COND.constprop.43+0x21/0x8a
[  189.213045]  [<ffffffff81085ff7>] ? lock_is_held+0x69/0x70
[  189.213743]  [<ffffffff81096622>] ? rcu_read_lock_held+0x29/0x2f
[  189.214497]  [<ffffffff81444541>] ip_output+0x65/0x6a
[  189.215130]  [<ffffffff8144240b>] dst_output+0x2b/0x30
[  189.215771]  [<ffffffff81443e82>] ip_local_out+0x2a/0x31
[  189.216430]  [<ffffffff814442a6>] ip_queue_xmit+0x2c3/0x315
[  189.217131]  [<ffffffff814586c7>] tcp_transmit_skb+0x696/0x6c5
[  189.217864]  [<ffffffff81458f16>] tcp_write_xmit+0x820/0xb1c
[  189.218566]  [<ffffffff8112e82a>] ? __might_fault+0xa0/0xa2
[  189.219257]  [<ffffffff8128dba0>] ? copy_from_iter+0x1cb/0x296
[  189.219974]  [<ffffffff8145948c>] __tcp_push_pending_frames+0x2b/0x67
[  189.220770]  [<ffffffff8144bc00>] tcp_push+0x94/0xff
[  189.221385]  [<ffffffff8144e707>] tcp_sendmsg+0x775/0x83a
[  189.222066]  [<ffffffff81472dbf>] inet_sendmsg+0x35/0x5c
[  189.222732]  [<ffffffff813edaa0>] sock_sendmsg_nosec+0x12/0x1d
[  189.223448]  [<ffffffff813edb2b>] sock_write_iter+0x75/0x8d
[  189.224137]  [<ffffffff8115a127>] __vfs_write+0x77/0xa0
[  189.224802]  [<ffffffff8115ad1d>] vfs_write+0xa2/0xc6
[  189.225423]  [<ffffffff8115b918>] SyS_write+0x4b/0x79
[  189.226067]  [<ffffffff814f7b3c>] entry_SYSCALL_64_fastpath+0x1f/0xbd
[  189.226887]  [<ffffffff81081420>] ? trace_hardirqs_off_caller+0xbc/0x122


and IPv6:

[   22.027086] WARNING: CPU: 2 PID: 1401 at 
../kernel/locking/lockdep.c:2099 validate_chain.isra.37+0x25b/0xa5b
[   22.029313] DEBUG_LOCKS_WARN_ON(chain_hlocks[chain->base + j] != id)
[   22.030724] Modules linked in:
[   22.031538] CPU: 2 PID: 1401 Comm: sshd Not tainted 4.7.0-rc2+ #310
[   22.032986] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), 
BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
[   22.035192]  0000000000000000 ffff88013a06b678 ffffffff8127e51e 
ffff88013a06b6c8
[   22.036874]  0000000000000000 ffff88013a06b6b8 ffffffff8104d190 
000008333a06b730
[   22.038563]  ffffffff81decea0 0000000000005088 01a1c10e0898ed06 
ffff8800b97026c0
[   22.040238] Call Trace:
[   22.040726]  [<ffffffff8127e51e>] dump_stack+0x81/0xb6
[   22.041687]  [<ffffffff8104d190>] __warn+0xc5/0xe0
[   22.042586]  [<ffffffff8104d1f1>] warn_slowpath_fmt+0x46/0x4e
[   22.043646]  [<ffffffff81083ded>] validate_chain.isra.37+0x25b/0xa5b
[   22.044852]  [<ffffffff810398f6>] ? kvm_clock_read+0x25/0x2e
[   22.045912]  [<ffffffff81039913>] ? kvm_sched_clock_read+0x9/0x12
[   22.047059]  [<ffffffff8101c65c>] ? paravirt_sched_clock+0x9/0xd
[   22.048093]  [<ffffffff8101ccc3>] ? sched_clock+0x9/0xb
[   22.048982]  [<ffffffff810853b7>] __lock_acquire+0x5e4/0x690
[   22.049933]  [<ffffffff810853b7>] ? __lock_acquire+0x5e4/0x690
[   22.050910]  [<ffffffff81085a32>] lock_acquire+0x140/0x1d8
[   22.051830]  [<ffffffff814287e6>] ? sch_direct_xmit+0x6f/0x167
[   22.052817]  [<ffffffff814f7066>] _raw_spin_lock+0x2f/0x65
[   22.053738]  [<ffffffff814287e6>] ? sch_direct_xmit+0x6f/0x167
[   22.054708]  [<ffffffff814287e6>] sch_direct_xmit+0x6f/0x167
[   22.055666]  [<ffffffff81408aad>] __dev_queue_xmit+0x43b/0x72d
[   22.056658]  [<ffffffff814a0d1b>] ? ip6_finish_output2+0x311/0x3ee
[   22.057704]  [<ffffffff81408daa>] dev_queue_xmit+0xb/0xd
[   22.058584]  [<ffffffff814a0d96>] ip6_finish_output2+0x38c/0x3ee
[   22.059582]  [<ffffffff81081976>] ? __lock_is_held+0x38/0x50
[   22.060553]  [<ffffffff81085ff7>] ? lock_is_held+0x69/0x70
[   22.061497]  [<ffffffff814a34aa>] ip6_finish_output+0x96/0x9d
[   22.062471]  [<ffffffff814a3531>] ip6_output+0x80/0xe9
[   22.063327]  [<ffffffff81081976>] ? __lock_is_held+0x38/0x50
[   22.064222]  [<ffffffff81085ff7>] ? lock_is_held+0x69/0x70
[   22.065112]  [<ffffffff814a0503>] dst_output+0x2b/0x30
[   22.065939]  [<ffffffff814a140c>] ip6_xmit+0x322/0x3dd
[   22.066759]  [<ffffffff81081976>] ? __lock_is_held+0x38/0x50
[   22.067669]  [<ffffffff814cdcff>] inet6_csk_xmit+0xe8/0x118
[   22.068569]  [<ffffffff814586c7>] tcp_transmit_skb+0x696/0x6c5
[   22.069491]  [<ffffffff81458f16>] tcp_write_xmit+0x820/0xb1c
[   22.070387]  [<ffffffff8112e82a>] ? __might_fault+0xa0/0xa2
[   22.071272]  [<ffffffff8128dba0>] ? copy_from_iter+0x1cb/0x296
[   22.072194]  [<ffffffff8145948c>] __tcp_push_pending_frames+0x2b/0x67
[   22.073229]  [<ffffffff8144bc00>] tcp_push+0x94/0xff
[   22.074020]  [<ffffffff8144e707>] tcp_sendmsg+0x775/0x83a
[   22.074851]  [<ffffffff81472dbf>] inet_sendmsg+0x35/0x5c
[   22.075663]  [<ffffffff813edaa0>] sock_sendmsg_nosec+0x12/0x1d
[   22.076555]  [<ffffffff813edb2b>] sock_write_iter+0x75/0x8d
[   22.077399]  [<ffffffff8115a127>] __vfs_write+0x77/0xa0
[   22.078186]  [<ffffffff8115ad1d>] vfs_write+0xa2/0xc6
[   22.078948]  [<ffffffff8115b918>] SyS_write+0x4b/0x79
[   22.079713]  [<ffffffff814f7b3c>] entry_SYSCALL_64_fastpath+0x1f/0xbd
[   22.080694]  [<ffffffff81081420>] ? trace_hardirqs_off_caller+0xbc/0x122
[   22.081688] ---[ end trace 6df0ce86bcf51c7f ]---
[   22.082375]
[   22.082615] ======================
[   22.083126] [chain_key collision ]
[   22.083646] 4.7.0-rc2+ #310 Tainted: G        W
[   22.084410] ----------------------
[   22.084927] sshd/1401: Hash chain already cached but the contents 
don't match!
[   22.086010] Held locks:depth: 6
[   22.086509]  class_idx:1255 -> chain_key:00000000000004e7 
(sk_lock-AF_INET6){+.+.+.}, at: [<ffffffff8144a84c>] lock_sock+0xb/0xd
[   22.088253]  class_idx:26 -> chain_key:00000000009ce01a 
(rcu_read_lock){......}, at: [<ffffffff814cd8a2>] rcu_read_lock+0x0/0x68
[   22.089999]  class_idx:898 -> chain_key:000000139c034382 
(rcu_read_lock_bh){......}, at: [<ffffffff814a031b>] 
rcu_lock_acquire+0x0/0x20
[   22.091811]  class_idx:898 -> chain_key:0002738068704382 
(rcu_read_lock_bh){......}, at: [<ffffffff81400393>] 
rcu_lock_acquire+0x0/0x20
[   22.093639]  class_idx:1223 -> chain_key:4e700d0e087044c7 
(dev->qdisc_running_key ?: &qdisc_running_key){+.....}, at: 
[<ffffffff81408a7e>] __dev_queue_xmit+0x40c/0x72d
[   22.095824]  class_idx:1224 -> chain_key:01a1c10e0898ed06 
(_xmit_ETHER#2){+.-...}, at: [<ffffffff814287e6>] sch_direct_xmit+0x6f/0x167
[   22.097616] Locks in cached chain:depth: 6
[   22.098197]  class_idx:1248 -> chain_key:00000000000004e0 
(((&ndev->rs_timer))){+.-...}
[   22.099345]  class_idx:26 -> chain_key:00000000009c001a 
(rcu_read_lock){......}
[   22.100419]  class_idx:898 -> chain_key:0000001380034382 
(rcu_read_lock_bh){......}
[   22.101535]  class_idx:898 -> chain_key:0002700068704382 
(rcu_read_lock_bh){......}
[   22.102656]  class_idx:1223 -> chain_key:4e000d0e087044c7 
(dev->qdisc_running_key ?: &qdisc_running_key){+.....}
[   22.104095]  class_idx:1222 -> chain_key:01a1c10e0898ed06 
(&(&list->lock)->rlock#3){+.-...}
[   22.105325]
[   22.105325] stack backtrace:
[   22.105917] CPU: 2 PID: 1401 Comm: sshd Tainted: G        W 
4.7.0-rc2+ #310
[   22.106930] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), 
BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
[   22.108258]  0000000000000000 ffff88013a06b6d8 ffffffff8127e51e 
00000000000004c5
[   22.109295]  ffffffff81decea0 ffff88013a06b720 ffffffff81083212 
0000000400000002
[   22.110312]  ffff8800b9702f18 ffffffff81decea0 0000000000005088 
01a1c10e0898ed06
[   22.111339] Call Trace:
[   22.111666]  [<ffffffff8127e51e>] dump_stack+0x81/0xb6
[   22.112356]  [<ffffffff81083212>] print_collision+0x203/0x210
[   22.113103]  [<ffffffff8108407d>] validate_chain.isra.37+0x4eb/0xa5b
[   22.113929]  [<ffffffff810398f6>] ? kvm_clock_read+0x25/0x2e
[   22.114667]  [<ffffffff81039913>] ? kvm_sched_clock_read+0x9/0x12
[   22.115458]  [<ffffffff8101c65c>] ? paravirt_sched_clock+0x9/0xd
[   22.116233]  [<ffffffff8101ccc3>] ? sched_clock+0x9/0xb
[   22.116920]  [<ffffffff810853b7>] __lock_acquire+0x5e4/0x690
[   22.117652]  [<ffffffff810853b7>] ? __lock_acquire+0x5e4/0x690
[   22.118732]  [<ffffffff81085a32>] lock_acquire+0x140/0x1d8
[   22.119481]  [<ffffffff814287e6>] ? sch_direct_xmit+0x6f/0x167
[   22.120252]  [<ffffffff814f7066>] _raw_spin_lock+0x2f/0x65
[   22.120981]  [<ffffffff814287e6>] ? sch_direct_xmit+0x6f/0x167
[   22.121741]  [<ffffffff814287e6>] sch_direct_xmit+0x6f/0x167
[   22.122453]  [<ffffffff81408aad>] __dev_queue_xmit+0x43b/0x72d
[   22.123188]  [<ffffffff814a0d1b>] ? ip6_finish_output2+0x311/0x3ee
[   22.123959]  [<ffffffff81408daa>] dev_queue_xmit+0xb/0xd
[   22.124633]  [<ffffffff814a0d96>] ip6_finish_output2+0x38c/0x3ee
[   22.125385]  [<ffffffff81081976>] ? __lock_is_held+0x38/0x50
[   22.126098]  [<ffffffff81085ff7>] ? lock_is_held+0x69/0x70
[   22.126786]  [<ffffffff814a34aa>] ip6_finish_output+0x96/0x9d
[   22.127503]  [<ffffffff814a3531>] ip6_output+0x80/0xe9
[   22.128143]  [<ffffffff81081976>] ? __lock_is_held+0x38/0x50
[   22.128867]  [<ffffffff81085ff7>] ? lock_is_held+0x69/0x70
[   22.129551]  [<ffffffff814a0503>] dst_output+0x2b/0x30
[   22.130191]  [<ffffffff814a140c>] ip6_xmit+0x322/0x3dd
[   22.130837]  [<ffffffff81081976>] ? __lock_is_held+0x38/0x50
[   22.131541]  [<ffffffff814cdcff>] inet6_csk_xmit+0xe8/0x118
[   22.132238]  [<ffffffff814586c7>] tcp_transmit_skb+0x696/0x6c5
[   22.132971]  [<ffffffff81458f16>] tcp_write_xmit+0x820/0xb1c
[   22.133686]  [<ffffffff8112e82a>] ? __might_fault+0xa0/0xa2
[   22.134386]  [<ffffffff8128dba0>] ? copy_from_iter+0x1cb/0x296
[   22.135116]  [<ffffffff8145948c>] __tcp_push_pending_frames+0x2b/0x67
[   22.135924]  [<ffffffff8144bc00>] tcp_push+0x94/0xff
[   22.136568]  [<ffffffff8144e707>] tcp_sendmsg+0x775/0x83a
[   22.137239]  [<ffffffff81472dbf>] inet_sendmsg+0x35/0x5c
[   22.137914]  [<ffffffff813edaa0>] sock_sendmsg_nosec+0x12/0x1d
[   22.138643]  [<ffffffff813edb2b>] sock_write_iter+0x75/0x8d
[   22.139352]  [<ffffffff8115a127>] __vfs_write+0x77/0xa0
[   22.140012]  [<ffffffff8115ad1d>] vfs_write+0xa2/0xc6
[   22.140668]  [<ffffffff8115b918>] SyS_write+0x4b/0x79
[   22.141307]  [<ffffffff814f7b3c>] entry_SYSCALL_64_fastpath+0x1f/0xbd
[   22.142109]  [<ffffffff81081420>] ? trace_hardirqs_off_caller+0xbc/0x122
