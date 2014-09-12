From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v5 13/16] net: sched: make tc_action safe to
 walk under RCU
Date: Fri, 12 Sep 2014 13:51:54 -0700
Message-ID: <1410555114.7106.101.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140912162748.19588.39677.stgit@nitbit.x32>
	 <20140912163403.19588.26443.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, davem@davemloft.net, jhs@mojatatu.com,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:61552 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751530AbaILUvz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 16:51:55 -0400
Received: by mail-pa0-f54.google.com with SMTP id lj1so2071505pab.13
        for <netdev@vger.kernel.org>; Fri, 12 Sep 2014 13:51:55 -0700 (PDT)
In-Reply-To: <20140912163403.19588.26443.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-09-12 at 09:34 -0700, John Fastabend wrote:

> Second there is a suspect usage of list_splice_init_rcu() in the
> tcf_exts_change() routine. Notice how it is used twice in succession
> and the second init works on the src tcf_exts. There is probably a
> better way to accomplish that.
> 


> +/* It is not safe to use src->actions after this due to _init_rcu usage
> + * INIT_LIST_HEAD_RCU() is called on src->actions
> + */
>  void tcf_exts_change(struct tcf_proto *tp, struct tcf_exts *dst,
>  		     struct tcf_exts *src)
>  {
>  #ifdef CONFIG_NET_CLS_ACT
>  	LIST_HEAD(tmp);
> -	tcf_tree_lock(tp);
> -	list_splice_init(&dst->actions, &tmp);
> -	list_splice(&src->actions, &dst->actions);
> -	tcf_tree_unlock(tp);
> +	list_splice_init_rcu(&dst->actions, &tmp, synchronize_rcu);
> +	list_splice_init_rcu(&src->actions,
> +			     &dst->actions,
> +			     synchronize_rcu);
>  	tcf_action_destroy(&tmp, TCA_ACT_UNBIND);
>  #endif
>  }

I am afraid I do not understand this part.
