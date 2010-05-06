From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: Consistent skb timestamping
Date: Thu, 06 May 2010 17:37:56 +0200
Message-ID: <1273160276.2853.27.camel@edumazet-laptop>
References: <1273147309.2357.59.camel@edumazet-laptop>
	 <AANLkTikLgHvtpCtBTKmJZBwixmZDHjRjGb1c59oAemli@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:59183 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754929Ab0EFPiC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 11:38:02 -0400
Received: by bwz19 with SMTP id 19so54858bwz.21
        for <netdev@vger.kernel.org>; Thu, 06 May 2010 08:38:00 -0700 (PDT)
In-Reply-To: <AANLkTikLgHvtpCtBTKmJZBwixmZDHjRjGb1c59oAemli@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 06 mai 2010 =C3=A0 08:12 -0700, Tom Herbert a =C3=A9crit :
> On Thu, May 6, 2010 at 5:01 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> > With RPS inclusion, skb timestamping is not consistent in RX path.
> >
> > If netif_receive_skb() is used, its deferred after RPS dispatch.
> >
> > If netif_rx() is used, its done before RPS dispatch.
> >
> > This can give strange tcpdump timestamps results.
> >
> > I think timestamping should be done as soon as possible in the rece=
ive
> > path, to get meaningful values (ie timestamps taken at the time pac=
ket
> > was delivered by NIC driver to our stack), even if NAPI already can
> > defer timestamping a bit (RPS can help to reduce the gap)
> >
> The counter argument to this is that it moves another thing into the
> serialized path for networking which slows everyone down.  I'm not
> concerned about when tcpdump is running since performance will suck
> anyway, but what is bad is if any single socket in the system turns o=
n
> SO_TIMESTAMP, overhead is incurred on *every* packet.  This happens
> regardless of whether the application ever actually gets a timestamp,
> or even whether timestamps are supported by the protocol (try setting
> SO_TIMESTAMP on a TCP socket ;-) ).  I'm contemplating changing
> SO_TIMESTAMP to not enable global timestamps, but only take the
> timestamp for a packet once the socket is identified and the timestam=
p
> flag is set (this is the technique done in FreeBSD and Solaris, so I
> believe the external semantics would still be valid).

I agree with you, thanks for this excellent argument.

Right now, timestamping is not meant for userland pleasure, but for
sniffers and network diagnostics. (I mean with current API, not with a
new one we could add later)

Once we settle a per socket timestamping, not global, we can reconsider
the thing (or not reconsider it, since socket timestamping will be done
after RPS dispatch)

Its true our global variable to enable/disable timestamp sucks, but its
a separate issue ;)

We probably could have a sysctl to let admin chose the moment timestamp
takes place (before or after RPS)

If TSC is available, here is the "perf top" of the cpu handling
1.200.000 packets per second, while timestamping is requested :
You can hardly see something about time services :

-----------------------------------------------------------------------=
---------------------------------------------------
   PerfTop:     983 irqs/sec  kernel:99.5% [1000Hz cycles],  (all, cpu:=
 10)
-----------------------------------------------------------------------=
---------------------------------------------------

             samples  pcnt function                            DSO
             _______ _____ ___________________________________ _______

             1568.00 14.9% bnx2x_rx_int                        vmlinux
             1133.00 10.7% eth_type_trans                      vmlinux
              798.00  7.6% kmem_cache_alloc_node               vmlinux
              720.00  6.8% _raw_spin_lock                      vmlinux
              709.00  6.7% __kmalloc_node_track_caller         vmlinux
              547.00  5.2% __memset                            vmlinux
              540.00  5.1% __slab_alloc                        vmlinux
              453.00  4.3% get_rps_cpu                         vmlinux
              402.00  3.8% _raw_spin_lock_irqsave              vmlinux
              295.00  2.8% enqueue_to_backlog                  vmlinux
              271.00  2.6% default_send_IPI_mask_sequence_phys vmlinux
              259.00  2.5% get_partial_node                    vmlinux
              235.00  2.2% __alloc_skb                         vmlinux
              227.00  2.2% vlan_gro_common                     vmlinux
              206.00  2.0% swiotlb_dma_mapping_error           vmlinux
              201.00  1.9% skb_put                             vmlinux
              118.00  1.1% getnstimeofday                      vmlinux
               97.00  0.9% csd_lock                            vmlinux
               96.00  0.9% swiotlb_map_page                    vmlinux
               85.00  0.8% read_tsc                            vmlinux
               76.00  0.7% dev_gro_receive                     vmlinux
               75.00  0.7% __napi_complete                     vmlinux
               74.00  0.7% bnx2x_poll                          vmlinux
               73.00  0.7% unmap_single                        vmlinux
               72.00  0.7% netif_receive_skb                   vmlinux
               66.00  0.6% irq_entries_start                   vmlinux
               65.00  0.6% net_rps_action_and_irq_enable       vmlinux
               62.00  0.6% __phys_addr                         vmlinux


If HPET or acpi_pm is used, then you can cry :)
 (820.000 pps, or 570.000 pps max)
-----------------------------------------------------------------------=
---------------------------------------------------
   PerfTop:    1001 irqs/sec  kernel:100.0% [1000Hz cycles],  (all, cpu=
: 10)
-----------------------------------------------------------------------=
---------------------------------------------------

             samples  pcnt function                            DSO
             _______ _____ ___________________________________ _______

             6488.00 48.4% read_hpet                           vmlinux
             1214.00  9.1% bnx2x_rx_int                        vmlinux
              820.00  6.1% eth_type_trans                      vmlinux
              679.00  5.1% _raw_spin_lock                      vmlinux
              678.00  5.1% kmem_cache_alloc_node               vmlinux
              607.00  4.5% __slab_alloc                        vmlinux
              478.00  3.6% __kmalloc_node_track_caller         vmlinux
              404.00  3.0% __memset                            vmlinux
              246.00  1.8% get_partial_node                    vmlinux
              213.00  1.6% get_rps_cpu                         vmlinux
              195.00  1.5% enqueue_to_backlog                  vmlinux
              171.00  1.3% __alloc_skb                         vmlinux
              163.00  1.2% vlan_gro_common                     vmlinux
              135.00  1.0% swiotlb_dma_mapping_error           vmlinux
              118.00  0.9% skb_put                             vmlinux
               88.00  0.7% getnstimeofday                      vmlinux
               60.00  0.4% swiotlb_map_page                    vmlinux
               59.00  0.4% dev_gro_receive                     vmlinux

-----------------------------------------------------------------------=
---------------------------------------------------
   PerfTop:    1001 irqs/sec  kernel:100.0% [1000Hz cycles],  (all, cpu=
: 10)
-----------------------------------------------------------------------=
---------------------------------------------------

             samples  pcnt function                            DSO
             _______ _____ ___________________________________ _______

             2573.00 68.3% acpi_pm_read                        vmlinux
              237.00  6.3% bnx2x_rx_int                        vmlinux
              153.00  4.1% eth_type_trans                      vmlinux
              101.00  2.7% kmem_cache_alloc_node               vmlinux
               99.00  2.6% __kmalloc_node_track_caller         vmlinux
               79.00  2.1% get_rps_cpu                         vmlinux
               75.00  2.0% __memset                            vmlinux
               72.00  1.9% _raw_spin_lock                      vmlinux
               68.00  1.8% __slab_alloc                        vmlinux
               40.00  1.1% enqueue_to_backlog                  vmlinux
               39.00  1.0% __alloc_skb                         vmlinux
               27.00  0.7% get_partial_node                    vmlinux
               23.00  0.6% swiotlb_dma_mapping_error           vmlinux
               22.00  0.6% vlan_gro_common                     vmlinux


