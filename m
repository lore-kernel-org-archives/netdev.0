From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next v3] tcp: use zero-window when free_space is low
Date: Wed, 19 Feb 2014 16:48:25 -0500 (EST)
Message-ID: <20140219.164825.1739772069060903135.davem@davemloft.net>
References: <1392810670-3543-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, ycheng@google.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47109 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752863AbaBSVs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 16:48:27 -0500
In-Reply-To: <1392810670-3543-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Wed, 19 Feb 2014 12:51:10 +0100

> Currently the kernel tries to announce a zero window when free_space
> is below the current receiver mss estimate.
> 
> When a sender is transmitting small packets and reader consumes data
> slowly (or not at all), receiver might be unable to shrink the receive
> win because
> 
> a) we cannot withdraw already-commited receive window, and,
> b) we have to round the current rwin up to a multiple of the wscale
>    factor, else we would shrink the current window.
> 
> This causes the receive buffer to fill up until the rmem limit is hit.
> When this happens, we start dropping packets.
> 
> Moreover, tcp_clamp_window may continue to grow sk_rcvbuf towards rmem[2]
> even if socket is not being read from.
> 
> As we cannot avoid the "current_win is rounded up to multiple of mss"
> issue [we would violate a) above] at least try to prevent the receive buf
> growth towards tcp_rmem[2] limit by attempting to move to zero-window
> announcement when free_space becomes less than 1/16 of the current
> allowed receive buffer maximum.  If tcp_rmem[2] is large, this will
> increase our chances to get a zero-window announcement out in time.
> 
> Reproducer:
> On server:
> $ nc -l -p 12345
> <suspend it: CTRL-Z>
> 
> Client:
> #!/usr/bin/env python
> import socket
> import time
> 
> sock = socket.socket()
> sock.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
> sock.connect(("192.168.4.1", 12345));
> while True:
>    sock.send('A' * 23)
>    time.sleep(0.005)
> 
> 
> socket buffer on server-side will grow until tcp_rmem[2] is hit,
> at which point the client rexmits data until -EDTIMEOUT:
> 
> tcp_data_queue invokes tcp_try_rmem_schedule which will call
> tcp_prune_queue which calls tcp_clamp_window().  And that function will
> grow sk->sk_rcvbuf up until it eventually hits tcp_rmem[2].
> 
> Thanks to Eric Dumazet for running regression tests.
> 
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Acked-by: Eric Dumazet <edumazet@google.com>
> Tested-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  no changes since v2; resend with Erics Ack/Tested-by tags
>  V1 of this patch was deferred, resending to get discussion going again.
>  Changes since v1:
>   - add reproducer to commit message

Applied, thanks!
