From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next RFC] net: increase LL_MAX_HEADER for Hyper-V
Date: Wed, 16 Sep 2015 16:48:50 -0700
Message-ID: <55F9FFE2.3030803@gmail.com>
References: <1442418625-11805-1-git-send-email-vkuznets@redhat.com>
 <BN1PR0301MB0770C47D37D272F5A28CD1DECA5B0@BN1PR0301MB0770.namprd03.prod.outlook.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CB9800B@AcuExch.aculab.com>
 <BY2PR0301MB16548B482FF9E0F4D82FC2C8A05B0@BY2PR0301MB1654.namprd03.prod.outlook.com>
 <55F9E172.2040008@gmail.com>
 <BY2PR0301MB16540426BFD633C8EBD1A4BBA05B0@BY2PR0301MB1654.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Jason Wang <jasowang@redhat.com>
To: KY Srinivasan <kys@microsoft.com>,
	David Laight <David.Laight@ACULAB.COM>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	Vitaly Kuznetsov <vkuznets@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BY2PR0301MB16540426BFD633C8EBD1A4BBA05B0@BY2PR0301MB1654.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/16/2015 03:57 PM, KY Srinivasan wrote:
>
>> -----Original Message-----
>> From: Alexander Duyck [mailto:alexander.duyck@gmail.com]
>> Sent: Wednesday, September 16, 2015 2:39 PM
>> To: KY Srinivasan <kys@microsoft.com>; David Laight
>> <David.Laight@ACULAB.COM>; Haiyang Zhang <haiyangz@microsoft.com>;
>> Vitaly Kuznetsov <vkuznets@redhat.com>; netdev@vger.kernel.org
>> Cc: David S. Miller <davem@davemloft.net>; linux-kernel@vger.kernel.org;
>> Jason Wang <jasowang@redhat.com>
>> Subject: Re: [PATCH net-next RFC] net: increase LL_MAX_HEADER for Hyper-V
>>
>> On 09/16/2015 10:55 AM, KY Srinivasan wrote:
>>>> -----Original Message-----
>>>> From: David Laight [mailto:David.Laight@ACULAB.COM]
>>>> Sent: Wednesday, September 16, 2015 9:25 AM
>>>> To: Haiyang Zhang <haiyangz@microsoft.com>; Vitaly Kuznetsov
>>>> <vkuznets@redhat.com>; netdev@vger.kernel.org
>>>> Cc: David S. Miller <davem@davemloft.net>; linux-kernel@vger.kernel.org;
>>>> KY Srinivasan <kys@microsoft.com>; Jason Wang <jasowang@redhat.com>
>>>> Subject: RE: [PATCH net-next RFC] net: increase LL_MAX_HEADER for Hyper-
>>>> V
>>>>
>>>> From: Haiyang Zhang
>>>>> Sent: 16 September 2015 17:09
>>>>>> -----Original Message-----
>>>>>> From: Vitaly Kuznetsov [mailto:vkuznets@redhat.com]
>>>>>> Sent: Wednesday, September 16, 2015 11:50 AM
>>>>>> To: netdev@vger.kernel.org
>>>>>> Cc: David S. Miller <davem@davemloft.net>; linux-
>>>> kernel@vger.kernel.org;
>>>>>> KY Srinivasan <kys@microsoft.com>; Haiyang Zhang
>>>>>> <haiyangz@microsoft.com>; Jason Wang <jasowang@redhat.com>
>>>>>> Subject: [PATCH net-next RFC] net: increase LL_MAX_HEADER for Hyper-
>>>> V
>>>>>> Commit b08cc79155fc26d0d112b1470d1ece5034651a4b ("hv_netvsc:
>>>> Eliminate
>>>>>>    memory allocation in the packet send path") introduced skb headroom
>>>>>> request for Hyper-V netvsc driver:
>>>>>>
>>>>>>          max_needed_headroom = sizeof(struct hv_netvsc_packet) +
>>>>>>                                  sizeof(struct rndis_message) +
>>>>>>                                  NDIS_VLAN_PPI_SIZE + NDIS_CSUM_PPI_SIZE +
>>>>>>                                  NDIS_LSO_PPI_SIZE + NDIS_HASH_PPI_SIZE;
>>>>>>          ...
>>>>>>          net->needed_headroom = max_needed_headroom;
>>>>>>
>>>>>> max_needed_headroom is 220 bytes, it significantly exceeds the
>>>>>> LL_MAX_HEADER setting. This causes each skb to be cloned on send
>>>> path,
>>>>>> e.g. for IPv4 case we fall into the following clause
>>>>>> (ip_finish_output2()):
>>>>>>
>>>>>> if (unlikely(skb_headroom(skb) < hh_len && dev->header_ops)) {
>>>>>>       ...
>>>>>>       skb2 = skb_realloc_headroom(skb, LL_RESERVED_SPACE(dev));
>>>>>>       ...
>>>>>> }
>>>>>>
>>>>>> leading to a significant performance regression. Increase
>>>> LL_MAX_HEADER
>>>>>> to make it suitable for netvsc, make it 224 to be 16-aligned.
>>>>>> Alternatively we could (partially) revert the commit which introduced
>>>>>> skb
>>>>>> headroom request restoring manual memory allocation on transmit path.
>>>>>>
>>>>>> Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
>>>>>> ---
>>>>>>    include/linux/netdevice.h | 4 +++-
>>>>>>    1 file changed, 3 insertions(+), 1 deletion(-)
>>>>>>
>>>>>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>>>>>> index 88a0069..7233790 100644
>>>>>> --- a/include/linux/netdevice.h
>>>>>> +++ b/include/linux/netdevice.h
>>>>>> @@ -132,7 +132,9 @@ static inline bool dev_xmit_complete(int rc)
>>>>>>     *	used.
>>>>>>     */
>>>>>>
>>>>>> -#if defined(CONFIG_WLAN) || IS_ENABLED(CONFIG_AX25)
>>>>>> +#if IS_ENABLED(CONFIG_HYPERV_NET)
>>>>>> +# define LL_MAX_HEADER 224
>>>>>> +#elif defined(CONFIG_WLAN) || IS_ENABLED(CONFIG_AX25)
>>>>>>    # if defined(CONFIG_MAC80211_MESH)
>>>>>>    #  define LL_MAX_HEADER 128
>>>>>>    # else
>>>>> Thanks for the patch.
>>>>> To avoid we forget to update that 224 number when we add more things
>>>>> into netvsc header, I suggest that we define a macro in netdevice.h such
>>>>> as:
>>>>> #define HVNETVSC_MAX_HEADER 224
>>>>> #define LL_MAX_HEADER HVNETVSC_MAX_HEADER
>>>>>
>>>>> And, put a note in netvsc code saying the header reservation shouldn't
>>>>> exceed HVNETVSC_MAX_HEADER, or you need to update
>>>> HVNETVSC_MAX_HEADER.
>>>>
>>>> Am I right in thinking this is adding an extra 96 unused bytes to the front
>>>> of almost all skb just so that hyper-v can make its link level header
>>>> contiguous with whatever follows (IP header ?).
>>>>
>>>> Doesn't sound ideal.
>>> Remote NDIS is the protocol used to send packets from the guest to the host.
>> Every packet
>>> needs to be decorated with the RNDIS header and the maximum room needed
>> for the RNDIS
>>> header is the hreadroom we want.
>> I think we get that.  The question is does the Remote NDIS header and
>> packet info actually need to be a part of the header data?  I would
>> argue that it probably doesn't.
>>
>> So for example in netvsc_start_xmit it looks like you are calling
>> init_page_array in order to populate a set of page buffers, but the
>> first buffer for the Remote NDIS protocol is populated as a separate
>> page and offset.  As such it doesn't seem like it necessarily needs to
>> be a part of the header data but could be maintained perhaps in a
>> separate ring buffer, or perhaps just be a separate page that you break
>> up to use for each header.
> You are right; the rndis header can be built as a separate fragment and sent.
> Indeed this is what we were doing earlier - on the outgoing path we would allocate
> memory for the rndis header. My goal was to avoid this allocation on every packet being
> sent and I decided to use the headroom instead. If we can completely avoid all memory
> allocation for rndis header, it makes a significant perf difference:
>
> Throughput as measured by iperf on a 40G interface (VM to VM on two nodes) in Gbps.
> Scenario #A: LL_MAX_HEADER =128 [no change], needed_headroom = 220 [no change]
> Scenario #B: LL_MAX_HEADER =224, needed_headroom = 220 [no change]
>
> Conn#   #A                     #B
> 1              6.9                  8.2
> 2              13.2                14.9
> 4              17.6                16.6
> 8              24.1                26.9
> 16           24.0                 31.5
> 32           24.5                 33.6
> 64           31.6                 31.5
> 128         29.6                 30.3
>
> Column A is the existing code where we end up having to allocate more headroom and column B is with
> Vitaly's patch. I will experiment with a light-weight allocator for the rndis header.
>
> Regards,
>
> K. Y

I get the performance implications, but that is increasing the memory 
footprint for every driver in the system that is holding any outstanding 
transmit buffers.  Also it will likely have a negative impact on 
transmit performance as it increases the truesize of every outgoing buffer.

The other thing I don't get is why hv_netvsc_packet was being included 
in this allocation as well.  It seems like it is just metadata that is 
used for each outgoing frame.  Odds are you could probably make it a 
separate allocation as well, however if nothing else you should probably 
look at rearranging the structure to fill the holes as it looks like you 
have about 16 bytes of wasted space due to the arrangement of 32b and 
64b values.  Fixing that would allow you to reduce your needed_headroom 
which may also help to improve things.

- Alex
