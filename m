From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [Patch net-next v2] net_sched: use idr to allocate bpf filter
 handles
Date: Mon, 25 Sep 2017 23:16:52 +0200
Message-ID: <59C97244.30301@iogearbox.net>
References: <20170925171351.4956-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chris Mi <chrism@mellanox.com>, Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:49828 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932182AbdIYVQz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 17:16:55 -0400
In-Reply-To: <20170925171351.4956-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/25/2017 07:13 PM, Cong Wang wrote:
> Instead of calling cls_bpf_get() in a loop to find
> a unused handle, just switch to idr API to allocate
> new handles.
>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Chris Mi <chrism@mellanox.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
[...]
> @@ -476,21 +462,30 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
>   		}
>   	}
>
> -	if (handle == 0)
> -		prog->handle = cls_bpf_grab_new_handle(tp, head);
> -	else
> +	if (handle == 0) {
> +		ret = idr_alloc_ext(&head->handle_idr, prog, &idr_index,
> +				    1, 0x7FFFFFFF, GFP_KERNEL);
> +		if (ret)
> +			goto errout;
> +		prog->handle = idr_index;
> +	} else {
> +		if (!oldprog) {
> +			ret = idr_alloc_ext(&head->handle_idr, prog, &idr_index,
> +					    handle, handle + 1, GFP_KERNEL);
> +			if (ret)
> +				goto errout;
> +		}
>   		prog->handle = handle;
> -	if (prog->handle == 0) {
> -		ret = -EINVAL;
> -		goto errout;
>   	}
>
>   	ret = cls_bpf_set_parms(net, tp, prog, base, tb, tca[TCA_RATE], ovr);
>   	if (ret < 0)
> -		goto errout;
> +		goto errout_idr;
>
>   	ret = cls_bpf_offload(tp, prog, oldprog);
>   	if (ret) {
> +		if (!oldprog)
> +			idr_remove_ext(&head->handle_idr, prog->handle);

Shouldn't we also call idr_remove_ext() when there was an
oldprog, but we didn't care about reusing the same handle,
so it was handle == 0 initially?

There's this condition in the code before above idr allocations,
I think also in other classifiers:

         if (oldprog) {
                 if (handle && oldprog->handle != handle) {
                         ret = -EINVAL;
                         goto errout;
                 }
         }

>   		__cls_bpf_delete_prog(prog);
>   		return ret;
>   	}
> @@ -499,6 +494,7 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
>   		prog->gen_flags |= TCA_CLS_FLAGS_NOT_IN_HW;
>
>   	if (oldprog) {
> +		idr_replace_ext(&head->handle_idr, prog, handle);

And here, we should probably use prog->handle for the above
mentioned case as well, no?

Would be great if all this (and e.g. the fact that we use idr itself)
could optionally be hidden behind some handle generator api given
we could reuse that api also for cls_basic and cls_u32. Could also
be followed-up perhaps.

>   		list_replace_rcu(&oldprog->link, &prog->link);
>   		tcf_unbind_filter(tp, &oldprog->res);
>   		call_rcu(&oldprog->rcu, cls_bpf_delete_prog_rcu);
> @@ -509,6 +505,9 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
>   	*arg = prog;
>   	return 0;
>
> +errout_idr:
> +	if (!oldprog)
> +		idr_remove_ext(&head->handle_idr, prog->handle);

(Likewise as the failing cls_bpf_offload().)

>   errout:
>   	tcf_exts_destroy(&prog->exts);
>   	kfree(prog);
>
