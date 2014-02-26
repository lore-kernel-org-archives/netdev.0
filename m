From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] unix: add read side socket memory
 accounting for dgram sockets
Date: Wed, 26 Feb 2014 14:55:59 -0500 (EST)
Message-ID: <20140226.145559.1040609936875578841.davem@davemloft.net>
References: <20140217130353.GA22833@order.stressinduktion.org>
	<20140219.144927.1558282069067885839.davem@davemloft.net>
	<20140219200811.GE1179@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yannick@koehler.name,
	eric.dumazet@gmail.com, xiyou.wangcong@gmail.com, dan@mindstab.net
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40466 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750813AbaBZT4E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 14:56:04 -0500
In-Reply-To: <20140219200811.GE1179@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 19 Feb 2014 21:08:11 +0100

> On Wed, Feb 19, 2014 at 02:49:27PM -0500, David Miller wrote:
>> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> Date: Mon, 17 Feb 2014 14:03:53 +0100
>> 
>> > We still allocate dgram packets with sock_alloc_send_pskb, which now
>> > does normally not block if the socket has too many packets in flight.
>> 
>> It seems like it does to me, it does sock_wait_for_wmem(), right?
> 
> We still do the sock_wait_for_wmem in sock_alloc_send_pskb, correct,
> but we rarly block there, maybe in highly concurrent cases with big
> payloads where one process got interrupted to account the memory to the
> receiving socket.
> 
>> Or are you trying to say that usually this is not the point at which
>> we block, but rather it's when we check the peer's receive queue?
> 
> Exactly.

So my only major objection is that we're now going to incur two atomics
on every single datagram UNIX packet sent between two peers.

I think you can safely put the 'other' sock pointer into the control
block.  Because when we disassociate from a peer any pending packets
in flight to him will be consumed/dropped, so there can't be any
lingering references, right?
