From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net] net_sched: invoke ->attach() after setting
 dev->qdisc
Date: Tue, 26 May 2015 18:57:54 -0700
Message-ID: <1432691874.4060.321.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1432681729-1295-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:33098 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752203AbbE0B55 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 21:57:57 -0400
Received: by iebgx4 with SMTP id gx4so3259939ieb.0
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 18:57:57 -0700 (PDT)
In-Reply-To: <1432681729-1295-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-05-26 at 16:08 -0700, Cong Wang wrote:
> For mq qdisc, we add per tx queue qdisc to root qdisc
> for display purpose, however, that happens too early,
> before the new dev->qdisc is finally set, this causes
> q->list points to an old root qdisc which is going to be
> freed right before assigning with a new one.
> 
> Fix this by moving ->attach() after setting dev->qdisc.
> 
> For the record, this fixes the following crash:
...

> For long term, we probably need to clean up the qdisc_graft() code
> in case it hides other bugs like this.
> 
> Fixes: 95dc19299f74 ("pkt_sched: give visibility to mq slave qdiscs")
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  net/sched/sch_api.c | 10 ++++++----
>  1 file changed, 6 insertions(+), 4 deletions(-)
> 
> diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
> index ad9eed7..1e1c89e 100644
> --- a/net/sched/sch_api.c
> +++ b/net/sched/sch_api.c
> @@ -815,10 +815,8 @@ static int qdisc_graft(struct net_device *dev, struct Qdisc *parent,
>  		if (dev->flags & IFF_UP)
>  			dev_deactivate(dev);
>  
> -		if (new && new->ops->attach) {
> -			new->ops->attach(new);
> -			num_q = 0;
> -		}
> +		if (new && new->ops->attach)
> +			goto skip;
>  
>  		for (i = 0; i < num_q; i++) {
>  			struct netdev_queue *dev_queue = dev_ingress_queue(dev);
> @@ -834,12 +832,16 @@ static int qdisc_graft(struct net_device *dev, struct Qdisc *parent,
>  				qdisc_destroy(old);
>  		}
>  
> +skip:
>  		if (!ingress) {
>  			notify_and_destroy(net, skb, n, classid,
>  					   dev->qdisc, new);
>  			if (new && !new->ops->attach)
>  				atomic_inc(&new->refcnt);
>  			dev->qdisc = new ? : &noop_qdisc;
> +
> +			if (new && new->ops->attach)
> +				new->ops->attach(new);
>  		} else {
>  			notify_and_destroy(net, skb, n, classid, old, new);
>  		}

Good catch !

Please CC author of a buggy patch, always interesting to learn from our
mistakes. ;)

Note that attach() method is called with the 'new' qdisc,
we might pass this parameter up to qdisc_list_add()

Conceptually, setting dev->qdisc before attach() seems a bit awkward,
but given that attach() returns void, we did not planned having an error
path anyway.

No strong feeling here, I think your patch is fine as is.

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks a lot.
