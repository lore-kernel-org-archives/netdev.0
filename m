From: Andrew Bennieston <andrew.bennieston@citrix.com>
Subject: Re: [PATCH V6 net-next 2/5] xen-netback: Add support for multiple
 queues
Date: Tue, 18 Mar 2014 10:48:12 +0000
Message-ID: <5328246C.6060502@citrix.com>
References: <1393847269-6981-1-git-send-email-andrew.bennieston@citrix.com>	 <1393847269-6981-3-git-send-email-andrew.bennieston@citrix.com> <1394813004.6442.133.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xenproject.org>, <wei.liu2@citrix.com>,
	<paul.durrant@citrix.com>, <netdev@vger.kernel.org>,
	<david.vrabel@citrix.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:51918 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754695AbaCRKsO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Mar 2014 06:48:14 -0400
In-Reply-To: <1394813004.6442.133.camel@kazak.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/03/14 16:03, Ian Campbell wrote:
> On Mon, 2014-03-03 at 11:47 +0000, Andrew J. Bennieston wrote:
>> From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
>>
>> Builds on the refactoring of the previous patch to implement multiple
>> queues between xen-netfront and xen-netback.
>>
>> Writes the maximum supported number of queues into XenStore, and reads
>> the values written by the frontend to determine how many queues to use.
>
>>
>> Ring references and event channels are read from XenStore on a per-queue
>> basis and rings are connected accordingly.
>>
>> Signed-off-by: Andrew J. Bennieston <andrew.bennieston@citrix.com>
>> Reviewed-by: Paul Durrant <paul.durrant@citrix.com>
>> ---
>>   drivers/net/xen-netback/common.h    |    2 +
>>   drivers/net/xen-netback/interface.c |    7 +++-
>>   drivers/net/xen-netback/netback.c   |    8 ++++
>>   drivers/net/xen-netback/xenbus.c    |   76 ++++++++++++++++++++++++++++++-----
>>   4 files changed, 82 insertions(+), 11 deletions(-)
>>
>> diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
>> index 4176539..e72bf38 100644
>> --- a/drivers/net/xen-netback/common.h
>> +++ b/drivers/net/xen-netback/common.h
>> @@ -261,4 +261,6 @@ void xenvif_carrier_on(struct xenvif *vif);
>>
>>   extern bool separate_tx_rx_irq;
>>
>> +extern unsigned int xenvif_max_queues;
>> +
>>   #endif /* __XEN_NETBACK__COMMON_H__ */
>> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
>> index 0297980..3f623b4 100644
>> --- a/drivers/net/xen-netback/interface.c
>> +++ b/drivers/net/xen-netback/interface.c
>> @@ -381,7 +381,12 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
>>   	char name[IFNAMSIZ] = {};
>>
>>   	snprintf(name, IFNAMSIZ - 1, "vif%u.%u", domid, handle);
>> -	dev = alloc_netdev_mq(sizeof(struct xenvif), name, ether_setup, 1);
>> +	/* Allocate a netdev with the max. supported number of queues.
>> +	 * When the guest selects the desired number, it will be updated
>> +	 * via netif_set_real_num_tx_queues().
>
> Does this allocate and then waste a load of resources? Or does it free
> them when you shrink things?
It allocates a small amount of resource; each struct netdev_queue is 256
bytes, and there are a few other things allocated at the same time. For
a xenvif_max_queues of 8, this is allocating 2K of netdev_queue
structs, plus a few other things; pretty small compared to the struct
xenvif_queue objects and the arrays contained within!

The resources aren't freed when netif_set_real_num_tx_queues() is
called; that just changes the value of dev->real_num_tx_queues.

> I suppose it is not possible to allocate small and grow or you'd have
> done so?
Indeed. This approach is taken by most drivers that support multiple
queues; they allocate as many as the device has, then use only as many
as there are online CPUs, or similar. In this case, xenvif_max_queues is
initialised to num_online_cpus(), but is also exported as a module
param. so the memory-conscious admin can reduce it further if desired.

>
> Can the host/guest admin change the number of queues on the fly?

This depends what you mean by 'on the fly'. The host admin can set the
module parameter in dom0, which will affect guests started after that
point, or the guest admin can set the module param in the guest. The
actual number used is always the minimum of the two.

It's important to keep in mind the distinction between a netdev_queue
and a xenvif_queue; a netdev_queue is small, but you have to allocate as
many as you think you might need, at a point in time too early to be
able to ask the guest how many it wants to use. A xenvif_queue is large,
but we only allocate as many as will actually be used.

>
>>   	xen_net_read_rate(dev, &credit_bytes, &credit_usec);
>>   	read_xenbus_vif_flags(be);
>>
>> -	be->vif->num_queues = 1;
>> +	/* Use the number of queues requested by the frontend */
>> +	be->vif->num_queues = requested_num_queues;
>>   	be->vif->queues = vzalloc(be->vif->num_queues *
>>   			sizeof(struct xenvif_queue));
>> +	rtnl_lock();
>> +	netif_set_real_num_tx_queues(be->vif->dev, be->vif->num_queues);
>> +	rtnl_unlock();
>
> I'm always a bit suspicious of this construct -- it makes me thing the
> call is happening from the wrong context and that the right context
> would naturally hold the lock already.

netif_set_real_num_tx_queues() must be called either with this lock
held, or before the netdev is registered. The netdev is registered early
so that it can be plugged into a bridge or whatever other network
configuration has to happen. The point at which we know the correct
number of tx queues happens in response to the frontend changing
Xenstore entries, so the rtnl lock is not naturally held here.
xenvif_carrier_on() and xenvif_carrier_off() also take this lock, but
they are not the appropriate place to set the number of queues.

>
>>
>>   	for (queue_index = 0; queue_index < be->vif->num_queues; ++queue_index) {
>>   		queue = &be->vif->queues[queue_index];
>> @@ -547,29 +575,52 @@ static int connect_rings(struct backend_info *be, struct xenvif_queue *queue)
>>   	unsigned long tx_ring_ref, rx_ring_ref;
>>   	unsigned int tx_evtchn, rx_evtchn;
>>   	int err;
>> +	char *xspath;
>> +	size_t xspathsize;
>> +	const size_t xenstore_path_ext_size = 11; /* sufficient for "/queue-NNN" */
>> +
>> +	/* If the frontend requested 1 queue, or we have fallen back
>> +	 * to single queue due to lack of frontend support for multi-
>> +	 * queue, expect the remaining XenStore keys in the toplevel
>> +	 * directory. Otherwise, expect them in a subdirectory called
>> +	 * queue-N.
>> +	 */
>> +	if (queue->vif->num_queues == 1) {
>> +		xspath = (char *)dev->otherend;
>
> Casting away a const is naughty. Either make xspath const or if that
> isn't possible make it dynamic in all cases with a strcpy in this
> degenerate case.
>

Ok, I can change this. I was trying to avoid the strcpy.

>> +	} else {
>> +		xspathsize = strlen(dev->otherend) + xenstore_path_ext_size;
>> +		xspath = kzalloc(xspathsize, GFP_KERNEL);
>> +		if (!xspath) {
>> +			xenbus_dev_fatal(dev, -ENOMEM,
>> +					"reading ring references");
>> +			return -ENOMEM;
>> +		}
>> +		snprintf(xspath, xspathsize, "%s/queue-%u", dev->otherend,
>> +				 queue->id);
>> +	}
>>
> [...]
>> @@ -582,10 +633,15 @@ static int connect_rings(struct backend_info *be, struct xenvif_queue *queue)
>>   				 "mapping shared-frames %lu/%lu port tx %u rx %u",
>>   				 tx_ring_ref, rx_ring_ref,
>>   				 tx_evtchn, rx_evtchn);
>> -		return err;
>> +		goto err;
>>   	}
>>
>> -	return 0;
>> +	err = 0;
>> +err: /* Regular return falls through with err == 0 */
>> +	if (xspath != dev->otherend)
>> +		kfree(xspath);
>
> Yet another reason to not cast away the const!

You're right; this is a little messy.

Andrew

>
>> +
>> +	return err;
>>   }
>>
>>   static int read_xenbus_vif_flags(struct backend_info *be)
>
>
