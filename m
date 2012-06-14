From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 02/10] netfilter: add parameter proto for
 l4proto.init_net
Date: Thu, 14 Jun 2012 19:59:03 +0200
Message-ID: <20120614175903.GB10633@1984>
References: <1339668445-23848-1-git-send-email-gaofeng@cn.fujitsu.com>
 <1339668445-23848-2-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1339668445-23848-2-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 14, 2012 at 06:07:17PM +0800, Gao feng wrote:
> there are redundancy codes in l4proto's init_net functions.
> we can use one init_net function and l3proto to impletment
> the same thing.
> 
> So we should add l3proto as a parameter for init_net function.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> ---
>  include/net/netfilter/nf_conntrack_l4proto.h   |    2 +-
>  net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |    2 +-
>  net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |    2 +-
>  net/netfilter/nf_conntrack_proto.c             |    6 ++++--
>  net/netfilter/nf_conntrack_proto_dccp.c        |    2 +-
>  net/netfilter/nf_conntrack_proto_generic.c     |    2 +-
>  net/netfilter/nf_conntrack_proto_gre.c         |    2 +-
>  net/netfilter/nf_conntrack_proto_sctp.c        |    4 ++--
>  net/netfilter/nf_conntrack_proto_tcp.c         |    4 ++--
>  net/netfilter/nf_conntrack_proto_udp.c         |    4 ++--
>  net/netfilter/nf_conntrack_proto_udplite.c     |    2 +-
>  11 files changed, 17 insertions(+), 15 deletions(-)
> 
> diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
> index 81c52b5..5dd60f2 100644
> --- a/include/net/netfilter/nf_conntrack_l4proto.h
> +++ b/include/net/netfilter/nf_conntrack_l4proto.h
> @@ -97,7 +97,7 @@ struct nf_conntrack_l4proto {
>  #endif
>  	int	*net_id;
>  	/* Init l4proto pernet data */
> -	int (*init_net)(struct net *net);
> +	int (*init_net)(struct net *net, u_int16_t proto);
>  
>  	/* Protocol name */
>  	const char *name;
> diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
> index 041923c..76f7a2f 100644
> --- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
> +++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
> @@ -337,7 +337,7 @@ static struct ctl_table icmp_compat_sysctl_table[] = {
>  #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
>  #endif /* CONFIG_SYSCTL */
>  
> -static int icmp_init_net(struct net *net)
> +static int icmp_init_net(struct net *net, u_int16_t proto)
>  {
>  	struct nf_icmp_net *in = icmp_pernet(net);
>  	struct nf_proto_net *pn = (struct nf_proto_net *)in;
> diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
> index 63ed012..807ae09 100644
> --- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
> +++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
> @@ -333,7 +333,7 @@ static struct ctl_table icmpv6_sysctl_table[] = {
>  };
>  #endif /* CONFIG_SYSCTL */
>  
> -static int icmpv6_init_net(struct net *net)
> +static int icmpv6_init_net(struct net *net, u_int16_t proto)
>  {
>  	struct nf_icmp_net *in = icmpv6_pernet(net);
>  	struct nf_proto_net *pn = (struct nf_proto_net *)in;
> diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
> index a434dd7..8fc0332 100644
> --- a/net/netfilter/nf_conntrack_proto.c
> +++ b/net/netfilter/nf_conntrack_proto.c
> @@ -193,6 +193,7 @@ static int nf_ct_l3proto_register_sysctl(struct net *net,
>  					    l3proto->ctl_table_path,
>  					    in->ctl_table,
>  					    NULL);
> +

This entire patchset contains many extra new lines. If you want to
provide some cleanup, it should come in some follow-up patch.

>  		if (err < 0) {
>  			kfree(in->ctl_table);
>  			in->ctl_table = NULL;
> @@ -460,7 +461,7 @@ int nf_conntrack_l4proto_register(struct net *net,
>  {
>  	int ret = 0;
>  	if (l4proto->init_net) {
> -		ret = l4proto->init_net(net);
> +		ret = l4proto->init_net(net, l4proto->l3proto);
>  		if (ret < 0)
>  			return ret;
>  	}
> @@ -514,7 +515,8 @@ int nf_conntrack_proto_init(struct net *net)
>  {
>  	unsigned int i;
>  	int err;
> -	err = nf_conntrack_l4proto_generic.init_net(net);
> +	err = nf_conntrack_l4proto_generic.init_net(net,
> +						    nf_conntrack_l4proto_generic.l3proto);

You have to make sure that lines break at 80-chars per column.

Something like this should be fine:

        err = nf_conntrack_l4proto_generic.init_net(net,
                                        nf_conntrack_l4proto_generic.l3proto);


>  	if (err < 0)
>  		return err;
>  	err = nf_ct_l4proto_register_sysctl(net,
> diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
> index c33f76a..52da8f0 100644
> --- a/net/netfilter/nf_conntrack_proto_dccp.c
> +++ b/net/netfilter/nf_conntrack_proto_dccp.c
> @@ -815,7 +815,7 @@ static struct ctl_table dccp_sysctl_table[] = {
>  };
>  #endif /* CONFIG_SYSCTL */
>  
> -static int dccp_init_net(struct net *net)
> +static int dccp_init_net(struct net *net, u_int16_t proto)
>  {
>  	struct dccp_net *dn = dccp_pernet(net);
>  	struct nf_proto_net *pn = (struct nf_proto_net *)dn;
> diff --git a/net/netfilter/nf_conntrack_proto_generic.c b/net/netfilter/nf_conntrack_proto_generic.c
> index bb0e74f..d1ed7b4 100644
> --- a/net/netfilter/nf_conntrack_proto_generic.c
> +++ b/net/netfilter/nf_conntrack_proto_generic.c
> @@ -135,7 +135,7 @@ static struct ctl_table generic_compat_sysctl_table[] = {
>  #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
>  #endif /* CONFIG_SYSCTL */
>  
> -static int generic_init_net(struct net *net)
> +static int generic_init_net(struct net *net, u_int16_t proto)
>  {
>  	struct nf_generic_net *gn = generic_pernet(net);
>  	struct nf_proto_net *pn = (struct nf_proto_net *)gn;
> diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
> index 25ba5a2..851b93b 100644
> --- a/net/netfilter/nf_conntrack_proto_gre.c
> +++ b/net/netfilter/nf_conntrack_proto_gre.c
> @@ -348,7 +348,7 @@ gre_timeout_nla_policy[CTA_TIMEOUT_GRE_MAX+1] = {
>  };
>  #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
>  
> -static int gre_init_net(struct net *net)
> +static int gre_init_net(struct net *net, u_int16_t proto)
>  {
>  	struct netns_proto_gre *net_gre = gre_pernet(net);
>  	int i;
> diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
> index 8fb0582..1e7836c 100644
> --- a/net/netfilter/nf_conntrack_proto_sctp.c
> +++ b/net/netfilter/nf_conntrack_proto_sctp.c
> @@ -767,7 +767,7 @@ static int sctp_kmemdup_compat_sysctl_table(struct nf_proto_net *pn)
>  	return 0;
>  }
>  
> -static int sctpv4_init_net(struct net *net)
> +static int sctpv4_init_net(struct net *net, u_int16_t proto)
>  {
>  	int ret;
>  	struct sctp_net *sn = sctp_pernet(net);
> @@ -793,7 +793,7 @@ static int sctpv4_init_net(struct net *net)
>  	return ret;
>  }
>  
> -static int sctpv6_init_net(struct net *net)
> +static int sctpv6_init_net(struct net *net, u_int16_t proto)
>  {
>  	struct sctp_net *sn = sctp_pernet(net);
>  	struct nf_proto_net *pn = (struct nf_proto_net *)sn;
> diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
> index 99caa13..6db9d3c 100644
> --- a/net/netfilter/nf_conntrack_proto_tcp.c
> +++ b/net/netfilter/nf_conntrack_proto_tcp.c
> @@ -1593,7 +1593,7 @@ static int tcp_kmemdup_compat_sysctl_table(struct nf_proto_net *pn)
>  	return 0;
>  }
>  
> -static int tcpv4_init_net(struct net *net)
> +static int tcpv4_init_net(struct net *net, u_int16_t proto)
>  {
>  	int i;
>  	int ret = 0;
> @@ -1631,7 +1631,7 @@ static int tcpv4_init_net(struct net *net)
>  	return ret;
>  }
>  
> -static int tcpv6_init_net(struct net *net)
> +static int tcpv6_init_net(struct net *net, u_int16_t proto)
>  {
>  	int i;
>  	struct nf_tcp_net *tn = tcp_pernet(net);
> diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
> index a83cf93..2b978e6 100644
> --- a/net/netfilter/nf_conntrack_proto_udp.c
> +++ b/net/netfilter/nf_conntrack_proto_udp.c
> @@ -283,7 +283,7 @@ static void udp_init_net_data(struct nf_udp_net *un)
>  	}
>  }
>  
> -static int udpv4_init_net(struct net *net)
> +static int udpv4_init_net(struct net *net, u_int16_t proto)
>  {
>  	int ret;
>  	struct nf_udp_net *un = udp_pernet(net);
> @@ -307,7 +307,7 @@ static int udpv4_init_net(struct net *net)
>  	return ret;
>  }
>  
> -static int udpv6_init_net(struct net *net)
> +static int udpv6_init_net(struct net *net, u_int16_t proto)
>  {
>  	struct nf_udp_net *un = udp_pernet(net);
>  	struct nf_proto_net *pn = (struct nf_proto_net *)un;
> diff --git a/net/netfilter/nf_conntrack_proto_udplite.c b/net/netfilter/nf_conntrack_proto_udplite.c
> index b32e700..d33e511 100644
> --- a/net/netfilter/nf_conntrack_proto_udplite.c
> +++ b/net/netfilter/nf_conntrack_proto_udplite.c
> @@ -234,7 +234,7 @@ static struct ctl_table udplite_sysctl_table[] = {
>  };
>  #endif /* CONFIG_SYSCTL */
>  
> -static int udplite_init_net(struct net *net)
> +static int udplite_init_net(struct net *net, u_int16_t proto)
>  {
>  	int i;
>  	struct udplite_net *un = udplite_pernet(net);
> -- 
> 1.7.7.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
