From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH 4/6] mpls: VPLS support
Date: Mon, 21 Aug 2017 18:18:27 +0200
Message-ID: <20170821161827.GX773745@eidolon>
References: <20170816170202.456851-1-equinox@diac24.net>
 <20170816170202.456851-5-equinox@diac24.net>
 <4cf89536-2d14-e2aa-cad9-bd13976d6fb3@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Lamparter <equinox@diac24.net>, netdev@vger.kernel.org,
        roopa@cumulusnetworks.com
To: Amine Kherbouche <amine.kherbouche@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eidolon.nox.tf ([185.142.180.128]:36816 "EHLO eidolon.nox.tf"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753264AbdHUQS3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 12:18:29 -0400
Content-Disposition: inline
In-Reply-To: <4cf89536-2d14-e2aa-cad9-bd13976d6fb3@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 21, 2017 at 05:14:46PM +0200, Amine Kherbouche wrote:
> > +#include <net/ip_tunnels.h>
> 
> some headers are not needed.

Which ones?  net/ip_tunnels.h is needed for ip_tunnel_get_stats64().

> > +static netdev_tx_t vpls_xmit(struct sk_buff *skb, struct net_device *dev)
> > +{
> > +	int err = -EINVAL, ok_count = 0;
> > +	struct vpls_priv *priv = netdev_priv(dev);
> > +	struct vpls_info *vi;
> > +	struct pcpu_sw_netstats *stats;
> > +	size_t len = skb->len;
> > +
> > +	rcu_read_lock();
> > +	vi = skb_vpls_info(skb);
> > +
> > +	skb_orphan(skb);
> > +	skb_forward_csum(skb);
> > +
> > +	if (vi) {
> > +		err = vpls_xmit_wire(skb, dev, priv, vi->pw_label);
> > +		if (err)
> > +			goto out_err;
> > +	} else {
> 
> the rcu_read_lock() is just needed for the else statement right ?

Yeah, it's leftover from an earlier version where it was used for what
is now skb_vpls_info().  Fixed in next version.

> > +int vpls_rcv(struct sk_buff *skb, struct net_device *in_dev,
> > +	     struct packet_type *pt, struct mpls_route *rt,
> > +	     struct mpls_shim_hdr *hdr, struct net_device *orig_dev)
> > +{
> > +	struct net_device *dev = rt->rt_vpls_dev;
> > +	struct mpls_entry_decoded dec;
[...]
> > +	dec = mpls_entry_decode(hdr);
> 
> we can get dec.bos from mpls stack as a function param, no need to 
> decode the mpls header again.

I didn't do that for 2 reasons:
- mpls_entry_decode is a very small inlined function
- for future OAM GAL label support, it will need to decode a 2nd label

> > +static const struct net_device_ops vpls_netdev_ops = {
> > +	.ndo_init		= vpls_dev_init,
> > +	.ndo_open		= vpls_open,
> > +	.ndo_stop		= vpls_close,
> > +	.ndo_start_xmit		= vpls_xmit,
> > +	.ndo_change_mtu		= vpls_change_mtu,
> > +	.ndo_get_stats64	= ip_tunnel_get_stats64,
> > +	.ndo_set_rx_mode	= vpls_set_multicast_list,
> > +	.ndo_set_mac_address	= eth_mac_addr,
> > +	.ndo_features_check	= passthru_features_check,
> > +};
> 
> can you add .ndo_get_stats64 function ?

It uses the same stats as ip tunnels:
+	.ndo_get_stats64	= ip_tunnel_get_stats64,

I don't think copypasting improves code quality here(???)

Cheers,


-David
