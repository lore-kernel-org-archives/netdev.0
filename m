From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/9] PKT_SCHED: tc filter extension API
Date: Fri, 31 Dec 2004 02:01:06 +0100
Message-ID: <41D4A4D2.4000109@trash.net>
References: <20041230122652.GM32419@postel.suug.ch> <20041230123023.GO32419@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <hadi@cyberus.ca>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041230123023.GO32419@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:

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

Please use act == NULL


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

This isn't right (its also wrong in the current code). If the
CPU reorders stores and another CPU looks at dst->action at
the wrong time it might see an inconsistent structure. So at
least smp_wmb is required for the unlocked case, but I think
you should just remove it completely. I also wonder if anyone
actually knows why we need the xchg (here and in all the other
places), it looks totally useless.

Regards
Patrick
