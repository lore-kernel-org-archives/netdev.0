From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] net: diag: support SOCK_DESTROY for UDP sockets
Date: Thu, 18 Aug 2016 21:17:39 -0700
Message-ID: <1471580259.29842.96.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1471573759-23145-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:35740 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752380AbcHSESC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 00:18:02 -0400
Received: by mail-pa0-f67.google.com with SMTP id cf3so2770285pad.2
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 21:17:41 -0700 (PDT)
In-Reply-To: <1471573759-23145-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-08-18 at 19:29 -0700, David Ahern wrote:
> This implements SOCK_DESTROY for UDP sockets similar to what was done
> for TCP with commit c1e64e298b8ca ("net: diag: Support destroying TCP
> sockets.") A process with a UDP socket targeted for destroy is awakened
> and recvmsg fails with ECONNABORTED giving the process notice that
> it should close the socket.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>  include/net/udp.h   |  8 ++++++++
>  net/ipv4/udp.c      | 58 +++++++++++++++++++++++++++++++++++++++++++++++++++++
>  net/ipv4/udp_diag.c | 55 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  net/ipv6/udp.c      | 45 +++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 166 insertions(+)
> 
> diff --git a/include/net/udp.h b/include/net/udp.h
> index 8894d7144189..5c3443634b4d 100644
> --- a/include/net/udp.h
> +++ b/include/net/udp.h
> @@ -251,6 +251,7 @@ int udp_get_port(struct sock *sk, unsigned short snum,
>  		 int (*saddr_cmp)(const struct sock *,
>  				  const struct sock *));
>  void udp_err(struct sk_buff *, u32);
> +int udp_abort(struct sock *sk, int err);
>  int udp_sendmsg(struct sock *sk, struct msghdr *msg, size_t len);
>  int udp_push_pending_frames(struct sock *sk);
>  void udp_flush_pending_frames(struct sock *sk);
> @@ -274,6 +275,9 @@ struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
>  			       struct udp_table *tbl, struct sk_buff *skb);
>  struct sock *udp4_lib_lookup_skb(struct sk_buff *skb,
>  				 __be16 sport, __be16 dport);
> +struct sock *udp4_lib_lookup_full(struct net *net, __be32 saddr,
> +				  __be16 sport, __be32 daddr, __be16 dport,
> +				  int dif, struct udp_table *table);
>  struct sock *udp6_lib_lookup(struct net *net,
>  			     const struct in6_addr *saddr, __be16 sport,
>  			     const struct in6_addr *daddr, __be16 dport,
> @@ -286,6 +290,10 @@ struct sock *__udp6_lib_lookup(struct net *net,
>  struct sock *udp6_lib_lookup_skb(struct sk_buff *skb,
>  				 __be16 sport, __be16 dport);
>  
> +struct sock *udp6_lib_lookup_full(struct net *net,
> +				  const struct in6_addr *saddr, __be16 sport,
> +				  const struct in6_addr *daddr, __be16 dport,
> +				  int dif, struct udp_table *table);
>  /*
>   * 	SNMP statistics for UDP and UDP-Lite
>   */
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index e61f7cd65d08..e5b72a7165e1 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -594,6 +594,47 @@ struct sock *udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
>  EXPORT_SYMBOL_GPL(udp4_lib_lookup);
>  #endif
>  
> +/* caller should hold rcu lock */
> +struct sock *udp4_lib_lookup_full(struct net *net, __be32 saddr,
> +				  __be16 sport, __be32 daddr, __be16 dport,
> +				  int dif, struct udp_table *table)
> +{
> +	struct sock *sk;
> +	int i;
> +
> +	for (i = 0; i <= table->mask; i++) {
> +		struct udp_hslot *hslot = &table->hash[i];
> +
> +		sk_for_each_rcu(sk, &hslot->head) {
> +			struct inet_sock *inet;
> +
> +			if (!net_eq(sock_net(sk), net) ||
> +			    ipv6_only_sock(sk))
> +				continue;
> +
> +			if (dif && sk->sk_bound_dev_if != dif)
> +				continue;
> +
> +			if (sk->sk_family != PF_INET)
> +				continue;
> +
> +			if (udp_sk(sk)->udp_port_hash != ntohs(sport))
> +				continue;
> +
> +			inet = inet_sk(sk);
> +			if (inet->inet_rcv_saddr != saddr  ||
> +			    inet->inet_daddr     != daddr  ||
> +			    inet->inet_dport     != dport)
> +				continue;
> +
> +			return sk;
> +		}
> +	}
> +
> +	return NULL;
> +}


Why are you iterating the whole table ?

Normally, udp_hashfn(net, ntohs(dport), udptable->mask) slot should be
enough to find all sockets bound to dport.
