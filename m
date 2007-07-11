From: "Daniel J Blueman" <daniel.blueman@gmail.com>
Subject: Re: sky2 hangs without any messages
Date: Wed, 11 Jul 2007 11:15:20 +0100
Message-ID: <6278d2220707110315h55b69c69r66420377afa703da@mail.gmail.com>
References: <6278d2220707020315q7c3df1cci5c7bb52316ad6081@mail.gmail.com>
	 <20070703123546.5d41410b@freepuppy.localdomain.hemminger.net>
	 <6278d2220707031402o7b13e45egc564076a1114b6f5@mail.gmail.com>
	 <6278d2220707050609s3579915bo50cf259ba73712f4@mail.gmail.com>
	 <20070705101046.542c1f8e@freepuppy.localdomain.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Linux Netdev" <netdev@vger.kernel.org>
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.236]:44023 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755974AbXGKKPW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 06:15:22 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1515245wxd
        for <netdev@vger.kernel.org>; Wed, 11 Jul 2007 03:15:21 -0700 (PDT)
In-Reply-To: <20070705101046.542c1f8e@freepuppy.localdomain.hemminger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/07/07, Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> Well, it didn't fix my test, but it made it better.  The following seemed
> to work longer...
>
> --- a/drivers/net/sky2.c        2007-07-05 09:09:45.000000000 -0700
> +++ b/drivers/net/sky2.c        2007-07-05 09:09:51.000000000 -0700
> @@ -2490,6 +2490,13 @@ static int sky2_poll(struct net_device *
>
>         work_done = sky2_status_intr(hw, work_limit);
>         if (work_done < work_limit) {
> +               /* Bug/Errata workaround?
> +                * Need to kick the TX irq moderation timer.
> +                */
> +               if (sky2_read8(hw, STAT_TX_TIMER_CTRL) == TIM_START) {
> +                       sky2_write8(hw, STAT_TX_TIMER_CTRL, TIM_STOP);
> +                       sky2_write8(hw, STAT_TX_TIMER_CTRL, TIM_START);
> +               }
>                 netif_rx_complete(dev0);
>
>                 /* end of interrupt, re-enables also acts as I/O synchronization */

I spoke too soon on this. With the above patch on 2.6.22-rc7, it
failed much sooner than the previous patch with the
read32(B0_Y2_SP_LISR); I'll try to reproduce with the older patch.

Note the ifconfig error/dropped/frame count at the time of failure:

# ethtool -g lan0
Ring parameters for lan0:
Pre-set maximums:
RX:             168
RX Mini:        0
RX Jumbo:       0
TX:             511
Current hardware settings:
RX:             168
RX Mini:        0
RX Jumbo:       0
TX:             511

# ethtool -a lan0
Pause parameters for lan0:
Autonegotiate:  on
RX:             on
TX:             on

# ethtool -c lan0
Coalesce parameters for lan0:
Adaptive RX: off  TX: off
stats-block-usecs: 0
sample-interval: 0
pkt-rate-low: 0
pkt-rate-high: 0

rx-usecs: 100
rx-frames: 16
rx-usecs-irq: 20
rx-frames-irq: 16

tx-usecs: 1000
tx-frames: 10
tx-usecs-irq: 0
tx-frames-irq: 0

rx-usecs-low: 0
rx-frame-low: 0
tx-usecs-low: 0
tx-frame-low: 0

rx-usecs-high: 0
rx-frame-high: 0
tx-usecs-high: 0
tx-frame-high: 0

# ethtool -k lan0
Offload parameters for lan0:
Cannot get device udp large send offload settings: Operation not supported
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: on
udp fragmentation offload: off
generic segmentation offload: off

# ethtool -S lan0
NIC statistics:
     tx_bytes: 2624901638
     rx_bytes: 125131827
     tx_broadcast: 177
     rx_broadcast: 245
     tx_multicast: 0
     rx_multicast: 0
     tx_unicast: 1818345
     rx_unicast: 973657
     tx_mac_pause: 0
     rx_mac_pause: 0
     collisions: 0
     late_collision: 0
     aborted: 0
     single_collisions: 0
     multi_collisions: 0
     rx_short: 0
     rx_runt: 0
     rx_64_byte_packets: 2475
     rx_65_to_127_byte_packets: 891841
     rx_128_to_255_byte_packets: 3748
     rx_256_to_511_byte_packets: 42082
     rx_512_to_1023_byte_packets: 3133
     rx_1024_to_1518_byte_packets: 30623
     rx_1518_to_max_byte_packets: 0
     rx_too_long: 0
     rx_fifo_overflow: 0
     rx_jabber: 0
     rx_fcs_error: 0
     tx_64_byte_packets: 1429
     tx_65_to_127_byte_packets: 35881
     tx_128_to_255_byte_packets: 17013
     tx_256_to_511_byte_packets: 25872
     tx_512_to_1023_byte_packets: 30901
     tx_1024_to_1518_byte_packets: 1707426
     tx_1519_to_max_byte_packets: 0
     tx_fifo_underrun: 0

# ifconfig lan0
lan0      Link encap:Ethernet  HWaddr 00:03:2D:05:9C:27
          inet addr:192.168.0.250  Bcast:192.168.0.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:973893 errors:1 dropped:1 overruns:0 frame:1
          TX packets:819179 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:107601061 (102.6 MiB)  TX bytes:2551658362 (2.3 GiB)
          Interrupt:16

# dmesg
...
ACPI: PCI Interrupt 0000:01:00.0[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:01:00.0 to 64
sky2 0000:01:00.0: v1.14 addr 0xdfbfc000 irq 16 Yukon-EC (0xb6) rev 1
sky2 eth1: addr 00:03:2d:05:9c:27
sky2 lan0: enabling interface
sky2 lan0: ram buffer 48K
sky2 lan0: Link is up at 1000 Mbps, full duplex, flow control both
...
lan0: hw csum failure.
 [<b02b707c>] __skb_checksum_complete_head+0x5c/0x60
 [<b02b7088>] __skb_checksum_complete+0x8/0x10
 [<b0313aab>] nf_ip_checksum+0xbb/0x130
 [<b02d8b9c>] udp_error+0x13c/0x1b0
 [<b02ba4cd>] dev_hard_start_xmit+0x1cd/0x230
 [<b02e93c0>] ip_finish_output+0x0/0x260
 [<b02d8a60>] udp_error+0x0/0x1b0
 [<b02d5736>] nf_conntrack_in+0xf6/0x4d0
 [<b02bbe85>] dev_queue_xmit+0x95/0x260
 [<b02eac51>] ip_output+0x141/0x2e0
 [<b02e93c0>] ip_finish_output+0x0/0x260
 [<b02ea20f>] ip_queue_xmit+0x1cf/0x3d0
 [<b02e7cd0>] dst_output+0x0/0x10
 [<b02d33a3>] nf_iterate+0x63/0x90
 [<b02e4fb0>] ip_rcv_finish+0x0/0x280
 [<b02d3519>] nf_hook_slow+0x59/0xe0
 [<b02e4fb0>] ip_rcv_finish+0x0/0x280
 [<b02e5740>] ip_rcv+0x2f0/0x4d0
 [<b02e4fb0>] ip_rcv_finish+0x0/0x280
 [<b0321d56>] packet_rcv_spkt+0xe6/0x180
 [<b02b9f38>] netif_receive_skb+0x1f8/0x2e0
 [<f0840db1>] sky2_poll+0x351/0x9c0 [sky2]
 [<b01206b4>] run_timer_softirq+0x124/0x180
 [<b02bbc6c>] net_rx_action+0x5c/0x100
 [<b011dd62>] __do_softirq+0x42/0x90
 [<b010642c>] do_softirq+0x5c/0xb0
 [<b0139e30>] handle_edge_irq+0x0/0xe0
 [<b011dc8a>] irq_exit+0x5a/0x60
 [<b01064ec>] do_IRQ+0x6c/0xb0
 [<b0104807>] common_interrupt+0x23/0x28
 [<b0420000>] xt_tcpudp_init+0x0/0x10
 [<b0102c9a>] default_idle+0x2a/0x40
 [<b01023d3>] cpu_idle+0x43/0x70
 [<b0404b25>] start_kernel+0x215/0x2a0
 [<b0404450>] unknown_bootoption+0x0/0x260
 =======================

Daniel
-- 
Daniel J Blueman
