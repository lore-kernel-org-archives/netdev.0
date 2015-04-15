From: Honggang LI <honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH linux-next 1/4] infiniband/ipoib: fix possible NULL
 pointer dereference in ipoib_get_iflink
Date: Wed, 15 Apr 2015 14:57:34 +0800
Message-ID: <20150415065734.GA2477@honli.nay.redhat.com>
References: <1429024817-21561-1-git-send-email-honli@redhat.com>
 <1429024817-21561-2-git-send-email-honli@redhat.com>
 <CAAk-MO-O9sjHQvDfCEuzJJPvUMXJTuRaCzrCkB0xc1DUfK8Aew@mail.gmail.com>
 <20150415051640.GB4881@honli.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	Alex Estrin <alex.estrin-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org,
	maheshb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
	elfring-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org, sfeldma-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Erez Shitrit <erezsh-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20150415051640.GB4881-9l7K0WC0B0wP68cbUhXDDlaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


There was network accident in the office. I can't find this email in
public mailing list. So, I reset it. If you had recived this, please
ignore it. 

thanks

On Wed, Apr 15, 2015 at 01:16:40PM +0800, Honggang LI wrote:
> On Tue, Apr 14, 2015 at 07:30:03PM +0300, Erez Shitrit wrote:
> > > @@ -846,7 +846,10 @@ static int ipoib_get_iflink(const struct net_device *dev)
> > >  {
> > >         struct ipoib_dev_priv *priv = netdev_priv(dev);
> > >
> > > -       return priv->parent->ifindex;
> > > +       if (priv && priv->parent)
> > > +               return priv->parent->ifindex;
> > > +       else
> > > +               return 0;
> > This will make parent interface to return 0 instead of its own ifindex.
> > I would suggest write something like that:
> > 
> > +       /* parent interface */
> > +       if (!test_bit(IPOIB_FLAG_SUBINTERFACE, &priv->flags))
> > +               return dev->ifindex;
> > +
> 
> Hi, Erez
> 
> Sorry for delay of reply. It was about 01:00 in the morning, so I
> went into bed. And thank you for the suggestion. You are right. After 
> insert some printk statements in the driver, I confirmed it.
> 
> ---------------------- console log --------------------
> ipoib_get_iflink: priv = ffff880275e487c0, priv->parent = (null), priv->flags = 0x20f, dev = ffff880275e48000, dev->name = qib_ib1
> qib_ib1, test_bit(IPOIB_FLAG_SUBINTERFACE, &priv->flags) = 0
> qib_ib1, idev->ifindex = 14
> 
> ipoib_get_iflink: priv = ffff8802765d27c0, priv->parent = (null), priv->flags = 0x20f, dev = ffff8802765d2000, dev->name = qib_ib2
> qib_ib2, test_bit(IPOIB_FLAG_SUBINTERFACE, &priv->flags) = 0
> qib_ib2, idev->ifindex = 15
> 
> ipoib_get_iflink: priv = ffff8804741a47c0, priv->parent = ffff880275e48000, priv->flags = 0x224, dev = ffff8804741a4000, dev->name = qib_ib1.8003
> qib_ib1.8003, test_bit(IPOIB_FLAG_SUBINTERFACE, &priv->flags) = 1
> qib_ib1.8003, idev->ifindex = 16
> 
> ---------------------- console log --------------------
> 
> I will rewrite the patch.
> 
> > +       /* child/vlan interface */
> > +       if (!priv->parent)
> > +               return -1;
> > +
> >         return priv->parent->ifindex;
> > 
> > Thanks,
> > Erez.
> > 
> > >  }
> > >
> > >  static u32 ipoib_addr_hash(struct ipoib_neigh_hash *htbl, u8 *daddr)
> > > --
> > > 1.8.3.1
> > >
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
