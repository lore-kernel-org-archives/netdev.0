From: Patrick McHardy <kaber@trash.net>
Subject: Re: [net-next-2.6 PATCH v3 4/5] rtnetlink: Add VF config code to
 rtnetlink
Date: Wed, 10 Feb 2010 13:02:41 +0100
Message-ID: <4B72A061.40905@trash.net>
References: <20100210114303.14483.71368.stgit@localhost.localdomain> <20100210114403.14483.11004.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	Mitch Williams <mitch.a.williams@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48907 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755208Ab0BJMCv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 07:02:51 -0500
In-Reply-To: <20100210114403.14483.11004.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote:
> @@ -665,6 +677,17 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
>  	stats = dev_get_stats(dev);
>  	copy_rtnl_link_stats(nla_data(attr), stats);
>  
> +	if (dev->netdev_ops->ndo_get_vf_config && dev->dev.parent) {
> +		int i;
> +		struct ifla_vf_info ivi;
> +
> +		NLA_PUT_U32(skb, IFLA_NUM_VF, dev_num_vf(dev->dev.parent));
> +		for (i = 0; i < dev_num_vf(dev->dev.parent); i++) {
> +			if (dev->netdev_ops->ndo_get_vf_config(dev, i, &ivi))
> +				break;
> +			NLA_PUT(skb, IFLA_VFINFO, sizeof(ivi), &ivi);

We usually encapsulate lists of the same attribute type in another
top-level attribute. Check out the IFLA_VLAN_*_QOS attributes for
an example.

The interface should also be symetrical, IOW you should dump the
same attributes used in the userspace->kernel direction instead
of a combined "info" attribute.

> +		}
> +	}

> @@ -898,6 +927,44 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
>  		write_unlock_bh(&dev_base_lock);
>  	}
>  
> +	if (tb[IFLA_VF_MAC]) {
> +		struct ifla_vf_mac *ivm;
> +		ivm = nla_data(tb[IFLA_VF_MAC]);
> +		write_lock_bh(&dev_base_lock);

It dev_base_lock really correct here? This is running under the RTNL, so
changes to the device list can't happen.

> +		if (ops->ndo_set_vf_mac)
> +			err = ops->ndo_set_vf_mac(dev, ivm->vf, ivm->mac);

Shouldn't this indicate an error if the attributes aren't supported?

> +		write_unlock_bh(&dev_base_lock);
> +		if (err < 0)
> +			goto errout;
> +		modified = 1;
> +	}
> +
> +	if (tb[IFLA_VF_VLAN]) {
> +		struct ifla_vf_vlan *ivv;
> +		ivv = nla_data(tb[IFLA_VF_VLAN]);
> +		write_lock_bh(&dev_base_lock);
> +		if (ops->ndo_set_vf_vlan)
> +			err = ops->ndo_set_vf_vlan(dev, ivv->vf,
> +						   (u16)ivv->vlan,
> +						   (u8)ivv->qos);

The casts aren't necessary. But why does struct ifla_vf_vlan use u32
for the vlan in the first place?

> +		write_unlock_bh(&dev_base_lock);
> +		if (err < 0)
> +			goto errout;
> +		modified = 1;
> +	}
> +	err = 0;
> +
> +	if (tb[IFLA_VF_TX_RATE]) {
> +		struct ifla_vf_tx_rate *ivt;
> +		ivt = nla_data(tb[IFLA_VF_TX_RATE]);
> +		write_lock_bh(&dev_base_lock);
> +		if (ops->ndo_set_vf_tx_rate)
> +			err = ops->ndo_set_vf_tx_rate(dev, ivt->vf, ivt->rate);
> +		write_unlock_bh(&dev_base_lock);
> +		if (err < 0)
> +			goto errout;
> +		modified = 1;
> +	}
>  	err = 0;
>  
>  errout:
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

