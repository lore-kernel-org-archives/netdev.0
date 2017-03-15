From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [RFC v1 for accelerated IPoIB 05/25] IB/ipoib: Support ipoib
 acceleration options callbacks
Date: Wed, 15 Mar 2017 09:58:02 -0600
Message-ID: <20170315155802.GB29562@obsidianresearch.com>
References: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
 <1489429896-10781-6-git-send-email-erezsh@mellanox.com>
 <20170314063538.GB79937@knc-06.sc.intel.com>
 <CAAk-MO8gQ5x-4Ubk1nzPntEWa2ivTK6uXyJ4eC7fmtUCNnOdfA@mail.gmail.com>
 <20170314160021.GD3244@obsidianresearch.com>
 <20170315064751.GD2079@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Erez Shitrit <erezsh@dev.mellanox.co.il>,
        "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>,
        Erez Shitrit <erezsh@mellanox.com>,
        Doug Ledford <dledford@redhat.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        netdev@vger.kernel.org, valex@mellanox.com, saedm@mellanox.com
To: Leon Romanovsky <leonro@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:33790 "EHLO quartz.orcorp.ca"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753433AbdCOP6T (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Mar 2017 11:58:19 -0400
Content-Disposition: inline
In-Reply-To: <20170315064751.GD2079@mtr-leonro.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 15, 2017 at 08:47:51AM +0200, Leon Romanovsky wrote:
> On Tue, Mar 14, 2017 at 10:00:21AM -0600, Jason Gunthorpe wrote:
> > On Tue, Mar 14, 2017 at 04:42:55PM +0200, Erez Shitrit wrote:
> > > >> +       if (!hca->alloc_rdma_netdev)
> > > >> +               dev = ipoib_create_netdev_default(hca, name,
> > > >> ipoib_setup_common);
> > > >> +       else
> > > >> +               dev = hca->alloc_rdma_netdev(hca, port, RDMA_NETDEV_IPOIB,
> > > >> +                                            name, NET_NAME_UNKNOWN,
> > > >> +                                            ipoib_setup_common);
> > > >> +       if (!dev) {
> > > >> +               kfree(priv);
> > > >> +               return NULL;
> > > >> +       }
> > > >
> > > >
> > > > This will break ipoib on hfi1 as hfi1 will define alloc_rdma_netdev for
> > > > OPA_VNIC type. We should probably look for a dedicated return type
> > > > (-ENODEV?) to determine of the driver supports specified rdma netdev type.
> > > > Or use a ib device attribute to suggest driver support ipoib rdma netdev.
> > >
> > > sorry, I don't understand that, we are in ipoib driver, so the type is
> > > RDMA_NETDEV_IPOIB, if hfi wants to implement it should use the same
> > > flag, and to use OPA_VNIC for vnic.
> >
> > He means it should look like this:
> >
> >  if (hca->alloc_rdma_netdev)
> >      dev = hca->alloc_rdma_netdev(hca, port, RDMA_NETDEV_IPOIB,
> >                                             name, NET_NAME_UNKNOWN,
> >                                             ipoib_setup_common);
> >
> >  if (IS_ERR(dev) && PTR_ERR(dev) != ENOTSUP)
> >       goto out;
> >
> >  dev = ipoib_create_netdev_default(hca, name, ipoib_setup_common);
> >  if (IS_ERR(dev))
> >       goto out;
> >
> >  WARN_ON(dev == NULL);
> >
> >   [...]
> >
> > out:
> >       return PTR_ERR(dev);
> >
> > And I'm confused why 'ipoib_create_netdev_default' doesn't need the
> > same function signature as hca->alloc_rdma_netdev
> 
> And now, I'm confused.
> In your's proposal, the "dev" will be overwritten, in Erez's proposal,
> "dev" will be one of two: defaults or device specific.

Well, not Erez's version allowed dev to be ERR_PTR too. More like this then

struct rdma_netdev *get_netdev(..)
{
   if (hca-alloc_rdma_netdev) {
       dev = hca-alloc_rdma_netdev(hca, port, RDMA_NETDEV_IPOIB,
                                              name, NET_NAME_UNKNOWN,
                                              ipoib_setup_common);
 
       if (!IS_ERR(dev) || PTR_ERR(dev) != ENOTSUP)
           return dev;
   }
 
   return ipoib_create_netdev_default(hca, name, ipoib_setup_common);
}

Jason
