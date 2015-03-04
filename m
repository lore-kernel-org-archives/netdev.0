From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v1] mv643xx_eth: only account for work done in
 rxq_process in poll callback.
Date: Wed, 4 Mar 2015 22:32:35 +0100
Message-ID: <20150304213235.GA20596@electric-eye.fr.zoreil.com>
References: <1425492124-5033-1-git-send-email-nschichan@freebox.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicolas Schichan <nschichan@freebox.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1425492124-5033-1-git-send-email-nschichan@freebox.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nicolas Schichan <nschichan@freebox.fr> :
[...]
> diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
> index 1c75829..52bc56b 100644
> --- a/drivers/net/ethernet/marvell/mv643xx_eth.c
> +++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
[...]
> @@ -1050,7 +1049,7 @@ static int txq_reclaim(struct tx_queue *txq, int budget, int force)
>  	__netif_tx_lock_bh(nq);
>  
>  	reclaimed = 0;
> -	while (reclaimed < budget && txq->tx_desc_count > 0) {
> +	while (txq->tx_desc_count > 0) {
>  		int tx_index;
>  		struct tx_desc *desc;
>  		u32 cmd_sts;

You may use a local 'int count = txq->tx_desc_count' variable then
perform a single update at the end of the locked section. 
txq->tx_used_desc could be reworked in a similar way.

> @@ -1105,8 +1104,7 @@ static int txq_reclaim(struct tx_queue *txq, int budget, int force)
>  
>  	__netif_tx_unlock_bh(nq);
>  
> -	if (reclaimed < budget)
> -		mp->work_tx &= ~(1 << txq->index);
> +	mp->work_tx &= ~(1 << txq->index);
>  
>  	return reclaimed;
>  }

work_tx is also updated in irq context. I'd rather see "clear_flag() then
reclaim()" than "reclaim() then clear_flag()" in a subsequent patch.

-- 
Ueimor
