From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next RFC v2] switchdev: bridge: drop hardware forwarded
 packets
Date: Fri, 20 Mar 2015 14:03:03 -0700
Message-ID: <550C8B07.4010308@cumulusnetworks.com>
References: <1426870714-3225-1-git-send-email-roopa@cumulusnetworks.com> <550C54BC.4040509@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, sfeldma@gmail.com, jiri@resnulli.us,
	ronen.arad@intel.com, netdev@vger.kernel.org,
	Wilson Kok <wkok@cumulusnetworks.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33039 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977AbbCTVDG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 17:03:06 -0400
Received: by pabxg6 with SMTP id xg6so107134998pab.0
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 14:03:05 -0700 (PDT)
In-Reply-To: <550C54BC.4040509@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/20/15, 10:11 AM, John Fastabend wrote:
> On 03/20/2015 09:58 AM, roopa@cumulusnetworks.com wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> On a Linux bridge with bridge forwarding offloaded to switch ASIC,
>> there is a need to not re-forward frames that have already been
>> forwarded in hardware.
>>
>> Typically these are broadcast or multicast frames forwarded by the
>> hardware to multiple destination ports including sending a copy of
>> the packet to the cpu (kernel e.g. an arp broadcast).
>> The bridge driver will try to forward the packet again, resulting in
>> two copies of the same packet.
>>
>> These packets can also come up to the kernel for logging when they hit
>> a LOG acl rule in hardware. In such cases, you do want the packet
>> to go through the bridge netfilter hooks. Hence, this patch adds the
>> required checks just before the packet is being xmited.
>>
>> v2:
>> 	- Add a new hw_fwded flag in skbuff to indicate that the packet
>> 	is already hardware forwarded. Switch driver will set this flag.
>> 	I have been trying to avoid having this flag in the skb
>> 	and thats why this patch has been in my tree for long. Cant think
>> 	of other better alternatives. Suggestions are welcome. I have put
>> 	this under CONFIG_NET_SWITCHDEV to minimize the impact.
>>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>> Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
>> ---
> Interesting. I completely avoid this problem by not instantiating a
> software bridge ;)
>   When these pkts come up the stack I either use a
> raw socket to capture them, put a 'tc' ingress rule to do something,
> or have OVS handle them in some special way.
> It seems to me that this
> is where the sw/hw model starts to break when you have these magic
> bits to handle the packets differently.

  In-kernel bridge driver is proven very useful for us to run stp,
or recently igmp reports (dont know the details here) etc in software.
I wonder how you handle these. If you don't use the in-kernel bridge
driver, I suspect you down the lane you will end-up having to duplicate a
lot of things that bridge driver already does in your switch driver.
>
> How do you know to set the skb bit? Do you have some indicator in the
> descriptor? I don't have any good way to learn this on my hardware. But
> I can assume if it reached the CPU it was because of some explicit rule.

Right now we tag all packets except for some igmp frames so that they 
get handled by software (in kernel bridge driver).
(But the igmp frames check is a bit of a hack right now). We don't use 
it today, but, the sdk
can give us some details about the reason the packet was sent to CPU (It 
possibly gets it from the descriptor).
