From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 3/4] Add checkpoint support for veth devices
Date: Wed, 10 Feb 2010 11:57:51 -0600
Message-ID: <20100210175751.GC12251@us.ibm.com>
References: <1265750713-15749-1-git-send-email-danms@us.ibm.com>
 <1265750713-15749-4-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, netdev@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:58881 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754529Ab0BJR6D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 12:58:03 -0500
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e32.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o1AHpnca020638
	for <netdev@vger.kernel.org>; Wed, 10 Feb 2010 10:51:49 -0700
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o1AHvxL0123624
	for <netdev@vger.kernel.org>; Wed, 10 Feb 2010 10:57:59 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o1AHvwp2031746
	for <netdev@vger.kernel.org>; Wed, 10 Feb 2010 10:57:59 -0700
Content-Disposition: inline
In-Reply-To: <1265750713-15749-4-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Dan Smith (danms@us.ibm.com):
> Adds an ndo_checkpoint() handler for veth devices to checkpoint themselves.
> Writes out the pairing information, addresses, and initiates a checkpoint
> on the peer if the peer won't be reached from another netns.  Throws an
> error of our peer's netns isn't already in the hash (i.e., a tree leak).
> 
> Signed-off-by: Dan Smith <danms@us.ibm.com>

What is here looks good to me, both patches 3 and 4  (but of course i
can't ack as is :)

> ---
>  drivers/net/veth.c |   74 ++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 74 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/veth.c b/drivers/net/veth.c
> index 3a15de5..ad0f561 100644
> --- a/drivers/net/veth.c
> +++ b/drivers/net/veth.c
> @@ -16,6 +16,9 @@
>  #include <net/xfrm.h>
>  #include <linux/veth.h>
> 
> +#include <linux/checkpoint.h>
> +#include <linux/checkpoint_hdr.h>
> +
>  #define DRV_NAME	"veth"
>  #define DRV_VERSION	"1.0"
> 
> @@ -284,6 +287,74 @@ static void veth_dev_free(struct net_device *dev)
>  	free_netdev(dev);
>  }
> 
> +#ifdef CONFIG_CHECKPOINT
> +static int veth_checkpoint(struct ckpt_ctx *ctx, struct net_device *dev)
> +{
> +	struct ckpt_hdr_netdev *h;
> +	struct veth_priv *priv = netdev_priv(dev);
> +	struct net_device *peer = priv->peer;
> +	struct ckpt_netdev_addr *addrs;
> +	int ret;
> +	int n;
> +
> +	if (!peer) {
> +		ckpt_err(ctx, -EINVAL, "veth device has no peer!\n");
> +		return -EINVAL;
> +	}
> +
> +	h = ckpt_netdev_base(ctx, dev, &addrs);
> +	if (IS_ERR(h))
> +		return PTR_ERR(h);
> +
> +	h->type = CKPT_NETDEV_VETH;
> +
> +	ret = h->this_ref = ckpt_obj_lookup_add(ctx, dev, CKPT_OBJ_NETDEV, &n);
> +	if (ret < 0)
> +		goto out;
> +
> +	ret = h->peer_ref = ckpt_obj_lookup_add(ctx, peer, CKPT_OBJ_NETDEV, &n);
> +	if (ret < 0)
> +		goto out;
> +
> +	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *)h);
> +	if (ret < 0)
> +		goto out;
> +
> +	ret = ckpt_write_buffer(ctx, dev->name, IFNAMSIZ);
> +	if (ret < 0)
> +		goto out;
> +
> +	ret = ckpt_write_buffer(ctx, peer->name, IFNAMSIZ);
> +	if (ret < 0)
> +		goto out;
> +
> +	if (h->inet_addrs > 0) {
> +		int len = (sizeof(struct ckpt_netdev_addr) * h->inet_addrs);
> +		ret = ckpt_write_buffer(ctx, addrs, len);
> +		if (ret)
> +			goto out;
> +	}
> +
> +	/* Only checkpoint peer if we're not going to arrive at it
> +	 * via another task's netns.  Fail if the pipe exits
> +	 * our container to a netns not already in the hash
> +	 */
> +	if (ckpt_netdev_in_init_netns(ctx, peer))
> +		ret = checkpoint_obj(ctx, peer, CKPT_OBJ_NETDEV);
> +	else if (!ckpt_obj_lookup(ctx, peer->nd_net, CKPT_OBJ_NET_NS)) {
> +		ret = -EINVAL;
> +		ckpt_err(ctx, ret,
> +			 "Peer %s of %s not in checkpointed namespaces\n",
> +			 peer->name, dev->name);
> +	}
> + out:
> +	ckpt_hdr_put(ctx, h);
> +	kfree(addrs);
> +
> +	return ret;
> +}
> +#endif
> +
>  static const struct net_device_ops veth_netdev_ops = {
>  	.ndo_init            = veth_dev_init,
>  	.ndo_open            = veth_open,
> @@ -292,6 +363,9 @@ static const struct net_device_ops veth_netdev_ops = {
>  	.ndo_change_mtu      = veth_change_mtu,
>  	.ndo_get_stats       = veth_get_stats,
>  	.ndo_set_mac_address = eth_mac_addr,
> +#ifdef CONFIG_CHECKPOINT
> +	.ndo_checkpoint      = veth_checkpoint,
> +#endif
>  };
> 
>  static void veth_setup(struct net_device *dev)
> -- 
> 1.6.2.5
> 
> _______________________________________________
> Containers mailing list
> Containers@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
