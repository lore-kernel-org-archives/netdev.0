From: Amine Kherbouche <amine.kherbouche@6wind.com>
Subject: Re: [PATCH 4/6] mpls: VPLS support
Date: Mon, 21 Aug 2017 17:14:46 +0200
Message-ID: <4cf89536-2d14-e2aa-cad9-bd13976d6fb3@6wind.com>
References: <20170816170202.456851-1-equinox@diac24.net>
 <20170816170202.456851-5-equinox@diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com
To: David Lamparter <equinox@diac24.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f178.google.com ([209.85.128.178]:34310 "EHLO
        mail-wr0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753126AbdHUPO4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 11:14:56 -0400
Received: by mail-wr0-f178.google.com with SMTP id p14so33263674wrg.1
        for <netdev@vger.kernel.org>; Mon, 21 Aug 2017 08:14:55 -0700 (PDT)
In-Reply-To: <20170816170202.456851-5-equinox@diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> new file mode 100644
> index 000000000000..28ac810da6e9
> --- /dev/null
> +++ b/net/mpls/vpls.c
> @@ -0,0 +1,469 @@
> +/*
> + *  net/mpls/vpls.c
> + *
> + *  Copyright (C) 2016 David Lamparter
> + *
> + */
> +
> +#include <linux/netdevice.h>
> +#include <linux/slab.h>
> +#include <linux/ethtool.h>
> +#include <linux/etherdevice.h>
> +#include <linux/u64_stats_sync.h>
> +#include <linux/mpls.h>
> +
> +#include <net/rtnetlink.h>
> +#include <net/dst.h>
> +#include <net/xfrm.h>
> +#include <net/mpls.h>
> +#include <linux/module.h>
> +#include <net/dst_metadata.h>
> +#include <net/ip_tunnels.h>

some headers are not needed.


> +
> +static netdev_tx_t vpls_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	int err = -EINVAL, ok_count = 0;
> +	struct vpls_priv *priv = netdev_priv(dev);
> +	struct vpls_info *vi;
> +	struct pcpu_sw_netstats *stats;
> +	size_t len = skb->len;
> +
> +	rcu_read_lock();
> +	vi = skb_vpls_info(skb);
> +
> +	skb_orphan(skb);
> +	skb_forward_csum(skb);
> +
> +	if (vi) {
> +		err = vpls_xmit_wire(skb, dev, priv, vi->pw_label);
> +		if (err)
> +			goto out_err;
> +	} else {

the rcu_read_lock() is just needed for the else statement right ?

> +		struct sk_buff *cloned;
> +		struct vpls_wirelist *wl;
> +		size_t i;
> +
> +		wl = rcu_dereference(priv->wires);
> +		if (wl->count == 0) {
> +			dev->stats.tx_carrier_errors++;
> +			goto out_err;
> +		}
> +
> +		for (i = 0; i < wl->count; i++) {
> +			cloned = skb_clone(skb, GFP_KERNEL);
> +			if (vpls_xmit_wire(cloned, dev, priv, wl->wires[i]))
> +				consume_skb(cloned);
> +			else
> +				ok_count++;
> +		}
> +		if (!ok_count)
> +			goto out_err;
> +
> +		consume_skb(skb);
> +	}
> +
> +	stats = this_cpu_ptr(dev->tstats);
> +	u64_stats_update_begin(&stats->syncp);
> +	stats->tx_packets++;
> +	stats->tx_bytes += len;
> +	u64_stats_update_end(&stats->syncp);
> +
> +	rcu_read_unlock();
> +	return 0;
> +}


> +int vpls_rcv(struct sk_buff *skb, struct net_device *in_dev,
> +	     struct packet_type *pt, struct mpls_route *rt,
> +	     struct mpls_shim_hdr *hdr, struct net_device *orig_dev)
> +{
> +	struct net_device *dev = rt->rt_vpls_dev;
> +	struct mpls_entry_decoded dec;
> +	struct metadata_dst *md_dst;
> +	struct pcpu_sw_netstats *stats;
> +
> +	if (!dev)
> +		goto drop_nodev;
> +

we can get dec.bos from mpls stack as a function param, no need to 
decode the mpls header again.

> +	dec = mpls_entry_decode(hdr);
> +	if (!dec.bos) {
> +		dev->stats.rx_frame_errors++;
> +		goto drop;
> +	}
> +
> +	skb_pull(skb, sizeof(*hdr));
> +
> +	if (unlikely(!pskb_may_pull(skb, ETH_HLEN))) {
> +		dev->stats.rx_length_errors++;
> +		goto drop;
> +	}



> +static const struct net_device_ops vpls_netdev_ops = {
> +	.ndo_init		= vpls_dev_init,
> +	.ndo_open		= vpls_open,
> +	.ndo_stop		= vpls_close,
> +	.ndo_start_xmit		= vpls_xmit,
> +	.ndo_change_mtu		= vpls_change_mtu,
> +	.ndo_get_stats64	= ip_tunnel_get_stats64,
> +	.ndo_set_rx_mode	= vpls_set_multicast_list,
> +	.ndo_set_mac_address	= eth_mac_addr,
> +	.ndo_features_check	= passthru_features_check,
> +};

can you add .ndo_get_stats64 function ?


>
