From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] inetpeer: fix token initialization
Date: Thu, 27 Sep 2012 16:18:36 +0200
Message-ID: <1348755516.5093.1326.camel@edumazet-glaptop>
References: <1348752886.5093.1282.camel@edumazet-glaptop>
	 <1348755060-3737-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:55846 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751125Ab2I0OSl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 10:18:41 -0400
Received: by bkcjk13 with SMTP id jk13so1881657bkc.19
        for <netdev@vger.kernel.org>; Thu, 27 Sep 2012 07:18:39 -0700 (PDT)
In-Reply-To: <1348755060-3737-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-27 at 16:11 +0200, Nicolas Dichtel wrote:
> When jiffies wraps around (for example, 5 minutes after the boot, see
> INITIAL_JIFFIES) and peer has just been created, now - peer->rate_last can be
> < XRLIM_BURST_FACTOR * timeout, so token is not set to the maximum value, thus
> some icmp packets can be unexpectedly dropped.
> 
> Fix this case by initializing last_rate to 60 seconds in the past.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
> v2: fix initialization of peer instead of adding some tests in
>     inet_peer_xrlim_allow()
> 
>  net/ipv4/inetpeer.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
> index e1e0a4e..c7527f6 100644
> --- a/net/ipv4/inetpeer.c
> +++ b/net/ipv4/inetpeer.c
> @@ -510,7 +510,10 @@ relookup:
>  					secure_ipv6_id(daddr->addr.a6));
>  		p->metrics[RTAX_LOCK-1] = INETPEER_METRICS_NEW;
>  		p->rate_tokens = 0;
> -		p->rate_last = 0;
> +		/* 60*HZ is arbitrary, but chosen enough high so that the first
> +		 * calculation of tokens is at its maximum.
> +		 */
> +		p->rate_last = jiffies - 60*HZ;
>  		INIT_LIST_HEAD(&p->gc_list);
>  
>  		/* Link the node. */

Signed-off-by: Eric Dumazet <edumazet@google.com>

Thanks !
