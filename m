From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mvpp2: fix dma unmapping of TX buffers for
 fragments
Date: Sat, 17 Dec 2016 10:20:57 -0500 (EST)
Message-ID: <20161217.102057.1497114610120684110.davem@davemloft.net>
References: <1481647995-7213-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        jason@lakedaemon.net, andrew@lunn.ch,
        sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com, mw@semihalf.com,
        stefanc@marvell.com, nadavh@marvell.com, hannah@marvell.com,
        yehuday@marvell.com, raphael.glon@corp.ovh.com,
        stable@vger.kernel.org
To: thomas.petazzoni@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40360 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752602AbcLQPVE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2016 10:21:04 -0500
In-Reply-To: <1481647995-7213-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Date: Tue, 13 Dec 2016 17:53:15 +0100

> diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
> index 1026c45..d168b13 100644
> --- a/drivers/net/ethernet/marvell/mvpp2.c
> +++ b/drivers/net/ethernet/marvell/mvpp2.c
> @@ -791,6 +791,8 @@ struct mvpp2_txq_pcpu {
>  	/* Array of transmitted buffers' physical addresses */
>  	dma_addr_t *tx_buffs;
>  
> +	size_t *tx_data_size;
> +

You're really destroying cache locality, and making things overly
complicated, by having two arrays.  Actually this is now the third in
this structure alone.  That's crazy.

Just have one array for the TX ring software state:

struct tx_buff_info {
	struct sk_buff	*skb;
	dma_addr_t	dma_addr;
	unsigned int	size;
};

Then in the per-cpu TX struct:

	struct tx_buff_info	*info;

This way every data access by the cpu for processing a ring entry
will be localized, increasing cache hit rates.

This also significantly simplifies the code that allocates and
frees this memory.
