From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH v2 net-next 3/3] tcp: better TCP_SKB_CB layout to reduce
 cache line misses
Date: Thu, 25 Sep 2014 17:48:44 +0200
Message-ID: <20140925154844.GM5044@cpaasch-mac>
References: <1411468452-3729-1-git-send-email-edumazet@google.com>
 <1411468452-3729-4-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f170.google.com ([74.125.82.170]:35410 "EHLO
	mail-we0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753821AbaIYPsr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 11:48:47 -0400
Received: by mail-we0-f170.google.com with SMTP id x48so6758252wes.15
        for <netdev@vger.kernel.org>; Thu, 25 Sep 2014 08:48:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1411468452-3729-4-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23/09/14 - 03:34:12, Eric Dumazet wrote:
> TCP maintains lists of skb in write queue, and in receive queues
> (in order and out of order queues)
> 
> Scanning these lists both in input and output path usually requires
> access to skb->next, TCP_SKB_CB(skb)->seq, and TCP_SKB_CB(skb)->end_seq
> 
> These fields are currently in two different cache lines, meaning we
> waste lot of memory bandwidth when these queues are big and flows
> have either packet drops or packet reorders.
> 
> We can move TCP_SKB_CB(skb)->header at the end of TCP_SKB_CB, because
> this header is not used in fast path. This allows TCP to search much faster
> in the skb lists.
> 
> Even with regular flows, we save one cache line miss in fast path.
> 
> Thanks to Christoph Paasch for noticing we need to cleanup
> skb->cb[] (IPCB/IP6CB) before entering IP stack in tx path.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  include/net/tcp.h     | 12 ++++++------
>  net/ipv4/tcp_ipv4.c   |  7 +++++++
>  net/ipv4/tcp_output.c |  5 +++++
>  net/ipv6/tcp_ipv6.c   |  7 +++++++
>  4 files changed, 25 insertions(+), 6 deletions(-)

Hello Eric,

I think that in tcp_v4_hnd_req() and tcp_v4_save_options() we also need to
avoid calling IPCB() and do TCP_SKB_CB(skb)->header.h4.opt instead.


Cheers,
Christoph
