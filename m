From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: use either ndo VLAN ops or switchdev
 VLAN ops to install MASTER vlans
Date: Thu, 11 Jun 2015 17:20:05 -0700 (PDT)
Message-ID: <20150611.172005.1576107106427695069.davem@davemloft.net>
References: <1434050122-26405-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	makita.toshiaki@lab.ntt.co.jp, roopa@cumulusnetworks.com,
	jhs@mojatatu.com, simon.horman@netronome.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37581 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751532AbbFLAUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 20:20:09 -0400
In-Reply-To: <1434050122-26405-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Thu, 11 Jun 2015 12:15:22 -0700

> +static int __vlan_vid_add(struct net_device *dev, struct net_bridge *br,
> +			  u16 vid, u16 flags)
> +{
> +	const struct net_device_ops *ops = dev->netdev_ops;
> +	struct switchdev_obj vlan_obj = {
> +		.id = SWITCHDEV_OBJ_PORT_VLAN,
> +		.u.vlan = {
> +			.flags = flags,
> +			.vid_start = vid,
> +			.vid_end = vid,
> +		},
> +	};
> +	int err;
> +
> +	/* If driver uses VLAN ndo ops, use 8021q to install vid
> +	 * on device, otherwise try switchdev ops to install vid.
> +	 */
> +
> +	if (ops->ndo_vlan_rx_add_vid) {
> +		err = vlan_vid_add(dev, br->vlan_proto, vid);
> +	} else {
> +		err = switchdev_port_obj_add(dev, &vlan_obj);
> +		if (err == -EOPNOTSUPP)
> +			err = 0;
> +	}

I know this looks like nit-picking, but would you please instantiate
the on-stack vlan_obj in the deepest basic block it is used inside
of?  Which here is the else branch.

> +static void __vlan_vid_del(struct net_device *dev, struct net_bridge *br,
> +			   u16 vid)
> +{
> +	const struct net_device_ops *ops = dev->netdev_ops;
> +	struct switchdev_obj vlan_obj = {
> +		.id = SWITCHDEV_OBJ_PORT_VLAN,
> +		.u.vlan = {
> +			.vid_start = vid,
> +			.vid_end = vid,
> +		},
> +	};
> +
> +	/* If driver uses VLAN ndo ops, use 8021q to delete vid
> +	 * on device, otherwise try switchdev ops to delete vid.
> +	 */
> +
> +	if (ops->ndo_vlan_rx_kill_vid)
> +		vlan_vid_del(dev, br->vlan_proto, vid);
> +	else
> +		switchdev_port_obj_del(dev, &vlan_obj);

Likewise.

Thanks.
