From: Marco Zunino <eng.marco.zunino@gmail.com>
Subject: Re: Trigger EHOSTUNREACH
Date: Mon, 5 Dec 2016 20:06:55 +0100
Message-ID: <CAP__gDk9ub2DVry0Uvit_oB8zCYV3V+XxwF53au8ZOh8rjZ-WQ@mail.gmail.com>
References: <CAP__gDkhM82EP6pP0NBHAYME0iPkEf49aeOp9C3dYQcCpdetrA@mail.gmail.com>
 <CADVnQy=HT1oH491s3nxrLTp1Q3C3KorMr3v9OHXr40Wr_cfTJg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        Bharadwaj Desikan <bharadwajdes2@gmail.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f181.google.com ([209.85.210.181]:35242 "EHLO
        mail-wj0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751260AbcLETHQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 14:07:16 -0500
Received: by mail-wj0-f181.google.com with SMTP id v7so298950053wjy.2
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2016 11:06:57 -0800 (PST)
In-Reply-To: <CADVnQy=HT1oH491s3nxrLTp1Q3C3KorMr3v9OHXr40Wr_cfTJg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Neal, thank you!
I can succesfully repoduce the following socket error now after
setting the IP_RECVERR socket option:

    ICMP type=3, code=1 -> EHOSTUNREACH
    ICMP type=3, code=2 -> ENOPROTOOPT
    ICMP type=3, code=3 -> ECONNREFUSED
    ICMP type=3, code=4 -> No error
    ICMP type=3, code=5 -> ENOTSUP
    ICMP type=3, code=6 -> ENETUNREACH
    ICMP type=3, code=7 -> EHOSTDOWN
    ICMP type=3, code=8 -> ENONET

In my case, the errors are triggered while in recv(). I did not know
packetdrill, so I am triggering this error using our own tool.

I tried to send an ICMP type=3 code=1 on an ESTABLISHED TCP connection
opened by Chrome browser, and after about 20 minutes, I get
ERR_ADDRESS_UNREACHABLE error in the browser screen. It is curious how
it does not fail with a  CONNECTION_TIMEOUT, I think this reflect your
interpretation of RFC 1122 section 3.2.2.1.

If I try to run your packetdrill test case, I get an error: unknown
symbol: 'IP_RECVERR'.
In the testcase, I tried to replace IP_RECVERR with the corresponding
value '0x0b', but in this case the write() does not return any error.


On Sun, Dec 4, 2016 at 6:51 PM, Neal Cardwell <ncardwell@google.com> wrote:
> On Sun, Dec 4, 2016 at 7:04 AM, Marco Zunino <eng.marco.zunino@gmail.com> wrote:
>> Hallo everyone, hope you are having a good day
>> we are building a networking testing tool to simulate network error
>> condition, and we are having difficulties triggering the EHOSTUNREACH
>> socket error.
>>
>> We are trying to trigger this error by sending an ICMP packet type=3
>> code=3 on an open STREAM socket, but it has no effect.
>>
>> Based on RFC1122 and the code here
>>
>> https://github.com/torvalds/linux/blob/e76d21c40bd6c67fd4e2c1540d77e113df962b4d/net/ipv4/tcp_ipv4.c#L353
>>
>> I would expect the this ICMP packet to abort the socket connection
>> with a EHOSTUNREACH error on the client side, but this does not
>> happen.
>
> In my quick tests with packetdrill, it looks like Linux will not
> immediately pass EHOSTUNREACH to the application unless the
> application has requested this with setsockopt(SOL_IP, IP_RECVERR).
>
> Specifically, the following packetdrill test passes for me:
> ---
> 0.000 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
>    +0 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
>    +0 bind(3, ..., ...) = 0
>    +0 listen(3, 1) = 0
>
>    +0 < S 0:0(0) win 32792 <mss 1000,sackOK,nop,nop,nop,wscale 7>
>    +0 > S. 0:0(0) ack 1 <mss 1460,nop,nop,sackOK,nop,wscale 8>
> +.020 < . 1:1(0) ack 1 win 257
>    +0 accept(3, ..., ...) = 4
>    +0 setsockopt(4, SOL_IP, IP_RECVERR, [1], 4) = 0
>    +0 write(4, ..., 1000) = 1000
>    +0 > P. 1:1001(1000) ack 1
>
> +.010 < icmp unreachable host_unreachable [1:1461(1460)]
>
>    +0 write(4, ..., 1) = -1 EHOSTUNREACH (No route to host)
> ---
>
> But without the setsockopt(SOL_IP, IP_RECVERR) there is no error upon
> the second write().
>
> My reading of RFC 1122 is that this is consistent with the RFC.
>
> RFC 1122 section 3.2.2.1 says:
>
>             A Destination Unreachable message that is received with code
>             0 (Net), 1 (Host), or 5 (Bad Source Route) may result from a
>             routing transient and MUST therefore be interpreted as only
>             a hint, not proof, that the specified destination is
>             unreachable [IP:11].
>
> So it seems that the RFC is suggesting that by default an ICMP host
> unreachable should not cause an immediate error for the connection.
> Instead, it should be used as a hint as to the cause of the problem if
> TCP's normal reliable delivery mechanisms ultimately timeout and fail.
>
> neal
