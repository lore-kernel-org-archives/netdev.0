From: Vasu Dev <vasu.dev@linux.intel.com>
Subject: Re: [net-next 24/40] ixgbe: alloc DDP PCI pool and ixgbe queues as
 per NUMA nodes
Date: Mon, 13 Jun 2011 17:14:23 -0700
Message-ID: <1308010463.31900.100.camel@vi2.jf.intel.com>
References: <1307449995-9458-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1307449995-9458-25-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1307451503.2908.5.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	Vasu Dev <vasu.dev@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:7732 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755361Ab1FNAOY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jun 2011 20:14:24 -0400
In-Reply-To: <1307451503.2908.5.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-06-07 at 13:58 +0100, Ben Hutchings wrote:
> On Tue, 2011-06-07 at 05:32 -0700, Jeff Kirsher wrote:
> > From: Vasu Dev <vasu.dev@intel.com>
> > 
> > Have DDP PCI pools allocated from closest NUMA node to the CPU
> > and have ixgbe queues allocs per NUMA node.
> > 
> > Signed-off-by: Vasu Dev <vasu.dev@intel.com>
> > Tested-by: Ross Brattain <ross.b.brattain@intel.com>
> > Tested-by: Evan Swanson <evan.swanson@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > ---
> >  drivers/net/ixgbe/ixgbe_fcoe.c |    8 ++++++--
> >  drivers/net/ixgbe/ixgbe_main.c |   12 +++++++++---
> >  2 files changed, 15 insertions(+), 5 deletions(-)
> > 
> > diff --git a/drivers/net/ixgbe/ixgbe_fcoe.c b/drivers/net/ixgbe/ixgbe_fcoe.c
> > index aadff4f..71e8458 100644
> > --- a/drivers/net/ixgbe/ixgbe_fcoe.c
> > +++ b/drivers/net/ixgbe/ixgbe_fcoe.c
> > @@ -615,7 +615,7 @@ static void ixgbe_fcoe_ddp_pools_free(struct ixgbe_fcoe *fcoe)
> >  static void ixgbe_fcoe_ddp_pools_alloc(struct ixgbe_adapter *adapter)
> >  {
> >  	struct ixgbe_fcoe *fcoe = &adapter->fcoe;
> > -	unsigned int cpu;
> > +	unsigned int cpu, nid;
> >  	struct pci_pool **pool;
> >  	char pool_name[32];
> >  
> > @@ -623,19 +623,23 @@ static void ixgbe_fcoe_ddp_pools_alloc(struct ixgbe_adapter *adapter)
> >  	if (!fcoe->pool)
> >  		return;
> >  
> > +	nid = dev_to_node(&adapter->pdev->dev);
> >  	/* allocate pci pool for each cpu */
> >  	for_each_possible_cpu(cpu) {
> >  		snprintf(pool_name, 32, "ixgbe_fcoe_ddp_%d", cpu);
> >  		pool = per_cpu_ptr(fcoe->pool, cpu);
> > +		set_dev_node(&adapter->pdev->dev, cpu_to_node(cpu));
> >  		*pool = pci_pool_create(pool_name,
> >  					adapter->pdev, IXGBE_FCPTR_MAX,
> >  					IXGBE_FCPTR_ALIGN, PAGE_SIZE);
> >  		if (!*pool) {
> >  			e_err(drv, "failed to alloc DDP pool on cpu:%d\n", cpu);
> >  			ixgbe_fcoe_ddp_pools_free(fcoe);
> > -			return;
> > +			break;
> >  		}
> >  	}
> > +	/* restore original node value */
> > +	set_dev_node(&adapter->pdev->dev, nid);
> >  }
> [...]
> 
> This is a horrible hack.  You should fix the API so that you can
> override the node ID, rather than modifying the device.

OK I'll take node id check out of this patch and another patch could do
API change to use node id as you suggested.

Thanks
Vasu

