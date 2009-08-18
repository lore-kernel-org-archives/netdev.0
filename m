From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] revert TCP retransmission backoff on ICMP destination
 unreachable
Date: Tue, 18 Aug 2009 16:45:02 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.0908181514560.10654@wel-95.cs.helsinki.fi>
References: <4A8155AE.7000707@tvk.rwth-aachen.de> <20090813.160839.127192632.davem@davemloft.net> <4A8553AD.2000601@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Damian Lukowski <damian@tvk.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33501 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751087AbZHRNpF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2009 09:45:05 -0400
In-Reply-To: <4A8553AD.2000601@tvk.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Aug 2009, Damian Lukowski wrote:

>> Longer than 80 columns, and use an inline function instead
>> of a macro in order to get proper type checking.
>> [...]
>> Do not break up the function local variables with spurious new lines
>> like this, please.
>> [...]
>> The indentation and tabbing is messed up in all of the code you are
>> adding, please fix it up to be consistent with the surrounding code
>> and the rest of the TCP stack.
>>
>> Do not use C++ style // comments.
>
> Better?

Please, include the changelog message on resubmits too next time.

> Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>


> diff -Naur linux-2.6.30.4/include/net/tcp.h linux-2.6.30.4-tcp-icmp/include/net/tcp.h
> --- linux-2.6.30.4/include/net/tcp.h	2009-07-31 00:34:47.000000000 +0200
> +++ linux-2.6.30.4-tcp-icmp/include/net/tcp.h	2009-08-14 12:18:30.846060685 +0200
> @@ -1220,6 +1220,14 @@
>  #define tcp_for_write_queue_from_safe(skb, tmp, sk)			\
>  	skb_queue_walk_from_safe(&(sk)->sk_write_queue, skb, tmp)
> 
> +static inline bool retrans_overstepped(const struct sock *sk,
> +					unsigned int boundary)
> +{
> +	return 	inet_csk(sk)->icsk_retransmits &&
> +		(tcp_time_stamp - tcp_sk(sk)->retrans_stamp) >=
> +			TCP_RTO_MIN*(2 << boundary);
> +}
> +
>  static inline struct sk_buff *tcp_send_head(struct sock *sk)
>  {
>  	return sk->sk_send_head;
> diff -Naur linux-2.6.30.4/net/ipv4/tcp_ipv4.c linux-2.6.30.4-tcp-icmp/net/ipv4/tcp_ipv4.c
> --- linux-2.6.30.4/net/ipv4/tcp_ipv4.c	2009-07-31 00:34:47.000000000 +0200
> +++ linux-2.6.30.4-tcp-icmp/net/ipv4/tcp_ipv4.c	2009-08-14 13:19:48.841598908 +0200
> @@ -332,11 +332,13 @@
>  {
>  	struct iphdr *iph = (struct iphdr *)skb->data;
>  	struct tcphdr *th = (struct tcphdr *)(skb->data + (iph->ihl << 2));
> +	struct inet_connection_sock *icsk;
>  	struct tcp_sock *tp;
>  	struct inet_sock *inet;
>  	const int type = icmp_hdr(skb)->type;
>  	const int code = icmp_hdr(skb)->code;
>  	struct sock *sk;
> +	struct sk_buff *skb_r;

I'd make this called "skb", and change the old skb to icmp_skb.

>  	__u32 seq;
>  	int err;
>  	struct net *net = dev_net(skb->dev);
> @@ -367,6 +369,7 @@
>  	if (sk->sk_state == TCP_CLOSE)
>  		goto out;
> 
> +	icsk = inet_csk(sk);
>  	tp = tcp_sk(sk);
>  	seq = ntohl(th->seq);
>  	if (sk->sk_state != TCP_LISTEN &&
> @@ -393,6 +396,41 @@
>  		}
>
>  		err = icmp_err_convert[code].errno;
> +		/* check if ICMP unreachable messages allow revert of backoff */
> +		if ((code != ICMP_NET_UNREACH && code != ICMP_HOST_UNREACH) ||
> +		    seq != tp->snd_una  || !icsk->icsk_retransmits ||
> +		    !icsk->icsk_backoff)

I'd recommend you break this into two if()\nbreak's, one for filtering
other icmps and other for filtering mismatching against the socket's 
state.

> +			break;
> +
> +		icsk->icsk_backoff--;
> +		icsk->icsk_rto >>= 1;

Are you absolute sure that we don't go to zero here when phase of the 
moon is just right? I'd put a max(..., 1) guard there.

> +
> +		skb_r = skb_peek(&sk->sk_write_queue);

tcp_write_queue_head(sk)

> +		BUG_ON(!skb_r);
> +
> +		if (sock_owned_by_user(sk)) {
> +			/* Deferring retransmission clocked by ICMP
> +			 * due to locked socket. */
> +			inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
> +			min(icsk->icsk_rto, TCP_RESOURCE_PROBE_INTERVAL),

??? (besides having indent wrong). What makes you think HZ/2 is right 
value if icsk_rto is large?

> +			TCP_RTO_MAX);

Perhaps you lack here something to exit?

> +		}
> +
> +		if (tcp_time_stamp - TCP_SKB_CB(skb_r)->when >
> +		    inet_csk(sk)->icsk_rto) {

icsk->icsk_rto !?!

> +			/* RTO revert clocked out retransmission. */
> +			tcp_retransmit_skb(sk, skb_r);

This is plain wrong, tcp_sock counters will get messed up if 
TCPCB_SACKED_RETRANS is already set while calling tcp_retransmit_skb. As a 
sidenote, it would be probably useful to move the check + clear of that 
bit before doing the retransmission to some common place one day.

> +			inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
> +						  icsk->icsk_rto, TCP_RTO_MAX);

RFC 2988, step 5.5 missing? Have you verified this patch for real?

> +		} else {
> +			/* RTO revert shortened timer. */
> +			inet_csk_reset_xmit_timer(
> +				sk, ICSK_TIME_RETRANS,
> +				icsk->icsk_rto-
> +				(tcp_time_stamp-TCP_SKB_CB(skb_r)->when),

Spacing.

> +				TCP_RTO_MAX);
> +		}
> +

How about:

 		u32 remaining;

 		remaining = icsk->icsk_rto - min(icsk->icsk_rto,
 						 tcp_time_stamp - TCP_SKB_CB(skb_r)->when));
 		if (!remaining) {
 			tcp_retransmit_skb(...);
 			remaining = icsk->icsk_rto;
 		}
 		inet_csk_reset_xmit_timer(..., remaining);

But check my note about step 5.5 (see above) to get remaining set right in 
the if branch.

>  		break;
>  	case ICMP_TIME_EXCEEDED:
>  		err = EHOSTUNREACH;
> diff -Naur linux-2.6.30.4/net/ipv4/tcp_timer.c linux-2.6.30.4-tcp-icmp/net/ipv4/tcp_timer.c
> --- linux-2.6.30.4/net/ipv4/tcp_timer.c	2009-07-31 00:34:47.000000000 +0200
> +++ linux-2.6.30.4-tcp-icmp/net/ipv4/tcp_timer.c	2009-08-14 13:22:18.068666329 +0200
> @@ -143,7 +143,7 @@
>  			dst_negative_advice(&sk->sk_dst_cache);
>  		retry_until = icsk->icsk_syn_retries ? : sysctl_tcp_syn_retries;
>  	} else {
> -		if (icsk->icsk_retransmits >= sysctl_tcp_retries1) {
> +		if (retrans_overstepped(sk, sysctl_tcp_retries1)) {

??? Could you justify these changes and explain their relation to the 
draft and icmp messages? If not, please drop them and try with proper 
description and description for them in a separate patch. I fail to see 
what you're trying to achieve here. You just ended up redefining the 
sysctl meaning too I think...

>  			/* Black hole detection */
>  			tcp_mtu_probing(icsk, sk);
> 
> @@ -156,12 +156,14 @@
>
>  			retry_until = tcp_orphan_retries(sk, alive);
> 
> -			if (tcp_out_of_resources(sk, alive || icsk->icsk_retransmits < retry_until))
> +			if (tcp_out_of_resources(
> +				sk, alive ||
> +				    !retrans_overstepped(sk, retry_until)))

???

>  				return 1;
>  		}
>  	}
> 
> -	if (icsk->icsk_retransmits >= retry_until) {
> +	if (retrans_overstepped(sk, retry_until)) {

...

>  		/* Has it gone just too far? */
>  		tcp_write_err(sk);
>  		return 1;
> @@ -385,7 +387,7 @@
>  out_reset_timer:
>  	icsk->icsk_rto = min(icsk->icsk_rto << 1, TCP_RTO_MAX);
>  	inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, icsk->icsk_rto, TCP_RTO_MAX);
> -	if (icsk->icsk_retransmits > sysctl_tcp_retries1)
> +	if (retrans_overstepped(sk, sysctl_tcp_retries1))

...I guess none of these retrans_overstepped are related to the icmp stuff 
at all?

>  		__sk_dst_reset(sk);
>
>  out:;

-- 
  i.
