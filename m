From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next-2.6 PATCH v2] net: implement mechanism for HW based
 QOS
Date: Tue, 21 Dec 2010 11:15:17 -0800
Message-ID: <4D10FCC5.9000407@intel.com>
References: <20101217165622.26608.24819.stgit@jf-dev1-dcblab> <1292885287.3055.22.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hadi@cyberus.ca" <hadi@cyberus.ca>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:8652 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751493Ab0LUTPS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Dec 2010 14:15:18 -0500
In-Reply-To: <1292885287.3055.22.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/20/2010 2:48 PM, Ben Hutchings wrote:
> On Fri, 2010-12-17 at 08:56 -0800, John Fastabend wrote:
> [...]
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index cc916c5..c5d7949 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -646,6 +646,12 @@ struct xps_dev_maps {
>>      (nr_cpu_ids * sizeof(struct xps_map *)))
>>  #endif /* CONFIG_XPS */
>>  
>> +/* HW offloaded queuing disciplines txq count and offset maps */
>> +struct netdev_tc_txq {
>> +	u16 count;
>> +	u16 offset;
>> +};
>> +
>>  /*
>>   * This structure defines the management hooks for network devices.
>>   * The following hooks can be defined; unless noted otherwise, they are
>> @@ -1146,6 +1152,9 @@ struct net_device {
>>  	/* Data Center Bridging netlink ops */
>>  	const struct dcbnl_rtnl_ops *dcbnl_ops;
>>  #endif
>> +	u8 num_tc;
>> +	struct netdev_tc_txq tc_to_txq[16];
>> +	u8 prio_tc_map[16];
> 
> That seems like a fair amount of data to add to every net device,
> considering that users may create e.g. a lot of VLAN devices and they
> won't use this state at all.  Have you considered putting these in a
> structure that is accessed indirectly?

This was Eric's suggestion per his response saves an indirection and avoids false sharing. 

> 
>>  #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
>>  	/* max exchange id for FCoE LRO by ddp */
>> @@ -1162,6 +1171,57 @@ struct net_device {
>>  #define	NETDEV_ALIGN		32
>>  
>>  static inline
>> +int netdev_get_prio_tc_map(const struct net_device *dev, u32 prio)
>> +{
>> +	return dev->prio_tc_map[prio & 15];
>> +}
>> +
>> +static inline
>> +int netdev_set_prio_tc_map(struct net_device *dev, u8 prio, u8 tc)
>> +{
>> +	if (tc >= dev->num_tc)
>> +		return -EINVAL;
>> +
>> +	dev->prio_tc_map[prio & 15] = tc & 15;
>> +	return 0;
>> +}
> [...]
> 
> Please name the magic numbers 15 and 16.
> 

TC_MAX_QUEUES and TC_BITMASK should work. Thanks for looking over this.

> Ben.
> 

