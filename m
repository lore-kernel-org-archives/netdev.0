From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv7 net-next 2/4] sunvnet: make transmit path zero-copy
 in the kernel
Date: Mon, 29 Sep 2014 15:28:02 -0400 (EDT)
Message-ID: <20140929.152802.1895227801613062829.davem@davemloft.net>
References: <54299A87.80305@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sowmini.varadhan@oracle.com,
	Raghuram.Kothakota@oracle.com
To: david.stevens@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32793 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753891AbaI2T2E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 15:28:04 -0400
In-Reply-To: <54299A87.80305@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David L Stevens <david.stevens@oracle.com>
Date: Mon, 29 Sep 2014 13:44:39 -0400

> @@ -788,12 +874,16 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	struct vio_net_desc *d;
>  	unsigned long flags;
>  	unsigned int len;
> -	void *tx_buf;
> -	int i, err;
> +	struct sk_buff *freeskbs = NULL;
> +	int i, err, txi;
> +	void *start = NULL;
> +	int nlen = 0;
> 
>  	if (unlikely(!port))
>  		goto out_dropped;
> 
> +	skb = vnet_skb_shape(skb, &start, &nlen);
> +
>  	spin_lock_irqsave(&port->vio.lock, flags);
> 
>  	dr = &port->vio.drings[VIO_DRIVER_TX_RING];

vnet_skb_shape() can return NULL, I don't think you're handling that case
at all and are blindly derefencing a potentially NULL skb pointer.
