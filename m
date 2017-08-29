From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net-next 1/3] idr: Add new APIs to support unsigned long
Date: Tue, 29 Aug 2017 09:14:04 +0200
Message-ID: <87y3q27sn7.fsf@stressinduktion.org>
References: <1503902477-39829-1-git-send-email-chrism@mellanox.com>
        <1503902477-39829-2-git-send-email-chrism@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, davem@davemloft.net, mawilcox@microsoft.com
To: Chris Mi <chrism@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:55049 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751219AbdH2HOI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 03:14:08 -0400
In-Reply-To: <1503902477-39829-2-git-send-email-chrism@mellanox.com> (Chris
        Mi's message of "Mon, 28 Aug 2017 02:41:15 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Chris Mi <chrism@mellanox.com> writes:

> The following new APIs are added:
>
> int idr_alloc_ext(struct idr *idr, void *ptr, unsigned long *index,
>                   unsigned long start, unsigned long end, gfp_t gfp);
> static inline void *idr_remove_ext(struct idr *idr, unsigned long id);
> static inline void *idr_find_ext(const struct idr *idr, unsigned long id);
> void *idr_replace_ext(struct idr *idr, void *ptr, unsigned long id);
> void *idr_get_next_ext(struct idr *idr, unsigned long *nextid);
>
> Signed-off-by: Chris Mi <chrism@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  include/linux/idr.h        | 16 ++++++++++
>  include/linux/radix-tree.h |  3 ++
>  lib/idr.c                  | 56 +++++++++++++++++++++++++++++++++++
>  lib/radix-tree.c           | 73 ++++++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 148 insertions(+)
>

[...]

> +int idr_alloc_ext(struct idr *idr, void *ptr, unsigned long *index,
> +		  unsigned long start, unsigned long end, gfp_t gfp)
> +{
> +	void __rcu **slot;
> +	struct radix_tree_iter iter;
> +
> +	if (WARN_ON_ONCE(radix_tree_is_internal_node(ptr)))
> +		return -EINVAL;
> +
> +	radix_tree_iter_init(&iter, start);
> +	slot = idr_get_free_ext(&idr->idr_rt, &iter, gfp, end);
> +	if (IS_ERR(slot))
> +		return PTR_ERR(slot);
> +
> +	radix_tree_iter_replace(&idr->idr_rt, &iter, slot, ptr);
> +	radix_tree_iter_tag_clear(&idr->idr_rt, &iter, IDR_FREE);
> +
> +	if (index)
> +		*index = iter.index;
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(idr_alloc_ext);

Can you express idr_alloc in terms of idr_alloc_ext? Same for most of
the other functions (it seems that signed int was used as return value
to indicate error cases, thus it should be easy to map those).

[...]

Thanks,
Hannes
