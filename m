From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v4 12/16] net: sched: rcu'ify cls_bpf
Date: Wed, 10 Sep 2014 19:28:01 -0700
Message-ID: <1410402481.7106.51.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140910154517.2036.53084.stgit@nitbit.x32>
	 <20140910155141.2036.66048.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, davem@davemloft.net, jhs@mojatatu.com,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:41466 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751865AbaIKC2D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 22:28:03 -0400
Received: by mail-pa0-f49.google.com with SMTP id lf10so6878199pab.8
        for <netdev@vger.kernel.org>; Wed, 10 Sep 2014 19:28:03 -0700 (PDT)
In-Reply-To: <20140910155141.2036.66048.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-09-10 at 08:51 -0700, John Fastabend wrote:
> This patch makes the cls_bpf classifier RCU safe. The tcf_lock
> was being used to protect a list of cls_bpf_prog now this list
> is RCU safe and updates occur with rcu_replace.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

...

> @@ -256,18 +254,19 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
>  	if (ret < 0)
>  		return ret;
>  
> -	if (prog != NULL) {
> -		if (handle && prog->handle != handle)
> -			return -EINVAL;
> -		return cls_bpf_modify_existing(net, tp, prog, base, tb,
> -					       tca[TCA_RATE], ovr);
> -	}
> -
>  	prog = kzalloc(sizeof(*prog), GFP_KERNEL);
> -	if (prog == NULL)
> +	if (!prog)
>  		return -ENOBUFS;
>  
>  	tcf_exts_init(&prog->exts, TCA_BPF_ACT, TCA_BPF_POLICE);
> +
> +	if (oldprog) {
> +		if (handle && oldprog->handle != handle) {
> +			ret = -EINVAL;
> +			goto errout;
> +		}
> +	}
> +
>  	if (handle == 0)
>  		prog->handle = cls_bpf_grab_new_handle(tp, head);
>  	else
> @@ -281,15 +280,17 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
>  	if (ret < 0)
>  		goto errout;
>  
> -	tcf_tree_lock(tp);
> -	list_add(&prog->link, &head->plist);
> -	tcf_tree_unlock(tp);
> +	if (oldprog) {
> +		list_replace_rcu(&prog->link, &oldprog->link);
> +		call_rcu(&oldprog->rcu, __cls_bpf_delete_prog);
> +	} else {
> +		list_add_rcu(&prog->link, &head->plist);
> +	}
>  
>  	*arg = (unsigned long) prog;
> -
>  	return 0;
>  errout:
> -	if (*arg == 0UL && prog)
> +	if (prog)
>  		kfree(prog);
>  

nit, you can directly call kfree(prog) even if prog == NULL
