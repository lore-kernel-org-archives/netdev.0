From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH net-next v4 2/3] net-timestamp: Make the clone operation
 stand-alone from phy timestamping
Date: Thu, 04 Sep 2014 11:30:31 -0700
Message-ID: <5408AFC7.70709@intel.com>
References: <20140904172906.7702.87598.stgit@ahduyck-bv4.jf.intel.com> <20140904173116.7702.30877.stgit@ahduyck-bv4.jf.intel.com> <5408A60A.3070603@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, davem@davemloft.net, willemb@google.com
To: Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:4279 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751620AbaIDSa7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Sep 2014 14:30:59 -0400
In-Reply-To: <5408A60A.3070603@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/04/2014 10:48 AM, Rick Jones wrote:
> On 09/04/2014 10:31 AM, Alexander Duyck wrote:
>
>>
>> ---
>>
>> v2: Renamed function to skb_clone_sk.
>>      Added destructor to call sock_put instead of doing it ourselves.
>>      Dropped freeing functionality from skb_complete_tx_timestamp.
>>      Added additional documentation to the code.
>>
>> v3: Renamed destructor sock_efree and moved to sock.c/h
>>      Added sock_hold/sock_put around call to sock_queue_err_skb
>>
>> v4: Dropped combining sock_edemux with sock_efree where the 2 are
>> identical
>>
>>   drivers/net/phy/dp83640.c |    6 +++---
>>   include/linux/skbuff.h    |    2 ++
>>   include/net/sock.h        |    1 +
>>   net/core/skbuff.c         |   32 +++++++++++++++++++++++++-------
>>   net/core/sock.c           |    6 ++++++
>>   net/core/timestamping.c   |   14 +++-----------
>>   6 files changed, 40 insertions(+), 21 deletions(-)
>>
>> diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
>> index d5991ac..87648b3 100644
>> --- a/drivers/net/phy/dp83640.c
>> +++ b/drivers/net/phy/dp83640.c
>> @@ -1148,7 +1148,7 @@ static void dp83640_remove(struct phy_device
>> *phydev)
>>           kfree_skb(skb);
>>
>>       while ((skb = skb_dequeue(&dp83640->tx_queue)) != NULL)
>> -        skb_complete_tx_timestamp(skb, NULL);
>> +        kfree_skb(skb);
>
> I may not be following the flow correctly, and may be noticing only
> because I just did two "floor-sweeping" patches to shift be2net and
> mlx4_en to "consume" but would it be better if these kfree_skb calls
> were a "consume" variety?
>
> rick jones

kfree_skb is probably the correct approach.  In this case it represents
a buffer that has to be freed due to a Tx timestamp request timeout so
it would be an event that we would want to trace as an error event.

Thanks,

Alex
