From: Igor Druzhinin <igor.druzhinin@citrix.com>
Subject: Re: [PATCH] xen-netback: fix memory leaks on XenBus disconnect
Date: Fri, 13 Jan 2017 11:06:33 +0000
Message-ID: <2447fe0c-cfae-a77b-2468-db22bb709163@citrix.com>
References: <1484243516-141100-1-git-send-email-igor.druzhinin@citrix.com>
 <20170113103800.GA5089@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xenproject.org>, <paul.durrant@citrix.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([185.25.65.24]:62152 "EHLO
        SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751373AbdAMLHD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 06:07:03 -0500
In-Reply-To: <20170113103800.GA5089@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/01/17 10:38, Wei Liu wrote:
> On Thu, Jan 12, 2017 at 05:51:56PM +0000, Igor Druzhinin wrote:
>> Eliminate memory leaks introduced several years ago by cleaning the queue
>> resources which are allocated on XenBus connection event. Namely, queue
>> structure array and pages used for IO rings.
>> vif->lock is used to protect statistics gathering agents from using the
>> queue structure during cleaning.
>>
> 
> There is code in netback_remove which eventually calls xenvif_free to
> free up the resources, maybe you should modify xenvif_free instead? That
> seems more symmetric to me. What do you think?
> 
>> Signed-off-by: Igor Druzhinin <igor.druzhinin@citrix.com>
>> ---
>>  drivers/net/xen-netback/interface.c |  6 ++++--
>>  drivers/net/xen-netback/xenbus.c    | 13 +++++++++++++
>>  2 files changed, 17 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
>> index e30ffd2..5795213 100644
>> --- a/drivers/net/xen-netback/interface.c
>> +++ b/drivers/net/xen-netback/interface.c
>> @@ -221,18 +221,18 @@ static struct net_device_stats *xenvif_get_stats(struct net_device *dev)
>>  {
>>  	struct xenvif *vif = netdev_priv(dev);
>>  	struct xenvif_queue *queue = NULL;
>> -	unsigned int num_queues = vif->num_queues;
>>  	unsigned long rx_bytes = 0;
>>  	unsigned long rx_packets = 0;
>>  	unsigned long tx_bytes = 0;
>>  	unsigned long tx_packets = 0;
>>  	unsigned int index;
>>  
>> +	spin_lock(&vif->lock);
>>  	if (vif->queues == NULL)
>>  		goto out;
>>  
>>  	/* Aggregate tx and rx stats from each queue */
>> -	for (index = 0; index < num_queues; ++index) {
>> +	for (index = 0; index < vif->num_queues; ++index) {
>>  		queue = &vif->queues[index];
>>  		rx_bytes += queue->stats.rx_bytes;
>>  		rx_packets += queue->stats.rx_packets;
>> @@ -241,6 +241,8 @@ static struct net_device_stats *xenvif_get_stats(struct net_device *dev)
>>  	}
>>  
>>  out:
>> +	spin_unlock(&vif->lock);
>> +
> 
> Good catch, this is definitely needed. And it would probably be in a
> separate patch.

I suggest we also need to have this spinlock acquired in another part
of cleaning code (xenvif_free). The reason to introduce it is a locking
practice in openvswitch when they don't grab any network subsystem locks
(rtnl_lock) in order to gather the statistics. I'm not sure that it's
correct behavior. Anyone can advise?

> Wei.
> 
