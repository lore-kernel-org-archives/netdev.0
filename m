From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: Re: Strange packet drops with heavy firewalling
Date: Mon, 12 Apr 2010 19:06:30 +0200
Message-ID: <1271091990.2858.409.camel@ursa.amorsen.dk>
References: <m339z50x1l.fsf@ursa.amorsen.dk>
	 <q2v40c9f5b21004120116p766df82dj88c6af4e4cad55f@mail.gmail.com>
	 <1271083479.2858.377.camel@ursa.amorsen.dk>
	 <p2x40c9f5b21004120833jd7a749cak6ea69cebd28f8352@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: zhigang gong <zhigang.gong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate1.ipvision.dk ([94.127.49.2]:36779 "EHLO gate1.ipvision.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751515Ab0DLRIe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Apr 2010 13:08:34 -0400
In-Reply-To: <p2x40c9f5b21004120833jd7a749cak6ea69cebd28f8352@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

man, 12 04 2010 kl. 23:33 +0800, skrev zhigang gong:

>  
> Now, I agree with Eric's analysis, there may be some bursts, for
> example a burst of a bunch of first packets for different new flows.
> What mode are you using the ethernet driver in? I guess it's NAPI,
> right?

I presume so.

>  And whether your time consumption workload is handled in soft-irq
> context or in a user space process? 

soft-irq, the box is doing pure iptables. The only time it does a little
bit of user-space work is when I use conntrackd, but killing conntrackd
does not affect the packet loss measurably.

I switched to a 82576-based card, and now I get:

             3341.00 -  4.9% : _spin_lock
             2506.00 -  3.7% : irq_entries_start
             2163.00 -  3.2% : _spin_lock_irqsave
             1616.00 -  2.4% : native_read_tsc
             1572.00 -  2.3% : igb_poll	[igb]
             1386.00 -  2.0% : get_partial_node
             1236.00 -  1.8% : igb_clean_tx_irq	[igb]
             1205.00 -  1.8% : igb_xmit_frame_adv	[igb]
             1170.00 -  1.7% : ipt_do_table
             1049.00 -  1.6% : fget_light
             1015.00 -  1.5% : tick_nohz_stop_sched_tick
              967.00 -  1.4% : fput
              945.00 -  1.4% : __slab_free
              919.00 -  1.4% : datagram_poll
              874.00 -  1.3% : dev_queue_xmit

And it seems the packet loss is gone!

# ethtool -S eth0|fgrep drop
     tx_dropped: 0
     rx_queue_drop_packet_count: 0
     dropped_smbus: 0
     rx_queue_0_drops: 0
     rx_queue_1_drops: 0
     rx_queue_2_drops: 0
     rx_queue_3_drops: 0

I'm a bit surprised by this though:
 
  99:         24    1306226          3          2   PCI-MSI-edge      eth1-tx-0
 100:      15735    1648774          3          7   PCI-MSI-edge      eth1-tx-1
 101:          8         11          9    1083022   PCI-MSI-edge      eth1-tx-2
 102:          0          0          0          0   PCI-MSI-edge      eth1-tx-3
 103:         18         15       6131    1095383   PCI-MSI-edge      eth1-rx-0
 104:        217         32      46544    1335325   PCI-MSI-edge      eth1-rx-1
 105:        154    1305595        218         16   PCI-MSI-edge      eth1-rx-2
 106:         17         16       8229    1467509   PCI-MSI-edge      eth1-rx-3
 107:          0          0          1          0   PCI-MSI-edge      eth1
 108:          2         14         15    1003053   PCI-MSI-edge      eth0-tx-0
 109:       8226    1668924        478        487   PCI-MSI-edge      eth0-tx-1
 110:          3    1188874         17         12   PCI-MSI-edge      eth0-tx-2
 111:          0          0          0          0   PCI-MSI-edge      eth0-tx-3
 112:        203        185       5324    1015263   PCI-MSI-edge      eth0-rx-0
 113:       4141    1600793        153        159   PCI-MSI-edge      eth0-rx-1
 114:      16242    1210108        436       3124   PCI-MSI-edge      eth0-rx-2
 115:        267       4173      19471    1321252   PCI-MSI-edge      eth0-rx-3
 116:          0          1          0          0   PCI-MSI-edge      eth0


irqbalanced seems to have picked CPU1 and CPU3 for all the interrupts,
which to my mind should cause the same problem as before (where CPU1 and
CPU3 was handling all packets). Yet the box clearly works much better
than before.

Anyway, this brings the saga to an end from my point of view. Thank you
very much for looking into this, you and Eric Dumazet have been
invaluable!


/Benny



