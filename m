From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] fix limited slow start bug
Date: Thu, 22 Feb 2007 23:37:44 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0702222317000.29273@kivilampi-30.cs.helsinki.fi>
References: <45DDE756.20001@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: John Heffner <jheffner@psc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33292 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751930AbXBVVhq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 16:37:46 -0500
In-Reply-To: <45DDE756.20001@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 22 Feb 2007, John Heffner wrote:

> diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
> index 7fd2910..a0c894f 100644
> --- a/net/ipv4/tcp_cong.c
> +++ b/net/ipv4/tcp_cong.c
> @@ -303,9 +303,9 @@ void tcp_slow_start(struct tcp_sock *tp)
> 	
> 	tp->snd_cwnd_cnt += cnt;
> 	while (tp->snd_cwnd_cnt >= tp->snd_cwnd) {
> +		tp->snd_cwnd_cnt -= tp->snd_cwnd;
> 		if (tp->snd_cwnd < tp->snd_cwnd_clamp)
>  			tp->snd_cwnd++;
> -		tp->snd_cwnd_cnt -= tp->snd_cwnd;
>  	}
> }
> EXPORT_SYMBOL_GPL(tcp_slow_start);


ACK. I was going to track this down tomorrow as I noticed strange
behavior during slow start while testing tcp-2.6 today but I don't have to 
anymore :-). The problem I saw is now obvious, whole congestion control 
was practically disabled due to underflow of the unsigned type that occurs 
without this patch, causing TCP to be limited only by the receiver 
advertized window during slow-start.


BTW, while looking this patch, I noticed that snd_cwnd_clamp is only u16 
while snd_cwnd is u32, which seems rather strange since snd_cwnd is being 
limited by the clamp value here and there?!?! And tcp_highspeed.c is 
clearly assuming even more than this (but the problem is hidden as 
snd_cwnd_clamp is feed back to the min_t and the used 32-bit constant 
could be safely cut to 16-bits anyway):

  tp->snd_cwnd_clamp = min_t(u32, tp->snd_cwnd_clamp, 0xffffffff/128);

Has the type being changed somewhere in the past or why is this so?


-- 
 i.
