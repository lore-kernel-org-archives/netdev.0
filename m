From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: e1000e: hard system lockup on Linux 4.2
Date: Fri, 9 Oct 2015 21:21:40 +0200
Message-ID: <CAHmME9r9PbyqpRd6shT8Ep5WmLbUBv9dOdXRAzhGykgT0AM+sA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: intel-wired-lan@lists.osuosl.org, Netdev <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: jeffrey.t.kirsher@intel.com, raanan.avargil@intel.com,
	yanirx.lubetkin@intel.com,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeffrey & Raanan & Yanirx,

I have a Thinkpad W530 with a 82579LM inside of it, which uses the
e1000e driver. Every few hours, my system does a hard lockup, and I am
unable to do anything at all with it except power it off. There isn't
a panic or oops, as nothing is written to /sys/fs/pstore after. But, I
did enable the lockup detection debug option, and was able to gain a
few stack traces. And all of the time, the culprit is the e1000e
driver.

The funny thing is that I'm not actually using the Ethernet card --
nothing is plugged into the jack, as I'm mostly on wifi these days.
Nevertheless, it receives power from my laptop and thus the driver is
partaking in some form of communication with it.

The stack traces follow below. You'll notice that some time after the
initial e1000e lockup, the there's a soft lockup in the bpf paths. I
believe this is due to the fact that at the time of the hard lockup in
e1000e, I was trying to open a new Chrome tab process, which makes use
of seccomp-bpf. I do not believe the bug is in the bpf code, however.

Briefly looking at the stack trace myself shows quite a bit of
activity in `e1000e_cyclecounter_read`. Running `git log
drivers/net/ethernet/intel/e1000e` indicates a recent change from
Raanan -- 37b12910dd11d9ab969f2c310dc9160b7f3e3405 -- "e1000e: Fix
tight loop implementation of systime read algorithm". In this change,
a loop is entirely removed.

Investigating the origin of that loop reveals this commit from Yanirx
-- 83129b37ef35bb6a7f01c060129736a8db5d31c4. This commit appears to be
present in 4.2, but not in 4.1. This leads me to think it may be the
cause of the bug, with the aforementioned
37b12910dd11d9ab969f2c310dc9160b7f3e3405 being the fix for it.

I would therefore recommend that -- if this analysis is correct --
37b12910dd11d9ab969f2c310dc9160b7f3e3405 be backported to the 4.2
stable releases (thus, CCing Greg).

If my very brief and preliminary investigation is not correct, please
let me know if there is any additional information or debugging steps
I can apply, so that we can fix this regression.

In the meantime while I wait to hear back, I'll try backporting that
commit to 4.2 myself, and seeing the stability of my laptop over the
next 24 hours.

Thanks,
Jason

=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~

[14469.274866] ------------[ cut here ]------------
[14469.274874] WARNING: CPU: 1 PID: 12032 at kernel/watchdog.c:311
watchdog_overflow_callback+0x74/0xa0()
[14469.274875] Watchdog detected hard LOCKUP on cpu 1
[14469.274877] Modules linked in:
[14469.274878]  bnep hid_generic usbhid cdc_acm af_packet pl2303
usbserial btusb btbcm btintel bluetooth uvcvideo videobuf2_vmalloc
videobuf2_memops videobuf2_core v4l2_common videodev ip6table_filter
iptable_filter ip6_tables ip_tables x_tables mmc_block
snd_hda_codec_realtek snd_hda_codec_generic iwldvm coretemp
x86_pkg_temp_thermal intel_powerclamp mac80211 kvm_intel snd_hda_intel
sdhci_pci snd_hda_codec kvm iwlwifi snd_hwdep snd_hda_core joydev
xhci_pci ehci_pci sdhci xhci_hcd ehci_hcd snd_pcm mousedev microcode
cfg80211 mmc_core usbcore snd_timer usb_common thinkpad_acpi thermal
snd soundcore hwmon rfkill ac battery evdev processor ipv6
[14469.274912] CPU: 1 PID: 12032 Comm: kworker/1:0 Not tainted 4.2.3-gentoo #3
[14469.274913] Hardware name: LENOVO 2436CTO/2436CTO, BIOS G5ETA2WW
(2.62 ) 03/31/2015
[14469.274918] Workqueue: events e1000e_systim_overflow_work
[14469.274920]  0000000000000000 ffffffff81a0eb69 ffffffff81683f33
ffff88081e245ba0
[14469.274922]  ffffffff810ce4b8 ffff8807fa6f0000 0000000000000000
ffff88081e245c80
[14469.274924]  ffff88081e245ef8 0000000000000000 ffffffff810ce535
ffffffff81a0a3f8
[14469.274926] Call Trace:
[14469.274928]  <NMI>  [<ffffffff81683f33>] ? dump_stack+0x40/0x50
[14469.274935]  [<ffffffff810ce4b8>] ? warn_slowpath_common+0x78/0xb0
[14469.274937]  [<ffffffff810ce535>] ? warn_slowpath_fmt+0x45/0x50
[14469.274939]  [<ffffffff811428a4>] ? watchdog_overflow_callback+0x74/0xa0
[14469.274941]  [<ffffffff8116ac36>] ? __perf_event_overflow+0x86/0x1c0
[14469.274944]  [<ffffffff8101cdd9>] ? intel_pmu_handle_irq+0x1c9/0x3f0
[14469.274948]  [<ffffffff81015145>] ? perf_event_nmi_handler+0x25/0x40
[14469.274951]  [<ffffffff8100695c>] ? nmi_handle+0x7c/0x100
[14469.274952]  [<ffffffff81006bbd>] ? do_nmi+0x1dd/0x360
[14469.274956]  [<ffffffff8168b097>] ? end_repeat_nmi+0x1a/0x1e
[14469.274958]  [<ffffffff81559bcd>] ? e1000e_cyclecounter_read+0xd/0xb0
[14469.274960]  [<ffffffff81559bcd>] ? e1000e_cyclecounter_read+0xd/0xb0
[14469.274962]  [<ffffffff81559bcd>] ? e1000e_cyclecounter_read+0xd/0xb0
[14469.274963]  <<EOE>>  [<ffffffff8112485c>] ? timecounter_read+0xc/0x50
[14469.274968]  [<ffffffff815652c8>] ? e1000e_phc_gettime+0x28/0x60
[14469.274971]  [<ffffffff81565438>] ? e1000e_systim_overflow_work+0x18/0x40
[14469.274974]  [<ffffffff810e3040>] ? process_one_work+0x140/0x3f0
[14469.274976]  [<ffffffff810e3332>] ? worker_thread+0x42/0x490
[14469.274978]  [<ffffffff810e32f0>] ? process_one_work+0x3f0/0x3f0
[14469.274980]  [<ffffffff810e873c>] ? kthread+0xbc/0xe0
[14469.274983]  [<ffffffff810e8680>] ? kthread_worker_fn+0x160/0x160
[14469.274985]  [<ffffffff8168969f>] ? ret_from_fork+0x3f/0x70
[14469.274987]  [<ffffffff810e8680>] ? kthread_worker_fn+0x160/0x160
[14469.274988] ---[ end trace 99827f3383cad419 ]---
[14491.475971] NMI watchdog: BUG: soft lockup - CPU#0 stuck for 23s!
[chrome:13388]
[14491.475973] Modules linked in: bnep hid_generic usbhid cdc_acm
af_packet pl2303 usbserial btusb btbcm btintel bluetooth uvcvideo
videobuf2_vmalloc videobuf2_memops videobuf2_core v4l2_common videodev
ip6table_filter iptable_filter ip6_tables ip_tables x_tables mmc_block
snd_hda_codec_realtek snd_hda_codec_generic iwldvm coretemp
x86_pkg_temp_thermal intel_powerclamp mac80211 kvm_intel snd_hda_intel
sdhci_pci snd_hda_codec kvm iwlwifi snd_hwdep snd_hda_core joydev
xhci_pci ehci_pci sdhci xhci_hcd ehci_hcd snd_pcm mousedev microcode
cfg80211 mmc_core usbcore snd_timer usb_common thinkpad_acpi thermal
snd soundcore hwmon rfkill ac battery evdev processor ipv6
[14491.476006] CPU: 0 PID: 13388 Comm: chrome Tainted: G        W
 4.2.3-gentoo #3
[14491.476007] Hardware name: LENOVO 2436CTO/2436CTO, BIOS G5ETA2WW
(2.62 ) 03/31/2015
[14491.476008] task: ffff8807a2550000 ti: ffff8806e163c000 task.ti:
ffff8806e163c000
[14491.476010] RIP: 0010:[<ffffffff8112d913>]  [<ffffffff8112d913>]
smp_call_function_many+0x1e3/0x240
[14491.476015] RSP: 0018:ffff8806e163fb88  EFLAGS: 00000202
[14491.476016] RAX: 0000000000000003 RBX: 0000000000000000 RCX: 0000000000000001
[14491.476018] RDX: ffff88081e258210 RSI: 0000000000000008 RDI: ffff88081e215908
[14491.476019] RBP: ffff88081e215900 R08: 0000000000000000 R09: 00000000000000fe
[14491.476020] R10: 0000000000000002 R11: 0000000000000fb0 R12: 0000000000000100
[14491.476021] R13: 0000000000000000 R14: ffff88081e5db808 R15: 0000000000000040
[14491.476022] FS:  00007f5b393ce900(0000) GS:ffff88081e200000(0000)
knlGS:0000000000000000
[14491.476023] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[14491.476024] CR2: 00000a1e2b91b008 CR3: 0000000742caf000 CR4: 00000000001406f0
[14491.476025] Stack:
[14491.476026]  00000000000158c0 0000000100000100 ffff88081e3d04a0
ffffffff81040d60
[14491.476028]  0000000000000000 ffff8806e163fc58 ffff88081e3d0478
ffff8806e163fcc8
[14491.476030]  ffff8806e163fc18 ffffffff8112d9c3 ffff8806e163fcc0
ffff88081e3d04a0
[14491.476032] Call Trace:
[14491.476036]  [<ffffffff81040d60>] ? flush_tlb_func+0x140/0x140
[14491.476038]  [<ffffffff8112d9c3>] ? on_each_cpu+0x23/0x40
[14491.476039]  [<ffffffff810410f3>] ? flush_tlb_kernel_range+0x33/0x60
[14491.476042]  [<ffffffff811a7c8d>] ? __purge_vmap_area_lazy+0xcd/0x350
[14491.476044]  [<ffffffff811a7eab>] ? __purge_vmap_area_lazy+0x2eb/0x350
[14491.476045]  [<ffffffff811a8029>] ? vm_unmap_aliases+0x119/0x130
[14491.476048]  [<ffffffffa0191000>] ? 0xffffffffa0191000
[14491.476051]  [<ffffffff8103d48e>] ? change_page_attr_set_clr+0xbe/0x420
[14491.476053]  [<ffffffff8103e288>] ? set_memory_ro+0x28/0x30
[14491.476056]  [<ffffffff810cb1b4>] ? bpf_int_jit_compile+0x174/0x220
[14491.476060]  [<ffffffff81160f61>] ? bpf_prog_select_runtime+0x11/0x90
[14491.476063]  [<ffffffff816037d4>] ? bpf_prepare_filter+0x344/0x360
[14491.476066]  [<ffffffff81142d90>] ? proc_watchdog_cpumask+0xb0/0xb0
[14491.476067]  [<ffffffff81142d90>] ? proc_watchdog_cpumask+0xb0/0xb0
[14491.476069]  [<ffffffff81603b68>] ? bpf_prog_create_from_user+0x68/0xa0
[14491.476071]  [<ffffffff81142fa8>] ? do_seccomp+0xd8/0x5f0
[14491.476073]  [<ffffffff810df092>] ? SyS_prctl+0x22/0x3b0
[14491.476076]  [<ffffffff816892d7>] ? entry_SYSCALL_64_fastpath+0x12/0x6a
[14491.476077] Code: 95 22 00 3b 05 a3 a2 b9 00 89 c1 0f 8d 9e fe ff
ff 48 98 48 8b 55 00 48 03 14 c5 e0 63 cc 81 8b 42 18 a8 01 74 ca f3
90 8b 42 18 <a8> 01 75 f7 eb bf 48 8b 15 a8 fa 6d 00 4c 89 e6 89 ef e8
26 6b
[14495.480698] NMI watchdog: BUG: soft lockup - CPU#4 stuck for 22s!
[chrome:13391]
[14495.480701] Modules linked in: bnep hid_generic usbhid cdc_acm
af_packet pl2303 usbserial btusb btbcm btintel bluetooth uvcvideo
videobuf2_vmalloc videobuf2_memops videobuf2_core v4l2_common videodev
ip6table_filter iptable_filter ip6_tables ip_tables x_tables mmc_block
snd_hda_codec_realtek snd_hda_codec_generic iwldvm coretemp
x86_pkg_temp_thermal intel_powerclamp mac80211 kvm_intel snd_hda_intel
sdhci_pci snd_hda_codec kvm iwlwifi snd_hwdep snd_hda_core joydev
xhci_pci ehci_pci sdhci xhci_hcd ehci_hcd snd_pcm mousedev microcode
cfg80211 mmc_core usbcore snd_timer usb_common thinkpad_acpi thermal
snd soundcore hwmon rfkill ac battery evdev processor ipv6
[14495.480728] CPU: 4 PID: 13391 Comm: chrome Tainted: G        W    L
 4.2.3-gentoo #3
[14495.480729] Hardware name: LENOVO 2436CTO/2436CTO, BIOS G5ETA2WW
(2.62 ) 03/31/2015
[14495.480730] task: ffff8807a2553100 ti: ffff88079503c000 task.ti:
ffff88079503c000
[14495.480731] RIP: 0010:[<ffffffff81106008>]  [<ffffffff81106008>]
queued_spin_lock_slowpath+0x158/0x170
[14495.480736] RSP: 0018:ffff88079503fc20  EFLAGS: 00000202
[14495.480737] RAX: 0000000000100101 RBX: ffff88081e5db800 RCX: 0000000000000001
[14495.480737] RDX: 0000000000000101 RSI: 0000000000000001 RDI: ffffffff81e684b8
[14495.480738] RBP: ffff88081e3d04a8 R08: 0000000000000101 R09: 00000000000000ff
[14495.480739] R10: 0000000000000002 R11: 0000000000000fb0 R12: 0000000000000100
[14495.480740] R13: 0000000000000000 R14: ffffffff81179d04 R15: ffff8807a2553100
[14495.480741] FS:  00007f5b393ce900(0000) GS:ffff88081e300000(0000)
knlGS:0000000000000000
[14495.480741] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[14495.480742] CR2: 00000a1e2b91b008 CR3: 00000007424af000 CR4: 00000000001406e0
[14495.480743] Stack:
[14495.480743]  ffffffff811a7cd2 0000000000001000 ffff88079503fcc0
ffffffffa0000000
[14495.480745]  00000000811a836c 00000000a2553100 ffff88081e5db800
ffff88079503fc58
[14495.480746]  ffff88079503fc58 0000000000000002 0000000000000002
ffff8807a2553100
[14495.480747] Call Trace:
[14495.480750]  [<ffffffff811a7cd2>] ? __purge_vmap_area_lazy+0x112/0x350
[14495.480753]  [<ffffffffa0000000>] ? 0xffffffffa0000000
[14495.480754]  [<ffffffff811a8029>] ? vm_unmap_aliases+0x119/0x130
[14495.480759]  [<ffffffff8103d48e>] ? change_page_attr_set_clr+0xbe/0x420
[14495.480761]  [<ffffffff8103e288>] ? set_memory_ro+0x28/0x30
[14495.480763]  [<ffffffff810cb1b4>] ? bpf_int_jit_compile+0x174/0x220
[14495.480765]  [<ffffffff81160f61>] ? bpf_prog_select_runtime+0x11/0x90
[14495.480768]  [<ffffffff816037d4>] ? bpf_prepare_filter+0x344/0x360
[14495.480770]  [<ffffffff81142d90>] ? proc_watchdog_cpumask+0xb0/0xb0
[14495.480772]  [<ffffffff81142d90>] ? proc_watchdog_cpumask+0xb0/0xb0
[14495.480773]  [<ffffffff81603b68>] ? bpf_prog_create_from_user+0x68/0xa0
[14495.480774]  [<ffffffff81142fa8>] ? do_seccomp+0xd8/0x5f0
[14495.480776]  [<ffffffff810df092>] ? SyS_prctl+0x22/0x3b0
[14495.480779]  [<ffffffff816892d7>] ? entry_SYSCALL_64_fastpath+0x12/0x6a
[14495.480779] Code: 8b 01 48 85 c0 75 0a f3 90 48 8b 01 48 85 c0 74
f6 c7 40 08 01 00 00 00 e9 66 ff ff ff 83 fa 01 75 07 e9 cc fe ff ff
f3 90 8b 07 <84> c0 75 f8 b8 01 00 00 00 66 89 07 c3 66 2e 0f 1f 84 00
00 00
[14503.476155] NMI watchdog: BUG: soft lockup - CPU#3 stuck for 22s!
[chrome:13398]
[14503.476158] Modules linked in: bnep hid_generic usbhid cdc_acm
af_packet pl2303 usbserial btusb btbcm btintel bluetooth uvcvideo
videobuf2_vmalloc videobuf2_memops videobuf2_core v4l2_common videodev
ip6table_filter iptable_filter ip6_tables ip_tables x_tables mmc_block
snd_hda_codec_realtek snd_hda_codec_generic iwldvm coretemp
x86_pkg_temp_thermal intel_powerclamp mac80211 kvm_intel snd_hda_intel
sdhci_pci snd_hda_codec kvm iwlwifi snd_hwdep snd_hda_core joydev
xhci_pci ehci_pci sdhci xhci_hcd ehci_hcd snd_pcm mousedev microcode
cfg80211 mmc_core usbcore snd_timer usb_common thinkpad_acpi thermal
snd soundcore hwmon rfkill ac battery evdev processor ipv6
[14503.476189] CPU: 3 PID: 13398 Comm: chrome Tainted: G        W    L
 4.2.3-gentoo #3
[14503.476191] Hardware name: LENOVO 2436CTO/2436CTO, BIOS G5ETA2WW
(2.62 ) 03/31/2015
[14503.476192] task: ffff8800d60b4980 ti: ffff8806e1634000 task.ti:
ffff8806e1634000
[14503.476193] RIP: 0010:[<ffffffff81105fc1>]  [<ffffffff81105fc1>]
queued_spin_lock_slowpath+0x111/0x170
[14503.476198] RSP: 0018:ffff8806e1637c20  EFLAGS: 00000202
[14503.476199] RAX: 0000000000000000 RBX: ffff88081e5db800 RCX: ffff88081e2d5500
[14503.476200] RDX: 0000000000100101 RSI: 0000000000100000 RDI: ffffffff81e684b8
[14503.476200] RBP: ffff88081e3d04a8 R08: 0000000000000101 R09: 00000000000000ff
[14503.476202] R10: 0000000000000002 R11: 0000000000000fb0 R12: 0000000000000100
[14503.476202] R13: 0000000000000000 R14: ffffffff81179d04 R15: ffff8800d60b4980
[14503.476203] FS:  00007f5b393ce900(0000) GS:ffff88081e2c0000(0000)
knlGS:0000000000000000
[14503.476204] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[14503.476205] CR2: 00000a1e2b91b008 CR3: 00000007f47a1000 CR4: 00000000001406e0
[14503.476206] Stack:
[14503.476207]  ffffffff811a7cd2 0000000000001000 ffff8806e1637cc0
ffffffffa0000000
[14503.476208]  00000000811a836c 00000000d60b4980 ffff88081e5db800
ffff8806e1637c58
[14503.476210]  ffff8806e1637c58 0000000000000002 0000000000000002
ffff8800d60b4980
[14503.476212] Call Trace:
[14503.476215]  [<ffffffff811a7cd2>] ? __purge_vmap_area_lazy+0x112/0x350
[14503.476217]  [<ffffffffa0000000>] ? 0xffffffffa0000000
[14503.476219]  [<ffffffff811a8029>] ? vm_unmap_aliases+0x119/0x130
[14503.476223]  [<ffffffff8103d48e>] ? change_page_attr_set_clr+0xbe/0x420
[14503.476225]  [<ffffffff8103e288>] ? set_memory_ro+0x28/0x30
[14503.476227]  [<ffffffff810cb1b4>] ? bpf_int_jit_compile+0x174/0x220
[14503.476230]  [<ffffffff81160f61>] ? bpf_prog_select_runtime+0x11/0x90
[14503.476233]  [<ffffffff816037d4>] ? bpf_prepare_filter+0x344/0x360
[14503.476236]  [<ffffffff81142d90>] ? proc_watchdog_cpumask+0xb0/0xb0
[14503.476238]  [<ffffffff81142d90>] ? proc_watchdog_cpumask+0xb0/0xb0
[14503.476239]  [<ffffffff81603b68>] ? bpf_prog_create_from_user+0x68/0xa0
[14503.476241]  [<ffffffff81142fa8>] ? do_seccomp+0xd8/0x5f0
[14503.476242]  [<ffffffff810df092>] ? SyS_prctl+0x22/0x3b0
[14503.476245]  [<ffffffff816892d7>] ? entry_SYSCALL_64_fastpath+0x12/0x6a
[14503.476246] Code: 30 48 98 48 81 c2 00 55 01 00 48 03 14 c5 e0 63
cc 81 48 89 0a 8b 41 08 85 c0 75 0d f3 90 8b 41 08 85 c0 74 f7 eb 02
f3 90 8b 17 <66> 85 d2 75 f7 39 f2 75 0f 89 d0 be 01 00 00 00 f0 0f b1
37 39
