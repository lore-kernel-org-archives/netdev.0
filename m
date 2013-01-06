From: Willy Tarreau <w@1wt.eu>
Subject: Re: Major network performance regression in 3.7
Date: Sun, 6 Jan 2013 01:50:53 +0100
Message-ID: <20130106005053.GS16031@1wt.eu>
References: <20130105214958.GA19814@1wt.eu> <1357427926.1678.4771.camel@edumazet-glaptop> <20130105232913.GQ16031@1wt.eu> <1357430523.1678.4901.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1357430523.1678.4901.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 05, 2013 at 04:02:03PM -0800, Eric Dumazet wrote:
> On Sun, 2013-01-06 at 00:29 +0100, Willy Tarreau wrote:
> 
> > > 2) Another possibility would be that Myri card/driver doesnt like very
> > > well high order pages.
> > 
> > It looks like it has not changed much since 3.6 :-/ I really suspect
> > something is wrong with memory allocation. I have tried reverting many
> > patches affecting the mm/ directory just in case but I did not come to
> > anything useful yet.
> > 
> 
> Hmm, I was referring to TCP stack now using order-3 pages instead of
> order-0 ones
> 
> See commit 5640f7685831e088fe6c2e1f863a6805962f8e81
> (net: use a per task frag allocator)

OK, so you think there are two distinct problems ?

I have tried to revert this one but it did not change the performance, I'm
still saturating at ~6.9 Gbps.

> Could you please post :
> 
> ethtool -S eth0

Yes, I've removed all zero counters in this short view for easier
reading (complete version appended at the end of this email). This
was after around 140 GB were transferred :

# ethtool -S eth1|grep -vw 0
NIC statistics:
     rx_packets: 8001500
     tx_packets: 10015409
     rx_bytes: 480115998
     tx_bytes: 148825674976
     tx_boundary: 2048
     WC: 1
     irq: 45
     MSI: 1
     read_dma_bw_MBs: 1200
     write_dma_bw_MBs: 1614
     read_write_dma_bw_MBs: 2101
     serial_number: 320061
     link_changes: 2
     link_up: 1
     tx_pkt_start: 10015409
     tx_pkt_done: 10015409
     tx_req: 93407411
     tx_done: 93407411
     rx_small_cnt: 8001500
     wake_queue: 187727
     stop_queue: 187727
     LRO aggregated: 146
     LRO flushed: 146
     LRO avg aggr: 1
     LRO no_desc: 80

Quite honnestly, this is typically the pattern what I'm used to
observe here. I'm now trying to bisect, hopefully we'll get
something exploitable.

Cheers,
Willy

----- full ethtool -S ----

NIC statistics:
     rx_packets: 8001500
     tx_packets: 10015409
     rx_bytes: 480115998
     tx_bytes: 148825674976
     rx_errors: 0
     tx_errors: 0
     rx_dropped: 0
     tx_dropped: 0
     multicast: 0
     collisions: 0
     rx_length_errors: 0
     rx_over_errors: 0
     rx_crc_errors: 0
     rx_frame_errors: 0
     rx_fifo_errors: 0
     rx_missed_errors: 0
     tx_aborted_errors: 0
     tx_carrier_errors: 0
     tx_fifo_errors: 0
     tx_heartbeat_errors: 0
     tx_window_errors: 0
     tx_boundary: 2048
     WC: 1
     irq: 45
     MSI: 1
     MSIX: 0
     read_dma_bw_MBs: 1200
     write_dma_bw_MBs: 1614
     read_write_dma_bw_MBs: 2101
     serial_number: 320061
     watchdog_resets: 0
     link_changes: 2
     link_up: 1
     dropped_link_overflow: 0
     dropped_link_error_or_filtered: 0
     dropped_pause: 0
     dropped_bad_phy: 0
     dropped_bad_crc32: 0
     dropped_unicast_filtered: 0
     dropped_multicast_filtered: 0
     dropped_runt: 0
     dropped_overrun: 0
     dropped_no_small_buffer: 0
     dropped_no_big_buffer: 0
     ----------- slice ---------: 0
     tx_pkt_start: 10015409
     tx_pkt_done: 10015409
     tx_req: 93407411
     tx_done: 93407411
     rx_small_cnt: 8001500
     rx_big_cnt: 0
     wake_queue: 187727
     stop_queue: 187727
     tx_linearized: 0
     LRO aggregated: 146
     LRO flushed: 146
     LRO avg aggr: 1
     LRO no_desc: 80
