From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NUMA and multiQ interation
Date: Tue, 24 Nov 2009 18:36:34 +0100
Message-ID: <4B0C19A2.9040906@gmail.com>
References: <65634d660911240904y294ea6fj4cf2e4ac757e619b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39676 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933618AbZKXRgd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2009 12:36:33 -0500
In-Reply-To: <65634d660911240904y294ea6fj4cf2e4ac757e619b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert a =E9crit :
> This is a question about the expected interaction between NUMA and
> receive multi queue.  Our test setup is a 16 core AMD system with 4
> sockets, one NUMA node per socket and a bnx2x.  The test is running
> 500 streams in netperf RR with response/request of one byte using
> net-next-2.6.
>=20
> Highest throughput we are seeing is with 4 queues (1 queue processed
> per socket) giving 361862 tps at 67% of cpu.  16 queues (1 queue per
> cpu) gives 226722 tps at 30.43% cpu.
>=20
> However, with a modified kernel that does RX skb allocations from
> local node rather than the devices numa node, I'm getting 923422 tps
> at 100% cpu.  This is much higher tps and better cpu utilization than
> the case where allocations are coming from the device numa node.  It
> appears that cross node allocations are a causing a significant
> performance hit.  For a 2.5 times performance improvement I'm kind of
> motivated to revert netdev_alloc_skb to when it did not pay attention
> to numa node :-)
>=20
> What is the expected interaction here, and would these results be
> typical?  If so, would this warrant the need to associate each RX
> queue to a numa node, instead of just the device?
>=20

I believe you answer to your own question Tom.

I always had doubts about forcing RX buffers to be 'close to the device=
'

And RPS clearly shows that the hard work is done on a CPU close to appl=
ication,
so it would make sense to allocate RX buffer on the local node (of cpu =
handling
the RX queue), eg not necessarly on the device numa node.

When packet is transfered from NIC to memory, the NUMA distance is only=
 hit
one time per cache line, no cache needed.

Then, when processing packet by host cpus, we might need many transfert=
s,
because of TCP coalescing and copying to user space.

SLUB/SLAB also pay an extra fee when cross node allocation/deallocation=
 are performed.

Another point to look is the vmalloc() that various drivers use at NIC =
initialization.
module loading is performed with poor NUMA property (forcing all alloca=
tion to one single node)

=46or example, on this IXGBE adapter, all working space (tx queue rings=
) is allocated on node 0,
on my dual node machine.

# grep ixgbe_setup_rx_resources /proc/vmallocinfo=20

0xffffc90006c67000-0xffffc90006c72000   45056 ixgbe_setup_rx_resources+=
0x45/0x1e0 [ixgbe] pages=3D10 vmalloc N0=3D10
0xffffc90006c73000-0xffffc90006c7e000   45056 ixgbe_setup_rx_resources+=
0x45/0x1e0 [ixgbe] pages=3D10 vmalloc N0=3D10
0xffffc90006d02000-0xffffc90006d0d000   45056 ixgbe_setup_rx_resources+=
0x45/0x1e0 [ixgbe] pages=3D10 vmalloc N0=3D10
0xffffc90006d0e000-0xffffc90006d19000   45056 ixgbe_setup_rx_resources+=
0x45/0x1e0 [ixgbe] pages=3D10 vmalloc N0=3D10
0xffffc90006d1a000-0xffffc90006d25000   45056 ixgbe_setup_rx_resources+=
0x45/0x1e0 [ixgbe] pages=3D10 vmalloc N0=3D10
0xffffc90006d26000-0xffffc90006d31000   45056 ixgbe_setup_rx_resources+=
0x45/0x1e0 [ixgbe] pages=3D10 vmalloc N0=3D10
0xffffc90006d32000-0xffffc90006d3d000   45056 ixgbe_setup_rx_resources+=
0x45/0x1e0 [ixgbe] pages=3D10 vmalloc N0=3D10
0xffffc90006d3e000-0xffffc90006d49000   45056 ixgbe_setup_rx_resources+=
0x45/0x1e0 [ixgbe] pages=3D10 vmalloc N0=3D10
0xffffc90006d4a000-0xffffc90006d55000   45056 ixgbe_setup_rx_resources+=
0x45/0x1e0 [ixgbe] pages=3D10 vmalloc N0=3D10
0xffffc90006d56000-0xffffc90006d61000   45056 ixgbe_setup_rx_resources+=
0x45/0x1e0 [ixgbe] pages=3D10 vmalloc N0=3D10
0xffffc90006d62000-0xffffc90006d6d000   45056 ixgbe_setup_rx_resources+=
0x45/0x1e0 [ixgbe] pages=3D10 vmalloc N0=3D10
0xffffc90006d6e000-0xffffc90006d79000   45056 ixgbe_setup_rx_resources+=
0x45/0x1e0 [ixgbe] pages=3D10 vmalloc N0=3D10
0xffffc90006d7a000-0xffffc90006d85000   45056 ixgbe_setup_rx_resources+=
0x45/0x1e0 [ixgbe] pages=3D10 vmalloc N0=3D10
0xffffc90006d86000-0xffffc90006d91000   45056 ixgbe_setup_rx_resources+=
0x45/0x1e0 [ixgbe] pages=3D10 vmalloc N0=3D10
0xffffc90006d92000-0xffffc90006d9d000   45056 ixgbe_setup_rx_resources+=
0x45/0x1e0 [ixgbe] pages=3D10 vmalloc N0=3D10
0xffffc90006d9e000-0xffffc90006da9000   45056 ixgbe_setup_rx_resources+=
0x45/0x1e0 [ixgbe] pages=3D10 vmalloc N0=3D10
0xffffc90006e4a000-0xffffc90006e55000   45056 ixgbe_setup_rx_resources+=
0x45/0x1e0 [ixgbe] pages=3D10 vmalloc N0=3D10
0xffffc90006e56000-0xffffc90006e61000   45056 ixgbe_setup_rx_resources+=
0x45/0x1e0 [ixgbe] pages=3D10 vmalloc N0=3D10
0xffffc90006e62000-0xffffc90006e6d000   45056 ixgbe_setup_rx_resources+=
0x45/0x1e0 [ixgbe] pages=3D10 vmalloc N0=3D10
0xffffc90006e6e000-0xffffc90006e79000   45056 ixgbe_setup_rx_resources+=
0x45/0x1e0 [ixgbe] pages=3D10 vmalloc N0=3D10
0xffffc90006e7a000-0xffffc90006e85000   45056 ixgbe_setup_rx_resources+=
0x45/0x1e0 [ixgbe] pages=3D10 vmalloc N0=3D10
0xffffc90006e86000-0xffffc90006e91000   45056 ixgbe_setup_rx_resources+=
0x45/0x1e0 [ixgbe] pages=3D10 vmalloc N0=3D10
0xffffc90006e92000-0xffffc90006e9d000   45056 ixgbe_setup_rx_resources+=
0x45/0x1e0 [ixgbe] pages=3D10 vmalloc N0=3D10
0xffffc90006e9e000-0xffffc90006ea9000   45056 ixgbe_setup_rx_resources+=
0x45/0x1e0 [ixgbe] pages=3D10 vmalloc N0=3D10
0xffffc90006eaa000-0xffffc90006eb5000   45056 ixgbe_setup_rx_resources+=
0x45/0x1e0 [ixgbe] pages=3D10 vmalloc N0=3D10
0xffffc90006eb6000-0xffffc90006ec1000   45056 ixgbe_setup_rx_resources+=
0x45/0x1e0 [ixgbe] pages=3D10 vmalloc N0=3D10
0xffffc90006ec2000-0xffffc90006ecd000   45056 ixgbe_setup_rx_resources+=
0x45/0x1e0 [ixgbe] pages=3D10 vmalloc N0=3D10
0xffffc90006ece000-0xffffc90006ed9000   45056 ixgbe_setup_rx_resources+=
0x45/0x1e0 [ixgbe] pages=3D10 vmalloc N0=3D10
0xffffc90006eda000-0xffffc90006ee5000   45056 ixgbe_setup_rx_resources+=
0x45/0x1e0 [ixgbe] pages=3D10 vmalloc N0=3D10
0xffffc90006ee6000-0xffffc90006ef1000   45056 ixgbe_setup_rx_resources+=
0x45/0x1e0 [ixgbe] pages=3D10 vmalloc N0=3D10
0xffffc90006ef2000-0xffffc90006efd000   45056 ixgbe_setup_rx_resources+=
0x45/0x1e0 [ixgbe] pages=3D10 vmalloc N0=3D10
0xffffc90006efe000-0xffffc90006f09000   45056 ixgbe_setup_rx_resources+=
0x45/0x1e0 [ixgbe] pages=3D10 vmalloc N0=3D10


alloc_large_system_hash() has better NUMA properties, spreading large h=
ash tables to all nodes.
