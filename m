From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH next resend] tcp: use zero-window when free_space is low
Date: Thu, 13 Feb 2014 06:58:19 -0800
Message-ID: <1392303499.1752.19.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1392292350-28800-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:47049 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751105AbaBMO6X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 09:58:23 -0500
Received: by mail-pd0-f179.google.com with SMTP id fp1so10227413pdb.38
        for <netdev@vger.kernel.org>; Thu, 13 Feb 2014 06:58:23 -0800 (PST)
In-Reply-To: <1392292350-28800-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-02-13 at 12:52 +0100, Florian Westphal wrote:
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
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  V1 of this patch was deferred, resending to get discussion going again.
>  Changes since v1:
>   - add reproducer to commit message
> 
>  Unfortunately I couldn't come up with something that has no magic
>  ('allowed >> 4') value.  I chose >>4 (1/16th) because it didn't cause
>  tput limitations in my 'full-mss-sized, steady state' netcat tests.
> 
>  Maybe someone has better idea?

Thanks a lot Florian looking at this.

Do we have one SNMP counter tracking number of time we took the decision
to send a 0 window ?

Would you mind waiting we run our packetdrill tests before acknowledging
this patch, because I suspect this might have some impact ?

Thanks !
