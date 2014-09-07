From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next v4 2/3] net-timestamp: Make the clone operation
 stand-alone from phy timestamping
Date: Sun, 07 Sep 2014 16:35:39 -0700
Message-ID: <540CEBCB.1010600@gmail.com>
References: <20140904172906.7702.87598.stgit@ahduyck-bv4.jf.intel.com> <20140904173116.7702.30877.stgit@ahduyck-bv4.jf.intel.com> <20140907215039.GA3900@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, willemb@google.com
To: Richard Cochran <richardcochran@gmail.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:60090 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752149AbaIGXfj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Sep 2014 19:35:39 -0400
Received: by mail-pd0-f176.google.com with SMTP id y13so1844699pdi.21
        for <netdev@vger.kernel.org>; Sun, 07 Sep 2014 16:35:38 -0700 (PDT)
In-Reply-To: <20140907215039.GA3900@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/07/2014 02:50 PM, Richard Cochran wrote:
> Just saw this now, was away on vacation, so sorry for the delay...
>
> On Thu, Sep 04, 2014 at 01:31:35PM -0400, Alexander Duyck wrote:
>> v2: Renamed function to skb_clone_sk.
>>     Added destructor to call sock_put instead of doing it ourselves.
>>     Dropped freeing functionality from skb_complete_tx_timestamp.
> ...
>
>> diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
>> index d5991ac..87648b3 100644
>> --- a/drivers/net/phy/dp83640.c
>> +++ b/drivers/net/phy/dp83640.c
>> @@ -1148,7 +1148,7 @@ static void dp83640_remove(struct phy_device *phydev)
>>  		kfree_skb(skb);
>>  
>>  	while ((skb = skb_dequeue(&dp83640->tx_queue)) != NULL)
>> -		skb_complete_tx_timestamp(skb, NULL);
>> +		kfree_skb(skb);
> The way the code was before, there was a clear usage pattern for
> phy_driver.txtstamp() and skb_complete_tx_timestamp() which was also
> documented in the comment to the latter.
>
> Now, we have drivers freeing buffers allocated by the stack.  I
> thought it was cleaner to have the same layer allocate and free the
> clone. Even if you say that this new way is just fine, still you
> should correct the comment to reflect the new pattern.

The "new" pattern is how we have done it for all Tx skbs handed down by
the stack, so why should we treat Tx timestamp SKBs any different?  If
anything this change eliminates a risk since now they don't have to
remember specifically to use a special "destructor included" callback to
free the buffer and the socket.  Instead all of the standard
kfree/consume_skb calls can be used to free the buffer.

It  just occurred to me when I was looking at this code is that it can
now use standard calls such as __skb_queue_purge instead of having to
implement its own version of the call.  I will try to remember to submit
a patch for that tomorrow.

Thanks,

Alex
