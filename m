From: Alexander Drozdov <al.drozdov@gmail.com>
Subject: Re: [net-next,1/2] net: Set sk_txhash from a random number
Date: Tue, 8 Dec 2015 11:33:26 +0300
Message-ID: <566695D6.6060603@gmail.com>
References: <1438124526-2129341-2-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:32803 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756031AbbLHIda (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 03:33:30 -0500
Received: by lbbkw15 with SMTP id kw15so6978551lbb.0
        for <netdev@vger.kernel.org>; Tue, 08 Dec 2015 00:33:29 -0800 (PST)
In-Reply-To: <1438124526-2129341-2-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


29.07.2015 02:02, Tom Herbert wrote:
> This patch creates sk_set_txhash and eliminates protocol specific
> inet_set_txhash and ip6_set_txhash. sk_set_txhash simply sets a
> random number instead of performing flow dissection. sk_set_txash
> is also allowed to be called multiple times for the same socket,
> we'll need this when redoing the hash for negative routing advice.
It seems that this patch and some previous txhash-related
ones break af_packet hash features for outgoing packets:
- PACKET_FANOUT_HASH
- TP_FT_REQ_FILL_RXHASH

af_packet now thinks that hashes for for incoming and outgoing
packets of the same TCP stream differ. That is true for TCP
sessions initiated by the host.

>
> Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
>   include/net/ip.h    | 16 ----------------
>   include/net/ipv6.h  | 19 -------------------
>   include/net/sock.h  |  8 ++++++++
>   net/ipv4/datagram.c |  2 +-
>   net/ipv4/tcp_ipv4.c |  4 ++--
>   net/ipv6/datagram.c |  2 +-
>   net/ipv6/tcp_ipv6.c |  4 ++--
>   7 files changed, 14 insertions(+), 41 deletions(-)
>
> diff --git a/include/net/ip.h b/include/net/ip.h
> index d5fe9f2..bee5f35 100644
> --- a/include/net/ip.h
> +++ b/include/net/ip.h
> @@ -370,22 +370,6 @@ static inline void iph_to_flow_copy_v4addrs(struct flow_keys *flow,
>   	flow->control.addr_type = FLOW_DISSECTOR_KEY_IPV4_ADDRS;
>   }
>   
> -static inline void inet_set_txhash(struct sock *sk)
> -{
> -	struct inet_sock *inet = inet_sk(sk);
> -	struct flow_keys keys;
> -
> -	memset(&keys, 0, sizeof(keys));
> -
> -	keys.addrs.v4addrs.src = inet->inet_saddr;
> -	keys.addrs.v4addrs.dst = inet->inet_daddr;
> -	keys.control.addr_type = FLOW_DISSECTOR_KEY_IPV4_ADDRS;
> -	keys.ports.src = inet->inet_sport;
> -	keys.ports.dst = inet->inet_dport;
> -
> -	sk->sk_txhash = flow_hash_from_keys(&keys);
> -}
> -
>   static inline __wsum inet_gro_compute_pseudo(struct sk_buff *skb, int proto)
>   {
>   	const struct iphdr *iph = skb_gro_network_header(skb);
> diff --git a/include/net/ipv6.h b/include/net/ipv6.h
> index 82dbdb0..7c79798 100644
> --- a/include/net/ipv6.h
> +++ b/include/net/ipv6.h
> @@ -707,25 +707,6 @@ static inline void iph_to_flow_copy_v6addrs(struct flow_keys *flow,
>   }
>   
>   #if IS_ENABLED(CONFIG_IPV6)
> -static inline void ip6_set_txhash(struct sock *sk)
> -{
> -	struct inet_sock *inet = inet_sk(sk);
> -	struct ipv6_pinfo *np = inet6_sk(sk);
> -	struct flow_keys keys;
> -
> -	memset(&keys, 0, sizeof(keys));
> -
> -	memcpy(&keys.addrs.v6addrs.src, &np->saddr,
> -	       sizeof(keys.addrs.v6addrs.src));
> -	memcpy(&keys.addrs.v6addrs.dst, &sk->sk_v6_daddr,
> -	       sizeof(keys.addrs.v6addrs.dst));
> -	keys.control.addr_type = FLOW_DISSECTOR_KEY_IPV6_ADDRS;
> -	keys.ports.src = inet->inet_sport;
> -	keys.ports.dst = inet->inet_dport;
> -
> -	sk->sk_txhash = flow_hash_from_keys(&keys);
> -}
> -
>   static inline __be32 ip6_make_flowlabel(struct net *net, struct sk_buff *skb,
>   					__be32 flowlabel, bool autolabel)
>   {
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 4353ef7..fe735c4 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -1687,6 +1687,14 @@ static inline void sock_graft(struct sock *sk, struct socket *parent)
>   kuid_t sock_i_uid(struct sock *sk);
>   unsigned long sock_i_ino(struct sock *sk);
>   
> +static inline void sk_set_txhash(struct sock *sk)
> +{
> +	sk->sk_txhash = prandom_u32();
> +
> +	if (unlikely(!sk->sk_txhash))
> +		sk->sk_txhash = 1;
> +}
> +
>   static inline struct dst_entry *
>   __sk_dst_get(struct sock *sk)
>   {
> diff --git a/net/ipv4/datagram.c b/net/ipv4/datagram.c
> index 574fad9..f915abf 100644
> --- a/net/ipv4/datagram.c
> +++ b/net/ipv4/datagram.c
> @@ -74,7 +74,7 @@ int __ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len
>   	inet->inet_daddr = fl4->daddr;
>   	inet->inet_dport = usin->sin_port;
>   	sk->sk_state = TCP_ESTABLISHED;
> -	inet_set_txhash(sk);
> +	sk_set_txhash(sk);
>   	inet->inet_id = jiffies;
>   
>   	sk_dst_set(sk, &rt->dst);
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 486ba96..d27eb54 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -222,7 +222,7 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
>   	if (err)
>   		goto failure;
>   
> -	inet_set_txhash(sk);
> +	sk_set_txhash(sk);
>   
>   	rt = ip_route_newports(fl4, rt, orig_sport, orig_dport,
>   			       inet->inet_sport, inet->inet_dport, sk);
> @@ -1277,7 +1277,7 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
>   	newinet->mc_ttl	      = ip_hdr(skb)->ttl;
>   	newinet->rcv_tos      = ip_hdr(skb)->tos;
>   	inet_csk(newsk)->icsk_ext_hdr_len = 0;
> -	inet_set_txhash(newsk);
> +	sk_set_txhash(newsk);
>   	if (inet_opt)
>   		inet_csk(newsk)->icsk_ext_hdr_len = inet_opt->opt.optlen;
>   	newinet->inet_id = newtp->write_seq ^ jiffies;
> diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
> index 2572a32..9aadd57 100644
> --- a/net/ipv6/datagram.c
> +++ b/net/ipv6/datagram.c
> @@ -199,7 +199,7 @@ ipv4_connected:
>   		      NULL);
>   
>   	sk->sk_state = TCP_ESTABLISHED;
> -	ip6_set_txhash(sk);
> +	sk_set_txhash(sk);
>   out:
>   	fl6_sock_release(flowlabel);
>   	return err;
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index d540846..52dd0d9 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -276,7 +276,7 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
>   	if (err)
>   		goto late_failure;
>   
> -	ip6_set_txhash(sk);
> +	sk_set_txhash(sk);
>   
>   	if (!tp->write_seq && likely(!tp->repair))
>   		tp->write_seq = secure_tcpv6_sequence_number(np->saddr.s6_addr32,
> @@ -1090,7 +1090,7 @@ static struct sock *tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
>   	newsk->sk_v6_rcv_saddr = ireq->ir_v6_loc_addr;
>   	newsk->sk_bound_dev_if = ireq->ir_iif;
>   
> -	ip6_set_txhash(newsk);
> +	sk_set_txhash(newsk);
>   
>   	/* Now IPv6 options...
>   
