From: John Miller <forall@mail15.com>
Subject: Re: UDP packet loss when running lsof
Date: Tue, 22 May 2007 02:12:59 +0400
Message-ID: <20070522021259.95ukifwz8kc4gccg@www.pochta.ru>
References: <loom.20070521T090409-252@post.gmane.org>
	<20070521113503.6bb70ae4.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=Windows-1251;
	DelSp="Yes";
	format="flowed"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web6.pochta.ru ([81.211.64.26]:30175 "EHLO web6.pochta.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756576AbXEUW03 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2007 18:26:29 -0400
In-Reply-To: <20070521113503.6bb70ae4.dada1@cosmosbay.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric,

> I CCed netdev since this stuff is about network and not
> lkml.

Ok, dropped the CC...

> What kind of machine do you have ? SMP or not ?

It's a HP system with two dual core CPUs at 3GHz, the
storage system is connected through QLogic FC-HBA. It should
really be fast enough to handle a data stream of 50 MB/s...

> If you have many sockets on this machine, lsof can be
> very slow reading /proc/net/tcp and/or /proc/net/udp,
> locking some tables long enough to drop packets.

First I tried with one UDP socket and during tests I switched
to 16 sockets with no effect. As I removed nearly all daemons
there aren't many open sockets.

/proc/net/tcp seems to be one cause of the problem: a simple
"cat /proc/net/tcp" leads nearly allways to immediate UDP packet
loss. So it seems that reading TCP statistics blocks UDP
packet processing.

As it isn't my goal to collect statistics all the time, I could
live with disabling access to /proc/net/tcp, but I wouldn't call
this a good solution...

> If you have a low count of tcp sockets, you might want to
> boot with thash_entries=2048 or so, to reduce tcp hash
> table size.

This did help a lot, I tried thash_entries=10 and now only a
while loop around the "cat ...tcp" triggers packet loss. Tests
are now running and I can say more tomorrow.

Getting information about thash_entries is really hard. Even
finding out the default value: For a system with 2GB RAM
it could be around 100000.

> no RcvbufErrors error as well ?

The kernel is a bit too old (2.6.18). Looking at the patch
from 2.16.18 to 1.6.19 I found that RcvbufErrors is only
increased when InErrors is increased. So my answer would be
yes.

> > - Network card is handled by bnx2 kernel module

> I dont know this NIC, does it support ethtool ?

It is a "Broadcom Corporation NetXtreme II BCM5708S
Gigabit Ethernet (rev 12)", and it seems ethtool is supported.

The output below was captured after packet loss (I don't see
any hints, but maybe you):

> ethtool -S eth0

NIC statistics:
      rx_bytes: 155481467364
      rx_error_bytes: 0
      tx_bytes: 5492161
      tx_error_bytes: 0
      rx_ucast_packets: 18341
      rx_mcast_packets: 137321933
      rx_bcast_packets: 2380
      tx_ucast_packets: 14416
      tx_mcast_packets: 190
      tx_bcast_packets: 8
      tx_mac_errors: 0
      tx_carrier_errors: 0
      rx_crc_errors: 0
      rx_align_errors: 0
      tx_single_collisions: 0
      tx_multi_collisions: 0
      tx_deferred: 0
      tx_excess_collisions: 0
      tx_late_collisions: 0
      tx_total_collisions: 0
      rx_fragments: 0
      rx_jabbers: 0
      rx_undersize_packets: 0
      rx_oversize_packets: 0
      rx_64_byte_packets: 244575
      rx_65_to_127_byte_packets: 6828
      rx_128_to_255_byte_packets: 167
      rx_256_to_511_byte_packets: 94
      rx_512_to_1023_byte_packets: 393
      rx_1024_to_1522_byte_packets: 137090597
      rx_1523_to_9022_byte_packets: 0
      tx_64_byte_packets: 52
      tx_65_to_127_byte_packets: 7547
      tx_128_to_255_byte_packets: 3304
      tx_256_to_511_byte_packets: 399
      tx_512_to_1023_byte_packets: 897
      tx_1024_to_1522_byte_packets: 2415
      tx_1523_to_9022_byte_packets: 0
      rx_xon_frames: 0
      rx_xoff_frames: 0
      tx_xon_frames: 0
      tx_xoff_frames: 0
      rx_mac_ctrl_frames: 0
      rx_filtered_packets: 158816
      rx_discards: 0
      rx_fw_discards: 0

> ethtool -c eth0

Coalesce parameters for eth1:
Adaptive RX: off  TX: off
stats-block-usecs: 999936
sample-interval: 0
pkt-rate-low: 0
pkt-rate-high: 0

rx-usecs: 18
rx-frames: 6
rx-usecs-irq: 18
rx-frames-irq: 6

tx-usecs: 80
tx-frames: 20
tx-usecs-irq: 80
tx-frames-irq: 20

rx-usecs-low: 0
rx-frame-low: 0
tx-usecs-low: 0
tx-frame-low: 0

rx-usecs-high: 0
rx-frame-high: 0
tx-usecs-high: 0
tx-frame-high: 0

> ethtool -g eth0

Ring parameters for eth1:
Pre-set maximums:
RX:             1020
RX Mini:        0
RX Jumbo:       0
TX:             255
Current hardware settings:
RX:             100
RX Mini:        0
RX Jumbo:       0
TX:             255

> Just to make sure, does your application setup a huge
> enough SO_RCVBUF val?

Yes, my first try with one socket was 5MB, but I also tested
with 10 and even 25MB. With 16 sockets I also set it to 5MB.
When pausing the application netstat shows the filled buffers.

> What values do you have in /proc/sys/net/ipv4/tcp_rmem ?

I kept the default values there:
4096    43689   87378

> cat /proc/meminfo

MemTotal:      2060664 kB
MemFree:        146536 kB
Buffers:         10984 kB
Cached:        1667740 kB
SwapCached:          0 kB
Active:         255228 kB
Inactive:      1536352 kB
HighTotal:           0 kB
HighFree:            0 kB
LowTotal:      2060664 kB
LowFree:        146536 kB
SwapTotal:           0 kB
SwapFree:            0 kB
Dirty:          820740 kB
Writeback:         112 kB
Mapped:         127612 kB
Slab:           104184 kB
CommitLimit:   1030332 kB
Committed_AS:   774944 kB
PageTables:       1928 kB
VmallocTotal: 34359738367 kB
VmallocUsed:      6924 kB
VmallocChunk: 34359731259 kB
HugePages_Total:     0
HugePages_Free:      0
HugePages_Rsvd:      0
Hugepagesize:     2048 kB

Thanks for your help!
Regards,
John



