From: Ben Greear <greearb@candelatech.com>
Subject: Lockdep splat for rt8169
Date: Wed, 04 May 2011 14:56:31 -0700
Message-ID: <4DC1CB8F.8080905@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:55934 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755984Ab1EDV4g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 17:56:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is from un-modified 39-rc6, with the slub cmpxcg patch posted today on lkml.

Seems to be the first post 2.6.38 kernel that will boot stable
on this system!

I previously reported the timer issue, but perhaps the lock
debugging will help.

[ INFO: inconsistent lock state ]
2.6.39-rc6+ #22
---------------------------------
inconsistent {HARDIRQ-ON-W} -> {IN-HARDIRQ-W} usage.
udevd/2410 [HC1[1]:SC0[0]:HE0:SE1] takes:
  (/home/greearb/git/linux-2.6/net/core/link_watch.c:35){?.-...}, at: [<c0445bb6>] del_timer_sync+0x0/0xa7
{HARDIRQ-ON-W} state was registered at:
   [<c046293d>] __lock_acquire+0x2b5/0xb77
   [<c046329f>] lock_acquire+0xa0/0xc4
   [<c044548a>] run_timer_softirq+0x142/0x232
   [<c043fbaa>] __do_softirq+0xb1/0x17c
irq event stamp: 138
hardirqs last  enabled at (137): [<c04b01b9>] get_page_from_freelist+0x28c/0x3c9
hardirqs last disabled at (138): [<c07f5927>] common_interrupt+0x27/0x40
softirqs last  enabled at (0): [<c0438c53>] copy_process+0x301/0xf1b
softirqs last disabled at (0): [<  (null)>]   (null)

other info that might help us debug this:
2 locks held by udevd/2410:
  #0:  (&sig->cred_guard_mutex){+.+.+.}, at: [<c04ea205>] prepare_bprm_creds+0x25/0x5a
  #1:  (&(&tp->lock)->rlock){-.-...}, at: [<f88c34ca>] __rtl8169_check_link_status+0x25/0xb4 [r8169]

stack backtrace:
Pid: 2410, comm: udevd Not tainted 2.6.39-rc6+ #22
Call Trace:
  [<c04617dc>] valid_state+0x131/0x144
  [<c04618de>] mark_lock+0xef/0x1de
  [<c0461fa1>] ? print_irq_inversion_bug+0xf0/0xf0
  [<c04628cf>] __lock_acquire+0x247/0xb77
  [<c0445bb6>] ? get_next_timer_interrupt+0x1d2/0x1d2
  [<c046329f>] lock_acquire+0xa0/0xc4
  [<c0445bb6>] ? get_next_timer_interrupt+0x1d2/0x1d2
  [<c0445bef>] del_timer_sync+0x39/0xa7
  [<c0445bb6>] ? get_next_timer_interrupt+0x1d2/0x1d2
  [<c07579ae>] linkwatch_schedule_work+0x6d/0x88
  [<c0757a76>] linkwatch_fire_event+0xad/0xb2
  [<c075ee8c>] netif_carrier_on+0x28/0x39
  [<f88c34f9>] __rtl8169_check_link_status+0x54/0xb4 [r8169]
  [<f88c3e22>] rtl8169_interrupt+0x1f4/0x298 [r8169]
  [<c0483fe0>] handle_irq_event_percpu+0x58/0x17b
  [<c0484134>] handle_irq_event+0x31/0x48
  [<c0485c2f>] ? handle_percpu_irq+0x40/0x40
  [<c0485cbe>] handle_edge_irq+0x8f/0xb1
  <IRQ>  [<c0403afe>] ? do_IRQ+0x3c/0x95
  [<c07f592e>] ? common_interrupt+0x2e/0x40
  [<c04b00d8>] ? get_page_from_freelist+0x1ab/0x3c9
  [<c04b0bd6>] ? __alloc_pages_nodemask+0x60e/0x66f
  [<c05b6061>] ? blk_finish_plug+0x12/0x2d
  [<c04254b1>] ? pte_alloc_one+0x1c/0x37
  [<c04c1fb7>] ? __pte_alloc+0x1d/0xf3
  [<c04c425f>] ? handle_mm_fault+0xee/0x150
  [<c04c4518>] ? __get_user_pages+0x257/0x39b
  [<c04c46d5>] ? get_user_pages+0x39/0x40
  [<c04eb064>] ? get_arg_page+0x35/0x8e
  [<c05cfc9c>] ? strnlen_user+0x20/0x3e
  [<c04eb1a8>] ? copy_strings+0xeb/0x1b3
  [<c04eb291>] ? copy_strings_kernel+0x21/0x30
  [<c04eb674>] ? do_execve+0x11d/0x22d
  [<c040830a>] ? sys_execve+0x31/0x54
  [<c07f5452>] ? ptregs_execve+0x12/0x20
  [<c07f535c>] ? sysenter_do_call+0x12/0x38
------------[ cut here ]------------
WARNING: at /home/greearb/git/linux-2.6/kernel/timer.c:1012 del_timer_sync+0x90/0xa7()
Hardware name: To Be Filled By O.E.M.
Modules linked in: veth 8021q garp stp llc fuse macvlan pktgen coretemp hwmon nfs lockd fscache auth_rpcgss nfs_acl sunrpc ipv6 uinput arc4 ecb 
snd_hda_codec_realtek ath9k snd_hda_intel snd_hda_codec mac80211 snd_hwdep snd_seq ath9k_common snd_seq_device snd_pcm microcode ath9k_hw ath cfg80211 snd_timer 
iTCO_wdt i2c_i801 pcspkr snd serio_raw iTCO_vendor_support r8169 soundcore snd_page_alloc mii i915 drm_kms_helper drm i2c_algo_bit video [last unloaded: 
scsi_wait_scan]
Pid: 2410, comm: udevd Not tainted 2.6.39-rc6+ #22
Call Trace:
  [<c043a0e2>] warn_slowpath_common+0x6a/0x7f
  [<c0445c46>] ? del_timer_sync+0x90/0xa7
  [<c043a10b>] warn_slowpath_null+0x14/0x18
  [<c0445c46>] del_timer_sync+0x90/0xa7
  [<c07579ae>] linkwatch_schedule_work+0x6d/0x88
  [<c0757a76>] linkwatch_fire_event+0xad/0xb2
  [<c075ee8c>] netif_carrier_on+0x28/0x39
  [<f88c34f9>] __rtl8169_check_link_status+0x54/0xb4 [r8169]
  [<f88c3e22>] rtl8169_interrupt+0x1f4/0x298 [r8169]
  [<c0483fe0>] handle_irq_event_percpu+0x58/0x17b
  [<c0484134>] handle_irq_event+0x31/0x48
  [<c0485c2f>] ? handle_percpu_irq+0x40/0x40
  [<c0485cbe>] handle_edge_irq+0x8f/0xb1
  <IRQ>  [<c0403afe>] ? do_IRQ+0x3c/0x95
  [<c07f592e>] ? common_interrupt+0x2e/0x40
  [<c04b00d8>] ? get_page_from_freelist+0x1ab/0x3c9
  [<c04b0bd6>] ? __alloc_pages_nodemask+0x60e/0x66f
  [<c05b6061>] ? blk_finish_plug+0x12/0x2d
  [<c04254b1>] ? pte_alloc_one+0x1c/0x37
  [<c04c1fb7>] ? __pte_alloc+0x1d/0xf3
  [<c04c425f>] ? handle_mm_fault+0xee/0x150
  [<c04c4518>] ? __get_user_pages+0x257/0x39b
  [<c04c46d5>] ? get_user_pages+0x39/0x40
  [<c04eb064>] ? get_arg_page+0x35/0x8e
  [<c05cfc9c>] ? strnlen_user+0x20/0x3e
  [<c04eb1a8>] ? copy_strings+0xeb/0x1b3
  [<c04eb291>] ? copy_strings_kernel+0x21/0x30
  [<c04eb674>] ? do_execve+0x11d/0x22d
  [<c040830a>] ? sys_execve+0x31/0x54
  [<c07f5452>] ? ptregs_execve+0x12/0x20
  [<c07f535c>] ? sysenter_do_call+0x12/0x38
---[ end trace 5bb67ffe27b66e2e ]---

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

