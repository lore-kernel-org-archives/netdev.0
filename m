From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: speedup udp receive path
Date: Thu, 29 Apr 2010 14:45:08 +0200
Message-ID: <1272545108.2222.65.camel@edumazet-laptop>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
	 <20100427.150817.84390202.davem@davemloft.net>
	 <1272406693.2343.26.camel@edumazet-laptop>  <1272454432.14068.4.camel@bigi>
	 <1272458001.2267.0.camel@edumazet-laptop>  <1272458174.14068.16.camel@bigi>
	 <1272463605.2267.70.camel@edumazet-laptop> <1272498293.4258.121.camel@bigi>
	 <1272514176.2201.85.camel@edumazet-laptop> <1272540952.4258.161.camel@bigi>
	 <u2l412e6f7f1004290512x7fcdb5c3w591c6446d676502@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hadi@cyberus.ca, David Miller <davem@davemloft.net>,
	therbert@google.com, shemminger@vyatta.com, netdev@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>,
	Brian Bloniarz <bmb@athenacr.com>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:49701 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756236Ab0D3UQp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 16:16:45 -0400
Received: by bwz19 with SMTP id 19so352237bwz.21
        for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 13:16:42 -0700 (PDT)
In-Reply-To: <u2l412e6f7f1004290512x7fcdb5c3w591c6446d676502@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 29 avril 2010 =C3=A0 20:12 +0800, Changli Gao a =C3=A9crit :
> On Thu, Apr 29, 2010 at 7:35 PM, jamal <hadi@cyberus.ca> wrote:
> >
> > Same here - even in my worst case scenario 88.5% of 750Kpps > 600Kp=
ps.
> > Attached is history results to make more sense of what i am saying:
> > we have net-next kernels from apr14, apr23, apr23 with changlis cha=
nge,
> > apr28, apr28 with your change. What you'll see is non-rps (blue) ge=
ts
> > better and rps (Orange) gets better slowly then by apr28 it is wors=
e.
>=20
> Did the number of IPIs increase in the apr28 test? The finial patch
> with Eric's change may introduce more IPIs. And I am wondering why
> 23rdcl-non-rps is better than before. Maybe it is the side effect of
> my patch: enlarge the netdev_max_backlog.
>=20
>=20

Changli, I wonder how you can cook "performance" patches without testin=
g
them at all for real... This cannot be true ?

When the cpu doing the device softirq is flooded, it handles 300 packet=
s
per net_rx_action() round (netdev_budget), so sends at most 6 ipis per
300 packets, with or without my patch, with or without your patch as
well.

(At most because if remote cpus are flooded as well, they dont
napi_complete so no IPI needed at all)

(My patch had an effect only on normal load, ie one packet received in =
a
while... up to 50.000 pps I would say). And it also has a nice effect o=
n
non RPS loads (mostly the more typical load for following years).
If a second packet comes 3us after the first one, and before 2nd CPU
handled it, we _can_ afford an extra IPI.

750.000/50 =3D 15.000 IPI per second.

Even with 200.000 IPI per second, 'perf top -C CPU_IPI_sender' shows
that sending IPI is very cheap (maybe ~1% of cpu cycles)

# Samples: 32033467127
#
# Overhead         Command      Shared Object  Symbol
# ........  ..............  .................  ......
#
    18.05%            init  [kernel.kallsyms]  [k] poll_idle
    10.91%            init  [kernel.kallsyms]  [k] bnx2x_rx_int
    10.42%            init  [kernel.kallsyms]  [k] eth_type_trans
     5.72%            init  [kernel.kallsyms]  [k] kmem_cache_alloc_nod=
e
     5.43%            init  [kernel.kallsyms]  [k] __memset
     5.20%            init  [kernel.kallsyms]  [k] get_rps_cpu
     4.82%            init  [kernel.kallsyms]  [k] __slab_alloc
     4.34%            init  [kernel.kallsyms]  [k] get_partial_node
     4.22%            init  [kernel.kallsyms]  [k] _raw_spin_lock
     3.41%            init  [kernel.kallsyms]  [k] __kmalloc_node_track=
_caller
     3.01%            init  [kernel.kallsyms]  [k] __alloc_skb
     2.22%            init  [kernel.kallsyms]  [k] enqueue_to_backlog
     2.10%            init  [kernel.kallsyms]  [k] vlan_gro_common
     1.34%            init  [kernel.kallsyms]  [k] swiotlb_map_page
     1.25%            init  [kernel.kallsyms]  [k] skb_put
     1.06%            init  [kernel.kallsyms]  [k] _raw_spin_lock_irqsa=
ve
     0.92%            init  [kernel.kallsyms]  [k] dev_gro_receive
     0.88%            init  [kernel.kallsyms]  [k] swiotlb_dma_mapping_=
error
     0.83%            init  [kernel.kallsyms]  [k] vlan_gro_receive
     0.83%            init  [kernel.kallsyms]  [k] __phys_addr
     0.83%            init  [kernel.kallsyms]  [k] __napi_complete
     0.83%            init  [kernel.kallsyms]  [k] default_send_IPI_mas=
k_sequence_phys
     0.77%            init  [kernel.kallsyms]  [k] is_swiotlb_buffer
     0.76%            init  [kernel.kallsyms]  [k] __netdev_alloc_skb
     0.74%            init  [kernel.kallsyms]  [k] deactivate_slab
     0.73%            init  [kernel.kallsyms]  [k] netif_receive_skb
     0.72%            init  [kernel.kallsyms]  [k] unmap_single
     0.69%            init  [kernel.kallsyms]  [k] csd_lock
     0.63%            init  [kernel.kallsyms]  [k] bnx2x_poll
     0.61%            init  [kernel.kallsyms]  [k] bnx2x_msix_fp_int
     0.59%            init  [kernel.kallsyms]  [k] irq_entries_start
     0.59%            init  [kernel.kallsyms]  [k] swiotlb_sync_single
     0.54%            init  [kernel.kallsyms]  [k] get_slab
     0.46%            init  [kernel.kallsyms]  [k] napi_skb_finish



