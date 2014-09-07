From: Raghuram Kothakota <Raghuram.Kothakota@oracle.com>
Subject: Re: [PATCH net-next v2 2/2] Re-check for a VIO_DESC_READY data descriptor after short udelay()
Date: Sun, 7 Sep 2014 12:36:11 -0700
Message-ID: <6B408DE5-566C-4B46-8257-DABB23BCC915@oracle.com>
References: <20140902162029.GC31516@oracle.com> <5405EFE7.4090302@oracle.com> <20140904.223648.559995846094457545.davem@davemloft.net> <20140905134758.GB1256@oracle.com> <20140906210253.GA5710@oracle.com> <20140907181510.GA23753@oracle.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>, david.stevens@oracle.com,
	netdev@vger.kernel.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:17751 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752010AbaIGTg2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Sep 2014 15:36:28 -0400
In-Reply-To: <20140907181510.GA23753@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for joining this thread late, please see my response below:

On Sep 7, 2014, at 11:15 AM, Sowmini Varadhan <sowmini.varadhan@oracle.com> wrote:

> 
> 
> On (09/06/14 17:02), Sowmini Varadhan wrote:
>> Date: Sat, 6 Sep 2014 17:02:53 -0400
>> From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
>> To: David Miller <davem@davemloft.net>
>> Cc: david.stevens@oracle.com, netdev@vger.kernel.org
>> Subject: Re: [PATCH net-next v2 2/2] Re-check for a VIO_DESC_READY data
>> descriptor after short udelay()
>> User-Agent: Mutt/1.5.21 (2010-09-15)
>> 
>> On (09/05/14 09:47), Sowmini Varadhan wrote:
>>>> The memory barrier exists in order to make sure the cookies et al. are
>>>> globally visible before the VIO_DESC_READY.  We don't want stores to
>>>> be reordered such that the VIO_DESC_READY is seen too early.
>>> 
>>> Ok, though David (dls) was just pointing out that a rmb() might
>>> be missing in vnet_walk_rx_one() before checking for READY descriptor
>> 
>> Stared at this a bit over the last two days, checked
>> the documentation, discussed with dls offline - looks like 
>> (a) the rmb() thing was mostly a red-herring/fud 
>> (b) we do need the wmb()
>> 
>> The wmb() part is working correctly as designed:
>> 
>> The producer will do
>>  /* code to set up cookies */
>>  wmb(); /* makes sure above changes are committed */
>>  d->hdr.state = VIO_DESC_READY;
>> 

Yeah, we need the producer memory barrier before setting
the descriptor state to ready. This ensures both data in the buffers
and other fields in the descriptor are flushed before the state
is visible to the consumer.  I do not believe the HV trap caused
by the trigger performs any sync of the store buffers.

>> the consumer will do
>> 
>>        if (desc->hdr.state != VIO_DESC_READY)
>>                return 1;
>>        err = vnet_rx_one(port, desc->size, desc->cookies, desc->ncookies);
>>                :
>>        desc->hdr.state = VIO_DESC_DONE;
>> 
>> So the vnet_rx_one() will only use valid cookie information at
>> all times.
>> 
>> This allows the code to correctly able to read multiple READY descriptors 
>> for a single LDC trigger, which it already does today.
>> (and it would be needlessly inefficient to clamp this down to
>> only one descriptor read per LDC-start in the vnet_rx())


Note, LDC message infrastructure is not a high performance infrastructure,
relying on an ldc message for each packet can greatly impact performance.
We need to reduce as many ldc messages as possible and rely on the
ring  more to pick up as many packets as possible without ldc messages.

The current implementation of vnet_start_xmit() performs all operations
such as grabbing a descriptor, copying the data into the data buffers
and updating the descriptor with in the same lock. This limits the parallelism
on the transmit path especially because the data copy operation is a bigger
operation and blocks other transmitters more than it is needed.  It is 
possible to split these operations where multiple transmitters can grab
descriptors in sequence but perform the copy operation in parallel.  When
this accomplished, there will be more possibility of racing with descriptors
getting ready quickly in a burst traffic situations. I believe the  udelay()
introduced in this patch will help even more when the transmitters are highly parallel.


-Raghuram
>> So what (if any) is the outstanding question about wmb() at this 
>> point?
>> 
>> --Sowmini
>> 
>> 
>> 
>> 
>> 
>> 
>> 
>> 
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
