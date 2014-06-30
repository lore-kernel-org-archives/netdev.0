From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net V1 1/3] net/mlx4_en: Don't use irq_affinity_notifier
 to track changes in IRQ affinity map
Date: Sun, 29 Jun 2014 23:41:51 -0700
Message-ID: <1404110511.15139.44.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1404032097-5132-1-git-send-email-amirv@mellanox.com>
	 <1404032097-5132-2-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ben Hutchings <ben@decadent.org.uk>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:45966 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754488AbaF3Gl4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2014 02:41:56 -0400
Received: by mail-wg0-f51.google.com with SMTP id x12so7440514wgg.34
        for <netdev@vger.kernel.org>; Sun, 29 Jun 2014 23:41:55 -0700 (PDT)
In-Reply-To: <1404032097-5132-2-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-06-29 at 11:54 +0300, Amir Vadai wrote:
> IRQ affinity notifier can only have a single notifier - cpu_rmap
> notifier. Can't use it to track changes in IRQ affinity map.
> Detect IRQ affinity changes by comparing CPU to current IRQ affinity map
> during NAPI poll thread.

...

> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> index 8be7483..ac3dead 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> @@ -474,15 +474,9 @@ int mlx4_en_poll_tx_cq(struct napi_struct *napi, int budget)
>  	/* If we used up all the quota - we're probably not done yet... */
>  	if (done < budget) {
>  		/* Done for now */
> -		cq->mcq.irq_affinity_change = false;
>  		napi_complete(napi);
>  		mlx4_en_arm_cq(priv, cq);
>  		return done;
> -	} else if (unlikely(cq->mcq.irq_affinity_change)) {
> -		cq->mcq.irq_affinity_change = false;
> -		napi_complete(napi);
> -		mlx4_en_arm_cq(priv, cq);
> -		return 0;
>  	}
>  	return budget;
>  }

It seems nothing is done then for the TX side after this patch ?

You might want to drain whole queue instead of limiting to a 'budget',
otherwise, a cpu might be stuck servicing (soft)irq for the TX
completion, even if irq affinities say otherwise.
