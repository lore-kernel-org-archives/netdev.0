From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC] unix: account skb memory to receiving socket's
 sk_rmem_alloc on sending
Date: Tue, 26 Mar 2013 08:53:38 -0700
Message-ID: <1364313218.1716.37.camel@edumazet-glaptop>
References: <20130204231414.GD6898@order.stressinduktion.org>
	 <20130309214333.GI28531@order.stressinduktion.org>
	 <1362889861.4051.15.camel@edumazet-glaptop>
	 <20130310044043.GB2709@order.stressinduktion.org>
	 <20130311193704.GA24481@order.stressinduktion.org>
	 <20130326001740.GB29705@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yannick@koehler.name,
	xiyou.wangcong@gmail.com, davem@davemloft.net
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f51.google.com ([209.85.210.51]:49210 "EHLO
	mail-da0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964940Ab3CZPxm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 11:53:42 -0400
Received: by mail-da0-f51.google.com with SMTP id g27so3603704dan.24
        for <netdev@vger.kernel.org>; Tue, 26 Mar 2013 08:53:41 -0700 (PDT)
In-Reply-To: <20130326001740.GB29705@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-03-26 at 01:17 +0100, Hannes Frederic Sowa wrote:

> This is the newest version of this patch. I only stripped out the setting
> of the SOCK_USE_WRITE_QUEUE socket flag (I was unsure if otherwise
> sock_wfree needed the socket lock but I am pretty confident that is
> is not needed). Perhaps someone finds some time to have a look at this
> patch. Also, if you come up with things my test case does not cover yet
> please let me know and I will catch up with the tests.
> 
> Patch is based on net-next.
> 
> Thanks!
> 
> [PATCH RFC] unix: account skb memory to receiving socket's sk_rmem_alloc on sending
> 
> In case of unix datagram sockets, skb memory was only accounted in the
> sending socket's sk_wmem_alloc. Hence, if one receiver would stop to
> receive frames on its socket, the sending socket's send buffer space
> could get exhausted and the socket would block sending datagrams to
> other destionations, too.
> 
> This patch places the refcounted peer's unix address for AF_UNIX
> SOCK_DGRAM sockets into the skb's UNIXCB. So a reference from the skb
> to the receiving struct sock can be set and so enables to do proper skb
> destructor handling for rmem and wmem. Buffer memory is then accounted
> to the receiving socket. If the socket rmem is exhausted the normal
> blocking and timeout behaviour kicks in.
> 
> Resource exhausion protection for unix dgram sockets is now based
> only on sockets rmem checking. Unix dgram sockets do not rely on
> sk_max_ack_backlog anymore. The controls for this are
> /proc/sys/net/core/{r,w}mem_{default,max}.
> 
> This patch also changes the reporting of unix dgram rqueue size, as it
> now reports not only the size of the first fragment but the amount of
> readable memory for the socket.
> 
> Based on the patches from Yannick Koehler and Cong Wang.

This opens the possibility of a sender to flood a receiver, instead of
being blocked by its own sndbuf.

Do we want such regression ? How many applications might rely on
existing behavior ?

Its not clear what is the appropriate way to handle this.
