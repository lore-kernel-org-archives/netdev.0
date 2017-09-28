From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [Patch net-next] net_sched: use idr to allocate u32 filter
 handles
Date: Thu, 28 Sep 2017 09:34:24 +0200
Message-ID: <20170928073423.GB15815@netronome.com>
References: <20170921234302.26558-3-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Chris Mi <chrism@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:50900 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751060AbdI1He1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 03:34:27 -0400
Received: by mail-wm0-f42.google.com with SMTP id u138so288670wmu.5
        for <netdev@vger.kernel.org>; Thu, 28 Sep 2017 00:34:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170921234302.26558-3-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 21, 2017 at 04:43:02PM -0700, Cong Wang wrote:
> Cc: Chris Mi <chrism@mellanox.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Hi Cong,

this looks like a nice enhancement to me. Did you measure any performance
benefit from it.  Perhaps it could be described in the changelog_ I also
have a more detailed question below.

> ---
>  net/sched/cls_u32.c | 108 ++++++++++++++++++++++++++++++++--------------------
>  1 file changed, 67 insertions(+), 41 deletions(-)
> 
> diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
> index 10b8d851fc6b..316b8a791b13 100644
> --- a/net/sched/cls_u32.c
> +++ b/net/sched/cls_u32.c
> @@ -46,6 +46,7 @@

...

> @@ -937,22 +940,33 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
>  			return -EINVAL;
>  		if (TC_U32_KEY(handle))
>  			return -EINVAL;
> -		if (handle == 0) {
> -			handle = gen_new_htid(tp->data);
> -			if (handle == 0)
> -				return -ENOMEM;
> -		}
>  		ht = kzalloc(sizeof(*ht) + divisor*sizeof(void *), GFP_KERNEL);
>  		if (ht == NULL)
>  			return -ENOBUFS;
> +		if (handle == 0) {
> +			handle = gen_new_htid(tp->data, ht);
> +			if (handle == 0) {
> +				kfree(ht);
> +				return -ENOMEM;
> +			}
> +		} else {
> +			err = idr_alloc_ext(&tp_c->handle_idr, ht, NULL,
> +					    handle, handle + 1, GFP_KERNEL);
> +			if (err) {
> +				kfree(ht);
> +				return err;
> +			}

The above seems to check that handle is not already in use and mark it as
in use. But I don't see that logic in the code prior to this patch.
Am I missing something? If not perhaps this portion should be a separate
patch or described in the changelog.

> +		}
>  		ht->tp_c = tp_c;
>  		ht->refcnt = 1;
>  		ht->divisor = divisor;
>  		ht->handle = handle;
>  		ht->prio = tp->prio;
> +		idr_init(&ht->handle_idr);
>  
>  		err = u32_replace_hw_hnode(tp, ht, flags);
>  		if (err) {
> +			idr_remove_ext(&tp_c->handle_idr, handle);
>  			kfree(ht);
>  			return err;
>  		}

...
