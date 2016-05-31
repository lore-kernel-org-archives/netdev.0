From: Miroslav Kratochvil <exa.exa@gmail.com>
Subject: codel/fq_codel triggers heaps of WARNs in net/sched/sch_hfsc.c:1426
Date: Tue, 31 May 2016 09:03:11 +0200
Message-ID: <CAO0uZ+-SvYncQ+OUbDn5B7-_W3j6Wge8=t0EKi6xCb1ruXUwiQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:36468 "EHLO
	mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751770AbcEaHDO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 03:03:14 -0400
Received: by mail-lf0-f65.google.com with SMTP id h68so8920675lfh.3
        for <netdev@vger.kernel.org>; Tue, 31 May 2016 00:03:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello everyone,

I've been trying to debug an issue that arises when I'm using codel
(of fq_codel) qdiscs attached to a HFSC leaf class. Basic problem is
that on random points in time, kernel log gets overfilled (tens of
MB's of the messages) with many WARNINGs at net/sched/sch_hfsc.c:1426;
full text of several is attached below. The warnings appear randomly
in time, but always in (large) groups.

I was thinking that it is an issue relevant to a similar thing with
SFQ, where it's been fixed by some trimming of stats produced by SFQ.
Documented here:
https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=631945

Similar patch for codel and fq_codel was recommended me for trying out, here:
https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/commit/net/sched/sch_fq_codel.c?h=linux-4.5.y&id=01465faa0e2d311512690724196042f9bb466034
but the issue didn't get solved by it.

Also also, there's my original debian bugreport:
https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=824790

Is there any good approach I can debug this? I currently have a test
system where I can trigger the message easily with any custom kernel;
I'd appreciate any advice on what to try out next.

The messages from test kernel are from 4.5.5 on debian with ~20k hfsc
classes; I'll try to test out 4.6 ASAP but there seems to be no
relevant change in this direction. tg3 driver is not to blame (same
happens with e1000, e1000e, igb and ixgbe). I'm not sure whether u32
filter hashbuckets could trigger this behavior, but hope not
(currently I have no method to try this without u32).

Thanks in advance for any thoughts on this.

-mk


Attached full warnings:

[ 1320.176095] ------------[ cut here ]------------
[ 1320.176104] WARNING: CPU: 2 PID: 0 at net/sched/sch_hfsc.c:1426
hfsc_dequeue+0x300/0x320 [sch_hfsc]()
[ 1320.176105] Modules linked in: sch_codel(E) binfmt_misc(E)
act_mirred(E) act_gact(E) sch_ingress(E) sch_sfq(E) cls_u32(E)
sch_hfsc(E) ext4(E) crc16(E) mbcache(E) jbd2(E)
x86_pkg_temp_thermal(E) intel_powerclamp(E) coretemp(E) kvm_intel(E)
kvm(E) irqbypass(E) snd_pcm(E) snd_timer(E) snd(E) soundcore(E)
acpi_power_meter(E) mgag200(E) ttm(E) drm_kms_helper(E) joydev(E)
crct10dif_pclmul(E) crc32_pclmul(E) ghash_clmulni_intel(E) drm(E)
i2c_algo_bit(E) hmac(E) drbg(E) ansi_cprng(E) 8250_fintek(E)
aesni_intel(E) ipmi_devintf(E) aes_x86_64(E) lrw(E) gf128mul(E)
evdev(E) sg(E) iTCO_wdt(E) iTCO_vendor_support(E) pcspkr(E) wmi(E)
shpchp(E) glue_helper(E) acpi_pad(E) ipmi_si(E) ipmi_msghandler(E)
mei_me(E) sb_edac(E) ablk_helper(E) cryptd(E) lpc_ich(E) button(E)
edac_core(E) mei(E) mfd_core(E) tpm_tis(E) tpm(E)
[ 1320.176141]  processor(E) ifb(E) autofs4(E) xfs(E) libcrc32c(E)
hid_generic(E) usbhid(E) hid(E) sr_mod(E) sd_mod(E) cdrom(E)
crc32c_intel(E) ixgbe(E) dca(E) vxlan(E) ip6_udp_tunnel(E)
udp_tunnel(E) mdio(E) ehci_pci(E) ahci(E) ehci_hcd(E) libahci(E)
libata(E) tg3(E) ptp(E) pps_core(E) megaraid_sas(E) usbcore(E)
libphy(E) usb_common(E) scsi_mod(E) fjes(E)
[ 1320.176159] CPU: 2 PID: 0 Comm: swapper/2 Tainted: G            E   4.5.5 #1
[ 1320.176160] Hardware name:    /08DM12, BIOS 2.1.2 01/20/2014
[ 1320.176162]  0000000000000286 21264a740a0fcbac ffffffff81302ff5
0000000000000000
[ 1320.176164]  ffffffffc04db049 ffffffff81078ced ffff880610c85948
00000004cd5ee44c
[ 1320.176166]  ffff880610c85800 ffff880610c85c90 ffff880606a67600
ffffffffc04d9550
[ 1320.176168] Call Trace:
[ 1320.176169]  <IRQ>  [<ffffffff81302ff5>] ? dump_stack+0x5c/0x77
[ 1320.176179]  [<ffffffff81078ced>] ? warn_slowpath_common+0x7d/0xb0
[ 1320.176181]  [<ffffffffc04d9550>] ? hfsc_dequeue+0x300/0x320 [sch_hfsc]
[ 1320.176185]  [<ffffffff814db925>] ? __qdisc_run+0x65/0x190
[ 1320.176189]  [<ffffffff814b33f6>] ? net_tx_action+0xd6/0x230
[ 1320.176191]  [<ffffffff8107d4c8>] ? __do_softirq+0xf8/0x290
[ 1320.176193]  [<ffffffff8107d7ab>] ? irq_exit+0x9b/0xa0
[ 1320.176196]  [<ffffffff815b50df>] ? do_IRQ+0x4f/0xd0
[ 1320.176199]  [<ffffffff815b3202>] ? common_interrupt+0x82/0x82
[ 1320.176200]  <EOI>  [<ffffffff8147dbf8>] ? cpuidle_enter_state+0x118/0x2c0
[ 1320.176203]  [<ffffffff8147dbe5>] ? cpuidle_enter_state+0x105/0x2c0
[ 1320.176207]  [<ffffffff810b8837>] ? cpu_startup_entry+0x287/0x340
[ 1320.176210]  [<ffffffff8104d40a>] ? start_secondary+0x15a/0x190
[ 1320.176211] ---[ end trace b5b10ee435b3246b ]---
[ 1320.176254] ------------[ cut here ]------------
[ 1320.176256] WARNING: CPU: 2 PID: 0 at net/sched/sch_hfsc.c:1426
hfsc_dequeue+0x300/0x320 [sch_hfsc]()
[ 1320.176257] Modules linked in: sch_codel(E) binfmt_misc(E)
act_mirred(E) act_gact(E) sch_ingress(E) sch_sfq(E) cls_u32(E)
sch_hfsc(E) ext4(E) crc16(E) mbcache(E) jbd2(E)
x86_pkg_temp_thermal(E) intel_powerclamp(E) coretemp(E) kvm_intel(E)
kvm(E) irqbypass(E) snd_pcm(E) snd_timer(E) snd(E) soundcore(E)
acpi_power_meter(E) mgag200(E) ttm(E) drm_kms_helper(E) joydev(E)
crct10dif_pclmul(E) crc32_pclmul(E) ghash_clmulni_intel(E) drm(E)
i2c_algo_bit(E) hmac(E) drbg(E) ansi_cprng(E) 8250_fintek(E)
aesni_intel(E) ipmi_devintf(E) aes_x86_64(E) lrw(E) gf128mul(E)
evdev(E) sg(E) iTCO_wdt(E) iTCO_vendor_support(E) pcspkr(E) wmi(E)
shpchp(E) glue_helper(E) acpi_pad(E) ipmi_si(E) ipmi_msghandler(E)
mei_me(E) sb_edac(E) ablk_helper(E) cryptd(E) lpc_ich(E) button(E)
edac_core(E) mei(E) mfd_core(E) tpm_tis(E) tpm(E)
[ 1320.176276]  processor(E) ifb(E) autofs4(E) xfs(E) libcrc32c(E)
hid_generic(E) usbhid(E) hid(E) sr_mod(E) sd_mod(E) cdrom(E)
crc32c_intel(E) ixgbe(E) dca(E) vxlan(E) ip6_udp_tunnel(E)
udp_tunnel(E) mdio(E) ehci_pci(E) ahci(E) ehci_hcd(E) libahci(E)
libata(E) tg3(E) ptp(E) pps_core(E) megaraid_sas(E) usbcore(E)
libphy(E) usb_common(E) scsi_mod(E) fjes(E)
[ 1320.176287] CPU: 2 PID: 0 Comm: swapper/2 Tainted: G        W   E   4.5.5 #1
[ 1320.176288] Hardware name:    /08DM12, BIOS 2.1.2 01/20/2014
[ 1320.176289]  0000000000000286 21264a740a0fcbac ffffffff81302ff5
0000000000000000
[ 1320.176291]  ffffffffc04db049 ffffffff81078ced ffff880610c85948
00000004cd5eee0c
[ 1320.176292]  ffff880610c85800 ffff880610c85c90 000000000000004c
ffffffffc04d9550
[ 1320.176295] Call Trace:
[ 1320.176295]  <IRQ>  [<ffffffff81302ff5>] ? dump_stack+0x5c/0x77
[ 1320.176299]  [<ffffffff81078ced>] ? warn_slowpath_common+0x7d/0xb0
[ 1320.176301]  [<ffffffffc04d9550>] ? hfsc_dequeue+0x300/0x320 [sch_hfsc]
[ 1320.176303]  [<ffffffff814db925>] ? __qdisc_run+0x65/0x190
[ 1320.176305]  [<ffffffff814b33f6>] ? net_tx_action+0xd6/0x230
[ 1320.176308]  [<ffffffff8107d4c8>] ? __do_softirq+0xf8/0x290
[ 1320.176310]  [<ffffffff8107d7ab>] ? irq_exit+0x9b/0xa0
[ 1320.176311]  [<ffffffff815b50df>] ? do_IRQ+0x4f/0xd0
[ 1320.176313]  [<ffffffff815b3202>] ? common_interrupt+0x82/0x82
[ 1320.176314]  <EOI>  [<ffffffff8147dbf8>] ? cpuidle_enter_state+0x118/0x2c0
[ 1320.176316]  [<ffffffff8147dbe5>] ? cpuidle_enter_state+0x105/0x2c0
[ 1320.176318]  [<ffffffff810b8837>] ? cpu_startup_entry+0x287/0x340
[ 1320.176320]  [<ffffffff8104d40a>] ? start_secondary+0x15a/0x190
[ 1320.176322] ---[ end trace b5b10ee435b3246c ]---
[ 1320.176332] ------------[ cut here ]------------
[ 1320.176334] WARNING: CPU: 2 PID: 0 at net/sched/sch_hfsc.c:1426
hfsc_dequeue+0x300/0x320 [sch_hfsc]()
[ 1320.176335] Modules linked in: sch_codel(E) binfmt_misc(E)
act_mirred(E) act_gact(E) sch_ingress(E) sch_sfq(E) cls_u32(E)
sch_hfsc(E) ext4(E) crc16(E) mbcache(E) jbd2(E)
x86_pkg_temp_thermal(E) intel_powerclamp(E) coretemp(E) kvm_intel(E)
kvm(E) irqbypass(E) snd_pcm(E) snd_timer(E) snd(E) soundcore(E)
acpi_power_meter(E) mgag200(E) ttm(E) drm_kms_helper(E) joydev(E)
crct10dif_pclmul(E) crc32_pclmul(E) ghash_clmulni_intel(E) drm(E)
i2c_algo_bit(E) hmac(E) drbg(E) ansi_cprng(E) 8250_fintek(E)
aesni_intel(E) ipmi_devintf(E) aes_x86_64(E) lrw(E) gf128mul(E)
evdev(E) sg(E) iTCO_wdt(E) iTCO_vendor_support(E) pcspkr(E) wmi(E)
shpchp(E) glue_helper(E) acpi_pad(E) ipmi_si(E) ipmi_msghandler(E)
mei_me(E) sb_edac(E) ablk_helper(E) cryptd(E) lpc_ich(E) button(E)
edac_core(E) mei(E) mfd_core(E) tpm_tis(E) tpm(E)
[ 1320.176354]  processor(E) ifb(E) autofs4(E) xfs(E) libcrc32c(E)
hid_generic(E) usbhid(E) hid(E) sr_mod(E) sd_mod(E) cdrom(E)
crc32c_intel(E) ixgbe(E) dca(E) vxlan(E) ip6_udp_tunnel(E)
udp_tunnel(E) mdio(E) ehci_pci(E) ahci(E) ehci_hcd(E) libahci(E)
libata(E) tg3(E) ptp(E) pps_core(E) megaraid_sas(E) usbcore(E)
libphy(E) usb_common(E) scsi_mod(E) fjes(E)
[ 1320.176365] CPU: 2 PID: 0 Comm: swapper/2 Tainted: G        W   E   4.5.5 #1
[ 1320.176366] Hardware name:    /08DM12, BIOS 2.1.2 01/20/2014
[ 1320.176366]  0000000000000286 21264a740a0fcbac ffffffff81302ff5
0000000000000000
[ 1320.176368]  ffffffffc04db049 ffffffff81078ced ffff880610c85948
00000004cd5ef2d6
[ 1320.176370]  ffff880610c85800 ffff880610c85c90 ffff880610e81e00
ffffffffc04d9550
[ 1320.176371] Call Trace:
[ 1320.176372]  <IRQ>  [<ffffffff81302ff5>] ? dump_stack+0x5c/0x77
[ 1320.176375]  [<ffffffff81078ced>] ? warn_slowpath_common+0x7d/0xb0
[ 1320.176377]  [<ffffffffc04d9550>] ? hfsc_dequeue+0x300/0x320 [sch_hfsc]
[ 1320.176379]  [<ffffffff814db925>] ? __qdisc_run+0x65/0x190
[ 1320.176381]  [<ffffffff814b7301>] ? __dev_queue_xmit+0x221/0x660
[ 1320.176384]  [<ffffffffc0554626>] ? tcf_mirred+0xf6/0x178 [act_mirred]
[ 1320.176387]  [<ffffffff814e11a1>] ? tcf_action_exec+0x41/0x70
[ 1320.176390]  [<ffffffffc0532a02>] ? u32_classify+0x232/0x460 [cls_u32]
[ 1320.176392]  [<ffffffff810e0a21>] ? hrtimer_interrupt+0xc1/0x190
[ 1320.176394]  [<ffffffff8107d74c>] ? irq_exit+0x3c/0xa0
[ 1320.176396]  [<ffffffff815b519e>] ? smp_apic_timer_interrupt+0x3e/0x50
[ 1320.176398]  [<ffffffff815b34a2>] ? apic_timer_interrupt+0x82/0x90
[ 1320.176400]  [<ffffffff814dcdea>] ? tc_classify+0x6a/0x120
[ 1320.176403]  [<ffffffff814b4725>] ? __netif_receive_skb_core+0x495/0xa20
[ 1320.176405]  [<ffffffff810bc7e2>] ? up+0x12/0x60
[ 1320.176408]  [<ffffffff810c9624>] ? console_unlock+0x214/0x540
[ 1320.176410]  [<ffffffff814b4d2f>] ? netif_receive_skb_internal+0x2f/0xa0
[ 1320.176411]  [<ffffffff814b5c5b>] ? napi_gro_receive+0xbb/0x110
[ 1320.176416]  [<ffffffffc0177700>] ? tg3_poll_work+0xd90/0xef0 [tg3]
[ 1320.176420]  [<ffffffffc017789a>] ? tg3_poll_msix+0x3a/0x150 [tg3]
[ 1320.176421]  [<ffffffff814b54de>] ? net_rx_action+0x22e/0x360
[ 1320.176423]  [<ffffffff8107d4c8>] ? __do_softirq+0xf8/0x290
[ 1320.176425]  [<ffffffff8107d7ab>] ? irq_exit+0x9b/0xa0
[ 1320.176427]  [<ffffffff815b50df>] ? do_IRQ+0x4f/0xd0
[ 1320.176429]  [<ffffffff815b3202>] ? common_interrupt+0x82/0x82
[ 1320.176429]  <EOI>  [<ffffffff8147dbf8>] ? cpuidle_enter_state+0x118/0x2c0
[ 1320.176432]  [<ffffffff8147dbe5>] ? cpuidle_enter_state+0x105/0x2c0
[ 1320.176434]  [<ffffffff810b8837>] ? cpu_startup_entry+0x287/0x340
[ 1320.176436]  [<ffffffff8104d40a>] ? start_secondary+0x15a/0x190
[ 1320.176438] ---[ end trace b5b10ee435b3246d ]---
[ 1320.176443] ------------[ cut here ]------------
[ 1320.176446] WARNING: CPU: 2 PID: 0 at net/sched/sch_hfsc.c:1426
hfsc_dequeue+0x300/0x320 [sch_hfsc]()
[ 1320.176446] Modules linked in: sch_codel(E) binfmt_misc(E)
act_mirred(E) act_gact(E) sch_ingress(E) sch_sfq(E) cls_u32(E)
sch_hfsc(E) ext4(E) crc16(E) mbcache(E) jbd2(E)
x86_pkg_temp_thermal(E) intel_powerclamp(E) coretemp(E) kvm_intel(E)
kvm(E) irqbypass(E) snd_pcm(E) snd_timer(E) snd(E) soundcore(E)
acpi_power_meter(E) mgag200(E) ttm(E) drm_kms_helper(E) joydev(E)
crct10dif_pclmul(E) crc32_pclmul(E) ghash_clmulni_intel(E) drm(E)
i2c_algo_bit(E) hmac(E) drbg(E) ansi_cprng(E) 8250_fintek(E)
aesni_intel(E) ipmi_devintf(E) aes_x86_64(E) lrw(E) gf128mul(E)
evdev(E) sg(E) iTCO_wdt(E) iTCO_vendor_support(E) pcspkr(E) wmi(E)
shpchp(E) glue_helper(E) acpi_pad(E) ipmi_si(E) ipmi_msghandler(E)
mei_me(E) sb_edac(E) ablk_helper(E) cryptd(E) lpc_ich(E) button(E)
edac_core(E) mei(E) mfd_core(E) tpm_tis(E) tpm(E)
[ 1320.176465]  processor(E) ifb(E) autofs4(E) xfs(E) libcrc32c(E)
hid_generic(E) usbhid(E) hid(E) sr_mod(E) sd_mod(E) cdrom(E)
crc32c_intel(E) ixgbe(E) dca(E) vxlan(E) ip6_udp_tunnel(E)
udp_tunnel(E) mdio(E) ehci_pci(E) ahci(E) ehci_hcd(E) libahci(E)
libata(E) tg3(E) ptp(E) pps_core(E) megaraid_sas(E) usbcore(E)
libphy(E) usb_common(E) scsi_mod(E) fjes(E)
[ 1320.176476] CPU: 2 PID: 0 Comm: swapper/2 Tainted: G        W   E   4.5.5 #1
[ 1320.176477] Hardware name:    /08DM12, BIOS 2.1.2 01/20/2014
[ 1320.176478]  0000000000000286 21264a740a0fcbac ffffffff81302ff5
0000000000000000
[ 1320.176479]  ffffffffc04db049 ffffffff81078ced ffff880610c85948
00000004cd5ef9a4
[ 1320.176481]  ffff880610c85800 ffff880610c85c90 ffff8806092e6b00
ffffffffc04d9550
[ 1320.176483] Call Trace:
[ 1320.176484]  <IRQ>  [<ffffffff81302ff5>] ? dump_stack+0x5c/0x77
[ 1320.176487]  [<ffffffff81078ced>] ? warn_slowpath_common+0x7d/0xb0
[ 1320.176489]  [<ffffffffc04d9550>] ? hfsc_dequeue+0x300/0x320 [sch_hfsc]
[ 1320.176491]  [<ffffffff814db925>] ? __qdisc_run+0x65/0x190
[ 1320.176493]  [<ffffffff814b7301>] ? __dev_queue_xmit+0x221/0x660
[ 1320.176495]  [<ffffffffc0554626>] ? tcf_mirred+0xf6/0x178 [act_mirred]
[ 1320.176496]  [<ffffffff814e11a1>] ? tcf_action_exec+0x41/0x70
[ 1320.176498]  [<ffffffffc0532a02>] ? u32_classify+0x232/0x460 [cls_u32]
[ 1320.176500]  [<ffffffff810e0a21>] ? hrtimer_interrupt+0xc1/0x190
[ 1320.176502]  [<ffffffff8130b8ee>] ? timerqueue_del+0x1e/0x60
[ 1320.176505]  [<ffffffff810dff75>] ? __remove_hrtimer+0x35/0x90
[ 1320.176507]  [<ffffffff814dcc62>] ? qdisc_watchdog+0x22/0x30
[ 1320.176510]  [<ffffffff810e028a>] ? __hrtimer_run_queues+0xfa/0x280
[ 1320.176512]  [<ffffffff814dcdea>] ? tc_classify+0x6a/0x120
[ 1320.176514]  [<ffffffff814b4725>] ? __netif_receive_skb_core+0x495/0xa20
[ 1320.176516]  [<ffffffff814b4d2f>] ? netif_receive_skb_internal+0x2f/0xa0
[ 1320.176517]  [<ffffffff814b5c5b>] ? napi_gro_receive+0xbb/0x110
[ 1320.176520]  [<ffffffffc0177700>] ? tg3_poll_work+0xd90/0xef0 [tg3]
[ 1320.176523]  [<ffffffffc017789a>] ? tg3_poll_msix+0x3a/0x150 [tg3]
[ 1320.176525]  [<ffffffff814b54de>] ? net_rx_action+0x22e/0x360
[ 1320.176527]  [<ffffffff8107d4c8>] ? __do_softirq+0xf8/0x290
[ 1320.176529]  [<ffffffff8107d7ab>] ? irq_exit+0x9b/0xa0
[ 1320.176531]  [<ffffffff815b50df>] ? do_IRQ+0x4f/0xd0
[ 1320.176532]  [<ffffffff815b3202>] ? common_interrupt+0x82/0x82
[ 1320.176533]  <EOI>  [<ffffffff8147dbf8>] ? cpuidle_enter_state+0x118/0x2c0
[ 1320.176535]  [<ffffffff8147dbe5>] ? cpuidle_enter_state+0x105/0x2c0
[ 1320.176537]  [<ffffffff810b8837>] ? cpu_startup_entry+0x287/0x340
[ 1320.176539]  [<ffffffff8104d40a>] ? start_secondary+0x15a/0x190
[ 1320.176540] ---[ end trace b5b10ee435b3246e ]---
