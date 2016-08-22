From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next] net_sched: properly handle failure case of
 tcf_exts_init()
Date: Mon, 22 Aug 2016 08:06:03 -0400
Message-ID: <78193bfb-33c4-4dc7-fdd9-18bb3d1084ce@mojatatu.com>
References: <1471635414-32433-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35170 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755136AbcHVMG0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 08:06:26 -0400
Received: by mail-it0-f68.google.com with SMTP id f6so4647275ith.2
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 05:06:26 -0700 (PDT)
In-Reply-To: <1471635414-32433-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Just small comment below:

On 16-08-19 03:36 PM, Cong Wang wrote:
> diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
> index 944c8ff..d950070 100644
> --- a/net/sched/cls_tcindex.c
> +++ b/net/sched/cls_tcindex.c
> @@ -219,10 +219,10 @@ static const struct nla_policy tcindex_policy[TCA_TCINDEX_MAX + 1] = {
>  	[TCA_TCINDEX_CLASSID]		= { .type = NLA_U32 },
>  };
>
> -static void tcindex_filter_result_init(struct tcindex_filter_result *r)
> +static int tcindex_filter_result_init(struct tcindex_filter_result *r)
>  {
>  	memset(r, 0, sizeof(*r));
> -	tcf_exts_init(&r->exts, TCA_TCINDEX_ACT, TCA_TCINDEX_POLICE);
> +	return tcf_exts_init(&r->exts, TCA_TCINDEX_ACT, TCA_TCINDEX_POLICE);
>  }
>
>  static void __tcindex_partial_destroy(struct rcu_head *head)
> @@ -233,23 +233,57 @@ static void __tcindex_partial_destroy(struct rcu_head *head)
>  	kfree(p);
>  }
>
> +static void tcindex_free_perfect_hash(struct tcindex_data *cp)
> +{
> +	int i;
> +
> +	for (i = 0; i < cp->hash; i++)
> +		tcf_exts_destroy(&cp->perfect[i].exts);
> +	kfree(cp->perfect);
> +}
> +
> +static int tcindex_alloc_perfect_hash(struct tcindex_data *cp)
> +{
> +	int i, err = 0;
> +
> +	cp->perfect = kcalloc(cp->hash, sizeof(struct tcindex_filter_result),
> +			      GFP_KERNEL);
> +	if (!cp->perfect)
> +		return -ENOMEM;
> +
> +	for (i = 0; i < cp->hash; i++) {
> +		err = tcf_exts_init(&cp->perfect[i].exts,
> +				    TCA_TCINDEX_ACT, TCA_TCINDEX_POLICE);
> +		if (err < 0)
> +			goto errout;
> +	}
> +
> +	return 0;
> +
> +errout:
> +	tcindex_free_perfect_hash(cp);
> +	return err;
> +}
> +


If you fail tcindex_alloc_perfect_hash somewhere freeing actions in
tcindex_free_perfect_hash() via tcf_exts_destroy require checking
if exts->actions require a check?

Otherwise, looks good.

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
