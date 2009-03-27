From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [ RFC ] igb: first draft of igb rtnl_link_ops interface for vf
 creation
Date: Fri, 27 Mar 2009 08:22:17 -0700
Message-ID: <49CCEF29.9060200@intel.com>
References: <49CAD25F.4080705@intel.com>	<20090325.201219.98810772.davem@davemloft.net>	<5f2db9d90903252027n7079ca54v76c06ec3849c65d9@mail.gmail.com> <20090325.203450.58187435.davem@davemloft.net> <49CC1E09.4010405@intel.com> <49CC6594.2080109@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:20339 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753214AbZC0PWT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Mar 2009 11:22:19 -0400
In-Reply-To: <49CC6594.2080109@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Alexander Duyck wrote:
>> In the meantime I have been working on the rtnl_link_ops approach and I 
>> think I have a few things going but I wanted to get some input before I 
>> go much further.
>>
>> First, is it ok for me to call rtnl_unlock prior to doing my settings 
>> changes on the sriov config space, followed by rtnl_lock afterwards in 
>> my newlink and dellink operations?  I ask because I had to do this in 
>> order to prevent a deadlock when the pci-hotplug events fired for the 
>> vfs and called unregister/register_netdev.
> 
> No, both functions are called with the RTNL already held. I'm not
> sure I understand what kind of potential deadlock you're trying
> to avoid. The ->newlink and ->dellink functions are called (mainly)
> in response to userspace netlink messages and there should never
> be a need to change anything related to rtnl locking.
> 
> A deadlock can happen when you call rtnl_link_unregister() while
> holding the RTNL. There's an unlocked version (__rtnl_link_unregister)
> for this case.
> 
> If that doesn't answer your question, please provide more detail.

So what I was seeing prior to changing the locking is that if I had the 
igbvf driver loaded and enabled a vf the operation would hang, and 
anything that tried to configure a network interface would hang as well.

The call to enable SR-IOV is contained within the newlink and dellink 
calls with this patch.  When I change the number of VFs it will trigger 
PCI hotplug events where it will remove all the VFs and then add them 
back.  As a result there are a number of register/unregister_netdev 
calls that are triggered by the igbvf_probe/remove calls in the igbvf 
driver.

> 
>> Second is it acceptable for me to just free the netdev at the end of 
>> newlink and call delete on the PF interface directly?  I ask because I 
>> don't have any use for the netdevs that are generated and I cannot call 
>> delete on specific VFs anyway since they are allocated/freed in LIFO 
>> order so I would always have to free the last one I allocated.
> 
> No, the newly created netdev is freed when returning an error, other
> netdevs should not be touched.

The problem is I have to alloc/free VFs in order.  See the rest of my 
comments on this below.

>> I have included a patch for review below that implements these changes 
>> against the current driver.  Please feel free to comment.
>>
>> +static int igb_new_vf(struct net_device *dev, struct nlattr *tb[],
>> +                      struct nlattr *data[])
>> +{
>> +    struct net_device *netdev;
>> +    struct igb_adapter *adapter;
>> +    int err;
>> +
>> +    netdev = __dev_get_by_index(dev_net(dev), nla_get_u32(tb[IFLA_LINK]));
>> +
>> +    if (!netdev)
>> +        return -ENODEV;
>> +   
>> +    adapter = netdev_priv(netdev);
>> +    err = igb_set_num_vfs(netdev, adapter->vfs_allocated_count + 1);
>> +    if (!err)
>> +        free_netdev(dev);
>> +
>> +    return err;
>> +
>> +}
>> +
>> +static void igb_del_vf(struct net_device *dev)
>> +{
>> +    struct igb_adapter *adapter = netdev_priv(dev);
>> +
>> +    if (adapter->vfs_allocated_count > 0)
>> +        igb_set_num_vfs(dev, adapter->vfs_allocated_count - 1);
> 
> Thats not really how this is supposed to work. Every device is an
> independant instance, so you can delete them in arbitrary order.
> If you need to assign them some device resources, you need to do
> this mapping internally.

This is where it gets messy and where we don't really have any good 
tools for this.  The problem is each VF is not independent.   If I 
remove VFs it has to be in LIFO ordering.  This is due to the fact that 
SR-IOV config space only allows you to specify a number of VFs, not the 
ordering of them, so they cannot be enabled/disabled individually.

Thanks,

Alex
