From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH net-2.6.26] NULL pointer dereference and other nasty things
 in /proc/net/(tcp|udp)[6]
Date: Fri, 21 Mar 2008 16:08:57 +0100
Message-ID: <47E3CF89.1060906@fr.ibm.com>
References: <47E3C91F.9080309@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([195.212.29.136]:11791 "EHLO
	mtagate3.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755542AbYCUPJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2008 11:09:33 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate3.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m2LF9WTV047364
	for <netdev@vger.kernel.org>; Fri, 21 Mar 2008 15:09:32 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2LF9Wir2072708
	for <netdev@vger.kernel.org>; Fri, 21 Mar 2008 15:09:32 GMT
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2LF9Wtd020791
	for <netdev@vger.kernel.org>; Fri, 21 Mar 2008 15:09:32 GMT
In-Reply-To: <47E3C91F.9080309@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
> Commits f40c81 ([NETNS][IPV4] tcp - make proc handle the network 
> namespaces) and a91275 ([NETNS][IPV6] udp - make proc handle the 
> network namespace) both introduced bad checks on sockets and tw
> buckets to belong to proper net namespace. 
> 
> I.e. when checking for socket to belong to given net and family the
> 
> 	do {
> 		sk = sk_next(sk);
> 	} while (sk && sk->sk_net != net && sk->sk_family != family);
> 
> constructions were used. This is wrong, since as soon as the sk->sk_net
> fits the net the socket is immediately returned, even if it belongs to
> other family.
> 
> As the result four /proc/net/(udp|tcp)[6] entries show wrong info. 
> The udp6 entry even oopses when dereferencing inet6_sk(sk) pointer:
> 
> static void udp6_sock_seq_show(struct seq_file *seq, struct sock *sp, int bucket)
> {
> 	...
>         struct ipv6_pinfo *np = inet6_sk(sp);
> 	...
> 
>         dest  = &np->daddr; /* will be NULL for AF_INET sockets */
> 	...
> 	seq_printf(...
> 	           dest->s6_addr32[0], dest->s6_addr32[1],
>                    dest->s6_addr32[2], dest->s6_addr32[3],
> 	...
> 
> Fix it by converting && to ||.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> ---
> 
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 744bc9d..0ba6e91 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -2050,7 +2050,7 @@ static void *established_get_first(struct seq_file *seq)
>  		st->state = TCP_SEQ_STATE_TIME_WAIT;
>  		inet_twsk_for_each(tw, node,
>  				   &tcp_hashinfo.ehash[st->bucket].twchain) {
> -			if (tw->tw_family != st->family &&
> +			if (tw->tw_family != st->family ||
>  			    tw->tw_net != net) {
>  				continue;
>  			}
> @@ -2078,7 +2078,7 @@ static void *established_get_next(struct seq_file *seq, void *cur)
>  		tw = cur;
>  		tw = tw_next(tw);
>  get_tw:
> -		while (tw && tw->tw_family != st->family && tw->tw_net != net) {
> +		while (tw && (tw->tw_family != st->family || tw->tw_net != net)) {
>  			tw = tw_next(tw);
>  		}
>  		if (tw) {
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index a98c43c..fa94682 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -1537,7 +1537,7 @@ static struct sock *udp_get_next(struct seq_file *seq, struct sock *sk)
>  		sk = sk_next(sk);
>  try_again:
>  		;
> -	} while (sk && sk->sk_net != net && sk->sk_family != state->family);
> +	} while (sk && (sk->sk_net != net || sk->sk_family != state->family));
> 
>  	if (!sk && ++state->bucket < UDP_HTABLE_SIZE) {
>  		sk = sk_head(state->hashtable + state->bucket);

good catch.
Weird I missed that :(

Thank you for fixing this so quickly.

Acked-by: Daniel Lezcano <dlezcano@fr.ibm.com>
