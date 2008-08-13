From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: CPU utilization increased in 2.6.27rc
Date: Wed, 13 Aug 2008 14:34:59 -0700
Message-ID: <20080813143459.1fb1c5c5@extreme>
References: <48A23137.2010107@myri.com>
	<20080812.181549.229367205.davem@davemloft.net>
	<48A30834.4090802@myri.com>
	<18595.15208.734736.864386@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Gallatin <gallatin@myri.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Robert.Olsson@data.slu.se
To: Robert Olsson <robert@robur.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:56768 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751655AbYHMVfC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 17:35:02 -0400
In-Reply-To: <18595.15208.734736.864386@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 Aug 2008 21:52:08 +0200
Robert Olsson <robert@robur.slu.se> wrote:

> 
> Andrew Gallatin writes:
>  > 
>  > Excellent!  This completely fixes the increased CPU
>  > utilization I observed on both 10GbE and 1GbE interfaces,
>  > and CPU utilization is now reduced back to 2.6.26 levels.
> 
> 
>  > > Robert, this could explain some of the things in the
>  > > multiqueue testing profile you sent me a week or so
>  > > ago.
> 
> I've just rerun the virtual 10g router experiment with the current
> git including the pkt_sched patch. The full experiment is below. In this 
> case the profile looks the same as before. No improvement due to this
> patch here.
> 
> In this case we have not any old numbers to compare with as we're 
> testing new functionality. I'm not to unhappy about the performance 
> and there must be some functions the in profile... 
> 
> Virtual IP forwarding experiment. We're splitting an incoming flow
> load (10g) among 4 CPU's and keep the incoming flows per-CPU including
> TX and also skb clearing 
> 
> 
> Network flow load into (eth0) 10G 82598. Total 295+293+293+220 kpps 
> 4 * (4096 concurrent flows at 30 pkts)
> 
> eth0   1500   0 3996889      0   1280      0      19      0      0      0 BMRU
> eth1   1500   0       1      0      0      0 3998236      0      0      0 BMRU
> 
> I've configured RSS with ixgbe so all 4 CPU's are used and hacked driver 
> so skb gets tagged with incoming CPU. The 2:nd col in softnet_stat is used 
> to verify tagging and affinity is correct until hard_xmit and even for TX-skb 
> cleaning to avoid all cache misses and true per-CPU forwarding. The ixgbe driver
> 1.3.31.5 from Intel's site is needed for RSS etc and bit modified for this test.
> 
> softnet_stat
> 000f3236 001e63f8 00000872 00000000 00000000 00000000 00000000 00000000 00000000
> 000f52df 001ea58c 000008b8 00000000 00000000 00000000 00000000 00000000 00000000
> 000f3d90 001e7af8 00000a3b 00000000 00000000 00000000 00000000 00000000 00000000
> 000f4174 001e82c2 00000a17 00000000 00000000 00000000 00000000 00000000 00000000
> 
> eth0 (incoming)
> 214:          4          0          0       6623   PCI-MSI-edge      eth0:v3-Rx
> 215:          0          5       6635          0   PCI-MSI-edge      eth0:v2-Rx
> 216:          0       7152          5          0   PCI-MSI-edge      eth0:v1-Rx
> 217:       7115          0          0          5   PCI-MSI-edge      eth0:v0-Rx
> 
> eth1 (outgoing)
> 201:          3          0          0       3738   PCI-MSI-edge      eth1:v7-Tx
> 202:          0          4       3743          0   PCI-MSI-edge      eth1:v6-Tx
> 203:          0       3743          4          0   PCI-MSI-edge      eth1:v5-Tx
> 204:       3746          0          0          6   PCI-MSI-edge      eth1:v4-Tx
> 
> CPU: AMD64 processors, speed 3000 MHz (estimated)
> Counted CPU_CLK_UNHALTED events (Cycles outside of halt state) with a unit mask of 0x00 (No unit mask) count 3000
> samples  %        image name               app name                 symbol name
> 407896    8.7211  vmlinux                  vmlinux                  cache_alloc_refill
> 339524    7.2592  vmlinux                  vmlinux                  __qdisc_run
> 243352    5.2030  vmlinux                  vmlinux                  dev_queue_xmit
> 227855    4.8717  vmlinux                  vmlinux                  kfree
> 214975    4.5963  vmlinux                  vmlinux                  __alloc_skb
> 172008    3.6776  vmlinux                  vmlinux                  cache_flusharray

I see you are still using the SLAB allocator. Does the SLUB change the numbers?
