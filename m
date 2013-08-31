From: =?UTF-8?B?RnLDqWTDqXJpYyBMZXJveQ==?= <fredo@starox.org>
Subject: Realtek r8168 hangs when sending data at full speed on a gigabit
 link
Date: Sat, 31 Aug 2013 12:15:02 +0200
Message-ID: <5221C226.9040209@starox.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-34071.dedibox.fr ([88.191.154.35]:44441 "EHLO
	sd-34071.dedibox.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753166Ab3HaKZa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Aug 2013 06:25:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

My network card hangs when I send data at full speed on a gigabit link.
This is a realtek :

        [fredo:~/work/r8169] $ lspci | grep Realtek
        02:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
RTL8111/8168 PCI Express Gigabit Ethernet controller (rev 09)

        [fredo:~/work/r8169] $ dmesg  | grep r8169
        [    1.732159] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
        [    1.732376] r8169 0000:02:00.0: irq 89 for MSI/MSI-X
        [    1.732635] r8169 0000:02:00.0 eth0: RTL8168f/8111f at
0xffffc9000066a000, 60:a4:4c:5a:db:cf, XID 08000800 IRQ 89
        [    1.732639] r8169 0000:02:00.0 eth0: jumbo features [frames:
9200 bytes, tx checksumming: ko]
        [    8.400499] r8169 0000:02:00.0 eth0: link down
        [    8.400520] r8169 0000:02:00.0 eth0: link down
        [   11.218946] r8169 0000:02:00.0 eth0: link up

I tried several kernel, up to 3.11.0-rc7+ and found that 3.1.0 works,
but bisecting the kernel gives me random result, depending on my "bad"
start point :

        262eb9b2237ecee047451a636e799ea1572b685a        cfg80211: split
wext compatibility to separate header
        7af40ad909e3e92a1cbb728999c427d2fa3b381d        igb: push data
into first igb_tx_buffer sooner to reduce stack usage
        f53b170f465d52546c33faa962c3d2609a6bf5b3        brcm80211:
removed unused functions

The only clue I have is the IO_PAGE_FAULT in the kernel logs :

        Aug 26 09:46:17 devel kernel: [    0.000000] Linux version
3.8.0-29-generic (buildd@roseapple) (gcc version 4.7.3 (Ubuntu/Linaro
4.7.3-1ubuntu1) ) #42-Ubuntu SMP Tue Aug 13 19:40:39 UTC 2013 (Ubuntu
3.8.0-29.42-generic 3.8.13.5)
        Aug 26 09:49:13 devel kernel: [  184.973716] AMD-Vi: Event
logged [IO_PAGE_FAULT device=02:00.0 domain=0x0015
address=0x0000000000003000 flags=0x0050]
        Aug 26 09:49:43 devel kernel: [  214.970724] ------------[ cut
here ]------------
        Aug 26 09:49:43 devel kernel: [  214.970731] WARNING: at
/build/buildd/linux-3.8.0/net/sched/sch_generic.c:254
dev_watchdog+0x242/0x250()
        Aug 26 09:49:43 devel kernel: [  214.970732] Hardware name: To
be filled by O.E.M.
        Aug 26 09:49:43 devel kernel: [  214.970733] NETDEV WATCHDOG:
eth0 (r8169): transmit queue 0 timed out
        Aug 26 09:49:43 devel kernel: [  214.970734] Modules linked in:
nls_iso8859_1(F) usb_storage(F) arc4(F) md4(F) nls_utf8 cifs(F)
fscache(F) pci_stub vboxpci(OF) vboxnetadp(OF) vboxnetflt(OF)
vboxdrv(OF) rfcomm parport_pc(F) ppdev(F) bnep bluetooth binfmt_misc(F)
e4000 snd_hda_codec_hdmi rtl2832 ext2(F) dvb_usb_rtl28xxu rtl2830
dvb_usb_v2 dvb_core rc_core usblp kvm_amd eeepc_wmi joydev(F) asus_wmi
kvm sparse_keymap video(F) mxm_wmi ghash_clmulni_intel(F) aesni_intel(F)
aes_x86_64(F) xts(F) lrw(F) gf128mul(F) snd_hda_codec_realtek
ablk_helper(F) cryptd(F) microcode(F) snd_hda_intel snd_seq_midi(F)
radeon snd_hda_codec snd_seq_midi_event(F) snd_hwdep(F) snd_pcm(F)
snd_rawmidi(F) fam15h_power serio_raw(F) sp5100_tco snd_page_alloc(F)
snd_seq(F) snd_seq_device(F) k10temp ttm i2c_piix4 edac_core
snd_timer(F) edac_mce_amd drm_kms_helper drm snd(F) i2c_algo_bit wmi
soundcore(F) mac_hid lp(F) parport(F) hid_logitech_dj hid_generic usbhid
hid skge r8169 ahci(F) libahci(F)
        Aug 26 09:49:43 devel kernel: [  214.970774] Pid: 0, comm:
swapper/4 Tainted: GF          O 3.8.0-29-generic #42-Ubuntu
        Aug 26 09:49:43 devel kernel: [  214.970776] Call Trace:
        Aug 26 09:49:43 devel kernel: [  214.970777]  <IRQ> 
[<ffffffff810589bf>] warn_slowpath_common+0x7f/0xc0
        Aug 26 09:49:43 devel kernel: [  214.970782] 
[<ffffffff81058abc>] warn_slowpath_fmt+0x4c/0x50
        Aug 26 09:49:43 devel kernel: [  214.970785] 
[<ffffffff81074e84>] ? insert_work+0x94/0xb0
        Aug 26 09:49:43 devel kernel: [  214.970789] 
[<ffffffff815e8922>] dev_watchdog+0x242/0x250
        Aug 26 09:49:43 devel kernel: [  214.970791] 
[<ffffffff815e86e0>] ? dev_graft_qdisc+0x90/0x90
        Aug 26 09:49:43 devel kernel: [  214.970793] 
[<ffffffff810682a6>] call_timer_fn+0x36/0x110
        Aug 26 09:49:43 devel kernel: [  214.970795] 
[<ffffffff815e86e0>] ? dev_graft_qdisc+0x90/0x90
        Aug 26 09:49:43 devel kernel: [  214.970797] 
[<ffffffff81069ed6>] run_timer_softirq+0x1f6/0x2a0
        Aug 26 09:49:43 devel kernel: [  214.970800] 
[<ffffffff8106110f>] __do_softirq+0xcf/0x200
        Aug 26 09:49:43 devel kernel: [  214.970803] 
[<ffffffff81574150>] ? centrino_target+0x370/0x370
        Aug 26 09:49:43 devel kernel: [  214.970805] 
[<ffffffff816d6a9c>] call_softirq+0x1c/0x30
        Aug 26 09:49:43 devel kernel: [  214.970808] 
[<ffffffff81016555>] do_softirq+0x75/0xb0
        Aug 26 09:49:43 devel kernel: [  214.970810] 
[<ffffffff810613a5>] irq_exit+0xa5/0xb0
        Aug 26 09:49:43 devel kernel: [  214.970812] 
[<ffffffff816d741e>] smp_apic_timer_interrupt+0x6e/0x99
        Aug 26 09:49:43 devel kernel: [  214.970814] 
[<ffffffff816d635d>] apic_timer_interrupt+0x6d/0x80
        Aug 26 09:49:43 devel kernel: [  214.970815]  <EOI> 
[<ffffffff81091a4d>] ? sched_clock_cpu+0xbd/0x110
        Aug 26 09:49:43 devel kernel: [  214.970819] 
[<ffffffff81574b98>] ? cpuidle_wrap_enter+0x58/0xa0
        Aug 26 09:49:43 devel kernel: [  214.970821] 
[<ffffffff81574bf0>] cpuidle_enter_tk+0x10/0x20
        Aug 26 09:49:43 devel kernel: [  214.970823] 
[<ffffffff815747e5>] cpuidle_idle_call+0xa5/0x260
        Aug 26 09:49:43 devel kernel: [  214.970826] 
[<ffffffff8101d5af>] cpu_idle+0xaf/0x120
        Aug 26 09:49:43 devel kernel: [  214.970828] 
[<ffffffff816b6a83>] start_secondary+0x1e0/0x1e5
        Aug 26 09:49:43 devel kernel: [  214.970830] ---[ end trace
9135f3ab0912c9e0 ]---
        Aug 26 09:49:43 devel kernel: [  214.977428] r8169 0000:02:00.0
eth0: link up

For triggering the bug, I use iperf, which either works, or hangs almost
immediately
with multiple threads :

        iperf -c myiperfserver -P 3 -t 60

Could you help me to fix this ?

Best regards,

-- 
Frederic Leroy
