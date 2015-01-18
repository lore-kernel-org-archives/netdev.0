From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [RFC PATCH net-next] bridge: ability to disable forwarding on
 a port
Date: Sun, 18 Jan 2015 00:48:53 -0800
Message-ID: <54BB7375.2070803@cumulusnetworks.com>
References: <1421479975-62049-1-git-send-email-roopa@cumulusnetworks.com> <E4CD12F19ABA0C4D8729E087A761DC3505DF57DB@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "stephen@networkplumber.org" <stephen@networkplumber.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"jhs@mojatatu.com" <jhs@mojatatu.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"jiri@resnulli.us" <jiri@resnulli.us>,
	"tgraf@suug.ch" <tgraf@suug.ch>,
	"john.fastabend@gmail.com" <john.fastabend@gmail.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	"wkok@cumulusnetworks.com" <wkok@cumulusnetworks.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>
To: "Arad, Ronen" <ronen.arad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:40872 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751602AbbARIs4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 03:48:56 -0500
Received: by mail-pa0-f47.google.com with SMTP id kq14so32613293pab.6
        for <netdev@vger.kernel.org>; Sun, 18 Jan 2015 00:48:55 -0800 (PST)
In-Reply-To: <E4CD12F19ABA0C4D8729E087A761DC3505DF57DB@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/17/15, 1:14 PM, Arad, Ronen wrote:
>
>> -----Original Message-----
>> From: roopa@cumulusnetworks.com [mailto:roopa@cumulusnetworks.com]
>> Sent: Friday, January 16, 2015 11:33 PM
>> To: stephen@networkplumber.org; davem@davemloft.net; jhs@mojatatu.com;
>> sfeldma@gmail.com; jiri@resnulli.us; Arad, Ronen; tgraf@suug.ch;
>> john.fastabend@gmail.com; vyasevic@redhat.com
>> Cc: netdev@vger.kernel.org; wkok@cumulusnetworks.com;
>> gospo@cumulusnetworks.com
>> Subject: [RFC PATCH net-next] bridge: ability to disable forwarding on a port
>>
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> On a Linux bridge with bridge forwarding offloaded to a switch ASIC,
>> there is a need to not re-forward the frames that come up to the
>> kernel in software.
>>
>> Typically these are broadcast or multicast packets forwarded by the
>> hardware to multiple destination ports including sending a copy of
>> the packet to the kernel (e.g. an arp broadcast).
>> The bridge driver will try to forward the packet again, resulting in
>> two copies of the same packet.
>>
>> These packets can also come up to the kernel for logging when they hit
>> a LOG acl in hardware.
>>
>> This patch makes forwarding a flag on the port similar to
>> learn and flood and drops the packet just before forwarding.
>> (The forwarding disable on a bridge is tested to work on our boxes.
>> The bridge port flag addition is only compile tested.
>> This will need to be further refined to cover cases where a non-switch port
>> is bridged to a switch port etc. We will submit more patches to cover
>> all cases if we agree on this approach).
>>
>> Other ways to solve the same problem could be to:
>> - use the offload feature flag on these switch ports to avoid the
>> re-forward:
>> https://www.marc.info/?l=linux-netdev&m=141820235010603&w=2
>>
>> - Or the switch driver can mark or set a flag in the skb, which the bridge
>> driver can use to avoid a re-forward.
>>
> The proposed patch does not go along with the offload feature flag.
> The premise of the offload feature flag is that offloading is driven by the
> switch port driver without user intervention. This patch requires different
> setting for BR_FLOOD in the software bridge port and the switch port driver.
Even with the offload feature flag, there are a few bridge port 
attributes that can be set
from userspace which can be different for sw and hw. So, with this patch 
I was
trying to see if making it similar to the other existing flags would be 
better.
> The alternatives suggested (offload flag or skb flag) are better.

Glad to know your opinion.
>
> The proposed patch avoids re-forward but not without cost. For example in the
> case of unicast flood with local destination, the skb is cloned for each port
> before the forward avoidance in __br_forward. Is it acceptable overhead?

This patch places it in __br_forward to just make sure all the paths 
including the netfilter
hook is traversed for these packets. And plus it was written with 
minimal changes in mind.
We have not measured it but the extra overhead for these pkts that hit
the kernel has been negligible. But, I will look at the code to see if 
it can be avoided.

Thanks,
Roopa
