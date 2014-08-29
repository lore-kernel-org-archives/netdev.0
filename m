From: Prashant Sreedharan <prashant@broadcom.com>
Subject: Re: [PATCH net v4 4/4] tg3: Fix tx_pending checks for tg3_tso_bug
Date: Thu, 28 Aug 2014 20:24:28 -0700
Message-ID: <1409282668.12635.21.camel@prashant>
References: <1409187858-7698-1-git-send-email-bpoirier@suse.de>
	 <1409187858-7698-4-git-send-email-bpoirier@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Benjamin Poirier <bpoirier@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:41621 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751578AbaH2DdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2014 23:33:16 -0400
In-Reply-To: <1409187858-7698-4-git-send-email-bpoirier@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>  
> -	for (i = 0; i < tp->irq_max; i++)
> -		tp->napi[i].tx_pending = ering->tx_pending;
> +	dev->gso_max_segs = TG3_TX_SEG_PER_DESC(ering->tx_pending - 1);
> +	for (i = 0; i < tp->irq_max; i++) {
> +		struct tg3_napi *tnapi = &tp->napi[i];
> +
> +		tnapi->tx_pending = ering->tx_pending;
> +		if (netif_tx_queue_stopped(netdev_get_tx_queue(dev, i)) &&

Need to limit the number of TX queues to tp->txq_cnt instead of
tp->irq_max as txq_cnt can be less than irq_max.

netif_set_real_num_tx_queues(tp->dev, tp->txq_cnt);

> +		    tnapi->wakeup_thresh >= ering->tx_pending)
> +			tnapi->wakeup_thresh = MAX_SKB_FRAGS + 1;
> +	}
>  
