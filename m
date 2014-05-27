From: Jack Wang <xjtuwjp-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [BUG]GPF in  skb_release_data+0xa8/0x100
Date: Tue, 27 May 2014 12:09:55 +0200
Message-ID: <53846473.2040004@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

We hit GPF in skb_release_data+0xa8/0x100 below in our production:

(gdb) list *skb_release_data+0xa8
0xffffffff81528118 is in skb_release_data (net/core/skbuff.c:399).
394			 */
395			if (skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) {
396				struct ubuf_info *uarg;
397	
398				uarg = skb_shinfo(skb)->destructor_arg;
399				if (uarg->callback)
400					uarg->callback(uarg);
401			}
402	
403			if (skb_has_frag_list(skb))
(gdb)

IMHO, something corrupted destructor_arg probably. But I have no idea,
what could the reason, anyone could share some input?

Note: I also cc rdma mail list as it's ipoib/srp related.

Thanks,

Jack

May 22 20:11:40 pserver204 kernel: [8594022.123439] AMD-Vi: Event logged
[IO_PAGE_FAULT device=03:00.0 domain=0x0012 address=0x0000000020d87f40
flags=0x0070]
May 22 20:11:40 pserver204 kernel: [8594022.183821] scsi host9: Null
scmnd for RSP w/tag 0000000000000004
May 22 20:11:40 pserver204 kernel: [8594022.261820] general protection
fault: 0000 [#1] SMP
May 22 20:11:40 pserver204 kernel: [8594022.261939] CPU 0
May 22 20:11:40 pserver204 kernel: [8594022.261949] Modules linked in:
nf_conntrack_netlink nfnetlink xt_hashlimit fuse cls_u32 sch_sfq sch_htb
ib_ipoib bridge stp llc nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter
ip6_tables raid1 md_mod dm_round_robin sd_mod crc_t10dif ib_srp
scsi_transport_srp scsi_tgt xt_ETHOIP6(O) x_tables vhost_net(O) macvtap
macvlan tun(O) nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 rdma_ucm
rdma_cm iw_cm ib_addr ib_cm ib_sa ib_uverbs ib_umad ib_qib mlx4_ib
ib_mthca ib_mad ib_core sg dm_multipath scsi_dh kvm_amd kvm powernow_k8
mperf crc32c_intel tpm_tis microcode tpm tpm_bios psmouse serio_raw
evdev amd64_edac_mod usb_storage edac_core edac_mce_amd i2c_piix4 ahci
libahci libata scsi_mod button processor thermal_sys mlx4_core [last
unloaded: ib_ipoib]
May 22 20:11:40 pserver204 kernel: [8594022.263491]
May 22 20:11:40 pserver204 kernel: [8594022.263587] Pid: 0, comm:
swapper/0 Tainted: G           O 3.4.71-3-pserver #1 Supermicro H8QG6/H8QG6
May 22 20:11:40 pserver204 kernel: [8594022.265532] RIP:
0010:[<ffffffff8153df98>]  [<ffffffff8153df98>] skb_release_data+0xa8/0x100
May 22 20:11:40 pserver204 kernel: [8594022.265738] RSP:
0018:ffff880807c03bc0  EFLAGS: 00010282
May 22 20:11:40 pserver204 kernel: [8594022.265846] RAX:
0000000000000000 RBX: ffff882f5c657800 RCX: ffff88025b056000
May 22 20:11:40 pserver204 kernel: [8594022.266042] RDX:
ffff88025b057ec0 RSI: 0000000000000064 RDI: cf39635277a7dad0
May 22 20:11:40 pserver204 kernel: [8594022.266236] RBP:
ffff882f5c657800 R08: ffff8801f08803c0 R09: ffff880807c03b64
May 22 20:11:40 pserver204 kernel: [8594022.266430] R10:
0000000000000004 R11: 0000000000000000 R12: ffffffff81aab2f0
May 22 20:11:40 pserver204 kernel: [8594022.266625] R13:
ffffffff81a76e80 R14: 0000000000000000 R15: ffff882f5c657828
May 22 20:11:40 pserver204 kernel: [8594022.266826] FS:
00007f725d992700(0000) GS:ffff880807c00000(0000) knlGS:0000000000000000
May 22 20:11:40 pserver204 kernel: [8594022.267029] CS:  0010 DS: 0000
ES: 0000 CR0: 000000008005003b
May 22 20:11:40 pserver204 kernel: [8594022.267138] CR2:
ffffffffff600400 CR3: 0000002803d4a000 CR4: 00000000000407f0
May 22 20:11:40 pserver204 kernel: [8594022.267333] DR0:
0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
May 22 20:11:40 pserver204 kernel: [8594022.267532] DR3:
0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
May 22 20:11:40 pserver204 kernel: [8594022.267739] Process swapper/0
(pid: 0, threadinfo ffffffff81a00000, task ffffffff81a13020)
May 22 20:11:40 pserver204 kernel: [8594022.267946] Stack:
May 22 20:11:40 pserver204 kernel: [8594022.268047]  0000000000000011
ffff882f5c657800 0000000000000011 ffffffff8153e001
May 22 20:11:40 pserver204 kernel: [8594022.268254]  ffff882f5c657800
ffffffff815f33d2 ffffffff81aab2f0 ffff880c7cc20000
May 22 20:11:40 pserver204 kernel: [8594022.268469]  0000000000000000
ffffffff8157443f ffffffff815db3e0 ffff882f5c657800
May 22 20:11:40 pserver204 kernel: [8594022.268679] Call Trace:
May 22 20:11:40 pserver204 kernel: [8594022.268778]  <IRQ>
May 22 20:11:40 pserver204 kernel: [8594022.269023]
[<ffffffff8153e001>] ? __kfree_skb+0x11/0x90
May 22 20:11:40 pserver204 kernel: [8594022.269136]
[<ffffffff815f33d2>] ? __udp6_lib_rcv+0x5c2/0x6b0
May 22 20:11:40 pserver204 kernel: [8594022.269249]
[<ffffffff8157443f>] ? nf_hook_slow+0x6f/0x150
May 22 20:11:40 pserver204 kernel: [8594022.269362]
[<ffffffff815db3e0>] ? ipv6_rcv+0x450/0x450
May 22 20:11:40 pserver204 kernel: [8594022.269476]
[<ffffffff815db542>] ? ip6_input_finish+0x162/0x380
May 22 20:11:40 pserver204 kernel: [8594022.269592]
[<ffffffff8154a784>] ? __netif_receive_skb+0x214/0x5f0
May 22 20:11:40 pserver204 kernel: [8594022.269710]
[<ffffffff81009105>] ? read_tsc+0x5/0x20
May 22 20:11:40 pserver204 kernel: [8594022.269821]
[<ffffffff8154ad74>] ? netif_receive_skb+0x24/0x80
May 22 20:11:40 pserver204 kernel: [8594022.269937]
[<ffffffffa033c87b>] ? ipoib_cm_handle_rx_wc+0x1ab/0x6a0 [ib_ipoib]
May 22 20:11:40 pserver204 kernel: [8594022.270148]
[<ffffffffa01e1c5f>] ? mlx4_ib_free_srq_wqe+0x1f/0x60 [mlx4_ib]
May 22 20:11:40 pserver204 kernel: [8594022.270353]
[<ffffffffa01d875c>] ? mlx4_ib_poll_cq+0x9c/0x7d0 [mlx4_ib]
May 22 20:11:40 pserver204 kernel: [8594022.270472]
[<ffffffff8103f139>] ? raise_softirq_irqoff+0x9/0x50
May 22 20:11:40 pserver204 kernel: [8594022.270590]
[<ffffffffa0334e5d>] ? ipoib_poll+0xed/0x1b0 [ib_ipoib]
May 22 20:11:40 pserver204 kernel: [8594022.270718]
[<ffffffffa00041cb>] ? mlx4_assign_eq+0x33b/0xc00 [mlx4_core]
May 22 20:11:40 pserver204 kernel: [8594022.270834]
[<ffffffff8154b5c4>] ? net_rx_action+0xf4/0x240
May 22 20:11:40 pserver204 kernel: [8594022.270954]
[<ffffffffa0062265>] ? acpi_processor_suspend+0x3f1/0x4e2 [processor]
May 22 20:11:40 pserver204 kernel: [8594022.271158]
[<ffffffff8103ee01>] ? __do_softirq+0xb1/0x1e0
May 22 20:11:40 pserver204 kernel: [8594022.271270]
[<ffffffff810ac784>] ? handle_irq_event_percpu+0xb4/0x1e0
May 22 20:11:40 pserver204 kernel: [8594022.270954]
[<ffffffffa0062265>] ? acpi_processor_suspend+0x3f1/0x4e2 [processor]
May 22 20:11:40 pserver204 kernel: [8594022.271158]
[<ffffffff8103ee01>] ? __do_softirq+0xb1/0x1e0
May 22 20:11:40 pserver204 kernel: [8594022.271270]
[<ffffffff810ac784>] ? handle_irq_event_percpu+0xb4/0x1e0
May 22 20:11:40 pserver204 kernel: [8594022.271383]
[<ffffffff8168159c>] ? call_softirq+0x1c/0x30
May 22 20:11:40 pserver204 kernel: [8594022.271495]
[<ffffffff810041e5>] ? do_softirq+0x65/0xa0
May 22 20:11:40 pserver204 kernel: [8594022.271608]
[<ffffffff8103ec1d>] ? irq_exit+0xbd/0xe0
May 22 20:11:40 pserver204 kernel: [8594022.271718]
[<ffffffff8100396c>] ? do_IRQ+0x5c/0xd0
May 22 20:11:40 pserver204 kernel: [8594022.271826]
[<ffffffff81678b2a>] ? common_interrupt+0x6a/0x6a
May 22 20:11:40 pserver204 kernel: [8594022.271936]  <EOI>
May 22 20:11:40 pserver204 kernel: [8594022.272035]
[<ffffffff810090b5>] ? sched_clock+0x5/0x10
May 22 20:11:40 pserver204 kernel: [8594022.272148]
[<ffffffffa0062265>] ? acpi_processor_suspend+0x3f1/0x4e2 [processor]
May 22 20:11:40 pserver204 kernel: [8594022.272351]
[<ffffffffa0062261>] ? acpi_processor_suspend+0x3ed/0x4e2 [processor]
May 22 20:11:40 pserver204 kernel: [8594022.272555]
[<ffffffff81512772>] ? cpuidle_idle_call+0xd2/0x1d0
May 22 20:11:40 pserver204 kernel: [8594022.272672]
[<ffffffff8100a5f4>] ? cpu_idle+0xc4/0x110
May 22 20:11:40 pserver204 kernel: [8594022.272782]
[<ffffffff81ac2d25>] ? start_kernel+0x3af/0x3ba
May 22 20:11:40 pserver204 kernel: [8594022.272891]
[<ffffffff81ac2798>] ? kernel_init+0x1c9/0x1c9
May 22 20:11:40 pserver204 kernel: [8594022.273001]
[<ffffffff81ac2430>] ? x86_64_start_kernel+0x104/0x113
May 22 20:11:40 pserver204 kernel: [8594022.273118] Code: 00 00 00 48 8d
14 11 0f b6 02 39 d8 7f d5 f6 42 01 08 75 3f 48 8b 7a 08 48 85 ff 74 25
48 c7 42 08 00 00 00 00 66 0f 1f 44 00 00 <48> 8b 1f e8 b0 fb ff ff 48
85 db 48 89 df 75 f0 48 8b 8d d8 00
May 22 20:11:40 pserver204 kernel: [8594022.273980] RIP
[<ffffffff8153df98>] skb_release_data+0xa8/0x100
May 22 20:11:40 pserver204 kernel: [8594022.274098]  RSP <ffff880807c03bc0>
May 22 20:11:40 pserver204 kernel: [8594022.274647] scsi host9: Null
scmnd for RSP w/tag 000000000000001f
May 22 20:11:40 pserver204 kernel: [8594022.274833] ---[ end trace
b696840d228c19cf ]---
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
