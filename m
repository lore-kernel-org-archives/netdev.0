From: Larry Baker <baker@usgs.gov>
Subject: decnet: warning for dst_metric(&rt->dst, RTAX_MTU)
Date: Mon, 11 Feb 2013 17:29:29 -0800
Message-ID: <F631B84F-839A-4071-AB8E-2C0193CBEC6C@usgs.gov>
Mime-Version: 1.0 (Apple Message framework v1085)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gscamnlh01.wr.usgs.gov ([130.118.9.68]:47436 "EHLO
	gscamnlh01.wr.usgs.gov" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932675Ab3BLB3b convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 20:29:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am seeing the warning messages below for the decnet kernel module on my Arch Linux ARM 3.1.10 system (Linux sheeva 3.1.10-15-ARCH #1 PREEMPT Wed Dec 12 15:25:18 UTC 2012 armv5tel GNU/Linux).  These messages do not appear for my DECnet systems running older kernels: CentOS 6.3 x86_64 system (Linux atompc.wr.usgs.gov 2.6.32-279.19.1.el6.x86_64 #1 SMP Wed Dec 19 07:05:20 UTC 2012 x86_64 x86_64 x86_64 GNU/Linux) and my (really old, I know) CentOS 4.8 x86_64 system (Linux wavelet.wr.usgs.gov 2.6.9-89.0.19.ELsmp #1 SMP Fri Jan 8 06:30:48 EST 2010 x86_64 x86_64 x86_64 GNU/Linux).

The warning is benign, as far as the operation of DECnet; my systems are working with our DEC VAXes and Alphas.  (Thank you very much!)

------------[ cut here ]------------
WARNING: at include/net/dst.h:178 dn_rt_set_next_hop+0xb8/0x1a0 [decnet]()
Modules linked in: ipt_REJECT xt_tcpudp nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack iptable_filter ip_tables x_tables ipv6 decnet mv_cesa nfs nfs_acl auth_rpcgss lockd sunrpc autofs4
[<c000d290>] (unwind_backtrace+0x0/0xe0) from [<c001e0dc>] (warn_slowpath_common+0x4c/0x64)
[<c001e0dc>] (warn_slowpath_common+0x4c/0x64) from [<c001e10c>] (warn_slowpath_null+0x18/0x1c)
[<c001e10c>] (warn_slowpath_null+0x18/0x1c) from [<bf0e118c>] (dn_rt_set_next_hop+0xb8/0x1a0 [decnet])
[<bf0e118c>] (dn_rt_set_next_hop+0xb8/0x1a0 [decnet]) from [<bf0e1a98>] (dn_route_input+0x33c/0x448 [decnet])
[<bf0e1a98>] (dn_route_input+0x33c/0x448 [decnet]) from [<bf0e1e24>] (dn_route_rx_packet+0x10/0x30c [decnet])
[<bf0e1e24>] (dn_route_rx_packet+0x10/0x30c [decnet]) from [<c03402e8>] (__netif_receive_skb+0x5c4/0x660)
[<c03402e8>] (__netif_receive_skb+0x5c4/0x660) from [<c02c87b4>] (mv643xx_eth_poll+0x4f0/0x654)
[<c02c87b4>] (mv643xx_eth_poll+0x4f0/0x654) from [<c03426c4>] (net_rx_action+0x94/0x304)
[<c03426c4>] (net_rx_action+0x94/0x304) from [<c0024a4c>] (__do_softirq+0x100/0x250)
[<c0024a4c>] (__do_softirq+0x100/0x250) from [<c0024fd4>] (irq_exit+0x48/0xa4)
[<c0024fd4>] (irq_exit+0x48/0xa4) from [<c00093d8>] (handle_IRQ+0x64/0x84)
[<c00093d8>] (handle_IRQ+0x64/0x84) from [<c03d24d4>] (__irq_svc+0x34/0x98)
[<c03d24d4>] (__irq_svc+0x34/0x98) from [<c0009634>] (cpu_idle+0x60/0xb8)
[<c0009634>] (cpu_idle+0x60/0xb8) from [<c052f750>] (start_kernel+0x2c0/0x31c)
---[ end trace f08022188f9dd652 ]---

The backtrace is from the dst_metric(&rt->dst, RTAX_MTU) call in dn_rt_set_next_hop() in net/decnet/dn_route.c.  dst_metric() is inlined from include/net/dst.h.  Sure enough, it says

	WARN_ON_ONCE(metric == RTAX_HOPLIMIT ||
		     metric == RTAX_ADVMSS ||
		     metric == RTAX_MTU);

>From what I could find searching with Google, dst_metric() was introduced as a replacement for direct access to dst->metric[].  Later, it seems other helper functions were added for the cases covered by WARN_ON_ONCE() that now appears in dst_metric().  (My CentOS 6.3 kernel does not have the WARN_ON_ONCE() filter, which explains why the same code has no warnings there.)

The simplest fix I can see is to replace any dst_metric() calls for RTAX_HOPLIMIT, RTAX_ADVMSS, and RTAX_MTU with calls to dst_metric_raw().  (Which is what happens anyway.)  This is the fix I see in net/ipv4/route.c.  (FYI: I noticed the line "metrics[RTAX_MTU - 1] = rt->rt_pmtu;" in net/ipv4/route.c.  This surprised me.)

Larry Baker
US Geological Survey
650-329-5608
baker@usgs.gov
