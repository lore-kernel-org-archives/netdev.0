From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: UDP packet loss when running lsof
Date: Tue, 22 May 2007 08:10:59 +0200
Message-ID: <46528973.50809@cosmosbay.com>
References: <loom.20070521T090409-252@post.gmane.org>	<20070521113503.6bb70ae4.dada1@cosmosbay.com> <20070522021259.95ukifwz8kc4gccg@www.pochta.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: John Miller <forall@mail15.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:55828 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756652AbXEVGLJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2007 02:11:09 -0400
In-Reply-To: <20070522021259.95ukifwz8kc4gccg@www.pochta.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John Miller a =C3=A9crit :
> Hi Eric,
>=20
>> I CCed netdev since this stuff is about network and not
>> lkml.
>=20
> Ok, dropped the CC...
>=20
>> What kind of machine do you have ? SMP or not ?
>=20
> It's a HP system with two dual core CPUs at 3GHz, the
> storage system is connected through QLogic FC-HBA. It should
> really be fast enough to handle a data stream of 50 MB/s...

Then you might try to bind network IRQ to one CPU
(echo 1 >/proc/irq/XX/smp_affinity)

XX being your NIC interrupt (cat /proc/interrupts to catch it)

and bind your user program to another cpu(s)

You might hit a cond_resched_softirq() bug that Ingo and others are sor=
ting=20
out right now. Using separate CPU for softirq handling and your program=
s=20
should help a lot here.

>=20
>> If you have many sockets on this machine, lsof can be
>> very slow reading /proc/net/tcp and/or /proc/net/udp,
>> locking some tables long enough to drop packets.
>=20
> First I tried with one UDP socket and during tests I switched
> to 16 sockets with no effect. As I removed nearly all daemons
> there aren't many open sockets.
>=20
> /proc/net/tcp seems to be one cause of the problem: a simple
> "cat /proc/net/tcp" leads nearly allways to immediate UDP packet
> loss. So it seems that reading TCP statistics blocks UDP
> packet processing.
>=20
> As it isn't my goal to collect statistics all the time, I could
> live with disabling access to /proc/net/tcp, but I wouldn't call
> this a good solution...
>=20
>> If you have a low count of tcp sockets, you might want to
>> boot with thash_entries=3D2048 or so, to reduce tcp hash
>> table size.
>=20
> This did help a lot, I tried thash_entries=3D10 and now only a
> while loop around the "cat ...tcp" triggers packet loss. Tests
> are now running and I can say more tomorrow.

I dont understand here : using a small thash_entries makes the bug alwa=
ys appear ?

>=20
> Getting information about thash_entries is really hard. Even
> finding out the default value: For a system with 2GB RAM
> it could be around 100000.
>=20
>> no RcvbufErrors error as well ?
>=20
> The kernel is a bit too old (2.6.18). Looking at the patch
> from 2.16.18 to 1.6.19 I found that RcvbufErrors is only
> increased when InErrors is increased. So my answer would be
> yes.
>=20
>> > - Network card is handled by bnx2 kernel module
>=20
>> I dont know this NIC, does it support ethtool ?
>=20
> It is a "Broadcom Corporation NetXtreme II BCM5708S
> Gigabit Ethernet (rev 12)", and it seems ethtool is supported.
>=20
> The output below was captured after packet loss (I don't see
> any hints, but maybe you):
>=20
>> ethtool -S eth0
>=20
> NIC statistics:
>      rx_bytes: 155481467364
>      rx_error_bytes: 0
>      tx_bytes: 5492161
>      tx_error_bytes: 0
>      rx_ucast_packets: 18341
>      rx_mcast_packets: 137321933
>      rx_bcast_packets: 2380
>      tx_ucast_packets: 14416
>      tx_mcast_packets: 190
>      tx_bcast_packets: 8
>      tx_mac_errors: 0
>      tx_carrier_errors: 0
>      rx_crc_errors: 0
>      rx_align_errors: 0
>      tx_single_collisions: 0
>      tx_multi_collisions: 0
>      tx_deferred: 0
>      tx_excess_collisions: 0
>      tx_late_collisions: 0
>      tx_total_collisions: 0
>      rx_fragments: 0
>      rx_jabbers: 0
>      rx_undersize_packets: 0
>      rx_oversize_packets: 0
>      rx_64_byte_packets: 244575
>      rx_65_to_127_byte_packets: 6828
>      rx_128_to_255_byte_packets: 167
>      rx_256_to_511_byte_packets: 94
>      rx_512_to_1023_byte_packets: 393
>      rx_1024_to_1522_byte_packets: 137090597
>      rx_1523_to_9022_byte_packets: 0
>      tx_64_byte_packets: 52
>      tx_65_to_127_byte_packets: 7547
>      tx_128_to_255_byte_packets: 3304
>      tx_256_to_511_byte_packets: 399
>      tx_512_to_1023_byte_packets: 897
>      tx_1024_to_1522_byte_packets: 2415
>      tx_1523_to_9022_byte_packets: 0
>      rx_xon_frames: 0
>      rx_xoff_frames: 0
>      tx_xon_frames: 0
>      tx_xoff_frames: 0
>      rx_mac_ctrl_frames: 0
>      rx_filtered_packets: 158816
>      rx_discards: 0
>      rx_fw_discards: 0
>=20
>> ethtool -c eth0
>=20
> Coalesce parameters for eth1:
> Adaptive RX: off  TX: off
> stats-block-usecs: 999936
> sample-interval: 0
> pkt-rate-low: 0
> pkt-rate-high: 0
>=20
> rx-usecs: 18
> rx-frames: 6
> rx-usecs-irq: 18
> rx-frames-irq: 6
>=20
> tx-usecs: 80
> tx-frames: 20
> tx-usecs-irq: 80
> tx-frames-irq: 20
>=20
> rx-usecs-low: 0
> rx-frame-low: 0
> tx-usecs-low: 0
> tx-frame-low: 0
>=20
> rx-usecs-high: 0
> rx-frame-high: 0
> tx-usecs-high: 0
> tx-frame-high: 0
>=20
>> ethtool -g eth0
>=20
> Ring parameters for eth1:
> Pre-set maximums:
> RX:             1020
> RX Mini:        0
> RX Jumbo:       0
> TX:             255
> Current hardware settings:
> RX:             100
> RX Mini:        0
> RX Jumbo:       0
> TX:             255
>=20
>> Just to make sure, does your application setup a huge
>> enough SO_RCVBUF val?
>=20
> Yes, my first try with one socket was 5MB, but I also tested
> with 10 and even 25MB. With 16 sockets I also set it to 5MB.
> When pausing the application netstat shows the filled buffers.
>=20
>> What values do you have in /proc/sys/net/ipv4/tcp_rmem ?
>=20
> I kept the default values there:
> 4096    43689   87378
>=20
>> cat /proc/meminfo
>=20
> MemTotal:      2060664 kB
> MemFree:        146536 kB
> Buffers:         10984 kB
> Cached:        1667740 kB
> SwapCached:          0 kB
> Active:         255228 kB
> Inactive:      1536352 kB
> HighTotal:           0 kB
> HighFree:            0 kB
> LowTotal:      2060664 kB
> LowFree:        146536 kB
> SwapTotal:           0 kB
> SwapFree:            0 kB
> Dirty:          820740 kB
> Writeback:         112 kB
> Mapped:         127612 kB
> Slab:           104184 kB
> CommitLimit:   1030332 kB
> Committed_AS:   774944 kB
> PageTables:       1928 kB
> VmallocTotal: 34359738367 kB
> VmallocUsed:      6924 kB
> VmallocChunk: 34359731259 kB
> HugePages_Total:     0
> HugePages_Free:      0
> HugePages_Rsvd:      0
> Hugepagesize:     2048 kB
>=20
> Thanks for your help!
> Regards,
> John
>=20
>=20

