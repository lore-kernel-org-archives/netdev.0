From: Ben Greear <greearb@candelatech.com>
Subject: Re: 3.9.5+:  Crash in tcp_input.c:4810.
Date: Fri, 21 Jun 2013 12:26:37 -0700
Message-ID: <51C4A8ED.8010106@candelatech.com>
References: <51BF50B3.1080403@candelatech.com> <1371493059.3252.200.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:47327 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423672Ab3FUT0k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jun 2013 15:26:40 -0400
In-Reply-To: <1371493059.3252.200.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/17/2013 11:17 AM, Eric Dumazet wrote:
> On Mon, 2013-06-17 at 11:08 -0700, Ben Greear wrote:
>> This is from a 3.9.5+ kernel with local patches.  We saw this crash during
>> a weekend run where we had TCP traffic trying to run on 128+ wifi station
>> interfaces as the interfaces assocaited over and over again (the AP
>> could handle no more than 127 stations and would dis-associate others
>> when the 128th tried to associate).
>>
>> The code in question is this from the tcp_collapse() method:
>>
>> 		skb_reserve(nskb, header);
>> 		memcpy(nskb->head, skb->head, header);
>> 		memcpy(nskb->cb, skb->cb, sizeof(skb->cb));
>> 		TCP_SKB_CB(nskb)->seq = TCP_SKB_CB(nskb)->end_seq = start;
>> 		__skb_queue_before(list, skb, nskb);
>> 		skb_set_owner_r(nskb, sk);
>>
>> 		/* Copy data, releasing collapsed skbs. */
>> 		while (copy > 0) {
>> 			int offset = start - TCP_SKB_CB(skb)->seq;
>> 			int size = TCP_SKB_CB(skb)->end_seq - start;
>>
>> 			BUG_ON(offset < 0);


It took about 3 days of running the same torture test (on 3.9.6+ this time),
but we saw this crash again.

No other kernel splats seen before this (at least for several hours).

Since it is rare, maybe we could change it to a WARN_ON, and take whatever
measures are needed to continue running?


------------[ cut here ]------------
kernel BUG at /home/greearb/git/linux-3.9.dev.y/net/ipv4/tcp_input.c:4810!
invalid opcode: 0000 [#1] PREEMPT SMP
Modules linked in: nf_nat_ipv4 nf_nat 8021q garp stp mrp llc fuse macvlan wanlink(O) pktgen lockd sunrpc f71882fg cdc_acm snd_hda_codec_realtek snd_hda_intel 
snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm snd_page_alloc snd_timer snd ath9k soundcore serio_raw gpio_ich pcspkr ath9k_common coretemp hwmon mperf 
intel_powerclamp ath9k_hw ath kvm mac80211 e1000e ptp cfg80211 ppdev iTCO_wdt iTCO_vendor_support parport_pc microcode lpc_ich i2c_i801 pps_core parport uinput 
ipv6 i915 video i2c_algo_bit drm_kms_helper drm i2c_core [last unloaded: iptable_nat]
CPU 3
Pid: 2443, comm: btserver Tainted: G        WC O 3.9.6+ #84 To be filled by O.E.M. To be filled by O.E.M./To be filled by O.E.M.
RIP: 0010:[<ffffffff8155ac89>]  [<ffffffff8155ac89>] tcp_collapse+0x267/0x37a
RSP: 0000:ffff88022bd83608  EFLAGS: 00010287
RAX: 0000000000001100 RBX: ffff8801850fd170 RCX: 0000000000000000
RDX: 00000000fffff4a5 RSI: ffff8801850fd100 RDI: ffff88009ff47700
RBP: ffff88022bd83668 R08: 000000009a632eec R09: ffff880196284428
R10: ffffffffa04047c0 R11: ffff880217f50000 R12: 000000009a62ea89
R13: ffff880196284400 R14: ffff88009ff47700 R15: 0000000000000df0
FS:  00007f74ca9eb740(0000) GS:ffff88022bd80000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000007e4dec8 CR3: 00000002179eb000 CR4: 00000000000007e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process btserver (pid: 2443, threadinfo ffff88021773c000, task ffff88021be6c650)
Stack:
  ffff88022bd83618 ffff8801000000d0 9a636da8fffff4a5 0000000000000000
  ffff8801850fd100 ffff88009ff47728 ffff88022bd83698 ffff8801850fd100
  ffff8801850fd6c8 ffff8801850fd6c8 0000000000000a80 ffff8801007d9400
Call Trace:
  <IRQ>
  [<ffffffff8155b515>] tcp_try_rmem_schedule+0x1c7/0x26d
  [<ffffffff8155b8ac>] tcp_data_queue+0x1a9/0xa7e
  [<ffffffff8155ec95>] tcp_rcv_established+0x63b/0x696
  [<ffffffff815668e7>] tcp_v4_do_rcv+0x1bd/0x37d
  [<ffffffff81568a97>] tcp_v4_rcv+0x4ed/0x7d7
  [<ffffffff81538790>] ? nf_hook_slow+0x102/0x113
  [<ffffffff81548c9c>] ? xfrm4_policy_check.clone.0+0x4f/0x4f
  [<ffffffff81548db8>] ip_local_deliver_finish+0x11c/0x199
  [<ffffffff81548c9c>] ? xfrm4_policy_check.clone.0+0x4f/0x4f
  [<ffffffff81548c9c>] ? xfrm4_policy_check.clone.0+0x4f/0x4f
  [<ffffffff81548e81>] NF_HOOK.clone.1+0x4c/0x53
  [<ffffffff81548ed6>] ip_local_deliver+0x4e/0x52
  [<ffffffff81548b46>] ip_rcv_finish+0x2da/0x2f2
  [<ffffffff8154886c>] ? inet_add_protocol+0x48/0x48
  [<ffffffff81548e81>] NF_HOOK.clone.1+0x4c/0x53
  [<ffffffff81549116>] ip_rcv+0x23c/0x26a
  [<ffffffff8150f632>] __netif_receive_skb_core+0x4e7/0x558
  [<ffffffff8150f6f1>] __netif_receive_skb+0x4e/0x5e
  [<ffffffff815118f7>] netif_receive_skb+0x5b/0x90
  [<ffffffffa027d04a>] ? ieee80211_data_to_8023+0x2eb/0x370 [cfg80211]
  [<ffffffff815ca611>] ? _raw_read_unlock+0x24/0x2f
  [<ffffffffa03cda4d>] ieee80211_deliver_skb+0xcd/0x108 [mac80211]
  [<ffffffffa03cf30d>] ieee80211_rx_handlers+0x1305/0x18c9 [mac80211]
  [<ffffffffa093b66e>] ? ath_txq_schedule+0x762/0x899 [ath9k]
  [<ffffffff81104823>] ? handle_irq_event+0x4c/0x61
  [<ffffffffa03d01cf>] ieee80211_prepare_and_rx_handle+0x8fe/0x96a [mac80211]
  [<ffffffffa03d09c4>] ieee80211_rx+0x6e9/0x759 [mac80211]
  [<ffffffff81307b1c>] ? swiotlb_map_page+0x67/0xbb
  [<ffffffffa0938f83>] ath_rx_tasklet+0xfce/0x10a7 [ath9k]
  [<ffffffffa09373b5>] ath9k_tasklet+0xf9/0x150 [ath9k]
  [<ffffffff8109d6d3>] tasklet_action+0x7d/0xcc
  [<ffffffff8109db2c>] __do_softirq+0x114/0x254
  [<ffffffff815ca525>] ? _raw_spin_unlock+0x24/0x2f
  [<ffffffff8109dcfe>] irq_exit+0x4b/0xa8
  [<ffffffff815d29dd>] do_IRQ+0x9d/0xb4
  [<ffffffff815caaad>] common_interrupt+0x6d/0x6d
  <EOI>
  [<ffffffff815d0e80>] ? sysret_audit+0x17/0x21
Code: 89 30 4d 89 75 08 ff 43 10 48 8b 75 c0 e8 30 d0 ff ff e9 ee 00 00 00 4d 8d 4d 28 44 89 e2 41 2b 51 18 45 8b 41 1c 89 55 b0 79 04 <0f> 0b eb fe 45 29 e0 45 
85 c0 7e 4d 45 39 f8 4c 89 f7 4c 89 4d
RIP  [<ffffffff8155ac89>] tcp_collapse+0x267/0x37a
  RSP <ffff88022bd83608>
---[ end trace 31987c0a8f390662 ]---


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
