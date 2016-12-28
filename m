From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: dev_weight: TX/RX orthogonality
Date: Wed, 28 Dec 2016 14:17:51 -0500 (EST)
Message-ID: <20161228.141751.81302085672323860.davem@davemloft.net>
References: <20161227164758.GA10870@localhost.localdomain>
        <1482918134-10483-1-git-send-email-matthias.tafelmeier@gmx.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hagen@jauu.net, fw@strlen.de,
        edumazet@google.com, daniel@iogearbox.net
To: matthias.tafelmeier@gmx.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43972 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751906AbcL1TR4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2016 14:17:56 -0500
In-Reply-To: <1482918134-10483-1-git-send-email-matthias.tafelmeier@gmx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Date: Wed, 28 Dec 2016 10:42:14 +0100

> @@ -3428,6 +3428,8 @@ EXPORT_SYMBOL(netdev_max_backlog);
>  int netdev_tstamp_prequeue __read_mostly = 1;
>  int netdev_budget __read_mostly = 300;
>  int weight_p __read_mostly = 64;            /* old backlog weight */
> +int dev_weight_rx_bias __read_mostly = 1;            /* bias for backlog weight */
> +int dev_weight_tx_bias __read_mostly = 1;            /* bias for output_queue quota */
>  
>  /* Called with irq disabled */
>  static inline void ____napi_schedule(struct softnet_data *sd,
> @@ -4833,7 +4835,7 @@ static int process_backlog(struct napi_struct *napi, int quota)
>  		net_rps_action_and_irq_enable(sd);
>  	}
>  
> -	napi->weight = weight_p;
> +	napi->weight = weight_p * dev_weight_rx_bias;
>  	while (again) {
>  		struct sk_buff *skb;
>  
 ...
> @@ -247,7 +247,7 @@ static inline int qdisc_restart(struct Qdisc *q, int *packets)
>  
>  void __qdisc_run(struct Qdisc *q)
>  {
> -	int quota = weight_p;
> +	int quota = weight_p * dev_weight_tx_bias;

Ok, this is a lot better than what you proposed initially.

However, being that this is the fast path for all packet processing,
introducing a multiply here doesn't sit well.

I think there are two possible ways to address this:

1) Make the bias instead be a "shift".

2) Precompute the dev_tx_weight and dev_rx_weight into two variables
   in net/core/dev.c  Install a special proc_dointvec handler for
   "dev_weight" that, upon proc_dointvec() success, updates both
   dev_tx_weight and dev_rx_weight based upon the bias settings.
