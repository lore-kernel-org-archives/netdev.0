From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skb: Propagate pfmemalloc on skb from head page only
Date: Thu, 14 Mar 2013 11:54:41 -0400 (EDT)
Message-ID: <20130314.115441.1016076054622568752.davem@davemloft.net>
References: <5141D0C4.70409@parallels.com>
	<1363270569.29475.11.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@parallels.com, mgorman@suse.de, netdev@vger.kernel.org,
	stable@kernel.org, kuznet@ms2.inr.ac.ru
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35053 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932394Ab3CNPy2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 11:54:28 -0400
In-Reply-To: <1363270569.29475.11.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 14 Mar 2013 15:16:09 +0100

> On Thu, 2013-03-14 at 17:29 +0400, Pavel Emelyanov wrote:
>> Hi.
>> 
>> I'm trying to send big chunks of memory from application address space via
>> TCP socket using vmsplice + splice like this
>> 
>>    mem = mmap(128Mb);
>>    vmsplice(pipe[1], mem); /* splice memory into pipe */
>>    splice(pipe[0], tcp_socket); /* send it into network */
>> 
>> When I'm lucky and a huge page splices into the pipe and then into the socket
>> _and_ client and server ends of the TCP connection are on the same host,
>> communicating via lo, the whole connection gets stuck! The sending queue
>> becomes full and app stops writing/splicing more into it, but the receiving
>> queue remains empty, and that's why.
>> 
>> The __skb_fill_page_desc observes a tail page of a huge page and erroneously
>> propagates its page->pfmemalloc value onto socket (the pfmemalloc on tail pages
>> contain garbage). Then this skb->pfmemalloc leaks through lo and due to the
>> 
>>     tcp_v4_rcv
>>     sk_filter
>>         if (skb->pfmemalloc && !sock_flag(sk, SOCK_MEMALLOC)) /* true */
>>             return -ENOMEM
>>         goto release_and_discard;
>> 
>> no packets reach the socket. Even TCP re-transmits are dropped by this, as skb
>> cloning clones the pfmemalloc flag as well.
>> 
>> That said, here's the proper page->pfmemalloc propagation onto socket: we
>> must check the huge-page's head page only, other pages' pfmemalloc and mapping
>> values do not contain what is expected in this place. However, I'm not sure
>> whether this fix is _complete_, since pfmemalloc propagation via lo also 
>> oesn't look great.
>> 
>> Both, bit propagation from page to skb and this check in sk_filter, were 
>> introduced by c48a11c7 (netvm: propagate page->pfmemalloc to skb), in v3.5 so
>> Mel and stable@ are in Cc.
>> 
>> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
 ...
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks.
