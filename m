From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/4] C/R: Basic support for network namespaces and
	devices (v3)
Date: Wed, 10 Feb 2010 11:24:05 -0600
Message-ID: <20100210172405.GB12251@us.ibm.com>
References: <1265750713-15749-1-git-send-email-danms@us.ibm.com>
	<1265750713-15749-3-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1265750713-15749-3-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
> +struct ckpt_netdev_addr {
> +	__u16 type;

Pretty sure this will have to come after the union to get the
same sized struct on 32- and 64-bit.

> +	union {
> +		struct {
> +			__u32 inet4_local;
> +			__u32 inet4_address;
> +			__u32 inet4_mask;
> +			__u32 inet4_broadcast;
> +		};
> +	};
> +} __attribute__((aligned(8)));
> +
>  struct ckpt_hdr_eventpoll_items {
>  	struct ckpt_hdr h;
>  	__s32  epfile_objref;
> diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
> index 51efd5a..e646ec6 100644
> --- a/include/linux/checkpoint_types.h
> +++ b/include/linux/checkpoint_types.h
> @@ -86,6 +86,7 @@ struct ckpt_ctx {
>  	wait_queue_head_t ghostq;	/* waitqueue for ghost tasks */
>  	struct cred *realcred, *ecred;	/* tmp storage for cred at restart */
>  	struct list_head listen_sockets;/* listening parent sockets */
> +	int init_netns_ref;             /* Objref of root net namespace */
> 
>  	struct ckpt_stats stats;	/* statistics */
> 
> diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
> index b0e71f2..78f5615 100644
> --- a/kernel/nsproxy.c
> +++ b/kernel/nsproxy.c
> @@ -248,6 +248,11 @@ int ckpt_collect_ns(struct ckpt_ctx *ctx, struct task_struct *t)
>  	ret = ckpt_obj_collect(ctx, nsproxy->uts_ns, CKPT_OBJ_UTS_NS);
>  	if (ret < 0)
>  		goto out;
> +#ifdef CONFIG_CHECKPOINT_NETNS
> +	ret = ckpt_obj_collect(ctx, nsproxy->net_ns, CKPT_OBJ_NET_NS);
> +	if (ret < 0)
> +		goto out;
> +#endif
>  	ret = ckpt_obj_collect(ctx, nsproxy->ipc_ns, CKPT_OBJ_IPC_NS);
>  	if (ret < 0)
>  		goto out;
> @@ -288,6 +293,12 @@ static int do_checkpoint_ns(struct ckpt_ctx *ctx, struct nsproxy *nsproxy)
>  	if (ret < 0)
>  		goto out;
>  	h->ipc_objref = ret;
> +#ifdef CONFIG_CHECKPOINT_NETNS
> +	ret = checkpoint_obj(ctx, nsproxy->net_ns, CKPT_OBJ_NET_NS);
> +	if (ret < 0)
> +		goto out;
> +	h->net_objref = ret;
> +#endif
> 
>  	/* FIXME: for now, only marked visited to pacify leaks */
>  	ret = ckpt_obj_visit(ctx, nsproxy->mnt_ns, CKPT_OBJ_MNT_NS);
> @@ -306,6 +317,34 @@ int checkpoint_ns(struct ckpt_ctx *ctx, void *ptr)
>  	return do_checkpoint_ns(ctx, (struct nsproxy *) ptr);
>  }
> 
> +static int do_restore_netns(struct ckpt_ctx *ctx,
> +			    struct ckpt_hdr_ns *h,
> +			    struct nsproxy *nsproxy)
> +{
> +#ifdef CONFIG_CHECKPOINT_NETNS
> +	struct net *net_ns;
> +
> +	if (h->net_objref < 0)
> +		return -EINVAL;
> +	else if (h->net_objref == 0)
> +		return 0;

What exactly is this == 0 case?  Does it mean 'use inherited netns'?

Don't you then still need to 

	get_net(current->nsproxy->net_ns);
	nsproxy->net_ns = current->nsproxy->net_ns;

as below?

> +	net_ns = ckpt_obj_fetch(ctx, h->net_objref, CKPT_OBJ_NET_NS);
> +	if (IS_ERR(net_ns))
> +		return PTR_ERR(net_ns);
> +
> +	get_net(net_ns);
> +	nsproxy->net_ns = net_ns;
> +#else
> +	if (h->net_objref > 0)
> +		return -EINVAL;
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
>  	/* TODO: add more namespaces here */
>  	ret = 0;
>   out:

Otherwise, looks good.

thanks,
-serge
