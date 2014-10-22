From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: Add TCP_FREEZE socket option
Date: Wed, 22 Oct 2014 08:54:32 -0700
Message-ID: <1413993272.9031.3.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1413992196-4891-1-git-send-email-kristian.evensen@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kristian Evensen <kristian.evensen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:60414 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932343AbaJVPye (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 11:54:34 -0400
Received: by mail-pd0-f173.google.com with SMTP id g10so3770385pdj.4
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2014 08:54:33 -0700 (PDT)
In-Reply-To: <1413992196-4891-1-git-send-email-kristian.evensen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-10-22 at 17:36 +0200, Kristian Evensen wrote:
> From: Kristian Evensen <kristian.evensen@gmail.com>
> 
> This patch introduces support for Freeze-TCP [1].
> 
> Devices that are mobile frequently experience temporary disconnects, for example
> due to signal fading or a technology change. These changes can last for a
> substantial amount of time (>10 seconds), potentially causing multiple RTOs to
> expire and the sender to enter slow start. Even though a device has
> reconnected, it can take a long time for the TCP connection to recover.
> 
> Operators of mobile broadband networks mitigate this issue by placing TCP
> splitters at the edge of their networks. However, the splitters typically only
> operate on some ports (mostly only port 80) and violate the end-to-end
> principle. The operator's TCP splitter receives a notification when a temporary
> disconnect occurs and starts sending Zero Window Announcements (ZWA) to the
> remote part of the connection. When a devices regains connectivity, the window
> is reopened.
> 
> Freeze-TCP is a client-side only approach for enabling application developers to
> trigger sending ZWAs. It is implemented as a socket option and accepts three
> different values. If the value is set to one, the connection is frozen. A ZWA is
> sent and the window size set to 0 in any reply to additional packets arriving
> from remote party. If the value is set to two, the connection is unfrozen and a
> window update announcement is sent. If the value is set to three, two additional
> window update announcements are sent. This is referred to as TR-ACK in the paper
> and is used to increase probability that a window update announcement will be
> received.
> 
> When to trigger Freeze-TCP depends on the application requirements and
> underlaying network, is not the responsibility of the kernel. One approach is to
> have the application, or a daemon, analyze the meta data exported from a mobile
> broadband modem. A temporary disconnect can often be detected in advance by
> looking at different statistics.
> 
> [1] - T. Goff, J. Moronski, D. S. Phatak, and V. Gupta, "Freeze-TCP: a True
> End-to-end TCP Enhancement Mechanism for Mobile Environments," In Proceedings of
> IEEE INFOCOM 2000. URL: http://www.csee.umbc.edu/~phatak/publications/ftcp.pdf
> 
> Signed-off-by: Kristian Evensen <kristian.evensen@gmail.com>
> ---
>  include/linux/tcp.h      |  3 ++-
>  include/uapi/linux/tcp.h |  1 +
>  net/ipv4/tcp.c           | 33 +++++++++++++++++++++++++++++++++
>  net/ipv4/tcp_output.c    |  8 +++++++-
>  4 files changed, 43 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> index c2dee7d..7ed26c1 100644
> --- a/include/linux/tcp.h
> +++ b/include/linux/tcp.h
> @@ -187,7 +187,8 @@ struct tcp_sock {
>  		syn_data:1,	/* SYN includes data */
>  		syn_fastopen:1,	/* SYN includes Fast Open option */
>  		syn_data_acked:1,/* data in SYN is acked by SYN-ACK */
> -		is_cwnd_limited:1;/* forward progress limited by snd_cwnd? */
> +		is_cwnd_limited:1,/* forward progress limited by snd_cwnd? */
> +		frozen:1;	/* Artifically deflate announced window to 0 */
>  	u32	tlp_high_seq;	/* snd_nxt at the time of TLP retransmit. */
>  
>  /* RTT measurement */
> diff --git a/include/uapi/linux/tcp.h b/include/uapi/linux/tcp.h
> index 3b97183..bc0684d 100644
> --- a/include/uapi/linux/tcp.h
> +++ b/include/uapi/linux/tcp.h
> @@ -112,6 +112,7 @@ enum {
>  #define TCP_FASTOPEN		23	/* Enable FastOpen on listeners */
>  #define TCP_TIMESTAMP		24
>  #define TCP_NOTSENT_LOWAT	25	/* limit number of unsent bytes in write queue */
> +#define TCP_FREEZE		26	/* Freeze TCP connection by sending ZWA */
>  
>  struct tcp_repair_opt {
>  	__u32	opt_code;
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 1bec4e7..5bf30d0 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -2339,6 +2339,7 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
>  	struct inet_connection_sock *icsk = inet_csk(sk);
>  	int val;
>  	int err = 0;
> +	u8 itr = 0;
>  
>  	/* These are data/string values, all the others are ints */
>  	switch (optname) {
> @@ -2600,6 +2601,35 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
>  		tp->notsent_lowat = val;
>  		sk->sk_write_space(sk);
>  		break;
> +	case TCP_FREEZE:
> +		if (val < 1 || val > 3 ||
> +		    !((1 << sk->sk_state) & TCPF_ESTABLISHED)) {
> +			err = -EINVAL;
> +			break;
> +		}
> +
> +		if (val == 1) {
> +			tp->frozen = 1;
> +			tcp_send_ack(sk);
> +			break;
> +		} else if (!tp->frozen) {
> +			err = -EINVAL;
> +			break;
> +		}
> +
> +		tp->frozen = 0;
> +		tcp_send_ack(sk);
> +
> +		if (val == 2)
> +			break;
> +
> +		/* If val is three, send two additional reconnection ACKs to
> +		 * increase chance of a non-zero windows announcement arriving.
> +		 */
> +		for (itr = 0; itr < 2; itr++)
> +			tcp_send_ack(sk);
> +
> +		break;
>  	default:
>  		err = -ENOPROTOOPT;
>  		break;
> @@ -2832,6 +2862,9 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
>  	case TCP_NOTSENT_LOWAT:
>  		val = tp->notsent_lowat;
>  		break;
> +	case TCP_FREEZE:
> +		val = tp->frozen;
> +		break;
>  	default:
>  		return -ENOPROTOOPT;
>  	}


This asymmetry looks strange

Following sequence should be allowed :

getsockopt(...  TCP_FREEZE, &val, ...)
setsockopt(...  TCP_FREEZE, &val, ...)

So setsockopt() should accept val = 0
