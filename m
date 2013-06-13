From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net-next v2] tcp: introduce a per-route knob for quick
 ack
Date: Wed, 12 Jun 2013 23:42:56 -0700
Message-ID: <1371105776.3252.98.camel@edumazet-glaptop>
References: <1371104643-24076-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Rick Jones <rick.jones2@hp.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	David Laight <David.Laight@ACULAB.COM>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f172.google.com ([209.85.215.172]:50558 "EHLO
	mail-ea0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755427Ab3FMGnB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 02:43:01 -0400
Received: by mail-ea0-f172.google.com with SMTP id q10so5990846eaj.17
        for <netdev@vger.kernel.org>; Wed, 12 Jun 2013 23:43:00 -0700 (PDT)
In-Reply-To: <1371104643-24076-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-06-13 at 14:24 +0800, Cong Wang wrote:


> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 907311c..51ed9b7 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -3726,6 +3726,7 @@ void tcp_reset(struct sock *sk)
>  static void tcp_fin(struct sock *sk)
>  {
>  	struct tcp_sock *tp = tcp_sk(sk);
> +	const struct dst_entry *dst;
>  
>  	inet_csk_schedule_ack(sk);
>  
> @@ -3737,7 +3738,9 @@ static void tcp_fin(struct sock *sk)
>  	case TCP_ESTABLISHED:
>  		/* Move to CLOSE_WAIT */
>  		tcp_set_state(sk, TCP_CLOSE_WAIT);
> -		inet_csk(sk)->icsk_ack.pingpong = 1;
> +		dst = __sk_dst_get(sk);

	What if dst is NULL ?

> +		if (!dst_metric(dst, RTAX_QUICKACK))
> +			inet_csk(sk)->icsk_ack.pingpong = 1;
>  		break;
>  
>  	case TCP_CLOSE_WAIT:
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index ec335fa..f840b92 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -160,6 +160,7 @@ static void tcp_event_data_sent(struct tcp_sock *tp,
>  {
>  	struct inet_connection_sock *icsk = inet_csk(sk);
>  	const u32 now = tcp_time_stamp;
> +	const struct dst_entry *dst = __sk_dst_get(sk);
>  


Same here : Are you sure dst cannot be NULL ?
