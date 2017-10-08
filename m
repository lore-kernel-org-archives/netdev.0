From: Tariq Toukan <tariqt@mellanox.com>
Subject: Re: [PATCH 41/47] netfilter: convert hook list to an array
Date: Sun, 8 Oct 2017 18:07:51 +0300
Message-ID: <81603cbd-603d-1d93-a29a-1174fc826dec@mellanox.com>
References: <1504478574-13281-1-git-send-email-pablo@netfilter.org>
 <1504478574-13281-6-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
        netfilter-devel@vger.kernel.org, Aaron Conole <aconole@bytheb.org>,
        Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0044.outbound.protection.outlook.com ([104.47.1.44]:62368
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751856AbdJHPH7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 8 Oct 2017 11:07:59 -0400
In-Reply-To: <1504478574-13281-6-git-send-email-pablo@netfilter.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04/09/2017 1:42 AM, Pablo Neira Ayuso wrote:
> From: Aaron Conole <aconole@bytheb.org>
> 
> This converts the storage and layout of netfilter hook entries from a
> linked list to an array.  After this commit, hook entries will be
> stored adjacent in memory.  The next pointer is no longer required.
> 
> The ops pointers are stored at the end of the array as they are only
> used in the register/unregister path and in the legacy br_netfilter code.
> 
> nf_unregister_net_hooks() is slower than needed as it just calls
> nf_unregister_net_hook in a loop (i.e. at least n synchronize_net()
> calls), this will be addressed in followup patch.
> 
> Test setup:
>   - ixgbe 10gbit
>   - netperf UDP_STREAM, 64 byte packets
>   - 5 hooks: (raw + mangle prerouting, mangle+filter input, inet filter):
> empty mangle and raw prerouting, mangle and filter input hooks:
> 353.9
> this patch:
> 364.2
> 
> Signed-off-by: Aaron Conole <aconole@bytheb.org>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> ---

Hi,

We experience a regression in server with iommu enabled.
After installing kernel and rebooting the server, it crashes during boot.
Please see trace below.

Bisecting points to this patch.

Any idea what's wrong?

Regards,
Tariq Toukan

[   25.590816] RIP: 0010:_raw_read_lock_bh+0x15/0x40
[   25.596160] RSP: 0018:ffffc90007db77a0 EFLAGS: 00010286
[   25.602089] RAX: 0000000000000100 RBX: 0000000000000003 RCX: 
0000000000000000
[   25.610152] RDX: 0000000000000000 RSI: ffffc90007db7898 RDI: 
000000000000003c
[   25.618470] RBP: ffffc90007db7840 R08: 0000000000000001 R09: 
0000000087c10eef
[   25.626786] R10: ffff88180f21f040 R11: ffffea005feeaf00 R12: 
0000000000000000
[   25.635103] R13: ffffc90007db7898 R14: ffff8817fbabdc00 R15: 
ffff8817fbabdc00
[   25.643421] FS:  00007fcdb7771740(0000) GS:ffff88180f200000(0000) 
knlGS:0000000000000000
[   25.653056] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   25.659818] CR2: 000000000000003c CR3: 0000001809ae0001 CR4: 
00000000001606e0
[   25.668136] Call Trace:
[   25.671215]  ? ebt_do_table+0x3d/0x6e8 [ebtables]
[   25.676817]  ebt_nat_out+0x1f/0x30 [ebtable_nat]
[   25.682326]  nf_hook_slow+0x3c/0xb0
[   25.686576]  __br_forward+0xb1/0x1b0 [bridge]
[   25.691786]  ? br_dev_queue_push_xmit+0x170/0x170 [bridge]
[   25.704333]  br_flood+0x130/0x1b0 [bridge]
[   25.709254]  br_dev_xmit+0x1e5/0x2a0 [bridge]
[   25.714468]  dev_hard_start_xmit+0xa1/0x210
[   25.719485]  __dev_queue_xmit+0x4f6/0x610
[   25.724304]  dev_queue_xmit+0x10/0x20
[   25.728739]  ip_finish_output2+0x233/0x320
[   25.733656]  ip_finish_output+0x12a/0x1d0
[   25.738474]  ? netif_rx_ni+0x33/0x80
[   25.742805]  ip_mc_output+0x84/0x250
[   25.747140]  ip_local_out+0x35/0x40
[   25.751377]  ip_send_skb+0x19/0x40
[   25.755583]  udp_send_skb+0x172/0x280
[   25.760013]  udp_sendmsg+0x2c0/0xa30
[   25.764348]  ? ip_reply_glue_bits+0x50/0x50
[   25.769366]  ? import_iovec+0x2c/0xc0
[   25.773801]  inet_sendmsg+0x31/0xb0
[   25.778042]  sock_sendmsg+0x38/0x50
[   25.782276]  ___sys_sendmsg+0x25c/0x270
[   25.786904]  ? file_update_time+0x3a/0xf0
[   25.791727]  ? __wake_up_sync_key+0x50/0x60
[   25.796741]  ? pipe_write+0x3cc/0x420
[   25.801175]  ? __vfs_write+0xd0/0x130
[   25.805608]  __sys_sendmsg+0x45/0x80
[   25.809938]  SyS_sendmsg+0x12/0x20
[   25.814077]  entry_SYSCALL_64_fastpath+0x1a/0xa5
[   25.819577] RIP: 0033:0x7fcdb64ac7a0
[   25.823908] RSP: 002b:00007ffe2b98cb98 EFLAGS: 00000246 ORIG_RAX: 
000000000000002e
[   25.832961] RAX: ffffffffffffffda RBX: 00007ffe2b98c630 RCX: 
00007fcdb64ac7a0
[   25.841270] RDX: 0000000000000000 RSI: 00007ffe2b98cc50 RDI: 
000000000000000c
[   25.849583] RBP: 00007fcdb69018f8 R08: 00007ffe2b98cbc3 R09: 
0000000000000004
[   25.857901] R10: 0000000000000019 R11: 0000000000000246 R12: 
0000000000000000
[   25.866213] R13: 0000000000000000 R14: 00007ffe2b98c6c0 R15: 
00007ffe2b98c6e0
[   25.874520] Code: 55 48 89 e5 e8 bd 74 82 ff 5d c3 66 66 2e 0f 1f 84 
00 00 00 00 00 0f 1f 44 00 00 65 81 05 68 78 74 7e 00 02 00 00 b8 00 01 
00 00 <f0> 0f c1 07 8d b0 00 01 00 00 40 84
[   25.896497] RIP: _raw_read_lock_bh+0x15/0x40 RSP: ffffc90007db77a0
[   25.903744] CR2: 000000000000003c
[   25.907808] ---[ end trace 4f824a5c467b1872 ]---
[   25.907811] BUG: unable to handle kernel NULL pointer dereference at 
000000000000003c
[   25.907828] IP: _raw_read_lock_bh+0x15/0x40
[   25.907830] PGD 0 P4D 0
[   25.907834] Oops: 0002 [#2] SMP
[   25.907836] Modules linked in: ebtable_nat(+) ebtables ib_ucm mlx4_en 
mlx4_ib rpcrdma mlx4_core rdma_ucm ib_uverbs ib_iser ib_umad rdma_cm 
ib_ipoib iw_cm ib_cm mlx5_ib bridge stp llc sge
[   25.907895] CPU: 12 PID: 0 Comm: swapper/12 Tainted: G      D 
4.13.0-for-linust-perf-2017-09-10_06-48-01-64 #1
[   25.907896] Hardware name: Dell Inc. PowerEdge R720/0HJK12, BIOS 
2.2.3 05/20/2014
[   25.907898] task: ffff880c0c2f8000 task.stack: ffffc90006318000
[   25.907901] RIP: 0010:_raw_read_lock_bh+0x15/0x40
[   25.907902] RSP: 0018:ffff880c0f9839d0 EFLAGS: 00010286
[   25.907904] RAX: 0000000000000100 RBX: 0000000000000003 RCX: 
0000000000000000
[   25.907905] RDX: 0000000000000000 RSI: ffff880c0f983ac8 RDI: 
000000000000003c
[   25.907906] RBP: ffff880c0f983a70 R08: 0000000000000001 R09: 
0000000000000000
[   25.907907] R10: 0000000000000000 R11: 0000000000000000 R12: 
0000000000000000
[   25.907909] R13: ffff880c0f983ac8 R14: ffff880bfcfdda00 R15: 
ffff880bfcfdda00
[   25.907911] FS:  0000000000000000(0000) GS:ffff880c0f980000(0000) 
knlGS:0000000000000000
[   25.907912] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   25.907913] CR2: 000000000000003c CR3: 0000001809a5e001 CR4: 
00000000001606e0
[   25.907915] Call Trace:
[   25.907918]  <IRQ>
[   25.907925]  ? ebt_do_table+0x3d/0x6e8 [ebtables]
[   25.907929]  ? lock_timer_base+0x7d/0xa0
[   25.907932]  ? mod_timer+0xa9/0x2c0
[   25.907937]  ebt_nat_out+0x1f/0x30 [ebtable_nat]
[   25.907946]  nf_hook_slow+0x3c/0xb0
[   25.907958]  __br_forward+0xb1/0x1b0 [bridge]
[   25.907966]  ? br_dev_queue_push_xmit+0x170/0x170 [bridge]
[   25.907972]  br_flood+0x130/0x1b0 [bridge]
[   25.907979]  br_dev_xmit+0x1e5/0x2a0 [bridge]
[   25.907987]  dev_hard_start_xmit+0xa1/0x210
[   25.907990]  __dev_queue_xmit+0x4f6/0x610
[   25.907993]  ? _raw_read_unlock_bh+0x20/0x30
[   25.907996]  dev_queue_xmit+0x10/0x20
[   25.908001]  ip6_finish_output2+0x3b5/0x4c0
[   25.908005]  ip6_finish_output+0xa5/0x100
[   25.908007]  ip6_output+0x5b/0xf0
[   25.908012]  NF_HOOK.constprop.43+0x30/0x90
[   25.908015]  ? icmp6_dst_alloc+0xd2/0x110
[   25.908018]  mld_sendpack+0x168/0x220
[   25.908021]  mld_ifc_timer_expire+0x17f/0x290
[   25.908024]  ? mld_dad_timer_expire+0x60/0x60
[   25.908026]  call_timer_fn+0x35/0x140
[   25.908028]  run_timer_softirq+0x1ce/0x410
[   25.908031]  ? timerqueue_add+0x59/0x90
[   25.908036]  ? sched_clock+0x9/0x10
[   25.908039]  ? sched_clock_cpu+0x11/0xb0
[   25.908042]  __do_softirq+0xd1/0x27f
[   25.908046]  irq_exit+0xb5/0xc0
[   25.908048]  smp_apic_timer_interrupt+0x69/0x130
[   25.908050]  apic_timer_interrupt+0x93/0xa0
[   25.908052]  </IRQ>
[   25.908056] RIP: 0010:cpuidle_enter_state+0xe9/0x280
[   25.908057] RSP: 0018:ffffc9000631be88 EFLAGS: 00000246 ORIG_RAX: 
ffffffffffffff10
[   25.908059] RAX: ffff880c0f99bdc0 RBX: ffffe8f400180270 RCX: 
000000000000001f
[   25.908060] RDX: 0000000000000000 RSI: ffff7761f8923d16 RDI: 
0000000000000000
[   25.908061] RBP: ffffc9000631bec0 R08: 00000000000002a1 R09: 
0000000000000390
[   25.908062] R10: 000000000000037e R11: 0000000000000018 R12: 
0000000000000004
[   25.908063] R13: 000000000000000c R14: ffffe8f400180270 R15: 
00000005f7b4d9b4
[   25.908068]  ? cpuidle_enter_state+0xc5/0x280
[   25.908071]  cpuidle_enter+0x17/0x20
[   25.908074]  call_cpuidle+0x23/0x40
[   25.908077]  do_idle+0x172/0x1e0
[   25.908079]  cpu_startup_entry+0x1d/0x30
[   25.908084]  start_secondary+0x103/0x130
[   25.908087]  secondary_startup_64+0xa5/0xa5
[   25.908089] Code: 55 48 89 e5 e8 bd 74 82 ff 5d c3 66 66 2e 0f 1f 84 
00 00 00 00 00 0f 1f 44 00 00 65 81 05 68 78 74 7e 00 02 00 00 b8 00 01 
00 00 <f0> 0f c1 07 8d b0 00 01 00 00 40 84
[   25.908124] RIP: _raw_read_lock_bh+0x15/0x40 RSP: ffff880c0f9839d0
[   25.908124] CR2: 000000000000003c
[   25.908154] ---[ end trace 4f824a5c467b1873 ]---
[   25.913089] Kernel panic - not syncing: Fatal exception in interrupt
[   26.964216] Shutting down cpus with NMI
[   26.968841] Kernel Offset: disabled
[   26.975644] ---[ end Kernel panic - not syncing: Fatal exception in 
interrupt
