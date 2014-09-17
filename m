From: Cong Wang <cwang@twopensource.com>
Subject: Re: [net-next PATCH 2/2] net: sched: cls_u32 changes to knode must
 appear atomic to readers
Date: Wed, 17 Sep 2014 14:11:22 -0700
Message-ID: <CAHA+R7NWzv8+2aUM1uQX8uZkQv-Dp9fYb0SNwmZqk3gKvXVWtw@mail.gmail.com>
References: <20140917191131.20529.91136.stgit@nitbit.x32>
	<20140917191202.20529.87231.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:39311 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756245AbaIQVLY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 17:11:24 -0400
Received: by mail-la0-f42.google.com with SMTP id hz20so2717738lab.15
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 14:11:22 -0700 (PDT)
In-Reply-To: <20140917191202.20529.87231.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 17, 2014 at 12:12 PM, John Fastabend
<john.fastabend@gmail.com> wrote:
>
> -static int u32_destroy_key(struct tcf_proto *tp, struct tc_u_knode *n)
> +static int u32_destroy_key(struct tcf_proto *tp, struct tc_u_knode *n, bool pf)
>  {
>         tcf_unbind_filter(tp, &n->res);
>         tcf_exts_destroy(tp, &n->exts);
>         if (n->ht_down)
>                 n->ht_down->refcnt--;
>  #ifdef CONFIG_CLS_U32_PERF
> -       free_percpu(n->pf);
> +       if (pf)

Nit: 'free_pf' is a better name than just 'pf'.

> +               free_percpu(n->pf);
>  #endif
>  #ifdef CONFIG_CLS_U32_MARK
> -       free_percpu(n->pcpu_success);
> +       if (pf)
> +               free_percpu(n->pcpu_success);
>  #endif
>         kfree(n);
>         return 0;
>  }
>
> +static void u32_delete_key_rcu_pf(struct rcu_head *rcu)
> +{
> +       struct tc_u_knode *key = container_of(rcu, struct tc_u_knode, rcu);
> +
> +       u32_destroy_key(key->tp, key, false);
> +}

I think you need a comment here to explain why you free it partially
on purpose, it is not that clear, at least I spent some time to figure
it out when I read your cls_tcindex patch.

Thanks!
