From: yzhu1 <Yanjun.Zhu@windriver.com>
Subject: Re: [PATCH 1/1] net namespace: dynamically configure new net namespace
 inherit net config
Date: Thu, 8 Oct 2015 14:44:18 +0800
Message-ID: <561610C2.5000309@windriver.com>
References: <1435311439-26916-1-git-send-email-Yanjun.Zhu@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:55194 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751336AbbJHGoV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 02:44:21 -0400
In-Reply-To: <1435311439-26916-1-git-send-email-Yanjun.Zhu@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Miller

Would you like to check this patch?

Thanks a lot.
Zhu Yanjun

On 06/26/2015 05:37 PM, Zhu Yanjun wrote:
> The new net namespace can inherit from the original net config, or
> the current net config. As such, a config is needed to decide where
> the new namespace inherit from.
>
> Signed-off-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>
> ---
>   init/Kconfig       |  9 +++++++++
>   net/ipv4/devinet.c | 13 +++++++++++++
>   2 files changed, 22 insertions(+)
>
> diff --git a/init/Kconfig b/init/Kconfig
> index dc24dec..fab8c41 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -1212,6 +1212,15 @@ config NET_NS
>   	  Allow user space to create what appear to be multiple instances
>   	  of the network stack.
>   
> +config NET_NS_INHERIT_ORIGINAL
> +	bool "New network namespace inherits from original net config"
> +	depends on NET_NS
> +	default n
> +	help
> +	  Allow new network namespace inherit from original net config.
> +	  If no, the new network namespace inherits from the current net
> +	  config including the modified net config.
> +
>   endif # NAMESPACES
>   
>   config SCHED_AUTOGROUP
> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
> index 419d23c..cf635e4 100644
> --- a/net/ipv4/devinet.c
> +++ b/net/ipv4/devinet.c
> @@ -2271,6 +2271,7 @@ static __net_init int devinet_init_net(struct net *net)
>   #endif
>   
>   	err = -ENOMEM;
> +#ifndef CONFIG_NET_NS_INHERIT_ORIGINAL
>   	all = &ipv4_devconf;
>   	dflt = &ipv4_devconf_dflt;
>   
> @@ -2282,6 +2283,15 @@ static __net_init int devinet_init_net(struct net *net)
>   		dflt = kmemdup(dflt, sizeof(ipv4_devconf_dflt), GFP_KERNEL);
>   		if (!dflt)
>   			goto err_alloc_dflt;
> +#else
> +	all = kmemdup(&ipv4_devconf, sizeof(ipv4_devconf), GFP_KERNEL);
> +	if (!all)
> +		goto err_alloc_all;
> +
> +	dflt = kmemdup(&ipv4_devconf_dflt, sizeof(ipv4_devconf_dflt), GFP_KERNEL);
> +	if (!dflt)
> +		goto err_alloc_dflt;
> +#endif
>   
>   #ifdef CONFIG_SYSCTL
>   		tbl = kmemdup(tbl, sizeof(ctl_forward_entry), GFP_KERNEL);
> @@ -2292,7 +2302,10 @@ static __net_init int devinet_init_net(struct net *net)
>   		tbl[0].extra1 = all;
>   		tbl[0].extra2 = net;
>   #endif
> +
> +#ifndef CONFIG_NET_NS_INHERIT_ORIGINAL
>   	}
> +#endif
>   
>   #ifdef CONFIG_SYSCTL
>   	err = __devinet_sysctl_register(net, "all", all);
