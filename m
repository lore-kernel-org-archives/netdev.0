From: Ben Dooks <ben@fluff.org>
Subject: Re: [PATCH] dm9000: fix spinlock issue and introduce platform_init
	callback
Date: Tue, 20 Nov 2007 15:07:19 +0000
Message-ID: <20071120150719.GD3244@fluff.org.uk>
References: <1195569822.17808.20.camel@diimka.pervushin.msk.ru> <20071120145151.GC3244@fluff.org.uk> <1195570789.17808.39.camel@diimka.pervushin.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Dooks <ben@fluff.org>, netdev <netdev@vger.kernel.org>
To: dmitry pervushin <dpervushin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:50631 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755500AbXKTPHZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 10:07:25 -0500
Content-Disposition: inline
In-Reply-To: <1195570789.17808.39.camel@diimka.pervushin.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 20, 2007 at 05:59:49PM +0300, dmitry pervushin wrote:
> 
> On ???, 2007-11-20 at 14:51 +0000, Ben Dooks wrote:
> > On Tue, Nov 20, 2007 at 05:43:42PM +0300, dmitry pervushin wrote:
> > > Hey all,
> > > 
> > > The patch below is intended to fix two problems:
> > > - trying to acquire spinlock twice on timeout condition
> > 
> > I'll have a look into this, although I think we may be better of
> > not dropping the spinlock and simply moving it out of
> > dm9000_init_dm9000() and ensure all callers of this function
> > hold the lock already.

> actually, dm9000_hash_table holds this spin lock. Well, I'll try to rework this

I think that dropping and re-aquiring the lock is creating the
possibility that something else could happen in this sequence
of events.

> > > - create callback than can be used by platform code to initialize the
> > > chip
> > 
> > Hi, what purpose is the callback for? and if it takes a platform
> > device why is the prototype for 'void *' ?
> to initialize the chip. My target board has to configure GPIO/CPLD
> registers properly to activate dm9000. I do not want to move this
> initialization to common code -- the GPIO lines might be shared and I'd
> like to configure them only if it is needed.

Aha, could the comment in the header file be expanded to say
something like "Callback for machine or board dependant initialisation,
such as enabling the routing of control signals to the DM9000" to signify
what is meant to be happening here.
 
> > This should have also been two seperate patches as there are two
> > different issues.

Just as an further explanation, the spinlock fix is ideal to push
now, whereas the callback patch is probably 2.6.25 material.

> > > Signed-off-by: dmitry pervushin <dpervushin@gmail.com>
> > > Index: linux/drivers/net/dm9000.c
> > > ===================================================================
> > > --- linux.orig/drivers/net/dm9000.c
> > > +++ linux/drivers/net/dm9000.c
> > > @@ -335,8 +335,11 @@ static void dm9000_timeout(struct net_de
> > >  
> > >  	netif_stop_queue(dev);
> > >  	dm9000_reset(db);
> > > +	spin_unlock_irqrestore(&db->lock,flags);
> > > +
> > >  	dm9000_init_dm9000(dev);
> > >  	/* We can accept TX packets again */
> > > +	spin_lock_irqsave(&db->lock,flags);
> > >  	dev->trans_start = jiffies;
> > >  	netif_wake_queue(dev);
> > >  
> > > @@ -526,6 +529,8 @@ dm9000_probe(struct platform_device *pde
> > >  			db->dumpblk = pdata->dumpblk;
> > >  	}
> > >  
> > > + 	if (pdata && pdata->platform_init)
> > > + 			pdata->platform_init(pdev);
> > >  	dm9000_reset(db);
> > >  
> > >  	/* try two times, DM9000 sometimes gets the first read wrong */
> > > @@ -1155,10 +1160,13 @@ dm9000_drv_resume(struct platform_device
> > >  {
> > >  	struct net_device *ndev = platform_get_drvdata(dev);
> > >  	board_info_t *db = (board_info_t *) ndev->priv;
> > > + 	struct dm9000_plat_data *pdata = dev->dev.platform_data;
> > >  
> > >  	if (ndev) {
> > >  
> > >  		if (netif_running(ndev)) {
> > > + 			if (pdata && pdata->platform_init)
> > > +         	                pdata->platform_init(dev);
> > >  			dm9000_reset(db);
> > >  			dm9000_init_dm9000(ndev);
> > >  
> > > Index: linux/include/linux/dm9000.h
> > > ===================================================================
> > > --- linux.orig/include/linux/dm9000.h
> > > +++ linux/include/linux/dm9000.h
> > > @@ -30,6 +30,9 @@ struct dm9000_plat_data {
> > >  	void	(*inblk)(void __iomem *reg, void *data, int len);
> > >  	void	(*outblk)(void __iomem *reg, void *data, int len);
> > >  	void	(*dumpblk)(void __iomem *reg, int len);
> > > +
> > > +	/* platform init, if any */
> > > +	void 	(*platform_init)(void *);
> > >  };
> > >  
> > >  #endif /* __DM9000_PLATFORM_DATA */
> > > 
> > > 
> > > -
> > > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
