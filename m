From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [net-next PATCH] Don't lookup the socket if there's a socket
	attached to the skb (was: Re: [net-next PATCH 10/16] Don't lookup
	the socket if there's a socket attached to the skb)
Date: Tue, 7 Oct 2008 09:36:26 -0300
Message-ID: <20081007123626.GB29610@ghostprotocols.net>
References: <20081001142431.4893.69772.stgit@este> <20081001.075040.135314845.davem@davemloft.net> <1222875500.7492.6.camel@este> <20081001.085104.193726318.davem@davemloft.net> <1222962200.14079.19.camel@este> <20081002170935.GE17843@ghostprotocols.net> <1223024268.8912.2.camel@este> <20081003134747.GH17843@ghostprotocols.net> <1223366369.35518.13.camel@nessa.odu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: KOVACS Krisztian <hidden@sch.bme.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1223366369.35518.13.camel@nessa.odu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Tue, Oct 07, 2008 at 09:59:29AM +0200, KOVACS Krisztian escreveu:
> Hi,
> 
> On Fri, 2008-10-03 at 10:47 -0300, Arnaldo Carvalho de Melo wrote:
> > > Those functions don't have access to the skb so unless we change the
> > > signature they won't be able to steal the reference.
> > 
> > Indeed, but we should try to have the main TCP code flow clean, ditto for
> > DCCP, free of such details, so after this activitity settles down I'll
> > submit something like the patch below.
> > 
> > If Dave agrees and you feel like merging it on your current patchset,
> > feel free to do it.
> 
> And here's the modified use-cached-sk-if-present patch built on top of
> the previous two x_lookup_skb() helper patches.
> 
> -- 
> KOVACS Krisztian
> 
> 
> Don't lookup the socket if there's a socket attached to the skb
> 
> Use the socket cached in the skb if it's present.
> 
> Signed-off-by: KOVACS Krisztian <hidden@sch.bme.hu>
> ---
> 
>  include/net/inet6_hashtables.h |   12 ++++++++----
>  include/net/inet_hashtables.h  |    9 ++++++---
>  include/net/sock.h             |   12 ++++++++++++
>  net/ipv4/udp.c                 |    9 ++++++---
>  net/ipv6/udp.c                 |    9 ++++++---
>  5 files changed, 38 insertions(+), 13 deletions(-)
> 
> 
> diff --git a/include/net/inet6_hashtables.h b/include/net/inet6_hashtables.h
> index 995efbb..f74665d 100644
> --- a/include/net/inet6_hashtables.h
> +++ b/include/net/inet6_hashtables.h
> @@ -96,10 +96,14 @@ static inline struct sock *__inet6_lookup_skb(struct inet_hashinfo *hashinfo,
>  					      const __be16 sport,
>  					      const __be16 dport)
>  {
> -	return __inet6_lookup(dev_net(skb->dst->dev), hashinfo,
> -			      &ipv6_hdr(skb)->saddr, sport,
> -			      &ipv6_hdr(skb)->daddr, ntohs(dport),
> -			      inet6_iif(skb));
> +	struct sock *sk;
> +
> +	if (unlikely(sk = skb_steal_sock(skb)))
> +		return sk;
> +	else return __inet6_lookup(dev_net(skb->dst->dev), hashinfo,
> +				   &ipv6_hdr(skb)->saddr, sport,
> +				   &ipv6_hdr(skb)->daddr, ntohs(dport),
> +				   inet6_iif(skb));
>  }
>  
>  extern struct sock *inet6_lookup(struct net *net, struct inet_hashinfo *hashinfo,
> diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
> index 3522bbc..72b9ba5 100644
> --- a/include/net/inet_hashtables.h
> +++ b/include/net/inet_hashtables.h
> @@ -378,11 +378,14 @@ static inline struct sock *__inet_lookup_skb(struct inet_hashinfo *hashinfo,
>  					     const __be16 sport,
>  					     const __be16 dport)
>  {
> +	struct sock *sk;
>  	const struct iphdr *iph = ip_hdr(skb);
>  
> -	return __inet_lookup(dev_net(skb->dst->dev), hashinfo,
> -			     iph->saddr, sport,
> -			     iph->daddr, dport, inet_iif(skb));
> +	if (unlikely(sk = skb_steal_sock(skb)))
> +		return sk;
> +	else return __inet_lookup(dev_net(skb->dst->dev), hashinfo,
> +				  iph->saddr, sport,
> +				  iph->daddr, dport, inet_iif(skb));

return on a different line, please:

	else
		return

>  }
>  
>  extern int __inet_hash_connect(struct inet_timewait_death_row *death_row,
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 75a312d..18f9670 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -1324,6 +1324,18 @@ static inline void sk_change_net(struct sock *sk, struct net *net)
>  	sock_net_set(sk, hold_net(net));
>  }
>  
> +static inline struct sock *skb_steal_sock(struct sk_buff *skb)
> +{
> +	if (unlikely(skb->sk)) {
> +		struct sock *sk = skb->sk;
> +
> +		skb->destructor = NULL;
> +		skb->sk = NULL;
> +		return sk;
> +	}
> +	return NULL;
> +}
> +
>  extern void sock_enable_timestamp(struct sock *sk);
>  extern int sock_get_timestamp(struct sock *, struct timeval __user *);
>  extern int sock_get_timestampns(struct sock *, struct timespec __user *);
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 8369f4d..219a4aa 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -306,11 +306,14 @@ static inline struct sock *__udp4_lib_lookup_skb(struct sk_buff *skb,
>  						 __be16 sport, __be16 dport,
>  						 struct hlist_head udptable[])
>  {
> +	struct sock *sk;
>  	const struct iphdr *iph = ip_hdr(skb);
>  
> -	return __udp4_lib_lookup(dev_net(skb->dst->dev), iph->saddr, sport,
> -				 iph->daddr, dport, inet_iif(skb),
> -				 udptable);
> +	if (unlikely(sk = skb_steal_sock(skb)))
> +		return sk;
> +	else return __udp4_lib_lookup(dev_net(skb->dst->dev), iph->saddr, sport,
> +				      iph->daddr, dport, inet_iif(skb),
> +				      udptable);

ditto

>  }
>  
>  struct sock *udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
> diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
> index ce26c41..95a2b56 100644
> --- a/net/ipv6/udp.c
> +++ b/net/ipv6/udp.c
> @@ -111,11 +111,14 @@ static struct sock *__udp6_lib_lookup_skb(struct sk_buff *skb,
>  					  __be16 sport, __be16 dport,
>  					  struct hlist_head udptable[])
>  {
> +	struct sock *sk;
>  	struct ipv6hdr *iph = ipv6_hdr(skb);
>  
> -	return __udp6_lib_lookup(dev_net(skb->dst->dev), &iph->saddr, sport,
> -				 &iph->daddr, dport, inet6_iif(skb),
> -				 udptable);
> +	if (unlikely(sk = skb_steal_sock(skb)))
> +		return sk;
> +	else return __udp6_lib_lookup(dev_net(skb->dst->dev), &iph->saddr, sport,
> +				      &iph->daddr, dport, inet6_iif(skb),
> +				      udptable);

ditto


After you fix this up, please add:

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
