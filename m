From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] tcp: fix FIN_WAIT2 timer expression in /proc/net/tcp
Date: Tue, 12 Feb 2013 06:57:50 -0800
Message-ID: <1360681070.13993.2.camel@edumazet-glaptop>
References: <1360673384.10638.10.camel@ubuntu-vm-makita>
	 <1360673521.10638.12.camel@ubuntu-vm-makita>
	 <1360673668.10638.14.camel@ubuntu-vm-makita>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f53.google.com ([209.85.210.53]:42906 "EHLO
	mail-da0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760680Ab3BLO5y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 09:57:54 -0500
Received: by mail-da0-f53.google.com with SMTP id w3so58867dad.26
        for <netdev@vger.kernel.org>; Tue, 12 Feb 2013 06:57:54 -0800 (PST)
In-Reply-To: <1360673668.10638.14.camel@ubuntu-vm-makita>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-02-12 at 21:54 +0900, Toshiaki Makita wrote:
> When tcp_fin_timeout is greater than 60, /proc/net/tcp shows
> FIN_WAIT2 keepalive timer as expires in (tcp_fin_timeout - 60)
> sec. This is confusing because the timer is not for keepalive
> and the socket needs another timewait timer to disappear.
> 
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> ---
>  net/ipv4/tcp_ipv4.c |   23 +++++++++++++++--------
>  net/ipv6/tcp_ipv6.c |   23 +++++++++++++++--------
>  2 files changed, 30 insertions(+), 16 deletions(-)
> 
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 629937d..32bde0e 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -2656,17 +2656,24 @@ static void get_tcp4_sock(struct sock *sk, struct seq_file *f, int i, int *len)
>  	int rx_queue;
>  
>  	if (icsk->icsk_pending == ICSK_TIME_RETRANS) {
> -		timer_active	= 1;
> -		timer_expires	= icsk->icsk_timeout;
> +		timer_active		= 1;
> +		timer_expires		= icsk->icsk_timeout;
>  	} else if (icsk->icsk_pending == ICSK_TIME_PROBE0) {
> -		timer_active	= 4;
> -		timer_expires	= icsk->icsk_timeout;
> +		timer_active		= 4;
> +		timer_expires		= icsk->icsk_timeout;
>  	} else if (timer_pending(&sk->sk_timer)) {
> -		timer_active	= 2;
> -		timer_expires	= sk->sk_timer.expires;
> +		if (sk->sk_state == TCP_FIN_WAIT2 && sock_flag(sk, SOCK_DEAD)) {
> +			timer_active	= 3;
> +			timer_expires	= sk->sk_timer.expires +
> +					  (tp->linger2 >= 0 ?
> +					   TCP_TIMEWAIT_LEN : 0);
> +		} else {
> +			timer_active	= 2;
> +			timer_expires	= sk->sk_timer.expires;
> +		}
>  	} else {
> -		timer_active	= 0;
> -		timer_expires = jiffies;
> +		timer_active		= 0;
> +		timer_expires		= jiffies;
>  	}
>  

I find this patch confusing :

1) Please don't change the indentation for a bug fix

2) You add a new 'active=3' field, that some user space
reading /proc/net/tcp wont expect.

So the changelog is not matching the changes.
