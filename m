From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [patch net-next 2/3] net/sched: Change cls_flower to use IDR
Date: Mon, 28 Aug 2017 13:37:22 +0200
Message-ID: <20170828113721.GA14697@vergenet.net>
References: <1503902477-39829-1-git-send-email-chrism@mellanox.com>
 <1503902477-39829-3-git-send-email-chrism@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, davem@davemloft.net, mawilcox@microsoft.com
To: Chris Mi <chrism@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:35853 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751258AbdH1LhW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 07:37:22 -0400
Received: by mail-wm0-f54.google.com with SMTP id b82so1604922wmd.1
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 04:37:21 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1503902477-39829-3-git-send-email-chrism@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 28, 2017 at 02:41:16AM -0400, Chris Mi wrote:
> Currently, all filters with the same priority are linked in a doubly
> linked list. Every filter should have a unique handle. To make the
> handle unique, we need to iterate the list every time to see if the
> handle exists or not when inserting a new filter. It is time-consuming.
> For example, it takes about 5m3.169s to insert 64K rules.
> 
> This patch changes cls_flower to use IDR. With this patch, it
> takes about 0m1.127s to insert 64K rules. The improvement is huge.

Very nice :)

> But please note that in this testing, all filters share the same action.
> If every filter has a unique action, that is another bottleneck.
> Follow-up patch in this patchset addresses that.
> 
> Signed-off-by: Chris Mi <chrism@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  net/sched/cls_flower.c | 55 +++++++++++++++++++++-----------------------------
>  1 file changed, 23 insertions(+), 32 deletions(-)
> 
> diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
> index bd9dab4..3d041d2 100644
> --- a/net/sched/cls_flower.c
> +++ b/net/sched/cls_flower.c

...

> @@ -890,6 +870,7 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
>  	struct cls_fl_filter *fnew;
>  	struct nlattr **tb;
>  	struct fl_flow_mask mask = {};
> +	unsigned long idr_index;
>  	int err;
>  
>  	if (!tca[TCA_OPTIONS])
> @@ -920,13 +901,21 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
>  		goto errout;
>  
>  	if (!handle) {
> -		handle = fl_grab_new_handle(tp, head);
> -		if (!handle) {
> -			err = -EINVAL;
> +		err = idr_alloc_ext(&head->handle_idr, fnew, &idr_index,
> +				    1, 0x80000000, GFP_KERNEL);
> +		if (err)
>  			goto errout;
> -		}
> +		fnew->handle = idr_index;
> +	}
> +
> +	/* user specifies a handle and it doesn't exist */
> +	if (handle && !fold) {
> +		err = idr_alloc_ext(&head->handle_idr, fnew, &idr_index,
> +				    handle, handle + 1, GFP_KERNEL);
> +		if (err)
> +			goto errout;
> +		fnew->handle = idr_index;
>  	}
> -	fnew->handle = handle;
>  
>  	if (tb[TCA_FLOWER_FLAGS]) {
>  		fnew->flags = nla_get_u32(tb[TCA_FLOWER_FLAGS]);
> @@ -980,6 +969,8 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
>  	*arg = fnew;
>  
>  	if (fold) {
> +		fnew->handle = handle;

Can it be the case that fold is non-NULL and handle is zero?
The handling of that case seem to have changed in this patch.

> +		idr_replace_ext(&head->handle_idr, fnew, fnew->handle);
>  		list_replace_rcu(&fold->list, &fnew->list);
>  		tcf_unbind_filter(tp, &fold->res);
>  		call_rcu(&fold->rcu, fl_destroy_filter);
> -- 
> 1.8.3.1
> 
