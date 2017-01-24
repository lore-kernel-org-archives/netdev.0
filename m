From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/3] net/tcp-fastopen: Add new API support
Date: Tue, 24 Jan 2017 10:51:25 -0800
Message-ID: <1485283885.16328.319.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170123185922.48046-1-tracywwnj@gmail.com>
         <20170123185922.48046-4-tracywwnj@gmail.com>
         <20170123211623.GE20894@1wt.eu>
         <1485279889.16328.306.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170124183446.GE21921@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Wei Wang <tracywwnj@gmail.com>, netdev@vger.kernel.org,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>, Wei Wang <weiwan@google.com>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33279 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750775AbdAXSv1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 13:51:27 -0500
Received: by mail-pf0-f193.google.com with SMTP id e4so12590719pfg.0
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 10:51:27 -0800 (PST)
In-Reply-To: <20170124183446.GE21921@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-01-24 at 19:34 +0100, Willy Tarreau wrote:
> Hi Eric,
> 
> On Tue, Jan 24, 2017 at 09:44:49AM -0800, Eric Dumazet wrote:
> > I believe there is a bug in this application.
> > 
> > It does not check connect() return value.
> 
> Yes in fact it does but I noticed the same thing, there's something causing
> the event not to be registered or something like this.
> 
> > When 0 is returned, it makes no sense to wait 200 ms :
> > 
> > > 06:29:24.048593 epoll_ctl(3, EPOLL_CTL_ADD, 9, {EPOLLIN|EPOLLRDHUP, {u32=9, u64=9}}) = 0
> > > 06:29:24.048651 epoll_wait(3, [], 200, 0) = 0
> > > 06:29:24.048699 getsockopt(10, SOL_SOCKET, SO_ERROR, [0], [4]) = 0
> > 
> > And it makes no sense to call connect() again :
> > 
> > > 06:29:24.048751 connect(10, {sa_family=AF_INET, sin_port=htons(8001), sin_addr=inet_addr("127.0.0.1")}, 16) = -1 EINPROGRES
> > > S (Operation now in progress)
> 
> I totally agree.
> 
> > man connect
> > 
> > <quote>
> > Generally,  connection-based protocol sockets may successfully connect()
> > only once;
> > </quote>
> > 
> > 
> > I would prefer we do not add yet another bit in tcp kernel sockets, to
> > work around some oddity in your program Willy.
> 
> I'm fine with chasing the bug on my side and fixing it, but there's a
> semantic trouble anyway with returning -EINPROGRESS :
>   - connect() = 0 indicates that the connection is established
>   - then a further connect() should return -EISCONN, and does so when
>     not using TFO
> 
> man connect says this regarding EINPROGRESS :
> 
>     The socket is nonblocking and the connection cannot be completed immediately.
>     It is possible to  select(2)  or  poll(2)  for completion  by  selecting  the
>     socket  for  writing.  After  select(2) indicates writability, use getsockopt(2)
>     to read the SO_ERROR option at level SOL_SOCKET to determine whether connect()
>     completed successfully (SO_ERROR is  zero)  or  unsuccess-fully (SO_ERROR is
>     one of the usual error codes listed here, explaining the reason for the failure).
> 
> Here we clearly have an incompatibility between this EINPROGRESS saying
> that we must poll, and poll returning POLLOUT suggesting that it's now
> OK.
> 
> I'm totally fine with not using an extra bit in a scarce area, but then
> we can either add an extra argument to __inet_stream_connect() to say
> "this is sendmsg" or just add an extra flag in the last argument.
> 
> But in general I don't feel comfortable with a semantics that doesn't
> completely match the current and documented one :-/
> 
> Thanks,
> Willy


We do not return -1 / EINPROGRESS but 0

Do not call connect() twice, it is clearly not supposed to work.

Fact that it happened to work is still kept for applications not using
new features (like TCP_FASTOPEN_CONNECT), we wont break this.

I would prefer you submit _if_ needed a patch on top of Wei patch, which
was carefully tested with our ~500 packetdrill tests.



TCP_FASTOPEN_CONNECT + connect() returning 0 is already a violation of
past behavior, in the sense that no connection really happened yet.

An application exploiting this return value and consider the server is
reachable would be mistaken.

We do not support connect() + TCP_FASTOPEN_CONNECT + read(), because we
do not want to add yet another conditional test in recvmsg() fast path
for such feature, while existing sendmsg() can already be used to send a
SYN with FastOpen option.

So people are not expected to blindly add TCP_FASTOPEN_CONNECT to every
TCP socket they allocate/use. This would add too much bloat to the
kernel.
