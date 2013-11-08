From: Sridhar Samudrala <samudrala.sridhar@gmail.com>
Subject: Re: [PATCH v2 net-next] inet: fix a UFO regression
Date: Thu, 07 Nov 2013 22:41:01 -0800
Message-ID: <527C877D.3080309@gmail.com>
References: <CAMEtUuyuHagy7j+fi8RnKjZNBnwYHhxfed508HyXLfHp-e634w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Alexei Starovoitov <ast@plumgrid.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f44.google.com ([209.85.219.44]:35185 "EHLO
	mail-oa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750781Ab3KHGkx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 01:40:53 -0500
Received: by mail-oa0-f44.google.com with SMTP id i7so2101682oag.17
        for <netdev@vger.kernel.org>; Thu, 07 Nov 2013 22:40:52 -0800 (PST)
In-Reply-To: <CAMEtUuyuHagy7j+fi8RnKjZNBnwYHhxfed508HyXLfHp-e634w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/7/2013 9:44 PM, Alexei Starovoitov wrote:
> On Thu, Nov 7, 2013 at 6:32 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> From: Eric Dumazet <edumazet@google.com>
>>
>> While testing virtio_net and skb_segment() changes, Hannes reported
>> that UFO was sending wrong frames.
>>
>> It appears this was introduced by a recent commit :
>> 8c3a897bfab1 ("inet: restore gso for vxlan")
>>
>> The old condition to perform IP frag was :
>>
>> tunnel = !!skb->encapsulation;
>> ...
>>          if (!tunnel && proto == IPPROTO_UDP) {
>>
>> So the new one should be :
>>
>> udpfrag = !skb->encapsulation && proto == IPPROTO_UDP;
>> ...
>>          if (udpfrag) {
>>
>> Initialization of udpfrag must be done before call
>> to ops->callbacks.gso_segment(skb, features), as
>> skb_udp_tunnel_segment() clears skb->encapsulation
>>
>> (We want udpfrag to be true for UFO, false for VXLAN)
>>
>> With help from Alexei Starovoitov
>>
>> Reported-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> Cc: Alexei Starovoitov <ast@plumgrid.com>
>> ---
> vxlan looks good through namespaces with and without gso
> and between physical machines via 10G nics

Does this fix also help vxlan performance between 2 VMs on 2 different 
physical m/cs across 10G NIC?
What is the throughput you are seeing via 10G nics?
With linux 3.12, i am only seeing around 2Gbps (iperf TCP_STREAM with 
16K messages)  between 2 VMs when using vxlan across a 10G nic.
Is this due to the overhead of software GSO and not doing GRO at the 
receiver?

Thanks
Sridhar
>
> Tested-by: Alexei Starovoitov <ast@plumgrid.com>
>
> Thanks Eric!
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
