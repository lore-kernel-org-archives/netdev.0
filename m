From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCHv2] netfilter: add CHECKSUM target
Date: Thu, 15 Jul 2010 11:36:35 +0200
Message-ID: <4C3ED6A3.6000905@trash.net>
References: <20100711150623.GA7420@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jan Engelhardt <jengelh@medozas.de>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	herbert@gondor.hengli.com.au
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100711150623.GA7420@redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 11.07.2010 17:06, schrieb Michael S. Tsirkin:
> +#ifndef _IPT_CHECKSUM_TARGET_H
> +#define _IPT_CHECKSUM_TARGET_H
> +
> +#define XT_CHECKSUM_OP_FILL	0x01	/* fill in checksum in IP header */
> +
> +struct xt_CHECKSUM_info {
> +	u_int8_t operation;	/* bitset of operations */

Please use __u8 in public header files.

> +};
> +
> +#endif /* _IPT_CHECKSUM_TARGET_H */
> diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
> index 8593a77..1cf4852 100644
> --- a/net/netfilter/Kconfig
> +++ b/net/netfilter/Kconfig
> @@ -294,7 +294,7 @@ endif # NF_CONNTRACK
>  config NETFILTER_TPROXY
>  	tristate "Transparent proxying support (EXPERIMENTAL)"
>  	depends on EXPERIMENTAL
> -	depends on IP_NF_MANGLE
> +	depends on IP_NF_MANGLE || IP6_NF_MANGLE

This does not seem to belong into this patch.

>  	depends on NETFILTER_ADVANCED
>  	help
>  	  This option enables transparent proxying support, that is,
> @@ -347,6 +347,21 @@ config NETFILTER_XT_CONNMARK
>  
>  comment "Xtables targets"
>  
> +config NETFILTER_XT_TARGET_CHECKSUM
> +	tristate "CHECKSUM target support"
> +	depends on NETFILTER_ADVANCED
> +	---help---
> +	  This option adds a `CHECKSUM' target, which can be used in the iptables mangle
> +	  table.  

You should add a dependency on the mangle table then.

> +
> +	  You can use this target to compute and fill in the checksum in
> +	  a packet that lacks a checksum.  This is particularly useful,
> +	  if you need to work around old applications such as dhcp clients,
> +	  that do not work well with checksum offloads, but don't want to disable
> +	  checksum offload in your device.
> +
> +	  To compile it as a module, choose M here.  If unsure, say N.
> +
>  config NETFILTER_XT_TARGET_CLASSIFY
>  	tristate '"CLASSIFY" target support'
>  	depends on NETFILTER_ADVANCED
> diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
> index 14e3a8f..8eb541d 100644
> --- a/net/netfilter/Makefile
> +++ b/net/netfilter/Makefile
> @@ -45,6 +45,7 @@ obj-$(CONFIG_NETFILTER_XT_MARK) += xt_mark.o
>  obj-$(CONFIG_NETFILTER_XT_CONNMARK) += xt_connmark.o
>  
>  # targets
> +obj-$(CONFIG_NETFILTER_XT_TARGET_CHECKSUM) += xt_CHECKSUM.o
>  obj-$(CONFIG_NETFILTER_XT_TARGET_CLASSIFY) += xt_CLASSIFY.o
>  obj-$(CONFIG_NETFILTER_XT_TARGET_CONNSECMARK) += xt_CONNSECMARK.o
>  obj-$(CONFIG_NETFILTER_XT_TARGET_CT) += xt_CT.o
> diff --git a/net/netfilter/xt_CHECKSUM.c b/net/netfilter/xt_CHECKSUM.c
> new file mode 100644
> index 0000000..0fee1a7
> --- /dev/null
> +++ b/net/netfilter/xt_CHECKSUM.c
> @@ -0,0 +1,72 @@
> +/* iptables module for the packet checksum mangling
> + *
> + * (C) 2002 by Harald Welte <laforge@netfilter.org>
> + * (C) 2010 Red Hat, Inc.
> + *
> + * Author: Michael S. Tsirkin <mst@redhat.com>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2 as
> + * published by the Free Software Foundation.
> +*/
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> +#include <linux/in.h>

Do you really need in.h?

> +#include <linux/module.h>
> +#include <linux/skbuff.h>
> +#include <linux/netdevice.h>
> +
> +#include <linux/netfilter/x_tables.h>
> +#include <linux/netfilter/xt_CHECKSUM.h>
> +
> +MODULE_LICENSE("GPL");
> +MODULE_AUTHOR("Michael S. Tsirkin <mst@redhat.com>");
> +MODULE_DESCRIPTION("Xtables: checksum modification");
> +MODULE_ALIAS("ipt_CHECKSUM");
> +MODULE_ALIAS("ip6t_CHECKSUM");
> +
> +static unsigned int
> +checksum_tg(struct sk_buff *skb, const struct xt_action_param *par)
> +{
> +	if (skb->ip_summed == CHECKSUM_PARTIAL)
> +		skb_checksum_help(skb);
> +
> +	return XT_CONTINUE;
> +}
> +
> +static int checksum_tg_check(const struct xt_tgchk_param *par)
> +{
> +	const struct xt_CHECKSUM_info *einfo = par->targinfo;
> +
> +	if (einfo->operation & ~XT_CHECKSUM_OP_FILL) {
> +		pr_info("unsupported CHECKSUM operation %x\n", einfo->operation);
> +		return -EINVAL;
> +	}
> +	if (!einfo->operation) {
> +		pr_info("no CHECKSUM operation enabled\n");
> +		return -EINVAL;
> +	}
> +	return 0;
> +}
> +
> +static struct xt_target checksum_tg_reg __read_mostly = {
> +	.name		= "CHECKSUM",
> +	.family		= NFPROTO_UNSPEC,
> +	.target		= checksum_tg,
> +	.targetsize	= sizeof(struct xt_CHECKSUM_info),
> +	.table		= "mangle",
> +	.checkentry	= checksum_tg_check,
> +	.me		= THIS_MODULE,
> +};
> +
> +static int __init checksum_tg_init(void)
> +{
> +	return xt_register_target(&checksum_tg_reg);
> +}
> +
> +static void __exit checksum_tg_exit(void)
> +{
> +	xt_unregister_target(&checksum_tg_reg);
> +}
> +
> +module_init(checksum_tg_init);
> +module_exit(checksum_tg_exit);

