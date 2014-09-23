From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH net-next 3/3] tcp: better TCP_SKB_CB layout to reduce
 cache line misses
Date: Tue, 23 Sep 2014 09:20:16 +0200
Message-ID: <20140923072016.GL3291@cpaasch-mac>
References: <1411429844-11099-1-git-send-email-edumazet@google.com>
 <1411429844-11099-4-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:59157 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752626AbaIWHUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 03:20:20 -0400
Received: by mail-wi0-f169.google.com with SMTP id fb4so4039418wid.0
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2014 00:20:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1411429844-11099-4-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Eric,

On 22/09/14 - 16:50:44, Eric Dumazet wrote:
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
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  include/net/tcp.h   | 12 ++++++------
>  net/ipv4/tcp_ipv4.c |  7 +++++++
>  net/ipv6/tcp_ipv6.c |  7 +++++++
>  3 files changed, 20 insertions(+), 6 deletions(-)

doesn't also the tx-path relies on IPCB(skb) being memset to 0 (e.g., in
xfrm4_output or ip_options_build)

Or is it somewhere already explicitly memset to 0? (didn't found this place
in the code though)


Cheers,
Christoph
