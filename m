From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH v2 3/4] virtio_net: Add a MAC filter table
Date: Fri, 30 Jan 2009 16:16:26 +1030
Message-ID: <200901301616.26914.rusty@rustcorp.com.au>
References: <20090129230502.2672.87669.stgit@debian.lart> <20090129230518.2672.20841.stgit@debian.lart>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: markmc@redhat.com, netdev@vger.kernel.org, kvm@vger.kernel.org
To: Alex Williamson <alex.williamson@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:56531 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751117AbZA3Fqo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jan 2009 00:46:44 -0500
In-Reply-To: <20090129230518.2672.20841.stgit@debian.lart>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 30 January 2009 09:35:18 Alex Williamson wrote:
>  	struct virtnet_info *vi = netdev_priv(dev);
>  	u8 promisc, allmulti;
> +	struct scatterlist sg[4];
> +	struct virtio_net_ctrl_hdr ctrl;
> +	virtio_net_ctrl_ack status;
> +	u8 *uc_buf = NULL, *mc_buf = NULL;
> +	unsigned int tmp;
>  
>  	if (!virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_RX))
>  		return;

It's kind of annoying that we have our virtnet_send_command helper and
yet we can't use it here.

Hmm, maybe we can kill two birds in one stone?  I was a bit nervous about the virtnet_send_command data arg because the pointer must not be vmalloc'ed memory.  If we make the arg to virtnet_send_command an sg[] in place of data & len, we force the caller to do the sg_set_buf (which means they *should* be aware of the limitation on what can be put in an sg), and we can make a copy (ideally we could chain it, but it's not possible to chain a const sg[], so let's BUG_ON if it's too big to fit on the stack).

Then this code can use it.

> -	promisc = ((dev->flags & IFF_PROMISC) != 0 || dev->uc_count > 0);
> -	allmulti = ((dev->flags & IFF_ALLMULTI) != 0 || dev->mc_count > 0);
> +	promisc = ((dev->flags & IFF_PROMISC) != 0);
> +	allmulti = ((dev->flags & IFF_ALLMULTI) != 0);
> +
> +	if (!virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_MAC)) {
> +		promisc |= (dev->uc_count > 0);
> +		allmulti |= (dev->mc_count > 0);
> +	}
>  
>  	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_RX,
>  				  VIRTIO_NET_CTRL_RX_PROMISC,
> @@ -682,6 +692,79 @@ static void virtnet_set_rx_mode(struct net_device *dev)
>  				  &allmulti, sizeof(allmulti)))
>  		printk(KERN_WARNING "%s: Failed to %sable allmulti mode.\n",
>  		       dev->name, allmulti ? "en" : "dis");
> +
> +	if (!virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_MAC))
> +		return;

I think we can now fold this feature into VIRTIO_NET_F_CTRL_RX and assert that you must support mac filtering.  Because it's now trivial to support in the host (use promisc!), and it simplifies the implementation.

> +	if (dev->uc_count) {
...
> +		sg_set_buf(&sg[1], uc_buf, dev->uc_count * ETH_ALEN);
...
> +	if (dev->mc_count) {
...
> +		sg_set_buf(&sg[2], mc_buf, dev->mc_count * ETH_ALEN);

We made the decision a while ago not to rely on scatter gather boundaries to define the API.  So you'll actually need a structure to contain the counts unfortunately (technically you only need one count, since the other can be intuited, but that seems silly, and this way you could theoretically add more fields without problems with future feature bits).

It also means you can do a single kmalloc, and skip the if here, if you wanted.

Cheers,
Rusty.
