From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: net 01/06: Add STP demux layer
Date: Thu, 3 Jul 2008 10:40:08 -0700
Message-ID: <20080703104008.0bb74b6e@extreme>
References: <20080703170441.6650.64717.sendpatchset@localhost.localdomain>
	<20080703170442.6650.31951.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	davem@davemloft.net
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:43633 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752597AbYGCRkQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jul 2008 13:40:16 -0400
In-Reply-To: <20080703170442.6650.31951.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  3 Jul 2008 19:04:42 +0200 (MEST)
Patrick McHardy <kaber@trash.net> wrote:

> net: Add STP demux layer
> 
> Add small STP demux layer for demuxing STP PDUs based on MAC address.
> This is needed to run both GARP and STP in parallel (or even load the
> modules) since both use LLC_SAP_BSPAN.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> ---
> commit 6c0be0e52a154f1991c221a6f60c6b9be71a10c8
> tree 6dcdf3d929edeae8463c6957e688f1e91ca6cfe5
> parent 44d28ab19c64d095314ac66f765d0c747519f4ed
> author Patrick McHardy <kaber@trash.net> Thu, 03 Jul 2008 18:05:56 +0200
> committer Patrick McHardy <kaber@trash.net> Thu, 03 Jul 2008 18:05:56 +0200
> 
>  include/net/stp.h |   14 +++++++
>  net/802/Kconfig   |    3 ++
>  net/802/Makefile  |    1 +
>  net/802/stp.c     |  102 +++++++++++++++++++++++++++++++++++++++++++++++++++++
>  net/Kconfig       |    1 +
>  5 files changed, 121 insertions(+), 0 deletions(-)
> 
> diff --git a/include/net/stp.h b/include/net/stp.h
> new file mode 100644
> index 0000000..ad447f1
> --- /dev/null
> +++ b/include/net/stp.h
> @@ -0,0 +1,14 @@
> +#ifndef _NET_STP_H
> +#define _NET_STP_H
> +
> +struct stp_proto {
> +	unsigned char	group_address[ETH_ALEN];
> +	void		(*rcv)(const struct stp_proto *, struct sk_buff *,
> +			       struct net_device *);
> +	void		*data;
> +};
> +
> +extern int stp_proto_register(const struct stp_proto *proto);
> +extern void stp_proto_unregister(const struct stp_proto *proto);
> +
> +#endif /* _NET_STP_H */
> diff --git a/net/802/Kconfig b/net/802/Kconfig
> new file mode 100644
> index 0000000..01cb094
> --- /dev/null
> +++ b/net/802/Kconfig
> @@ -0,0 +1,3 @@
> +config STP
> +	tristate
> +	select LLC
> diff --git a/net/802/Makefile b/net/802/Makefile
> index 68569ff..c441d89 100644
> --- a/net/802/Makefile
> +++ b/net/802/Makefile
> @@ -10,3 +10,4 @@ obj-$(CONFIG_FDDI)	+=                 fddi.o
>  obj-$(CONFIG_HIPPI)	+=                 hippi.o
>  obj-$(CONFIG_IPX)	+= p8022.o psnap.o p8023.o
>  obj-$(CONFIG_ATALK)	+= p8022.o psnap.o
> +obj-$(CONFIG_STP)	+= stp.o
> diff --git a/net/802/stp.c b/net/802/stp.c
> new file mode 100644
> index 0000000..0b7a244
> --- /dev/null
> +++ b/net/802/stp.c
> @@ -0,0 +1,102 @@
> +/*
> + *	STP SAP demux
> + *
> + *	Copyright (c) 2008 Patrick McHardy <kaber@trash.net>
> + *
> + *	This program is free software; you can redistribute it and/or
> + *	modify it under the terms of the GNU General Public License
> + *	version 2 as published by the Free Software Foundation.
> + */
> +#include <linux/mutex.h>
> +#include <linux/skbuff.h>
> +#include <linux/etherdevice.h>
> +#include <linux/llc.h>
> +#include <net/llc.h>
> +#include <net/llc_pdu.h>
> +#include <net/stp.h>
> +
> +/* 01:80:c2:00:00:20 - 01:80:c2:00:00:2F */
> +#define GARP_ADDR_MIN	0x20
> +#define GARP_ADDR_MAX	0x2F
> +#define GARP_ADDR_RANGE	(GARP_ADDR_MAX - GARP_ADDR_MIN)
> +
> +static const struct stp_proto *garp_protos[GARP_ADDR_RANGE + 1] __read_mostly;
> +static const struct stp_proto *stp_proto __read_mostly;
> +
> +static struct llc_sap *sap __read_mostly;
> +static unsigned int sap_registered;
> +static DEFINE_MUTEX(stp_proto_mutex);
> +
> +/* Called under rcu_read_lock from LLC */
> +static int stp_pdu_rcv(struct sk_buff *skb, struct net_device *dev,
> +		       struct packet_type *pt, struct net_device *orig_dev)
> +{
> +	const struct ethhdr *eh = eth_hdr(skb);
> +	const struct llc_pdu_un *pdu = llc_pdu_un_hdr(skb);
> +	const struct stp_proto *proto;
> +
> +	if (pdu->ssap != LLC_SAP_BSPAN ||
> +	    pdu->dsap != LLC_SAP_BSPAN ||
> +	    pdu->ctrl_1 != LLC_PDU_TYPE_U)
> +		goto err;
> +
> +	if (eh->h_dest[5] >= GARP_ADDR_MIN && eh->h_dest[5] <= GARP_ADDR_MAX) {
> +		proto = rcu_dereference(garp_protos[eh->h_dest[5] -
> +						    GARP_ADDR_MIN]);
> +		if (proto &&
> +		    compare_ether_addr(eh->h_dest, proto->group_address))
> +			goto err;
> +	} else
> +		proto = rcu_dereference(stp_proto);
> +
> +	if (!proto)
> +		goto err;
> +
> +	proto->rcv(proto, skb, dev);
> +	return 0;
> +
> +err:
> +	kfree_skb(skb);
> +	return 0;
> +}
> +
> +int stp_proto_register(const struct stp_proto *proto)
> +{
> +	int err = 0;
> +
> +	mutex_lock(&stp_proto_mutex);
> +	if (sap_registered++ == 0) {
> +		sap = llc_sap_open(LLC_SAP_BSPAN, stp_pdu_rcv);
> +		if (!sap) {
> +			err = -ENOMEM;
> +			goto out;
> +		}
> +	}
> +	if (is_zero_ether_addr(proto->group_address))
> +		rcu_assign_pointer(stp_proto, proto);
> +	else
> +		rcu_assign_pointer(garp_protos[proto->group_address[5] -
> +					       GARP_ADDR_MIN], proto);
> +out:
> +	mutex_unlock(&stp_proto_mutex);
> +	return err;
> +}
> +EXPORT_SYMBOL_GPL(stp_proto_register);
> +
> +void stp_proto_unregister(const struct stp_proto *proto)
> +{
> +	mutex_lock(&stp_proto_mutex);
> +	if (is_zero_ether_addr(proto->group_address))
> +		rcu_assign_pointer(stp_proto, NULL);
> +	else
> +		rcu_assign_pointer(garp_protos[proto->group_address[5] -
> +					       GARP_ADDR_MIN], NULL);
> +	synchronize_rcu();
> +
> +	if (--sap_registered == 0)
> +		llc_sap_put(sap);
> +	mutex_unlock(&stp_proto_mutex);
> +}
> +EXPORT_SYMBOL_GPL(stp_proto_unregister);
> +
> +MODULE_LICENSE("GPL");
> diff --git a/net/Kconfig b/net/Kconfig
> index acbf7c6..b986687 100644
> --- a/net/Kconfig
> +++ b/net/Kconfig
> @@ -181,6 +181,7 @@ source "net/dccp/Kconfig"
>  source "net/sctp/Kconfig"
>  source "net/tipc/Kconfig"
>  source "net/atm/Kconfig"
> +source "net/802/Kconfig"
>  source "net/bridge/Kconfig"
>  source "net/8021q/Kconfig"
>  source "net/decnet/Kconfig"

Why not just have LLC handle multiple registrations for same SAP?
