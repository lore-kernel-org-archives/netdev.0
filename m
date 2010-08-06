From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 1/9] net classifier: dont allow filters on semi-classful
 qdisc
Date: Fri, 06 Aug 2010 23:24:47 +0200
Message-ID: <4C5C7D9F.4040303@gmail.com>
References: <20100806193548.007978639@vyatta.com> <20100806193558.580890552@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:39410 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964823Ab0HFVYy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Aug 2010 17:24:54 -0400
Received: by bwz3 with SMTP id 3so231693bwz.19
        for <netdev@vger.kernel.org>; Fri, 06 Aug 2010 14:24:52 -0700 (PDT)
In-Reply-To: <20100806193558.580890552@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote, On -10.01.-28163 20:59:

> There are several qdisc which only support a single class (sfq, mq, tbf)
> and the kernel would dereference a null pointer (bind_tcf), if a user
> attempted to apply a filter one of these classes.


mq and tbf can't have this issue because they don't have
.tcf_chain class method. sfq should support it on purpose
after this patch:

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=7d2681a6ff4f9ab5e48d02550b4c6338f1638998
and needs tiny fix only.


Jarek P.

> 
> This patch changes the tcf_bind_filter to return an error in
> these cases.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> 
> ---
> This needs to go in net-2.6 and stable.
> 
>  include/net/pkt_cls.h   |   12 +++++++++---
>  net/sched/cls_basic.c   |    4 +++-
>  net/sched/cls_fw.c      |    6 ++++--
>  net/sched/cls_route.c   |    4 +++-
>  net/sched/cls_tcindex.c |    4 +++-
>  net/sched/cls_u32.c     |    4 +++-
>  6 files changed, 25 insertions(+), 9 deletions(-)
> 
> --- a/include/net/pkt_cls.h	2010-08-06 11:51:18.903581556 -0700
> +++ b/include/net/pkt_cls.h	2010-08-06 12:20:02.072241508 -0700
> @@ -40,15 +40,21 @@ cls_set_class(struct tcf_proto *tp, unsi
>  	return old_cl;
>  }
>  
> -static inline void
> +static inline int
>  tcf_bind_filter(struct tcf_proto *tp, struct tcf_result *r, unsigned long base)
>  {
> +	const struct Qdisc_class_ops *cops = tp->q->ops->cl_ops;
>  	unsigned long cl;
>  
> -	cl = tp->q->ops->cl_ops->bind_tcf(tp->q, base, r->classid);
> +	if (!cops->bind_tcf)
> +		return -EINVAL;
> +
> +	cl = cops->bind_tcf(tp->q, base, r->classid);
>  	cl = cls_set_class(tp, &r->class, cl);
>  	if (cl)
> -		tp->q->ops->cl_ops->unbind_tcf(tp->q, cl);
> +		cops->unbind_tcf(tp->q, cl);
> +
> +	return 0;
>  }
>  
>  static inline void
> --- a/net/sched/cls_basic.c	2010-08-06 11:51:18.923582342 -0700
> +++ b/net/sched/cls_basic.c	2010-08-06 11:55:13.292553190 -0700
> @@ -153,7 +153,9 @@ static inline int basic_set_parms(struct
>  
>  	if (tb[TCA_BASIC_CLASSID]) {
>  		f->res.classid = nla_get_u32(tb[TCA_BASIC_CLASSID]);
> -		tcf_bind_filter(tp, &f->res, base);
> +		err = tcf_bind_filter(tp, &f->res, base);
> +		if (err)
> +			goto errout;
>  	}
>  
>  	tcf_exts_change(tp, &f->exts, &e);
> --- a/net/sched/cls_fw.c	2010-08-06 11:51:18.943583126 -0700
> +++ b/net/sched/cls_fw.c	2010-08-06 11:55:39.085476144 -0700
> @@ -206,10 +206,11 @@ fw_change_attrs(struct tcf_proto *tp, st
>  	if (err < 0)
>  		return err;
>  
> -	err = -EINVAL;
>  	if (tb[TCA_FW_CLASSID]) {
>  		f->res.classid = nla_get_u32(tb[TCA_FW_CLASSID]);
> -		tcf_bind_filter(tp, &f->res, base);
> +		err = tcf_bind_filter(tp, &f->res, base);
> +		if (err)
> +			goto errout;
>  	}
>  
>  #ifdef CONFIG_NET_CLS_IND
> @@ -220,6 +221,7 @@ fw_change_attrs(struct tcf_proto *tp, st
>  	}
>  #endif /* CONFIG_NET_CLS_IND */
>  
> +	err = -EINVAL;
>  	if (tb[TCA_FW_MASK]) {
>  		mask = nla_get_u32(tb[TCA_FW_MASK]);
>  		if (mask != head->mask)
> --- a/net/sched/cls_route.c	2010-08-06 11:51:18.959583757 -0700
> +++ b/net/sched/cls_route.c	2010-08-06 11:55:50.077870498 -0700
> @@ -412,7 +412,9 @@ static int route4_set_parms(struct tcf_p
>  
>  	if (tb[TCA_ROUTE4_CLASSID]) {
>  		f->res.classid = nla_get_u32(tb[TCA_ROUTE4_CLASSID]);
> -		tcf_bind_filter(tp, &f->res, base);
> +		err = tcf_bind_filter(tp, &f->res, base);
> +		if (err)
> +			goto errout;
>  	}
>  
>  	tcf_exts_change(tp, &f->exts, &e);
> --- a/net/sched/cls_tcindex.c	2010-08-06 11:51:18.999585326 -0700
> +++ b/net/sched/cls_tcindex.c	2010-08-06 11:56:01.486283847 -0700
> @@ -295,7 +295,9 @@ tcindex_set_parms(struct tcf_proto *tp, 
>  
>  	if (tb[TCA_TCINDEX_CLASSID]) {
>  		cr.res.classid = nla_get_u32(tb[TCA_TCINDEX_CLASSID]);
> -		tcf_bind_filter(tp, &cr.res, base);
> +		err = tcf_bind_filter(tp, &cr.res, base);
> +		if (err)
> +			goto errout;
>  	}
>  
>  	tcf_exts_change(tp, &cr.exts, &e);
> --- a/net/sched/cls_u32.c	2010-08-06 11:51:19.019586112 -0700
> +++ b/net/sched/cls_u32.c	2010-08-06 11:56:12.390678703 -0700
> @@ -528,7 +528,9 @@ static int u32_set_parms(struct tcf_prot
>  	}
>  	if (tb[TCA_U32_CLASSID]) {
>  		n->res.classid = nla_get_u32(tb[TCA_U32_CLASSID]);
> -		tcf_bind_filter(tp, &n->res, base);
> +		err = tcf_bind_filter(tp, &n->res, base);
> +		if (err)
> +			goto errout;
>  	}
>  
>  #ifdef CONFIG_NET_CLS_IND
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


