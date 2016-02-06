From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 2/2] mpls: allow TTL propagation to/from IP packets to be configured
Date: Sat, 06 Feb 2016 12:36:15 -0600
Message-ID: <87r3gpadpc.fsf@x220.int.ebiederm.org>
References: <1454700472-13543-1-git-send-email-rshearma@brocade.com>
	<1454700472-13543-3-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:35281 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753255AbcBFSq7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2016 13:46:59 -0500
In-Reply-To: <1454700472-13543-3-git-send-email-rshearma@brocade.com> (Robert
	Shearman's message of "Fri, 5 Feb 2016 19:27:52 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert Shearman <rshearma@brocade.com> writes:

> It is sometimes desirable to present an MPLS transport network as a
> single hop to traffic transiting it because it prevents confusion when
> diagnosing failures. An example of where confusion can be generated is
> when addresses used in the provider network overlap with addresses in
> the overlay network and the addresses get exposed through ICMP errors
> generated as packets transit the provider network.

The configuration you are talking about is a bug.  ICMP errors can
be handled without confusion simplify by forwarding the packets out
to the end of the tunnel.  Which is how the standards require that
situation to be handled if an ICMP error is generated.

> Therefore, provide the ability to control whether the TTL value from
> an MPLS packet is propagated to an IPv4/IPv6 packet when the last
> label is popped through the addition of a new per-namespace sysctl:
> "net.mpls.ip_ttl_propagate" which defaults to enabled.
>
> Use the same sysctl to control whether the TTL is propagated from IP
> packets into the MPLS header. If the TTL isn't propagated then a
> default TTL value is used which can be configured via a new sysctl:
> "net.mpls.default_ttl".

Ugh.  There is a case for this, but this feels much more like a per
tunnel/label/route egress property not a per network interface property.

I don't recall all of the gory details but some flavors of mpls labels
always require ttl propogation (the ip over mpls default) and some
flavors of mpls labels always require no propagation (pseudo wires).

There may be something cute in between.  For something that is a per
tunnel property I don't feel comfortable with a sysctl.

Especially when it is something as potentially dangerous as enabling
packets to loop in a network.  As I recall most IP over IP tunnels
also propogate the ttl between the inner and outer ip packets to prevent
loops.

Eric

> Signed-off-by: Robert Shearman <rshearma@brocade.com>
> ---
>  Documentation/networking/mpls-sysctl.txt | 19 +++++++++
>  include/net/netns/mpls.h                 |  3 ++
>  net/mpls/af_mpls.c                       | 70 ++++++++++++++++++++++++--------
>  net/mpls/mpls_iptunnel.c                 | 10 ++++-
>  4 files changed, 83 insertions(+), 19 deletions(-)
>
> diff --git a/Documentation/networking/mpls-sysctl.txt b/Documentation/networking/mpls-sysctl.txt
> index 9ed15f86c17c..9e8cfa6d48d1 100644
> --- a/Documentation/networking/mpls-sysctl.txt
> +++ b/Documentation/networking/mpls-sysctl.txt
> @@ -19,6 +19,25 @@ platform_labels - INTEGER
>  	Possible values: 0 - 1048575
>  	Default: 0
>  
> +ip_ttl_propagate - BOOL
> +	Control whether TTL is propagated from the IPv4/IPv6 header to
> +	the MPLS header on imposing labels and propagated from the
> +	MPLS header to the IPv4/IPv6 header on popping the last label.
> +
> +	If disabled, the MPLS transport network will appear as a
> +	single hop to transit traffic.
> +
> +	0 - disabled
> +	1 - enabled (default)
> +
> +default_ttl - BOOL
> +	Default TTL value to use for MPLS packets where it cannot be
> +	propagated from an IP header, either because one isn't present
> +	or ip_ttl_propagate has been disabled.
> +
> +	Possible values: 1 - 255
> +	Default: 255
> +
>  conf/<interface>/input - BOOL
>  	Control whether packets can be input on this interface.
>  
> diff --git a/include/net/netns/mpls.h b/include/net/netns/mpls.h
> index 3062b0aa3a08..9bdc2bd8fcb8 100644
> --- a/include/net/netns/mpls.h
> +++ b/include/net/netns/mpls.h
> @@ -10,7 +10,10 @@ struct ctl_table_header;
>  
>  struct netns_mpls {
>  	size_t platform_labels;
> +	int ip_ttl_propagate;
> +	int default_ttl;
>  	struct mpls_route __rcu * __rcu *platform_label;
> +
>  	struct ctl_table_header *ctl;
>  	struct proc_dir_entry *proc_net_devsnmp;
>  };
> diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
> index 6b3c96e2b21f..a2a4f0a884a3 100644
> --- a/net/mpls/af_mpls.c
> +++ b/net/mpls/af_mpls.c
> @@ -31,7 +31,9 @@
>  #define MPLS_NEIGH_TABLE_UNSPEC (NEIGH_LINK_TABLE + 1)
>  
>  static int zero = 0;
> +static int one = 1;
>  static int label_limit = (1 << 20) - 1;
> +static int ttl_max = 255;
>  
>  static void rtmsg_lfib(int event, u32 label, struct mpls_route *rt,
>  		       struct nlmsghdr *nlh, struct net *net, u32 portid,
> @@ -215,8 +217,8 @@ out:
>  	return &rt->rt_nh[nh_index];
>  }
>  
> -static bool mpls_egress(struct mpls_route *rt, struct sk_buff *skb,
> -			struct mpls_entry_decoded dec)
> +static bool mpls_egress(struct net *net, struct mpls_route *rt,
> +			struct sk_buff *skb, struct mpls_entry_decoded dec)
>  {
>  	enum mpls_payload_type payload_type;
>  	bool success = false;
> @@ -239,24 +241,29 @@ static bool mpls_egress(struct mpls_route *rt, struct sk_buff *skb,
>  		payload_type = ip_hdr(skb)->version;
>  
>  	switch (payload_type) {
> -	case MPT_IPV4: {
> -		struct iphdr *hdr4 = ip_hdr(skb);
> -		skb->protocol = htons(ETH_P_IP);
> -		csum_replace2(&hdr4->check,
> -			      htons(hdr4->ttl << 8),
> -			      htons(dec.ttl << 8));
> -		hdr4->ttl = dec.ttl;
> +	case MPT_IPV4:
> +		if (net->mpls.ip_ttl_propagate) {
> +			struct iphdr *hdr4 = ip_hdr(skb);
> +
> +			skb->protocol = htons(ETH_P_IP);
> +			csum_replace2(&hdr4->check,
> +				      htons(hdr4->ttl << 8),
> +				      htons(dec.ttl << 8));
> +			hdr4->ttl = dec.ttl;
> +		}
>  		success = true;
>  		break;
> -	}
> -	case MPT_IPV6: {
> -		struct ipv6hdr *hdr6 = ipv6_hdr(skb);
> -		skb->protocol = htons(ETH_P_IPV6);
> -		hdr6->hop_limit = dec.ttl;
> +	case MPT_IPV6:
> +		if (net->mpls.ip_ttl_propagate) {
> +			struct ipv6hdr *hdr6 = ipv6_hdr(skb);
> +
> +			skb->protocol = htons(ETH_P_IPV6);
> +			hdr6->hop_limit = dec.ttl;
> +		}
>  		success = true;
>  		break;
> -	}
>  	case MPT_UNSPEC:
> +		/* Should have decided which protocol it is by now */
>  		break;
>  	}
>  
> @@ -356,7 +363,7 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
>  
>  	if (unlikely(!new_header_size && dec.bos)) {
>  		/* Penultimate hop popping */
> -		if (!mpls_egress(rt, skb, dec))
> +		if (!mpls_egress(dev_net(out_dev), rt, skb, dec))
>  			goto err;
>  	} else {
>  		bool bos;
> @@ -1708,6 +1715,9 @@ static int mpls_platform_labels(struct ctl_table *table, int write,
>  	return ret;
>  }
>  
> +#define MPLS_NS_SYSCTL_OFFSET(field)		\
> +	(&((struct net *)0)->field)
> +
>  static const struct ctl_table mpls_table[] = {
>  	{
>  		.procname	= "platform_labels",
> @@ -1716,21 +1726,47 @@ static const struct ctl_table mpls_table[] = {
>  		.mode		= 0644,
>  		.proc_handler	= mpls_platform_labels,
>  	},
> +	{
> +		.procname	= "ip_ttl_propagate",
> +		.data		= MPLS_NS_SYSCTL_OFFSET(mpls.ip_ttl_propagate),
> +		.maxlen		= sizeof(int),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec_minmax,
> +		.extra1		= &zero,
> +		.extra2		= &one,
> +	},
> +	{
> +		.procname	= "default_ttl",
> +		.data		= MPLS_NS_SYSCTL_OFFSET(mpls.default_ttl),
> +		.maxlen		= sizeof(int),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec_minmax,
> +		.extra1		= &one,
> +		.extra2		= &ttl_max,
> +	},
>  	{ }
>  };
>  
>  static int mpls_net_init(struct net *net)
>  {
>  	struct ctl_table *table;
> +	int i;
>  
>  	net->mpls.platform_labels = 0;
>  	net->mpls.platform_label = NULL;
> +	net->mpls.ip_ttl_propagate = 1;
> +	net->mpls.default_ttl = 255;
>  
>  	table = kmemdup(mpls_table, sizeof(mpls_table), GFP_KERNEL);
>  	if (table == NULL)
>  		return -ENOMEM;
>  
> -	table[0].data = net;
> +	/* Table data contains only offsets relative to the base of
> +	 * the mdev at this point, so make them absolute.
> +	 */
> +	for (i = 0; i < ARRAY_SIZE(mpls_table) - 1; i++)
> +		table[i].data = (char *)net + (uintptr_t)table[i].data;
> +
>  	net->mpls.ctl = register_net_sysctl(net, "net/mpls", table);
>  	if (net->mpls.ctl == NULL) {
>  		kfree(table);
> diff --git a/net/mpls/mpls_iptunnel.c b/net/mpls/mpls_iptunnel.c
> index 94d8837d42f6..b2d85d35c322 100644
> --- a/net/mpls/mpls_iptunnel.c
> +++ b/net/mpls/mpls_iptunnel.c
> @@ -59,10 +59,16 @@ static int mpls_output(struct net *net, struct sock *sk, struct sk_buff *skb)
>  
>  	/* Obtain the ttl */
>  	if (dst->ops->family == AF_INET) {
> -		ttl = ip_hdr(skb)->ttl;
> +		if (net->mpls.ip_ttl_propagate)
> +			ttl = ip_hdr(skb)->ttl;
> +		else
> +			ttl = net->mpls.default_ttl;
>  		rt = (struct rtable *)dst;
>  	} else if (dst->ops->family == AF_INET6) {
> -		ttl = ipv6_hdr(skb)->hop_limit;
> +		if (net->mpls.ip_ttl_propagate)
> +			ttl = ipv6_hdr(skb)->hop_limit;
> +		else
> +			ttl = net->mpls.default_ttl;
>  		rt6 = (struct rt6_info *)dst;
>  	} else {
>  		goto drop;
