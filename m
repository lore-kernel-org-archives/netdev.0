From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] skb: Propagate pfmemalloc on skb from head page only
Date: Thu, 14 Mar 2013 14:28:24 +0000
Message-ID: <20130314142824.GE10369@suse.de>
References: <5141D0C4.70409@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	stable@kernel.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:43546 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756672Ab3CNO2b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Mar 2013 10:28:31 -0400
Content-Disposition: inline
In-Reply-To: <5141D0C4.70409@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 14, 2013 at 05:29:40PM +0400, Pavel Emelyanov wrote:
> Hi.
> 
> I'm trying to send big chunks of memory from application address space via
> TCP socket using vmsplice + splice like this
> 
>    mem = mmap(128Mb);
>    vmsplice(pipe[1], mem); /* splice memory into pipe */
>    splice(pipe[0], tcp_socket); /* send it into network */
> 
> When I'm lucky and a huge page splices into the pipe and then into the socket
> _and_ client and server ends of the TCP connection are on the same host,
> communicating via lo, the whole connection gets stuck! The sending queue
> becomes full and app stops writing/splicing more into it, but the receiving
> queue remains empty, and that's why.
> 
> The __skb_fill_page_desc observes a tail page of a huge page and erroneously
> propagates its page->pfmemalloc value onto socket (the pfmemalloc on tail pages
> contain garbage). Then this skb->pfmemalloc leaks through lo and due to the
> 
>     tcp_v4_rcv
>     sk_filter
>         if (skb->pfmemalloc && !sock_flag(sk, SOCK_MEMALLOC)) /* true */
>             return -ENOMEM
>         goto release_and_discard;
> 
> no packets reach the socket. Even TCP re-transmits are dropped by this, as skb
> cloning clones the pfmemalloc flag as well.
> 
> That said, here's the proper page->pfmemalloc propagation onto socket: we
> must check the huge-page's head page only, other pages' pfmemalloc and mapping
> values do not contain what is expected in this place. However, I'm not sure
> whether this fix is _complete_, since pfmemalloc propagation via lo also 
> oesn't look great.
> 
> Both, bit propagation from page to skb and this check in sk_filter, were 
> introduced by c48a11c7 (netvm: propagate page->pfmemalloc to skb), in v3.5 so
> Mel and stable@ are in Cc.
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
> 

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs
