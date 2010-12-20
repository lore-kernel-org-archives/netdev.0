From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next-2.6 PATCH 2/4] net_sched: Allow multiple mq qdisc to
 be used as non-root
Date: Mon, 20 Dec 2010 23:12:42 +0000
Message-ID: <1292886762.3055.38.camel@bwh-desktop>
References: <20101217153439.12170.39538.stgit@jf-dev1-dcblab>
	 <20101217153445.12170.73420.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, hadi@cyberus.ca,
	shemminger@vyatta.com, tgraf@infradead.org, eric.dumazet@gmail.com,
	nhorman@tuxdriver.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:9655 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933135Ab0LTXMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 18:12:47 -0500
In-Reply-To: <20101217153445.12170.73420.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-12-17 at 07:34 -0800, John Fastabend wrote:
[...]
> diff --git a/net/sched/sch_mq.c b/net/sched/sch_mq.c
> index ecc302f..35ed26d 100644
> --- a/net/sched/sch_mq.c
> +++ b/net/sched/sch_mq.c
> @@ -19,17 +19,39 @@
>  
>  struct mq_sched {
>  	struct Qdisc		**qdiscs;
> +	u8 num_tc;
>  };
>  
> +static void mq_queues(struct net_device *dev, struct Qdisc *sch,
> +		      unsigned int *count, unsigned int *offset)
> +{
> +	struct mq_sched *priv = qdisc_priv(sch);
> +	if (priv->num_tc) {
> +		int queue = TC_H_MIN(sch->parent) - 1;
> +		if (count)
> +			*count = dev->tc_to_txq[queue].count;
> +		if (offset)
> +			*offset = dev->tc_to_txq[queue].offset;
> +	} else {
> +		if (count)
> +			*count = dev->num_tx_queues;
> +		if (offset)
> +			*offset = 0;
> +	}
> +}
[...]

It looks like num_tc will be set even for the root qdisc if the device
is capable of QoS.  Would mq_queues() behave correctly then, i.e. is the
queue range for priority 0 required to be [0, dev->num_tx_queues)?

Also it would be neater to return count and offset together as struct
netdev_tc_txq, rather than through optional out-parameters.  Even better
would be to cache these in struct mq_sched, if that's possible.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

