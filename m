From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 6/7] net-tcp: Fast Open client - detecting SYN-data
 drops
Date: Wed, 18 Jul 2012 23:35:47 +0200
Message-ID: <1342647347.2626.3721.camel@edumazet-glaptop>
References: <1342645307-17772-1-git-send-email-ycheng@google.com>
	 <1342645307-17772-7-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, hkchu@google.com, edumazet@google.com,
	ncardwell@google.com, sivasankar@cs.ucsd.edu,
	netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f174.google.com ([209.85.160.174]:50752 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753389Ab2GRVfx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 17:35:53 -0400
Received: by ghrr11 with SMTP id r11so2118248ghr.19
        for <netdev@vger.kernel.org>; Wed, 18 Jul 2012 14:35:53 -0700 (PDT)
In-Reply-To: <1342645307-17772-7-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-18 at 14:01 -0700, Yuchung Cheng wrote:
> On paths with firewalls dropping SYN with data or experimental TCP options,
> Fast Open connections will have experience SYN timeout and bad performance.
> The solution is to track such incidents in the cookie cache and disables
> Fast Open temporarily.
> 
> Since only the original SYN includes data and/or Fast Open option, the
> SYN-ACK has some tell-tale sign (tcp_rcv_fastopen_synack()) to detect
> such drops. If a path has recurring Fast Open SYN drops, Fast Open is
> disabled for 2^(recurring_losses) minutes starting from four minutes up to
> roughly one and half day. sendmsg with MSG_FASTOPEN flag will succeed but
> it behaves as connect() then write().
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
...

>  void tcp_fastopen_cache_set(struct sock *sk, u16 mss,
> -			    struct tcp_fastopen_cookie *cookie)
> +			    struct tcp_fastopen_cookie *cookie, bool syn_lost)
>  {
>  	struct tcp_metrics_block *tm;
>  
> @@ -670,6 +675,11 @@ void tcp_fastopen_cache_set(struct sock *sk, u16 mss,
>  		tfom->mss = mss;
>  		if (cookie->len > 0)
>  			tfom->cookie = *cookie;
> +		if (syn_lost) {
> +			++tfom->syn_loss;
> +			tfom->last_syn_loss = jiffies;
> +		} else
> +			tfom->syn_loss = 0;
>  	}
>  	rcu_read_unlock();
>  }

Proably needs a respin after you use a seqlock, otherwise looks good to
me.
