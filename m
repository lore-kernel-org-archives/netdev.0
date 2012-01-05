From: Brent Cook <bcook@breakingpoint.com>
Subject: Re: Possible DoS with 6RD border relay
Date: Wed, 4 Jan 2012 22:22:52 -0600
Message-ID: <201201042222.53147.bcook@breakingpoint.com>
References: <201201041048.44509.bcook@breakingpoint.com> <1325699600.2428.39.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <201201041326.04403.bcook@breakingpoint.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.breakingpoint.com ([65.36.7.12]:7206 "EHLO
	mail.breakingpoint.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757849Ab2AEEX0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2012 23:23:26 -0500
In-Reply-To: <201201041326.04403.bcook@breakingpoint.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, January 04, 2012 01:26:04 PM Brent Cook wrote:
> On Wednesday, January 04, 2012 11:53:20 AM Eric Dumazet wrote:
> > 
> > I am not sure of this.
> > 
> > Try to change /proc/sys/net/ipv6/route/max_size
> > 
> > and /proc/sys/net/ipv6/route/gc_thresh
> > 
> > [To something larger than number of in flight packets on your gateway ]
> 
> Thanks for the suggestion, I tried 200k:
> 
> root@target1:~# echo 200000 > /proc/sys/net/ipv6/route/max_size
> root@target1:~# echo 200000 > /proc/sys/net/ipv6/route/gc_thresh
> 
> It did not seem to improve the behavior - once neighbor table overflow
> hits, things go downhill.  So far, only modifying the neighbor cache
> threshold seems to improve things.

After some more examination, it appears that the extra neighbor entries are 
only allocated for traffic flowing from the native IPv6 host to the 6rd 
client. Packets generated from the 6rd client to the native IPv6 host did not 
experience a problem by themselves. I originally tested bidirectional TCP 
traffic, but switching to unidirection UDP to isolate the routing paths.

 Pid: 0, comm: swapper/3 Not tainted 3.2.0-rc7 #8
 Call Trace:
  <IRQ>  
  [<ffffffffa013a476>] ? rt6_bind_peer+0x36/0x80 [ipv6]
  [<ffffffff8153bed0>] neigh_create+0x30/0x550  
  [<ffffffff8153923d>] ? neigh_lookup+0xcd/0x100  
  [<ffffffffa013a182>] rt6_alloc_cow+0x202/0x240 [ipv6]  
  [<ffffffffa013aa0b>] ip6_pol_route.isra.36+0x38b/0x3a0 [ipv6]
  [<ffffffffa013aa7d>] ip6_pol_route_input+0x2d/0x30 [ipv6]
  [<ffffffffa015caa1>] fib6_rule_action+0xd1/0x1f0 [ipv6]
  [<ffffffffa013aa50>] ? ip6_pol_route_output+0x30/0x30 [ipv6]
  [<ffffffff815316b1>] ? dev_queue_xmit+0x1c1/0x630
  [<ffffffff81546acd>] fib_rules_lookup+0xcd/0x150
  [<ffffffffa015ce64>] fib6_rule_lookup+0x44/0x80 [ipv6]
  [<ffffffffa013aa50>] ? ip6_pol_route_output+0x30/0x30 [ipv6]
  [<ffffffffa013ab44>] ip6_route_input+0xc4/0xf0 [ipv6]
  [<ffffffffa0130177>] ipv6_rcv+0x317/0x3c0 [ipv6]
  [<ffffffff8152ed1a>] __netif_receive_skb+0x51a/0x5c0  
  [<ffffffff8152f990>] netif_receive_skb+0x80/0x90  
  [<ffffffff8152fd89>] ? dev_gro_receive+0x1b9/0x2c0
  [<ffffffff8152fad0>] napi_skb_finish+0x50/0x70
  [<ffffffff81530005>] napi_gro_receive+0xb5/0xc0
  [<ffffffffa001034b>] e1000_receive_skb+0x5b/0x70 [e1000e]
  [<ffffffffa0012122>] e1000_clean_rx_irq+0x352/0x460 [e1000e]
  [<ffffffffa00117f8>] e1000_clean+0x78/0x2b0 [e1000e]
  [<ffffffff81530214>] net_rx_action+0x134/0x290
  [<ffffffff8106c4f8>] __do_softirq+0xa8/0x210    
  [<ffffffff8160736e>] ? _raw_spin_lock+0xe/0x20
  [<ffffffff816116ac>] call_softirq+0x1c/0x30  
  [<ffffffff81015195>] do_softirq+0x65/0xa0
  [<ffffffff8106c8de>] irq_exit+0x8e/0xb0  
  [<ffffffff81611f63>] do_IRQ+0x63/0xe0
  [<ffffffff8160782e>] common_interrupt+0x6e/0x6e

Is this expected behavior? All of the peers in this case are really the same 
6RD client - it's really simulating a customer edge router with a few thousand 
hosts behind it. I suspect that adding a static route entry for the CE's 
prefix via 'sit' will also make the problem go away.
