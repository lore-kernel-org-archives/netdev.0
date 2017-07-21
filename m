From: John Crispin <john@phrozen.org>
Subject: Re: [RFC 1/2] net-next: add a dma_desc element to struct
 skb_shared_info
Date: Fri, 21 Jul 2017 19:01:57 +0200
Message-ID: <6bcc6463-c2e7-5f56-22b0-f49bb369ce1c@phrozen.org>
References: <20170721152035.6645-1-john@phrozen.org>
 <20170721152035.6645-2-john@phrozen.org>
 <1500652599.3924.10.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Paolo Abeni <pabeni@redhat.com>,
        "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1500652599.3924.10.camel@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 21/07/17 17:56, Paolo Abeni wrote:
> Hi,
>
> On Fri, 2017-07-21 at 17:20 +0200, John Crispin wrote:
>> In order to make HW flow offloading work in latest MediaTek silicon we need
>> to propagate part of the RX DMS descriptor to the upper layers populating
>> the flow offload engines HW tables. This patch adds an extra element to
>> struct skb_shared_info allowing the ethernet drivers RX napi code to store
>> the required information and make it persistent for the lifecycle of the
>> skb and its clones.
>>
>> Signed-off-by: John Crispin <john@phrozen.org>
>> ---
>>   include/linux/skbuff.h | 1 +
>>   1 file changed, 1 insertion(+)
>>
>> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
>> index 4093552be1de..db9576cd946b 100644
>> --- a/include/linux/skbuff.h
>> +++ b/include/linux/skbuff.h
>> @@ -426,6 +426,7 @@ struct skb_shared_info {
>>   	unsigned int	gso_type;
>>   	u32		tskey;
>>   	__be32          ip6_frag_id;
>> +	u32		dma_desc;
>>   
>>   	/*
>>   	 * Warning : all fields before dataref are cleared in __alloc_skb()
> This will increase the skb_shared_info struct size, which is already
> quite large, and can have several kind of performance drawback.
> AFAIK this is discouraged.
>
> I don't understand the use case; the driver will set this field, but
> who is going to consume it?
>
> Thanks,
>
> Paolo
Hi Paolo,

When the flow offloading engine forwards a packet to the DMA it will 
send additional info to the sw path. this includes
* physical switch port
* internal flow hash - this is required to populate the correct flow 
table entry
* ppe state - this indicates what state the PPEs internal table is in 
for the flow
* the reason why the packet was forwarde - these are things like bind, 
unbind, timed out, ...

once the flow table offloading patches are ready and upstream, the 
netfilter layer will see the SKB and pass it o to the flow table 
offloading code, at which point it will finally end up inside the 
offloading driver. this will need to have access to this info sent to 
the sw path inside the rx descriptor to properly work out what state the 
flow is in and which table entry to populate in the HW table for 
offloading to work.

Hope that is a little clearer. current hackish driver is here [1], the 
patch to the ethernet driver is here [2]

     John

[1] 
https://git.lede-project.org/?p=lede/blogic/staging.git;a=tree;f=target/linux/mediatek/files/drivers/net/ethernet/mediatek/mtk_hnat;hb=bc0518b9d928b43d965d8a1f8860281f0ae6a31c
[2] 
https://git.lede-project.org/?p=lede/blogic/staging.git;a=blob;f=target/linux/mediatek/patches-4.9/0310-hwnat.patch;h=57bd0c07b39d2169f3ba08e1aa83b92dffcee025;hb=bc0518b9d928b43d965d8a1f8860281f0ae6a31c
