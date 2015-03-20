From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next RFC v2] switchdev: bridge: drop hardware forwarded
 packets
Date: Fri, 20 Mar 2015 14:23:09 -0700
Message-ID: <550C8FBD.2000903@gmail.com>
References: <1426870714-3225-1-git-send-email-roopa@cumulusnetworks.com> <550C54BC.4040509@intel.com> <550C8B07.4010308@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>, davem@davemloft.net,
	sfeldma@gmail.com, jiri@resnulli.us, ronen.arad@intel.com,
	netdev@vger.kernel.org, Wilson Kok <wkok@cumulusnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:33026 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751522AbbCTVX2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 17:23:28 -0400
Received: by obcxo2 with SMTP id xo2so87301125obc.0
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 14:23:28 -0700 (PDT)
In-Reply-To: <550C8B07.4010308@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/20/2015 02:03 PM, roopa wrote:
> On 3/20/15, 10:11 AM, John Fastabend wrote:
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
>>>     - Add a new hw_fwded flag in skbuff to indicate that the packet
>>>     is already hardware forwarded. Switch driver will set this flag.
>>>     I have been trying to avoid having this flag in the skb
>>>     and thats why this patch has been in my tree for long. Cant think
>>>     of other better alternatives. Suggestions are welcome. I have put
>>>     this under CONFIG_NET_SWITCHDEV to minimize the impact.
>>>
>>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>>> Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
>>> ---
>> Interesting. I completely avoid this problem by not instantiating a
>> software bridge ;)
>>   When these pkts come up the stack I either use a
>> raw socket to capture them, put a 'tc' ingress rule to do something,
>> or have OVS handle them in some special way.
>> It seems to me that this
>> is where the sw/hw model starts to break when you have these magic
>> bits to handle the packets differently.
>
>   In-kernel bridge driver is proven very useful for us to run stp,
> or recently igmp reports (dont know the details here) etc in software.
> I wonder how you handle these. If you don't use the in-kernel bridge
> driver, I suspect you down the lane you will end-up having to duplicate a
> lot of things that bridge driver already does in your switch driver.

I think that code is in need of some serious love before it is usable. I
actually don't know who is using STP anymore if anyone. I suspect
everyone is using their own agents. I know Stephen had RSTP code for
awhile. Anyways it all runs in userspace and doesn't depend on the sw
bridge. I think it is a better model to run the control protocols in
userspace like this. I'm not an expert though, maybe Stephen will chime
in.

>>
>> How do you know to set the skb bit? Do you have some indicator in the
>> descriptor? I don't have any good way to learn this on my hardware. But
>> I can assume if it reached the CPU it was because of some explicit rule.
>
> Right now we tag all packets except for some igmp frames so that they
> get handled by software (in kernel bridge driver).
> (But the igmp frames check is a bit of a hack right now). We don't use
> it today, but, the sdk
> can give us some details about the reason the packet was sent to CPU (It
> possibly gets it from the descriptor).
>

hmm I agree with Scott then it seems like if your just tagging every
packet (or nearly every packet) you can turn forwarding off at the
port layer. then we save the bit in the skb for something else. And I
guess if you turn forwarding off at the port layer and have the control
traffic handled by a userspace agent there is no need for the software
bridge which is my case. Just my opinion though.

>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
John Fastabend         Intel Corporation
