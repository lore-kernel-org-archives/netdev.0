From: Ulrich Kunitz <kune@deine-taler.de>
Subject: d80211: soft lockup in ieee80211_unregister_hw
Date: Sat, 6 Jan 2007 14:30:24 +0100
Message-ID: <20070106133024.GA18480@p15091797.pureserver.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from deine-taler.de ([217.160.107.63]:58485 "EHLO
	p15091797.pureserver.info" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751384AbXAFNa0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Jan 2007 08:30:26 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

while doing my first steps under d80211 I stumbled over a
soft lockup. It's on a real SMP machine (Core 2 Duo). After the
lockup the machine becomes unusable. I can reproduce it reliably
by unplugging the device.

The bug appears to be present in the John Linville's wireless-dev
master branch, but also in Micheal Wu's zd1211rw-week51 branch. 

Reading the code I see that the work structs are canceled more
then one time. At first in ieee80211_unregister_hw and second in
ieee80211_if_shutdown called by unregister_netdev. The second
cancel operation casues the soft lockup.

Does anybody have an idea how to fix it? 

Here is the kernel log with the soft lockup.

Ja  6 13:13:26 newa kernel: [  152.647382] BUG: soft lockup detected on CPU#0!
Jan  6 13:13:26 newa kernel: [  152.647390] 
Jan  6 13:13:26 newa kernel: [  152.647391] Call Trace:
Jan  6 13:13:26 newa kernel: [  152.647410]  [show_trace+65/112] show_trace+0x41/0x70
Jan  6 13:13:26 newa kernel: [  152.647419]  [dump_stack+18/32] dump_stack+0x12/0x20
Jan  6 13:13:26 newa kernel: [  152.647429]  [softlockup_tick+250/288] softlockup_tick+0xfa/0x120
Jan  6 13:13:26 newa kernel: [  152.647439]  [update_process_times+87/144] update_process_times+0x57/0x90
Jan  6 13:13:26 newa kernel: [  152.647448]  [smp_local_timer_interrupt+52/96] smp_local_timer_interrupt+0x34/0x60
Jan  6 13:13:26 newa kernel: [  152.647457]  [smp_apic_timer_interrupt+89/128] smp_apic_timer_interrupt+0x59/0x80
Jan  6 13:13:26 newa kernel: [  152.647465]  [apic_timer_interrupt+102/112] apic_timer_interrupt+0x66/0x70
Jan  6 13:13:26 newa kernel: [  152.648225] DWARF2 unwinder stuck at apic_timer_interrupt+0x66/0x70
Jan  6 13:13:26 newa kernel: [  152.648229] 
Jan  6 13:13:26 newa kernel: [  152.648232] Leftover inexact backtrace:
Jan  6 13:13:26 newa kernel: [  152.648233] 
Jan  6 13:13:26 newa kernel: [  152.648237]  <IRQ>  <EOI>  [lock_timer_base+64/96] lock_timer_base+0x40/0x60
Jan  6 13:13:26 newa kernel: [  152.648268]  [try_to_del_timer_sync+24/96] try_to_del_timer_sync+0x18/0x60
Jan  6 13:13:26 newa kernel: [  152.648277]  [del_timer_sync+12/32] del_timer_sync+0xc/0x20
Jan  6 13:13:26 newa kernel: [  152.648301]  [_end+129730637/2130872328] :80211:ieee80211_if_shutdown+0x75/0x100
Jan  6 13:13:26 newa kernel: [  152.648323]  [_end+129745001/2130872328] :80211:ieee80211_stop+0x101/0x120
Jan  6 13:13:26 newa kernel: [  152.648334]  [dev_close+88/128] dev_close+0x58/0x80
Jan  6 13:13:26 newa kernel: [  152.648341]  [unregister_netdevice+149/592] unregister_netdevice+0x95/0x250
Jan  6 13:13:26 newa kernel: [  152.648363]  [_end+129742664/2130872328] :80211:ieee80211_unregister_hw+0x90/0x220
Jan  6 13:13:26 newa kernel: [  152.648382]  [_end+129956419/2130872328] :zd1211rw_d80211:disconnect+0xab/0x120
Jan  6 13:13:26 newa kernel: [  152.648412]  [_end+128711626/2130872328] :usbcore:usb_unbind_interface+0x72/0xe0
Jan  6 13:13:26 newa kernel: [  152.648423]  [__device_release_driver+135/208] __device_release_driver+0x87/0xd0
Jan  6 13:13:26 newa kernel: [  152.648431]  [device_release_driver+51/96] device_release_driver+0x33/0x60
Jan  6 13:13:26 newa kernel: [  152.648438]  [bus_remove_device+137/176] bus_remove_device+0x89/0xb0
Jan  6 13:13:26 newa kernel: [  152.648446]  [device_del+419/496] device_del+0x1a3/0x1f0
Jan  6 13:13:26 newa kernel: [  152.648472]  [_end+128700218/2130872328] :usbcore:usb_disable_device+0x82/0x100
Jan  6 13:13:26 newa kernel: [  152.648499]  [_end+128684210/2130872328] :usbcore:usb_disconnect+0xaa/0x110
Jan  6 13:13:26 newa kernel: [  152.648526]  [_end+128687990/2130872328] :usbcore:hub_thread+0x48e/0xd20
Jan  6 13:13:26 newa kernel: [  152.648537]  [thread_return+0/237] thread_return+0x0/0xed
Jan  6 13:13:26 newa kernel: [  152.648551]  [autoremove_wake_function+0/48] autoremove_wake_function+0x0/0x30
Jan  6 13:13:26 newa kernel: [  152.648579]  [_end+128686824/2130872328] :usbcore:hub_thread+0x0/0xd20
Jan  6 13:13:26 newa kernel: [  152.648587]  [keventd_create_kthread+0/128] keventd_create_kthread+0x0/0x80
Jan  6 13:13:26 newa kernel: [  152.648594]  [kthread+217/288] kthread+0xd9/0x120
Jan  6 13:13:26 newa kernel: [  152.648604]  [child_rip+10/18] child_rip+0xa/0x12
Jan  6 13:13:26 newa kernel: [  152.648611]  [keventd_create_kthread+0/128] keventd_create_kthread+0x0/0x80
Jan  6 13:13:26 newa kernel: [  152.648620]  [flat_send_IPI_mask+0/80] flat_send_IPI_mask+0x0/0x50
Jan  6 13:13:26 newa kernel: [  152.648630]  [kthread+0/288] kthread+0x0/0x120
Jan  6 13:13:26 newa kernel: [  152.648637]  [child_rip+0/18] child_rip+0x0/0x12
Jan  6 13:13:26 newa kernel: [  152.648643] 

Uli

-- 
Uli Kunitz
