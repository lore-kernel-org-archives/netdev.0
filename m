From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] [V3] net: add Xilinx emac lite device driver
Date: Thu, 20 Aug 2009 09:49:14 -0700
Message-ID: <20090820094914.46f1db9c@nehalam>
References: <20090820094956.02DFC45004F@mail96-dub.bigfish.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	davem@davemloft.net, jgarzik@pobox.com,
	John Linn <john.linn@xilinx.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	Josh Boyer <jwboyer@linux.vnet.ibm.com>,
	John Williams <john.williams@petalogix.com>,
	Michal Simek <michal.simek@petalogix.com>,
	Sadanand M <sadanan@xilinx.com>
To: John Linn <john.linn@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54125 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754494AbZHTQtS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Aug 2009 12:49:18 -0400
In-Reply-To: <20090820094956.02DFC45004F@mail96-dub.bigfish.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 20 Aug 2009 03:49:51 -0600
John Linn <john.linn@xilinx.com> wrote:

> +/**
> + * xemaclite_ioctl - Perform IO Control operations on the network device
> + * @dev:	Pointer to the network device
> + * @rq:		Pointer to the interface request structure
> + * @cmd:	IOCTL command
> + *
> + * The only IOCTL operation supported by this function is setting the MAC
> + * address. An error is reported if any other operations are requested.
> + *
> + * Return:	0 to indicate success, or a negative error for failure.
> + */
> +static int xemaclite_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
> +{
> +	struct net_local *lp = (struct net_local *) netdev_priv(dev);
> +	struct hw_addr_data *hw_addr = (struct hw_addr_data *) &rq->ifr_hwaddr;
> +
> +	switch (cmd) {
> +	case SIOCETHTOOL:
> +		return -EIO;
> +
> +	case SIOCSIFHWADDR:
> +		dev_err(&lp->ndev->dev, "SIOCSIFHWADDR\n");
> +
> +		/* Copy MAC address in from user space */
> +		copy_from_user((void __force *) dev->dev_addr,
> +			       (void __user __force *) hw_addr,
> +			       IFHWADDRLEN);
> +		xemaclite_set_mac_address(lp, dev->dev_addr);
> +		break;
> +	default:
> +		return -EOPNOTSUPP;
> +	}
> +
> +	return 0;
> +}

Do you really need this? I doubt the SIOCSIFHWADDR even reaches driver!

The normal call path for setting hardware address is:
  dev_ifsioc
         dev_set_mac_address
             ops->ndo_set_mac_address --> 

The driver should be:
   1. defining new code to do ndo_set_mac_address
   2. remove existing xmaclite_ioctl - all ioctl's handled by upper layers

FYI - the only ioctl's that make it to network device ndo_ioctl
 are listed in dev_ifsioc
   SIOCDEVPRIVATE ... SIOCDEVPRIVATE + 15
   SIOCBOND*
   SIOCMII*
   SIOCBR*
   SIOCHWTSTAMP
   SIOCWANDEV


