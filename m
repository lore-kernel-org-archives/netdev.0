From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bnx2x: add support for receive hashing
Date: Tue, 27 Apr 2010 19:13:59 +0200
Message-ID: <1272388439.2295.369.camel@edumazet-laptop>
References: <q2o65634d661004261038t8f0c32f5ye8169ef0c38172b7@mail.gmail.com>
	 <20100426.110432.104061817.davem@davemloft.net>
	 <4BD6E887.3000804@athenacr.com>
	 <20100427.095108.68126984.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bmb@athenacr.com, therbert@google.com, netdev@vger.kernel.org,
	rick.jones2@hp.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:36463 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755001Ab0D0ROH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 13:14:07 -0400
Received: by bwz19 with SMTP id 19so14269bwz.21
        for <netdev@vger.kernel.org>; Tue, 27 Apr 2010 10:14:03 -0700 (PDT)
In-Reply-To: <20100427.095108.68126984.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 27 avril 2010 =C3=A0 09:51 -0700, David Miller a =C3=A9crit :
> From: Brian Bloniarz <bmb@athenacr.com>
> Date: Tue, 27 Apr 2010 09:37:11 -0400
>=20
> > David Miller wrote:
> >> How damn hard is it to add two 16-bit ports to the hash regardless=
 of
> >> protocol?
> >>  =20
> > Come to think of it, for UDP the hash must ignore
> > the srcport and srcaddr, because a single bound
> > socket is going to wildcard both those fields.
>=20
> For load distribution we don't care if the local socket is wildcard
> bounded on source.
>=20
> It's going to be fully specified in the packet, and that's enough.
>=20
> Sure, for full RFS some amends might be necessary in this area, but
> for RPS and adapter based hw steering, using all of the ports is
> entirely sufficient.

Well well well...

I was doing some pktgen tests, with :

 pgset "src_min 192.168.0.10"
 pgset "src_max 192.168.0.110"
 pgset "dst_min 192.168.0.2"
 pgset "dst_max 192.168.0.2"
 pgset "udp_dst_min 4000"
 pgset "udp_dst_max 4000"

So I simulate 100 remote IPS bombarding a single port on target machine=
=2E
pktgen injects about 930.000 pps

sofirq of my target received on cpu0, and RPS spread packets to 7 other
cpus.

And my receiver is stuck (he can read about 50 pps !!!)


As soon as I disable rps, my receiver can catch 850.000 pps


RPS OFF: perf top of cpu 0

-----------------------------------------------------------------------=
-------------------------------------------------------
   PerfTop:    1001 irqs/sec  kernel:100.0% [1000Hz cycles],  (all, cpu=
: 0)
-----------------------------------------------------------------------=
-------------------------------------------------------

             samples  pcnt function               DSO
             _______ _____ ______________________ _______

              385.00 10.2% __udp4_lib_lookup      vmlinux
              322.00  8.5% ip_route_input         vmlinux
              312.00  8.3% sock_queue_rcv_skb     vmlinux
              262.00  6.9% do_raw_spin_lock       vmlinux
              251.00  6.6% __alloc_skb            vmlinux
              239.00  6.3% sock_put               vmlinux
              207.00  5.5% eth_type_trans         vmlinux
              202.00  5.4% __slab_alloc           vmlinux
              159.00  4.2% __kmalloc_track_caller vmlinux
              149.00  3.9% __sk_mem_schedule      vmlinux
              125.00  3.3% kmem_cache_alloc       vmlinux
              116.00  3.1% ipt_do_table           vmlinux
              115.00  3.0% do_raw_read_lock       vmlinux
               71.00  1.9% tg3_poll_work          vmlinux
               65.00  1.7% __netdev_alloc_skb     vmlinux
               64.00  1.7% skb_pull               vmlinux
               58.00  1.5% ip_rcv                 vmlinux
               58.00  1.5% __slab_free            vmlinux
               53.00  1.4% udp_queue_rcv_skb      vmlinux
               47.00  1.2% nf_iterate             vmlinux
               44.00  1.2% __netif_receive_skb    vmlinux
               29.00  0.8% sock_def_readable      vmlinux
               28.00  0.7% do_raw_spin_unlock     vmlinux
               26.00  0.7% kfree                  vmlinux
               25.00  0.7% __udp4_lib_rcv         vmlinux
               24.00  0.6% ip_rcv_finish          vmlinux
               24.00  0.6% __list_add             vmlinux


RPS, on, a perf top of a slave CPU :

-----------------------------------------------------------------------=
-------------------------------------------------------
   PerfTop:    1000 irqs/sec  kernel:100.0% [1000Hz cycles],  (all, cpu=
: 1)
-----------------------------------------------------------------------=
-------------------------------------------------------

             samples  pcnt function            DSO
             _______ _____ ___________________ _______

             2411.00 62.0% do_raw_spin_lock    vmlinux
              690.00 17.7% delay_tsc           vmlinux
              234.00  6.0% __udp4_lib_lookup   vmlinux
              174.00  4.5% sock_put            vmlinux
               72.00  1.9% ip_rcv              vmlinux
               51.00  1.3% __netif_receive_skb vmlinux
               43.00  1.1% do_raw_spin_unlock  vmlinux
               39.00  1.0% __delay             vmlinux
               38.00  1.0% sock_queue_rcv_skb  vmlinux
               36.00  0.9% udp_queue_rcv_skb   vmlinux
               31.00  0.8% ip_route_input      vmlinux
               15.00  0.4% __slab_free         vmlinux
               12.00  0.3% ipt_do_table        vmlinux
               11.00  0.3% skb_release_data    vmlinux
                7.00  0.2% kfree               vmlinux
                5.00  0.1% nf_iterate          vmlinux

So we have a BIG problem :

All cpus are fighting to get the socket lock,
and very litle progress is done.

Note this problem has nothing to do with RPS, we could have=20
it with multiqueue as well.

Oh well...



