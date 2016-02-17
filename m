From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH v3 3/8] net: sched: add cls_u32 offload hooks for
 netdevs
Date: Wed, 17 Feb 2016 05:59:26 -0500
Message-ID: <56C4528E.5090505@mojatatu.com>
References: <20160217051418.17139.41052.stgit@john-Precision-Tower-5810>
 <20160217051709.17139.88337.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: John Fastabend <john.fastabend@gmail.com>, jiri@resnulli.us,
	amir@vadai.me, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:37851 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934096AbcBQK72 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 05:59:28 -0500
Received: by mail-ig0-f176.google.com with SMTP id 5so12583483igt.0
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 02:59:28 -0800 (PST)
In-Reply-To: <20160217051709.17139.88337.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-17 12:17 AM, John Fastabend wrote:
> This patch allows netdev drivers to consume cls_u32 offloads via
> the ndo_setup_tc ndo op.
>
> This works aligns with how network drivers have been doing qdisc
> offloads for mqprio.
>

This one i have comments on.

> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>   include/linux/netdevice.h |    6 ++-
>   include/net/pkt_cls.h     |   34 +++++++++++++++
>   net/sched/cls_u32.c       |   99 ++++++++++++++++++++++++++++++++++++++++++++-
>   3 files changed, 136 insertions(+), 3 deletions(-)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index e396060..47671ce0 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -779,17 +779,21 @@ static inline bool netdev_phys_item_id_same(struct netdev_phys_item_id *a,
>   typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
>   				       struct sk_buff *skb);
>
> -/* This structure holds attributes of qdisc and classifiers
> +/* These structures hold the attributes of qdisc and classifiers
>    * that are being passed to the netdevice through the setup_tc op.
>    */
>   enum {
>   	TC_SETUP_MQPRIO,
> +	TC_SETUP_CLSU32,
>   };
>
> +struct tc_cls_u32_offload;
> +
>   struct tc_to_netdev {
>   	unsigned int type;
>   	union {
>   		u8 tc;
> +		struct tc_cls_u32_offload *cls_u32;
>   	};
>   };
>
 >
> diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
> index bc49967..59789ca 100644
> --- a/include/net/pkt_cls.h
> +++ b/include/net/pkt_cls.h
> @@ -358,4 +358,38 @@ tcf_match_indev(struct sk_buff *skb, int ifindex)
>   }
>   #endif /* CONFIG_NET_CLS_IND */
>
> +struct tc_cls_u32_knode {
> +	struct tcf_exts *exts;
> +	u8 fshift;
> +	u32 handle;
> +	u32 val;
> +	u32 mask;
> +	u32 link_handle;
> +	struct tc_u32_sel *sel;
> +};
>

Swapping sel and fshift would give better struct alignment.

> +struct tc_cls_u32_hnode {
> +	u32 handle;
> +	u32 prio;
> +	unsigned int divisor;
> +};


Assuming in the future "prio" would be moved to something that is more
generic classifier specific?

> +enum tc_clsu32_command {
> +	TC_CLSU32_NEW_KNODE,
> +	TC_CLSU32_REPLACE_KNODE,
> +	TC_CLSU32_DELETE_KNODE,
> +	TC_CLSU32_NEW_HNODE,
> +	TC_CLSU32_REPLACE_HNODE,
> +	TC_CLSU32_DELETE_HNODE,
> +};
> +

It seems to me commands should be generic which speak
Netlinkism. A REPLACE is just a flag to NEW. You dont need
a NEW_XXX for every object. switchdev got this right.
If you use cmd + flags  then you can have all kinds of
netlink semantics that relay user intent from user space. Example:
Exclusivity where user says "create if it doesnt exist but dont replace
if it does".
At minimal add "flags" there.
Maybe not this release - but it makes sense to move "command" into 
tc_to_netdev; a u16 cmd + u16 flags.

> +struct tc_cls_u32_offload {
> +	/* knode values */
> +	enum tc_clsu32_command command;
> +	union {
> +		struct tc_cls_u32_knode knode;
> +		struct tc_cls_u32_hnode hnode;
> +	};
> +};
> +
>   #endif
> diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
> index 4fbb674..d54bc94 100644

> +static void u32_replace_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h)
> +{
> +	struct net_device *dev = tp->q->dev_queue->dev;
> +	struct tc_cls_u32_offload u32_offload = {0};
> +	struct tc_to_netdev offload;
> +
> +	offload.type = TC_SETUP_CLSU32;
> +	offload.cls_u32 = &u32_offload;
> +
> +	if (dev->netdev_ops->ndo_setup_tc) {
> +		offload.cls_u32->command = TC_CLSU32_NEW_HNODE;

TC_CLSU32_REPLACE_HNODE?

> +		offload.cls_u32->hnode.divisor = h->divisor;
> +		offload.cls_u32->hnode.handle = h->handle;
> +		offload.cls_u32->hnode.prio = h->prio;
> +
> +		dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
> +					      tp->protocol, &offload);
> +	}
> +}


>   static void u32_clear_hnode(struct tcf_proto *tp, struct tc_u_hnode *ht)
>   {
>   	struct tc_u_knode *n;
> @@ -434,6 +522,7 @@ static void u32_clear_hnode(struct tcf_proto *tp, struct tc_u_hnode *ht)
>   			RCU_INIT_POINTER(ht->ht[h],
>   					 rtnl_dereference(n->next));
>   			tcf_unbind_filter(tp, &n->res);
> +			u32_remove_hw_knode(tp, n->handle);
>   			call_rcu(&n->rcu, u32_delete_key_freepf_rcu);
>   		}
>   	}
> @@ -454,6 +543,7 @@ static int u32_destroy_hnode(struct tcf_proto *tp, struct tc_u_hnode *ht)
>   	     phn;
>   	     hn = &phn->next, phn = rtnl_dereference(*hn)) {
>   		if (phn == ht) {
> +			u32_clear_hw_hnode(tp, ht);
>   			RCU_INIT_POINTER(*hn, ht->next);
>   			kfree_rcu(ht, rcu);
>   			return 0;
> @@ -540,8 +630,10 @@ static int u32_delete(struct tcf_proto *tp, unsigned long arg)
>   	if (ht == NULL)
>   		return 0;
>
> -	if (TC_U32_KEY(ht->handle))
> +	if (TC_U32_KEY(ht->handle)) {
> +		u32_remove_hw_knode(tp, ht->handle);
>   		return u32_delete_key(tp, (struct tc_u_knode *)ht);
> +	}
>


You are unconditionally calling the _hw_ api. For someone not using _hw_ 
offloads, there are a few more instructions. Maybe just do the
dev->netdev_ops->ndo_setup_tc first?


And to Or's point: How do i distinguish s/w from h/w?

cheers,
jamal
