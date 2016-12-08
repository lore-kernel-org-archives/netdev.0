From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] udp: under rx pressure, try to condense skbs
Date: Thu, 08 Dec 2016 13:26:02 -0500 (EST)
Message-ID: <20161208.132602.1437771867201682270.davem@davemloft.net>
References: <1481131173.4930.36.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pabeni@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36102 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752727AbcLHS0E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 13:26:04 -0500
In-Reply-To: <1481131173.4930.36.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 07 Dec 2016 09:19:33 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Under UDP flood, many softirq producers try to add packets to
> UDP receive queue, and one user thread is burning one cpu trying
> to dequeue packets as fast as possible.
> 
> Two parts of the per packet cost are :
> - copying payload from kernel space to user space,
> - freeing memory pieces associated with skb.
> 
> If socket is under pressure, softirq handler(s) can try to pull in
> skb->head the payload of the packet if it fits.
> 
> Meaning the softirq handler(s) can free/reuse the page fragment
> immediately, instead of letting udp_recvmsg() do this hundreds of usec
> later, possibly from another node.
> 
> 
> Additional gains :
> - We reduce skb->truesize and thus can store more packets per SO_RCVBUF
> - We avoid cache line misses at copyout() time and consume_skb() time,
> and avoid one put_page() with potential alien freeing on NUMA hosts.
> 
> This comes at the cost of a copy, bounded to available tail room, which
> is usually small. (We might have to fix GRO_MAX_HEAD which looks bigger
> than necessary)
> 
> This patch gave me about 5 % increase in throughput in my tests.
> 
> skb_condense() helper could probably used in other contexts.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

This is isolated to UDP, and would be easy to revert if it causes
problems.  So applied, thanks Eric.
