From: Johannes Berg <johannes@sipsolutions.net>
Subject: race condition leading to segfault in d80211
Date: Fri, 11 Aug 2006 13:14:31 +0200
Message-ID: <44DC6697.5080005@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:44733 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S932109AbWHKLPM
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Aug 2006 07:15:12 -0400
To: netdev@vger.kernel.org, Jiri Benc <jbenc@suse.cz>,
	Jouni Malinen <jkm@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

What was that about locking not having problems? :P

I was writing a small program that (using ioctls)
 * creates a new interface (using sysfs)
 * sets the interface to monitor mode
 * sets IFF_UP
 * (1)
 * sets IFF_DOWN
 * (2)
 * destroy interface (using sysfs)


That was fine, but then I wanted to see this happening and added 
"system("iwconfig")" at the two places marked (1) and (2), which 
triggered below bug. Note the address, I have slab debugging enabled.

[12143.789779] BUG: unable to handle kernel paging request at virtual address 6b6b752f
[12143.789785]  printing eip:
[12143.789787] e2cc1df0
[12143.789789] *pde = 00000000
[12143.789792] Oops: 0000 [#1]
[12143.789794] PREEMPT
[12143.789796] Modules linked in: arc4 rate_control rt2500usb 80211 ipv6 af_packet speedstep_lib cpufreq_userspace cpufreq_stats freq_table cpufreq_powersave cpufreq_ondemand cpufreq_conservative video sbs thermal i2c_ec i2c_core processor fan button battery container ac asus_acpi sr_mod sbp2 snd_intel8x0 snd_ac97_codec snd_ac97_bus snd_pcm_oss snd_mixer_oss snd_pcm snd_timer 8250_pnp snd soundcore floppy 8250 serial_core psmouse snd_page_alloc skge crc32 ohci1394 ieee1394 rtc pcspkr ehci_hcd uhci_hcd usbcore sg evdev
[12143.789831] CPU:    0
[12143.789832] EIP:    0060:[<e2cc1df0>]    Not tainted VLI
[12143.789833] EFLAGS: 00210282   (2.6.18-rc4 #2)
[12143.789850] EIP is at ieee80211_sta_scan_work+0x1a/0x406 [80211]
[12143.789853] eax: d517c320   ebx: cda019d8   ecx: c0128a7e   edx: c1490000
[12143.789856] esi: cda019dc   edi: 6b6b6b6b   ebp: c1491f4c   esp: c1491eec
[12143.789859] ds: 007b   es: 007b   ss: 0068
[12143.789862] Process events/0 (pid: 4, ti=c1490000 task=c1488070 task.ti=c1490000)
[12143.789864] Stack: 00200046 00200046 00200046 00000000 c042653c 00200046 00000000 c1476888
[12143.789872]        d517c000 d517c320 00200046 00000002 00000001 c0128a28 c147686c c0128a7e
[12143.789879]        00200046 c147686c c147686c 00200292 c1491f4c cda019d8 cda019dc c147686c
[12143.789887] Call Trace:
[12143.789889]  [<c010418f>] show_stack_log_lvl+0xa8/0xe5
[12143.789895]  [<c0104365>] show_registers+0x199/0x229
[12143.789899]  [<c0104844>] die+0x118/0x2ac
[12143.789902]  [<c0113db9>] do_page_fault+0x280/0x599
[12143.789908]  [<c0103ad5>] error_code+0x39/0x40
[12143.789912]  [<c0128a8e>] run_workqueue+0x76/0xea
[12143.789917]  [<c0128c88>] worker_thread+0xe4/0x11c
[12143.789921]  [<c012b82e>] kthread+0xcf/0xd3
[12143.789925]  [<c0101005>] kernel_thread_helper+0x5/0xb
[12143.789928] Code: ba 03 00 00 00 89 d8 e8 9c de 5c dd e9 e6 fe ff ff 55 89 e5 57 56 53 83 ec 54 89 45 c0 8b b8 c0 00 00 00 05 20 03 00 00 89 45 c4 <8b> 87 c4 09 00 00 89 45 b4 85 c0 0f 84 18 01 00 00 8b 87 d0 09
[12143.789964] EIP: [<e2cc1df0>] ieee80211_sta_scan_work+0x1a/0x406 [80211] SS:ESP 0068:c1491eec
[12143.789977]

