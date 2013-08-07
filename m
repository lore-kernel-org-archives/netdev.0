From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: [PATCH 5/5] netfilter: add IPv6 SYNPROXY target
Date: Wed, 7 Aug 2013 22:34:40 +0200
Message-ID: <20130807223440.0a40a7c1@redhat.com>
References: <1375897371-18430-1-git-send-email-kaber@trash.net>
	<1375897371-18430-6-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, mph@one.com, as@one.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1375897371-18430-6-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wed,  7 Aug 2013 19:42:51 +0200 Patrick McHardy <kaber@trash.net> wrote:

> Add an IPv6 version of the SYNPROXY target. The main differences to
> the IPv4 version is routing and IP header construction.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

[...]

> diff --git a/net/ipv6/netfilter/ip6t_SYNPROXY.c
> b/net/ipv6/netfilter/ip6t_SYNPROXY.c new file mode 100644
> index 0000000..ee773da
> --- /dev/null
> +++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
[...]

> +static void
> +synproxy_send_server_syn(const struct synproxy_net *snet,
> +			 const struct sk_buff *skb, const struct tcphdr *th,
> +			 const struct synproxy_options *opts)
> +{
> +	struct sk_buff *nskb;
> +	struct ipv6hdr *iph, *niph;
> +	struct tcphdr *nth;
> +	unsigned int tcp_hdr_size;
> +
> +	iph = ipv6_hdr(skb);
> +
> +	tcp_hdr_size = sizeof(*nth) + synproxy_options_size(opts);
> +	nskb = alloc_skb(sizeof(*niph) + tcp_hdr_size + LL_MAX_HEADER,
> +			 GFP_ATOMIC);
> +	if (nskb == NULL)
> +		return;
> +	skb_reserve(nskb, LL_MAX_HEADER);
> +
> +	niph = synproxy_build_ip(nskb, &iph->saddr, &iph->daddr);
> +
> +	skb_reset_transport_header(nskb);
> +	nth = (struct tcphdr *)skb_put(nskb, tcp_hdr_size);
> +	nth->source	= th->source;
> +	nth->dest	= th->dest;
> +	nth->seq	= htonl(ntohl(th->seq) - 1);
> +	nth->ack_seq	= htonl(ntohl(th->ack_seq) - 1);;

Strange double ";;".

And as IPv4, shouldn't this be zero? I might be wrong...


> +	tcp_flag_word(nth) = TCP_FLAG_SYN;
> +	if (opts->options & XT_SYNPROXY_OPT_ECN)
> +		tcp_flag_word(nth) |= TCP_FLAG_ECE | TCP_FLAG_CWR;
> +	nth->doff	= tcp_hdr_size / 4;
> +	nth->window	= th->window;
> +	nth->check	= 0;
> +	nth->urg_ptr	= 0;
> +
> +	synproxy_build_options(nth, opts);
> +
> +	synproxy_send_tcp(skb, nskb, &snet->tmpl->ct_general, IP_CT_NEW,
> +			  niph, nth, tcp_hdr_size);
> +}
> +
> +static void
> +synproxy_send_server_ack(const struct synproxy_net *snet,
> +			 const struct ip_ct_tcp *state,
> +			 const struct sk_buff *skb, const struct tcphdr *th,
> +			 const struct synproxy_options *opts)
> +{
> +	struct sk_buff *nskb;
> +	struct ipv6hdr *iph, *niph;
> +	struct tcphdr *nth;
> +	unsigned int tcp_hdr_size;
> +
> +	iph = ipv6_hdr(skb);
> +
> +	tcp_hdr_size = sizeof(*nth) + synproxy_options_size(opts);
> +	nskb = alloc_skb(sizeof(*niph) + tcp_hdr_size + LL_MAX_HEADER,
> +			 GFP_ATOMIC);
> +	if (nskb == NULL)
> +		return;
> +	skb_reserve(nskb, LL_MAX_HEADER);
> +
> +	niph = synproxy_build_ip(nskb, &iph->daddr, &iph->saddr);
> +
> +	skb_reset_transport_header(nskb);
> +	nth = (struct tcphdr *)skb_put(nskb, tcp_hdr_size);
> +	nth->source	= th->dest;
> +	nth->dest	= th->source;
> +	nth->seq	= htonl(ntohl(th->ack_seq));
> +	nth->ack_seq	= htonl(ntohl(th->seq) + 1);;

Strange double ";;"


> +	tcp_flag_word(nth) = TCP_FLAG_ACK;
> +	nth->doff	= tcp_hdr_size / 4;
> +	nth->window	=
> htons(state->seen[IP_CT_DIR_ORIGINAL].td_maxwin);
> +	nth->check	= 0;
> +	nth->urg_ptr	= 0;
> +
> +	synproxy_build_options(nth, opts);
> +
> +	synproxy_send_tcp(skb, nskb, skb->nfct, IP_CT_ESTABLISHED,
> +			  niph, nth, tcp_hdr_size);
> +}
> +


> +static int synproxy_tg6_check(const struct xt_tgchk_param *par)
> +{
> +	/// XXX PROTO match TCP

Ups, this looks like an comment to your self ;-)

> +	return nf_ct_l3proto_try_module_get(par->family);
> +}



-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
