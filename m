From: Alex Bennee <kernel-hacker@bennee.com>
Subject: r8169 ethernet hangs after a pm-suspend (and resume)
Date: Wed, 9 Sep 2009 08:13:07 +0100
Message-ID: <b2cdc9f30909090013q1741da26la73da66f1eef975f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: lkml <linux-kernel@vger.kernel.org>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:21760 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751544AbZIIHNG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2009 03:13:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've just recently gotten suspend working on my system. Unfortunately
after the resume event I loose access to the network.
As far as the system is concerned the network is configured properly
but every attempt to ping local nodes fails with "Host not reachable".

If also seen an oops or two but I don't know id that is related:

[  289.816066] ------------[ cut here ]------------
[  289.816077] WARNING: at net/sched/sch_generic.c:246
dev_watchdog+0x132/0x1da()
[  289.816080] Hardware name: System Product Name
[  289.816083] NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed
out
[  289.816085] Modules linked in: nls_iso8859_1 nls_cp437 vfat fat
joydev usb_storage usbhid usb_libusual bridge stp llc bnep rfcomm
l2cap bluetooth ipv6 snd_pcm_oss snd_mixer_oss snd_seq_oss
snd_seq_midi_event snd_seq snd_seq_device kvm_intel kvm acpi_cpufreq
snd_hda_codec_analog uhci_hcd usbcore snd_hda_intel snd_hda_codec
firewire_ohci snd_hwdep snd_pcm snd_timer snd firewire_core crc_itu_t
soundcore snd_page_alloc ide_cd_mod pcspkr evdev cdrom thermal
processor nls_base unix [last unloaded: ehci_hcd]
[  289.816135] Pid: 0, comm: swapper Not tainted
2.6.31-rc9-ajb-00012-g3ff323f-dirty #84
[  289.816138] Call Trace:
[  289.816140]  <IRQ>  [<ffffffff812aef27>] ? dev_watchdog+0x132/0x1da
[  289.816152]  [<ffffffff8103eb72>] warn_slowpath_common+0x7c/0xa9
[  289.816157]  [<ffffffff8103ec1e>] warn_slowpath_fmt+0x69/0x6b
[  289.816165]  [<ffffffffa0124cbb>] ? uhci_scan_schedule+0x194/0x86a
[uhci_hcd]
[  289.816169]  [<ffffffff81048fbc>] ? lock_timer_base+0x2b/0x4f
[  289.816174]  [<ffffffff81049699>] ? mod_timer+0x111/0x123
[  289.816180]  [<ffffffffa0125d9a>] ?
uhci_hub_status_data+0x16e/0x17d [uhci_hcd]
[  289.816185]  [<ffffffff8129d98d>] ? netdev_drivername+0x48/0x4f
[  289.816189]  [<ffffffff812aef27>] dev_watchdog+0x132/0x1da
[  289.816211]  [<ffffffffa00f0233>] ?
usb_hcd_poll_rh_status+0x144/0x153 [usbcore]
[  289.816215]  [<ffffffff812aedf5>] ? dev_watchdog+0x0/0x1da
[  289.816220]  [<ffffffff81048d76>] run_timer_softirq+0x198/0x20d
[  289.816226]  [<ffffffff8101d0c6>] ? lapic_next_event+0x1d/0x21
[  289.816231]  [<ffffffff8104464f>] __do_softirq+0xd6/0x19a
[  289.816235]  [<ffffffff8100c19c>] call_softirq+0x1c/0x28
[  289.816239]  [<ffffffff8100d51d>] do_softirq+0x39/0x77
[  289.816243]  [<ffffffff8104430c>] irq_exit+0x44/0x7e
[  289.816248]  [<ffffffff8130b164>]
smp_apic_timer_interrupt+0x8d/0x9b
[  289.816253]  [<ffffffff8100bb73>] apic_timer_interrupt+0x13/0x20
[  289.816256]  <EOI>  [<ffffffff810117ac>] ? mwait_idle+0xb9/0xf0
[  289.816264]  [<ffffffff81309645>] ?
atomic_notifier_call_chain+0x13/0x15
[  289.816268]  [<ffffffff8100a30a>] ? cpu_idle+0x57/0x98
[  289.816273]  [<ffffffff812f5422>] ? rest_init+0x66/0x68
[  289.816278]  [<ffffffff815319da>] ? start_kernel+0x343/0x34e
[  289.816283]  [<ffffffff8153103a>] ?
x86_64_start_reservations+0xaa/0xae
[  289.816287]  [<ffffffff8153111f>] ? x86_64_start_kernel+0xe1/0xe8
[  289.816290] ---[ end trace 01c3a2a7a5f34536 ]---
[  290.635368] r8169: eth0: link up
[  314.635844] r8169: eth0: link up

I'm currently running 2.6.31-rc9-ajb-00012-g3ff323f-dirty and am
willing to test any patches that might be going.

My card is:
02:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 02)
	Subsystem: ASUSTeK Computer Inc. Device 81aa
	Flags: bus master, fast devsel, latency 0, IRQ 25
	I/O ports at e800 [size=256]
	Memory at dffff000 (64-bit, non-prefetchable) [size=4K]
	Memory at deff0000 (64-bit, prefetchable) [size=64K]
	Expansion ROM at dffc0000 [disabled] [size=128K]
	Capabilities: [40] Power Management version 2
	Capabilities: [50] Message Signalled Interrupts: Mask- 64bit- Count=1/1 Enable+
	Capabilities: [70] Express Endpoint, MSI 08
	Capabilities: [b0] MSI-X: Enable- Mask- TabSize=2
	Capabilities: [d0] Vital Product Data <?>
	Kernel driver in use: r8169


-- 
Alex, homepage: http://www.bennee.com/~alex/
http://www.half-llama.co.uk
