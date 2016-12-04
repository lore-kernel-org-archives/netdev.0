From: Neal Cardwell <ncardwell@google.com>
Subject: Re: Trigger EHOSTUNREACH
Date: Sun, 4 Dec 2016 12:51:33 -0500
Message-ID: <CADVnQy=HT1oH491s3nxrLTp1Q3C3KorMr3v9OHXr40Wr_cfTJg@mail.gmail.com>
References: <CAP__gDkhM82EP6pP0NBHAYME0iPkEf49aeOp9C3dYQcCpdetrA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>
To: Marco Zunino <eng.marco.zunino@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:35768 "EHLO
        mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751070AbcLDRwE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2016 12:52:04 -0500
Received: by mail-oi0-f53.google.com with SMTP id b126so317315032oia.2
        for <netdev@vger.kernel.org>; Sun, 04 Dec 2016 09:52:04 -0800 (PST)
In-Reply-To: <CAP__gDkhM82EP6pP0NBHAYME0iPkEf49aeOp9C3dYQcCpdetrA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 4, 2016 at 7:04 AM, Marco Zunino <eng.marco.zunino@gmail.com> wrote:
> Hallo everyone, hope you are having a good day
> we are building a networking testing tool to simulate network error
> condition, and we are having difficulties triggering the EHOSTUNREACH
> socket error.
>
> We are trying to trigger this error by sending an ICMP packet type=3
> code=3 on an open STREAM socket, but it has no effect.
>
> Based on RFC1122 and the code here
>
> https://github.com/torvalds/linux/blob/e76d21c40bd6c67fd4e2c1540d77e113df962b4d/net/ipv4/tcp_ipv4.c#L353
>
> I would expect the this ICMP packet to abort the socket connection
> with a EHOSTUNREACH error on the client side, but this does not
> happen.

In my quick tests with packetdrill, it looks like Linux will not
immediately pass EHOSTUNREACH to the application unless the
application has requested this with setsockopt(SOL_IP, IP_RECVERR).

Specifically, the following packetdrill test passes for me:
---
0.000 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
   +0 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
   +0 bind(3, ..., ...) = 0
   +0 listen(3, 1) = 0

   +0 < S 0:0(0) win 32792 <mss 1000,sackOK,nop,nop,nop,wscale 7>
   +0 > S. 0:0(0) ack 1 <mss 1460,nop,nop,sackOK,nop,wscale 8>
+.020 < . 1:1(0) ack 1 win 257
   +0 accept(3, ..., ...) = 4
   +0 setsockopt(4, SOL_IP, IP_RECVERR, [1], 4) = 0
   +0 write(4, ..., 1000) = 1000
   +0 > P. 1:1001(1000) ack 1

+.010 < icmp unreachable host_unreachable [1:1461(1460)]

   +0 write(4, ..., 1) = -1 EHOSTUNREACH (No route to host)
---

But without the setsockopt(SOL_IP, IP_RECVERR) there is no error upon
the second write().

My reading of RFC 1122 is that this is consistent with the RFC.

RFC 1122 section 3.2.2.1 says:

            A Destination Unreachable message that is received with code
            0 (Net), 1 (Host), or 5 (Bad Source Route) may result from a
            routing transient and MUST therefore be interpreted as only
            a hint, not proof, that the specified destination is
            unreachable [IP:11].

So it seems that the RFC is suggesting that by default an ICMP host
unreachable should not cause an immediate error for the connection.
Instead, it should be used as a hint as to the cause of the problem if
TCP's normal reliable delivery mechanisms ultimately timeout and fail.

neal
