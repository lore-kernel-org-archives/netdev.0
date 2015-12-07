From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [RFC PATCH net-next 1/2] tcp: RTO Restart (RTOR)
Date: Mon, 7 Dec 2015 12:22:08 +0200 (EET)
Message-ID: <alpine.DEB.2.10.1512071215580.17913@melkinpaasi.cs.helsinki.fi>
References: <cover.1449478261.git.per.hurtig@kau.se> <4719073d7d8285006b2fe5f1b67a3fe5255c503e.1449478261.git.per.hurtig@kau.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, edumazet@google.com,
	ncardwell@google.com, nanditad@google.com, tom@herbertland.com,
	ycheng@google.com, viro@zeniv.linux.org.uk, fw@strlen.de,
	mleitner@redhat.com, daniel@iogearbox.net, willemb@google.com,
	pasi.sarolahti@iki.fi, stephen@networkplumber.org,
	Netdev <netdev@vger.kernel.org>, anna.brunstrom@kau.se,
	apetlund@simula.no, michawe@ifi.uio.no, mohammad.rajiullah@kau.se
To: Per Hurtig <per.hurtig@kau.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from script.cs.helsinki.fi ([128.214.11.1]:57212 "EHLO
	script.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754824AbbLGK1m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 05:27:42 -0500
In-Reply-To: <4719073d7d8285006b2fe5f1b67a3fe5255c503e.1449478261.git.per.hurtig@kau.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 7 Dec 2015, Per Hurtig wrote:

> This patch implements the RTO restart modification (RTOR). When data is
> ACKed, and the RTO timer is restarted, the time elapsed since the last
> outstanding segment was transmitted is subtracted from the calculated RTO
> value. This way, the RTO timer will expire after exactly RTO seconds, and
> not RTO + RTT [+ delACK] seconds.
> 
> This patch also implements a new sysctl (tcp_timer_restart) that is used
> to control the timer restart behavior.
> 
> Signed-off-by: Per Hurtig <per.hurtig@kau.se>
> ---
>  Documentation/networking/ip-sysctl.txt | 12 ++++++++++++
>  include/net/tcp.h                      |  4 ++++
>  net/ipv4/sysctl_net_ipv4.c             | 10 ++++++++++
>  net/ipv4/tcp_input.c                   | 24 ++++++++++++++++++++++++
>  4 files changed, 50 insertions(+)
> 
> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
> index 2ea4c45..4094128 100644
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -591,6 +591,18 @@ tcp_syn_retries - INTEGER
>  	with the current initial RTO of 1second. With this the final timeout
>  	for an active TCP connection attempt will happen after 127seconds.
>  
> +tcp_timer_restart - INTEGER
> +	Controls how the RTO and PTO timers are restarted (RTOR and TLPR).
> +	If set (per timer or combined) the timers are restarted with
> +	respect to the earliest outstanding segment, to not extend tail loss
> +	latency unnecessarily.
> +	Possible values:
> +		0 disables RTOR and TLPR.
> +		1 enables RTOR.
> +		2 enables TLPR.
> +		3 enables RTOR and TLPR.
> +	Default: 3
> +
>  tcp_timestamps - BOOLEAN
>  	Enable timestamps as defined in RFC1323.
>  

[...snip...]

> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index fdd88c3..66e0425 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c

[...snip...]

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

Use a bit operation here instead? Also I think that this sysctl would 
benefit from named constants rather than use of literals (similar 
comment applies to the other patch too).

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


-- 
 i.
