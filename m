From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] revert TCP retransmission backoff on ICMP destination
 unreachable
Date: Thu, 13 Aug 2009 16:08:39 -0700 (PDT)
Message-ID: <20090813.160839.127192632.davem@davemloft.net>
References: <4A8155AE.7000707@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: damian@tvk.rwth-aachen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59658
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752702AbZHMXI2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 19:08:28 -0400
In-Reply-To: <4A8155AE.7000707@tvk.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Date: Tue, 11 Aug 2009 13:27:42 +0200

> @@ -1220,6 +1220,8 @@
>  #define tcp_for_write_queue_from_safe(skb, tmp, sk)			\
>  	skb_queue_walk_from_safe(&(sk)->sk_write_queue, skb, tmp)
>  
> +#define retrans_overstepped(sk, boundary) (inet_csk(sk)->icsk_retransmits && (tcp_time_stamp - tcp_sk(sk)->retrans_stamp) >= TCP_RTO_MIN*(2 << boundary))
> +

Longer than 80 columns, and use an inline function instead
of a macro in order to get proper type checking.

> @@ -332,11 +332,14 @@
>  {
>  	struct iphdr *iph = (struct iphdr *)skb->data;
>  	struct tcphdr *th = (struct tcphdr *)(skb->data + (iph->ihl << 2));
> +
> +	struct inet_connection_sock *icsk;
>  	struct tcp_sock *tp;
>  	struct inet_sock *inet;

Do not break up the function local variables with spurious new lines
like this, please.

>  	const int type = icmp_hdr(skb)->type;
>  	const int code = icmp_hdr(skb)->code;
>  	struct sock *sk;
> +	struct sk_buff *skb_r;
>  	__u32 seq;
>  	int err;
>  	struct net *net = dev_net(skb->dev);
> @@ -367,6 +370,7 @@
>  	if (sk->sk_state == TCP_CLOSE)
>  		goto out;
>  
> +	icsk = inet_csk(sk);
>  	tp = tcp_sk(sk);
>  	seq = ntohl(th->seq);
>  	if (sk->sk_state != TCP_LISTEN &&
> @@ -393,6 +397,34 @@
>  		}
>  
>  		err = icmp_err_convert[code].errno;
> +
> +		/* check if ICMP unreachable messages allow revert of back-off */
> +                if ((code != ICMP_NET_UNREACH && code != ICMP_HOST_UNREACH) || seq != tp->snd_una 
> +		|| !icsk->icsk_retransmits || !icsk->icsk_backoff) break;
> +
> +                icsk->icsk_backoff--;
> +                icsk->icsk_rto >>= 1;
> +
> +                skb_r = skb_peek(&sk->sk_write_queue);
> +                BUG_ON(!skb_r);
> +

The indentation and tabbing is messed up in all of the code you are
adding, please fix it up to be consistent with the surrounding code
and the rest of the TCP stack.

Do not use C++ style // comments.
