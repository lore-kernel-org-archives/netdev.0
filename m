From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [v4 PATCH 1/1] netfilter: Add fail-open support
Date: Thu, 24 May 2012 12:17:55 +0200
Message-ID: <20120524101755.GF13091@1984>
References: <20120524082518.13146.25740.sendpatchset@localhost.localdomain>
 <20120524082531.13146.347.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, vivk@us.ibm.com, svajipay@in.ibm.com,
	fw@strlen.de, netfilter-devel@vger.kernel.org, sri@us.ibm.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	davem <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57323 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754837Ab2EXKTE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 May 2012 06:19:04 -0400
Content-Disposition: inline
In-Reply-To: <20120524082531.13146.347.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My main objection with this patch is that it adds more code out of the
scope of the nf_queue handling to nf_hook_slow. And this is done for
very specific purpose.

@David, @Eric: Krishna aims to provide a mechanism that can be enabled
to accept packets if the nfqueue becomes full, ie. it changes the
default behaviour under congestion from drop to accept. It seems some
users prefer not to block traffic under nfqueue congestion.

The problem is the GSO handling: If we start enqueueing segments and
the queue gets full, we've got a list with the remaining segments that
need to be accepted. The current approach to handle this situation
does not look very nice. Do you have any suggestion for this?

Thanks!

Patch is below, in case you want to have a look at it.

On Thu, May 24, 2012 at 01:55:31PM +0530, Krishna Kumar wrote:
> Implement a new "fail-open" mode where packets are not dropped
> upon queue-full condition. This mode can be enabled/disabled per
> queue using netlink NFAQ_CFG_FLAGS & NFAQ_CFG_MASK attributes.
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> Signed-off-by: Vivek Kashyap <vivk@us.ibm.com>
> Signed-off-by: Sridhar Samudrala <samudrala@us.ibm.com>
> ---
>  include/linux/netfilter/nfnetlink_queue.h |    5 ++
>  net/netfilter/core.c                      |   37 +++++++++++++++++++-
>  net/netfilter/nf_queue.c                  |   15 ++++++--
>  net/netfilter/nfnetlink_queue.c           |   36 +++++++++++++++++--
>  4 files changed, 86 insertions(+), 7 deletions(-)
> 
> diff -ruNp org/include/linux/netfilter/nfnetlink_queue.h new/include/linux/netfilter/nfnetlink_queue.h
> --- org/include/linux/netfilter/nfnetlink_queue.h	2012-05-23 09:52:54.738660685 +0530
> +++ new/include/linux/netfilter/nfnetlink_queue.h	2012-05-24 10:25:33.500073415 +0530
> @@ -84,8 +84,13 @@ enum nfqnl_attr_config {
>  	NFQA_CFG_CMD,			/* nfqnl_msg_config_cmd */
>  	NFQA_CFG_PARAMS,		/* nfqnl_msg_config_params */
>  	NFQA_CFG_QUEUE_MAXLEN,		/* __u32 */
> +	NFQA_CFG_MASK,			/* identify which flags to change */
> +	NFQA_CFG_FLAGS,			/* value of these flags (__be32) */
>  	__NFQA_CFG_MAX
>  };
>  #define NFQA_CFG_MAX (__NFQA_CFG_MAX-1)
>  
> +/* Flags for NFQA_CFG_FLAGS */
> +#define NFQA_CFG_F_FAIL_OPEN			(1 << 0)
> +
>  #endif /* _NFNETLINK_QUEUE_H */
> diff -ruNp org/net/netfilter/core.c new/net/netfilter/core.c
> --- org/net/netfilter/core.c	2012-05-23 09:52:54.740660556 +0530
> +++ new/net/netfilter/core.c	2012-05-24 11:35:55.958845493 +0530
> @@ -163,6 +163,31 @@ repeat:
>  	return NF_ACCEPT;
>  }
>  
> +/*
> + * Handler was not able to enqueue the packet, and returned ENOSPC
> + * as "fail-open" was enabled. We temporarily accept the skb; or
> + * each segment for a GSO skb and free the header.
> + */
> +static void handle_fail_open(struct sk_buff *skb,
> +			     int (*okfn)(struct sk_buff *))
> +{
> +	struct sk_buff *segs;
> +	bool gso;
> +
> +	segs = skb->next ? : skb;
> +	gso = skb->next != NULL;
> +
> +	do {
> +		struct sk_buff *nskb = segs->next;
> +
> +		segs->next = NULL;
> +		okfn(segs);
> +		segs = nskb;
> +	} while (segs);
> +
> +	if (gso)
> +		kfree_skb(skb);
> +}
>  
>  /* Returns 1 if okfn() needs to be executed by the caller,
>   * -EPERM for NF_DROP, 0 otherwise. */
> @@ -174,6 +199,7 @@ int nf_hook_slow(u_int8_t pf, unsigned i
>  {
>  	struct list_head *elem;
>  	unsigned int verdict;
> +	int failopen = 0;
>  	int ret = 0;
>  
>  	/* We may already have this, but read-locks nest anyway */
> @@ -184,7 +210,8 @@ next_hook:
>  	verdict = nf_iterate(&nf_hooks[pf][hook], skb, hook, indev,
>  			     outdev, &elem, okfn, hook_thresh);
>  	if (verdict == NF_ACCEPT || verdict == NF_STOP) {
> -		ret = 1;
> +		if (!failopen) /* don't use the default verdict if 'failopen' */
> +			ret = 1;
>  	} else if ((verdict & NF_VERDICT_MASK) == NF_DROP) {
>  		kfree_skb(skb);
>  		ret = NF_DROP_GETERR(verdict);
> @@ -199,10 +226,18 @@ next_hook:
>  			if (err == -ESRCH &&
>  			   (verdict & NF_VERDICT_FLAG_QUEUE_BYPASS))
>  				goto next_hook;
> +			if (err == -ENOSPC) {
> +				failopen = 1;
> +				goto next_hook;
> +			}
>  			kfree_skb(skb);
>  		}
>  	}
>  	rcu_read_unlock();
> +
> +	if (!ret && failopen)
> +		handle_fail_open(skb, okfn);
> +
>  	return ret;
>  }
>  EXPORT_SYMBOL(nf_hook_slow);
> diff -ruNp org/net/netfilter/nfnetlink_queue.c new/net/netfilter/nfnetlink_queue.c
> --- org/net/netfilter/nfnetlink_queue.c	2012-05-23 09:52:54.742661899 +0530
> +++ new/net/netfilter/nfnetlink_queue.c	2012-05-24 13:42:24.155860334 +0530
> @@ -52,6 +52,7 @@ struct nfqnl_instance {
>  
>  	u_int16_t queue_num;			/* number of this queue */
>  	u_int8_t copy_mode;
> +	u_int32_t flags;			/* Set using NFQA_CFG_FLAGS */
>  /*
>   * Following fields are dirtied for each queued packet,
>   * keep them in same cache line if possible.
> @@ -431,9 +432,13 @@ nfqnl_enqueue_packet(struct nf_queue_ent
>  		goto err_out_free_nskb;
>  	}
>  	if (queue->queue_total >= queue->queue_maxlen) {
> -		queue->queue_dropped++;
> -		net_warn_ratelimited("nf_queue: full at %d entries, dropping packets(s)\n",
> -				     queue->queue_total);
> +		if (queue->flags & NFQA_CFG_F_FAIL_OPEN) {
> +			err = -ENOSPC;
> +		} else {
> +			queue->queue_dropped++;
> +			net_warn_ratelimited("nf_queue: full at %d entries, dropping packets(s)\n",
> +					     queue->queue_total);
> +		}
>  		goto err_out_free_nskb;
>  	}
>  	entry->id = ++queue->id_sequence;
> @@ -858,6 +863,31 @@ nfqnl_recv_config(struct sock *ctnl, str
>  		spin_unlock_bh(&queue->lock);
>  	}
>  
> +	if (nfqa[NFQA_CFG_FLAGS]) {
> +		__be32 flags, mask;
> +
> +		if (!queue) {
> +			ret = -ENODEV;
> +			goto err_out_unlock;
> +		}
> +
> +		if (!nfqa[NFQA_CFG_MASK]) {
> +			/* A mask is needed to specify which flags are being
> +			 * changed.
> +			 */
> +			ret = -EINVAL;
> +			goto err_out_unlock;
> +		}
> +
> +		flags = ntohl(nla_get_be32(nfqa[NFQA_CFG_FLAGS]));
> +		mask = ntohl(nla_get_be32(nfqa[NFQA_CFG_MASK]));
> +
> +		spin_lock_bh(&queue->lock);
> +		queue->flags &= ~mask;
> +		queue->flags |= flags & mask;
> +		spin_unlock_bh(&queue->lock);
> +	}
> +
>  err_out_unlock:
>  	rcu_read_unlock();
>  	return ret;
> diff -ruNp org/net/netfilter/nf_queue.c new/net/netfilter/nf_queue.c
> --- org/net/netfilter/nf_queue.c	2012-05-23 09:52:54.739533744 +0530
> +++ new/net/netfilter/nf_queue.c	2012-05-24 11:34:46.302003629 +0530
> @@ -268,14 +268,23 @@ int nf_queue(struct sk_buff *skb,
>  			err = __nf_queue(segs, elem, pf, hook, indev,
>  					   outdev, okfn, queuenum);
>  		}
> -		if (err == 0)
> +
> +		if (err == 0) {
>  			queued++;
> -		else
> +		} else if (err == -ENOSPC) {
> +			/* Enqueue failed due to queue-full and handler is
> +			 * in "fail-open" mode.
> +			 */
> +			segs->next = nskb;
> +			skb->next = segs;
> +			break;
> +		} else {
>  			kfree_skb(segs);
> +		}
>  		segs = nskb;
>  	} while (segs);
>  
> -	if (queued) {
> +	if (queued && err != -ENOSPC) {
>  		kfree_skb(skb);
>  		return 0;
>  	}
> 
