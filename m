From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH] tcp: call tcp_replace_ts_recent() from tcp_ack()
Date: Fri, 19 Apr 2013 12:33:41 -0400
Message-ID: <CADVnQymOBoJ9687qn9-fQCXdMcuaP23-bP-Y1ZS0aoYqCdaFVg@mail.gmail.com>
References: <1366384390.16391.17.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f53.google.com ([74.125.83.53]:41147 "EHLO
	mail-ee0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758401Ab3DSQdm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 12:33:42 -0400
Received: by mail-ee0-f53.google.com with SMTP id d17so1163601eek.26
        for <netdev@vger.kernel.org>; Fri, 19 Apr 2013 09:33:41 -0700 (PDT)
In-Reply-To: <1366384390.16391.17.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 19, 2013 at 11:13 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> commit bd090dfc634d (tcp: tcp_replace_ts_recent() should not be called
> from tcp_validate_incoming()) introduced a TS ecr bug in slow path
> processing.
>
> 1 A > B P. 1:10001(10000) ack 1 <nop,nop,TS val 1001 ecr 200>
> 2 B < A . 1:1(0) ack 1 win 257 <sack 9001:10001,TS val 300 ecr 1001>
> 3 A > B . 1:1001(1000) ack 1 win 227 <nop,nop,TS val 1002 ecr 200>
> 4 A > B . 1001:2001(1000) ack 1 win 227 <nop,nop,TS val 1002 ecr 200>
>
> (ecr 200 should be ecr 300 in packets 3 & 4)
>
> Problem is tcp_ack() can trigger send of new packets (retransmits),
> reflecting the prior TSval, instead of the TSval contained in the
> currently processed incoming packet.
>
> Fix this by calling tcp_replace_ts_recent() from tcp_ack() after the
> checks, but before the actions.
>
> Reported-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

This patch looks good. But AFAICT the other call site for
tcp_replace_ts_recent() has the same bug, which can be fixed in the
same way: tcp_rcv_state_process() seems to fall through the big switch
statement down to its call to tcp_replace_ts_recent() even in some
cases where tcp_ack() already decided the ACK was unacceptable.

neal
