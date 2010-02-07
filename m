From: Chris Caputo <ccaputo@alt.net>
Subject: Re: bonding forwarding perf issues in 2.6.32.7 & 2.6.29.6
Date: Sun, 7 Feb 2010 06:52:00 +0000 (UTC)
Message-ID: <Pine.LNX.4.64.1002070616470.15390@nacho.alt.net>
References: <Pine.LNX.4.64.1002060641380.14159@nacho.alt.net>
	<1125.1265474211@death.nxdomain.ibm.com>
Reply-To: Chris Caputo <ccaputo-dated-1268117520.8281d9@alt.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nacho.alt.net ([208.90.169.18]:60236 "EHLO nacho.alt.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751464Ab0BGGwB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Feb 2010 01:52:01 -0500
In-Reply-To: <1125.1265474211@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 6 Feb 2010, Jay Vosburgh wrote:
> Chris Caputo <ccaputo@alt.net> wrote:
> >Kernel 2.6.32.7 (and 2.6.32.5 & 2.6.29.6) on a 2x Intel Xeon E5420 
> >(Quad-Core 2.5Ghz), SuperMicro X7DBE+, 32GB (16 * 2GB) DDR2-667MHz.
> >
> >I have a router with a variety of e1000 and e1000e based interfaces.
> >
> >bond0 is a 2xGigE (82571EB) with two active slaves.
> >
> >bond1 has up to 3 slaves (2x 80003ES2LAN/82563, 82546EB).
> >
> >Both are configured with miimon=100, balance-xor, layer3+4.
> >
> >When bond1 has just a single active slave, outbound (and possibly inbound) 
> >forwarding performance on bond1 is better than when it has two or three 
> >active slaves.  Ie., when I activate the second slave, by enabling the 
> >port on the switch it is connected to, forwarding performance drops 
> >dramatically across the full bond1.
> 
> 	What exactly do you mean by "forwarding performance drops
> dramatically"?  How are you measuring this?

I have TCP flows continuously coming in through this router to internal 
servers.

On a second by second basis, parsing ifconfig output as an example, I can 
see the flow rates through the router, ex:

  RX: 360 mbits/sec  TX: 462 mbits/sec
  RX: 350 mbits/sec  TX: 527 mbits/sec
  RX: 361 mbits/sec  TX: 462 mbits/sec
  [...]
	
When I go from a single GigE slave to 2x or 3xGigE, there is a noticeable 
drop in throughput.  That could be explained by decreased retransmits due 
to less packet loss on a less congested link, but I am able to discern 
that is not happening based on how the internal servers store the data.  
(They receive the data, and then store the data to storage servers using 
another NIC.)

As a demonstration, when I had 3xGigE bond1 going on the router, 
throughput on one of the storage server was as follows:

  [10 second averages]
  RX: 207 mbits/sec  TX: 3 mbits/sec
  RX: 206 mbits/sec  TX: 3 mbits/sec
  RX: 208 mbits/sec  TX: 3 mbits/sec
  RX: 202 mbits/sec  TX: 3 mbits/sec
  RX: 208 mbits/sec  TX: 3 mbits/sec
  RX: 202 mbits/sec  TX: 3 mbits/sec
  RX: 197 mbits/sec  TX: 3 mbits/sec

When I then disabled all but one of the GigE's for bond1 on the router, 
the release of back-pressure on the incoming TCP flows was immediately 
visible through increased writes to this storage server:

  [10 second averages]
  RX: 144 mbits/sec  TX: 2 mbits/sec
  RX: 355 mbits/sec  TX: 6 mbits/sec
  RX: 387 mbits/sec  TX: 7 mbits/sec
  RX: 325 mbits/sec  TX: 6 mbits/sec
  RX: 365 mbits/sec  TX: 6 mbits/sec
  RX: 317 mbits/sec  TX: 5 mbits/sec
  RX: 318 mbits/sec  TX: 5 mbits/sec

  (I think the dip to 144 mbits was the result of the NIC status changes.)

This is repeatable, and going the other way (GigE -> 3xGigE) also shows a 
visible drop in throughput.

Also, I tried balance-rr, rather than balance-xor, and that didn't help.

I would suspect motherboard bus limitations, except that I am able run 
netperf unidirectional UDP tests that on a round-robin 3xGigE result in 
more than 800 mbps on each interface, which is far more than the TCP flows 
that appear to have back-pressure when I engage bonding.

> 	Also, just to confirm, are the switch ports connected to the
> respective bonds also grouped on the switch?  The balance-xor mode is
> meant to interop with an Etherchannel compatible switch port
> aggregation.

Yes, the switch is an HP2848 with the 3 GigE's configured as a trunk.

> >Locally originated packets do not seem to be harmed by the second GigE 
> >coming online.  From what I have observed, the issue is with forwarding.  
> >The majority of the forwarding traffic is coming in on bond0 and egressing 
> >on bond1.
> 
> 	Perhaps it has something to do with forwarding causing LRO to be
> disabled.

All three interfaces have LRO off:

  rx-checksumming: on
  tx-checksumming: on
  scatter-gather: on
  tcp-segmentation-offload: off
  udp-fragmentation-offload: off
  generic-segmentation-offload: on
  generic-receive-offload: off
  large-receive-offload: off

Thanks,
Chris

> 	-J
> 
> >I have tried changing IRQ binding in a variety of ways (same CPU, same 
> >core, different cores, paired based on bond, irqbalance) and it hasn't 
> >helped.
> >
> >I have tried having one of bond1's GigEs be on a separate bus with a 
> >separate NIC, to no avail.
> >
> >Oprofiling (data below) does not reveal much time is being spent in the 
> >bonding driver.  bond_start_xmit() is the peak for the bonding driver, at 
> >less than 1% regardless of how many interfaces are bound.
> >
> >Does anyone have any tips on how I should try to narrow down this further?
> >
> >Thanks,
> >Chris
> >
> >---
> >
> >bond1 with just one 80003ES2LAN/82563 active:
> >
> >samples  %        image name               app name                 symbol name
> >114103   13.4161  vmlinux-2.6.32.7         vmlinux-2.6.32.7         ipt_do_table
> >24447     2.8745  e1000e.ko                e1000e.ko                e1000_xmit_frame
> >23687     2.7851  vmlinux-2.6.32.7         vmlinux-2.6.32.7         dev_queue_xmit
> >19088     2.2444  e1000e.ko                e1000e.ko                e1000_clean_tx_irq
> >18820     2.2128  vmlinux-2.6.32.7         vmlinux-2.6.32.7         skb_copy_bits
> >16028     1.8846  vmlinux-2.6.32.7         vmlinux-2.6.32.7         skb_segment
> >15013     1.7652  vmlinux-2.6.32.7         vmlinux-2.6.32.7         __slab_free
> >14187     1.6681  vmlinux-2.6.32.7         vmlinux-2.6.32.7         __slab_alloc
> >13649     1.6048  vmlinux-2.6.32.7         vmlinux-2.6.32.7         mwait_idle
> >13177     1.5493  e1000e.ko                e1000e.ko                e1000_irq_enable
> >13017     1.5305  bgpd                     bgpd                     bgp_process_announce_selected
> >12242     1.4394  vmlinux-2.6.32.7         vmlinux-2.6.32.7         __alloc_skb
> >11186     1.3152  vmlinux-2.6.32.7         vmlinux-2.6.32.7         ip_vs_in
> >11054     1.2997  vmlinux-2.6.32.7         vmlinux-2.6.32.7         find_vma
> >10861     1.2770  vmlinux-2.6.32.7         vmlinux-2.6.32.7         ip_rcv
> >10724     1.2609  vmlinux-2.6.32.7         vmlinux-2.6.32.7         nf_iterate
> >10659     1.2533  vmlinux-2.6.32.7         vmlinux-2.6.32.7         kmem_cache_alloc
> >
> >bond1 with a 80003ES2LAN/82563 and a 82546EB active:
> >
> >samples  %        image name               app name                 symbol name
> >36249    14.1261  vmlinux-2.6.32.7         vmlinux-2.6.32.7         ipt_do_table
> >5985      2.3323  vmlinux-2.6.32.7         vmlinux-2.6.32.7         skb_copy_bits
> >5731      2.2333  vmlinux-2.6.32.7         vmlinux-2.6.32.7         __slab_free
> >5496      2.1418  e1000.ko                 e1000.ko                 e1000_clean
> >5489      2.1390  vmlinux-2.6.32.7         vmlinux-2.6.32.7         dev_queue_xmit
> >5247      2.0447  vmlinux-2.6.32.7         vmlinux-2.6.32.7         mwait_idle
> >5090      1.9835  e1000e.ko                e1000e.ko                e1000_xmit_frame
> >5025      1.9582  e1000e.ko                e1000e.ko                e1000_irq_enable
> >4777      1.8616  vmlinux-2.6.32.7         vmlinux-2.6.32.7         __slab_alloc
> >4714      1.8370  e1000e.ko                e1000e.ko                e1000_clean_tx_irq
> >4102      1.5985  e1000.ko                 e1000.ko                 e1000_intr
> >4004      1.5603  vmlinux-2.6.32.7         vmlinux-2.6.32.7         skb_segment
> >3924      1.5292  e1000e.ko                e1000e.ko                e1000_intr_msi
> >3867      1.5070  vmlinux-2.6.32.7         vmlinux-2.6.32.7         __alloc_skb
> >3424      1.3343  e1000.ko                 e1000.ko                 e1000_xmit_frame
> >3225      1.2568  vmlinux-2.6.32.7         vmlinux-2.6.32.7         find_vma
> >3148      1.2268  vmlinux-2.6.32.7         vmlinux-2.6.32.7         kfree
> >
> >bond1 with 2x 80003ES2LAN/82563 active and a 82546EB active:
> >
> >samples  %        image name               app name                 symbol name
> >28124    14.5651  vmlinux-2.6.32.7         vmlinux-2.6.32.7         ipt_do_table
> >5725      2.9649  e1000e.ko                e1000e.ko                e1000_irq_enable
> >5077      2.6293  vmlinux-2.6.32.7         vmlinux-2.6.32.7         mwait_idle
> >4374      2.2652  vmlinux-2.6.32.7         vmlinux-2.6.32.7         skb_copy_bits
> >4277      2.2150  e1000e.ko                e1000e.ko                e1000_intr_msi
> >4224      2.1876  e1000e.ko                e1000e.ko                e1000_xmit_frame
> >3863      2.0006  vmlinux-2.6.32.7         vmlinux-2.6.32.7         __slab_free
> >3826      1.9814  e1000e.ko                e1000e.ko                e1000_clean_tx_irq
> >3682      1.9069  vmlinux-2.6.32.7         vmlinux-2.6.32.7         dev_queue_xmit
> >3512      1.8188  vmlinux-2.6.32.7         vmlinux-2.6.32.7         __slab_alloc
> >3191      1.6526  e1000.ko                 e1000.ko                 e1000_clean
> >3042      1.5754  e1000.ko                 e1000.ko                 e1000_intr
> >2540      1.3154  vmlinux-2.6.32.7         vmlinux-2.6.32.7         __alloc_skb
> >2425      1.2559  vmlinux-2.6.32.7         vmlinux-2.6.32.7         ip_rcv
> >2406      1.2460  vmlinux-2.6.32.7         vmlinux-2.6.32.7         skb_segment
> >2333      1.2082  vmlinux-2.6.32.7         vmlinux-2.6.32.7         nf_iterate
> >2329      1.2062  vmlinux-2.6.32.7         vmlinux-2.6.32.7         ip_vs_in
