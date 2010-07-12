From: Yanko Kaneti <yaneti@declera.com>
Subject: [REGRESSION] 2.6.35-rc crash in br_deliver  (netpoll related)
Date: Mon, 12 Jul 2010 15:54:49 +0300
Message-ID: <1278939289.3557.15.camel@d2>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from indigo.declera.com ([212.116.131.21]:51296 "HELO
	indigo.declera.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754061Ab0GLMxU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jul 2010 08:53:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is quite reliably reproducible in Fedora rawhide acting as a host
for a kvm guest Fedora 13 netinstall (over libvirt created bridged vm
network). Its not reproducible with the same scenario on any of the
2.6.34 fedora kernels.

In a brief experiment I tried pulling the netpoll/bridge fixes from
Herbert Xu http://www.spinics.net/lists/netdev/msg132556.html from
net-next along with nearby patches to make it apply/build. The crash was
gone but there were some new warnings 
WARNING: at kernel/softirq.c:88 __local_bh_disable+0x42/0xbe()
perhaps I didn't pull all the related rcu fixes..

general protection fault: 0000 [#1] SMP 
last sysfs file: /sys/devices/platform/it87.552/temp3_input
CPU 3 
Modules linked in: tun nfs lockd fscache nfs_acl auth_rpcgss sunrpc fuse pppoe pppox ppp_synctty ppp_async crc_ccitt ppp_generic slhc ip6table_filter ip6_tables ebtable_nat ebtables bridge it87 hwmon_vid 8021q garp stp llc ipv6 nf_conntrack_netbios_ns ipt_MASQUERADE iptable_nat nf_nat xt_physdev kvm_amd kvm uinput snd_hda_codec_atihdmi snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm snd_timer snd soundcore snd_page_alloc ppdev parport_pc i2c_piix4 parport shpchp edac_core k10temp edac_mce_amd wmi raid1 ata_generic pata_acpi usb_storage 3c59x firewire_ohci firewire_core crc_itu_t tulip pata_atiixp r8169 mii radeon ttm drm_kms_helper drm i2c_algo_bit i2c_core [last unloaded: scsi_wait_scan]

Pid: 3278, comm: qemu-kvm Not tainted 2.6.35-0.31.rc4.git4.fc14.x86_64 #1 GA-MA78GM-S2H/GA-MA78GM-S2H
RIP: 0010:[<ffffffffa0394529>]  [<ffffffffa0394529>] __br_deliver+0x82/0xa2 [bridge]
RSP: 0018:ffff880003203b30  EFLAGS: 00010246
RAX: 6b6b6b6b6b6b6b6b RBX: ffff8801cf8caf00 RCX: 0000000000000000
RDX: ffff8802045330e0 RSI: ffff88020133a168 RDI: ffffffff80000000
RBP: ffff880003203b40 R08: ffff8802077d07a0 R09: ffff8800032039b0
R10: ffff8802045330e0 R11: ffff8801cf8caf00 R12: ffff880220c6a9e0
R13: ffff8801cf8caf28 R14: ffff88020133a168 R15: ffff880220e6bbd8
FS:  00007f08fb362700(0000) GS:ffff880003200000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000ffedd0 CR3: 0000000201163000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process qemu-kvm (pid: 3278, threadinfo ffff8802013c4000, task ffff8801fdd38000)
Stack:
 ffff8801cf8caf00 ffff880220c6a9e0 ffff880003203b50 ffffffffa03945e5
<0> ffff880003203b80 ffffffffa0393561 ffff8801cf8caf00 ffff880220c6a060
<0> ffff880220c6a060 ffff880220e6bbd8 ffff880003203bd0 ffffffff813e85a0
Call Trace:
 <IRQ> 
 [<ffffffffa03945e5>] br_deliver+0x27/0x33 [bridge]
 [<ffffffffa0393561>] br_dev_xmit+0x10a/0x122 [bridge]
 [<ffffffff813e85a0>] dev_hard_start_xmit+0x237/0x30e
 [<ffffffff813e89e3>] dev_queue_xmit+0x36c/0x434
 [<ffffffff813e8751>] ? dev_queue_xmit+0xda/0x434
 [<ffffffff81408aba>] ? nf_hook_slow+0xd1/0xe3
 [<ffffffff8141d438>] ? ip_finish_output+0x0/0x71
 [<ffffffff8141d3f5>] ip_finish_output2+0x1df/0x222
 [<ffffffff8141d4a4>] ip_finish_output+0x6c/0x71
 [<ffffffff8141dd29>] ip_output+0x96/0x9a
 [<ffffffff8141b318>] ip_forward_finish+0x4e/0x53
 [<ffffffff8141b5fb>] ip_forward+0x2de/0x34b
 [<ffffffff814198bd>] ? rcu_read_lock_held+0xe/0x27
 [<ffffffff81419d25>] ip_rcv_finish+0x387/0x3b9
 [<ffffffff8141999e>] ? ip_rcv_finish+0x0/0x3b9
 [<ffffffff8141a026>] NF_HOOK.clone.6+0x51/0x59
 [<ffffffff8141a3c6>] ip_rcv+0x21f/0x24d
 [<ffffffff813e4df8>] __netif_receive_skb+0x470/0x49a
 [<ffffffff813e6724>] process_backlog+0x99/0x17b
 [<ffffffff813e68b7>] net_rx_action+0xb1/0x1f5
 [<ffffffff8107ae11>] ? print_lock_contention_bug+0x1b/0xd5
 [<ffffffff8100abdc>] ? call_softirq+0x1c/0x30
 [<ffffffff81056660>] __do_softirq+0xfa/0x1cf
 [<ffffffff8107d358>] ? lock_release+0x19a/0x1a6
 [<ffffffff8100abdc>] call_softirq+0x1c/0x30
 [<ffffffff8100c375>] do_softirq+0x4b/0xa2
 [<ffffffff81056806>] irq_exit+0x4a/0x8c
 [<ffffffff8149d6c5>] do_IRQ+0x9d/0xb4
 [<ffffffff81497853>] ret_from_intr+0x0/0x16
 <EOI> 
 [<ffffffffa0319044>] ? kvm_arch_vcpu_ioctl_run+0x7a5/0xadd [kvm]
 [<ffffffffa030cc31>] ? raw_local_irq_enable+0xd/0x12 [kvm]
 [<ffffffff8107d886>] ? trace_hardirqs_on+0xd/0xf
 [<ffffffffa0319049>] kvm_arch_vcpu_ioctl_run+0x7aa/0xadd [kvm]
 [<ffffffffa0306320>] kvm_vcpu_ioctl+0x103/0x5d7 [kvm]
 [<ffffffff81081e40>] ? do_futex+0x7c0/0x895
 [<ffffffff81128174>] ? generic_file_llseek+0x2f/0x60
 [<ffffffff81135cd4>] vfs_ioctl+0x36/0xa7
 [<ffffffff8113664d>] do_vfs_ioctl+0x47c/0x4af
 [<ffffffff8107d358>] ? lock_release+0x19a/0x1a6
 [<ffffffff8112931a>] ? rcu_read_unlock+0x21/0x23
 [<ffffffff811366d6>] sys_ioctl+0x56/0x7c
 [<ffffffff81009c72>] system_call_fastpath+0x16/0x1b
Code: 66 81 88 7e 01 00 00 00 10 48 8b 4f 08 31 d2 49 c7 c0 82 44 39 a0 48 89 de bf 03 00 00 00 48 89 4b 20 e8 04 ff ff ff 48 8b 43 20 <48> 8b 80 08 05 00 00 48 85 c0 74 0f 48 8b 80 d0 01 00 00 49 8b 
...



