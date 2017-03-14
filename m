From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [RFC v1 for accelerated IPoIB 05/25] IB/ipoib: Support ipoib
 acceleration options callbacks
Date: Tue, 14 Mar 2017 10:00:21 -0600
Message-ID: <20170314160021.GD3244@obsidianresearch.com>
References: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
 <1489429896-10781-6-git-send-email-erezsh@mellanox.com>
 <20170314063538.GB79937@knc-06.sc.intel.com>
 <CAAk-MO8gQ5x-4Ubk1nzPntEWa2ivTK6uXyJ4eC7fmtUCNnOdfA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>,
        Erez Shitrit <erezsh@mellanox.com>,
        Doug Ledford <dledford@redhat.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        netdev@vger.kernel.org, valex@mellanox.com,
        Leon Romanovsky <leonro@mellanox.com>, saedm@mellanox.com
To: Erez Shitrit <erezsh@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:41290 "EHLO quartz.orcorp.ca"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751000AbdCNQA3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 14 Mar 2017 12:00:29 -0400
Content-Disposition: inline
In-Reply-To: <CAAk-MO8gQ5x-4Ubk1nzPntEWa2ivTK6uXyJ4eC7fmtUCNnOdfA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 14, 2017 at 04:42:55PM +0200, Erez Shitrit wrote:
> >> +       if (!hca->alloc_rdma_netdev)
> >> +               dev = ipoib_create_netdev_default(hca, name,
> >> ipoib_setup_common);
> >> +       else
> >> +               dev = hca->alloc_rdma_netdev(hca, port, RDMA_NETDEV_IPOIB,
> >> +                                            name, NET_NAME_UNKNOWN,
> >> +                                            ipoib_setup_common);
> >> +       if (!dev) {
> >> +               kfree(priv);
> >> +               return NULL;
> >> +       }
> >
> >
> > This will break ipoib on hfi1 as hfi1 will define alloc_rdma_netdev for
> > OPA_VNIC type. We should probably look for a dedicated return type
> > (-ENODEV?) to determine of the driver supports specified rdma netdev type.
> > Or use a ib device attribute to suggest driver support ipoib rdma netdev.
> 
> sorry, I don't understand that, we are in ipoib driver, so the type is
> RDMA_NETDEV_IPOIB, if hfi wants to implement it should use the same
> flag, and to use OPA_VNIC for vnic.

He means it should look like this:

 if (hca->alloc_rdma_netdev)
     dev = hca->alloc_rdma_netdev(hca, port, RDMA_NETDEV_IPOIB,
                                            name, NET_NAME_UNKNOWN,
                                            ipoib_setup_common);

 if (IS_ERR(dev) && PTR_ERR(dev) != ENOTSUP)
      goto out;

 dev = ipoib_create_netdev_default(hca, name, ipoib_setup_common);
 if (IS_ERR(dev))
      goto out;

 WARN_ON(dev == NULL);

  [...]
  
out:
      return PTR_ERR(dev);

And I'm confused why 'ipoib_create_netdev_default' doesn't need the
same function signature as hca->alloc_rdma_netdev

Both drivers should implement hca->alloc_rdma_netdev to return ENOTSUP
if RDMA_NETDEV is not supported.

Jason
