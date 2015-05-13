From: Dan Williams <dcbw@redhat.com>
Subject: Re: BUG: rwlock bad magic on CPU#1, NetworkManager/
Date: Wed, 13 May 2015 18:05:31 -0500
Message-ID: <1431558331.6773.35.camel@redhat.com>
References: <20150513214939.GA4755@hudson.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeremiah Mahler <jmmahler@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150513214939.GA4755@hudson.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-05-13 at 14:49 -0700, Jeremiah Mahler wrote:
> all,
> 
> Running the latest linux-next (20150513) on an Acer C720 causes the
> machine to lockup as the window manager is started.  The following BUG
> messages and trace are found in the logs from the failed boot (full log
> is attached).
> 
> May 13 14:25:25 newt NetworkManager[1182]: <info> Loaded device plugin: /usr/lib/x86_64-linux-gnu/NetworkManager/libnm-device-plugin-adsl.so
> May 13 14:25:25 newt NetworkManager[1182]: <info> Loaded device plugin: /usr/lib/x86_64-linux-gnu/NetworkManager/libnm-device-plugin-wwan.so
> May 13 14:25:25 newt NetworkManager[1182]: <info> WiFi enabled by radio killswitch; enabled by state file
> May 13 14:25:25 newt NetworkManager[1182]: <info> WWAN enabled by radio killswitch; enabled by state file
> May 13 14:25:25 newt NetworkManager[1182]: <info> WiMAX enabled by radio killswitch; enabled by state file
> May 13 14:25:25 newt NetworkManager[1182]: <info> Networking is enabled by state file
> May 13 14:25:25 newt NetworkManager[1182]: <info> (lo): link connected
> May 13 14:25:25 newt NetworkManager[1182]: <info> (lo): carrier is ON
> May 13 14:25:25 newt NetworkManager[1182]: <info> (lo): new Generic device (driver: 'unknown' ifindex: 1)
> May 13 14:25:25 newt NetworkManager[1182]: <info> (lo): exported as /org/freedesktop/NetworkManager/Devices/0
> May 13 14:25:25 newt NetworkManager[1182]: <info> (wlan0): using nl80211 for WiFi device control
> May 13 14:25:25 newt NetworkManager[1182]: <info> (wlan0): driver supports Access Point (AP) mode
> May 13 14:25:25 newt NetworkManager[1182]: <info> (wlan0): new 802.11 WiFi device (driver: 'ath9k' ifindex: 2)
> May 13 14:25:25 newt kernel: random: nonblocking pool is initialized
> May 13 14:25:25 newt kernel: BUG: rwlock bad magic on CPU#1, NetworkManager/1182, ffff880074862918
> May 13 14:25:25 newt kernel: CPU: 1 PID: 1182 Comm: NetworkManager Not tainted 4.1.0-rc3-next-20150513+ #192
> May 13 14:25:25 newt kernel: Hardware name: Acer Peppy, BIOS          04/30/2014
> May 13 14:25:25 newt kernel:  0000000000000000 ffff880074862930 ffffffff815628c6 ffff880074862918
> May 13 14:25:25 newt kernel:  ffffffff810b6594 ffff880074862900 ffffffffa05a941b 0000000000000001
> May 13 14:25:25 newt kernel:  0000000000000000 ffff880074862900 ffff880074862900 ffff880071e50740
> May 13 14:25:25 newt kernel: Call Trace:
> May 13 14:25:25 newt kernel:  [<ffffffff815628c6>] ? dump_stack+0x40/0x50
> May 13 14:25:25 newt kernel:  [<ffffffff810b6594>] ? do_raw_read_lock+0x34/0x50
> May 13 14:25:25 newt kernel:  [<ffffffffa05a941b>] ? tpt_trig_timer+0xdb/0x150 [mac80211]
> May 13 14:25:25 newt kernel:  [<ffffffffa05a9a85>] ? ieee80211_mod_tpt_led_trig+0x95/0x150 [mac80211]
> May 13 14:25:25 newt kernel:  [<ffffffffa056c87c>] ? ieee80211_do_open+0x77c/0xd90 [mac80211]
> May 13 14:25:25 newt kernel:  [<ffffffff81473246>] ? __dev_open+0x96/0x100
> May 13 14:25:25 newt kernel:  [<ffffffff81473516>] ? __dev_change_flags+0x96/0x160
> May 13 14:25:25 newt kernel:  [<ffffffff81473603>] ? dev_change_flags+0x23/0x60
> May 13 14:25:25 newt kernel:  [<ffffffff81480e2d>] ? do_setlink+0x2fd/0x860
> May 13 14:25:25 newt kernel:  [<ffffffff8130bdde>] ? nla_parse+0x2e/0x110
> May 13 14:25:25 newt kernel:  [<ffffffff81482545>] ? rtnl_newlink+0x545/0x8e0
> May 13 14:25:25 newt kernel:  [<ffffffff8145dd42>] ? __kmalloc_reserve.isra.31+0x32/0x90
> May 13 14:25:25 newt kernel:  [<ffffffff81524db4>] ? fib6_walk+0x74/0x80
> May 13 14:25:25 newt kernel:  [<ffffffff8145dd42>] ? __kmalloc_reserve.isra.31+0x32/0x90
> May 13 14:25:25 newt kernel:  [<ffffffff8147fc0d>] ? rtnetlink_rcv_msg+0x8d/0x250
> May 13 14:25:25 newt kernel:  [<ffffffff8145e8f7>] ? __alloc_skb+0x47/0x1e0
> May 13 14:25:25 newt kernel:  [<ffffffff8149c7b0>] ? __netlink_lookup+0xb0/0xe0
> May 13 14:25:25 newt kernel:  [<ffffffff8147fb80>] ? rtnetlink_rcv+0x30/0x30
> May 13 14:25:25 newt kernel:  [<ffffffff8149f350>] ? netlink_rcv_skb+0xa0/0xc0
> May 13 14:25:25 newt kernel:  [<ffffffff8147fb74>] ? rtnetlink_rcv+0x24/0x30
> May 13 14:25:25 newt kernel:  [<ffffffff8149eaf4>] ? netlink_unicast+0x104/0x190
> May 13 14:25:25 newt kernel:  [<ffffffff8149f086>] ? netlink_sendmsg+0x506/0x620
> May 13 14:25:25 newt kernel:  [<ffffffff81455b2c>] ? sock_sendmsg+0x3c/0x50
> May 13 14:25:25 newt kernel:  [<ffffffff8145667b>] ? ___sys_sendmsg+0x27b/0x290
> May 13 14:25:25 newt kernel:  [<ffffffff811c3618>] ? mem_cgroup_try_charge+0x88/0x110
> May 13 14:25:25 newt kernel:  [<ffffffff811c3976>] ? mem_cgroup_commit_charge+0x56/0xa0
> May 13 14:25:25 newt kernel:  [<ffffffff81568f1e>] ? _raw_spin_unlock+0xe/0x20
> May 13 14:25:25 newt kernel:  [<ffffffff812ef349>] ? lockref_put_or_lock+0x9/0x30
> May 13 14:25:25 newt kernel:  [<ffffffff81456dfe>] ? __sys_sendmsg+0x3e/0x80
> May 13 14:25:25 newt kernel:  [<ffffffff81569472>] ? system_call_fastpath+0x16/0x75
> May 13 14:25:25 newt kernel: BUG: unable to handle kernel paging request at ffffffffffffff48
> May 13 14:25:25 newt kernel: IP: [<ffffffff810d3075>] lock_timer_base.isra.36+0x15/0x60
> May 13 14:25:25 newt kernel: PGD 1810067 PUD 1812067 PMD 0 
> May 13 14:25:25 newt kernel: Oops: 0000 [#1] SMP 
> May 13 14:25:25 newt kernel: Modules linked in: binfmt_misc snd_hda_codec_hdmi uvcvideo hid_generic videobuf2_vmalloc videobuf2_memops videobuf2_core v4l2_common usbhid videodev hid media cyapatp crc_itu_t tpm_infineon iTCO_wdt iTCO_vendor_support arc4 ath9k ath9k_common ath9k_hw x86_pkg_temp_thermal intel_powerclamp intel_rapl iosf_mbi coretemp kvm_intel kvm ath mac80211 crct10dif_pclmul crc32_pclmul chromeos_laptop crc32c_intel ghash_clmulni_intel cryptd evdev cfg80211 serio_raw pcspkr i915 i2c_i801 tpm_tis ac tpm battery snd_hda_codec_realtek snd_hda_codec_generic ath3k snd_hda_intel btusb snd_hda_codec btintel i2c_algo_bit drm_kms_helper video bluetooth snd_hwdep snd_hda_core drm snd_pcm button processor rfkill snd_timer lpc_ich shpchp snd mfd_core i2c_designware_pci i2c_designware_c
 ore i2c_core soundcore fuse
> May 13 14:25:25 newt kernel:  autofs4 ext4 crc16 mbcache jbd2 sg sd_mod fan ahci libahci thermal sdhci_acpi sdhci mmc_core thermal_sys xhci_pci xhci_hcd usbcore libata scsi_mod usb_common
> May 13 14:25:25 newt kernel: CPU: 1 PID: 1182 Comm: NetworkManager Not tainted 4.1.0-rc3-next-20150513+ #192
> May 13 14:25:25 newt kernel: Hardware name: Acer Peppy, BIOS          04/30/2014
> May 13 14:25:25 newt kernel: task: ffff88003529a250 ti: ffff880035590000 task.ti: ffff880035590000
> May 13 14:25:25 newt kernel: RIP: 0010:[<ffffffff810d3075>]  [<ffffffff810d3075>] lock_timer_base.isra.36+0x15/0x60
> May 13 14:25:25 newt kernel: RSP: 0018:ffff8800355936e8  EFLAGS: 00010296
> May 13 14:25:25 newt kernel: RAX: 0000000000000000 RBX: ffffffffffffff30 RCX: 0000000000000006
> May 13 14:25:25 newt kernel: RDX: ffff880035593780 RSI: ffff880035593720 RDI: ffffffffffffff48
> May 13 14:25:25 newt kernel: RBP: ffff880035593778 R08: 000000000000000a R09: 00000000fffffffe
> May 13 14:25:25 newt kernel: R10: 0000000000000296 R11: 0000000000000002 R12: ffffffffffffff48
> May 13 14:25:25 newt kernel: R13: ffff880035593720 R14: 0000000000000001 R15: ffff880074b90a60
> May 13 14:25:25 newt kernel: FS:  00007f00b64ea8c0(0000) GS:ffff880100300000(0000) knlGS:0000000000000000
> May 13 14:25:25 newt kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> May 13 14:25:25 newt kernel: CR2: ffffffffffffff48 CR3: 00000000715b5000 CR4: 00000000000407e0
> May 13 14:25:25 newt kernel: Stack:
> May 13 14:25:25 newt kernel:  0000000000000000 ffffffffffffff30 ffff880035593778 ffff880035593780
> May 13 14:25:25 newt kernel:  0000000000000000 ffffffff810d429c 0000000000000000 0000000000000001
> May 13 14:25:25 newt kernel:  ffff880074b90a60 ffffffffffffff30 ffff880035593778 ffffffff810d432a
> May 13 14:25:25 newt kernel: Call Trace:
> May 13 14:25:25 newt kernel:  [<ffffffff810d429c>] ? try_to_del_timer_sync+0x1c/0x60
> May 13 14:25:25 newt kernel:  [<ffffffff810d432a>] ? del_timer_sync+0x4a/0x50
> May 13 14:25:25 newt kernel:  [<ffffffff8143e61b>] ? led_blink_set+0x1b/0x40
> May 13 14:25:25 newt kernel:  [<ffffffffa05a9440>] ? tpt_trig_timer+0x100/0x150 [mac80211]
> May 13 14:25:25 newt kernel:  [<ffffffffa05a9a85>] ? ieee80211_mod_tpt_led_trig+0x95/0x150 [mac80211]
> May 13 14:25:25 newt kernel:  [<ffffffffa056c87c>] ? ieee80211_do_open+0x77c/0xd90 [mac80211]
> May 13 14:25:25 newt kernel:  [<ffffffff81473246>] ? __dev_open+0x96/0x100
> May 13 14:25:25 newt kernel:  [<ffffffff81473516>] ? __dev_change_flags+0x96/0x160
> May 13 14:25:25 newt kernel:  [<ffffffff81473603>] ? dev_change_flags+0x23/0x60
> May 13 14:25:25 newt kernel:  [<ffffffff81480e2d>] ? do_setlink+0x2fd/0x860
> May 13 14:25:25 newt kernel:  [<ffffffff8130bdde>] ? nla_parse+0x2e/0x110
> May 13 14:25:25 newt kernel:  [<ffffffff81482545>] ? rtnl_newlink+0x545/0x8e0
> May 13 14:25:25 newt kernel:  [<ffffffff8145dd42>] ? __kmalloc_reserve.isra.31+0x32/0x90
> May 13 14:25:25 newt kernel:  [<ffffffff81524db4>] ? fib6_walk+0x74/0x80
> May 13 14:25:25 newt kernel:  [<ffffffff8145dd42>] ? __kmalloc_reserve.isra.31+0x32/0x90
> May 13 14:25:25 newt kernel:  [<ffffffff8147fc0d>] ? rtnetlink_rcv_msg+0x8d/0x250
> May 13 14:25:25 newt kernel:  [<ffffffff8145e8f7>] ? __alloc_skb+0x47/0x1e0
> May 13 14:25:25 newt kernel:  [<ffffffff8149c7b0>] ? __netlink_lookup+0xb0/0xe0
> May 13 14:25:25 newt kernel:  [<ffffffff8147fb80>] ? rtnetlink_rcv+0x30/0x30
> May 13 14:25:25 newt kernel:  [<ffffffff8149f350>] ? netlink_rcv_skb+0xa0/0xc0
> May 13 14:25:25 newt kernel:  [<ffffffff8147fb74>] ? rtnetlink_rcv+0x24/0x30
> May 13 14:25:25 newt kernel:  [<ffffffff8149eaf4>] ? netlink_unicast+0x104/0x190
> May 13 14:25:25 newt kernel:  [<ffffffff8149f086>] ? netlink_sendmsg+0x506/0x620
> May 13 14:25:25 newt kernel:  [<ffffffff81455b2c>] ? sock_sendmsg+0x3c/0x50
> May 13 14:25:25 newt kernel:  [<ffffffff8145667b>] ? ___sys_sendmsg+0x27b/0x290
> May 13 14:25:25 newt kernel:  [<ffffffff811c3618>] ? mem_cgroup_try_charge+0x88/0x110
> May 13 14:25:25 newt kernel:  [<ffffffff811c3976>] ? mem_cgroup_commit_charge+0x56/0xa0
> May 13 14:25:25 newt kernel:  [<ffffffff81568f1e>] ? _raw_spin_unlock+0xe/0x20
> May 13 14:25:25 newt kernel:  [<ffffffff812ef349>] ? lockref_put_or_lock+0x9/0x30
> May 13 14:25:25 newt kernel:  [<ffffffff81456dfe>] ? __sys_sendmsg+0x3e/0x80
> May 13 14:25:25 newt kernel:  [<ffffffff81569472>] ? system_call_fastpath+0x16/0x75
> May 13 14:25:25 newt kernel: Code: 1a 83 e2 3f e8 9d fc ff ff e9 e3 fd ff ff 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 41 55 41 54 49 89 f5 55 53 49 89 fc 48 83 ec 08 <49> 8b 1c 24 48 89 dd 48 83 e5 fc 74 31 48 89 ef e8 86 61 49 00 
> May 13 14:25:25 newt kernel: RIP  [<ffffffff810d3075>] lock_timer_base.isra.36+0x15/0x60
> 
> If I disable NetworkManager
> 
>   systemctl disable NetworkManager.service
> 
> and reboot, everything works, except networking is down.
> 
> So somehow NetworkManager is triggering a fault although I am not sure
> how.  Any suggestions for what to try next are welcome.

NM is triggering the fault, but only by doing a normal operation of
opening the netdevice.  The fault lies in the mac80211 stack's LED
handling somewhere.

Dan
