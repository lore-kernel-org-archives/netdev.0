From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC] network driver skb allocations
Date: Mon, 03 May 2010 20:49:26 +0100
Message-ID: <1272916166.27948.62.camel@localhost>
References: <1272906384.2226.80.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:9924 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751286Ab0ECTta (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 15:49:30 -0400
In-Reply-To: <1272906384.2226.80.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-05-03 at 19:06 +0200, Eric Dumazet wrote:
[...]
> Current logic for drivers is to :
> 
> allocate skbs (sk_buff + data) and put them in a ring buffer.

Not all of them.

> When rx interrupt comes, get the skb and give it to stack.
> 
> Allocate a new skb (sk_buff + data) and put it in rx fat ring buffer (511 entries for tg3 )
> 
> This is suboptimal, because sk_buff will probably be cold 512 rx later...
> Also, NUMA info might be wrong : sk_buff should be allocated on current node,
> not on the device preferred node.

This also avoids allocating sk_buffs that are never needed due to GRO or
scattering of jumbo frames.

> Drivers should allocate only the data part for NIC, and at the time of interrupt,
> allocate the skb_buff and link it to buffer filled by NIC.

I think we found that this increases latency, so sfc switches between
page and skb allocations dynamically.

Ben.

> With a prefetch(first_cache_line_of_data) before doing sk_buff allocation and init,
> eth_type_trans() / get_rps_cpus() would be much faster.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

