From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 00/12] Implement XDP bpf_redirect vairants
Date: Tue, 11 Jul 2017 17:36:58 +0200
Message-ID: <20170711173658.6188b0a2@redhat.com>
References: <20170707172115.9984.53461.stgit@john-Precision-Tower-5810>
        <595FC974.9030807@gmail.com>
        <20170708.104618.2149883426031901592.davem@davemloft.net>
        <20170708210617.249059b9@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: john.fastabend@gmail.com, netdev@vger.kernel.org,
        andy@greyhouse.net, daniel@iogearbox.net, ast@fb.com,
        alexander.duyck@gmail.com, bjorn.topel@intel.com,
        jakub.kicinski@netronome.com, ecree@solarflare.com,
        sgoutham@cavium.com, Yuval.Mintz@cavium.com, saeedm@mellanox.com,
        brouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42130 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933478AbdGKPhH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Jul 2017 11:37:07 -0400
In-Reply-To: <20170708210617.249059b9@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 8 Jul 2017 21:06:17 +0200
Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> My plan is to test this latest patchset again, Monday and Tuesday.
> I'll try to assess stability and provide some performance numbers.

Performance numbers:

 14378479 pkt/s = XDP_DROP without touching memory
  9222401 pkt/s = xdp1: XDP_DROP with reading packet data
  6344472 pkt/s = xdp2: XDP_TX   with swap mac (writes into pkt)
  4595574 pkt/s = xdp_redirect:     XDP_REDIRECT with swap mac (simulate XDP_TX)
  5066243 pkt/s = xdp_redirect_map: XDP_REDIRECT with swap mac + devmap

The performance drop between xdp2 and xdp_redirect, was expected due
to the HW-tailptr flush per packet, which is costly.

 (1/6344472-1/4595574)*10^9 = -59.98 ns

The performance drop between xdp2 and xdp_redirect_map, is higher than
I expected, which is not good!  The avoidance of the tailptr flush per
packet was expected to give a higher boost.  The cost increased with
40 ns, which is too high compared to the code added (on a 4GHz machine
approx 160 cycles).

 (1/6344472-1/5066243)*10^9 = -39.77 ns

This system doesn't have DDIO, thus we are stalling on cache-misses,
but I was actually expecting that the added code could "hide" behind
these cache-misses.

I'm somewhat surprised to see this large a performance drop.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

Results::

 # XDP_DROP with reading packet data
 [jbrouer@canyon bpf]$ sudo ./xdp1 3
 proto 17:    6449727 pkt/s
 proto 17:    9222639 pkt/s
 proto 17:    9222401 pkt/s
 proto 17:    9223083 pkt/s
 proto 17:    9223515 pkt/s
 proto 17:    9222477 pkt/s
 ^C

 # XDP_TX with swap mac
 [jbrouer@canyon bpf]$ sudo ./xdp2 3
 proto 17:     934682 pkt/s
 proto 17:    6344845 pkt/s
 proto 17:    6344472 pkt/s
 proto 17:    6345265 pkt/s
 proto 17:    6345238 pkt/s
 proto 17:    6345338 pkt/s
 ^C

 # XDP_REDIRECT with swap mac (simulate XDP_TX via same ifindex)
 [jbrouer@canyon bpf]$ sudo ./xdp_redirect 3 3
 ifindex 3:     749567 pkt/s
 ifindex 3:    4595025 pkt/s
 ifindex 3:    4595574 pkt/s
 ifindex 3:    4595429 pkt/s
 ifindex 3:    4595340 pkt/s
 ifindex 3:    4595352 pkt/s
 ifindex 3:    4595364 pkt/s
 ^C

  # XDP_REDIRECT with swap mac + devmap (still simulate XDP_TX)
 [jbrouer@canyon bpf]$ sudo ./xdp_redirect_map 3 3
 map[0] (vports) = 4, map[1] (map) = 5, map[2] (count) = 0
 ifindex 3:    3076506 pkt/s
 ifindex 3:    5066282 pkt/s
 ifindex 3:    5066243 pkt/s
 ifindex 3:    5067376 pkt/s
 ifindex 3:    5067226 pkt/s
 ifindex 3:    5067622 pkt/s

My own tools::

 [jbrouer@canyon prototype-kernel]$
   sudo ./xdp_bench01_mem_access_cost --dev ixgbe1 --sec 2 \
    --action XDP_DROP
 XDP_action   pps        pps-human-readable mem      
 XDP_DROP     0          0                  no_touch 
 XDP_DROP     9894401    9,894,401          no_touch 
 XDP_DROP     14377459   14,377,459         no_touch 
 XDP_DROP     14378228   14,378,228         no_touch 
 XDP_DROP     14378400   14,378,400         no_touch 
 XDP_DROP     14378319   14,378,319         no_touch 
 XDP_DROP     14378479   14,378,479         no_touch 
 XDP_DROP     14377332   14,377,332         no_touch 
 XDP_DROP     14378411   14,378,411         no_touch 
 XDP_DROP     14378095   14,378,095         no_touch 
 ^CInterrupted: Removing XDP program on ifindex:3 device:ixgbe1

 [jbrouer@canyon prototype-kernel]$
  sudo ./xdp_bench01_mem_access_cost --dev ixgbe1 --sec 2 \
   --action XDP_DROP --read
 XDP_action   pps        pps-human-readable mem      
 XDP_DROP     0          0                  read     
 XDP_DROP     6994114    6,994,114          read     
 XDP_DROP     8979414    8,979,414          read     
 XDP_DROP     8979636    8,979,636          read     
 XDP_DROP     8980087    8,980,087          read     
 XDP_DROP     8979097    8,979,097          read     
 XDP_DROP     8978970    8,978,970          read     
 ^CInterrupted: Removing XDP program on ifindex:3 device:ixgbe1

 [jbrouer@canyon prototype-kernel]$
  sudo ./xdp_bench01_mem_access_cost --dev ixgbe1 --sec 2 \
  --action XDP_TX --swap --read
 XDP_action   pps        pps-human-readable mem      
 XDP_TX       0          0                  swap_mac 
 XDP_TX       2141556    2,141,556          swap_mac 
 XDP_TX       6171984    6,171,984          swap_mac 
 XDP_TX       6171955    6,171,955          swap_mac 
 XDP_TX       6171767    6,171,767          swap_mac 
 XDP_TX       6171680    6,171,680          swap_mac 
 XDP_TX       6172201    6,172,201          swap_mac 
 ^CInterrupted: Removing XDP program on ifindex:3 device:ixgbe1


Setting tuned-adm network-latency ::

 $ sudo tuned-adm list
 [...]
 Current active profile: network-latency
