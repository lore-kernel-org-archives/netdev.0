From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/6 net-next-2.6] vxge: Use fifo based trans_start time
Date: Thu, 08 Jul 2010 23:34:14 -0700 (PDT)
Message-ID: <20100708.233414.116369101.davem@davemloft.net>
References: <20100708192125.GB15167@exar.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sreenivasa.honnur@exar.com,
	ram.vepa@exar.com
To: jon.mason@exar.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45336
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751333Ab0GIGeB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 02:34:01 -0400
In-Reply-To: <20100708192125.GB15167@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Mason <jon.mason@exar.com>
Date: Thu, 8 Jul 2010 14:21:26 -0500

> @@ -968,8 +969,10 @@ vxge_xmit(struct sk_buff *skb, struct net_device *dev)
>  					VXGE_HW_FIFO_TXD_TX_CKO_UDP_EN);
>  
>  	vxge_hw_fifo_txdl_post(fifo_hw, dtr);
> +
>  #ifdef NETIF_F_LLTX
> -	dev->trans_start = jiffies; /* NETIF_F_LLTX driver :( */
> +	txq = netdev_get_tx_queue(dev, vpath_no);
> +	txq->trans_start = jiffies;
>  #endif

This comment was placed there not just for it's artistic value,
you should heed what it's saying when making changes like this.

NETIF_F_LLTX drivers cannot use the per-txq trans_start mechanism,
because doing so is racy.

The dev_watchdog() timer, which checks these ->trans_start values,
can only synchornize with the driver by the traditional means,
which is by taking the spinlock on the TX queue.  This is bypassed
by NETIF_F_LLTX drivers, so the driver can be in it's TX handler
while the watchdog timer is trying to evaluate the trans_start
state.

This is one of a many reasons why NETIF_F_LLTX is a bad idea and you
should convert your driver away from it.
