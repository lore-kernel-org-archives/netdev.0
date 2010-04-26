From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH v3] TCP: avoid to send keepalive probes if receiving
 data
Date: Mon, 26 Apr 2010 12:47:13 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1004261241510.7041@wel-95.cs.helsinki.fi>
References: <20100425235549.GB2550@sysclose.org> <1272249659-2292-1-git-send-email-fleitner@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Flavio Leitner <fleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:48352 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752261Ab0DZJrO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 05:47:14 -0400
In-Reply-To: <1272249659-2292-1-git-send-email-fleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 25 Apr 2010, Flavio Leitner wrote:

> RFC 1122 says the following:
> ...
>   Keep-alive packets MUST only be sent when no data or
>   acknowledgement packets have been received for the
>   connection within an interval.
> ...
> 
> The acknowledgement packet is reseting the keepalive
> timer but the data packet isn't. This patch fixes it by
> checking the timestamp of the last received data packet
> too when the keepalive timer expires.
> 
> Signed-off-by: Flavio Leitner <fleitner@redhat.com>
> ---
>  net/ipv4/tcp.c       |    5 ++++-
>  net/ipv4/tcp_timer.c |    8 ++++++++
>  2 files changed, 12 insertions(+), 1 deletions(-)
> 
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 0f8caf6..94f605c 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -2298,7 +2298,10 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
>  			if (sock_flag(sk, SOCK_KEEPOPEN) &&
>  			    !((1 << sk->sk_state) &
>  			      (TCPF_CLOSE | TCPF_LISTEN))) {
> -				__u32 elapsed = tcp_time_stamp - tp->rcv_tstamp;
> +				u32 elapsed = min_t(u32,
> +				      tcp_time_stamp - icsk->icsk_ack.lrcvtime,
> +				      tcp_time_stamp - tp->rcv_tstamp);
> +

I'd put this into a helper in include/net/tcp.h

>  				if (tp->keepalive_time > elapsed)
>  					elapsed = tp->keepalive_time - elapsed;
>  				else
> diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
> index 8a0ab29..9d1bb6f 100644
> --- a/net/ipv4/tcp_timer.c
> +++ b/net/ipv4/tcp_timer.c
> @@ -554,6 +554,14 @@ static void tcp_keepalive_timer (unsigned long data)
>  	if (tp->packets_out || tcp_send_head(sk))
>  		goto resched;
>  
> +	elapsed = tcp_time_stamp - icsk->icsk_ack.lrcvtime;
> +
> +	/* receiving data means alive */
> +	if (elapsed < keepalive_time_when(tp)) {
> +		elapsed = keepalive_time_when(tp) - elapsed;
> +		goto resched;
> +	}
> +
>  	elapsed = tcp_time_stamp - tp->rcv_tstamp;

...And then use it here too for setting the elapsed and doing the test 
and what follows only once?

>  	if (elapsed >= keepalive_time_when(tp)) {
> 

-- 
 i.
