From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [net-next-2.6,	v4 1/3] ethtool: Introduce n-tuple filter
 programming support
Date: Wed, 10 Feb 2010 15:53:38 -0800 (Pacific Standard Time)
Message-ID: <Pine.WNT.4.64.1002101533340.58956@ppwaskie-MOBL2.amr.corp.intel.com>
References: <20100210100718.10855.96567.stgit@localhost.localdomain>
 <4B7296AB.6020004@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:10268 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756053Ab0BJXxh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Feb 2010 18:53:37 -0500
In-Reply-To: <4B7296AB.6020004@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 10 Feb 2010, Patrick McHardy wrote:

Thanks for the review Patrick.  Comments inline.

-PJ

> Jeff Kirsher wrote:
> > diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> > index ef4a2d8..4e9ef85 100644
> > --- a/include/linux/ethtool.h
> > +++ b/include/linux/ethtool.h
> > +struct ethtool_rx_ntuple_list {
> > +#define ETHTOOL_MAX_NTUPLE_LIST_ENTRY 1024
> > +#define ETHTOOL_MAX_NTUPLE_STRING_PER_ENTRY 14
> > +	struct list_head	list;
> > +	int			count;
> 
> unsigned int seems more appropriate.

Really?  It's a count of the number of cached filters.  Is it just so we 
don't overflow?  I don't have any strong preference, so I can update this.

> 
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index 94c1eee..4593abe 100644
> > @@ -5447,6 +5449,7 @@ EXPORT_SYMBOL(alloc_netdev_mq);
> >  void free_netdev(struct net_device *dev)
> >  {
> >  	struct napi_struct *p, *n;
> > +	struct ethtool_rx_ntuple_flow_spec_container *fsc, *f;
> >  
> >  	release_net(dev_net(dev));
> >  
> > @@ -5455,6 +5458,12 @@ void free_netdev(struct net_device *dev)
> >  	/* Flush device addresses */
> >  	dev_addr_flush(dev);
> >  
> > +	/* Clear ethtool n-tuple list */
> > +	list_for_each_entry_safe(fsc, f, &dev->ethtool_ntuple_list.list, list) {
> > +		list_del(&fsc->list);
> 
> Shouldn't the filters be freed here?

Um, yes.  Oops.  Thanks.

> 
> > +	}
> > +	dev->ethtool_ntuple_list.count = 0;
> > +
> >  	list_for_each_entry_safe(p, n, &dev->napi_list, dev_list)
> >  		netif_napi_del(p);
> >  
> > diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> > index d8aee58..fa703c6 100644
> > --- a/net/core/ethtool.c
> > +++ b/net/core/ethtool.c
> > @@ -120,7 +120,7 @@ int ethtool_op_set_ufo(struct net_device *dev, u32 data)
> >   * NETIF_F_xxx values in include/linux/netdevice.h
> >   */
> >  static const u32 flags_dup_features =
> > -	ETH_FLAG_LRO;
> > +	(ETH_FLAG_LRO | ETH_FLAG_NTUPLE);
> >  
> >  u32 ethtool_op_get_flags(struct net_device *dev)
> >  {
> > @@ -139,6 +139,11 @@ int ethtool_op_set_flags(struct net_device *dev, u32 data)
> >  	else
> >  		dev->features &= ~NETIF_F_LRO;
> >  
> > +	if (data & ETH_FLAG_NTUPLE)
> > +		dev->features |= NETIF_F_NTUPLE;
> > +	else
> > +		dev->features &= ~NETIF_F_NTUPLE;
> 
> Shouldn't this check for the real capabilities of the device first?

The userspace side does before it calls the ioctl.  It will abort with a 
-EOPNOTSUPP (just tested with igb - properly aborted).

> 
> > +static int __rx_ntuple_filter_add(struct ethtool_rx_ntuple_list *list,
> > +                                  struct ethtool_rx_ntuple_flow_spec *spec)
> > +{
> > +	struct ethtool_rx_ntuple_flow_spec_container *fsc;
> > +	int alloc_size;
> > +
> > +	/* don't add filters forever */
> > +	if (list->count >= ETHTOOL_MAX_NTUPLE_LIST_ENTRY)
> > +		return 0;
> > +
> > +	list_for_each_entry(fsc, &list->list, list) { /* run to end */ }
> 
> What does this do? fsc is allocated below, so it seems useless.

Very true.  It's unneeded.

> 
> > +
> > +	alloc_size = sizeof(*fsc);
> > +	if (alloc_size < L1_CACHE_BYTES)
> > +		alloc_size = L1_CACHE_BYTES;
> 
> Is that really necessary? I thought the filters would be offloaded
> to hardware, so I'd expect aligning them to the cache line size
> shouldn't make any difference.
> 
> > +	fsc = kmalloc(alloc_size, GFP_ATOMIC);
> > +	if (!fsc)
> > +		return -ENOMEM;
> > +
> > +	/* Copy the whole filter over */
> > +	fsc->fs.flow_type = spec->flow_type;
> > +	memcpy(&fsc->fs.h_u, &spec->h_u, sizeof(spec->h_u));
> > +	memcpy(&fsc->fs.m_u, &spec->m_u, sizeof(spec->m_u));
> > +
> > +	fsc->fs.vlan_tag = spec->vlan_tag;
> > +	fsc->fs.vlan_tag_mask = spec->vlan_tag_mask;
> > +	fsc->fs.data = spec->data;
> > +	fsc->fs.data_mask = spec->data_mask;
> > +	fsc->fs.action = spec->action;
> > +
> > +	/* add to the list */
> > +	list_add_tail_rcu(&fsc->list, &list->list);
> > +	list->count++;
> > +
> > +	return 0;
> > +}
> > +
> > +static int ethtool_get_rx_ntuple(struct net_device *dev, void __user *useraddr)
> > +{
> > +	struct ethtool_gstrings gstrings;
> > +	const struct ethtool_ops *ops = dev->ethtool_ops;
> > +	struct ethtool_rx_ntuple_flow_spec_container *fsc;
> > +	u8 *data;
> > +	char *p;
> > +	int ret, i, num_strings = 0;
> > +
> > +	if (!ops->get_sset_count)
> > +		return -EOPNOTSUPP;
> > +
> > +	if (copy_from_user(&gstrings, useraddr, sizeof(gstrings)))
> > +		return -EFAULT;
> > +
> > +	ret = ops->get_sset_count(dev, gstrings.string_set);
> > +	if (ret < 0)
> > +		return ret;
> > +
> > +	gstrings.len = ret;
> > +
> > +	data = kmalloc(gstrings.len * ETH_GSTRING_LEN, GFP_USER);
> > +	if (!data)
> > +		return -ENOMEM;
> > +
> > +	if (ops->get_rx_ntuple) {
> > +		/* driver-specific filter grab */
> > +		ret = ops->get_rx_ntuple(dev, gstrings.string_set, data);
> > +		goto copy;
> > +	}
> > +
> > +	/* default ethtool filter grab */
> > +	i = 0;
> > +	p = (char *)data;
> > +	list_for_each_entry(fsc, &dev->ethtool_ntuple_list.list, list) {
> > +		sprintf(p, "Filter %d:\n", i);
> 
> Providing a textual representation from within the kernel doesn't
> seem like a good interface to me. If userspace wants to do anything
> but simply display them, it will have to parse them again. Additionally
> it seems a driver providing a ->get_rx_ntuple() callback would have
> to duplicate the entire conversion code, which is error prone.

The goal was to give a generic way to dump what was programmed, if an 
underlying driver didn't want to implement the ->get_rx_ntuple() 
operation.  The two ways I could think of doing it was dump the list the 
way I did, and provide a strings blob to ethtool (like stats), or try and 
package the structs into a list, copy that to userspace, and let ethtool 
generate the blobs.

I agree that an underlying driver will have much of the same in terms of 
what it generates, but it will not be restricted to how it stores the 
items.  In other words, if ixgbe wanted to retrieve all 8192 filters, we 
could avoid the caching altogether, and pull directly from HW when the 
call is made from ethtool.  One way or another, there's going to be a big 
amount of copied data from kernel space to user space.  This was the 
approach I thougt would be the most useful without defining a kernel to 
userspace chain of flow spec structs.

> 
> > +		p += ETH_GSTRING_LEN;
> > +		num_strings++;
> > +
> > +		switch (fsc->fs.flow_type) {
> > +		case TCP_V4_FLOW:
> > +			sprintf(p, "\tFlow Type: TCP\n");
> > +			p += ETH_GSTRING_LEN;
> > +			num_strings++;
> > +			break;
> > +		case UDP_V4_FLOW:
> > +			sprintf(p, "\tFlow Type: UDP\n");
> > +			p += ETH_GSTRING_LEN;
> > +			num_strings++;
> > +			break;
> > +		case SCTP_V4_FLOW:
> > +			sprintf(p, "\tFlow Type: SCTP\n");
> > +			p += ETH_GSTRING_LEN;
> > +			num_strings++;
> > +			break;
> > +		case AH_ESP_V4_FLOW:
> > +			sprintf(p, "\tFlow Type: AH ESP\n");
> > +			p += ETH_GSTRING_LEN;
> > +			num_strings++;
> > +			break;
> > +		case ESP_V4_FLOW:
> > +			sprintf(p, "\tFlow Type: ESP\n");
> > +			p += ETH_GSTRING_LEN;
> > +			num_strings++;
> > +			break;
> > +		case IP_USER_FLOW:
> > +			sprintf(p, "\tFlow Type: Raw IP\n");
> > +			p += ETH_GSTRING_LEN;
> > +			num_strings++;
> > +			break;
> > +		case IPV4_FLOW:
> > +			sprintf(p, "\tFlow Type: IPv4\n");
> > +			p += ETH_GSTRING_LEN;
> > +			num_strings++;
> > +			break;
> > +		default:
> > +			sprintf(p, "\tFlow Type: Unknown\n");
> > +			p += ETH_GSTRING_LEN;
> > +			num_strings++;
> > +			goto unknown_filter;
> > +		};
> > +
> > +		/* now the rest of the filters */
> > +		switch (fsc->fs.flow_type) {
> > +		case TCP_V4_FLOW:
> > +		case UDP_V4_FLOW:
> > +		case SCTP_V4_FLOW:
> > +			sprintf(p, "\tSrc IP addr: 0x%x\n",
> > +			        fsc->fs.h_u.tcp_ip4_spec.ip4src);
> > +			p += ETH_GSTRING_LEN;
> > +			num_strings++;
> > +			sprintf(p, "\tSrc IP mask: 0x%x\n",
> > +			        fsc->fs.m_u.tcp_ip4_spec.ip4src);
> > +			p += ETH_GSTRING_LEN;
> > +			num_strings++;
> > +			sprintf(p, "\tDest IP addr: 0x%x\n",
> > +			        fsc->fs.h_u.tcp_ip4_spec.ip4dst);
> > +			p += ETH_GSTRING_LEN;
> > +			num_strings++;
> > +			sprintf(p, "\tDest IP mask: 0x%x\n",
> > +			        fsc->fs.m_u.tcp_ip4_spec.ip4dst);
> > +			p += ETH_GSTRING_LEN;
> > +			num_strings++;
> > +			sprintf(p, "\tSrc Port: %d, mask: 0x%x\n",
> > +			        fsc->fs.h_u.tcp_ip4_spec.psrc,
> > +			        fsc->fs.m_u.tcp_ip4_spec.psrc);
> > +			p += ETH_GSTRING_LEN;
> > +			num_strings++;
> > +			sprintf(p, "\tDest Port: %d, mask: 0x%x\n",
> > +			        fsc->fs.h_u.tcp_ip4_spec.pdst,
> > +			        fsc->fs.m_u.tcp_ip4_spec.pdst);
> > +			p += ETH_GSTRING_LEN;
> > +			num_strings++;
> > +			sprintf(p, "\tTOS: %d, mask: 0x%x\n",
> > +			        fsc->fs.h_u.tcp_ip4_spec.tos,
> > +			        fsc->fs.m_u.tcp_ip4_spec.tos);
> > +			p += ETH_GSTRING_LEN;
> > +			num_strings++;
> > +			break;
> > +		case AH_ESP_V4_FLOW:
> > +		case ESP_V4_FLOW:
> > +			sprintf(p, "\tSrc IP addr: 0x%x\n",
> > +			        fsc->fs.h_u.ah_ip4_spec.ip4src);
> > +			p += ETH_GSTRING_LEN;
> > +			num_strings++;
> > +			sprintf(p, "\tSrc IP mask: 0x%x\n",
> > +			        fsc->fs.m_u.ah_ip4_spec.ip4src);
> > +			p += ETH_GSTRING_LEN;
> > +			num_strings++;
> > +			sprintf(p, "\tDest IP addr: 0x%x\n",
> > +			        fsc->fs.h_u.ah_ip4_spec.ip4dst);
> > +			p += ETH_GSTRING_LEN;
> > +			num_strings++;
> > +			sprintf(p, "\tDest IP mask: 0x%x\n",
> > +			        fsc->fs.m_u.ah_ip4_spec.ip4dst);
> > +			p += ETH_GSTRING_LEN;
> > +			num_strings++;
> > +			sprintf(p, "\tSPI: %d, mask: 0x%x\n",
> > +			        fsc->fs.h_u.ah_ip4_spec.spi,
> > +			        fsc->fs.m_u.ah_ip4_spec.spi);
> > +			p += ETH_GSTRING_LEN;
> > +			num_strings++;
> > +			sprintf(p, "\tTOS: %d, mask: 0x%x\n",
> > +			        fsc->fs.h_u.ah_ip4_spec.tos,
> > +			        fsc->fs.m_u.ah_ip4_spec.tos);
> > +			p += ETH_GSTRING_LEN;
> > +			num_strings++;
> > +			break;
> > +		case IP_USER_FLOW:
> > +			sprintf(p, "\tSrc IP addr: 0x%x\n",
> > +			        fsc->fs.h_u.raw_ip4_spec.ip4src);
> > +			p += ETH_GSTRING_LEN;
> > +			num_strings++;
> > +			sprintf(p, "\tSrc IP mask: 0x%x\n",
> > +			        fsc->fs.m_u.raw_ip4_spec.ip4src);
> > +			p += ETH_GSTRING_LEN;
> > +			num_strings++;
> > +			sprintf(p, "\tDest IP addr: 0x%x\n",
> > +			        fsc->fs.h_u.raw_ip4_spec.ip4dst);
> > +			p += ETH_GSTRING_LEN;
> > +			num_strings++;
> > +			sprintf(p, "\tDest IP mask: 0x%x\n",
> > +			        fsc->fs.m_u.raw_ip4_spec.ip4dst);
> > +			p += ETH_GSTRING_LEN;
> > +			num_strings++;
> > +			break;
> > +		case IPV4_FLOW:
> > +			sprintf(p, "\tSrc IP addr: 0x%x\n",
> > +			        fsc->fs.h_u.usr_ip4_spec.ip4src);
> > +			p += ETH_GSTRING_LEN;
> > +			num_strings++;
> > +			sprintf(p, "\tSrc IP mask: 0x%x\n",
> > +			        fsc->fs.m_u.usr_ip4_spec.ip4src);
> > +			p += ETH_GSTRING_LEN;
> > +			num_strings++;
> > +			sprintf(p, "\tDest IP addr: 0x%x\n",
> > +			        fsc->fs.h_u.usr_ip4_spec.ip4dst);
> > +			p += ETH_GSTRING_LEN;
> > +			num_strings++;
> > +			sprintf(p, "\tDest IP mask: 0x%x\n",
> > +			        fsc->fs.m_u.usr_ip4_spec.ip4dst);
> > +			p += ETH_GSTRING_LEN;
> > +			num_strings++;
> > +			sprintf(p, "\tL4 bytes: 0x%x, mask: 0x%x\n",
> > +			        fsc->fs.h_u.usr_ip4_spec.l4_4_bytes,
> > +			        fsc->fs.m_u.usr_ip4_spec.l4_4_bytes);
> > +			p += ETH_GSTRING_LEN;
> > +			num_strings++;
> > +			sprintf(p, "\tTOS: %d, mask: 0x%x\n",
> > +			        fsc->fs.h_u.usr_ip4_spec.tos,
> > +			        fsc->fs.m_u.usr_ip4_spec.tos);
> > +			p += ETH_GSTRING_LEN;
> > +			num_strings++;
> > +			sprintf(p, "\tIP Version: %d, mask: 0x%x\n",
> > +			        fsc->fs.h_u.usr_ip4_spec.ip_ver,
> > +			        fsc->fs.m_u.usr_ip4_spec.ip_ver);
> > +			p += ETH_GSTRING_LEN;
> > +			num_strings++;
> > +			sprintf(p, "\tProtocol: %d, mask: 0x%x\n",
> > +			        fsc->fs.h_u.usr_ip4_spec.proto,
> > +			        fsc->fs.m_u.usr_ip4_spec.proto);
> > +			p += ETH_GSTRING_LEN;
> > +			num_strings++;
> > +			break;
> > +		};
> > +		sprintf(p, "\tVLAN: %d, mask: 0x%x\n",
> > +		        fsc->fs.vlan_tag, fsc->fs.vlan_tag_mask);
> > +		p += ETH_GSTRING_LEN;
> > +		num_strings++;
> > +		sprintf(p, "\tUser-defined: 0x%Lx\n", fsc->fs.data);
> > +		p += ETH_GSTRING_LEN;
> > +		num_strings++;
> > +		sprintf(p, "\tUser-defined mask: 0x%Lx\n", fsc->fs.data_mask);
> > +		p += ETH_GSTRING_LEN;
> > +		num_strings++;
> > +		if (fsc->fs.action == ETHTOOL_RXNTUPLE_ACTION_DROP)
> > +			sprintf(p, "\tAction: Drop\n");
> > +		else
> > +			sprintf(p, "\tAction: Direct to queue %d\n",
> > +			        fsc->fs.action);
> > +		p += ETH_GSTRING_LEN;
> > +		num_strings++;
> > +unknown_filter:
> > +		i++;
> > +	}
> > +copy:
> > +	/* indicate to userspace how many strings we actually have */
> > +	gstrings.len = num_strings;
> > +	ret = -EFAULT;
> > +	if (copy_to_user(useraddr, &gstrings, sizeof(gstrings)))
> > +		goto out;
> > +	useraddr += sizeof(gstrings);
> > +	if (copy_to_user(useraddr, data, gstrings.len * ETH_GSTRING_LEN))
> > +		goto out;
> > +	ret = 0;
> > +
> > +out:
> > +	kfree(data);
> > +	return ret;
> > +}
> > +
> >  static int ethtool_get_regs(struct net_device *dev, char __user *useraddr)
> >  {
> >  	struct ethtool_regs regs;
> > @@ -313,6 +626,12 @@ static int ethtool_reset(struct net_device *dev, char __user *useraddr)
> >  	if (copy_from_user(&reset, useraddr, sizeof(reset)))
> >  		return -EFAULT;
> >  
> > +	/* Clear ethtool n-tuple list */
> > +	list_for_each_entry_safe(fsc, f, &dev->ethtool_ntuple_list.list, list) {
> > +		list_del(&fsc->list);
> 
> This should also free the filters if I'm not mistaken.

Yes...

> 
> > +	}
> > +	dev->ethtool_ntuple_list.count = 0;
> > +
> >  	ret = dev->ethtool_ops->reset(dev, &reset.data);
> >  	if (ret)
> >  		return ret;
> > @@ -351,9 +670,17 @@ static int ethtool_set_wol(struct net_device *dev, char __user *useraddr)
> >  
> >  static int ethtool_nway_reset(struct net_device *dev)
> >  {
> > +	struct ethtool_rx_ntuple_flow_spec_container *fsc, *f;
> > +
> >  	if (!dev->ethtool_ops->nway_reset)
> >  		return -EOPNOTSUPP;
> >  
> > +	/* Clear ethtool n-tuple list */
> > +	list_for_each_entry_safe(fsc, f, &dev->ethtool_ntuple_list.list, list) {
> > +		list_del(&fsc->list);
> 
> Same here. But why are they cleared here at all? It doesn't
> seem very intuitive that filters are lost when restarting
> auto-negotiation.
>

ixgbe uses nway_reset to perform a MAC-level reset.  This is silly, but it 
affected this decision, which was a poor one.  My plan is to pull all the 
remove operations and make a helper function, and then only call it in the 
core on free_netdev().  Then the base drivers can call it where needed to 
clear their respective lists.
 
> > +	}
> > +	dev->ethtool_ntuple_list.count = 0;
> > +
> >  	return dev->ethtool_ops->nway_reset(dev);
> >  }
> 
