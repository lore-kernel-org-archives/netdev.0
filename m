From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 00/12] Implement XDP bpf_redirect vairants
Date: Tue, 11 Jul 2017 20:44:05 +0200
Message-ID: <20170711204405.2f6b033c@redhat.com>
References: <20170707172115.9984.53461.stgit@john-Precision-Tower-5810>
        <595FC974.9030807@gmail.com>
        <20170708.104618.2149883426031901592.davem@davemloft.net>
        <20170708210617.249059b9@redhat.com>
        <20170711173658.6188b0a2@redhat.com>
        <59650F6D.4070202@gmail.com>
        <20170711200136.46ab5687@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        andy@greyhouse.net, daniel@iogearbox.net, ast@fb.com,
        alexander.duyck@gmail.com, bjorn.topel@intel.com,
        jakub.kicinski@netronome.com, ecree@solarflare.com,
        sgoutham@cavium.com, Yuval.Mintz@cavium.com, saeedm@mellanox.com,
        brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60430 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933021AbdGKSoR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Jul 2017 14:44:17 -0400
In-Reply-To: <20170711200136.46ab5687@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 11 Jul 2017 20:01:36 +0200
Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> On Tue, 11 Jul 2017 10:48:29 -0700
> John Fastabend <john.fastabend@gmail.com> wrote:
> 
> > On 07/11/2017 08:36 AM, Jesper Dangaard Brouer wrote:  
> > > On Sat, 8 Jul 2017 21:06:17 +0200
> > > Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> > >     
> > >> My plan is to test this latest patchset again, Monday and Tuesday.
> > >> I'll try to assess stability and provide some performance numbers.    
> > > 
> > > Performance numbers:
> > > 
> > >  14378479 pkt/s = XDP_DROP without touching memory
> > >   9222401 pkt/s = xdp1: XDP_DROP with reading packet data
> > >   6344472 pkt/s = xdp2: XDP_TX   with swap mac (writes into pkt)
> > >   4595574 pkt/s = xdp_redirect:     XDP_REDIRECT with swap mac (simulate XDP_TX)
> > >   5066243 pkt/s = xdp_redirect_map: XDP_REDIRECT with swap mac + devmap
> > > 
> > > The performance drop between xdp2 and xdp_redirect, was expected due
> > > to the HW-tailptr flush per packet, which is costly.
> > > 
> > >  (1/6344472-1/4595574)*10^9 = -59.98 ns
> > > 
> > > The performance drop between xdp2 and xdp_redirect_map, is higher than
> > > I expected, which is not good!  The avoidance of the tailptr flush per
> > > packet was expected to give a higher boost.  The cost increased with
> > > 40 ns, which is too high compared to the code added (on a 4GHz machine
> > > approx 160 cycles).
> > > 
> > >  (1/6344472-1/5066243)*10^9 = -39.77 ns
> > > 
> > > This system doesn't have DDIO, thus we are stalling on cache-misses,
> > > but I was actually expecting that the added code could "hide" behind
> > > these cache-misses.
> > > 
> > > I'm somewhat surprised to see this large a performance drop.
> > >     
> > 
> > Yep, although there is room for optimizations in the code path for sure. And
> > 5mpps is not horrible my preference is to get this series in plus any
> > small optimization we come up with while the merge window is closed. Then
> > follow up patches can do optimizations.  
> 
> IMHO 5Mpps is a very bad number for XDP.
> 
> > One easy optimization is to get rid of the atomic bitops. They are not needed
> > here we have a per cpu unsigned long. Another easy one would be to move
> > some of the checks out of the hotpath. For example checking for ndo_xdp_xmit
> > and flush ops on the net device in the hotpath really should be done in the
> > slow path.  
> 
> I'm already running with a similar patch as below, but it
> (surprisingly) only gave my 3 ns improvement.  I also tried a
> prefetchw() on xdp.data that gave me 10 ns (which is quite good).
> 
> I'm booting up another system with a CPU E5-1650 v4 @ 3.60GHz, which
> have DDIO ... I have high hopes for this, as the major bottleneck on
> this CPU i7-4790K CPU @ 4.00GHz is clearly cache-misses.
> 
> Something is definitely wrong on this CPU, as perf stats shows, a very
> bad utilization of the CPU pipeline with 0.89 insn per cycle.

Wow, getting DDIO working and avoiding the cache-miss, was really
_the_ issue.  On this CPU E5-1650 v4 @ 3.60GHz things look really
really good for XDP_REDIRECT with maps. (p.s. with __set_bit()
optimization)

13,939,674 pkt/s = XDP_DROP without touching memory
14,290,650 pkt/s = xdp1: XDP_DROP with reading packet data
13,221,812 pkt/s = xdp2: XDP_TX   with swap mac (writes into pkt)
 7,596,576 pkt/s = xdp_redirect:    XDP_REDIRECT with swap mac (like XDP_TX)
13,058,435 pkt/s = xdp_redirect_map:XDP_REDIRECT with swap mac + devmap

Surprisingly, on this DDIO capable CPU it is slightly slower NOT to
read packet memory.

The large performance gap to xdp_redirect is due to the tailptr flush,
which really show up on this system.  The CPU efficiency is 1.36 insn
per cycle, which for map variant is 2.15 insn per cycle.

 Gap (1/13221812-1/7596576)*10^9 = -56 ns

The xdp_redirect_map performance is really really good, almost 10G
wirespeed on a single CPU!!!  This is amazing, and we know that this
code is not even optimal yet.  The performance difference to xdp2 is
only around 1 ns.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer


 [jbrouer@E5-1650v4 bpf]$ sudo ./xdp1 6
 proto 17:   11919302 pkt/s
 proto 17:   14281659 pkt/s
 proto 17:   14290650 pkt/s
 proto 17:   14283120 pkt/s
 proto 17:   14303023 pkt/s
 proto 17:   14299496 pkt/s

 [jbrouer@E5-1650v4 bpf]$ sudo ./xdp2 6
 proto 0:          1 pkt/s
 proto 17:    3225455 pkt/s
 proto 17:   13266772 pkt/s
 proto 17:   13221812 pkt/s
 proto 17:   13222200 pkt/s
 proto 17:   13225508 pkt/s
 proto 17:   13226274 pkt/s

 [jbrouer@E5-1650v4 bpf]$ sudo ./xdp_redirect 6 6
 ifindex 6:      66040 pkt/s
 ifindex 6:    7029143 pkt/s
 ifindex 6:    7596576 pkt/s
 ifindex 6:    7598499 pkt/s
 ifindex 6:    7597025 pkt/s
 ifindex 6:    7598462 pkt/s

 [jbrouer@E5-1650v4 bpf]$ sudo ./xdp_redirect_map 6 6
 map[0] (vports) = 4, map[1] (map) = 5, map[2] (count) = 0
 ifindex 6:      95429 pkt/s
 ifindex 6:   12156600 pkt/s
 ifindex 6:   13058435 pkt/s
 ifindex 6:   13058515 pkt/s
 ifindex 6:   13059213 pkt/s
 ifindex 6:   13058322 pkt/s
 ifindex 6:   13059342 pkt/s

 [jbrouer@E5-1650v4 prototype-kernel]$
  sudo ./xdp_bench01_mem_access_cost --dev ixgbe2 --action XDP_DROP
 XDP_action   pps        pps-human-readable mem      
 XDP_DROP     0          0                  no_touch 
 XDP_DROP     1          1                  no_touch 
 XDP_DROP     11959667   11,959,667         no_touch 
 XDP_DROP     13939674   13,939,674         no_touch 
 XDP_DROP     13954549   13,954,549         no_touch 
 XDP_DROP     13953897   13,953,897         no_touch 
 XDP_DROP     13963531   13,963,531         no_touch 

 [jbrouer@E5-1650v4 prototype-kernel]$
  sudo ./xdp_bench01_mem_access_cost --dev ixgbe2 --action XDP_DROP --read
 XDP_action   pps        pps-human-readable mem      
 XDP_DROP     0          0                  read     
 XDP_DROP     0          0                  read     
 XDP_DROP     0          0                  read     
 XDP_DROP     8611099    8,611,099          read     
 XDP_DROP     14300230   14,300,230         read     
 XDP_DROP     14293416   14,293,416         read     
 XDP_DROP     14297247   14,297,247         read     
 XDP_DROP     14300563   14,300,563         read     
 XDP_DROP     14299873   14,299,873         read     
 ^CInterrupted: Removing XDP program on ifindex:6 device:ixgbe2

 [jbrouer@E5-1650v4 prototype-kernel]$
 sudo ./xdp_bench01_mem_access_cost --dev ixgbe2 --action XDP_TX --swap
 XDP_action   pps        pps-human-readable mem      
 XDP_TX       1          1                  swap_mac 
 XDP_TX       3007657    3,007,657          swap_mac 
 XDP_TX       13322885   13,322,885         swap_mac 
 XDP_TX       13200845   13,200,845         swap_mac 
 XDP_TX       13189829   13,189,829         swap_mac 
 XDP_TX       13197952   13,197,952         swap_mac 
 XDP_TX       13198856   13,198,856         swap_mac 
 ^CInterrupted: Removing XDP program on ifindex:6 device:ixgbe2

Normal xdp_redirect:

 [jbrouer@localhost ~]$ sudo perf stat -C10 -e L1-icache-load-misses -e cycles:k -e  instructions:k -e cache-misses:k -e   cache-references:k  -e LLC-store-misses:k -e LLC-store -e LLC-load-misses:k -e  LLC-load -e L1-dcache-load-misses -e L1-dcache-loads -e L1-dcache-stores -e ref-cycles -e bus-cycles -r 3 sleep 1

 Performance counter stats for 'CPU(s) 10' (3 runs):

           105,645      L1-icache-load-misses                                         ( +-  0.90% )  (35.48%)
     3,790,481,191      cycles:k                                                      ( +-  0.00% )  (42.67%)
     5,159,580,049      instructions:k            #    1.36  insn per cycle           ( +-  0.02% )  (49.87%)
               931      cache-misses:k            #    0.004 % of all cache refs      ( +- 31.80% )  (49.97%)
        21,394,789      cache-references:k                                            ( +-  0.03% )  (50.07%)
                 0      LLC-store-misses                                              (43.07%)
           840,689      LLC-store                                                     ( +-  0.13% )  (43.16%)
                 0      LLC-load-misses                                               (14.37%)
         8,031,535      LLC-load                                                      ( +-  0.02% )  (14.27%)
        42,211,992      L1-dcache-load-misses     #    2.49% of all L1-dcache hits    ( +-  0.01% )  (21.36%)
     1,692,701,894      L1-dcache-loads                                               ( +-  0.02% )  (28.46%)
       922,985,760      L1-dcache-stores                                              ( +-  0.02% )  (28.37%)
     3,591,805,402      ref-cycles                                                    ( +-  0.00% )  (35.47%)
        99,762,378      bus-cycles                                                    ( +-  0.00% )  (35.47%)

       1.000964284 seconds time elapsed                                          ( +-  0.01% )


xdp_redirect_map::

 [jbrouer@localhost ~]$ sudo perf stat -C10 -e L1-icache-load-misses -e cycles:k -e  instructions:k -e cache-misses:k -e   cache-references:k  -e LLC-store-misses:k -e LLC-store -e LLC-load-misses:k -e  LLC-load -e L1-dcache-load-misses -e L1-dcache-loads -e L1-dcache-stores -e ref-cycles -e bus-cycles -r 3 sleep 1

 Performance counter stats for 'CPU(s) 10' (3 runs):

           103,113      L1-icache-load-misses                                         ( +- 11.60% )  (35.48%)
     3,789,133,467      cycles:k                                                      ( +-  0.03% )  (42.66%)
     8,152,033,594      instructions:k            #    2.15  insn per cycle           ( +-  9.00% )  (49.85%)
             1,414      cache-misses:k            #    0.004 % of all cache refs      ( +- 21.42% )  (49.95%)
        32,480,603      cache-references:k                                            ( +-  8.63% )  (50.05%)
                 0      LLC-store-misses                                              (43.06%)
           786,799      LLC-store                                                     ( +-  1.57% )  (43.14%)
                67      LLC-load-misses                                               ( +-100.00% )  (14.37%)
        12,445,529      LLC-load                                                      ( +-  9.05% )  (14.28%)
        77,013,768      L1-dcache-load-misses     #    2.83% of all L1-dcache hits    ( +-  9.07% )  (21.38%)
     2,725,676,877      L1-dcache-loads                                               ( +-  8.98% )  (28.47%)
     1,566,087,361      L1-dcache-stores                                              ( +-  8.95% )  (28.39%)
     3,590,481,746      ref-cycles                                                    ( +-  0.03% )  (35.48%)
        99,725,522      bus-cycles                                                    ( +-  0.03% )  (35.47%)

       1.000920909 seconds time elapsed                                          ( +-  0.00% )
