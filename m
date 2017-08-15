From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Kernel 4.13.0-rc4-next-20170811 - IP Routing / Forwarding
 performance vs Core/RSS number / HT on
Date: Tue, 15 Aug 2017 11:35:42 +0200
Message-ID: <20170815113542.62175adf@redhat.com>
References: <3ac1a817-5c62-2490-64e7-2512f0ee3b3e@itcare.pl>
        <20170812142358.08291888@redhat.com>
        <af5b3482-8f26-52b5-4a00-3a5a42b7449f@itcare.pl>
        <ce33b7b3-ae00-b6f0-e82a-6df3d5a5e995@itcare.pl>
        <20170814181957.5be27906@redhat.com>
        <1502729870.8411.63.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?UGF3ZcWC?= Staszewski <pstaszewski@itcare.pl>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>, brouer@redhat.com
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46114 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752368AbdHOJfs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Aug 2017 05:35:48 -0400
In-Reply-To: <1502729870.8411.63.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 14 Aug 2017 18:57:50 +0200
Paolo Abeni <pabeni@redhat.com> wrote:

> On Mon, 2017-08-14 at 18:19 +0200, Jesper Dangaard Brouer wrote:
> > The output (extracted below) didn't show who called 'do_raw_spin_lock',
> > BUT it showed another interesting thing.  The kernel code
> > __dev_queue_xmit() in might create route dst-cache problem for itself(?),
> > as it will first call skb_dst_force() and then skb_dst_drop() when the
> > packet is transmitted on a VLAN.
> > 
> >  static int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
> >  {
> >  [...]
> > 	/* If device/qdisc don't need skb->dst, release it right now while
> > 	 * its hot in this cpu cache.
> > 	 */
> > 	if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
> > 		skb_dst_drop(skb);
> > 	else
> > 		skb_dst_force(skb);  
> 
> I think that the high impact of the above code in this specific test is
> mostly due to the following:
> 
> - ingress packets with different RSS rx hash lands on different CPUs
> - but they use the same dst entry, since the destination IPs belong to
> the same subnet
> - the dst refcnt cacheline is contented between all the CPUs

Good point and explanation Paolo :-)
I changed my pktgen setup to be closer to Pawel's to provoke this
situation some more, and I get closer to provoke this although not as
clearly as Pawel.

A perf diff does show, that the overhead in the VLAN cause originates
from the routing "dst_release" code.  Diff Baseline==non-vlan case.

[jbrouer@canyon ~]$ sudo ~/perf diff
# Event 'cycles'
#
# Baseline  Delta Abs  Shared Object     Symbol                                   
# ........  .........  ................  .........................................
#
     3.23%     +4.32%  [kernel.vmlinux]  [k] __dev_queue_xmit
               +3.43%  [kernel.vmlinux]  [k] dst_release
    13.54%     -3.17%  [kernel.vmlinux]  [k] fib_table_lookup
     9.33%     -2.73%  [kernel.vmlinux]  [k] _raw_spin_lock
     7.91%     -1.75%  [ixgbe]           [k] ixgbe_poll
               +1.64%  [8021q]           [k] vlan_dev_hard_start_xmit
     7.23%     -1.26%  [ixgbe]           [k] ixgbe_xmit_frame_ring
     3.34%     -1.10%  [kernel.vmlinux]  [k] eth_type_trans
     5.20%     +0.97%  [kernel.vmlinux]  [k] ip_route_input_rcu
     1.13%     +0.95%  [kernel.vmlinux]  [k] ip_rcv_finish
     2.49%     -0.82%  [kernel.vmlinux]  [k] ip_forward
     3.05%     -0.80%  [kernel.vmlinux]  [k] __build_skb
     0.44%     +0.74%  [kernel.vmlinux]  [k] __netif_receive_skb
               +0.71%  [kernel.vmlinux]  [k] neigh_connected_output
     1.70%     +0.68%  [kernel.vmlinux]  [k] validate_xmit_skb
     1.42%     +0.67%  [kernel.vmlinux]  [k] dev_hard_start_xmit
     0.49%     +0.66%  [kernel.vmlinux]  [k] netif_receive_skb_internal
               +0.62%  [kernel.vmlinux]  [k] eth_header
               +0.57%  [ixgbe]           [k] ixgbe_tx_ctxtdesc
     1.19%     -0.55%  [kernel.vmlinux]  [k] __netdev_pick_tx
     2.54%     -0.48%  [kernel.vmlinux]  [k] fib_validate_source
     2.83%     +0.46%  [kernel.vmlinux]  [k] ip_finish_output2
     1.45%     +0.45%  [kernel.vmlinux]  [k] netif_skb_features
     1.66%     -0.45%  [kernel.vmlinux]  [k] napi_gro_receive
     0.90%     -0.40%  [kernel.vmlinux]  [k] validate_xmit_skb_list
     1.45%     -0.39%  [kernel.vmlinux]  [k] ip_finish_output
               +0.36%  [8021q]           [k] vlan_passthru_hard_header
     1.28%     -0.33%  [kernel.vmlinux]  [k] netdev_pick_tx
 

> Perhaps we can inprove the situation setting the IFF_XMIT_DST_RELEASE
> flag for vlan if the underlaying device does not have (relevant)
> classifier attached? (and clearing it as needed)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
