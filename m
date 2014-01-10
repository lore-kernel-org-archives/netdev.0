From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC Patch net-next 2/4] net_sched: avoid holding qdisc lock
 for filters
Date: Thu, 09 Jan 2014 19:13:42 -0800
Message-ID: <52CF6566.9000707@gmail.com>
References: <1389291593-2494-1-git-send-email-xiyou.wangcong@gmail.com> <1389291593-2494-3-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f50.google.com ([209.85.219.50]:34572 "EHLO
	mail-oa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751027AbaAJDOB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 22:14:01 -0500
Received: by mail-oa0-f50.google.com with SMTP id l6so4410351oag.37
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 19:14:00 -0800 (PST)
In-Reply-To: <1389291593-2494-3-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/09/2014 10:19 AM, Cong Wang wrote:
> Cc: John Fastabend <john.fastabend@gmail.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>   include/net/pkt_cls.h     | 25 ++++---------------------
>   include/net/sch_generic.h |  5 +++--
>   net/sched/cls_api.c       | 12 +++++-------
>   3 files changed, 12 insertions(+), 30 deletions(-)
>
> diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
> index 50ea079..9afb15b 100644
> --- a/include/net/pkt_cls.h
> +++ b/include/net/pkt_cls.h
> @@ -18,26 +18,9 @@ int register_tcf_proto_ops(struct tcf_proto_ops *ops);
>   int unregister_tcf_proto_ops(struct tcf_proto_ops *ops);
>
>   static inline unsigned long
> -__cls_set_class(unsigned long *clp, unsigned long cl)
> +cls_set_class(unsigned long *clp, unsigned long cl)
>   {

commit message should mention this conversion to xchg.

> -	unsigned long old_cl;
> -
> -	old_cl = *clp;
> -	*clp = cl;
> -	return old_cl;
> -}
> -
> -static inline unsigned long
> -cls_set_class(struct tcf_proto *tp, unsigned long *clp,
> -	unsigned long cl)
> -{
> -	unsigned long old_cl;
> -	
> -	tcf_tree_lock(tp);
> -	old_cl = __cls_set_class(clp, cl);
> -	tcf_tree_unlock(tp);
> -
> -	return old_cl;
> +	return xchg(clp, cl);
>   }
>
>   static inline void
> @@ -46,7 +29,7 @@ tcf_bind_filter(struct tcf_proto *tp, struct tcf_result *r, unsigned long base)
>   	unsigned long cl;
>
>   	cl = tp->q->ops->cl_ops->bind_tcf(tp->q, base, r->classid);
> -	cl = cls_set_class(tp, &r->class, cl);
> +	cl = cls_set_class(&r->class, cl);
>   	if (cl)
>   		tp->q->ops->cl_ops->unbind_tcf(tp->q, cl);
>   }
> @@ -56,7 +39,7 @@ tcf_unbind_filter(struct tcf_proto *tp, struct tcf_result *r)
>   {
>   	unsigned long cl;
>
> -	if ((cl = __cls_set_class(&r->class, 0)) != 0)
> +	if ((cl = cls_set_class(&r->class, 0)) != 0)
>   		tp->q->ops->cl_ops->unbind_tcf(tp->q, cl);
>   }
>
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index 97123cc..000ce54 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -215,6 +215,7 @@ struct tcf_proto_ops {
>
>   struct tcf_proto {
>   	/* Fast access part */
> +	spinlock_t		lock;

[...]

Th lock can just be dropped all these operations are initiated via
rtnetlink and hence have rtnl held.

.John
-- 
John Fastabend         Intel Corporation
