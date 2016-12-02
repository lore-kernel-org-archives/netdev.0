From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/4] tcp: tsq: add shortcut in
 tcp_tasklet_func()
Date: Fri, 02 Dec 2016 14:12:30 -0800
Message-ID: <1480716750.18162.387.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480703159-2327-1-git-send-email-edumazet@google.com>
         <1480703159-2327-4-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34311 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750949AbcLBWOG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 17:14:06 -0500
Received: by mail-pg0-f66.google.com with SMTP id e9so8997402pgc.1
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 14:13:32 -0800 (PST)
In-Reply-To: <1480703159-2327-4-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-12-02 at 10:25 -0800, Eric Dumazet wrote:
> Under high stress, I've seen tcp_tasklet_func() consuming
> ~700 usec, handling ~150 tcp sockets.
> 
> By setting TCP_TSQ_DEFERRED in tcp_wfree(), we give a chance
> for other cpus/threads entering tcp_write_xmit() to grab it,
> allowing tcp_tasklet_func() to skip sockets that already did
> an xmit cycle.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

...

> @@ -884,7 +884,7 @@ void tcp_wfree(struct sk_buff *skb)
>  		if (!(oval & TSQF_THROTTLED) || (oval & TSQF_QUEUED))
>  			goto out;
>  
> -		nval = (oval & ~TSQF_THROTTLED) | TSQF_QUEUED;
> +		nval = (oval & ~TSQF_THROTTLED) | TSQF_QUEUED | TCP_TSQ_DEFERRED;

Typo here...

Should be :
		nval = (oval & ~TSQF_THROTTLED) | TSQF_QUEUED | TCPF_TSQ_DEFERRED;

>  		nval = cmpxchg(&tp->tsq_flags, oval, nval);
>  		if (nval != oval)
>  			continue;
