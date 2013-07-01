From: Ben Greear <greearb@candelatech.com>
Subject: Re: 3.9.5+:  Crash in tcp_input.c:4810.
Date: Mon, 01 Jul 2013 11:10:40 -0700
Message-ID: <51D1C620.8030007@candelatech.com>
References: <51BF50B3.1080403@candelatech.com> <1371493059.3252.200.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:52085 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753587Ab3GASKm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 14:10:42 -0400
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

Here's some more info on this.  This is from 3.9.8, plus some local patches,
plus the debugging patch below.

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a2f267a..63f7704 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4810,7 +4810,15 @@ restart:
                          int offset = start - TCP_SKB_CB(skb)->seq;
                          int size = TCP_SKB_CB(skb)->end_seq - start;

-                       BUG_ON(offset < 0);
+                       if (WARN_ON(offset < 0)) {
+                               /* We see a crash here (when using BUG_ON) every few days under
+                                * some torture tests.  I'm not sure how to clean this up properly,
+                                * so just return and hope thinks keep muddling through. --Ben
+                                */
+                               printk("offset: %i  start: %i seq: %i size: %i copy: %i\n",
+                                      offset, start, TCP_SKB_CB(skb)->seq, size, copy);
+                               return;
+                       }
                         if (size > 0) {
                                  size = min(copy, size);
                                  if (skb_copy_bits(skb, offset, skb_put(nskb, size), size))

There are some fairly nasty ath9k errors right before this in the logs, but
I am not certain they are the cause since in previous cases where we saw the
tcp_collapse issue I did not these errors.

wiphy1: start_sw_scan: running-other-vifs: 0  running-station-vifs: 138, associated-stations: 128 scanning current channel: 5745 MHz
sta303: authenticate with 4c:60:de:43:ae:d5
sta303: send auth to 4c:60:de:43:ae:d5 (try 1/3)
sta334: 4c:60:de:43:ae:d5 denied authentication (status 1)
sta303: 4c:60:de:43:ae:d5 denied authentication (status 1)
wiphy1: start_sw_scan: running-other-vifs: 0  running-station-vifs: 138, associated-stations: 128 scanning current channel: 5745 MHz
sta330: authenticate with 4c:60:de:43:ae:d5
sta330: send auth to 4c:60:de:43:ae:d5 (try 1/3)
sta323: authenticate with 4c:60:de:43:ae:d5
sta323: send auth to 4c:60:de:43:ae:d5 (try 1/3)
sta316: authenticate with 4c:60:de:43:ae:d5
sta316: send auth to 4c:60:de:43:ae:d5 (try 1/3)
sta316: 4c:60:de:43:ae:d5 denied authentication (status 1)
sta323: 4c:60:de:43:ae:d5 denied authentication (status 1)
sta330: 4c:60:de:43:ae:d5 denied authentication (status 1)
ath: wiphy1: soft tx hang: queue: 2 pending-frames: 124, resetting chip
ath: wiphy1: Pending frames still exist on txq: 2 after drain: 124  axq-depth: 0  ampdu-depth: 0
------------[ cut here ]------------
WARNING: at /home/greearb/git/linux-3.9.dev.y/net/ipv4/tcp_input.c:4813 tcp_collapse+0x289/0x3bf()
Hardware name: To be filled by O.E.M.
Modules linked in: nfsv3 nfs_acl nfsv4 auth_rpcgss nfs fscache nf_nat_ipv4 nf_nat 8021q garp stp mrp llc fuse macvlan wanlink(O) pktgen lockd sunrpc f71882fg 
ath9k ath9k_common ath9k_hw ath e1000e mac80211 snd_hda_codec_realtek coretemp hwmon cfg80211 mperf snd_hda_intel intel_powerclamp snd_hda_codec snd_hwdep 
snd_seq snd_seq_device snd_pcm snd_page_alloc snd_timer snd kvm iTCO_wdt cdc_acm ptp gpio_ich pps_core soundcore iTCO_vendor_support ppdev lpc_ich parport_pc 
pcspkr i2c_i801 microcode serio_raw parport uinput ipv6 i915 video i2c_algo_bit drm_kms_helper drm i2c_core [last unloaded: iptable_nat]
Pid: 10149, comm: btserver Tainted: G        WC O 3.9.8+ #97
Call Trace:
  <IRQ>  [<ffffffff81096291>] warn_slowpath_common+0x85/0x9f
  [<ffffffff810962c5>] warn_slowpath_null+0x1a/0x1c
  [<ffffffff8155af57>] tcp_collapse+0x289/0x3bf
  [<ffffffff8155b806>] tcp_try_rmem_schedule+0x1c7/0x26d
  [<ffffffff8155bb9d>] tcp_data_queue+0x1a9/0xa7e
  [<ffffffff8155efbf>] tcp_rcv_established+0x63b/0x696
  [<ffffffff81566c1f>] tcp_v4_do_rcv+0x1bd/0x37d
  [<ffffffff81568dcf>] tcp_v4_rcv+0x4ed/0x7d7
  [<ffffffff815389c4>] ? nf_hook_slow+0x102/0x113
  [<ffffffff81548f38>] ? xfrm4_policy_check.clone.0+0x4f/0x4f
  [<ffffffff81549054>] ip_local_deliver_finish+0x11c/0x199
  [<ffffffff81548f38>] ? xfrm4_policy_check.clone.0+0x4f/0x4f
  [<ffffffff81548f38>] ? xfrm4_policy_check.clone.0+0x4f/0x4f
  [<ffffffff8154911d>] NF_HOOK.clone.1+0x4c/0x53
  [<ffffffff81549172>] ip_local_deliver+0x4e/0x52
  [<ffffffff81548de2>] ip_rcv_finish+0x2da/0x2f2
  [<ffffffff81548b08>] ? inet_add_protocol+0x48/0x48
  [<ffffffff8154911d>] NF_HOOK.clone.1+0x4c/0x53
  [<ffffffff815493b2>] ip_rcv+0x23c/0x26a
  [<ffffffff8150f80e>] __netif_receive_skb_core+0x4e7/0x558
  [<ffffffff8150f8cd>] __netif_receive_skb+0x4e/0x5e
  [<ffffffff81511ad3>] netif_receive_skb+0x5b/0x90
  [<ffffffffa05a104a>] ? ieee80211_data_to_8023+0x2eb/0x370 [cfg80211]
  [<ffffffff815cab71>] ? _raw_read_unlock+0x24/0x2f
  [<ffffffffa0712a4d>] ieee80211_deliver_skb+0xcd/0x108 [mac80211]
  [<ffffffffa071430d>] ieee80211_rx_handlers+0x1305/0x18c9 [mac80211]
  [<ffffffff8109dce0>] ? local_bh_enable_ip+0xe/0x10
  [<ffffffff810a4cac>] ? del_timer+0x46/0x52
  [<ffffffffa07151cf>] ieee80211_prepare_and_rx_handle+0x8fe/0x96a [mac80211]
  [<ffffffffa07159c4>] ieee80211_rx+0x6e9/0x759 [mac80211]
  [<ffffffff81307762>] ? swiotlb_tbl_unmap_single+0xc4/0xc9
  [<ffffffffa09d7f6f>] ath_rx_tasklet+0xfce/0x10a7 [ath9k]
  [<ffffffffa09d63a1>] ath9k_tasklet+0xf9/0x150 [ath9k]
  [<ffffffff8109d5af>] tasklet_action+0x7d/0xcc
  [<ffffffff8109da08>] __do_softirq+0x114/0x254
  [<ffffffff815caa85>] ? _raw_spin_unlock+0x24/0x2f
  [<ffffffff8109dbda>] irq_exit+0x4b/0xa8
  [<ffffffff815d2f1d>] do_IRQ+0x9d/0xb4
  [<ffffffff815cafed>] common_interrupt+0x6d/0x6d
  <EOI>  [<ffffffff815d13c0>] ? sysret_audit+0x17/0x21
---[ end trace 32d17d795371ef40 ]---
offset: -1459  start: -1146162927 seq: -1146161468 size: 16047 copy: 3576
------------[ cut here ]------------
WARNING: at /home/greearb/git/linux-3.9.dev.y/net/ipv4/tcp_input.c:4813 tcp_collapse+0x289/0x3bf()
Hardware name: To be filled by O.E.M.
Modules linked in: nfsv3 nfs_acl nfsv4 auth_rpcgss nfs fscache nf_nat_ipv4 nf_nat 8021q garp stp mrp llc fuse macvlan wanlink(O) pktgen lockd sunrpc f71882fg 
ath9k ath9k_common ath9k_hw ath e1000e mac80211 snd_hda_codec_realtek coretemp hwmon cfg80211 mperf snd_hda_intel intel_powerclamp snd_hda_codec snd_hwdep 
snd_seq snd_seq_device snd_pcm snd_page_alloc snd_timer snd kvm iTCO_wdt cdc_acm ptp gpio_ich pps_core soundcore iTCO_vendor_support ppdev lpc_ich parport_pc 
pcspkr i2c_i801 microcode serio_raw parport uinput ipv6 i915 video i2c_algo_bit drm_kms_helper drm i2c_core [last unloaded: iptable_nat]
Pid: 10149, comm: btserver Tainted: G        WC O 3.9.8+ #97
Call Trace:
  <IRQ>  [<ffffffff81096291>] warn_slowpath_common+0x85/0x9f
  [<ffffffff810962c5>] warn_slowpath_null+0x1a/0x1c
  [<ffffffff8155af57>] tcp_collapse+0x289/0x3bf
  [<ffffffff8155b806>] tcp_try_rmem_schedule+0x1c7/0x26d
  [<ffffffff8155bfe9>] tcp_data_queue+0x5f5/0xa7e
  [<ffffffff8155efbf>] tcp_rcv_established+0x63b/0x696
  [<ffffffff81566c1f>] tcp_v4_do_rcv+0x1bd/0x37d
  [<ffffffff81568dcf>] tcp_v4_rcv+0x4ed/0x7d7
  [<ffffffff815389c4>] ? nf_hook_slow+0x102/0x113
  [<ffffffff81548f38>] ? xfrm4_policy_check.clone.0+0x4f/0x4f
  [<ffffffff81549054>] ip_local_deliver_finish+0x11c/0x199
  [<ffffffff81548f38>] ? xfrm4_policy_check.clone.0+0x4f/0x4f
  [<ffffffff81548f38>] ? xfrm4_policy_check.clone.0+0x4f/0x4f
  [<ffffffff8154911d>] NF_HOOK.clone.1+0x4c/0x53
  [<ffffffff81549172>] ip_local_deliver+0x4e/0x52
  [<ffffffff81548de2>] ip_rcv_finish+0x2da/0x2f2
  [<ffffffff81548b08>] ? inet_add_protocol+0x48/0x48
  [<ffffffff8154911d>] NF_HOOK.clone.1+0x4c/0x53
  [<ffffffff815493b2>] ip_rcv+0x23c/0x26a
  [<ffffffff8150f80e>] __netif_receive_skb_core+0x4e7/0x558
  [<ffffffff8150f8cd>] __netif_receive_skb+0x4e/0x5e
  [<ffffffff81511ad3>] netif_receive_skb+0x5b/0x90
  [<ffffffffa05a104a>] ? ieee80211_data_to_8023+0x2eb/0x370 [cfg80211]
  [<ffffffff815cab71>] ? _raw_read_unlock+0x24/0x2f
  [<ffffffffa0712a4d>] ieee80211_deliver_skb+0xcd/0x108 [mac80211]
  [<ffffffffa071430d>] ieee80211_rx_handlers+0x1305/0x18c9 [mac80211]
  [<ffffffff810a4cac>] ? del_timer+0x46/0x52
  [<ffffffffa07151cf>] ieee80211_prepare_and_rx_handle+0x8fe/0x96a [mac80211]
  [<ffffffffa07159c4>] ieee80211_rx+0x6e9/0x759 [mac80211]
  [<ffffffff81307762>] ? swiotlb_tbl_unmap_single+0xc4/0xc9
  [<ffffffffa09d7f6f>] ath_rx_tasklet+0xfce/0x10a7 [ath9k]
  [<ffffffffa09d63a1>] ath9k_tasklet+0xf9/0x150 [ath9k]
  [<ffffffff8109d5af>] tasklet_action+0x7d/0xcc
  [<ffffffff8109da08>] __do_softirq+0x114/0x254
  [<ffffffff815caa85>] ? _raw_spin_unlock+0x24/0x2f
  [<ffffffff8109dbda>] irq_exit+0x4b/0xa8
  [<ffffffff815d2f1d>] do_IRQ+0x9d/0xb4
  [<ffffffff815cafed>] common_interrupt+0x6d/0x6d
  <EOI>  [<ffffffff815d13c0>] ? sysret_audit+0x17/0x21
---[ end trace 32d17d795371ef41 ]---
offset: -1459  start: -1146162927 seq: -1146161468 size: 16047 copy: 3576
...

There were 80 total splats of this nature grouped together, and then
the system recovered and continue to function normally as far as I
can tell.  The later splats are a bit farther apart...maybe the
TCP connection is dying.

It appears my 'work-around' is poor at best, but I'd rather kill
a TCP connection and spam the logs than crash the OS.

I'd be more than happy to add more/different debugging code.

We will also attempt to run the same test on an un-patched upstream
kernel in case the bug is in local patches.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
