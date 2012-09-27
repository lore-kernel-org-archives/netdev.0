From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] inetpeer: ensure to set the maximum tokens the first
 time
Date: Thu, 27 Sep 2012 14:53:25 +0200
Message-ID: <1348750405.5093.1234.camel@edumazet-glaptop>
References: <1348749237-3919-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:39964 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756499Ab2I0Mxa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 08:53:30 -0400
Received: by bkcjk13 with SMTP id jk13so1714979bkc.19
        for <netdev@vger.kernel.org>; Thu, 27 Sep 2012 05:53:29 -0700 (PDT)
In-Reply-To: <1348749237-3919-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-27 at 14:33 +0200, Nicolas Dichtel wrote:
> When jiffies wraps around (for example, 5 minutes after the boot, see
> INITIAL_JIFFIES) and peer has just been created, now - peer->rate_last can be
> < XRLIM_BURST_FACTOR * timeout, so token is not set to the maximum value, thus
> some icmp packets can be unexpectedly dropped.
> 
> With this patch, it's still possible that last_rate and rate_tokens are 0 at the
> same time after jiffies wraps round, but the probability is very low and the
> only consequence is to let some ICMP packets bypass the filter.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>  net/ipv4/inetpeer.c | 10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
> index e1e0a4e..92fec02 100644
> --- a/net/ipv4/inetpeer.c
> +++ b/net/ipv4/inetpeer.c
> @@ -559,10 +559,14 @@ bool inet_peer_xrlim_allow(struct inet_peer *peer, int timeout)
>  
>  	token = peer->rate_tokens;
>  	now = jiffies;
> -	token += now - peer->rate_last;
> -	peer->rate_last = now;
> -	if (token > XRLIM_BURST_FACTOR * timeout)
> +	if (!peer->rate_last && !token)
>  		token = XRLIM_BURST_FACTOR * timeout;
> +	else {
> +		token += now - peer->rate_last;
> +		if (token > XRLIM_BURST_FACTOR * timeout)
> +			token = XRLIM_BURST_FACTOR * timeout;
> +	}
> +	peer->rate_last = now;
>  	if (token >= timeout) {
>  		token -= timeout;
>  		rc = true;


I am sorry I dont understand your patch at all.

Why not init rate_last to a more sensible value ?

diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index e1e0a4e..25ed555 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -510,7 +510,7 @@ relookup:
 					secure_ipv6_id(daddr->addr.a6));
 		p->metrics[RTAX_LOCK-1] = INETPEER_METRICS_NEW;
 		p->rate_tokens = 0;
-		p->rate_last = 0;
+		p->rate_last = jiffies;
 		INIT_LIST_HEAD(&p->gc_list);
 
 		/* Link the node. */
