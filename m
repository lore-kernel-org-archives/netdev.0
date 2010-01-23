From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] C/R: Basic support for network namespaces and
 devices (v2)
Date: Sat, 23 Jan 2010 01:25:37 -0800 (PST)
Message-ID: <20100123.012537.99190542.davem@davemloft.net>
References: <1264194592-7529-1-git-send-email-danms@us.ibm.com>
	<1264194592-7529-4-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, netdev@vger.kernel.org,
	orenl@librato.com
To: danms@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46595
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752731Ab0AWJZZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 04:25:25 -0500
In-Reply-To: <1264194592-7529-4-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Smith <danms@us.ibm.com>
Date: Fri, 22 Jan 2010 13:09:52 -0800

> +	if (strcmp(dev->name, "sit0") == 0) {
> +		return 0;                                    /* Skip sit0 */
> +	} else if (dev->ethtool_ops && dev->ethtool_ops->get_drvinfo) {
> +		dev->ethtool_ops->get_drvinfo(dev, &drvinfo);
> +		if (strcmp(drvinfo.driver, "veth") == 0)
> +			return 1;                            /* vethX is okay */
> +	} else if (strcmp(dev->name, "lo") == 0)
> +		return 1;                                    /* lo is okay */
 ...
> +	if (strcmp(dev->name, "lo") == 0)
> +		h->type = CKPT_NETDEV_LO;
> +	else if (strncmp(dev->name, "veth", 4) == 0) {
> +		h->type = CKPT_NETDEV_VETH;
> +		peer = veth_get_peer(dev);
> +	} else {

This is gross.  You can't do things this way.

First of all, devices can get whatever name the user wants
to assign to them.  If they want to rename the loopback
device to something other than "lo" they can.

You need another way.  Is it such a stretch of ingenuity to
simply add an attribute flag to struct netdev that you can test
here and perhaps a callback for what you need?

Your direct calls into these drivers, like the veth bits, will not
work if the driver is built modular.  It's one of several reasons
why doing things this way isn't going to work.

This misdesign is also why you find a need to get at the RTNL link ops
too.  You have no infrastructure for doing what you need to do
generically, so instead you are forced to directly call into drivers
and export RTNL internals needlessly.

This needs a lot of work, sorry.
