From: dmitry pervushin <dpervushin@gmail.com>
Subject: Re: [PATCH] dm9000: fix spinlock issue and introduce platform_init
	callback
Date: Tue, 20 Nov 2007 17:59:49 +0300
Message-ID: <1195570789.17808.39.camel@diimka.pervushin.msk.ru>
References: <1195569822.17808.20.camel@diimka.pervushin.msk.ru>
	 <20071120145151.GC3244@fluff.org.uk>
Reply-To: dpervushin@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Ben Dooks <ben@fluff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.244]:61280 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755424AbXKTO7x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 09:59:53 -0500
Received: by an-out-0708.google.com with SMTP id d31so470001and
        for <netdev@vger.kernel.org>; Tue, 20 Nov 2007 06:59:52 -0800 (PST)
In-Reply-To: <20071120145151.GC3244@fluff.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On =F7=D4=D2, 2007-11-20 at 14:51 +0000, Ben Dooks wrote:
> On Tue, Nov 20, 2007 at 05:43:42PM +0300, dmitry pervushin wrote:
> > Hey all,
> >=20
> > The patch below is intended to fix two problems:
> > - trying to acquire spinlock twice on timeout condition
>=20
> I'll have a look into this, although I think we may be better of
> not dropping the spinlock and simply moving it out of
> dm9000_init_dm9000() and ensure all callers of this function
> hold the lock already.
actually, dm9000_hash_table holds this spin lock. Well, I'll try to rew=
ork this
> > - create callback than can be used by platform code to initialize t=
he
> > chip
>=20
> Hi, what purpose is the callback for? and if it takes a platform
> device why is the prototype for 'void *' ?
to initialize the chip. My target board has to configure GPIO/CPLD
registers properly to activate dm9000. I do not want to move this
initialization to common code -- the GPIO lines might be shared and I'd
like to configure them only if it is needed.

> This should have also been two seperate patches as there are two
> different issues.
> =20
> > Signed-off-by: dmitry pervushin <dpervushin@gmail.com>
> > Index: linux/drivers/net/dm9000.c
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > --- linux.orig/drivers/net/dm9000.c
> > +++ linux/drivers/net/dm9000.c
> > @@ -335,8 +335,11 @@ static void dm9000_timeout(struct net_de
> > =20
> >  	netif_stop_queue(dev);
> >  	dm9000_reset(db);
> > +	spin_unlock_irqrestore(&db->lock,flags);
> > +
> >  	dm9000_init_dm9000(dev);
> >  	/* We can accept TX packets again */
> > +	spin_lock_irqsave(&db->lock,flags);
> >  	dev->trans_start =3D jiffies;
> >  	netif_wake_queue(dev);
> > =20
> > @@ -526,6 +529,8 @@ dm9000_probe(struct platform_device *pde
> >  			db->dumpblk =3D pdata->dumpblk;
> >  	}
> > =20
> > + 	if (pdata && pdata->platform_init)
> > + 			pdata->platform_init(pdev);
> >  	dm9000_reset(db);
> > =20
> >  	/* try two times, DM9000 sometimes gets the first read wrong */
> > @@ -1155,10 +1160,13 @@ dm9000_drv_resume(struct platform_device
> >  {
> >  	struct net_device *ndev =3D platform_get_drvdata(dev);
> >  	board_info_t *db =3D (board_info_t *) ndev->priv;
> > + 	struct dm9000_plat_data *pdata =3D dev->dev.platform_data;
> > =20
> >  	if (ndev) {
> > =20
> >  		if (netif_running(ndev)) {
> > + 			if (pdata && pdata->platform_init)
> > +         	                pdata->platform_init(dev);
> >  			dm9000_reset(db);
> >  			dm9000_init_dm9000(ndev);
> > =20
> > Index: linux/include/linux/dm9000.h
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > --- linux.orig/include/linux/dm9000.h
> > +++ linux/include/linux/dm9000.h
> > @@ -30,6 +30,9 @@ struct dm9000_plat_data {
> >  	void	(*inblk)(void __iomem *reg, void *data, int len);
> >  	void	(*outblk)(void __iomem *reg, void *data, int len);
> >  	void	(*dumpblk)(void __iomem *reg, int len);
> > +
> > +	/* platform init, if any */
> > +	void 	(*platform_init)(void *);
> >  };
> > =20
> >  #endif /* __DM9000_PLATFORM_DATA */
> >=20
> >=20
> > -
> > To unsubscribe from this list: send the line "unsubscribe netdev" i=
n
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20

