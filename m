From: Ben Greear <greearb@candelatech.com>
Subject: Crash in e1000e, 3.3.8+ (tainted)
Date: Tue, 24 Jul 2012 14:46:08 -0700
Message-ID: <500F17A0.30906@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: e1000-devel list <e1000-devel@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:33260 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753709Ab2GXVqQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 17:46:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have a somewhat reproducible crash using a 6-port NIC
with 3.3.8+ kernel.  This kernel is tainted with a proprietary
module, but the module is not in use.

The rx-all and related patches that were later accepted
upstream have been applied to this kernel.

It seems that buffer_info is NULL in the code below?


(gdb) list e1000_alloc_rx_buffers+0x5b
Junk at end of line specification.
(gdb) list *(e1000_alloc_rx_buffers+0x5b)
0x15822 is in e1000_alloc_rx_buffers (/home/greearb/git/linux-3.3.dev.y/drivers/net/ethernet/intel/e1000e/netdev.c:611).
606	
607		i = rx_ring->next_to_use;
608		buffer_info = &rx_ring->buffer_info[i];
609	
610		while (cleaned_count--) {
611			skb = buffer_info->skb;
612			if (skb) {
613				skb_trim(skb, 0);
614				goto map_skb;
615			}
(gdb)



ADDRCONF(NETDEV_UP): rddVR1-p: link is not ready
ADDRCONF(NETDEV_UP): eth16: link is not ready
8021q: adding VLAN 0 to HW filter on device eth16
e1000e: eth17 NIC Link is Down
e1000e 0000:04:00.1: eth17: Reset adapter
------------[ cut here ]------------
WARNING: at /home/greearb/git/linux-3.3.dev.y/drivers/net/ethernet/intel/e1000e/netdev.c:3937 e1000_close+0x38/0x134 [e1000e]()
Hardware name: To be filled by O.E.M.
Modules linked in: veth 8021q garp stp llc fuse macvlan wanlink(PO) pktgen sbs sbshc f71882fg coretemp hwmon sunrpc ipv6 uinput snd_hda_codec_realtek 
snd_hda_intel ath9k snd_hda_codec mac80211 joydev snd_hwdep snd_seq ath9k_common ath9k_hw snd_seq_device snd_pcm ath snd_timer e1000e snd mei(C) microcode 
cfg80211 ppdev i2c_i801 soundcore serio_raw pcspkr snd_page_alloc iTCO_wdt iTCO_vendor_support parport_pc parport i915 drm_kms_helper drm i2c_algo_bit i2c_core 
video [last unloaded: scsi_wait_scan]
Pid: 2360, comm: ip Tainted: P         C O 3.3.8+ #51
Call Trace:
  [<ffffffff81055bd1>] warn_slowpath_common+0x80/0x98
  [<ffffffff81055bfe>] warn_slowpath_null+0x15/0x17
  [<ffffffffa0199f49>] e1000_close+0x38/0x134 [e1000e]
  [<ffffffff8141239f>] __dev_close_many+0x88/0xb9
  [<ffffffff81412401>] __dev_close+0x31/0x42
  [<ffffffff8140fd39>] __dev_change_flags+0xb9/0x13c
  [<ffffffff81412d48>] dev_change_flags+0x1c/0x52
  [<ffffffff8141dfac>] do_setlink+0x2b8/0x7ca
  [<ffffffff8141cfd7>] ? rtnl_fill_ifinfo+0x9f1/0xab1
  [<ffffffff8141e7f3>] rtnl_newlink+0x266/0x4b7
  [<ffffffff8141e630>] ? rtnl_newlink+0xa3/0x4b7
  [<ffffffff8141db55>] ? rtnl_dump_ifinfo+0x134/0x15d
  [<ffffffff81077243>] ? get_parent_ip+0x11/0x42
  [<ffffffff814c9382>] ? sub_preempt_count+0x92/0xa5
  [<ffffffff811d7328>] ? security_capable+0x13/0x15
  [<ffffffff8141d78b>] rtnetlink_rcv_msg+0x21e/0x23b
  [<ffffffff8141d56d>] ? rtnetlink_rcv+0x28/0x28
  [<ffffffff8142fbb6>] netlink_rcv_skb+0x3e/0x8f
  [<ffffffff8141d566>] rtnetlink_rcv+0x21/0x28
  [<ffffffff8142f991>] netlink_unicast+0xe9/0x152
  [<ffffffff814300ea>] netlink_sendmsg+0x1f8/0x216
  [<ffffffff813fed37>] __sock_sendmsg_nosec+0x5f/0x6a
  [<ffffffff813fed7f>] __sock_sendmsg+0x3d/0x48
  [<ffffffff813ff61f>] sock_sendmsg+0xa3/0xbc
  [<ffffffff81077243>] ? get_parent_ip+0x11/0x42
  [<ffffffff814c9382>] ? sub_preempt_count+0x92/0xa5
  [<ffffffff814c623b>] ? _raw_spin_unlock+0x28/0x33
  [<ffffffff810e73ae>] ? do_wp_page+0x548/0x5af
  [<ffffffff813fe77d>] ? copy_from_user+0x9/0xb
  [<ffffffff813ff2c7>] ? move_addr_to_kernel+0x2b/0x65
  [<ffffffff814099b1>] ? copy_from_user+0x9/0xb
  [<ffffffff81409cfe>] ? verify_iovec+0x4f/0xa3
  [<ffffffff813ffd81>] __sys_sendmsg+0x20f/0x29c
  [<ffffffff810e8241>] ? handle_mm_fault+0x1ac/0x1c4
  [<ffffffff814c9195>] ? do_page_fault+0x2de/0x350
  [<ffffffff810ebdd3>] ? do_brk+0x2b8/0x31a
  [<ffffffff813fff6b>] sys_sendmsg+0x3d/0x5b
  [<ffffffff814cb0f9>] system_call_fastpath+0x16/0x1b
---[ end trace 059af067cdc81b69 ]---
BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
IP: [<ffffffffa019a7fe>] e1000_alloc_rx_buffers+0x5b/0x162 [e1000e]
PGD 0
Oops: 0000 [#1] PREEMPT SMP
CPU 2
Modules linked in: veth 8021q garp stp llc fuse macvlan wanlink(PO) pktgen sbs sbshc f71882fg coretemp hwmon sunrpc ipv6 uinput snd_hda_codec_realtek 
snd_hda_intel ath9k snd_hda_codec mac80211 joydev snd_hwdep snd_seq ath9k_common ath9k_hw snd_seq_device snd_pcm ath snd_timer e1000e snd mei(C) microcode 
cfg80211 ppdev i2c_i801 soundcore serio_raw pcspkr snd_page_alloc iTCO_wdt iTCO_vendor_support parport_pc parport i915 drm_kms_helper drm i2c_algo_bit i2c_core 
video [last unloaded: scsi_wait_scan]

Pid: 140, comm: kworker/2:1 Tainted: P        WC O 3.3.8+ #51 To be filled by O.E.M. To be filled by O.E.M./To be filled by O.E.M.
RIP: 0010:[<ffffffffa019a7fe>]  [<ffffffffa019a7fe>] e1000_alloc_rx_buffers+0x5b/0x162 [e1000e]
RSP: 0018:ffff88021e185cc0  EFLAGS: 00010206
RAX: ffff8802203ae090 RBX: 0000000000000000 RCX: 0000000000000000
RDX: 00000000000000d0 RSI: 00000000000000ff RDI: ffff88021e8a4800
RBP: ffff88021e185d20 R08: ffff88021e184000 R09: ffffffff81a8f658
R10: ffff88021e185be0 R11: ffff88021e185fd8 R12: ffff88021e8a4800
R13: 0000000000000000 R14: ffff88021dda2360 R15: 00000000000000ff
FS:  0000000000000000(0000) GS:ffff88022bd00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000008 CR3: 0000000001a05000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process kworker/2:1 (pid: 140, threadinfo ffff88021e184000, task ffff88021fc0dd00)
Stack:
  0000000000000000 ffffffffa0194ea7 000000d01e185d00 ffff88021e8a4000
  000005f21dda2360 ffff8802203ae090 ffff88021e185d00 ffff88021e8a4800
  ffff88021dda2360 0000000000001000 0000000004008002 ffff88021dda2960
Call Trace:
  [<ffffffffa0194ea7>] ? e1000e_set_rx_mode+0xbc/0x260 [e1000e]
  [<ffffffffa0195a6d>] e1000_configure+0x51c/0x525 [e1000e]
  [<ffffffffa019934c>] ? e1000_set_features+0x8e/0x8e [e1000e]
  [<ffffffffa0195a87>] e1000e_up+0x11/0xbc [e1000e]
  [<ffffffffa01992b1>] e1000e_reinit_locked+0x3f/0x4c [e1000e]
  [<ffffffffa0199a29>] e1000_reset_task+0x6dd/0x6ec [e1000e]
  [<ffffffff81069df7>] ? schedule_work+0x13/0x15
  [<ffffffff81077243>] ? get_parent_ip+0x11/0x42
  [<ffffffff81077243>] ? get_parent_ip+0x11/0x42
  [<ffffffffa019934c>] ? e1000_set_features+0x8e/0x8e [e1000e]
  [<ffffffff8106837e>] process_one_work+0x1a6/0x278
  [<ffffffff8106a3d1>] worker_thread+0x136/0x255
  [<ffffffff8106a29b>] ? manage_workers+0x190/0x190
  [<ffffffff8106da7d>] kthread+0x84/0x8c
  [<ffffffff814cc4a4>] kernel_thread_helper+0x4/0x10
  [<ffffffff8106d9f9>] ? __init_kthread_worker+0x37/0x37
  [<ffffffff814cc4a0>] ? gs_change+0x13/0x13
Code: 00 00 89 45 c4 41 0f b7 5e 18 48 8b 87 a8 04 00 00 41 89 dd 48 05 90 00 00 00 4d 6b ed 28 4d 03 6e 20 48 89 45 c8 e9 ea 00 00 00 <49> 8b 45 08 48 85 c0 74 
14 48 89 c7 31 f6 48 89 45 a8 e8 76 b1
RIP  [<ffffffffa019a7fe>] e1000_alloc_rx_buffers+0x5b/0x162 [e1000e]
  RSP <ffff88021e185cc0>
CR2: 0000000000000008
---[ end trace 059af067cdc81b6a ]---
BUG: unable to handle kernel paging request at fffffffffffffff8
IP: [<ffffffff8106d618>] kthread_data+0xb/0x11
PGD 1a07067 PUD 1a08067 PMD 0
Oops: 0000 [#2] PREEMPT SMP
CPU 2
Modules linked in: veth 8021q garp stp llc fuse macvlan wanlink(PO) pktgen sbs sbshc f71882fg coretemp hwmon sunrpc ipv6 uinput snd_hda_codec_realtek 
snd_hda_intel ath9k snd_hda_codec mac80211 joydev snd_hwdep snd_seq ath9k_common ath9k_hw snd_seq_device snd_pcm ath snd_timer e1000e snd mei(C) microcode 
cfg80211 ppdev i2c_i801 soundcore serio_raw pcspkr snd_page_alloc iTCO_wdt iTCO_vendor_support parport_pc parport i915 drm_kms_helper drm i2c_algo_bit i2c_core 
video [last unloaded: scsi_wait_scan]

Pid: 140, comm: kworker/2:1 Tainted: P      D WC O 3.3.8+ #51 To be filled by O.E.M. To be filled by O.E.M./To be filled by O.E.M.
RIP: 0010:[<ffffffff8106d618>]  [<ffffffff8106d618>] kthread_data+0xb/0x11
RSP: 0018:ffff88021e1858b8  EFLAGS: 00010092
RAX: 0000000000000000 RBX: 0000000000000002 RCX: 0000000000000002
RDX: ffffffff81bee730 RSI: 0000000000000002 RDI: ffff88021fc0dd00
RBP: ffff88021e1858b8 R08: 0000000000000400 R09: ffff88021fc0e0b8
R10: ffff88021e185978 R11: 0000000000000000 R12: ffff88021fc0e0b8
R13: ffff88021e1859b8 R14: 0000000000000002 R15: 0000000000000001
FS:  0000000000000000(0000) GS:ffff88022bd00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: fffffffffffffff8 CR3: 0000000001a05000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process kworker/2:1 (pid: 140, threadinfo ffff88021e184000, task ffff88021fc0dd00)
Stack:
  ffff88021e1858d8 ffffffff81069e8f ffff88021e1858d8 ffff88022bd12340
  ffff88021e185978 ffffffff814c5041 ffff88021e185918 0000000000000246
  ffff88021e184010 ffff88021fc0dd00 ffff88021e185fd8 0000000000012340
Call Trace:
  [<ffffffff81069e8f>] wq_worker_sleeping+0x10/0x8a
  [<ffffffff814c5041>] __schedule+0x17f/0x562
  [<ffffffff814c54c9>] schedule+0x55/0x57
  [<ffffffff81059b09>] do_exit+0x73e/0x742
  [<ffffffff814c73c7>] oops_end+0xba/0xc2
  [<ffffffff8102df05>] no_context+0x25a/0x269
  [<ffffffff8107cee0>] ? load_balance+0x98/0x6b0
  [<ffffffff8102e0db>] __bad_area_nosemaphore+0x1c7/0x1e7
  [<ffffffff8102e109>] bad_area_nosemaphore+0xe/0x10
  [<ffffffff814c902d>] do_page_fault+0x176/0x350
  [<ffffffff81009785>] ? __switch_to+0x1cd/0x37c
  [<ffffffff814c62bc>] ? _raw_spin_unlock_irq+0x2f/0x3a
  [<ffffffff81077243>] ? get_parent_ip+0x11/0x42
  [<ffffffff81077243>] ? get_parent_ip+0x11/0x42
  [<ffffffff814c9382>] ? sub_preempt_count+0x92/0xa5
  [<ffffffff814c6925>] page_fault+0x25/0x30
  [<ffffffffa019a7fe>] ? e1000_alloc_rx_buffers+0x5b/0x162 [e1000e]
  [<ffffffffa0194ea7>] ? e1000e_set_rx_mode+0xbc/0x260 [e1000e]
  [<ffffffffa0195a6d>] e1000_configure+0x51c/0x525 [e1000e]
  [<ffffffffa019934c>] ? e1000_set_features+0x8e/0x8e [e1000e]
  [<ffffffffa0195a87>] e1000e_up+0x11/0xbc [e1000e]
  [<ffffffffa01992b1>] e1000e_reinit_locked+0x3f/0x4c [e1000e]
  [<ffffffffa0199a29>] e1000_reset_task+0x6dd/0x6ec [e1000e]
  [<ffffffff81069df7>] ? schedule_work+0x13/0x15
  [<ffffffff81077243>] ? get_parent_ip+0x11/0x42
  [<ffffffff81077243>] ? get_parent_ip+0x11/0x42
  [<ffffffffa019934c>] ? e1000_set_features+0x8e/0x8e [e1000e]
  [<ffffffff8106837e>] process_one_work+0x1a6/0x278
  [<ffffffff8106a3d1>] worker_thread+0x136/0x255
  [<ffffffff8106a29b>] ? manage_workers+0x190/0x190
  [<ffffffff8106da7d>] kthread+0x84/0x8c
  [<ffffffff814cc4a4>] kernel_thread_helper+0x4/0x10
  [<ffffffff8106d9f9>] ? __init_kthread_worker+0x37/0x37
  [<ffffffff814cc4a0>] ? gs_change+0x13/0x13
Code: ea ff ff ff eb 9d 90 55 65 48 8b 04 25 00 c7 00 00 48 8b 80 60 03 00 00 48 89 e5 8b 40 f0 c9 c3 48 8b 87 60 03 00 00 55 48 89 e5 <48> 8b 40 f8 c9 c3 48 3b 
3d 7b 10 b8 00 55 48 89 e5 75 09 0f bf
RIP  [<ffffffff8106d618>] kthread_data+0xb/0x11
  RSP <ffff88021e1858b8>
CR2: fffffffffffffff8
---[ end trace 059af067cdc81b6b ]---
Fixing recursive fault but reboot is needed!




-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
