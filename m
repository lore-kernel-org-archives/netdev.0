From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] net-tcp: TCP/IP stack bypass for loopback
 connections
Date: Mon, 17 Sep 2012 22:20:39 +0200
Message-ID: <1347913239.26523.173.camel@edumazet-glaptop>
References: <1347908305-13541-1-git-send-email-brutus@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: "Bruce \"Brutus\" Curtis" <brutus@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:39444 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755707Ab2IQUUt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2012 16:20:49 -0400
Received: by bkwj10 with SMTP id j10so2754533bkw.19
        for <netdev@vger.kernel.org>; Mon, 17 Sep 2012 13:20:47 -0700 (PDT)
In-Reply-To: <1347908305-13541-1-git-send-email-brutus@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-09-17 at 11:58 -0700, Bruce "Brutus" Curtis wrote:
> From: "Bruce \"Brutus\" Curtis" <brutus@google.com>
> 
> TCP/IP loopback socket pair stack bypass, based on an idea by, and
> rough upstream patch from, David Miller <davem@davemloft.net> called
> "friends", the data structure modifcations and connection scheme are
> reused with extensive data-path changes.

...

>  
> +		if (skb->friend) {
> +			/*
> +			 * If friends haven't been made yet, our sk_friend
> +			 * still == NULL, then update with the ACK's friend
> +			 * value (the listen()er's sock addr) which is used
> +			 * as a place holder.
> +			 */
> +			cmpxchg(&sk->sk_friend, NULL, skb->friend);
> +		}


There is a fundamental issue with this patch

Setting skb->friend to a socket structure, without holding a reference
on it is going to add subtle races and bugs.

In this code, we have no guarantee the socket pointed by skb->friend was
eventually freed and/or reused.

But adding references might be overkill, as we need to unref them in
some places, in hot path.
