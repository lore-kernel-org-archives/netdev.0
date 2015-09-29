From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: avoid reorders for TFO passive
 connections
Date: Mon, 28 Sep 2015 22:11:45 -0700 (PDT)
Message-ID: <20150928.221145.1804590785343592452.davem@davemloft.net>
References: <1443140165.29850.181.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53883 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993AbbI2FLq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 01:11:46 -0400
In-Reply-To: <1443140165.29850.181.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 24 Sep 2015 17:16:05 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> We found that a TCP Fast Open passive connection was vulnerable
> to reorders, as the exchange might look like
> 
> [1] C -> S S <FO ...> <request>
> [2] S -> C S. ack request <options>
> [3] S -> C . <answer>
> 
> packets [2] and [3] can be generated at almost the same time.
> 
> If C receives the 3rd packet before the 2nd, it will drop it as
> the socket is in SYN_SENT state and expects a SYNACK.
> 
> S will have to retransmit the answer.
> 
> Current OOO avoidance in linux is defeated because SYNACK
> packets are attached to the LISTEN socket, while DATA packets
> are attached to the children. They might be sent by different cpus,
> and different TX queues might be selected.
> 
> It turns out that for TFO, we created a child, which is a
> full blown socket in TCP_SYN_RECV state, and we simply can attach
> the SYNACK packet to this socket.
> 
> This means that at the time tcp_sendmsg() pushes DATA packet,
> skb->ooo_okay will be set iff the SYNACK packet had been sent
> and TX completed.
> 
> This removes the reorder source at the host level.
> 
> We also removed the export of tcp_try_fastopen(), as it is no
> longer called from IPv6.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Applied, thanks.
