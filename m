From: Martin Rusko <martin.rusko@gmail.com>
Subject: Re: Sending undersized ARP packets with VXLAN L3 interface
Date: Wed, 27 Aug 2014 23:00:38 +0200
Message-ID: <CAMYYbY7vCqpW7pqy=a7O=9YnPM=R1Ta2gfXdZEqrmyK-P-Akdw@mail.gmail.com>
References: <CAMYYbY79hOVA5b22-gmLJTNQwprdfwa_QxKqveuwNhJMcXv9tA@mail.gmail.com>
	<CAHA+R7Ok6K_9U6RCZkSLCuVXtFG4Zs60FQKFZMu-v2yK581hog@mail.gmail.com>
	<53FE1AC3.5030409@gmail.com>
	<20140827114209.3a9d3761@urahara>
	<53FE2738.30702@gmail.com>
	<CAMYYbY4KHTkkv6peT14S8mCzcQJ8wROnHWj5tMy563H-w79KMg@mail.gmail.com>
	<53FE3E5C.8020804@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Cong Wang <cwang@twopensource.com>,
	netdev <netdev@vger.kernel.org>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f172.google.com ([209.85.220.172]:56838 "EHLO
	mail-vc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935336AbaH0VAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 17:00:39 -0400
Received: by mail-vc0-f172.google.com with SMTP id le20so269279vcb.3
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 14:00:38 -0700 (PDT)
In-Reply-To: <53FE3E5C.8020804@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 27, 2014 at 10:23 PM, Vlad Yasevich <vyasevich@gmail.com> wrote:
> On 08/27/2014 04:01 PM, Martin Rusko wrote:
>> On Wed, Aug 27, 2014 at 8:45 PM, Vlad Yasevich <vyasevich@gmail.com> wrote:
>>> On 08/27/2014 02:42 PM, Stephen Hemminger wrote:
>>>> On Wed, 27 Aug 2014 13:52:03 -0400
>>>> Vlad Yasevich <vyasevich@gmail.com> wrote:
>>>>
>>>>> On 08/27/2014 01:28 PM, Cong Wang wrote:
>>>>>> On Wed, Aug 27, 2014 at 10:06 AM, Martin Rusko <martin.rusko@gmail.com> wrote:
>>>>>>>
>>>>>>> I'm wondering, where is the proper place to fix this. Should
>>>>>>> arp_create() function allocate skb big enough to produce ethernet
>>>>>>> frame with at least minimum size? Or is it somewhere in NIC drivers
>>>>>>> where small packets are padded with zeros?
>>>>>>
>>>>>> Drivers do that, for example e1000:
>>>>>>
>>>>>>         /* On PCI/PCI-X HW, if packet size is less than ETH_ZLEN,
>>>>>>          * packets may get corrupted during padding by HW.
>>>>>>          * To WA this issue, pad all small packets manually.
>>>>>>          */
>>>>>>         if (skb->len < ETH_ZLEN) {
>>>>>>                 if (skb_pad(skb, ETH_ZLEN - skb->len))
>>>>>>                         return NETDEV_TX_OK;
>>>>>>                 skb->len = ETH_ZLEN;
>>>>>>                 skb_set_tail_pointer(skb, ETH_ZLEN);
>>>>>>         }
>>>>>
>>>>>
>>>>> I think vxlan needs something like this:
>>>>>
>>>>> From: Vladislav Yasevich <vyasevich@gmail.com>
>>>>> Date: Wed, 27 Aug 2014 13:39:32 -0400
>>>>> Subject: [PATCH] vxlan: Pad short ethernet frames.
>>>>>
>>>>> If sending short ethernet frames from the vxlan device, pad
>>>>> them to minimum size so they can be forwarded after decapsulation.
>>>>>
>>>>> Reported-by: Martin Rusko <martin.rusko@gmail.com>
>>>>> Signed-off-by: Vladislav Yasevich <vyasevich@gmail.com>
>>>>> ---
>>>>>  drivers/net/vxlan.c | 8 ++++++++
>>>>>  1 file changed, 8 insertions(+)
>>>>>
>>>>> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
>>>>> index 1fb7b37..48267d4 100644
>>>>> --- a/drivers/net/vxlan.c
>>>>> +++ b/drivers/net/vxlan.c
>>>>> @@ -1939,6 +1939,14 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct
>>>>> net_device *dev)
>>>>>  #endif
>>>>>      }
>>>>>
>>>>> +    /* Pad short frames so they can be forwarded after decapsulation */
>>>>> +    if (skb->len < ETH_ZLEN) {
>>>>> +            if (skb_pad(skb, ETH_ZLEN - skb->len))
>>>>> +                    return NETDEV_TX_OK;
>>>>> +            skb->len = ETH_ZLEN;
>>>>> +            skb_set_tail_pointer(skb, ETH_ZLEN);
>>>>> +    }
>>>>> +
>>>>>      f = vxlan_find_mac(vxlan, eth->h_dest);
>>>>>      did_rsc = false;
>>>>>
>>>>
>>>> No. The short frame is perfectly valid, over the VXLAN.
>>>> The system doing the decap and forwarding should be where any padding is added if necessary.
>>>>
>>
>> Well, RFC 7348 is not dealing with padding at all. Both deployment
>> scenarios listed in RFC, as well as most of the existing real life
>> deployments today (in my opinion) use VXLAN for bridged traffic. In
>> other words, frame encapsulated by VTEP is received first over some
>> ethernet interface (physical or virtual) which implies that the frame
>> is at least 64 bytes long already.
>>
>> Perhaps we're going to see more VXLAN interfaces in L3 mode, yet it
>> might be safer not to count on receiving VTEP doing the right thing
>> (pad small packets with zeros).
>>
>>>
>>> If that's the case, then Martin is most likely seeing a HW bug on the switch.
>>> I wonder how common such a bug might be?
>>>
>>> -vlad
>>>
>>
>> I see this on Vmware distributed virtual switch. Perhaps soon I will
>> be able to test it against HP 5930 switch. I'm going to try how Linux
>> bridge copes with it, now.
>
> Linux bridge will do just fine as it will pass the frame off to the hw driver
> which should pad things appropriately.
>
> -vlad
>

I can confirm that, now. After using namespaces to setup following topology:

[main host] ~~~~~ [switch ns] ------ [host ns]

~~~ = vxlan (on top of veth link)
---- = veth link

# namespace for the bridge with VTEP
ip netns add switch
# namespace for the remote host behind the bridge
ip netns add host
ip li add name veth0 type veth peer name veth1
ip li set veth1 netns switch
ip li set veth2 netns switch
ip li set veth3 netns host
ip ad add 192.0.2.1/30 brd + dev veth0
ip li set veth0 up
ip netns exec switch ip ad add 192.0.2.2/30 brd + dev veth1
ip netns exec switch ip li set veth1 up
ip li add name vxln0 type vxlan id 100 group 239.0.2.0 \
 local 192.0.2.1 dev veth0 dstport 0
ip ad add 198.51.100.1/24 brd + dev vxln0
ip li set vxln0 up
ip netns exec switch ip li add name vxln1 type vxlan id 100 \
 group 239.0.2.0 local 192.0.2.2 dev veth1 dstport 0
ip netns exec switch ip li add name vbr0 type bridge
ip netns exec switch ip li set vxln1 master vbr0
ip netns exec switch ip li set veth2 master vbr0
ip netns exec switch ip li set vxln1 up
ip netns exec switch ip li set veth2 up
ip netns exec switch ip li set vbr0 up
ip netns exec host ip ad add 198.51.100.2/24 brd + dev veth3
ip netns exec host ip li set veth3 up

I was able to arping remote host from the main host and when I tapped
to veth0 and veth2 interfaces, I could see small packets being
exchange without any issues.

Vlad, I'm going to recompile 3.16.1 kernel with your patch.

Regards,
Martin
