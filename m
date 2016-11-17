From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: Netperf UDP issue with connected sockets
Date: Thu, 17 Nov 2016 17:34:12 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB0222982@AcuExch.aculab.com>
References: <20140903165943.372b897b@redhat.com>
        <1409757426.26422.41.camel@edumazet-glaptop2.roam.corp.google.com>
        <20161116131609.4e5726b4@redhat.com>
        <7c4b43a4-74bf-1ee2-6f0d-17783b5d8fcb@hpe.com>
        <20161116234022.2bad179b@redhat.com>
        <1479342849.8455.233.camel@edumazet-glaptop3.roam.corp.google.com>
        <20161117091638.5fab8494@redhat.com>
        <1479388850.8455.240.camel@edumazet-glaptop3.roam.corp.google.com>
        <20161117144248.23500001@redhat.com>
        <1479392258.8455.249.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161117155753.17b76f5a@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Rick Jones <rick.jones2@hpe.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Jesper Dangaard Brouer' <brouer@redhat.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.193]:62512 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941641AbcKQReW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 12:34:22 -0500
In-Reply-To: <20161117155753.17b76f5a@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer
> Sent: 17 November 2016 14:58
> On Thu, 17 Nov 2016 06:17:38 -0800
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > On Thu, 2016-11-17 at 14:42 +0100, Jesper Dangaard Brouer wrote:
> >
> > > I can see that qdisc layer does not activate xmit_more in this case.
> > >
> >
> > Sure. Not enough pressure from the sender(s).
> >
> > The bottleneck is not the NIC or qdisc in your case, meaning that BQL
> > limit is kept at a small value.
> >
> > (BTW not all NIC have expensive doorbells)
> 
> I believe this NIC mlx5 (50G edition) does.
> 
> I'm seeing UDP TX of 1656017.55 pps, which is per packet:
> 2414 cycles(tsc) 603.86 ns
> 
> Perf top shows (with my own udp_flood, that avoids __ip_select_ident):
> 
>  Samples: 56K of event 'cycles', Event count (approx.): 51613832267
>    Overhead  Command        Shared Object        Symbol
>  +    8.92%  udp_flood      [kernel.vmlinux]     [k] _raw_spin_lock
>    - _raw_spin_lock
>       + 90.78% __dev_queue_xmit
>       + 7.83% dev_queue_xmit
>       + 1.30% ___slab_alloc
>  +    5.59%  udp_flood      [kernel.vmlinux]     [k] skb_set_owner_w
>  +    4.77%  udp_flood      [mlx5_core]          [k] mlx5e_sq_xmit
>  +    4.09%  udp_flood      [kernel.vmlinux]     [k] fib_table_lookup
>  +    4.00%  swapper        [mlx5_core]          [k] mlx5e_poll_tx_cq
>  +    3.11%  udp_flood      [kernel.vmlinux]     [k] __ip_route_output_key_hash
>  +    2.49%  swapper        [kernel.vmlinux]     [k] __slab_free
> 
> In this setup the spinlock in __dev_queue_xmit should be uncongested.
> An uncongested spin_lock+unlock cost 32 cycles(tsc) 8.198 ns on this system.
> 
> But 8.92% of the time is spend on it, which corresponds to a cost of 215
> cycles (2414*0.0892).  This cost is too high, thus something else is
> going on... I claim this mysterious extra cost is the tailptr/doorbell.

Try adding code to ring the doorbell twice.
If this doesn't slow things down then it isn't (likely to be) responsible
for the delay you are seeing.

	David
