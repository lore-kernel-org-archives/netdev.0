From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH RFC 02/10] dpaa_eth: add support for DPAA Ethernet
Date: Wed, 01 Apr 2015 10:11:29 -0700
Message-ID: <1427908289.31790.50.camel@perches.com>
References: <1427905196-27778-1-git-send-email-madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-kernel@vger.kernel.org
To: madalin.bucur@freescale.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427905196-27778-1-git-send-email-madalin.bucur@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-04-01 at 19:19 +0300, Madalin Bucur wrote:
> This introduces the Freescale Data Path Acceleration Architecture
> (DPAA) Ethernet driver (dpaa_eth) that builds upon the DPAA QMan,
> BMan, PAMU and FMan drivers to deliver Ethernet connectivity on
> the Freescale DPAA QorIQ platforms.

trivial notes:

> diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
[]
> @@ -0,0 +1,835 @@
> +/* Copyright 2008 - 2015 Freescale Semiconductor Inc.
> + *
> + * Redistribution and use in source and binary forms, with or without
> + * modification, are permitted provided that the following conditions are met:
> + *     * Redistributions of source code must retain the above copyright
> + *	 notice, this list of conditions and the following disclaimer.
> + *     * Redistributions in binary form must reproduce the above copyright
> + *	 notice, this list of conditions and the following disclaimer in the
> + *	 documentation and/or other materials provided with the distribution.
> + *     * Neither the name of Freescale Semiconductor nor the
> + *	 names of its contributors may be used to endorse or promote products
> + *	 derived from this software without specific prior written permission.
> + *
> + * ALTERNATIVELY, this software may be distributed under the terms of the
> + * GNU General Public License ("GPL") as published by the Free Software
> + * Foundation, either version 2 of that License or (at your option) any
> + * later version.

Given this is GPLed here, does the first block need to exist?

> +#define pr_fmt(fmt) \
> +	KBUILD_MODNAME ": " fmt

single line please

> +#include <linux/if_arp.h>	/* arp_hdr_len() */
> +#include <linux/if_vlan.h>	/* VLAN_HLEN */
> +#include <linux/icmp.h>		/* struct icmphdr */
> +#include <linux/ip.h>		/* struct iphdr */
> +#include <linux/ipv6.h>		/* struct ipv6hdr */
> +#include <linux/udp.h>		/* struct udphdr */
> +#include <linux/tcp.h>		/* struct tcphdr */
> +#include <linux/net.h>		/* net_ratelimit() */
> +#include <linux/if_ether.h>	/* ETH_P_IP and ETH_P_IPV6 */

These comments are pretty unusual and likely incomplete
so they're probably not useful.

> +static u8 debug = -1;
> +module_param(debug, byte, S_IRUGO);
> +MODULE_PARM_DESC(debug, "Module/Driver verbosity level");

default on?  Likely default off would be better.

> +static void _dpa_rx_error(struct net_device *net_dev,
> +			  const struct dpa_priv_s	*priv,
> +			  struct dpa_percpu_priv_s *percpu_priv,
> +			  const struct qm_fd *fd,
> +			  u32 fqid)
> +{
> +	/* limit common, possibly innocuous Rx FIFO Overflow errors'
> +	 * interference with zero-loss convergence benchmark results.
> +	 */
> +	if (likely(fd->status & FM_FD_STAT_ERR_PHYSICAL))
> +		pr_warn_once("non-zero error counters in fman statistics (sysfs)\n");
> +	else
> +		if (netif_msg_hw(priv) && net_ratelimit())
> +			netdev_err(net_dev, "Err FD status = 0x%08x\n",
> +				   fd->status & FM_FD_STAT_RX_ERRORS);

	if (netif_msg_<foo>(priv))
		netdev_<level>(netdev, ...)

uses can be written like:

	netif_<level>(priv, <foo>, netdev, ...);

So this is perhaps better as

	if (likely(fd->status & FM_FD_STAT_ERR_PHYSICAL))
		pr_warn_once("non-zero error counters in fman statistics (sysfs)\n");
	else if (net_ratelimit())
		netif_err(priv, hw, net_dev, "Err FD status = 0x%08x\n",
			  fd->status & FM_FD_STAT_RX_ERRORS);

> +
> +	percpu_priv->stats.rx_errors++;
> +
> +	dpa_fd_release(net_dev, fd);,
> +}
> +
> +static void _dpa_tx_error(struct net_device		*net_dev,
> +			  const struct dpa_priv_s	*priv,
> +			  struct dpa_percpu_priv_s	*percpu_priv,
> +			  const struct qm_fd		*fd,
> +			  u32				 fqid)
> +{
> +	struct sk_buff *skb;
> +
> +	if (netif_msg_hw(priv) && net_ratelimit())
> +		netdev_warn(net_dev, "FD status = 0x%08x\n",
> +			    fd->status & FM_FD_STAT_TX_ERRORS);

	netif_warn(priv, hw, net_dev, etc...);


> +static int __cold dpa_eth_priv_stop(struct net_device *net_dev)

Use of __cold is pretty unusual in drivers

> +static struct dpa_bp * __cold
> +dpa_priv_bp_probe(struct device *dev)
> +{
> +	struct dpa_bp *dpa_bp;
> +
> +	dpa_bp = devm_kzalloc(dev, sizeof(*dpa_bp), GFP_KERNEL);
> +	if (unlikely(!dpa_bp)) {
> +		dev_err(dev, "devm_kzalloc() failed\n");

No need for this alloc failure message

> +static int dpa_priv_bp_create(struct net_device *net_dev, struct dpa_bp *dpa_bp,
> +			      size_t count)
> +{
> +	struct dpa_priv_s *priv = netdev_priv(net_dev);
> +	int i;
> +
> +	if (netif_msg_probe(priv))
> +		dev_dbg(net_dev->dev.parent,
> +			"Using private BM buffer pools\n");

Why emit using dev.parent?

> diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.h b/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.h

> +int __cold dpa_start(struct net_device *net_dev);
> +int __cold dpa_stop(struct net_device *net_dev);
> +void __cold dpa_timeout(struct net_device *net_dev);

Marking a function prototype with an attribute means
the implementation doesn't need the same attribute.

> +/* Convenience macros for storing/retrieving the skb back-pointers.
> + *
> + * NB: @off is an offset from a (struct sk_buff **) pointer!
> + */
> +#define DPA_WRITE_SKB_PTR(skb, skbh, addr, off) \
> +	{ \
> +		skbh = (struct sk_buff **)addr; \
> +		*(skbh + (off)) = skb; \
> +	}
> +#define DPA_READ_SKB_PTR(skb, skbh, addr, off) \
> +	{ \
> +		skbh = (struct sk_buff **)addr; \
> +		skb = *(skbh + (off)); \
> +	}

Maybe these are better as static inlines?
