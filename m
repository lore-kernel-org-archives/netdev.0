From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v2 1/2] netfilter: ip6t_SYNPROXY: fix NULL pointer
 dereference
Date: Mon, 10 Aug 2015 09:57:21 +0200
Message-ID: <20150810075721.GB20899@acer.localdomain>
References: <20150808155746.GC29362@acer.localdomain>
 <1439118856-26484-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1439118856-26484-1-git-send-email-phil@nwl.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09.08, Phil Sutter wrote:
> This happens when networking namespaces are enabled.
> 
> Suggested-by: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Acked-by: Patrick McHardy <kaber@trash.net>

> ---
> Changes since v1:
> - Moved snet param to first place.
> - Constify snet param.
> ---
>  net/ipv6/netfilter/ip6t_SYNPROXY.c | 18 ++++++++++--------
>  1 file changed, 10 insertions(+), 8 deletions(-)
> 
> diff --git a/net/ipv6/netfilter/ip6t_SYNPROXY.c b/net/ipv6/netfilter/ip6t_SYNPROXY.c
> index 6edb7b1..bcebc24 100644
> --- a/net/ipv6/netfilter/ip6t_SYNPROXY.c
> +++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
> @@ -37,12 +37,13 @@ synproxy_build_ip(struct sk_buff *skb, const struct in6_addr *saddr,
>  }
>  
>  static void
> -synproxy_send_tcp(const struct sk_buff *skb, struct sk_buff *nskb,
> +synproxy_send_tcp(const struct synproxy_net *snet,
> +		  const struct sk_buff *skb, struct sk_buff *nskb,
>  		  struct nf_conntrack *nfct, enum ip_conntrack_info ctinfo,
>  		  struct ipv6hdr *niph, struct tcphdr *nth,
>  		  unsigned int tcp_hdr_size)
>  {
> -	struct net *net = nf_ct_net((struct nf_conn *)nfct);
> +	struct net *net = nf_ct_net(snet->tmpl);
>  	struct dst_entry *dst;
>  	struct flowi6 fl6;
>  
> @@ -83,7 +84,8 @@ free_nskb:
>  }
>  
>  static void
> -synproxy_send_client_synack(const struct sk_buff *skb, const struct tcphdr *th,
> +synproxy_send_client_synack(const struct synproxy_net *snet,
> +			    const struct sk_buff *skb, const struct tcphdr *th,
>  			    const struct synproxy_options *opts)
>  {
>  	struct sk_buff *nskb;
> @@ -119,7 +121,7 @@ synproxy_send_client_synack(const struct sk_buff *skb, const struct tcphdr *th,
>  
>  	synproxy_build_options(nth, opts);
>  
> -	synproxy_send_tcp(skb, nskb, skb->nfct, IP_CT_ESTABLISHED_REPLY,
> +	synproxy_send_tcp(snet, skb, nskb, skb->nfct, IP_CT_ESTABLISHED_REPLY,
>  			  niph, nth, tcp_hdr_size);
>  }
>  
> @@ -163,7 +165,7 @@ synproxy_send_server_syn(const struct synproxy_net *snet,
>  
>  	synproxy_build_options(nth, opts);
>  
> -	synproxy_send_tcp(skb, nskb, &snet->tmpl->ct_general, IP_CT_NEW,
> +	synproxy_send_tcp(snet, skb, nskb, &snet->tmpl->ct_general, IP_CT_NEW,
>  			  niph, nth, tcp_hdr_size);
>  }
>  
> @@ -203,7 +205,7 @@ synproxy_send_server_ack(const struct synproxy_net *snet,
>  
>  	synproxy_build_options(nth, opts);
>  
> -	synproxy_send_tcp(skb, nskb, NULL, 0, niph, nth, tcp_hdr_size);
> +	synproxy_send_tcp(snet, skb, nskb, NULL, 0, niph, nth, tcp_hdr_size);
>  }
>  
>  static void
> @@ -241,7 +243,7 @@ synproxy_send_client_ack(const struct synproxy_net *snet,
>  
>  	synproxy_build_options(nth, opts);
>  
> -	synproxy_send_tcp(skb, nskb, NULL, 0, niph, nth, tcp_hdr_size);
> +	synproxy_send_tcp(snet, skb, nskb, NULL, 0, niph, nth, tcp_hdr_size);
>  }
>  
>  static bool
> @@ -301,7 +303,7 @@ synproxy_tg6(struct sk_buff *skb, const struct xt_action_param *par)
>  					  XT_SYNPROXY_OPT_SACK_PERM |
>  					  XT_SYNPROXY_OPT_ECN);
>  
> -		synproxy_send_client_synack(skb, th, &opts);
> +		synproxy_send_client_synack(snet, skb, th, &opts);
>  		return NF_DROP;
>  
>  	} else if (th->ack && !(th->fin || th->rst || th->syn)) {
> -- 
> 2.1.2
> 
