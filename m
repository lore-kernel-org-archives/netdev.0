From: Francesco Ruggeri <fruggeri@arista.com>
Subject: Re: [PATCH net-next] macvlan: fix failure during registration v3
Date: Tue, 26 Apr 2016 12:07:24 -0700
Message-ID: <CA+HUmGgYf8BkaPqYxvuDtuUY5JC90QC-6_mxEQ6DWRcaoeid2Q@mail.gmail.com>
References: <1461449012-7401-1-git-send-email-fruggeri@arista.com>
	<CAF2d9jh98MGYorJ=btvx04==EsjP5_ivUEimf0TJ1NUPDzG4nw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-netdev <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:34697 "EHLO
	mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752384AbcDZTHZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 15:07:25 -0400
Received: by mail-oi0-f49.google.com with SMTP id k142so25570163oib.1
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2016 12:07:25 -0700 (PDT)
In-Reply-To: <CAF2d9jh98MGYorJ=btvx04==EsjP5_ivUEimf0TJ1NUPDzG4nw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 26, 2016 at 11:54 AM, Mahesh Bandewar <maheshb@google.com> wrote:
>
> On Sat, Apr 23, 2016 at 3:03 PM, Francesco Ruggeri <fruggeri@arista.com> wrote:
> > If macvlan_common_newlink fails in register_netdevice after macvlan_init
> > then it decrements port->count twice, first in macvlan_uninit (from
> > register_netdevice or rollback_registered) and then again in
> > macvlan_common_newlink.
> > A similar problem may exist in the ipvlan driver.
> That is correct! The problem exists in ipvlan driver also. I'll cook a
> patch to fix this in ipvlan driver.
>
> > This patch consolidates modifications to port->count into macvlan_init
> > and macvlan_uninit (thanks to Eric Biederman for suggesting this approach).
> >
> > v3: remove macvtap specific bits.
> >
> > Signed-off-by: Francesco Ruggeri <fruggeri@arista.com>
> > ---
> >  drivers/net/macvlan.c | 10 ++++------
> >  1 file changed, 4 insertions(+), 6 deletions(-)
> >
> > diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> > index 2bcf1f3..cb01023 100644
> > --- a/drivers/net/macvlan.c
> > +++ b/drivers/net/macvlan.c
> > @@ -795,6 +795,7 @@ static int macvlan_init(struct net_device *dev)
> >  {
> >         struct macvlan_dev *vlan = netdev_priv(dev);
> >         const struct net_device *lowerdev = vlan->lowerdev;
> > +       struct macvlan_port *port = vlan->port;
> >
> >         dev->state              = (dev->state & ~MACVLAN_STATE_MASK) |
> >                                   (lowerdev->state & MACVLAN_STATE_MASK);
> > @@ -812,6 +813,8 @@ static int macvlan_init(struct net_device *dev)
> >         if (!vlan->pcpu_stats)
> >                 return -ENOMEM;
> >
> > +       port->count += 1;
> > +
> >         return 0;
> >  }
> >
> > @@ -1312,10 +1315,9 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
> >                         return err;
> >         }
> >
> > -       port->count += 1;
> >         err = register_netdevice(dev);
> >         if (err < 0)
> > -               goto destroy_port;
> > +               return err;
> >
> >         dev->priv_flags |= IFF_MACVLAN;
> >         err = netdev_upper_dev_link(lowerdev, dev);
> > @@ -1330,10 +1332,6 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
> >
> >  unregister_netdev:
> >         unregister_netdevice(dev);
> > -destroy_port:
> > -       port->count -= 1;
> > -       if (!port->count)
> > -               macvlan_port_destroy(lowerdev);
> I think you still need this when it fails netdev_upper_dev_link(). The
> only thing you should remove is the label.

I don't think so. I think the double decrement also occurred in this case.
unregister_netdevice invokes rollback_registered/macvlan_uninit
which does the decrement.

Thanks,
Francesco

> >
> >         return err;
> >  }
> > --
> > 1.8.1.4
> >
