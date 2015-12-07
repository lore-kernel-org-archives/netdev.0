From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH net-next 1/2] tcp: RTO Restart (RTOR)
Date: Mon, 07 Dec 2015 09:03:44 -0800
Message-ID: <1449507824.25029.76.camel@edumazet-glaptop2.roam.corp.google.com>
References: <cover.1449478261.git.per.hurtig@kau.se>
	 <4719073d7d8285006b2fe5f1b67a3fe5255c503e.1449478261.git.per.hurtig@kau.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, edumazet@google.com, ncardwell@google.com,
	nanditad@google.com, tom@herbertland.com, ycheng@google.com,
	viro@zeniv.linux.org.uk, fw@strlen.de, mleitner@redhat.com,
	daniel@iogearbox.net, willemb@google.com,
	ilpo.jarvinen@helsinki.fi, pasi.sarolahti@iki.fi,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	anna.brunstrom@kau.se, apetlund@simula.no, michawe@ifi.uio.no,
	mohammad.rajiullah@kau.se
To: Per Hurtig <per.hurtig@kau.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36764 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932237AbbLGRDr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 12:03:47 -0500
Received: by pacdm15 with SMTP id dm15so127675586pac.3
        for <netdev@vger.kernel.org>; Mon, 07 Dec 2015 09:03:46 -0800 (PST)
In-Reply-To: <4719073d7d8285006b2fe5f1b67a3fe5255c503e.1449478261.git.per.hurtig@kau.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-12-07 at 10:00 +0100, Per Hurtig wrote:
\
>  
> +static u32 tcp_unsent_pkts(const struct sock *sk)
> +{
> +	struct sk_buff *skb = tcp_send_head(sk);
> +	u32 pkts = 0;
> +
> +	if (skb)
> +		tcp_for_write_queue_from(skb, sk)
> +			pkts += tcp_skb_pcount(skb);
> +
> +	return pkts;
> +}

write queue can be very big (consider GSO/TSO being off for example)

Parsing it just to implement later :

(tp->packets_out + tcp_unsent_pkts(sk) <
> +			    TCP_RTORESTART_THRESH)

is probably not very efficient.

I would rather implement a different helper, aborting the loop as soon
as the condition can not be met anymore.

> +
>  /* Restart timer after forward progress on connection.
>   * RFC2988 recommends to restart timer to now+rto.
>   */
> @@ -3027,6 +3040,17 @@ void tcp_rearm_rto(struct sock *sk)
>  			 */
>  			if (delta > 0)
>  				rto = delta;
> +		} else if (icsk->icsk_pending == ICSK_TIME_RETRANS &&
> +			   (sysctl_tcp_timer_restart == 1 ||
> +			    sysctl_tcp_timer_restart == 3) &&
> +			   (tp->packets_out + tcp_unsent_pkts(sk) <
> +			    TCP_RTORESTART_THRESH)) {
> +			struct sk_buff *skb = tcp_write_queue_head(sk);
> +			const u32 rto_time_stamp = tcp_skb_timestamp(skb);
> +			s32 delta = (s32)(tcp_time_stamp - rto_time_stamp);
> +
> +			if (delta > 0 && rto > delta)
> +				rto -= delta;
>  		}
>  		inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, rto,
>  					  TCP_RTO_MAX);
