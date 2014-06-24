From: YOSHIFUJI Hideaki <hideaki@yoshifuji.org>
Subject: Re: [PATCH v2 2/2] ipv6:  Allow accepting RA from local IP addresses.
Date: Wed, 25 Jun 2014 07:22:02 +0900
Message-ID: <53A9FA0A.70902@yoshifuji.org>
References: <1403644488-21709-1-git-send-email-greearb@candelatech.com> <1403644488-21709-2-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	hideaki.yoshifuji@miraclelinux.com
To: greearb@candelatech.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:51297 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750925AbaFXWa1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2014 18:30:27 -0400
In-Reply-To: <1403644488-21709-2-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

(2014/06/25 6:14), greearb@candelatech.com wrote:
> From: Ben Greear <greearb@candelatech.com>
> 
> This can be used in virtual networking applications, and
> may have other uses as well.  The option is disabled by
> default, so no change to current operating behaviour

                                  standard compliant behavior?

> without the user explicitly changing the behaviour.
> 

Would you include your specific example?

> Signed-off-by: Ben Greear <greearb@candelatech.com>
> ---
> 
> v2:  Add suggested static helper method, do not consider
>       the 'all' config option, only specific iface.
> Patch is against 3.14.8+
> 
>   Documentation/networking/ip-sysctl.txt | 12 ++++++++++++
>   include/linux/ipv6.h                   |  1 +
>   include/uapi/linux/ipv6.h              |  1 +
>   include/uapi/linux/sysctl.h            |  1 +
>   kernel/sysctl_binary.c                 |  1 +
>   net/ipv6/addrconf.c                    | 10 ++++++++++
>   net/ipv6/ndisc.c                       | 23 +++++++++++++++++------
>   7 files changed, 43 insertions(+), 6 deletions(-)
> 
> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
> index a30ecc6..0656756 100644
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -1223,6 +1223,18 @@ accept_ra_defrtr - BOOLEAN
>   	Functional default: enabled if accept_ra is enabled.
>   			    disabled if accept_ra is disabled.
>   
> +accept_ra_from_local - BOOLEAN
> +	Accept RA with source-address that is found on local machine
> +        if the RA is otherwise proper and able to be accepted.
> +        Default is to NOT accept these as it may be an un-intended
> +        network loop.
> +
> +	Functional default:
> +           enabled if accept_ra_from_local is enabled
> +               on a specific interface.
> +	   disabled if accept_ra_from_local is disabled
> +               on a specific interface.
> +
>   accept_ra_pinfo - BOOLEAN
>   	Learn Prefix Information in Router Advertisement.
>   
> diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
> index 2faef33..de635d1 100644
> --- a/include/linux/ipv6.h
> +++ b/include/linux/ipv6.h
> @@ -39,6 +39,7 @@ struct ipv6_devconf {
>   #endif
>   	__s32		proxy_ndp;
>   	__s32		accept_source_route;
> +	__s32		accept_ra_from_local;
>   #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
>   	__s32		optimistic_dad;
>   #endif
> diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
> index 593b0e3..efa2666 100644
> --- a/include/uapi/linux/ipv6.h
> +++ b/include/uapi/linux/ipv6.h
> @@ -163,6 +163,7 @@ enum {
>   	DEVCONF_MLDV1_UNSOLICITED_REPORT_INTERVAL,
>   	DEVCONF_MLDV2_UNSOLICITED_REPORT_INTERVAL,
>   	DEVCONF_SUPPRESS_FRAG_NDISC,
> +	DEVCONF_ACCEPT_RA_FROM_LOCAL,
>   	DEVCONF_MAX
>   };
>   
> diff --git a/include/uapi/linux/sysctl.h b/include/uapi/linux/sysctl.h
> index 7544146..ce15796 100644
> --- a/include/uapi/linux/sysctl.h
> +++ b/include/uapi/linux/sysctl.h
> @@ -568,6 +568,7 @@ enum {
>   	NET_IPV6_ACCEPT_RA_RT_INFO_MAX_PLEN=22,
>   	NET_IPV6_PROXY_NDP=23,
>   	NET_IPV6_ACCEPT_SOURCE_ROUTE=25,
> +	NET_IPV6_ACCEPT_RA_FROM_LOCAL=26,
>   	__NET_IPV6_MAX
>   };
>   
> diff --git a/kernel/sysctl_binary.c b/kernel/sysctl_binary.c
> index 6eacbcf..e10b51a 100644
> --- a/kernel/sysctl_binary.c
> +++ b/kernel/sysctl_binary.c
> @@ -523,6 +523,7 @@ static const struct bin_table bin_net_ipv6_conf_var_table[] = {
>   	{ CTL_INT,	NET_IPV6_ACCEPT_RA_RT_INFO_MAX_PLEN,	"accept_ra_rt_info_max_plen" },
>   	{ CTL_INT,	NET_IPV6_PROXY_NDP,			"proxy_ndp" },
>   	{ CTL_INT,	NET_IPV6_ACCEPT_SOURCE_ROUTE,		"accept_source_route" },
> +	{ CTL_INT,	NET_IPV6_ACCEPT_RA_FROM_LOCAL,		"accept_ra_from_local" },
>   	{}
>   };
>   
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 6c7fa08..f0b7305 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -186,6 +186,7 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
>   	.max_desync_factor	= MAX_DESYNC_FACTOR,
>   	.max_addresses		= IPV6_MAX_ADDRESSES,
>   	.accept_ra_defrtr	= 1,
> +	.accept_ra_from_local	= 0,
>   	.accept_ra_pinfo	= 1,
>   #ifdef CONFIG_IPV6_ROUTER_PREF
>   	.accept_ra_rtr_pref	= 1,
> @@ -222,6 +223,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
>   	.max_desync_factor	= MAX_DESYNC_FACTOR,
>   	.max_addresses		= IPV6_MAX_ADDRESSES,
>   	.accept_ra_defrtr	= 1,
> +	.accept_ra_from_local	= 0,
>   	.accept_ra_pinfo	= 1,
>   #ifdef CONFIG_IPV6_ROUTER_PREF
>   	.accept_ra_rtr_pref	= 1,
> @@ -4326,6 +4328,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
>   	array[DEVCONF_FORCE_TLLAO] = cnf->force_tllao;
>   	array[DEVCONF_NDISC_NOTIFY] = cnf->ndisc_notify;
>   	array[DEVCONF_SUPPRESS_FRAG_NDISC] = cnf->suppress_frag_ndisc;
> +	array[DEVCONF_ACCEPT_RA_FROM_LOCAL] = cnf->accept_ra_from_local;
>   }
>   
>   static inline size_t inet6_ifla6_size(void)
> @@ -5173,6 +5176,13 @@ static struct addrconf_sysctl_table
>   			.proc_handler	= proc_dointvec
>   		},
>   		{
> +			.procname	= "accept_ra_from_local",
> +			.data		= &ipv6_devconf.accept_ra_from_local,
> +			.maxlen		= sizeof(int),
> +			.mode		= 0644,
> +			.proc_handler	= proc_dointvec,
> +		},
> +		{
>   			/* sentinel */
>   		}
>   	},
> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
> index 2fef3d5..2165d5e 100644
> --- a/net/ipv6/ndisc.c
> +++ b/net/ipv6/ndisc.c
> @@ -1057,6 +1057,19 @@ errout:
>   	rtnl_set_sk_err(net, RTNLGRP_ND_USEROPT, err);
>   }
>   
> +static bool ipv6_accept_ra_local(struct inet6_dev *in6_dev, struct sk_buf *skb)
> +{
> +	/* Do not accept RA with source-addr found on local machine unless
> +	 * accept_ra_from_local is set to true.
> +	 */
> +	if (!in6_dev->cnf.accept_ra_from_local &&
> +	    ipv6_chk_addr(dev_net(in6_dev->dev), &ipv6_hdr(skb)->saddr,
> +			  NULL, 0))
> +		return false;
> +	return true;
> +}
> +
> +
>   static void ndisc_router_discovery(struct sk_buff *skb)
>   {
>   	struct ra_msg *ra_msg = (struct ra_msg *)skb_transport_header(skb);
> @@ -1151,10 +1164,9 @@ static void ndisc_router_discovery(struct sk_buff *skb)
>   		goto skip_defrtr;
>   	}
>   
> -	if (ipv6_chk_addr(dev_net(in6_dev->dev), &ipv6_hdr(skb)->saddr,
> -			  NULL, 0)) {
> +	if (!ipv6_accept_ra_local(in6_dev, skb)) {
>   		ND_PRINTK(2, info,
> -			  "RA: %s, chk_addr failed for dev: %s\n",
> +			  "RA: %s, accept_ra_local failed for dev: %s\n",
>   			  __func__, skb->dev->name);
>   		goto skip_defrtr;
>   	}

Hmm, without global knob, I see little benefit by
having new helper.

At least, it should be called ipv6_chk_addr_ra(),
ipv6_check_ra_saddr(), ipv6_is_nonlocal_ra() or
something else.

I think we do not need to change debugging output,
or we could say "RA from local address detected; 
default router ignored." or something like.

> @@ -1293,10 +1305,9 @@ skip_linkparms:
>   	}
>   
>   #ifdef CONFIG_IPV6_ROUTE_INFO
> -	if (ipv6_chk_addr(dev_net(in6_dev->dev), &ipv6_hdr(skb)->saddr,
> -			  NULL, 0)) {
> +	if (!ipv6_accept_ra_local(in6_dev, skb)) {
>   		ND_PRINTK(2, info,
> -			  "RA: %s, chk-addr (route info) is false for dev: %s\n",
> +			  "RA: %s, accept_ra_local (route info) failed for dev: %s\n",
>   			  __func__, skb->dev->name);

I think it original is just okay because this message 
does not appears if the new option is enabled by hand.

About debugging output, similar for default router.

>   		goto skip_routeinfo;
>   	}
> 

--yoshfuji
