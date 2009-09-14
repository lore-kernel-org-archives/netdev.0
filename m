From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] pkt_sched: Fix tx queue selection in tc_modify_qdisc
Date: Mon, 14 Sep 2009 20:05:45 +0200
Message-ID: <4AAE85F9.2060600@trash.net>
References: <20090914122226.GA14087@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59518 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932192AbZINSFn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2009 14:05:43 -0400
In-Reply-To: <20090914122226.GA14087@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> After the recent mq change there is the new select_queue qdisc class
> method used in tc_modify_qdisc, but it works OK only for direct child
> qdiscs of mq qdisc. Grandchildren always get the first tx queue, which
> would give wrong qdisc_root etc. results (e.g. for sch_htb as child of
> sch_prio). This patch fixes it by using parent's dev_queue for such
> grandchildren qdiscs. The select_queue method is replaced BTW with the
> static qdisc_select_tx_queue function (it's used only in one place).

Thanks, this looks correct. My assumption was that we shouldn't
be using the locks of grandchildren anyways, but we do need the
proper root lock for estimators.

> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index 88eb9de..865120c 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -81,7 +81,6 @@ struct Qdisc
>  struct Qdisc_class_ops
>  {
>  	/* Child qdisc manipulation */
> -	unsigned int		(*select_queue)(struct Qdisc *, struct tcmsg *);
>  	int			(*graft)(struct Qdisc *, unsigned long cl,
>  					struct Qdisc *, struct Qdisc **);
>  	struct Qdisc *		(*leaf)(struct Qdisc *, unsigned long cl);
> diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
> index 3af1061..223a6bc 100644
> --- a/net/sched/sch_api.c
> +++ b/net/sched/sch_api.c
> @@ -990,6 +990,24 @@ static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
>  	return 0;
>  }
>  
> +static struct netdev_queue *qdisc_select_tx_queue(struct net_device *dev,
> +						  struct Qdisc *p, u32 clid)
> +{
> +	unsigned long ntx;
> +
> +	if (!p)
> +		return netdev_get_tx_queue(dev, 0);
> +
> +	if (!(p->flags & TCQ_F_MQROOT))
> +		return p->dev_queue;
> +
> +	ntx = TC_H_MIN(clid) - 1;

I didn't want to expose the numbering scheme used by sch_mq internally,
but fine, I see you really don't like the callback :)
