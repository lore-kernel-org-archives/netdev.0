From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Netfilter: BUG: unable to handle kernel paging request, RIP:
 =?UTF-8?Q?physdev=5Fmt+=30xd=36/=30x=31=36=30?=
Date: Sun, 13 Sep 2015 13:34:43 +0200
Message-ID: <1620a50057d1e8aadafe27c74ee42d93@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
To: netdev@vger.kernel.org, netfilter@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vserver.eikelenboom.it ([84.200.39.61]:48813 "EHLO
	smtp.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751516AbbIMLm7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Sep 2015 07:42:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using a linux-4.3-rc1 kernel i encountered the splat below:

addr2line gives:
/usr/src/new/linux-linus/include/linux/netfilter/x_tables.h:350

which is:

/*
  * This helper is performance critical and must be inlined
  */
static inline unsigned long ifname_compare_aligned(const char *_a,
                                                    const char *_b,
                                                    const char *_mask)
{
         const unsigned long *a = (const unsigned long *)_a;
         const unsigned long *b = (const unsigned long *)_b;
         const unsigned long *mask = (const unsigned long *)_mask;
         unsigned long ret;

         ret = (a[0] ^ b[0]) & mask[0];
         if (IFNAMSIZ > sizeof(unsigned long))
HERE -->        ret |= (a[1] ^ b[1]) & mask[1];
         if (IFNAMSIZ > 2 * sizeof(unsigned long))
                 ret |= (a[2] ^ b[2]) & mask[2];
         if (IFNAMSIZ > 3 * sizeof(unsigned long))
                 ret |= (a[3] ^ b[3]) & mask[3];
         BUILD_BUG_ON(IFNAMSIZ > 4 * sizeof(unsigned long));
         return ret;
}

--
Sander

[  290.200642] BUG: unable to handle kernel paging request at 
000000000484195d
[  290.211702] IP: [<ffffffff819bc3e6>] physdev_mt+0xd6/0x160
[  290.222716] PGD 591ea067 PUD 5772a067 PMD 0
[  290.233389] Oops: 0000 [#1] SMP
[  290.244017] Modules linked in:
[  290.254338] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 
4.3.0-rc1-20150913-linus-doflr+ #1
[  290.264862] Hardware name: MSI MS-7640/890FXA-GD70 (MS-7640)  , BIOS 
V1.8B1 09/13/2010
[  290.275319] task: ffffffff8221a580 ti: ffffffff82200000 task.ti: 
ffffffff82200000
[  290.285909] RIP: e030:[<ffffffff819bc3e6>]  [<ffffffff819bc3e6>] 
physdev_mt+0xd6/0x160
[  290.296374] RSP: e02b:ffff88005f6037b0  EFLAGS: 00010206
[  290.306758] RAX: 00302e3531666976 RBX: ffff880000414d00 RCX: 
0000000000000000
[  290.310800] xen_bridge: port 13(vif13.0) entered forwarding state
[  290.327013] RDX: ffffc90003c0c4f0 RSI: ffff88003bfba000 RDI: 
0000000000000002
[  290.337148] RBP: ffff88005f6037b0 R08: 0000000004841955 R09: 
ffff880057bf2501
[  290.347361] R10: 0000000000000000 R11: 0000000000000000 R12: 
ffff880004b4a24e
[  290.357395] R13: ffff8800044bc000 R14: ffffc90003c0c460 R15: 
ffffc90003c0c4d0
[  290.367437] FS:  00007ff6d0ed3700(0000) GS:ffff88005f600000(0000) 
knlGS:0000000000000000
[  290.377264] CS:  e033 DS: 0000 ES: 0000 CR0: 000000008005003b
[  290.386939] CR2: 000000000484195d CR3: 0000000048ba6000 CR4: 
0000000000000660
[  290.396564] Stack:
[  290.406066]  ffff88005f603848 ffffffff81a4e6c0 ffffc90003c09008 
000000008110df32
[  290.415683]  ffff8800559ddc00 ffff880004d50000 ffffc90003c09040 
0000000000000001
[  290.425294]  ffffffff822f7c40 ffffc90003c0c4f0 ffff8800044bc000 
ffff880004d50000
[  290.434788] Call Trace:
[  290.444034]  <IRQ>
[  290.444088]  [<ffffffff81a4e6c0>] ipt_do_table+0x210/0x390
[  290.461951]  [<ffffffff81a510ae>] iptable_filter_hook+0x2e/0x70
[  290.470756]  [<ffffffff8199279c>] nf_iterate+0x4c/0x80
[  290.479587]  [<ffffffff81992834>] nf_hook_slow+0x64/0xc0
[  290.488341]  [<ffffffff81a06779>] ip_forward+0x369/0x3c0
[  290.496927]  [<ffffffff81a06380>] ? ip_frag_mem+0x40/0x40
[  290.505365]  [<ffffffff81a04961>] ip_rcv_finish+0x101/0x330
[  290.513480]  [<ffffffff81a05001>] ip_rcv+0x291/0x390
[  290.521562]  [<ffffffff81a04860>] ? 
ip_local_deliver_finish+0x120/0x120
[  290.529509]  [<ffffffff819619f0>] 
__netif_receive_skb_core+0x2a0/0x960
[  290.537381]  [<ffffffff8199ea19>] ? tcp_error+0xa9/0x1e0
[  290.545287]  [<ffffffff810cbdf6>] ? __local_bh_enable_ip+0x26/0x90
[  290.553065]  [<ffffffff81963fa1>] __netif_receive_skb+0x11/0x70
[  290.560671]  [<ffffffff8196401e>] 
netif_receive_skb_internal+0x1e/0x80
[  290.568025]  [<ffffffff81992834>] ? nf_hook_slow+0x64/0xc0
[  290.575341]  [<ffffffff8196408c>] netif_receive_skb_sk+0xc/0x10
[  290.582655]  [<ffffffff81a62caa>] br_handle_frame_finish+0x17a/0x4b0
[  290.589910]  [<ffffffff81a4ba1a>] ? nf_nat_ipv4_fn+0x19a/0x1e0
[  290.597120]  [<ffffffff81a51370>] ? iptable_nat_ipv4_fn+0x20/0x20
[  290.604316]  [<ffffffff81964080>] ? 
netif_receive_skb_internal+0x80/0x80
[  290.611375]  [<ffffffff81a6d0f6>] 
br_nf_pre_routing_finish+0x166/0x340
[  290.618246]  [<ffffffff81a62b30>] ? br_handle_local_finish+0x50/0x50
[  290.624925]  [<ffffffff81a6d65b>] br_nf_pre_routing+0x29b/0x370
[  290.631446]  [<ffffffff81a6cf90>] ? br_nf_forward_ip+0x3d0/0x3d0
[  290.637991]  [<ffffffff8199279c>] nf_iterate+0x4c/0x80
[  290.644328]  [<ffffffff81992834>] nf_hook_slow+0x64/0xc0
[  290.650380]  [<ffffffff81a63179>] br_handle_frame+0x199/0x280
[  290.656432]  [<ffffffff81a62b30>] ? br_handle_local_finish+0x50/0x50
[  290.662593]  [<ffffffff81a62fe0>] ? 
br_handle_frame_finish+0x4b0/0x4b0
[  290.668626]  [<ffffffff8196187b>] 
__netif_receive_skb_core+0x12b/0x960
[  290.674643]  [<ffffffff810fd401>] ? 
__raw_callee_save___pv_queued_spin_unlock+0x11/0x20
[  290.680797]  [<ffffffff8195cf31>] ? __skb_flow_dissect+0x5f1/0x8f0
[  290.686902]  [<ffffffff81963fa1>] __netif_receive_skb+0x11/0x70
[  290.693046]  [<ffffffff8196401e>] 
netif_receive_skb_internal+0x1e/0x80
[  290.699031]  [<ffffffff8196408c>] netif_receive_skb_sk+0xc/0x10
[  290.704880]  [<ffffffff81732dfa>] xenvif_tx_action+0x69a/0x830
[  290.710609]  [<ffffffff81963fa1>] ? __netif_receive_skb+0x11/0x70
[  290.716365]  [<ffffffff81735349>] xenvif_poll+0x29/0x70
[  290.722241]  [<ffffffff81965357>] net_rx_action+0x1f7/0x300
[  290.727940]  [<ffffffff810cbbf3>] __do_softirq+0x103/0x210
[  290.733564]  [<ffffffff810cbefb>] irq_exit+0x4b/0xa0
[  290.739094]  [<ffffffff814d5b40>] xen_evtchn_do_upcall+0x30/0x40
[  290.744626]  [<ffffffff81ad78fe>] 
xen_do_hypervisor_callback+0x1e/0x40
[  290.750062]  <EOI>
[  290.750114]  [<ffffffff810013aa>] ? xen_hypercall_sched_op+0xa/0x20
[  290.760785]  [<ffffffff810013aa>] ? xen_hypercall_sched_op+0xa/0x20
[  290.766024]  [<ffffffff81009240>] ? xen_safe_halt+0x10/0x20
[  290.771254]  [<ffffffff810198a3>] ? default_idle+0x13/0x20
[  290.776525]  [<ffffffff81019dda>] ? arch_cpu_idle+0xa/0x10
[  290.781750]  [<ffffffff810fae2e>] ? default_idle_call+0x2e/0x50
[  290.786833]  [<ffffffff810fb0c2>] ? cpu_startup_entry+0x272/0x2e0
[  290.791911]  [<ffffffff81acea77>] ? rest_init+0x77/0x80
[  290.796864]  [<ffffffff82314f43>] ? start_kernel+0x438/0x445
[  290.801857]  [<ffffffff823144ef>] ? 
x86_64_start_reservations+0x2a/0x2c
[  290.806726]  [<ffffffff82317fef>] ? xen_start_kernel+0x555/0x561
[  290.811611] Code: 0f 94 c6 31 c0 83 e1 01 83 f1 01 40 38 ce 75 8a 83 
e7 02 b8 01 00 00 00 74 80 4d 85 c0 0f 84 8e 00 00 00 48 8b 4a 28 48 8b 
42 20 <49> 33 48 08 49 33 00 48 23 4a 38 48 23 42 30 5d 48 09 c1 0f b6
[  290.822337] RIP  [<ffffffff819bc3e6>] physdev_mt+0xd6/0x160
[  290.827562]  RSP <ffff88005f6037b0>
[  290.832752] CR2: 000000000484195d
[  290.837934] ---[ end trace 82d08e819d389b33 ]---
[  290.843177] Kernel panic - not syncing: Fatal exception in interrupt
[  290.848508] Kernel Offset: disabled
(XEN) [2015-09-13 11:22:50.171] Hardware Dom0 crashed: rebooting machine 
in 5 seconds.
