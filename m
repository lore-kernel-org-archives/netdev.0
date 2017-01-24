From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/3] net/tcp-fastopen: Add new API support
Date: Tue, 24 Jan 2017 09:44:49 -0800
Message-ID: <1485279889.16328.306.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170123185922.48046-1-tracywwnj@gmail.com>
         <20170123185922.48046-4-tracywwnj@gmail.com>
         <20170123211623.GE20894@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Wei Wang <tracywwnj@gmail.com>, netdev@vger.kernel.org,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>, Wei Wang <weiwan@google.com>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35646 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750738AbdAXRov (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 12:44:51 -0500
Received: by mail-pg0-f68.google.com with SMTP id 204so17182572pge.2
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 09:44:51 -0800 (PST)
In-Reply-To: <20170123211623.GE20894@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-01-23 at 22:16 +0100, Willy Tarreau wrote:
> Hi Wei,
> 
> first, thanks a lot for doing this, it's really awesome!
> 
> I'm testing it on 4.9 on haproxy and I met a corner case : when I
> perform a connect() to a server and I have nothing to send, upon
> POLLOUT notification since I have nothing to send I simply probe the
> connection using connect() again to see if it returns EISCONN or
> anything else. But here now I'm seeing EINPROGRESS loops.
> 
> To illustrate this, here's what I'm doing :
> 
>                 :8000          :8001
>   [ client ] ---> [ proxy ] ---> [ server ]
> 
> The proxy is configured to enable TFO to the server and the server
> supports TFO as well. The proxy and the server are in fact two proxy
> instances in haproxy running in the same process for convenience.
> 
> When I already have data to send here's what I'm seeing (so it works fine) :
> 
> 06:29:16.861190 accept4(7, {sa_family=AF_INET, sin_port=htons(33986), sin_addr=inet_addr("192.168.0.176")}, [128->16], SOCK
> _NONBLOCK) = 9
> 06:29:16.861277 setsockopt(9, SOL_TCP, TCP_NODELAY, [1], 4) = 0
> 06:29:16.861342 accept4(7, 0x7ffd0d794430, [128], SOCK_NONBLOCK) = -1 EAGAIN (Resource temporarily unavailable)
> 06:29:16.861417 recvfrom(9, "BLAH\n", 7006, 0, NULL, NULL) = 5
> 06:29:16.861509 recvfrom(9, 0x2619329, 7001, 0, NULL, NULL) = -1 EAGAIN (Resource temporarily unavailable)
> 06:29:16.861657 socket(AF_INET, SOCK_STREAM, IPPROTO_TCP) = 10
> 06:29:16.861730 fcntl(10, F_SETFL, O_RDONLY|O_NONBLOCK) = 0
> 06:29:16.861779 setsockopt(10, SOL_TCP, TCP_NODELAY, [1], 4) = 0
> 06:29:16.861882 setsockopt(10, SOL_TCP, 0x1e /* TCP_??? */, [1], 4) = 0
> 06:29:16.861942 connect(10, {sa_family=AF_INET, sin_port=htons(8001), sin_addr=inet_addr("127.0.0.1")}, 16) = 0
> 06:29:16.862015 epoll_ctl(3, EPOLL_CTL_ADD, 9, {EPOLLIN|EPOLLRDHUP, {u32=9, u64=9}}) = 0
> 06:29:16.862072 epoll_wait(3, [], 200, 0) = 0
> 06:29:16.862126 sendto(10, "BLAH\n", 5, MSG_DONTWAIT|MSG_NOSIGNAL, NULL, 0) = 5
> 06:29:16.862281 epoll_wait(3, [{EPOLLIN, {u32=8, u64=8}}], 200, 0) = 1
> 06:29:16.862334 recvfrom(10, 0x26173a4, 8030, 0, NULL, NULL) = -1 EAGAIN (Resource temporarily unavailable)
> 06:29:16.862385 accept4(8, {sa_family=AF_INET, sin_port=htons(46760), sin_addr=inet_addr("127.0.0.1")}, [128->16], SOCK_NON
> BLOCK) = 11
> 06:29:16.862450 setsockopt(11, SOL_TCP, TCP_NODELAY, [1], 4) = 0
> 06:29:16.862504 accept4(8, 0x7ffd0d794430, [128], SOCK_NONBLOCK) = -1 EAGAIN (Resource temporarily unavailable)
> 06:29:16.862564 recvfrom(11, "BLAH\n", 7006, 0, NULL, NULL) = 5
> 
> 
> When I don't have data, here's what I'm seeing :
> 
> 06:29:24.047801 accept4(7, {sa_family=AF_INET, sin_port=htons(33988), sin_addr=inet_addr("192.168.0.176")}, [128->16], SOCK
> _NONBLOCK) = 9
> 06:29:24.047899 setsockopt(9, SOL_TCP, TCP_NODELAY, [1], 4) = 0
> 06:29:24.047966 accept4(7, 0x7ffdedb2c7f0, [128], SOCK_NONBLOCK) = -1 EAGAIN (Resource temporarily unavailable)
> 06:29:24.048043 recvfrom(9, 0xd31324, 7006, 0, NULL, NULL) = -1 EAGAIN (Resource temporarily unavailable)
> 06:29:24.048281 socket(AF_INET, SOCK_STREAM, IPPROTO_TCP) = 10
> 06:29:24.048342 fcntl(10, F_SETFL, O_RDONLY|O_NONBLOCK) = 0
> 06:29:24.048392 setsockopt(10, SOL_TCP, TCP_NODELAY, [1], 4) = 0
> 06:29:24.048447 setsockopt(10, SOL_TCP, 0x1e /* TCP_??? */, [1], 4) = 0
> 06:29:24.048508 connect(10, {sa_family=AF_INET, sin_port=htons(8001), sin_addr=inet_addr("127.0.0.1")}, 16) = 0

I believe there is a bug in this application.

It does not check connect() return value.

When 0 is returned, it makes no sense to wait 200 ms :

> 06:29:24.048593 epoll_ctl(3, EPOLL_CTL_ADD, 9, {EPOLLIN|EPOLLRDHUP, {u32=9, u64=9}}) = 0
> 06:29:24.048651 epoll_wait(3, [], 200, 0) = 0
> 06:29:24.048699 getsockopt(10, SOL_SOCKET, SO_ERROR, [0], [4]) = 0

And it makes no sense to call connect() again :

> 06:29:24.048751 connect(10, {sa_family=AF_INET, sin_port=htons(8001), sin_addr=inet_addr("127.0.0.1")}, 16) = -1 EINPROGRES
> S (Operation now in progress)

man connect

<quote>
Generally,  connection-based protocol sockets may successfully connect()
only once;
</quote>


I would prefer we do not add yet another bit in tcp kernel sockets, to
work around some oddity in your program Willy.

> 06:29:24.048808 epoll_ctl(3, EPOLL_CTL_ADD, 10, {EPOLLOUT, {u32=10, u64=10}}) = 0
> 06:29:24.048860 epoll_wait(3, [{EPOLLOUT, {u32=10, u64=10}}], 200, 1000) = 1
> 06:29:24.048912 getsockopt(10, SOL_SOCKET, SO_ERROR, [0], [4]) = 0
> 06:29:24.048963 connect(10, {sa_family=AF_INET, sin_port=htons(8001), sin_addr=inet_addr("127.0.0.1")}, 16) = -1 EINPROGRES
> S (Operation now in progress)
> 06:29:24.049018 epoll_wait(3, [{EPOLLOUT, {u32=10, u64=10}}], 200, 1000) = 1
> 06:29:24.049072 getsockopt(10, SOL_SOCKET, SO_ERROR, [0], [4]) = 0
> 06:29:24.049122 connect(10, {sa_family=AF_INET, sin_port=htons(8001), sin_addr=inet_addr("127.0.0.1")}, 16) = -1 EINPROGRES
> S (Operation now in progress)
> 
> 
> I theorically understand why but I think we have something wrong here
> and instead we should have -1 EISCONN (to pretend the connection is
> established) or return EALREADY (to mention that a previous request was
> already made and that we're waiting for the next step).
> 
> While I can instrument my connect() *not* to use TFO when connecting
> without any pending data, I don't always know this (eg when I use
> openssl and cross fingers so that it decides to quickly send something
> on the next round).
> 
> I think it's easy to fall into this tricky corner case and am wondering
> what can be done about it. Does the EINPROGRESS happen only because there
> is no cookie yet ? If so, shouldn't the connect's status change in this
> case ?
> 
> Thanks,
> Willy
