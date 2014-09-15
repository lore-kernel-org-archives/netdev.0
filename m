From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/3] tcp: no longer keep around headers in
 input path
Date: Mon, 15 Sep 2014 14:41:37 -0400 (EDT)
Message-ID: <20140915.144137.278293056053518622.davem@davemloft.net>
References: <1410779993-31464-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com, ncardwell@google.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36357 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753349AbaIOSlk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 14:41:40 -0400
In-Reply-To: <1410779993-31464-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Mon, 15 Sep 2014 04:19:50 -0700

> Looking at tcp_try_coalesce() I was wondering why I did :
> 
> if (tcp_hdr(from)->fin)
>      return false;
> 
> The answer would be to allow the aggregation, if we simply OR the FIN and PSH
> flags eventually present in @from to @to packet. (Note a change is also
> needed in skb_try_coalesce() to avoid calling skb_put() with 0 len)
> 
> Then, looking at tcp_recvmsg(), I realized we access tcp_hdr(skb)->syn
> (and maybe tcp_hdr(skb)->fin) for every packet we process from socket
> receive queue.
> 
> We have to understand TCP flags are cold in cpu caches most of the time
> (assuming TCP timestamps, and that application calls recvmsg() a long
> time after incoming packet was processed), and bringing a whole
> cache line only to access one bit is not very nice.
> 
> It would make sense to use in TCP input path TCP_SKB_CB(skb)->tcp_flags
> as we do in output path.
> 
> This saves one cache line miss, and TCP tcp_collapse() can avoid dealing
> with the headers.

Looks great, applied, thanks Eric.
