From: Oren Laadan <orenl@cs.columbia.edu>
Subject: Re: [PATCH 2/4] C/R: Basic support for network namespaces and devices
 (v3)
Date: Thu, 11 Feb 2010 12:20:55 -0500 (EST)
Message-ID: <Pine.LNX.4.64.1002111147270.13921@takamine.ncl.cs.columbia.edu>
References: <1265750713-15749-1-git-send-email-danms@us.ibm.com>
 <1265750713-15749-3-git-send-email-danms@us.ibm.com> <87ljf1gemh.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: containers@lists.osdl.org, netdev@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from serrano.cc.columbia.edu ([128.59.29.6]:52896 "EHLO
	serrano.cc.columbia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755254Ab0BKRVF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2010 12:21:05 -0500
In-Reply-To: <87ljf1gemh.fsf@caffeine.danplanet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 10 Feb 2010, Dan Smith wrote:

> Guilt dropped the new checkpoint_dev.c file when I switched to the
> newer branch.  Sorry about that.  Updated patch included below.
> 
> -- 
> Dan Smith
> IBM Linux Technology Center
> email: danms@us.ibm.com
> 
> C/R: Basic support for network namespaces and devices (v3)
> 
> When checkpointing a task tree with network namespaces, we hook into
> do_checkpoint_ns() along with the others.  Any devices in a given namespace
> are checkpointed (including their peer, in the case of veth) sequentially.
> Each network device stores a list of protocol addresses, as well as other
> information, such as hardware address.
> 
> This patch supports veth pairs, as well as the loopback adapter.  The
> loopback support is there to make sure that any additional addresses and
> state (such as up/down) is copied to the loopback adapter that we are
> given in the new network namespace.
> 
> On restart, we instantiate new network namespaces and veth pairs as
> necessary.  Any device we encounter that isn't in a network namespace
> that was checkpointed as part of a task is left in the namespace of the
> restarting process.  This will be the case for a veth half that exists
> in the init netns to provide network access to a container.

[...]

> index fcd07fa..9375e62 100644
> --- a/checkpoint/restart.c
> +++ b/checkpoint/restart.c
> @@ -690,6 +690,10 @@ static int restore_container(struct ckpt_ctx *ctx)
>  		return PTR_ERR(h);
>  	ckpt_hdr_put(ctx, h);
>  
> +	/* Store the ref of the init netns so we know to leave its
> +	 * devices where they fall */
> +	ctx->init_netns_ref = h->init_netns_ref;
> +

Validate h->init_netns_ref first ?

>  	/* read the LSM name and info which follow ("are a part of")
>  	 * the ckpt_hdr_container */
>  	ret = restore_lsm(ctx);
> diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> index 7101d6f..f6e144f 100644
> --- a/include/linux/checkpoint.h
> +++ b/include/linux/checkpoint.h
> @@ -35,6 +35,7 @@
>  #include <linux/checkpoint_types.h>
>  #include <linux/checkpoint_hdr.h>
>  #include <linux/err.h>
> +#include <linux/inetdevice.h>
>  #include <net/sock.h>
>  
>  /* sycall helpers */
> @@ -119,6 +120,26 @@ extern int ckpt_sock_getnames(struct ckpt_ctx *ctx,
>  extern struct sk_buff *sock_restore_skb(struct ckpt_ctx *ctx, struct sock *sk);
>  extern void sock_listening_list_free(struct list_head *head);
>  
> +#ifdef CONFIG_CHECKPOINT_NETNS
> +int checkpoint_netns(struct ckpt_ctx *ctx, void *ptr);
> +void *restore_netns(struct ckpt_ctx *ctx);
> +int checkpoint_netdev(struct ckpt_ctx *ctx, void *ptr);
> +void *restore_netdev(struct ckpt_ctx *ctx);
> +
> +int ckpt_netdev_in_init_netns(struct ckpt_ctx *ctx, struct net_device *dev);
> +int ckpt_netdev_inet_addrs(struct in_device *indev,
> +			   struct ckpt_netdev_addr *list[]);
> +int ckpt_netdev_hwaddr(struct net_device *dev, struct ckpt_hdr_netdev *h);
> +struct ckpt_hdr_netdev *ckpt_netdev_base(struct ckpt_ctx *ctx,
> +					 struct net_device *dev,
> +					 struct ckpt_netdev_addr *addrs[]);

Nit: add 'extern' please (I vaguely recall a complaint about it)

[...]

> +static int do_restore_netns(struct ckpt_ctx *ctx,
> +			    struct ckpt_hdr_ns *h,
> +			    struct nsproxy *nsproxy)
> +{
> +#ifdef CONFIG_CHECKPOINT_NETNS
> +	struct net *net_ns;
> +
> +	if (h->net_objref < 0)
> +		return -EINVAL;

This is covered by ckpt_obj_fetch().

> +	else if (h->net_objref == 0)
> +		return 0;
> +
> +	net_ns = ckpt_obj_fetch(ctx, h->net_objref, CKPT_OBJ_NET_NS);
> +	if (IS_ERR(net_ns))
> +		return PTR_ERR(net_ns);
> +
> +	get_net(net_ns);
> +	nsproxy->net_ns = net_ns;
> +#else
> +	if (h->net_objref > 0)
> +		return -EINVAL;

If you get rid of the #ifdef, then the code aboe already covers 
this case.

> +	get_net(current->nsproxy->net_ns);
> +	nsproxy->net_ns = current->nsproxy->net_ns;
> +#endif
> +
> +	return 0;
> +}
> +
>  static struct nsproxy *do_restore_ns(struct ckpt_ctx *ctx)
>  {
>  	struct ckpt_hdr_ns *h;
> @@ -349,8 +388,6 @@ static struct nsproxy *do_restore_ns(struct ckpt_ctx *ctx)
>  	nsproxy->pid_ns = current->nsproxy->pid_ns;
>  	get_mnt_ns(current->nsproxy->mnt_ns);
>  	nsproxy->mnt_ns = current->nsproxy->mnt_ns;
> -	get_net(current->nsproxy->net_ns);
> -	nsproxy->net_ns = current->nsproxy->net_ns;

(*) see below.

>  #else
>  	nsproxy = current->nsproxy;
>  	get_nsproxy(nsproxy);
> @@ -359,6 +396,10 @@ static struct nsproxy *do_restore_ns(struct ckpt_ctx *ctx)
>  	BUG_ON(nsproxy->ipc_ns != ipc_ns);
>  #endif
>  
> +	ret = do_restore_netns(ctx, h, nsproxy);
> +	if (ret < 0)
> +		goto out;
> +

How about instead, after the "ipc_ns = ..." in the original code you add:
	if (h->net_objref == 0)
		net_ns = current->nsproxy->net_ns;
	else
		net_ns = ckpt_obj_fetch(ctx, h->net_objref, CKPT_OBJ_NET_NS);

and then the two lines in (*) will move a bit up and become:
	get_net_ns(net_ns);
	nsproxy->net_ns = net_ns;

In fact, this is a lead to a generic way to allow for reuse of the
parent namespace (of the container) that I can adapt for the other
namespaces too.

Also theoretically you want to add "|| defined(CONFIG_NET_NS)" and
a matching BUG_ON(...) like the existing code. However, I now think
that the optimization there is confusing so I'll simplify it.

[...]

> +int ckpt_netdev_inet_addrs(struct in_device *indev,
> +			   struct ckpt_netdev_addr *_abuf[])
> +{
> +	struct ckpt_netdev_addr *abuf = NULL;
> +	struct in_ifaddr *addr = indev->ifa_list;
> +	int pages = 0;
> +	int addrs = 0;
> +	int max;
> +
> +	read_lock(&dev_base_lock);
> + retry:
> +	if (++pages > 4) {
> +		addrs = -ENOMEM;
> +		goto out;

Since this is not the usual "no memory", but related to the state of 
the network device, it would be useful to communicate this status to
the caller via ckpt_err().

For example, you can return -E2BIG and below then report the error 
conditoinally if the error value matches.

[...]

> +struct ckpt_hdr_netdev *ckpt_netdev_base(struct ckpt_ctx *ctx,
> +					 struct net_device *dev,
> +					 struct ckpt_netdev_addr *addrs[])
> +{
> +	struct ckpt_hdr_netdev *h;
> +	int ret;
> +
> +	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_NETDEV);
> +	if (!h)
> +		return ERR_PTR(-ENOMEM);
> +
> +	ret = ckpt_netdev_hwaddr(dev, h);
> +	if (ret < 0)

(report here the error, e.g. for E2BIG)

> +		goto out;
> +
> +	*addrs = NULL;
> +	ret = h->inet_addrs = ckpt_netdev_inet_addrs(dev->ip_ptr, addrs);
> +	if (ret < 0)
> +		goto out;
> +
> +	ret = h->netns_ref = checkpoint_obj(ctx, dev->nd_net, CKPT_OBJ_NET_NS);
> + out:
> +	if (ret < 0) {
> +		ckpt_hdr_put(ctx, h);
> +		h = ERR_PTR(ret);
> +		if (*addrs)
> +			kfree(*addrs);
> +	}
> +
> +	return h;
> +}
> +
> +int checkpoint_netdev(struct ckpt_ctx *ctx, void *ptr)
> +{
> +	struct net_device *dev = (struct net_device *)ptr;
> +
> +	if (!dev->netdev_ops->ndo_checkpoint)
> +		return -EINVAL;

Maybe ENOSYS is better ?
Also ckpt_err() would be useful.

> +
> +	ckpt_debug("checkpointing netdev %s\n", dev->name);
> +
> +	return dev->netdev_ops->ndo_checkpoint(ctx, dev);
> +}

[...]

Oren.

