From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: allow splice() to build full TSO packets
Date: Tue, 03 Apr 2012 17:21:26 -0400 (EDT)
Message-ID: <20120403.172126.672236532461758456.davem@davemloft.net>
References: <1333481821.18626.322.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, therbert@google.com,
	ycheng@google.com, hkchu@google.com, maze@google.com,
	maheshb@google.com, ilpo.jarvinen@helsinki.fi, nanditad@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38370 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751552Ab2DCVVl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 17:21:41 -0400
In-Reply-To: <1333481821.18626.322.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 03 Apr 2012 21:37:01 +0200

> vmsplice()/splice(pipe, socket) call do_tcp_sendpages() one page at a
> time, adding at most 4096 bytes to an skb. (assuming PAGE_SIZE=4096)
> 
> The call to tcp_push() at the end of do_tcp_sendpages() forces an
> immediate xmit when pipe is not already filled, and tso_fragment() try
> to split these skb to MSS multiples.
> 
> 4096 bytes are usually split in a skb with 2 MSS, and a remaining
> sub-mss skb (assuming MTU=1500)

Interesting.

But why doesn't TCP_NAGLE_CORK save us?  That gets passed down into
the push pending frames logic when MSG_MORE is specified.

As far as I can tell, the combination of TCP_NAGLE_CORK and the TSO
deferral logic should do the right thing here.

Obviously you see different behavior, but why?

Also, by eliding the tcp_push() call you are introducing other side
effects:

1) we won't do the tcp_mark_push logic

2) we don't set the URG seq

I think #2 can never happen in the vmsplice/splice path, but #1 might
matter.

That's why I want to concentrate on why the tcp_push() path doesn't
behave properly when MSG_MORE is set.
