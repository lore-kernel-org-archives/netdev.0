From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 3/3] [IPV6]: Replace sk_buff ** with sk_buff * in input
 handlers
Date: Mon, 15 Oct 2007 00:43:03 +0900 (JST)
Message-ID: <20071015.004303.71155143.yoshfuji@linux-ipv6.org>
References: <20071014144649.GA14792@gondor.apana.org.au>
	<E1Ih4m9-0003s7-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, davem@davemloft.net, hadi@cyberus.ca,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, tgraf@suug.ch,
	yoshfuji@linux-ipv6.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:53656 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756535AbXJNPlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Oct 2007 11:41:07 -0400
In-Reply-To: <E1Ih4m9-0003s7-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert,

I really appreciate this work.
Thank you!

--yoshfuji

In article <E1Ih4m9-0003s7-00@gondolin.me.apana.org.au> (at Sun, 14 Oct 2007 22:49:05 +0800), Herbert Xu <herbert@gondor.apana.org.au> says:

> [IPV6]: Replace sk_buff ** with sk_buff * in input handlers
> 
> With all the users of the double pointers removed from the IPv6 input path,
> this patch converts all occurances of sk_buff ** to sk_buff * in IPv6 input
> handlers.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> ---
> 
>  include/net/ipv6.h     |    2 +-
>  include/net/protocol.h |    2 +-
>  include/net/xfrm.h     |    2 +-
>  net/dccp/ipv6.c        |    3 +--
>  net/ipv6/exthdrs.c     |   41 ++++++++++++++---------------------------
>  net/ipv6/icmp.c        |    5 ++---
>  net/ipv6/ip6_input.c   |    4 ++--
>  net/ipv6/reassembly.c  |    3 +--
>  net/ipv6/tcp_ipv6.c    |    3 +--
>  net/ipv6/tunnel6.c     |    6 ++----
>  net/ipv6/udp.c         |    7 +++----
>  net/ipv6/udp_impl.h    |    2 +-
>  net/ipv6/udplite.c     |    4 ++--
>  net/ipv6/xfrm6_input.c |    4 ++--
>  net/sctp/ipv6.c        |    4 ++--
>  15 files changed, 36 insertions(+), 56 deletions(-)
> 
> diff --git a/include/net/ipv6.h b/include/net/ipv6.h
> index 31b3f1b..abd8584 100644
> --- a/include/net/ipv6.h
> +++ b/include/net/ipv6.h
> @@ -240,7 +240,7 @@ extern int 			ip6_ra_control(struct sock *sk, int sel,
>  					       void (*destructor)(struct sock *));
>  
>  
> -extern int			ipv6_parse_hopopts(struct sk_buff **skbp);
> +extern int			ipv6_parse_hopopts(struct sk_buff *skb);
>  
>  extern struct ipv6_txoptions *  ipv6_dup_options(struct sock *sk, struct ipv6_txoptions *opt);
>  extern struct ipv6_txoptions *	ipv6_renew_options(struct sock *sk, struct ipv6_txoptions *opt,
> diff --git a/include/net/protocol.h b/include/net/protocol.h
> index 105bf12..1166ffb 100644
> --- a/include/net/protocol.h
> +++ b/include/net/protocol.h
> @@ -45,7 +45,7 @@ struct net_protocol {
>  #if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
>  struct inet6_protocol 
>  {
> -	int	(*handler)(struct sk_buff **skb);
> +	int	(*handler)(struct sk_buff *skb);
>  
>  	void	(*err_handler)(struct sk_buff *skb,
>  			       struct inet6_skb_parm *opt,
> diff --git a/include/net/xfrm.h b/include/net/xfrm.h
> index 77be396..0e84484 100644
> --- a/include/net/xfrm.h
> +++ b/include/net/xfrm.h
> @@ -1051,7 +1051,7 @@ extern int xfrm4_output(struct sk_buff *skb);
>  extern int xfrm4_tunnel_register(struct xfrm_tunnel *handler, unsigned short family);
>  extern int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler, unsigned short family);
>  extern int xfrm6_rcv_spi(struct sk_buff *skb, __be32 spi);
> -extern int xfrm6_rcv(struct sk_buff **pskb);
> +extern int xfrm6_rcv(struct sk_buff *skb);
>  extern int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
>  			    xfrm_address_t *saddr, u8 proto);
>  extern int xfrm6_tunnel_register(struct xfrm6_tunnel *handler, unsigned short family);
> diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
> index 006a383..cac5354 100644
> --- a/net/dccp/ipv6.c
> +++ b/net/dccp/ipv6.c
> @@ -767,10 +767,9 @@ discard:
>  	return 0;
>  }
>  
> -static int dccp_v6_rcv(struct sk_buff **pskb)
> +static int dccp_v6_rcv(struct sk_buff *skb)
>  {
>  	const struct dccp_hdr *dh;
> -	struct sk_buff *skb = *pskb;
>  	struct sock *sk;
>  	int min_cov;
>  
> diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
> index 0ff2bf1..1e89efd 100644
> --- a/net/ipv6/exthdrs.c
> +++ b/net/ipv6/exthdrs.c
> @@ -102,7 +102,7 @@ EXPORT_SYMBOL_GPL(ipv6_find_tlv);
>  
>  struct tlvtype_proc {
>  	int	type;
> -	int	(*func)(struct sk_buff **skbp, int offset);
> +	int	(*func)(struct sk_buff *skb, int offset);
>  };
>  
>  /*********************
> @@ -111,10 +111,8 @@ struct tlvtype_proc {
>  
>  /* An unknown option is detected, decide what to do */
>  
> -static int ip6_tlvopt_unknown(struct sk_buff **skbp, int optoff)
> +static int ip6_tlvopt_unknown(struct sk_buff *skb, int optoff)
>  {
> -	struct sk_buff *skb = *skbp;
> -
>  	switch ((skb_network_header(skb)[optoff] & 0xC0) >> 6) {
>  	case 0: /* ignore */
>  		return 1;
> @@ -139,9 +137,8 @@ static int ip6_tlvopt_unknown(struct sk_buff **skbp, int optoff)
>  
>  /* Parse tlv encoded option header (hop-by-hop or destination) */
>  
> -static int ip6_parse_tlv(struct tlvtype_proc *procs, struct sk_buff **skbp)
> +static int ip6_parse_tlv(struct tlvtype_proc *procs, struct sk_buff *skb)
>  {
> -	struct sk_buff *skb = *skbp;
>  	struct tlvtype_proc *curr;
>  	const unsigned char *nh = skb_network_header(skb);
>  	int off = skb_network_header_len(skb);
> @@ -172,13 +169,13 @@ static int ip6_parse_tlv(struct tlvtype_proc *procs, struct sk_buff **skbp)
>  					/* type specific length/alignment
>  					   checks will be performed in the
>  					   func(). */
> -					if (curr->func(skbp, off) == 0)
> +					if (curr->func(skb, off) == 0)
>  						return 0;
>  					break;
>  				}
>  			}
>  			if (curr->type < 0) {
> -				if (ip6_tlvopt_unknown(skbp, off) == 0)
> +				if (ip6_tlvopt_unknown(skb, off) == 0)
>  					return 0;
>  			}
>  			break;
> @@ -198,9 +195,8 @@ bad:
>   *****************************/
>  
>  #if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
> -static int ipv6_dest_hao(struct sk_buff **skbp, int optoff)
> +static int ipv6_dest_hao(struct sk_buff *skb, int optoff)
>  {
> -	struct sk_buff *skb = *skbp;
>  	struct ipv6_destopt_hao *hao;
>  	struct inet6_skb_parm *opt = IP6CB(skb);
>  	struct ipv6hdr *ipv6h = ipv6_hdr(skb);
> @@ -271,9 +267,8 @@ static struct tlvtype_proc tlvprocdestopt_lst[] = {
>  	{-1,			NULL}
>  };
>  
> -static int ipv6_destopt_rcv(struct sk_buff **skbp)
> +static int ipv6_destopt_rcv(struct sk_buff *skb)
>  {
> -	struct sk_buff *skb = *skbp;
>  	struct inet6_skb_parm *opt = IP6CB(skb);
>  #if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
>  	__u16 dstbuf;
> @@ -295,9 +290,8 @@ static int ipv6_destopt_rcv(struct sk_buff **skbp)
>  #endif
>  
>  	dst = dst_clone(skb->dst);
> -	if (ip6_parse_tlv(tlvprocdestopt_lst, skbp)) {
> +	if (ip6_parse_tlv(tlvprocdestopt_lst, skb)) {
>  		dst_release(dst);
> -		skb = *skbp;
>  		skb->transport_header += (skb_transport_header(skb)[1] + 1) << 3;
>  		opt = IP6CB(skb);
>  #if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
> @@ -328,10 +322,8 @@ void __init ipv6_destopt_init(void)
>    NONE header. No data in packet.
>   ********************************/
>  
> -static int ipv6_nodata_rcv(struct sk_buff **skbp)
> +static int ipv6_nodata_rcv(struct sk_buff *skb)
>  {
> -	struct sk_buff *skb = *skbp;
> -
>  	kfree_skb(skb);
>  	return 0;
>  }
> @@ -351,9 +343,8 @@ void __init ipv6_nodata_init(void)
>    Routing header.
>   ********************************/
>  
> -static int ipv6_rthdr_rcv(struct sk_buff **skbp)
> +static int ipv6_rthdr_rcv(struct sk_buff *skb)
>  {
> -	struct sk_buff *skb = *skbp;
>  	struct inet6_skb_parm *opt = IP6CB(skb);
>  	struct in6_addr *addr = NULL;
>  	struct in6_addr daddr;
> @@ -565,9 +556,8 @@ static inline struct inet6_dev *ipv6_skb_idev(struct sk_buff *skb)
>  
>  /* Router Alert as of RFC 2711 */
>  
> -static int ipv6_hop_ra(struct sk_buff **skbp, int optoff)
> +static int ipv6_hop_ra(struct sk_buff *skb, int optoff)
>  {
> -	struct sk_buff *skb = *skbp;
>  	const unsigned char *nh = skb_network_header(skb);
>  
>  	if (nh[optoff + 1] == 2) {
> @@ -582,9 +572,8 @@ static int ipv6_hop_ra(struct sk_buff **skbp, int optoff)
>  
>  /* Jumbo payload */
>  
> -static int ipv6_hop_jumbo(struct sk_buff **skbp, int optoff)
> +static int ipv6_hop_jumbo(struct sk_buff *skb, int optoff)
>  {
> -	struct sk_buff *skb = *skbp;
>  	const unsigned char *nh = skb_network_header(skb);
>  	u32 pkt_len;
>  
> @@ -635,9 +624,8 @@ static struct tlvtype_proc tlvprochopopt_lst[] = {
>  	{ -1, }
>  };
>  
> -int ipv6_parse_hopopts(struct sk_buff **skbp)
> +int ipv6_parse_hopopts(struct sk_buff *skb)
>  {
> -	struct sk_buff *skb = *skbp;
>  	struct inet6_skb_parm *opt = IP6CB(skb);
>  
>  	/*
> @@ -654,8 +642,7 @@ int ipv6_parse_hopopts(struct sk_buff **skbp)
>  	}
>  
>  	opt->hop = sizeof(struct ipv6hdr);
> -	if (ip6_parse_tlv(tlvprochopopt_lst, skbp)) {
> -		skb = *skbp;
> +	if (ip6_parse_tlv(tlvprochopopt_lst, skb)) {
>  		skb->transport_header += (skb_transport_header(skb)[1] + 1) << 3;
>  		opt = IP6CB(skb);
>  		opt->nhoff = sizeof(struct ipv6hdr);
> diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
> index 47b8ce2..9bb031f 100644
> --- a/net/ipv6/icmp.c
> +++ b/net/ipv6/icmp.c
> @@ -82,7 +82,7 @@ EXPORT_SYMBOL(icmpv6msg_statistics);
>  static DEFINE_PER_CPU(struct socket *, __icmpv6_socket) = NULL;
>  #define icmpv6_socket	__get_cpu_var(__icmpv6_socket)
>  
> -static int icmpv6_rcv(struct sk_buff **pskb);
> +static int icmpv6_rcv(struct sk_buff *skb);
>  
>  static struct inet6_protocol icmpv6_protocol = {
>  	.handler	=	icmpv6_rcv,
> @@ -614,9 +614,8 @@ static void icmpv6_notify(struct sk_buff *skb, int type, int code, __be32 info)
>   *	Handle icmp messages
>   */
>  
> -static int icmpv6_rcv(struct sk_buff **pskb)
> +static int icmpv6_rcv(struct sk_buff *skb)
>  {
> -	struct sk_buff *skb = *pskb;
>  	struct net_device *dev = skb->dev;
>  	struct inet6_dev *idev = __in6_dev_get(dev);
>  	struct in6_addr *saddr, *daddr;
> diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
> index 9149fc2..af355df 100644
> --- a/net/ipv6/ip6_input.c
> +++ b/net/ipv6/ip6_input.c
> @@ -125,7 +125,7 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
>  	}
>  
>  	if (hdr->nexthdr == NEXTHDR_HOP) {
> -		if (ipv6_parse_hopopts(&skb) < 0) {
> +		if (ipv6_parse_hopopts(skb) < 0) {
>  			IP6_INC_STATS_BH(idev, IPSTATS_MIB_INHDRERRORS);
>  			rcu_read_unlock();
>  			return 0;
> @@ -199,7 +199,7 @@ resubmit:
>  		    !xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb))
>  			goto discard;
>  
> -		ret = ipprot->handler(&skb);
> +		ret = ipprot->handler(skb);
>  		if (ret > 0)
>  			goto resubmit;
>  		else if (ret == 0)
> diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
> index fa1055b..79c3253 100644
> --- a/net/ipv6/reassembly.c
> +++ b/net/ipv6/reassembly.c
> @@ -730,9 +730,8 @@ out_fail:
>  	return -1;
>  }
>  
> -static int ipv6_frag_rcv(struct sk_buff **skbp)
> +static int ipv6_frag_rcv(struct sk_buff *skb)
>  {
> -	struct sk_buff *skb = *skbp;
>  	struct frag_hdr *fhdr;
>  	struct frag_queue *fq;
>  	struct ipv6hdr *hdr = ipv6_hdr(skb);
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index a07b59c..737b755 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -1668,9 +1668,8 @@ ipv6_pktoptions:
>  	return 0;
>  }
>  
> -static int tcp_v6_rcv(struct sk_buff **pskb)
> +static int tcp_v6_rcv(struct sk_buff *skb)
>  {
> -	struct sk_buff *skb = *pskb;
>  	struct tcphdr *th;
>  	struct sock *sk;
>  	int ret;
> diff --git a/net/ipv6/tunnel6.c b/net/ipv6/tunnel6.c
> index 23e2809..6323921 100644
> --- a/net/ipv6/tunnel6.c
> +++ b/net/ipv6/tunnel6.c
> @@ -87,9 +87,8 @@ int xfrm6_tunnel_deregister(struct xfrm6_tunnel *handler, unsigned short family)
>  
>  EXPORT_SYMBOL(xfrm6_tunnel_deregister);
>  
> -static int tunnel6_rcv(struct sk_buff **pskb)
> +static int tunnel6_rcv(struct sk_buff *skb)
>  {
> -	struct sk_buff *skb = *pskb;
>  	struct xfrm6_tunnel *handler;
>  
>  	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
> @@ -106,9 +105,8 @@ drop:
>  	return 0;
>  }
>  
> -static int tunnel46_rcv(struct sk_buff **pskb)
> +static int tunnel46_rcv(struct sk_buff *skb)
>  {
> -	struct sk_buff *skb = *pskb;
>  	struct xfrm6_tunnel *handler;
>  
>  	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
> diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
> index 82ff26d..caebad6 100644
> --- a/net/ipv6/udp.c
> +++ b/net/ipv6/udp.c
> @@ -405,10 +405,9 @@ static inline int udp6_csum_init(struct sk_buff *skb, struct udphdr *uh,
>  	return 0;
>  }
>  
> -int __udp6_lib_rcv(struct sk_buff **pskb, struct hlist_head udptable[],
> +int __udp6_lib_rcv(struct sk_buff *skb, struct hlist_head udptable[],
>  		   int proto)
>  {
> -	struct sk_buff *skb = *pskb;
>  	struct sock *sk;
>  	struct udphdr *uh;
>  	struct net_device *dev = skb->dev;
> @@ -494,9 +493,9 @@ discard:
>  	return 0;
>  }
>  
> -static __inline__ int udpv6_rcv(struct sk_buff **pskb)
> +static __inline__ int udpv6_rcv(struct sk_buff *skb)
>  {
> -	return __udp6_lib_rcv(pskb, udp_hash, IPPROTO_UDP);
> +	return __udp6_lib_rcv(skb, udp_hash, IPPROTO_UDP);
>  }
>  
>  /*
> diff --git a/net/ipv6/udp_impl.h b/net/ipv6/udp_impl.h
> index 6e252f3..2d3fda6 100644
> --- a/net/ipv6/udp_impl.h
> +++ b/net/ipv6/udp_impl.h
> @@ -6,7 +6,7 @@
>  #include <net/addrconf.h>
>  #include <net/inet_common.h>
>  
> -extern int  	__udp6_lib_rcv(struct sk_buff **, struct hlist_head [], int );
> +extern int  	__udp6_lib_rcv(struct sk_buff *, struct hlist_head [], int );
>  extern void 	__udp6_lib_err(struct sk_buff *, struct inet6_skb_parm *,
>  			       int , int , int , __be32 , struct hlist_head []);
>  
> diff --git a/net/ipv6/udplite.c b/net/ipv6/udplite.c
> index f54016a..766566f 100644
> --- a/net/ipv6/udplite.c
> +++ b/net/ipv6/udplite.c
> @@ -17,9 +17,9 @@
>  
>  DEFINE_SNMP_STAT(struct udp_mib, udplite_stats_in6) __read_mostly;
>  
> -static int udplitev6_rcv(struct sk_buff **pskb)
> +static int udplitev6_rcv(struct sk_buff *skb)
>  {
> -	return __udp6_lib_rcv(pskb, udplite_hash, IPPROTO_UDPLITE);
> +	return __udp6_lib_rcv(skb, udplite_hash, IPPROTO_UDPLITE);
>  }
>  
>  static void udplitev6_err(struct sk_buff *skb,
> diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
> index c858537..02f69e5 100644
> --- a/net/ipv6/xfrm6_input.c
> +++ b/net/ipv6/xfrm6_input.c
> @@ -133,9 +133,9 @@ drop:
>  
>  EXPORT_SYMBOL(xfrm6_rcv_spi);
>  
> -int xfrm6_rcv(struct sk_buff **pskb)
> +int xfrm6_rcv(struct sk_buff *skb)
>  {
> -	return xfrm6_rcv_spi(*pskb, 0);
> +	return xfrm6_rcv_spi(skb, 0);
>  }
>  
>  EXPORT_SYMBOL(xfrm6_rcv);
> diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
> index 9de3dda..eb4deaf 100644
> --- a/net/sctp/ipv6.c
> +++ b/net/sctp/ipv6.c
> @@ -954,9 +954,9 @@ static struct inet_protosw sctpv6_stream_protosw = {
>  	.flags         = SCTP_PROTOSW_FLAG,
>  };
>  
> -static int sctp6_rcv(struct sk_buff **pskb)
> +static int sctp6_rcv(struct sk_buff *skb)
>  {
> -	return sctp_rcv(*pskb) ? -1 : 0;
> +	return sctp_rcv(skb) ? -1 : 0;
>  }
>  
>  static struct inet6_protocol sctpv6_protocol = {
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
