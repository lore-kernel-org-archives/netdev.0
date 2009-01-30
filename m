From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH v2 2/4] virtio_net: Add a set_rx_mode interface
Date: Fri, 30 Jan 2009 16:00:57 +1030
Message-ID: <200901301600.57298.rusty@rustcorp.com.au>
References: <20090129230502.2672.87669.stgit@debian.lart> <20090129230512.2672.13107.stgit@debian.lart>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: markmc@redhat.com, netdev@vger.kernel.org, kvm@vger.kernel.org
To: Alex Williamson <alex.williamson@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:46086 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750784AbZA3FbE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jan 2009 00:31:04 -0500
In-Reply-To: <20090129230512.2672.13107.stgit@debian.lart>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 30 January 2009 09:35:12 Alex Williamson wrote: 
> +static void virtnet_set_rx_mode(struct net_device *dev)
> +{
> +	struct virtnet_info *vi = netdev_priv(dev);
> +	u8 promisc, allmulti;
> +
> +	if (!virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_RX))
> +		return;

Hmm, this check duplicates the one in virtnet_send_command; after
all your patches, is it ever called with !VIRTIO_NET_F_CTRL_RX?  Maybe it should be a BUG_ON in there?

> +	promisc = ((dev->flags & IFF_PROMISC) != 0 || dev->uc_count > 0);
> +	allmulti = ((dev->flags & IFF_ALLMULTI) != 0 || dev->mc_count > 0);
> +
> +	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_RX,
> +				  VIRTIO_NET_CTRL_RX_PROMISC,
> +				  &promisc, sizeof(promisc)))
> +		printk(KERN_WARNING "%s: Failed to %sable promisc mode.\n",
> +		       dev->name, promisc ? "en" : "dis");
> +
> +	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_RX,
> +				  VIRTIO_NET_CTRL_RX_ALLMULTI,
> +				  &allmulti, sizeof(allmulti)))
> +		printk(KERN_WARNING "%s: Failed to %sable allmulti mode.\n",
> +		       dev->name, allmulti ? "en" : "dis");
> +}

Hmm, we can't do anything with this error.  I'd be very tempted to define the API to say "this can't fail".  Leave this code in as a sanity check, but have a comment to that effect?

> +#define VIRTIO_NET_CTRL_RX    0
> + #define VIRTIO_NET_CTRL_RX_PROMISC      0
> + #define VIRTIO_NET_CTRL_RX_ALLMULTI     1

Comment above/beside these two perhaps?
/* Supported if VIRTIO_NET_F_CTRL_RX */

Cheers,
Rusty.
