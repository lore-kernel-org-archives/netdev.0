From: Ben Mansell <ben@zeus.com>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Thu, 08 Jan 2009 21:50:44 +0000
Message-ID: <49667534.5060501@zeus.com>
References: <20090108173028.GA22531@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Jens Axboe <jens.axboe@oracle.com>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout03-winn.ispmail.ntl.com ([81.103.221.49]:7091 "EHLO
	mtaout03-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751031AbZAHVvG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 16:51:06 -0500
In-Reply-To: <20090108173028.GA22531@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From fafe76713523c8e9767805cfdc7b73323d7bf180 Mon Sep 17 00:00:00 2001
> From: Willy Tarreau <w@1wt.eu>
> Date: Thu, 8 Jan 2009 17:10:13 +0100
> Subject: [PATCH] tcp: splice as many packets as possible at once
> 
> Currently, in non-blocking mode, tcp_splice_read() returns after
> splicing one segment regardless of the len argument. This results
> in low performance and very high overhead due to syscall rate when
> splicing from interfaces which do not support LRO.
> 
> The fix simply consists in not breaking out of the loop after the
> first read. That way, we can read up to the size requested by the
> caller and still return when there is no data left.
> 
> Performance has significantly improved with this fix, with the
> number of calls to splice() divided by about 20, and CPU usage
> dropped from 100% to 75%.
> 

I get similar results with my testing here. Benchmarking an application 
with this patch shows that more than one packet is being splice()d in at 
once, as a result I see a doubling in throughput.

Tested-by: Ben Mansell <ben@zeus.com>

> Signed-off-by: Willy Tarreau <w@1wt.eu>
> ---
>  net/ipv4/tcp.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 35bcddf..80261b4 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -615,7 +615,7 @@ ssize_t tcp_splice_read(struct socket *sock, loff_t *ppos,
>  		lock_sock(sk);
>  
>  		if (sk->sk_err || sk->sk_state == TCP_CLOSE ||
> -		    (sk->sk_shutdown & RCV_SHUTDOWN) || !timeo ||
> +		    (sk->sk_shutdown & RCV_SHUTDOWN) ||
>  		    signal_pending(current))
>  			break;
>  	}

