From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [net-next PATCH 6/8] mlx4: Add support for inner IPv6 checksum
 offloads and TSO
Date: Wed, 27 Apr 2016 18:39:54 +0300
Message-ID: <8ed986cd-10f4-bcf4-1433-45e6594849a8@gmail.com>
References: <20160425182442.11331.88349.stgit@ahduyck-xeon-server>
 <20160425183133.11331.54774.stgit@ahduyck-xeon-server>
 <571F7D14.7090504@dev.mellanox.co.il>
 <CAMt9YRqrk51Rx28FiBiR2RM-fern-UuUq7_A+FeZV+mfm_q+zg@mail.gmail.com>
 <CALzJLG87ABt8O8MpT7GycdREfkYTv3eabRCWuBsJOBDf7+LhGg@mail.gmail.com>
 <CAKgT0UfWUOFs8NvjWFQTtL_3Ure8MWbe5tJhEWFYnowb1kz1Dw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alex Duyck <aduyck@mirantis.com>, Tal Alon <talal@mellanox.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Gal Pressman <galp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>
To: Alexander Duyck <alexander.duyck@gmail.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33881 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753107AbcD0Pj7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 11:39:59 -0400
Received: by mail-wm0-f66.google.com with SMTP id n129so5062863wmn.1
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 08:39:58 -0700 (PDT)
In-Reply-To: <CAKgT0UfWUOFs8NvjWFQTtL_3Ure8MWbe5tJhEWFYnowb1kz1Dw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 27/04/2016 12:01 AM, Alexander Duyck wrote:
> On Tue, Apr 26, 2016 at 1:23 PM, Saeed Mahameed
> <saeedm@dev.mellanox.co.il> wrote:
>> On Tue, Apr 26, 2016 at 6:50 PM, Alex Duyck <aduyck@mirantis.com> wrote:
>>> The setup is pretty straight forward.  Basically I left the first port
>>> in the default namespace and moved the second int a secondary
>>> namespace referred to below as $netns.  I then assigned the IPv6
>>> addresses fec0::10:1 and fec0::10:2. After that I ran the following:
>>>
>>>          VXLAN=vx$net
>>>          echo $VXLAN ${test_options[$i]}
>>>          ip link add $VXLAN type vxlan id $net \
>>>                  local fec0::10:1 remote $addr6 dev $PF0 \
>>>                  ${test_options[$i]} dstport `expr 8800 + $net`
>>>          ip netns exec $netns ip link add $VXLAN type vxlan id $net \
>>>                                    local $addr6 remote fec0::10:1 dev $port \
>>>                                    ${test_options[$i]} dstport `expr 8800 + $net`
>>>          ifconfig $VXLAN 192.168.${net}.1/24
>>>          ip netns exec $netns ifconfig $VXLAN 192.168.${net}.2/24
>>>
>> Thanks, indeed i see that GSO is not working with vxlan over IPv6 over
>> mlx5 device.
>> We will test out those patches on both mlx4 and mlx5, and debug mlx4
>> IPv6 issue you see.
>>
>>>> Anyway, I suspect it might be related to a driver bug most likely in
>>>> get_real_size function @en_tx.c
>>>> specifically in : *lso_header_size = (skb_inner_transport_header(skb) -
>>>> skb->data) + inner_tcp_hdrlen(skb);
>>>>
>>>> will check this and get back to you.
>>> I'm not entirely convinced.  What I was seeing is t hat the hardware
>>> itself was performing Rx checksum offload only on tunnels with an
>>> outer IPv4 header and ignoring tunnels with an outer IPv6 header.
>> I don't get it, are you trying to say that the issue is in the RX side ?
>> what do you mean by ignoring ? Dropping ? or just not validating checksum ?
>> if so why would you disable GSO and IPv6 checksumming on TX ?
> I'm suspecting that whatever parsing logic exists in either the
> hardware or firmware may not be configured to parse tunnels with outer
> IPv6 headers.  The tell-tale sign is what occurs with an IPv6 based
> tunnel with no outer checksum.  The hardware is not performing a
> checksum on the inner headers so it reports it as a UDP frame with no
> checksum to the stack which ends up preventing us from doing GRO.
> That tells me that the hardware is not parsing IPv6 based tunnels on
> Rx.  I am assuming that if the Rx side doesn't work then there is a
> good chance that the Tx won't.
>
>>>>>    @@ -2431,7 +2435,18 @@ static netdev_features_t
>>>>> mlx4_en_features_check(struct sk_buff *skb,
>>>>>                                                  netdev_features_t
>>>>> features)
>>>>>    {
>>>>>          features = vlan_features_check(skb, features);
>>>>> -       return vxlan_features_check(skb, features);
>>>>> +       features = vxlan_features_check(skb, features);
>>>>> +
>>>>> +       /* The ConnectX-3 doesn't support outer IPv6 checksums but it does
>>>>> +        * support inner IPv6 checksums and segmentation so  we need to
>>>>> +        * strip that feature if this is an IPv6 encapsulated frame.
>>>>> +        */
>>>>> +       if (skb->encapsulation &&
>>>>> +           (skb->ip_summed == CHECKSUM_PARTIAL) &&
>>>>> +           (ip_hdr(skb)->version != 4))
>>>>> +               features &= ~(NETIF_F_CSUM_MASK | NETIF_F_GSO_MASK);
>>>> Dejavu, didn't you fix this already in harmonize_features, in
>>>> i.e, it is enough to do here:
>>>>
>>>> if (skb->encapsulation && (skb->ip_summed == CHECKSUM_PARTIAL))
>>>>              features &= ~NETIF_F_IPV6_CSUM;
>>>>
>>> So what this patch is doing is enabling an inner IPv6 header offloads.
>>> Up above we set the NETIF_F_IPV6_CSUM bit and we want it to stay set
>>> unless we have an outer IPv6 header because the inner headers may
>>> still need that bit set.  If I did what you suggest it strips IPv6
>>> checksum support for inner headers and if we have to use GSO partial I
>>> ended up encountering some of the other bugs that I have fixed for GSO
>>> partial where either sg or csum are not defined.
>>>
>> I see, you mean that you want to disable checksumming and GSO only for
>> packets with Outer(IPv6):Inner(X) and keep it in case for
>> Outer(IPv4):Inner(IPv6)
>> but i think it is weird that the driver decides to disable features it
>> didn't declare in first place (NETIF_F_CSUM_MASK | NETIF_F_GSO_MASK)
>>
>> Retry:
>>
>> if (skb->encapsulation && (skb->ip_summed == CHECKSUM_PARTIAL) &&
>>      (ip_hdr(skb)->version != 4))
>>              features &= ~NETIF_F_IPV6_CSUM;
>>
>> will this work ?
> Sort of.  All that would happen is that you would fall through to
> harmonize_features where NETIF_F_CSUM_MASK | NETIF_F_GSO_MASK gets
> cleared.  I just figured I would short-cut things since we cannot
> support inner checksum or any GSO offloads if the tunnel has an outer
> IPv6 header.  In addition this happens to effectively be the same code
> I am using in vxlan_features_check to disable things if we cannot
> checksum a protocol so it should help to keep the code size smaller
> for the function if the compiler is smart enough to coalesce similar
> code.
>
>> Anyway i prefer to debug the mlx4 issue first before we discuss the
>> best approach to disable checksumming & GSO for outer IPv6 in mlx4.
> The current code as-is already has it disabled.  All I am doing is
> enabling IPv6 checksums for inner headers as it seems like it doesn't
> work for outer headers.

Hi Alex,
I will be working on the mlx4 issue next week after the holidays.
I will check this offline in-house, without blocking the series.

Regards,
Tariq
