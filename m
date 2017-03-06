From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: 4.11-rc1 regression: e1000e "BUG at drivers/pci/msi.c" on unplugged suspend+resume
Date: Mon, 06 Mar 2017 10:28:36 +0100
Message-ID: <87bmten48r.fsf@miraculix.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, khalidm <khalidm@cisco.com>,
        David Singleton <davsingl@cisco.com>,
        Aaron Brown <aaron.f.brown@intel.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:41327 "EHLO canardo.mork.no"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753178AbdCFJ3B (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 6 Mar 2017 04:29:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is new with v4.11-rc1, so I strongly suspect commit 7e54d9d063fa
("e1000e: driver trying to free already-free irq"), which looks more
than suspicious in this context.  Haven't had time to test a revert
yet.  Just wanted to give an advance warning in case this isn't known.


Suspending and resuming my laptop with the ethernet unplugged results
in:

------------[ cut here ]------------
WARNING: CPU: 1 PID: 2086 at drivers/pci/msi.c:1052 __pci_enable_msi_range+=
0x3c8/0x420
Modules linked in: rfcomm xt_multiport iptable_filter 8021q garp mrp stp ll=
c tun ctr ccm cmac bnep nls_utf8 nls_cp437 vfat fat qcserial usb_wwan arc4 =
mei_wdt intel_rapl cdc_mbim cdc_wdm cdc_ncm usbnet mii usbserial x86_pkg_te=
mp_thermal intel_powerclamp coretemp kvm_intel kvm irqbypass crct10dif_pclm=
ul crc32_pclmul ghash_clmulni_intel pcbc uvcvideo btusb btrtl btbcm videobu=
f2_vmalloc videobuf2_memops snd_hda_codec_hdmi btintel videobuf2_v4l2 video=
buf2_core bluetooth videodev snd_hda_codec_conexant snd_hda_codec_generic i=
wlmvm mac80211 efi_pstore snd_hda_intel iwlwifi snd_hda_codec snd_hwdep aes=
ni_intel aes_x86_64 crypto_simd glue_helper cryptd snd_hda_core evdev serio=
_raw snd_pcm efivars cfg80211 iTCO_wdt iTCO_vendor_support snd_timer mei_me=
 mei thinkpad_acpi wmi nvram snd soundcore ac
 rfkill battery i915 intel_gtt i2c_algo_bit drm_kms_helper syscopyarea sysf=
illrect sysimgblt video fb_sys_fops tpm_crb drm intel_pch_thermal button tp=
m_tis tpm_tis_core tpm sunrpc efivarfs ip_tables x_tables autofs4 ext4 crc1=
6 jbd2 fscrypto mbcache crc32c_generic intel_ishtp_hid hid rtsx_pci_sdmmc m=
mc_core crc32c_intel psmouse i2c_i801 e1000e ptp pps_core xhci_pci xhci_hcd=
 nvme nvme_core usbcore rtsx_pci mfd_core intel_ish_ipc intel_ishtp thermal
CPU: 1 PID: 2086 Comm: kworker/u8:38 Not tainted 4.11.0-rc1 #443
Hardware name: LENOVO 20FB006AMN/20FB006AMN, BIOS N1FET47W (1.21 ) 11/28/20=
16
Workqueue: events_unbound async_run_entry_fn
Call Trace:
 dump_stack+0x67/0x92
 __warn+0xd1/0xf0
 warn_slowpath_null+0x1d/0x20
 __pci_enable_msi_range+0x3c8/0x420
 ? e1000_get_phy_info_82577+0x30/0x170 [e1000e]
 pci_enable_msi+0x1a/0x30
 e1000e_set_interrupt_capability+0x3c/0x120 [e1000e]
 e1000e_pm_thaw+0x22/0x60 [e1000e]
 e1000e_pm_resume+0x25/0x30 [e1000e]
 pci_pm_resume+0x64/0xa0
 dpm_run_callback+0xb9/0x2f0
 ? pci_pm_thaw+0x90/0x90
 device_resume+0x87/0x190
 async_resume+0x1d/0x50
 async_run_entry_fn+0x39/0x170
 process_one_work+0x1fe/0x6d0
 ? process_one_work+0x17f/0x6d0
 worker_thread+0x69/0x4c0
 kthread+0x12b/0x160
 ? process_one_work+0x6d0/0x6d0
 ? kthread_create_on_node+0x60/0x60
 ret_from_fork+0x2e/0x40
---[ end trace 103a4ba3722e184f ]---
e1000e 0000:00:1f.6 eth0: Failed to initialize MSI interrupts.  Falling bac=
k to legacy interrupts.


followed by


------------[ cut here ]------------
kernel BUG at drivers/pci/msi.c:893!
invalid opcode: 0000 [#1] SMP
Modules linked in: rfcomm xt_multiport iptable_filter 8021q garp mrp stp ll=
c tun ctr ccm cmac bnep nls_utf8 nls_cp437 vfat fat qcserial usb_wwan arc4 =
mei_wdt intel_rapl cdc_mbim cdc_wdm cdc_ncm usbnet mii usbserial x86_pkg_te=
mp_thermal intel_powerclamp coretemp kvm_intel kvm irqbypass crct10dif_pclm=
ul crc32_pclmul ghash_clmulni_intel pcbc uvcvideo btusb btrtl btbcm videobu=
f2_vmalloc videobuf2_memops snd_hda_codec_hdmi btintel videobuf2_v4l2 video=
buf2_core bluetooth videodev snd_hda_codec_conexant snd_hda_codec_generic i=
wlmvm mac80211 efi_pstore snd_hda_intel iwlwifi snd_hda_codec snd_hwdep aes=
ni_intel aes_x86_64 crypto_simd glue_helper cryptd snd_hda_core evdev serio=
_raw snd_pcm efivars cfg80211 iTCO_wdt iTCO_vendor_support snd_timer mei_me=
 mei thinkpad_acpi wmi nvram snd soundcore ac
 rfkill battery i915 intel_gtt i2c_algo_bit drm_kms_helper syscopyarea sysf=
illrect sysimgblt video fb_sys_fops tpm_crb drm intel_pch_thermal button tp=
m_tis tpm_tis_core tpm sunrpc efivarfs ip_tables x_tables autofs4 ext4 crc1=
6 jbd2 fscrypto mbcache crc32c_generic intel_ishtp_hid hid rtsx_pci_sdmmc m=
mc_core crc32c_intel psmouse i2c_i801 e1000e ptp pps_core xhci_pci xhci_hcd=
 nvme nvme_core usbcore rtsx_pci mfd_core intel_ish_ipc intel_ishtp thermal
CPU: 3 PID: 545 Comm: NetworkManager Tainted: G        W       4.11.0-rc1 #=
443
Hardware name: LENOVO 20FB006AMN/20FB006AMN, BIOS N1FET47W (1.21 ) 11/28/20=
16
task: ffff98efa6452380 task.stack: ffffb475426e0000
RIP: 0010:pci_msi_shutdown+0x11c/0x130
RSP: 0018:ffffb475426e36a8 EFLAGS: 00010246
RAX: ffff98efaddfd440 RBX: ffff98efaddfd000 RCX: 0000000000000000
RDX: ffff98efaddfd440 RSI: 0000000000000000 RDI: ffff98efaddfd000
RBP: ffffb475426e36c8 R08: ffff98efaab74000 R09: ffff98efaab74000
R10: ffffffff8d784c80 R11: 0000000000000000 R12: ffff98efaab74000
R13: 00000000ffffffea R14: ffff98efaab74000 R15: 0000000000000000
FS:  00007f25df4c7e40(0000) GS:ffff98efb0c00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f609181eab4 CR3: 000000042645d000 CR4: 00000000001406e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Call Trace:
 pci_disable_msi+0x2c/0x40
 e1000e_reset_interrupt_capability+0x52/0x60 [e1000e]
 e1000_request_irq+0x1b9/0x260 [e1000e]
 e1000e_open+0x107/0x440 [e1000e]
 __dev_open+0xc8/0x140
 __dev_change_flags+0x9d/0x160
 dev_change_flags+0x29/0x70
 do_setlink+0x4fe/0xda0
 ? sched_clock_cpu+0x11/0xc0
 ? sched_clock_cpu+0x11/0xc0
 ? sched_clock_cpu+0x11/0xc0
 ? nla_parse+0x32/0x100
 rtnl_newlink+0x514/0x910
 ? ndo_dflt_fdb_add+0x90/0xa0
 ? ns_capable_common+0x81/0xa0
 ? ns_capable+0x13/0x20
 rtnetlink_rcv_msg+0xa1/0x220
 ? netlink_deliver_tap+0x5/0x2c0
 ? netlink_deliver_tap+0x7a/0x2c0
 ? rtnl_newlink+0x910/0x910
 netlink_rcv_skb+0xa4/0xc0
 rtnetlink_rcv+0x2a/0x40
 netlink_unicast+0x181/0x220
 netlink_sendmsg+0x353/0x3a0
 ___sys_sendmsg+0x2e7/0x300
 ? sched_clock_cpu+0x11/0xc0
 ? sched_clock_cpu+0x11/0xc0
 ? __fget+0x5/0x200
 ? __fget+0xf5/0x200
 ? __fget+0x114/0x200
 ? __fget+0x5/0x200
 ? __fget_light+0x25/0x60
 __sys_sendmsg+0x54/0x90
 SyS_sendmsg+0x12/0x20
 entry_SYSCALL_64_fastpath+0x1c/0xb1
RIP: 0033:0x7f25dcc59e90
RSP: 002b:00007ffef0005c60 EFLAGS: 00000293 ORIG_RAX: 000000000000002e
RAX: ffffffffffffffda RBX: 0000559c6db98b41 RCX: 00007f25dcc59e90
RDX: 0000000000000000 RSI: 00007ffef0005d10 RDI: 000000000000000c
RBP: 00007ffef0006160 R08: 0000000000000000 R09: 0000000000001010
R10: 0000000000000030 R11: 0000000000000293 R12: 0000000000000001
R13: 0000000000000000 R14: 0000559c6de08000 R15: 0000000000000000
Code: 10 5b 41 5c 5d c3 be 01 00 00 00 89 f0 d3 e0 89 c1 d3 e6 83 ee 01 89 =
f2 f7 d2 eb b7 be 01 00 00 00 48 89 df e8 46 fb fd ff eb 89 <0f> 0b e8 ad 5=
b ca ff 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 0f=20
RIP: pci_msi_shutdown+0x11c/0x130 RSP: ffffb475426e36a8
---[ end trace 103a4ba3722e1850 ]---




Bj=C3=B8rn
