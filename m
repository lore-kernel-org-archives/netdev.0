From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next-2.6 PATCH v6 1/2] net: implement mechanism for HW based
 QOS
Date: Fri, 07 Jan 2011 14:48:13 -0800
Message-ID: <4D27982D.6080002@intel.com>
References: <20110107031211.2446.35715.stgit@jf-dev1-dcblab> <20110107214645.GB2050@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"hadi@cyberus.ca" <hadi@cyberus.ca>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:57713 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754914Ab1AGWsP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jan 2011 17:48:15 -0500
In-Reply-To: <20110107214645.GB2050@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/7/2011 1:46 PM, Jarek Poplawski wrote:
> On Thu, Jan 06, 2011 at 07:12:11PM -0800, John Fastabend wrote:
>> This patch provides a mechanism for lower layer devices to
>> steer traffic using skb->priority to tx queues. This allows
>> for hardware based QOS schemes to use the default qdisc without
>> incurring the penalties related to global state and the qdisc
>> lock. While reliably receiving skbs on the correct tx ring
>> to avoid head of line blocking resulting from shuffling in
>> the LLD. Finally, all the goodness from txq caching and xps/rps
>> can still be leveraged.
>>
>> Many drivers and hardware exist with the ability to implement
>> QOS schemes in the hardware but currently these drivers tend
>> to rely on firmware to reroute specific traffic, a driver
>> specific select_queue or the queue_mapping action in the
>> qdisc.
>>
>> By using select_queue for this drivers need to be updated for
>> each and every traffic type and we lose the goodness of much
>> of the upstream work. Firmware solutions are inherently
>> inflexible. And finally if admins are expected to build a
>> qdisc and filter rules to steer traffic this requires knowledge
>> of how the hardware is currently configured. The number of tx
>> queues and the queue offsets may change depending on resources.
>> Also this approach incurs all the overhead of a qdisc with filters.
>>
>> With the mechanism in this patch users can set skb priority using
>> expected methods ie setsockopt() or the stack can set the priority
>> directly. Then the skb will be steered to the correct tx queues
>> aligned with hardware QOS traffic classes. In the normal case with
>> a single traffic class and all queues in this class everything
>> works as is until the LLD enables multiple tcs.
>>
>> To steer the skb we mask out the lower 4 bits of the priority
>> and allow the hardware to configure upto 15 distinct classes
>> of traffic. This is expected to be sufficient for most applications
>> at any rate it is more then the 8021Q spec designates and is
>> equal to the number of prio bands currently implemented in
>> the default qdisc.
>>
>> This in conjunction with a userspace application such as
>> lldpad can be used to implement 8021Q transmission selection
>> algorithms one of these algorithms being the extended transmission
>> selection algorithm currently being used for DCB.
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---
>>
>>  include/linux/netdevice.h |   65 +++++++++++++++++++++++++++++++++++++++++++++
>>  net/core/dev.c            |   52 +++++++++++++++++++++++++++++++++++-
>>  2 files changed, 116 insertions(+), 1 deletions(-)
>>
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index 0f6b1c9..12fff42 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -646,6 +646,14 @@ struct xps_dev_maps {
>>      (nr_cpu_ids * sizeof(struct xps_map *)))
>>  #endif /* CONFIG_XPS */
>>  
>> +#define TC_MAX_QUEUE	16
>> +#define TC_BITMASK	15
>> +/* HW offloaded queuing disciplines txq count and offset maps */
>> +struct netdev_tc_txq {
>> +	u16 count;
>> +	u16 offset;
>> +};
>> +
>>  /*
>>   * This structure defines the management hooks for network devices.
>>   * The following hooks can be defined; unless noted otherwise, they are
>> @@ -756,6 +764,7 @@ struct xps_dev_maps {
>>   * int (*ndo_set_vf_port)(struct net_device *dev, int vf,
>>   *			  struct nlattr *port[]);
>>   * int (*ndo_get_vf_port)(struct net_device *dev, int vf, struct sk_buff *skb);
>> + * void (*ndo_setup_tc)(struct net_device *dev, u8 tc)
> 
> ..., unsigned int txq) ?
> 
>>   */
>>  #define HAVE_NET_DEVICE_OPS
>>  struct net_device_ops {
>> @@ -814,6 +823,8 @@ struct net_device_ops {
>>  						   struct nlattr *port[]);
>>  	int			(*ndo_get_vf_port)(struct net_device *dev,
>>  						   int vf, struct sk_buff *skb);
>> +	int			(*ndo_setup_tc)(struct net_device *dev, u8 tc,
>> +						unsigned int txq);
> 
> ...
>> +/* netif_setup_tc - Handle tc mappings on real_num_tx_queues change
>> + * @dev: Network device
>> + * @txq: number of queues available
>> + *
>> + * If real_num_tx_queues is changed the tc mappings may no longer be
>> + * valid. To resolve this if the net_device supports ndo_setup_tc
>> + * call the ops routine with the new queue number. If the ops is not
>> + * available verify the tc mapping remains valid and if not NULL the
>> + * mapping. With no priorities mapping to this offset/count pair it
>> + * will no longer be used. In the worst case TC0 is invalid nothing
>> + * can be done so disable priority mappings.
>> + */
>> +void netif_setup_tc(struct net_device *dev, unsigned int txq)
>> +{
>> +	const struct net_device_ops *ops = dev->netdev_ops;
>> +
>> +	if (ops->ndo_setup_tc) {
>> +		ops->ndo_setup_tc(dev, dev->num_tc, txq);
>> +	} else {
>> +		int i;
>> +		struct netdev_tc_txq *tc = &dev->tc_to_txq[0];
>> +
>> +		/* If TC0 is invalidated disable TC mapping */
>> +		if (tc->offset + tc->count > txq) {
>> +			dev->num_tc = 0;
>> +			return;
>> +		}
>> +
>> +		/* Invalidated prio to tc mappings set to TC0 */
>> +		for (i = 1; i < TC_BITMASK + 1; i++) {
>> +			int q = netdev_get_prio_tc_map(dev, i);
> 
> (empty line)
> Btw, probably some warning should be logged on config change here.
> 

OK maybe I should see about making at least my local checkpatch script
look for this. Also added pr_warnings here.

>> +			tc = &dev->tc_to_txq[q];
>> +
>> +			if (tc->offset + tc->count > txq)
>> +				netdev_set_prio_tc_map(dev, i, 0);
>> +		}
>> +	}
>> +}
>> +
>>  /*
>>   * Routine to help set real_num_tx_queues. To avoid skbs mapped to queues
>>   * greater then real_num_tx_queues stale skbs on the qdisc must be flushed.
>> @@ -1614,6 +1653,9 @@ int netif_set_real_num_tx_queues(struct net_device *dev, unsigned int txq)
>>  
>>  		if (txq < dev->real_num_tx_queues)
>>  			qdisc_reset_all_tx_gt(dev, txq);
>> +
>> +		if (dev->num_tc)
>> +			netif_setup_tc(dev, txq);
> 
> Should be before qdisc_reset_all_tx_gt (above).
> 
> Jarek P.

I will fix this. Thanks!

