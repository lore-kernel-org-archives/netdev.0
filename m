From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [RFC 02/10] IB/hfi-vnic: Virtual Network Interface Controller
 (VNIC) Bus driver
Date: Tue, 22 Nov 2016 17:49:32 -0700
Message-ID: <20161123004932.GA13598@obsidianresearch.com>
References: <1479508938-63799-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <1479508938-63799-3-git-send-email-niranjana.vishwanathapura@intel.com>
 <20161119190445.GG22775@obsidianresearch.com>
 <20161121213017.GB67872@knc-06.sc.intel.com>
 <20161121213930.GA30111@obsidianresearch.com>
 <20161121232629.GA67988@knc-06.sc.intel.com>
 <20161121233118.GA31132@obsidianresearch.com>
 <20161122015304.GB67988@knc-06.sc.intel.com>
 <20161122170407.GE3956@obsidianresearch.com>
 <20161123000502.GA27968@phlsvsds.ph.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>,
        Doug Ledford <dledford@redhat.com>, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org,
        Dennis Dalessandro <dennis.dalessandro@intel.com>
To: "ira.weiny" <ira.weiny@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:55946 "EHLO quartz.orcorp.ca"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755453AbcKWAtg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 22 Nov 2016 19:49:36 -0500
Content-Disposition: inline
In-Reply-To: <20161123000502.GA27968@phlsvsds.ph.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 22, 2016 at 07:05:05PM -0500, ira.weiny wrote:
> On Tue, Nov 22, 2016 at 10:04:07AM -0700, Jason Gunthorpe wrote:
> > On Mon, Nov 21, 2016 at 05:53:04PM -0800, Vishwanathapura, Niranjana wrote:
> > > There are many example drivers in kernel which are using bus_register() in
> > > an initcall.
> > 
> > There really are not, certainly not in major subsystems.
> 
> I see 2 drivers in the Block subsystem which do this:
> 
> 
> 19   5354  /nfs/site/home/iweiny/linux-stable/drivers/block/cciss.c <<cciss_init>>
> 	err = bus_register(&cciss_bus_type);
> 20   6447 /nfs/site/home/iweiny/linux-stable/drivers/block/rbd.c <<rbd_sysfs_init>>
> 	ret = bus_register(&rbd_bus_type);
> 
> 2 drivers in the drm subsystem which do this:
> 
> 
> 29   1155  /nfs/site/home/iweiny/linux-stable/drivers/gpu/drm/drm_mipi_dsi.c <<mipi_dsi_bus_init>>
> 	return bus_register(&mipi_dsi_bus_type);
> 30    242 /nfs/site/home/iweiny/linux-stable/drivers/gpu/host1x/dev.c <<tegra_host1x_init>>
> 	err = bus_register(&host1x_bus_type);

IMHO this is all obscure or legacy stuff (eg ccsiss lost its bus when
it was reworked into hpsa). Who knows about that SOC stuff, maybe
there really is a special on-chip bus under those drivers.

The point is using a bus as a generic interconnect between two driver
modules seems very rare, and is not what we have historically ever
done in drivers/infiniband - all our split drivers use a trivial
register scheme. eg see cxgb4_register_uld/mlx4_register_interface/etc.

Should a multi-function driver use a bus or class to connect its
parts? Who knows. Maybe Greg KH/etc has an opinion. But that is not
what we have been doing, it doesn't seem very simplifying, and
this series doesn't even make module auto-loading work...

Since doing this creates a bunch of uapis (again, from a driver, ugh) it
seems like a bad idea without more support as 'the right way'

.. and yes, it would be nice to have a lightweight mechanism to
replace those register functions that could handle module auto loading
too, and maybe that is a 'multi part driver bus/class' or somesuch
... This is really a topic for the device core maintainers, IMHO.

> > > We could add a custom Interface between HFI1 driver and hfi_vnic drivers
> > > without involving a bus.
> > 
> > hfi is already registering on the infiniband class, just use that.
> 
> I don't understand what you mean here?

Get the struct ib_device for the hfi and then do something to get hfi
specific function calls.

Or work it backwards with a _register function..

> [*] As an aside why does the ib_core not use this methodology?  It dawned on
> me that this may be a better way to fix our module load problems.  However, I
> have not looked into details.

ib_core is a class, which is appropriate. RDMA devices are not busses.

Jason
