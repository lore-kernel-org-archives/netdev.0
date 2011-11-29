From: Lucas Stach <dev@lynxeye.de>
Subject: Lockups with r8169 driver (Was: Hangs with Linux 3.2.0-rc3)
Date: Tue, 29 Nov 2011 19:35:41 +0100
Message-ID: <1322591741.1675.14.camel@tellur>
References: <1322552218.1679.5.camel@tellur>
	 <20111129080655.GA12809@x1.osrc.amd.com>
	 <20111129154352.GC13958@x1.osrc.amd.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Ff/r2XgoguVDD+3ERzrv"
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Borislav Petkov <bp@alien8.de>,
	Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111129154352.GC13958@x1.osrc.amd.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Ff/r2XgoguVDD+3ERzrv
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

Hi Boris,

Am Dienstag, den 29.11.2011, 16:43 +0100 schrieb Borislav Petkov:
> On Tue, Nov 29, 2011 at 09:06:55AM +0100, Borislav Petkov wrote:
> > > Nov 29 00:22:04 tellur kernel: [13936.370598] WARNING: at kernel/watchdog.c:241 watchdog_overflow_callback+0x9b/0xa6()
> > > Nov 29 00:22:04 tellur kernel: [13936.370598] Hardware name: GA-970A-UD3
> > > Nov 29 00:22:04 tellur kernel: [13936.370598] Watchdog detected hard LOCKUP on cpu 0
> > > Nov 29 00:22:04 tellur kernel: [13936.370598] Modules linked in: tcp_lp ppdev parport_pc lp parport fuse nfs fscache auth_rpcgss nfs_acl ebtable_nat ebtables ipt_MASQUERADE iptable_nat nf_nat iptable_mangle tun lockd bridge stp llc bluetooth rfkill it87 adt7475 hwmon_vid ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm ir_lirc_codec lirc_dev ir_mce_kbd_decoder snd_timer snd ir_sony_decoder ir_jvc_decoder ir_rc6_decoder ata_generic pata_acpi edac_core serio_raw soundcore joydev ir_rc5_decoder pata_atiixp ir_nec_decoder r8169 mii mceusb rc_core virtio_net edac_mce_amd sp5100_tco i2c_piix4 xhci_hcd fam15h_power pcspkr snd_page_alloc microcode k10temp virtio_ring virtio kvm_a
 md kvm uinput sunrpc ipv6 usb_storage firewire_ohci uas firewire_core crc_itu_t nouveau ttm drm_kms_helper drm hwmon i2c_algo_bit i2c_core mxm_wmi video wmi [last unloaded: scsi_wait_scan]
> > > Nov 29 00:22:04 tellur kernel: [13936.370598] Pid: 0, comm: swapper Not tainted 3.2.0-rc3+ #39
> > > Nov 29 00:22:04 tellur kernel: [13936.370598] Call Trace:
> > > Nov 29 00:22:04 tellur kernel: [13936.370598]  <NMI>  [<ffffffff81050c5a>] warn_slowpath_common+0x83/0x9b
> > > Nov 29 00:22:04 tellur kernel: [13936.370598]  [<ffffffff81050d15>] warn_slowpath_fmt+0x46/0x48
> > > Nov 29 00:22:04 tellur kernel: [13936.370598]  [<ffffffff81015204>] ? native_sched_clock+0x34/0x36
> > > Nov 29 00:22:04 tellur kernel: [13936.370598]  [<ffffffff810a7abb>] watchdog_overflow_callback+0x9b/0xa6
> > > Nov 29 00:22:04 tellur kernel: [13936.370598]  [<ffffffff810d28c5>] __perf_event_overflow+0x100/0x17f
> > > Nov 29 00:22:04 tellur kernel: [13936.370598]  [<ffffffff8107055b>] ? local_clock+0x27/0x2f
> > > Nov 29 00:22:04 tellur kernel: [13936.370598]  [<ffffffff810d0cb6>] ? perf_event_update_userpage+0xf/0xa3
> > > Nov 29 00:22:04 tellur kernel: [13936.370598]  [<ffffffff810d2f2e>] perf_event_overflow+0x14/0x16
> > > Nov 29 00:22:04 tellur kernel: [13936.370598]  [<ffffffff8101c22a>] x86_pmu_handle_irq+0xbe/0xf9
> > > Nov 29 00:22:04 tellur kernel: [13936.370598]  [<ffffffff814aa5ee>] perf_event_nmi_handler+0x19/0x1b
> > > Nov 29 00:22:04 tellur kernel: [13936.370598]  [<ffffffff814a9f77>] nmi_handle+0x42/0x67
> > > Nov 29 00:22:04 tellur kernel: [13936.370598]  [<ffffffff814aa028>] do_nmi+0x8c/0x26f
> > > Nov 29 00:22:04 tellur kernel: [13936.370598]  [<ffffffff814a9830>] nmi+0x20/0x30
> > > Nov 29 00:22:04 tellur kernel: [13936.370598]  [<ffffffffa023bf55>] ? rtl8169_interrupt+0x268/0x2a4 [r8169]
> 
> Btw,
> 
> this looks like the box hanged itself after getting an net IRQ over your
> r8169 which reminds me of this other issue being debugged on lkml in
> conjunction with r8169:
> 
> http://marc.info/?l=linux-kernel&m=132225246211817&w=2

Thanks for the pointer, this helped a lot.

It seems the lockup is triggered by the r6169 driver. I can reproduce it
with rc2 also. With AMD IOMMU enabled I get the following in dmesg just
before the lockup:
"AMD-Vi: Event logged [IO_PAGE_FAULT device=03:00.0 domain=0x0018 address=0x0000000000003000 flags=0x0050]"
where device=03:00.0 is my r8169 ethernet adapter. So it seems the
hardware tries to dma to a location it's not supposed to dma to.

Dropping Andreas Herrmann from cc as this is clearly not Bulldozer
related. Instead adding netdev and r8169 maintainer. For completeness I
will reattach the whole crashdump and lspci -vv for the ethernet device.

I will try the last patch mentioned in the linked thread and report
back.

Thanks,
Lucas

> 
> Can you try reproducing the issue without having network traffic. Also,
> according to the thread above, 3.1 kernel is also affected so it could
> make sense for you go back to 3.0 and see whether it happens with it
> too.
> 
> HTH.
> 


--=-Ff/r2XgoguVDD+3ERzrv
Content-Disposition: attachment; filename="crash"
Content-Type: text/plain; name="crash"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

Nov 29 00:22:04 tellur kernel: [13936.370598] WARNING: at kernel/watchdog.c:241 watchdog_overflow_callback+0x9b/0xa6()
Nov 29 00:22:04 tellur kernel: [13936.370598] Hardware name: GA-970A-UD3
Nov 29 00:22:04 tellur kernel: [13936.370598] Watchdog detected hard LOCKUP on cpu 0
Nov 29 00:22:04 tellur kernel: [13936.370598] Modules linked in: tcp_lp ppdev parport_pc lp parport fuse nfs fscache auth_rpcgss nfs_acl ebtable_nat ebtables ipt_MASQUERADE iptable_nat nf_nat iptable_mangle tun lockd bridge stp llc bluetooth rfkill it87 adt7475 hwmon_vid ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm ir_lirc_codec lirc_dev ir_mce_kbd_decoder snd_timer snd ir_sony_decoder ir_jvc_decoder ir_rc6_decoder ata_generic pata_acpi edac_core serio_raw soundcore joydev ir_rc5_decoder pata_atiixp ir_nec_decoder r8169 mii mceusb rc_core virtio_net edac_mce_amd sp5100_tco i2c_piix4 xhci_hcd fam15h_power pcspkr snd_page_alloc microcode k10temp virtio_ring virtio kvm_amd kvm
  uinput sunrpc ipv6 usb_storage firewire_ohci uas firewire_core crc_itu_t nouveau ttm drm_kms_helper drm hwmon i2c_algo_bit i2c_core mxm_wmi video wmi [last unloaded: scsi_wait_scan]
Nov 29 00:22:04 tellur kernel: [13936.370598] Pid: 0, comm: swapper Not tainted 3.2.0-rc3+ #39
Nov 29 00:22:04 tellur kernel: [13936.370598] Call Trace:
Nov 29 00:22:04 tellur kernel: [13936.370598]  <NMI>  [<ffffffff81050c5a>] warn_slowpath_common+0x83/0x9b
Nov 29 00:22:04 tellur kernel: [13936.370598]  [<ffffffff81050d15>] warn_slowpath_fmt+0x46/0x48
Nov 29 00:22:04 tellur kernel: [13936.370598]  [<ffffffff81015204>] ? native_sched_clock+0x34/0x36
Nov 29 00:22:04 tellur kernel: [13936.370598]  [<ffffffff810a7abb>] watchdog_overflow_callback+0x9b/0xa6
Nov 29 00:22:04 tellur kernel: [13936.370598]  [<ffffffff810d28c5>] __perf_event_overflow+0x100/0x17f
Nov 29 00:22:04 tellur kernel: [13936.370598]  [<ffffffff8107055b>] ? local_clock+0x27/0x2f
Nov 29 00:22:04 tellur kernel: [13936.370598]  [<ffffffff810d0cb6>] ? perf_event_update_userpage+0xf/0xa3
Nov 29 00:22:04 tellur kernel: [13936.370598]  [<ffffffff810d2f2e>] perf_event_overflow+0x14/0x16
Nov 29 00:22:04 tellur kernel: [13936.370598]  [<ffffffff8101c22a>] x86_pmu_handle_irq+0xbe/0xf9
Nov 29 00:22:04 tellur kernel: [13936.370598]  [<ffffffff814aa5ee>] perf_event_nmi_handler+0x19/0x1b
Nov 29 00:22:04 tellur kernel: [13936.370598]  [<ffffffff814a9f77>] nmi_handle+0x42/0x67
Nov 29 00:22:04 tellur kernel: [13936.370598]  [<ffffffff814aa028>] do_nmi+0x8c/0x26f
Nov 29 00:22:04 tellur kernel: [13936.370598]  [<ffffffff814a9830>] nmi+0x20/0x30
Nov 29 00:22:04 tellur kernel: [13936.370598]  [<ffffffffa023bf55>] ? rtl8169_interrupt+0x268/0x2a4 [r8169]
Nov 29 00:22:04 tellur kernel: [13936.370598]  <<EOE>>  <IRQ>  [<ffffffff81014de7>] ? read_tsc+0x9/0x19
Nov 29 00:22:04 tellur kernel: [13936.370598]  [<ffffffff810a841d>] handle_irq_event_percpu+0x5f/0x193
Nov 29 00:22:04 tellur kernel: [13936.370598]  [<ffffffff810a858c>] handle_irq_event+0x3b/0x57
Nov 29 00:22:04 tellur kernel: [13936.370598]  [<ffffffff810293ac>] ? ack_apic_edge+0x24/0x28
Nov 29 00:22:04 tellur kernel: [13936.370598]  [<ffffffff810aad4e>] handle_edge_irq+0xa6/0xcc
Nov 29 00:22:04 tellur kernel: [13936.370598]  [<ffffffff81010a95>] handle_irq+0x88/0x8e
Nov 29 00:22:04 tellur kernel: [13936.370598]  [<ffffffff814b214d>] do_IRQ+0x4d/0xa5
Nov 29 00:22:04 tellur kernel: [13936.370598]  [<ffffffff814a92ae>] common_interrupt+0x6e/0x6e
Nov 29 00:22:04 tellur kernel: [13936.370598]  <EOI>  [<ffffffff8102f369>] ? native_safe_halt+0xb/0xd
Nov 29 00:22:04 tellur kernel: [13936.370598]  [<ffffffff812afe54>] acpi_safe_halt+0x2a/0x43
Nov 29 00:22:04 tellur kernel: [13936.370598]  [<ffffffff812afe8d>] acpi_idle_do_entry+0x20/0x30
Nov 29 00:22:04 tellur kernel: [13936.370598]  [<ffffffff812b030e>] acpi_idle_enter_c1+0x62/0xbf
Nov 29 00:22:04 tellur kernel: [13936.370598]  [<ffffffff813c1e7b>] cpuidle_idle_call+0xf8/0x189
Nov 29 00:22:04 tellur kernel: [13936.370598]  [<ffffffff8100e2e8>] cpu_idle+0xa9/0xf0
Nov 29 00:22:04 tellur kernel: [13936.370598]  [<ffffffff81487a9e>] rest_init+0x72/0x74
Nov 29 00:22:04 tellur kernel: [13936.370598]  [<ffffffff81b67b6c>] start_kernel+0x3ab/0x3b8
Nov 29 00:22:04 tellur kernel: [13936.370598]  [<ffffffff81b672c4>] x86_64_start_reservations+0xaf/0xb3
Nov 29 00:22:04 tellur kernel: [13936.370598]  [<ffffffff81b67140>] ? early_idt_handlers+0x140/0x140
Nov 29 00:22:04 tellur kernel: [13936.370598]  [<ffffffff81b673ca>] x86_64_start_kernel+0x102/0x111
Nov 29 00:22:04 tellur kernel: [13936.370598] ---[ end trace d8087f6327f1e63a ]---
Nov 29 00:22:53 tellur kernel: [13986.409015] INFO: rcu_sched detected stalls on CPUs/tasks: { 0} (detected by 1, t=60002 jiffies)
Nov 29 00:22:53 tellur kernel: [13986.409020] sending NMI to all CPUs:
Nov 29 00:22:53 tellur kernel: [13986.409023] NMI backtrace for cpu 1
Nov 29 00:22:53 tellur kernel: [13986.409025] CPU 1 
Nov 29 00:22:53 tellur kernel: [13986.409027] Modules linked in: tcp_lp ppdev parport_pc lp parport fuse nfs fscache auth_rpcgss nfs_acl ebtable_nat ebtables ipt_MASQUERADE iptable_nat nf_nat iptable_mangle tun lockd bridge stp llc bluetooth rfkill it87 adt7475 hwmon_vid ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm ir_lirc_codec lirc_dev ir_mce_kbd_decoder snd_timer snd ir_sony_decoder ir_jvc_decoder ir_rc6_decoder ata_generic pata_acpi edac_core serio_raw soundcore joydev ir_rc5_decoder pata_atiixp ir_nec_decoder r8169 mii mceusb rc_core virtio_net edac_mce_amd sp5100_tco i2c_piix4 xhci_hcd fam15h_power pcspkr snd_page_alloc microcode k10temp virtio_ring virtio kvm_amd kvm
  uinput sunrpc ipv6 usb_storage firewire_ohci uas firewire_core crc_itu_t nouveau ttm drm_kms_helper drm hwmon i2c_algo_bit i2c_core mxm_wmi video wmi [last unloaded: scsi_wait_scan]
Nov 29 00:22:53 tellur kernel: [13986.409099] 
Nov 29 00:22:53 tellur kernel: [13986.409102] Pid: 0, comm: kworker/0:0 Tainted: G        W    3.2.0-rc3+ #39 Gigabyte Technology Co., Ltd. GA-970A-UD3/GA-970A-UD3
Nov 29 00:22:53 tellur kernel: [13986.409107] RIP: 0010:[<ffffffff812444cc>]  [<ffffffff812444cc>] __const_udelay+0x1/0x2e
Nov 29 00:22:53 tellur kernel: [13986.409114] RSP: 0018:ffff88042ec43dd8  EFLAGS: 00000046
Nov 29 00:22:53 tellur kernel: [13986.409116] RAX: 0000000000000000 RBX: 0000000000002710 RCX: 0000000000000040
Nov 29 00:22:53 tellur kernel: [13986.409118] RDX: 0000000000000001 RSI: 0000000000000100 RDI: 0000000000418958
Nov 29 00:22:53 tellur kernel: [13986.409120] RBP: ffff88042ec43df8 R08: 0000000000000002 R09: 0000ffff00066c0a
Nov 29 00:22:53 tellur kernel: [13986.409123] R10: 0000ffff00066c0a R11: 0000000000000000 R12: ffffffff81a2e880
Nov 29 00:22:53 tellur kernel: [13986.409125] R13: ffffffff81a2e980 R14: 0000000000000001 R15: ffffffff81a2f980
Nov 29 00:22:53 tellur kernel: [13986.409128] FS:  00007f7c157d2880(0000) GS:ffff88042ec40000(0000) knlGS:0000000000000000
Nov 29 00:22:53 tellur kernel: [13986.409130] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Nov 29 00:22:53 tellur kernel: [13986.409133] CR2: 00000000006e81d8 CR3: 00000003f2cbb000 CR4: 00000000000406e0
Nov 29 00:22:53 tellur kernel: [13986.409135] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Nov 29 00:22:53 tellur kernel: [13986.409138] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Nov 29 00:22:53 tellur kernel: [13986.409140] Process kworker/0:0 (pid: 0, threadinfo ffff880414536000, task ffff880414539710)
Nov 29 00:22:53 tellur kernel: [13986.409144] Stack:
Nov 29 00:22:53 tellur kernel: [13986.409146]  ffff88042ec43df8 ffffffff81027c3d 0000000000000000 ffff88042ec4ea80
Nov 29 00:22:53 tellur kernel: [13986.409151]  ffff88042ec43e48 ffffffff810adcd8 0000000000000000 ffffffff81a2f980
Nov 29 00:22:53 tellur kernel: [13986.409155]  ffff88042ec43e28 0000000000000001 0000000000000000 0000000000000001
Nov 29 00:22:53 tellur kernel: [13986.409160] Call Trace:
Nov 29 00:22:53 tellur kernel: [13986.409162]  <IRQ> 
Nov 29 00:22:53 tellur kernel: [13986.409167]  [<ffffffff81027c3d>] ? arch_trigger_all_cpu_backtrace+0x76/0x89
Nov 29 00:22:53 tellur kernel: [13986.409171]  [<ffffffff810adcd8>] __rcu_pending+0x22d/0x354
Nov 29 00:22:53 tellur kernel: [13986.409175]  [<ffffffff810ae1c0>] rcu_check_callbacks+0x9b/0xd9
Nov 29 00:22:53 tellur kernel: [13986.409179]  [<ffffffff8105d862>] update_process_times+0x3f/0x76
Nov 29 00:22:53 tellur kernel: [13986.409183]  [<ffffffff81078f06>] tick_sched_timer+0x75/0x9f
Nov 29 00:22:53 tellur kernel: [13986.409186]  [<ffffffff8106e86f>] __run_hrtimer+0xbc/0x145
Nov 29 00:22:53 tellur kernel: [13986.409190]  [<ffffffff81078e91>] ? tick_nohz_handler+0xde/0xde
Nov 29 00:22:53 tellur kernel: [13986.409193]  [<ffffffff8106ef70>] hrtimer_interrupt+0xe0/0x19d
Nov 29 00:22:53 tellur kernel: [13986.409197]  [<ffffffff814b221c>] smp_apic_timer_interrupt+0x77/0x8a
Nov 29 00:22:53 tellur kernel: [13986.409202]  [<ffffffff814b011e>] apic_timer_interrupt+0x6e/0x80
Nov 29 00:22:53 tellur kernel: [13986.409204]  <EOI> 
Nov 29 00:22:53 tellur kernel: [13986.409207]  [<ffffffff81014de7>] ? read_tsc+0x9/0x19
Nov 29 00:22:53 tellur kernel: [13986.409211]  [<ffffffff812af523>] ? arch_local_irq_enable+0x8/0xd
Nov 29 00:22:53 tellur kernel: [13986.409215]  [<ffffffff81070635>] ? sched_clock_idle_wakeup_event+0x17/0x1a
Nov 29 00:22:53 tellur kernel: [13986.409219]  [<ffffffff812b026a>] acpi_idle_enter_simple+0xd3/0x115
Nov 29 00:22:53 tellur kernel: [13986.409223]  [<ffffffff813c1e7b>] cpuidle_idle_call+0xf8/0x189
Nov 29 00:22:53 tellur kernel: [13986.409227]  [<ffffffff8100e2e8>] cpu_idle+0xa9/0xf0
Nov 29 00:22:53 tellur kernel: [13986.409232]  [<ffffffff81498652>] start_secondary+0x23f/0x241
Nov 29 00:22:53 tellur kernel: [13986.409234] Code: 0e 66 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 48 ff c8 75 fb 48 ff c8 5d c3 55 48 89 e5 66 66 66 66 90 ff 15 2f 8c 81 00 5d c3 55 
Nov 29 00:22:53 tellur kernel: [13986.409275] Call Trace:
Nov 29 00:22:53 tellur kernel: [13986.409277]  <IRQ>  [<ffffffff81027c3d>] ? arch_trigger_all_cpu_backtrace+0x76/0x89
Nov 29 00:22:53 tellur kernel: [13986.409283]  [<ffffffff810adcd8>] __rcu_pending+0x22d/0x354
Nov 29 00:22:53 tellur kernel: [13986.409287]  [<ffffffff810ae1c0>] rcu_check_callbacks+0x9b/0xd9
Nov 29 00:22:53 tellur kernel: [13986.409290]  [<ffffffff8105d862>] update_process_times+0x3f/0x76
Nov 29 00:22:53 tellur kernel: [13986.409293]  [<ffffffff81078f06>] tick_sched_timer+0x75/0x9f
Nov 29 00:22:53 tellur kernel: [13986.409296]  [<ffffffff8106e86f>] __run_hrtimer+0xbc/0x145
Nov 29 00:22:53 tellur kernel: [13986.409300]  [<ffffffff81078e91>] ? tick_nohz_handler+0xde/0xde
Nov 29 00:22:53 tellur kernel: [13986.409303]  [<ffffffff8106ef70>] hrtimer_interrupt+0xe0/0x19d
Nov 29 00:22:53 tellur kernel: [13986.409307]  [<ffffffff814b221c>] smp_apic_timer_interrupt+0x77/0x8a
Nov 29 00:22:53 tellur kernel: [13986.409310]  [<ffffffff814b011e>] apic_timer_interrupt+0x6e/0x80
Nov 29 00:22:53 tellur kernel: [13986.409312]  <EOI>  [<ffffffff81014de7>] ? read_tsc+0x9/0x19
Nov 29 00:22:53 tellur kernel: [13986.409317]  [<ffffffff812af523>] ? arch_local_irq_enable+0x8/0xd
Nov 29 00:22:53 tellur kernel: [13986.409321]  [<ffffffff81070635>] ? sched_clock_idle_wakeup_event+0x17/0x1a
Nov 29 00:22:53 tellur kernel: [13986.409324]  [<ffffffff812b026a>] acpi_idle_enter_simple+0xd3/0x115
Nov 29 00:22:53 tellur kernel: [13986.409328]  [<ffffffff813c1e7b>] cpuidle_idle_call+0xf8/0x189
Nov 29 00:22:53 tellur kernel: [13986.409331]  [<ffffffff8100e2e8>] cpu_idle+0xa9/0xf0
Nov 29 00:22:53 tellur kernel: [13986.409335]  [<ffffffff81498652>] start_secondary+0x23f/0x241
Nov 29 00:22:53 tellur kernel: [13936.370598] NMI backtrace for cpu 0
Nov 29 00:22:53 tellur kernel: [13936.370598] CPU 0 
Nov 29 00:22:53 tellur kernel: [13936.370598] Modules linked in: tcp_lp ppdev parport_pc lp parport fuse nfs fscache auth_rpcgss nfs_acl ebtable_nat ebtables ipt_MASQUERADE iptable_nat nf_nat iptable_mangle tun lockd bridge stp llc bluetooth rfkill it87 adt7475 hwmon_vid ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm ir_lirc_codec lirc_dev ir_mce_kbd_decoder snd_timer snd ir_sony_decoder ir_jvc_decoder ir_rc6_decoder ata_generic pata_acpi edac_core serio_raw soundcore joydev ir_rc5_decoder pata_atiixp ir_nec_decoder r8169 mii mceusb rc_core virtio_net edac_mce_amd sp5100_tco i2c_piix4 xhci_hcd fam15h_power pcspkr snd_page_alloc microcode k10temp virtio_ring virtio kvm_amd kvm
  uinput sunrpc ipv6 usb_storage firewire_ohci uas firewire_core crc_itu_t nouveau ttm drm_kms_helper drm hwmon i2c_algo_bit i2c_core mxm_wmi video wmi [last unloaded: scsi_wait_scan]
Nov 29 00:22:53 tellur kernel: [13936.370598] 
Nov 29 00:22:53 tellur kernel: [13936.370598] Pid: 0, comm: swapper Tainted: G        W    3.2.0-rc3+ #39 Gigabyte Technology Co., Ltd. GA-970A-UD3/GA-970A-UD3
Nov 29 00:22:53 tellur kernel: [13936.370598] RIP: 0010:[<ffffffffa023bf55>]  [<ffffffffa023bf55>] rtl8169_interrupt+0x268/0x2a4 [r8169]
Nov 29 00:22:53 tellur kernel: [13936.370598] RSP: 0018:ffff88042ec03e68  EFLAGS: 00000006
Nov 29 00:22:53 tellur kernel: [13936.370598] RAX: 0000000000000050 RBX: ffff8803f6188000 RCX: ffff88042ec13f90
Nov 29 00:22:53 tellur kernel: [13936.370598] RDX: 0000000000000000 RSI: ffff88042ec13f90 RDI: 0000000000000092
Nov 29 00:22:53 tellur kernel: [13936.370598] RBP: ffff88042ec03eb8 R08: ffff88042ec13f90 R09: 000000000000002d
Nov 29 00:22:53 tellur kernel: [13936.370598] R10: ffff8803ef3a5c40 R11: ffff8804144fae68 R12: 0000000000000040
Nov 29 00:22:53 tellur kernel: [13936.370598] R13: ffffc9001273e000 R14: ffffc9001273e03e R15: ffff8803f6188780
Nov 29 00:22:53 tellur kernel: [13936.370598] FS:  00007f137bda29c0(0000) GS:ffff88042ec00000(0000) knlGS:0000000000000000
Nov 29 00:22:53 tellur kernel: [13936.370598] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Nov 29 00:22:53 tellur kernel: [13936.370598] CR2: 00007f1369168000 CR3: 00000003f46e8000 CR4: 00000000000406f0
Nov 29 00:22:53 tellur kernel: [13936.370598] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Nov 29 00:22:53 tellur kernel: [13936.370598] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Nov 29 00:22:53 tellur kernel: [13936.370598] Process swapper (pid: 0, threadinfo ffffffff81a00000, task ffffffff81a0d020)
Nov 29 00:22:53 tellur kernel: [13936.370598] Stack:
Nov 29 00:22:53 tellur kernel: [13936.370598]  ffff8803f6188798 0000004081014d65 ffff88042ec03e88 ffffffff81014de7
Nov 29 00:22:53 tellur kernel: [13936.370598]  ffff88042ec03e98 ffff880404ebf580 ffff88040e9b3e00 000000000000002b
Nov 29 00:22:53 tellur kernel: [13936.370598]  0000000000000000 125a8b380294c398 ffff88042ec03f08 ffffffff810a841d
Nov 29 00:22:53 tellur kernel: [13936.370598] Call Trace:
Nov 29 00:22:53 tellur kernel: [13936.370598]  <IRQ> 
Nov 29 00:22:53 tellur kernel: [13936.370598]  [<ffffffff81014de7>] ? read_tsc+0x9/0x19
Nov 29 00:22:53 tellur kernel: [13936.370598]  [<ffffffff810a841d>] handle_irq_event_percpu+0x5f/0x193
Nov 29 00:22:53 tellur kernel: [13936.370598]  [<ffffffff810a858c>] handle_irq_event+0x3b/0x57
Nov 29 00:22:53 tellur kernel: [13936.370598]  [<ffffffff810293ac>] ? ack_apic_edge+0x24/0x28
Nov 29 00:22:53 tellur kernel: [13936.370598]  [<ffffffff810aad4e>] handle_edge_irq+0xa6/0xcc
Nov 29 00:22:53 tellur kernel: [13936.370598]  [<ffffffff81010a95>] handle_irq+0x88/0x8e
Nov 29 00:22:53 tellur kernel: [13936.370598]  [<ffffffff814b214d>] do_IRQ+0x4d/0xa5
Nov 29 00:22:53 tellur kernel: [13936.370598]  [<ffffffff814a92ae>] common_interrupt+0x6e/0x6e
Nov 29 00:22:53 tellur kernel: [13936.370598]  <EOI> 
Nov 29 00:22:53 tellur kernel: [13936.370598]  [<ffffffff8102f369>] ? native_safe_halt+0xb/0xd
Nov 29 00:22:53 tellur kernel: [13936.370598]  [<ffffffff812afe54>] acpi_safe_halt+0x2a/0x43
Nov 29 00:22:53 tellur kernel: [13936.370598]  [<ffffffff812afe8d>] acpi_idle_do_entry+0x20/0x30
Nov 29 00:22:53 tellur kernel: [13936.370598]  [<ffffffff812b030e>] acpi_idle_enter_c1+0x62/0xbf
Nov 29 00:22:53 tellur kernel: [13936.370598]  [<ffffffff813c1e7b>] cpuidle_idle_call+0xf8/0x189
Nov 29 00:22:53 tellur kernel: [13936.370598]  [<ffffffff8100e2e8>] cpu_idle+0xa9/0xf0
Nov 29 00:22:53 tellur kernel: [13936.370598]  [<ffffffff81487a9e>] rest_init+0x72/0x74
Nov 29 00:22:53 tellur kernel: [13936.370598]  [<ffffffff81b67b6c>] start_kernel+0x3ab/0x3b8
Nov 29 00:22:53 tellur kernel: [13936.370598]  [<ffffffff81b672c4>] x86_64_start_reservations+0xaf/0xb3
Nov 29 00:22:53 tellur kernel: [13936.370598]  [<ffffffff81b67140>] ? early_idt_handlers+0x140/0x140
Nov 29 00:22:53 tellur kernel: [13936.370598]  [<ffffffff81b673ca>] x86_64_start_kernel+0x102/0x111
Nov 29 00:22:53 tellur kernel: [13936.370598] Code: 48 c7 c6 69 e5 23 a0 48 89 df 31 c0 e8 74 3d 1b e1 83 7d bc 00 41 0f b7 c4 74 08 41 83 cc 10 41 0f b7 c4 66 41 89 06 66 45 8b 26 <b8> 01 00 00 00 45 0f b7 e4 41 81 fc ff ff 00 00 74 10 45 85 e4 
Nov 29 00:22:53 tellur kernel: [13936.370598] Call Trace:
Nov 29 00:22:53 tellur kernel: [13936.370598]  <IRQ>  [<ffffffff81014de7>] ? read_tsc+0x9/0x19
Nov 29 00:22:53 tellur kernel: [13936.370598]  [<ffffffff810a841d>] handle_irq_event_percpu+0x5f/0x193
Nov 29 00:22:53 tellur kernel: [13936.370598]  [<ffffffff810a858c>] handle_irq_event+0x3b/0x57
Nov 29 00:22:53 tellur kernel: [13936.370598]  [<ffffffff810293ac>] ? ack_apic_edge+0x24/0x28
Nov 29 00:22:53 tellur kernel: [13936.370598]  [<ffffffff810aad4e>] handle_edge_irq+0xa6/0xcc
Nov 29 00:22:53 tellur kernel: [13936.370598]  [<ffffffff81010a95>] handle_irq+0x88/0x8e
Nov 29 00:22:53 tellur kernel: [13936.370598]  [<ffffffff814b214d>] do_IRQ+0x4d/0xa5
Nov 29 00:22:53 tellur kernel: [13936.370598]  [<ffffffff814a92ae>] common_interrupt+0x6e/0x6e
Nov 29 00:22:53 tellur kernel: [13936.370598]  <EOI>  [<ffffffff8102f369>] ? native_safe_halt+0xb/0xd
Nov 29 00:22:53 tellur kernel: [13936.370598]  [<ffffffff812afe54>] acpi_safe_halt+0x2a/0x43
Nov 29 00:22:53 tellur kernel: [13936.370598]  [<ffffffff812afe8d>] acpi_idle_do_entry+0x20/0x30
Nov 29 00:22:53 tellur kernel: [13936.370598]  [<ffffffff812b030e>] acpi_idle_enter_c1+0x62/0xbf
Nov 29 00:22:53 tellur kernel: [13936.370598]  [<ffffffff813c1e7b>] cpuidle_idle_call+0xf8/0x189
Nov 29 00:22:53 tellur kernel: [13936.370598]  [<ffffffff8100e2e8>] cpu_idle+0xa9/0xf0
Nov 29 00:22:53 tellur kernel: [13936.370598]  [<ffffffff81487a9e>] rest_init+0x72/0x74
Nov 29 00:22:53 tellur kernel: [13936.370598]  [<ffffffff81b67b6c>] start_kernel+0x3ab/0x3b8
Nov 29 00:22:53 tellur kernel: [13936.370598]  [<ffffffff81b672c4>] x86_64_start_reservations+0xaf/0xb3
Nov 29 00:22:53 tellur kernel: [13936.370598]  [<ffffffff81b67140>] ? early_idt_handlers+0x140/0x140
Nov 29 00:22:53 tellur kernel: [13936.370598]  [<ffffffff81b673ca>] x86_64_start_kernel+0x102/0x111
Nov 29 00:22:53 tellur kernel: [13986.409076] NMI backtrace for cpu 5
Nov 29 00:22:53 tellur kernel: [13986.409076] CPU 5 
Nov 29 00:22:53 tellur kernel: [13986.409076] Modules linked in: tcp_lp ppdev parport_pc lp parport fuse nfs fscache auth_rpcgss nfs_acl ebtable_nat ebtables ipt_MASQUERADE iptable_nat nf_nat iptable_mangle tun lockd bridge stp llc bluetooth rfkill it87 adt7475 hwmon_vid ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm ir_lirc_codec lirc_dev ir_mce_kbd_decoder snd_timer snd ir_sony_decoder ir_jvc_decoder ir_rc6_decoder ata_generic pata_acpi edac_core serio_raw soundcore joydev ir_rc5_decoder pata_atiixp ir_nec_decoder r8169 mii mceusb rc_core virtio_net edac_mce_amd sp5100_tco i2c_piix4 xhci_hcd fam15h_power pcspkr snd_page_alloc microcode k10temp virtio_ring virtio kvm_amd kvm
  uinput sunrpc ipv6 usb_storage firewire_ohci uas firewire_core crc_itu_t nouveau ttm drm_kms_helper drm hwmon i2c_algo_bit i2c_core mxm_wmi video wmi [last unloaded: scsi_wait_scan]
Nov 29 00:22:53 tellur kernel: [13986.409076] 
Nov 29 00:22:53 tellur kernel: [13986.409076] Pid: 0, comm: kworker/0:1 Tainted: G        W    3.2.0-rc3+ #39 Gigabyte Technology Co., Ltd. GA-970A-UD3/GA-970A-UD3
Nov 29 00:22:53 tellur kernel: [13986.409076] RIP: 0010:[<ffffffff812afe93>]  [<ffffffff812afe93>] acpi_idle_do_entry+0x26/0x30
Nov 29 00:22:53 tellur kernel: [13986.409076] RSP: 0018:ffff8804145bfe68  EFLAGS: 00000093
Nov 29 00:22:53 tellur kernel: [13986.409076] RAX: 00000cb876e2ac00 RBX: ffff88040edf4260 RCX: 00000cb876e2a476
Nov 29 00:22:53 tellur kernel: [13986.409076] RDX: 0000000000000841 RSI: 00000000000007d6 RDI: ffff88040edf4260
Nov 29 00:22:53 tellur kernel: [13986.409076] RBP: ffff8804145bfe68 R08: 0000000000000064 R09: 0000000000000389
Nov 29 00:22:53 tellur kernel: [13986.409076] R10: 00007fc830f4a820 R11: 0000000000000202 R12: 0000000000000002
Nov 29 00:22:53 tellur kernel: [13986.409076] R13: ffff88040edf4000 R14: ffff88040edf4020 R15: 125a8b45fe8f1164
Nov 29 00:22:53 tellur kernel: [13986.409076] FS:  00007fc830f4b700(0000) GS:ffff88042ed40000(0000) knlGS:0000000000000000
Nov 29 00:22:53 tellur kernel: [13986.409076] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Nov 29 00:22:53 tellur kernel: [13986.409076] CR2: 00007fefe4e16000 CR3: 0000000001a05000 CR4: 00000000000406e0
Nov 29 00:22:53 tellur kernel: [13986.409076] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Nov 29 00:22:53 tellur kernel: [13986.409076] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Nov 29 00:22:53 tellur kernel: [13986.409076] Process kworker/0:1 (pid: 0, threadinfo ffff8804145be000, task ffff8804145c1710)
Nov 29 00:22:53 tellur kernel: [13986.409076] Stack:
Nov 29 00:22:53 tellur kernel: [13986.409076]  ffff8804145bfea8 ffffffff812b0241 00007fc830f4a820 ffff88040edf4020
Nov 29 00:22:53 tellur kernel: [13986.409076]  ffffffff81a63ae0 00000000fffffff0 0000000000000002 ffffffff81a63b90
Nov 29 00:22:53 tellur kernel: [13986.409076]  ffff8804145bfef8 ffffffff813c1e7b ffff8804145bffd8 0000000581b48ee0
Nov 29 00:22:53 tellur kernel: [13986.409076] Call Trace:
Nov 29 00:22:53 tellur kernel: [13986.409076]  [<ffffffff812b0241>] acpi_idle_enter_simple+0xaa/0x115
Nov 29 00:22:53 tellur kernel: [13986.409076]  [<ffffffff813c1e7b>] cpuidle_idle_call+0xf8/0x189
Nov 29 00:22:53 tellur kernel: [13986.409076]  [<ffffffff8100e2e8>] cpu_idle+0xa9/0xf0
Nov 29 00:22:53 tellur kernel: [13986.409076]  [<ffffffff81498652>] start_secondary+0x23f/0x241
Nov 29 00:22:53 tellur kernel: [13986.409076] Code: ff ff 04 5d c3 55 48 89 e5 66 66 66 66 90 8a 47 08 3c 01 75 07 e8 07 5d d7 ff eb 17 3c 02 75 07 e8 9d ff ff ff eb 0c 8b 57 04 ec 
Nov 29 00:22:53 tellur kernel: [13986.409076] Call Trace:
Nov 29 00:22:53 tellur kernel: [13986.409076]  [<ffffffff812b0241>] acpi_idle_enter_simple+0xaa/0x115
Nov 29 00:22:53 tellur kernel: [13986.409076]  [<ffffffff813c1e7b>] cpuidle_idle_call+0xf8/0x189
Nov 29 00:22:53 tellur kernel: [13986.409076]  [<ffffffff8100e2e8>] cpu_idle+0xa9/0xf0
Nov 29 00:22:53 tellur kernel: [13986.409076]  [<ffffffff81498652>] start_secondary+0x23f/0x241
Nov 29 00:22:53 tellur kernel: [13986.409076] NMI backtrace for cpu 4
Nov 29 00:22:53 tellur kernel: [13986.409076] CPU 4 
Nov 29 00:22:53 tellur kernel: [13986.409076] Modules linked in: tcp_lp ppdev parport_pc lp parport fuse nfs fscache auth_rpcgss nfs_acl ebtable_nat ebtables ipt_MASQUERADE iptable_nat nf_nat iptable_mangle tun lockd bridge stp llc bluetooth rfkill it87 adt7475 hwmon_vid ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm ir_lirc_codec lirc_dev ir_mce_kbd_decoder snd_timer snd ir_sony_decoder ir_jvc_decoder ir_rc6_decoder ata_generic pata_acpi edac_core serio_raw soundcore joydev ir_rc5_decoder pata_atiixp ir_nec_decoder r8169 mii mceusb rc_core virtio_net edac_mce_amd sp5100_tco i2c_piix4 xhci_hcd fam15h_power pcspkr snd_page_alloc microcode k10temp virtio_ring virtio kvm_amd kvm
  uinput sunrpc ipv6 usb_storage firewire_ohci uas firewire_core crc_itu_t nouveau ttm drm_kms_helper drm hwmon i2c_algo_bit i2c_core mxm_wmi video wmi [last unloaded: scsi_wait_scan]
Nov 29 00:22:53 tellur kernel: [13986.409076] 
Nov 29 00:22:53 tellur kernel: [13986.409076] Pid: 0, comm: kworker/0:1 Tainted: G        W    3.2.0-rc3+ #39 Gigabyte Technology Co., Ltd. GA-970A-UD3/GA-970A-UD3
Nov 29 00:22:53 tellur kernel: [13986.409076] RIP: 0010:[<ffffffff812afe93>]  [<ffffffff812afe93>] acpi_idle_do_entry+0x26/0x30
Nov 29 00:22:53 tellur kernel: [13986.409076] RSP: 0018:ffff8804145a5e68  EFLAGS: 00000093
Nov 29 00:22:53 tellur kernel: [13986.409076] RAX: 00000cb876e2ac00 RBX: ffff88040edf3a60 RCX: 00000cb876e2a472
Nov 29 00:22:53 tellur kernel: [13986.409076] RDX: 0000000000000841 RSI: 00000000000007be RDI: ffff88040edf3a60
Nov 29 00:22:53 tellur kernel: [13986.409076] RBP: ffff8804145a5e68 R08: 0000000000000064 R09: 0000000000000389
Nov 29 00:22:53 tellur kernel: [13986.409076] R10: 0000000000000000 R11: 0000000000000293 R12: 0000000000000002
Nov 29 00:22:53 tellur kernel: [13986.409076] R13: ffff88040edf3800 R14: ffff88040edf3820 R15: 125a8b45fe8f1155
Nov 29 00:22:53 tellur kernel: [13986.409076] FS:  00007f8a62e47700(0000) GS:ffff88042ed00000(0000) knlGS:0000000000000000
Nov 29 00:22:53 tellur kernel: [13986.409076] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Nov 29 00:22:53 tellur kernel: [13986.409076] CR2: 00007f8a5815b000 CR3: 00000003ee023000 CR4: 00000000000406e0
Nov 29 00:22:53 tellur kernel: [13986.409076] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Nov 29 00:22:53 tellur kernel: [13986.409076] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Nov 29 00:22:53 tellur kernel: [13986.409076] Process kworker/0:1 (pid: 0, threadinfo ffff8804145a4000, task ffff8804145a9710)
Nov 29 00:22:53 tellur kernel: [13986.409076] Stack:
Nov 29 00:22:53 tellur kernel: [13986.409076]  ffff8804145a5ea8 ffffffff812b0241 0000000000000000 ffff88040edf3820
Nov 29 00:22:53 tellur kernel: [13986.409076]  ffffffff81a63ae0 00000000fffffff0 0000000000000002 ffffffff81a63b90
Nov 29 00:22:53 tellur kernel: [13986.409076]  ffff8804145a5ef8 ffffffff813c1e7b ffff8804145a5fd8 0000000481b48ee0
Nov 29 00:22:53 tellur kernel: [13986.409076] Call Trace:
Nov 29 00:22:53 tellur kernel: [13986.409076]  [<ffffffff812b0241>] acpi_idle_enter_simple+0xaa/0x115
Nov 29 00:22:53 tellur kernel: [13986.409076]  [<ffffffff813c1e7b>] cpuidle_idle_call+0xf8/0x189
Nov 29 00:22:53 tellur kernel: [13986.409076]  [<ffffffff8100e2e8>] cpu_idle+0xa9/0xf0
Nov 29 00:22:53 tellur kernel: [13986.409076]  [<ffffffff81498652>] start_secondary+0x23f/0x241
Nov 29 00:22:53 tellur kernel: [13986.409076] Code: ff ff 04 5d c3 55 48 89 e5 66 66 66 66 90 8a 47 08 3c 01 75 07 e8 07 5d d7 ff eb 17 3c 02 75 07 e8 9d ff ff ff eb 0c 8b 57 04 ec 
Nov 29 00:22:53 tellur kernel: [13986.409076] Call Trace:
Nov 29 00:22:53 tellur kernel: [13986.409076]  [<ffffffff812b0241>] acpi_idle_enter_simple+0xaa/0x115
Nov 29 00:22:53 tellur kernel: [13986.409076]  [<ffffffff813c1e7b>] cpuidle_idle_call+0xf8/0x189
Nov 29 00:22:53 tellur kernel: [13986.409076]  [<ffffffff8100e2e8>] cpu_idle+0xa9/0xf0
Nov 29 00:22:53 tellur kernel: [13986.409076]  [<ffffffff81498652>] start_secondary+0x23f/0x241
Nov 29 00:22:53 tellur kernel: [13986.409080] NMI backtrace for cpu 6
Nov 29 00:22:53 tellur kernel: [13986.409080] CPU 6 
Nov 29 00:22:53 tellur kernel: [13986.409080] Modules linked in: tcp_lp ppdev parport_pc lp parport fuse nfs fscache auth_rpcgss nfs_acl ebtable_nat ebtables ipt_MASQUERADE iptable_nat nf_nat iptable_mangle tun lockd bridge stp llc bluetooth rfkill it87 adt7475 hwmon_vid ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm ir_lirc_codec lirc_dev ir_mce_kbd_decoder snd_timer snd ir_sony_decoder ir_jvc_decoder ir_rc6_decoder ata_generic pata_acpi edac_core serio_raw soundcore joydev ir_rc5_decoder pata_atiixp ir_nec_decoder r8169 mii mceusb rc_core virtio_net edac_mce_amd sp5100_tco i2c_piix4 xhci_hcd fam15h_power pcspkr snd_page_alloc microcode k10temp virtio_ring virtio kvm_amd kvm
  uinput sunrpc ipv6 usb_storage firewire_ohci uas firewire_core crc_itu_t nouveau ttm drm_kms_helper drm hwmon i2c_algo_bit i2c_core mxm_wmi video wmi [last unloaded: scsi_wait_scan]
Nov 29 00:22:53 tellur kernel: [13986.409080] 
Nov 29 00:22:53 tellur kernel: [13986.409080] Pid: 0, comm: kworker/0:1 Tainted: G        W    3.2.0-rc3+ #39 Gigabyte Technology Co., Ltd. GA-970A-UD3/GA-970A-UD3
Nov 29 00:22:53 tellur kernel: [13986.409080] RIP: 0010:[<ffffffff812afe93>]  [<ffffffff812afe93>] acpi_idle_do_entry+0x26/0x30
Nov 29 00:22:53 tellur kernel: [13986.409080] RSP: 0018:ffff8804145e5e68  EFLAGS: 00000093
Nov 29 00:22:53 tellur kernel: [13986.409080] RAX: 00000cb876e2c600 RBX: ffff88040edf4a60 RCX: 00000cb876e2c168
Nov 29 00:22:53 tellur kernel: [13986.409080] RDX: 0000000000000841 RSI: 00000000000004b6 RDI: ffff88040edf4a60
Nov 29 00:22:53 tellur kernel: [13986.409080] RBP: ffff8804145e5e68 R08: 0000000000000064 R09: 0000000000000389
Nov 29 00:22:53 tellur kernel: [13986.409080] R10: 0000000000000a6f R11: 0000000000000000 R12: 0000000000000002
Nov 29 00:22:53 tellur kernel: [13986.409080] R13: ffff88040edf4800 R14: ffff88040edf4820 R15: 125a8b45fe8f2b48
Nov 29 00:22:53 tellur kernel: [13986.409080] FS:  00007fdef1f589c0(0000) GS:ffff88042ed80000(0000) knlGS:0000000000000000
Nov 29 00:22:53 tellur kernel: [13986.409080] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Nov 29 00:22:53 tellur kernel: [13986.409080] CR2: 00007fc8441981a8 CR3: 00000003a06db000 CR4: 00000000000406e0
Nov 29 00:22:53 tellur kernel: [13986.409080] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Nov 29 00:22:53 tellur kernel: [13986.409080] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Nov 29 00:22:53 tellur kernel: [13986.409080] Process kworker/0:1 (pid: 0, threadinfo ffff8804145e4000, task ffff8804145e9710)
Nov 29 00:22:53 tellur kernel: [13986.409080] Stack:
Nov 29 00:22:53 tellur kernel: [13986.409080]  ffff8804145e5ea8 ffffffff812b0241 0000000000000a6f ffff88040edf4820
Nov 29 00:22:53 tellur kernel: [13986.409080]  ffffffff81a63ae0 00000000fffffff0 0000000000000002 ffffffff81a63b90
Nov 29 00:22:53 tellur kernel: [13986.409080]  ffff8804145e5ef8 ffffffff813c1e7b ffff8804145e5fd8 0000000681b48ee0
Nov 29 00:22:53 tellur kernel: [13986.409080] Call Trace:
Nov 29 00:22:53 tellur kernel: [13986.409080]  [<ffffffff812b0241>] acpi_idle_enter_simple+0xaa/0x115
Nov 29 00:22:53 tellur kernel: [13986.409080]  [<ffffffff813c1e7b>] cpuidle_idle_call+0xf8/0x189
Nov 29 00:22:53 tellur kernel: [13986.409080]  [<ffffffff8100e2e8>] cpu_idle+0xa9/0xf0
Nov 29 00:22:53 tellur kernel: [13986.409080]  [<ffffffff81498652>] start_secondary+0x23f/0x241
Nov 29 00:22:53 tellur kernel: [13986.409080] Code: ff ff 04 5d c3 55 48 89 e5 66 66 66 66 90 8a 47 08 3c 01 75 07 e8 07 5d d7 ff eb 17 3c 02 75 07 e8 9d ff ff ff eb 0c 8b 57 04 ec 
Nov 29 00:22:53 tellur kernel: [13986.409080] Call Trace:
Nov 29 00:22:53 tellur kernel: [13986.409080]  [<ffffffff812b0241>] acpi_idle_enter_simple+0xaa/0x115
Nov 29 00:22:53 tellur kernel: [13986.409080]  [<ffffffff813c1e7b>] cpuidle_idle_call+0xf8/0x189
Nov 29 00:22:53 tellur kernel: [13986.409080]  [<ffffffff8100e2e8>] cpu_idle+0xa9/0xf0
Nov 29 00:22:53 tellur kernel: [13986.409080]  [<ffffffff81498652>] start_secondary+0x23f/0x241
Nov 29 00:22:53 tellur kernel: [13986.409080] NMI backtrace for cpu 7
Nov 29 00:22:53 tellur kernel: [13986.409080] CPU 7 
Nov 29 00:22:53 tellur kernel: [13986.409080] Modules linked in: tcp_lp ppdev parport_pc lp parport fuse nfs fscache auth_rpcgss nfs_acl ebtable_nat ebtables ipt_MASQUERADE iptable_nat nf_nat iptable_mangle tun lockd bridge stp llc bluetooth rfkill it87 adt7475 hwmon_vid ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm ir_lirc_codec lirc_dev ir_mce_kbd_decoder snd_timer snd ir_sony_decoder ir_jvc_decoder ir_rc6_decoder ata_generic pata_acpi edac_core serio_raw soundcore joydev ir_rc5_decoder pata_atiixp ir_nec_decoder r8169 mii mceusb rc_core virtio_net edac_mce_amd sp5100_tco i2c_piix4 xhci_hcd fam15h_power pcspkr snd_page_alloc microcode k10temp virtio_ring virtio kvm_amd kvm
  uinput sunrpc ipv6 usb_storage firewire_ohci uas firewire_core crc_itu_t nouveau ttm drm_kms_helper drm hwmon i2c_algo_bit i2c_core mxm_wmi video wmi [last unloaded: scsi_wait_scan]
Nov 29 00:22:53 tellur kernel: [13986.409080] 
Nov 29 00:22:53 tellur kernel: [13986.409080] Pid: 0, comm: kworker/0:1 Tainted: G        W    3.2.0-rc3+ #39 Gigabyte Technology Co., Ltd. GA-970A-UD3/GA-970A-UD3
Nov 29 00:22:53 tellur kernel: [13986.409080] RIP: 0010:[<ffffffff812afe93>]  [<ffffffff812afe93>] acpi_idle_do_entry+0x26/0x30
Nov 29 00:22:53 tellur kernel: [13986.409080] RSP: 0018:ffff880414621e68  EFLAGS: 00000093
Nov 29 00:22:53 tellur kernel: [13986.409080] RAX: 00000cb876e2bc00 RBX: ffff88040edf5260 RCX: 00000cb876e2b484
Nov 29 00:22:53 tellur kernel: [13986.409080] RDX: 0000000000000841 RSI: 00000000000007bd RDI: ffff88040edf5260
Nov 29 00:22:53 tellur kernel: [13986.409080] RBP: ffff880414621e68 R08: 0000000000000064 R09: 0000000000000389
Nov 29 00:22:53 tellur kernel: [13986.409080] R10: 00007fc84014bd40 R11: 0000000000000202 R12: 0000000000000002
Nov 29 00:22:53 tellur kernel: [13986.409080] R13: ffff88040edf5000 R14: ffff88040edf5020 R15: 125a8b45fe8f2160
Nov 29 00:22:53 tellur kernel: [13986.409080] FS:  00007fc84014c700(0000) GS:ffff88042edc0000(0000) knlGS:0000000000000000
Nov 29 00:22:53 tellur kernel: [13986.409080] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Nov 29 00:22:53 tellur kernel: [13986.409080] CR2: 00007f3f7dc9ec4c CR3: 00000003ef51c000 CR4: 00000000000406e0
Nov 29 00:22:53 tellur kernel: [13986.409080] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Nov 29 00:22:53 tellur kernel: [13986.409080] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Nov 29 00:22:53 tellur kernel: [13986.409080] Process kworker/0:1 (pid: 0, threadinfo ffff880414620000, task ffff8804145f9710)
Nov 29 00:22:53 tellur kernel: [13986.409080] Stack:
Nov 29 00:22:53 tellur kernel: [13986.409080]  ffff880414621ea8 ffffffff812b0241 00007fc84014bd40 ffff88040edf5020
Nov 29 00:22:53 tellur kernel: [13986.409080]  ffffffff81a63ae0 00000000fffffff0 0000000000000002 ffffffff81a63b90
Nov 29 00:22:53 tellur kernel: [13986.409080]  ffff880414621ef8 ffffffff813c1e7b ffff880414621fd8 0000000781b48ee0
Nov 29 00:22:53 tellur kernel: [13986.409080] Call Trace:
Nov 29 00:22:53 tellur kernel: [13986.409080]  [<ffffffff812b0241>] acpi_idle_enter_simple+0xaa/0x115
Nov 29 00:22:53 tellur kernel: [13986.409080]  [<ffffffff813c1e7b>] cpuidle_idle_call+0xf8/0x189
Nov 29 00:22:53 tellur kernel: [13986.409080]  [<ffffffff8100e2e8>] cpu_idle+0xa9/0xf0
Nov 29 00:22:53 tellur kernel: [13986.409080]  [<ffffffff81498652>] start_secondary+0x23f/0x241
Nov 29 00:22:53 tellur kernel: [13986.409080] Code: ff ff 04 5d c3 55 48 89 e5 66 66 66 66 90 8a 47 08 3c 01 75 07 e8 07 5d d7 ff eb 17 3c 02 75 07 e8 9d ff ff ff eb 0c 8b 57 04 ec 
Nov 29 00:22:53 tellur kernel: [13986.409080] Call Trace:
Nov 29 00:22:53 tellur kernel: [13986.409080]  [<ffffffff812b0241>] acpi_idle_enter_simple+0xaa/0x115
Nov 29 00:22:53 tellur kernel: [13986.409080]  [<ffffffff813c1e7b>] cpuidle_idle_call+0xf8/0x189
Nov 29 00:22:53 tellur kernel: [13986.409080]  [<ffffffff8100e2e8>] cpu_idle+0xa9/0xf0
Nov 29 00:22:53 tellur kernel: [13986.409080]  [<ffffffff81498652>] start_secondary+0x23f/0x241
Nov 29 00:22:53 tellur kernel: [13986.409081] NMI backtrace for cpu 2
Nov 29 00:22:53 tellur kernel: [13986.409081] CPU 2 
Nov 29 00:22:53 tellur kernel: [13986.409081] Modules linked in: tcp_lp ppdev parport_pc lp parport fuse nfs fscache auth_rpcgss nfs_acl ebtable_nat ebtables ipt_MASQUERADE iptable_nat nf_nat iptable_mangle tun lockd bridge stp llc bluetooth rfkill it87 adt7475 hwmon_vid ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm ir_lirc_codec lirc_dev ir_mce_kbd_decoder snd_timer snd ir_sony_decoder ir_jvc_decoder ir_rc6_decoder ata_generic pata_acpi edac_core serio_raw soundcore joydev ir_rc5_decoder pata_atiixp ir_nec_decoder r8169 mii mceusb rc_core virtio_net edac_mce_amd sp5100_tco i2c_piix4 xhci_hcd fam15h_power pcspkr snd_page_alloc microcode k10temp virtio_ring virtio kvm_amd kvm
  uinput sunrpc ipv6 usb_storage firewire_ohci uas firewire_core crc_itu_t nouveau ttm drm_kms_helper drm hwmon i2c_algo_bit i2c_core mxm_wmi video wmi [last unloaded: scsi_wait_scan]
Nov 29 00:22:53 tellur kernel: [13986.409081] 
Nov 29 00:22:53 tellur kernel: [13986.409081] Pid: 0, comm: kworker/0:1 Tainted: G        W    3.2.0-rc3+ #39 Gigabyte Technology Co., Ltd. GA-970A-UD3/GA-970A-UD3
Nov 29 00:22:53 tellur kernel: [13986.409081] RIP: 0010:[<ffffffff812afe93>]  [<ffffffff812afe93>] acpi_idle_do_entry+0x26/0x30
Nov 29 00:22:53 tellur kernel: [13986.409081] RSP: 0018:ffff880414579e68  EFLAGS: 00000093
Nov 29 00:22:53 tellur kernel: [13986.409081] RAX: 00000cb876e2c100 RBX: ffff88040edf2a60 RCX: 00000cb876e2b9c6
Nov 29 00:22:53 tellur kernel: [13986.409081] RDX: 0000000000000841 RSI: 00000000000007db RDI: ffff88040edf2a60
Nov 29 00:22:53 tellur kernel: [13986.409081] RBP: ffff880414579e68 R08: 0000000000000064 R09: 0000000000000382
Nov 29 00:22:53 tellur kernel: [13986.409081] R10: 0000000000000001 R11: 0000000000000293 R12: 0000000000000002
Nov 29 00:22:53 tellur kernel: [13986.409081] R13: ffff88040edf2800 R14: ffff88040edf2820 R15: 125a8b45fe8f26be
Nov 29 00:22:53 tellur kernel: [13986.409081] FS:  00007fded085f700(0000) GS:ffff88042ec80000(0000) knlGS:0000000000000000
Nov 29 00:22:53 tellur kernel: [13986.409081] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Nov 29 00:22:53 tellur kernel: [13986.409081] CR2: 00007fb17c005078 CR3: 00000003a06db000 CR4: 00000000000406e0
Nov 29 00:22:53 tellur kernel: [13986.409081] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Nov 29 00:22:53 tellur kernel: [13986.409081] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Nov 29 00:22:53 tellur kernel: [13986.409081] Process kworker/0:1 (pid: 0, threadinfo ffff880414578000, task ffff880414551710)
Nov 29 00:22:53 tellur kernel: [13986.409081] Stack:
Nov 29 00:22:53 tellur kernel: [13986.409081]  ffff880414579ea8 ffffffff812b0241 0000000000000001 ffff88040edf2820
Nov 29 00:22:53 tellur kernel: [13986.409081]  ffffffff81a63ae0 00000000fffffff0 0000000000000002 ffffffff81a63b90
Nov 29 00:22:53 tellur kernel: [13986.409081]  ffff880414579ef8 ffffffff813c1e7b ffff880414579fd8 0000000281b48ee0
Nov 29 00:22:53 tellur kernel: [13986.409081] Call Trace:
Nov 29 00:22:53 tellur kernel: [13986.409081]  [<ffffffff812b0241>] acpi_idle_enter_simple+0xaa/0x115
Nov 29 00:22:53 tellur kernel: [13986.409081]  [<ffffffff813c1e7b>] cpuidle_idle_call+0xf8/0x189
Nov 29 00:22:53 tellur kernel: [13986.409081]  [<ffffffff8100e2e8>] cpu_idle+0xa9/0xf0
Nov 29 00:22:53 tellur kernel: [13986.409081]  [<ffffffff81498652>] start_secondary+0x23f/0x241
Nov 29 00:22:53 tellur kernel: [13986.409081] Code: ff ff 04 5d c3 55 48 89 e5 66 66 66 66 90 8a 47 08 3c 01 75 07 e8 07 5d d7 ff eb 17 3c 02 75 07 e8 9d ff ff ff eb 0c 8b 57 04 ec 
Nov 29 00:22:53 tellur kernel: [13986.409081] Call Trace:
Nov 29 00:22:53 tellur kernel: [13986.409081]  [<ffffffff812b0241>] acpi_idle_enter_simple+0xaa/0x115
Nov 29 00:22:53 tellur kernel: [13986.409081]  [<ffffffff813c1e7b>] cpuidle_idle_call+0xf8/0x189
Nov 29 00:22:53 tellur kernel: [13986.409081]  [<ffffffff8100e2e8>] cpu_idle+0xa9/0xf0
Nov 29 00:22:53 tellur kernel: [13986.409081]  [<ffffffff81498652>] start_secondary+0x23f/0x241
Nov 29 00:22:53 tellur kernel: [13986.409081] NMI backtrace for cpu 3
Nov 29 00:22:53 tellur kernel: [13986.409081] CPU 3 
Nov 29 00:22:53 tellur kernel: [13986.409081] Modules linked in: tcp_lp ppdev parport_pc lp parport fuse nfs fscache auth_rpcgss nfs_acl ebtable_nat ebtables ipt_MASQUERADE iptable_nat nf_nat iptable_mangle tun lockd bridge stp llc bluetooth rfkill it87 adt7475 hwmon_vid ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm ir_lirc_codec lirc_dev ir_mce_kbd_decoder snd_timer snd ir_sony_decoder ir_jvc_decoder ir_rc6_decoder ata_generic pata_acpi edac_core serio_raw soundcore joydev ir_rc5_decoder pata_atiixp ir_nec_decoder r8169 mii mceusb rc_core virtio_net edac_mce_amd sp5100_tco i2c_piix4 xhci_hcd fam15h_power pcspkr snd_page_alloc microcode k10temp virtio_ring virtio kvm_amd kvm
  uinput sunrpc ipv6 usb_storage firewire_ohci uas firewire_core crc_itu_t nouveau ttm drm_kms_helper drm hwmon i2c_algo_bit i2c_core mxm_wmi video wmi [last unloaded: scsi_wait_scan]
Nov 29 00:22:53 tellur kernel: [13986.409081] 
Nov 29 00:22:53 tellur kernel: [13986.409081] Pid: 0, comm: kworker/0:1 Tainted: G        W    3.2.0-rc3+ #39 Gigabyte Technology Co., Ltd. GA-970A-UD3/GA-970A-UD3
Nov 29 00:22:53 tellur kernel: [13986.409081] RIP: 0010:[<ffffffff812afe93>]  [<ffffffff812afe93>] acpi_idle_do_entry+0x26/0x30
Nov 29 00:22:53 tellur kernel: [13986.409081] RSP: 0018:ffff88041458fe68  EFLAGS: 00000093
Nov 29 00:22:53 tellur kernel: [13986.409081] RAX: 00000cb876e2c100 RBX: ffff88040edf3260 RCX: 00000cb876e2b9da
Nov 29 00:22:53 tellur kernel: [13986.409081] RDX: 0000000000000841 RSI: 00000000000007f3 RDI: ffff88040edf3260
Nov 29 00:22:53 tellur kernel: [13986.409081] RBP: ffff88041458fe68 R08: 0000000000000064 R09: 0000000000000382
Nov 29 00:22:53 tellur kernel: [13986.409081] R10: 00007fc831f367a0 R11: 0000000000000202 R12: 0000000000000002
Nov 29 00:22:53 tellur kernel: [13986.409081] R13: ffff88040edf3000 R14: ffff88040edf3020 R15: 125a8b45fe8f26f3
Nov 29 00:22:53 tellur kernel: [13986.409081] FS:  00007fc831f37700(0000) GS:ffff88042ecc0000(0000) knlGS:0000000000000000
Nov 29 00:22:53 tellur kernel: [13986.409081] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Nov 29 00:22:53 tellur kernel: [13986.409081] CR2: 00007f3f7dc9ec4c CR3: 0000000001a05000 CR4: 00000000000406e0
Nov 29 00:22:53 tellur kernel: [13986.409081] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Nov 29 00:22:53 tellur kernel: [13986.409081] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Nov 29 00:22:53 tellur kernel: [13986.409081] Process kworker/0:1 (pid: 0, threadinfo ffff88041458e000, task ffff880414591710)
Nov 29 00:22:53 tellur kernel: [13986.409081] Stack:
Nov 29 00:22:53 tellur kernel: [13986.409081]  ffff88041458fea8 ffffffff812b0241 00007fc831f367a0 ffff88040edf3020
Nov 29 00:22:53 tellur kernel: [13986.409081]  ffffffff81a63ae0 00000000fffffff0 0000000000000002 ffffffff81a63b90
Nov 29 00:22:53 tellur kernel: [13986.409081]  ffff88041458fef8 ffffffff813c1e7b ffff88041458ffd8 0000000381b48ee0
Nov 29 00:22:53 tellur kernel: [13986.409081] Call Trace:
Nov 29 00:22:53 tellur kernel: [13986.409081]  [<ffffffff812b0241>] acpi_idle_enter_simple+0xaa/0x115
Nov 29 00:22:53 tellur kernel: [13986.409081]  [<ffffffff813c1e7b>] cpuidle_idle_call+0xf8/0x189
Nov 29 00:22:53 tellur kernel: [13986.409081]  [<ffffffff8100e2e8>] cpu_idle+0xa9/0xf0
Nov 29 00:22:53 tellur kernel: [13986.409081]  [<ffffffff81498652>] start_secondary+0x23f/0x241
Nov 29 00:22:53 tellur kernel: [13986.409081] Code: ff ff 04 5d c3 55 48 89 e5 66 66 66 66 90 8a 47 08 3c 01 75 07 e8 07 5d d7 ff eb 17 3c 02 75 07 e8 9d ff ff ff eb 0c 8b 57 04 ec 
Nov 29 00:22:53 tellur kernel: [13986.409081] Call Trace:
Nov 29 00:22:53 tellur kernel: [13986.409081]  [<ffffffff812b0241>] acpi_idle_enter_simple+0xaa/0x115
Nov 29 00:22:53 tellur kernel: [13986.409081]  [<ffffffff813c1e7b>] cpuidle_idle_call+0xf8/0x189
Nov 29 00:22:53 tellur kernel: [13986.409081]  [<ffffffff8100e2e8>] cpu_idle+0xa9/0xf0
Nov 29 00:22:53 tellur kernel: [13986.409081]  [<ffffffff81498652>] start_secondary+0x23f/0x241

--=-Ff/r2XgoguVDD+3ERzrv
Content-Disposition: attachment; filename="lspci"
Content-Type: text/plain; name="lspci"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

03:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 06)
	Subsystem: Giga-byte Technology GA-EP45-DS5 Motherboard
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 43
	Region 0: I/O ports at ee00 [size=256]
	Region 2: Memory at fdeff000 (64-bit, prefetchable) [size=4K]
	Region 4: Memory at fdef8000 (64-bit, prefetchable) [size=16K]
	Capabilities: [40] Power Management version 3
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [50] MSI: Enable+ Count=1/1 Maskable- 64bit+
		Address: 00000000fee0100c  Data: 4179
	Capabilities: [70] Express (v2) Endpoint, MSI 01
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <512ns, L1 <64us
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 4096 bytes
		DevSta:	CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+ TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 unlimited, L1 <64us
			ClockPM+ Surprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
		DevCap2: Completion Timeout: Range ABCD, TimeoutDis+
		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-
		LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-, Selectable De-emphasis: -6dB
			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
			 Compliance De-emphasis: -6dB
		LnkSta2: Current De-emphasis Level: -6dB
	Capabilities: [b0] MSI-X: Enable- Count=4 Masked-
		Vector table: BAR=4 offset=00000000
		PBA: BAR=4 offset=00000800
	Capabilities: [d0] Vital Product Data
		Unknown small resource type 00, will not decode more.
	Capabilities: [100 v1] Advanced Error Reporting
		UESta:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
		UESvrt:	DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
		CESta:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		CEMsk:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		AERCap:	First Error Pointer: 00, GenCap+ CGenEn- ChkCap+ ChkEn-
	Capabilities: [140 v1] Virtual Channel
		Caps:	LPEVC=0 RefClk=100ns PATEntryBits=1
		Arb:	Fixed- WRR32- WRR64- WRR128-
		Ctrl:	ArbSelect=Fixed
		Status:	InProgress-
		VC0:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
			Arb:	Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable+ ID=0 ArbSelect=Fixed TC/VC=ff
			Status:	NegoPending- InProgress-
	Capabilities: [160 v1] Device Serial Number 12-34-56-78-12-34-56-78
	Kernel driver in use: r8169
	Kernel modules: r8169


--=-Ff/r2XgoguVDD+3ERzrv--
