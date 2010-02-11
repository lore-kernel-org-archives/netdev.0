From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [net-next-2.6,	v4 1/3] ethtool: Introduce n-tuple filter
 programming support
Date: Wed, 10 Feb 2010 23:07:07 -0800
Message-ID: <1265872027.4501.97.camel@localhost>
References: <20100210100718.10855.96567.stgit@localhost.localdomain>
	 <4B7296AB.6020004@trash.net>
	 <Pine.WNT.4.64.1002101533340.58956@ppwaskie-MOBL2.amr.corp.intel.com>
	 <4B73A0BE.1060407@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:47577 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751477Ab0BKHHH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Feb 2010 02:07:07 -0500
In-Reply-To: <4B73A0BE.1060407@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-02-10 at 22:16 -0800, Patrick McHardy wrote:
> Waskiewicz Jr, Peter P wrote:
> > On Wed, 10 Feb 2010, Patrick McHardy wrote:
> > 
> > Thanks for the review Patrick.  Comments inline.
> > 
> > -PJ
> > 
> >> Jeff Kirsher wrote:
> >>> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> >>> index ef4a2d8..4e9ef85 100644
> >>> --- a/include/linux/ethtool.h
> >>> +++ b/include/linux/ethtool.h
> >>> +struct ethtool_rx_ntuple_list {
> >>> +#define ETHTOOL_MAX_NTUPLE_LIST_ENTRY 1024
> >>> +#define ETHTOOL_MAX_NTUPLE_STRING_PER_ENTRY 14
> >>> +	struct list_head	list;
> >>> +	int			count;
> >> unsigned int seems more appropriate.
> > 
> > Really?  It's a count of the number of cached filters.  Is it just so we 
> > don't overflow?  I don't have any strong preference, so I can update this.
> 
> Mainly because I don't think we can have a negative number
> of filters :)

Heh, good point.

> >>>  u32 ethtool_op_get_flags(struct net_device *dev)
> >>>  {
> >>> @@ -139,6 +139,11 @@ int ethtool_op_set_flags(struct net_device *dev, u32 data)
> >>>  	else
> >>>  		dev->features &= ~NETIF_F_LRO;
> >>>  
> >>> +	if (data & ETH_FLAG_NTUPLE)
> >>> +		dev->features |= NETIF_F_NTUPLE;
> >>> +	else
> >>> +		dev->features &= ~NETIF_F_NTUPLE;
> >> Shouldn't this check for the real capabilities of the device first?
> > 
> > The userspace side does before it calls the ioctl.  It will abort with a 
> > -EOPNOTSUPP (just tested with igb - properly aborted).
> 
> I think this check belongs into the kernel. You already have these
> two checks in ethtool_set_rx_ntuple():

Ok, I see your point.

> > +	if (!ops->set_rx_ntuple)
> > +		return -EOPNOTSUPP;
> > +
> > +	if (!(dev->features & NETIF_F_NTUPLE))
> > +		return -EINVAL;
> 
> Moving the check for ops->set_rx_ntuple to ethtool_op_set_flags()
> should be enough.

Dave wants me to fix up the caching, I'll look at including this in the
same patchset.  It will also require checks in other drivers that
implement their own set_flags (like ixgbe) to take into account the
ethtool_op_set_flags() return code.  ixgbe currently doesn't, which is
not correct.

> >>> +static int ethtool_get_rx_ntuple(struct net_device *dev, void __user *useraddr)
> >>> +{
> >>> +	struct ethtool_gstrings gstrings;
> >>> +	const struct ethtool_ops *ops = dev->ethtool_ops;
> >>> +	struct ethtool_rx_ntuple_flow_spec_container *fsc;
> >>> +	u8 *data;
> >>> +	char *p;
> >>> +	int ret, i, num_strings = 0;
> >>> +
> >>> +	if (!ops->get_sset_count)
> >>> +		return -EOPNOTSUPP;
> >>> +
> >>> +	if (copy_from_user(&gstrings, useraddr, sizeof(gstrings)))
> >>> +		return -EFAULT;
> >>> +
> >>> +	ret = ops->get_sset_count(dev, gstrings.string_set);
> >>> +	if (ret < 0)
> >>> +		return ret;
> >>> +
> >>> +	gstrings.len = ret;
> >>> +
> >>> +	data = kmalloc(gstrings.len * ETH_GSTRING_LEN, GFP_USER);
> >>> +	if (!data)
> >>> +		return -ENOMEM;
> >>> +
> >>> +	if (ops->get_rx_ntuple) {
> >>> +		/* driver-specific filter grab */
> >>> +		ret = ops->get_rx_ntuple(dev, gstrings.string_set, data);
> >>> +		goto copy;
> >>> +	}
> >>> +
> >>> +	/* default ethtool filter grab */
> >>> +	i = 0;
> >>> +	p = (char *)data;
> >>> +	list_for_each_entry(fsc, &dev->ethtool_ntuple_list.list, list) {
> >>> +		sprintf(p, "Filter %d:\n", i);
> >> Providing a textual representation from within the kernel doesn't
> >> seem like a good interface to me. If userspace wants to do anything
> >> but simply display them, it will have to parse them again. Additionally
> >> it seems a driver providing a ->get_rx_ntuple() callback would have
> >> to duplicate the entire conversion code, which is error prone.
> > 
> > The goal was to give a generic way to dump what was programmed, if an 
> > underlying driver didn't want to implement the ->get_rx_ntuple() 
> > operation.  The two ways I could think of doing it was dump the list the 
> > way I did, and provide a strings blob to ethtool (like stats), or try and 
> > package the structs into a list, copy that to userspace, and let ethtool 
> > generate the blobs.
> > 
> > I agree that an underlying driver will have much of the same in terms of 
> > what it generates, but it will not be restricted to how it stores the 
> > items.  In other words, if ixgbe wanted to retrieve all 8192 filters, we 
> > could avoid the caching altogether, and pull directly from HW when the 
> > call is made from ethtool.  One way or another, there's going to be a big 
> > amount of copied data from kernel space to user space.  This was the 
> > approach I thougt would be the most useful without defining a kernel to 
> > userspace chain of flow spec structs.
> 
> My main concern is that its hard for userspace to do anything with
> this data except print it. By using a binary representation the
> kernel code should get simpler and less prone to potential
> inconsistencies within drivers and make it more useful to userspace
> at the same time.

It would be easier to change ethtool in userspace to reformat data.
However, some drivers/hardware may represent data in a different way for
their filters, much like the ethtool stats (ethtool -S).  I see this as
a hardware-specific thing, so letting the kernel provide the strings is
the most flexible, since it's the most representative of the hardware.

Cheers,
-PJ

