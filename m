From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH 1/1] net namespace: dynamically configure new net
 namespace inherit net config
Date: Fri, 26 Jun 2015 10:34:19 -0400
Message-ID: <CAP=VYLo+rAjzEU8WJYuby9AhWLnQ_12N42LrnAT0ZUKcHvfVMw@mail.gmail.com>
References: <1435311439-26916-1-git-send-email-Yanjun.Zhu@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Zhu Yanjun <Yanjun.Zhu@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:32960 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753546AbbFZOet (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 10:34:49 -0400
Received: by ieqy10 with SMTP id y10so77044207ieq.0
        for <netdev@vger.kernel.org>; Fri, 26 Jun 2015 07:34:49 -0700 (PDT)
In-Reply-To: <1435311439-26916-1-git-send-email-Yanjun.Zhu@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 26, 2015 at 5:37 AM, Zhu Yanjun <Yanjun.Zhu@windriver.com> wrote:
> The new net namespace can inherit from the original net config, or
> the current net config. As such, a config is needed to decide where
> the new namespace inherit from.

As per the netdev mailing list FAQ, and Dave's post from a day
or two ago, netdev is closed for patches during the merge
window.

And on top of that your commit doesn't tell us who needs this
and why, plus a compile time switch is a klunky and user
unfriendly way of configuring something that smells like it
might be needed to be changed regularly (if it needs to exist
even at all).  Finally, putting ifdefs around a curly brace like
you've done here is really bad form.

Paul.
--

>
> Signed-off-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>
> ---
>  init/Kconfig       |  9 +++++++++
>  net/ipv4/devinet.c | 13 +++++++++++++
>  2 files changed, 22 insertions(+)
>
> diff --git a/init/Kconfig b/init/Kconfig
> index dc24dec..fab8c41 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -1212,6 +1212,15 @@ config NET_NS
>           Allow user space to create what appear to be multiple instances
>           of the network stack.
>
> +config NET_NS_INHERIT_ORIGINAL
> +       bool "New network namespace inherits from original net config"
> +       depends on NET_NS
> +       default n
> +       help
> +         Allow new network namespace inherit from original net config.
> +         If no, the new network namespace inherits from the current net
> +         config including the modified net config.
> +
>  endif # NAMESPACES
>
>  config SCHED_AUTOGROUP
> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
> index 419d23c..cf635e4 100644
> --- a/net/ipv4/devinet.c
> +++ b/net/ipv4/devinet.c
> @@ -2271,6 +2271,7 @@ static __net_init int devinet_init_net(struct net *net)
>  #endif
>
>         err = -ENOMEM;
> +#ifndef CONFIG_NET_NS_INHERIT_ORIGINAL
>         all = &ipv4_devconf;
>         dflt = &ipv4_devconf_dflt;
>
> @@ -2282,6 +2283,15 @@ static __net_init int devinet_init_net(struct net *net)
>                 dflt = kmemdup(dflt, sizeof(ipv4_devconf_dflt), GFP_KERNEL);
>                 if (!dflt)
>                         goto err_alloc_dflt;
> +#else
> +       all = kmemdup(&ipv4_devconf, sizeof(ipv4_devconf), GFP_KERNEL);
> +       if (!all)
> +               goto err_alloc_all;
> +
> +       dflt = kmemdup(&ipv4_devconf_dflt, sizeof(ipv4_devconf_dflt), GFP_KERNEL);
> +       if (!dflt)
> +               goto err_alloc_dflt;
> +#endif
>
>  #ifdef CONFIG_SYSCTL
>                 tbl = kmemdup(tbl, sizeof(ctl_forward_entry), GFP_KERNEL);
> @@ -2292,7 +2302,10 @@ static __net_init int devinet_init_net(struct net *net)
>                 tbl[0].extra1 = all;
>                 tbl[0].extra2 = net;
>  #endif
> +
> +#ifndef CONFIG_NET_NS_INHERIT_ORIGINAL
>         }
> +#endif
>
>  #ifdef CONFIG_SYSCTL
>         err = __devinet_sysctl_register(net, "all", all);
> --
> 1.9.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
