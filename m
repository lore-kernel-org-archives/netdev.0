From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 01/26] switchdev: introduce get/set attrs
 ops
Date: Wed, 01 Apr 2015 14:08:22 -0400 (EDT)
Message-ID: <20150401.140822.2230858157895026713.davem@davemloft.net>
References: <1427882882-2533-1-git-send-email-sfeldma@gmail.com>
	<1427882882-2533-2-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59438 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753239AbbDASI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 14:08:27 -0400
In-Reply-To: <1427882882-2533-2-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Wed,  1 Apr 2015 03:07:37 -0700

> +int swdev_port_attr_set(struct net_device *dev, struct swdev_attr *attr)
> +{
> +	struct swdev_attr prev = *attr;
> +	int err, get_err, revert_err;
> +
> +	get_err = swdev_port_attr_get(dev, &prev);
> +
> +	err = __swdev_port_attr_set(dev, attr);
> +	if (err && !get_err && !(attr->flags & SWDEV_F_NO_RECOVER)) {
> +		/* Some err on set: revert to previous value */
> +		revert_err = __swdev_port_attr_set(dev, &prev);
> +		if (revert_err)
> +			netdev_err(dev, "Reverting swdev port attr %d failed\n",
> +				   attr->id);
> +	}
> +
> +	return err;

This style of error recovery doesn't work.

You have to have a prepare/commit model to do this sanely, because
otherwise:

1) Partial state updates can be seen by the data plane (and other
   code paths) that do not use RTNL mutex protection.

2) It is absoultely expected that if some resource allocation failed
   when switching to the new attribute value, the same exactly thing
   is extremely likely during the rollback.

So you have to code this in a way that no partial state updates are
ever visible, and also that rollbacks don't fail.

I also agree with Jamal that you should use the netlink attribute
values for these attributes rather than inventing yet another
namespace of ID numbers.
