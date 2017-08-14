From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Kernel 4.13.0-rc4-next-20170811 - IP Routing / Forwarding
 performance vs Core/RSS number / HT on
Date: Mon, 14 Aug 2017 18:19:57 +0200
Message-ID: <20170814181957.5be27906@redhat.com>
References: <3ac1a817-5c62-2490-64e7-2512f0ee3b3e@itcare.pl>
        <20170812142358.08291888@redhat.com>
        <af5b3482-8f26-52b5-4a00-3a5a42b7449f@itcare.pl>
        <ce33b7b3-ae00-b6f0-e82a-6df3d5a5e995@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        brouer@redhat.com, Alexander Duyck <alexander.duyck@gmail.com>
To: =?UTF-8?B?UGF3ZcWC?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59662 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752314AbdHNQUE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Aug 2017 12:20:04 -0400
In-Reply-To: <ce33b7b3-ae00-b6f0-e82a-6df3d5a5e995@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sun, 13 Aug 2017 18:58:58 +0200 Paweł Staszewski <pstaszewski@itcare.pl> wrote:

> To show some difference below comparision vlan/no-vlan traffic
> 
> 10Mpps forwarded traffic vith no-vlan vs 6.9Mpps with vlan

I'm trying to reproduce in my testlab (with ixgbe).  I do see, a
performance reduction of about 10-19% when I forward out a VLAN
interface.  This is larger than I expected, but still lower than what
you reported 30-40% slowdown.

[...]

> >>> perf top:
> >>>
> >>>    PerfTop:   77835 irqs/sec  kernel:99.7%  
> >>> ---------------------------------------------
> >>>
> >>>       16.32%  [kernel]       [k] skb_dst_force
> >>>       16.30%  [kernel]       [k] dst_release
> >>>       15.11%  [kernel]       [k] rt_cache_valid
> >>>       12.62%  [kernel]       [k] ipv4_mtu  
> >> It seems a little strange that these 4 functions are on the top  

I don't see these in my test.

> >>  
> >>>        5.60%  [kernel]       [k] do_raw_spin_lock  
> >> Why is calling/taking this lock? (Use perf call-graph recording).  
> > can be hard to paste it here:)
> > attached file

The attached was very big. Please don't attach so big file on mailing
lists.  Next time plase share them via e.g. pastebin. The output was a
capture from your terminal, which made the output more difficult to
read.  Hint: You can/could use perf --stdio and place it in a file
instead.

The output (extracted below) didn't show who called 'do_raw_spin_lock',
BUT it showed another interesting thing.  The kernel code
__dev_queue_xmit() in might create route dst-cache problem for itself(?),
as it will first call skb_dst_force() and then skb_dst_drop() when the
packet is transmitted on a VLAN.

 static int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
 {
 [...]
	/* If device/qdisc don't need skb->dst, release it right now while
	 * its hot in this cpu cache.
	 */
	if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
		skb_dst_drop(skb);
	else
		skb_dst_force(skb);


- - 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

Extracted part of attached perf output:

 --5.37%--ip_rcv_finish
   |          
   |--4.02%--ip_forward
   |   |          
   |    --3.92%--ip_forward_finish
   |       |          
   |        --3.91%--ip_output
   |          |          
   |           --3.90%--ip_finish_output
   |              |          
   |               --3.88%--ip_finish_output2
   |                  |          
   |                   --2.77%--neigh_connected_output
   |                     |          
   |                      --2.74%--dev_queue_xmit
   |                         |          
   |                          --2.73%--__dev_queue_xmit
   |                             |          
   |                             |--1.66%--dev_hard_start_xmit
   |                             |   |          
   |                             |    --1.64%--vlan_dev_hard_start_xmit
   |                             |       |          
   |                             |        --1.63%--dev_queue_xmit
   |                             |           |          
   |                             |            --1.62%--__dev_queue_xmit
   |                             |               |          
   |                             |               |--0.99%--skb_dst_drop.isra.77
   |                             |               |   |          
   |                             |               |   --0.99%--dst_release
   |                             |               |          
   |                             |                --0.55%--sch_direct_xmit
   |                             |          
   |                              --0.99%--skb_dst_force
   |          
    --1.29%--ip_route_input_noref
        |          
         --1.29%--ip_route_input_rcu
             |          
              --1.05%--rt_cache_valid
