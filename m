From: Flavio Leitner <fbl@redhat.com>
Subject: Re: RSS is not efficient when forwarding (ixgbe)
Date: Fri, 4 Jul 2014 16:36:44 -0300
Message-ID: <20140704193644.GB2343@t520.home>
References: <20140703224408.GA2343@t520.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51489 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752602AbaGDTgr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jul 2014 15:36:47 -0400
Content-Disposition: inline
In-Reply-To: <20140703224408.GA2343@t520.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 03, 2014 at 07:44:08PM -0300, Flavio Leitner wrote:
> 
> Hi,
> 
> I have a simple router setup which forwards traffic from
> one ixgbe 82599ES to another ixgbe of the same model.
> 
> kernel: 3.16.0-rc2-00262-ga921e2a
> 
>   p2p1: 192.168.155.1/24 is the gateway of the LAN
>   p2p2: 192.168.156.1/24 is the gateway of the other LAN
> 
> While the ARP is resolving, I can see the packets being spread
> among all the 8 queues (8 online CPUs) available and that is fine.
> 
> However, as soon as the TCP traffic starts, all streams are
> merged to rx-queue-0 which overwhelms one single CPU, so the
> total throughput is about 4Gbits/sec.
> 
> I can see the driver sending different skb->hash for each stream,
> so it can't be the NIC.
> 
> Also, if I run a local http on the router, the skb->hash pattern
> doesn't change, but the workload is spread among all CPUs.
> 
> debug output while reproducing all the streams on rx-queue-0:
> [...]
> [11685.885093] ixgbe_rx_skb:1713 skb(ffff880222a77200) hash: 0xC2AF4A27
> [11685.891454] ixgbe_rx_skb:1713 skb(ffff880222a77200) hash: 0x8C5B749D
> [11685.897820] ixgbe_rx_skb:1713 skb(ffff880222a77200) hash: 0xA33BA6D5
> [11690.845032] net_ratelimit: 3276406 callbacks suppressed
> [...]

The command 'ehtool -S p2p1 | grep rx_queue' shows only rx queue #0
receiving packets.  Also, /proc/interrupts shows only p2p1-TxRx-0
generating interrupts.

Nothing changes when I start irqbalance in the middle of the test.
However, if I create new streams, they are correctly distributed
among the NIC queues/irqs/CPUs.

I have tried the same setup and test with another card (bnx2, 1GbE)
and all queues got traffic by default though they were all assigned
to CPU#0 (no irqbalance), so this is expected and makes me think
this is specific to the ixgbe driver.

Any ideas?

Thanks,
fbl
