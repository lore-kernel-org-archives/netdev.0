From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next RFC v2] switchdev: bridge: drop hardware forwarded
 packets
Date: Fri, 20 Mar 2015 11:30:01 -0700
Message-ID: <550C6729.5060706@gmail.com>
References: <1426870714-3225-1-git-send-email-roopa@cumulusnetworks.com> <550C54BC.4040509@intel.com> <CAE4R7bCC=VZerEfVRfn=NmQvE9bwQ-KGo7v77ghHOLAR5p5hwg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	"David S. Miller" <davem@davemloft.net>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	"Arad, Ronen" <ronen.arad@intel.com>,
	Netdev <netdev@vger.kernel.org>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:34687 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750929AbbCTSaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 14:30:18 -0400
Received: by obbgg8 with SMTP id gg8so84193314obb.1
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 11:30:18 -0700 (PDT)
In-Reply-To: <CAE4R7bCC=VZerEfVRfn=NmQvE9bwQ-KGo7v77ghHOLAR5p5hwg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/20/2015 11:13 AM, Scott Feldman wrote:
> On Fri, Mar 20, 2015 at 10:11 AM, John Fastabend
> <john.r.fastabend@intel.com> wrote:
>> On 03/20/2015 09:58 AM, roopa@cumulusnetworks.com wrote:
>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>
>>> On a Linux bridge with bridge forwarding offloaded to switch ASIC,
>>> there is a need to not re-forward frames that have already been
>>> forwarded in hardware.
>>>
>>> Typically these are broadcast or multicast frames forwarded by the
>>> hardware to multiple destination ports including sending a copy of
>>> the packet to the cpu (kernel e.g. an arp broadcast).
>>> The bridge driver will try to forward the packet again, resulting in
>>> two copies of the same packet.
>>>
>>> These packets can also come up to the kernel for logging when they hit
>>> a LOG acl rule in hardware. In such cases, you do want the packet
>>> to go through the bridge netfilter hooks. Hence, this patch adds the
>>> required checks just before the packet is being xmited.
>>>
>>> v2:
>>>        - Add a new hw_fwded flag in skbuff to indicate that the packet
>>>        is already hardware forwarded. Switch driver will set this flag.
>>>        I have been trying to avoid having this flag in the skb
>>>        and thats why this patch has been in my tree for long. Cant think
>>>        of other better alternatives. Suggestions are welcome. I have put
>>>        this under CONFIG_NET_SWITCHDEV to minimize the impact.
>>>
>>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>>> Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
>>> ---
>>
>> Interesting. I completely avoid this problem by not instantiating a
>> software bridge ;) When these pkts come up the stack I either use a
>> raw socket to capture them, put a 'tc' ingress rule to do something,
>> or have OVS handle them in some special way. It seems to me that this
>> is where the sw/hw model starts to break when you have these magic
>> bits to handle the packets differently.
>>
>> How do you know to set the skb bit? Do you have some indicator in the
>> descriptor? I don't have any good way to learn this on my hardware. But
>> I can assume if it reached the CPU it was because of some explicit rule.
>
> I was wondering that also, since there was no example.
>
> This features seems like it belongs in the bridge.  We already have
> BR_FLOOD to indicate whether unknown unicast traffic is flooded to a
> bridge port.  Can we add another BR_FLOOD_BCAST (or some name) for
> this new feature?  You would set/clear this flag on the bridge
> (master) port.  The default is set.  And now:
>
> - #define BR_AUTO_MASK          (BR_FLOOD | BR_LEARNING)
> + #define BR_AUTO_MASK          (BR_FLOOD | BR_FLOOD_BCAST | BR_LEARNING)
>
> Does this work for your use-case, Roopa?

I'm probably being a bit dense but I can't think of a case where I would
want pkts forwarded back to the hardware. If you could explain a bit
more why this would be useful that would help me at least. Maybe a flag
to disable forwarding on the port would work. Perhaps using the
BR_STATE_* bits would be good enough?

.John

>
> -scott
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


-- 
John Fastabend         Intel Corporation
