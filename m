From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v6] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Mon, 26 Apr 2010 16:55:07 +0200
Message-ID: <1272293707.19143.51.camel@edumazet-laptop>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
	 <1272014825.7895.7851.camel@edumazet-laptop> <1272060153.8918.8.camel@bigi>
	 <1272118252.8918.13.camel@bigi> <1272290584.19143.43.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, Andi Kleen <andi@firstfloor.org>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:58969 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751891Ab0DZOzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 10:55:13 -0400
Received: by bwz19 with SMTP id 19so222523bwz.21
        for <netdev@vger.kernel.org>; Mon, 26 Apr 2010 07:55:11 -0700 (PDT)
In-Reply-To: <1272290584.19143.43.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 26 avril 2010 =C3=A0 16:03 +0200, Eric Dumazet a =C3=A9crit :
> Le samedi 24 avril 2010 =C3=A0 10:10 -0400, jamal a =C3=A9crit :
> > On Fri, 2010-04-23 at 18:02 -0400, jamal wrote:
> >=20
> > > Ive done a setup with the last patch from Changli + net-next - I =
will
> > > post test results tomorrow AM.
> >=20
> > ok, annotated results attached.=20
> >=20
> > cheers,
> > jamal
>=20
> Jamal, I have a Nehalem setup now, and I can see
> _raw_spin_lock_irqsave() abuse is not coming from network tree, but f=
rom
> clockevents_notify()
>=20

Another interesting finding:

- if all packets are received on a single queue, max speed seems to be
1.200.000 packets per second on my machine :-(

And on profile of receiving cpu (RPS enabled, pakets sent to 15 other
cpus), we can see default_send_IPI_mask_sequence_phys() is the slow
thing...

Andi, what do you think of this one ?
Dont we have a function to send an IPI to an individual cpu instead ?

void default_send_IPI_mask_sequence_phys(const struct cpumask *mask, in=
t
vector)
{
        unsigned long query_cpu;
        unsigned long flags;

        /*
         * Hack. The clustered APIC addressing mode doesn't allow us to
send
         * to an arbitrary mask, so I do a unicast to each CPU instead.
         * - mbligh
         */
        local_irq_save(flags);
        for_each_cpu(query_cpu, mask) {
                __default_send_IPI_dest_field(per_cpu(x86_cpu_to_apicid=
,
                                query_cpu), vector, APIC_DEST_PHYSICAL)=
;
        }
        local_irq_restore(flags);
}


-----------------------------------------------------------------------=
------------------------------------------------------------------
   PerfTop:    1000 irqs/sec  kernel:100.0% [1000Hz cycles],  (all, cpu=
:
7)
-----------------------------------------------------------------------=
------------------------------------------------------------------

             samples  pcnt function                            DSO
             _______ _____ ___________________________________ _______

              668.00 17.7% default_send_IPI_mask_sequence_phys vmlinux
              363.00  9.6% bnx2x_rx_int                        vmlinux
              354.00  9.4% eth_type_trans                      vmlinux
              332.00  8.8% kmem_cache_alloc_node               vmlinux
              285.00  7.6% __kmalloc_node_track_caller         vmlinux
              278.00  7.4% _raw_spin_lock                      vmlinux
              166.00  4.4% __slab_alloc                        vmlinux
              147.00  3.9% __memset                            vmlinux
              136.00  3.6% list_del                            vmlinux
              132.00  3.5% get_partial_node                    vmlinux
              131.00  3.5% get_rps_cpu                         vmlinux
              102.00  2.7% enqueue_to_backlog                  vmlinux
               95.00  2.5% unmap_single                        vmlinux
               94.00  2.5% __alloc_skb                         vmlinux
               74.00  2.0% vlan_gro_common                     vmlinux
               52.00  1.4% __phys_addr                         vmlinux
               48.00  1.3% dev_gro_receive                     vmlinux
               39.00  1.0% swiotlb_dma_mapping_error           vmlinux
               36.00  1.0% swiotlb_map_page                    vmlinux
               34.00  0.9% skb_put                             vmlinux
               27.00  0.7% is_swiotlb_buffer                   vmlinux
               23.00  0.6% deactivate_slab                     vmlinux
               20.00  0.5% vlan_gro_receive                    vmlinux
               17.00  0.5% __skb_bond_should_drop              vmlinux
               14.00  0.4% netif_receive_skb                   vmlinux
               14.00  0.4% __netdev_alloc_skb                  vmlinux
               12.00  0.3% skb_gro_reset_offset                vmlinux
               12.00  0.3% get_slab                            vmlinux
               11.00  0.3% napi_skb_finish                     vmlinux


