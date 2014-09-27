From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next 3/3] tcp: better TCP_SKB_CB layout to reduce
 cache line misses
Date: Sat, 27 Sep 2014 09:46:25 -0700
Message-ID: <1411836385.16953.138.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411676092-16196-1-git-send-email-edumazet@google.com>
	 <1411676092-16196-4-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Christoph Paasch <christoph.paasch@uclouvain.be>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:40215 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751985AbaI0Qq2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Sep 2014 12:46:28 -0400
Received: by mail-pa0-f53.google.com with SMTP id kq14so3019326pab.12
        for <netdev@vger.kernel.org>; Sat, 27 Sep 2014 09:46:28 -0700 (PDT)
In-Reply-To: <1411676092-16196-4-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-09-25 at 13:14 -0700, Eric Dumazet wrote:
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
> skb->cb[] (IPCB/IP6CB) before entering IP stack in tx path,
> and that I forgot IPCB use in tcp_v4_hnd_req() and tcp_v4_save_options().
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---

Silly me, I'll send a v4, sorry for the noise

net/ipv4/tcp_ipv4.c: In function 'tcp_v4_save_options':
net/ipv4/tcp_ipv4.c:889:33: warning: initialization from incompatible pointer type [enabled by default]
net/ipv4/tcp_ipv4.c: In function 'tcp_v4_hnd_req':
net/ipv4/tcp_ipv4.c:1432:43: warning: passing argument 3 of 'cookie_v4_check' from incompatible pointer type [enabled by default]
In file included from net/ipv4/tcp_ipv4.c:69:0:
include/net/tcp.h:474:14: note: expected 'struct ip_options *' but argument is of type 'struct inet_skb_parm *'
