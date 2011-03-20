From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: oops / kernel panic in bonding.
Date: Sun, 20 Mar 2011 21:17:48 +0100
Message-ID: <4D8660EC.6080102@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:39939 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752318Ab1CTURx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Mar 2011 16:17:53 -0400
Received: by wwk4 with SMTP id 4so2872720wwk.1
        for <netdev@vger.kernel.org>; Sun, 20 Mar 2011 13:17:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri,

I suspect we have a race condition somewhere in the new bond_handle_frame function:

The following commands produce one of the following errors:

modprobe bonding max_bonds=0
echo +bond0>/sys/class/net/bonding_masters
echo +bond1>/sys/class/net/bonding_masters
echo +eth1>/sys/class/net/bond1/bonding/slaves

This is mostly reproducible, under VirtualBox.

All tests done with 08351fc6a75731226e1112fc7254542bd3a2912e at the top commit (current net-next-2.6).

	Nicolas.

First try:

[   42.478455] BUG: unable to handle kernel NULL pointer dereference at 0000000000000280
[   42.480035] IP: [<ffffffffa040c9b0>] bond_handle_frame+0x1f/0x138 [bonding]
[   42.480035] PGD 0
[   42.480035] Oops: 0000 [#1] SMP
[   42.480035] last sysfs file: /sys/devices/virtual/net/bond1/bonding/slaves
[   42.480035] CPU 0
[   42.480035] Modules linked in: bonding loop snd_intel8x0 snd_ac97_codec ac97_bus snd_pcm 
snd_timer tpm_tis tpm snd psmouse tpm_bios parport_pc processor evdev pcspkr parport battery 
i2c_piix4 serio_raw ac i2c_core button thermal_sys soundcore snd_page_alloc ext3 jbd mbcache 
ide_gd_mod ide_cd_mod cdrom ata_generic ata_piix libata scsi_mod ohci_hcd piix ide_core floppy 
ehci_hcd usbcore e1000 nls_base [last unloaded: scsi_wait_scan]
[   42.480035]
[   42.480035] Pid: 206, comm: udevd Not tainted 2.6.38+ #5 innotek GmbH VirtualBox
[   42.480035] RIP: 0010:[<ffffffffa040c9b0>]  [<ffffffffa040c9b0>] bond_handle_frame+0x1f/0x138 
[bonding]
[   42.480035] RSP: 0018:ffff88003fc03c20  EFLAGS: 00010282
[   42.480035] RAX: 0000000000000000 RBX: 0000000000000000 RCX: ffff88002ecb0608
[   42.480035] RDX: ffff880023392600 RSI: ffff880023392600 RDI: ffff880023392600
[   42.480035] RBP: ffffffffa040c991 R08: ffff880023392600 R09: 00000000ffffffff
[   42.480035] R10: ffff88002322c740 R11: dead000000200200 R12: ffff88002ec0ea00
[   42.480035] R13: ffff88003fc03c58 R14: 0000000000000000 R15: 0000000000000001
[   42.480035] FS:  00007fbab75c57a0(0000) GS:ffff88003fc00000(0000) knlGS:0000000000000000
[   42.480035] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   42.480035] CR2: 0000000000000280 CR3: 000000003defd000 CR4: 00000000000006f0
[   42.480035] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   42.480035] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[   42.480035] Process udevd (pid: 206, threadinfo ffff880030066000, task ffff8800231c5040)
[   42.480035] Stack:
[   42.480035]  00000000ffffffff 0000000000000000 ffffffffa040c991 ffff88002322c000
[   42.480035]  ffff88003fc03c68 ffffffff81267192 0000000000000000 ffff880023392600
[   42.480035]  0000000000000080
[   42.524186] bonding: bond1: enslaving eth1 as an active interface with an up link.

Another try:

[  308.145200] BUG: unable to handle kernel NULL pointer dereference at 0000000000000280
[  308.146140] IP: [<ffffffffa042c9b0>] bond_handle_frame+0x1f/0x138 [bonding]
[  308.146993] PGD 0
[  308.147249] Oops: 0000 [#1] SMP
[  308.147669] last sysfs file: /sys/devices/virtual/net/bond0/uevent
[  308.148024] CPU 0
[  308.148024] Modules linked in: bonding loop snd_intel8x0 snd_ac97_codec ac97_bus snd_pcm 
snd_timer psmouse tpm_tis snd tpm tpm_bios serio_raw parport_pc i2c_piix4 pcspkr soundcore processor 
evdev snd_page_alloc i2c_core parport battery ac button thermal_sys ext3 jbd mbcache ide_cd_mod 
ide_gd_mod cdrom ata_generic ata_piix libata scsi_mod ohci_hcd piix ide_core ehci_hcd usbcore floppy 
e1000 nls_base [last unloaded: bonding]
[  308.148024]
[  308.148024] Pid: 1291, comm: udevd Not tainted 2.6.38+ #5 innotek GmbH VirtualBox
[  308.165445] RIP: 0010:[<ffffffffa042c9b0>]  [<ffffffffa042c9b0>] bond_handle_frame+0x1f/0x138 
[bonding]
[  308.165445] RSP: 0000:ffff88003fc03c20  EFLAGS: 00010282
[  308.165445] RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000148
[  308.165445] RDX: ffff880023246000 RSI: ffff880023246000 RDI: ffff880023246000
[  308.165445] RBP: ffffffffa042c991 R08: ffff880023246000 R09: 0000000000000000
[  308.165445] R10: ffff88002ee2e740 R11: ffffffff81051a61 R12: ffff880039e50800
[  308.165445] R13: ffff88003fc03c58 R14: 0000000000000000 R15: 0000000000000001
[  308.165445] FS:  00007f1f30e837a0(0000) GS:ffff88003fc00000(0000) knlGS:0000000000000000
[  308.165445] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  308.165445] CR2: 0000000000000280 CR3: 000000002e582000 CR4: 00000000000006f0
[  308.165445] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  308.165445] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  308.165445] Process udevd (pid: 1291, threadinfo ffff88002eea0000, task ffff88002f808d60)
[  308.165445] Stack:
[  308.165445]  ffff88002f80eb00 0000000000000000 ffffffffa042c991 ffff88002ee2e000
[  308.165445]  ffff88003fc03c68 ffffffff81267192 ffffffff810345f4 ffff880023246000
[  308.165445]  0000000000000000 ffffffff81679c20 ffff880023246000 ffff880023246000
[  308.165445] Call Trace:
[  308.165445]  <IRQ>
[  308.165445]  [<ffffffffa042c991>] ? bond_handle_frame+0x0/0x138 [bonding]
[  308.165445]  [<ffffffff81267192>] ? __netif_receive_skb+0x2f9/0x4c5
[  308.165445]  [<ffffffff810345f4>] ? __wake_up_common+0x41/0x78
[  308.165445]  [<ffffffff81267656>] ? netif_receive_skb+0x67/0x6d
[  308.165445]  [<ffffffff81267b5d>] ? napi_gro_receive+0x1f/0x2d
[  308.165445]  [<ffffffff8126772b>] ? napi_skb_finish+0x1c/0x31
[  308.165445]  [<ffffffffa000b25c>] ? e1000_clean_rx_irq+0x2fd/0x3b0 [e1000]
[  308.165445]  [<ffffffffa000ab46>] ? e1000_clean+0x30f/0x490 [e1000]
[  308.165445]  [<ffffffff81020bf6>] ? ack_apic_level+0x6e/0x134
[  308.165445]  [<ffffffff81091a7f>] ? handle_fasteoi_irq+0x9c/0xb4
[  308.165445]  [<ffffffff8104aa01>] ? irq_exit+0x6e/0xa0
[  308.165445]  [<ffffffff81267c8a>] ? net_rx_action+0xa8/0x206
[  308.165445]  [<ffffffff8104abf3>] ? __do_softirq+0xc3/0x19e
[  308.165445]  [<ffffffff8108f6d0>] ? handle_irq_event_percpu+0x171/0x18f
[  308.165445]  [<ffffffff8104ac6b>] ? __do_softirq+0x13b/0x19e
[  308.165445]  [<ffffffff81323edc>] ? call_softirq+0x1c/0x30
[  308.165445]  [<ffffffff8100aa53>] ? do_softirq+0x3f/0x79
[  308.165445]  [<ffffffff8104a9d2>] ? irq_exit+0x3f/0xa0
[  308.165445]  [<ffffffff8100a39f>] ? do_IRQ+0x94/0xaa
[  308.165445]  [<ffffffff8131cbd3>] ? ret_from_intr+0x0/0x15
[  308.165445]  <EOI>
[  308.165445]  [<ffffffff810da903>] ? ptep_clear_flush+0x17/0x34
[  308.165445]  [<ffffffff810cb8ba>] ? copy_user_highpage+0x27/0x40
[  308.165445]  [<ffffffff810cf45c>] ? do_wp_page+0x5c1/0x689
[  308.165445]  [<ffffffff810d0155>] ? handle_pte_fault+0x8a5/0x8f2
[  308.165445]  [<ffffffff810d02c4>] ? handle_mm_fault+0x122/0x18b
[  308.165445]  [<ffffffff8131f9b7>] ? do_page_fault+0x32a/0x34c
[  308.165445]  [<ffffffff8131ce95>] ? page_fault+0x25/0x30
[  308.165445]  [<ffffffff81199b0d>] ? __put_user_4+0x1d/0x30
[  308.165445]  [<ffffffff8131ce95>] ? page_fault+0x25/0x30
[  308.165445] Code: e8 ed fc e2 e0 5a 48 89 d8 5b 5d c3 41 55 49 89 fd 41 54 55 53 48 83 ec 08 48 
8b 3f 48 8b 47 20 4c 8b a0 f0 02 00 00 49 8b 04 24
[  308.165445]  8b a8 80 02 00 00 b8 03 00 00 00 48 85 ed 0f 84 fc 00 00 00
[  308.165445] RIP  [<ffffffffa042c9b0>] bond_handle_frame+0x1f/0x138 [bonding]
[  308.165445]  RSP <ffff88003fc03c20>
[  308.165445] CR2: 0000000000000280
[  308.246179] ---[ end trace 31773bac6ab820b4 ]---
[  308.246897] Kernel panic - not syncing: Fatal exception in interrupt
[  308.248076] Pid: 1291, comm: udevd Tainted: G      D     2.6.38+ #5
[  308.249089] Call Trace:
[  308.249496]  <IRQ>  [<ffffffff8131abe8>] ? panic+0x92/0x197
[  308.250396]  [<ffffffff810457a5>] ? kmsg_dump+0x41/0xe3
[  308.251211]  [<ffffffff8131d9a6>] ? oops_end+0xa9/0xb6
[  308.252077]  [<ffffffff8102c9ff>] ? no_context+0x1f4/0x201
[  308.252967]  [<ffffffffa000a7ed>] ? e1000_xmit_frame+0xa5b/0xaa5 [e1000]
[  308.254014]  [<ffffffff8131f83c>] ? do_page_fault+0x1af/0x34c
[  308.254915]  [<ffffffff81264479>] ? dev_hard_start_xmit+0x3de/0x53c
[  308.256937]  [<ffffffffa042c991>] ? bond_handle_frame+0x0/0x138 [bonding]
[  308.258683]  [<ffffffff8131ce95>] ? page_fault+0x25/0x30
[  308.260431]  [<ffffffffa042c991>] ? bond_handle_frame+0x0/0x138 [bonding]
[  308.262420]  [<ffffffff81051a61>] ? __mod_timer+0x145/0x157
[  308.264009]  [<ffffffffa042c9b0>] ? bond_handle_frame+0x1f/0x138 [bonding]
[  308.265944]  [<ffffffffa042c991>] ? bond_handle_frame+0x0/0x138 [bonding]
[  308.267404] bonding: bond1: enslaving eth1 as an active interface with an up link.
[  308.269896]  [<ffffffff81267192>] ? __netif_receive_skb+0x2f9/0x4c5
[  308.271792]  [<ffffffff810345f4>] ? __wake_up_common+0x41/0x78
[  308.271795]  [<ffffffff81267656>] ? netif_receive_skb+0x67/0x6d
[  308.271797]  [<ffffffff81267b5d>] ? napi_gro_receive+0x1f/0x2d
[  308.271799]  [<ffffffff8126772b>] ? napi_skb_finish+0x1c/0x31
[  308.271811]  [<ffffffffa000b25c>] ? e1000_clean_rx_irq+0x2fd/0x3b0 [e1000]
[  308.271815]  [<ffffffffa000ab46>] ? e1000_clean+0x30f/0x490 [e1000]
[  308.271819]  [<ffffffff81020bf6>] ? ack_apic_level+0x6e/0x134
[  308.271822]  [<ffffffff81091a7f>] ? handle_fasteoi_irq+0x9c/0xb4
