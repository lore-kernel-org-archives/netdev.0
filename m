From: Ben Dooks <ben-linux@fluff.org>
Subject: Re: [PATCH] dm9000 - fix spinlock issue, updated
Date: Sun, 23 Dec 2007 02:21:50 +0000
Message-ID: <20071223022150.GC9216@fluff.org.uk>
References: <1195652873.4999.8.camel@diimka.pervushin.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, ben@fluff.org
To: dmitry pervushin <dpervushin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:64222 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754065AbXLWCVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Dec 2007 21:21:52 -0500
Content-Disposition: inline
In-Reply-To: <1195652873.4999.8.camel@diimka.pervushin.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 21, 2007 at 04:47:53PM +0300, dmitry pervushin wrote:
> The patch below fixes the problem with dm9000_timeout function: it calls
> dm9000_init under the spin_lock db->lock, which was going to be acquired
> again in dm9000_hash_table. From the other hand, dm9000_hash_table has
> to be called with db->lock held
> 
> Signed-off-by: dmitry pervushin <dpervushin@gmail.com>
Acked-by: Ben Dooks <ben-linux@fluff.org>
> Index: linux/drivers/net/dm9000.c
> ===================================================================
> --- linux.orig/drivers/net/dm9000.c
> +++ linux/drivers/net/dm9000.c
> @@ -173,6 +173,7 @@ static void dm9000_phy_write(struct net_
>  static u16 read_srom_word(board_info_t *, int);
>  static void dm9000_rx(struct net_device *);
>  static void dm9000_hash_table(struct net_device *);
> +static void dm9000_set_multicast(struct net_device *dev);
>  
>  //#define DM9000_PROGRAM_EEPROM
>  #ifdef DM9000_PROGRAM_EEPROM
> @@ -556,7 +557,7 @@ dm9000_probe(struct platform_device *pde
>  	ndev->tx_timeout         = &dm9000_timeout;
>  	ndev->watchdog_timeo = msecs_to_jiffies(watchdog);
>  	ndev->stop		 = &dm9000_stop;
> -	ndev->set_multicast_list = &dm9000_hash_table;
> +	ndev->set_multicast_list = &dm9000_set_multicast;
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  	ndev->poll_controller	 = &dm9000_poll_controller;
>  #endif
> @@ -620,6 +621,7 @@ static int
>  dm9000_open(struct net_device *dev)
>  {
>  	board_info_t *db = (board_info_t *) dev->priv;
> +	unsigned long flags;
>  
>  	PRINTK2("entering dm9000_open\n");
>  
> @@ -627,8 +629,10 @@ dm9000_open(struct net_device *dev)
>  		return -EAGAIN;
>  
>  	/* Initialize DM9000 board */
> +	spin_lock_irqsave(&db->lock, flags);
>  	dm9000_reset(db);
>  	dm9000_init_dm9000(dev);
> +	spin_unlock_irqrestore(&db->lock, flags);
>  
>  	/* Init driver variable */
>  	db->dbug_cnt = 0;
> @@ -1030,6 +1034,18 @@ cal_CRC(unsigned char *Data, unsigned in
>  /*
>   *  Set DM9000 multicast address
>   */
> +
> +static void
> +dm9000_set_multicast(struct net_device *dev)
> +{
> +	board_info_t *db = (board_info_t *) dev->priv;
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&db->lock,flags);
> +	dm9000_hash_table(dev);
> +	spin_unlock_irqrestore(&db->lock, flags);
> +}
> +
>  static void
>  dm9000_hash_table(struct net_device *dev)
>  {
> @@ -1038,12 +1054,9 @@ dm9000_hash_table(struct net_device *dev
>  	int mc_cnt = dev->mc_count;
>  	u32 hash_val;
>  	u16 i, oft, hash_table[4];
> -	unsigned long flags;
>  
>  	PRINTK2("dm9000_hash_table()\n");
>  
> -	spin_lock_irqsave(&db->lock,flags);
> -
>  	for (i = 0, oft = 0x10; i < 6; i++, oft++)
>  		iow(db, oft, dev->dev_addr[i]);
>  
> @@ -1065,8 +1078,6 @@ dm9000_hash_table(struct net_device *dev
>  		iow(db, oft++, hash_table[i] & 0xff);
>  		iow(db, oft++, (hash_table[i] >> 8) & 0xff);
>  	}
> -
> -	spin_unlock_irqrestore(&db->lock,flags);
>  }
>  
>  
> @@ -1155,12 +1166,15 @@ dm9000_drv_resume(struct platform_device
>  {
>  	struct net_device *ndev = platform_get_drvdata(dev);
>  	board_info_t *db = (board_info_t *) ndev->priv;
> +	unsigned long flags;
>  
>  	if (ndev) {
>  
>  		if (netif_running(ndev)) {
> +			spin_lock_irqsave(&db->lock, flags);
>  			dm9000_reset(db);
>  			dm9000_init_dm9000(ndev);
> +			spin_unlock_irqrestore(&db->lock, flags);
>  
>  			netif_device_attach(ndev);
>  		}
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
