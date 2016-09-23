From: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Subject: Re: [RFC] net: store port/representative id in metadata_dst
Date: Fri, 23 Sep 2016 10:22:59 -0700
Message-ID: <57E564F3.5010107@intel.com>
References: <1474572417-15907-1-git-send-email-jakub.kicinski@netronome.com>    <20160923063429.GA1821@nanopsycho.orion>        <20160923110609.2f221f99@griffin>       <20160923135512.64e5d5e9@jkicinski-Precision-T1700>     <57E53ADE.10806@gmail.com> <20160923162907.7fd5314e@jkicinski-Precision-T1700>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@redhat.com>, Jiri Pirko <jiri@resnulli.us>,
        netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        ogerlitz@mellanox.com, ast@kernel.org, daniel@iogearbox.net,
        simon.horman@netronome.com, Paolo Abeni <pabeni@redhat.com>,
        Pravin B Shelar <pshelar@nicira.com>,
        hannes@stressinduktion.org, kubakici@wp.pl
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:11696 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755042AbcIWRXR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 13:23:17 -0400
In-Reply-To: <20160923162907.7fd5314e@jkicinski-Precision-T1700>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 9/23/2016 8:29 AM, Jakub Kicinski wrote:
> On Fri, 23 Sep 2016 07:23:26 -0700, John Fastabend wrote:
>> On 16-09-23 05:55 AM, Jakub Kicinski wrote:
>>> On Fri, 23 Sep 2016 11:06:09 +0200, Jiri Benc wrote:
>>>> On Fri, 23 Sep 2016 08:34:29 +0200, Jiri Pirko wrote:
>>>>> So if I understand that correctly, this would need some "shared netdev"
>>>>> which would effectively serve only as a sink for all port netdevices to
>>>>> tx packets to. On RX, this would be completely avoided. This lower
>>>>> device looks like half zombie to me.
>>>> Looks more like a quarter zombie. Even tx would not be allowed unless
>>>> going through one of the ports, as all skbs without
>>>> METADATA_HW_PORT_MUX metadata_dst would be dropped. But it would be
>>>> possible to attach qdisc to the "lower" netdevice and it would actually
>>>> have an effect. On rx this netdevice would be ignored completely. This
>>>> is very weird behavior.
>>>>   
>>>>> I don't like it :( I wonder if the
>>>>> solution would not be possible without this lower netdev.
>>>> I agree. This approach doesn't sound correct. The skbs should not be
>>>> requeued.
>>> Thanks for the responses!
>> Nice timing we were just thinking about this.
>>
>>> I think SR-IOV NICs are coming at this problem from a different angle,
>>> we already have a big, feature-full per-port netdevs and now we want to
>>> spawn representators for VFs to handle fallback traffic.  This patch
>>> would help us mux VFR traffic on all the queues of the physical port
>>> netdevs (the ones which were already present in legacy mode, that's the
>>> lower device).
>> Yep, I like the idea in general. I had a slightly different approach in
>> mind though. If you look at __dev_queue_xmit() there is a void
>> accel_priv pointer (gather you found this based on your commit note).
>> My take was we could extend this a bit so it can be used by the VFR
>> devices and they could do a dev_queue_xmit_accel(). In this way there is
>> no need to touch /net/core/{filter, dst, ip_tunnel}.c etc. Maybe the
>> accel logic needs to be extended to push the priv pointer all the way
>> through the xmit routine of the target netdev though. This should look
>> a lot like the macvlan accelerated xmit device path without the
>> switching logic.
>>
>> Of course maybe the name would be extended to dev_queue_xmit_extended()
>> or something.
>>
>> So the flow on ingress would be,
>>
>>    1. pkt_received_by_PF_netdev
>>    2. PF_netdev reads some tag off packet/descriptor and sets correct
>>       skb->dev field. This is needed so stack "sees" packets from
>>       correct VF ports.
>>    3. packet passed up to stack.
>>
>> I guess it is a bit "zombie" like on the receive path because the packet
>> is never actually handled by VF netdev code per se and on egress can
>> traverse both the VFR and PF netdevs qdiscs. But on the other hand the
>> VFR netdevs and PF netdevs are all in the same driver. Plus using a
>> queue per VFR is a bit of a waste as its not needed and also hardware
>> may not have any mechanism to push VF traffic onto a rx queue.
>>
>> On egress,
>>
>>    1. VFR xmit is called
>>    2. VFR xmit calls dev_queue_xmit_accel() with some meta-data if needed
>>       for the lower netdev
>>    3. lower netdev sends out the packet.
>>
>> Again we don't need to waste any queues for each VFR and the VFR can be
>> a LLTX device. In this scheme I think you avoid much of the changes in
>> your patch and keep it all contained in the driver. Any thoughts?

The 'accel' parameter in dev_queue_xmit_accel() is currently only passed
to ndo_select_queue() via netdev_pick_tx() and is used to select the tx 
queue.
Also, it is not passed all the way to the driver specific xmit routine.  
Doesn't it require
changing all the driver xmit routines if we want to pass this parameter?

> Goes without saying that you have a much better understanding of packet
> scheduling so please bear with me :)  My target model is that I have
> n_cpus x "n_tc/prio" queues on the PF and I want to transmit the
> fallback traffic over those same queues.  So no new HW queues are used
> for VFRs at all.  This is a reverse of macvlan offload which AFAICT has
> "bastard hw queues" which actually TX for a separate software device.
>
> My understanding was that I can rework this model to have software
> queues for VFRs (#sw queues == #PF queues + #VFRs) but no extra HW
> queues (#hw queues == #PF queues) but then when the driver sees a
> packet on sw-only VFR queue it has to pick one of the PF queues (which
> one?), lock PF software queue to own it, and only then can it
> transmit.  With the dst_metadata there is no need for extra locking or
> queue selection.

Yes.  The VFPR netdevs don't have any HW queues associated with them and 
we would like
to use the PF queues for the xmit.
I was also looking into some way of passing the port id via skb 
parameter to the
dev_queue_xmit() call so that the PF xmit routine can do a directed 
transmit to a specifc VF.
Is skb->cb an option to pass this info?
dst_metadata approach would work  too if it is acceptable.


>
>> To address 'I wonder if the solution can be done without this lower
>> netdev' I think it can be but it creates two issues which I'm not sure
>> have a good solution.
>>
>> Without a lowerdev we either (a) give each VFR its own queue which I
>> don't like because it complicates mgmt and uses resources or (b) we
>> implicitly share queues. The later could be fine it just looks a bit
>> cleaner IMO to make it explicit.
>>
>> With regard to VF-PF flow rules if we allow matching on ingress port
>> then can all your flow rules be pushed through the PF netdevices or
>> if you want any of the VFR netdevs? After all I expsect the flow rule
>> table is actually a shared resource between all attached ports.
> With the VF-PF forwarding rules I was just inching towards re-opening
> the discussion on whether there should be an CPU port netdev.  I guess
> there are good reasons why there isn't so maybe let's not go there :)
> The meaning of PF netdevs in SR-IOV switchdev mode is "external ports"
> AFAICT which could make it cumbersome to reach the host.
