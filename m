From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next] xen-netback: Stop using xenvif_tx_pending_slots_available
Date: Fri, 21 Mar 2014 19:16:00 +0000
Message-ID: <532C8FF0.7090008@citrix.com>
References: <1395343961-4744-1-git-send-email-zoltan.kiss@citrix.com> <1395394603.27358.8.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<paul.durrant@citrix.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395394603.27358.8.camel@kazak.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 21/03/14 09:36, Ian Campbell wrote:
> On Thu, 2014-03-20 at 19:32 +0000, Zoltan Kiss wrote:
>> Since the early days TX stops if there isn't enough free pending slots to
>> consume a maximum sized (slot-wise) packet. Probably the reason for that is to
>> avoid the case when we don't have enough free pending slot in the ring to finish
>> the packet. But if we make sure that the pending ring has the same size as the
>> shared ring, that shouldn't really happen. The frontend can only post packets
>> which fit the to the free space of the shared ring. If it doesn't, the frontend
>> has to stop, as it can only increase the req_prod when the whole packet fits
>> onto the ring.
>
> My only real concern here is that by removing these checks we are
> introducing a way for a malicious or buggy guest to trigger misbehaviour
> in the backend, leading to e.g. a DoS.
>
> Should we need to some sanity checks which shutdown the ring if
> something like this occurs? i.e. if we come to consume a packet and
> there is insufficient space on the pending ring we kill the vif.
The backend doesn't see what the guest does with the responses, and 
that's OK, it's the guest's problem, after netback increased 
rsp_prod_pvt it doesn't really care. But as soon as the guest start 
placing new requests after rsp_prod_pvt, or just increasing req_prod so 
req_prod-rsp_prod_pvt > XEN_NETIF_TX_RING_SIZE, it becomes an issue.
So far this xenvif_tx_pending_slots_available indirectly saved us from 
consuming requests overwriting still pending requests, but the guest 
could still overwrote our responses. But again, that's still the guests 
problem, we had the original request saved in the pending ring data. If 
the guest went too far, build_gops killed the vif when req_prod-req_cons 
 > XEN_NETIF_TX_RING_SIZE
Indirect above means it only happened because the pending ring had the 
same size, and the used slots has a 1-to-1 mapping for slots between 
rsp_prod_pvt and req_cons. So xenvif_tx_pending_slots_available also 
means (req_cons - rsp_prod_pvt) + XEN_NETBK_LEGACY_SLOTS_MAX < 
XEN_NETIF_TX_RING_SIZE (does this look familiar? :)
But consuming overrunning requests after rsp_prod_pvt is a problem:
- NAPI instance races with dealloc thread over the slots. The first 
reads them as requests, the second writes them as responses
- the NAPI instance overwrites used pending slots as well, so skb frag 
release go wrong etc.
But the current RING_HAS_UNCONSUMED_REQUESTS fortunately saves us here, 
let me explain it through an example:
rsp_prod_pvt = 0
req_cons = 253
req_prod = 258

Therefore:
req = 5
rsp = 3

So in xenvif_tx_build_gops work_to_do will be 3, and in 
xenvif_count_requests we bail out when we see that the packet actually 
exceeds that.
So in the end, we are safe here, but we shouldn't change that macro I 
suggested to refactor :)

Zoli


>
> What's the invariant we are relying on here, is it:
>      req_prod >= req_cons >= pending_prod >= pending_cons >= rsp_prod >= rsp_cons
> ?
>
>> This patch avoid using this checking, makes sure the 2 ring has the same size,
>> and remove a checking from the callback. As now we don't stop the NAPI instance
>> on this condition, we don't have to wake it up if we free pending slots up.
>>
>> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
>> ---
>> diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
>> index bef37be..a800a8e 100644
>> --- a/drivers/net/xen-netback/common.h
>> +++ b/drivers/net/xen-netback/common.h
>> @@ -81,7 +81,7 @@ struct xenvif_rx_meta {
>>
>>   #define MAX_BUFFER_OFFSET PAGE_SIZE
>>
>> -#define MAX_PENDING_REQS 256
>> +#define MAX_PENDING_REQS XEN_NETIF_TX_RING_SIZE
>
> XEN_NETIF_TX_RING_SIZE is already == 256, right? (Just want to make sure
> this is semantically no change).
Yes, it is __CONST_RING_SIZE(xen_netif_tx, PAGE_SIZE)
