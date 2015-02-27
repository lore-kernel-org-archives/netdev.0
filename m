From: Brian Rak <brak@vultr.com>
Subject: Repeatable IPv6 crash in 3.19.0-1
Date: Fri, 27 Feb 2015 16:37:16 -0500
Message-ID: <54F0E38C.5060203@vultr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.choopa.net ([216.155.136.52]:56062 "EHLO mail.choopa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753405AbbB0Vq7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Feb 2015 16:46:59 -0500
Received: from localhost (unknown [127.0.0.1])
	by mail.choopa.net (iRedMail) with ESMTP id 8382C4AED86
	for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 16:37:15 -0500 (EST)
Received: from mail.choopa.net ([127.0.0.1])
	by localhost (mail.choopa.net [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id TBQgZ3zieKzI for <netdev@vger.kernel.org>;
	Fri, 27 Feb 2015 16:37:14 -0500 (EST)
Received: from [10.5.5.117] (office-nat.choopa.net [208.167.225.40])
	by mail.choopa.net (iRedMail) with ESMTPSA id 0A8BB4AEDC0
	for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 16:37:14 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've been seeing a crash under 3.19.0 that seems to occur when I put 
heavy traffic across a macvtap/veth interface.

We have a KVM guest attached to a veth pair using macvtap.  We're 
routing IPv6 traffic into one end of the veth pair using some static 
routes.  We do *not* have proxy_ndp enabled (though, we are using some 
software to do neighbor proxying - http://priv.nu/projects/ndppd/ ).

I've been able to reproduce this pretty easily by downloading some large 
files from the guest.  We see two traces in a row when this occurs:

------------[ cut here ]------------
WARNING: CPU: 0 PID: 6520 at arch/x86/kernel/smp.c:124 
native_smp_send_reschedule+0x5f/0x70()
Modules linked in: ip_set netconsole configfs xt_comment ebt_ip6 
ip6table_mangle veth xt_physdev br_netfilter ebt_arp ebt_ip ebtable_nat 
ebtables cls_fw sch_sfq sch_htb vhost_net macvtap macvlan vhost tun 
kvm_intel kvm 8021q garp nfnetlink_queue nfnetlink_log nfnetlink 
bluetooth rfkill bridge stp llc xt_CHECKSUM iptable_mangle ipt_REJECT 
nf_reject_ipv4 iptable_filter ip_tables ip6t_REJECT nf_reject_ipv6 
ip6table_filter ip6_tables ipv6 joydev iTCO_wdt iTCO_vendor_support 
8250_fintek ipmi_devintf ipmi_si ipmi_msghandler microcode pcspkr 
i2c_i801 sg lpc_ich igb dca ptp pps_core hwmon shpchp xhci_pci xhci_hcd 
ie31200_edac edac_core ext4 jbd2 mbcache sd_mod ahci libahci video ttm 
drm_kms_helper sysimgblt sysfillrect syscopyarea dm_mirror 
dm_region_hash dm_log dm_mod
CPU: 0 PID: 6520 Comm: vhost-6518 Tainted: G      D 
3.19.0-1.el6.elrepo.x86_64 #1
Hardware name: Supermicro X10SLH-F/X10SLM+-F/X10SLH-F/X10SLM+-F, BIOS 
1.1a 12/03/2013
  000000000000007c ffff88041fc035a0 ffffffff816754e2 000000000000007c
  0000000000000000 ffff88041fc035e0 ffffffff81074bc5 ffff88041fc03600
  ffff88041fc53f00 0000000000000001 ffff88041fc13f00 ffff8803f6a11150
Call Trace:
  <IRQ>  [<ffffffff816754e2>] dump_stack+0x48/0x5e
  [<ffffffff81074bc5>] warn_slowpath_common+0x95/0xe0
  [<ffffffff81074c2a>] warn_slowpath_null+0x1a/0x20
  [<ffffffff8104749f>] native_smp_send_reschedule+0x5f/0x70
  [<ffffffff810a83fa>] trigger_load_balance+0x14a/0x1f0
  [<ffffffff81099a06>] scheduler_tick+0xa6/0xe0
  [<ffffffff810da121>] update_process_times+0x51/0x70
  [<ffffffff810eb919>] tick_sched_handle+0x39/0x80
  [<ffffffff810ebb62>] tick_sched_timer+0x52/0xa0
  [<ffffffff810dc9d3>] __run_hrtimer+0x83/0x1d0
  [<ffffffff810ebb10>] ? tick_nohz_handler+0xc0/0xc0
  [<ffffffff810dcd46>] hrtimer_interrupt+0x106/0x250
  [<ffffffff8104a249>] local_apic_timer_interrupt+0x39/0x60
  [<ffffffff8167c7d5>] smp_apic_timer_interrupt+0x45/0x60
  [<ffffffff8167a87d>] apic_timer_interrupt+0x6d/0x80
  [<ffffffff81675362>] ? panic+0x1c0/0x206
  [<ffffffff8167535b>] ? panic+0x1b9/0x206
  [<ffffffff810185ca>] oops_end+0xea/0xf0
  [<ffffffff810602c5>] no_context+0x125/0x200
  [<ffffffff810604cd>] __bad_area_nosemaphore+0x12d/0x230
  [<ffffffffa02f726c>] ? ip6t_do_table+0x29c/0x6e0 [ip6_tables]
  [<ffffffffa0331ed0>] ? deliver_clone+0x60/0x60 [bridge]
  [<ffffffff810605e3>] bad_area_nosemaphore+0x13/0x20
  [<ffffffff81060b76>] __do_page_fault+0x336/0x520
  [<ffffffffa03320b9>] ? br_dev_queue_push_xmit+0x1e9/0x200 [bridge]
  [<ffffffff81060e6c>] do_page_fault+0x2c/0x40
  [<ffffffff8167b928>] page_fault+0x28/0x30
  [<ffffffffa02836a3>] ? ip6_finish_output2+0x193/0x490 [ipv6]
  [<ffffffff815d9e4d>] ? nf_hook_slow+0x7d/0x150
  [<ffffffffa0283e10>] ? ip6_xmit+0x470/0x470 [ipv6]
  [<ffffffffa0282a00>] ? ip6_forward_proxy_check+0x150/0x150 [ipv6]
  [<ffffffffa0283ea5>] ip6_finish_output+0x95/0xd0 [ipv6]
  [<ffffffffa0283f58>] ip6_output+0x78/0xb0 [ipv6]
  [<ffffffffa0282a16>] ip6_forward_finish+0x16/0x20 [ipv6]
  [<ffffffffa0284548>] ip6_forward+0x5b8/0x7a0 [ipv6]
  [<ffffffffa0290cac>] ? ip6_route_input+0xbc/0xe0 [ipv6]
  [<ffffffffa028590d>] ip6_rcv_finish+0x9d/0xb0 [ipv6]
  [<ffffffffa0285c88>] ipv6_rcv+0x368/0x4d0 [ipv6]
  [<ffffffff815a8274>] __netif_receive_skb_core+0x4b4/0x640
  [<ffffffff815a8427>] __netif_receive_skb+0x27/0x70
  [<ffffffff815a8562>] process_backlog+0xf2/0x1b0
  [<ffffffff815a8de3>] napi_poll+0xd3/0x1c0
  [<ffffffff810e9664>] ? clockevents_program_event+0x74/0x120
  [<ffffffff815a8f60>] net_rx_action+0x90/0x1c0
  [<ffffffff81078b3b>] __do_softirq+0xfb/0x2a0
  [<ffffffff8167b53c>] do_softirq_own_stack+0x1c/0x30
  <EOI>  [<ffffffff81078645>] do_softirq+0x55/0x60
  [<ffffffff81078728>] __local_bh_enable_ip+0x88/0x90
  [<ffffffff815a9c67>] __dev_queue_xmit+0x227/0x5a0
  [<ffffffff815aa000>] dev_queue_xmit+0x10/0x20
  [<ffffffffa04b4417>] macvtap_get_user+0x437/0x5d0 [macvtap]
  [<ffffffffa04a1172>] ? vhost_get_vq_desc+0x152/0x300 [vhost]
  [<ffffffffa04b45d5>] macvtap_sendmsg+0x25/0x30 [macvtap]
  [<ffffffffa04b9f8b>] handle_tx+0x27b/0x480 [vhost_net]
  [<ffffffffa04ba1c5>] handle_tx_kick+0x15/0x20 [vhost_net]
  [<ffffffffa04a0f6d>] vhost_worker+0x10d/0x1c0 [vhost]
  [<ffffffffa04a0e60>] ? vhost_dev_init+0x1d0/0x1d0 [vhost]
  [<ffffffff8109244e>] kthread+0xce/0xf0
  [<ffffffff81092380>] ? kthread_freezable_should_stop+0x70/0x70
  [<ffffffff816798bc>] ret_from_fork+0x7c/0xb0
  [<ffffffff81092380>] ? kthread_freezable_should_stop+0x70/0x70
---[ end trace eb7c35e4dfea0d83 ]---
BUG: unable to handle kernel paging request at ffff880408812ffe
IP: [<ffffffffa027b6a3>] ip6_finish_output2+0x193/0x490 [ipv6]
PGD 211e067 PUD 2121067 PMD 409339063 PTE 8000000408812161
Oops: 0003 [#1] SMP
Modules linked in: netconsole configfs ip_set xt_comment ebt_ip6 
ip6table_mangle veth xt_physdev br_netfilter ebt_arp ebt_ip ebtable_nat 
ebtables cls_fw sch_sfq sch_htb vhost_net macvtap macvlan vhost tun 
kvm_intel kvm 8021q garp nfnetlink_queue nfnetlink_log nfnetlink 
bluetooth rfkill bridge stp llc joydev xt_CHECKSUM iptable_mangle 
ipt_REJECT nf_reject_ipv4 iptable_filter ip_tables ip6t_REJECT 
nf_reject_ipv6 ip6table_filter ip6_tables ipv6 iTCO_wdt 
iTCO_vendor_support 8250_fintek ipmi_devintf ipmi_si ipmi_msghandler 
microcode pcspkr i2c_i801 sg lpc_ich igb dca ptp pps_core hwmon shpchp 
xhci_pci xhci_hcd ie31200_edac edac_core ext4 jbd2 mbcache sd_mod ahci 
libahci video ttm drm_kms_helper sysimgblt sysfillrect syscopyarea 
dm_mirror dm_region_hash dm_log dm_mod
CPU: 7 PID: 8187 Comm: vhost-8184 Not tainted 3.19.0-1.el6.elrepo.x86_64 #1
Hardware name: Supermicro X10SLH-F/X10SLM+-F/X10SLH-F/X10SLM+-F, BIOS 
1.1a 12/03/2013
task: ffff8803f391c050 ti: ffff88040c128000 task.ti: ffff88040c128000
RIP: 0010:[<ffffffffa027b6a3>]  [<ffffffffa027b6a3>] 
ip6_finish_output2+0x193/0x490 [ipv6]
RSP: 0018:ffff88041fdc3be8  EFLAGS: 00010283
RAX: ffff88040881300e RBX: ffff8803cfcd3a00 RCX: ffff88040d1c52e4
RDX: 7f813e3323000000 RSI: ffff88040bcee168 RDI: ffff8803f65b55c0
RBP: ffff88041fdc3c38 R08: ffff8803d36283d8 R09: 00000000ff332302
R10: 00000000000080fe R11: 000000007f813efe R12: 000000000000000e
R13: ffff88040d1c5200 R14: ffff88040d1c52f0 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff88041fdc0000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: ffff880408812ffe CR3: 00000000d1613000 CR4: 00000000001427e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Stack:
  ffffffffa027be10 ffff880380000000 ffffffffa027aa00 0000000a00000002
  ffffffff81d5e380 ffff8803cfcd3a00 00000000000005dc ffffffff81d25340
  ffff88040881300e ffff880408813000 ffff88041fdc3c58 ffffffffa027bea5
Call Trace:
  <IRQ>
  [<ffffffffa027be10>] ? ip6_xmit+0x470/0x470 [ipv6]
  [<ffffffffa027aa00>] ? ip6_forward_proxy_check+0x150/0x150 [ipv6]
  [<ffffffffa027bea5>] ip6_finish_output+0x95/0xd0 [ipv6]
  [<ffffffffa027bf58>] ip6_output+0x78/0xb0 [ipv6]
  [<ffffffffa027aa16>] ip6_forward_finish+0x16/0x20 [ipv6]
  [<ffffffffa027c548>] ip6_forward+0x5b8/0x7a0 [ipv6]
  [<ffffffffa0288cac>] ? ip6_route_input+0xbc/0xe0 [ipv6]
  [<ffffffffa027d90d>] ip6_rcv_finish+0x9d/0xb0 [ipv6]
  [<ffffffffa027dc88>] ipv6_rcv+0x368/0x4d0 [ipv6]
  [<ffffffff815a8274>] __netif_receive_skb_core+0x4b4/0x640
  [<ffffffff815a8427>] __netif_receive_skb+0x27/0x70
  [<ffffffff815a8562>] process_backlog+0xf2/0x1b0
  [<ffffffff815a8de3>] napi_poll+0xd3/0x1c0
  [<ffffffff815a8f60>] net_rx_action+0x90/0x1c0
  [<ffffffff81078b3b>] __do_softirq+0xfb/0x2a0
  [<ffffffff8167b53c>] do_softirq_own_stack+0x1c/0x30
  <EOI>
  [<ffffffff81078645>] do_softirq+0x55/0x60
  [<ffffffff81078728>] __local_bh_enable_ip+0x88/0x90
  [<ffffffff815a9c67>] __dev_queue_xmit+0x227/0x5a0
  [<ffffffff815aa000>] dev_queue_xmit+0x10/0x20
  [<ffffffffa04b0417>] macvtap_get_user+0x437/0x5d0 [macvtap]
  [<ffffffffa049d172>] ? vhost_get_vq_desc+0x152/0x300 [vhost]
  [<ffffffffa04b05d5>] macvtap_sendmsg+0x25/0x30 [macvtap]
  [<ffffffffa04b5f8b>] handle_tx+0x27b/0x480 [vhost_net]
  [<ffffffffa04b61c5>] handle_tx_kick+0x15/0x20 [vhost_net]
  [<ffffffffa049cf6d>] vhost_worker+0x10d/0x1c0 [vhost]
  [<ffffffffa049ce60>] ? vhost_dev_init+0x1d0/0x1d0 [vhost]
  [<ffffffff8109244e>] kthread+0xce/0xf0
  [<ffffffff81092380>] ? kthread_freezable_should_stop+0x70/0x70
  [<ffffffff816798bc>] ret_from_fork+0x7c/0xb0
  [<ffffffff81092380>] ? kthread_freezable_should_stop+0x70/0x70
Code: 00 00 44 8b 39 41 f6 c7 01 0f 85 8d 02 00 00 45 0f b7 a5 e0 00 00 
00 41 83 fc 10 0f 8f 82 02 00 00 49 8b 16 48 8b 83 d8 00 00 00 <48> 89 
50 f0 49 8b 56 08 48 89 50 f8 45 3b bd e4 00 00 00 75 c2
RIP  [<ffffffffa027b6a3>] ip6_finish_output2+0x193/0x490 [ipv6]
  RSP <ffff88041fdc3be8>
CR2: ffff880408812ffe
---[ end trace d743d347dba40c49 ]---
