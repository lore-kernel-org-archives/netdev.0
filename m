From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: [RFC PATCH 1/1] net namespace: dynamically configure new net
 namespace inherit net config
Date: Mon, 14 Mar 2016 13:12:22 +0800
Message-ID: <56E64836.70405@gmail.com>
References: <1457578473-14730-1-git-send-email-yanjun.zhu@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Zhu Yanjun <yanjun.zhu@windriver.com>, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	bruce.ashfield@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36620 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751207AbcCNFLx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 01:11:53 -0400
Received: by mail-pf0-f193.google.com with SMTP id q129so12263732pfb.3
        for <netdev@vger.kernel.org>; Sun, 13 Mar 2016 22:11:52 -0700 (PDT)
In-Reply-To: <1457578473-14730-1-git-send-email-yanjun.zhu@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ping

On 03/10/2016 10:54 AM, Zhu Yanjun wrote:
> Sometimes the system engineer and application expect a new net namespace
> to inherit config from the base net config. Sometimes the current net config
> is expected by the system engineer and application. So it is necessary that
> the system engineer and application can choose a new net namespace to inherit
> from the base net config, or the current net config.
>
> For example, the value of /proc/sys/net/ipv4/ip_forward is taken as
> an example. The value of /proc/sys/net/ipv4/ip_forward in the base net
> config is 0 while the value of /proc/sys/net/ipv4/ip_forward is changed
> to 1 in the current net config. The system engineer and application can choose
> a new net namespace to inherit the value of /proc/sys/net/ipv4/ip_forward from
> the base or the current settings.
>
> Test case:
>
> 1. % cat /proc/sys/net/ipv4/net_ns_inherit
>     1
>
> 2. Set ip forwarding in the "base namespace"
>
>     % echo 1 > /proc/sys/net/ipv4/ip_forward
>
>     % cat /proc/sys/net/ipv4/ip_forward
>     1
>
> 3. Create a new namespace
>
>     % ip netns add mynewns
>
> 4. Check ip forwarding in the new namespace
>
>     % ip netns exec mynewns cat /proc/sys/net/ipv4/ip_forward
>     1
>
> 5. % echo 0 > /proc/sys/net/ipv4/net_ns_inherit
>
>     % cat /proc/sys/net/ipv4/net_ns_inherit
>     0
>
> 6. Set ip forwarding in the "base namespace"
>
>     % echo 1 > /proc/sys/net/ipv4/ip_forward
>
>     % cat /proc/sys/net/ipv4/ip_forward
>     1
>
> 7. Create a new namespace
>
>     % ip netns add mynewns_new
>
> 8. Check ip forwarding in the new namespace
>
>     % ip netns exec mynewns_new cat /proc/sys/net/ipv4/ip_forward
>     0
>
> Suggested-by: Bruce Ashfield <bruce.ashfield@windriver.com>
> Signed-off-by: Zhu Yanjun <yanjun.zhu@windriver.com>
> CC: David S. Miller  <davem@davemloft.net>
> CC: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> CC: James Morris <jmorris@namei.org>
> CC: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> CC: Patrick McHardy <kaber@trash.net>
>
> ---
>   include/linux/inetdevice.h  |    2 +-
>   include/net/ip.h            |    3 +++
>   include/uapi/linux/sysctl.h |    1 +
>   net/ipv4/devinet.c          |   58 ++++++++++++++++++++++++++++++++++++-------
>   net/ipv4/sysctl_net_ipv4.c  |    7 ++++++
>   5 files changed, 61 insertions(+), 10 deletions(-)
>
> diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
> index ee971f3..1c0ae93 100644
> --- a/include/linux/inetdevice.h
> +++ b/include/linux/inetdevice.h
> @@ -164,7 +164,7 @@ static inline struct net_device *ip_dev_find(struct net *net, __be32 addr)
>   
>   int inet_addr_onlink(struct in_device *in_dev, __be32 a, __be32 b);
>   int devinet_ioctl(struct net *net, unsigned int cmd, void __user *);
> -void devinet_init(void);
> +int devinet_init(void);
>   struct in_device *inetdev_by_index(struct net *, int);
>   __be32 inet_select_addr(const struct net_device *dev, __be32 dst, int scope);
>   __be32 inet_confirm_addr(struct net *net, struct in_device *in_dev, __be32 dst,
> diff --git a/include/net/ip.h b/include/net/ip.h
> index 1a98f1c..0ad4a7d 100644
> --- a/include/net/ip.h
> +++ b/include/net/ip.h
> @@ -245,6 +245,9 @@ extern int inet_peer_threshold;
>   extern int inet_peer_minttl;
>   extern int inet_peer_maxttl;
>   
> +/* From devinet.c */
> +extern int net_ns_inherit;
> +
>   /* From ip_input.c */
>   extern int sysctl_ip_early_demux;
>   
> diff --git a/include/uapi/linux/sysctl.h b/include/uapi/linux/sysctl.h
> index 0956373..350c3ce 100644
> --- a/include/uapi/linux/sysctl.h
> +++ b/include/uapi/linux/sysctl.h
> @@ -426,6 +426,7 @@ enum
>   	NET_TCP_ALLOWED_CONG_CONTROL=123,
>   	NET_TCP_MAX_SSTHRESH=124,
>   	NET_TCP_FRTO_RESPONSE=125,
> +	NET_IPV4_NET_NS_INHERIT = 126,
>   };
>   
>   enum {
> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
> index cebd9d3..b68d7fa 100644
> --- a/net/ipv4/devinet.c
> +++ b/net/ipv4/devinet.c
> @@ -2277,28 +2277,31 @@ static struct ctl_table ctl_forward_entry[] = {
>   };
>   #endif
>   
> +#define NET_NS_INIT_DEFAULT	0
> +#define NET_NS_INIT_MODIFIED	1
> +
> +/* net ns initialized from current */
> +int net_ns_inherit __read_mostly = NET_NS_INIT_MODIFIED;
> +static struct ipv4_devconf *all_backup, *dflt_backup;
> +
>   static __net_init int devinet_init_net(struct net *net)
>   {
>   	int err;
> -	struct ipv4_devconf *all, *dflt;
> +	struct ipv4_devconf *all = NULL, *dflt = NULL;
>   #ifdef CONFIG_SYSCTL
>   	struct ctl_table *tbl = ctl_forward_entry;
>   	struct ctl_table_header *forw_hdr;
>   #endif
> -
>   	err = -ENOMEM;
> -	all = &ipv4_devconf;
> -	dflt = &ipv4_devconf_dflt;
>   
> -	if (!net_eq(net, &init_net)) {
> -		all = kmemdup(all, sizeof(ipv4_devconf), GFP_KERNEL);
> +	if (net_ns_inherit == NET_NS_INIT_DEFAULT) {
> +		all = kmemdup(all_backup, sizeof(ipv4_devconf), GFP_KERNEL);
>   		if (!all)
>   			goto err_alloc_all;
>   
> -		dflt = kmemdup(dflt, sizeof(ipv4_devconf_dflt), GFP_KERNEL);
> +		dflt = kmemdup(dflt_backup, sizeof(ipv4_devconf_dflt), GFP_KERNEL);
>   		if (!dflt)
>   			goto err_alloc_dflt;
> -
>   #ifdef CONFIG_SYSCTL
>   		tbl = kmemdup(tbl, sizeof(ctl_forward_entry), GFP_KERNEL);
>   		if (!tbl)
> @@ -2309,6 +2312,29 @@ static __net_init int devinet_init_net(struct net *net)
>   		tbl[0].extra2 = net;
>   #endif
>   	}
> +	if (net_ns_inherit == NET_NS_INIT_MODIFIED) {
> +		all = &ipv4_devconf;
> +		dflt = &ipv4_devconf_dflt;
> +
> +		if (!net_eq(net, &init_net)) {
> +			all = kmemdup(all, sizeof(ipv4_devconf), GFP_KERNEL);
> +			if (!all)
> +				goto err_alloc_all;
> +
> +			dflt = kmemdup(dflt, sizeof(ipv4_devconf_dflt), GFP_KERNEL);
> +			if (!dflt)
> +				goto err_alloc_dflt;
> +#ifdef CONFIG_SYSCTL
> +			tbl = kmemdup(tbl, sizeof(ctl_forward_entry), GFP_KERNEL);
> +			if (!tbl)
> +				goto err_alloc_ctl;
> +
> +			tbl[0].data = &all->data[IPV4_DEVCONF_FORWARDING - 1];
> +			tbl[0].extra1 = all;
> +			tbl[0].extra2 = net;
> +#endif
> +		}
> +	}
>   
>   #ifdef CONFIG_SYSCTL
>   	err = __devinet_sysctl_register(net, "all", all);
> @@ -2360,6 +2386,8 @@ static __net_exit void devinet_exit_net(struct net *net)
>   	__devinet_sysctl_unregister(net->ipv4.devconf_all);
>   	kfree(tbl);
>   #endif
> +	kfree(all_backup);
> +	kfree(dflt_backup);
>   	kfree(net->ipv4.devconf_dflt);
>   	kfree(net->ipv4.devconf_all);
>   }
> @@ -2377,10 +2405,20 @@ static struct rtnl_af_ops inet_af_ops __read_mostly = {
>   	.set_link_af	  = inet_set_link_af,
>   };
>   
> -void __init devinet_init(void)
> +int __init devinet_init(void)
>   {
>   	int i;
>   
> +	all_backup = kmemdup(&ipv4_devconf, sizeof(ipv4_devconf), GFP_KERNEL);
> +	if (!all_backup) {
> +		return -ENOBUFS;
> +	}
> +
> +	dflt_backup = kmemdup(&ipv4_devconf_dflt, sizeof(ipv4_devconf_dflt), GFP_KERNEL);
> +	if (!dflt_backup) {
> +		return -ENOBUFS;
> +	}
> +
>   	for (i = 0; i < IN4_ADDR_HSIZE; i++)
>   		INIT_HLIST_HEAD(&inet_addr_lst[i]);
>   
> @@ -2398,4 +2436,6 @@ void __init devinet_init(void)
>   	rtnl_register(PF_INET, RTM_GETADDR, NULL, inet_dump_ifaddr, NULL);
>   	rtnl_register(PF_INET, RTM_GETNETCONF, inet_netconf_get_devconf,
>   		      inet_netconf_dump_devconf, NULL);
> +
> +	return 0;
>   }
> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
> index a0bd7a5..d4a68e3 100644
> --- a/net/ipv4/sysctl_net_ipv4.c
> +++ b/net/ipv4/sysctl_net_ipv4.c
> @@ -799,6 +799,13 @@ static struct ctl_table ipv4_table[] = {
>   		.proc_handler	= proc_dointvec_minmax,
>   		.extra1		= &one
>   	},
> +	{
> +		.procname	= "net_ns_inherit",
> +		.data		= &net_ns_inherit,
> +		.maxlen		= sizeof(int),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec
> +	},
>   	{ }
>   };
>   
