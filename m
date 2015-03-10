From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net] net_sched: fix struct tc_u_hnode layout in u32
Date: Mon, 09 Mar 2015 17:13:13 -0700
Message-ID: <1425946393.8261.24.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1425945820-9582-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.fastabend@gmail.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:42627 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751057AbbCJANP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 20:13:15 -0400
Received: by iecvy18 with SMTP id vy18so44100558iec.9
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 17:13:14 -0700 (PDT)
In-Reply-To: <1425945820-9582-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-03-09 at 17:03 -0700, Cong Wang wrote:
> We dynamically allocate divisor+1 entries for ->ht[] in tc_u_hnode:
> 
>   ht = kzalloc(sizeof(*ht) + divisor*sizeof(void *), GFP_KERNEL);
> 
> So ->ht is supposed to be the last field of this struct, however
> this is broken, since an rcu head is appended after it.
> 
> Fixes: 1ce87720d456 ("net: sched: make cls_u32 lockless")
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: John Fastabend <john.fastabend@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  net/sched/cls_u32.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
> index 09487af..95fdf4e 100644
> --- a/net/sched/cls_u32.c
> +++ b/net/sched/cls_u32.c
> @@ -78,8 +78,11 @@ struct tc_u_hnode {
>  	struct tc_u_common	*tp_c;
>  	int			refcnt;
>  	unsigned int		divisor;
> -	struct tc_u_knode __rcu	*ht[1];
>  	struct rcu_head		rcu;
> +	/* The 'ht' field MUST be the last field in structure to allow for
> +	 * more entries allocated at end of structure.
> +	 */
> +	struct tc_u_knode __rcu	*ht[1];
>  };

Good catch.

Definitely a call to make this a flexible array in net-next (ht[]), so
that compiler would have catch the bug.

Acked-by: Eric Dumazet <edumazet@google.com>
