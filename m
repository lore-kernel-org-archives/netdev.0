From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [PATCH net-next v2 10/10] amd-xgbe: Rework the Rx path SKB allocation
Date: Thu, 19 Mar 2015 17:07:40 -0500
Message-ID: <550B48AC.5030007@amd.com>
References: <20150319200908.28321.60118.stgit@tlendack-t1.amdoffice.net>
	<20150319.162000.938727994480466006.davem@davemloft.net>
	<550B3780.4080302@amd.com>
 <20150319.175107.1317700631160353748.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0112.outbound.protection.outlook.com ([207.46.100.112]:49046
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750734AbbCSWHr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Mar 2015 18:07:47 -0400
In-Reply-To: <20150319.175107.1317700631160353748.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/19/2015 04:51 PM, David Miller wrote:
> From: Tom Lendacky <thomas.lendacky@amd.com>
> Date: Thu, 19 Mar 2015 15:54:24 -0500
>
>> On 03/19/2015 03:20 PM, David Miller wrote:
>>> From: Tom Lendacky <thomas.lendacky@amd.com>
>>> Date: Thu, 19 Mar 2015 15:09:08 -0500
>>>
>>>> When the driver creates an SKB it currently only copies the header
>>>> buffer data (which can be just the header if split header processing
>>>> succeeded or header plus data if split header processing did not
>>>> succeed) into the SKB. The receive buffer data is always added as a
>>>> frag, even if it could fit in the SKB. As part of SKB creation, inline
>>>> the receive buffer data if it will fit in the the SKB, otherwise add
>>>> it
>>>> as a frag during SKB creation.
>>>>
>>>> Also, Update the code to trigger off of the first/last descriptor
>>>> indicators and remove the incomplete indicator.
>>>>
>>>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>>>
>>> I do not understand the motivation for this, could you explain?
>>>
>>> The less copying you do the better, just having the headers in the
>>> linear area is the most optimal situation, and have all the data
>>> in page frag references.
>>>
>>
>> I was trying to make the Rx path more logical from a first / last
>> descriptor point of view.  If it's the first descriptor allocate the
>> SKB, otherwise add the data as a frag. Compared to the current code:
>> check for null skb pointer, allocate the SKB and if there's data left
>> add it as a frag.
>>
>> I could keep the first / last descriptor methodology and in the
>> xgbe_create_skb routine avoid the second copy and just always add the
>> other buffer as a frag. That will eliminate the extra copying. Would
>> that be ok or would you prefer that I just drop this patch?
>
> The point is, the data might not even be touched by the cpu so copying
> it into the linear SKB data area could be a complete waste of cpu
> cycles.

I understood that point, sorry if I wasn't clear.  I'd would remove the
copying of the data and just always add it as a frag in xgbe_create_skb
routine so that only the headers are in the linear area.  What I'd like
to do though is keep the overall changes of how I determine when to
call the xgbe_create_skb routine so that it appears a bit cleaner,
more logical.  The net effect is that the behavior of the code would
remain the same (headers in the linear area, data as frags), but I feel
it reads better and is easier to understand.

Thanks,
Tom

>
> Only the headers will be touched by the cpu in the packet processing
> paths.
>
> And when we copy the packet data into userspace, that might even occur
> on another cpu, so the data will just thrash between the individual
> cpu's caches.
>
