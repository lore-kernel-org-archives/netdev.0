From: Ben Greear <greearb@candelatech.com>
Subject: 3.9.5+:  Crash in tcp_input.c:4810.
Date: Mon, 17 Jun 2013 11:08:51 -0700
Message-ID: <51BF50B3.1080403@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:60223 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754793Ab3FQSIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 14:08:53 -0400
Received: from [192.168.100.226] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id r5HI8phO026657
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 17 Jun 2013 11:08:52 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is from a 3.9.5+ kernel with local patches.  We saw this crash during
a weekend run where we had TCP traffic trying to run on 128+ wifi station
interfaces as the interfaces assocaited over and over again (the AP
could handle no more than 127 stations and would dis-associate others
when the 128th tried to associate).

The code in question is this from the tcp_collapse() method:

		skb_reserve(nskb, header);
		memcpy(nskb->head, skb->head, header);
		memcpy(nskb->cb, skb->cb, sizeof(skb->cb));
		TCP_SKB_CB(nskb)->seq = TCP_SKB_CB(nskb)->end_seq = start;
		__skb_queue_before(list, skb, nskb);
		skb_set_owner_r(nskb, sk);

		/* Copy data, releasing collapsed skbs. */
		while (copy > 0) {
			int offset = start - TCP_SKB_CB(skb)->seq;
			int size = TCP_SKB_CB(skb)->end_seq - start;

			BUG_ON(offset < 0);



------------[ cut here ]------------
kernel BUG at /home/greearb/git/linux-3.9.dev.y/net/ipv4/tcp_input.c:4810!
invalid opcode: 0000 [#1] PREEMPT SMP
Modules linked in: nf_nat_ipv4 nf_nat 8021q garp stp mrp llc fuse macvlan wanlink(O) pktgen lockd sunrpc f71882fg e1000e ath9k ath9k_common ath9k_hw ath 
mac80211 snd_hda_codec_realtek coretemp snd_hda_intel hwmon snd_hda_codec snd_hwdep mperf intel_powerclamp snd_seq snd_seq_device snd_pcm cfg80211 ptp pps_core 
snd_page_alloc snd_timer kvm cdc_acm i2c_i801 gpio_ich iTCO_wdt iTCO_vendor_support snd soundcore ppdev microcode pcspkr serio_raw lpc_ich parport_pc parport 
uinput ipv6 i915 video i2c_algo_bit drm_kms_helper drm i2c_core [last unloaded: iptable_nat]
CPU 1
Pid: 0, comm: swapper/1 Tainted: G        WC O 3.9.5+ #80 To be filled by O.E.M. To be filled by O.E.M./To be filled by O.E.M.
RIP: 0010:[<ffffffff8155a9e9>]  [<ffffffff8155a9e9>] tcp_collapse+0x267/0x37a
RSP: 0018:ffff88022bc83608  EFLAGS: 00010297
RAX: 0000000000001100 RBX: ffff8801b8f08730 RCX: 0000000000000000
RDX: 00000000fffffa4d RSI: ffff8801b8f086c0 RDI: ffff880219adbe00
RBP: ffff88022bc83668 R08: 000000009efbe0a8 R09: ffff8801d25eb328
R10: ffffffff8109d762 R11: ffff88021791ff00 R12: 000000009efba1f9
R13: ffff8801d25eb300 R14: ffff880219adbe00 R15: 0000000000000df0
FS:  0000000000000000(0000) GS:ffff88022bc80000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 000000000286f350 CR3: 0000000001a0c000 CR4: 00000000000007e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper/1 (pid: 0, threadinfo ffff880222162000, task ffff88022215ddc0)
Stack:
  ffff88022bc83618 ffff8801000000d0 9efc19bcfffffa4d 0000000000000000
  ffff8801b8f086c0 ffff880219adbe28 ffff88022bc83698 ffff8801b8f086c0
  ffff8801b8f08c88 ffff8801b8f08c88 0000000000000a80 ffff8801c7841d00
Call Trace:
  <IRQ>
  [<ffffffff8155b275>] tcp_try_rmem_schedule+0x1c7/0x26d
  [<ffffffff8155b60c>] tcp_data_queue+0x1a9/0xa7e
  [<ffffffff8155e9f5>] tcp_rcv_established+0x63b/0x696
  [<ffffffff81566647>] tcp_v4_do_rcv+0x1bd/0x37d
  [<ffffffff815687f7>] tcp_v4_rcv+0x4ed/0x7d7
  [<ffffffff815384f0>] ? nf_hook_slow+0x102/0x113
  [<ffffffff815489fc>] ? xfrm4_policy_check.clone.0+0x4f/0x4f
  [<ffffffff81548b18>] ip_local_deliver_finish+0x11c/0x199
  [<ffffffff815489fc>] ? xfrm4_policy_check.clone.0+0x4f/0x4f
  [<ffffffff815489fc>] ? xfrm4_policy_check.clone.0+0x4f/0x4f
  [<ffffffff81548be1>] NF_HOOK.clone.1+0x4c/0x53
  [<ffffffff81548c36>] ip_local_deliver+0x4e/0x52
  [<ffffffff815488a6>] ip_rcv_finish+0x2da/0x2f2
  [<ffffffff815485cc>] ? inet_add_protocol+0x48/0x48
  [<ffffffff81548be1>] NF_HOOK.clone.1+0x4c/0x53
  [<ffffffff81548e76>] ip_rcv+0x23c/0x26a
  [<ffffffff8150f392>] __netif_receive_skb_core+0x4e7/0x558
  [<ffffffff8150f451>] __netif_receive_skb+0x4e/0x5e
  [<ffffffff81511657>] netif_receive_skb+0x5b/0x90
  [<ffffffffa0559fe2>] ? ieee80211_data_to_8023+0x2eb/0x370 [cfg80211]
  [<ffffffff815ca369>] ? _raw_read_unlock+0x24/0x2f
  [<ffffffffa07afa4d>] ieee80211_deliver_skb+0xcd/0x108 [mac80211]
  [<ffffffffa07b130d>] ieee80211_rx_handlers+0x1305/0x18c9 [mac80211]
  [<ffffffffa07b21cf>] ieee80211_prepare_and_rx_handle+0x8fe/0x96a [mac80211]
  [<ffffffffa07b29c4>] ieee80211_rx+0x6e9/0x759 [mac80211]
  [<ffffffff81307afc>] ? swiotlb_map_page+0x67/0xbb
  [<ffffffffa0971f83>] ath_rx_tasklet+0xfce/0x10a7 [ath9k]
  [<ffffffffa09703b5>] ath9k_tasklet+0xf9/0x150 [ath9k]
  [<ffffffff8109d6d3>] tasklet_action+0x7d/0xcc
  [<ffffffff8109db2c>] __do_softirq+0x114/0x254
  [<ffffffff815ca27d>] ? _raw_spin_unlock+0x24/0x2f
  [<ffffffff8109dcfe>] irq_exit+0x4b/0xa8
  [<ffffffff815d271d>] do_IRQ+0x9d/0xb4
  [<ffffffff815ca7ed>] common_interrupt+0x6d/0x6d
  <EOI>
  [<ffffffff810c6b5c>] ? set_next_entity+0x28/0x7e
  [<ffffffff814c74b6>] ? cpuidle_wrap_enter+0x43/0x78
  [<ffffffff814c74af>] ? cpuidle_wrap_enter+0x3c/0x78
  [<ffffffff814c74fb>] cpuidle_enter_tk+0x10/0x12
  [<ffffffff814c6fb5>] cpuidle_enter_state+0x17/0x3f
  [<ffffffff814c7734>] cpuidle_idle_call+0xba/0xfa
  [<ffffffff810177dd>] cpu_idle+0x65/0xb5
  [<ffffffff815c35d3>] start_secondary+0x211/0x213
  [<ffffffff81b34b86>] ? regulator_init_complete+0x62/0x157
Code: 89 30 4d 89 75 08 ff 43 10 48 8b 75 c0 e8 30 d0 ff ff e9 ee 00 00 00 4d 8d 4d 28 44 89 e2 41 2b 51 18 45 8b 41 1c 89 55 b0 79 04 <0f> 0b eb fe 45 29 e0 45 
85 c0 7e 4d 45 39 f8 4c 89 f7 4c 89 4d
RIP  [<ffffffff8155a9e9>] tcp_collapse+0x267/0x37a
  RSP <ffff88022bc83608>
---[ end trace f30d144e49d988df ]---
Kernel panic - not syncing: Fatal exception in interrupt
drm_kms_helper: panic occurred, switching back to text console

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
