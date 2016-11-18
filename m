From: Phil Sutter <phil@nwl.cc>
Subject: Re: [net-next PATCH v2] net: dummy: Introduce dummy virtual functions
Date: Fri, 18 Nov 2016 16:59:47 +0100
Message-ID: <20161118155947.GB26542@orbyte.nwl.cc>
References: <20161114130205.18333-1-phil@nwl.cc>
 <CAJ3xEMhG4Eeh6pwY2Uq_KxmuHJb9-xYYkr4Ps_kQWwEXeB9Sbg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Sabrina Dubroca <sd@queasysnail.net>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:40065 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751593AbcKRP7t (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 18 Nov 2016 10:59:49 -0500
Content-Disposition: inline
In-Reply-To: <CAJ3xEMhG4Eeh6pwY2Uq_KxmuHJb9-xYYkr4Ps_kQWwEXeB9Sbg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, Nov 18, 2016 at 12:04:14AM +0200, Or Gerlitz wrote:
> On Mon, Nov 14, 2016 at 3:02 PM, Phil Sutter <phil@nwl.cc> wrote:
> 
> > Due to the assumption that all PFs are PCI devices, this implementation
> > is not completely straightforward: In order to allow for
> > rtnl_fill_ifinfo() to see the dummy VFs, a fake PCI parent device is
> > attached to the dummy netdev. This has to happen at the right spot so
> > register_netdevice() does not get confused. This patch abuses
> > ndo_fix_features callback for that. In ndo_uninit callback, the fake
> > parent is removed again for the same purpose.
> 
> So you did some mimic-ing of PCI interface, how do you let the user to
> config the number of VFs? though a module param? why? if the module
> param only serves to say how many VF the device supports, maybe
> support the maximum possible by PCI spec and skip the module param?

Yes, this is controlled via module parameter. But it doesn't say how
much is supported but rather how many dummy VFs are to be created for
each dummy interface.

> > +module_param(num_vfs, int, 0);
> > +MODULE_PARM_DESC(num_vfs, "Number of dummy VFs per dummy device");
> > +
> 
> > @@ -190,6 +382,7 @@ static int __init dummy_init_one(void)
> >         err = register_netdevice(dev_dummy);
> >         if (err < 0)
> >                 goto err;
> > +
> >         return 0;
> 
> nit, remove this added blank line..

Oh yes, thanks. Spontaneous reviewer's blindness. :)

The implementation is problematic in another aspect though: Upon reboot,
it seems like no netdev ops are being called but the fake PCI parent's
kobject is being freed which does not work (and leads to an oops).

Cheers, Phil
