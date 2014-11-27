From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 0/3] net: Alloc NAPI page frags from their own pool
Date: Thu, 27 Nov 2014 13:00:57 +0100
Message-ID: <20141127130057.5403429c@redhat.com>
References: <20141126235900.1617.10008.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, eric.dumazet@gmail.com,
	ast@plumgrid.com, brouer@redhat.com
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37566 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753382AbaK0MBH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Nov 2014 07:01:07 -0500
In-Reply-To: <20141126235900.1617.10008.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 26 Nov 2014 16:05:50 -0800
Alexander Duyck <alexander.h.duyck@redhat.com> wrote:

> This patch series implements a means of allocating page fragments without
> the need for the local_irq_save/restore in __netdev_alloc_frag.  By doing
> this I am able to decrease packet processing time by 11ns per packet in my
> test environment.

This is really good work!

I've tested the patchset (detail see below).  Two different packet
sizes 64bytes and 272bytes, due to "copy-break" point in driver.

Notice, these tests are single flow, resulting in single CPU getting
activated on receiver.

If I drop packets very early in iptables "raw" table, I see an
improvement 10.51 ns to 13.22 ns (for 272bytes between 9.64 ns to 11.97
ns).  Which corrospond with Alex'es observations.

A little surprising, when doing full forwarding (IP-routing), I see a
much larger "nanosec" improvement, for 64bytes of between 47.64ns to
58.15ns (for 272bytes between 29.08ns to 30.14ns).  This improvement is
larger than I expected.  One pitfall is with full forwarding, we can
only forwards approx 1Mpps (single CPU), and the accuracy between tests
runs vary more.

Setup
-----
Generator: ixgbe, pktgen (3x CPUs), sending 10G wirespeed
 - Single flow pktgen, resulting in single CPU activation on target
 - pkt@64bytes:  tx:14900856 pps (wirespeed)
 - pkt@272bytes: tx: 4228696 pps (wirespeed)

Ethernet wirespeed:
 * (1/((64+20)*8))*(10*10^9)  = 14880952
 * (1/((272+20)*8))*(10*10^9) =  4280822

Receiver CPU E5-2695 running state-c0@2.8GHz

baseline
--------

Baseline: Full forwarding (no-netfilter):

 * pkt@64bytes: tx:977414 pps
 * pkt@64bytes: tx:974404 pps
 * test-variation@64bytes: 3010pps (1/977414*10^9)-(1/974404*10^9) = -3.16ns

 * pkt@272bytes: tx:911657 pps
 * pkt@272bytes: tx:906229 pps
 * test-variation@272bytes: 5428pps -6.57ns

Baseline: Drop in iptables RAW:

 * pkt@64bytes: rx:2801058 pps
 * pkt@64bytes: rx:2785579 pps
 * test-variation@64bytes: 15479pps -1.98 ns

 * pkt@272bytes: rx:2559718 pps
 * pkt@272bytes: rx:2544577 pps
 * test-variation@64bytes diff: 6230pps 0.746ns

With patch: alex'es napi_alloc_skb
----------------------------------

Full forwarding (no-netfilter) (pkt@64bytes):

 * pkt@64bytes: tx:1025150 pps
 * pkt@64bytes: tx:1032930 pps
 * test-variation@64bytes: -7780pps 7.34ns
 * Patchset improvements@64-fwd:
 - 977414 -> 1025150 = 47736pps -> 47.64ns
 - 974404 -> 1032930 = 58526pps -> 58.15ns

 * pkt@272bytes: tx:937416 pps
 * pkt@272bytes: tx:930761 pps
 * test-variation@272bytes: 6655pps -7.62ns
 * Patchset improvements@272-fwd:
  - 911657 -> 937416 = 25759pps -> 30.14ns
  - 906229 -> 930761 = 24532pps -> 29.08ns

Drop in iptables RAW (pkt@64bytes):

 * pkt@64bytes: rx:2885820 pps
 * pkt@64bytes: rx:2892050 pps
 * test-variation@64bytes diff: 6230pps 0.746ns
 * Patchset improvements@64-drop:
  - 2800896 -> 2885820 =  84924pps -> 10.51 ns
  - 2785579 -> 2892050 = 106471pps -> 13.22 ns

 * pkt@272bytes: rx:2624484 pps
 * pkt@272bytes: rx:2624492 pps
 * test-variation: pkt@272bytes diff: 8pps 0ns
 * Patchset improvements@272-drop:
  - 2624484 -> 2559718 = 64766 pps ->  9.64 ns
  - 2624492 -> 2544577 = 79915 pps -> 11.97 ns


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
