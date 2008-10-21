From: Robert Olsson <robert@robur.slu.se>
Subject: Re: [PATCH] sky2: skb recycling
Date: Tue, 21 Oct 2008 13:58:19 +0200
Message-ID: <18685.50139.138839.606865@robur.slu.se>
References: <20081020190922.7dd6510a@extreme>
	<48FD6E8A.6060304@cosmosbay.com>
	<18685.37380.34636.316536@robur.slu.se>
	<48FDA6B6.70905@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from robur.slu.se ([130.238.98.12]:50967 "EHLO robur.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754140AbYJUL6U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Oct 2008 07:58:20 -0400
In-Reply-To: <48FDA6B6.70905@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Eric Dumazet writes:
 > 
 > One CPU does the allocations, (interrupts handled by a given CPU)
 > Another CPU(s) do(es) the freeing
 > 
 > Such scenario is hard for slab/slub because it needs inter-CPU communication, while
 > slub/slab are optimized to deal with per CPU queues/structures (fast path)
 > 
 > skb recycling is an interesting technique because typical NIC handles RX & TX completion
 > in one CPU at the same time, thus we can reduce this slab/slub inter-CPU handling.

 Slab added "Magazine Layer" when we last discussed this. This helped quite a bit. 
 In a longer run we'll decrease this passing of memory object between CPU's. 
 Multiqueue (classifiers in combination affinity) will be a very good start.

 > skb recycling has a (nice ?) side effect on NUMA platforms, not for forwarding workloads,
 > (which are IMHO not the majority of linux machines workloads) but typical servers.
 > 
 > Current NIC drivers actually allocate their RX rings using the memory node
 > close to the device.
 > 
 > With RX recycling, we are re-using skb that were allocated by the process itself,
 > and this process is likely the one that will process received frames.
 > 
 > On loaded machines, I am not sure that NIC having to access to remote nodes is
 > the limiting factor, especially considering modern coalescing/mitigation that tends to
 > delay interrupts anyway (and thus notification to host)

In a bigger system perspective a fear we're getting suboptimal as we are not 
using memory that's in the warm cache. Think we'll need a global recycler for 
this not private per driver or even per device.

FYI. I've experimented quite heavily with skb recycling some years ago but was 
actually quite happy kill this thread as slab memory performance increased.
 
Has all sorts variants skb-reuse:
ftp://robur.slu.se/pub/Linux/net-development/skb_recycling/

Well the major advantage was that PCI-mapping could be reused which was costly 
on some platforms.

Down side is the complexity of having extra memory systems, wrt low memory, cache 
etc. As said I would like to challange slab/slub folks... 


Cheers.
						--ro


