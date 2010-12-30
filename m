From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-2.6] bridge: fix br_multicast_ipv6_rcv for paged
 skbs
Date: Thu, 30 Dec 2010 10:46:56 -0800
Message-ID: <20101230104656.6c5a4b4e@nehalam>
References: <AANLkTi=XQ2DE==ggJHfokUE1=opDVOFxQNeqwY1xZN_8@mail.gmail.com>
	<1293708753-17728-1-git-send-email-tomas.winkler@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	Johannes Berg <johannes@sipsolutions.net>
To: Tomas Winkler <tomas.winkler@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43740 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754051Ab0L3SrA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Dec 2010 13:47:00 -0500
In-Reply-To: <1293708753-17728-1-git-send-email-tomas.winkler@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 30 Dec 2010 13:32:33 +0200
Tomas Winkler <tomas.winkler@intel.com> wrote:

> use pskb_may_pull to access header correctly for paged skbs
> 
> the pskb_may_pull ideom is used ipv6 heder parsing
> but omitted int the bridge code
> 
> this fixes bug https://bugzilla.kernel.org/show_bug.cgi?id=25202
> 
> Dec 15 14:36:40 User-PC hostapd: wlan0: STA 00:15:00:60:5d:34 IEEE 802.11: authenticated
> Dec 15 14:36:40 User-PC hostapd: wlan0: STA 00:15:00:60:5d:34 IEEE 802.11: associated (aid 2)
> Dec 15 14:36:40 User-PC hostapd: wlan0: STA 00:15:00:60:5d:34 RADIUS: starting accounting session 4D0608A3-00000005
> Dec 15 14:36:41 User-PC kernel: [175576.120287] ------------[ cut here ]------------
> Dec 15 14:36:41 User-PC kernel: [175576.120452] kernel BUG at include/linux/skbuff.h:1178!
> Dec 15 14:36:41 User-PC kernel: [175576.120609] invalid opcode: 0000 [#1] SMP
> Dec 15 14:36:41 User-PC kernel: [175576.120749] last sysfs file: /sys/devices/pci0000:00/0000:00:1f.2/host0/target0:0:0/0:0:0:0/block/sda/uevent
> Dec 15 14:36:41 User-PC kernel: [175576.121035] Modules linked in: oprofile binfmt_misc bridge stp llc parport_pc ppdev arc4 iwlagn snd_hda_codec_realtek iwlcore i915 snd_hda_intel mac80211 joydev snd_hda_codec snd_hwdep snd_pcm snd_seq_midi drm_kms_helper snd_rawmidi drm snd_seq_midi_event snd_seq snd_timer snd_seq_device cfg80211 eeepc_wmi usbhid psmouse intel_agp i2c_algo_bit intel_gtt uvcvideo agpgart videodev sparse_keymap snd shpchp v4l1_compat lp hid video serio_raw soundcore output snd_page_alloc ahci libahci atl1c
> Dec 15 14:36:41 User-PC kernel: [175576.122712]
> Dec 15 14:36:41 User-PC kernel: [175576.122769] Pid: 0, comm: kworker/0:0 Tainted: G        W   2.6.37-rc5-wl+ #3 1015PE/1016P
> Dec 15 14:36:41 User-PC kernel: [175576.123012] EIP: 0060:[<f83edd65>] EFLAGS: 00010283 CPU: 1
> Dec 15 14:36:41 User-PC kernel: [175576.123193] EIP is at br_multicast_rcv+0xc95/0xe1c [bridge]
> Dec 15 14:36:41 User-PC kernel: [175576.123362] EAX: 0000001c EBX: f5626318 ECX: 00000000 EDX: 00000000
> Dec 15 14:36:41 User-PC kernel: [175576.123550] ESI: ec512262 EDI: f5626180 EBP: f60b5ca0 ESP: f60b5bd8
> Dec 15 14:36:41 User-PC kernel: [175576.123737]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
> Dec 15 14:36:41 User-PC kernel: [175576.123902] Process kworker/0:0 (pid: 0, ti=f60b4000 task=f60a8000 task.ti=f60b0000)
> Dec 15 14:36:41 User-PC kernel: [175576.124137] Stack:
> Dec 15 14:36:41 User-PC kernel: [175576.124181]  ec556500 f6d06800 f60b5be8 c01087d8 ec512262 00000030 00000024 f5626180
> Dec 15 14:36:41 User-PC kernel: [175576.124181]  f572c200 ef463440 f5626300 3affffff f6d06dd0 e60766a4 000000c4 f6d06860
> Dec 15 14:36:41 User-PC kernel: [175576.124181]  ffffffff ec55652c 00000001 f6d06844 f60b5c64 c0138264 c016e451 c013e47d
> Dec 15 14:36:41 User-PC kernel: [175576.124181] Call Trace:
> Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c01087d8>] ? sched_clock+0x8/0x10
> Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c0138264>] ? enqueue_entity+0x174/0x440
> Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c016e451>] ? sched_clock_cpu+0x131/0x190
> Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c013e47d>] ? select_task_rq_fair+0x2ad/0x730
> Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c0524fc1>] ? nf_iterate+0x71/0x90
> Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<f83e4914>] ? br_handle_frame_finish+0x184/0x220 [bridge]
> Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<f83e4790>] ? br_handle_frame_finish+0x0/0x220 [bridge]
> Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<f83e46e9>] ? br_handle_frame+0x189/0x230 [bridge]
> Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<f83e4790>] ? br_handle_frame_finish+0x0/0x220 [bridge]
> Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<f83e4560>] ? br_handle_frame+0x0/0x230 [bridge]
> Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c04ff026>] ? __netif_receive_skb+0x1b6/0x5b0
> Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c04f7a30>] ? skb_copy_bits+0x110/0x210
> Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c0503a7f>] ? netif_receive_skb+0x6f/0x80
> Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<f82cb74c>] ? ieee80211_deliver_skb+0x8c/0x1a0 [mac80211]
> Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<f82cc836>] ? ieee80211_rx_handlers+0xeb6/0x1aa0 [mac80211]
> Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c04ff1f0>] ? __netif_receive_skb+0x380/0x5b0
> Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c016e242>] ? sched_clock_local+0xb2/0x190
> Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c012b688>] ? default_spin_lock_flags+0x8/0x10
> Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c05d83df>] ? _raw_spin_lock_irqsave+0x2f/0x50
> Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<f82cd621>] ? ieee80211_prepare_and_rx_handle+0x201/0xa90 [mac80211]
> Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<f82ce154>] ? ieee80211_rx+0x2a4/0x830 [mac80211]
> Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<f815a8d6>] ? iwl_update_stats+0xa6/0x2a0 [iwlcore]
> Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<f8499212>] ? iwlagn_rx_reply_rx+0x292/0x3b0 [iwlagn]
> Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c05d83df>] ? _raw_spin_lock_irqsave+0x2f/0x50
> Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<f8483697>] ? iwl_rx_handle+0xe7/0x350 [iwlagn]
> Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<f8486ab7>] ? iwl_irq_tasklet+0xf7/0x5c0 [iwlagn]
> Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c01aece1>] ? __rcu_process_callbacks+0x201/0x2d0
> Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c0150d05>] ? tasklet_action+0xc5/0x100
> Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c0150a07>] ? __do_softirq+0x97/0x1d0
> Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c05d910c>] ? nmi_stack_correct+0x2f/0x34
> Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c0150970>] ? __do_softirq+0x0/0x1d0
> Dec 15 14:36:41 User-PC kernel: [175576.124181]  <IRQ>
> Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c01508f5>] ? irq_exit+0x65/0x70
> Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c05df062>] ? do_IRQ+0x52/0xc0
> Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c01036b0>] ? common_interrupt+0x30/0x38
> Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c03a1fc2>] ? intel_idle+0xc2/0x160
> Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c04daebb>] ? cpuidle_idle_call+0x6b/0x100
> Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c0101dea>] ? cpu_idle+0x8a/0xf0
> Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c05d2702>] ? start_secondary+0x1e8/0x1ee
> 
> Cc:YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Cc: Johannes Berg <johannes@sipsolutions.net>
> Signed-off-by: Tomas Winkler <tomas.winkler@intel.com>
> ---
>  net/bridge/br_multicast.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
> index f19e347..074c478 100644
> --- a/net/bridge/br_multicast.c
> +++ b/net/bridge/br_multicast.c
> @@ -1464,6 +1464,10 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
>  	if (offset < 0 || nexthdr != IPPROTO_ICMPV6)
>  		return 0;
>  
> +	if (!pskb_may_pull(skb,
> +		(skb_network_header(skb) + offset + 1 - skb->data))) 
> +                        return 0;
> +
>  	/* Okay, we found ICMPv6 header */
>  	skb2 = skb_clone(skb, GFP_ATOMIC);
>  	if (!skb2)

This doesn't look correct. The calculation of the offset doesn't look correct.
Just following the skb_clone(), the skb_pull value is "offset".
Also, the other checks return -EINVAL for incorrectly formed packet.

--- a/net/bridge/br_multicast.c	2010-12-30 10:29:58.579510488 -0800
+++ b/net/bridge/br_multicast.c	2010-12-30 10:43:27.273386691 -0800
@@ -1464,6 +1464,9 @@ static int br_multicast_ipv6_rcv(struct
 	if (offset < 0 || nexthdr != IPPROTO_ICMPV6)
 		return 0;
 
+	if (!pskb_may_pull(skb, offset))
+		return -EINVAL;
+
 	/* Okay, we found ICMPv6 header */
 	skb2 = skb_clone(skb, GFP_ATOMIC);
 	if (!skb2)



-- 
