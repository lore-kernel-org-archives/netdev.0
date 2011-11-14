From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 1/2] net: introduce build_skb()
Date: Mon, 14 Nov 2011 17:08:59 +0000
Message-ID: <1321290539.2827.10.camel@bwh-desktop>
References: <1321286614.2272.47.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <eilong@broadcom.com>,
	<pstaszewski@itcare.pl>, <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Jamal Hadi Salim <hadi@mojatatu.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Thomas Graf <tgraf@infradead.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:17240 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753373Ab1KNRJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 12:09:08 -0500
In-Reply-To: <1321286614.2272.47.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-11-14 at 17:03 +0100, Eric Dumazet wrote:
> One of the thing we discussed during netdev 2011 conference was the idea
> to change some network drivers to allocate/populate their skb at RX
> completion time, right before feeding the skb to network stack.
> 
> In old days, we allocated skbs when populating the RX ring.
> 
> This means bringing into cpu cache sk_buff and skb_shared_info cache
> lines (since we clear/initialize them), then 'queue' skb->data to NIC.
> 
> By the time NIC fills a frame in skb->data buffer and host can process
> it, cpu probably threw away the cache lines from its caches, because lot
> of things happened between the allocation and final use.

This is definitely a win so long as skbs are getting merged by GRO.
However, those cache misses take less time than skb allocation, so
preallocation of skbs normally reduces latency.  This is why sfc has an
adaptive buffer allocation behaviour.

> So the deal would be to allocate only the data buffer for the NIC to
> populate its RX ring buffer. And use build_skb() at RX completion to
> attach a data buffer (now filled with an ethernet frame) to a new skb,
> initialize the skb_shared_info portion, and give the hot skb to network
> stack.
> 
> build_skb() is the function to allocate an skb, caller providing the
> data buffer that should be attached to it. Drivers are expected to call 
> skb_reserve() right after build_skb() to adjust skb->data to the
> Ethernet frame (usually skipping NET_SKB_PAD and NET_IP_ALIGN, but some
> drivers might add a hardware provided alignment)
[...]

The option to attach a heap-allocated buffer rather than allocating a
header buffer and attaching a page might shift the balance.  I'll have
to test this (but don't hold your breath).

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
