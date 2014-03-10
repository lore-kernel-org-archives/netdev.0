From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RCU PATCH 05/14] net: sched: cls_flow use RCU
Date: Mon, 10 Mar 2014 10:38:17 -0700
Message-ID: <1394473097.3607.43.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140310170008.3011.73599.stgit@nitbit.x32>
	 <20140310170518.3011.10518.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:53220 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751689AbaCJRiU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 13:38:20 -0400
Received: by mail-pd0-f177.google.com with SMTP id g10so7252897pdj.8
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 10:38:19 -0700 (PDT)
In-Reply-To: <20140310170518.3011.10518.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-10 at 10:05 -0700, John Fastabend wrote:

>  static void flow_destroy(struct tcf_proto *tp)
>  {
> -	struct flow_head *head = tp->root;
> +	struct flow_head *head = rtnl_dereference(tp->root);
>  	struct flow_filter *f, *next;
>  
>  	list_for_each_entry_safe(f, next, &head->filters, list) {
> -		list_del(&f->list);
> -		flow_destroy_filter(tp, f);
> +		list_del_rcu(&f->list);
> +		call_rcu(&f->rcu, flow_destroy_filter);
>  	}
> -	kfree(head);
> +	rcu_assign_pointer(tp->root, NULL);

RCU_INIT_POINTER()

> +	kfree_rcu(head, rcu);
>  }
>  

Otherwise, SGTM, thanks !
