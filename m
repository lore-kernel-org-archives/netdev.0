From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net-tcp: TCP/IP stack bypass for loopback
 connections
Date: Wed, 19 Sep 2012 16:34:06 -0400 (EDT)
Message-ID: <20120919.163406.487082174277409074.davem@davemloft.net>
References: <1347908305-13541-1-git-send-email-brutus@google.com>
	<1347913239.26523.173.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brutus@google.com, edumazet@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57399 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751584Ab2ISUeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 16:34:08 -0400
In-Reply-To: <1347913239.26523.173.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 17 Sep 2012 22:20:39 +0200

> On Mon, 2012-09-17 at 11:58 -0700, Bruce "Brutus" Curtis wrote:
>> From: "Bruce \"Brutus\" Curtis" <brutus@google.com>
>> 
>> TCP/IP loopback socket pair stack bypass, based on an idea by, and
>> rough upstream patch from, David Miller <davem@davemloft.net> called
>> "friends", the data structure modifcations and connection scheme are
>> reused with extensive data-path changes.
> 
> ...
> 
>>  
>> +		if (skb->friend) {
>> +			/*
>> +			 * If friends haven't been made yet, our sk_friend
>> +			 * still == NULL, then update with the ACK's friend
>> +			 * value (the listen()er's sock addr) which is used
>> +			 * as a place holder.
>> +			 */
>> +			cmpxchg(&sk->sk_friend, NULL, skb->friend);
>> +		}
> 
> 
> There is a fundamental issue with this patch
> 
> Setting skb->friend to a socket structure, without holding a reference
> on it is going to add subtle races and bugs.
> 
> In this code, we have no guarantee the socket pointed by skb->friend was
> eventually freed and/or reused.
> 
> But adding references might be overkill, as we need to unref them in
> some places, in hot path.

I have an idea on how to handle this.

In drivers/net/loopback.c:loopback_tx(), skip the SKB orphan operation
if there is a friend socket at skb->friend.

When sending such friend SKBs out at connection startup, arrange it
such that the skb->destructor will zap the skb->friend pointer to
NULL.

Also, in skb_orphan*(), if necessary, set skb->friend to NULL.

skb->sk will hold a reference to the socket, and since skb->friend
will be equal, this will make sure a pointer to an unreferenced
socket does not escape.
