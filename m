From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/9] PKT_SCHED: tc filter extension API
Date: 30 Dec 2004 23:36:57 -0500
Message-ID: <1104467816.1049.181.camel@jzny.localdomain>
References: <20041230122652.GM32419@postel.suug.ch>
	 <20041230123023.GO32419@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, Patrick McHardy <kaber@trash.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041230123023.GO32419@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-12-30 at 07:30, Thomas Graf wrote:

>   The extensions are executed by the classifier by calling tcf_exts_exec
>   which must be done as the last thing after making sure the
>   filter matches. Note: A classifier might take further actions after
>   the execution to tcf_exts_exec such as correcting its own cache to
>   avoid caching results which could have been influenced by the extensions.

Which cache?

>   tcf_exts_exec returns a negative error code if the filter must be
>   considered unmatched, 0 on normal execution or a positive classifier
>   return code (TC_ACT_*) which must be returned to the underlying layer
>   as-is.

Look at the TC_ACT_*; i think they should be sufficient.

> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> 
> --- linux-2.6.10-bk2.orig/include/net/pkt_cls.h	2004-12-30 01:22:01.000000000 +0100
> +++ linux-2.6.10-bk2/include/net/pkt_cls.h	2004-12-30 01:22:39.000000000 +0100


> +/**
> + * tcf_exts_exec - execute tc filter extensions
> + * @skb: socket buffer
> + * @exts: tc filter extensions handle
> + * @res: desired result
> + *
> + * Executes all configured extensions. Returns 0 on a normal execution,
> + * a negative number if the filter must be considered unmatched or
> + * a positive action code (TC_ACT_*) which must be returned to the
> + * underlying layer.

TCA_ACT_OK is 0. 



>  tcf_change_act_police(struct tcf_proto *tp, struct tc_action **action,
> --- linux-2.6.10-bk2.orig/net/sched/cls_api.c	2004-12-30 01:22:01.000000000 +0100
> +++ linux-2.6.10-bk2/net/sched/cls_api.c	2004-12-30 00:47:06.000000000 +0100
> @@ -439,6 +439,162 @@
>  	return skb->len;
>  }

> +
> +int
> +tcf_exts_validate(struct tcf_proto *tp, struct rtattr **tb,
> +	          struct rtattr *rate_tlv, struct tcf_exts *exts,
> +	          struct tcf_ext_map *map)
> +{
> +	memset(exts, 0, sizeof(*exts));
> +	
> +#ifdef CONFIG_NET_CLS_ACT
> +	int err;
> +	struct tc_action *act;
> +
> +	if (map->police && tb[map->police-1] && rate_tlv) {
> +		act = tcf_action_init_1(tb[map->police-1], rate_tlv, "police",
> +			TCA_ACT_NOREPLACE, TCA_ACT_BIND, &err);
> +		if (NULL == act)
> +			return err;
> +
> +		act->type = TCA_OLD_COMPAT;
> +		exts->action = act;
> +	} else if (map->action && tb[map->action-1] && rate_tlv) {
> +		act = tcf_action_init(tb[map->action-1], rate_tlv, NULL,
> +			TCA_ACT_NOREPLACE, TCA_ACT_BIND, &err);
> +		if (NULL == act)
> +			return err;
> +
> +		exts->action = act;
> +	}
> +#elif defined CONFIG_NET_CLS_POLICE
> +	if (map->police && tb[map->police-1] && rate_tlv) {
> +		struct tcf_police *p;
> +		
> +		p = tcf_police_locate(tb[map->police-1], rate_tlv);
> +		if (NULL == p)
> +			return -EINVAL;
> +
> +		exts->police = p;
> +	} else if (map->action && tb[map->action-1])
> +		return -EOPNOTSUPP;
> +#else
> +	if ((map->action && tb[map->action-1]) ||
> +	    (map->police && tb[map->police-1]))
> +		return -EOPNOTSUPP;
> +#endif
> +
> +	return 0;
> +}

Maybe a few DPRINTKs for debugging purposes?

> +void
> +tcf_exts_change(struct tcf_proto *tp, struct tcf_exts *dst,
> +	        struct tcf_exts *src)
> +{
> +#ifdef CONFIG_NET_CLS_ACT
> +	if (src->action) {
> +		if (dst->action) {
> +			struct tc_action *act;
> +
> +			tcf_tree_lock(tp);
> +			act = xchg(&dst->action, src->action);
> +			tcf_tree_unlock(tp);
> +
> +			tcf_action_destroy(act, TCA_ACT_UNBIND);
> +		} else
> +			dst->action = src->action;
> +	}
> +#elif defined CONFIG_NET_CLS_POLICE
> +	if (src->police) {
> +		if (dst->police) {
> +			struct tcf_police *p;
> +
> +			tcf_tree_lock(tp);
> +			p = xchg(&dst->police, src->police);
> +			tcf_tree_unlock(tp);
> +
> +			tcf_police_release(p, TCA_ACT_UNBIND);
> +		} else
> +			dst->police = src->police;
> +	}
> +#endif

Patrick pointed this in other email: the xchg is sort of defeated by the
else. Perhaps make  the second one xchg as well.

BTW Thomas: Hopefully these patches match closely what was already in
place? (sorry didnt cross reference)
i.e if any optimizations we should probably bring next phase

cheers,
jamal
