From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next 1/3] net/tcp_fastopen: Disable active side TFO in
 certain scenarios
Date: Thu, 20 Apr 2017 22:40:32 -0400
Message-ID: <CADVnQyk6MEFpKg_qzLySYJcXT_zsb-bGYaBWUiOX=aEJkCafJQ@mail.gmail.com>
References: <20170420214548.23666-1-tracywwnj@gmail.com> <20170420214548.23666-2-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Yuchung Cheng <ycheng@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Wei Wang <weiwan@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:33535 "EHLO
        mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034435AbdDUClE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 22:41:04 -0400
Received: by mail-oi0-f47.google.com with SMTP id y11so43754573oie.0
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 19:41:04 -0700 (PDT)
In-Reply-To: <20170420214548.23666-2-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 20, 2017 at 5:45 PM, Wei Wang <weiwan@google.com> wrote:
> From: Wei Wang <weiwan@google.com>
>
> Middlebox firewall issues can potentially cause server's data being
> blackholed after a successful 3WHS using TFO. Following are the related
> reports from Apple:
> https://www.nanog.org/sites/default/files/Paasch_Network_Support.pdf
> Slide 31 identifies an issue where the client ACK to the server's data
> sent during a TFO'd handshake is dropped.
> C ---> syn-data ---> S
> C <--- syn/ack ----- S
> C (accept & write)
> C <---- data ------- S
> C ----- ACK -> X     S
>                 [retry and timeout]
>
> https://www.ietf.org/proceedings/94/slides/slides-94-tcpm-13.pdf
> Slide 5 shows a similar situation that the server's data gets dropped
> after 3WHS.
> C ---- syn-data ---> S
> C <--- syn/ack ----- S
> C ---- ack --------> S
> S (accept & write)
> C?  X <- data ------ S
>                 [retry and timeout]
>
> This is the worst failure b/c the client can not detect such behavior to
> mitigate the situation (such as disabling TFO). Failing to proceed, the
> application (e.g., SSL library) may simply timeout and retry with TFO
> again, and the process repeats indefinitely.
>
> The proposed solution is to disable active TFO globally under the
> following circumstances:
> 1. client side TFO socket detects out of order FIN
> 2. client side TFO socket receives out of order RST
>
> We disable active side TFO globally for 1hr at first. Then if it
> happens again, we disable it for 2h, then 4h, 8h, ...
> And we reset the timeout to 1hr if a client side TFO sockets not opened
> on loopback has successfully received data segs from server.
> And we examine this condition during close().
>
> The rational behind it is that when such firewall issue happens,
> application running on the client should eventually close the socket as
> it is not able to get the data it is expecting. Or application running
> on the server should close the socket as it is not able to receive any
> response from client.
> In both cases, out of order FIN or RST will get received on the client
> given that the firewall will not block them as no data are in those
> frames.
> And we want to disable active TFO globally as it helps if the middle box
> is very close to the client and most of the connections are likely to
> fail.
>
> Also, add a debug sysctl:
>   tcp_fastopen_blackhole_detect_timeout_sec:
>     the initial timeout to use when firewall blackhole issue happens.
>     This can be set and read.
>     When setting it to 0, it means to disable the active disable logic.
>
> Signed-off-by: Wei Wang <weiwan@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
