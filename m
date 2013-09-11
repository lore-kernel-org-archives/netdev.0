From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net] tuntap: correctly handle error in tun_set_iff()
Date: Wed, 11 Sep 2013 05:55:04 -0400 (EDT)
Message-ID: <540640927.12279419.1378893304081.JavaMail.root@redhat.com>
References: <1378887845-6821-1-git-send-email-jasowang@redhat.com> <20130911093843.GA20836@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	wannes rombouts <wannes.rombouts@epitech.eu>,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130911093843.GA20836@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



----- Original Message -----
> On Wed, Sep 11, 2013 at 04:24:05PM +0800, Jason Wang wrote:
> > Commit c8d68e6be1c3b242f1c598595830890b65cea64a (tuntap: multiqueue
> > support)
> > only call free_netdev() on err in tun_set_iff(). This causes several
> > issues:
> > 
> > - memory of tun security were leaked
> 
> Not just tun security -  sock reference too (didn't detach)
> 

Yes, I mention it in the next item.
> > - use after free since the flow gc timer was not deleted and the tfile were
> > not
> >   detached
> > 
> > This patch solves the above issues.
> > 
> > Reported-by: Wannes Rombouts <wannes.rombouts@epitech.eu>
> > Cc: Michael S. Tsirkin <mst@redhat.com>
> > Signed-off-by: Jason Wang <jasowang@redhat.com>
> > ---
> > The patch were also needed for stable 3.8+.
> > ---
> >  drivers/net/tun.c |    9 +++++++--
> >  1 files changed, 7 insertions(+), 2 deletions(-)
> > 
> > diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> > index a639de8..e5fb5d3 100644
> > --- a/drivers/net/tun.c
> > +++ b/drivers/net/tun.c
> > @@ -1641,11 +1641,11 @@ static int tun_set_iff(struct net *net, struct file
> > *file, struct ifreq *ifr)
> >  		INIT_LIST_HEAD(&tun->disabled);
> >  		err = tun_attach(tun, file, false);
> >  		if (err < 0)
> > -			goto err_free_dev;
> > +			goto err_free_flow;
> >  
> >  		err = register_netdevice(tun->dev);
> >  		if (err < 0)
> > -			goto err_free_dev;
> > +			goto err_detach;
> >  
> >  		if (device_create_file(&tun->dev->dev, &dev_attr_tun_flags) ||
> >  		    device_create_file(&tun->dev->dev, &dev_attr_owner) ||
> > @@ -1689,6 +1689,11 @@ static int tun_set_iff(struct net *net, struct file
> > *file, struct ifreq *ifr)
> >  	strcpy(ifr->ifr_name, tun->dev->name);
> >  	return 0;
> >  
> > +err_detach:
> > +	tun_detach_all(dev);
> > +err_free_flow:
> > +	tun_flow_uninit(tun);
> > +	security_tun_dev_free_security(tun->security);
> 
> This bit looks wrong: if flow_init fails, we
> need security_tun_dev_free_security, don't we?
> I think we need:
> 	+err_free_sec:	security_tun_dev_free_security(tun->security);
> and goto here on flow_init failures.

tun_flow_init() always succeed. So we're ok here.
> 
> >   err_free_dev:
> 
> Pls shift this one 1 space left for consistency.
> 

Ok.
> >  	free_netdev(dev);
> >  	return err;
> > --
> > 1.7.1
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
