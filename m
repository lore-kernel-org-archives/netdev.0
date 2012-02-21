From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] datagram: Extend the datagram queue MSG_PEEK-ing
Date: Tue, 21 Feb 2012 00:01:01 -0500 (EST)
Message-ID: <20120221.000101.921848983774820950.davem@davemloft.net>
References: <4F352182.6060601@parallels.com>
	<20120215.155226.1446930776120577759.davem@davemloft.net>
	<4F4239C7.6040905@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, tj@kernel.org, netdev@vger.kernel.org
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52523 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750696Ab2BUFBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 00:01:11 -0500
In-Reply-To: <4F4239C7.6040905@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Mon, 20 Feb 2012 16:17:11 +0400

> I was thinking about another option of doing the same, how about introducing
> the peek offset member on sock (get/set via sockopt) which works like
> 
> * if == -1, then peek works as before
> * if >= 0, then each peek/recvmsg will increase/decrease the value so that
>   the next peek peeks next data
> 
> It's questionable what to do if the peek_off points into the middle of a
> datagram however. Here's an example of how this looks for datagram sockets
> (tested on pf_unix), for stream this requires more patching.
> 
> What do you think? Does it make sense to go on with this making other 
> ->recvmsg handlers support peeking offset?

I think you need to add some kind of locking to this for sanity, for
example right now you're doing test/decide/store decisions over
sk_peek_off inside of __skb_recv_datagram() without the socket lock,
yet another thread can set the SO_PEEK_OFF in parallel.

The locking decision will probably be worse for stream sockets.
