From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC PATCH 2/3] net: expose ebridge FDB with priv flag IFF_OFFLOADED_FDB
Date: Mon, 05 Mar 2012 19:34:49 -0800
Message-ID: <4F5585D9.5080501@intel.com>
References: <20120229070418.10937.8692.stgit@jf-dev1-dcblab>  <20120229071719.10937.68718.stgit@jf-dev1-dcblab> <1330718193.2611.36.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, shemminger@vyatta.com, kernel@wantstofly.org,
	hadi@cyberus.ca, roprabhu@cisco.com, mst@redhat.com,
	netdev@vger.kernel.org, gregory.v.rose@intel.com,
	davem@davemloft.net
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:64085 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757214Ab2CFDew (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2012 22:34:52 -0500
In-Reply-To: <1330718193.2611.36.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/2/2012 11:56 AM, Ben Hutchings wrote:
> On Tue, 2012-02-28 at 23:17 -0800, John Fastabend wrote:
>> This adds a new private interface flag IFF_OFFLOADED_FDB and an
>> additional ndmsg flag NTF_EMBEDDED.
>>
>> The private flag IFF_OFFLOADED_FDB should be set on devices to
>> indicate an embedded bridging component exists with a forwarding
>> database.
>>
>> With this set PF_BRIDGE:{RTM_NEWNEIGH|RTM_DELNEIGH|RTM_GETNEIGH}
>> netlink msgs can manage the unicast address list on these devices
>> by setting the NTF_EMBEDDED flag in ndm_flags.
>>
>> These commands are compatible with the SW bridge allowing the same
>> user space tools to be used with both SW bridges and HW bridges.
> [...]
>> index 9e70191..7b1a581 100644
>> --- a/net/bridge/br_netlink.c
>> +++ b/net/bridge/br_netlink.c
>> @@ -211,6 +211,57 @@ static int br_validate(struct nlattr *tb[], struct nlattr *data[])
>>  	return 0;
>>  }
>>  
>> +static int rtnl_offloaded_fdb_add(struct nlmsghdr *nlh, struct net_device *dev)
>> +{
>> +	struct ndmsg *ndm;
>> +	struct netdev_hw_addr *ha;
>> +	struct nlattr *tb[NDA_MAX+1];
>> +	__u8 *addr;
>> +	int err;
>> +
>> +	ASSERT_RTNL();
>> +
>> +	if (!(dev->priv_flags & IFF_OFFLOADED_FDB))
>> +		return -ENODEV;
> 
> EOPNOTSUPP
> 

Right thanks.

[...]

>> +	if (is_multicast_ether_addr(addr))
>> +		return -EINVAL;
> 
> There is a pending change to the ndo_validate_addr interface which I
> think would allow us to replace the Ethernet-specific checks with a
> check against dev->addr_len and a call to ndo_validate_addr.  Not that I
> really care about anything other than Ethernet, but it would be a little
> more elegant.
> 
>> +	netif_addr_lock_bh(dev);
>> +	list_for_each_entry(ha, &dev->uc.list, list) {
>> +		if (!compare_ether_addr(ha->addr, addr)) {
>> +			netif_addr_unlock_bh(dev);
>> +			return -EEXIST;
>> +		}
>> +	}
>> +	netif_addr_unlock_bh(dev);
>> +
>> +	err = dev_uc_add(dev, addr);
> [...]
> 
> The software bridge makes the duplicate check conditional on NLM_F_EXCL.
> Shouldn't this be consistent?

Agreed it should be consistent.

> 
> Also, this seems racy.  If all manipulation of the UC address list is
> serialised by RTNL (which I think in practice it is) then there is no
> race and we also don't need to take the netif_addr_lock(), but if we're
> not allowed to assume that then we shouldn't drop the lock.  Perhaps the
> check can be moved into a dev_uc_add_exclusive() or something like that.
> 

Yep I'll at least make this consistent with other usages. And maybe a
follow up patch to clean up the usage throughout.

Thanks,
John
