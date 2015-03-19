From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 10/10] amd-xgbe: Rework the Rx path SKB
 allocation
Date: Thu, 19 Mar 2015 17:51:07 -0400 (EDT)
Message-ID: <20150319.175107.1317700631160353748.davem@davemloft.net>
References: <20150319200908.28321.60118.stgit@tlendack-t1.amdoffice.net>
	<20150319.162000.938727994480466006.davem@davemloft.net>
	<550B3780.4080302@amd.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51055 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751314AbbCSVvM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 17:51:12 -0400
In-Reply-To: <550B3780.4080302@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Thu, 19 Mar 2015 15:54:24 -0500

> On 03/19/2015 03:20 PM, David Miller wrote:
>> From: Tom Lendacky <thomas.lendacky@amd.com>
>> Date: Thu, 19 Mar 2015 15:09:08 -0500
>>
>>> When the driver creates an SKB it currently only copies the header
>>> buffer data (which can be just the header if split header processing
>>> succeeded or header plus data if split header processing did not
>>> succeed) into the SKB. The receive buffer data is always added as a
>>> frag, even if it could fit in the SKB. As part of SKB creation, inline
>>> the receive buffer data if it will fit in the the SKB, otherwise add
>>> it
>>> as a frag during SKB creation.
>>>
>>> Also, Update the code to trigger off of the first/last descriptor
>>> indicators and remove the incomplete indicator.
>>>
>>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>>
>> I do not understand the motivation for this, could you explain?
>>
>> The less copying you do the better, just having the headers in the
>> linear area is the most optimal situation, and have all the data
>> in page frag references.
>>
> 
> I was trying to make the Rx path more logical from a first / last
> descriptor point of view.  If it's the first descriptor allocate the
> SKB, otherwise add the data as a frag. Compared to the current code:
> check for null skb pointer, allocate the SKB and if there's data left
> add it as a frag.
> 
> I could keep the first / last descriptor methodology and in the
> xgbe_create_skb routine avoid the second copy and just always add the
> other buffer as a frag. That will eliminate the extra copying. Would
> that be ok or would you prefer that I just drop this patch?

The point is, the data might not even be touched by the cpu so copying
it into the linear SKB data area could be a complete waste of cpu
cycles.

Only the headers will be touched by the cpu in the packet processing
paths.

And when we copy the packet data into userspace, that might even occur
on another cpu, so the data will just thrash between the individual
cpu's caches.
