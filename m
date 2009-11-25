From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] irq: Add node_affinity CPU masks for smarter irqbalance
 hints
Date: Wed, 25 Nov 2009 11:30:26 +0100
Message-ID: <4B0D0742.2050301@gmail.com>
References: <20091124.093956.247147202.davem@davemloft.net>	<1259085412.2631.48.camel@ppwaskie-mobl2> <4B0C2547.8030408@gmail.com>	<20091124.105442.06273019.davem@davemloft.net>	<4B0C2CCA.6030006@gmail.com> <87iqczwtia.fsf@basil.nowhere.org> <4B0C4624.9080607@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	peter.p.waskiewicz.jr@intel.com, peterz@infradead.org,
	arjan@linux.intel.com, yong.zhang0@gmail.com,
	linux-kernel@vger.kernel.org, arjan@linux.jf.intel.com,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758688AbZKYKal@vger.kernel.org>
In-Reply-To: <4B0C4624.9080607@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet a =E9crit :
> Andi Kleen a =E9crit :
>> They are typically allocated with dma_alloc_coherent(), which does
>> allocate a continuous area.  In theory you could do interleaving
>> with IOMMus, but just putting it on the same node as the device
>> is probably better.
>=20
> There are two parts, biggest one allocated with vmalloc()
> (to hold struct ixgbe_rx_buffer array, 32 bytes or more per entry),
> only used by driver (not adapter)
>=20
> and one allocated with pci_alloc_consistent()=20
> (to hold ixgbe_adv_tx_desc array, 16 bytes per entry)
>=20
> vmalloc() one could be spreaded on many nodes.
> I am not speaking about the pci_alloc_consistent() one :)
>=20

BTW, I found my Nehalem dev machine behaves strangly, defeating all
my NUMA tweaks. (This is an HP DL380 G6)

It has two sockets, populated with two E5530 @2.4GH.

Each cpu has 2x4GB RAM modules.

It claims having two memory nodes, but all cpus are on Node 0

dmesg | grep -i node
[    0.000000] SRAT: PXM 0 -> APIC 0 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 1 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 2 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 3 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 4 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 5 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 6 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 7 -> Node 0
[    0.000000] SRAT: Node 0 PXM 0 0-e0000000
[    0.000000] SRAT: Node 0 PXM 0 100000000-220000000
[    0.000000] SRAT: Node 1 PXM 1 220000000-420000000
[    0.000000] Bootmem setup node 0 0000000000000000-0000000220000000
[    0.000000]   NODE_DATA [0000000000001000 - 0000000000004fff]
[    0.000000] Bootmem setup node 1 0000000220000000-000000041ffff000
[    0.000000]   NODE_DATA [0000000220000000 - 0000000220003fff]
[    0.000000]  [ffffea0000000000-ffffea00087fffff] PMD -> [ffff8800286=
00000-ffff8800305fffff] on node 0
[    0.000000]  [ffffea0008800000-ffffea00107fffff] PMD -> [ffff8802202=
00000-ffff8802281fffff] on node 1
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[5] active PFN ranges
[    0.000000] On node 0 totalpages: 2094543
[    0.000000] On node 1 totalpages: 2097151
[    0.000000] NR_CPUS:16 nr_cpumask_bits:16 nr_cpu_ids:16 nr_node_ids:=
2
[    0.000000] SLUB: Genslabs=3D14, HWalign=3D64, Order=3D0-3, MinObjec=
ts=3D0, CPUs=3D16, Nodes=3D2
[    0.004756] Inode-cache hash table entries: 1048576 (order: 11, 8388=
608 bytes)
[    0.007213] CPU 0/0x0 -> Node 0
[    0.398104] CPU 1/0x10 -> Node 0
[    0.557854] CPU 2/0x4 -> Node 0
[    0.717606] CPU 3/0x14 -> Node 0
[    0.877357] CPU 4/0x2 -> Node 0
[    1.037109] CPU 5/0x12 -> Node 0
[    1.196860] CPU 6/0x6 -> Node 0
[    1.356611] CPU 7/0x16 -> Node 0
[    1.516365] CPU 8/0x1 -> Node 0
[    1.676114] CPU 9/0x11 -> Node 0
[    1.835865] CPU 10/0x5 -> Node 0
[    1.995616] CPU 11/0x15 -> Node 0
[    2.155367] CPU 12/0x3 -> Node 0
[    2.315119] CPU 13/0x13 -> Node 0
[    2.474870] CPU 14/0x7 -> Node 0
[    2.634621] CPU 15/0x17 -> Node 0

# cat /proc/buddyinfo=20
Node 0, zone      DMA      2      2      2      1      1      1      1 =
     0      1      1      3=20
Node 0, zone    DMA32      5     11      4      5      4     12      1 =
     4      4      5    834=20
Node 0, zone   Normal   4109    120     98    153     67     35     21 =
    15     11     10    109=20
Node 1, zone   Normal      7     17     10     12      7     14      5 =
     7      6      5   2004=20


This is with net-next-2.6, I'll try linux-2.6
