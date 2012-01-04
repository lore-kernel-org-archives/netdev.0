From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [PATCH 1/1] netfilter: Add possibility to turn off netfilters
 defrag per netns
Date: Wed, 4 Jan 2012 09:28:05 +0100 (CET)
Message-ID: <alpine.DEB.2.00.1201040922020.925@blackhole.kfki.hu>
References: <1325664443-10320-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>, jengelh@medozas.de,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	hans@schillstrom.com
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1325664443-10320-1-git-send-email-hans.schillstrom@ericsson.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Hans,

On Wed, 4 Jan 2012, Hans Schillstrom wrote:

> In some cases it not desirable to have auto defrag.
> Ex. in a cluster where packets can arrive on different blades.
> In that case it is possible to use containers (LXC) and send
> all fragments to one place where defrag is enabled.
> 
> This patch makes it possible to turn off the defrag per network name space,
> by setting net.netfilter.nf_conntrack_nodefrag to 1.
> Both IPv4 and IPv6 is effected by this sysctl.
> Default is 0 which is defrag.

Conntrack assumes that the packets are defragmented and will drop any 
unfragmented one. So your patch results packet drops.

Also, if you want to disable defragmentation then why don't you simply 
"mark" the packets with the NOTRACK target?

Best regards,
Jozsef
 
> Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
> ---
>  include/net/netns/conntrack.h             |    1 +
>  net/ipv4/netfilter/nf_defrag_ipv4.c       |    8 ++++++++
>  net/ipv6/netfilter/nf_defrag_ipv6_hooks.c |    6 ++++++
>  net/netfilter/nf_conntrack_standalone.c   |    8 ++++++++
>  4 files changed, 23 insertions(+), 0 deletions(-)
> 
> diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
> index 7a911ec..059f7b5 100644
> --- a/include/net/netns/conntrack.h
> +++ b/include/net/netns/conntrack.h
> @@ -26,6 +26,7 @@ struct netns_ct {
>  	int			sysctl_tstamp;
>  	int			sysctl_checksum;
>  	unsigned int		sysctl_log_invalid; /* Log invalid packets */
> +	int			sysctl_nodefrag;
>  #ifdef CONFIG_SYSCTL
>  	struct ctl_table_header	*sysctl_header;
>  	struct ctl_table_header	*acct_sysctl_header;
> diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
> index 9bb1b8a..f4908b3 100644
> --- a/net/ipv4/netfilter/nf_defrag_ipv4.c
> +++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
> @@ -74,6 +74,14 @@ static unsigned int ipv4_conntrack_defrag(unsigned int hooknum,
>  		return NF_ACCEPT;
>  
>  #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
> +	/* Check for no defrag options */
> +	{
> +		const struct net_device *dev = (hooknum == NF_INET_LOCAL_OUT ?
> +						out : in);
> +
> +		if (dev_net(dev)->ct.sysctl_nodefrag)
> +			return NF_ACCEPT;
> +	}
>  #if !defined(CONFIG_NF_NAT) && !defined(CONFIG_NF_NAT_MODULE)
>  	/* Previously seen (loopback)?  Ignore.  Do this before
>  	   fragment check. */
> diff --git a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
> index cdd6d04..4b0a05b 100644
> --- a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
> +++ b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
> @@ -61,6 +61,12 @@ static unsigned int ipv6_defrag(unsigned int hooknum,
>  	struct sk_buff *reasm;
>  
>  #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
> +	/* Check for no defrag options */
> +	const struct net_device *dev = (hooknum == NF_INET_LOCAL_OUT ?
> +					out : in);
> +
> +	if (dev_net(dev)->ct.sysctl_nodefrag)
> +		return NF_ACCEPT;
>  	/* Previously seen (loopback)?	*/
>  	if (skb->nfct && !nf_ct_is_template((struct nf_conn *)skb->nfct))
>  		return NF_ACCEPT;
> diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
> index 885f5ab..95c489f 100644
> --- a/net/netfilter/nf_conntrack_standalone.c
> +++ b/net/netfilter/nf_conntrack_standalone.c
> @@ -446,6 +446,13 @@ static ctl_table nf_ct_sysctl_table[] = {
>  		.extra2		= &log_invalid_proto_max,
>  	},
>  	{
> +		.procname	= "nf_conntrack_nodefrag",
> +		.data		= &init_net.ct.sysctl_nodefrag,
> +		.maxlen		= sizeof(int),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec,
> +	},
> +	{
>  		.procname	= "nf_conntrack_expect_max",
>  		.data		= &nf_ct_expect_max,
>  		.maxlen		= sizeof(int),
> @@ -493,6 +500,7 @@ static int nf_conntrack_standalone_init_sysctl(struct net *net)
>  	table[2].data = &net->ct.htable_size;
>  	table[3].data = &net->ct.sysctl_checksum;
>  	table[4].data = &net->ct.sysctl_log_invalid;
> +	table[5].data = &net->ct.sysctl_nodefrag;
>  
>  	net->ct.sysctl_header = register_net_sysctl_table(net,
>  					nf_net_netfilter_sysctl_path, table);
> -- 
> 1.7.2.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
