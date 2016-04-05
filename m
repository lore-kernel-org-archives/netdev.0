From: Petko Manolov <petkan@mip-labs.com>
Subject: Re: ADMtek ADM8511 "Pegasus II" USB Ethernet causes oops
Date: Tue, 05 Apr 2016 18:42:23 +0300
Message-ID: <CDA0DCA5-4846-4153-811B-C56AEF93C312@mip-labs.com>
References: <57039405.7050501@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Lincoln Ramsay <a1291762@gmail.com>, petkan@nucleusys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lan.nucleusys.com ([92.247.61.126]:39178 "EHLO
	zztop.nucleusys.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759304AbcDEPmn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 11:42:43 -0400
In-Reply-To: <57039405.7050501@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've no idea how this PEGASUS_MTU + 8 got in.  Maybe somebody played games with the skb alignment over the years.

I'm traveling right now so i'll look at the patch more closely when I get back.  At first glance it does look OK.


cheers,
Petko



On April 5, 2016 1:31:33 PM GMT+03:00, Lincoln Ramsay <a1291762@gmail.com> wrote:
>Hello,
>
>I have this (rather old) USB ethernet device but I cannot use it
>because 
>it crashes my machine.
>
>Simply plugging in the adapter and causing some traffic (pinging the 
>gateway will do) causes an oops. With older kernels (3.10-3.19) this
>was 
>generally nearly instant. With the current kernel (4.6 rc2) it can take
>
>longer to trigger (several minutes of pinging). Booting with the
>adapter 
>inserted does not change the observed behaviour.
>
>I found (via bisecting) that commit 
>313a58e487ab3eb80e7e1f9baddc75968288aad9 causes the symptom. However,
>it 
>looks like this just exposes an older, underlying problem. The 
>underlying problem appears to be a skb buffer overrun. I think this 
>overrun was not visible before this change due to the memory allocation
>
>pattern of the buffer pool.
>
>I updated the code to avoid reading more data than the buffer can hold 
>(see patch at the end) and I could use the adapter. My machine was up 
>all day running this patch and doing network traffic over the adapter 
>without issue.
>
>/proc/version says
>Linux version 4.6.0-040600rc2-generic (kernel@tangerine) (gcc version 
>5.2.1 20151010 (Ubuntu 5.2.1-22ubuntu2) ) #201604031130 SMP Sun Apr 3 
>15:32:46 UTC 2016
>
>Here's an example oops (obtained via netconsole over the other ethernet
>
>interface). However, I doubt it's much use due to the nature of the 
>issue. I have seen a variety of different oops messages while 
>investigating this issue.
>
>[   56.333612] BUG: unable to handle kernel NULL pointer dereference at
>
>0000000000000020
>[   56.333700] IP: [<ffffffff81718ccd>] skb_release_data+0x7d/0x120
>[   56.333764] PGD baf0c067 PUD bb738067 PMD 0
>[   56.333828] Oops: 0000 [#1] SMP
>[   56.333880] Modules linked in: nouveau arc4 iwldvm mac80211 ttm 
>drm_kms_helper drm coretemp kvm_intel i2c_algo_bit snd_hda_codec_hdmi 
>pata_pcmcia fb_sys_fops kvm syscopyarea sysfillrect
>snd_hda_codec_analog 
>uvcvideo iwlwifi snd_hda_codec_generic sysimgblt hp_wmi r852 irqbypass 
>snd_hda_intel sparse_keymap ppdev videobuf2_vmalloc mxm_wmi sm_common 
>pcmcia nand snd_hda_codec videobuf2_memops nand_ecc snd_hda_core 
>nand_bch cfg80211 videobuf2_v4l2 snd_hwdep snd_pcm videobuf2_core 
>yenta_socket bch snd_timer videodev snd pcmcia_rsrc nand_ids r592 
>pcmcia_core mtd soundcore lpc_ich serio_raw pegasus memstick media 
>netconsole mii hp_accel lis3lv02d configfs input_leds joydev 
>input_polldev shpchp 8250_fintek wmi mei_me tpm_infineon parport_pc mei
>
>video lp mac_hid parport hid_generic sdhci_pci e1000e ptp usbhid 
>firewire_ohci psmouse pps_core firewire_core crc_itu_t sdhci hid 
>pata_acpi fjes
>[   56.335370] CPU: 1 PID: 0 Comm: swapper/1 Not tainted 
>4.6.0-040600rc2-generic #201604031130
>[   56.335417] Hardware name: Hewlett-Packard HP EliteBook 8530w/30E7, 
>BIOS 68PDV Ver. F.20 12/08/2011
>[   56.335465] task: ffff880136428d00 ti: ffff880136434000 task.ti: 
>ffff880136434000
>[   56.335508] RIP: 0010:[<ffffffff81718ccd>] [<ffffffff81718ccd>] 
>skb_release_data+0x7d/0x120
>[   56.335570] RSP: 0018:ffff88013bc83c80  EFLAGS: 00010206
>[   56.335609] RAX: 0000000000000000 RBX: ffff8801342cde00 RCX: 
>0000000000000011
>[   56.335650] RDX: 0000000001010a0a RSI: 00000000090000e0 RDI: 
>ffff8801342cde00
>[   56.335693] RBP: ffff88013bc83ca0 R08: 0000000000000000 R09: 
>0000000000000000
>[   56.335734] R10: 0000000000000001 R11: 0000000000000000 R12: 
>ffff8801342cde00
>[   56.335776] R13: 0000000000000000 R14: ffff8801356715c0 R15: 
>ffff8801358600a0
>[   56.335818] FS:  0000000000000000(0000) GS:ffff88013bc80000(0000) 
>knlGS:0000000000000000
>[   56.335866] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>[   56.335903] CR2: 0000000000000020 CR3: 00000000bba1f000 CR4: 
>00000000000006e0
>[   56.335945] Stack:
>[   56.335965]  ffff8801342cde00 ffff8801342cde00 ffffffff8176c757 
>ffffffff81ef48c0
>[   56.336052]  ffff88013bc83cb8 ffffffff81718d94 ffff8801342cde00 
>ffff88013bc83ce0
>[   56.336137]  ffffffff81718df2 ffff8801342cde00 ffff880135670fce 
>ffffffff81ef48c0
>[   56.336223] Call Trace:
>[   56.336244]  <IRQ>
>[   56.336338]  [<ffffffff8176c757>] ? ip_rcv_finish+0x197/0x390
>[   56.336387]  [<ffffffff81718d94>] skb_release_all+0x24/0x30
>[   56.336425]  [<ffffffff81718df2>] kfree_skb+0x32/0x90
>[   56.336461]  [<ffffffff8176c757>] ip_rcv_finish+0x197/0x390
>[   56.336498]  [<ffffffff8176d001>] ip_rcv+0x291/0x3b0
>[   56.336537]  [<ffffffff8172c6b3>]
>__netif_receive_skb_core+0x523/0xaa0
>[   56.336582]  [<ffffffff8161d773>] ?
>usb_submit_urb.part.6+0x2f3/0x560
>[   56.336622]  [<ffffffff8171d87a>] ? __build_skb+0x2a/0xe0
>[   56.336660]  [<ffffffff8172cc48>] __netif_receive_skb+0x18/0x60
>[   56.336698]  [<ffffffff8172dd48>] process_backlog+0xa8/0x150
>[   56.337576]  [<ffffffff8172d495>] net_rx_action+0x225/0x360
>[   56.337576]  [<ffffffff8161abda>] ? usb_giveback_urb_bh+0xba/0x100
>[   56.337576]  [<ffffffff8183cb66>] __do_softirq+0xf6/0x27e
>[   56.337576]  [<ffffffff810883d3>] irq_exit+0xa3/0xb0
>[   56.337576]  [<ffffffff8183c8c4>] do_IRQ+0x54/0xd0
>[   56.337576]  [<ffffffff8183a9c2>] common_interrupt+0x82/0x82
>[   56.337576]  <EOI>
>[   56.337576]  [<ffffffff816cab1a>] ? cpuidle_enter_state+0x11a/0x2c0
>[   56.337576]  [<ffffffff816cacf7>] cpuidle_enter+0x17/0x20
>[   56.337576]  [<ffffffff810c691a>] call_cpuidle+0x2a/0x50
>[   56.337576]  [<ffffffff810c6cfe>] cpu_startup_entry+0x29e/0x340
>[   56.337576]  [<ffffffff81051cbe>] start_secondary+0x15e/0x190
>[   56.337576] Code: 00 45 31 ed 41 80 3e 00 49 89 fc 75 0f eb 55 41 0f
>
>b6 06 41 83 c5 01 44 39 e8 7e 48 49 63 c5 48 83 c0 03 48 c1 e0 04 49 8b
>
>04 06 <48> 8b 50 20 48 8d 5a ff 83 e2 01 48 0f 44 d8 f0 ff 4b 1c 74 5a
>[   56.337576] RIP  [<ffffffff81718ccd>] skb_release_data+0x7d/0x120
>[   56.337576]  RSP <ffff88013bc83c80>
>[   56.337576] CR2: 0000000000000020
>[   56.337576] ---[ end trace 1e92d60587813cad ]---
>[   56.337576] Kernel panic - not syncing: Fatal exception in interrupt
>[   56.337576] Kernel Offset: disabled
>[   56.337576] ---[ end Kernel panic - not syncing: Fatal exception in 
>interrupt
>[   56.337576] ------------[ cut here ]------------
>[   56.337576] WARNING: CPU: 1 PID: 0 at 
>/home/kernel/COD/linux/kernel/time/tick-broadcast.c:642 
>tick_handle_oneshot_broadcast+0x1e5/0x1f0
>[   56.337576] Modules linked in: nouveau arc4 iwldvm mac80211 ttm 
>drm_kms_helper drm coretemp kvm_intel i2c_algo_bit snd_hda_codec_hdmi 
>pata_pcmcia fb_sys_fops kvm syscopyarea sysfillrect
>snd_hda_codec_analog 
>uvcvideo iwlwifi snd_hda_codec_generic sysimgblt hp_wmi r852 irqbypass 
>snd_hda_intel sparse_keymap ppdev videobuf2_vmalloc mxm_wmi sm_common 
>pcmcia nand snd_hda_codec videobuf2_memops nand_ecc snd_hda_core 
>nand_bch cfg80211 videobuf2_v4l2 snd_hwdep snd_pcm videobuf2_core 
>yenta_socket bch snd_timer videodev snd pcmcia_rsrc nand_ids r592 
>pcmcia_core mtd soundcore lpc_ich serio_raw pegasus memstick media 
>netconsole mii hp_accel lis3lv02d configfs input_leds joydev 
>input_polldev shpchp 8250_fintek wmi mei_me tpm_infineon parport_pc mei
>
>video lp mac_hid parport hid_generic sdhci_pci e1000e ptp usbhid 
>firewire_ohci psmouse pps_core firewire_core crc_itu_t sdhci hid 
>pata_acpi fjes
>[   56.337576] CPU: 1 PID: 0 Comm: swapper/1 Tainted: G D         
>4.6.0-040600rc2-generic #201604031130
>[   56.337576] Hardware name: Hewlett-Packard HP EliteBook 8530w/30E7, 
>BIOS 68PDV Ver. F.20 12/08/2011
>[   56.337576]  0000000000000086 5ce7513385219fe0 ffff88013bc837a8 
>ffffffff813ee8d3
>[   56.337576]  0000000000000000 0000000000000000 ffff88013bc837e8 
>ffffffff810827cb
>[   56.337576]  000002823bc837e8 7fffffffffffffff 000000000000f160 
>0000000d20aa97dc
>[   56.337576] Call Trace:
>[   56.337576]  <IRQ>  [<ffffffff813ee8d3>] dump_stack+0x63/0x90
>[   56.337576]  [<ffffffff810827cb>] __warn+0xcb/0xf0
>[   56.337576]  [<ffffffff810828fd>] warn_slowpath_null+0x1d/0x20
>[   56.337576]  [<ffffffff81101015>] 
>tick_handle_oneshot_broadcast+0x1e5/0x1f0
>[   56.337576]  [<ffffffff81031975>] timer_interrupt+0x15/0x20
>[   56.337576]  [<ffffffff810de192>] handle_irq_event_percpu+0x82/0x1c0
>[   56.337576]  [<ffffffff810de30e>] handle_irq_event+0x3e/0x60
>[   56.337576]  [<ffffffff810e19bd>] handle_edge_irq+0x7d/0x150
>[   56.337576]  [<ffffffff810312fa>] handle_irq+0x1a/0x30
>[   56.337576]  [<ffffffff8183c8bb>] do_IRQ+0x4b/0xd0
>[   56.337576]  [<ffffffff8183a9c2>] common_interrupt+0x82/0x82
>[   56.337576]  [<ffffffff811927f6>] ? panic+0x1dd/0x220
>[   56.337576]  [<ffffffff81031dbc>] oops_end+0xcc/0xd0
>[   56.337576]  [<ffffffff8106b22a>] no_context+0x13a/0x380
>[   56.337576]  [<ffffffff8106b4f1>] __bad_area_nosemaphore+0x81/0x200
>[   56.337576]  [<ffffffff8106b684>] bad_area_nosemaphore+0x14/0x20
>[   56.337576]  [<ffffffff8106ba20>] __do_page_fault+0xc0/0x4d0
>[   56.337576]  [<ffffffff811e7803>] ? dma_pool_alloc+0x1b3/0x240
>[   56.337576]  [<ffffffff813fbf6b>] ? __const_udelay+0x2b/0x30
>[   56.337576]  [<ffffffff8106be52>] do_page_fault+0x22/0x30
>[   56.337576]  [<ffffffff8183c078>] page_fault+0x28/0x30
>[   56.337576]  [<ffffffff81718ccd>] ? skb_release_data+0x7d/0x120
>[   56.337576]  [<ffffffff8176c757>] ? ip_rcv_finish+0x197/0x390
>[   56.337576]  [<ffffffff81718d94>] skb_release_all+0x24/0x30
>[   56.337576]  [<ffffffff81718df2>] kfree_skb+0x32/0x90
>[   56.337576]  [<ffffffff8176c757>] ip_rcv_finish+0x197/0x390
>[   56.337576]  [<ffffffff8176d001>] ip_rcv+0x291/0x3b0
>[   56.337576]  [<ffffffff8172c6b3>]
>__netif_receive_skb_core+0x523/0xaa0
>[   56.337576]  [<ffffffff8161d773>] ?
>usb_submit_urb.part.6+0x2f3/0x560
>[   56.337576]  [<ffffffff8171d87a>] ? __build_skb+0x2a/0xe0
>[   56.337576]  [<ffffffff8172cc48>] __netif_receive_skb+0x18/0x60
>[   56.337576]  [<ffffffff8172dd48>] process_backlog+0xa8/0x150
>[   56.337576]  [<ffffffff8172d495>] net_rx_action+0x225/0x360
>[   56.337576]  [<ffffffff8161abda>] ? usb_giveback_urb_bh+0xba/0x100
>[   56.337576]  [<ffffffff8183cb66>] __do_softirq+0xf6/0x27e
>[   56.337576]  [<ffffffff810883d3>] irq_exit+0xa3/0xb0
>[   56.337576]  [<ffffffff8183c8c4>] do_IRQ+0x54/0xd0
>[   56.337576]  [<ffffffff8183a9c2>] common_interrupt+0x82/0x82
>[   56.337576]  <EOI>  [<ffffffff816cab1a>] ? 
>cpuidle_enter_state+0x11a/0x2c0
>[   56.337576]  [<ffffffff816cacf7>] cpuidle_enter+0x17/0x20
>[   56.337576]  [<ffffffff810c691a>] call_cpuidle+0x2a/0x50
>[   56.337576]  [<ffffffff810c6cfe>] cpu_startup_entry+0x29e/0x340
>[   56.337576]  [<ffffffff81051cbe>] start_secondary+0x15e/0x190
>[   56.337576] ---[ end trace 1e92d60587813cae ]---
>
>lsb-release -rd says
>Description:    Ubuntu 14.04.4 LTS
>Release:    14.04
>
>ver_linux says
>Linux woody 4.6.0-040600rc2-generic #201604031130 SMP Sun Apr 3
>15:32:46 
>UTC 2016 x86_64 x86_64 x86_64 GNU/Linux
>
>GNU C            4.8
>GNU Make        3.81
>Binutils        2.24
>Util-linux        2.20.1
>Mount            2.20.1
>Module-init-tools    15
>E2fsprogs        1.42.9
>PPP            2.4.5
>Linux C Library        2.19
>Dynamic linker (ldd)    2.19
>Linux C++ Library    6.0.19
>Procps            3.3.9
>Net-tools        1.60
>Kbd            1.15.5
>Console-tools        1.15.5
>Sh-utils        8.21
>Udev            204
>Wireless-tools        30
>Modules Loaded        8250_fintek arc4 bch cfg80211 configfs coretemp 
>crc_itu_t drm drm_kms_helper e1000e fb_sys_fops firewire_core 
>firewire_ohci fjes hid hid_generic hp_accel hp_wmi i2c_algo_bit 
>input_leds input_polldev ip_tables iptable_nat irqbypass iwldvm iwlwifi
>
>joydev kvm kvm_intel lis3lv02d lp lpc_ich mac80211 mac_hid media mei 
>mei_me memstick mii mtd mxm_wmi nand nand_bch nand_ecc nand_ids 
>netconsole nf_conntrack nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat 
>nf_nat_ipv4 nf_nat_redirect nouveau parport parport_pc pata_acpi 
>pata_pcmcia pcmcia pcmcia_core pcmcia_rsrc pegasus ppdev pps_core 
>psmouse ptp r592 r852 sdhci sdhci_pci serio_raw shpchp sm_common snd 
>snd_hda_codec snd_hda_codec_analog snd_hda_codec_generic 
>snd_hda_codec_hdmi snd_hda_core snd_hda_intel snd_hwdep snd_pcm 
>snd_timer soundcore sparse_keymap syscopyarea sysfillrect sysimgblt 
>tpm_infineon ttm usbhid uvcvideo video videobuf2_core videobuf2_memops 
>videobuf2_v4l2 videobuf2_vmalloc videodev wmi x_tables xt_REDIRECT 
>xt_tcpudp yenta_socket
>
>/proc/cpuinfo says
>processor    : 0
>vendor_id    : GenuineIntel
>cpu family    : 6
>model        : 23
>model name    : Intel(R) Core(TM)2 Duo CPU     T9600  @ 2.80GHz
>stepping    : 6
>microcode    : 0x60f
>cpu MHz        : 800.000
>cache size    : 6144 KB
>physical id    : 0
>siblings    : 2
>core id        : 0
>cpu cores    : 2
>apicid        : 0
>initial apicid    : 0
>fpu        : yes
>fpu_exception    : yes
>cpuid level    : 10
>wp        : yes
>flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca
>
>cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall 
>nx lm constant_tsc arch_perfmon pebs bts nopl aperfmperf eagerfpu pni 
>dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm sse4_1 
>lahf_lm tpr_shadow vnmi flexpriority dtherm
>bugs        :
>bogomips    : 5585.93
>clflush size    : 64
>cache_alignment    : 64
>address sizes    : 36 bits physical, 48 bits virtual
>power management:
>
>processor    : 1
>vendor_id    : GenuineIntel
>cpu family    : 6
>model        : 23
>model name    : Intel(R) Core(TM)2 Duo CPU     T9600  @ 2.80GHz
>stepping    : 6
>microcode    : 0x60f
>cpu MHz        : 800.000
>cache size    : 6144 KB
>physical id    : 0
>siblings    : 2
>core id        : 1
>cpu cores    : 2
>apicid        : 1
>initial apicid    : 1
>fpu        : yes
>fpu_exception    : yes
>cpuid level    : 10
>wp        : yes
>flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca
>
>cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall 
>nx lm constant_tsc arch_perfmon pebs bts nopl aperfmperf eagerfpu pni 
>dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm sse4_1 
>lahf_lm tpr_shadow vnmi flexpriority dtherm
>bugs        :
>bogomips    : 5585.98
>clflush size    : 64
>cache_alignment    : 64
>address sizes    : 36 bits physical, 48 bits virtual
>power management:
>
>/proc/modules says
>pegasus 32768 0 - Live 0x0000000000000000
>mii 16384 1 pegasus, Live 0x0000000000000000
>xt_REDIRECT 16384 1 - Live 0x0000000000000000
>nf_nat_redirect 16384 1 xt_REDIRECT, Live 0x0000000000000000
>xt_tcpudp 16384 1 - Live 0x0000000000000000
>iptable_nat 16384 1 - Live 0x0000000000000000
>nf_conntrack_ipv4 16384 1 - Live 0x0000000000000000
>nf_defrag_ipv4 16384 1 nf_conntrack_ipv4, Live 0x0000000000000000
>nf_nat_ipv4 16384 1 iptable_nat, Live 0x0000000000000000
>nf_nat 24576 2 nf_nat_redirect,nf_nat_ipv4, Live 0x0000000000000000
>nf_conntrack 106496 3 nf_conntrack_ipv4,nf_nat_ipv4,nf_nat, Live 
>0x0000000000000000
>ip_tables 28672 1 iptable_nat, Live 0x0000000000000000
>x_tables 36864 3 xt_REDIRECT,xt_tcpudp,ip_tables, Live
>0x0000000000000000
>nouveau 1515520 1 - Live 0x0000000000000000
>arc4 16384 2 - Live 0x0000000000000000
>iwldvm 233472 0 - Live 0x0000000000000000
>ttm 98304 1 nouveau, Live 0x0000000000000000
>mac80211 745472 1 iwldvm, Live 0x0000000000000000
>drm_kms_helper 147456 1 nouveau, Live 0x0000000000000000
>drm 364544 4 nouveau,ttm,drm_kms_helper, Live 0x0000000000000000
>snd_hda_codec_hdmi 45056 1 - Live 0x0000000000000000
>coretemp 16384 0 - Live 0x0000000000000000
>i2c_algo_bit 16384 1 nouveau, Live 0x0000000000000000
>fb_sys_fops 16384 1 drm_kms_helper, Live 0x0000000000000000
>snd_hda_codec_analog 16384 1 - Live 0x0000000000000000
>kvm_intel 188416 0 - Live 0x0000000000000000
>snd_hda_codec_generic 73728 1 snd_hda_codec_analog, Live
>0x0000000000000000
>syscopyarea 16384 1 drm_kms_helper, Live 0x0000000000000000
>pata_pcmcia 20480 1 - Live 0x0000000000000000
>sysfillrect 16384 1 drm_kms_helper, Live 0x0000000000000000
>hp_wmi 16384 0 - Live 0x0000000000000000
>uvcvideo 90112 0 - Live 0x0000000000000000
>kvm 569344 1 kvm_intel, Live 0x0000000000000000
>snd_hda_intel 36864 0 - Live 0x0000000000000000
>sparse_keymap 16384 1 hp_wmi, Live 0x0000000000000000
>sysimgblt 16384 1 drm_kms_helper, Live 0x0000000000000000
>ppdev 20480 0 - Live 0x0000000000000000
>mxm_wmi 16384 1 nouveau, Live 0x0000000000000000
>r852 20480 0 - Live 0x0000000000000000
>iwlwifi 217088 1 iwldvm, Live 0x0000000000000000
>snd_hda_codec 135168 4 
>snd_hda_codec_hdmi,snd_hda_codec_analog,snd_hda_codec_generic,snd_hda_intel,
>
>Live 0x0000000000000000
>sm_common 20480 1 r852, Live 0x0000000000000000
>nand 69632 2 r852,sm_common, Live 0x0000000000000000
>snd_hda_core 81920 5 
>snd_hda_codec_hdmi,snd_hda_codec_analog,snd_hda_codec_generic,snd_hda_intel,snd_hda_codec,
>
>Live 0x0000000000000000
>videobuf2_vmalloc 16384 1 uvcvideo, Live 0x0000000000000000
>nand_ecc 16384 1 nand, Live 0x0000000000000000
>videobuf2_memops 16384 1 videobuf2_vmalloc, Live 0x0000000000000000
>nand_bch 16384 1 nand, Live 0x0000000000000000
>snd_hwdep 16384 1 snd_hda_codec, Live 0x0000000000000000
>videobuf2_v4l2 24576 1 uvcvideo, Live 0x0000000000000000
>bch 20480 1 nand_bch, Live 0x0000000000000000
>irqbypass 16384 1 kvm, Live 0x0000000000000000
>snd_pcm 110592 4 
>snd_hda_codec_hdmi,snd_hda_intel,snd_hda_codec,snd_hda_core, Live 
>0x0000000000000000
>videobuf2_core 40960 2 uvcvideo,videobuf2_v4l2, Live 0x0000000000000000
>nand_ids 16384 1 nand, Live 0x0000000000000000
>pcmcia 61440 1 pata_pcmcia, Live 0x0000000000000000
>mtd 57344 2 sm_common,nand, Live 0x0000000000000000
>cfg80211 581632 3 iwldvm,mac80211,iwlwifi, Live 0x0000000000000000
>videodev 180224 3 uvcvideo,videobuf2_v4l2,videobuf2_core, Live 
>0x0000000000000000
>snd_timer 32768 1 snd_pcm, Live 0x0000000000000000
>yenta_socket 45056 0 - Live 0x0000000000000000
>lpc_ich 24576 0 - Live 0x0000000000000000
>snd 81920 8 
>snd_hda_codec_hdmi,snd_hda_codec_analog,snd_hda_codec_generic,snd_hda_intel,snd_hda_codec,snd_hwdep,snd_pcm,snd_timer,
>
>Live 0x0000000000000000
>netconsole 20480 0 - Live 0x0000000000000000
>r592 20480 0 - Live 0x0000000000000000
>media 40960 2 uvcvideo,videodev, Live 0x0000000000000000
>soundcore 16384 1 snd, Live 0x0000000000000000
>pcmcia_rsrc 20480 1 yenta_socket, Live 0x0000000000000000
>pcmcia_core 24576 3 pcmcia,yenta_socket,pcmcia_rsrc, Live
>0x0000000000000000
>serio_raw 16384 0 - Live 0x0000000000000000
>memstick 20480 1 r592, Live 0x0000000000000000
>hp_accel 28672 0 - Live 0x0000000000000000
>lis3lv02d 20480 1 hp_accel, Live 0x0000000000000000
>configfs 40960 2 netconsole, Live 0x0000000000000000
>input_leds 16384 0 - Live 0x0000000000000000
>joydev 20480 0 - Live 0x0000000000000000
>input_polldev 16384 1 lis3lv02d, Live 0x0000000000000000
>shpchp 36864 0 - Live 0x0000000000000000
>8250_fintek 16384 0 - Live 0x0000000000000000
>mei_me 32768 0 - Live 0x0000000000000000
>tpm_infineon 20480 0 - Live 0x0000000000000000
>parport_pc 32768 1 - Live 0x0000000000000000
>mei 102400 1 mei_me, Live 0x0000000000000000
>video 40960 1 nouveau, Live 0x0000000000000000
>lp 20480 0 - Live 0x0000000000000000
>wmi 20480 3 nouveau,hp_wmi,mxm_wmi, Live 0x0000000000000000
>mac_hid 16384 0 - Live 0x0000000000000000
>parport 49152 3 ppdev,parport_pc,lp, Live 0x0000000000000000
>hid_generic 16384 0 - Live 0x0000000000000000
>e1000e 237568 0 - Live 0x0000000000000000
>usbhid 49152 0 - Live 0x0000000000000000
>ptp 20480 1 e1000e, Live 0x0000000000000000
>sdhci_pci 28672 0 - Live 0x0000000000000000
>firewire_ohci 40960 0 - Live 0x0000000000000000
>psmouse 131072 0 - Live 0x0000000000000000
>firewire_core 65536 1 firewire_ohci, Live 0x0000000000000000
>crc_itu_t 16384 1 firewire_core, Live 0x0000000000000000
>sdhci 45056 1 sdhci_pci, Live 0x0000000000000000
>hid 122880 2 hid_generic,usbhid, Live 0x0000000000000000
>pps_core 20480 1 ptp, Live 0x0000000000000000
>pata_acpi 16384 0 - Live 0x0000000000000000
>fjes 28672 0 - Live 0x0000000000000000
>
>/proc/ioports says
>0000-0cf7 : PCI Bus 0000:00
>   0000-001f : dma1
>   0020-0021 : pic1
>   0040-0043 : timer0
>   0050-0053 : timer1
>   0060-0060 : keyboard
>   0062-0062 : PNP0C09:00
>     0062-0062 : EC data
>   0064-0064 : keyboard
>   0066-0066 : PNP0C09:00
>     0066-0066 : EC cmd
>   0070-0077 : rtc0
>   0080-008f : dma page reg
>   00a0-00a1 : pic2
>   00c0-00df : dma2
>   00f0-00ff : fpu
>     00f0-00f0 : PNP0C04:00
>   0170-0177 : 0000:00:1f.2
>     0170-0177 : ata_piix
>   01f0-01f7 : 0000:00:1f.2
>     01f0-01f7 : ata_piix
>   0200-027f : pnp 00:03
>   0376-0376 : 0000:00:1f.2
>     0376-0376 : ata_piix
>   0378-037a : parport0
>   037b-037f : parport0
>   03c0-03df : vesafb
>   03f6-03f6 : 0000:00:1f.2
>     03f6-03f6 : ata_piix
>   03f8-03ff : serial
>   0400-0403 : ACPI PM1a_EVT_BLK
>   0404-0405 : ACPI PM1a_CNT_BLK
>   0408-040b : ACPI PM_TMR
>   0410-0415 : ACPI CPU throttle
>   0420-042f : ACPI GPE0_BLK
>   0430-0433 : iTCO_wdt.0.auto
>   0450-0450 : ACPI PM2_CNT_BLK
>   0460-047f : iTCO_wdt.0.auto
>   0500-057f : pnp 00:03
>   0778-077a : parport0
>0cf8-0cff : PCI conf1
>0d00-ffff : PCI Bus 0000:00
>   1000-1003 : pnp 00:03
>   1010-101f : pnp 00:03
>   2000-2fff : PCI Bus 0000:86
>     2000-20ff : PCI CardBus 0000:87
>     2100-210f : pcmcia_socket0
>       2100-210f : pcmcia0.0
>     2400-24ff : PCI CardBus 0000:87
>   3000-4fff : PCI Bus 0000:45
>   5000-6fff : PCI Bus 0000:04
>   7000-7fff : PCI Bus 0000:01
>     7000-707f : 0000:01:00.0
>   8000-801f : 0000:00:1d.2
>     8000-801f : uhci_hcd
>   8020-803f : 0000:00:1d.1
>     8020-803f : uhci_hcd
>   8040-805f : 0000:00:1d.0
>     8040-805f : uhci_hcd
>   8060-807f : 0000:00:1a.2
>     8060-807f : uhci_hcd
>   8080-809f : 0000:00:1a.1
>     8080-809f : uhci_hcd
>   80a0-80bf : 0000:00:1a.0
>     80a0-80bf : uhci_hcd
>   80c0-80df : 0000:00:19.0
>   80e0-80ef : 0000:00:1f.5
>     80e0-80ef : ata_piix
>   80f0-80ff : 0000:00:1f.5
>     80f0-80ff : ata_piix
>   8100-810f : 0000:00:1f.2
>     8100-810f : ata_piix
>   8110-811f : 0000:00:1f.2
>     8110-811f : ata_piix
>   8120-812f : 0000:00:03.2
>   8130-8137 : 0000:00:1f.5
>     8130-8137 : ata_piix
>   8138-813f : 0000:00:1f.5
>     8138-813f : ata_piix
>   8150-8157 : 0000:00:03.3
>     8150-8157 : serial
>   8158-815f : 0000:00:03.2
>   8160-8167 : 0000:00:03.2
>   8168-816b : 0000:00:1f.5
>     8168-816b : ata_piix
>   816c-816f : 0000:00:1f.5
>     816c-816f : ata_piix
>   8178-817b : 0000:00:03.2
>   817c-817f : 0000:00:03.2
>   9000-9fff : PCI Bus 0000:02
>   a000-afff : PCI Bus 0000:03
>   ef80-ef9f : pnp 00:03
>   ffff-ffff : pnp 00:03
>
>/proc/iomem says
>00000000-00000fff : reserved
>00001000-0009fbff : System RAM
>0009fc00-0009ffff : reserved
>000a0000-000bffff : PCI Bus 0000:00
>000c0000-000ce1ff : Video ROM
>000ce800-000cf7ff : Adapter ROM
>000cf800-000d07ff : Adapter ROM
>000ef000-000fffff : reserved
>   000f0000-000fffff : System ROM
>00100000-b8e1dfff : System RAM
>   01000000-0183eff7 : Kernel code
>   0183eff8-01f4347f : Kernel data
>   020c6000-02207fff : Kernel bss
>b8e1e000-b8e1ffff : reserved
>b8e20000-b9d6ffff : System RAM
>b9d70000-b9d7ffff : ACPI Non-volatile Storage
>b9d80000-bc492fff : System RAM
>bc493000-bc692fff : ACPI Non-volatile Storage
>bc693000-bde91fff : System RAM
>bde92000-bde99fff : reserved
>bde9a000-bdebefff : System RAM
>bdebf000-bdecefff : reserved
>bdecf000-bdfcefff : ACPI Non-volatile Storage
>bdfcf000-bdffefff : ACPI Tables
>bdfff000-bdffffff : System RAM
>be000000-bfffffff : reserved
>c0000000-dfffffff : PCI Bus 0000:00
>   c0000000-cfffffff : PCI Bus 0000:01
>     c0000000-cfffffff : 0000:01:00.0
>   d0000000-d2ffffff : PCI Bus 0000:01
>     d0000000-d1ffffff : 0000:01:00.0
>     d2000000-d2ffffff : 0000:01:00.0
>   d3000000-d30fffff : PCI Bus 0000:86
>     d3000000-d3000fff : 0000:86:09.4
>       d3000000-d3000fff : yenta_socket
>     d3001000-d30017ff : 0000:86:09.0
>       d3001000-d30017ff : firewire_ohci
>     d3001800-d30018ff : 0000:86:09.3
>       d3001800-d30018ff : r852
>     d3001900-d30019ff : 0000:86:09.2
>       d3001900-d30019ff : r592
>     d3001b00-d3001bff : 0000:86:09.1
>       d3001b00-d3001bff : mmc0
>     d3010000-d3010fff : pcmcia_socket0
>   d3100000-d70fffff : PCI Bus 0000:45
>   d7100000-db0fffff : PCI Bus 0000:04
>   db100000-db1fffff : PCI Bus 0000:03
>     db100000-db101fff : 0000:03:00.0
>       db100000-db101fff : iwlwifi
>   db200000-db2fffff : PCI Bus 0000:02
>   db300000-db31ffff : 0000:00:19.0
>     db300000-db31ffff : e1000e
>   db320000-db323fff : 0000:00:1b.0
>     db320000-db323fff : ICH HD audio
>   db324000-db324fff : 0000:00:19.0
>     db324000-db324fff : e1000e
>   db325000-db325fff : 0000:00:03.3
>   db326000-db3263ff : 0000:00:1d.7
>     db326000-db3263ff : ehci_hcd
>   db326400-db3267ff : 0000:00:1a.7
>     db326400-db3267ff : ehci_hcd
>   db326800-db32680f : 0000:00:03.0
>     db326800-db32680f : mei_me
>   db400000-db5fffff : PCI Bus 0000:02
>   db600000-db7fffff : PCI Bus 0000:03
>   db800000-db9fffff : PCI Bus 0000:04
>   dba00000-dbbfffff : PCI Bus 0000:45
>   dc000000-dfffffff : PCI CardBus 0000:87
>e0000000-efffffff : PCI MMCONFIG 0000 [bus 00-ff]
>   e0000000-efffffff : reserved
>     e0000000-efffffff : pnp 00:00
>f0000000-fedfffff : PCI Bus 0000:00
>   f0000000-f3ffffff : PCI CardBus 0000:87
>   fec00000-fec00fff : reserved
>     fec00000-fec003ff : IOAPIC 0
>   fed00000-fed003ff : HPET 0
>     fed00000-fed003ff : pnp 00:02
>   fed10000-fed13fff : reserved
>     fed10000-fed13fff : pnp 00:00
>   fed18000-fed19fff : reserved
>     fed18000-fed18fff : pnp 00:00
>     fed19000-fed19fff : pnp 00:00
>   fed1c000-fed1ffff : reserved
>     fed1c000-fed1ffff : pnp 00:00
>       fed1f410-fed1f414 : iTCO_wdt.0.auto
>   fed20000-fed3ffff : pnp 00:00
>   fed40000-fed44fff : GTPM
>   fed45000-fed8ffff : pnp 00:00
>fee00000-fee00fff : Local APIC
>   fee00000-fee00fff : reserved
>fee01000-ffffffff : PCI Bus 0000:00
>   ff000000-ffffffff : INT0800:00
>     ffe80000-ffffffff : reserved
>100000000-13bffffff : System RAM
>
>sudo lspci -vvv says
>00:00.0 Host bridge: Intel Corporation Mobile 4 Series Chipset Memory 
>Controller Hub (rev 07)
>     Subsystem: Hewlett-Packard Company Device 30e7
>   Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
>Stepping- SERR- FastB2B- DisINTx-
>     Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- 
><TAbort- <MAbort+ >SERR- <PERR- INTx-
>     Latency: 0
>     Capabilities: [e0] Vendor Specific Information: Len=0a <?>
>
>00:01.0 PCI bridge: Intel Corporation Mobile 4 Series Chipset PCI 
>Express Graphics Port (rev 07) (prog-if 00 [Normal decode])
>   Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
>Stepping- SERR- FastB2B- DisINTx+
>     Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
><TAbort- <MAbort- >SERR- <PERR- INTx-
>     Latency: 0, Cache Line Size: 64 bytes
>     Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
>     I/O behind bridge: 00007000-00007fff
>     Memory behind bridge: d0000000-d2ffffff
>   Prefetchable memory behind bridge: 00000000c0000000-00000000cfffffff
>     Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- 
><TAbort- <MAbort+ <SERR- <PERR-
>     BridgeCtl: Parity- SERR- NoISA- VGA+ MAbort- >Reset- FastB2B-
>         PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
>     Capabilities: [88] Subsystem: Hewlett-Packard Company Device 30e7
>     Capabilities: [80] Power Management version 3
>         Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA 
>PME(D0+,D1-,D2-,D3hot+,D3cold+)
>         Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
>     Capabilities: [90] MSI: Enable+ Count=1/1 Maskable- 64bit-
>         Address: fee0300c  Data: 41e1
>     Capabilities: [a0] Express (v1) Root Port (Slot+), MSI 00
>         DevCap:    MaxPayload 128 bytes, PhantFunc 0
>             ExtTag- RBE+
>         DevCtl:    Report errors: Correctable- Non-Fatal- Fatal- 
>Unsupported-
>             RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
>             MaxPayload 128 bytes, MaxReadReq 128 bytes
>         DevSta:    CorrErr+ UncorrErr- FatalErr- UnsuppReq- AuxPwr- 
>TransPend-
>       LnkCap:    Port #2, Speed 2.5GT/s, Width x16, ASPM L0s L1, Exit 
>Latency L0s <256ns, L1 <4us
>             ClockPM- Surprise- LLActRep- BwNot-
>        LnkCtl:    ASPM L0s L1 Enabled; RCB 64 bytes Disabled- CommClk+
>             ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>         LnkSta:    Speed 2.5GT/s, Width x16, TrErr- Train- SlotClk+ 
>DLActive- BWMgmt- ABWMgmt-
>         SltCap:    AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ 
>Surprise-
>             Slot #1, PowerLimit 75.000W; Interlock- NoCompl+
>         SltCtl:    Enable: AttnBtn- PwrFlt- MRL- PresDet+ CmdCplt- 
>HPIrq+ LinkChg-
>             Control: AttnInd Off, PwrInd On, Power- Interlock-
>         SltSta:    Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ 
>Interlock-
>             Changed: MRL- PresDet- LinkState-
>         RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna+ 
>CRSVisible-
>         RootCap: CRSVisible-
>         RootSta: PME ReqID 0000, PMEStatus- PMEPending-
>     Capabilities: [100 v1] Virtual Channel
>         Caps:    LPEVC=0 RefClk=100ns PATEntryBits=1
>         Arb:    Fixed+ WRR32- WRR64- WRR128-
>         Ctrl:    ArbSelect=Fixed
>         Status:    InProgress-
>         VC0:    Caps:    PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
>             Arb:    Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
>             Ctrl:    Enable+ ID=0 ArbSelect=Fixed TC/VC=01
>             Status:    NegoPending- InProgress-
>     Capabilities: [140 v1] Root Complex Link
>         Desc:    PortNumber=02 ComponentID=01 EltType=Config
>        Link0:    Desc:    TargetPort=00 TargetComponent=01 AssocRCRB- 
>LinkType=MemMapped LinkValid+
>             Addr:    00000000fed19000
>     Kernel driver in use: pcieport
>
>00:03.0 Communication controller: Intel Corporation Mobile 4 Series 
>Chipset MEI Controller (rev 07)
>     Subsystem: Hewlett-Packard Company Device 30e7
>   Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
>Stepping- SERR- FastB2B- DisINTx+
>     Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
><TAbort- <MAbort- >SERR- <PERR- INTx-
>     Latency: 0
>     Interrupt: pin A routed to IRQ 30
>     Region 0: Memory at db326800 (64-bit, non-prefetchable) [size=16]
>     Capabilities: [50] Power Management version 3
>         Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA 
>PME(D0+,D1-,D2-,D3hot+,D3cold+)
>         Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
>     Capabilities: [8c] MSI: Enable+ Count=1/1 Maskable- 64bit+
>         Address: 00000000fee0300c  Data: 41e2
>     Kernel driver in use: mei_me
>
>00:03.2 IDE interface: Intel Corporation Mobile 4 Series Chipset PT
>IDER 
>Controller (rev 07) (prog-if 85 [Master SecO PriO])
>     Subsystem: Hewlett-Packard Company Device 30e7
>   Control: I/O+ Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- 
>Stepping- SERR- FastB2B- DisINTx-
>     Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- 
><TAbort- <MAbort- >SERR- <PERR- INTx-
>     Interrupt: pin C routed to IRQ 18
>     Region 0: I/O ports at 8160 [size=8]
>     Region 1: I/O ports at 817c [size=4]
>     Region 2: I/O ports at 8158 [size=8]
>     Region 3: I/O ports at 8178 [size=4]
>     Region 4: I/O ports at 8120 [size=16]
>     Capabilities: [c8] Power Management version 3
>         Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA 
>PME(D0-,D1-,D2-,D3hot-,D3cold-)
>         Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
>     Capabilities: [d0] MSI: Enable- Count=1/1 Maskable- 64bit+
>         Address: 0000000000000000  Data: 0000
>
>00:03.3 Serial controller: Intel Corporation Mobile 4 Series Chipset
>AMT 
>SOL Redirection (rev 07) (prog-if 02 [16550])
>     Subsystem: Hewlett-Packard Company Device 30e7
>   Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
>Stepping- SERR- FastB2B- DisINTx-
>     Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- 
><TAbort- <MAbort- >SERR- <PERR- INTx-
>     Latency: 0
>     Interrupt: pin B routed to IRQ 17
>     Region 0: I/O ports at 8150 [size=8]
>     Region 1: Memory at db325000 (32-bit, non-prefetchable) [size=4K]
>     Capabilities: [c8] Power Management version 3
>         Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA 
>PME(D0-,D1-,D2-,D3hot-,D3cold-)
>         Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
>     Capabilities: [d0] MSI: Enable- Count=1/1 Maskable- 64bit+
>         Address: 0000000000000000  Data: 0000
>     Kernel driver in use: serial
>
>00:19.0 Ethernet controller: Intel Corporation 82567LM Gigabit Network 
>Connection (rev 03)
>     Subsystem: Hewlett-Packard Company Device 30e7
>   Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
>Stepping- SERR- FastB2B- DisINTx+
>     Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
><TAbort- <MAbort- >SERR- <PERR- INTx-
>     Latency: 0
>     Interrupt: pin A routed to IRQ 29
>    Region 0: Memory at db300000 (32-bit, non-prefetchable) [size=128K]
>     Region 1: Memory at db324000 (32-bit, non-prefetchable) [size=4K]
>     Region 2: I/O ports at 80c0 [size=32]
>     Capabilities: [c8] Power Management version 2
>         Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA 
>PME(D0+,D1-,D2-,D3hot+,D3cold+)
>         Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME-
>     Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
>         Address: 00000000fee0200c  Data: 4143
>     Capabilities: [e0] PCI Advanced Features
>         AFCap: TP+ FLR+
>         AFCtrl: FLR-
>         AFStatus: TP-
>     Kernel driver in use: e1000e
>
>00:1a.0 USB controller: Intel Corporation 82801I (ICH9 Family) USB UHCI
>
>Controller #4 (rev 03) (prog-if 00 [UHCI])
>     Subsystem: Hewlett-Packard Company Device 30e7
>   Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
>Stepping- SERR- FastB2B- DisINTx-
>     Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
><TAbort- <MAbort- >SERR- <PERR- INTx-
>     Latency: 0
>     Interrupt: pin A routed to IRQ 16
>     Region 4: I/O ports at 80a0 [size=32]
>     Capabilities: [50] PCI Advanced Features
>         AFCap: TP+ FLR+
>         AFCtrl: FLR-
>         AFStatus: TP-
>     Kernel driver in use: uhci_hcd
>
>00:1a.1 USB controller: Intel Corporation 82801I (ICH9 Family) USB UHCI
>
>Controller #5 (rev 03) (prog-if 00 [UHCI])
>     Subsystem: Hewlett-Packard Company Device 30e7
>   Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
>Stepping- SERR- FastB2B- DisINTx-
>     Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
><TAbort- <MAbort- >SERR- <PERR- INTx-
>     Latency: 0
>     Interrupt: pin B routed to IRQ 17
>     Region 4: I/O ports at 8080 [size=32]
>     Capabilities: [50] PCI Advanced Features
>         AFCap: TP+ FLR+
>         AFCtrl: FLR-
>         AFStatus: TP-
>     Kernel driver in use: uhci_hcd
>
>00:1a.2 USB controller: Intel Corporation 82801I (ICH9 Family) USB UHCI
>
>Controller #6 (rev 03) (prog-if 00 [UHCI])
>     Subsystem: Hewlett-Packard Company Device 30e7
>   Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
>Stepping- SERR- FastB2B- DisINTx-
>     Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
><TAbort- <MAbort- >SERR- <PERR- INTx-
>     Latency: 0
>     Interrupt: pin C routed to IRQ 18
>     Region 4: I/O ports at 8060 [size=32]
>     Capabilities: [50] PCI Advanced Features
>         AFCap: TP+ FLR+
>         AFCtrl: FLR-
>         AFStatus: TP-
>     Kernel driver in use: uhci_hcd
>
>00:1a.7 USB controller: Intel Corporation 82801I (ICH9 Family) USB2
>EHCI 
>Controller #2 (rev 03) (prog-if 20 [EHCI])
>     Subsystem: Hewlett-Packard Company Device 30e7
>   Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
>Stepping- SERR- FastB2B- DisINTx-
>     Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
><TAbort- <MAbort- >SERR- <PERR- INTx-
>     Latency: 0
>     Interrupt: pin D routed to IRQ 19
>     Region 0: Memory at db326400 (32-bit, non-prefetchable) [size=1K]
>     Capabilities: [50] Power Management version 2
>         Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA 
>PME(D0+,D1-,D2-,D3hot+,D3cold+)
>         Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME+
>     Capabilities: [58] Debug port: BAR=1 offset=00a0
>     Capabilities: [98] PCI Advanced Features
>         AFCap: TP+ FLR+
>         AFCtrl: FLR-
>         AFStatus: TP-
>     Kernel driver in use: ehci-pci
>
>00:1b.0 Audio device: Intel Corporation 82801I (ICH9 Family) HD Audio 
>Controller (rev 03)
>     Subsystem: Hewlett-Packard Company Device 30e7
>   Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
>Stepping- SERR- FastB2B- DisINTx+
>     Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
><TAbort- <MAbort- >SERR- <PERR- INTx-
>     Latency: 0, Cache Line Size: 64 bytes
>     Interrupt: pin A routed to IRQ 32
>     Region 0: Memory at db320000 (64-bit, non-prefetchable) [size=16K]
>     Capabilities: [50] Power Management version 2
>         Flags: PMEClk- DSI- D1- D2- AuxCurrent=55mA 
>PME(D0+,D1-,D2-,D3hot+,D3cold+)
>         Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
>     Capabilities: [60] MSI: Enable+ Count=1/1 Maskable- 64bit+
>         Address: 00000000fee0300c  Data: 4163
>     Capabilities: [70] Express (v1) Root Complex Integrated Endpoint, 
>MSI 00
>         DevCap:    MaxPayload 128 bytes, PhantFunc 0
>             ExtTag- RBE-
>         DevCtl:    Report errors: Correctable- Non-Fatal- Fatal- 
>Unsupported-
>             RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
>             MaxPayload 128 bytes, MaxReadReq 128 bytes
>         DevSta:    CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ 
>TransPend-
>     Capabilities: [100 v1] Virtual Channel
>         Caps:    LPEVC=0 RefClk=100ns PATEntryBits=1
>         Arb:    Fixed- WRR32- WRR64- WRR128-
>         Ctrl:    ArbSelect=Fixed
>         Status:    InProgress-
>         VC0:    Caps:    PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
>             Arb:    Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
>             Ctrl:    Enable+ ID=0 ArbSelect=Fixed TC/VC=7f
>             Status:    NegoPending- InProgress-
>         VC1:    Caps:    PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
>             Arb:    Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
>             Ctrl:    Enable+ ID=1 ArbSelect=Fixed TC/VC=80
>             Status:    NegoPending- InProgress-
>     Capabilities: [130 v1] Root Complex Link
>         Desc:    PortNumber=0f ComponentID=02 EltType=Config
>        Link0:    Desc:    TargetPort=00 TargetComponent=02 AssocRCRB- 
>LinkType=MemMapped LinkValid+
>             Addr:    00000000fed1c000
>     Kernel driver in use: snd_hda_intel
>
>00:1c.0 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express 
>Port 1 (rev 03) (prog-if 00 [Normal decode])
>   Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
>Stepping- SERR- FastB2B- DisINTx+
>     Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
><TAbort- <MAbort- >SERR- <PERR- INTx-
>     Latency: 0, Cache Line Size: 64 bytes
>     Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
>     I/O behind bridge: 00009000-00009fff
>     Memory behind bridge: db200000-db2fffff
>   Prefetchable memory behind bridge: 00000000db400000-00000000db5fffff
>     Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- 
><TAbort- <MAbort+ <SERR- <PERR-
>     BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
>         PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
>     Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
>         DevCap:    MaxPayload 128 bytes, PhantFunc 0
>             ExtTag- RBE+
>         DevCtl:    Report errors: Correctable- Non-Fatal- Fatal- 
>Unsupported-
>             RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
>             MaxPayload 128 bytes, MaxReadReq 128 bytes
>         DevSta:    CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ 
>TransPend-
>        LnkCap:    Port #1, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit 
>Latency L0s <1us, L1 <4us
>             ClockPM- Surprise- LLActRep+ BwNot-
>         LnkCtl:    ASPM Disabled; RCB 64 bytes Disabled- CommClk-
>             ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>         LnkSta:    Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ 
>DLActive- BWMgmt- ABWMgmt-
>         SltCap:    AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ 
>Surprise+
>             Slot #0, PowerLimit 6.500W; Interlock- NoCompl-
>         SltCtl:    Enable: AttnBtn- PwrFlt- MRL- PresDet+ CmdCplt+ 
>HPIrq+ LinkChg+
>            Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
>         SltSta:    Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- 
>Interlock-
>             Changed: MRL- PresDet- LinkState-
>         RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna+ 
>CRSVisible-
>         RootCap: CRSVisible-
>         RootSta: PME ReqID 0000, PMEStatus- PMEPending-
>     Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
>         Address: fee0300c  Data: 4122
>     Capabilities: [90] Subsystem: Device 0000:0000
>     Capabilities: [a0] Power Management version 2
>         Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA 
>PME(D0+,D1-,D2-,D3hot+,D3cold+)
>         Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
>     Capabilities: [100 v1] Virtual Channel
>         Caps:    LPEVC=0 RefClk=100ns PATEntryBits=1
>         Arb:    Fixed+ WRR32- WRR64- WRR128-
>         Ctrl:    ArbSelect=Fixed
>         Status:    InProgress-
>         VC0:    Caps:    PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
>             Arb:    Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
>             Ctrl:    Enable+ ID=0 ArbSelect=Fixed TC/VC=01
>             Status:    NegoPending- InProgress-
>     Capabilities: [180 v1] Root Complex Link
>         Desc:    PortNumber=01 ComponentID=02 EltType=Config
>        Link0:    Desc:    TargetPort=00 TargetComponent=02 AssocRCRB- 
>LinkType=MemMapped LinkValid+
>             Addr:    00000000fed1c000
>     Kernel driver in use: pcieport
>
>00:1c.1 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express 
>Port 2 (rev 03) (prog-if 00 [Normal decode])
>   Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
>Stepping- SERR- FastB2B- DisINTx+
>     Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
><TAbort- <MAbort- >SERR- <PERR- INTx-
>     Latency: 0, Cache Line Size: 64 bytes
>     Bus: primary=00, secondary=03, subordinate=03, sec-latency=0
>     I/O behind bridge: 0000a000-0000afff
>     Memory behind bridge: db100000-db1fffff
>   Prefetchable memory behind bridge: 00000000db600000-00000000db7fffff
>     Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- 
><TAbort- <MAbort+ <SERR- <PERR-
>     BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
>         PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
>     Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
>         DevCap:    MaxPayload 128 bytes, PhantFunc 0
>             ExtTag- RBE+
>         DevCtl:    Report errors: Correctable- Non-Fatal- Fatal- 
>Unsupported-
>             RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
>             MaxPayload 128 bytes, MaxReadReq 128 bytes
>         DevSta:    CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ 
>TransPend-
>        LnkCap:    Port #2, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit 
>Latency L0s <256ns, L1 <4us
>             ClockPM- Surprise- LLActRep+ BwNot-
>         LnkCtl:    ASPM L1 Enabled; RCB 64 bytes Disabled- CommClk+
>             ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>         LnkSta:    Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ 
>DLActive+ BWMgmt- ABWMgmt-
>         SltCap:    AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ 
>Surprise+
>             Slot #1, PowerLimit 6.500W; Interlock- NoCompl-
>         SltCtl:    Enable: AttnBtn- PwrFlt- MRL- PresDet+ CmdCplt+ 
>HPIrq+ LinkChg+
>            Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
>         SltSta:    Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ 
>Interlock-
>             Changed: MRL- PresDet- LinkState-
>         RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna+ 
>CRSVisible-
>         RootCap: CRSVisible-
>         RootSta: PME ReqID 0000, PMEStatus- PMEPending-
>     Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
>         Address: fee0300c  Data: 4152
>     Capabilities: [90] Subsystem: Device 0000:0000
>     Capabilities: [a0] Power Management version 2
>         Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA 
>PME(D0+,D1-,D2-,D3hot+,D3cold+)
>         Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
>     Capabilities: [100 v1] Virtual Channel
>         Caps:    LPEVC=0 RefClk=100ns PATEntryBits=1
>         Arb:    Fixed+ WRR32- WRR64- WRR128-
>         Ctrl:    ArbSelect=Fixed
>         Status:    InProgress-
>         VC0:    Caps:    PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
>             Arb:    Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
>             Ctrl:    Enable+ ID=0 ArbSelect=Fixed TC/VC=01
>             Status:    NegoPending- InProgress-
>     Capabilities: [180 v1] Root Complex Link
>         Desc:    PortNumber=02 ComponentID=02 EltType=Config
>        Link0:    Desc:    TargetPort=00 TargetComponent=02 AssocRCRB- 
>LinkType=MemMapped LinkValid+
>             Addr:    00000000fed1c000
>     Kernel driver in use: pcieport
>
>00:1c.2 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express 
>Port 3 (rev 03) (prog-if 00 [Normal decode])
>   Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
>Stepping- SERR- FastB2B- DisINTx+
>     Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
><TAbort- <MAbort- >SERR- <PERR- INTx-
>     Latency: 0, Cache Line Size: 64 bytes
>     Bus: primary=00, secondary=04, subordinate=44, sec-latency=0
>     I/O behind bridge: 00005000-00006fff
>     Memory behind bridge: d7100000-db0fffff
>   Prefetchable memory behind bridge: 00000000db800000-00000000db9fffff
>     Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- 
><TAbort- <MAbort+ <SERR- <PERR-
>     BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
>         PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
>     Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
>         DevCap:    MaxPayload 128 bytes, PhantFunc 0
>             ExtTag- RBE+
>         DevCtl:    Report errors: Correctable- Non-Fatal- Fatal- 
>Unsupported-
>             RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
>             MaxPayload 128 bytes, MaxReadReq 128 bytes
>         DevSta:    CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ 
>TransPend-
>        LnkCap:    Port #3, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit 
>Latency L0s <1us, L1 <4us
>             ClockPM- Surprise- LLActRep+ BwNot-
>         LnkCtl:    ASPM Disabled; RCB 64 bytes Disabled- CommClk-
>             ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>         LnkSta:    Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ 
>DLActive- BWMgmt- ABWMgmt-
>         SltCap:    AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ 
>Surprise+
>             Slot #2, PowerLimit 6.500W; Interlock- NoCompl-
>         SltCtl:    Enable: AttnBtn- PwrFlt- MRL- PresDet+ CmdCplt+ 
>HPIrq+ LinkChg+
>            Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
>         SltSta:    Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- 
>Interlock-
>             Changed: MRL- PresDet- LinkState-
>         RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna+ 
>CRSVisible-
>         RootCap: CRSVisible-
>         RootSta: PME ReqID 0000, PMEStatus- PMEPending-
>     Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
>         Address: fee0300c  Data: 4172
>     Capabilities: [90] Subsystem: Device 0000:0000
>     Capabilities: [a0] Power Management version 2
>         Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA 
>PME(D0+,D1-,D2-,D3hot+,D3cold+)
>         Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
>     Capabilities: [100 v1] Virtual Channel
>         Caps:    LPEVC=0 RefClk=100ns PATEntryBits=1
>         Arb:    Fixed+ WRR32- WRR64- WRR128-
>         Ctrl:    ArbSelect=Fixed
>         Status:    InProgress-
>         VC0:    Caps:    PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
>             Arb:    Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
>             Ctrl:    Enable+ ID=0 ArbSelect=Fixed TC/VC=01
>             Status:    NegoPending- InProgress-
>     Capabilities: [180 v1] Root Complex Link
>         Desc:    PortNumber=03 ComponentID=02 EltType=Config
>        Link0:    Desc:    TargetPort=00 TargetComponent=02 AssocRCRB- 
>LinkType=MemMapped LinkValid+
>             Addr:    00000000fed1c000
>     Kernel driver in use: pcieport
>
>00:1c.4 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express 
>Port 5 (rev 03) (prog-if 00 [Normal decode])
>   Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
>Stepping- SERR- FastB2B- DisINTx+
>     Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
><TAbort- <MAbort- >SERR- <PERR- INTx-
>     Latency: 0, Cache Line Size: 64 bytes
>     Bus: primary=00, secondary=45, subordinate=85, sec-latency=0
>     I/O behind bridge: 00003000-00004fff
>     Memory behind bridge: d3100000-d70fffff
>   Prefetchable memory behind bridge: 00000000dba00000-00000000dbbfffff
>     Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- 
><TAbort- <MAbort+ <SERR- <PERR-
>     BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
>         PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
>     Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
>         DevCap:    MaxPayload 128 bytes, PhantFunc 0
>             ExtTag- RBE+
>         DevCtl:    Report errors: Correctable- Non-Fatal- Fatal- 
>Unsupported-
>             RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
>             MaxPayload 128 bytes, MaxReadReq 128 bytes
>         DevSta:    CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ 
>TransPend-
>        LnkCap:    Port #5, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit 
>Latency L0s <1us, L1 <4us
>             ClockPM- Surprise- LLActRep+ BwNot-
>         LnkCtl:    ASPM Disabled; RCB 64 bytes Disabled- CommClk-
>             ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>         LnkSta:    Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ 
>DLActive- BWMgmt- ABWMgmt-
>         SltCap:    AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ 
>Surprise+
>             Slot #4, PowerLimit 6.500W; Interlock- NoCompl-
>         SltCtl:    Enable: AttnBtn- PwrFlt- MRL- PresDet+ CmdCplt+ 
>HPIrq+ LinkChg+
>            Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
>         SltSta:    Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- 
>Interlock-
>             Changed: MRL- PresDet- LinkState-
>         RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna+ 
>CRSVisible-
>         RootCap: CRSVisible-
>         RootSta: PME ReqID 0000, PMEStatus- PMEPending-
>     Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
>         Address: fee0300c  Data: 4182
>     Capabilities: [90] Subsystem: Device 0000:0000
>     Capabilities: [a0] Power Management version 2
>         Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA 
>PME(D0+,D1-,D2-,D3hot+,D3cold+)
>         Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
>     Capabilities: [100 v1] Virtual Channel
>         Caps:    LPEVC=0 RefClk=100ns PATEntryBits=1
>         Arb:    Fixed+ WRR32- WRR64- WRR128-
>         Ctrl:    ArbSelect=Fixed
>         Status:    InProgress-
>         VC0:    Caps:    PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
>             Arb:    Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
>             Ctrl:    Enable+ ID=0 ArbSelect=Fixed TC/VC=01
>             Status:    NegoPending- InProgress-
>     Capabilities: [180 v1] Root Complex Link
>         Desc:    PortNumber=05 ComponentID=02 EltType=Config
>        Link0:    Desc:    TargetPort=00 TargetComponent=02 AssocRCRB- 
>LinkType=MemMapped LinkValid+
>             Addr:    00000000fed1c000
>     Kernel driver in use: pcieport
>
>00:1d.0 USB controller: Intel Corporation 82801I (ICH9 Family) USB UHCI
>
>Controller #1 (rev 03) (prog-if 00 [UHCI])
>     Subsystem: Hewlett-Packard Company Device 30e7
>   Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
>Stepping- SERR- FastB2B- DisINTx-
>     Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
><TAbort- <MAbort- >SERR- <PERR- INTx-
>     Latency: 0
>     Interrupt: pin A routed to IRQ 20
>     Region 4: I/O ports at 8040 [size=32]
>     Capabilities: [50] PCI Advanced Features
>         AFCap: TP+ FLR+
>         AFCtrl: FLR-
>         AFStatus: TP-
>     Kernel driver in use: uhci_hcd
>
>00:1d.1 USB controller: Intel Corporation 82801I (ICH9 Family) USB UHCI
>
>Controller #2 (rev 03) (prog-if 00 [UHCI])
>     Subsystem: Hewlett-Packard Company Device 30e7
>   Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
>Stepping- SERR- FastB2B- DisINTx-
>     Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
><TAbort- <MAbort- >SERR- <PERR- INTx-
>     Latency: 0
>     Interrupt: pin B routed to IRQ 22
>     Region 4: I/O ports at 8020 [size=32]
>     Capabilities: [50] PCI Advanced Features
>         AFCap: TP+ FLR+
>         AFCtrl: FLR-
>         AFStatus: TP-
>     Kernel driver in use: uhci_hcd
>
>00:1d.2 USB controller: Intel Corporation 82801I (ICH9 Family) USB UHCI
>
>Controller #3 (rev 03) (prog-if 00 [UHCI])
>     Subsystem: Hewlett-Packard Company Device 30e7
>   Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
>Stepping- SERR- FastB2B- DisINTx-
>     Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
><TAbort- <MAbort- >SERR- <PERR- INTx-
>     Latency: 0
>     Interrupt: pin C routed to IRQ 18
>     Region 4: I/O ports at 8000 [size=32]
>     Capabilities: [50] PCI Advanced Features
>         AFCap: TP+ FLR+
>         AFCtrl: FLR-
>         AFStatus: TP-
>     Kernel driver in use: uhci_hcd
>
>00:1d.7 USB controller: Intel Corporation 82801I (ICH9 Family) USB2
>EHCI 
>Controller #1 (rev 03) (prog-if 20 [EHCI])
>     Subsystem: Hewlett-Packard Company Device 30e7
>   Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
>Stepping- SERR- FastB2B- DisINTx-
>     Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
><TAbort- <MAbort- >SERR- <PERR- INTx-
>     Latency: 0
>     Interrupt: pin D routed to IRQ 20
>     Region 0: Memory at db326000 (32-bit, non-prefetchable) [size=1K]
>     Capabilities: [50] Power Management version 2
>         Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA 
>PME(D0+,D1-,D2-,D3hot+,D3cold+)
>         Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
>     Capabilities: [58] Debug port: BAR=1 offset=00a0
>     Capabilities: [98] PCI Advanced Features
>         AFCap: TP+ FLR+
>         AFCtrl: FLR-
>         AFStatus: TP-
>     Kernel driver in use: ehci-pci
>
>00:1e.0 PCI bridge: Intel Corporation 82801 Mobile PCI Bridge (rev 93) 
>(prog-if 01 [Subtractive decode])
>   Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
>Stepping- SERR+ FastB2B- DisINTx-
>     Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
><TAbort- <MAbort- >SERR- <PERR- INTx-
>     Latency: 0
>     Bus: primary=00, secondary=86, subordinate=8a, sec-latency=64
>     I/O behind bridge: 00002000-00002fff
>     Memory behind bridge: d3000000-d30fffff
>   Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
>     Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
><TAbort- <MAbort+ <SERR- <PERR-
>     BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
>         PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
>     Capabilities: [50] Subsystem: Device 0000:0000
>
>00:1f.0 ISA bridge: Intel Corporation ICH9M-E LPC Interface Controller 
>(rev 03)
>     Subsystem: Hewlett-Packard Company Device 30e7
>   Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
>Stepping- SERR- FastB2B- DisINTx-
>     Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- 
><TAbort- <MAbort- >SERR- <PERR- INTx-
>     Latency: 0
>     Capabilities: [e0] Vendor Specific Information: Len=0c <?>
>     Kernel driver in use: lpc_ich
>
>00:1f.2 IDE interface: Intel Corporation 82801IBM/IEM (ICH9M/ICH9M-E) 2
>
>port SATA Controller [IDE mode] (rev 03) (prog-if 8a [Master SecP
>PriP])
>     Subsystem: Hewlett-Packard Company Device 30e7
>   Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
>Stepping- SERR- FastB2B- DisINTx-
>     Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
><TAbort- <MAbort- >SERR- <PERR- INTx-
>     Latency: 0
>     Interrupt: pin A routed to IRQ 21
>     Region 0: I/O ports at 01f0 [size=8]
>     Region 1: I/O ports at 03f4
>     Region 2: I/O ports at 0170 [size=8]
>     Region 3: I/O ports at 0374
>     Region 4: I/O ports at 8110 [size=16]
>     Region 5: I/O ports at 8100 [size=16]
>     Capabilities: [70] Power Management version 3
>         Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA 
>PME(D0-,D1-,D2-,D3hot-,D3cold-)
>         Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
>     Capabilities: [b0] PCI Advanced Features
>         AFCap: TP+ FLR+
>         AFCtrl: FLR-
>         AFStatus: TP-
>     Kernel driver in use: ata_piix
>
>00:1f.5 IDE interface: Intel Corporation 82801IBM/IEM (ICH9M/ICH9M-E) 2
>
>port SATA Controller [IDE mode] (rev 03) (prog-if 85 [Master SecO
>PriO])
>     Subsystem: Hewlett-Packard Company Device 30e7
>   Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
>Stepping- SERR- FastB2B- DisINTx-
>     Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
><TAbort- <MAbort- >SERR- <PERR- INTx-
>     Latency: 0
>     Interrupt: pin C routed to IRQ 18
>     Region 0: I/O ports at 8138 [size=8]
>     Region 1: I/O ports at 816c [size=4]
>     Region 2: I/O ports at 8130 [size=8]
>     Region 3: I/O ports at 8168 [size=4]
>     Region 4: I/O ports at 80f0 [size=16]
>     Region 5: I/O ports at 80e0 [size=16]
>     Capabilities: [70] Power Management version 3
>         Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA 
>PME(D0-,D1-,D2-,D3hot-,D3cold-)
>         Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
>     Capabilities: [b0] PCI Advanced Features
>         AFCap: TP+ FLR+
>         AFCtrl: FLR-
>         AFStatus: TP-
>     Kernel driver in use: ata_piix
>
>01:00.0 VGA compatible controller: NVIDIA Corporation G96GLM [Quadro FX
>
>770M] (rev a1) (prog-if 00 [VGA controller])
>     Subsystem: Hewlett-Packard Company Device 30e7
>     Physical Slot: 1
>   Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
>Stepping- SERR- FastB2B- DisINTx+
>     Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
><TAbort- <MAbort- >SERR- <PERR- INTx-
>     Latency: 0, Cache Line Size: 64 bytes
>     Interrupt: pin A routed to IRQ 33
>     Region 0: Memory at d2000000 (32-bit, non-prefetchable) [size=16M]
>     Region 1: Memory at c0000000 (64-bit, prefetchable) [size=256M]
>     Region 3: Memory at d0000000 (64-bit, non-prefetchable) [size=32M]
>     Region 5: I/O ports at 7000 [size=128]
>     Expansion ROM at 000c0000 [disabled] [size=128K]
>     Capabilities: [60] Power Management version 3
>         Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA 
>PME(D0-,D1-,D2-,D3hot-,D3cold-)
>         Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
>     Capabilities: [68] MSI: Enable+ Count=1/1 Maskable- 64bit+
>         Address: 00000000fee0300c  Data: 4173
>     Capabilities: [78] Express (v2) Endpoint, MSI 00
>         DevCap:    MaxPayload 128 bytes, PhantFunc 0, Latency L0s 
><256ns, L1 <4us
>             ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
>         DevCtl:    Report errors: Correctable- Non-Fatal- Fatal- 
>Unsupported-
>             RlxdOrd+ ExtTag+ PhantFunc- AuxPwr- NoSnoop+
>             MaxPayload 128 bytes, MaxReadReq 512 bytes
>         DevSta:    CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- 
>TransPend-
>       LnkCap:    Port #0, Speed 2.5GT/s, Width x16, ASPM L0s L1, Exit 
>Latency L0s <256ns, L1 <1us
>             ClockPM- Surprise- LLActRep- BwNot-
>       LnkCtl:    ASPM L0s L1 Enabled; RCB 128 bytes Disabled- CommClk+
>             ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>         LnkSta:    Speed 2.5GT/s, Width x16, TrErr- Train- SlotClk+ 
>DLActive- BWMgmt- ABWMgmt-
>        DevCap2: Completion Timeout: Not Supported, TimeoutDis+, LTR-, 
>OBFF Not Supported
>         DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-, 
>OBFF Disabled
>        LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-
>              Transmit Margin: Normal Operating Range, 
>EnterModifiedCompliance- ComplianceSOS-
>              Compliance De-emphasis: -6dB
>         LnkSta2: Current De-emphasis Level: -6dB, 
>EqualizationComplete-, EqualizationPhase1-
>              EqualizationPhase2-, EqualizationPhase3-, 
>LinkEqualizationRequest-
>     Capabilities: [b4] Vendor Specific Information: Len=14 <?>
>     Capabilities: [100 v1] Virtual Channel
>         Caps:    LPEVC=0 RefClk=100ns PATEntryBits=1
>         Arb:    Fixed- WRR32- WRR64- WRR128-
>         Ctrl:    ArbSelect=Fixed
>         Status:    InProgress-
>         VC0:    Caps:    PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
>             Arb:    Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
>             Ctrl:    Enable+ ID=0 ArbSelect=Fixed TC/VC=01
>             Status:    NegoPending- InProgress-
>     Capabilities: [128 v1] Power Budgeting <?>
>     Capabilities: [600 v1] Vendor Specific Information: ID=0001 Rev=1 
>Len=024 <?>
>     Kernel driver in use: nouveau
>
>03:00.0 Network controller: Intel Corporation Ultimate N WiFi Link 5300
>     Subsystem: Intel Corporation Device 1011
>     Physical Slot: 1-1
>   Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
>Stepping- SERR- FastB2B- DisINTx+
>     Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
><TAbort- <MAbort- >SERR- <PERR- INTx-
>     Latency: 0, Cache Line Size: 64 bytes
>     Interrupt: pin A routed to IRQ 31
>     Region 0: Memory at db100000 (64-bit, non-prefetchable) [size=8K]
>     Capabilities: [c8] Power Management version 3
>         Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA 
>PME(D0+,D1-,D2-,D3hot+,D3cold+)
>         Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
>     Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
>         Address: 00000000fee0300c  Data: 4153
>     Capabilities: [e0] Express (v1) Endpoint, MSI 00
>         DevCap:    MaxPayload 128 bytes, PhantFunc 0, Latency L0s 
><512ns, L1 unlimited
>             ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset+
>         DevCtl:    Report errors: Correctable- Non-Fatal- Fatal- 
>Unsupported-
>             RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+ FLReset-
>             MaxPayload 128 bytes, MaxReadReq 128 bytes
>         DevSta:    CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+ 
>TransPend-
>        LnkCap:    Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit 
>Latency L0s <128ns, L1 <32us
>             ClockPM+ Surprise- LLActRep- BwNot-
>        LnkCtl:    ASPM L0s L1 Enabled; RCB 64 bytes Disabled- CommClk+
>             ExtSynch- ClockPM+ AutWidDis- BWInt- AutBWInt-
>         LnkSta:    Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ 
>DLActive- BWMgmt- ABWMgmt-
>     Capabilities: [100 v1] Advanced Error Reporting
>         UESta:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- 
>RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
>         UEMsk:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- 
>RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
>         UESvrt:    DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- 
>RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
>      CESta:    RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
>      CEMsk:    RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
>     AERCap:    First Error Pointer: 00, GenCap- CGenEn- ChkCap- ChkEn-
>    Capabilities: [140 v1] Device Serial Number 00-21-6a-ff-ff-0d-ba-8a
>     Kernel driver in use: iwlwifi
>
>86:09.0 FireWire (IEEE 1394): Ricoh Co Ltd R5C832 IEEE 1394 Controller 
>(rev 06) (prog-if 10 [OHCI])
>     Subsystem: Hewlett-Packard Company Device 30e7
>   Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
>Stepping- SERR- FastB2B- DisINTx-
>     Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- 
><TAbort- <MAbort- >SERR- <PERR- INTx-
>     Latency: 64 (500ns min, 1000ns max), Cache Line Size: 64 bytes
>     Interrupt: pin A routed to IRQ 20
>     Region 0: Memory at d3001000 (32-bit, non-prefetchable) [size=2K]
>     Capabilities: [dc] Power Management version 2
>         Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA 
>PME(D0+,D1+,D2+,D3hot+,D3cold+)
>         Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=2 PME+
>     Kernel driver in use: firewire_ohci
>
>86:09.1 SD Host controller: Ricoh Co Ltd R5C822 SD/SDIO/MMC/MS/MSPro 
>Host Adapter (rev 25)
>     Subsystem: Hewlett-Packard Company Device 30e7
>   Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
>Stepping- SERR- FastB2B- DisINTx-
>     Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- 
><TAbort- <MAbort- >SERR- <PERR- INTx-
>     Latency: 64, Cache Line Size: 64 bytes
>     Interrupt: pin B routed to IRQ 22
>     Region 0: Memory at d3001b00 (32-bit, non-prefetchable) [size=256]
>     Capabilities: [80] Power Management version 2
>         Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA 
>PME(D0+,D1+,D2+,D3hot+,D3cold+)
>         Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=2 PME-
>     Kernel driver in use: sdhci-pci
>
>86:09.2 System peripheral: Ricoh Co Ltd R5C592 Memory Stick Bus Host 
>Adapter (rev 14)
>     Subsystem: Hewlett-Packard Company Device 30e7
>   Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
>Stepping- SERR- FastB2B- DisINTx-
>     Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- 
><TAbort- <MAbort- >SERR- <PERR- INTx-
>     Latency: 64, Cache Line Size: 64 bytes
>     Interrupt: pin B routed to IRQ 22
>     Region 0: Memory at d3001900 (32-bit, non-prefetchable) [size=256]
>     Capabilities: [80] Power Management version 2
>         Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA 
>PME(D0+,D1+,D2+,D3hot+,D3cold+)
>         Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=2 PME-
>     Kernel driver in use: r592
>
>86:09.3 System peripheral: Ricoh Co Ltd xD-Picture Card Controller (rev
>14)
>     Subsystem: Hewlett-Packard Company Device 30e7
>   Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
>Stepping- SERR- FastB2B- DisINTx-
>     Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- 
><TAbort- <MAbort- >SERR- <PERR- INTx-
>     Latency: 64, Cache Line Size: 64 bytes
>     Interrupt: pin B routed to IRQ 22
>     Region 0: Memory at d3001800 (32-bit, non-prefetchable) [size=256]
>     Capabilities: [80] Power Management version 2
>         Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA 
>PME(D0+,D1+,D2+,D3hot+,D3cold+)
>         Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=2 PME-
>     Kernel driver in use: r852
>
>86:09.4 CardBus bridge: Ricoh Co Ltd RL5c476 II (rev bb)
>     Subsystem: Hewlett-Packard Company Device 30e7
>   Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
>Stepping- SERR- FastB2B- DisINTx-
>     Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- 
><TAbort- <MAbort- >SERR- <PERR- INTx-
>     Latency: 168
>     Interrupt: pin B routed to IRQ 22
>     Region 0: Memory at d3000000 (32-bit, non-prefetchable) [size=4K]
>     Bus: primary=86, secondary=87, subordinate=8a, sec-latency=176
>     Memory window 0: dc000000-dfffffff (prefetchable)
>     Memory window 1: f0000000-f3ffffff
>     I/O window 0: 00002000-000020ff
>     I/O window 1: 00002400-000024ff
>  BridgeCtl: Parity- SERR- ISA- VGA- MAbort- >Reset- 16bInt- PostWrite+
>     16-bit legacy interface ports at 0001
>     Capabilities: [dc] Power Management version 2
>         Flags: PMEClk+ DSI- D1+ D2+ AuxCurrent=0mA 
>PME(D0+,D1+,D2+,D3hot+,D3cold+)
>         Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=2 PME-
>         Bridge: PM- B3+
>     Kernel driver in use: yenta_cardbus
>
>
> From 4acb3b3b5199d92bc21a2d043582addfe671eff7 Mon Sep 17 00:00:00 2001
>From: Lincoln Ramsay <a1291762@gmail.com>
>Date: Sat, 2 Apr 2016 14:47:49 +1000
>Subject: [PATCH] pegasus: Do not write more data to the buffer than it
>can
>  hold.
>
>---
>  drivers/net/usb/pegasus.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
>
>diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
>index 03e8a15..ab85656 100644
>--- a/drivers/net/usb/pegasus.c
>+++ b/drivers/net/usb/pegasus.c
>@@ -528,7 +528,7 @@ static void read_bulk_callback(struct urb *urb)
>  goon:
>      usb_fill_bulk_urb(pegasus->rx_urb, pegasus->usb,
>                usb_rcvbulkpipe(pegasus->usb, 1),
>-              pegasus->rx_skb->data, PEGASUS_MTU + 8,
>+              pegasus->rx_skb->data, PEGASUS_MTU,
>                read_bulk_callback, pegasus);
>      rx_status = usb_submit_urb(pegasus->rx_urb, GFP_ATOMIC);
>      if (rx_status == -ENODEV)
>@@ -569,7 +569,7 @@ static void rx_fixup(unsigned long data)
>      }
>      usb_fill_bulk_urb(pegasus->rx_urb, pegasus->usb,
>                usb_rcvbulkpipe(pegasus->usb, 1),
>-              pegasus->rx_skb->data, PEGASUS_MTU + 8,
>+              pegasus->rx_skb->data, PEGASUS_MTU,
>                read_bulk_callback, pegasus);
>  try_again:
>      status = usb_submit_urb(pegasus->rx_urb, GFP_ATOMIC);
>@@ -823,7 +823,7 @@ static int pegasus_open(struct net_device *net)
>
>      usb_fill_bulk_urb(pegasus->rx_urb, pegasus->usb,
>                usb_rcvbulkpipe(pegasus->usb, 1),
>-              pegasus->rx_skb->data, PEGASUS_MTU + 8,
>+              pegasus->rx_skb->data, PEGASUS_MTU,
>                read_bulk_callback, pegasus);
>      if ((res = usb_submit_urb(pegasus->rx_urb, GFP_KERNEL))) {
>          if (res == -ENODEV)
