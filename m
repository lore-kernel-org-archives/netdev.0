From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch 06/22] NET: DM9000: Use kthread to probe MII status when device open
Date: Tue, 20 Nov 2007 07:46:27 +0000
Message-ID: <20071120074627.GA31558@infradead.org>
References: <20071119203910.687238131@fluff.org> <20071119204013.745821010@fluff.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, vince@simtec.co.uk
To: Ben Dooks <ben-linux@fluff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:58422 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754628AbXKTHqa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 02:46:30 -0500
Content-Disposition: inline
In-Reply-To: <20071119204013.745821010@fluff.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +static void dm9000_start_thread(struct net_device *dev)
> +{
> +	board_info_t *db = (board_info_t *) dev->priv;
> +
> +	/* Create a thread to keep track of the state of the phy
> +	 * as we do not get an interrupt when the PHY state changes.
> +	 *
> +	 * Note, we do not abort the open if we fail to create the
> +	 * thread, as this is mainly to ensure the user is kept up to
> +	 * date with the device's state. PHY accesses will still work
> +	 * via the MII read and write methods.
> +	 */
> +
> +	db->thread = kthread_create(dm9000_mii_thread, db, dev->name);
> +	if (IS_ERR(db->thread)) {
> +		dev_err(db->dev, "failed to create MII thread\n");
> +		db->thread = NULL;
> +	} else
> +		wake_up_process(db->thread);
> +}
> +
>  /*
>   *  Open the interface.
>   *  The interface is opened whenever "ifconfig" actives it.
> @@ -704,12 +724,7 @@ dm9000_open(struct net_device *dev)
>  	/* Init driver variable */
>  	db->dbug_cnt = 0;
>  
> -	/* set and active a timer process */
> -	init_timer(&db->timer);
> -	db->timer.expires  = DM9000_TIMER_WUT;
> -	db->timer.data     = (unsigned long) dev;
> -	db->timer.function = &dm9000_timer;
> -	add_timer(&db->timer);
> +	dm9000_start_thread(dev);

Please don't just ignore the error.  Just inline the content of
dm9000_start_thread into the caller and use proper goto-based
unwinding.

