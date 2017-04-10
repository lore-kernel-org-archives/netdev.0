From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH v2 net-next RFC] Generic XDP
Date: Mon, 10 Apr 2017 17:41:31 -0400
Message-ID: <20170410214131.GE4730@C02RW35GFVH8.dhcp.broadcom.net>
References: <20170409.133528.660876505013192371.davem@davemloft.net>
 <20170410183935.GB4730@C02RW35GFVH8.dhcp.broadcom.net>
 <58EBE73A.7090202@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        xdp-newbies@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:32921 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751978AbdDJVlp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 17:41:45 -0400
Received: by mail-pf0-f193.google.com with SMTP id c198so7928078pfc.0
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 14:41:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <58EBE73A.7090202@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 10, 2017 at 10:12:42PM +0200, Daniel Borkmann wrote:
> On 04/10/2017 08:39 PM, Andy Gospodarek wrote:
> [...]
> > I ran this on a desktop-class system I have (i7-6700 CPU @ 3.40GHz)
> > and used pktgen_sample03_burst_single_flow.sh from another system to
> > throw ~6.5Mpps as a single UDP stream towards the system running XDP.
> > 
> > I just commented out the ndo_xdp op in bnxt.c to test this patch.  The
> > differences were pretty dramatic.
> > 
> > Using the ndo_xdp ndo in bnxt_en, my perf report output looked like
> > this (not sure why X is still running on this system!):
> > 
> >      38.08%  swapper          [sysimgblt]                   [k] 0x0000000000005bd0
> >      11.80%  swapper          [kernel.vmlinux]              [k] intel_idle
> >      10.49%  swapper          [bnxt_en]                     [k] bnxt_rx_pkt
> >       6.31%  swapper          [bnxt_en]                     [k] bnxt_rx_xdp
> >       5.64%  swapper          [bnxt_en]                     [k] bnxt_poll
> >       4.22%  swapper          [kernel.vmlinux]              [k] poll_idle
> >       3.46%  swapper          [kernel.vmlinux]              [k] irq_entries_start
> >       2.95%  swapper          [kernel.vmlinux]              [k] napi_complete_done
> >       1.79%  swapper          [kernel.vmlinux]              [k] cpuidle_enter_state
> >       1.53%  swapper          [kernel.vmlinux]              [k] menu_select
> >       1.19%  swapper          [bnxt_en]                     [k] bnxt_reuse_rx_data
> >       1.00%  swapper          [sysimgblt]                   [k] 0x0000000000005c6f
> >       0.92%  swapper          [kernel.vmlinux]              [k] __next_timer_interrupt
> >       0.71%  swapper          [kernel.vmlinux]              [k] _raw_spin_lock_irqsave
> >       0.71%  swapper          [kernel.vmlinux]              [k] bpf_map_lookup_elem
> > 
> > mpstat reports that the CPU receiving and dropping the traffic is
> > basically running idle.  Dropping this amount of traffic in the driver
> > has very little impact on the system.
> > 
> > With v2 of this patch I see the following from perf report:
> > 
> >      19.69%  ksoftirqd/3      [kernel.vmlinux]              [k] memcpy_erms
> >      16.30%  ksoftirqd/3      [kernel.vmlinux]              [k] __bpf_prog_run
> 
> Forgot echo 1 > /proc/sys/net/core/bpf_jit_enable? Was it disabled in both cases?
> 

Good catch.  This must have been a run I did with it off.

Results with bpf_git_enable=1 and gro off, still only 7.5Mpps.

    26.34%  ksoftirqd/5      [kernel.vmlinux]              [k] memcpy_erms
    14.79%  ksoftirqd/5      [bnxt_en]                     [k] bnxt_rx_pkt
    10.11%  ksoftirqd/5      [kernel.vmlinux]              [k] __build_skb
     5.01%  ksoftirqd/5      [kernel.vmlinux]              [k] page_frag_free
     4.66%  ksoftirqd/5      [kernel.vmlinux]              [k] kmem_cache_alloc
     4.19%  ksoftirqd/5      [kernel.vmlinux]              [k] kmem_cache_free
     3.67%  ksoftirqd/5      [bnxt_en]                     [k] bnxt_poll
     2.97%  ksoftirqd/5      [kernel.vmlinux]              [k] netif_receive_skb_internal
     2.24%  ksoftirqd/5      [kernel.vmlinux]              [k] __napi_alloc_skb
     1.92%  ksoftirqd/5      [kernel.vmlinux]              [k] eth_type_trans
     1.78%  ksoftirqd/5      [bnxt_en]                     [k] bnxt_rx_xdp
     1.62%  ksoftirqd/5      [kernel.vmlinux]              [k] net_rx_action
     1.61%  ksoftirqd/5      [kernel.vmlinux]              [k] kfree_skb
     1.58%  ksoftirqd/5      [kernel.vmlinux]              [k] dev_gro_receive
     1.51%  ksoftirqd/5      [bnxt_en]                     [k] bnxt_reuse_rx_data
     1.44%  ksoftirqd/5      [kernel.vmlinux]              [k] skb_release_data
     1.42%  ksoftirqd/5      [kernel.vmlinux]              [k] page_frag_alloc
     1.29%  ksoftirqd/5      [kernel.vmlinux]              [k] napi_gro_receive
     1.21%  ksoftirqd/5      [kernel.vmlinux]              [k] skb_release_head_state
     0.82%  ksoftirqd/5      [kernel.vmlinux]              [k] skb_free_head
     0.81%  ksoftirqd/5      [kernel.vmlinux]              [k] swiotlb_sync_single
     0.77%  ksoftirqd/5      [kernel.vmlinux]              [k] skb_gro_reset_offset
     0.76%  ksoftirqd/5      [kernel.vmlinux]              [k] skb_release_all
     0.73%  ksoftirqd/5      [kernel.vmlinux]              [k] kfree_skbmem




> >      10.11%  ksoftirqd/3      [bnxt_en]                     [k] bnxt_rx_pkt
> >       7.69%  ksoftirqd/3      [kernel.vmlinux]              [k] __build_skb
> >       4.25%  ksoftirqd/3      [kernel.vmlinux]              [k] inet_gro_receive
> >       3.74%  ksoftirqd/3      [kernel.vmlinux]              [k] kmem_cache_alloc
> >       3.53%  ksoftirqd/3      [kernel.vmlinux]              [k] dev_gro_receive
> >       3.43%  ksoftirqd/3      [kernel.vmlinux]              [k] page_frag_free
> >       3.12%  ksoftirqd/3      [kernel.vmlinux]              [k] kmem_cache_free
> >       2.56%  ksoftirqd/3      [bnxt_en]                     [k] bnxt_poll
> >       2.46%  ksoftirqd/3      [kernel.vmlinux]              [k] netif_receive_skb_internal
> >       2.13%  ksoftirqd/3      [kernel.vmlinux]              [k] __udp4_lib_lookup
> >       1.63%  ksoftirqd/3      [kernel.vmlinux]              [k] __napi_alloc_skb
> >       1.51%  ksoftirqd/3      [kernel.vmlinux]              [k] eth_type_trans
> >       1.42%  ksoftirqd/3      [kernel.vmlinux]              [k] udp_gro_receive
> >       1.29%  ksoftirqd/3      [kernel.vmlinux]              [k] napi_gro_receive
> >       1.25%  ksoftirqd/3      [kernel.vmlinux]              [k] udp4_gro_receive
> >       1.18%  ksoftirqd/3      [bnxt_en]                     [k] bnxt_rx_xdp
> >       1.17%  ksoftirqd/3      [kernel.vmlinux]              [k] skb_release_data
> >       1.11%  ksoftirqd/3      [bnxt_en]                     [k] bnxt_reuse_rx_data
> >       1.07%  ksoftirqd/3      [kernel.vmlinux]              [k] net_rx_action
> 
