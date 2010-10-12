From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net:  allocate skbs on local node
Date: Tue, 12 Oct 2010 08:58:19 +0200
Message-ID: <1286866699.30423.234.camel@edumazet-laptop>
References: <1286838210.30423.128.camel@edumazet-laptop>
	 <1286839363.30423.130.camel@edumazet-laptop>
	 <1286859925.30423.184.camel@edumazet-laptop>
	 <20101011230322.f0f6dd47.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Christoph Hellwig <hch@lst.de>,
	Christoph Lameter <cl@linux-foundation.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:38450 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754296Ab0JLG6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Oct 2010 02:58:41 -0400
Received: by wwj40 with SMTP id 40so4649477wwj.1
        for <netdev@vger.kernel.org>; Mon, 11 Oct 2010 23:58:40 -0700 (PDT)
In-Reply-To: <20101011230322.f0f6dd47.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 11 octobre 2010 =C3=A0 23:03 -0700, Andrew Morton a =C3=A9crit=
 :
> On Tue, 12 Oct 2010 07:05:25 +0200 Eric Dumazet <eric.dumazet@gmail.c=
om> wrote:

> > [PATCH net-next] net: allocate skbs on local node
> >=20
> > commit b30973f877 (node-aware skb allocation) spread a wrong habit =
of
> > allocating net drivers skbs on a given memory node : The one closes=
t to
> > the NIC hardware. This is wrong because as soon as we try to scale
> > network stack, we need to use many cpus to handle traffic and hit
> > slub/slab management on cross-node allocations/frees when these cpu=
s
> > have to alloc/free skbs bound to a central node.
> >=20
> > skb allocated in RX path are ephemeral, they have a very short
> > lifetime : Extra cost to maintain NUMA affinity is too expensive. W=
hat
> > appeared as a nice idea four years ago is in fact a bad one.
> >=20
> > In 2010, NIC hardwares are multiqueue, or we use RPS to spread the =
load,
> > and two 10Gb NIC might deliver more than 28 million packets per sec=
ond,
> > needing all the available cpus.
> >=20
> > Cost of cross-node handling in network and vm stacks outperforms th=
e
> > small benefit hardware had when doing its DMA transfert in its 'loc=
al'
> > memory node at RX time. Even trying to differentiate the two alloca=
tions
> > done for one skb (the sk_buff on local node, the data part on NIC
> > hardware node) is not enough to bring good performance.
> >=20
>=20
> This is all conspicuously hand-wavy and unquantified.  (IOW: prove it=
!)
>=20

I would say, _you_ should prove that original patch was good. It seems
no network guy was really in the discussion ?

Just run a test on a bnx2x or ixgbe multiqueue 10Gb adapter, and see th=
e
difference. Thats about a 40% slowdown on high packet rates, on a dual
socket machine (dual X5570  @2.93GHz). You can expect higher values on
four nodes (I dont have such hardware to do the test)


> The mooted effects should be tested for on both slab and slub, I
> suggest.  They're pretty different beasts.

SLAB is so slow on NUMA these days, you can forget it for good.

Its about 40% slower on some tests I did this week on net-next, to
speedup output (and routing) performance, so it was with normal (local)
allocations, not even cross-nodes ones.

Once you remove network bottlenecks, you badly hit contention on SLAB
and are forced to switch to SLUB ;)

Sending 160.000.000 udp frames on same neighbour/destination,
IP route cache disabled (to mimic DDOS on a router)
16 threads, 16 logical cpus. 32bit kernel (dual E5540  @ 2.53GHz)


(It takes more than 2 minutes with linux-2.6, so use net-next-2.6 if yo=
u
really want to get these numbers)

SLUB :

real	0m50.661s
user	0m15.973s
sys	11m42.548s


18348.00 21.4% dst_destroy             vmlinux
 5674.00  6.6% fib_table_lookup        vmlinux
 5563.00  6.5% dst_alloc               vmlinux
 5226.00  6.1% neigh_lookup            vmlinux
 3590.00  4.2% __ip_route_output_key   vmlinux
 2712.00  3.2% neigh_resolve_output    vmlinux
 2511.00  2.9% fib_semantic_match      vmlinux
 2488.00  2.9% ipv4_dst_destroy        vmlinux
 2206.00  2.6% __xfrm_lookup           vmlinux
 2119.00  2.5% memset                  vmlinux
 2015.00  2.4% __copy_from_user_ll     vmlinux
 1722.00  2.0% udp_sendmsg             vmlinux
 1679.00  2.0% __slab_free             vmlinux
 1152.00  1.3% ip_append_data          vmlinux
 1044.00  1.2% __alloc_skb             vmlinux
  952.00  1.1% kmem_cache_free         vmlinux
  942.00  1.1% udp_push_pending_frames vmlinux
  877.00  1.0% kfree                   vmlinux
  870.00  1.0% __call_rcu              vmlinux
  829.00  1.0% ip_push_pending_frames  vmlinux
  799.00  0.9% _raw_spin_lock_bh       vmlinux

SLAB:

real	1m10.771s
user	0m13.941s
sys	12m42.188s


22734.00 26.0% _raw_spin_lock          vmlinux
 8238.00  9.4% dst_destroy             vmlinux
 4393.00  5.0% fib_table_lookup        vmlinux
 3652.00  4.2% dst_alloc               vmlinux
 3335.00  3.8% neigh_lookup            vmlinux
 2444.00  2.8% memset                  vmlinux
 2443.00  2.8% __ip_route_output_key   vmlinux
 1916.00  2.2% fib_semantic_match      vmlinux
 1708.00  2.0% __copy_from_user_ll     vmlinux
 1669.00  1.9% __xfrm_lookup           vmlinux
 1642.00  1.9% free_block              vmlinux
 1554.00  1.8% neigh_resolve_output    vmlinux
 1388.00  1.6% ipv4_dst_destroy        vmlinux
 1335.00  1.5% udp_sendmsg             vmlinux
 1109.00  1.3% kmem_cache_free         vmlinux
 1007.00  1.2% __alloc_skb             vmlinux
 1004.00  1.1% kfree                   vmlinux
 1002.00  1.1% ip_append_data          vmlinux
  975.00  1.1% cache_grow              vmlinux
  936.00  1.1% ____cache_alloc_node    vmlinux
  925.00  1.1% udp_push_pending_frames vmlinux


All this raw_spin_lock overhead comes from SLAB.


