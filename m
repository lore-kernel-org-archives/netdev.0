From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] net-gro: Prepare GRO stack for the upcoming
 tunneling support
Date: Tue, 10 Dec 2013 19:19:31 +0000
Message-ID: <1386703171.1516.203.camel@bwh-desktop.uk.level5networks.com>
References: <1386518682-30488-1-git-send-email-hkchu@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Or Gerlitz <ogerlitz@mellanox.com>, <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: "H.K. Jerry Chu" <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17662 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753025Ab3LJTTg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 14:19:36 -0500
In-Reply-To: <1386518682-30488-1-git-send-email-hkchu@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-12-08 at 08:04 -0800, H.K. Jerry Chu wrote:
> From: Jerry Chu <hkchu@google.com>
> 
> This patch modifies the GRO stack to remove the assumption that
> only one IP hdr is present in the encapsulation chain. It avoids
> the use of ip_hdr()/ipv6_hdr() macro in IP's *_gro_receive()/
> *_gro_complete() functions because there may be more than one IP
> hdr present in the encapsulation chain when various flavors of IP
> tunneling support are added. By doing so it also allows multiple
> level, not just a single level (i.e., with only two IP hdrs like
> IP-in-IP) of encapsulation to be supported in the future.
> 
> With this patch, the GRO stack traversing now is mostly based on
> skb_gro_offset rather than special hdr offsets saved in skb (e.g.,
> skb->network_header, skb->transport_header,...) As a consequence
> all but the top layer (which is likely to be the transport layer)
> must have hdrs of the same length in order for a pkt to be
> considered for aggregation. Therefore when adding a new layer
> (e.g., for tunneling), one must check and skip flows (e.g., setting
> NAPI_GRO_CB(p)->same_flow to 0) that have a different hdr length.
> 
> Signed-off-by: H.K. Jerry Chu <hkchu@google.com>
> Suggested-by: Eric Dumazet <edumazet@google.com>
> Reviewed-by: Eric Dumazet <edumazet@google.com>
[...]
> --- a/net/ipv4/tcp_offload.c
> +++ b/net/ipv4/tcp_offload.c
[...]
> @@ -303,16 +308,16 @@ skip_csum:
>  	return tcp_gro_receive(head, skb);
>  }
>  
> -static int tcp4_gro_complete(struct sk_buff *skb)
> +static int tcp4_gro_complete(struct sk_buff *skb, int nhoff)

The offset should definitely be called thoff in this function.

[...]
> --- a/net/ipv6/ip6_offload.c
> +++ b/net/ipv6/ip6_offload.c
[...]
> @@ -198,25 +228,28 @@ static struct sk_buff **ipv6_gro_receive(struct sk_buff **head,
>  
>  		iph = ipv6_hdr(skb);
>  	}
> -
>  	NAPI_GRO_CB(skb)->proto = proto;
>  
>  	flush--;
> -	nlen = skb_network_header_len(skb);
> +	nlen = next_header - skb->network_header;
>  
>  	for (p = *head; p; p = p->next) {
> -		const struct ipv6hdr *iph2;
> +		struct ipv6hdr *iph2;

Why remove const here?

[...]
> -static int ipv6_gro_complete(struct sk_buff *skb)
> +static int ipv6_gro_complete(struct sk_buff *skb, int nhoff)
>  {
>  	const struct net_offload *ops;
> -	struct ipv6hdr *iph = ipv6_hdr(skb);
> +	struct ipv6hdr *iph = (struct ipv6hdr *)(skb->data + nhoff);
>  	int err = -ENOSYS;
>  
> -	iph->payload_len = htons(skb->len - skb_network_offset(skb) -
> -				 sizeof(*iph));
> +	iph->payload_len = htons(skb->len - nhoff - sizeof(*iph));
>  
>  	rcu_read_lock();
> -	ops = rcu_dereference(inet6_offloads[NAPI_GRO_CB(skb)->proto]);
> +
> +	nhoff += sizeof(*iph) + ipv6_exthdrs_len(iph, &ops);

Would be clearer as:
	int thoff;
	...
	thoff = nhoff + ...

>  	if (WARN_ON(!ops || !ops->callbacks.gro_complete))
>  		goto out_unlock;
>  
> -	err = ops->callbacks.gro_complete(skb);
> +	err = ops->callbacks.gro_complete(skb, nhoff);
>  
>  out_unlock:
>  	rcu_read_unlock();
> diff --git a/net/ipv6/tcpv6_offload.c b/net/ipv6/tcpv6_offload.c
> index 6d18157..a107ad6 100644
> --- a/net/ipv6/tcpv6_offload.c
> +++ b/net/ipv6/tcpv6_offload.c
> @@ -66,16 +66,16 @@ skip_csum:
>  	return tcp_gro_receive(head, skb);
>  }
>  
> -static int tcp6_gro_complete(struct sk_buff *skb)
> +static int tcp6_gro_complete(struct sk_buff *skb, int nhoff)
[...]

Same comment as for tcp4_gro_complete().

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
