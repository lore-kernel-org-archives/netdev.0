From: Andrew <nitr0@seti.kr.ua>
Subject: Another pppoe-related crash
Date: Fri, 11 Dec 2015 16:43:39 +0200
Message-ID: <566AE11B.5070709@seti.kr.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pop3.seti.kr.ua ([91.202.132.4]:51086 "EHLO mail.seti.kr.ua"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753595AbbLKOnn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Dec 2015 09:43:43 -0500
Received: from [91.202.133.67] (helo=[192.168.0.145])
	by mail.seti.kr.ua with esmtpa (Exim 4.68)
	(envelope-from <nitr0@seti.kr.ua>)
	id 1a7Ov5-0001CF-Dq
	for netdev@vger.kernel.org; Fri, 11 Dec 2015 16:43:40 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've got another pppoe-related crash on one PPPoE BRAS.

Kernel is 4.1.13 with patch "pppoe: fix memory corruption in padt work 
structure"

Crash place:

(gdb) list *unregister_sysctl_table+0x1a
0xc118f26a is in unregister_sysctl_table 
(/var/testpoint/LEAF/source/i486-unknown-linux-uclibc/linux/linux-4.1/fs/proc/proc_sysctl.c:1573).
1568        might_sleep();
1569
1570        if (header == NULL)
1571            return;
1572
1573        nr_subheaders = count_subheaders(header->ctl_table_arg);
1574        if (unlikely(nr_subheaders > 1)) {
1575            struct ctl_table_header **subheaders;
1576            int i;
1577


Here's trace:

[587692.546567] BUG: unable to handle kernel paging request at 05040214
[587692.546602] IP: [<c118f26a>] unregister_sysctl_table+0x1a/0x80
[587692.546626] *pdpt = 000000001d6a9001 *pde = 0000000000000000
[587692.546643] Oops: 0000 [#1] SMP
[587692.546657] Modules linked in: act_mirred pppoe pppox ppp_generic 
slhc iptable_filter xt_length xt_TCPMSS xt_tcpudp xt_mark xt_dscp 
iptable_mangle ip_tables x_tables ipv6 sch_sfq sch_htb cls_u32 
sch_ingress sch_prio sch_tbf cls_flow cls_fw act_police ifb 8021q mrp 
garp stp llc softdog thermal parport_pc parport acpi_cpufreq processor 
asus_atk0110 fan thermal_sys igb(O) k10temp hwmon dca ptp pps_core 
ohci_pci ohci_hcd i2c_nforce2 i2c_core nv_tco sd_mod pata_acpi pcspkr 
ehci_pci pata_amd sata_nv ata_generic ehci_hcd libata usbcore scsi_mod 
usb_common ext4 mbcache jbd2 crc16 vfat fat isofs
[587692.546828] CPU: 0 PID: 7260 Comm: ip-down Tainted: G        W O    
4.1.13-i686 #1
[587692.546851] Hardware name: System manufacturer System Product 
Name/M2N-SLI DELUXE, BIOS ASUS M2N-SLI DELUXE ACPI BIOS Revision 5001 
02/04/2010
[587692.546875] task: dfa89b60 ti: debae000 task.ti: debae000
[587692.546891] EIP: 0060:[<c118f26a>] EFLAGS: 00210206 CPU: 0
[587692.546906] EIP is at unregister_sysctl_table+0x1a/0x80
[587692.546919] EAX: 05040200 EBX: 05040200 ECX: 00000000 EDX: 00000000
[587692.546932] ESI: df359b0c EDI: df359b00 EBP: debafe54 ESP: debafe48
[587692.546946]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
[587692.546959] CR0: 8005003b CR2: 05040214 CR3: 1827b740 CR4: 000006f0
[587692.546971] Stack:
[587692.546981]  d613f000 df359b0c df359b00 debafe60 c13783bc d613c000 
debafea8 c13789bf
[587692.547008]  00200246 d9d156e0 f6db82a0 f6401e00 debafe9c c112dc17 
f920844b f920844b
[587692.547035]  d613c000 c132a8fd 00000008 cbe14800 00200246 c1523ff8 
c1524264 00000000
[587692.547060] Call Trace:
[587692.547079]  [<c13783bc>] ? 
__devinet_sysctl_unregister.isra.19+0x1c/0x30
[587692.547094]  [<c13789bf>] ? inetdev_event+0x17f/0x4c0
[587692.547110]  [<c112dc17>] ? kfree+0xf7/0x130
[587692.547126]  [<f920844b>] ? htb_destroy+0xbb/0x100 [sch_htb]
[587692.547142]  [<f920844b>] ? htb_destroy+0xbb/0x100 [sch_htb]
[587692.547158]  [<c132a8fd>] ? fib_rules_event+0x1d/0x1b0
[587692.547174]  [<c1065fdd>] ? notifier_call_chain+0x4d/0x70
[587692.547189]  [<c106610f>] ? raw_notifier_call_chain+0x1f/0x30
[587692.547205]  [<c130d386>] ? rollback_registered_many+0x146/0x280
[587692.547222]  [<c107f811>] ? mutex_optimistic_spin+0x101/0x190
[587692.547236]  [<c130d4e4>] ? rollback_registered+0x24/0x40
[587692.547251]  [<c130e6e7>] ? unregister_netdevice_queue+0x57/0xc0
[587692.547265]  [<c130e76d>] ? unregister_netdev+0x1d/0x30
[587692.547281]  [<f952b614>] ? ppp_shutdown_interface+0xd4/0xf0 
[ppp_generic]
[587692.547297]  [<f952d107>] ? ppp_release+0x67/0x70 [ppp_generic]
[587692.547312]  [<f952d0fc>] ? ppp_release+0x5c/0x70 [ppp_generic]
[587692.547327]  [<c1139fc4>] ? __fput+0x84/0x1b0
[587692.547343]  [<c1063d39>] ? task_work_run+0xa9/0xd0
[587692.547357]  [<c13bb415>] ? work_notifysig+0x16/0x1d
[587692.547369] Code: 9e 22 00 b8 84 2f 5f c1 e8 44 bb 22 00 eb 9d 66 90 
55 89 e5 83 ec 0c 89 5d f4 89 75 f8 89 7d fc 3e 8d 74 26 00 85 c0 89 c3 
74 25 <8b> 40 14 e8 ce f6 ff ff 83 f8 01 7f 25 b8 84 2f 5f c1 e8 0f bb
[587692.547458] EIP: [<c118f26a>] unregister_sysctl_table+0x1a/0x80 
SS:ESP 0068:debafe48
[587692.547481] CR2: 0000000005040214
[587692.547675] ---[ end trace fbeed93ca56120ba ]---
