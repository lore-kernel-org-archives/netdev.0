From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] tcp: refine TSO autosizing
Date: Tue, 09 Dec 2014 16:39:44 -0500 (EST)
Message-ID: <20141209.163944.2168015976309810889.davem@davemloft.net>
References: <1417788937.4322.21.camel@edumazet-glaptop2.roam.corp.google.com>
	<1417832560.15618.29.camel@edumazet-glaptop2.roam.corp.google.com>
	<1417983738.15618.38.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, ycheng@google.com,
	nanditad@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39046 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752647AbaLIVjr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 16:39:47 -0500
In-Reply-To: <1417983738.15618.38.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 07 Dec 2014 12:22:18 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Commit 95bd09eb2750 ("tcp: TSO packets automatic sizing") tried to
> control TSO size, but did this at the wrong place (sendmsg() time)
> 
> At sendmsg() time, we might have a pessimistic view of flow rate,
> and we end up building very small skbs (with 2 MSS per skb).
> 
> This is bad because :
> 
>  - It sends small TSO packets even in Slow Start where rate quickly
>    increases.
>  - It tends to make socket write queue very big, increasing tcp_ack()
>    processing time, but also increasing memory needs, not necessarily
>    accounted for, as fast clones overhead is currently ignored.
>  - Lower GRO efficiency and more ACK packets.
> 
> Servers with a lot of small lived connections suffer from this.
> 
> Lets instead fill skbs as much as possible (64KB of payload), but split
> them at xmit time, when we have a precise idea of the flow rate.
> skb split is actually quite efficient.
> 
> Patch looks bigger than necessary, because TCP Small Queue decision now
> has to take place after the eventual split.
> 
> As Neal suggested, introduce a new tcp_tso_autosize() helper, so that
> tcp_tso_should_defer() can be synchronized on same goal.
> 
> Rename tp->xmit_size_goal_segs to tp->gso_segs, as this variable
> contains number of mss that we can put in GSO packet, and is not
> related to the autosizing goal anymore.
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> ---
> v3: tcp_xmit_size_goal() still needs to return a multiple of mss.
> v2: added tcp_tso_autosize() helper and removed tp->xmit_size_goal_segs

Applied, thanks Eric.
