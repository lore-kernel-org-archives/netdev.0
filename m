From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/5] Add checkpoint support for veth devices (v2)
Date: Mon, 22 Feb 2010 13:56:47 -0600
Message-ID: <20100222195647.GB13135@us.ibm.com>
References: <1266336187-19105-1-git-send-email-danms@us.ibm.com>
	<1266336187-19105-4-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1266336187-19105-4-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Quoting Dan Smith (danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> Adds an ndo_checkpoint() handler for veth devices to checkpoint themselves.
> Writes out the pairing information, addresses, and initiates a checkpoint
> on the peer if the peer won't be reached from another netns.  Throws an
> error of our peer's netns isn't already in the hash (i.e., a tree leak).
> 
> Changes in v2:
>  - Fix check detecting if peer is in the init netns
> 
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  drivers/net/veth.c |   76 ++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 76 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/veth.c b/drivers/net/veth.c
> index 3a15de5..db92de8 100644
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
> @@ -284,6 +287,76 @@ static void veth_dev_free(struct net_device *dev)
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
> +	ret = h->veth.this_ref = ckpt_obj_lookup_add(ctx, dev,
> +						     CKPT_OBJ_NETDEV, &n);
> +	if (ret < 0)
> +		goto out;
> +
> +	ret = h->veth.peer_ref = ckpt_obj_lookup_add(ctx, peer,
> +						     CKPT_OBJ_NETDEV, &n);
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

I'm not sure this check does what you think it does:  note that
ckpt_netdev_base(), defined in the previous patch, and called higher
up in this function, is going to checkpoint peer->nd_net.   :)

(right?)

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
> @@ -292,6 +365,9 @@ static const struct net_device_ops veth_netdev_ops = {
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
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
