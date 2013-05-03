From: holger@eitzenberger.org
Subject: [patch 0/1] [BUG PATCH] asix: fix BUG in receive path when lowering MTU
Date: Fri, 03 May 2013 12:02:19 +0200
Message-ID: <20130503112618.108645718@eitzenberger.org>
Cc: netdev@vger.kernel.org
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:58663 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762019Ab3ECLc5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 May 2013 07:32:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Oliver,

there has been reported a bug in the asix usbnet driver, occuring
at the time a packet arrives larger than MTU size (minus some
overhead):

 BUG: unable to handle kernel paging request at 0000004000000001
 IP: [<ffffffff8126f65b>] skb_release_head_state+0x2d/0xd2
 PGD 0 
 Oops: 0002 [#1] SMP 
 Modules linked in: xt_connmark xt_tcpudp xt_set xt_multiport xt_addrtype ip_set_hash_ip nf_nat_pptp nf_nat_proto_gre nf_nat_irc nf_nat_ftp nf_conntrack_pptp nf_conntrack_proto_gre nf_conntrack_irc nf_conntrack_ftp af_packet ebtable_filter ebtables ip6table_ips ip6table_mangle ip6table_nat nf_nat_ipv6 iptable_ips iptable_mangle iptable_nat nf_nat_ipv4 nf_nat xt_NFLOG xt_condition(O) xt_logmark xt_confirmed xt_owner ip6t_REJECT ipt_REJECT xt_state ip_set red2 ip_scheduler red nfnetlink_log nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6table_raw nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack iptable_filter iptable_raw xt_CT nf_conntrack_netlink nfnetlink nf_conntrack ip6_tables ip_tables x_tables ipv6 loop asix libphy usbnet mii acpi_cpufreq mperf crc32c_intel coretemp ehci_pci e1000e(O
 ) ehci_hcd xhci_hcd sg sr_mod evdev rtc_cmos pcspkr i2c_i801 ppdev parport_pc e1000 parport microcode button cdrom fan thermal sd_mod processor thermal_sys hwmon pata_acpi ata_generic edd ata_piix libata scsi_mod
 CPU 0 
 Pid: 0, comm: swapper/0 Tainted: G           O 3.8.6-1.gae5c790-smp64 #1 System manufacturer System Product Name/P8H61/USB3
 RIP: 0010:[<ffffffff8126f65b>]  [<ffffffff8126f65b>] skb_release_head_state+0x2d/0xd2
 RSP: 0018:ffff88011ec03e20  EFLAGS: 00010202
 RAX: 0000000000000000 RBX: ffff880117869000 RCX: 0000000000000086
 RDX: ffff8801178690f4 RSI: 0000000000000046 RDI: 0000004000000001
 RBP: 0000000000000000 R08: 0000000000000046 R09: ffffffff815515ec
 R10: 0000000000000000 R11: 0000000000000078 R12: ffff88011923e8d0
 R13: ffff880118d5a600 R14: ffff88011923e780 R15: 000000000000000a
 FS:  0000000000000000(0000) GS:ffff88011ec00000(0000) knlGS:0000000000000000
 CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
 CR2: 0000004000000001 CR3: 0000000001430000 CR4: 00000000000407f0
 DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
 DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
 Process swapper/0 (pid: 0, threadinfo ffffffff81424000, task ffffffff81438410)
 Stack:
  ffff880117869000 ffffffff8126f86d ffff880117869000 ffffffff8126f8ad
  ffff8801181aa050 ffffffffa00b4200 ffff8801189584aa ffff880118f5f048
  ffff88011923e780 ffff880118d5a600 ffff88011923e8d0 0000000000000001
 Call Trace:
  <IRQ> 
  [<ffffffff8126f86d>] ? skb_release_all+0x9/0x1e
  [<ffffffff8126f8ad>] ? __kfree_skb+0x9/0x6f
  [<ffffffffa00b4200>] ? asix_rx_fixup_internal+0xff/0x1ae [asix]
  [<ffffffffa00fb3dc>] ? usbnet_bh+0x4f/0x226 [usbnet]
  [<ffffffff812056fe>] ? add_interrupt_randomness+0x39/0x157
  [<ffffffff81039ff6>] ? tasklet_action+0x74/0xbd
  [<ffffffff8103a742>] ? __do_softirq+0x9d/0x15f
  [<ffffffff8130099c>] ? call_softirq+0x1c/0x30
  [<ffffffff81009fd7>] ? do_softirq+0x3f/0x79
  [<ffffffff8103a538>] ? irq_exit+0x43/0xb0
  [<ffffffff81009865>] ? do_IRQ+0x98/0xae
  [<ffffffff812536d2>] ? disable_cpuidle+0xb/0xb
  [<ffffffff812fa1ad>] ? common_interrupt+0x6d/0x6d
  <EOI> 
  [<ffffffff8104f21b>] ? __hrtimer_start_range_ns+0x271/0x284
  [<ffffffff811ad3f2>] ? __setup_broadcast_timer+0x2d/0x2d
  [<ffffffff8100dd4e>] ? sched_clock+0x5/0x8
  [<ffffffff81253c47>] ? cpuidle_wrap_enter+0x39/0x71
  [<ffffffff81253c40>] ? cpuidle_wrap_enter+0x32/0x71
  [<ffffffff812536ee>] ? cpuidle_enter_state+0xa/0x33
  [<ffffffff81253b70>] ? cpuidle_idle_call+0x9e/0xcc
  [<ffffffff8100ef8f>] ? cpu_idle+0x61/0xa9
  [<ffffffff81499120>] ? early_idt_handlers+0x120/0x120
  [<ffffffff81499c5f>] ? start_kernel+0x372/0x37e
  [<ffffffff81499705>] ? repair_env_string+0x5d/0x5d
  [<ffffffff814993e1>] ? x86_64_start_kernel+0x102/0x10f
 Code: 89 fb 48 8b 7f 58 48 85 ff 74 17 40 f6 c7 01 75 09 48 83 e7 fe e8 e5 ef 00 00 48 c7 43 58 00 00 00 00 48 8b 7b 60 48 85 ff 74 0f <f0> ff 0f 0f 94 c0 84 c0 74 05 e8 7b 16 07 00 48 83 bb 80 00 00 
 RIP  [<ffffffff8126f65b>] skb_release_head_state+0x2d/0xd2
  RSP <ffff88011ec03e20>
 CR2: 0000004000000001
 ---[ end trace 9c13f42cc4b59d9c ]---

It is easily reproducable by setting an MTU of 512 e. g. and sending something
like

 $ ping -s 1472 -c 1 -M do $SELF

from another box.

I can see that the overlong packet case is detected correctly in
asix_rx_fixup_internal(), but in this case the asix_rx_fix_info data
is not reset properly, so that a subsequent call frees that skb again.

The attached patch fixes that for me by resetting rx->ax_skb and
rx->size on error.  Please check.

Thank you.

 /Holger
