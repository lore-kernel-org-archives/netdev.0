From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH net-next 3/3] net/tcp-fastopen: Add new API support
Date: Tue, 24 Jan 2017 19:34:46 +0100
Message-ID: <20170124183446.GE21921@1wt.eu>
References: <20170123185922.48046-1-tracywwnj@gmail.com>
 <20170123185922.48046-4-tracywwnj@gmail.com>
 <20170123211623.GE20894@1wt.eu>
 <1485279889.16328.306.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wei Wang <tracywwnj@gmail.com>, netdev@vger.kernel.org,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>, Wei Wang <weiwan@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:65009 "EHLO 1wt.eu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750725AbdAXSfA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 13:35:00 -0500
Content-Disposition: inline
In-Reply-To: <1485279889.16328.306.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Tue, Jan 24, 2017 at 09:44:49AM -0800, Eric Dumazet wrote:
> I believe there is a bug in this application.
> 
> It does not check connect() return value.

Yes in fact it does but I noticed the same thing, there's something causing
the event not to be registered or something like this.

> When 0 is returned, it makes no sense to wait 200 ms :
> 
> > 06:29:24.048593 epoll_ctl(3, EPOLL_CTL_ADD, 9, {EPOLLIN|EPOLLRDHUP, {u32=9, u64=9}}) = 0
> > 06:29:24.048651 epoll_wait(3, [], 200, 0) = 0
> > 06:29:24.048699 getsockopt(10, SOL_SOCKET, SO_ERROR, [0], [4]) = 0
> 
> And it makes no sense to call connect() again :
> 
> > 06:29:24.048751 connect(10, {sa_family=AF_INET, sin_port=htons(8001), sin_addr=inet_addr("127.0.0.1")}, 16) = -1 EINPROGRES
> > S (Operation now in progress)

I totally agree.

> man connect
> 
> <quote>
> Generally,  connection-based protocol sockets may successfully connect()
> only once;
> </quote>
> 
> 
> I would prefer we do not add yet another bit in tcp kernel sockets, to
> work around some oddity in your program Willy.

I'm fine with chasing the bug on my side and fixing it, but there's a
semantic trouble anyway with returning -EINPROGRESS :
  - connect() = 0 indicates that the connection is established
  - then a further connect() should return -EISCONN, and does so when
    not using TFO

man connect says this regarding EINPROGRESS :

    The socket is nonblocking and the connection cannot be completed immediately.
    It is possible to  select(2)  or  poll(2)  for completion  by  selecting  the
    socket  for  writing.  After  select(2) indicates writability, use getsockopt(2)
    to read the SO_ERROR option at level SOL_SOCKET to determine whether connect()
    completed successfully (SO_ERROR is  zero)  or  unsuccess-fully (SO_ERROR is
    one of the usual error codes listed here, explaining the reason for the failure).

Here we clearly have an incompatibility between this EINPROGRESS saying
that we must poll, and poll returning POLLOUT suggesting that it's now
OK.

I'm totally fine with not using an extra bit in a scarce area, but then
we can either add an extra argument to __inet_stream_connect() to say
"this is sendmsg" or just add an extra flag in the last argument.

But in general I don't feel comfortable with a semantics that doesn't
completely match the current and documented one :-/

Thanks,
Willy
